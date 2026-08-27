---
--- 船舱详情面板 — Controller
--- 职责：
---   1. 组装船舱详情数据（建筑信息+产出+家具+英雄）
---   2. 提供家具操作接口（解锁/升级/领取）
---   3. 打开升级确认弹窗
---@class UIShipCabinDetailCtrl : UIBaseCtrl
local UIShipCabinDetailCtrl = BaseClass("UIShipCabinDetailCtrl", UIBaseCtrl)

--- 资源名映射
local RESOURCE_NAME = {
    [102001] = "食材",
    [102002] = "金属",
    [102003] = "电力",
    [102004] = "有机质",
    [102005] = "科技点",
}

--- ---------------------------------------------------------------
--- 建筑查询
--- ---------------------------------------------------------------

--- 获取建筑基础配置（来自 Building_Config）
function UIShipCabinDetailCtrl:GetBuildingConfig(buildId)
    local cfg = {}
    cfg.id          = buildId
    cfg.name        = GetTableData(TableName.Building_Config, buildId, "name")          or ""
    cfg.desc        = GetTableData(TableName.Building_Config, buildId, "desc")          or ""
    cfg.detail_desc = GetTableData(TableName.Building_Config, buildId, "detail_desc")   or ""
    cfg.level_limit = GetTableNumber(TableName.Building_Config, buildId, "level_limit") or 1
    cfg.icon        = GetTableData(TableName.Building_Config, buildId, "icon")          or ""
    cfg.type        = GetTableNumber(TableName.Building_Config, buildId, "type")        or 0
    cfg.group       = GetTableNumber(TableName.Building_Config, buildId, "group")       or 0
    cfg.produce_cd  = GetTableNumber(TableName.Building_Config, buildId, "produce_cd")  or 0
    cfg.product_base = GetTableNumber(TableName.Building_Config, buildId, "product_base") or 0
    cfg.product     = GetTableData(TableName.Building_Config, buildId, "product")       or ""
    return cfg
end

--- 获取建筑运行时数据
function UIShipCabinDetailCtrl:GetBuildingData(buildId)
    return DataCenter.ShipPlayerDataManager:GetMaxLevelBuilding(buildId)
end

--- 获取建筑当前等级
function UIShipCabinDetailCtrl:GetBuildingLevel(buildId)
    return DataCenter.ShipPlayerDataManager:GetMaxBuildingLevel(buildId)
end

--- 是否已解锁
function UIShipCabinDetailCtrl:IsBuildingUnlocked(buildId)
    return DataCenter.ShipPlayerDataManager:IsBuildingUnlocked(buildId)
end

--- ---------------------------------------------------------------
--- 组装船舱详情数据（供 View 展示）
--- ---------------------------------------------------------------

function UIShipCabinDetailCtrl:GetCabinDetail(buildId)
    local cfg       = self:GetBuildingConfig(buildId)
    local buildData = self:GetBuildingData(buildId)
    local unlocked  = self:IsBuildingUnlocked(buildId)
    local curLevel  = self:GetBuildingLevel(buildId)
    local maxLevel  = cfg.level_limit

    local isUpgrading = buildData and (buildData:IsUpgrading() or buildData:IsUnlocking()) or false
    local isDone      = buildData and buildData:IsDone() or false
    local isMax       = unlocked and (curLevel >= maxLevel)

    -- 产出信息
    local productId   = tonumber(string.match(cfg.product or "", "^(%d+)")) or 0
    local productName = RESOURCE_NAME[productId] or ""
    local productBase = cfg.product_base or 0
    local produceCD   = cfg.produce_cd or 0

    -- 生产上限 = 挂机结算上限（8小时）内最多能累积的产量。
    -- 注意：Building_Config 里**没有** produce_limit 字段（字段止于 product_base），
    -- 原先读它恒为 nil→0，这一列永远不显示。改由数据层按 CD 和产量换算。
    local produceLimit = 0
    local produceCapHours = 0
    local mgr = DataCenter.ShipPlayerDataManager
    if mgr and mgr.GetProduceCapAmount then
        produceLimit    = mgr:GetProduceCapAmount(buildId)
        produceCapHours = math.floor(mgr:GetProduceCapSeconds() / 3600)
    end

    -- 家具加成
    local outputInc = 0
    local cdDec     = 0
    if DataCenter.ShipFurnitureManager then
        outputInc = DataCenter.ShipFurnitureManager:GetBuildingOutputInc(buildId)
        cdDec     = DataCenter.ShipFurnitureManager:GetBuildingCDDec(buildId)
    end

    local realOutput = productBase + outputInc
    local realCD     = math.max(produceCD - cdDec, 1)

    -- 每小时产出
    local outputPerHour = 0
    if realCD > 0 and realOutput > 0 then
        outputPerHour = math.floor(realOutput * (3600 / realCD))
    end

    -- 家具列表
    local furnitureList = self:GetFurnitureListDetail(buildId, curLevel)

    -- 战力
    local power = buildData and buildData.power or 0

    return {
        buildId        = buildId,
        buildData      = buildData,
        cfg            = cfg,
        unlocked       = unlocked,
        curLevel       = curLevel,
        maxLevel       = maxLevel,
        isMax          = isMax,
        isUpgrading    = isUpgrading,
        isDone         = isDone,
        remainSeconds  = buildData and buildData:GetRemainSeconds() or 0,
        power          = power,

        -- 产出信息
        productId      = productId,
        productName    = productName,
        productBase    = productBase,
        outputInc      = outputInc,
        realOutput     = realOutput,
        produceCD      = produceCD,
        cdDec          = cdDec,
        realCD         = realCD,
        outputPerHour  = outputPerHour,
        produceLimit   = produceLimit,
        produceCapHours = produceCapHours,

        -- 家具
        furnitureList  = furnitureList,
    }
end

--- ---------------------------------------------------------------
--- 家具列表详情
--- ---------------------------------------------------------------

function UIShipCabinDetailCtrl:GetFurnitureListDetail(buildId, buildingLevel)
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not furnitureMgr then return {} end

    local list   = furnitureMgr:GetFurnituresByBuildId(buildId)
    local result = {}
    local MAX_FURNITURE_LEVEL = 30

    for _, fData in ipairs(list) do
        local fId  = fData.furnitureId
        local fCfg = furnitureMgr:GetFurnitureConfig(fId)

        local isUnlocked   = fData.unlock == 1 and fData.level > 0
        local isUpgrading  = fData:IsUpgrading()
        local isDone       = fData:IsDone()
        local isMax        = isUnlocked and fData.level >= MAX_FURNITURE_LEVEL
        local canUnlock    = (not isUnlocked) and (buildingLevel >= fCfg.unlockBuildingLevel)
        local canUpgrade   = isUnlocked and (not fData:IsBusy()) and (not isMax)

        -- 当前等级配置
        local curLevelCfg = nil
        if isUnlocked and fData.level > 0 then
            curLevelCfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, fData.level)
        end

        -- 下一级配置
        local nextLevel = fData.level + 1
        if isDone and fData.upgradeTargetLevel > 0 then
            nextLevel = fData.upgradeTargetLevel
        end
        local nextLevelCfg = nil
        if not isMax then
            nextLevelCfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, nextLevel)
        end

        table.insert(result, {
            uuid             = fData.uuid,
            furnitureId      = fId,
            name             = fCfg.name,
            level            = fData.level,
            maxLevel         = MAX_FURNITURE_LEVEL,
            isUnlocked       = isUnlocked,
            isUpgrading      = isUpgrading,
            isDone           = isDone,
            isMax            = isMax,
            remainSeconds    = fData:GetRemainSeconds(),
            unlockBuildLevel = fCfg.unlockBuildingLevel,
            canUnlock        = canUnlock,
            canUpgrade       = canUpgrade,
            curLevelCfg      = curLevelCfg,
            nextLevelCfg     = nextLevelCfg,
            nextLevel        = nextLevel,
            -- 产出加成描述，家具行显示在名称下方（参考图那里是产出数值）
            productBonus     = self:_ParseFurnitureEffect(curLevelCfg),
            nextBonus        = self:_ParseFurnitureEffect(nextLevelCfg),
        })
    end

    -- 按解锁等级排列
    table.sort(result, function(a, b)
        if a.isUnlocked ~= b.isUnlocked then
            return a.isUnlocked
        end
        return a.unlockBuildLevel < b.unlockBuildLevel
    end)

    return result
end

--- 把家具等级配置里的效果字段解析成可读描述
--- 与 UIShipBackgroundCtrl:_ParseFurnitureEffect 同逻辑 —— 两个 Ctrl 各有一份
--- GetFurnitureListDetail，详情面板走的是本文件这份。
---
--- 注意字段名是驼峰的 effType/effArg（GetFurnitureLevelConfig 组装时定的），
--- 不是配置表原始的 eff_type/eff_arg，写错会永远取到 nil、描述恒为空。
function UIShipCabinDetailCtrl:_ParseFurnitureEffect(levelCfg)
    if not levelCfg then return "" end
    local parts = {}

    local function addEffect(effType, effArg)
        if not effType or effType == "" then return end
        local t   = tonumber(effType)
        local val = tonumber(effArg) or 0
        if t == 1 then
            table.insert(parts, string.format("产出速度+%d%%", val))
        elseif t == 2 then
            table.insert(parts, string.format("产量上限+%d%%", val))
        elseif t == 3 then
            table.insert(parts, string.format("升级时间-%d%%", val))
        elseif t == 4 then
            table.insert(parts, string.format("战力+%d", val))
        else
            table.insert(parts, string.format("效果%s+%s", tostring(effType), tostring(effArg)))
        end
    end

    addEffect(levelCfg.effType,  levelCfg.effArg)
    addEffect(levelCfg.effType2, levelCfg.effArg2)
    addEffect(levelCfg.effType3, levelCfg.effArg3)
    addEffect(levelCfg.effType4, levelCfg.effArg4)

    return table.concat(parts, "  ")
end

--- ---------------------------------------------------------------
--- 操作接口
--- ---------------------------------------------------------------

--- 打开升级确认弹窗
--- 直接复用 UIShipBackgroundCtrl:OpenBuildingPanel，
--- 由它完成等级校验、前置条件判断、资源检查，与测试用例走同一条路径。
--- 注意：UIShipBackground 窗口在真实流程中不会被打开（船舱走 UIShipCabin），
--- 所以这里不能用 GetWindow 拿 Ctrl。UIBaseCtrl 无状态，直接 New 一个实例即可，
--- 与 CSharpCallLuaInterface.OpenShipBuildingUpgrade 保持同一做法。
function UIShipCabinDetailCtrl:OpenUpgradePanel(buildId)
    local ok, cls = pcall(require, "UI.UIShipBackground.Controller.UIShipBackgroundCtrl")
    if not ok or cls == nil then
        Logger.LogWarning(string.format(
            "UIShipCabinDetailCtrl OpenUpgradePanel require UIShipBackgroundCtrl失败 buildId=%d err=%s",
            buildId, tostring(cls)))
        return
    end
    cls.New():OpenBuildingPanel(buildId)
end

--- 解锁家具
function UIShipCabinDetailCtrl:UnlockFurniture(furnitureId, buildId)
    local buildingLevel = self:GetBuildingLevel(buildId)
    local ok, errMsg = DataCenter.ShipFurnitureManager:UnlockFurniture(furnitureId, buildingLevel)
    if not ok then
        UIUtil.ShowTips(errMsg)
    end
    return ok
end

--- 升级家具
function UIShipCabinDetailCtrl:UpgradeFurniture(furnitureId)
    local MAX_FURNITURE_LEVEL = 30
    local ok, errMsg = DataCenter.ShipFurnitureManager:UpgradeFurniture(furnitureId, MAX_FURNITURE_LEVEL)
    if not ok then
        UIUtil.ShowTips(errMsg)
    end
    return ok
end

--- 领取家具
function UIShipCabinDetailCtrl:CollectFurniture(furnitureUuid)
    local ok, errMsg = DataCenter.ShipFurnitureManager:CollectFurnitureResult(furnitureUuid)
    if not ok then
        UIUtil.ShowTips(errMsg)
    end
    return ok
end

return UIShipCabinDetailCtrl
