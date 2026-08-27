---
--- 隆隆冒险号 船舱主界面 — Controller
--- 船体剖面布局：多个房间(舱室)，点击房间打开详情面板
--- 数据层复用 DataCenter.ShipPlayerDataManager
--- 顶部资源栏、底部进度条数据也由此提供
---@class UIShipCabinCtrl : UIBaseCtrl
local UIShipCabinCtrl = BaseClass("UIShipCabinCtrl", UIBaseCtrl)

--- 资源栏展示的资源ID
--- 参考原版：6 项资源两行紧凑排布（见 knowledge/codebase/longlong-ui-design-reference.md）
local TOP_RESOURCE_IDS = {
    102001, -- 食材
    102002, -- 金属
    102003, -- 电力
    102004, -- 有机质
    102005, -- 科技点
    102006, -- 晶体（若配置表无此项，GetResourceCount 返回 0，显示 0 不报错）
}

local RESOURCE_NAME = {
    [102001] = "食材",
    [102002] = "金属",
    [102003] = "电力",
    [102004] = "有机质",
    [102005] = "科技点",
    [102006] = "晶体",
}

--- 资源ID → 图标 sprite 名（ItemIcons 目录下的通用资源图标）
local RESOURCE_ICON = {
    [102001] = "Common_icon_foodbox01",
    [102002] = "Common_icon_metal",
    [102003] = "Common_icon_electricity",
    [102004] = "Common_icon_oil",
    [102005] = "Common_icon_chip2",
    [102006] = "Common_icon_glass",
}

--- ---------------------------------------------------------------
--- 房间(舱室)列表
--- ---------------------------------------------------------------

--- 获取所有舱室房间数据（船体剖面上的每个房间）
--- 返回 { { buildId, name, level, unlocked, isUpgrading, isDone, remainSeconds, totalSeconds }, ... }
--- 说明：产出资源由 ShipPlayerDataManager:_TickProduction 按 cdAccum 直接入账，
--- 不存在"产出待领取"状态，因此这里不再返回 hasProduct/canCollect。
--- isDone 表示的是升级/解锁完成待领取（ShipBuildingState.Done）。
--- totalSeconds 为本次升级/解锁的总时长（updateTime - startTime），供进度条计算用。
function UIShipCabinCtrl:GetRoomList()
    local mgr = DataCenter.ShipPlayerDataManager
    if not mgr then return {} end

    local buildIdList = mgr:GetAllBuildIdList()
    local result = {}

    for _, buildId in ipairs(buildIdList) do
        local buildData = mgr:GetMaxLevelBuilding(buildId)
        local unlocked  = mgr:IsBuildingUnlocked(buildId)
        local level     = mgr:GetMaxBuildingLevel(buildId)
        local name      = GetTableData(TableName.Building_Config, buildId, "name") or ""

        local isUpgrading = buildData and (buildData:IsUpgrading() or buildData:IsUnlocking()) or false
        local isDone      = buildData and buildData:IsDone() or false

        -- 本次升级/解锁总时长，供进度条算百分比；未在进行时为 0
        local totalSeconds = 0
        if buildData and isUpgrading
            and buildData.updateTime > 0 and buildData.startTime > 0 then
            totalSeconds = buildData.updateTime - buildData.startTime
            if totalSeconds < 0 then totalSeconds = 0 end
        end

        table.insert(result, {
            buildId       = buildId,
            name          = name,
            level         = level,
            unlocked      = unlocked,
            isUpgrading   = isUpgrading,
            isDone        = isDone,
            remainSeconds = buildData and buildData:GetRemainSeconds() or 0,
            totalSeconds  = totalSeconds,
            power         = buildData and buildData.power or 0,
        })
    end

    return result
end

--- 惰性拿一个 UIShipBackgroundCtrl 实例并缓存
--- 刷新 37 个格子时每格都会查解锁条件，不缓存的话每次 require+New 会造 37 个实例
function UIShipCabinCtrl:_GetBgCtrl()
    if self._bgCtrl ~= nil then return self._bgCtrl end
    local ok, cls = pcall(require, "UI.UIShipBackground.Controller.UIShipBackgroundCtrl")
    if not ok or cls == nil then
        Logger.LogWarning(string.format(
            "UIShipCabinCtrl require UIShipBackgroundCtrl失败 err=%s", tostring(cls)))
        return nil
    end
    self._bgCtrl = cls.New()
    return self._bgCtrl
end

--- 查询某舱室的解锁条件（前置条件 + 资源）
--- 复用 UIShipBackgroundCtrl 的权威校验，不在这里重新解析配置表，
--- 避免和那边的实现分叉。
---
--- 只判前置条件是不够的：条件满足但资源不够时其实解锁不了，
--- 若只看 condOk 会误报"可解锁"。
--- @return boolean 是否真的可以解锁, string 不能解锁时的原因描述
function UIShipCabinCtrl:GetUnlockCondition(buildId)
    local bg = self:_GetBgCtrl()
    if bg == nil then return false, "" end

    local condOk, condDesc = bg:CheckUnlockCondition(buildId)
    if not condOk then
        return false, condDesc or ""
    end

    -- 解锁费用取第1级配置的 costList
    local lv1 = bg:GetBuildingLevelConfig(buildId, 1)
    local costList = lv1 and lv1.costList or nil
    if costList ~= nil and #costList > 0 then
        if not bg:CheckResourceEnough(costList) then
            return false, "解锁资源不足"
        end
    end
    return true, ""
end

--- 领取单个舱室的解锁/升级成果
--- UIShipBackgroundCtrl:CollectBuilding 只写日志不返回结果，View 无法据此提示，
--- 所以这里直接调数据层并把结果传回去。
--- @return boolean 是否成功, string 失败原因, string 领取类型（unlock/upgrade）
function UIShipCabinCtrl:CollectBuilding(buildId)
    local mgr = DataCenter.ShipPlayerDataManager
    if mgr == nil then return false, "" end

    local buildData = mgr:GetMaxLevelBuilding(buildId)
    if buildData == nil then return false, "" end
    if not buildData:IsDone() then return false, "没有可领取的成果" end

    -- doneType 要在领取前取，领取后 state 会被清掉
    local doneType = buildData:GetDoneType()
    local ok, errMsg = mgr:CollectBuildingResult(buildData.uuid)
    if not ok then
        return false, (errMsg ~= nil and errMsg ~= "") and errMsg or "领取失败"
    end
    return true, "", doneType
end

--- 直接解锁舱室（不弹确认弹窗）
--- UIBuildingPanel 是为升级设计的（费用列表 + "确认升级"按钮），
--- 拿来做解锁确认布局会垮，所以这里直接执行解锁并返回结果由 View 提示。
--- DoConfirm 内部仍会校验 condOk / resEnough，安全性不依赖调用方。
--- @return boolean 是否成功, string 失败原因
function UIShipCabinCtrl:DoUnlock(buildId)
    local bg = self:_GetBgCtrl()
    if bg == nil then return false, "" end

    local ok, cls = pcall(require, "UI.UIBuildingPanel.Controller.UIBuildingPanelCtrl")
    if not ok or cls == nil then
        Logger.LogWarning(string.format(
            "UIShipCabinCtrl DoUnlock require UIBuildingPanelCtrl失败 err=%s", tostring(cls)))
        return false, ""
    end

    local detail = bg:GetBuildingDetail(buildId)
    if detail == nil then return false, "" end
    return cls.New():DoConfirm(detail)
end

--- 点击房间：打开详情面板
--- 第2个参数必须是 options 表，不能传 nil：
--- UIManager.OpenWindow 用 type(arg1)=="table" 判断有没有 options，
--- 传 nil 会走 else 分支把 nil 一起打进 userData（变成 {nil, buildId} n=2），
--- View 侧 GetUserData() 取第1位拿到 nil，buildId 丢失。
---
--- 另：框架只在首次创建窗口时调 OnEnable，面板已打开时重复 OpenWindow
--- 只会走 SetActive(true)，不触发 OnEnable。所以这里要在窗口已存在时
--- 显式调 View:ApplyUserData()，否则点另一个格子界面不会切换。
function UIShipCabinCtrl:OpenRoomDetail(buildId)
    local uiMgr = UIManager:GetInstance()
    uiMgr:OpenWindow(UIWindowNames.UIShipCabinDetail, OpenWinAnimTrue, buildId)

    local win = uiMgr:GetWindow(UIWindowNames.UIShipCabinDetail)
    if win ~= nil and win.View ~= nil and win.View.gameObject ~= nil
        and win.View.ApplyUserData ~= nil then
        win.View:ApplyUserData()
    end
end

--- ---------------------------------------------------------------
--- 顶部资源栏
--- ---------------------------------------------------------------

--- 获取顶部资源列表 { { itemId, name, count }, ... }
--- 资源栏数据（6 项）
--- 返回 { { itemId, name, count, icon, ratePerMin }, ... }
--- ratePerMin 供参考图里的 "N/分钟" 速率副标签用，0 表示该资源无产出建筑
function UIShipCabinCtrl:GetTopResources()
    local mgr = DataCenter.ShipPlayerDataManager
    if not mgr then return {} end

    local result = {}
    for _, itemId in ipairs(TOP_RESOURCE_IDS) do
        local rate = 0
        if mgr.GetResourceRatePerMinute then
            rate = mgr:GetResourceRatePerMinute(itemId)
        end
        -- 库存上限：0 = 无仓库约束（仓库还没解锁，或该资源没有对应仓库）
        local maxCount, isFull = 0, false
        if mgr.GetResourceMax then
            maxCount = mgr:GetResourceMax(itemId)
            isFull   = mgr:IsResourceFull(itemId)
        end
        table.insert(result, {
            itemId     = itemId,
            name       = RESOURCE_NAME[itemId] or "",
            count      = mgr:GetResourceCount(itemId),
            icon       = RESOURCE_ICON[itemId],
            ratePerMin = rate,
            maxCount   = maxCount,
            isFull     = isFull,
        })
    end
    return result
end

--- 玩家信息（资源栏左侧头像框：等级 + 名称 + 总战力）
--- 参考图左上角是菱形金边头像，左下挂等级，下方另挂一个数字
function UIShipCabinCtrl:GetPlayerInfo()
    local mgr = DataCenter.ShipPlayerDataManager
    if not mgr then
        return { level = 1, name = "", totalPower = 0 }
    end
    return {
        level      = mgr:GetSelfLevel() or 1,
        name       = mgr:GetSelfDisplayName() or "",
        totalPower = mgr:CalcTotalPower() or 0,
    }
end

--- ---------------------------------------------------------------
--- 建造队列
--- ---------------------------------------------------------------

--- 获取建造队列概览
---
--- 供左侧 BtnQueue 的角标展示：占用数 / 已解锁槽位数，以及最近一个完成的倒计时。
---@return table { running, unlocked, total, nearestRemain, slots }
function UIShipCabinCtrl:GetQueueInfo()
    local qMgr = DataCenter.ShipWorkQueueManager
    if qMgr == nil then
        return { running = 0, unlocked = 0, total = 0, nearestRemain = 0, slots = {} }
    end

    local slots = {}
    local nearestRemain = 0

    for _, slot in ipairs(qMgr:GetAllSlots()) do
        local buildId = slot.buildId
        local name = buildId > 0
            and (GetTableData(TableName.Building_Config, buildId, "name") or "")
            or ""
        local remain = slot:GetRemainSeconds()

        -- 取所有在跑任务里剩余时间最短的那个（最先完成）
        if not slot:IsIdle() and remain > 0 then
            if nearestRemain == 0 or remain < nearestRemain then
                nearestRemain = remain
            end
        end

        -- 动作文案在 Ctrl 里定好，View 不必依赖数据层的 ShipWorkQueueTaskType 全局
        local actionDesc = ""
        if not slot:IsIdle() then
            actionDesc = (slot.taskType == ShipWorkQueueTaskType.Unlock)
                and "解锁"
                or string.format("升到%d级", slot.targetLevel)
        end

        table.insert(slots, {
            slotIndex     = slot.slotIndex,
            isUnlocked    = slot.isUnlocked,
            isIdle        = slot:IsIdle(),
            isFinished    = slot:IsFinished(),
            buildId       = buildId,
            buildName     = name,
            targetLevel   = slot.targetLevel,
            actionDesc    = actionDesc,
            remainSeconds = remain,
        })
    end

    return {
        running       = qMgr:GetRunningCount(),
        unlocked      = qMgr:GetUnlockedSlotCount(),
        total         = qMgr:GetSlotCount(),
        nearestRemain = nearestRemain,
        slots         = slots,
    }
end

--- ---------------------------------------------------------------
--- 底部进度条（当前重点培养的舱室升级进度）
--- ---------------------------------------------------------------

--- 获取底部进度信息 { desc, curLevel, targetLevel, hasTask }
function UIShipCabinCtrl:GetBottomProgress()
    local mgr = DataCenter.ShipPlayerDataManager
    if not mgr then
        return { hasTask = false }
    end

    -- 找一个正在升级/解锁中的舱室作为进度展示（可按实际引导逻辑替换）
    local buildIdList = mgr:GetAllBuildIdList()
    for _, buildId in ipairs(buildIdList) do
        local buildData = mgr:GetMaxLevelBuilding(buildId)
        if buildData and (buildData:IsUpgrading() or buildData:IsUnlocking()) then
            local name       = GetTableData(TableName.Building_Config, buildId, "name") or ""
            local curLevel   = mgr:GetMaxBuildingLevel(buildId)
            local targetLevel = buildData.upgradeTargetLevel > 0 and buildData.upgradeTargetLevel or (curLevel + 1)
            return {
                hasTask     = true,
                buildId     = buildId,
                desc        = string.format("%s升到%d级", name, targetLevel),
                curLevel    = curLevel,
                targetLevel = targetLevel,
            }
        end
    end

    return { hasTask = false }
end

--- 一键领取所有可收取产出
function UIShipCabinCtrl:CollectAll()
    local mgr = DataCenter.ShipPlayerDataManager
    if not mgr then return end

    local buildIdList = mgr:GetAllBuildIdList()
    local collected = 0
    for _, buildId in ipairs(buildIdList) do
        local buildData = mgr:GetMaxLevelBuilding(buildId)
        if buildData and buildData:IsDone() then
            local ok = mgr:CollectBuildingResult(buildData.uuid)
            if ok then collected = collected + 1 end
        end
    end
    return collected
end

return UIShipCabinCtrl
