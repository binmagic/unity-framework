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

--- 2026-08-26 按隆隆冒险号原版重做版式，节点路径随之改变：
---   标题栏拆成「舱室名」+「N级」两行（原版标题居中、等级另起一行）
---   新增「── 升级效果 ──」「── 所需条件 ──」两个分节标题
---   前置条件不再单独一行，与资源统一用 CostItem_N 模板（图标|名称|当前/需求|✓✗）
---   底部改为原版双按钮：立即完成(橙,付费) + 升级(蓝)，取消由右上 × 承担
local PATH = {
    BTN_CLOSE       = BG .. "Header/BtnClose",

    -- 底部双按钮
    BTN_INSTANT     = BG .. "Footer/BtnInstant",
    TXT_BTN_INSTANT = BG .. "Footer/BtnInstant/TxtLabel",
    TXT_SUB_INSTANT = BG .. "Footer/BtnInstant/TxtSub",
    BTN_CONFIRM     = BG .. "Footer/BtnConfirm",
    TXT_BTN_CONFIRM = BG .. "Footer/BtnConfirm/TxtLabel",
    TXT_SUB_CONFIRM = BG .. "Footer/BtnConfirm/TxtSub",

    -- 标题栏
    TXT_TITLE       = BG .. "Header/TxtTitle",
    TXT_LEVEL       = BG .. "Header/TxtLevel",

    -- 升级效果
    TXT_EFF_NAME    = BG .. "EffectRow/TxtEffName",
    TXT_EFF_VALUE   = BG .. "EffectRow/TxtEffValue",

    -- 条件列表（前置建筑 + 资源共用），子节点 CostItem_1..5
    COST_ROOT       = BG .. "CostRoot",
    COST_ITEM_PREFIX = BG .. "CostRoot/CostItem_",

    -- 所需时间
    TXT_TIME        = BG .. "TxtTime",
}

--- 资源 itemId → 图标路径（原版每行条件左侧都有图标）
local RESOURCE_ICON = {
    [102001] = "Assets/Main/Sprites/ItemIcons/Common_icon_foodbox01.png",   -- 食材
    [102002] = "Assets/Main/Sprites/ItemIcons/Common_icon_metal.png",       -- 金属
    [102003] = "Assets/Main/Sprites/ItemIcons/Common_icon_electricity.png", -- 电力
    [102004] = "Assets/Main/Sprites/ItemIcons/Common_icon_oil.png",         -- 有机质
    [102005] = "Assets/Main/Sprites/ItemIcons/Common_icon_chip2.png",       -- 科技点
}
--- 前置建筑行用的图标
local PREREQ_ICON = "Assets/Main/Sprites/UIShipCabinClean/UI_Icons_Only/side_build.png"

--- 格式化大数值（原版是「1亿 / 2906.2万」这种紧凑写法）
local function FormatNumber(num)
    num = tonumber(num) or 0
    if num >= 100000000 then
        return string.format("%.1f亿", num / 100000000)
    elseif num >= 10000 then
        return string.format("%.1f万", num / 10000)
    else
        return tostring(math.floor(num))
    end
end

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

    -- 「立即完成」= 花钻石抹掉倒计时（未开始时先发起再抹）
    self.btnInstant = SafeAddComponent(self, UIButton, PATH.BTN_INSTANT)
    if self.btnInstant then
        self.btnInstant:SetOnClick(function() self:OnClickInstant() end)
    end

    self.btnConfirm = SafeAddComponent(self, UIButton, PATH.BTN_CONFIRM)
    if self.btnConfirm then
        self.btnConfirm:SetOnClick(function() self:OnClickConfirm() end)
    end

    self.txtBtnConfirm = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_BTN_CONFIRM)
    self.txtSubConfirm = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_SUB_CONFIRM)
    self.txtSubInstant = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_SUB_INSTANT)
    self.txtTitle      = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_TITLE)
    self.txtLevel      = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_LEVEL)
    self.txtTime       = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_TIME)
    self.txtEffName    = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_EFF_NAME)
    self.txtEffValue   = SafeAddComponent(self, UITextMeshProUGUIEx, PATH.TXT_EFF_VALUE)
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

    -- 标题栏：原版是「舱室名」居中 + 「N级」另起一行，不是拼成一行
    if self.txtTitle then
        self.txtTitle:SetText(d.cfg.name or "")
    end
    if self.txtLevel then
        if not d.unlocked then
            self.txtLevel:SetText("待解锁")
        elseif d.isMax then
            self.txtLevel:SetText(string.format("%d级（已满级）", d.curLevel or 0))
        else
            self.txtLevel:SetText(string.format("%d级 → %d级", d.curLevel or 0, d.nextLevel or 0))
        end
    end

    -- 所需时间（原版是右对齐小字「初始时间：4天7小时」）
    if self.txtTime then
        self.txtTime:SetText("所需时间：" .. FormatTime(d.upgradeTime))
    end

    -- 升级效果：战力变化。项目战力系统尚未接入，按用户要求显示为占位。
    self:_RefreshEffect(d)

    -- 条件列表（前置建筑 + 资源统一用 CostItem_N 模板）
    self:_RefreshCostList(d)

    -- 底部按钮
    self:_RefreshConfirmBtn(d)
end

--- 刷新「升级效果」行
--- 原版是「战力 +253500 ⟹ +293500」，箭头与新值用绿色。
--- 本项目战力系统未接入，Ctrl 虽已从 lvup_effect 解析出 power，
--- 但没有「当前战力」的来源，无法算出变化量，故显示占位。
function UIBuildingPanelView:_RefreshEffect(d)
    if self.txtEffName then self.txtEffName:SetText("战力") end
    if not self.txtEffValue then return end

    local nextPower = d.nextLevelCfg and d.nextLevelCfg.power or 0
    if nextPower and nextPower > 0 then
        -- 拿得到目标战力时至少显示它，仍标注待接入
        self.txtEffValue:SetText(string.format("<color=#8C99B5>待接入</color>  +%s", FormatNumber(nextPower)))
    else
        self.txtEffValue:SetText("<color=#8C99B5>待接入</color>")
    end
end

--- 拼出前置条件的描述文字（原版第一行就是「轮机组 22级 ✓」这种）
local function BuildPrereqText(cfg)
    local condType = cfg.lvup_cond_type or 0
    if condType == 2 then
        local bid     = tonumber(cfg.lvup_require1)
        local preName = bid and (GetTableData(TableName.Building_Config, bid, "name") or tostring(bid)) or ""
        return preName, "需完成"
    elseif condType == 3 then
        return "玩家等级", string.format("%d级", cfg.lvup_require1_unlock or 0)
    elseif condType == 4 then
        local bid     = tonumber(cfg.lvup_require1)
        local preName = bid and (GetTableData(TableName.Building_Config, bid, "name") or tostring(bid)) or ""
        return preName, string.format("%d级", cfg.lvup_require1_unlock or 0)
    elseif condType == 5 then
        return "物品", tostring(cfg.lvup_require1 or "")
    elseif condType == 6 then
        return "英雄", tostring(cfg.lvup_require1 or "")
    elseif condType == 7 then
        return "科技", tostring(cfg.lvup_require1 or "")
    end
    return nil, nil
end

--- 刷新条件列表
---
--- 原版「所需条件」是**统一模板的多行**：前置建筑和各资源用同一种行样式
--- （图标 | 名称 | 当前/需求 | ✓✗），而不是前置单独一行、资源另做一套。
--- 所以这里把前置条件也塞进 CostItem_N 序列，排在资源之前。
function UIBuildingPanelView:_RefreshCostList(d)
    local costRoot = self.transform:Find(PATH.COST_ROOT)
    if not costRoot then return end

    -- 组装成统一的行数据：{icon=路径, name=名称, value=右侧文字, ok=是否满足}
    local rows = {}

    -- 1) 前置条件（有才加）
    if d.nextLevelCfg then
        local pName, pValue = BuildPrereqText(d.nextLevelCfg)
        if pName and pName ~= "" then
            table.insert(rows, {
                icon  = PREREQ_ICON,
                name  = pName,
                value = pValue,
                ok    = (d.condOk == true),
            })
        end
    end

    -- 2) 资源消耗
    local costList = {}
    if d.nextLevelCfg and d.nextLevelCfg.costList then
        costList = d.nextLevelCfg.costList
    elseif not d.unlocked then
        -- 解锁时用第1级费用
        local lv1 = self.ctrl:GetLv1Config(d.buildId)
        if lv1 then costList = lv1.costList or {} end
    end
    for _, cost in ipairs(costList) do
        local owned = DataCenter.ShipPlayerDataManager:GetResourceCount(cost.itemId)
        table.insert(rows, {
            icon  = RESOURCE_ICON[cost.itemId],
            name  = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId),
            -- 原版是「1亿/2906.2万」这种紧凑写法，不是裸数字
            value = string.format("%s/%s", FormatNumber(owned), FormatNumber(cost.count)),
            ok    = (owned >= cost.count),
        })
    end

    -- 逐行填充
    for i, row in ipairs(rows) do
        local itemNode = self.transform:Find(PATH.COST_ITEM_PREFIX .. tostring(i))
        if itemNode then
            itemNode.gameObject:SetActive(true)

            local iconNode = itemNode:Find("ImgIcon")
            if iconNode then
                local iconComp = self:AddComponent(UIImage, PATH.COST_ITEM_PREFIX .. tostring(i) .. "/ImgIcon")
                if iconComp and row.icon then
                    iconComp:LoadSprite(row.icon)
                end
                iconNode.gameObject:SetActive(row.icon ~= nil)
            end

            local txtName = itemNode:Find("TxtName")
            if txtName then
                local label = txtName:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
                if label then label.text = row.name end
            end

            local txtAmount = itemNode:Find("TxtAmount")
            if txtAmount then
                local label = txtAmount:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
                if label then
                    label.text = row.value
                    -- 不足才标红；满足时用中性灰蓝，让右侧的 ✓ 承担"通过"的表达
                    label.color = row.ok
                        and CS.UnityEngine.Color(0.353, 0.40, 0.471, 1)
                        or  CS.UnityEngine.Color(0.85, 0.35, 0.32, 1)
                end
            end

            -- 原版用 ✓ / ✗ 表示每条是否满足
            local imgOk   = itemNode:Find("ImgOk")
            local imgFail = itemNode:Find("ImgFail")
            if imgOk   then imgOk.gameObject:SetActive(row.ok) end
            if imgFail then imgFail.gameObject:SetActive(not row.ok) end
        end
    end

    -- 隐藏多余的行
    local i = #rows + 1
    while true do
        local node = self.transform:Find(PATH.COST_ITEM_PREFIX .. tostring(i))
        if not node then break end
        node.gameObject:SetActive(false)
        i = i + 1
    end
end

--- 刷新底部双按钮
---
--- 原版底部是「立即完成 💎14,791」(橙) + 「升级 ⏱2天5小时」(蓝)：
--- 主文字是动作、副文字是代价（钻石数 / 耗时），橙蓝对立表达"花钱"与"正常推进"。
function UIBuildingPanelView:_RefreshConfirmBtn(d)
    if not self.btnConfirm then return end

    -- isDone（待领取）必须算进来：漏掉它会让按钮不灰、文案还写"升级"，
    -- 点下去却被 OnClickConfirm 的 IsBusy() 拦掉 —— 玩家看到的就是"点了没反应"
    local canDo = d.canOperate and not d.isMax and not d.isUpgrading and not d.isDone

    -- 第 3 参是 canClick，它直接决定 `Button.enabled`（UIGray.cs:155）。
    -- 这里恒传 true：Button 一旦 enabled=false，UIButton 绑的原生 onClick
    -- （UIButton.lua:95）压根不触发，连 OnClickConfirm 里的拒绝提示都执行不到，
    -- 于是不能操作的原因永远传不到玩家眼前。
    -- 灰色只负责"看起来不可用"，能不能做由 OnClickConfirm 判定并给出具体原因。
    UIGray.SetGray(self.btnConfirm.transform, not canDo, true)

    -- 蓝按钮：主文字=动作，副文字=耗时
    if self.txtBtnConfirm then
        if d.isUpgrading then
            self.txtBtnConfirm:SetText("升级中")
        elseif d.isDone then
            self.txtBtnConfirm:SetText("待领取")
        elseif d.isMax then
            self.txtBtnConfirm:SetText("已满级")
        elseif not d.unlocked then
            self.txtBtnConfirm:SetText("解锁")
        else
            self.txtBtnConfirm:SetText("升级")
        end
    end
    if self.txtSubConfirm then
        if d.isMax then
            self.txtSubConfirm:SetText("")
        else
            -- 不要用 ⏱ 之类符号：NotoSansSC 源字体没有这些字形，
            -- TryAddCharacters 也加不进来，只会显示成方块（实测 U+23F1/U+1F48E/U+2713 全缺）
            self.txtSubConfirm:SetText(FormatTime(d.upgradeTime))
        end
    end

    -- 橙按钮：满级、待领取、以及耗时为 0（无需加速）时都没有意义，整个隐藏
    local instantCost = self.ctrl.GetInstantDiamond and self.ctrl:GetInstantDiamond(d) or 0
    local showInstant = not d.isMax and not d.isDone and instantCost > 0
    local instantNode = self.transform:Find(PATH.BTN_INSTANT)
    if instantNode then
        instantNode.gameObject:SetActive(showInstant)
    end
    if self.txtSubInstant and showInstant then
        -- 不写 💎 之类符号：NotoSansSC 缺这些字形，只会显示成方块（见上方注释）
        self.txtSubInstant:SetText("钻石 " .. FormatNumber(instantCost))
    end

    -- 只剩一个按钮时让它占满整行，避免右半边空着
    -- 判据是「橙按钮是否显示」，不是「是否满级」：
    -- 耗时为 0 的升级也会隐藏橙按钮，那时同样要让蓝按钮占满整行。
    local confirmNode = self.transform:Find(PATH.BTN_CONFIRM)
    if confirmNode then
        local rt = confirmNode:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if rt then
            if not showInstant then
                rt.anchorMin = CS.UnityEngine.Vector2(0, 0)
                rt.offsetMin = CS.UnityEngine.Vector2(0, 0)
            else
                rt.anchorMin = CS.UnityEngine.Vector2(0.5, 0)
                rt.offsetMin = CS.UnityEngine.Vector2(8, 0)
            end
        end
    end
end

--- ---------------------------------------------------------------
--- 按钮回调
--- ---------------------------------------------------------------

--- 点确认：真正执行扣消耗 + 开始升级/解锁
---
--- 每条拒绝分支都必须给 Tips。只写 Logger 的话玩家看到的就是"点了没反应"——
--- 日志只有开发能看见，而这些拒绝（待领取、条件不足、资源不够）全是玩家能自己解决的。
function UIBuildingPanelView:OnClickConfirm()
    local d = self.detail
    if not d or not d.buildId then return end

    -- 点确认时从 DataManager 拉最新建筑状态，避免弹窗打开后状态已变
    local buildData = DataCenter.ShipPlayerDataManager:GetMaxLevelBuilding(d.buildId)
    if buildData and buildData:IsBusy() then
        -- IsBusy 覆盖升级中/解锁中/待领取三态，逐一给出玩家能看懂的原因。
        -- 这里必须分开说：待领取是"去领取"，升级中是"等倒计时"，处置方式完全不同。
        local doneType = buildData:GetDoneType()
        local msg
        if buildData:IsDone() then
            msg = (doneType == "unlock") and "解锁已完成，请先领取" or "升级已完成，请先领取"
        elseif buildData:IsUnlocking() then
            msg = "正在解锁中，请等待完成"
        else
            msg = "正在升级中，请等待完成"
        end
        UIUtil.ShowTips(msg)
        Logger.LogWarning(string.format("[UIBuildingPanelView] OnClickConfirm 拒绝: 建筑忙碌 state=%s doneType=%s",
            tostring(buildData.state), tostring(doneType)))
        return
    end

    if d.isMax then
        UIUtil.ShowTips("已达到最高等级")
        Logger.LogWarning("[UIBuildingPanelView] OnClickConfirm 拒绝: 已满级")
        return
    end
    if not d.canOperate then
        -- condDesc 是 CheckCondition 给出的具体原因（"需要【轮机组】达到 8 级"这类），
        -- 有它就直接用，别退回笼统文案
        local msg
        if d.condOk == false then
            msg = (d.condDesc ~= nil and d.condDesc ~= "") and d.condDesc or "前置条件不满足"
        else
            msg = "资源不足"
        end
        UIUtil.ShowTips(msg)
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
        UIUtil.ShowTips(err or "操作失败")
        Logger.LogWarning("[UIBuildingPanelView] DoConfirm 失败: " .. tostring(err))
    end
end

--- 点立即完成：花钻石抹掉倒计时
--- 失败原因（钻石不足 / 前置不满足）要用 Tips 告诉玩家，
--- 只写日志的话按钮点下去像没反应。
function UIBuildingPanelView:OnClickInstant()
    local d = self.detail
    if not d or not d.buildId then return end

    local ok, err, cost = self.ctrl:DoInstantFinish(d)
    if ok then
        if cost and cost > 0 then
            UIUtil.ShowTips(string.format("已花费 %s 钻石立即完成", FormatNumber(cost)))
        end
        self:CloseSelf()
    else
        UIUtil.ShowTips(err or "无法立即完成")
        Logger.LogWarning("[UIBuildingPanelView] DoInstantFinish 失败: " .. tostring(err))
    end
end

return UIBuildingPanelView
