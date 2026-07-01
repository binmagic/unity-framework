
--[[
-- added by wsh @ 2017-12-03
-- UI工具类
--]]

--local Const = require "Scene.BattlePveModule.Const"

---@class UIUtil
local UIUtil = {}

--[[
local NORMAL = NewMarchType.NORMAL
local DIRECT_MOVE_MARCH = NewMarchType.DIRECT_MOVE_MARCH
local BOSS = NewMarchType.BOSS
local MONSTER = NewMarchType.MONSTER
local ACT_BOSS = NewMarchType.ACT_BOSS
local ASSEMBLY_MARCH = NewMarchType.ASSEMBLY_MARCH
local SCOUT = NewMarchType.SCOUT
local RESOURCE_HELP = NewMarchType.RESOURCE_HELP
local GOLLOES_EXPLORE = NewMarchType.GOLLOES_EXPLORE
local GOLLOES_TRADE = NewMarchType.GOLLOES_TRADE
local PUZZLE_BOSS = NewMarchType.PUZZLE_BOSS
local CHALLENGE_BOSS = NewMarchType.CHALLENGE_BOSS
local ALLIANCE_BOSS = NewMarchType.ALLIANCE_BOSS
]]--

local Data = CS.GameEntry.Data
local ResourceManager = CS.GameEntry.Resource
local NoAnimation = {anim = false} -- 不播放动画

local TouchWrapper = CS.BitBenderGames.TouchWrapper
local EventSystem = CS.UnityEngine.EventSystems.EventSystem

-- tipText可以直接使用多语言ID，注意要是数字格式；里面会自动处理
-- UICommonMessageTipView:RefreshData
local function ShowMessage(tipText,btnNum,text1,text2,action1,action2,closeAction,titleText,isChangeImg,noPlayCloseEffect,enableBtn1,enableBtn2,countdown)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageTip)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageTip)
    if window~=nil and window.View~=nil then
        window.View:SetData(tipText,btnNum,text1,text2,action1,action2,closeAction,titleText,isChangeImg,noPlayCloseEffect,enableBtn1,enableBtn2,countdown)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

local function IsPad()
    local ret = false
    pcall(function()
        ret = not CS.UIUtils:IsPhone()
    end)
    return ret;
end

local function ShowIntro(title, subtitle, intro, closeAction)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonIntroTip)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonIntroTip)
    if window and window.View then
        window.View:SetData(title, subtitle, intro, closeAction)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

local function ShowIntroId(titleId, subtitleId, introId, closeAction)
	UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonIntroTip)
	local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonIntroTip)
	if window and window.View then
		window.View:SetDataId(titleId, subtitleId, introId, closeAction)
		if window.View:GetActive() then
			window.View:RefreshData()
		end
	end
end

local function ShowIntroBtn(title, subtitle, intro, configAction, cancelAction)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonIntroTip)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonIntroTip)
    if window and window.View then
        window.View:SetData(title, subtitle, intro, nil, nil, nil, true, configAction, cancelAction)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

local function ShowIntroWithRewards(title, subtitle, intro, closeAction, rewards)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonIntroTip)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonIntroTip)
    if window and window.View then
        window.View:SetData(title, subtitle, intro, closeAction, nil, nil, nil, nil, nil, rewards)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

-- confirmStr, cancelStr 为空时，显示默认值
local function ShowUseItemTip(title, param)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonUseItemTip, { anim = true, UIMainAnim = UIMainAnimType.LeftRightBottomHide })
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonUseItemTip)
    if window and window.View then
        window.View:SetData(title, param)
        return window.View
    end
end

-- 展示一个复杂的Tip
-- tipInfo 格式见 UIComplexTipView.lua
local function ShowComplexTip(tipInfo)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIComplexTip)
    if window then
        window.View:PushTipInfo(tipInfo)
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIComplexTip, { anim = true, playEffect = false }, tipInfo)
    end
end

-- 显示是否再次弹出窗口
-- title:标题文本
-- tipText:描述文本
-- btnNum:按钮个数
-- text1:左边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- text2:右边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- sureAction:点击左边按钮回调函数
-- toggleAction:点击中间复选框按钮回调函数
-- cancelAction:点击右边按钮回调函数
-- closeAction:点击x和黑色背景回调函数
-- isChangeImg:为true 左边红色按钮，右边黄色按钮  为空 左边蓝色按钮，右边黄色按钮
-- toggleText:中间复选框文本描述
-- btnNoUseDialog:text1和text2类型 为true表示文本 为空表示多语言
-- leftBtnPicName:左边按钮图片路径
-- rightBtnPicName:右边按钮图片路径
local function ShowSecondMessage(titleText,tipText,btnNum,text1,text2,sureAction,toggleAction,cancelAction,closeAction,isChangeImg,toggleText, btnNoUseDialog, leftBtnPicName, rightBtnPicName)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UISellConfirm)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UISellConfirm)
    if window~=nil and window.View~=nil then
        window.View:SetData(titleText,tipText,btnNum,text1,text2,sureAction,toggleAction,cancelAction,closeAction,isChangeImg,toggleText, btnNoUseDialog, leftBtnPicName, rightBtnPicName)
        if window.View:GetActive() then
            window.View:RefreshView()
        end
    end
end

function UIUtil.ShowSecondMessageWithParam(param)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UISellConfirm)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UISellConfirm)
    if window~=nil and window.View~=nil then
        window.View:SetParam(param)
        if window.View:GetActive() then
            window.View:RefreshView()
        end
    end
end

function UIUtil.ShowConfirmForAlMoveItemLack(pointId,from_window_ins)
    --针对联盟迁城道具不足时的优化：
    --在联盟领地里，按钮分高级迁城和联盟迁城，
    --点击高级迁城，如果高级迁城不足弹出高级迁城不足弹窗
    --点击联盟迁城，走购买逻辑
    local sureAction = function()
        local itemId = SpecialItemId.ITEM_MOVE_CITY
        local ownCount = DataCenter.ItemData:GetItemCount(itemId)
        if ownCount > 0 then
            local mainBuild = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
            if New_Lua_World then
                SceneManager.World:UICreateBuilding(BuildingTypes.FUN_BUILD_MAIN, mainBuild.uuid, pointId, PlaceBuildType.MoveCity_Cmn)
            else
                CS.SceneManager.World:UICreateBuilding(BuildingTypes.FUN_BUILD_MAIN, mainBuild.uuid, pointId, PlaceBuildType.MoveCity_Cmn)
            end
        else
            local spendGold = CommonUtil.GetItemGoldByItemId(itemId, 1)
            local itemName = DataCenter.ItemTemplateManager:GetName(itemId)
            local tipText = Localization:GetString(880004,itemName, spendGold)
            local param = {
                contentText = tipText,
                btnNum = 2,
                text1 = GameDialogDefine.CONFIRM,
                text2 = GameDialogDefine.CANCEL,
                sureAction = function()
                    local gold = LuaEntry.Player.gold
                    if gold < spendGold then
                        GoToUtil.GotoPayTips()
                    else
                        local param = {}
                        param.itemId = tostring(itemId)
                        param.num = 1
                        param.buyMoveCityItemMark = true
                        param.pointId = pointId
                        SFSNetwork.SendMessage(MsgDefines.UIShopBuy,param)
                    end
                end,
                cancelActon = function() end,
                DescText = 483119,
                DescClickAction = function()
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonShop, 2)
                end
            }
            UIUtil.ShowSecondMessageWithParam(param)
        end
        if from_window_ins then
            from_window_ins:CloseSelf(true)
        end
    end
    local cancelActon = function()
        local itemId = SpecialItemId.ITEM_ALLIANCE_CITY_MOVE
        local spendGold = CommonUtil.GetItemGoldByItemId(itemId, 1)
        local gold = LuaEntry.Player.gold
        if gold < spendGold then
            GoToUtil.GotoPayTips()
        else
            local param = {}
            param.itemId = tostring(itemId)
            param.num = 1
            param.buyMoveCityItemMark = true
            param.pointId = pointId
            SFSNetwork.SendMessage(MsgDefines.UIShopBuy,param)
        end
        if from_window_ins then
            from_window_ins:CloseSelf(true)
        end
    end

    local ownCount = DataCenter.ItemData:GetItemCount(SpecialItemId.ITEM_MOVE_CITY)
    local cost = tostring(CommonUtil.GetItemGoldByItemId(SpecialItemId.ITEM_ALLIANCE_CITY_MOVE, 1))
    local param = {
        contentText = Localization:GetString(898392,cost),
        btnNum = 2,
        text1 = 180074,--高级迁城
        text2 = 390854,--联盟迁城
        sureAction = sureAction,
        cancelAction = cancelActon,
        rightBtnPicText = cost,
        rightBtnPicName = ResourceTypeIconName[ResourceType.Gold],
        btn1TopInfo = {text = string.format("%d/1",ownCount),icon = "Assets/Main/Sprites/ItemIcons/item001.png"}
    }
    UIUtil.ShowSecondMessageWithParam(param)
end

function UIUtil.ShowAlHelpTips(msg, playerHead, sound)
    local anim = not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageBar)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageBar,{anim = anim,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageBar)
    if window~=nil and window.View~=nil then
        window.View:SetPanelPosCaches(0, 0)
        window.View:AddNewMsg_Msg(msg, nil, playerHead, nil, nil, nil, nil, sound)
    end
end

function UIUtil.ShowTipsWithOffset(msg,offsety,showTime, playerHead,heroHead,girlicon,alliancePoint)
    local anim = not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageBar)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageBar,{anim = anim,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageBar)
    if window~=nil and window.View~=nil then
        window.View:SetPanelPosCaches(0,offsety)
        window.View:AddNewMsg_Msg(msg,showTime, playerHead,heroHead,girlicon,alliancePoint)
        --window.View:SetData(msg,img,messageBarType)
        --if window.View:GetActive() then
        --    window.View:RefreshData()
        --end

    end
end

local function ShowTips(msg,showTime, playerHead,heroHead,girlicon,alliancePoint, timeBeforeFadeOut)
    local anim = not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageBar)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageBar,{anim = anim,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageBar)
    if window~=nil and window.View~=nil then
        window.View:AddNewMsg_Msg(msg,showTime, playerHead,heroHead,girlicon,alliancePoint, timeBeforeFadeOut)
        --window.View:SetData(msg,img,messageBarType)
        --if window.View:GetActive() then
        --    window.View:RefreshData()
        --end

    end
end

local function ShowSpecialTips(msg,showTime)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageSpecialBar,{anim = true,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageSpecialBar)
    if window~=nil and window.View~=nil then
        window.View:AddNewMsg_Msg(msg,showTime)
    end
end

local function ShowSingleTip(msg)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonSingleMsgBar,{anim = true,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonSingleMsgBar)
    if window~=nil and window.View~=nil then
        window.View:ShowStrTip(msg)
    end
end

-- 显示localid携带参数的提示版本
local function ShowTipsIdParams(msgId, params, showTime, playerHead,heroHead,girlicon,alliancePoint)
	local anim = not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageBar)
	UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageBar,{anim = anim,playEffect = false})
	local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageBar)
	if window~=nil and window.View~=nil then
		window.View:AddNewMsg_MsgIdParams(msgId, params, showTime, playerHead,heroHead,girlicon,alliancePoint)
		--window.View:SetData(msg,img,messageBarType)
		--if window.View:GetActive() then
		--    window.View:RefreshData()
		--end

	end
end

local function ShowTipsId(msgId,showTime, playerHead,heroHead,girlicon,alliancePoint)
    local anim = not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageBar)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonMessageBar,{anim = anim,playEffect = false})
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonMessageBar)
    if window~=nil and window.View~=nil then
        window.View:AddNewMsg_MsgId(msgId,showTime, playerHead,heroHead,girlicon,alliancePoint)
        --window.View:SetData(msg,img,messageBarType)
        --if window.View:GetActive() then
        --    window.View:RefreshData()
        --end

    end
end

local function ShowBuyMessage(tipText,btnNum,text1,text2,action1,action2,closeAction,titleText,btnPriceTxt,item,noPlayCloseEffect,enableBtn1,enableBtn2)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonBuyItem)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonBuyItem)
    if window~=nil and window.View~=nil then
        window.View:SetData(tipText,btnNum,text1,text2,action1,action2,closeAction,titleText,btnPriceTxt,item,noPlayCloseEffect,enableBtn1,enableBtn2)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

local function ShowUseResItemMessage(tipText,text2,action2,closeAction,titleText,item,noPlayCloseEffect,enableBtn1,enableBtn2)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonUseResItemTips)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonUseResItemTips)
    if window~=nil and window.View~=nil then
        window.View:SetData(tipText,text2,action2,closeAction,titleText,item,noPlayCloseEffect,enableBtn1,enableBtn2)
        if window.View:GetActive() then
            window.View:RefreshData()
        end
    end
end

--求AB对CD的交点
local function SegmentsInterPoint(a,b,c,d)
    c.z = 0
    d.z = 0
    --v1×v2=x1y2-y1x2
    --以线段ab为准，是否c，d在同一侧
    local ab = b - a
    local ac = c - a;
    local abXac = UIUtil.Cross(ab, ac)

    local ad = d - a
    local abXad = UIUtil.Cross(ab, ad)

    if abXac * abXad >= 0 then
        return nil
    end
    --以线段cd为准，是否ab在同一侧
    local cd = d - c
    local ca = a - c
    local cb = b - c

    local cdXca = UIUtil.Cross(cd, ca)
    local cdXcb = UIUtil.Cross(cd, cb)
    if cdXca * cdXcb >= 0 then
        return nil
    end

    --计算交点坐标
    local t = UIUtil.Cross(a - c, d - c) / UIUtil.Cross(d - c, b - a)
    local dx = t * (b.x - a.x)
    local dy = t * (b.y - a.y)
    return Vector2.New(a.x + dx, a.y + dy)
end

local function Cross(a,b)
    return a.x * b.y - b.x * a.y
end

--获取资源位置
local function GetResourcePos(resourceType)
    local resourceBar = UIUtil.GetResourceBar()
    if resourceBar then
        return resourceBar:GetResourcePos(resourceType)
    else
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Goods)
    end
end

local function GetResource(resourceType)
    local resourceBar = UIUtil.GetResourceBar()
    if resourceBar then
        return resourceBar:GetResource(resourceType)
    end
    return nil
end

local function GetResourceBar()
    local resourceBar
    local topWindow = UIManager:GetInstance():GetStackTopWindow()
    if not topWindow then
        topWindow = UIManager:GetInstance():GetWindow(UIWindowNames.MainUI_SU)
    end
    if topWindow and topWindow.View and topWindow.State == 2 then
        if topWindow.Name == UIWindowNames.MainUI_SU and topWindow.View.topLayer then
            resourceBar = topWindow.View.topLayer.resourceBar
        else
            resourceBar = topWindow.View.resourceBar
        end
    end
    if resourceBar == nil then
        if UIManager:GetInstance():IsPanelLoadingComplete(UIWindowNames.MainUI_SU) then
            local window = UIManager:GetInstance():GetWindow(UIWindowNames.MainUI_SU)
            if window ~= nil and window.View ~= nil and window.View.topLayer ~= nil then
                resourceBar = window.View.topLayer.resourceBar
            end
        end
    end
    return resourceBar
end

local function GetAllianceItemPos(aItemType)
    if UIManager:GetInstance():IsPanelLoadingComplete(UIWindowNames.UIAllianceScience) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIAllianceScience)
        if window ~= nil and window.View ~= nil then
            return window.View:GetAllianceItemPos(aItemType)
        end
    end
end

--点击世界关闭已打开世界UI
local function ClickWorldCloseWorldUI()
    --UIUtil.ClickCloseWorldUI(CloseUIType.ClickWorld)
end

--点击UI关闭已打开世界UI
local function ClickUICloseWorldUI()
    --UIUtil.ClickCloseWorldUI(CloseUIType.ClickUI)
end

--拖动世界关闭已打开世界UI
local function DragWorldCloseWorldUI()
    UIUtil.ClickCloseWorldUI(CloseUIType.DragWorld)
    EventManager:GetInstance():Broadcast(EventId.ClickFarmBuildHide)
    EventManager:GetInstance():Broadcast(EventId.ClickFarmBuildHideEffect)
end

local function CheckNeedQuitFocus()
    local needQuit = false
    for k,v in ipairs(DragWorldNeedCloseExtraWorldUI) do
        if needQuit==false then
            if UIManager:GetInstance():IsWindowOpen(v) then
                needQuit = true
            end
        end
    end
    return needQuit
end
local function ClickCloseWorldUI(closeUIType)
    local needCloseList = {}
    if closeUIType == CloseUIType.DragWorld then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIWorldPoint)
        if window ~= nil and window.View ~= nil and window.View.activeSelf == true and window.Ctrl ~= nil then
            if window.Ctrl.type == WorldPointUIType.SingleMapGarbage then
                table.insert(needCloseList, UIWindowNames.UIWorldPoint)
            end
        end
    end
    for k,v in ipairs(ClickWorldNeedCloseWorldUI) do
        table.insert(needCloseList,v)
    end
    if closeUIType == CloseUIType.ClickUI then
        for k1,v1 in ipairs(ClickUINeedCloseExtraWorldUI) do
            table.insert(needCloseList,v1)
        end
        table.insert(needCloseList,UIWindowNames.UIWorldPoint)
    elseif closeUIType == CloseUIType.DragWorld then
        for k1,v1 in ipairs(DragWorldNeedCloseExtraWorldUI) do
            table.insert(needCloseList,v1)
        end
    end
    UIManager:GetInstance():DestroyViewList(needCloseList,closeUIType ~= CloseUIType.ClickUI)
    EventManager:GetInstance():Broadcast(EventId.HideMarchTip)
    --if isOpenWindow and closeUIType ~= CloseUIType.ClickUI then
    --    EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true);
    --end
end

local function PlayAnimationReturnTime(unity_animator,animName)
    local duration = 0
    local clips = unity_animator.runtimeAnimatorController.animationClips
    for i = 0, clips.Length - 1 do
        if string.endswith(clips[i].name,animName) then
            duration = clips[i].length
            unity_animator:Play(animName, 0, 0)
            return true, duration
        end
    end

    return false
end

local function ClickBuildAdjustCameraView(worldPoint,adjustTable,lossyScale, zoom)
    if not SceneUtils.GetIsInWorld() and SceneManager.GetLevel():GetViewMode() == ViewMode.RPG then
        return
    end
    
    local screen = CS.SceneManager.World:WorldToScreenPoint(worldPoint)
    local Screen = CS.UnityEngine.Screen
    local ScreenY = Screen.height
    local ScreenX = Screen.width
    local maxTop = ScreenY - adjustTable.top * lossyScale
    local maxBottom = adjustTable.bottom * lossyScale
    local maxLeft = adjustTable.left * lossyScale
    local maxRight = ScreenX - adjustTable.right * lossyScale
    local needMove = false
    if screen.x > maxRight then
        needMove = true
        screen.x = maxRight
    elseif screen.x < maxLeft then
        needMove = true
        screen.x = maxLeft
    end
    if screen.y > maxTop then
        needMove = true
        screen.y = maxTop
    elseif screen.y < maxBottom then
        needMove = true
        screen.y = maxBottom
    end
    if needMove then
        --CS.SceneManager.World:QuitFocus(worldPoint,LookAtFocusTime)
        if SceneUtils.GetIsInWorld() then
            local posWorld = CS.SceneManager.World:ScreenPointToWorld(screen)
            local curPos = CS.SceneManager.World.CurTarget + worldPoint - posWorld
            GoToUtil.GotoPos(curPos,zoom,nil,nil,LuaEntry.Player:GetCurServerId(),nil, LuaEntry.Player:GetCurWorldId())
        else
            local level = SceneManager.GetLevel()
            local camera = level:GetCamera()
            local posWorld = camera:ScreenPointToWorld(screen)
            local curPos = camera:GetCameraTargetPos() + worldPoint - posWorld
            GoToUtil.GotoPos(curPos,zoom,nil,nil,LuaEntry.Player:GetCurServerId(),nil, LuaEntry.Player:GetCurWorldId())
        end
    end
    --local posWorld = CS.SceneManager.World:ScreenPointToWorld(screen)
    --local curPos = CS.SceneManager.World.CurTarget + worldPoint - posWorld
    --GoToUtil.GotoPos(worldPoint)

    return screen
end

local function ClickFarmAdjustPos(worldPoint,Adjust)
    local pos = worldPoint
    local lossyScale = UIManager:GetInstance():GetScaleFactor()
    local screen = CS.SceneManager.World:WorldToScreenPoint(worldPoint)
    local Screen = CS.UnityEngine.Screen
    local ScreenY = Screen.height
    local ScreenX = Screen.width
    local maxTop = ScreenY - Adjust.top * lossyScale
    local maxBottom = Adjust.bottom * lossyScale
    local maxLeft = Adjust.left* lossyScale
    local maxRight = ScreenX - Adjust.right* lossyScale
    local needMove = false
    if screen.x > maxRight then
        needMove = true
        screen.x = maxRight
    elseif screen.x < maxLeft then
        needMove = true
        screen.x = maxLeft
    end
    if screen.y > maxTop then
        needMove = true
        screen.y = maxTop
    elseif screen.y < maxBottom then
        needMove = true
        screen.y = maxBottom
    end
    if needMove then
        --CS.SceneManager.World:QuitFocus(worldPoint,LookAtFocusTime)
        local posWorld = CS.SceneManager.World:ScreenPointToWorld(screen)
        pos = CS.SceneManager.World.CurTarget + worldPoint - posWorld
    end
    return pos,needMove
end

--是否在视野内
local function IsInView(worldPoint)
    local screen = CS.SceneManager.World:WorldToScreenPoint(worldPoint)
    local Screen = CS.UnityEngine.Screen
    return screen.x < Screen.width and screen.y < Screen.height
end

function UIUtil.OnClickMultiObjects(objects,index)

    local lod = CS.SceneManager.World:GetLodLevel()
    if lod >= 4 then
        return false
    end
    local showGrid = false
    local needChangeCamera =  UIUtil.CheckNeedQuitFocus()
    UIUtil.ClickWorldCloseWorldUI()
    local needCloseWorldPointUI = true
    EventManager:GetInstance():Broadcast(EventId.ClickAny)

    local needCloseUI = {}
    for k,v in ipairs(ClickUINeedCloseExtraWorldUI) do
        needCloseUI[v] = true
    end
    for k,v in ipairs(DragWorldNeedCloseExtraWorldUI) do
        needCloseUI[v] = true
    end

    if needCloseWorldPointUI == true then
        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIWorldPoint)
        end
    end
    for k,v in pairs(needCloseUI) do
        if v then
            if k == UIWindowNames.UIFormationSelectListNew then
                if UIManager:GetInstance():IsWindowOpen(k) then
                    EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true)
                end

            end
            UIManager:GetInstance():DestroyWindow(k)
        end
    end
    --整理出所有点到的物体
    local roots = {}
    local insertMarks = {}
    for i = 1, #objects do
        local obj = objects[i]
        if obj ~= nil and IsNull(obj) == false then
            local tmp = obj.transform
            while tmp ~= nil and tmp.parent ~= CS.SceneManager.World.DynamicObjNode do
                tmp = tmp.parent
            end
            if tmp ~= nil and not insertMarks[tmp] then
                insertMarks[tmp] = true
                local param = {}
                param.gameObject = tmp.gameObject
                param.triggerObj = obj:GetComponent(typeof(CS.TouchObjectEventTrigger))
                table.insert(roots, param)
            end
        end
    end
    --打开多目标选择界面时，判断下有没有优先弹出的选项
    for _,v in ipairs(roots) do
        local triggerObj = v.triggerObj
        local pointIndex = SceneUtils.TilePosToIndex(triggerObj.TilePos)
        if pointIndex > 0 then
            local info = DataCenter.WorldPointManager:GetPointInfo(pointIndex)
            if info ~= nil then
                if info.PointType == WorldPointType.GodzillaGift then
                    local pointData = info.treasureInfo
                    if pointData ~= nil then
                        local typeValue = toInt(GetTableData("precious_deposits", pointData.configId,"type"))
                        if typeValue == 2 and info.treasureInfo.state == 1 then
                            local ifSelfOwner = DataCenter.WorldPointManager.CheckIsSelfOwnerDigTreasure(info.pointIndex)
                            local isSelfAlliance = DataCenter.WorldPointManager.CheckIsSelfAllianceDigTreasure(info.pointIndex)
                            if ifSelfOwner or isSelfAlliance then
                                local extrainfo = info.treasureInfo
                                local uids = string.string2array_s(extrainfo.rewarduids,";")
                                if not table.hasvalue(uids,LuaEntry.Player.uid) then
                                    UIUtil.ClickAllianceTreasure(info.pointIndex)
                                    return
                                end
                            end
                        elseif typeValue == 3 and info.treasureInfo.state == 1 then
                            local extrainfo = info.treasureInfo
                            local uids = string.string2array_s(extrainfo.rewarduids,";")
                            if not table.hasvalue(uids,LuaEntry.Player.uid) then
                                UIUtil.ClickDroppedTreasure(info.pointIndex)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldMultiSelect,OpenWinAnimTrue,roots,index)
    return true
end

local function OnClickWorldTroop(marchUuid)
    local _existMarch = false
    UIUtil.ClickWorldCloseWorldUI()
    local needCloseUI = {}
    for k,v in ipairs(ClickUINeedCloseExtraWorldUI) do
        needCloseUI[v] = true
    end
    local needCloseWorldPointUI = true
    local marchInfo = DataCenter.WorldMarchDataManager:GetMarch(marchUuid)
    if marchInfo~=nil then
        if marchInfo.ownerUid ~= LuaEntry.Player.uid and marchInfo:GetMarchType() ~= NewMarchType.TRAIN then
            SUSoundUtil.PlayEffect(SoundAssets.Click_OtherPlayerApc) 
        end
        _existMarch = true
        if not string.IsNullOrEmpty(marchInfo.eventId) then
            --DataCenter.TroopActionManager:DoTroopAction(TroopActionType.TROOP_ACTION_TYPE_RADAR_CENTER)
        end
--        if marchInfo:GetMarchType()== NORMAL or marchInfo:GetMarchType() == ASSEMBLY_MARCH or marchInfo:GetMarchType() == SCOUT or marchInfo:GetMarchType() == RESOURCE_HELP
--                or marchInfo:GetMarchType() == GOLLOES_EXPLORE or marchInfo:GetMarchType() == GOLLOES_TRADE or marchInfo:GetMarchType() == DIRECT_MOVE_MARCH
--                or marchInfo:GetMarchType() == NewMarchType.MONSTER_SIEGE then
--            CS.SceneManager.World.marchUuid = marchUuid
--            --DataCenter.WorldMarchDataManager:TrackMarch(marchUuid)
--            --DataCenter.WorldMarchDataManager:TrackMarch(marchUuid)
--            WorldMarchTileUIManager:GetInstance():ShowTroop(marchUuid, true)
--            --CS.WorldTileUI.ShowTroop(marchUuid, CS.SceneManager.World,false)
--        elseif marchInfo:GetMarchType() == NewMarchType.TRAIN then
--            ---- 货车
--            SUSoundUtil.PlayEffect(SoundAssets.Click_Truck) 
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            needCloseWorldPointUI = false
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--            local _param = {}
--            _param["uuid"] = marchUuid
--            _param["pointId"] = marchInfo.targetPos
--            _param["ownerUid"] = ""
--            _param["type"] = WorldPointUIType.Train
--            _param["buildId"] = 0
--            local troop = WorldTroopManager:GetInstance():GetTroop(marchUuid)
--            if troop ~= nil then
--                local lod = SceneManager.World:GetLodLevel()
--                if lod and lod > MiniMapActiveLod then
--                    local targetPos = troop:GetPosition()
--                    GoToUtil.GotoPos(targetPos, World_InitZoom, LookAtFocusTime, function()
--                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                        else
--                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--                        end
--                        DataCenter.WorldMarchDataManager:TrackMarch(marchUuid)
--                    end,LuaEntry.Player:GetCurServerId())
--                else
--                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                    else
--                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--                    end
--                    DataCenter.WorldMarchDataManager:TrackMarch(marchUuid)     
--                end
--            end
--        elseif marchInfo:GetMarchType() == MONSTER or marchInfo:GetMarchType() == BOSS then
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Click_Enemy1)
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--            local _param = {}
--            _param["uuid"] = marchUuid
--            _param["pointId"] = marchInfo.targetPos
--            _param["ownerUid"] = ""
--            _param["type"] = WorldPointUIType.Monster
--            _param["buildId"] = 0
--            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--            else
--                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--            end
--            --雷打怪走引导
--            local param = {}
--            param.monster = true
--            DataCenter.GuideManager:SetCompleteNeedParam(param)
--            DataCenter.GuideManager:CheckGuideComplete()
--            if DataCenter.RadarCenterDataManager:GetDetectEventInfoByPointId(marchInfo.targetPos) ~= nil then
--                DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ClickRadarMonster, SaveGuideDoneValue)
--            else
--                DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ClickMonster, tostring(marchInfo.monsterId))
--            end
--            needCloseWorldPointUI = false
--            --UIManager:GetInstance():OpenWindow(UIWindowNames.WorldDesUI,marchUuid)
--        elseif marchInfo:GetMarchType() == ACT_BOSS then
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                local _param = {}
--                _param["uuid"] = marchUuid
--                _param["pointId"] = marchInfo.targetPos
--                _param["ownerUid"] = ""
--                _param["type"] = WorldPointUIType.ActBoss
--                _param["buildId"] = 0
--            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                local str = marchUuid..";"..marchInfo.targetPos..";"..""..";"..WorldPointUIType.ActBoss..";".."0"..";".."0"
--                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--            else
--                
--                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--            end
--            needCloseWorldPointUI = false
--        elseif marchInfo:GetMarchType()== PUZZLE_BOSS then
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                local _param = {}
--                _param["uuid"] = marchUuid
--                _param["pointId"] = marchInfo.targetPos
--                _param["ownerUid"] = ""
--                _param["type"] = WorldPointUIType.PuzzleBoss
--                _param["buildId"] = 0
--            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                local str = marchUuid..";"..marchInfo.targetPos..";"..""..";"..WorldPointUIType.PuzzleBoss..";".."0"..";".."0"
--                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--            else
--                
--                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--            end
--            needCloseWorldPointUI = false
--        elseif marchInfo:GetMarchType() == CHALLENGE_BOSS then
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                local _param = {}
--                _param["uuid"] = marchUuid
--                _param["pointId"] = marchInfo.targetPos
--                _param["ownerUid"] = ""
--                _param["type"] = WorldPointUIType.ChallengeBoss
--                _param["buildId"] = 0
--            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                local str = marchUuid..";"..marchInfo.targetPos..";"..""..";"..WorldPointUIType.ChallengeBoss..";".."0"..";".."0"
--                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--            else
--                
--                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--            end
--            needCloseWorldPointUI = false
--        elseif marchInfo:GetMarchType() == ALLIANCE_BOSS then
--            WorldMarchTileUIManager:GetInstance():RemoveTroop()
--            needCloseUI[UIWindowNames.UIWorldPoint] = nil
--            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                local _param = {}
--                _param["uuid"] = marchUuid
--                _param["pointId"] = marchInfo.targetPos
--                _param["ownerUid"] = ""
--                _param["type"] = WorldPointUIType.AllianceBoss
--                _param["buildId"] = 0
--                _param["allianceUid"] = marchInfo.allianceUid
--            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                local str = marchUuid..";"..marchInfo.targetPos..";"..""..";"..WorldPointUIType.AllianceBoss..";".."0"..";".."0"
--                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--            else
--                
--                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--            end
--            needCloseWorldPointUI = false
--        end
    end
    for k,v in pairs(needCloseUI) do
        if v then
            UIManager:GetInstance():DestroyWindow(k)
        end
    end
    if needCloseWorldPointUI == true then
        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIWorldPoint)
        end
    end
    return _existMarch
end

function UIUtil.GuideLog(info)
end

function UIUtil.IsSeasonBuild( buildId )
    if buildId == 741000
            or buildId == 742000
            or buildId == 743000
            or buildId == 744000
            or buildId == 745000
            or buildId == 746000
            or buildId == 747000
            or buildId == 748000
            or buildId == 749000
    then
        return true
    end
    return false
end

local function OnClickWorld(curIndex,clickType, playerBuildingDontReset, offsetTile)
    --[[local lod = CS.SceneManager.World:GetLodLevel()
    if lod >= 4 then
        return
    end]]
    local needChangeCamera =  UIUtil.CheckNeedQuitFocus()
    UIUtil.ClickWorldCloseWorldUI()
    local needCloseIsFocus = true
    local needCloseWorldPointUI = true
    EventManager:GetInstance():Broadcast(EventId.ClickAny)

    local needCloseUI = {}
    for k,v in ipairs(ClickUINeedCloseExtraWorldUI) do
        needCloseUI[v] = true
    end
    for k,v in ipairs(DragWorldNeedCloseExtraWorldUI) do
        needCloseUI[v] = true
    end

    WorldMarchTileUIManager:GetInstance():RemoveTroop()
    WorldMarchEmotionManager:GetInstance():HideCurBtns()
    EventManager:GetInstance():Broadcast(EventId.OnClickWorld,curIndex)
    local info = DataCenter.WorldPointManager:GetPointInfo(curIndex)
    if info ~= nil then
        SUSoundUtil.PlayWorldMusic(info.PointType,nil, nil, curIndex)
        UIUtil.GuideLog(info)
        if info.PointType == WorldPointType.PlayerBuilding then
            local build = DataCenter.WorldPointManager:GetBuildDataByPointIndex(curIndex)
            if build ~= nil then
                if build.crossFlag > 0 then
                    return
                end
                
                if build.ownerUid == LuaEntry.Player.uid then
                    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(build.uuid)
                    Logger.Log("main Uuid"..build.uuid)
                    if buildData ~= nil then
                        if buildData.destroyStartTime>0 then
                            local isFinish = DataCenter.BuildManager:CheckSendFixBuildFinish(build.uuid)
                            if build.level >= 0 and isFinish == true then
                                needCloseUI[UIWindowNames.UIWorldTileUI] = nil
                                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldTileUI) then
                                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldTileUI, tostring(build.mainIndex))
                                else
                                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldTileUI, { anim = true, playEffect = false}, tostring(build.mainIndex), needChangeCamera)
                                end
                            end
                        else
                            local isFinish = DataCenter.BuildManager:CheckSendBuildFinish(build.uuid) and 
                                    DataCenter.BuildManager:CheckSendFreeSpeed(build.uuid)
                            local itemId = build.itemId
                            if itemId ==nil or itemId == 0 then
                                itemId = build.buildId
                            end
                            --0级虫洞特殊处理
                            if build.level == 0 and (build.itemId == BuildingTypes.APS_BUILD_WORMHOLE_SUB or BuildingUtils.IsInEdenSubwayGroup(itemId)== true) then
                                needCloseUI[UIWindowNames.UIWorldTileUI] = nil
                                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldTileUI,{anim = true,playEffect = false},tostring(build.mainIndex),needChangeCamera)
                            elseif build.level >= 0 and isFinish ==true then
                                local buildTemplate = DataCenter.BuildTemplateManager:GetBuildingDesTemplate(itemId)
                                if buildTemplate~=nil then
                                    if buildData ~= nil then
                                        local bUuid = buildData.uuid
                                        local buildId = itemId
                                        if build.level == 0 then
                                            if buildData.updateTime == 0 then
                                                GoToUtil.GotoOpenBuildCreateWindow(UIWindowNames.UIBuildCreate, NormalPanelAnim, {buildId = itemId})
                                            end
                                        else
                                            if buildId == BuildingTypes.FUN_BUILD_ELECTRICITY then
                                                if buildData.unavailableTime == 0 then
                                                    local now = UITimeManager:GetInstance():GetServerTime()
                                                    if buildData.produceEndTime > now and buildData.produceEndTime > buildData.lastCollectTime then
                                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIResourceCost) then
                                                            EventManager:GetInstance():Broadcast(EventId.UIResourceCostChangeState,bUuid)
                                                        else
                                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIResourceCost,bUuid)
                                                        end
                                                        needCloseUI[UIWindowNames.UIResourceCost] = nil
                                                    end
                                                end
                                            end
                                            if buildTemplate.build_type ~= BuildType.Second or buildTemplate.id == BuildingTypes.APS_BUILD_WORMHOLE_MAIN
                                                    or buildTemplate.id == BuildingTypes.APS_BUILD_WORMHOLE_SUB or buildTemplate.id == BuildingTypes.WORM_HOLE_CROSS or BuildingUtils.IsInEdenSubwayGroup(buildTemplate.id)== true then--加了虫洞特殊规则
                                                if buildTemplate.id == BuildingTypes.FUN_BUILD_CONDOMINIUM then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_LIBRARY)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_GROCERY_STORE then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Golloes_Build)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_MAIN  then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Main_City)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_BARRACKS  then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_BARRACKS)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_CAR_BARRACK  then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_CAR_BARRACK)
                                                elseif buildTemplate.id == BuildingTypes.APS_BUILD_PUB  then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Hero_Build)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_INFANTRY_BARRACK  then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_INFANTRY_BARRACK)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_AIRCRAFT_BARRACK then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_AIRCRAFT_BARRACK)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_TRAP_BARRACK then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_TRAP_BARRACK)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_POLICE_STATION then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_POLICE_STATION)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_RADAR_CENTER then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Radar)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_DRONE then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_DRONE)
                                                elseif buildTemplate.id == BuildingTypes.FUND_BUILD_ALLIANCE_CENTER then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_ALLIANCE_CENTER)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_LIBRARY then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Apartment)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_COLD_STORAGE then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_COLD_STORAGE)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_SCIENE then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_SCIENE)
                                                elseif buildTemplate.id == BuildingTypes.FUN_BUILD_TRAINFIELD_1
                                                        or buildTemplate.id == BuildingTypes.FUN_BUILD_TRAINFIELD_2
                                                        or buildTemplate.id == BuildingTypes.FUN_BUILD_TRAINFIELD_3
                                                        or buildTemplate.id == BuildingTypes.FUN_BUILD_TRAINFIELD_4 then
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_TRAINFIELD)
                                                else
                                                    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                                end
                                                if itemId == BuildingTypes.FUN_BUILD_MAIN then
                                                    needCloseWorldPointUI = false
                                                    needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                                    local worldPointPos = BuildingUtils.GetBuildModelCenterVecNotTile(build.mainIndex, 3)
                                                    worldPointPos.z = worldPointPos.z + 1.5
                                                    GoToUtil.GotoWorldPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function ()
                                                        SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                                                            local _param = {}
                                                            _param["uuid"] = build.uuid
                                                            _param["pointId"] = build.mainIndex
                                                            _param["ownerUid"] = build.ownerUid
                                                            _param["type"] = WorldPointUIType.City
                                                            _param["isAlliance"] = true
                                                            _param["buildId"] = itemId
                                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                                            local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.City..";".."1"..";"..itemId
                                                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                                                        else
                                                            
                                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
                                                        end
                                                    end,LuaEntry.Player:GetCurServerId(),LuaEntry.Player:GetCurWorldId())
                                                else
                                                    if UIUtil.IsSeasonBuild(build.itemId) then
                                                        needCloseWorldPointUI = false
                                                        needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                                        UIUtil.ShowWorldPointView(build, build.itemId)
                                                    else
                                                        needCloseUI[UIWindowNames.UIWorldTileUI] = nil
                                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldTileUI) then
                                                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldTileUI,tostring(build.mainIndex))
                                                        else
                                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldTileUI,{anim = true,playEffect = false},tostring(build.mainIndex),needChangeCamera)
                                                        end
                                                    end
                                                    
                                                end

                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                elseif build.ownerUid ~= LuaEntry.Player.uid then
                    if build.level >= 0 then
                        local allianceId = LuaEntry.Player.allianceId
                        local itemId = build.itemId
                        if itemId ==nil or itemId == 0 then
                            itemId = build.buildId
                        end
                        if build.allianceId~=nil and allianceId~=nil and allianceId~="" and build.allianceId~="" and build.allianceId == allianceId then
                            if itemId == BuildingTypes.FUN_BUILD_MAIN then
                                needCloseWorldPointUI = false
                                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                local worldPointPos = BuildingUtils.GetBuildModelCenterVec(build.mainIndex, 3)
                                if playerBuildingDontReset then
                                    --local serverId = LuaEntry.Player:GetCurWorldId()
                                    --local crossServerId = LuaEntry.Player:GetCrossServerId()
                                    --if crossServerId~=serverId then
                                    --    GoToUtil.CheckCrossWar(LuaEntry.Player:GetCurServerId())
                                    --    CrossServerUtil.OnCrossServer(serverId)
                                    --end
                                    --
                                    --SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                    --if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                    --    local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.City..";".."1"..";"..itemId
                                    --    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,str)
                                    --else
                                    --    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,{anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide},build.uuid,build.mainIndex,build.ownerUid,WorldPointUIType.City,1,itemId)
                                    --end
                                    if offsetTile ~= nil then
                                        local x, z = SceneUtils.IndexToTileXY(build.mainIndex, ForceChangeScene.World)
                                        z = z + offsetTile.y
                                        x = x + offsetTile.x
                                        local pos = SceneUtils.TileXYToWorld(x,z, ForceChangeScene.World)
                                        worldPointPos.x = pos.x
                                        worldPointPos.z = pos.z
                                    end
                                    worldPointPos.z = worldPointPos.z + 1.5
                                    GoToUtil.GotoWorldPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function ()
                                         SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                                            local _param = {}
                                            _param["uuid"] = build.uuid
                                            _param["pointId"] = build.mainIndex
                                            _param["ownerUid"] = build.ownerUid
                                            _param["type"] = WorldPointUIType.City
                                            _param["isAlliance"] = true
                                            _param["buildId"] = itemId
                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                            local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.City..";".."1"..";"..itemId
                                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                                        else
                                            
                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
                                        end
                                    end,LuaEntry.Player:GetCurServerId(),LuaEntry.Player:GetCurWorldId(), false)
                                else
                                    local curX, curY = SceneUtils.WorldToTileXZ(worldPointPos.x, worldPointPos.z, ForceChangeScene.World)
                                    local pos = SceneUtils.TileXYToWorld(curX, curY,  ForceChangeScene.World)
                                    worldPointPos.x = pos.x
                                    worldPointPos.z = pos.z + 1.5
                                    GoToUtil.GotoWorldPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function ()
                                        SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                                            local _param = {}
                                            _param["uuid"] = build.uuid
                                            _param["pointId"] = build.mainIndex
                                            _param["ownerUid"] = build.ownerUid
                                            _param["type"] = WorldPointUIType.City
                                            _param["isAlliance"] = true
                                            _param["buildId"] = itemId
                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                            local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.City..";".."1"..";"..itemId
                                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                                        else
                                            
                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                                        end
                                    end,LuaEntry.Player:GetCurServerId(),LuaEntry.Player:GetCurWorldId())
                                end
                            else
                                needCloseWorldPointUI = false
                                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                                    local _param = {}
                                    _param["uuid"] = build.uuid
                                    _param["pointId"] = build.mainIndex
                                    _param["ownerUid"] = build.ownerUid
                                    _param["type"] = WorldPointUIType.Build
                                    _param["isAlliance"] = true
                                    _param["buildId"] = itemId
                                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                    local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.Build..";".."1"..";"..itemId
                                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                                else
                                    
                                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
                                end
                                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPlayerPoint,info.mainIndex,info.ownerUid,1,info.uuid)
                            end
                        else
                            if itemId == BuildingTypes.FUN_BUILD_MAIN then
                                needCloseWorldPointUI = false
                                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                local worldPointPos = BuildingUtils.GetBuildModelCenterVec(info.mainIndex, 3)
                                worldPointPos.z = worldPointPos.z + 1.5
                                GoToUtil.GotoWorldPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function ()
                                    --SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                    SUSoundUtil.PlayEffect(SoundAssets.Click_OtherPlayerCity)
                                    if DataCenter.CrossWonderManager:CheckShowMoveCityTips(build,info) then
                                        UIManager:GetInstance():OpenWindow(UIWindowNames.UICrossWonderMoveCityTips)
                                    else
                                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                                            local _param = {}
                                            _param["uuid"] = build.uuid
                                            _param["pointId"] = build.mainIndex
                                            _param["ownerUid"] = build.ownerUid
                                            _param["type"] = WorldPointUIType.City
                                            _param["isAlliance"] = false
                                            _param["buildId"] = itemId
                                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                                            local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.City..";".."0"..";"..itemId
                                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                                        else
                                            
                                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                                        end

                                        --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPlayerBuild,info.inside,info.ownerUid,0,info.uuid)
                                    end
                                end,LuaEntry.Player:GetCurServerId(),LuaEntry.Player:GetCurWorldId())
                            else
                                needCloseWorldPointUI = false
                                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                                SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Building)
                                UIUtil.ShowWorldPointView(build, itemId)
                                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,info.uuid,info.mainIndex,info.ownerUid,WorldPointUIType.Build,0,info.itemId)
                                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPlayerPoint,info.mainIndex,info.ownerUid,0,info.uuid)
                            end

                        end
                    end
                end
            end
        elseif info.PointType == WorldPointType.WORLD_TALK_TASK then
            local data = DataCenter.RadarCenterDataManager:GetDetectEventInfo(info.uuid)
            if data then
                local template = DataCenter.DetectEventTemplateManager:GetDetectEventTemplate(data.eventId)
                if template ~= nil and template.type == DetectEventType.DetectTalkWorld then
                    local id_group = template.para
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIDetectNpc,{anim = false,playEffect = false,UIMainAnim = UIMainAnimType.AllHide},{uuid = info.uuid,id_group = id_group})
                    -- SFSNetwork.SendMessage(MsgDefines.SU_DetectDialog,{uuid = info.uuid, dialogId = })
                    -- todo打开对应的界面
                    needCloseWorldPointUI = true
                end
            end
        elseif info.PointType == WorldPointType.WorldCollectResource then
            local collectInfo = CS.SceneManager.World:GetCollectInfoByIndex(info.pointIndex)
            if collectInfo~=nil then
                needCloseWorldPointUI = false
                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                local uiType = WorldPointUIType.CollectPoint
                if collectInfo.type == ResPointType.Alliance then
                    uiType = WorldPointUIType.AllianceCollectPoint
                end
                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                    local _param = {}
                    _param["uuid"] = 0
                    _param["pointId"] = info.mainIndex
                    _param["ownerUid"] = ""
                    _param["type"] = uiType
                    _param["isAlliance"] = false
                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                    local str = "0"..";"..info.mainIndex..";"..""..";"..uiType..";".."0"..";".."0"
                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                else
                    
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                end
                local param = {}
                param.collectType = collectInfo:GetResourceType()
                DataCenter.GuideManager:SetCompleteNeedParam(param)
                DataCenter.GuideManager:CheckGuideComplete()
            end 
        elseif info.PointType == WorldPointType.NPC_CITY then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Click_Building)
            local worldPointPos = SceneUtils.TileIndexToWorld(info.mainIndex)
            GoToUtil.GotoPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function()
                CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Click_Building)
                local uid = NpcCityUtil.UuidToNpcUid(info.uuid)
                local itemId = BuildingTypes.FUN_BUILD_MAIN
                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                    local _param = {}
                    _param["uuid"] = info.uuid
                    _param["pointId"] = info.mainIndex
                    _param["ownerUid"] = uid
                    _param["type"] = WorldPointUIType.NpcCity
                    _param["isAlliance"] = false
                    _param["buildId"] = itemId
                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                    local str = info.uuid..";"..info.mainIndex..";"..uid..";"..WorldPointUIType.NpcCity..";".."0"..";"..itemId
                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                else
                    
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                end
            end, LuaEntry.Player:GetCurServerId(), false)
            --local worldPointPos = SceneUtils.TileIndexToWorld(info.mainIndex)
            --GoToUtil.GotoPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime, function()
            --    
            --end, LuaEntry.Player:GetCurServerId())
        elseif info.PointType == WorldPointType.WorldResource then
            local data =  DataCenter.WorldPointManager:GetResourcePointInfoByIndex(info.pointIndex)
            if data ~= nil then
                local gatherUuid = data.gatherMarchUuid
                if gatherUuid ==nil or gatherUuid == 0 then
                    gatherUuid = data.gatherUuid
                end
                if gatherUuid~=nil and gatherUuid ~= 0 then
                    --依次判断自己-->盟友-->敌人
                    local marchInfo = DataCenter.WorldMarchDataManager:GetMarch(gatherUuid)
                    if marchInfo ~= nil then
                        needCloseWorldPointUI = false
                        needCloseUI[UIWindowNames.UIWorldPoint] = nil
                        local isAlliance = false
                        local isAlliance1 = 0
                        if marchInfo.allianceUid ~= "" and marchInfo.allianceUid == LuaEntry.Player.allianceId then
                            isAlliance = true
                            isAlliance1 = 1
                        end
                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                            local _param = {}
                            _param["uuid"] = gatherUuid
                            _param["pointId"] = info.mainIndex
                            _param["ownerUid"] = marchInfo.ownerUid
                            _param["type"] = WorldPointUIType.CollectArmy
                            _param["isAlliance"] = isAlliance
                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                            local str = gatherUuid..";"..info.mainIndex..";"..marchInfo.ownerUid..";"..WorldPointUIType.CollectArmy..";"..isAlliance1
                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                        else
                            
                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                        end
                    end
                else
                    local id = info.id
                    if id ==nil then
                        id = data.resourceId
                    end
                    local triggerType = GetTableData(TableName.GatherResource, id,"resource_type")
                    local resourceType = tonumber(triggerType)
                    triggerType = tostring(triggerType)
                    if DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ClickWorldCollectPoint, triggerType) then
                        local pos = SceneUtils.TileIndexToWorld(curIndex, ForceChangeScene.World)
                        GoToUtil.GotoWorldPos(pos)
                    else
                        needCloseWorldPointUI = false
                        needCloseUI[UIWindowNames.UIWorldPoint] = nil
                        local uiType = WorldPointUIType.CollectPoint
                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                            local _param = {}
                            _param["uuid"] = 0
                            _param["pointId"] = info.mainIndex
                            _param["ownerUid"] = ""
                            _param["type"] = uiType
                            _param["isAlliance"] = false
                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                            local str = "0"..";"..info.mainIndex..";"..""..";"..uiType..";".."0"..";".."0"
                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                        else
                            
                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                        end
                    end
                end
                local param = {}
                param.point = info.pointIndex
                DataCenter.GuideManager:SetCompleteNeedParam(param)
                DataCenter.GuideManager:CheckGuideComplete()
            end
        elseif info.PointType == WorldPointType.SAMPLE_POINT or info.PointType == WorldPointType.SAMPLE_POINT_NEW then
            --local data = CS.SceneManager.World:GetSamplePointInfoByIndex(info.pointIndex)
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldSamplePointUI, info.pointIndex, data.uuid)
            local data = DataCenter.WorldPointManager:GetSamplePointInfoByIndex(info.pointIndex)
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = data.uuid
                _param["pointId"] = info.pointIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.Sample
                _param["isAlliance"] = false
            --DataCenter.TroopActionManager:DoTroopAction(TroopActionType.TROOP_ACTION_TYPE_RADAR_CENTER)
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = data.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.Sample..";".."0"..";".."0"
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
            end
            local template = DataCenter.GuideManager:GetCurTemplate()
            if template ~= nil and template.type == GuideType.ClickRadarMonster then
                DataCenter.GuideManager:DoNext()
            end
        elseif info.PointType == WorldPointType.EXPLORE_POINT or info.PointType == WorldPointType.DETECT_EVENT_PVE then
            local data = DataCenter.WorldPointManager:GetExplorePointInfoByIndex(info.pointIndex)
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            --if info.PointType == WorldPointType.EXPLORE_POINT then
            --    --SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_Gulu)
            --end
            --DataCenter.TroopActionManager:DoTroopAction(TroopActionType.TROOP_ACTION_TYPE_RADAR_CENTER)
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = data.uuid
                _param["pointId"] = info.pointIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.Explore
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = data.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.Explore..";".."0"..";".."0"
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
            end
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldExplorePointUI, info.pointIndex, data.uuid)

        elseif info.PointType == WorldPointType.GARBAGE then
            SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Click_GroundGoods)
            local param = {}
            param.isClickGarbage = true
            DataCenter.GuideManager:SetCompleteNeedParam(param)
            DataCenter.GuideManager:CheckGuideComplete()
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldGarbagePointUI, info.pointIndex)
            local data = DataCenter.WorldPointManager:GetGarbagePointInfoByIndex(info.pointIndex)
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = data.uuid
                _param["pointId"] = info.pointIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.PickGarbage
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = data.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.PickGarbage..";".."0"..";".."0"
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
            end

        elseif info.PointType == WorldPointType.WORLD_ALLIANCE_CITY then
            if DataCenter.CrossWonderManager:CheckShowMoveCityTips(nil,info) then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UICrossWonderMoveCityTips)
            elseif info~=nil then
                local allianceCityPointInfo = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.AllianceCityPointInfo")
                if allianceCityPointInfo~=nil then
                    needCloseUI[UIWindowNames.UIWorldSiegePoint] = nil
                    local cityId = allianceCityPointInfo.cityId
                    local tile = GetTableData(TableName.WorldCity,cityId, "size")
                    local eden_city_type = GetTableData(TableName.WorldCity,cityId, "eden_city_type")
                    local showGuide = false
                    if LuaEntry.Player.serverType == ServerType.EDEN_SERVER then
                        if eden_city_type == WorldCityType.AlliancePass then
                            showGuide = DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.EnterSeasonOpenIntro,tostring(SeasonIntroType.Pass))
                        elseif eden_city_type == WorldCityType.StrongHold then
                            showGuide = DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.EnterSeasonOpenIntro,tostring(SeasonIntroType.Stronghold))
                        end
                    end
                    if showGuide ==false then
                        local worldPos = SceneUtils.TileIndexToWorld(info.mainIndex)
                        worldPos.x = worldPos.x ---1
                        worldPos.z = worldPos.z ---1
                        local pointIndex = SceneUtils.WorldToTileIndex(worldPos)
                        SUSoundUtil.PlayWorldMusic(info.PointType, cityId)

                        local flag = UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldSiegePoint)
                        if not flag then
                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldSiegePoint, NormalPanelAnim, allianceCityPointInfo.cityId,pointIndex, WorldPointType.WORLD_ALLIANCE_CITY)
                        end
                    else
                        local worldPos = SceneUtils.TileIndexToWorld(info.mainIndex)
                        --worldPos.x = worldPos.x - tile+1
                        --worldPos.z = worldPos.z - tile+1
                        local pointIndex = SceneUtils.WorldToTileIndex(worldPos)
                        DataCenter.GuideManager:SetGuideEndCallBack(function()
                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldSiegePoint,NormalPanelAnim, cityId, pointIndex, WorldPointType.WORLD_ALLIANCE_CITY)
                        end)
                    end
                end
            end
        elseif info.PointType == WorldPointType.WORLD_ALLIANCE_BUILD then
            local alMinePointInfo = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.AllianceBuildingPointInfo")
            if alMinePointInfo then
                needCloseWorldPointUI = false
                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                local buildId = alMinePointInfo["buildId"]
                if buildId == BuildingTypes.ALLIANCE_FLAG_BUILD or WorldAllianceBuildUtil.IsAllianceCenterGroup(buildId) ==true or WorldAllianceBuildUtil.IsAllianceFrontGroup(buildId) then
                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                        local _param = {}
                        _param["uuid"] = info.uuid
                        _param["pointId"] = info.mainIndex
                        _param["ownerUid"] = ""
                        _param["type"] = WorldPointUIType.AllianceBuild
                        _param["buildId"] = buildId
                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                        local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.AllianceBuild..";".."0"..";"..buildId
                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                    else
                        
                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                    end
                elseif WorldAllianceBuildUtil.IsAllianceMineGroup(buildId) then
                    SUSoundUtil.PlayEffect(SoundAssets.Click_OIL)
                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                        local _param = {}
                        _param["uuid"] = info.uuid
                        _param["pointId"] = info.mainIndex
                        _param["ownerUid"] = ""
                        _param["type"] = WorldPointUIType.AllianceMine
                        _param["buildId"] = buildId
                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                        local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.AllianceMine..";".."0"..";"..buildId
                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                    else
                        
                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                    end
                elseif WorldAllianceBuildUtil.IsAllianceActMineGroup(buildId) then
                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                        local _param = {}
                        _param["uuid"] = info.uuid
                        _param["pointId"] = info.mainIndex
                        _param["ownerUid"] = ""
                        _param["type"] = WorldPointUIType.AllianceActMine
                        _param["buildId"] = buildId
                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                        local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.AllianceActMine..";".."0"..";"..buildId
                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                    else
                        
                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                    end
                end

            end
        elseif info.PointType == WorldPointType.DRAGON_BUILDING then
            --巨龙建筑点击
            local buildInfo = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.DragonBuildingPointInfo")
            if buildInfo then
                if buildInfo.buildId == 10060 then
                    --巨龙Boss建筑，不做处理
                    return
                end
                
                needCloseWorldPointUI = false
                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                local buildId = buildInfo["buildId"]
                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = info.uuid
                _param["pointId"] = info.mainIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.DragonBuild
                _param["buildId"] = buildId
                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                    local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.DragonBuild..";".."0"..";"..buildId
                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                else
                    
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                end

            end
        elseif info.PointType == WorldPointType.SECRET_KEY then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = info.uuid
                _param["pointId"] = info.mainIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.DragonSecretKey
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.DragonSecretKey
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
            end
        elseif info.PointType == WorldPointType.HERO_DISPATCH then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local worldPointPos = SceneUtils.TileIndexToWorld(curIndex)
            -- GoToUtil.GotoWorldPos(worldPointPos)
            GoToUtil.GotoPos(worldPointPos, CS.SceneManager.World.Zoom, LookAtFocusTime,function()
                
            local dispatchMission = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.DispatchMission")
            if dispatchMission~=nil then
                local mgr = DataCenter.ActDispatchTaskDataManager
                local player = LuaEntry.Player
                local selfUid = player.uid
                local now = UITimeManager:GetInstance():GetServerTime()
                local canAward = dispatchMission.finishTime > 0 and dispatchMission.finishTime <= now
                if selfUid == dispatchMission.ownerUid then
                    if not canAward  then
                        if dispatchMission.finishTime == 0 then
                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationDispatchTask,OpenWinAnimFalse,dispatchMission.uuid,curIndex)    
                        else
                            UIUtil.ShowTipsId(894234)
                        end
                        return
                    else
                        SFSNetwork.SendMessage(MsgDefines.DispatchReward, dispatchMission.uuid)
                        return
                    end
                end
            end
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = info.uuid
                _param["pointId"] = info.mainIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.DispatchTask
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.DispatchTask..";".."0"..";".."0"
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
            end
            end,LuaEntry.Player:GetCurServerId())
            
        elseif info.PointType == WorldPointType.WorldRuinPoint then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local ownerUid = ""
            local isAlliance = 0
            local desertId = 0
            local uuid = 0

            if not CommonUtil.IsInDragonActivity() and ((SeasonUtil.IsSeasonNeedConnectDesert() and CrossServerUtil:GetIsCrossServer() ==false) or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil.GetCrossServerFightIsInSeason()) or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil:GetIsInBattleServerGroup(LuaEntry.Player:GetCurServerId())==true))then
                local worldTileInfo = nil --CS.SceneManager.World:GetWorldTileInfo(curIndex)
                if worldTileInfo~=nil then
                    local desertInfo = worldTileInfo:GetWorldDesertInfo()
                    if desertInfo~=nil then
                        ownerUid = desertInfo.ownerUid
                        local allianceId = desertInfo.allianceId
                        if allianceId ~= "" and allianceId == LuaEntry.Player.allianceId then
                            isAlliance = 1
                        end
                        desertId = desertInfo.desertId
                        uuid =desertInfo.uuid
                    end
                end
                local level = GetTableData(TableName.Desert,desertId, "desert_level")
                local checkLevel = toInt(level)
                local canClick = true
                if checkLevel == nil or checkLevel<=0 then
                    if (SceneUtils.IsInBlackRange(curIndex)==true and LuaEntry.DataConfig:CheckSwitch("rocky_groud_season")==false) then
                        canClick = false
                    end
                end
                if canClick== true and (not string.IsNullOrEmpty(ownerUid) or not DataCenter.MissileManager:IsRuinPoint(curIndex)) then
                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                        local _param = {}
                        _param["uuid"] = uuid
                        _param["pointId"] = curIndex
                        _param["ownerUid"] = ownerUid
                        _param["type"] = WorldPointUIType.Desert
                        _param["isAlliance"] = isAlliance
                        _param["buildId"] = 0
                        _param["desertId"] = desertId
                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint)==false then
                        
                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
                    else
                        if tonumber(level) ~= nil and tonumber(level) > 0 then
                            local str = uuid..";"..curIndex..";"..ownerUid..";"..WorldPointUIType.Desert..";"..isAlliance..";".."0"..";".."0"..";"..desertId
                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                        end
                    end
                end
            end
            if string.IsNullOrEmpty(ownerUid) then
                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                    local _param = {}
                    _param["uuid"] = info.uuid
                    _param["pointId"] = info.mainIndex
                    _param["ownerUid"] = ""
                    _param["type"] = WorldPointUIType.Ruin
                    _param["isAlliance"] = isAlliance
                    _param["buildId"] = 0
                    _param["desertId"] = desertId
                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                    local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.Ruin..";"..isAlliance..";".."0"..";".."0"..";"..desertId
                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
                else
                    
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
                end
            end
        elseif info.PointType == WorldPointType.WorldMonster then
            local marchInfo = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.WorldPointMonster")
            if marchInfo then
                needCloseWorldPointUI = false
                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                SUSoundUtil.PlayWorldMusic(info.PointType, marchInfo.type)
--                if marchInfo.type == MONSTER or marchInfo.type == BOSS then
--                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                        local _param = {}
--                        _param["uuid"] = info.uuid
--                        _param["pointId"] = info.pointIndex
--                        _param["ownerUid"] = ""
--                        _param["type"] = WorldPointUIType.Monster
--                        _param["buildId"] = 0
--                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                        local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.Monster..";".."0"..";".."0"
--                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                    else
--                        
--                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--                    end
--
--                    local obj = DataCenter.WorldPointManager:GetObjectByPoint(curIndex)
--                    if obj~=nil and obj.OnClickThis then
--                        obj:OnClickThis()
--                    end
--                elseif marchInfo.type == ACT_BOSS then
--                    local isCanShowWorldPointView = false
--                    local dataList = DataCenter.ActivityListDataManager:GetActivityDataByType(ActivityEnum.ActivityType.WorldBoss)
--                    if #dataList > 0 then
--                        isCanShowWorldPointView = DataCenter.ActivityListDataManager:CheckIsSend(dataList[1])
--                    end
--                    if isCanShowWorldPointView then
--                        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                            local _param = {}
--                            _param["uuid"] = info.uuid
--                            _param["pointId"] = info.pointIndex
--                            _param["ownerUid"] = ""
--                            _param["type"] = WorldPointUIType.ActBoss
--                            _param["buildId"] = 0
--                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                            local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.ActBoss..";".."0"..";".."0"
--                            EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                        else
--                            
--                            UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--                        end
--                    else
--                        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIWorldPoint)
--                        end
--                        UIUtil.ShowTips(Localization:GetString("140212", dataList[1].needMainCityLevel))
--                    end
--                    
--                elseif marchInfo.type == PUZZLE_BOSS then
--                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                        local _param = {}
--                        _param["uuid"] = info.uuid
--                        _param["pointId"] = info.pointIndex
--                        _param["ownerUid"] = ""
--                        _param["type"] = WorldPointUIType.PuzzleBoss
--                        _param["buildId"] = 0
--                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                        local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.PuzzleBoss..";".."0"..";".."0"
--                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                    else
--                        
--                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
--                    end
--                elseif marchInfo.type == CHALLENGE_BOSS then
--                    local isCanShowWorldPointView = false
--                    local dataList = DataCenter.ActivityListDataManager:GetActivityDataByType(ActivityEnum.ActivityType.MonsterTower)
--                    if #dataList > 0 then
--                        isCanShowWorldPointView = DataCenter.ActivityListDataManager:CheckIsSend(dataList[1])
--                        if isCanShowWorldPointView then
--                            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                                local _param = {}
--                                _param["uuid"] = info.uuid
--                                _param["pointId"] = info.mainIndex
--                                _param["ownerUid"] = ""
--                                _param["type"] = WorldPointUIType.ChallengeBoss
--                                _param["buildId"] = 0
--                            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                                local str = info.uuid..";"..info.mainIndex..";"..""..";"..WorldPointUIType.ChallengeBoss..";".."0"..";".."0"
--                                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                            else
--                                
--                                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--                            end
--                        else
--                            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                                UIManager:GetInstance():DestroyWindow(UIWindowNames.UIWorldPoint)
--                            end
--                            UIUtil.ShowTips(Localization:GetString("140212", dataList[1].needMainCityLevel))
--                        end
--                    else
--                        UIUtil.ShowTipsId(302183)
--                    end
--                elseif marchInfo.type == ALLIANCE_BOSS then
--                    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
--                        local _param = {}
--                        _param["uuid"] = info.uuid
--                        _param["pointId"] = info.pointIndex
--                        _param["ownerUid"] = ""
--                        _param["type"] = WorldPointUIType.AllianceBoss
--                        _param["buildId"] = 0
--                    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
--                        local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.AllianceBoss..";".."0"..";".."0"
--                        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
--                    else
--                        
--                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
--                    end
--                end
            end
        elseif info.PointType == WorldPointType.GodzillaGift then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            needCloseUI[UIWindowNames.UIFormationSelectListNew] = nil
            local treasureInfo = info.treasureInfo
            if treasureInfo ~= nil then
                local typeValue = toInt(GetTableData("precious_deposits", treasureInfo.configId,"type"))
                if typeValue == 1 then
                    UIUtil.ClickGodzillaGift(info.pointIndex)
                elseif typeValue == 2 then
                    UIUtil.ClickAllianceTreasure(info.pointIndex)
                elseif typeValue == 3 then
                    UIUtil.ClickDroppedTreasure(info.pointIndex)
                end
            end
        elseif info.PointType == WorldPointType.ACT_RESOURCE then
            needCloseWorldPointUI = false
            needCloseUI[UIWindowNames.UIWorldPoint] = nil
            local actresource = info.actresource
            if actresource ~= nil then
                UIUtil.ClickActResourcePoint(info.pointIndex)
            end
        end
    else
        if  not CommonUtil.IsInDragonActivity()
                and ((SeasonUtil.IsInSeasonDesertMode() and CrossServerUtil:GetIsCrossServer() ==false)
                or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil.GetCrossServerFightIsInSeason())
                or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil:GetIsInBattleServerGroup(LuaEntry.Player:GetCurServerId())==true)
                or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil:IsCheckSrcServer()))
                or (CrossServerUtil:GetIsCrossServer() and CrossServerUtil.GetActCrossServerIsInSeason()) then
            -- 地格
            local desertInfo = DataCenter.WorldPointManager:GetDesertInfo(curIndex)
            if desertInfo ~=nil then
                needCloseWorldPointUI = false
                needCloseUI[UIWindowNames.UIWorldPoint] = nil
                local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local uiParam = {}
                uiParam.uuid = desertInfo.uuid
                uiParam.pointId = curIndex
                uiParam.ownerUid = desertInfo.ownerUid
                uiParam.type = WorldPointUIType.Desert
                uiParam.desertId = desertInfo.desertId
                local allianceId = desertInfo.allianceId
                if allianceId ~= "" and allianceId == LuaEntry.Player.allianceId then
                    uiParam.isAlliance = 1
                end
                if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                    EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView, uiParam)
                else
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint, _panelConfig, uiParam)
                end
            else
                ------ 空地
                --if curIndex > 0 then
                --    needCloseWorldPointUI = false
                --    needCloseUI[UIWindowNames.UIWorldPoint] = nil
                --    local uiParam = {}
                --    uiParam.pointId = curIndex
                --    uiParam.type = WorldPointUIType.Empty
                --    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                --        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView, uiParam)
                --    else
                --        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint, OpenWinAnimTrue, uiParam)
                --    end
                --    showGrid = true
                --end
            end
        else
            local lod = CS.SceneManager.World:GetLodLevel()
            if lod >= 4 then
                if curIndex > 0 then
                    needCloseWorldPointUI = false
                    needCloseUI[UIWindowNames.UIWorldPoint] = nil
                    local worldPointPos = SceneUtils.TileIndexToWorld(curIndex)
                    GoToUtil.GotoPos(worldPointPos, World_InitZoom, LookAtFocusTime, nil)
                end
            end
        end
    end
    if needCloseWorldPointUI == true then
        if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIWorldPoint)
        end
    end
    for k,v in pairs(needCloseUI) do
        if v then
            if k == UIWindowNames.UIFormationSelectListNew then
                if UIManager:GetInstance():IsWindowOpen(k) then
                    EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true)
                end

            end
            UIManager:GetInstance():DestroyWindow(k)
        end
    end
    --if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIFormationSelectListNew) then
    --    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIFormationSelectListNew)
    --    EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true)
    --end

    if needCloseIsFocus then
        --先特殊处理
        if not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIMoveCity) then
            CS.SceneManager.World:QuitFocus(LookAtFocusTime)
        end
    end
end

function UIUtil.ShowWorldPointView(build , itemId)
    local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
    local _param = {}
    _param["uuid"] = build.uuid
    _param["pointId"] = build.mainIndex
    _param["ownerUid"] = build.ownerUid
    _param["type"] = WorldPointUIType.Build
    _param["buildId"] = itemId
    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
        local str = build.uuid..";"..build.mainIndex..";"..build.ownerUid..";"..WorldPointUIType.Build..";".."0"..";"..itemId
        EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
    else

        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
    end
end

local function CloseWorldMarchTileUI(uuid)
    if uuid~=nil then
        WorldMarchTileUIManager:GetInstance():RemoveTroopByUuid(uuid)
        WorldMarchEmotionManager:GetInstance():DestroyPanel(uuid)
    else
        WorldMarchTileUIManager:GetInstance():RemoveTroop()
        WorldMarchEmotionManager:GetInstance():DestroyAllPanels()
    end

end

-- 当前建筑不能升级警徽，查找一个可以升级警徽的建筑
function UIUtil.GoToFindCanUpPoliceInsigniaBuild(buildUuid, findList)
    if DataCenter.GuideManager:InGuide() then
        return
    end
    
    if not buildUuid then
        return
    end
    local mgr = DataCenter.BuildManager
    if not mgr then
        return
    end
    local policeMgr = DataCenter.BuildPoliceInsigniaManager
    if not policeMgr then
        return
    end
    
    local curData = mgr:GetBuildingDataByUuid(buildUuid)
    if not curData then
        return
    end
    if not DataCenter.MainCityAreaDataManager:IsTileUnlocked(curData.pointId) then
        return
    end
    local order = policeMgr:GetPoliceInsigniaDependencyOrderByUuid(buildUuid)
    if order == 0 then
        return 
    end
    local dependencyInfo = policeMgr:GetPoliceInsigniaDependencyOrder(order)
    if not dependencyInfo then
        return
    end
    if findList == nil then
        findList = {}
        findList.findState = false
    else
        if findList.findState then
            return
        end
    end
    
    local findUuid = nil
    for _,v in pairs(dependencyInfo.dependencyOrder) do
        local uuids = policeMgr:GetPoliceInsigniaDependencyUuidsByOrder(v.order)
        if uuids and #uuids > 0 then
            local uuid = uuids[1]
            local data = mgr:GetBuildingDataByUuid(uuid)
            local result = data.level < v.level
            if result then
                --这个还没升级，需要看看其父依赖是否完成，如果父依赖完成，则跳转这个
                local dependCheck = policeMgr:CheckPoliceInsigniaDependencyBuildFinishByUuid(uuid)
                if dependCheck then
                    findUuid = uuid
                    findList.findState = true
                    break
                else
                    -- 依赖的也没解锁升级
                    UIUtil.GoToFindCanUpPoliceInsigniaBuild(uuid, findList)
                end
            end
        end
    end

    if findUuid then
        UIUtil.ShowTipsId(894014)
        GoToUtil.GotoCityByBuildUuid(findUuid, WorldTileBtnType.PoliceInsigniaOut)
    end
end

local function CheckPubButtonOpen(btnType)
    local k2 = LuaEntry.DataConfig:TryGetStr("free_heroes", "k2")
    if string.IsNullOrEmpty(k2) then
        return true
    end
    local vec = string.split(k2, ";")
    local mainLv = DataCenter.BuildManager.MainLv

    local index = -1
    if btnType == WorldTileBtnType.Hero_Recruit then
        index = 1
    elseif btnType == WorldTileBtnType.Hero_Advance then
        index = 2
    elseif btnType == WorldTileBtnType.HeroResetShop then
        index = 3
    elseif btnType == WorldTileBtnType.City_Details then
        index = 4
    elseif btnType == WorldTileBtnType.Poster_Exchange then
        index = 5
    elseif btnType == WorldTileBtnType.HeroMedalShop then
        index = 6
    end
    if index < 0 or index > table.count(vec) then
        return true
    end
    return mainLv >= toInt(vec[index])
end

local function GetSUCityBuildBtns(buildInfo)
    local buttonList = {}
    if buildInfo ~= nil then
        local uuid = buildInfo.uuid
        local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
        if buildData ~= nil then
            local buildId = buildData.itemId

            if buildId == BuildingTypes.Survival_Cabinet or buildId == BuildingTypes.Survival_Cabinet_Newbie then
                table.insert(buttonList,WorldTileBtnType.SU_Warehouse)
            elseif table.hasvalue(FactoryBuild, buildId) then --工厂类
                table.insert(buttonList,WorldTileBtnType.SU_Factory)
            elseif table.hasvalue(BarracksBuild, buildId) then --造兵建筑
                local queue = DataCenter.QueueDataManager:GetQueueByType(DataCenter.ArmyManager:GetArmyQueueTypeByBuildId(buildId))
                if queue ~= nil then
                    local state = queue:GetQueueState()
                    if state == NewQueueState.Finish then
                        SFSNetwork.SendMessage(MsgDefines.QueueFinish, { uuid = queue.uuid })
                    end
                end
                if buildId == BuildingTypes.FUN_BUILD_CAR_BARRACK then
                    table.insert(buttonList,WorldTileBtnType.City_TrainingTank)
                elseif buildId == BuildingTypes.FUN_BUILD_INFANTRY_BARRACK then
                    table.insert(buttonList,WorldTileBtnType.City_TrainingInfantry)
                elseif buildId == BuildingTypes.FUN_BUILD_AIRCRAFT_BARRACK then
                    table.insert(buttonList,WorldTileBtnType.City_TrainingAircraft)
                end
            elseif buildId == BuildingTypes.Survival_Bed then
                table.insert(buttonList,WorldTileBtnType.SU_Bed)
            elseif buildId == BuildingTypes.Survival_Mail then
                table.insert(buttonList,WorldTileBtnType.SU_Mail)
            elseif buildId == BuildingTypes.Survival_Bar then
                table.insert(buttonList,WorldTileBtnType.SU_Bar)
            elseif buildId == BuildingTypes.Survival_WeaponFactory then
                table.insert(buttonList, WorldTileBtnType.SU_Blueprint_Weapon)
            elseif buildId == BuildingTypes.Survival_EquipFactory then
                table.insert(buttonList, WorldTileBtnType.SU_Blueprint_Equip)
            elseif buildId == BuildingTypes.FUN_BUILD_SCIENE or buildId == BuildingTypes.FUN_BUILD_SCIENCE_PART or buildId == BuildingTypes.FUN_BUILD_SCIENCE_1 then
                local queue = DataCenter.QueueDataManager:GetQueueByBuildUuidForScience(uuid)
                if queue ~= nil then
                    local state = queue:GetQueueState()
                    if state == NewQueueState.Finish then
                        SFSNetwork.SendMessage(MsgDefines.QueueFinish, { uuid = queue.uuid })
                    end
                end
                table.insert(buttonList,WorldTileBtnType.City_Science)
            elseif buildId == BuildingTypes.FUN_BUILD_HOSPITAL then
                local queue = DataCenter.QueueDataManager:GetQueueByType(NewQueueType.Hospital)
                if queue ~= nil then
                    local state = queue:GetQueueState()
                    if state == NewQueueState.Finish then
                        SFSNetwork.SendMessage(MsgDefines.QueueFinish, { uuid = queue.uuid })
                    end
                end
                table.insert(buttonList,WorldTileBtnType.City_Recovery)
            elseif  buildId == BuildingTypes.FUN_BUILD_TRAINFIELD_1 or buildId == BuildingTypes.FUN_BUILD_TRAINFIELD_2 or buildId == BuildingTypes.FUN_BUILD_TRAINFIELD_3 then
                if EquipmentUtil.IsEquipmentSysOpen() then
                    table.insert(buttonList,WorldTileBtnType.GarageEquipment)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_POLICE_STATION then
                table.insert(buttonList, WorldTileBtnType.PoliceStation)
            elseif buildId == BuildingTypes.FUN_BUILD_SMITHY then
                table.insert(buttonList, WorldTileBtnType.AllianceBattle)
            elseif buildId == BuildingTypes.FUND_BUILD_ALLIANCE_CENTER then
                table.insert(buttonList, WorldTileBtnType.AllianceEntrance)
            elseif buildId == BuildingTypes.APS_BUILD_WORMHOLE_MAIN then	--虫洞入口
                table.insert(buttonList, WorldTileBtnType.WormHoleToB)
            elseif buildId == BuildingTypes.FUN_BUILD_MARKET then
                table.insert(buttonList,WorldTileBtnType.City_QiFei)
            elseif buildId == BuildingTypes.FUN_BUILD_TRADING_CENTER then
                --如果显示召回按钮则不显示这个图标
                --local recall = DataCenter.EarthOrderDataManager:checkIsRecall()
                --if recall == false then
                    --table.insert(buttonList,WorldTileBtnType.City_EarthOrder)
                --end
            elseif buildId == BuildingTypes.APS_BUILD_FARM  then
                local open  = LuaEntry.Effect:GetGameEffect(EffectDefine.ROBOT_IN_FARM)
                if open > 0 then
                    table.insert(buttonList,WorldTileBtnType.City_Robot_Set)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_KONBINI then
                table.insert(buttonList,WorldTileBtnType.Konbini)
            elseif buildId == BuildingTypes.FUN_BUILD_BUSINESS_CENTER then
                --if DataCenter.ResidentOrderDataManager:GetOrderSendLeftTime() <= 0 then
                    --table.insert(buttonList,WorldTileBtnType.City_BusinessCenter)
                --end
            elseif buildId == BuildingTypes.FUN_BUILD_COLD_STORAGE then
                table.insert(buttonList,WorldTileBtnType.City_ColdCapacity)
            elseif buildId == BuildingTypes.FUN_BUILD_WATER_STORAGE then
                table.insert(buttonList,WorldTileBtnType.City_ColdCapacity)
            elseif buildId == BuildingTypes.APS_BUILD_PUB then
                if self:CheckPubButtonOpen(WorldTileBtnType.Hero_Recruit) then
                    table.insert(buttonList,WorldTileBtnType.Hero_Recruit)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_COMPREHENSIVE_STORAGE then
                table.insert(buttonList,WorldTileBtnType.City_IntegratedWarehouse)
            elseif buildId == BuildingTypes.FUN_BUILD_ELECTRICITY then
                table.insert(buttonList,WorldTileBtnType.City_ResourceTransport)
            elseif buildId == BuildingTypes.FUN_BUILD_DEFENCE_CENTER then
                table.insert(buttonList,WorldTileBtnType.City_Defence)
            elseif buildId == BuildingTypes.FUN_BUILD_DEFENCE_CENTER_NEW then
                if EquipmentUtil.IsEquipmentSysOpen() then
                    table.insert(buttonList,WorldTileBtnType.DefenceSuitEquipment)
                end
                local showLevel = LuaEntry.DataConfig:TryGetNum("battle_config", "k15")
                if DataCenter.BuildManager.MainLv >= showLevel then
                    table.insert(buttonList,WorldTileBtnType.City_Defence)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_SPEED then
                table.insert(buttonList,WorldTileBtnType.BuildNitrogen)
            elseif buildId == BuildingTypes.FUN_BUILD_RADAR_CENTER then
                local effect = Mathf.Round(LuaEntry.Effect:GetGameEffect(EffectDefine.DETECT_EVENT_FUNCTION_OPEN))
                if effect > 0 then
                    table.insert(buttonList,WorldTileBtnType.RadarCenter_Detective)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_GROCERY_STORE then
                if DataCenter.CommonShopManager:CheckIfModuleOpen() then
                    table.insert(buttonList, WorldTileBtnType.CommonShop)
                end
                local num = LuaEntry.Effect:GetGameEffect(EffectDefine.EFFECT_GULU_STORE_OPEN)
                if num > 0 then
                    table.insert(buttonList, WorldTileBtnType.City_GROCERY_STORE)
                end
                local isAvailable = DataCenter.MonthCardNewManager:CheckIfGolloesMonthCardAvailable()
                if isAvailable and LuaEntry.DataConfig:CheckSwitch("APS_monthcard") then
                    table.insert(buttonList, WorldTileBtnType.GolloesCamp)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_BARRACKS then
                table.insert(buttonList, WorldTileBtnType.ARMY)
            elseif buildId == BuildingTypes.FUN_BUILD_MAIN then
                --400000  大本暂时按钮注释（策划让的）
                -- local showLevel = LuaEntry.DataConfig:TryGetNum("battle_config", "k15")
                -- if DataCenter.BuildManager.MainLv >= showLevel then
                --     table.insert(buttonList,WorldTileBtnType.City_Defence)
                -- end
                -- local configOpenState = LuaEntry.DataConfig:CheckSwitch("base_talent_switch")
                -- if configOpenState then
                --     table.insert(buttonList,WorldTileBtnType.Talent)
                -- end
            --elseif buildId == BuildingTypes.FUN_BUILD_DRONE then
            --    if DataCenter.WorldTrendManager:CheckOpen() and DataCenter.BuildManager.MainLv >= 4 then
            --        table.insert(buttonList,WorldTileBtnType.WorldTrend)
            --    end
            elseif buildId == BuildingTypes.FUN_BUILD_HERO_MONUMENT then
                table.insert(buttonList,WorldTileBtnType.PveMonument)
            elseif buildId == BuildingTypes.FUN_BUILD_HERO_BOUNTY then
                if buildData.level > 0 then
                    table.insert(buttonList,WorldTileBtnType.HeroBounty)
                end
            elseif buildId == BuildingTypes.FUN_BUILD_HERO_OFFICE then
                table.insert(buttonList,WorldTileBtnType.HeroOfficial)
            elseif buildId == BuildingTypes.FUN_BUILD_HERO_BAR then
                table.insert(buttonList,WorldTileBtnType.LevelExplore)
            elseif buildId == BuildingTypes.Survival_Bathe then
                table.insert(buttonList,WorldTileBtnType.bathe)
            end
        end
    end

    return buttonList
end

local function OnSUCityBuildBtnClick(param)
    local btnType = param.btnType
    local info = param.info
    local buildTemplate = param.buildTemplate
    if btnType == WorldTileBtnType.City_MyProfile then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIPlayerInfo, info.ownerUid)
    elseif btnType == WorldTileBtnType.City_Upgrade then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UINewBuildUpgrade, info.uuid)
    elseif btnType == WorldTileBtnType.City_SpeedUp then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed,ItemSpdMenu.ItemSpdMenu_City,info.uuid)
    elseif btnType == WorldTileBtnType.City_SpeedUpRuins then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed,ItemSpdMenu.ItemSpdMenu_Fix_Ruins,info.uuid)
    elseif btnType == WorldTileBtnType.City_Attack then

    elseif btnType == WorldTileBtnType.HeroBounty then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroBountyMain, { anim = true, UIMainAnim = UIMainAnimType.AllHide })
    elseif btnType == WorldTileBtnType.HeroOfficial then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroOfficial)
--    elseif btnType == WorldTileBtnType.LevelExplore then
--        UIManager:GetInstance():OpenWindow(UIWindowNames.UILevelExplore)
--    elseif btnType == WorldTileBtnType.Museum then
--        UIManager:GetInstance():OpenWindow(UIWindowNames.UIMuseum)
    elseif btnType == WorldTileBtnType.City_TrainingAircraft or btnType == WorldTileBtnType.City_TrainingTank
            or btnType == WorldTileBtnType.City_TrainingInfantry then
        local queue = DataCenter.QueueDataManager:GetQueueByType(DataCenter.ArmyManager:GetArmyQueueTypeByBuildId(info.itemId))
        if queue ~= nil then
            local state = queue:GetQueueState()
            if state == NewQueueState.Finish then
                SFSNetwork.SendMessage(MsgDefines.QueueFinish, { uuid = queue.uuid })
            end
        end
        UIManager:GetInstance():OpenWindow(UIWindowNames.UITrain,info.itemId)
    elseif btnType == WorldTileBtnType.City_Science then
        DataCenter.ScienceManager:CheckResearchFinishByBuildUuid(info.uuid)
        GoToUtil.GotoScience(nil,nil,info.uuid)
        return
        
    elseif btnType == WorldTileBtnType.City_Recovery then
        local queue = DataCenter.QueueDataManager:GetQueueByType(NewQueueType.Hospital)
        if queue ~= nil then
            local state = queue:GetQueueState()
            if state == NewQueueState.Finish then
                SFSNetwork.SendMessage(MsgDefines.QueueFinish, { uuid = queue.uuid })
            end
        end
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHospital)
    elseif btnType == WorldTileBtnType.WormHole_Enter then
        local mainBuildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
        local aNum = DataCenter.BuildManager:GetHaveBuildNumWithOutFoldUpByBuildId(BuildingTypes.APS_BUILD_WORMHOLE_SUB)
        if mainBuildData~=nil and aNum>0 then
            MarchUtil.OnClickStartMarch(MarchTargetType.GO_WORM_HOLE,LuaEntry.Player:GetMainWorldPos(), mainBuildData.uuid)
        end
    elseif btnType == WorldTileBtnType.WormHole_Create then
        --建筑虫洞
        --检查下是否已有部队正在前往修建虫洞
        local selfMarch = DataCenter.WorldMarchDataManager:GetOwnerMarches(LuaEntry.Player.uid, LuaEntry.Player.allianceId)
        local count = #selfMarch
        if count > 0 then
            for i = 1, count do
                local march = selfMarch[i]
                --正在修建
                if march:GetMarchStatus() == MarchStatus.BUILD_WORM_HOLE then
                    return 	UIUtil.ShowSUMainMsgId(121268)
                end
                --已有部队正在前往
                if march:GetMarchTargetType() == MarchTargetType.BUILD_WORM_HOLE then
                    return 	UIUtil.ShowSUMainMsgId(121267)
                end
            end
        end
        MarchUtil.OnClickStartMarch(MarchTargetType.BUILD_WORM_HOLE, info.mainIndex, info.uuid)
    elseif btnType == WorldTileBtnType.WormHole_Dismantle then
        local uuid = info.uuid
        UIUtil.ShowMessage(Localization:GetString(121046),2,nil,nil,function ()SFSNetwork.SendMessage(MsgDefines.FreeBuildingFoldUpNew,{buildUuid = uuid})end,nil)
    --elseif btnType == WorldTileBtnType.WormHoleToB then
        --local list = DataCenter.BuildManager:GetAllBuildingByItemIdWithoutPickUp(BuildingTypes.APS_BUILD_WORMHOLE_SUB)
        --if #list > 0 then
            --local buildData = list[1]
            --local targetServerId = buildData.server
            --local pointId = buildData.pointId
            --if pointId>0 then
                --local position = TileCoordWorld.TileIndexToWorld(pointId,ForceChangeScene.World)
                ----position.x = position.x-1
                ----position.y = position.y
                ----position.z = position.z-1
                --UIUtil.ShowMessage(Localization:GetString(121265,Localization:GetString("156012")),2, GameDialogDefine.CONFIRM, GameDialogDefine.CANCEL, function()
                    --GoToUtil.GotoWorldPos(position,nil,nil,function()
                        --WorldArrowManager:GetInstance():ShowArrowEffect(0,position,ArrowType.Building)
                    --end,targetServerId)
                --end)
            --end
        --else
            --UIUtil.ShowSUMainMsgId(140259)
        --end
    --elseif btnType == WorldTileBtnType.WormHoleToC then
        --if CrossServerUtil:CanShowCrossSubwayBuildBtn() then
            --if DataCenter.CrossWormManager:IsNewWormTrain() then
                --UIManager:GetInstance():OpenWindow(UIWindowNames.UICrossWorm, 1)
            --else
                --GoToUtil.GotoCrossWorm()
            --end
        --else
            --UIUtil.ShowSUMainMsgId(104274)
        --end


    --elseif btnType == WorldTileBtnType.CrossWormHoleEnter then
        --if CrossServerUtil:CanPlaceCrossSubway() then
            --local crossBuildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.WORM_HOLE_CROSS)
            --if crossBuildData~=nil then
                --local targetServerId = crossBuildData.server
                --MarchUtil.OnClickStartMarch(MarchTargetType.CROSS_SERVER_WORM,LuaEntry.Player:GetMainWorldPos(), crossBuildData.uuid,nil,nil,nil,targetServerId)
            --else
                --UIUtil.ShowSUMainMsgId(104273)
            --end
        --else
            --UIUtil.ShowSUMainMsgId(104274)
        --end
    elseif btnType == WorldTileBtnType.CrossWormHero then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UICrossWormHero, info.uuid)
    elseif btnType == WorldTileBtnType.City_Details then
        local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(info.uuid)
        if buildData.itemId == BuildingTypes.WORM_HOLE_CROSS and DataCenter.CrossWormManager:IsNewWormTrain() then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UICrossWorm, 1)
        else
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIBuildDetails,info.uuid)
        end
    elseif btnType == WorldTileBtnType.PoliceStation then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIPoliceStation)
    elseif btnType == WorldTileBtnType.SeasonBuildPickUp then
        local uuid = info.uuid
        UIUtil.ShowMessage(Localization:GetString(GameDialogDefine.BUILD_PUCK_UP_CONFIRM_DES),2,nil,nil, function ()
            SFSNetwork.SendMessage(MsgDefines.FreeBuildingFoldUpNew,{buildUuid = uuid}) end,nil)
    elseif btnType == WorldTileBtnType.AssistanceSeasonBuild then
        local mainLv = DataCenter.BuildManager.MainLv
        local needMainLv = LuaEntry.DataConfig:TryGetNum("assistance_open", "k1")
        if mainLv >= needMainLv then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationAssistance,info.uuid,LuaEntry.Player.uid,info.pointIndex,AssistanceType.Build)
        else
            UIUtil.ShowSUMainMsg(Localization:GetString(121005, needMainLv))
        end
    elseif btnType == WorldTileBtnType.DesertOperate then
        local uuid = info.uuid
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIDesertOperate, { anim = true, UIMainAnim = UIMainAnimType.AllHide }, uuid)
    elseif btnType == WorldTileBtnType.City_PickUp then
        local tempBuild = DataCenter.BuildManager:GetBuildingDataByUuid(info.uuid)
        if tempBuild ~= nil  then
            local resourceType = DataCenter.BuildManager:GetOutResourceTypeByBuildId(tempBuild.itemId)
            if resourceType ~= ResourceType.None then
                if tempBuild.state == BuildingStateType.Normal and tempBuild:IsConnect() then
                    local num = DataCenter.BuildManager:GetOutResourceNum(info.uuid)
                    if num > 0 then
                        local worldPos = SceneUtils.TileIndexToWorld(tempBuild.pointId)
                        local pos = CS.SceneManager.World:WorldToScreenPoint(worldPos)
                        --DataCenter.FlyResourceEffectManager:ShowGetResourceEffect(pos,resourceType,FlyMoneyCount)
                        DataCenter.DecResourceEffectManager:DecOneItemEffect(worldPos + FlyGetResourceDelta,ResourceTypeIconName[resourceType],num,info.uuid)
                    end
                end
                local itemId = nil
                local levelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(tempBuild.itemId, tempBuild.level)
                if levelTemplate ~= nil then
                    if resourceType == ResourceType.ResourceItem then
                        local resourceItemId = levelTemplate:GetOutResourceItemId()
                        itemId = resourceItemId
                    end
                end
                SFSNetwork.SendMessage(MsgDefines.UserResSynNew,{resourceType = resourceType, itemId = itemId})
            end
            if DataCenter.BuildManager:IsCanOutItemByBuildId(tempBuild.itemId) then
                if tempBuild.state == BuildingStateType.Normal and tempBuild:IsConnect() and DataCenter.BuildManager:IsHaveItem(info.uuid) then
                    SFSNetwork.SendMessage(MsgDefines.ReceiveBuildingGrowValReward,{uuid = info.uuid})
                end
            end
        end
        SFSNetwork.SendMessage(MsgDefines.FreeBuildingFoldUpNew,{buildUuid = info.uuid})
    --elseif btnType == WorldTileBtnType.City_EarthOrder then
        ----if not DataCenter.HeroStationManager.SWITCH_ON or LuaEntry.Effect:GetGameEffect(EffectDefine.EARTH_ORDER_UNLOCK) == 1 then
        --if LuaEntry.Effect:GetGameEffect(EffectDefine.EARTH_ORDER_UNLOCK) == 1 then
            --local info_temp = DataCenter.EarthOrderDataManager:GetOneEarthOrder()
            --if info_temp ~= nil then
                ----判断是否在播放动画
                --local isAnim = false
                --if CS.SceneManager.World ~= nil then
                    --local city = CS.SceneManager.World:GetBuildingByPoint(info_temp.pointIndex)
                    --if city ~= nil then
                        --cast(city, typeof(CS.BaseRocketCenter))
                        --if city:IsArriving() then
                            --isAnim = true
                        --end
                    --end
                --end
                --if isAnim then
                    --UIUtil.ShowSUMainMsgId(GameDialogDefine.PLEASE_WAIT_ROCKET_STOP)
                --else
                    --if DataCenter.EarthOrderDataManager:IsPreviewStatus()then
----                        UIManager:GetInstance():OpenWindow(UIWindowNames.UINoEarthOrder, NextBusinessComeType.EARTH_ORDER)
                    --else
                        --CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Repair)
----                        UIManager:GetInstance():OpenWindow(UIWindowNames.UIEarthOrder,{ anim = true, UIMainAnim = UIMainAnimType.AllHide },info_temp.uuid)
                        ----GoToUtil.OpenInCity(function()
                        ----end, BuildingTypes.FUN_BUILD_TRADING_CENTER)
                    --end
                --end
            --else
----                UIManager:GetInstance():OpenWindow(UIWindowNames.UINoEarthOrder, NextBusinessComeType.EARTH_ORDER)
            --end
        --else
            --UIUtil.ShowSUMainMsgId(129000)
            --return
        --end

    elseif btnType == WorldTileBtnType.City_Product then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIFactory2, info.uuid)
    elseif btnType == WorldTileBtnType.City_BusinessCenter then
        UIUtil.CheckAndOpenBusinessCenter()
    elseif btnType == WorldTileBtnType.City_ColdCapacity then
        
    elseif btnType == WorldTileBtnType.City_IntegratedWarehouse then
        
--    elseif btnType == WorldTileBtnType.City_ResourceTransport then
        --打开运输资源页面
--        UIManager:GetInstance():OpenWindow(UIWindowNames.UITransportRes,info.uuid)
    elseif btnType == WorldTileBtnType.Hero_Advance then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroAdvance, {anim = true,UIMainAnim = UIMainAnimType.AllHide})
    --elseif btnType == WorldTileBtnType.Hero_Bag then
    --    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroBag, {anim = true,UIMainAnim = UIMainAnimType.AllHide})
    elseif btnType == WorldTileBtnType.GolloesCamp then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIGolloesCamp, OpenWinAnimTrue)
    elseif btnType == WorldTileBtnType.Poster_Exchange then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroPosterExchangeMain, {anim = true,UIMainAnim = UIMainAnimType.AllHide})
    elseif btnType == WorldTileBtnType.Hero_Recruit then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroRecruit)
    elseif btnType == WorldTileBtnType.City_SpeedUpTrain then
        local queue = DataCenter.QueueDataManager:GetQueueByType(DataCenter.ArmyManager:GetArmyQueueTypeByBuildId(info.itemId))
        if queue ~= nil then
            local state = queue:GetQueueState()
            if state == NewQueueState.Work then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed,ItemSpdMenu.ItemSpdMenu_Soldier,queue.uuid)
            end
        end
    elseif btnType == WorldTileBtnType.City_SpeedUpScience then
        local queue = DataCenter.QueueDataManager:GetQueueByBuildUuidForScience(info.uuid)
        if queue ~= nil then
            local state = queue:GetQueueState()
            if state == NewQueueState.Work then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed,ItemSpdMenu.ItemSpdMenu_Science,queue.uuid)
            end
        end
    elseif btnType == WorldTileBtnType.City_SpeedUpHospital then
        local queue = DataCenter.QueueDataManager:GetQueueByType(NewQueueType.Hospital)
        if queue ~= nil then
            local state = queue:GetQueueState()
            if state == NewQueueState.Work then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed,ItemSpdMenu.ItemSpdMenu_Heal,queue.uuid)
            end
        end
    elseif btnType == WorldTileBtnType.City_IntegratedWarehouse then
        

    elseif btnType == WorldTileBtnType.City_Defence then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationDefenceTable)
    elseif btnType == WorldTileBtnType.City_BatteryrAttack then
        
    elseif btnType == WorldTileBtnType.City_Assistance then
        local selfUid = LuaEntry.Player.uid
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationAssistance,info.uuid,selfUid,info.mainIndex,AssistanceType.Build)
    elseif btnType == WorldTileBtnType.RadarCenter_Alert then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIDetectEvent)
    elseif btnType == WorldTileBtnType.RadarCenter_Detective then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIDetectEvent)
    elseif btnType == WorldTileBtnType.City_Repair then
        local uuid = info.uuid
        SFSNetwork.SendMessage(MsgDefines.UserStartFixBuilding,uuid)
    elseif btnType == WorldTileBtnType.AllianceEntrance then
        if LuaEntry.Player:IsInAlliance() ==false then
            GoToUtil.GotoAllianceIntroView(OpenWinAnimTrue)
        else
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIAllianceMainTable)
        end
    elseif btnType == WorldTileBtnType.AllianceResSupport then
        if not LuaEntry.Player:IsInAlliance() then
            UIUtil.ShowSUMainMsgId(390838)
            return
        end
        local data =  DataCenter.AllianceBaseDataManager:GetAllianceBaseData()
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIAllianceMemberDetail,OpenWinAnimTrue,data.uid, AllianceMemberOpenType.ResSupport)
    elseif btnType == WorldTileBtnType.AllianceBattle then
        if not LuaEntry.Player:IsInAlliance() then
            UIUtil.ShowSUMainMsgId(390536)
            return
        end
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIAllianceWarMainTable,2)
    --elseif btnType == WorldTileBtnType.City_GROCERY_STORE then
        --local reachLimit = DataCenter.GroceryStoreOrderDataManager:IsReachMax()
        --if reachLimit == true then
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIReachLimit, NextBusinessComeType.GROCERY_STORE)
        --else
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIGroceryStore)
        --end
    elseif btnType == WorldTileBtnType.City_Robot_Set then
        local bUuid = info.uuid
        local queue = DataCenter.BuildQueueManager:GetQueueDataByBuildUuid(bUuid,false,false)
        if queue~=nil then
            SFSNetwork.SendMessage(MsgDefines.UserRobotDismiss,queue.uuid)
        else
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIBuildList,UIBuildListTabType.Robot,false,bUuid)
            UIManager:GetInstance():OpenWIndow(UIWindowNames.UIBuildQueueList, OpenWinAnimTrue)
        end
    elseif btnType == WorldTileBtnType.ARMY then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIArmyInfo)
    elseif btnType == WorldTileBtnType.WorldNews then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldBattleNews)
    elseif btnType == WorldTileBtnType.Notice then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIMainNotice,OpenWinAnimTrue)
    elseif btnType == WorldTileBtnType.Hero_Station then
        UIUtil.OpenHeroStationByBuildUuid(info.uuid)
    elseif btnType == WorldTileBtnType.StorageShop then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIStorageShopMain)
    elseif btnType == WorldTileBtnType.CommonShop then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonShop)
    elseif btnType == WorldTileBtnType.Konbini then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIKonbini, info.uuid)
    elseif btnType == WorldTileBtnType.GarageRefit then
        if DataCenter.GarageRefitManager:IsOpenNewGarageRefit() then
            local needMainLv = DataCenter.GarageRefitManager.needMainLv
            if DataCenter.BuildManager.MainLv >= needMainLv then
                Logger.Log("讲道理这里不会执行，如果执行了，请检查 GarageRefitManager:IsOpenNewGarageRefit 函数")
                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIGarageRefit, info.itemId)
            else
                UIUtil.ShowSUMainMsg(Localization:GetString(140339, needMainLv))
            end
        end
    elseif btnType == WorldTileBtnType.GarageRefitDrone then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIAircraftMain)
    elseif btnType == WorldTileBtnType.GarageEquipment then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIEquipmentMain, {anim = true, UIMainAnim = UIMainAnimType.AllHide}, info.itemId)
    elseif btnType == WorldTileBtnType.EquipmentBag then
        CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Click_Open_Equipment_Factory)
        UIManager:GetInstance():OpenWindow(UIWindowNames.EquipmentBag)
    elseif btnType == WorldTileBtnType.PveMonument then
        --local id = DataCenter.PveMonumentManager:GetNextId()
        --if id then
        --    DataCenter.PveMonumentManager:Enter(id)
        --end
    --elseif btnType == WorldTileBtnType.Talent then
    --    UIManager:GetInstance():OpenWindow(UIWindowNames.UITalentInfo, {anim = true, UIMainAnim = UIMainAnimType.AllHide}, DataCenter.TalentDataManager.specialShowTalentId)
    elseif btnType == WorldTileBtnType.HeroResetShop then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroResetShop)
    elseif btnType == WorldTileBtnType.Decoration then
        DecorationUtil.OpenDecorationPanel()
        return
    --elseif btnType == WorldTileBtnType.HeroMedalShop then
    --    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroMedalShop, {anim = true, UIMainAnim = UIMainAnimType.AllHide })
    --elseif btnType == WorldTileBtnType.SU_Bed then
        --local bUuid = info.uuid
        --local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(bUuid)
        --local buildObj = DataCenter.BattleLevel:GetObjMgr():GetObjectByUuid(bUuid)
        --if buildData ~= nil and buildObj ~= nil then
            --local levelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildData.itemId, buildData.level)
            --if levelTemplate ~= nil then
                --local now = UITimeManager:GetInstance():GetServerTime()
                --local lastCollectTime = buildData.lastCollectTime
                --local offset = tonumber(levelTemplate.para1) or 0
                --local t = tonumber(levelTemplate.para2) or 3
                --if lastCollectTime + offset * 1000 <= now then
                    --local Effect_Build = require "Scene.PVEBattleLevel.MapObject.MapObjectEffect_Build"
                    --local buildEffect = Effect_Build.New(buildObj)
                    --buildObj.isUsing = true
                    --buildEffect:CreateEventPointEffect(bUuid, t, function()
                        --SFSNetwork.SendMessage(MsgDefines.SU_BuildUse, bUuid)
                    --end)
                --else
                    --UIUtil.ShowSUMainMsgId(799084)
                --end
            --end
        --end
    elseif btnType == WorldTileBtnType.SU_Mail then
        GoToUtil.GotoOpenView(UIWindowNames.UIMailNew)
    elseif btnType == WorldTileBtnType.SU_Bar then
        local levelId = buildTemplate.para1
        if not string.IsNullOrEmpty(levelId) then
            local id = tonumber(levelId)
            local k5 = LuaEntry.DataConfig:TryGetNum("c_initial_Parameter", "k5")
            local emptySlotCount = DataCenter.BagGridDataManager:GetPlayerPocketData():GetEmptySlotCount()
            if k5 >= emptySlotCount and id ~= LevelId.Main then
                UIUtil.ShowMessage(Localization:GetString(820459), 2, 820457, 820458, function()
                    local pveTemplate = DataCenter.PveLevelTemplateManager:GetTemplate(id)
                    if pveTemplate ~= nil then
                        local param = {}
                        param.pveEntrance = PveEntrance.Test
                        param.levelId = id
                        param.isStart = false
                        SceneManager.ChangeToLevel(param)
                    else
                        Logger.LogError("Can't get level " .. tostring(id))
                    end
                end)
            else
                local pveTemplate = DataCenter.PveLevelTemplateManager:GetTemplate(id)
                if pveTemplate ~= nil then
                    local param = {}
                    param.pveEntrance = PveEntrance.Test
                    param.levelId = id
                    param.isStart = false
                    SceneManager.ChangeToLevel(param)
                else
                    Logger.LogError("Can't get level " .. tostring(id))
                end
            end
        end
    elseif btnType == WorldTileBtnType.SU_Repair then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UI_SUBuildRepair, OpenWinAnimTrue, {info.uuid})
    elseif btnType == WorldTileBtnType.SU_Blueprint_Weapon then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIBluePrint, { anim = true, UIMainAnim = UIMainAnimType.AllHide}, {buildId = BuildingTypes.Survival_WeaponFactory})
    elseif btnType == WorldTileBtnType.SU_Blueprint_Equip then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIBluePrint, { anim = true, UIMainAnim = UIMainAnimType.AllHide}, {buildId = BuildingTypes.Survival_EquipFactory})
    elseif btnType == WorldTileBtnType.SU_Warehouse then
        BagUtil.OpenBagView({showType = BagUtil.ShowType.Cabinet, uuid = info.uuid})
    elseif btnType == WorldTileBtnType.SU_Factory then
        local isOpen = LuaEntry.DataConfig:CheckSwitch("factory_button")
        if DataCenter.BuildManager:IsFactoryBuild(buildTemplate.id) and not isOpen then
            if DataCenter.FactoryDataManager:HasUnlockItemByBuildId(buildTemplate.id) then
                WorldArrowManager:GetInstance():RemoveEffect()
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIFactory2, {anim = true, UIMainAnim = UIMainAnimType.AllHide}, info.uuid)
            end
        end
    elseif btnType == WorldTileBtnType.bathe then
        --local batheConsume = LuaEntry.DataConfig:TryGetStr("shower", "k2")--洗澡消耗x瓶水
        --local _tabPara = string.string2table_ii(batheConsume, '|', ';')
        --local reqItemList = {}
        --for k, v in pairs(_tabPara) do
            --reqItemList[#reqItemList+1] = {["itemId"] = k, ["reqNum"] = v}
        --end

        --local callback = function(ret)
            --DataCenter.BatheManager:SetCurBuildInfo(info)
            --SFSNetwork.SendMessage(MsgDefines.SU_Shower)
        --end
        --local titleStr = Localization:GetString(820719)
        --local tipStr = Localization:GetString(820713)
        --local btnStr = Localization:GetString(820720)
        --local param = {reqItemList = reqItemList,
                       --callback = callback,
                       --titleStr = titleStr,
                       --tipStr = tipStr,
                       --btnStr = btnStr,
        --}

        --UIManager:GetInstance():OpenWindow(UIWindowNames.UIGive, OpenWinAnimTrue, param)
    end
end


-- titleText:标题文本
-- tipText:描述文本
-- btnNum:按钮个数
-- text1:左边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- text2:右边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- action1:点击左边按钮回调函数
-- action2:点击右边按钮回调函数
-- closeAction:点击x和黑色背景回调函数
-- btnNoUseDialog:text1和text2类型 为true表示文本 为空表示多语言
-- leftBtnPicName:左边按钮图片路径
-- rightBtnPicName:右边按钮图片路径
local function ShowUseDiamondConfirm(todayType, tipText, btnNum, text1, text2, action1, action2, closeAction, titleText, btnNoUseDialog, leftBtnPicName, rightBtnPicName)
    local needShowConfirm = Setting:GetPrivateBool(SettingKeys.SHOW_USE_DIAMOND_ALERT, true)
    if needShowConfirm == true and DataCenter.SecondConfirmManager:GetTodayCanShowSecondConfirm(todayType) then
        UIUtil.ShowSecondMessage(titleText,tipText,btnNum,text1,text2, function()
            action1()
        end, function(needSellConfirm)
            DataCenter.SecondConfirmManager:SetTodayNoShowSecondConfirm(todayType,needSellConfirm)
        end,action2,closeAction,nil,Localization:GetString(GameDialogDefine.TODAY_NO_SHOW), btnNoUseDialog, leftBtnPicName, rightBtnPicName)
    else
        action1()
    end
end

local function ShowUnlockWindow(title, icon, intro, type, flyEndPos)
    DataCenter.UnlockDataManager:AddData(title, icon, intro, type, flyEndPos)
    if UIManager:GetInstance():GetWindow(UIWindowNames.UIUnLockSuccess) == nil then
        local data = DataCenter.UnlockDataManager:GetFirstData()
        if data ~= nil then
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIUnLockSuccess, { anim = true, playEffect = false, UIMainAnim = UIMainAnimType.LeftRightBottomHide }, data)
        end
    end
end

local function ShowGuideBtnUnlockWindow(title, intro, btnType)
    DataCenter.UnlockDataManager:AddGuideBtnData(title, intro, btnType)
    if UIManager:GetInstance():GetWindow(UIWindowNames.UIUnLockSuccess) == nil then
        local data = DataCenter.UnlockDataManager:GetFirstData()
        if data ~= nil then
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIUnLockSuccess, { anim = true, playEffect = false, UIMainAnim = UIMainAnimType.LeftRightBottomHide }, data)
        end
    end
end

--获取UIMain保存节点的位置
local function GetUIMainSavePos(posType)
    if UIManager:GetInstance():IsPanelLoadingComplete(UIWindowNames.MainUI_SU) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.MainUI_SU)
        if window ~= nil and window.View ~= nil then
            return window.View:GetSavePos(posType)
        end
    end
    return VecZero
end

local function OnPointDownMarch(marchUuid)
    --TroopHeadUIManager:GetInstance():OnPointDownMarch(marchUuid)
end

local function OnPointUpMarch(marchUuid)
    --TroopHeadUIManager:GetInstance():OnPointUpMarch(marchUuid)
end

local function OnMarchDragStart(marchUuid)
    --UIUtil.CloseWorldMarchTileUI(marchUuid,true)
end

local function DoFly(rewardType, num, icon, srcPos, destPos, width, height, callback, useTextFormat,moveTime,timeDelta, uuid, parentNode)
    DataCenter.FlyController.DoFly(rewardType, num, icon, srcPos, destPos, width, height, callback, useTextFormat,moveTime,timeDelta, uuid, parentNode)
end

local function DoFlyCustom(icon, content, num, srcPos, destPos, width, height, callback, model,minRange ,maxRange, parentNode)
    DataCenter.FlyController.DoFlyCustom(icon, content, num, srcPos, destPos, width, height, callback, model, minRange, maxRange, parentNode)
end

local function DoFlyUnlockNewFunc(icon, srcPos, destPos, width, height, moveTime, doMoveTime, loadResCompCallback, callback, isPurple, parentNode)
    DataCenter.FlyController.DoFlyUnlockNewFunc(icon, srcPos, destPos, width, height, moveTime, doMoveTime, loadResCompCallback, callback, isPurple, parentNode)
end


--region ----------------------DoFly到ui下层----------------------
function UIUtil.DoFly_Bottom(rewardType, num, icon, srcPos, destPos, width, height, callback, useTextFormat,moveTime,timeDelta, uuid)
    local uiResourceLayer = UIManager:GetInstance():GetLayer(UILayer.UIResource.Name)
    local parentNode = uiResourceLayer and uiResourceLayer.transform or nil
    UIUtil.DoFly(rewardType, num, icon, srcPos, destPos, width, height, callback, useTextFormat,moveTime,timeDelta, uuid, parentNode)
end

function UIUtil.DoFlyCustom_Bottom(icon, content, num, srcPos, destPos, width, height, callback, model,minRange ,maxRange)
    local uiResourceLayer = UIManager:GetInstance():GetLayer(UILayer.UIResource.Name)
    local parentNode = uiResourceLayer and uiResourceLayer.transform or nil
    UIUtil.DoFlyCustom_Top(icon, content, num, srcPos, destPos, width, height, callback, model,minRange ,maxRange, parentNode)
end

function UIUtil.DoFlyUnlockNewFunc_Bottom(icon, srcPos, destPos, width, height, moveTime, doMoveTime, loadResCompCallback, callback, isPurple)
    local uiResourceLayer = UIManager:GetInstance():GetLayer(UILayer.UIResource.Name)
    local parentNode = uiResourceLayer and uiResourceLayer.transform or nil
    UIUtil.DoFlyCustom_Top(icon, srcPos, destPos, width, height, moveTime, doMoveTime, loadResCompCallback, callback, isPurple, parentNode)
end

function UIUtil.DoJumpFly_Bottom(icon, nums, srcPos, destPos, delay, width, height, callback)
    local uiResourceLayer = UIManager:GetInstance():GetLayer(UILayer.UIResource.Name)
    local parentNode = uiResourceLayer and uiResourceLayer.transform or nil
    UIUtil.DoFlyCustom_Top(icon, nums, srcPos, destPos, delay, width, height, callback, parentNode)
end
--endregion ----------------------DoFly到ui下层----------------------


local function GetSelfMarchCountExceptGolloes()
    local allianceId = LuaEntry.Player.allianceId
    local selfMarches = DataCenter.WorldMarchDataManager:GetOwnerMarches(LuaEntry.Player.uid, allianceId)
    local retCount = 0
    local count = #selfMarches
    for i = 1, count do
        local tempMarch = selfMarches[i]
        if tempMarch:GetMarchType()== NewMarchType.GOLLOES_EXPLORE and tempMarch:GetMarchType() == NewMarchType.GOLLOES_TRADE then
            retCount = retCount + 1
        end
    end
    return retCount
end

local function OpenHeroStationByBuildUuid(bUuid)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UISmallPeopleBuildInfo,OpenWinAnimTrue,bUuid)
    --local config = DataCenter.HeroSmallPeopleDataManager:GetHeroStationByBuildUuid(bUuid)
    --UIManager:GetInstance():OpenWindow(UIWindowNames.UISmallPeopleSurvivors)
end

-- 不能使用,如果不使用建筑的uuid，无法确认打开的是哪个建筑
local function OpenHeroStationByStationId(stationId)
--    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroStation, { anim = true, UIMainAnim = UIMainAnimType.AllHide }, stationId)
end

local function OpenHeroStationByEffectType(effectType, isArrow, highlightLevelUp)
    local skillId = DataCenter.HeroStationManager:GetSkillIdByEffectType(effectType)
    local stationId = DataCenter.HeroStationManager:GetStationIdBySkillId(skillId)
--    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroStation, { anim = true, UIMainAnim = UIMainAnimType.AllHide }, stationId, isArrow, highlightLevelUp)
end

local function CheckAndOpenBusinessCenter()
	--[[
    local reachLimit = DataCenter.ResidentOrderDataManager:IsReachMax()
    if reachLimit == false then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIBusinessCenter)
        return true
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIReachLimit, NextBusinessComeType.RESIDENT_ORDER)
        return false
    end
	]]
    return false
end

local function ShowPiggyBankTip(param)
    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIPiggyBankTip) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIPiggyBankTip)
        window.View:Refresh(param, 0)
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIPiggyBankTip, OpenWinAnimFalse, param)
    end
end

local function ShowEnergyBankTip(param)
    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIEnergyBankTip) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIEnergyBankTip)
        window.View:Refresh(param, 0)
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIEnergyBankTip, OpenWinAnimFalse, param)
    end
end

local function DoJumpFly(icon, nums, srcPos, destPos, delay, width, height, callback, parentNode)
    return DataCenter.FlyController.DoJumpFly(icon, nums, srcPos, destPos, delay, width, height, callback, parentNode)
end

local function GetUIMainEnergySlider()
    if UIManager:GetInstance():IsPanelLoadingComplete(UIWindowNames.MainUI_SU) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.MainUI_SU)
        if window ~= nil and window.View ~= nil then
            return window.View:GetEnergySlider()
        end
    end
    return nil
end

-- useStatic, true: 使用预制体中固定的位置; false: 使用 UIEnergySlider 实时位置
local function GetEnergyIconPos(useStatic)
    if UIManager:GetInstance():IsPanelLoadingComplete(UIWindowNames.MainUI_SU) then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.MainUI_SU)
        if window ~= nil and window.View ~= nil then
            return window.View:GetEnergyIconPos(useStatic)
        end
    end
    return nil
end

local function ShowSelectArmy(param)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UISelectArmy)
    if window == nil then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISelectArmy, OpenWinAnimFalse, param)
    else
        window.View:ReInit(param)
        window.View:Show()
    end
end

local function GetUIMainPromptView()
    local view
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIMainPromptView)
    if window ~= nil and window.View ~= nil then
        view = window.View
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIMainPromptView, NoAnimation)
        window = UIManager:GetInstance():GetWindow(UIWindowNames.UIMainPromptView)
        if window ~= nil and window.View ~= nil then
            view = window.View
        end
    end
    return view
end

local function ShowSUMainPromptHP(hp)
    local npcGirl = UIManager:GetInstance():GetWindow(UIWindowNames.UINpcGirl)
    if npcGirl ~= nil then
        return
    end

    local View = UIUtil.GetUIMainPromptView()
    if View then
        View:ShowHP(hp)
    end
end

local function ShowSUMainPromptZombieHP(hp, zombie, color)
    local View = UIUtil.GetUIMainPromptView()
    if View then
        View:ShowZombieHP(hp, zombie, color)
    end
end

local function ShowSUMainPromptXP(xp)
    local View = UIUtil.GetUIMainPromptView()
    if View then
        View:ShowXP(xp)
    end
end

local function ShowSUUserLevelUp()
--    UIManager:GetInstance():OpenWindow(UIWindowNames.UIPlayerLevelUp, NoAnimation)
end

local function ShowCharacterDialogId(dialogId, character, showTime, nextTime, guideType, avatar, offsetY, isFlip, offsetX, offsetZ)
    DataCenter.CharacterDialogManager:ShowCharacterDialogId(dialogId, character, showTime, nextTime, guideType, avatar, offsetY, isFlip, offsetX, offsetZ)
end

local function GetUIMainMsgView()
    local view
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIMainMsgView)
    if window ~= nil and window.View ~= nil then
        view = window.View
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIMainMsgView, NoAnimation)
        window = UIManager:GetInstance():GetWindow(UIWindowNames.UIMainMsgView)
        if window ~= nil and window.View ~= nil then
            view = window.View
        end
    end
    return view
end


local function ShowSUMainMsg(msg, color,icon)
    local View = UIUtil.GetUIMainMsgView()
    if View then
        View:ShowMsg(msg, color,icon)
    end
end

local function ShowSUMainMsgId(msgId, color)
    local View = UIUtil.GetUIMainMsgView()
    if View then
        View:ShowMsgId(msgId, color)
    end
end

local function ShowSUMainDialog(param)
    local View = UIUtil.GetUIMainMsgView()
    if View then
        View:ShowDialog(param)
    end
end

local function TryMoveCity(topType, targetPointIndex, isForce)
    if CrossServerUtil:GetIsCrossServer() and not isForce then
        UIUtil.ShowTipsId(104266)
    else
        local mainBuild = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
        if mainBuild~=nil then
            --local city = CS.SceneManager.World:GetWorldBuildingByUuid(mainBuild.uuid)
            --if city ~=nil then
            --    city:SetMoveState(true)
            --end
            --if not targetPointIndex then
            --    targetPointIndex = LuaEntry.Player:GetMainWorldPos()
            --end
            local mainCityWorldIndex = LuaEntry.Player:GetMainWorldPos()
            targetPointIndex = (targetPointIndex == nil or targetPointIndex <= 0) and mainCityWorldIndex or targetPointIndex
            if New_Lua_World then
                SceneManager.World:UICreateBuilding(BuildingTypes.FUN_BUILD_MAIN, mainBuild.uuid,targetPointIndex, topType)
            else
                CS.SceneManager.World:UICreateBuilding(BuildingTypes.FUN_BUILD_MAIN, mainBuild.uuid, targetPointIndex, topType)
            end
        end
    end
end

local function GetFlyTargetPosByRewardType(rewardType)
    if rewardType == RewardType.MONEY then
        return UIUtil.GetResourcePos(ResourceType.Money)
    elseif rewardType == RewardType.METAL then
        return UIUtil.GetResourcePos(ResourceType.Metal)
    elseif rewardType == RewardType.WOOD then
        return UIUtil.GetResourcePos(ResourceType.Wood)
    elseif rewardType == RewardType.OIL then
        return UIUtil.GetResourcePos(ResourceType.Oil)
    elseif rewardType == RewardType.ELECTRICITY then
        return UIUtil.GetResourcePos(ResourceType.Electricity)
    elseif rewardType == RewardType.WATER then
        return UIUtil.GetResourcePos(ResourceType.Water)
    elseif rewardType == RewardType.PEOPLE then
        return UIUtil.GetResourcePos(ResourceType.People)
    elseif rewardType == RewardType.POWER or rewardType == RewardType.FlyGoods_Science then
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Power)
    elseif rewardType == RewardType.GOLD then
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Gold)
    elseif rewardType == RewardType.FORMATION_STAMINA then
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Stamina)
    elseif rewardType == RewardType.LM_food then
        return UIUtil.GetResourcePos(ResourceType.LM_food)
    elseif rewardType == RewardType.LM_metal then
        return UIUtil.GetResourcePos(ResourceType.LM_metal)
    elseif rewardType == RewardType.PVE_STAMINA then
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Stamina)
    else
        return UIUtil.GetUIMainSavePos(UIMainSavePosType.Goods)
    end
end

function UIUtil.GetFlyTargetTypeByRewardType(rewardType)
    if rewardType == RewardType.MONEY then
        return ResourceType.Money
    elseif rewardType == RewardType.METAL then
        return ResourceType.Metal
    elseif rewardType == RewardType.WOOD then
        return ResourceType.Wood
    elseif rewardType == RewardType.OIL then
        return ResourceType.Oil
    elseif rewardType == RewardType.ELECTRICITY then
        return ResourceType.Electricity
    elseif rewardType == RewardType.WATER then
        return ResourceType.Water
    elseif rewardType == RewardType.PEOPLE then
        return ResourceType.People
    elseif rewardType == RewardType.POWER or rewardType == RewardType.FlyGoods_Science then
        return UIMainSavePosType.Power
    elseif rewardType == RewardType.GOLD then
        return UIMainSavePosType.Gold
    elseif rewardType == RewardType.FORMATION_STAMINA then
        return UIMainSavePosType.Stamina
    elseif rewardType == RewardType.LM_food then
        return ResourceType.LM_food
    elseif rewardType == RewardType.LM_metal then
        return ResourceType.LM_metal
    elseif rewardType == RewardType.PVE_STAMINA then
        return UIMainSavePosType.Stamina
    elseif rewardType == RewardType.FAKE then
        return nil
    else
        return UIMainSavePosType.Goods
    end
end

local function ShowPvePowerLack(param)
end

local function PveSceneHeroListRefresh()
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIPVEScene)
    if window then
        window.View.hero_list:ResetHeroList()
        window.View.ctrl:OnOneKeyFillClick()
        window.View:RefreshArmy()
    end
end

local function PveSceneHeroListScrollToHero(heroUuid)
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIPVEScene)
    if window then
        window.View.hero_list:ResetHeroList()
        window.View.hero_list:ScrollToHero(heroUuid, true)
    end
end

--解锁类型
local unLockType = {
    level = 1,--玩家等级，1,10=玩家10级解锁
    task = 2,--完成任务，2,1000=完成任务ID=1000的任务
    chapter = 3,--完成章节，3,3=完成章节3解锁
    talent = 4,--天赋是否解锁
    build = 5,--建筑是否解锁
    landLock = 6,--地块解锁
}

--检测按钮功显示
---@param btnId number @按钮ID
---@param showAllFunctionBtn boolean @showAllFunctionBtn
---@param btn table @按钮组件
local function CheckFunctionBtnShow(btnId,showAllFunctionBtn,btn)
    --0隐藏；1置灰
    local mode = GetTableNumber(TableName.SU_FunctionShow, btnId, "lock_mode")
    local isShow = UIUtil.GetIsFunctionUnlock(btnId)
    --如果解锁， 在关卡内根据表中填的条件显示
    if isShow then
        --设置 mode 提前设置一状态,因为跳转场景，主场景跟关卡显示的模式不一样，主场景要隐藏，关卡置灰
        UIUtil.SetFunctionBtnState(btnId, btn,0,isShow)
        UIUtil.SetFunctionBtnState(btnId, btn,1,isShow)
        mode,isShow = UIUtil.GetTableDataUnlockCondition(btnId,mode,isShow)
    end
    if showAllFunctionBtn ~= nil then
        isShow = showAllFunctionBtn
    end
    if btnId == FunctionBtnType.MainTroops and not SceneManager.IsInWorld() then
        isShow = false
    end

    if btnId == FunctionBtnType.sidebar and SceneManager.IsInWorld() then
        isShow = false
    end
    
    if btnId == FunctionBtnType.Mistress and not LuaEntry.DataConfig:CheckSwitch("beauty_switch") then
        isShow = false
    end

    if SceneManager.IsInCity() then
        --if btnId == FunctionBtnType.Radar then
        --    isShow = false
        --end
        if btnId == FunctionBtnType.Level or btnId == FunctionBtnType.Hero or btnId == FunctionBtnType.story then
            if DataCenter.BattleLevel:GetViewMode() == ViewMode.RPG then
                isShow = false
            end
        end
    else
        if btnId == FunctionBtnType.build then
            isShow = false
        end
    end
    
    local needDoGuide = false
    local guideId = DataCenter.GuideManager:CheckUnlockNewFunctionGuide(btnId)
    if guideId ~= nil then
        local template = DataCenter.GuideTemplateManager:GetGuideTemplate(guideId)
        if template then
            if not string.IsNullOrEmpty(template.para5) then
                local para5 = tonumber(template.para5)
                local mainLv = DataCenter.BuildManager.MainLv
                if mainLv < para5 then
                    needDoGuide = true
                end
            end
        end
    end
    
    if showAllFunctionBtn == nil and needDoGuide then
        isShow = false
    end

    -- 直接去掉
    if btnId == FunctionBtnType.Level then
        isShow = false
    end

    if btnId == FunctionBtnType.Activity then
        local list = DataCenter.ActivityListDataManager:GetNowActivityList()
        if table.IsNullOrEmpty(list) then
            isShow = false
        end
    end

    -- 0隐藏；1置灰
    UIUtil.SetFunctionBtnState(btnId, btn,mode,isShow)

    local id_tips = GetTableNumber(TableName.SU_FunctionShow, btnId, "id_tips")

    -- 资源栏上的道具和资源
    if btnId > FunctionBtnType.ResourceBarItemOrResBegin and btnId < FunctionBtnType.ResourceBarItemOrResEnd then
        return isShow, id_tips
    end
    
    local canClick = id_tips ~= ""--如果填了点击提示，需要能点击
    local lockTips = nil --锁定提示，当这个有值时，说明当前是未解锁状态，但是能点击给提示
    --如果没解锁，并且可以点击，将文本Id返回
    if not isShow and canClick then
        lockTips = id_tips
    end

    return isShow,lockTips
end

local hideMainQuest = false
function UIUtil.SetHideMainQuest(value)
    hideMainQuest = value
end
function UIUtil.GetHideMainQuest()
    return hideMainQuest
end

local conditionSplTab = {}
local guaranteeSplTab = {}
--获取功能是否解锁
---@param btnId number @按钮ID
---@return boolean
local function GetIsFunctionUnlock(btnId)
    if btnId == FunctionBtnType.ResourceBar and App.IS_IPhonePlayer() then
        return true
    end

    if btnId == FunctionBtnType.Quest and hideMainQuest then
        return false
    end

    local guarantee_spl = guaranteeSplTab[btnId]
    if not guarantee_spl then
        local lock_guarantee = GetTableData(TableName.SU_FunctionShow, btnId, "lock_guarantee")
        if lock_guarantee ~= "" then
            guarantee_spl = {}
            local spl = string.split_ii_array(lock_guarantee, ";")
            table.insert(guarantee_spl, spl)
            guaranteeSplTab[btnId] = guarantee_spl
        end
    end
    -- 保底条件，只要满足就认为解锁
    if guarantee_spl then
        for i = 1, #guarantee_spl do
            local spl = guarantee_spl[i]
            if #spl == 2 then
                if spl[1] == unLockType.level then
                    local player = DataCenter.CharacterInfoMgr:GetPvePlayerInfo(1)
                    if player ~= nil then
                        if player:GetLevel() >= spl[2] then
                            return true
                        end
                    end
                elseif spl[1] == unLockType.task then
                    if DataCenter.ChapterTaskManager:CheckIsSuccess(spl[2]) or DataCenter.TaskManager:IsFinishTask(spl[2]) then
                        return true
                    end
                elseif spl[1] == unLockType.chapter then
                    local chapterId = DataCenter.ChapterTaskManager:GetCurChapterId()
                    if chapterId > spl[2] or chapterId == 0 then
                        return true
                    end
                elseif spl[1] == unLockType.talent then
                    if DataCenter.TalentDataManager:IsTalentOpen(spl[2]) then
                        return true
                    end
                elseif spl[1] == unLockType.build then
                    local buildId = spl[2] // 100 * 100
                    local level = spl[2] % buildId
                    local isUnlock = DataCenter.BuildManager:IsExistBuildByTypeLv(buildId,level, true)
                    if isUnlock then
                        return true
                    end
                elseif spl[1] == unLockType.landLock then
                    local landLockId = spl[2]
                    local isUnlock = DataCenter.LandLockManager:IsLandIdFinished(landLockId)
                    if isUnlock then
                        return true
                    end
                end
            end
        end
    end
    
    local isShow = true
    local condition_spl = conditionSplTab[btnId]
    --没有取到，缓存一份分割后的数据，不用每次都分割字符串
    if not condition_spl then
        local lock_condition = GetTableData(TableName.SU_FunctionShow, btnId, "lock_condition")
        if lock_condition ~= "" then
            condition_spl = {}
            local condition = string.split_ss_array(lock_condition, ",")
            for i = 1, #condition do
                local spl = string.split_ii_array(condition[i], ";")
                table.insert(condition_spl,spl)
            end
            conditionSplTab[btnId] = condition_spl
        end
    end
    -- 解锁条件，要全部满足才认为解锁
    if condition_spl then
        for i = 1, #condition_spl do
            isShow = false
            local spl = condition_spl[i]
            if #spl == 2 then
                if spl[1] == unLockType.level then
                    local player = DataCenter.CharacterInfoMgr:GetPvePlayerInfo(1)
                    if player ~= nil then
                        if player:GetLevel() >= spl[2] then
                            isShow = true
                        end
                    end
                elseif spl[1] == unLockType.task then
                    if DataCenter.ChapterTaskManager:CheckIsSuccess(spl[2]) or DataCenter.TaskManager:IsFinishTask(spl[2]) then
                        isShow = true
                    end
                elseif spl[1] == unLockType.chapter then
                    local chapterId = DataCenter.ChapterTaskManager:GetCurChapterId()
                    if chapterId > spl[2] or chapterId == 0 then
                        isShow = true
                    end
                elseif spl[1] == unLockType.talent then
                    if DataCenter.TalentDataManager:IsTalentOpen(spl[2]) then
                        isShow = true
                    end
                elseif spl[1] == unLockType.build then
                    local buildId = spl[2] // 100 * 100
                    local level = spl[2] % buildId
                    local isUnlock = DataCenter.BuildManager:IsExistBuildByTypeLv(buildId,level)
                    if isUnlock then
                        isShow = true
                    end
                elseif spl[1] == unLockType.landLock then
                    local landLockId = spl[2]
                    local isUnlock = DataCenter.LandLockManager:IsLandIdFinished(landLockId)
                    if isUnlock then
                        isShow = true
                    end
                elseif spl[1] == unLockType.landLock then
                    local landLockId = spl[2]
                    local isUnlock = DataCenter.LandLockManager:IsLandIdFinished(landLockId)
                    if isUnlock then
                        isShow = true
                    end
                end
            end
            --如果有一个条件不满足，直接结束循环
            if not isShow then
                break
            end
        end
        return isShow
    end
    
    return true
end

--获取表中解锁条件（主要是表中控制的条件）
---@param btnId number @按钮ID
---@param mode number @按钮显示模式 --0隐藏；1置灰
---@param isShow boolean @是否显示
---@return number @mode 按钮显示模式 --0隐藏；1置灰
---@return boolean @isShow 是否显示
local function GetTableDataUnlockCondition(btnId,mode,isShow)
    --Show状态:0=隐藏 1置灰 2正常
    local showState = nil
    if SceneManager.IsInLevel() then
        --boss关卡显示条件
        if DataCenter.BattleLevel:IsHeroBossLevel() then
            --在boss关卡内状态    0=隐藏 1置灰 2正常
            showState = GetTableNumber(TableName.SU_FunctionShow, btnId, "boss_btn_show")
        else
            --在关卡内状态    0=隐藏 1置灰 2正常
            showState = GetTableNumber(TableName.SU_FunctionShow, btnId, "level_btn_show")
        end
    elseif SceneManager.IsInWorld() then
    elseif SceneManager.IsInHome() then
        if DataCenter.BattleLevel:GetViewMode() == ViewMode.RPG then
        elseif DataCenter.BattleLevel:GetViewMode() == ViewMode.SLG then
        end
    end
    if showState then
        --showState:0=隐藏 1置灰 2正常
        mode = showState == 1 and 1 or 0
        isShow = showState == 2
    end
    return mode,isShow
end

--设置按钮状态
---@param btnId number @按钮ID
---@param btn table @按钮
---@param mode number @按钮显示模式
---@param isShow boolean @是否显示
local function SetFunctionBtnState(btnId, btn,mode,isShow)
    if btn then
        -- 0隐藏；1置灰
        if mode == 0 then
            btn:SetActive(isShow)
        elseif mode == 1 then
            local id_tips = GetTableNumber(TableName.SU_FunctionShow, btnId, "id_tips")
            local canClick = id_tips ~= ""--如果填了点击提示，需要能点击
            CS.UIGray.SetGray(btn.transform, not isShow,canClick)
            if not isShow then
                --因为现在传过来的不一定都是按钮，所以都先再外部处理未解锁的点击提示，需要都统一成按钮，这边才能统一处理
                --btn:SetOnClick(function()
                --    --UIUtil.ShowTips(Localization:GetString(id_tips))
                --end)
            end
        else
            Logger.LogError("DO CheckFunctionBtnShow 数据异常  btnId = " .. btnId.." mode = "..tostring(mode))
        end
    end
end

local screenWidth = DeepCopy(CS.UnityEngine.Screen.width)
local function GetScreenWidth(self)
    return  screenWidth
end

local screenHeight = DeepCopy(CS.UnityEngine.Screen.height)
local function GetScreenHeight(self)
    return screenHeight
end

local function IsSpeedUpIcon(icon)
	return icon == "Speedup_FederalCop" or
	icon == "Speedup_Consigliere" or
	icon == "Speedup_secretary" or
	icon == "Speedup_kongzhitai"
end

local function GetPosOfTowLine(pointA, pointB, pointM, pointN)
    local x1, y1 = pointA.x,pointA.y -- AB线段 首坐标
    local x2, y2 = pointB.x, pointB.y -- AB线段 尾坐标
    local x3, y3 = pointM.x, pointM.y -- MN线段 首坐标
    local x4, y4 = pointN.x, pointN.y -- MN线段 尾坐标
    local v2 ={}
    v2.x = -1
    v2.y = -1
    --判断 (x1, y1)~(x2, y2) 和 (x3, y3)~(x4, y4) 是否平行
    if ((y4 - y3) * (x2 - x1) == (y2 - y1) * (x4 - x3)) then
        --若平行，则判断 (x3, y3) 是否在「直线」(x1, y1)~(x2, y2) 上
        if ((y2 - y1) * (x3 - x1) == (y3 - y1) * (x2 - x1)) then
            --判断 (x3, y3) 是否在「线段」(x1, y1)~(x2, y2) 上
            if (UIUtil.IsInSide(x1,y1,x2,y2,x3,y3)) then
                v2 = UIUtil.UpdatePoint(v2,x3,y3)
            end
            --判断 (x4, y4) 是否在「线段」(x1, y1)~(x2, y2) 上
            if (UIUtil.IsInSide(x1,y1,x2,y2,x4,y4)) then
                v2 =UIUtil.UpdatePoint(v2,x4,y4)
            end
            --判断 (x1, y1) 是否在「线段」(x3, y3)~(x4, y4) 上
            if (UIUtil.IsInSide(x3,y3,x4,y4,x1,y1)) then
                v2 =UIUtil.UpdatePoint(v2,x1,y1)
            end
            --判断 (x2, y2) 是否在「线段」(x3, y3)~(x4, y4) 上
            if (UIUtil.IsInSide(x3,y3,x4,y4,x2,y2)) then
                v2 =UIUtil.UpdatePoint(v2,x2,y2)
            end
        end
        --在平行时，其余的所有情况都不会有交点
    else
        --联立方程得到 t1 和 t2 的值
        local t1 = (x3 * (y4 - y3) + y1 * (x4 - x3) - y3 * (x4 - x3) - x1 * (y4 - y3)) / ((x2 - x1) * (y4 - y3) - (x4 - x3) * (y2 - y1));
        local t2 = (x1 * (y2 - y1) + y3 * (x2 - x1) - y1 * (x2 - x1) - x3 * (y2 - y1)) / ((x4 - x3) * (y2 - y1) - (x2 - x1) * (y4 - y3));
        --判断 t1 和 t2 是否均在 [0, 1] 之间
        if (t1 >= 0 and  t1 <= 1 and t2 >= 0 and t2 <= 1) then
            v2.x = math.floor(x1 + t1 * (x2 - x1))
            v2.y = math.floor(y1 + t1 * (y2 - y1))
        end
    end

    if v2.x>=0 and v2.y>=0 then
        return TileCoordWorld.TilePosToIndex(v2,ForceChangeScene.World)
    end
    return nil
end

--判断 (xk, yk) 是否在「线段」(x1, y1)~(x2, y2) 上
--这里的前提是 (xk, yk) 一定在「直线」(x1, y1)~(x2, y2) 上
local function IsInSide(tx1,ty1,tx2,ty2,txk,tyk)
    --若与 x 轴平行，只需要判断 x 的部分
    --若与 y 轴平行，只需要判断 y 的部分
    --若为普通线段，则都要判断
    return (tx1 == tx2 or (math.min(tx1, tx2) <= txk and txk <= math.max(tx1, tx2))) and (ty1 == ty2 or (math.min(ty1, ty2) <= tyk and tyk <= math.max(ty1, ty2)));
end

local function UpdatePoint(tv2,txk,tyk)
    local v2 = {}
    v2.x = tv2.x
    v2.y = tv2.y
    if (v2.x<0 and v2.y<0) or txk<v2.x or (txk<v2.x and tyk<v2.y) then
        v2.x = txk
        v2.y = tyk
    end
    return v2
end

-- 如果该玩家已移民，则名字置灰
local function GetChampionBattleMigrateName(name, migrate)
	if migrate == 1 then
		return "<color=#4C4C4C>" .. Localization:GetString("250398", name) .. "</color>"
	else
		return name
	end
end



function UIUtil.GetMasteryExpByItemId(itemId)
    itemId = tostring(itemId)
    local oneExp = 0
    if itemId == "251112" then
        oneExp = 1000
    elseif itemId == "251114" then
        oneExp = 100
    elseif itemId == "251115" then
        oneExp = 10000
    elseif itemId == "251116" then
        oneExp = 100000
    elseif itemId == "23001" then
        oneExp = 10000
    elseif itemId == "23002" then
        oneExp = 60000
    elseif itemId == "23003" then
        oneExp = 1000000
    end
    return oneExp
end

function UIUtil.GetMasteryExpItemMaxCount(itemId)
    itemId = tostring(itemId)
    local oneExp = UIUtil.GetMasteryExpByItemId(itemId)
    if oneExp == 0 then
        return IntMaxValue
    end
    local restExp = DataCenter.MasteryManager:GetRestExpToMaxLevel()
    if restExp <= 0 then
        return 0
    end
    return restExp // oneExp + 1
end

--保留小数
local function KeepDecimal(num,n)
    if type(num) ~= "number" then
        return num
    end
    n = n or 2
    if num < 0 then
        return -(math.abs(num) - math.abs(num) % 0.1 ^ n)
    else
        return num - num % 0.1 ^ n
    end
end

local function GetSpeedUpIcon(type)
    if LuaEntry.DataConfig:CheckSwitch("ABtest_aps_new_heroes") then
        if type == SpeedUpType.Build then
            return "Speedup_secretary"
        elseif type == SpeedUpType.Science then
            return HeroUtils.GetHeroIconPath(HeroSkillToHeroId.ScienceFreeTime,false)--"Speedup_Consigliere"
        end
    else
        if type == SpeedUpType.Build then
            return HeroUtils.GetHeroIconPath(HeroSkillToHeroId.BuildFreeTime,false)--"Speedup_Consigliere"
        elseif type == SpeedUpType.Science then
            return  HeroUtils.GetHeroIconPath(HeroSkillToHeroId.ScienceFreeTime,false)--"Speedup_FederalCop"
        end
    end
    return ""
end

--检测显示重伤特效
local function CheckShowDeadlyEffect(isForceShow,state,isOnce)
    do return end
    
    local isShow = true
    --开关表中如果关闭直接就关闭
    local isOpen = LuaEntry.DataConfig:CheckSwitch("deadly_effect")
    if not isOpen then
        return false
    end
    if not isForceShow then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIDeadly)
        if window == nil then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIDeadly)
        else
            if window ~= nil and window.View ~= nil then
                window.View:PlayInDeadly(isOnce)
            end
        end
    end

    --如果强制播放效果
    if isForceShow then
        if state == 1 then
            local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIDeadly)
            if window == nil then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIDeadly)
            else
                if window ~= nil and window.View ~= nil then
                    window.View:ForceShowLoopHeartbeat()
                end
            end
        else
            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIDeadly)
        end
    end
    return isShow
end

local function OpenConsumeItemView(consumeType)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIConsumeItem, { anim = true}, consumeType)
end

--获取目标点距离中心点的位置关系
local function GetDirectionByXY(targetPointX, targetPointY, centerPointX, centerPointY)
    local isRight = targetPointX >= centerPointX
    local isTop = targetPointY >= centerPointY
    if isRight then
        if isTop then
            return CommonDirection.RightTop
        end
        return CommonDirection.RightDown
    else
        if isTop then
            return CommonDirection.LeftTop
        end
    end
    return CommonDirection.LeftDown
end

local function GetSpeedUpHeroName(type)
    -- if LuaEntry.DataConfig:CheckSwitch("ABtest_aps_new_heroes") then
        if type == SpeedUpType.Build then
            return HeroUtils.GetHeroNameByConfigId(HeroSkillToHeroId.BuildFreeTime)
        elseif type == SpeedUpType.Science then
            return HeroUtils.GetHeroNameByConfigId(HeroSkillToHeroId.ScienceFreeTime)
        end
    -- else
    --     if type == SpeedUpType.Build then
    --         return HeroUtils.GetHeroNameByConfigId(11001)
    --     elseif type == SpeedUpType.Science then
    --         return HeroUtils.GetHeroNameByConfigId(22001)
    --     end
    -- end
    return ""
end

function UIUtil.ShowServerError(errorCode)
    if errorCode == "550018" then
        local msg = Localization:GetString(errorCode)
        UIUtil.ShowMessage(msg, 1)
    else
        UIUtil.ShowTipsId(errorCode)
    end
end

--点击女二礼包气泡
local function OnClickGiftBubble(giftId)  --giftId可以通过 mistrees_base表里的recharge_id里获得
    --第一次点击播放视频后打开一个界面，后续点击直接打开界面
    local giftId = giftId
    if giftId == nil then return end
    local firstOpenGiftBubble = Setting:GetPrivateBool("firstOpenGiftBubble", true)
    if firstOpenGiftBubble then
        Setting:SetPrivateBool("firstOpenGiftBubble", false)
        local callback = function()
            --local giftId = LuaEntry.DataConfig:TryGetStr("girl_giftBubbl", "k4")
            --local giftId = LuaEntry.DataConfig:TryGetStr("first_pay", "k2")
            ---@type GiftPackInfoDefault
            local packInfo = GiftPackageData.get(giftId)
            if packInfo then
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIRobotPack, OpenWinAnimTrue, packInfo)
            else
                Logger.LogError("获取不到礼包数据============   giftId = "..giftId)
            end

        end
        UIUtil.PlayGiftVideo(callback)
    else
        --local giftId = LuaEntry.DataConfig:TryGetStr("girl_giftBubbl", "k4")
        ---@type GiftPackInfoDefault
        local packInfo = GiftPackageData.get(giftId)
        if packInfo then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIRobotPack, OpenWinAnimTrue, packInfo)
        else
            Logger.LogError("获取不到礼包数据============   giftId = "..giftId)
        end
    end
end

--播放女儿礼包视频
local function PlayGiftVideo(callback)
    local param = {}
    param["video"] = "story12_bl.mp4"
    param["callback"] = callback
    param['skipShowTime'] = 0
    UIManager:GetInstance():OpenWindow(UIWindowNames.UI_VideoPlayer, OpenWinAnimFalse, param)
end

local function CheckShowBrokenTips(targetLv)
    local tip_unlocked = LuaEntry.DataConfig:TryGetNum("shield_base", "k3")
    if tip_unlocked and tip_unlocked == 0 then
        --k3=0 不出弹窗， k3=1 出弹窗
        return false
    end
    local checkObj = LuaEntry.DataConfig:GetObj("shield_base_2")
    if checkObj~=nil then
        local checkLevel = tonumber(checkObj)
        if targetLv == checkLevel then
            return true
        end
    end
    return false
end

--建筑升级
local function BuildUpgrade(buildUuid)
    ---@type BuildingDate
    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(buildUuid)
    local nextLevel = buildData.level + 1
    local state = buildData.state
    local isUpgrading = buildData:IsUpgrading()--是否在升级中
    if isUpgrading then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed, ItemSpdMenu.ItemSpdMenu_City, buildUuid)
    elseif state == BuildingStateType.Normal then
        local needPathTime = 0
        local buildId = buildData.itemId
        ---@type BuildingDesTemplate
        local buildTemplate =DataCenter.BuildTemplateManager:GetBuildingDesTemplate(buildId)
        if buildTemplate.scan == BuildScanAnim.Play then
            needPathTime = Mathf.Ceil(DataCenter.BuildManager:GetPathTimeFromDroneToBuildTarget(buildData.pointId,buildTemplate.tiles)*1000)
        end
        local param = {}
        param.uuid = tostring(buildUuid)
        param.gold = BuildUpgradeUseGoldType.No
        param.upLevel = nextLevel
        param.clientParam = ""
        param.truckId = 0
        param.pathTime = needPathTime
        param.robotUuid = 0
        local buildCurLevelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildId, buildData.level)
        local useTime = buildCurLevelTemplate:GetBuildTime() * 1000 + needPathTime
        if DataCenter.BuildQueueManager:IsCanUpgrade(buildId, buildData.level, useTime) then            
            if useTime > 0 then
                if useTime > 0 then
                    local robot = DataCenter.BuildQueueManager:GetFreeQueue(buildTemplate:IsSeasonBuild(), useTime)
                    if robot~=nil then
                        param.robotUuid = robot.uuid
                    end
                end
            end
            if buildId == BuildingTypes.FUN_BUILD_MAIN and UIUtil.CheckShowBrokenTips(nextLevel) then
                UIUtil.ShowMessage(Localization:GetString("110165",nextLevel), 2, GameDialogDefine.CONFIRM, GameDialogDefine.CANCEL,function()
                    SFSNetwork.SendMessage(MsgDefines.FreeBuildingUpNew,param)
                end, function()
                end)
            else
                SFSNetwork.SendMessage(MsgDefines.FreeBuildingUpNew,param)
            end
        else
            local buildQueueParam = {}
            buildQueueParam.enterType = UIBuildQueueEnterType.Upgrade
            buildQueueParam.uuid = buildUuid
            buildQueueParam.messageParam = param
            buildQueueParam.buildId = buildData.itemId
            DataCenter.BuildQueueManager:SetWillUpgradeParam(buildQueueParam)
            UIUtil.ShowTipsId(130500)
        end
    end
end


local function CheckUIWorldTileClose()
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UIWorldTileUI)
    if window~=nil and window.Ctrl~=nil then
        window.Ctrl:CloseSelf(false)
    end

    --日志
    if window == nil then
        Logger.Log("UITile不存在")
    elseif window.Ctrl == nil then
        Logger.Log("找到UITile,但winodw.Ctrl没启用")
    else
        Logger.Log("成功关闭UITile一次")
    end
end

local function CheckUICanOpen(UIName) --只用于在Item表里设置了打开UI条件的情况
    local questIdCfg = LuaEntry.DataConfig:TryGetNum(UIName, "k1")
    if questIdCfg ~= nil and questIdCfg ~= 0 then
        local isQuestSuccess = DataCenter.ChapterTaskManager:CheckIsSuccess(questIdCfg)
        if not isQuestSuccess then
            return false
        end
    end
    local buildIdCfg = LuaEntry.DataConfig:TryGetNum(UIName, "k2")
    if buildIdCfg ~= nil and buildIdCfg ~= 0 then
        local buildId = buildIdCfg // 100 * 100
        local level = buildIdCfg % buildId
        local isUnlock = DataCenter.BuildManager:IsExistBuildByTypeLv(buildId,level)
        if not isUnlock then
            return false
        end
    end
    return true
end

function UIUtil.PoliceInsigniaFlyDown(num, icon, srcPos, destPos, moveTime, doMoveTime, timeDelta)
    DataCenter.FlyController.PoliceInsigniaFlyDown(num, icon, srcPos, destPos, moveTime, doMoveTime, timeDelta)
end

function UIUtil.PoliceInsigniaFlyUp(obj, destPos, moveTime, doMoveTime, index, callback)
    DataCenter.FlyController.PoliceInsigniaFlyUp(obj, destPos, moveTime, doMoveTime, index, callback)
end

function UIUtil.PoliceInsigniaWorldFlyDown(icon, srcPos, destPos, moveTime, doMoveTime, index, startCallBack, finishCallBack)
    DataCenter.FlyController.PoliceInsigniaWorldFlyDown(icon, srcPos, destPos, moveTime, doMoveTime, index, startCallBack, finishCallBack)
end

function UIUtil.RollNum(hostText, srcValue, dstValue, formatFunc)
    if hostText == nil or IsNull(hostText.gameObject) then
        return
    end

    formatFunc = formatFunc or string.GetFormattedGoldNum
    
    local function Getter()
        return srcValue
    end

    local function Setter(value)
        if IsNull(hostText.gameObject) then
            return
        end
        
        local v = math.floor(value + 0.5)
        hostText:SetText(formatFunc(v))
    end

    local function Complete()
        if IsNull(hostText.gameObject) then
            return
        end

        hostText:SetText(formatFunc(dstValue))
        hostText.transform:Set_localScale(1, 1, 1)
    end

    hostText.transform:Set_localScale(1, 1, 1)
    hostText.transform:DOScale(Vector3.New(1.1, 1.1, 1), 0.15):OnComplete(function()
        local tween = DOTween.To(Getter, Setter, dstValue, 0.7):OnComplete(Complete)
    end)
end

--计算抛物线路径的中点
local function CalculateArc(StarPos,targetPos,height)
    --计算弧线中点，可以根据需要进行调整
    local middlePoint = (StarPos + targetPos) / 2;
    middlePoint = middlePoint + Vector3.New(0,1,0) * height;
    return middlePoint
end
local function IntersectsSegment(rect,p1,p2)
    local num1 = math.min(p1.x, p2.x)
    local num2 = math.max(p1.x, p2.x)
    if num2 > rect.xMax then
        num2 = rect.xMax
    end
    if num1 > rect.xMin then
        num1 = rect.xMin
    end
    if num1 > num2 then
        return false
    end
    local num3 = math.min(p1.y, p2.y)
    local num4 = math.max(p1.y, p2.y)
    local f = p2.x - p1.x
    if math.abs(f)> 1.40129846432482E-45 then
        local num5 = (p2.y - p1.y) / f
        local num6 = p1.y - num5 * p1.x
        num3 = num5 * num1 + num6
        num4 = num5 * num2 + num6
    end
    if num3 > num4 then
        local num5 = num4
        num4 = num3
        num3 = num5
    end
    if num4>rect.yMax then
        num4 = rect.yMax
    end
    if num3>rect.yMin then
        num3 = rect.yMin
    end
    return num3<=num4
end

local function GetEffectNumByType(val, type)
    local intType = tonumber(type)
    if intType == EffectLocalTypeInEffectDesc.Num then
        local a, b = math.modf(val)
        if b == 0 then
            return string.GetFormattedSeperatorNum(a)
        end
        return string.GetFormattedSeperatorNum(val)
    elseif intType == EffectLocalTypeInEffectDesc.Percent then
        local a, b = math.modf(val)
        if b == 0 then
            return string.GetFormattedSeperatorNum(a) .. "%"
        end
        return string.GetFormattedSeperatorNum(val) .. "%"
    elseif intType == EffectLocalTypeInEffectDesc.Thousandth then
        return string.GetFormattedThousandthStr(val / 1000)
    elseif intType == EffectLocalTypeInEffectDesc.NegativePercent then
        local a, b = math.modf(val)
        if b == 0 then
            return "-" .. string.GetFormattedSeperatorNum(a) .. "%"
        end
        return "-" .. string.GetFormattedSeperatorNum(val) .. "%"
    end
    return ""
end

local function GetEffectNumWithType(val, type)
    local intType = tonumber(type)
    if intType == EffectLocalTypeInEffectDesc.Num then
        return "+" .. string.GetFormattedSeperatorNum(val)
    elseif intType == EffectLocalTypeInEffectDesc.Percent then
        local a, b = math.modf(val)
        if b == 0 then
            return "+" .. string.GetFormattedSeperatorNum(a) .. "%"
        end
        return "+" .. string.GetFormattedSeperatorNum(val) .. "%"
    elseif intType == EffectLocalTypeInEffectDesc.Thousandth then
        return "+" .. string.GetFormattedThousandthStr(val / 1000)
    elseif intType == EffectLocalTypeInEffectDesc.NegativePercent then
        local a, b = math.modf(val)
        if b == 0 then
            return "-" .. string.GetFormattedSeperatorNum(a) .. "%"
        end
        return "-" .. string.GetFormattedSeperatorNum(val) .. "%"
    end
    return ""
end

local function OnDispatchTaskClick(pointIndex,openFuc,isbubble)
    local actList = DataCenter.ActivityListDataManager:GetActivityDataByType(EnumActivity.DispatchTask.Type)
    local actInfo = #actList > 0 and actList[1] or nil
    if actInfo == nil then
        UIUtil.ShowTipsId(130231)
        return
    end
    -- 等级不够
    if actInfo.needMainCityLevel and actInfo.needMainCityLevel > DataCenter.BuildManager.MainLv then
        UIUtil.ShowTips(Localization:GetString("302235",actInfo.needMainCityLevel))
        return
    end
    -- 区分 自己领取 ？ 盟友协助 ？ 还是别人偷
    local info = DataCenter.WorldPointManager:GetPointInfo(pointIndex)
    if info~=nil and info.extraInfo~=nil then
        if info.pointType == WorldPointType.HERO_DISPATCH then
            local dispatchMission = PBController.ParsePbFromBytes(info.extraInfo, "protobuf.DispatchMission")
            if dispatchMission~=nil then
                local mgr = DataCenter.ActDispatchTaskDataManager
                local player = LuaEntry.Player
                local selfUid = player.uid
                local now = UITimeManager:GetInstance():GetServerTime()
                local canAward = dispatchMission.finishTime > 0 and dispatchMission.finishTime <= now
                if canAward then
                    if selfUid == dispatchMission.ownerUid then
                        if not DataCenter.ActDispatchTaskDataManager:IsLandUnLock() then
                            UIUtil.ShowTipsId(896292)
                            return
                        end
                        --自己操作
                        --info.rewarded = 1   -- 防止多次点击?
                        SFSNetwork.SendMessage(MsgDefines.DispatchReward, dispatchMission.uuid)
                    elseif dispatchMission.allianceId~=nil and dispatchMission.allianceId~=""  and dispatchMission.allianceId == LuaEntry.Player.allianceId then
                        --盟友
                        local todayAssistNum = mgr:GetTodayAssistNum()
                        local assistMax = toInt(mgr:GetDispatchSetting("aid_count"))
                        if todayAssistNum < assistMax then
                            SFSNetwork.SendMessage(MsgDefines.DispatchAssist, dispatchMission.uuid)
                        else
                            UIUtil.ShowTipsId(894237) -- 456225=今日协助次数已达上限
                        end
                    else
                        local steal_max_count = toInt(GetTableData(TableName.LwDispatchTask, dispatchMission.missionId,"steal_maxtimes"))
                        local curCount = table.count(dispatchMission.stealUids)
                        if curCount<steal_max_count then
                            local hasSteal = false
                            if curCount>0 then
                                for i = 1,curCount do
                                    if dispatchMission.stealUids[i] == LuaEntry.Player.uid then
                                        hasSteal = true
                                    end
                                end
                            end
                            if hasSteal == true then
                                if isbubble then
                                    local share_param = {}
                                    -- share_param.post = PostType.Text_PointShare
                                    share_param.sid = LuaEntry.Player:GetCurServerId()
                                    share_param.pos = pointIndex
                                    share_param.oname = GetTableData(TableName.LwDispatchTask, dispatchMission.missionId,"name")
                                    -- share_param.olv = toInt(GetTableData(TableName.LwDispatchTask, dispatchMission.missionId,"level"))
                                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIPositionShare, OpenWinAnimTrue, share_param)
                                else
                                    UIUtil.ShowTipsId(894240) -- 456235=这个据点已经偷过了，给他留点奖励吧！
                                end
                            else
                                local todayStealNum = DataCenter.ActDispatchTaskDataManager:GetTodayStealNum()
                                local maxStealNum = DataCenter.ActDispatchTaskDataManager:GetDispatchSetting("steal_count")
                                if todayStealNum<maxStealNum then
                                    SFSNetwork.SendMessage(MsgDefines.DispatchSteal,dispatchMission.uuid)
                                else
                                    UIUtil.ShowTipsId(894237) -- 456226=今日偷取次数已达上限
                                end
                            end
                        else
                            UIUtil.ShowTipsId(894238) -- 456227=这个探索点已经被偷光了！
                        end
                    end
                else
                    if openFuc~=nil then
                        local isSelf = selfUid == dispatchMission.ownerUid
                        local finishTime = dispatchMission.finishTime
                        local uuid = dispatchMission.uuid
                        openFuc(isSelf,finishTime,uuid)
                    end
                end
            end
        end
    end
end

--zlh: 将rectTransform全向拉伸至于父节点同等大小
function UIUtil.StretchFullRectTransform(rectTransform)
    if rectTransform == nil then
        return
    end

    rectTransform:Set_anchorMin(0, 0)
    rectTransform:Set_anchorMax(1, 1)
    rectTransform:Set_offsetMin(0, 0)
    rectTransform:Set_offsetMax(0, 0)
    rectTransform:Set_pivot(0.5, 0.5)
    rectTransform:Set_localScale(1, 1, 1)
    --rectTransform:Set_localPosition(0, 0, 0)
    rectTransform:SetLocalPositionZ(0)
    rectTransform:SetAsLastSibling()
end

function UIUtil.FixTextMeshProMask(textMeshPro)
    if textMeshPro == nil or not Is(textMeshPro, CS.NewTMPText) then
        return
    end
    
    local subGraphics = textMeshPro.transform:GetComponentsInChildren(typeof(CS.UnityEngine.UI.MaskableGraphic), true)
    if subGraphics ~= nil and subGraphics.Length > 0 then
        for i = 0, subGraphics.Length -1 do
            local obj = subGraphics[i]
            if obj.transform == textMeshPro.transform then
                goto continue
            end

            if Is(obj, CS.TMPro.TMP_SubMeshUI) then
                obj.maskable = false
            else
                obj.maskable = true
            end

            ::continue::
        end
    end
end


local GirlSmallIconPath = 'Assets/Main/Sprites/GirlIconsSmall/%s.png'
function UIUtil.GetGirlIconPath(girlId)
    local smallIconPath = GetTableData(TableName.MistressBase, girlId, 'smallIcon')
    if string.IsNullOrEmpty(smallIconPath) then
        smallIconPath = 'girl_icon_' .. girlId
    end
    
    local iconPath = string.format(GirlSmallIconPath, smallIconPath)
    return iconPath
end

function UIUtil.DoFlySimpleFunc(path, srcPos, destPos, moveTime, parent, callback)
    return DataCenter.FlyController.DoFlySimpleFunc(path, srcPos, destPos, moveTime, parent, callback)
end

--播放过场动画，三个阶段：先云雾聚拢，然后等待若干秒，再云雾散开
---@param midAction function @中场回调，云雾聚拢完成时调用
---@param holdFunc function @等待函数，等待阶段每秒调用一次，当且仅当返回true时播放云雾散开；holdFunc=nil，则无等待阶段
---@param toServerId number @去其他服的时候传这个，用来提示跨服
local function PlayCutSceneAnim(midAction,holdFunc,toServerId)
    if midAction then
        midAction()
    end
end
--格式化拼接 联盟简称+名字，形如:[武当派]张三丰
--特别的，获取自己的联盟简称+名字直接调用：LuaEntry.Player:GetFullName()
local function FormatAllianceAndName(abbr,name)
    if string.IsNullOrEmpty(abbr) then
        return name or ''
    else
        return string.format("[%s]%s", abbr, name or '')
    end
end

--格式化拼接 原服+联盟简称+名字，形如:#100 [武当派]张三丰
local function FormatServerAllianceName(serverId,abbr,name)
    if serverId and serverId>0 then
        return string.format("#%s %s",serverId,UIUtil.FormatAllianceAndName(abbr,name))
    else
        return UIUtil.FormatAllianceAndName(abbr,name)
    end
end

function UIUtil.GoToHeroDispatch()
    local actList = DataCenter.ActivityListDataManager:GetActivityDataByType(EnumActivity.DispatchTask.Type)
    local actInfo = #actList > 0 and actList[1] or nil
    if actInfo == nil then        
        return
    end
    local isEnd = false
    local curTime = UITimeManager:GetInstance():GetServerTime()
    if actInfo.endTime < curTime then
        isEnd = true
    end
    GoToUtil.GoActWindow(actInfo.id)
end

UIUtil.popupPackageConfig = {}
local function GetPopupPackageConfig(packName)
    if UIUtil.popupPackageConfig[packName] == nil then
        local defaultConfig = nil
        LocalController:instance():visitTable(TableName.PopupPackageUI, function(_, lineData)
            local config = DeepCopy(lineData)
            UIUtil.popupPackageConfig[lineData.name] = config
            if config.name == "Default" then
                defaultConfig = config
            end
        end)
        if UIUtil.popupPackageConfig[packName] == nil then
            UIUtil.popupPackageConfig[packName] = defaultConfig
        end
    end
    return UIUtil.popupPackageConfig[packName]
end

function UIUtil.TryRecoverUI(levelParam)
    if levelParam.pveEntrance == PveEntrance.ArenaBattle and levelParam.levelId == ArenaBattleLevelId then
        --UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide},EnumActivity.Arena.ActId)
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaPanel,{ anim = true, hideTop = true, UIMainAnim = UIMainAnimType.AllHide })
        DataCenter.ArenaManager:TryOpenCacheUI()
    elseif levelParam.pveEntrance == PveEntrance.BattlePlayBack then
        if levelParam.jumpType == PlayBackEndJumpType.Arena then
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide},EnumActivity.Arena.ActId)
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaPanel,{ anim = true, hideTop = true, UIMainAnim = UIMainAnimType.AllHide })
            --UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaHistory)
        end
    elseif levelParam.pveEntrance == PveEntrance.Story then
        --                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIStoryMain)
    elseif levelParam.pveEntrance == PveEntrance.MineCave then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide }, EnumActivity.MineCave.ActId)
    elseif levelParam.pveEntrance == PveEntrance.TruckRob then
        local _truckData = levelParam.truckData or {}
        local _marchUuid = _truckData["marchUid"] or ""
        local _serverId = _truckData["serverId"] or LuaEntry.Player:GetCurServerId()
        RailwayUtil.JumpToTrainByMarchUuid(_marchUuid,_serverId)
    elseif levelParam.pveEntrance == PveEntrance.LandingOperation then
        local battleResult = PveActorMgr:GetInstance():GetBattleResult()
        local camp = DataCenter.LandingOperationsDataManager:GetSelectCamp()
        local actInfo = DataCenter.LandingOperationsDataManager:GetInfo()
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide}, tonumber(actInfo.activityId), nil, {targetCamp = camp})
        
        local chapter,level = actInfo:GetProcess(camp)
        --if battleResult == Const.Result.Fail or battleResult == Const.Result.NoWar then
        --    UIManager:GetInstance():OpenWindow(UIWindowNames.UILoMap)
        --else
        --    if level ~= 1 then
        --        UIManager:GetInstance():OpenWindow(UIWindowNames.UILoMap)
        --    else
        --        UIUtil.ShowTipsId(799167)
        --        DataCenter.LandingOperationsDataManager:TryShowUnlockTips(camp)
        --    end
        --end
    elseif levelParam.pveEntrance == PveEntrance.DetectEventPve 
        or levelParam.pveEntrance == DetectEventBarrelPve
            --or levelParam.pveEntrance == PveEntrance.DetectEventTower
    then
        local isOpenSevenDay = false
        local windowName = DataCenter.RadarCenterDataManager:GetNeedOpenWindowName()
        if windowName and windowName == UIWindowNames.UISevenDayNew and levelParam.uid then
            local data = DataCenter.RadarCenterDataManager:GetDetectEventInfo(levelParam.uid)
            if data then
                local template = DataCenter.DetectEventTemplateManager:GetDetectEventTemplate(data.eventId)
                if template ~= nil and template.type == DetectEventType.DetectEvent_SevenDay then
                    isOpenSevenDay = true
                    UIManager:GetInstance():OpenWindow(windowName, OpenWinAnimTrue, 2)
                end
            end
        end
        if isOpenSevenDay == false then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIDetectEvent, OpenWinAnimTrue)
        end
    elseif levelParam.pveEntrance == PveEntrance.TowerClimb then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIJeepAdventureMain, OpenWinAnimTrue)
    end
end

---传入一个按钮一个字体一个颜色，可以将对应的字体和按钮切换成想要的颜色，并且字体的材质也会适应颜色 ----
function UIUtil.SetBtnAndTmpByColor(color,btn,tmp)
    if color and btn and tmp then
        btn:LoadSprite(string.format(LoadPath.CommonNewPath, BtnAndTmpColorData[color][1]))
        tmp:SetFontMaterialByType(color)
        tmp:SetColor(BtnAndTmpColorData[color][2])
    end
end

function UIUtil.CloseFromArenaPve(levelType, levelParam, result, callback)

    local param = PveActorMgr:GetInstance():GetLevelParam()
    local battlePlayBack = false
    if param~=nil and param.pveEntrance == PveEntrance.BattlePlayBack then
        battlePlayBack = true
    end
    
    if (levelType == PveLevelType.FightLevel or
            levelType == PveLevelType.RadarExpLevel or
            levelType == PveLevelType.AdventureSetting or
            levelType == PveLevelType.StoryLevel or
            levelType == PveLevelType.GuideLevel
    ) and not battlePlayBack then
        if levelParam ~= nil then
            if DataCenter.BattleLevel:NeedBackToWorld() then
                DataCenter.BattleLevel:Exit(function()
                    UIUtil.TryRecoverUI(levelParam)
                end, result)
            else
                UIUtil.TryRecoverUI(levelParam)

                TimerManager:GetInstance():DelayInvoke(function()
                    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIPVEResult)
                    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIParkourBattleLose)
                    DataCenter.BattleLevel:Exit(nil, result)
                end, 0.5)
            end
        end
    elseif levelType == PveLevelType.BattlePlayBackLevel or battlePlayBack then
        local param = PveActorMgr:GetInstance():GetLevelParam()
        local mailId = nil
        local jumpType = nil
        if param~=nil and param.pveEntrance == PveEntrance.BattlePlayBack then
            mailId = param.mailId
            jumpType = param.jumpType
        end

        local function recoverUI()
            if jumpType == PlayBackEndJumpType.Mail then
                if mailId~=nil then
                    local param = {}
                    param["selectTab"] = MailInternalGroup.MAIL_IN_report
                    param["selectUid"] = mailId
                    GoToUtil.GotoOpenView(UIWindowNames.UIMailNew,OpenWinAnimTrue, param)
                end
            elseif jumpType == PlayBackEndJumpType.Arena then
                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide}, tonumber(EnumActivity.Arena.ActId))
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaPanel,{ anim = true, hideTop = true, UIMainAnim = UIMainAnimType.AllHide })
                if DataCenter.CrossArenaManager:GetCanJoinAct() then
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaHistory,true)
                else
                    UIManager:GetInstance():OpenWindow(UIWindowNames.UIArenaHistory,false)
                end
            elseif jumpType == PlayBackEndJumpType.MineCave then
                DataCenter.MineCaveManager:SetEnemyPlayerPower()
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIActivityCenterTable, { anim = true, UIMainAnim = UIMainAnimType.AllHide}, tonumber(EnumActivity.MineCave.ActId))
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIMineCaveLog)
            end
        end

        if DataCenter.BattleLevel:NeedBackToWorld() then
            PveActorMgr:GetInstance():Leave()
            DataCenter.BattleLevel:Exit(recoverUI, result)
        else
            recoverUI()
            PveActorMgr:GetInstance():Leave()
            TimerManager:GetInstance():DelayInvoke(function()
                DataCenter.BattleLevel:Exit(nil, result)
            end, 0.5)
        end
    elseif levelType == PveLevelType.NormalLevel or
            levelType == PveLevelType.HeroExpLevel or
            levelType == PveLevelType.NormalExpLevel or
            levelType == PveLevelType.BattleExpLevel or
            levelType == PveLevelType.SkillLevel then
        PveActorMgr:GetInstance():Leave()
    elseif levelType == PveLevelType.ArmyLevel then
        PveActorMgr:GetInstance():Leave()
        DataCenter.BattleLevel:UpdateArmyRecordHpBar(true)
    elseif levelType == PveLevelType.AdventureLevel then
        --if result == Const.Result.Fail then
        --    DataCenter.BattleLevel:Exit()
        --else
        --    PveActorMgr:GetInstance():Leave()
        --    DataCenter.AdventureManager:CheckShowReward()
        --end
    end
end

function UIUtil.GetPopupPackageVIP()
    local allPacks = GiftPackageData.GetAllAvailablePackageByRechargeId(100014, false)
    local _,pack = next(allPacks)
    return pack
end

function UIUtil.ClickGodzillaGift(pointindex)
     local info = DataCenter.WorldPointManager:GetPointInfo(pointindex)
     if info~=nil and info.treasureInfo ~= nil then
        local hasget = false
        local extrainfo =info.treasureInfo
        local uids = string.string2array_s(extrainfo.rewarduids,";")
        local curcount = #uids
        if curcount >0 then
            for i = 1,curcount do
                if uids[i] and uids[i] == LuaEntry.Player.uid then
                    hasget = true
                end
            end
        end
        if not hasget then
            local targetType = MarchTargetType.GodzillaGift
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationSelectListNew,{ anim = true, UIMainAnim = UIMainAnimType.AllHide }, 2, targetType, pointindex, info.uuid) 
        else
            local targetType = MarchTargetType.GodzillaGift
            -- UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationSelectListNew,{ anim = true, UIMainAnim = UIMainAnimType.AllHide }, 2, targetType, info.PointType, info.uuid)
            -- needCloseWorldPointUI = false
            -- needCloseUI[UIWindowNames.UIWorldPoint] = nil
            --DataCenter.TroopActionManager:DoTroopAction(TroopActionType.TROOP_ACTION_TYPE_RADAR_CENTER)
            local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
                local _param = {}
                _param["uuid"] = info.uuid
                _param["pointId"] = info.pointIndex
                _param["ownerUid"] = ""
                _param["type"] = WorldPointUIType.GodzillaGift
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIWorldPoint) then
                local str = info.uuid..";"..info.pointIndex..";"..""..";"..WorldPointUIType.GodzillaGift ..";".."0"..";".."0"
                EventManager:GetInstance():Broadcast(EventId.RefreshUIWorldPointView,_param)
            else
                
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig,_param)
            end
            -- UIUtil.OnClickWorld(self.pointIndex)
            UIUtil.ShowTipsId(897553)
        end
    end
end

---是否能领取联盟宝藏/挖去联盟宝藏
---@public
---@param isShowTips boolean
---@return boolean
function UIUtil.CheckCanGetAllianceTreasure(isShowTips)
    local joinHour = DataCenter.AllianceBaseDataManager:GetJoinTimeForNow()
    if joinHour ~= -1 and LuaEntry.Player.isFirstJoin ~= FirstJoinAllianceType.Yes then
        local targetHour = LuaEntry.DataConfig:TryGetNum("detect_config_dig", "k1")
        if joinHour < targetHour then
            if isShowTips then
                local msg = Localization:GetString( 898228, targetHour)
                UIUtil.ShowTips(msg)
            end
            return false
        end
    end
    
    return true
end

function UIUtil.ClickAllianceTreasure(pointIndex)
    local info = DataCenter.WorldPointManager:GetPointInfo(pointIndex)
    if info~=nil and info.treasureInfo ~= nil then
        if info.treasureInfo.state == 1 then
            local ifSelfOwner = DataCenter.WorldPointManager.CheckIsSelfOwnerDigTreasure(info.pointIndex)
            if not ifSelfOwner then
                local isSelfAlliance = DataCenter.WorldPointManager.CheckIsSelfAllianceDigTreasure(info.pointIndex,true)
                if not isSelfAlliance then
                    return
                end
            end
            local reward_num = toInt(GetTableData("precious_deposits", info.treasureInfo.configId,"reward_num"))
            local hasget = false
            local extrainfo =info.treasureInfo
            local uids = string.string2array_s(extrainfo.rewarduids,";")
            local curcount = #uids
            if curcount >= reward_num then
                UIManager:GetInstance():OpenWindow(UIWindowNames.DigTreasureGift,{hidetop = false},info.treasureInfo.uuid)
                return
            end
            if curcount >0 then
                for i = 1,curcount do
                    if uids[i] and uids[i] == LuaEntry.Player.uid then
                        hasget = true
                    end
                end
            end
            if not hasget then
                --local viewSetting = { anim = true, UIMainAnim = UIMainAnimType.AllHide }
                --local targetType = MarchTargetType.GodzillaGift
                --UIManager:GetInstance():OpenWindow(UIWindowNames.UIFormationSelectListNew,viewSetting, 2, targetType, info.pointIndex, info.uuid)
                SFSNetwork.SendMessage(MsgDefines.GetDigTreasureReward, info.treasureInfo.uuid)
            else
                UIUtil.ShowTipsId(898111)
            end
            return
        end
        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
        local _param = {}
        _param["uuid"] = info.uuid
        _param["pointId"] = info.pointIndex
        _param["ownerUid"] = ""
        _param["type"] = WorldPointUIType.DigTreasure
        _param["buildId"] = 0
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
    end
end

function UIUtil.ClickDroppedTreasure(pointIndex)
    if not UIUtil.CheckSourceServerLimit(true) then
        return
    end
    local info = DataCenter.WorldPointManager:GetPointInfo(pointIndex)
    if info~=nil and info.treasureInfo ~= nil then
        if info.treasureInfo.state == 1 then
            local reward_num = toInt(GetTableData("precious_deposits", info.treasureInfo.configId,"reward_num"))
            local hasget = false
            local extrainfo =info.treasureInfo
            local uids = string.string2array_s(extrainfo.rewarduids,";")
            local curcount = #uids
            if curcount >= reward_num then
                UIManager:GetInstance():OpenWindow(UIWindowNames.DigTreasureGift,{hidetop = false},info.treasureInfo.uuid)
                return
            end
            if curcount >0 then
                for i = 1,curcount do
                    if uids[i] and uids[i] == LuaEntry.Player.uid then
                        hasget = true
                    end
                end
            end
            if not hasget then
                SFSNetwork.SendMessage(MsgDefines.GetDirectTreasureReward, info.treasureInfo.uuid)
            else
                --share
                local name = toInt(GetTableData("precious_deposits", info.treasureInfo.configId,"name"))
                local share_param = {}
                share_param.sid = LuaEntry.Player:GetCurServerId()
                share_param.pos = pointIndex
                share_param.oname = name
                UIManager:GetInstance():OpenWindow(UIWindowNames.UIPositionShare, OpenWinAnimTrue, share_param)
            end
        end
    end
end

function UIUtil.ClickActResourcePoint(pointIndex)
    local info = DataCenter.WorldPointManager:GetPointInfo(pointIndex)
    local actresource = info and info.actresource or nil
    if actresource ~= nil then
        local _panelConfig = {anim = true,playEffect = false,UIMainAnim = UIMainAnimType.LeftRightBottomHide}
        local _param = {}
        _param["pointId"] = info.pointIndex
        _param["type"] = WorldPointUIType.ActResource
        UIManager:GetInstance():OpenWindow(UIWindowNames.UIWorldPoint,_panelConfig, _param)
    end
end

function UIUtil.JumpToActResource(fightServerId,pointIndex,justCheck)
    justCheck = justCheck ~= nil and justCheck or false 
    --跨服掠夺前往对应服务器
    --就在当前服，就不用跨服直接跳转
    if fightServerId == LuaEntry.Player:GetSelfServerId() then
        GoToUtil.CloseAllWindows()
        GoToUtil.GotoWorldPos(SceneUtils.TileIndexToWorld(pointIndex, ForceChangeScene.World), World_InitZoom,LookAtFocusTime,function()
            UIUtil.ClickActResourcePoint(pointIndex)
        end, fightServerId)
        return
    end
    --有部队在外面，提示叫回
    local isMarched = DataCenter.ArmyFormationDataManager:GetInMarchArmyFormationCount() > 0
    if isMarched then
        UIUtil.ShowTipsId(379001)
        return
    end
    GoToUtil.CloseAllWindows()
    if justCheck then
        GoToUtil.GotoWorldPos(SceneUtils.TileIndexToWorld(pointIndex, ForceChangeScene.World), World_InitZoom,LookAtFocusTime,function()
            UIUtil.ClickActResourcePoint(pointIndex)
        end, fightServerId)
        return
    end
    if LuaEntry.Player:IsInAlliance() then
        SFSNetwork.SendMessage(MsgDefines.StopAllianceAutoRally)
    end
    local tip = Localization:GetString(379002, fightServerId)
    UIUtil.ShowTips(tip)
    local ringRadius = math.ceil(3 / 2) + WorldBuildUtil.GetBuildTileSize(BuildingTypes.FUN_BUILD_MAIN)
    local ringForTargetPoints = WorldBuildUtil.GetRing(SceneUtils.IndexToTilePos(pointIndex,ForceChangeScene.World),ringRadius)
    local targetPointIndex = table.randomArrayValue(ringForTargetPoints)
    GoToUtil.GotoWorldPos(SceneUtils.TileIndexToWorld(targetPointIndex, ForceChangeScene.World), World_InitZoom,LookAtFocusTime,function()
        UIUtil.TryMoveCity(PlaceBuildType.MoveCity_PlunderMine, targetPointIndex, true)
    end, fightServerId, nil,true)
end

function UIUtil.IsFingerOnUI()
    if TouchWrapper.TouchCount > 0 then
        local touches = TouchWrapper.Touches
        local touchCount = touches.Count
        for i = 0, touchCount - 1 do
            local t = touches[i]
            if EventSystem.current:IsPointerOverGameObject(t.FingerId) then
                return true
            end
        end
    end
    return false
end

function UIUtil.ShowCommonCountTimeMessageTip(title, param)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UICommonCountTimeMessageTip, { anim = true, UIMainAnim = UIMainAnimType.LeftRightBottomHide })
    local window = UIManager:GetInstance():GetWindow(UIWindowNames.UICommonCountTimeMessageTip)
    if window and window.View then
        window.View:SetData(title, param)
        return window.View
    end
end

function UIUtil.CheckCanMoveCity(showTips)
    showTips = showTips ~= nil and showTips or false
    --行军
    local allList = DataCenter.ArmyFormationDataManager:GetArmyFormationList()
    if allList ~= nil then
        for _,v in pairs(allList) do
            if v ~= nil and v.state == ArmyFormationState.March then
                local march = DataCenter.WorldMarchDataManager:GetOwnerFormationMarch(LuaEntry.Player.uid, v.uuid, LuaEntry.Player.allianceId)
                if march~=nil then
                    if showTips then
                        UIUtil.ShowTipsId(129036)
                    end
                    return false
                end
            end
        end
    end
    --侦察
    local unlockCount = DataCenter.ArmyFormationDataManager:GetMaxInvesFormationCount()
    for i = 1, InvestigateTroopMaxNum do
        if unlockCount < i then
            break
        end
        local tempFormationInfo = DataCenter.ArmyFormationDataManager:GetInvestigateFormationInfoByIndex(i)
        if tempFormationInfo and tempFormationInfo.state == 1 then
            local marchInfo = DataCenter.WorldMarchDataManager:GetOwnerFormationMarch(LuaEntry.Player.uid, tempFormationInfo.uuid, LuaEntry.Player.allianceId)
            if marchInfo ~= nil then
                if showTips then
                    UIUtil.ShowTipsId(129036)
                end
                return false
            end
        end
    end
    return true
end

function UIUtil.GetAllianceWholeName(serverId, abbr, name)
    return string.format("#%s[%s]%s", serverId, abbr, name)
end

--开改装车组件箱子确认弹窗
-- titleText:标题文本
-- tipText:描述文本
-- btnNum:按钮个数
-- text1:左边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- text2:右边按钮名称（当btnNoUseDialog为true时表示内容，为空时表示多语言）
-- action1:点击左边按钮回调函数
-- action2:点击右边按钮回调函数
-- closeAction:点击x和黑色背景回调函数
-- btnNoUseDialog:text1和text2类型 为true表示文本 为空表示多语言
-- leftBtnPicName:左边按钮图片路径
-- rightBtnPicName:右边按钮图片路径
local function ShowUseGarageComponBoxConfirm(todayType, tipText, btnNum, text1, text2, action1, action2, closeAction, titleText, btnNoUseDialog, leftBtnPicName, rightBtnPicName)
    if DataCenter.SecondConfirmManager:GetTodayCanShowSecondConfirm(todayType) then
        UIUtil.ShowSecondMessage(titleText,tipText,btnNum,text1,text2, function()
            action1()
        end, function(needSellConfirm)
            DataCenter.SecondConfirmManager:SetTodayNoShowSecondConfirm(todayType,needSellConfirm)
        end,action2,closeAction,nil,Localization:GetString(GameDialogDefine.TODAY_NO_SHOW), btnNoUseDialog, leftBtnPicName, rightBtnPicName)
    else
        action1()
    end
end

local uiWorldGoHomeBtnBottomOffset = 72
local function CalcConstructMilePointer(hasSafeArea, leftPadding, topPadding, mainWorldPos, targetWorldPos)
    local show, dist, pos, eulerAngleZ = false, 0, VecZero, 0
    local world = CS.SceneManager.World
    if world == nil then
        return show, dist
    end

    local mainTilePos = SceneUtils.WorldToTile(mainWorldPos)
    local mainScreenPos = world:WorldToScreenPoint(mainWorldPos)
    local targetTilePos = SceneUtils.WorldToTile(targetWorldPos)

    if (mainTilePos.x == 0 and mainTilePos.y == 0) or (CrossServerUtil:GetIsCrossServer() and not CommonUtil.IsInDragonActivity()) then
        return false
    end

    local screenX = CS.UnityEngine.Screen.width
    local screenY = CS.UnityEngine.Screen.height
    if mainScreenPos.x > 0 and mainScreenPos.x < screenX and mainScreenPos.y > 0 and mainScreenPos.y < screenY then
        return show, dist, pos.x, pos.y, eulerAngleZ
    end

    show = true
    local scaleFactor = UIManager:GetInstance():GetScaleFactor()
    leftPadding = leftPadding * scaleFactor
    topPadding = topPadding * scaleFactor
    local tempUiWorldGoHomeBtnBottomOffset = uiWorldGoHomeBtnBottomOffset * scaleFactor

    if mainScreenPos.x < leftPadding then
        mainScreenPos.x = leftPadding
    end
    if mainScreenPos.x > (screenX - leftPadding) then
        mainScreenPos.x = screenX - leftPadding
    end

    if mainScreenPos.y < topPadding + tempUiWorldGoHomeBtnBottomOffset then
        mainScreenPos.y = topPadding + tempUiWorldGoHomeBtnBottomOffset
    end
    local yOffset = 0
    if hasSafeArea then
        yOffset = 100
    end
    if mainScreenPos.y > (screenY - topPadding - yOffset) then
        mainScreenPos.y = screenY - topPadding - yOffset
    end
    
    pos = mainScreenPos
    local v = Vector3.Normalize(pos - Vector3.New(screenX / 2, screenY / 2, 0))
    local angle = Vector3.Angle(Vector3.New(0, 1, 0), v)
    eulerAngleZ = angle
    if v.x > 0 then
        eulerAngleZ = -eulerAngleZ
    end


    dist = math.floor(Vector2.Distance(mainTilePos, targetTilePos))
    pos = UIManager:GetInstance():GetUICamera():ScreenToWorldPoint(mainScreenPos)
    return show, dist, pos.x, pos.y, eulerAngleZ
end

local function CalcMilePointer(hasSafeArea, leftPadding, topPadding)
    local world = CS.SceneManager.World
    if world == nil then
        return false, 0
    end
    local mainIndex = LuaEntry.Player:GetMainWorldPos()
    if CommonUtil.IsInDragonActivity() then
        mainIndex = 0
        local crossBuildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.WORM_HOLE_CROSS)
        if crossBuildData~=nil then
            mainIndex = crossBuildData.pointId
        end
    end
    if mainIndex <= 0 then
        return false, 0
    end
    local mainWorldPos = SceneUtils.TileIndexToWorld(mainIndex)
    local targetWorldPos = world.CurTarget
    return UIUtil.CalcConstructMilePointer(hasSafeArea, leftPadding, topPadding, mainWorldPos, targetWorldPos)
end

local function CheckSourceServerLimit(showTips)
    if LuaEntry.Player:IsInSourceServer() then
        --在源服务器才能够针对宝藏进行操作
        return true
    end
    if showTips then
        UIUtil.ShowTipsId(458585)
    end
    return false
end

UIUtil.PlayCutSceneAnim = PlayCutSceneAnim
UIUtil.FormatAllianceAndName = FormatAllianceAndName
UIUtil.FormatServerAllianceName = FormatServerAllianceName
UIUtil.IntersectsSegment = IntersectsSegment
UIUtil.OpenConsumeItemView = OpenConsumeItemView
UIUtil.ShowMessage =ShowMessage
UIUtil.ShowIntro =ShowIntro
UIUtil.ShowIntroId =ShowIntroId
UIUtil.ShowIntroBtn = ShowIntroBtn
UIUtil.ShowIntroWithRewards = ShowIntroWithRewards
UIUtil.ShowUseItemTip =ShowUseItemTip
UIUtil.ShowComplexTip =ShowComplexTip
UIUtil.ShowTips =ShowTips
UIUtil.ShowTipsId =ShowTipsId
UIUtil.ShowTipsIdParams =ShowTipsIdParams
UIUtil.ShowBuyMessage = ShowBuyMessage
UIUtil.ShowUseResItemMessage = ShowUseResItemMessage
UIUtil.GetResourcePos = GetResourcePos
UIUtil.GetResourceBar = GetResourceBar
UIUtil.GetDirectionByXY = GetDirectionByXY
UIUtil.PlayAnimationReturnTime =PlayAnimationReturnTime
UIUtil.ClickBuildAdjustCameraView =ClickBuildAdjustCameraView
UIUtil.IsInView =IsInView
UIUtil.OnClickWorld = OnClickWorld
UIUtil.OnClickWorldTroop = OnClickWorldTroop
UIUtil.ShowSecondMessage = ShowSecondMessage
UIUtil.CloseWorldMarchTileUI =CloseWorldMarchTileUI
UIUtil.ClickCloseWorldUI =ClickCloseWorldUI
UIUtil.ClickWorldCloseWorldUI =ClickWorldCloseWorldUI
UIUtil.ClickUICloseWorldUI =ClickUICloseWorldUI
UIUtil.OnClickBuild =OnClickBuild
UIUtil.OnClickCity =OnClickCity
UIUtil.DragWorldCloseWorldUI =DragWorldCloseWorldUI
UIUtil.ShowUseDiamondConfirm = ShowUseDiamondConfirm
UIUtil.ShowUnlockWindow = ShowUnlockWindow
UIUtil.ShowGuideBtnUnlockWindow = ShowGuideBtnUnlockWindow
UIUtil.ClickFarmAdjustPos = ClickFarmAdjustPos
UIUtil.CheckNeedQuitFocus= CheckNeedQuitFocus
UIUtil.GetUIMainSavePos = GetUIMainSavePos
UIUtil.OnPointDownMarch = OnPointDownMarch
UIUtil.OnPointUpMarch = OnPointUpMarch
UIUtil.OnMarchDragStart = OnMarchDragStart
UIUtil.DoFly = DoFly
UIUtil.DoFlyCustom = DoFlyCustom
UIUtil.DoFlyUnlockNewFunc = DoFlyUnlockNewFunc
UIUtil.DoFlyReward = DoFlyReward
UIUtil.GetSelfMarchCountExceptGolloes = GetSelfMarchCountExceptGolloes
UIUtil.ShowSingleTip = ShowSingleTip
UIUtil.IsPad = IsPad
UIUtil.OpenHeroStationByBuildUuid = OpenHeroStationByBuildUuid
UIUtil.OpenHeroStationByStationId = OpenHeroStationByStationId
UIUtil.OpenHeroStationByEffectType = OpenHeroStationByEffectType
UIUtil.CheckAndOpenBusinessCenter = CheckAndOpenBusinessCenter
UIUtil.ShowPiggyBankTip = ShowPiggyBankTip
UIUtil.ShowEnergyBankTip = ShowEnergyBankTip
UIUtil.GetAllianceItemPos = GetAllianceItemPos
UIUtil.DoJumpFly = DoJumpFly
UIUtil.GetUIMainEnergySlider = GetUIMainEnergySlider
UIUtil.GetEnergyIconPos = GetEnergyIconPos
UIUtil.ShowSpecialTips = ShowSpecialTips
UIUtil.ShowSelectArmy = ShowSelectArmy
UIUtil.GetUIMainPromptView = GetUIMainPromptView
UIUtil.ShowSUMainPromptHP = ShowSUMainPromptHP
UIUtil.ShowSUMainPromptZombieHP = ShowSUMainPromptZombieHP
UIUtil.ShowSUMainPromptXP = ShowSUMainPromptXP
UIUtil.ShowCharacterDialogId = ShowCharacterDialogId
UIUtil.GetUIMainMsgView = GetUIMainMsgView
UIUtil.ShowSUMainMsg = ShowSUMainMsg
UIUtil.ShowSUMainMsgId = ShowSUMainMsgId
UIUtil.ShowSUMainDialog = ShowSUMainDialog
UIUtil.TryMoveCity = TryMoveCity
UIUtil.GetFlyTargetPosByRewardType = GetFlyTargetPosByRewardType
UIUtil.ShowPvePowerLack = ShowPvePowerLack
UIUtil.PveSceneHeroListRefresh = PveSceneHeroListRefresh
UIUtil.PveSceneHeroListScrollToHero = PveSceneHeroListScrollToHero
UIUtil.CheckPubButtonOpen = CheckPubButtonOpen
UIUtil.GetSUCityBuildBtns = GetSUCityBuildBtns
UIUtil.OnSUCityBuildBtnClick = OnSUCityBuildBtnClick
UIUtil.CheckFunctionBtnShow = CheckFunctionBtnShow
UIUtil.GetScreenWidth = GetScreenWidth
UIUtil.GetScreenHeight = GetScreenHeight
UIUtil.UpdatePoint = UpdatePoint
UIUtil.IsInSide =IsInSide
UIUtil.IsSpeedUpIcon = IsSpeedUpIcon
UIUtil.GetPosOfTowLine =GetPosOfTowLine
UIUtil.GetChampionBattleMigrateName = GetChampionBattleMigrateName
UIUtil.KeepDecimal =KeepDecimal
UIUtil.GetSpeedUpIcon = GetSpeedUpIcon
UIUtil.SetFunctionBtnState = SetFunctionBtnState
UIUtil.ShowSUUserLevelUp = ShowSUUserLevelUp
UIUtil.GetTableDataUnlockCondition = GetTableDataUnlockCondition
UIUtil.GetIsFunctionUnlock = GetIsFunctionUnlock
UIUtil.CheckShowDeadlyEffect = CheckShowDeadlyEffect
UIUtil.SegmentsInterPoint = SegmentsInterPoint
UIUtil.Cross = Cross
UIUtil.GetSpeedUpHeroName = GetSpeedUpHeroName
UIUtil.OnClickGiftBubble = OnClickGiftBubble
UIUtil.PlayGiftVideo = PlayGiftVideo
UIUtil.CheckShowBrokenTips = CheckShowBrokenTips
UIUtil.BuildUpgrade = BuildUpgrade
UIUtil.CheckUIWorldTileClose = CheckUIWorldTileClose
UIUtil.CheckUICanOpen = CheckUICanOpen
UIUtil.GetResource = GetResource
UIUtil.CalculateArc = CalculateArc
UIUtil.OnDispatchTaskClick = OnDispatchTaskClick
UIUtil.GetPopupPackageConfig = GetPopupPackageConfig
UIUtil.GetEffectNumWithType = GetEffectNumWithType
UIUtil.GetEffectNumByType =GetEffectNumByType
UIUtil.ShowUseGarageComponBoxConfirm = ShowUseGarageComponBoxConfirm
UIUtil.CalcMilePointer = CalcMilePointer
UIUtil.CalcConstructMilePointer = CalcConstructMilePointer
UIUtil.CheckSourceServerLimit = CheckSourceServerLimit

return ConstClass("UIUtil", UIUtil)