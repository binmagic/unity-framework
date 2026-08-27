---
--- 飞船背景UI — View
--- 主界面：建筑格子列表 + 底部操作栏
--- 格子点击选中 → 底部显示建筑名/等级/状态/操作按钮
--- 节点不存在时静默跳过，Prefab 补充节点后自动生效
---
local UIShipBackgroundView = BaseClass("UIShipBackgroundView", UIBaseView)
local base = UIBaseView
local UIGray = CS.UIGray

--- 安全 AddComponent：节点不存在时静默跳过
local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

--- 格式化秒数为可读字符串
local function FormatTime(seconds)
    if seconds <= 0 then return "立即完成" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if d > 0 then
        return string.format("%d天%02d:%02d:%02d", d, h, m, s)
    elseif h > 0 then
        return string.format("%d时%02d分%02d秒", h, m, s)
    elseif m > 0 then
        return string.format("%d分%02d秒", m, s)
    else
        return string.format("%d秒", s)
    end
end

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function UIShipBackgroundView:OnCreate()
    base.OnCreate(self)
    self:_FixBgImage()
    self:ComponentDefine()
    self:DataDefine()
    self:RefreshBuildingGrid()
    self:RefreshBottomBar()
    self:RefreshTotalPower()
    self:_CreateDebugBtn()
end

function UIShipBackgroundView:ResortOrder(baseLayerOrder)
    if self.canvas then
        self.canvas.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceOverlay
        self.canvas.sortingOrder = -1
        self.lastSortingOrder = -1
    end
end

function UIShipBackgroundView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.ShipBuildingUpgradeFinish, self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockFinish,  self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUpgradeStart,  self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockStart,   self.OnBuildingStateChanged)
    -- 倒计时结束进入待领取状态
    self:AddUIListener(EventId.ShipBuildingUpgradeDone,   self.OnBuildingDone)
    self:AddUIListener(EventId.ShipBuildingUnlockDone,    self.OnBuildingDone)
    -- 总战力变化（领取建筑后触发）
    self:AddUIListener(EventId.ShipPlayerInfoUpdated,     self.OnPlayerInfoUpdated)
end

function UIShipBackgroundView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeFinish, self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockFinish,  self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeStart,  self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockStart,   self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeDone,   self.OnBuildingDone)
    self:RemoveUIListener(EventId.ShipBuildingUnlockDone,    self.OnBuildingDone)
    self:RemoveUIListener(EventId.ShipPlayerInfoUpdated,     self.OnPlayerInfoUpdated)
end

function UIShipBackgroundView:OnDestroy()
    if self.countdownTimer then
        self.countdownTimer:Stop()
        self.countdownTimer = nil
    end
    self:DataDestroy()
    base.OnDestroy(self)
end

--- ---------------------------------------------------------------
--- 调试按钮（仅 Editor，动态创建，不依赖 Prefab 节点）
--- ---------------------------------------------------------------

function UIShipBackgroundView:_CreateDebugBtn()
    if not App.IsEditor() then return end

    local GameObject    = CS.UnityEngine.GameObject
    local RectTransform = typeof(CS.UnityEngine.RectTransform)
    local Image         = typeof(CS.UnityEngine.UI.Image)
    local Button        = typeof(CS.UnityEngine.UI.Button)
    local Text          = typeof(CS.UnityEngine.UI.Text)
    local Color         = CS.UnityEngine.Color
    local Vector2       = CS.UnityEngine.Vector2

    -- 找 BtnDetail 节点，把调试按钮放在它正上方
    local parent     = self.transform
    local anchorPos  = Vector2(0, 60)   -- 默认左上角兜底位置
    local anchorMin  = Vector2(0, 1)
    local anchorMax  = Vector2(0, 1)
    local pivot      = Vector2(0, 1)

    local btnDetailTf = self.transform:Find("BtnDetail")
    if btnDetailTf == nil then
        -- 兜底：挂在根节点左上角
        Logger.Log("[ShipTest] BtnDetail 未找到，调试按钮放左上角")
    else
        -- 和 BtnDetail 同父节点，位置在它正上方
        parent    = btnDetailTf.parent
        local rt  = btnDetailTf:GetComponent(RectTransform)
        anchorMin = rt.anchorMin
        anchorMax = rt.anchorMax
        pivot     = rt.pivot
        -- 在 BtnDetail 的 anchoredPosition 基础上往上偏移 60px
        anchorPos = Vector2(rt.anchoredPosition.x, rt.anchoredPosition.y + 60)
    end

    local btnGo = GameObject("DEBUG_ShipTest", RectTransform)
    btnGo.transform:SetParent(parent, false)

    local rt2 = btnGo:GetComponent(RectTransform)
    rt2.anchorMin        = anchorMin
    rt2.anchorMax        = anchorMax
    rt2.pivot            = pivot
    rt2.anchoredPosition = anchorPos
    rt2.sizeDelta        = Vector2(180, 50)

    local img = btnGo:AddComponent(Image)
    img.color = Color(0.15, 0.15, 0.15, 0.85)

    local txtGo = GameObject("Text", RectTransform)
    txtGo.transform:SetParent(btnGo.transform, false)
    local txtRt = txtGo:GetComponent(RectTransform)
    txtRt.anchorMin = Vector2(0, 0)
    txtRt.anchorMax = Vector2(1, 1)
    txtRt.offsetMin = Vector2(0, 0)
    txtRt.offsetMax = Vector2(0, 0)
    local txt = txtGo:AddComponent(Text)
    txt.text      = "[DEBUG] 船舱测试"
    txt.fontSize  = 18
    txt.alignment = CS.UnityEngine.TextAnchor.MiddleCenter
    txt.color     = Color(0.2, 1, 0.4, 1)

    local btn = btnGo:AddComponent(Button)
    btn.onClick:AddListener(function()
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISettingConsole,
            { anim = true, UIMainAnim = UIMainAnimType.AllHide })
    end)
end

--- ---------------------------------------------------------------
--- 背景偏移修正
--- ---------------------------------------------------------------

function UIShipBackgroundView:_FixBgImage()
    local bg = self.transform:Find("BgImage")
    if bg then
        local rt = bg:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if rt then
            rt.offsetMin = CS.UnityEngine.Vector2(0, 100)
            rt.offsetMax = CS.UnityEngine.Vector2(0, 0)
        end
    end
end

--- ---------------------------------------------------------------
--- 组件绑定
--- ---------------------------------------------------------------

function UIShipBackgroundView:ComponentDefine()
    -- 关闭按钮
    self.btnClose = SafeAddComponent(self, UIButton, "BtnClose")
    if self.btnClose then
        self.btnClose:SetOnClick(function() self:CloseSelf() end)
    end

    -- 建筑格子列表容器
    self.gridContent = self.transform:Find("ScrollView/Viewport/Content")

    -- ---- 底部操作栏 ----
    self.txtBuildName   = SafeAddComponent(self, UITextMeshProUGUIEx, "BottomBar/TxtBuildName")
    self.txtBuildLevel  = SafeAddComponent(self, UITextMeshProUGUIEx, "BottomBar/TxtBuildLevel")
    self.txtBuildPower  = SafeAddComponent(self, UITextMeshProUGUIEx, "BottomBar/TxtBuildPower")
    self.txtBuildEffect = SafeAddComponent(self, UITextMeshProUGUIEx, "BottomBar/TxtBuildEffect")
    self.txtCountdown   = SafeAddComponent(self, UITextMeshProUGUIEx, "BottomBar/TxtCountdown")

    self.btnUnlock  = SafeAddComponent(self, UIButton, "BottomBar/BtnUnlock")
    if self.btnUnlock then
        self.btnUnlock:SetOnClick(function() self:OnClickUnlock() end)
    end

    self.btnUpgrade = SafeAddComponent(self, UIButton, "BottomBar/BtnUpgrade")
    if self.btnUpgrade then
        self.btnUpgrade:SetOnClick(function() self:OnClickUpgrade() end)
    end

    self.btnSpeedUp = SafeAddComponent(self, UIButton, "BottomBar/BtnSpeedUp")
    if self.btnSpeedUp then
        self.btnSpeedUp:SetOnClick(function() self:OnClickSpeedUp() end)
    end

    -- 领取按钮：倒计时结束后显示，玩家点击才真正写入等级/战力
    self.btnCollect = SafeAddComponent(self, UIButton, "BottomBar/BtnCollect")
    if self.btnCollect then
        self.btnCollect:SetOnClick(function() self:OnClickCollect() end)
    end

    -- 总战力显示（节点不存在时静默跳过）
    self.txtTotalPower = SafeAddComponent(self, UITextMeshProUGUIEx, "TopBar/TxtTotalPower")
end

--- ---------------------------------------------------------------
--- 数据初始化
--- ---------------------------------------------------------------

function UIShipBackgroundView:DataDefine()
    -- 所有建筑 id 列表
    self.buildIdList    = self.ctrl:GetPlayerBuildIdList()
    -- 当前选中的 buildId
    self.curBuildId     = self.buildIdList and self.buildIdList[1] or nil
    -- 格子节点缓存 table<buildId, transform>
    self.gridItemMap    = {}
    -- 倒计时定时器
    self.countdownTimer = nil
end

function UIShipBackgroundView:DataDestroy()
    self.buildIdList  = nil
    self.curBuildId   = nil
    self.gridItemMap  = nil
end

--- ---------------------------------------------------------------
--- 建筑格子列表
--- ---------------------------------------------------------------

--- 刷新所有格子
function UIShipBackgroundView:RefreshBuildingGrid()
    if not self.gridContent or not self.buildIdList then return end
    for i, buildId in ipairs(self.buildIdList) do
        local itemNode = self.gridContent:Find("Item_" .. tostring(i))
        if itemNode then
            self.gridItemMap[buildId] = itemNode
            self:RefreshGridItem(itemNode, buildId)
        end
    end
end

--- 刷新单个格子
function UIShipBackgroundView:RefreshGridItem(itemNode, buildId)
    local cfg       = self.ctrl:GetBuildingConfig(buildId)
    local unlocked  = self.ctrl:IsBuildingUnlocked(buildId)
    local level     = self.ctrl:GetPlayerBuildingLevel(buildId)
    local buildData = self.ctrl:GetPlayerBuildingData(buildId)
    local isDone    = buildData and buildData:IsDone() or false

    -- 锁定遮罩（调试：暂时强制隐藏，确认格子底色是否可见）
    local imgLock = itemNode:Find("ImgLock")
    if imgLock then
        imgLock.gameObject:SetActive(false)  -- DEBUG: 强制隐藏锁定遮罩
    end

    -- 升级中扳手图标
    local imgUpgrading = itemNode:Find("ImgUpgrading")
    if imgUpgrading then
        local isUpgrading = buildData and (buildData:IsUpgrading() or buildData:IsUnlocking())
        imgUpgrading.gameObject:SetActive(isUpgrading == true)
    end

    -- 完成待领取图标（感叹号/完成标记）
    local imgDone = itemNode:Find("ImgDone")
    if imgDone then
        imgDone.gameObject:SetActive(isDone)
    end

    -- 等级文本
    local txtLevel = itemNode:Find("TxtLevel")
    if txtLevel then
        local label = txtLevel:GetComponent(typeof(CS.UnityEngine.UI.Text))
        if label then
            if isDone then
                label.text = "完成!"
            else
                label.text = unlocked and ("Lv." .. tostring(level)) or ""
            end
        end
    end

    -- 建筑名
    local txtName = itemNode:Find("TxtName")
    if txtName then
        local label = txtName:GetComponent(typeof(CS.UnityEngine.UI.Text))
        if label then
            label.text = cfg.name or ""
        end
    end

    -- 选中高亮边框
    local imgSelected = itemNode:Find("ImgSelected")
    if imgSelected then
        imgSelected.gameObject:SetActive(buildId == self.curBuildId)
    end

    -- 点击事件
    local btn = itemNode:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if btn then
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            self:SelectBuilding(buildId)
        end)
    end
end

--- 切换选中建筑
function UIShipBackgroundView:SelectBuilding(buildId)
    local prevBuildId = self.curBuildId
    self.curBuildId   = buildId

    -- 刷新前一个格子（取消高亮）
    if prevBuildId and self.gridItemMap[prevBuildId] then
        self:RefreshGridItem(self.gridItemMap[prevBuildId], prevBuildId)
    end
    -- 刷新当前格子（显示高亮）
    if self.gridItemMap[buildId] then
        self:RefreshGridItem(self.gridItemMap[buildId], buildId)
    end

    self:RefreshBottomBar()

    -- 打开船舱详情面板
    self:OpenCabinDetail(buildId)
end

--- 打开船舱详情面板
function UIShipBackgroundView:OpenCabinDetail(buildId)
    if not buildId then return end
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIShipCabinDetail, nil, buildId)
end

--- ---------------------------------------------------------------
--- 底部操作栏
--- ---------------------------------------------------------------

--- 刷新底部操作栏
function UIShipBackgroundView:RefreshBottomBar()
    local buildId = self.curBuildId
    if not buildId then
        self:_SetBottomBarVisible(false)
        return
    end
    self:_SetBottomBarVisible(true)

    local d = self.ctrl:GetBuildingDetail(buildId)
    self.curDetail = d

    -- 建筑名
    if self.txtBuildName then
        self.txtBuildName:SetText(d.cfg.name or "")
    end

    -- 等级：待领取时显示"完成"提示
    if self.txtBuildLevel then
        if d.isDone then
            local doneStr = d.doneType == "unlock" and "解锁完成！" or
                string.format("升至%d级 完成！", d.nextLevel)
            self.txtBuildLevel:SetText(doneStr)
        elseif d.unlocked then
            self.txtBuildLevel:SetText(string.format("Lv.%d / %d", d.curLevel, d.maxLevel))
        else
            self.txtBuildLevel:SetText("未解锁")
        end
    end

    -- 当前战力
    if self.txtBuildPower then
        if d.unlocked and d.curPower > 0 then
            self.txtBuildPower:SetText("战力 " .. tostring(d.curPower))
        else
            self.txtBuildPower:SetText("")
        end
    end

    -- 当前产出/效果描述
    if self.txtBuildEffect then
        if d.unlocked then
            self.txtBuildEffect:SetText(d.curEffect or "")
        else
            self.txtBuildEffect:SetText(d.cfg.desc or "")
        end
    end

    -- 倒计时（升级/解锁中时显示，待领取时隐藏）
    if self.txtCountdown then
        self.txtCountdown:SetActive(d.isUpgrading)
        if d.isUpgrading then
            self.txtCountdown:SetText(FormatTime(d.remainSeconds))
        end
    end

    -- 按钮互斥显示逻辑：
    -- 待领取（Done）  → 领取按钮
    -- 未解锁          → 解锁按钮
    -- 升级/解锁中     → 立即完成按钮
    -- 已解锁空闲未满级 → 升级按钮
    -- 满级            → 全部隐藏
    local showCollect = d.isDone
    local showUnlock  = not d.isDone and not d.unlocked
    local showSpeedUp = not d.isDone and d.unlocked and d.isUpgrading
    local showUpgrade = not d.isDone and d.unlocked and not d.isUpgrading and not d.isMax

    if self.btnCollect then self.btnCollect:SetActive(showCollect) end
    if self.btnUnlock  then self.btnUnlock:SetActive(showUnlock)   end
    if self.btnSpeedUp then self.btnSpeedUp:SetActive(showSpeedUp) end
    if self.btnUpgrade then self.btnUpgrade:SetActive(showUpgrade) end

    -- 升级/解锁按钮灰化
    -- 第 3 参 canClick 恒传 true：它直接决定 `Button.enabled`（UIGray.cs:155），
    -- 传 false 会让原生 onClick 压根不触发。这两个按钮点了只是打开确认弹窗，
    -- 而弹窗正是展示"缺哪样资源 / 差什么前置"的地方 —— 禁用掉玩家就无从得知原因。
    if self.btnUpgrade and showUpgrade then
        UIGray.SetGray(self.btnUpgrade.transform, not d.canOperate, true)
    end
    if self.btnUnlock and showUnlock then
        UIGray.SetGray(self.btnUnlock.transform, not d.canOperate, true)
    end

    self:_UpdateCountdownTimer(d.isUpgrading)
end

--- 控制底部栏整体显隐
function UIShipBackgroundView:_SetBottomBarVisible(visible)
    local bar = self.transform:Find("BottomBar")
    if bar then bar.gameObject:SetActive(visible) end
end

--- 倒计时定时器管理（每秒刷新一次倒计时文本）
function UIShipBackgroundView:_UpdateCountdownTimer(needTimer)
    if needTimer then
        if not self.countdownTimer then
            self.countdownTimer = TimerManager:GetInstance():GetTimer(
                1, self._OnCountdownTick, self, false, false, false)
            self.countdownTimer:Start()
        end
    else
        if self.countdownTimer then
            self.countdownTimer:Stop()
            self.countdownTimer = nil
        end
    end
end

--- 每秒刷新倒计时文本
function UIShipBackgroundView:_OnCountdownTick()
    local buildId = self.curBuildId
    if not buildId then return end
    local buildData = self.ctrl:GetPlayerBuildingData(buildId)
    if not buildData then return end

    if buildData:IsUpgrading() or buildData:IsUnlocking() then
        if self.txtCountdown then
            self.txtCountdown:SetText(FormatTime(buildData:GetRemainSeconds()))
        end
    else
        -- 倒计时结束，刷新整个底部栏
        self:RefreshBottomBar()
        -- 同时刷新对应格子
        if self.gridItemMap[buildId] then
            self:RefreshGridItem(self.gridItemMap[buildId], buildId)
        end
    end
end

--- ---------------------------------------------------------------
--- 事件监听
--- ---------------------------------------------------------------

--- 建筑状态变化（升级开始/完成领取、解锁开始/完成领取）
function UIShipBackgroundView:OnBuildingStateChanged(data)
    local buildId = data and data.buildId
    if not buildId then return end
    if self.gridItemMap[buildId] then
        self:RefreshGridItem(self.gridItemMap[buildId], buildId)
    end
    if buildId == self.curBuildId then
        self:RefreshBottomBar()
    end
end

--- 总战力刷新（领取建筑后调用）
function UIShipBackgroundView:RefreshTotalPower()
    if not self.txtTotalPower then return end
    local total = DataCenter.ShipPlayerDataManager:CalcTotalPower()
    self.txtTotalPower:SetText("总战力 " .. tostring(total))
end

--- 玩家信息变更事件（总战力等）
function UIShipBackgroundView:OnPlayerInfoUpdated()
    self:RefreshTotalPower()
end

--- 倒计时结束进入待领取状态
function UIShipBackgroundView:OnBuildingDone(data)
    local buildId = data and data.buildId
    if not buildId then return end
    -- 停止倒计时定时器
    self:_UpdateCountdownTimer(false)
    -- 刷新格子（显示完成图标）
    if self.gridItemMap[buildId] then
        self:RefreshGridItem(self.gridItemMap[buildId], buildId)
    end
    -- 刷新底部栏（显示领取按钮）
    if buildId == self.curBuildId then
        self:RefreshBottomBar()
    end
end

--- ---------------------------------------------------------------
--- 按钮回调
--- ---------------------------------------------------------------

--- 领取按钮：真正写入等级/战力
function UIShipBackgroundView:OnClickCollect()
    if not self.curBuildId then return end
    self.ctrl:CollectBuilding(self.curBuildId)
end

--- 升级按钮：打开确认弹窗，不直接扣消耗
function UIShipBackgroundView:OnClickUpgrade()
    if not self.curBuildId then return end
    self.ctrl:OpenBuildingPanel(self.curBuildId)
end

--- 解锁按钮：打开确认弹窗
function UIShipBackgroundView:OnClickUnlock()
    if not self.curBuildId then return end
    self.ctrl:OpenBuildingPanel(self.curBuildId)
end

--- 立即完成按钮：直接加速，不需要确认
function UIShipBackgroundView:OnClickSpeedUp()
    if not self.curBuildId then return end
    self.ctrl:SpeedUpBuilding(self.curBuildId)
end

return UIShipBackgroundView
