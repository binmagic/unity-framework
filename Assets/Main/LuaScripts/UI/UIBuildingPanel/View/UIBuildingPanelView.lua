--- 建筑升级/解锁 确认弹窗 — View
--- 交互：
---   打开时展示：建筑名+目标等级、所需资源（拥有量/需要量）、所需时间
---   点「确认」→ Ctrl 执行真正的扣消耗+开始升级/解锁
---   点「取消」→ 关闭弹窗
--- 节点不存在时静默跳过，Prefab 补充节点后自动生效
---@class UIBuildingPanelView : UIBaseView
local UIBuildingPanelView = BaseClass("UIBuildingPanelView", UIBaseView)
local base = UIBaseView
local UIGray = CS.UIGray

local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

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

local RESOURCE_NAME = {
    [102001] = "食材",
    [102002] = "金属",
    [102003] = "电力",
    [102004] = "有机质",
    [102005] = "科技点",
}

--- 节点路径
--- 内容节点都在 BgPanel（700x900 居中卡片）下。
--- 它们原本挂在全屏根节点上，锚点 (0.5,1)/(0.5,0) 相对的是全屏，
--- 于是全部跑到卡片外面（标题/费用列表飘到屏幕上方、按钮贴屏幕底）。
--- 2026-08-04 把它们 reparent 进 BgPanel，路径也随之加前缀。
local BG = "BgPanel/"

local PATH = {
    BTN_CLOSE       = BG .. "BtnClose",
    BTN_CANCEL      = BG .. "Footer/BtnCancel",
    BTN_CONFIRM     = BG .. "Footer/BtnConfirm",
    TXT_BTN_CONFIRM = BG .. "Footer/BtnConfirm/TxtLabel",

    -- 标题：「食材仓库 升至7级」
    TXT_TITLE       = BG .. "Header/TxtTitle",
    -- 所需时间
    TXT_TIME        = BG .. "Header/TxtTime",

    -- 资源列表容器，子节点 CostItem_1 / CostItem_2 ...
    COST_ROOT       = BG .. "CostRoot",
    COST_ITEM_PREFIX = BG .. "CostRoot/CostItem_",

    -- 前置条件行（有前置时显示）
    PREREQ_ROW      = BG .. "PrereqRow",
    TXT_PREREQ      = BG .. "PrereqRow/TxtName",
    IMG_PREREQ_OK   = BG .. "PrereqRow/ImgOk",
    IMG_PREREQ_FAIL = BG .. "PrereqRow/ImgFail",
}

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function UIBuildingPanelView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function UIBuildingPanelView:OnEnable()
    base.OnEnable(self)
    -- detail 由 UIShipBackgroundCtrl:OpenBuildingPanel 通过 OpenWindow 第二参数传入
    local detail = self:GetUserData()
    self.detail  = detail or {}
    Logger.Log(string.format("[UIBuildingPanelView] OnEnable buildId=%s unlocked=%s isDone=%s isUpgrading=%s canOperate=%s",
        tostring(self.detail.buildId), tostring(self.detail.unlocked), tostring(self.detail.isDone),
        tostring(self.detail.isUpgrading), tostring(self.detail.canOperate)))
    self:Refresh()
end

function UIBuildingPanelView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

--- ---------------------------------------------------------------
--- 组件绑定
--- ---------------------------------------------------------------

function UIBuildingPanelView:ComponentDefine()
    self.btnClose = SafeAddComponent(self, UIButton, PATH.BTN_CLOSE)
    if self.btnClose then
        self.btnClose:SetOnClick(function() self:CloseSelf() end)
    end

    self.btnCancel = SafeAddComponent(self, UIButton, PATH.BTN_CANCEL)
    if self.btnCancel then
        self.btnCancel:SetOnClick(function() self:CloseSelf() end)
    end

    self.btnConfirm = SafeAddComponent(self, UIButton, PATH.BTN_CONFIRM)
    if self.btnConfirm then
        self.btnConfirm:SetOnClick(function() self:OnClickConfirm() end)
    end

    self.txtBtnConfirm = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_BTN_CONFIRM)
    self.txtTitle      = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_TITLE)
    self.txtTime       = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_TIME)
    self.txtPrereq     = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_PREREQ)
    self.imgPrereqOk   = self.transform:Find(PATH.IMG_PREREQ_OK)
    self.imgPrereqFail = self.transform:Find(PATH.IMG_PREREQ_FAIL)
end

--- ---------------------------------------------------------------
--- 数据
--- ---------------------------------------------------------------

function UIBuildingPanelView:DataDefine()
    self.detail = {}
end

function UIBuildingPanelView:DataDestroy()
    self.detail = nil
end

--- ---------------------------------------------------------------
--- 刷新
--- ---------------------------------------------------------------

function UIBuildingPanelView:Refresh()
    local d = self.detail
    if not d or not d.buildId then return end

    -- 标题：「食材仓库  升至7级」 / 「食材仓库  解锁」
    if self.txtTitle then
        local actionStr
        if not d.unlocked then
            actionStr = "解锁"
        elseif d.isMax then
            actionStr = "已满级"
        else
            actionStr = string.format("升至%d级", d.nextLevel)
        end
        self.txtTitle:SetText(string.format("%s  %s", d.cfg.name, actionStr))
    end

    -- 所需时间
    if self.txtTime then
        self.txtTime:SetText("所需时间：" .. FormatTime(d.upgradeTime))
    end

    -- 前置条件行
    local prereqRow = self.transform:Find(PATH.PREREQ_ROW)
    if prereqRow then
        local hasPrereq = (d.condOk ~= nil) and (not d.condOk or
            (d.nextLevelCfg and d.nextLevelCfg.lvup_require1 ~= ""))
        prereqRow.gameObject:SetActive(hasPrereq == true)
        if hasPrereq then
            if self.txtPrereq and d.nextLevelCfg then
                local cfg      = d.nextLevelCfg
                local condType = cfg.lvup_cond_type or 0
                local prereqText = ""
                if condType == 2 then
                    -- 建筑完成
                    local bid     = tonumber(cfg.lvup_require1)
                    local preName = bid and (GetTableData(TableName.Building_Config, bid, "name") or tostring(bid)) or ""
                    prereqText = string.format("需要完成【%s】", preName)
                elseif condType == 3 then
                    prereqText = string.format("玩家等级 %d 级", cfg.lvup_require1_unlock or 0)
                elseif condType == 4 then
                    -- 建筑等级
                    local bid     = tonumber(cfg.lvup_require1)
                    local preName = bid and (GetTableData(TableName.Building_Config, bid, "name") or tostring(bid)) or ""
                    prereqText = string.format("%s  %d级", preName, cfg.lvup_require1_unlock or 0)
                elseif condType == 5 then
                    prereqText = string.format("需要持有物品 %s", cfg.lvup_require1 or "")
                elseif condType == 6 then
                    prereqText = string.format("需要英雄 %s", cfg.lvup_require1 or "")
                elseif condType == 7 then
                    prereqText = string.format("需要完成科技 %s", cfg.lvup_require1 or "")
                end
                self.txtPrereq:SetText(prereqText)
            end
            if self.imgPrereqOk   then self.imgPrereqOk.gameObject:SetActive(d.condOk == true) end
            if self.imgPrereqFail then self.imgPrereqFail.gameObject:SetActive(not d.condOk) end
        end
    end

    -- 资源消耗列表
    self:_RefreshCostList(d)

    -- 确认按钮
    self:_RefreshConfirmBtn(d)
end

--- 刷新资源消耗列表
function UIBuildingPanelView:_RefreshCostList(d)
    local costRoot = self.transform:Find(PATH.COST_ROOT)
    if not costRoot then return end

    local costList = {}
    if d.nextLevelCfg and d.nextLevelCfg.costList then
        costList = d.nextLevelCfg.costList
    elseif not d.unlocked then
        -- 解锁时用第1级费用
        local lv1 = self.ctrl:GetLv1Config(d.buildId)
        if lv1 then costList = lv1.costList or {} end
    end

    for i, cost in ipairs(costList) do
        local itemPath = PATH.COST_ITEM_PREFIX .. tostring(i)
        local itemNode = self.transform:Find(itemPath)
        if itemNode then
            -- 资源名
            local txtName = itemNode:Find("TxtName")
            if txtName then
                local label = txtName:GetComponent(typeof(CS.UnityEngine.UI.Text))
                if label then
                    label.text = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                end
            end
            -- 拥有量 / 需要量
            local txtAmount = itemNode:Find("TxtAmount")
            if txtAmount then
                local label = txtAmount:GetComponent(typeof(CS.UnityEngine.UI.Text))
                if label then
                    local owned = DataCenter.ShipPlayerDataManager:GetResourceCount(cost.itemId)
                    local enough = owned >= cost.count
                    label.text  = string.format("%d / %d", owned, cost.count)
                    label.color = enough
                        and CS.UnityEngine.Color(0.2, 0.9, 0.2, 1)
                        or  CS.UnityEngine.Color(0.9, 0.2, 0.2, 1)
                end
            end
        end
    end

    -- 隐藏多余的 CostItem 节点
    local i = #costList + 1
    while true do
        local node = self.transform:Find(PATH.COST_ITEM_PREFIX .. tostring(i))
        if not node then break end
        node.gameObject:SetActive(false)
        i = i + 1
    end
end

--- 刷新确认按钮文字和灰化状态
function UIBuildingPanelView:_RefreshConfirmBtn(d)
    if not self.btnConfirm then return end

    local canDo = d.canOperate and not d.isMax and not d.isUpgrading

    UIGray.SetGray(self.btnConfirm.transform, not canDo, canDo)

    if self.txtBtnConfirm then
        if d.isUpgrading then
            self.txtBtnConfirm:SetText("升级中...")
        elseif d.isMax then
            self.txtBtnConfirm:SetText("已满级")
        elseif not d.unlocked then
            self.txtBtnConfirm:SetText("确认解锁")
        else
            self.txtBtnConfirm:SetText("确认升级")
        end
    end
end

--- ---------------------------------------------------------------
--- 按钮回调
--- ---------------------------------------------------------------

--- 点确认：真正执行扣消耗 + 开始升级/解锁
function UIBuildingPanelView:OnClickConfirm()
    local d = self.detail
    if not d or not d.buildId then return end

    -- 点确认时从 DataManager 拉最新建筑状态，避免弹窗打开后状态已变
    local buildData = DataCenter.ShipPlayerDataManager:GetMaxLevelBuilding(d.buildId)
    if buildData then
        if buildData:IsBusy() then
            Logger.LogWarning(string.format("[UIBuildingPanelView] OnClickConfirm 拒绝: 建筑忙碌 state=%d", buildData.state))
            return
        end
    end

    if d.isMax then
        Logger.LogWarning("[UIBuildingPanelView] OnClickConfirm 拒绝: 已满级")
        return
    end
    if not d.canOperate then
        Logger.LogWarning(string.format("[UIBuildingPanelView] OnClickConfirm 拒绝: canOperate=false condOk=%s resEnough=%s",
            tostring(d.condOk), tostring(d.resEnough)))
        return
    end

    Logger.Log(string.format("[UIBuildingPanelView] OnClickConfirm buildId=%d unlocked=%s nextLevel=%d upgradeTime=%ds",
        d.buildId, tostring(d.unlocked), d.nextLevel or 0, d.upgradeTime or 0))

    local ok, err = self.ctrl:DoConfirm(d)
    if ok then
        self:CloseSelf()
    else
        Logger.LogWarning("[UIBuildingPanelView] DoConfirm 失败: " .. tostring(err))
    end
end

return UIBuildingPanelView
