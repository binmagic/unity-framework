--[[
-- added by wsh @ 2017-11-30
-- UI管理系统：提供UI操作、UI层级、UI消息、UI资源加载、UI调度、UI缓存等管理
-- 注意：
-- 1、Window包括：Model、Ctrl、View、和Active状态等构成的一个整体概念
-- 2、所有带Window接口的都是操作整个窗口，如CloseWindow以后：整个窗口将不再活动
-- 3、所有带View接口的都是操作视图层展示，如CloseView以后：View、Model依然活跃，只是看不见，可看做切入了后台
-- 4、如果只是要监听数据，可以创建不带View、Ctrl的后台窗口，配置为nil，比如多窗口需要共享某控制model（配置为后台窗口）
-- 5、可将UIManager看做一个挂载在UIRoot上的不完全UI组件，但是它是Singleton，不使用多重继承，UI组件特性隐式实现
--]]

---@class UIManager:Singleton
local UIManager = BaseClass("UIManager", Singleton)

local UIRootPath = "GameFramework/UI"
local MainCamera = "GameFramework/JustForShake/Main Camera"
local ResourceManager = CS.GameEntry.Resource
local GameObject = CS.UnityEngine.GameObject
local Sound = CS.GameEntry.Sound
local LayerOrder = { "Scene", "Background", "UIResource", "Normal", "Info", "Dialog", "Guide", "TopMost", "TopCanvas" }
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Canvas = typeof(CS.UnityEngine.Canvas)
local Input = CS.UnityEngine.Input

local KeyCode_Escape = CS.UnityEngine.KeyCode.Escape
local WindowState = { Create = 0, Loading = 1, Open = 2, Close = 3, Destroying = 4 }

local EmptyParam = {}
local Default_OpenOptions = { anim = true, UIMainAnim = UIMainAnimType.AllHide }

-- 构造函数
local function __init(self)
    Logger.Log("UIManager:__init")

    -- 所有存活的窗体
    self.windows = {}
    self.windowsConfig = {}
    -- 所有可用的层级
    self.layers = {}
    -- 初始化组件
    self.transform = GameObject.Find(UIRootPath).transform

    self.blurList = {false,false,false,false}

    self.refCountMainCamera = 0
    self.mainCamera = GameObject.Find(MainCamera)
    local container = self.transform:Find("UIContainer")
    self.imgBlackScreen = container:Find('BlackScreen'):GetComponent(typeof(CS.UnityEngine.UI.Image))

    self.canvas = container:GetComponent(Canvas)
    self.rect = container:GetComponent(RectTransform)
    self.windowStack = list:new()
    self.otherWindowStack = list:new()
    self.UIMainAnim = nil
    -- 初始化层级
    self.layers = {}
    for i, layerName in ipairs(LayerOrder) do
        local layerPath = "UIContainer/"..layerName
        local layerObj = nil
        local trans = self.transform:Find(layerPath)
        if trans~=nil then
            layerObj = trans.gameObject
        end

        local layerConf = UILayer[layerName]
        if layerObj == nil then
            layerObj = GameObject(layerName, RectTransform)
            layerObj.transform:SetParent(container, false)
            local canvas = layerObj.transform:GetOrAddComponent(typeof(CS.UnityEngine.Canvas))
            canvas.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceCamera
            canvas.worldCamera = UIManager:GetInstance():GetUICamera()
            canvas.overrideSorting = true
            canvas.sortingLayerName = 'Default'
            canvas.sortingOrder = layerConf.OrderInLayer
        end
        local layer = UILayerComponent.New(self, layerConf.Name)
        layer:OnCreate(layerConf)
        self.layers[layerConf.Name] = layer
    end

    local layerConf = UILayer["World"]
    local layerObj = self.transform:Find("WorldUIContainer").gameObject
    local layer = UILayerComponent.New(self, layerObj)
    layer:OnCreate()
    self.layers[layerConf.Name] = layer
    self:AddListener()
end

local function __delete(self)
    self:DestroyAllWindow(true)
    self:RemoveListener()
    self:DeleteAllLayer()
    Logger.Log("UIManager:__delete")
end

local function DeleteAllLayer(self)
    for k,v in pairs(self.layers) do
        GameObject.Destroy(v)
    end
    self.layers= nil
end
local function AddListener(self)
    EventManager:GetInstance():AddListener(EventId.OnKeyCodeEscape, self.OnKeyCodeEscape)
end

local function RemoveListener(self)
    EventManager:GetInstance():RemoveListener(EventId.OnKeyCodeEscape, self.OnKeyCodeEscape)
end

-- 获取窗口
local function GetWindow(self, ui_name)
    return self.windows[ui_name]
end

local function GetLayer(self,layerName)
    return self.layers[layerName]
end

local function GetScaleFactor(self)
    return self.canvas.scaleFactor
end

local function GetWindowConfig(self, ui_name)
    local configPath = UIConfig[ui_name]
    assert(configPath, "No window named : "..ui_name..".You should add it to UIConfig first!")

    local config = self.windowsConfig[ui_name]
    if config == nil then
        _, config = next(require(configPath))
        self.windowsConfig[ui_name] = config
    end
    return config
end

local function ProtectCall(fun, ...)
    local ok, msg = XPCALL(fun, debug.traceback, ...)
    if not ok then
        local now = UITimeManager:GetInstance():GetServerSeconds()
        local str = "UIManager Error:"..msg
        CommonUtil.SendErrorMessageToServer(now, now, str)
        Logger.LogError(str)
    end
end

local function PlayAnimation(go, animName)
    if IsNull(go) or not go.activeSelf then
        return
    end

    local ani = go:GetComponent_Animator()
    if IsNull(ani) then
        return
    end

    if not animName then
        return
    end
    
    local duration = ani:GetAnimationClipLength(animName)
    if duration > 0.01 then
        local hashId = GlobalCache.Animator_StringToHash(animName)
        ani:Play(hashId,0,0)
        return true, duration
    end

    return false
end

local function PlayMoveInAnim(self, window)
    if not window.OpenOptions.anim then
        return
    end

    local go = window.View.gameObject
    local prefabName = PathUtil.GetFileNameWithoutExtension(window.PrefabPath)
    local ok = PlayAnimation(go, prefabName .. "_movein")
    if not ok then
        PlayAnimation(go, "CommonPopup_movein")
    end
end

local function PlayMoveOutAnim(self, window)
    local go = window.View.gameObject
    local prefabName = PathUtil.GetFileNameWithoutExtension(window.PrefabPath)
    local ok, duration = PlayAnimation(go, prefabName .. "_moveout")
    if not ok then
        ok, duration = PlayAnimation(go, "CommonPopup_moveout")
    end
    return ok, duration
end

-- 关闭窗口
local function InnerCloseWindow(self, window)
    if window then
        if window.View:GetActive() then
            -- 这里没做销毁，这个函数下面的那个函数有销毁
            if window.state ~= WindowState.Loading then
                window.View:SetActive(false)
            end
        end
        window.State = WindowState.Close
    end
end

local function Startup(self)
end

local function OnKeyCodeEscape(data)
    UIManager:GetInstance():KeyCodeEscape()
end


local function KeyCodeEscape(self)

    -- 如果在guide和loading中，那么就直接弹出退出游戏
    if DataCenter.GuideManager:InGuide()
            or AppStartupLoading:GetInstance():IsLoading()
    --CS.ApplicationLaunch.Instance.Loading.IsLoading or
    --CS.SceneManager.IsInPVE() 
    then

        UIUtil.ShowMessage(Localization:GetString("dialog_message_exit_confirm"), 2, GameDialogDefine.CONFIRM, GameDialogDefine.CANCEL,
                function()
                    Logger.Log("#app# call CS.ApplicationLaunch.Instance:Quit in function KeyCodeEscape 1!")
                    CS.ApplicationLaunch.Instance:Quit()
                end)
        return
    end

    local stack = nil
    if self.otherWindowStack.length > 0 then
        stack = self.otherWindowStack
    elseif self.windowStack.length > 0 then
        stack = self.windowStack
    end

    if stack == nil then
        UIUtil.ShowMessage(Localization:GetString("dialog_message_exit_confirm"), 2, GameDialogDefine.CONFIRM, GameDialogDefine.CANCEL, function()
            Logger.Log("#app# call CS.ApplicationLaunch.Instance:Quit in function KeyCodeEscape 2!")
            CS.ApplicationLaunch.Instance:Quit()
        end)
    else
        local topWin = stack:tail()
        if topWin.Name == UIWindowNames.UIPVEScene or topWin.Name == UIWindowNames.UIParkourBattleMain or topWin.Name == UIWindowNames.UIParkourBattleLose or topWin.Name == UIWindowNames.UIParkourBattleWin then
            return
        end

        self:DestroyWindow(topWin.Name, OpenWinAnimTrue)
    end
end

-- 这里定义几个函数，目的是避免无效的闭包开销
local function Window_OnCreate(thiz)
    thiz:OnCreate()
end

local function Window_OnEnable(thiz)
    thiz:OnEnable()
end

local function Window_SetBlurObj(instance, ...)
    instance:SetBlurObj(...)
end

local function Window_TryRecoverMainCamera(thiz)
    if thiz ~= nil then thiz:TryRecoverMainCamera() end
end

-- 打开窗口
--[[ 
    参数1：窗口名
    参数2：可选参数，窗口打开选项
    参数3……：用户数据，不要用table作为用户数据
    
    窗口打开选项
    options = {
        打开窗口时是否播放动画
        anim = true/false
        
        窗口是否常驻内存不释放
        dontdestroy = true/false,
        
        关闭窗口时要返回到前一窗口
        back = { ui = "ui_name", anim = true/false },
        
        打开窗口时，主界面做动画 (只有Layer = Background,UIResource,Normal,Guide层才做)
        UIMainAnim = UIMainAnimType.AllHide,
                    (UIMainAnimType为动画枚举)
                         1:主界面上下左右全部隐藏
                         2:主界面上部保留（资源条和头像），下左右全部隐藏
         示例：
           1.默认options为空做UIMainAnimType.LeftRightBottomHide动画 
                例如 UIManager:GetInstance():OpenWindow("UIPop")
           2.打开界面需要主界面做UIMainAnimType.AllHide动画 需要在打开界面写 
                例如 UIManager:GetInstance():OpenWindow("UIPop",{anim = true,UIMainAnim = UIMainAnimType.AllHide})
           3.有界面1，打开的新界面2需要隐藏界面1，返回时显示界面1 需要在打开界面写 
                    UIManager:GetInstance():OpenWindow("UIPop", { anim = true，back = {ui = "UIDemo2", anim = false} }, "user data")
           4.有界面1，打开的新界面2需要和界面1共同显示的 需要在打开界面写 
                    UIManager:GetInstance():OpenWindow("UIPop", OpenWinAnimTrue, "user data")
           5.特殊情况：界面1关闭打开界面2不做动画，界面2关闭做动画 需要这样做
                     界面1关闭时写：
                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIBookMark,OpenWinAnimTrue)
                        UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBookMarkPositionCollect,OpenWinAnimTrue)
                     界面2关闭时写
                         UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBookMark,{anim = true,UIMainAnim = UIMainAnimType.LeftRightBottomShow})
             
       
    }
   
    示例：
    1. 打开窗口，默认情况下播放窗口打开动画
    需要播放动画的窗口在其根结点添加 Animator，播放动画时，先查找 Animator 中是否有与窗口
    同名的动画，如 "UISearch_movein"，若找不到同名动画时，播放通用弹出动画 CommonPopup_movein
    UIManager:GetInstance():OpenWindow("UIPop")
    
    2. 打开窗口，不播放打开动画
    UIManager:GetInstance():OpenWindow("UIPop", OpenWinAnimFalse, "user data")
    
    3. 打开窗口，会关闭指定窗口，如 UIOther，并在此窗口关闭时，自动返回 UIOther，在返回 UIOther 时，UIOther是否播放打开动画由 back.anim 控制
    UIManager:GetInstance():OpenWindow("UIPop", { anim = true, back = { ui = "UIOther", anim = true })
]]
local function OpenWindow(self, ui_name, ...)
     if ui_name == UIWindowNames.UIParkourBattleWin then
        Logger.Debug(debug.traceback('#UIManager# OpenWindow UIParkourBattleWin!', 5))
    end
    if ui_name == UIWindowNames.UIScrollPack then
        local p
        local c = select('#', ...)
        if (c > 1) then
            p = (select(2, ...))
        end
        if p then
            local packageInfo = p
            local id = packageInfo:getID()
            if id == nil or id == -1 then
                Logger.Debug(debug.traceback('#lxrTest# 打开UI单独礼包界面 UIScrollPack,礼包ID:'..id, 1))
            end
        end
    end
    Logger.Debug('#UIManager# OpenWindow name:', tostring(ui_name))
    
    --跨服时不能打开的界面，给予提示
    if self:IsUIShieldByCross(ui_name) then
        UIUtil.ShowTipsId(379004)
        return
    end

    local config = GetWindowConfig(self, ui_name)
    if config.Layer == UILayer.Background or config.Layer == UILayer.Normal then
        if not DataCenter.GuideManager:IsCanOpenUI(ui_name) then
            UIUtil.ClickUICloseWorldUI()
            return
        end
        if ui_name ~= UIWindowNames.UIBuildUpgradeAddDes and ui_name ~= UIWindowNames.UIItemTips
                and ui_name ~= UIWindowNames.UIHeroTip and ui_name ~= UIWindowNames.UIFormationTip
                and ui_name ~= UIWindowNames.UIMainPromptView and ui_name ~= UIWindowNames.UIArmyTips 
                and ui_name ~= UIWindowNames.UIAllianceBossWorldPointTipPanel then
            UIUtil.ClickUICloseWorldUI()
        end
    end

    local window = self.windows[ui_name]

    if window ~= nil and window.State == WindowState.Create then
        Logger.Log("OpenWindow create, not done ", ui_name)
        return
    end

    if window ~= nil and window.State == WindowState.Loading then
        Logger.Log("OpenWindow loading, not done ", ui_name)
        return
    end

    if window ~= nil and window.State == WindowState.Destroying and window.CloseTimer ~= nil then
        window.CloseTimer:Stop()
        window.CloseTimer = nil
        self:OnDestroyWindow(window)
        window = nil
    end

    --
    -- 创建窗口
    --
    if not window then
        window = UIWindow.New()
        self.windows[ui_name] = window

        local layer = self.layers[config.Layer.Name]
        assert(layer, "No layer named : "..config.Layer.Name..".You should create it first!")

        if config.Ctrl then
            window.Ctrl = config.Ctrl.New()
        end
        if config.View then
            window.View = config.View.New(layer, ui_name, window.Ctrl, config)
        end

        window.priority = config.Priority
        window.Name = ui_name
        window.Layer = layer
        window.PrefabPath = config.PrefabPath
        window.State = WindowState.Create
    end

    --
    -- 设置用户传递过来的参数
    --
    local p = EmptyParam
    local arg1 = select(1, ...)
    if type(arg1) == "table" then
        window.OpenOptions = arg1

        local c = select('#', ...)
        if (c > 1) then
            p = SafePack(select(2, ...))
        end
    else
        window.OpenOptions = Default_OpenOptions --{ anim = true, UIMainAnim = UIMainAnimType.AllHide }

        local c = select('#', ...)
        if (c > 0) then
            p = SafePack(...)
        end
    end
    window.View:SetUserData(p)

    if window.OpenOptions.UIMainAnim ~= nil and self.UIMainAnim == nil then
        if self:NeedHideMainUI(ui_name) and (config.Layer == UILayer.Background or config.Layer == UILayer.Normal or config.Layer == UILayer.Guide) then
            local UIMain = self.windows[UIWindowNames.MainUI_SU]
            if UIMain and UIMain.InstanceRequest and UIMain.InstanceRequest.isDone then
                self.UIMainAnim = window.OpenOptions.UIMainAnim
                --Logger.Log("OpenWindow UIMain.View:PlayAnim, " .. ui_name .. " " .. tostring(self.UIMainAnim))
                UIMain.View:PlayAnim(window.OpenOptions.UIMainAnim)
                --EventManager:GetInstance():Broadcast(EventId.SetGoldStoreBtnVisible, window.OpenOptions.UIMainAnim)
            end
        end
        if self:GetStackWindowCount() > 0 then
            Logger.Debug("OpenWindow ", ui_name)
            local index = 0
            for i, v in ilist(self.windowStack) do
                Logger.Debug(string.format("WindowStack %d %s", index, v.Name))
                index = index + 1
            end
        end
    end


    if config ~= nil and config.requireBlack then
        self:ToggleBlackScreen(true)
    end

    -- 实例化并显示
    self:PushStackWindow(window, window.OpenOptions.hideTop)
    if not window.View.gameObject then
        local blurRtOrder = -1

        --优先级：OpenOptions.isBlur > config.isBlur
        local isBlur = window.View:IsNeedShowBlur(window.OpenOptions)
        --local isBlur = config.isBlur
        --if window.OpenOptions.isBlur ~= nil then
        --    isBlur = window.OpenOptions.isBlur
        --end
        
        if isBlur then
            blurRtOrder = self:AddBlur()
            window.blurRtOrder = blurRtOrder
            --BlurURP 截屏需要等待1-2帧，所以延迟 0.1s执行延迟创建界面
            window.timer = TimerManager:GetInstance():DelayInvoke(function()
                self:InnerCreateWindow(window, config, blurRtOrder)
            end, 0.15)
        else
            self:InnerCreateWindow(window, config)
        end
    else
        window.View:SetActive(true)
        self:OnCreateWindow(window, config)
    end

    if not self:NoSoundPlayed(ui_name) then
        SUSoundUtil.PlayUISoundEffect(ui_name)
    end
    self:StopWorldCameraMove(window)

    if self:IsShouldPauseRole(config, ui_name) then
        if (DataCenter.BattleLevel:GetRoleMgr()) then
            DataCenter.BattleLevel:GetRoleMgr():PauseAll()
        end
    end
    DataCenter.QuestArrowManager:ResetLastRecordTime()
end

function UIManager:NoSoundPlayed(ui_name)
    if ui_name == UIWindowNames.UI_DayNight then
        return true
    end
    return false
end

function UIManager:GetBlurImgObj()
    if self.blurImgObj ~= nil then
        return self.blurImgObj
    end
    local blurImgGo = GameObject.Find("UIContainer/blurImg")
    if blurImgGo ~= nil then
        self.blurImgObj = blurImgGo.gameObject
    end
end

function UIManager:InnerCreateWindow(window, config, blurRtOrder)
    local timeStamp1 = UITimeManager:GetInstance():GetLocalTime()

    window.State = WindowState.Loading
    window.View.HideMainCamera = config.HideMainCamera or false
    window.InstanceRequest = CommonUtil.LoadResAsync(window.PrefabPath,
            function (request)
                if request.isError then
                    return
                end

                local timeStamp2 = UITimeManager:GetInstance():GetLocalTime()
                local cost = timeStamp2 - timeStamp1
                Logger.DebugFormat('#zlh# ==================InnerCreateWindow winName:[%s] cost: %s===================', window.Name,  cost)
                
                local go = request.gameObject
                local trans = go.transform
                trans:SetParent(window.Layer.transform, false)
                trans:SetName(_ToID(window.Name))

                --拷贝模糊背景object
                local _blurObj = self:GetBlurImgObj()
                if _blurObj ~= nil and blurRtOrder ~= nil and blurRtOrder >0 then
                    local blurItem = _blurObj:GameObjectSpawn(trans.parent)
                    if blurItem ~= nil then
                        local siblingIndex = trans:GetSiblingIndex()
                        blurItem.transform:SetSiblingIndex(siblingIndex)
                        trans:SetSiblingIndex(siblingIndex + 1)
                        ProtectCall(Window_SetBlurObj, window.View, blurItem, blurRtOrder)
                    end
                end

                --由view管理
                ProtectCall(Window_OnCreate, window.View)

                if window.State ~= WindowState.Close and window.State ~= WindowState.Destroying then
                    window.View.activeSelf = true
                    window.View.gameObject:SetActive(true)
                    ProtectCall(Window_OnEnable, window.View)

                    --直接将当前所在UI所在的Layer重排下
                    UIManager.Instance:ResortLayer(window.Layer)
                    self:OnCreateWindow(window, config)
                end

            end, window.Layer.transform)

    if window.InstanceRequest then
        local defPriority = window.priority or 4
        window.InstanceRequest:SetPriority(defPriority)
    end
end

function UIManager:NeedHideMainUI(ui_name)
    if ui_name == UIWindowNames.UIWorldBlackTile 
            or ui_name == UIWindowNames.UIWorldNoSelectable
            or ui_name == UIWindowNames.UIWorldPoint
    then
        return false
    end
    return true
end

-------------------------UI与特效排序-----------------------
function UIManager:ResortLayer(layer)
    local baseLayerOrder = layer:GetOrderInLayer()
    --遍历一下当前所有的window
    for _, window in pairs(self.windows) do
        if window.Layer == layer then
            window.View:ResortOrder(baseLayerOrder)
        end
    end
end
-----------------------------------------------------------

local function IsShouldPauseRole(self, config, ui_name)
    if ui_name == UIWindowNames.UILensBlackEdge or ui_name == UIWindowNames.UIWorldBlackTile then
        return false
    end
    if config.Layer == UILayer.Normal and ui_name ~= UIWindowNames.UIMain and ui_name ~= UIWindowNames.MainUI_SU then
        return true
    end
    if (ui_name == UIWindowNames.UI_GuideFullScreenDialog or
            ui_name == UIWindowNames.UI_GuideMoviePrologue or
            ui_name == UIWindowNames.UI_BuildUseFullScreenDialog or
            ui_name == UIWindowNames.UI_PicGuide or
            ui_name == UIWindowNames.UIGuideIntroBubble or
--            ui_name == UIWindowNames.UIPVELevelHeroSelect or
            ui_name == UIWindowNames.UIBagView or
            --            ui_name == UIWindowNames.UIBluePrint or
--            ui_name == UIWindowNames.UITalentChoose or
--            ui_name == UIWindowNames.UIFactory2 or
            ui_name == UIWindowNames.UICommonMessageTip or
            ui_name == UIWindowNames.UIPVELevelLoading) then
        return true
    end
    return false
end

--function UIManager:CanResumeRole()
    --if DataCenter.GuideManager:IsShouldPauseRole() then
        --return false
    --end
    --local canResumeRole = true
    --for i, window in ilist(self.windowStack) do
        --local windowName = window.Name
        --local layerCfg = window.Layer:GetConfig()

        --if self:IsShouldPauseRole(layerCfg, windowName) then
            --canResumeRole = false
            --break
        --end
    --end
    --return canResumeRole
--end

-- 遍历所有打开的窗口
function UIManager:EnumWindows(fn)
    for i, window in ilist(self.windowStack) do
        fn(window)
    end
end

local function StopWorldCameraMove(self, window)
    if window.Name == UIWindowNames.UIMain or
            window.Layer:GetName() == UILayer.Guide.Name or
            window.Layer:GetName() == UILayer.TopMost.Name or
            window.Layer:GetName() == UILayer.Info.Name or
            window.Layer:GetName() == UILayer.Scene.Name or
            window.Layer:GetName() == UILayer.World.Name or
            window.Name == UIWindowNames.UIMainMiniMap or
            window.Name == UIWindowNames.UISearchLod or
            window.Name == UIWindowNames.UINoInput
    then
        return
    end
    local world = CS.SceneManager.World
    if world ~= nil then
        if DataCenter.GuideManager and DataCenter.GuideManager:IsOnRadarMoveAndClickCamera() then
            return
        end
        pcall(function() world:StopCameraMove() end)
    end
end

local function InnerDestroyWindow(self, window)
    ProtectCall(function()
        if window.View:HideBlur() then
            --如果删除成功，计数-1
            self:RemoveBlur(window.blurRtOrder)
        end

        if window.Ctrl ~= nil and window.Ctrl.Delete ~= nil then window.Ctrl:Delete() end
        window.View:Delete()
    end)

    if window.timer~=nil then
        window.timer:Stop()
        window.timer = nil
    end

    if window.InstanceRequest ~= nil then
        if window.Name == UIWindowNames.MainUI_SU then
            -- 主UI上有动态创建的元素，删除主UI的时候去删除这些元素一堆问题
            -- 暂时不折腾了，直接删除prefab，用新的prefab再重新创建
            window.InstanceRequest:Destroy(false)
        else
            window.InstanceRequest:Destroy()
        end
        window.InstanceRequest = nil
    end
    self.windows[window.Name] = nil
end

local function OnDestroyWindow(self, win)
    InnerCloseWindow(self, win)
    InnerDestroyWindow(self, win)
    --self:TryMuteWorldScopeAudio();
    EventManager:GetInstance():Broadcast(EventId.CloseUI, win.Name)
end

function UIManager:OnCreateWindow(window, config)
    window.State = WindowState.Open
    self:PlayMoveInAnim(window)
    --self:TryMuteWorldScopeAudio()
    EventManager:GetInstance():Broadcast(EventId.OpenUI, window.Name)
end

-- 销毁窗口
--[[
    options = {
        关闭窗口时是否播放关闭动画
        anim = true/false
        
        关闭窗口时，主界面做动画(只有Layer = Background,UIResource,Normal,Guide层才做)
        UIMainAnim = UIMainAnimType.AllShow,
                    (UIMainAnimType为动画枚举)
                         1:主界面上下左右全部显示
                         2:主界面上部不动（资源条和头像），下左右全部显示
       规则：
          1.如果打开该界面时没有做主界面动画则关闭也不会做
          2.有界面1，打开的新界面2需要隐藏界面1，返回时显示界面1 此时界面2关闭不回做动画，只有界面1关闭才会做动画
          3.如果强制界面关闭做动画 需要写
               UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBookMark,{anim = true,UIMainAnim = UIMainAnimType.LeftRightBottomShow})
          4.如果强制界面关闭不做动画 需要写
               UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBookMark,OpenWinAnimTrue)
]]

local function GetUIMainShowAnim(animType)
    if animType == UIMainAnimType.AllHide then
        return UIMainAnimType.AllShow
    elseif animType == UIMainAnimType.LeftRightBottomHide then
        return UIMainAnimType.LeftRightBottomShow
    else
        return UIMainAnimType.AllShow
    end
end

local function PlayUIMainShowAnimation(self, animName, window)
    local count = self:GetStackWindowCount()
    local topWindow = self:GetStackTopWindow()
    if topWindow ~= nil then
        print("***close window: count: " .. tostring(count) .. " topWindowName: " .. tostring(topWindow.Name))
    end

    if count == 0 or count == 1 and topWindow == window then
        --Logger.Log("DestroyWindow closeOptions.UIMainAnim " .. tostring(closeOptions.UIMainAnim) .. " " .. tostring(self:IsCanDoShowAnim(window)))
        if animName then
            local UIMain = self.windows[UIWindowNames.MainUI_SU]
            if UIMain and UIMain.InstanceRequest and UIMain.InstanceRequest.isDone then
                --Logger.Log("DestroyWindow UIMain.View:PlayAnim, " .. window.Name .. " " .. animName)
                UIMain.View:PlayAnim(animName)
                --EventManager:GetInstance():Broadcast(EventId.SetGoldStoreBtnVisible, animName)
                self.UIMainAnim = nil
            end
        end
    end
end

local function OnAfterWindowDestroy(self, ui_name)
    if ui_name == UIWindowNames.UIFarm  or ui_name == UIWindowNames.UIFarmGather or ui_name == UIWindowNames.UIPasture or ui_name == UIWindowNames.UIFormationSelectListNew or ui_name == UIWindowNames.UICapacityFull then
        if CS.SceneManager.World then
            CS.SceneManager.World:QuitFocus(LookAtFocusTime)
        end
        EventManager:GetInstance():Broadcast(EventId.ClickFarmBuildHideEffect)
    end

    if DataCenter:IsValid('UIPopWindowManager') then
        DataCenter.UIPopWindowManager:OnWindowDestroy(ui_name)
    end

    if ui_name == "UIDebugChooseServer" then
        return
    end
    --if self:CanResumeRole() then
        --if (DataCenter.BattleLevel:GetRoleMgr()) then
            --DataCenter.BattleLevel:GetRoleMgr():ResumeAll()
        --end
    --end
    DataCenter.QuestArrowManager:ResetLastRecordTime()
end

local function DestroyWindow(self, ui_name, closeOptions)
    local window = self.windows[ui_name]
    if not window or window.State == WindowState.Destroying then
        return
    end
    EventManager:GetInstance():Broadcast(EventId.BeforeCloseUI, ui_name)
    Logger.Debug('#UIManager# DestroyWindow name:', tostring(ui_name))

    --关闭黑屏
    local config = GetWindowConfig(self, ui_name)
    if config ~= nil and config.requireBlack then
        self:ToggleBlackScreen(false)
    end

    if not closeOptions then
        closeOptions = OpenWinAnimTrue
    end

    local playEffectWhenOpen = closeOptions.playEffect
    --Logger.Log("DestroyWindow stack count: " .. tostring(self:GetStackWindowCount()) .. " " .. (self:GetStackWindowCount() >= 1 and self:GetStackTopWindow().Name or ""))
	
	if closeOptions.UIMainAnim == nil then
		--closeOptions.UIMainAnim = GetUIMainShowAnim(self.UIMainAnim)
		local uiMainAnim = GetUIMainShowAnim(self.UIMainAnim)
		self:PlayUIMainShowAnimation(uiMainAnim, window)
    else
        self:PlayUIMainShowAnimation(closeOptions.UIMainAnim, window)
    end

    local ok, duration
    if closeOptions.anim then
        ok, duration = self:PlayMoveOutAnim(window)
        EventManager:GetInstance():Broadcast(EventId.PlayCloseUIAnim,ui_name)
    end
    self:PopStackWindow(window)
    if closeOptions.anim and ok then
        --如果有关闭动画的话提前尝试恢复相机
        ProtectCall(Window_TryRecoverMainCamera, window.View)
        local closeTimer = TimerManager:GetInstance():GetTimer(duration or 0.2, function()
            window.CloseTimer = nil
            --Logger.Log("DestroyWindow window.CloseTimer = nil, " .. ui_name)
            if not IsNull(window.View.gameObject) then
                --Logger.Log("DestroyWindow onDestroy, " .. ui_name)
                self:OnDestroyWindow(window)
            end
        end, nil, true, false, true)

        closeTimer:Start()
        window.CloseTimer = closeTimer
        window.State = WindowState.Destroying
    else
        self:OnDestroyWindow(window)
    end

    self:OnAfterWindowDestroy(ui_name)

    --self:PlayUIMainShowAnimation(closeOptions.UIMainAnim, window)

    if playEffectWhenOpen == nil or playEffectWhenOpen == true then
        --Sound:PlayEffect(_ToID(SoundAssets.Music_Effect_Close))
    end
end

local function IsWindowOpen(self,ui_name)
    local window = self.windows[ui_name]
    if not window then
        return false
    end
    return window.State == WindowState.Create or window.State == WindowState.Loading or window.State == WindowState.Open
end

-- 销毁层级所有窗口
local function DestroyWindowByLayer(self, layer)
    local windows = {}
    for k, v in pairs(self.windows) do
        windows[k] = v
    end

    for k,v in pairs(windows) do
        if v.Layer:GetName() == layer.Name and v.Name ~= UIWindowNames.MainUI_SU and v.Name ~= UIWindowNames.UIPVEScene then
            local ui_name = v.Name
            self:PlayUIMainShowAnimation(GetUIMainShowAnim(self.UIMainAnim), v)
            self:PopStackWindow(v)
            self:OnDestroyWindow(v)
            self:OnAfterWindowDestroy(ui_name)
        end
    end
    --if layer == UILayer.Normal or layer == UILayer.Background or layer == UILayer.Guide then
    --    local UIMain = self.windows[UIWindowNames.UIMain]
    --    if UIMain then
    --        UIMain.View:PlayAnim(UIMainAnimType.ChangeAllShow)
    --    end
    --end
end

-- 销毁所有窗口
local function DestroyAllWindow(self)
    -- 打印关闭堆栈
    local str = "#UIManager# DestroyAllWindow"
    if App.IsEditor() or App.IsDebug() then
        str = debug.traceback('#UIManager# DestroyAllWindow ', 5)
    end
    Logger.Log(str)

    local windows = {}
    for k, v in pairs(self.windows) do
        windows[k] = v
    end

    for k,v in pairs(windows) do
        local ui_name = v.Name
        --print(string.format("<color=#ffff00>DestroyAllWindow %s</color>", tostring(ui_name)))
        --self:PopStackWindow(v)
        InnerCloseWindow(self, v)
        InnerDestroyWindow(self, v)
        self:OnAfterWindowDestroy(ui_name)
    end
    self.windows = {}
    self.windowStack:clear()
    self.otherWindowStack:clear()
    --self:TryMuteWorldScopeAudio();
end

-- 是否有打开界面
local function HasWindow(self)
    for k,v in pairs(self.windows) do
        local layerName = v.Layer:GetName()
        if layerName == UILayer.Normal.Name or layerName == UILayer.Background.Name or layerName == UILayer.Guide.Name then
            return true
        end
    end
    return false
end

local function HideAllWindowByGuideTalk(self)
    self.hideWindows = {}
    for k,v in pairs(self.windows) do
        if v.Name ~= UIWindowNames.TouchScreenEffect and v.Name ~= UIWindowNames.MainUI_SU and
                v.Name ~= UIWindowNames.UISceneNoInput and v.Name ~= UIWindowNames.UINoInput and
                v.Name ~= UIWindowNames.UIDeadly and v.Name ~= UIWindowNames.UIGuideTalk then
            if v.State ~= WindowState.Close and v.State ~= WindowState.Destroying and v.View:GetActive() then
                v.View:SetActive(false)
                self.hideWindows[v.Name] = v
            end
        end
    end
end

local function ShowAllWindowByGuideTalk(self)
    if table.count(self.hideWindows) > 0 then
        for k,v in pairs(self.hideWindows) do
            if v.State ~= WindowState.Close and v.State ~= WindowState.Destroying then
                v.View:SetActive(true)
            end
        end
    end
    self.hideWindows = nil
end

--只有主界面显示
local function CheckIfIsMainUIOpenOnly(self, ignoreGuide)
    for _, v in pairs(self.windows) do
        if v.Name ~= UIWindowNames.TouchScreenEffect and
                v.Name ~= UIWindowNames.UICommonMessageTip and
--                v.Name ~= UIWindowNames.UINpcTalkLayer and
                v.Name ~= UIWindowNames.UIArrow and
                v.Name ~= UIWindowNames.MainUI_SU and
                v.Name ~= UIWindowNames.UINoticeHeroTips and
                v.Name ~= UIWindowNames.UINoticeTips and
                v.Name ~= UIWindowNames.UIMainPromptView and
                v.Name ~= UIWindowNames.UIGuideArrow and
                v.Name ~= UIWindowNames.UIGuideArrowNew and
                v.Name ~= UIWindowNames.UISceneNoInput and
                v.Name ~= UIWindowNames.UINoInput and
                v.Name ~= UIWindowNames.UIMainMiniMap and
                v.Name ~= UIWindowNames.UIMainMsgView and
                v.Name ~= UIWindowNames.UICommonMessageBar and
--                v.Name ~= UIWindowNames.UIPlayerLevelUp and
                v.Name ~= UIWindowNames.UIDeadly and
                v.Name ~= UIWindowNames.UITutorialAnimation and
                v.Name ~= UIWindowNames.UICameraInfo and
                v.Name ~= UIWindowNames.UIBagPickUp and
                v.Name ~= UIWindowNames.UICommonSingleMsgBar and 
                v.Name ~= UIWindowNames.UIAllianceCityBar and
                v.Name ~= UIWindowNames.UIActivityNoticeTip and
                v.Name ~= UIWindowNames.UIScreenCenterTips and
                v.Name ~= UIWindowNames.UIBuildTimeOfChange and
                v.Name ~= UIWindowNames.UIActivityTip and
                v.Name ~= UIWindowNames.UIBarrelHeroBottomInfo and 
                v.Name ~= UIWindowNames.UIBuildUpgradeTip and
                v.Name ~= UIWindowNames.UIWorldTileUI and 
                v.Name ~= UIWindowNames.UINoticeEquipTips and
                v.Name ~= UIWindowNames.UIGloryDeclareWarPopTips and
                v.Name ~= UIWindowNames.UIGloryDeclareWarLastHit
        then
            if self:IsWindowOpen(v.Name) then
                return false, v.Name
            end
        end
    end
    if not ignoreGuide and DataCenter.GuideManager:InGuide() then
        return false, "InGuide"
    end
    return true
end

local function PushStackWindow(self, window, hideTop)
    if window.Name == UIWindowNames.MainUI_SU or
            window.Name == UIWindowNames.UIPVELoading or
            window.Name == UIWindowNames.UIGuideArrow or
            window.Name == UIWindowNames.UIGuideArrowNew or
            window.Name == UIWindowNames.UIArrow or
            window.Name == UIWindowNames.UIGuideHeadTalk or
            window.Layer:GetName() == UILayer.TopMost.Name or
            window.Layer:GetName() == UILayer.Scene.Name or
            window.Layer:GetName() == UILayer.World.Name or
            window.Name == UIWindowNames.UIWorldTileUI or
            window.Name == UIWindowNames.UIBagPickUp or
            window.Name == UIWindowNames.UIMainPromptView or
            window.Name == UIWindowNames.UICameraInfo or
            window.Name == UIWindowNames.UIMainMiniMap or
            window.Name == UIWindowNames.UIActivityNoticeTip or
            window.Name == UIWindowNames.UIScreenCenterTips or
            window.Name == UIWindowNames.UIBuildTimeOfChange or
            window.Name == UIWindowNames.UIActivityTip or
            window.Name == UIWindowNames.UIBarrelHeroBottomInfo or
            window.Name == UIWindowNames.UIFormationDispatchTip or 
            window.Name == UIWindowNames.UIMedalGet or
            window.Name == UIWindowNames.UIGloryDeclareWarPopTips or
            window.Name == UIWindowNames.UIGloryDeclareWarLastHit
    then
        return
    elseif window.Layer:GetName() == UILayer.Info.Name or
            window.Layer:GetName() == UILayer.Dialog.Name then
        self.otherWindowStack:erase(window)
        self.otherWindowStack:push(window)
    else
        local windowStack = self.windowStack
        windowStack:erase(window)

        if hideTop then
            local topWin = windowStack:tail()
            if topWin then
                topWin.View:SetActive(false)
                topWin.State = WindowState.Close
            end
        end
        windowStack:push(window)
    end
    --window.View.rectTransform:SetAsLastSibling()

    --Logger.Log("------------- PushStackWindow")
    --local index = 0
    --for i, v in ilist(self.windowStack) do
    --    Logger.Log(string.format("PushStackWindow %d %s", index, v.Name))
    --    index = index + 1
    --end
end

local function PopStackWindow(self, window)
    if window.Name == UIWindowNames.UIMain or
            window.Name == UIWindowNames.UIPVELoading or
            window.Name == UIWindowNames.UIGuideArrow or
            window.Name == UIWindowNames.UIGuideArrowNew or
            window.Name == UIWindowNames.UIArrow or
            window.Layer:GetName() == UILayer.TopMost.Name or
            window.Layer:GetName() == UILayer.Scene.Name or
            window.Layer:GetName() == UILayer.World.Name then
        return
    elseif window.Layer:GetName() == UILayer.Info.Name or
            window.Layer:GetName() == UILayer.Dialog.Name then
        self.otherWindowStack:erase(window)
    else
        local windowStack = self.windowStack

        if windowStack:tail() == window then
            windowStack:pop()
            local topWin = windowStack:tail()
            if topWin and topWin.State ~= WindowState.Create and topWin.State ~= WindowState.Loading and topWin.State ~= WindowState.Destroying and not topWin.View:GetActive() then
                topWin.View:SetActive(true)
                topWin.State = WindowState.Open
            end
        else
            windowStack:erase(window)
        end
    end

    --Logger.Log("------------- PopStackWindow")
    --local index = 0
    --for i, v in ilist(self.windowStack) do
    --    Logger.Log(string.format("PopStackWindow %d %s", index, v.Name))
    --    index = index + 1
    --end
end

local function GetStackWindowCount(self)
    local windowStack = self.windowStack
    return windowStack.length
end

local function GetStackTopWindow(self)
    local windowStack = self.windowStack
    return windowStack:tail()
end


local function DestroyViewList(self,needCloseList,needPlayCloseEffect)
    for k,v in ipairs(needCloseList) do
        if DataCenter.GuideManager:IsCanCloseUI(v) then
            local window = self.windows[v]
            if window ~= nil then
                if needPlayCloseEffect then
                    self:DestroyWindow(v)
                else
                    self:DestroyWindow(v, { anim = true ,playEffect = false})
                end
            end
        end
    end
end

local function GetUIMainAnim(self)
    return self.UIMainAnim
end

--设置UI层级显示/隐藏（播放timeline时调用）
local function SetLayerActive(self,layerName,active)
    local layer = self:GetLayer(layerName)
    if layer ~= nil then
        layer.gameObject:SetActive(active)
    end
end

--该页面是否加载完成
local function IsPanelLoadingComplete(self,ui_name)
    local window = self:GetWindow(ui_name)
    if window ~= nil and window.State == WindowState.Open then
        return true
    end
    return false
end


local function SetUIMainEnable(self,value)
    local window = self:GetWindow(UIWindowNames.MainUI_SU)
    if window ~= nil and window.View~=nil then
        window.View:SetActive(value)
    end
end

function UIManager:GetUICamera()
    return self.canvas.worldCamera
end

function UIManager:AddBlur()
    local blurNum = 1
    for i=1, #self.blurList do
        if self.blurList[i] == false then
            blurNum = i
            break
        end
    end
    
    local tfName = "BlurURP" .. blurNum
    RenderSetting.ToggleBlur(true,tfName, blurNum)
    self.blurList[blurNum] = true
    return blurNum
end

function UIManager:RemoveBlur(blurNum)
    local tfName = "BlurURP"..blurNum
    RenderSetting.ToggleBlur(false, tfName, blurNum)
    self.blurList[blurNum] = false
end

--function UIManager:SetLastTopWindowActive(topWin, active)
--    if topWin ~= nil and topWin.View ~= nil and topWin.View.gameObject ~= nil then
--        topWin.View.gameObject:SetActive(active)
--    end
--end

local function GetTopCanvas(self)
    if (self.m_topCanvas == nil) then
        local _uiContainer = CS.GameEntry.UIContainer
        self.m_topCanvas = _uiContainer:Find("TopCanvas")
    end
    return self.m_topCanvas or CS.GameEntry.UIContainer
end

--显示/隐藏黑屏
--保险起见 显示黑屏即便后续不调用关闭黑屏 默认2s后也会关闭 
function UIManager:ToggleBlackScreen(t)
    Logger.Log('#UIManager# ToggleBlackScreen t:' .. tostring(t))
    if self.imgBlackScreen == nil then
        return
    end

    --将之前的设置的延时关闭取消掉
    DOTween.Kill(self.imgBlackScreen)
    self.imgBlackScreen.gameObject:SetActive(t)
    --显示黑屏默认2s后关闭
    if t then
        self.imgBlackScreen:DOFade(1, 2):OnComplete(function()
            self.imgBlackScreen.gameObject:SetActive(false)
        end)
    end
end




function UIManager:DumpUIHierarchy()
    local retStr = ''
    function __printChildNames(transform, depth)
        for i = 0, transform.childCount - 1 do
            local childTransform = transform:GetChild(i)
            local s = string.rep("-", depth) .. " " .. childTransform.name
            retStr = retStr .. s .. '@@@@'

            if depth < 2 then
                __printChildNames(childTransform, depth + 1)
            end
        end
    end

    local rootTF = CS.GameEntry.UIContainer
    if rootTF ~= nil then
        __printChildNames(rootTF, 1)
    end

    return retStr
end

local function IsUIShieldByCross(self, ui_name)
    local checkServer = not LuaEntry.Player:IsInSelfServer() or LuaEntry.Player:IsInCrossFight()
    if checkServer and CrossShieldUI[ui_name] then
        return true
    end
    return false
end

local function GetAllWindowNames(self)
    if self.windows ~= nil then
        local windowNames = {}
        for _,v in pairs(self.windows) do
            if v ~= nil and v.State ~= nil and v.State ~= WindowState.Destroying then
                table.insert(windowNames, v.Name)
            end
        end
        
        return windowNames
    end
    return nil
end

--公共接口获取屏幕实际宽和高
function UIManager:GetScreenWidthAndHeight()
    return self.rect:Get_sizeDelta()
end

function UIManager:ShowAnimateBlur()
    self:HideAnimateBlur()
    local path = 'Assets/Main/Prefabs/UI/SU_Common/AnimateBlur.prefab'
    self.blurReq = CommonUtil.LoadResAsync(path,
            function(request)
                if request.isError or request.gameObject == nil then
                    Logger.LogError("fly request error: " .. path)
                    return
                end

                request.gameObject:SetActive(true)
            end)

    TimerManager:GetInstance():DelayInvoke(function()
        self:HideAnimateBlur()
    end, 5)
end

function UIManager:HideAnimateBlur()
    if self.blurReq ~= nil then
        if self.blurReq.gameObject ~= nil then
            self.blurReq.gameObject:SetActive(false)
        end
        
        self.blurReq:Destroy()
        self.blurReq = nil
    end
end


--[[
World Scope Audio Settings
需求：功能上遮盖全屏的界面应该关闭掉场景内的部分音效
由于UIManager的Layer在实际使用中比较混乱，界面不尊重Layer的功能设计，造成无法准确筛选合理的逻辑层级，暂时选用ViewStack作为第一层筛选，不加入ViewStack中的层都不认为会出现全屏遮挡
]]--

function UIManager:IsNeedMuteWorldScopeAudio(view)
    if not view then
        return false
    end
    if view.OpenOptions ~= nil and view.OpenOptions.worldMute ~= nil then
        return view.OpenOptions.worldMute
    end

    if view.winConfig ~= nil then
        if view.winConfig.isBlur then
            return true
        end
        if view.winConfig.hideCamera then
            return true
        end
        if view.winConfig.worldMute ~= nil then
            return view.winConfig.worldMute
        end
    end
    return true -- 作为一个关闭操作，是不应该默认true的，但是目前界面的层级管理太混乱了，没办法快速筛选出合理的全屏界面，所以只能将默认值设为true,特殊情况单独处理
end

function UIManager:TryMuteWorldScopeAudio()
    if not SceneManager.IsInWorld() then
        SUSoundUtil.SetWorldScopeVolume(1.0)
        return
    end
    if self.otherWindowStack.length == 0 and self.windowStack.length == 0 then
        SUSoundUtil.SetWorldScopeVolume(1.0)
    end

    for _, v in ilist(self.windowStack) do
        if v.View and v.View.activeSelf and self:IsNeedMuteWorldScopeAudio(v.View) then
            SUSoundUtil.SetWorldScopeVolume(0.0)
            return
        end
    end

    for _, v in ilist(self.windowStack) do
        if v.View and v.View.activeSelf and self:IsNeedMuteWorldScopeAudio(v.View) then
            SUSoundUtil.SetWorldScopeVolume(0.0)
            return
        end
    end

    SUSoundUtil.SetWorldScopeVolume(1.0)
end

UIManager.__init = __init
UIManager.__delete =__delete
UIManager.Startup = Startup
UIManager.GetWindow = GetWindow
UIManager.OpenWindow = OpenWindow
UIManager.DestroyWindow = DestroyWindow
UIManager.IsWindowOpen = IsWindowOpen
UIManager.DestroyWindowByLayer = DestroyWindowByLayer
UIManager.DestroyAllWindow = DestroyAllWindow
UIManager.GetLayer = GetLayer
UIManager.HasWindow = HasWindow
UIManager.CheckIfIsMainUIOpenOnly = CheckIfIsMainUIOpenOnly
UIManager.GetScaleFactor = GetScaleFactor

UIManager.PushStackWindow = PushStackWindow
UIManager.PopStackWindow = PopStackWindow
UIManager.GetStackTopWindow = GetStackTopWindow
UIManager.GetStackWindowCount = GetStackWindowCount
UIManager.PlayMoveInAnim = PlayMoveInAnim
UIManager.PlayMoveOutAnim = PlayMoveOutAnim
UIManager.OnDestroyWindow = OnDestroyWindow
UIManager.PlayUIMainShowAnimation = PlayUIMainShowAnimation
UIManager.DestroyViewList = DestroyViewList
UIManager.GetUIMainAnim = GetUIMainAnim
UIManager.StopWorldCameraMove = StopWorldCameraMove
UIManager.SetLayerActive = SetLayerActive
UIManager.IsPanelLoadingComplete = IsPanelLoadingComplete
UIManager.AddListener = AddListener
UIManager.RemoveListener = RemoveListener
UIManager.OnKeyCodeEscape = OnKeyCodeEscape
UIManager.KeyCodeEscape = KeyCodeEscape
UIManager.DeleteAllLayer = DeleteAllLayer
UIManager.SetUIMainEnable = SetUIMainEnable
UIManager.GetTopCanvas = GetTopCanvas
UIManager.OnAfterWindowDestroy = OnAfterWindowDestroy
UIManager.IsShouldPauseRole = IsShouldPauseRole
UIManager.HideAllWindowByGuideTalk = HideAllWindowByGuideTalk
UIManager.ShowAllWindowByGuideTalk = ShowAllWindowByGuideTalk
UIManager.IsUIShieldByCross = IsUIShieldByCross
UIManager.GetAllWindowNames = GetAllWindowNames

return UIManager