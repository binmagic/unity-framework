---
--- 船舱详情面板 — View
--- 点击船舱格子后弹出，展示：
---   标题栏：舱室名 + 等级
---   数据行：用时 / 产出 / 生产上限（3列横排）
---   家具列表：图标 + 名称 + 等级 + 进度条 + 升级按钮
---   船员区：船员头像列表
---   底部：返回 / 升级 / 领取按钮
---@class UIShipCabinDetailView : UIBaseView
local UIShipCabinDetailView = BaseClass("UIShipCabinDetailView", UIBaseView)
local base = UIBaseView

--- 家具图标映射（buildId + 序号 → 道具 sprite），唯一真相源
local FurnitureIconMap = require "UI.UIShipCabinDetail.FurnitureIconMap"

--- 安全 AddComponent
local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

--- 格式化秒数
local function FormatTime(seconds)
    if seconds <= 0 then return "已完成" end
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

--- 格式化大数值
local function FormatNumber(num)
    if num >= 100000000 then
        return string.format("%.1f亿", num / 100000000)
    elseif num >= 10000 then
        return string.format("%.1f万", num / 10000)
    else
        return tostring(num)
    end
end

--- Prefab 节点路径（与新预制体结构对应）
local PATH = {
    BTN_CLOSE         = "MainPanel/BtnClose",
    BTN_BG_MASK       = "BgMask",

    -- 标题栏
    TXT_NAME              = "MainPanel/TitleBar/TxtName",
    TXT_LEVEL             = "MainPanel/TitleBar/TxtLevel",
    BTN_UPGRADE_ARROW     = "MainPanel/TitleBar/BtnUpgradeArrow",

    -- 升级进度条（建筑等级进度）
    UPGRADE_BAR           = "MainPanel/UpgradeBar",
    TXT_PROGRESS          = "MainPanel/UpgradeBar/TxtProgress",
    UPGRADE_BAR_FILL      = "MainPanel/UpgradeBar/ProgressFill",

    -- 数据行（3列横排）
    DATA_ROW          = "MainPanel/DataRow",
    TXT_TIME          = "MainPanel/DataRow/DataCol_0/TxtTime",
    TXT_OUTPUT        = "MainPanel/DataRow/DataCol_1/TxtOutput",
    TXT_LIMIT         = "MainPanel/DataRow/DataCol_2/TxtLimit",

    -- 预览窗内的产量条（参考原版："[舱室]产量 +N%" + 右侧 ☰）
    OUTPUT_BAR            = "RoomPreview/OutputBar",
    TXT_OUTPUT_BAR        = "RoomPreview/OutputBar/TxtOutput",
    BTN_OUTPUT_MENU       = "RoomPreview/OutputBar/BtnMenu",

    -- 家具列表
    FURNITURE_ROOT        = "MainPanel/FurniturePanel",
    FURNITURE_ITEM_PREFIX = "MainPanel/FurniturePanel/FurnitureItem_",

    -- 船员区
    CREW_PANEL        = "MainPanel/CrewPanel",
    BTN_ADD_CREW      = "MainPanel/CrewPanel/BtnAddCrew",
    TXT_PLUS          = "MainPanel/CrewPanel/BtnAddCrew/TxtPlus",
    CREW_SLOT_PREFIX  = "MainPanel/CrewPanel/CrewSlot_",

    -- 底部按钮
    BTN_BACK          = "MainPanel/Footer/BtnBack",
    BTN_UPGRADE       = "MainPanel/Footer/BtnUpgrade",
    TXT_BTN_UPGRADE   = "MainPanel/Footer/BtnUpgrade/TxtLabel",
    BTN_COLLECT       = "MainPanel/Footer/BtnCollect",
}

--- 家具区最多显示几行。prefab 里 FurniturePanel 就是按 4 行做的
--- （FurnitureItem_1..4），原来写 2 会让下半区空着，与参考图的紧凑感差很远。
local MAX_FURNITURE_DISPLAY = 4

--- 家具区几何（须与 prefab 分带保持一致，供 _RelayoutSections 按实际行数收缩用）
--- prefab 里 FurniturePanel 写死高度容纳 4 行，只显示 N 行时底部会留空白
--- 分带比例参照原版设计（详见 knowledge/codebase/longlong-ui-design-reference.md）：
---   标题96 + 进度40 + 指标118 = 254 为家具区顶偏移
local FURNITURE_TITLE_H     = 34    -- TxtFurnitureTitle 高
local FURNITURE_ROW_H       = 160   -- FurnitureItem_N 基准高（家具区380严格取参考图23.4%，
                                    -- 2行平分后每行160，占屏9.9%，接近参考图单行11.7%）
local FURNITURE_ROW_H_MIN   = 96    -- 行高下限（行数多时不能挤得太扁）
-- 行高上限：参考图的家具行明显偏矮、一屏能看到 4 行。原来 190 是按"单行占屏
-- 11.7%"算的，但那测的是参考图里最高的那行；实际 4 行并排时每行约 130。
-- 上限收到 132 后，4 行时行高由平分值（~175）被夹到 132，视觉密度才接近参考图。
local FURNITURE_ROW_H_MAX   = 132   -- 行高上限
local FURNITURE_ROW_GAP     = 8     -- 行间距
local FURNITURE_PAD_BOTTOM  = 10    -- 底部留白
-- 家具行内部横向分带（行宽 734 = MainPanel 750 - 左右各 8）
local FURNITURE_ROW_PAD_X   = 14    -- 行内左右边距
local FURNITURE_ROW_ICON_GAP= 16    -- 图标底衬与文字列的间隔
local FURNITURE_STATUS_W    = 180   -- 状态按钮宽（最长倒计时"1时02分30秒"实测 142，放得下）
local FURNITURE_TOP_OFFSET  = 251   -- = TitleBar 96 + UpgradeBar 36 + DataRow 119
local SECTION_GAP           = 8     -- 区块间距
local PANEL_H               = 856   -- MainPanel 高（须与 prefab 一致）
                                    -- = 标题96+进度36+指标119+家具380+船员154+底部72
local FOOTER_H              = 72    -- Footer 高（须与 prefab 一致）
local FURNITURE_CREW_H      = 154   -- CrewPanel 高（拿不到实际值时的兜底）

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function UIShipCabinDetailView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function UIShipCabinDetailView:OnEnable()
    base.OnEnable(self)
    self:ApplyUserData()
end

--- 按当前 userData 切换到对应舱室
--- 抽成独立方法的原因：框架只在首次创建窗口时调 OnEnable，
--- 面板已打开时重复 OpenWindow 走的是 SetActive(true)，不会再触发 OnEnable。
--- 所以 Ctrl 侧在窗口已存在时要显式调这个方法，否则 userData 更新了但界面不刷新。
function UIShipCabinDetailView:ApplyUserData()
    local buildId = self:GetUserData()
    self.buildId = buildId
    Logger.Log("UIShipCabinDetailView ApplyUserData buildId=" .. tostring(buildId))

    -- 触发 RoomScene 加载动画
    -- 内景名由 Lua 侧 RoomSceneMap 决定（唯一真相源，覆盖全部 37 个建筑），
    -- 直接作为参数传给 C#，不让 C# 反查 Lua——XLuaManager.CallWithReturn* 取不到返回值
    local bid = tonumber(buildId) or 0
    if bid >= 1 then
        local animator = self.transform:GetComponent(typeof(CS.ShipCabinDetailAnimator))
        if animator then
            local ok, map = pcall(require, "UI.UIShipCabin.RoomSceneMap")
            if ok and map ~= nil then
                animator:Show(bid, map.GetSceneName(bid))
            else
                Logger.LogWarning("UIShipCabinDetailView ApplyUserData require RoomSceneMap失败 err=" .. tostring(map))
                animator:Show(bid)
            end
        end
    end

    self:Refresh()
end

function UIShipCabinDetailView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.ShipBuildingUpgradeFinish, self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockFinish,  self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUpgradeStart,  self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockStart,   self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUpgradeDone,   self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockDone,    self.OnBuildingStateChanged)
    self:AddUIListener(EventId.ShipFurnitureUpgradeStart,  self.OnFurnitureChanged)
    self:AddUIListener(EventId.ShipFurnitureUpgradeDone,   self.OnFurnitureChanged)
    self:AddUIListener(EventId.ShipFurnitureUpgradeFinish, self.OnFurnitureChanged)
    self:AddUIListener(EventId.ShipFurnitureUnlockFinish,  self.OnFurnitureChanged)
end

function UIShipCabinDetailView:OnRemoveListener()
    self:RemoveUIListener(EventId.ShipBuildingUpgradeFinish, self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockFinish,  self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeStart,  self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockStart,   self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeDone,   self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockDone,    self.OnBuildingStateChanged)
    self:RemoveUIListener(EventId.ShipFurnitureUpgradeStart,  self.OnFurnitureChanged)
    self:RemoveUIListener(EventId.ShipFurnitureUpgradeDone,   self.OnFurnitureChanged)
    self:RemoveUIListener(EventId.ShipFurnitureUpgradeFinish, self.OnFurnitureChanged)
    self:RemoveUIListener(EventId.ShipFurnitureUnlockFinish,  self.OnFurnitureChanged)
    base.OnRemoveListener(self)
end

function UIShipCabinDetailView:OnDestroy()
    self:_StopCountdownTimer()
    self:DataDestroy()
    base.OnDestroy(self)
end

--- ---------------------------------------------------------------
--- 组件绑定
--- ---------------------------------------------------------------

function UIShipCabinDetailView:ComponentDefine()
    -- 关闭 / 背景点击
    self.btnClose = SafeAddComponent(self, UIButton, PATH.BTN_CLOSE)
    if self.btnClose then
        self.btnClose:SetOnClick(function() self:CloseSelf() end)
    end
    self.btnBgMask = SafeAddComponent(self, UIButton, PATH.BTN_BG_MASK)
    if self.btnBgMask then
        self.btnBgMask:SetOnClick(function() self:CloseSelf() end)
    end

    -- 标题栏
    self.txtName  = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_NAME)
    self.txtLevel = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_LEVEL)

    -- 标题栏升级箭头
    self.btnUpgradeArrow = SafeAddComponent(self, UIButton, PATH.BTN_UPGRADE_ARROW)
    if self.btnUpgradeArrow then
        self.btnUpgradeArrow:SetOnClick(function() self:OnClickUpgrade() end)
    end

    -- 升级进度条
    self.txtProgress = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_PROGRESS)
    local upgradeBarFillNode = self.transform:Find(PATH.UPGRADE_BAR_FILL)
    self.upgradeBarFillRT = upgradeBarFillNode and upgradeBarFillNode:GetComponent(typeof(CS.UnityEngine.RectTransform)) or nil

    -- 数据行
    self.txtTime   = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_TIME)
    self.txtOutput = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_OUTPUT)
    self.txtLimit  = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_LIMIT)

    -- 预览窗内的产量条
    self.txtOutputBar  = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_OUTPUT_BAR)
    self.btnOutputMenu = SafeAddComponent(self, UIButton, PATH.BTN_OUTPUT_MENU)
    if self.btnOutputMenu then
        self.btnOutputMenu:SetOnClick(function() UIUtil.ShowTips("产量详情开发中") end)
    end

    -- 船员区加号按钮（目前仅提示，未接入真实船员）
    self.btnAddCrew = SafeAddComponent(self, UIButton, PATH.BTN_ADD_CREW)
    if self.btnAddCrew then
        self.btnAddCrew:SetOnClick(function() UIUtil.ShowTips("船员功能开发中") end)
    end

    -- 底部按钮
    self.btnBack = SafeAddComponent(self, UIButton, PATH.BTN_BACK)
    if self.btnBack then
        self.btnBack:SetOnClick(function() self:CloseSelf() end)
    end

    self.btnUpgrade = SafeAddComponent(self, UIButton, PATH.BTN_UPGRADE)
    if self.btnUpgrade then
        self.btnUpgrade:SetOnClick(function() self:OnClickUpgrade() end)
    end
    self.txtBtnUpgrade = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_BTN_UPGRADE)

    self.btnCollect = SafeAddComponent(self, UIButton, PATH.BTN_COLLECT)
    if self.btnCollect then
        self.btnCollect:SetOnClick(function() self:OnClickCollect() end)
    end
end

function UIShipCabinDetailView:DataDefine()
    self.buildId        = nil
    self.detail         = nil
    self.countdownTimer = nil
end

function UIShipCabinDetailView:DataDestroy()
    self.buildId = nil
    self.detail  = nil
end

--- ---------------------------------------------------------------
--- 刷新
--- ---------------------------------------------------------------

function UIShipCabinDetailView:Refresh()
    if not self.buildId then return end

    local d = self.ctrl:GetCabinDetail(self.buildId)
    self.detail = d

    self:RefreshHeader(d)
    self:RefreshUpgradeBar(d)
    self:RefreshDataRow(d)
    self:RefreshOutputBar(d)
    self:RefreshFurnitureList(d)
    self:RefreshCrewPanel(d)
    self:RefreshFooter(d)
end

--- 预览窗内的产量条（参考原版："[金属冶炼室]产量 +50%" + 右侧 ☰）
--- 加成百分比 = 家具带来的 outputInc 占基础产量的比例
function UIShipCabinDetailView:RefreshOutputBar(d)
    local bar = self.transform:Find(PATH.OUTPUT_BAR)
    if bar == nil then return end

    -- 只有能产出的舱室才显示
    local hasOutput = (d.produceCD or 0) > 0 and (d.productBase or 0) > 0
    bar.gameObject:SetActive(hasOutput)
    if not hasOutput then return end

    if self.txtOutputBar then
        local base = d.productBase or 0
        local inc  = d.outputInc or 0
        local pct  = (base > 0) and math.floor(inc / base * 100 + 0.5) or 0
        self.txtOutputBar:SetText(string.format("[%s]产量 +%d%%", d.cfg.name or "", pct))
    end
end

--- 标题栏：名称 + 等级 + 升级箭头可见性
function UIShipCabinDetailView:RefreshHeader(d)
    if self.txtName then
        self.txtName:SetText(d.cfg.name or "")
    end
    if self.txtLevel then
        -- 未解锁时不显示文字（原来会显示"未解锁"，与底部按钮的"解锁"重复，
        -- 参考图标题栏只在已解锁时显示等级）
        if d.unlocked then
            self.txtLevel:SetActive(true)
            self.txtLevel:SetText(string.format("%d级", d.curLevel))
        else
            self.txtLevel:SetActive(false)
        end
    end
    -- 升级箭头：满级/升级中隐藏，其余显示
    if self.btnUpgradeArrow then
        local showArrow = not d.isMax and not d.isUpgrading
        self.btnUpgradeArrow:SetActive(showArrow)
    end
end

--- 升级进度条：显示当前等级进度 (curLevel / maxLevel)
function UIShipCabinDetailView:RefreshUpgradeBar(d)
    local barNode = self.transform:Find(PATH.UPGRADE_BAR)
    if not barNode then return end
    barNode.gameObject:SetActive(d.unlocked)
    if not d.unlocked then return end

    local maxLevel = d.maxLevel or 1
    local curLevel = d.curLevel or 0
    local progress = maxLevel > 0 and math.min(curLevel / maxLevel, 1) or 0

    -- 进度条填充（anchorMax.x 控制宽度）
    if self.upgradeBarFillRT then
        self.upgradeBarFillRT.anchorMax = CS.UnityEngine.Vector2(progress, 1)
    end

    -- 进度文字：例如 "21/28" 或百分比
    if self.txtProgress then
        self.txtProgress:SetText(string.format("%d/%d", curLevel, maxLevel))
    end
end

--- 船员区：目前只显示/隐藏容器，头像槽留空（船员功能待接入）
function UIShipCabinDetailView:RefreshCrewPanel(d)
    local crewPanel = self.transform:Find(PATH.CREW_PANEL)
    if not crewPanel then return end
    -- 已解锁的建筑才显示船员区
    crewPanel.gameObject:SetActive(d.unlocked)
end

--- 数据行：用时 / 产出 / 生产上限
function UIShipCabinDetailView:RefreshDataRow(d)
    local dataRow = self.transform:Find(PATH.DATA_ROW)
    if dataRow then
        dataRow.gameObject:SetActive(d.produceCD > 0)
    end
    if d.produceCD <= 0 then return end

    if self.txtTime then
        self.txtTime:SetText(FormatTime(d.realCD))
    end
    if self.txtOutput then
        self.txtOutput:SetText(FormatNumber(d.outputPerHour))
    end
    if self.txtLimit then
        if d.produceLimit > 0 then
            self.txtLimit:SetText(FormatNumber(d.produceLimit))
        else
            self.txtLimit:SetText("∞")
        end
    end
end

--- 家具列表
function UIShipCabinDetailView:RefreshFurnitureList(d)
    local furnitureRoot = self.transform:Find(PATH.FURNITURE_ROOT)
    if not furnitureRoot then return end

    local list = d.furnitureList or {}
    furnitureRoot.gameObject:SetActive(#list > 0)

    local shown = 0
    for i = 1, MAX_FURNITURE_DISPLAY do
        local itemNode = self.transform:Find(PATH.FURNITURE_ITEM_PREFIX .. tostring(i))
        if not itemNode then break end
        local fData = list[i]
        if fData then
            itemNode.gameObject:SetActive(true)
            self:_RefreshFurnitureItem(itemNode, fData, i)
            shown = shown + 1
        else
            itemNode.gameObject:SetActive(false)
        end
    end

    self:_RelayoutSections(shown)

    -- 首次打开时 MainPanel 的 RectTransform 还没被 Canvas 排版，
    -- rect.height 读到 0（_RelayoutSections 会退回 PANEL_H 常量），
    -- 算出的可用高度偏小 → 最后一行溢出到家具区外面。
    -- 延迟一帧再排一次，此时能读到真实高度（实测 856）。
    --
    -- 每次刷新都补排，不能用一次性标志：切换舱室后行数会变，
    -- 只在首次补排的话，之后换到行数不同的舱室又会溢出。
    if self._relayoutTimer then
        self._relayoutTimer:Stop()
        self._relayoutTimer = nil
    end
    self._relayoutTimer = TimerManager:GetInstance():DelayInvoke(function()
        self._relayoutTimer = nil
        if self.transform then self:_RelayoutSections(shown) end
    end, 0.05)
end

--- 按实际家具行数调整家具区高度
--- 关键：船员区固定贴在底栏上方（参考图就是这样），不跟着家具区移动。
--- 家具区吸收全部富余空间（行数少时下方留白在家具区内部），
--- 否则家具只有 2 行时整个下半部分会上移、底部空出一大片。
---@param shownRows number 实际显示的家具行数
function UIShipCabinDetailView:_RelayoutSections(shownRows)
    local furnitureRoot = self.transform:Find(PATH.FURNITURE_ROOT)
    local crewPanel     = self.transform:Find(PATH.CREW_PANEL)
    if not furnitureRoot then return end

    local fRt = furnitureRoot:GetComponent(typeof(CS.UnityEngine.RectTransform))
    if not fRt then return end

    -- 面板高必须读**实际值**，不能用 PANEL_H 常量：
    -- Canvas 缩放模式改成 ScaleWithScreenSize 后，MainPanel 实测 rect.height≈856，
    -- 与常量差一大截。用常量算出的可用高度偏小，最后一行会溢出到区块外面。
    local panelH = PANEL_H
    local mpNode = self.transform:Find("MainPanel")
    if mpNode then
        local mpRt = mpNode:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if mpRt and mpRt.rect.height > 0 then panelH = mpRt.rect.height end
    end

    -- 船员区：未解锁时整块隐藏（见 RefreshCrewList 的 SetActive(d.unlocked)），
    -- 此时它不占版面，可用高度不能再扣它，否则家具区被压小、最后一行溢出。
    local crewH = 0
    local crewVisible = crewPanel ~= nil and crewPanel.gameObject.activeSelf
    if crewVisible then
        local cRt = crewPanel:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if cRt then
            crewH = cRt.sizeDelta.y
            if crewH <= 0 then crewH = FURNITURE_CREW_H end
            -- 顶部锚定，位置 = -(面板高 - 底栏 - 间距 - 船员高 + 半高)
            local crewTop = panelH - FOOTER_H - SECTION_GAP - crewH
            cRt.anchoredPosition = CS.UnityEngine.Vector2(cRt.anchoredPosition.x,
                -(crewTop + crewH * 0.5))
        end
    end

    -- 船员区可见时才为它留出「区块高 + 一个间距」
    local reserveCrew = crewVisible and (crewH + SECTION_GAP) or 0
    local availH = panelH - FOOTER_H - SECTION_GAP - reserveCrew - FURNITURE_TOP_OFFSET
    if availH < 0 then availH = 0 end

    local rows = math.max(shownRows, 0)
    if rows <= 0 then
        fRt.sizeDelta = CS.UnityEngine.Vector2(fRt.sizeDelta.x, availH)
        fRt.anchoredPosition = CS.UnityEngine.Vector2(fRt.anchoredPosition.x,
            -(FURNITURE_TOP_OFFSET + availH * 0.5))
        return
    end

    -- 每行平分标题以下的空间
    local bodyH  = availH - FURNITURE_TITLE_H - FURNITURE_PAD_BOTTOM
    local gapsH  = (rows - 1) * FURNITURE_ROW_GAP
    local rowH   = (bodyH - gapsH) / rows

    -- 上限：避免行数少时每行高得离谱
    if rowH > FURNITURE_ROW_H_MAX then rowH = FURNITURE_ROW_H_MAX end

    -- 下限只是"期望值"，不能硬套：availH 放不下 rows 行时若强行拉到下限，
    -- 行会按 rowH 铺开却被区块高（min 到 availH）截住 —— 最后一行溢出。
    -- 所以先算出"这么多行在 availH 里最多能有多高"，取两者较小值。
    local maxFit = (bodyH - gapsH) / rows
    if rowH < FURNITURE_ROW_H_MIN then
        rowH = math.min(FURNITURE_ROW_H_MIN, maxFit)
    end
    if rowH < 1 then rowH = 1 end

    -- 行高定下来后，区块高按实际内容算：
    -- 行高被上限夹小时收缩掉富余（底部不留空白）；此时 contentH 必然 <= availH。
    local contentH = FURNITURE_TITLE_H + rows * rowH + gapsH + FURNITURE_PAD_BOTTOM
    local blockH = math.min(contentH, availH)
    fRt.sizeDelta = CS.UnityEngine.Vector2(fRt.sizeDelta.x, blockH)
    fRt.anchoredPosition = CS.UnityEngine.Vector2(fRt.anchoredPosition.x,
        -(FURNITURE_TOP_OFFSET + blockH * 0.5))

    for i = 1, rows do
        local itemNode = self.transform:Find(PATH.FURNITURE_ITEM_PREFIX .. tostring(i))
        if itemNode then
            local iRt = itemNode:GetComponent(typeof(CS.UnityEngine.RectTransform))
            if iRt then
                iRt.sizeDelta = CS.UnityEngine.Vector2(iRt.sizeDelta.x, rowH)
                local top = FURNITURE_TITLE_H + (i - 1) * (rowH + FURNITURE_ROW_GAP)
                iRt.anchoredPosition = CS.UnityEngine.Vector2(iRt.anchoredPosition.x,
                    -(top + rowH * 0.5))
                -- 行高是运行时算出来的（4 行时实测只有 88），prefab 里子节点却是按
                -- 132 的固定偏移摆的 → 必须跟着重排，否则等级文字与进度条会重叠。
                self:_LayoutFurnitureRow(itemNode, rowH)
            end
        end
    end

end

--- 按实际行高重排单行内部（图标底衬 / 名称 / 加成 / 进度条 / 状态按钮）
---
--- 为什么必须有这个函数：prefab 里这些子节点用的是**固定像素偏移**
--- （TxtName 顶部 6、TxtLevel 顶部 48、ProgressBg 底部 14、IconPlate 高 96），
--- 那套数值只在行高 132 时成立。而 `_RelayoutSections` 会按可用高度平分行高，
--- 4 行时 rowH 实测只有 88 —— 此时：
---   TxtLevel 占 48..80，ProgressBg 占 60..74 → **纵向重叠**（文字被进度条压住）
---   IconPlate 高 96 > 行高 88 → 底衬上下溢出卡片
--- 所以行高一变就要重算内部排布，不能只改卡片自身高度。
---
--- 横向分带（行宽 734）：图标 14..14+底衬 | 文字/进度 → 524 | 状态按钮 540..720
---@param itemNode userdata 家具行节点
---@param rowH number 该行实际高度
function UIShipCabinDetailView:_LayoutFurnitureRow(itemNode, rowH)
    if itemNode == nil or rowH == nil or rowH <= 0 then return end

    local function rectOf(name)
        local n = itemNode:Find(name)
        if n == nil then return nil end
        return n:GetComponent(typeof(CS.UnityEngine.RectTransform))
    end
    local function clamp(v, lo, hi)
        if v < lo then return lo elseif v > hi then return hi else return v end
    end

    -- 图标底衬：留 12 上下边距，且不超过原设计的 96
    local plateSize = clamp(rowH - 12, 56, 96)
    local plateRt = rectOf("IconPlate")
    if plateRt then
        plateRt.sizeDelta = CS.UnityEngine.Vector2(plateSize, plateSize)
        plateRt.anchoredPosition = CS.UnityEngine.Vector2(FURNITURE_ROW_PAD_X, 0)
    end
    -- 图标缩在底衬内留 12 内边距（Image 已改 Simple+preserveAspect，非方图不会被拉变形）
    local iconSize = plateSize - 24
    local iconRt = rectOf("ImgIcon")
    if iconRt then
        iconRt.sizeDelta = CS.UnityEngine.Vector2(iconSize, iconSize)
        iconRt.anchoredPosition = CS.UnityEngine.Vector2(
            FURNITURE_ROW_PAD_X + (plateSize - iconSize) * 0.5, 0)
    end

    -- 文字列：左边贴着底衬右侧，右边给状态按钮让位
    local textLeft = FURNITURE_ROW_PAD_X + plateSize + FURNITURE_ROW_ICON_GAP
    local textRightInset = FURNITURE_ROW_PAD_X + FURNITURE_STATUS_W + FURNITURE_ROW_ICON_GAP

    -- 三层竖向排布，全部按行高比例算，保证任何行高下都不重叠
    local padTop     = clamp(rowH * 0.05, 4, 8)
    local nameH      = clamp(rowH * 0.30, 26, 40)
    local levelH     = clamp(rowH * 0.24, 20, 32)
    local progressH  = clamp(rowH * 0.11, 10, 14)
    local progressBot= clamp(rowH * 0.10, 8, 14)

    --- 设置横向拉伸节点的左右内缩（anchorMin.x=0 / anchorMax.x=1 的节点）
    local function setX(rt)
        rt.offsetMin = CS.UnityEngine.Vector2(textLeft, rt.offsetMin.y)
        rt.offsetMax = CS.UnityEngine.Vector2(-textRightInset, rt.offsetMax.y)
    end

    local nameRt = rectOf("TxtName")
    if nameRt then
        nameRt.sizeDelta = CS.UnityEngine.Vector2(nameRt.sizeDelta.x, nameH)
        nameRt.anchoredPosition = CS.UnityEngine.Vector2(nameRt.anchoredPosition.x, -padTop)
        setX(nameRt)
    end

    local levelRt = rectOf("TxtLevel")
    if levelRt then
        levelRt.sizeDelta = CS.UnityEngine.Vector2(levelRt.sizeDelta.x, levelH)
        levelRt.anchoredPosition = CS.UnityEngine.Vector2(levelRt.anchoredPosition.x,
            -(padTop + nameH + 2))
        setX(levelRt)
    end

    local progRt = rectOf("ProgressBg")
    if progRt then
        progRt.sizeDelta = CS.UnityEngine.Vector2(progRt.sizeDelta.x, progressH)
        progRt.anchoredPosition = CS.UnityEngine.Vector2(progRt.anchoredPosition.x, progressBot)
        setX(progRt)
    end

    -- 行高压缩后字号也要跟着收，否则 26 号字塞不进 26px 高的框里（会被裁）
    local function setFontSize(name, size)
        local n = itemNode:Find(name)
        if n == nil then return end
        local t = n:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        if t then t.fontSize = size end
    end
    setFontSize("TxtName",  clamp(rowH * 0.20, 20, 26))
    setFontSize("TxtLevel", clamp(rowH * 0.155, 16, 20))

    -- 状态按钮：高度跟着行高收，宽度保持（倒计时文字最长实测 142，180 放得下）
    local statusRt = rectOf("TxtStatus")
    if statusRt then
        statusRt.sizeDelta = CS.UnityEngine.Vector2(FURNITURE_STATUS_W,
            clamp(rowH - 16, 44, 76))
        statusRt.anchoredPosition = CS.UnityEngine.Vector2(-FURNITURE_ROW_PAD_X, 0)
    end
    setFontSize("TxtStatus/TxtBtnLabel", clamp(rowH * 0.18, 18, 24))
end

--- 刷新单个家具条目
function UIShipCabinDetailView:_RefreshFurnitureItem(itemNode, fData, index)
    -- 图标：prefab 里 ImgIcon 原本只是个灰蓝色块（没人赋过 sprite），
    -- 这里按 buildId + 序号从 FurnitureIconMap 取道具图，未解锁时压暗。
    -- UIImage:LoadSprite 内部按路径去重，重复调同一路径不会重复加载。
    --
    -- 注意：LoadSprite 走 VEngine.Asset.Load，依赖 XAssetPro 资源清单。
    -- 2026-08-20 之前 UISprite 分组的 assets 是空的，整个 Assets/Main/Sprites
    -- 都没进清单 → Asset.Load 返回 null → 静默失败（只有一条
    -- "LoadSprite not found: xxx" 警告）。已给该分组补上目录。
    self.furnitureIcons = self.furnitureIcons or {}
    local iconIdx = index or 1
    if self.furnitureIcons[iconIdx] == nil then
        local iconPath = PATH.FURNITURE_ITEM_PREFIX .. tostring(iconIdx) .. "/ImgIcon"
        self.furnitureIcons[iconIdx] = SafeAddComponent(self, UIImage, iconPath)
    end
    local iconComp = self.furnitureIcons[iconIdx]
    if iconComp then
        -- 传家具名进去：优先按名字关键词选图（"工具箱"→toolbox），
        -- 只按序号轮转的话图标和家具名基本对不上。
        iconComp:LoadSprite(FurnitureIconMap.GetSpritePath(self.buildId or 1, iconIdx, fData.name))
        -- 图标一律保持原色（白 = 不染色）。
        -- 道具图本身是深色带透明背景的小图，配 IconPlate 深色底衬已有足够对比；
        -- 再按未解锁压暗会让图标糊在底衬里看不清，所以未解锁改用底衬变暗表达。
        iconComp:SetColor(CS.UnityEngine.Color(1, 1, 1, 1))
    end

    -- 未解锁时把图标底衬压暗（而不是压暗图标本身）
    self.furniturePlates = self.furniturePlates or {}
    if self.furniturePlates[iconIdx] == nil then
        local platePath = PATH.FURNITURE_ITEM_PREFIX .. tostring(iconIdx) .. "/IconPlate"
        self.furniturePlates[iconIdx] = SafeAddComponent(self, UIImage, platePath)
    end
    local plateComp = self.furniturePlates[iconIdx]
    if plateComp then
        -- 底衬必须比图标**亮**：Props_NoText 那 21 张道具图全是深色线稿
        -- （实测平均亮度 0.281，范围 0.089~0.402）。
        -- 原来用深色底衬（#2C3446 亮度 0.217 / 未解锁 rgb82,89,107 亮度 0.363）
        -- 与图标亮度几乎相同 → 图标糊在底衬里看不清。改成浅底衬后对比差 ~0.5。
        -- 同时底衬要能与白卡片（亮度 0.894）分出层次，所以取中浅调而非纯白。
        if fData.isUnlocked then
            plateComp:SetColor(CS.UnityEngine.Color(0.788, 0.824, 0.886, 1))  -- #C9D2E2
        else
            plateComp:SetColor(CS.UnityEngine.Color(0.659, 0.690, 0.749, 1))  -- 未解锁：压暗一档 #A8B0BF
        end
    end

    -- 名称
    local txtName = itemNode:Find("TxtName")
    if txtName then
        local label = txtName:GetComponent(typeof(CS.UnityEngine.UI.Text))
            or txtName:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        if label then label.text = fData.name or "" end
    end

    -- 家具名下方：显示产出加成（参考图那里是产出数值，不是等级）
    --
    -- 未解锁时参考图的做法是把"需要船舱达到22级"这类**警告写在文字行**、
    -- 按钮仍写"升级"并置灰，而不是让按钮显示"未满足"。这里跟原版对齐：
    -- 条件不足 → 本行显示黄色警告；条件够了但还没解锁 → 显示解锁后能拿到的加成。
    local txtLevel = itemNode:Find("TxtLevel")
    if txtLevel then
        local label = txtLevel:GetComponent(typeof(CS.UnityEngine.UI.Text))
            or txtLevel:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        if label then
            local warn = false
            if fData.isUnlocked then
                -- 已解锁：当前等级加成（productBonus 形如"产出速度+15%"）；
                -- 拿不到时退回等级显示，避免整行空白
                if fData.productBonus ~= nil and fData.productBonus ~= "" then
                    label.text = fData.productBonus
                else
                    label.text = string.format("Lv.%d/%d", fData.level, fData.maxLevel)
                end
            elseif fData.canUnlock then
                -- 条件已满足、待解锁：显示解锁后能拿到的加成，让玩家判断值不值得
                if fData.nextBonus ~= nil and fData.nextBonus ~= "" then
                    label.text = fData.nextBonus
                else
                    label.text = "可解锁"
                end
            else
                -- 条件不足：警告文案（对齐参考图）
                label.text = string.format("需要船舱达到%d级", fData.unlockBuildLevel or 0)
                warn = true
            end
            -- 警告用黄色（原版 ⚠️ 那一档），正常用中性灰蓝
            label.color = warn and Color(0.90, 0.72, 0.30, 1) or Color(0.35, 0.40, 0.47, 1)
        end
    end

    -- 进度条填充（0~1）
    local progressFill = itemNode:Find("ProgressBg/ProgressFill")
    if progressFill then
        local rt = progressFill:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if rt then
            local progress = 0
            if fData.isMax then
                progress = 1
            elseif fData.isUnlocked and fData.maxLevel > 0 then
                progress = fData.level / fData.maxLevel
            end
            rt.anchorMax = CS.UnityEngine.Vector2(progress, 1)
        end
    end

    -- 状态按钮文字
    local txtStatus = itemNode:Find("TxtStatus")
    if txtStatus then
        -- TxtStatus 节点本身就是按钮背景，其下 TxtBtnLabel 是文字
        local lblNode = txtStatus:Find("TxtBtnLabel")
        local label = nil
        if lblNode then
            label = lblNode:GetComponent(typeof(CS.UnityEngine.UI.Text))
                or lblNode:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        end
        if not label then
            label = txtStatus:GetComponent(typeof(CS.UnityEngine.UI.Text))
                or txtStatus:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        end
        -- 按钮三态：可操作=蓝底白字，条件不足/已满级=灰底暗字
        -- 参考原版设计：蓝色恒表示"正常推进"，灰色表示不可操作
        local actionable = fData.isDone or fData.canUpgrade or fData.canUnlock

        if label then
            if fData.isDone then
                label.text = "领取"
            elseif fData.isUpgrading then
                label.text = FormatTime(fData.remainSeconds)
            elseif fData.isMax then
                label.text = "满级"
            elseif fData.canUpgrade then
                label.text = "升级"
            elseif fData.canUnlock then
                label.text = "解锁"
            else
                -- 条件不足时原版仍写"升级"、只是置灰，警告文案放在上方文字行
                -- （见 TxtLevel 分支）。写"未满足"是本项目自创的，与参考图不符。
                label.text = "升级"
            end
            -- 蓝底/灰底上都用白字（灰底稍降透明感，不用暗色否则看不清）
            label.color = actionable and Color(1, 1, 1, 1) or Color(0.88, 0.90, 0.94, 1)
        end

        local btnImg = txtStatus:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if btnImg then
            -- 按钮底图已改为纯白九宫格（Common_bg_white20），颜色必须在这里给足：
            -- 原来可操作态设 Color(1,1,1,1) 是依赖 sprite 自带蓝色，换白图后就变成白按钮了。
            if actionable then
                btnImg.color = Color(0.243, 0.431, 0.545, 1)   -- #3E6E8B 次 CTA 蓝
            else
                btnImg.color = Color(0.55, 0.58, 0.65, 1)      -- 不可操作：灰
            end
        end
    end

    -- 整行点击回调
    local btn = itemNode:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if btn then
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            self:OnClickFurniture(fData)
        end)
    end
end

--- 底部按钮区
function UIShipCabinDetailView:RefreshFooter(d)
    local showCollect = d.isDone
    local showUpgrade = not d.isDone and not d.isMax

    if self.btnCollect then
        self.btnCollect:SetActive(showCollect)
    end
    if self.btnUpgrade then
        self.btnUpgrade:SetActive(showUpgrade)
        if showUpgrade and self.txtBtnUpgrade then
            if not d.unlocked then
                self.txtBtnUpgrade:SetText("解锁")
            elseif d.isUpgrading then
                self.txtBtnUpgrade:SetText("加速")
            else
                self.txtBtnUpgrade:SetText("升级")
            end
        end
    end
end

--- ---------------------------------------------------------------
--- 按钮回调
--- ---------------------------------------------------------------

function UIShipCabinDetailView:OnClickUpgrade()
    if not self.buildId then return end
    self.ctrl:OpenUpgradePanel(self.buildId)
end

function UIShipCabinDetailView:OnClickCollect()
    if not self.buildId then return end
    local buildData = self.ctrl:GetBuildingData(self.buildId)
    if not buildData or not buildData:IsDone() then return end
    local ok, errMsg = DataCenter.ShipPlayerDataManager:CollectBuildingResult(buildData.uuid)
    if not ok then
        Logger.LogWarning("[UIShipCabinDetailView] CollectBuilding 失败: " .. tostring(errMsg))
    end
end

function UIShipCabinDetailView:OnClickFurniture(fData)
    if fData.isDone then
        self.ctrl:CollectFurniture(fData.uuid)
    elseif fData.canUnlock then
        self.ctrl:UnlockFurniture(fData.furnitureId, self.buildId)
    elseif fData.canUpgrade then
        self.ctrl:UpgradeFurniture(fData.furnitureId)
    elseif fData.isUpgrading then
        UIUtil.ShowTips(string.format("%s 升级中，剩余 %s", fData.name, FormatTime(fData.remainSeconds)))
    elseif fData.isMax then
        UIUtil.ShowTips(fData.name .. " 已满级")
    else
        UIUtil.ShowTips(string.format("%s 需要建筑达到 Lv.%d", fData.name, fData.unlockBuildLevel))
    end
end

--- ---------------------------------------------------------------
--- 事件监听
--- ---------------------------------------------------------------

function UIShipCabinDetailView:OnBuildingStateChanged(data)
    if not self.buildId then return end
    local buildId = data and data.buildId
    if buildId == self.buildId then self:Refresh() end
end

function UIShipCabinDetailView:OnFurnitureChanged(data)
    if not self.buildId then return end
    self:Refresh()
end

--- ---------------------------------------------------------------
--- 倒计时
--- ---------------------------------------------------------------

function UIShipCabinDetailView:_StartCountdownTimer()
    if self.countdownTimer then return end
    self.countdownTimer = TimerManager:GetInstance():GetTimer(
        1, self._OnCountdownTick, self, false, false, false)
    self.countdownTimer:Start()
end

function UIShipCabinDetailView:_StopCountdownTimer()
    if self.countdownTimer then
        self.countdownTimer:Stop()
        self.countdownTimer = nil
    end
    -- 延迟重排的定时器也要一起清，否则面板销毁后回调仍会触发
    if self._relayoutTimer then
        self._relayoutTimer:Stop()
        self._relayoutTimer = nil
    end
end

function UIShipCabinDetailView:_OnCountdownTick()
    if not self.buildId then return end
    local buildData = self.ctrl:GetBuildingData(self.buildId)
    if not buildData then return end
    if buildData:IsUpgrading() or buildData:IsUnlocking() then
        -- 只刷新倒计时文字，避免全量刷新闪烁
        self:RefreshDataRow(self.detail)
    else
        self:Refresh()
    end
end

--- ---------------------------------------------------------------
--- 关闭
--- ---------------------------------------------------------------

function UIShipCabinDetailView:CloseSelf()
    local animator = self.transform:GetComponent(typeof(CS.ShipCabinDetailAnimator))
    if animator then
        animator:HideWithCallback(function()
            UIManager:GetInstance():DestroyWindow(UIWindowNames.UIShipCabinDetail)
        end)
    else
        UIManager:GetInstance():DestroyWindow(UIWindowNames.UIShipCabinDetail)
    end
end

return UIShipCabinDetailView
