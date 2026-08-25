--- 建筑升级/解锁 确认弹窗 — Controller
--- 职责：
---   1. 提供 View 需要的辅助查询（第1级配置）
---   2. DoConfirm：执行真正的扣消耗 + 开始升级/解锁
---   3. ClosePanel：关闭弹窗
---@class UIBuildingPanelCtrl : UIBaseCtrl
local UIBuildingPanelCtrl = BaseClass("UIBuildingPanelCtrl", UIBaseCtrl)

--- ---------------------------------------------------------------
--- 辅助查询
--- ---------------------------------------------------------------

--- 获取建筑第1级配置（解锁时用）
function UIBuildingPanelCtrl:GetLv1Config(buildId)
    -- rowId 即 build_lv，第1级 rowId=1
    local rowId = nil
    LocalController:instance():visitTable(TableName.Building_Levelup_Config, function(rid, lineData)
        if rowId then return end
        local blv = tonumber(lineData:getValue("build_lv"))
        if blv == 1 then
            rowId = rid
        end
    end)
    if not rowId then return nil end

    local prefix = tostring(buildId) .. "|"
    local lvupVal, costVal, unlockVal
    for n = 1, 37 do
        local val = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_" .. n)
        if val and val ~= "" and string.sub(val, 1, #prefix) == prefix then
            lvupVal   = val
            costVal   = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_cost_" .. n)   or ""
            unlockVal = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_unlock_" .. n) or ""
            break
        end
    end
    if not lvupVal then return nil end

    -- 解析 lvup: "buildId|condStr|time"
    local rest     = string.match(lvupVal, "^%d+|(.+)$") or ""
    local condStr, timeStr = string.match(rest, "^([^|]*)|(.*)$")
    local lvupTime = tonumber(timeStr) or 0

    -- 解析消耗: "buildId|itemId,count;..."
    local costStr = string.match(costVal, "^%d+|(.+)$") or ""

    -- 解析战力: "buildId|1;power" effType=1 -> power
    local power = 0
    local unlockRest = string.match(unlockVal, "^%d+|(.+)$") or ""
    for seg in string.gmatch(unlockRest, "[^;]+") do
        local effType, effArg = string.match(seg, "^(%d+),(.+)$")
        if not effType then effType, effArg = string.match(seg, "^(%d+);(.+)$") end
        if tonumber(effType) == 1 then power = tonumber(effArg) or 0; break end
    end

    -- 解析前置条件，按类型处理
    local condType  = tonumber(string.match(condStr or "", "^(%d+)")) or 0
    local condParam = string.match(condStr or "", "^%d+;(.+)$") or ""

    local require1, require1_unlock
    if condType == 0 or condType == 1 then
        require1        = ""
        require1_unlock = -1
    elseif condType == 2 then
        require1        = condParam
        require1_unlock = -1
    elseif condType == 3 then
        require1        = condParam
        require1_unlock = tonumber(condParam) or -1
    elseif condType == 4 then
        local bid, lv   = string.match(condParam, "^(%d+),(%d+)$")
        require1        = bid or condParam
        require1_unlock = tonumber(lv) or -1
    elseif condType == 5 then
        require1        = condParam
        require1_unlock = -1
    elseif condType == 6 then
        require1        = condParam
        require1_unlock = -1
    elseif condType == 7 then
        require1        = condParam
        require1_unlock = -1
    else
        require1        = condParam
        require1_unlock = -1
    end

    local cfg = {}
    cfg.power                = power
    cfg.lvup_cost            = costStr
    cfg.lvup_time            = lvupTime
    cfg.lvup_cond_type       = condType
    cfg.lvup_require1        = require1
    cfg.lvup_require1_unlock = require1_unlock
    cfg.costList = {}
    for segment in string.gmatch(costStr, "[^;]+") do
        local itemId, count = string.match(segment, "%s*(%d+)%s*,%s*(%d+)%s*")
        if itemId and count then
            table.insert(cfg.costList, { itemId = tonumber(itemId), count = tonumber(count) })
        end
    end
    return cfg
end

--- ---------------------------------------------------------------
--- 执行确认（扣消耗 + 开始升级/解锁）
--- detail 来自 UIShipBackgroundCtrl:GetBuildingDetail()
--- 返回 ok, errMsg
--- ---------------------------------------------------------------

function UIBuildingPanelCtrl:DoConfirm(detail)
    if not detail or not detail.buildId then
        return false, "detail 为空"
    end

    local buildId = detail.buildId

    if not detail.unlocked then
        -- 执行解锁
        return self:_DoUnlock(buildId, detail)
    else
        -- 执行升级
        return self:_DoUpgrade(buildId, detail)
    end
end

function UIBuildingPanelCtrl:_DoUnlock(buildId, detail)
    -- 前置条件校验（condType 0~5：主舱等级/其它舱室等级/科技等等）
    -- GetBuildingDetail 已经算好 condOk，这里必须拦住，否则条件不满足也能解锁成功
    if detail.condOk == false then
        return false, detail.condDesc or "前置条件不满足"
    end
    -- 资源校验（StartUnlockBuilding 内部也会扣费校验，这里提前给出明确文案）
    if detail.resEnough == false then
        return false, "资源不足"
    end

    local lv1 = self:GetLv1Config(buildId)
    local costList   = lv1 and lv1.costList   or {}
    local unlockTime = lv1 and lv1.lvup_time  or 0

    local ok, err = DataCenter.ShipPlayerDataManager:StartUnlockBuilding(
        buildId, costList, unlockTime)
    if not ok then
        return false, err
    end

    Logger.Log(string.format("[UIBuildingPanelCtrl] 解锁建筑 id=%d 耗时=%ds", buildId, unlockTime))

    -- TODO: 服务器联调时取消注释
    -- SFSNetwork.SendMessage(MsgDefines.UnlockBuilding, { bId = buildId })

    return true
end

function UIBuildingPanelCtrl:_DoUpgrade(buildId, detail)
    if detail.isMax then
        return false, "已满级"
    end
    if detail.isUpgrading then
        return false, "升级中"
    end
    if detail.isDone then
        return false, "有待领取的成果，请先领取"
    end
    -- 前置条件校验（condType 0~5）。GetBuildingDetail 已算好 condOk，
    -- 这里必须拦住 —— 之前缺这段，条件不满足也能升级成功
    if detail.condOk == false then
        return false, detail.condDesc or "前置条件不满足"
    end
    -- 资源校验（StartUpgradeBuilding 内部也会校验，这里提前给出明确文案）
    if detail.resEnough == false then
        return false, "资源不足"
    end

    local nextLevelCfg = detail.nextLevelCfg
    if not nextLevelCfg then
        return false, "找不到下一级配置"
    end

    local ok, err = DataCenter.ShipPlayerDataManager:StartUpgradeBuilding(
        buildId, nextLevelCfg.costList, nextLevelCfg.lvup_time, detail.nextLevel)
    if not ok then
        return false, err
    end

    Logger.Log(string.format("[UIBuildingPanelCtrl] 升级建筑 id=%d %d->%d 耗时=%ds",
        buildId, detail.curLevel, detail.nextLevel, nextLevelCfg.lvup_time))

    -- TODO: 服务器联调时取消注释
    -- local buildData = detail.buildData
    -- if buildData then
    --     SFSNetwork.SendMessage(MsgDefines.FreeBuildingUpNew, {
    --         uuid = tostring(buildData.uuid), gold = BuildUpgradeUseGoldType.No,
    --         upLevel = detail.nextLevel, clientParam = "", truckId = 0, pathTime = 0, robotUuid = 0,
    --     })
    -- end

    return true
end

--- ---------------------------------------------------------------
--- 关闭弹窗
--- ---------------------------------------------------------------

function UIBuildingPanelCtrl:ClosePanel()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBuildingPanel)
end

return UIBuildingPanelCtrl
