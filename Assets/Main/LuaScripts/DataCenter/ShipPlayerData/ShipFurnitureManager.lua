---
--- 飞船家具管理器（本地内存版）
--- 管理所有建筑的家具数据，支持解锁/升级/领取
---
--- 配置表：
---   Furniture_Config       — 家具基础配置（id, furniture_name, position, build_id, unlock_building_level）
---   Furniture_Levelup_Config — 家具升级配置（rowId=furniture_lv 等级，列 lvup_{furnitureId} 对应该家具该等级）
---     每列格式：家具id|解锁条件|消耗资源|产出加成
---     产出加成格式：effType;effArg（如 "1;10" 表示产量+10，"2;5" 表示减CD 5秒）
---
---@class ShipFurnitureManager
local ShipFurnitureManager = BaseClass("ShipFurnitureManager")

local ShipFurnitureData = require "DataCenter.ShipPlayerData.ShipFurnitureData"

--- 本地 uuid 自增计数器（负数，避免与服务器 uuid 冲突）
local LOCAL_FURNITURE_UUID = -10000
local function NextFurnitureUuid()
    LOCAL_FURNITURE_UUID = LOCAL_FURNITURE_UUID - 1
    return LOCAL_FURNITURE_UUID
end

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function ShipFurnitureManager:__init()
    ---@type table<number, ShipFurnitureData>  key = uuid
    self.furnitureMap   = {}
    ---@type table<number, ShipFurnitureData[]>  key = buildId
    self.buildIndex     = {}
    ---@type table<number, boolean>  升级中的家具 uuid 集合
    self.upgradingSet   = {}
    self.tickTimer      = nil

    self:_InitDefaultFurnitures()
end

function ShipFurnitureManager:__delete()
    self:_StopTimer()
    self.furnitureMap = nil
    self.buildIndex   = nil
    self.upgradingSet = nil
end

function ShipFurnitureManager:Startup()
    self:_StartTimer()
end

function ShipFurnitureManager:_StartTimer()
    if self.tickTimer then return end
    self.tickTimer = TimerManager:GetInstance():GetTimer(1, self.Tick, self, false, false, false)
    self.tickTimer:Start()
end

function ShipFurnitureManager:_StopTimer()
    if self.tickTimer then
        self.tickTimer:Stop()
        self.tickTimer = nil
    end
end

--- ---------------------------------------------------------------
--- 初始化：根据 Furniture_Config 表创建所有家具的初始本地数据
--- ---------------------------------------------------------------

function ShipFurnitureManager:_InitDefaultFurnitures()
    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        local furnitureId = tonumber(rowId)
        if not furnitureId then return end
        local buildId  = tonumber(lineData:getValue("build_id"))  or 0
        -- 新表用 furnitureId 本身作为升级表列索引，不再需要单独的 cfgId
        local cfgId    = furnitureId
        local data = ShipFurnitureData.New()
        data:InitNew(furnitureId, buildId, cfgId, NextFurnitureUuid())
        self:_AddToIndex(data)
    end)
end

--- ---------------------------------------------------------------
--- 索引维护（内部）
--- ---------------------------------------------------------------

function ShipFurnitureManager:_AddToIndex(data)
    self.furnitureMap[data.uuid] = data
    if not self.buildIndex[data.buildId] then
        self.buildIndex[data.buildId] = {}
    end
    table.insert(self.buildIndex[data.buildId], data)
end

--- ---------------------------------------------------------------
--- 查询接口
--- ---------------------------------------------------------------

---@param uuid number
---@return ShipFurnitureData|nil
function ShipFurnitureManager:GetFurnitureByUuid(uuid)
    return self.furnitureMap[uuid]
end

--- 获取某建筑下所有家具列表
---@param buildId number
---@return ShipFurnitureData[]
function ShipFurnitureManager:GetFurnituresByBuildId(buildId)
    return self.buildIndex[buildId] or {}
end

--- 获取某建筑下某家具类型的数据（一个建筑同类型家具通常只有一件）
---@param buildId number
---@param furnitureId number
---@return ShipFurnitureData|nil
function ShipFurnitureManager:GetFurnitureByBuildAndId(buildId, furnitureId)
    local list = self:GetFurnituresByBuildId(buildId)
    for _, d in ipairs(list) do
        if d.furnitureId == furnitureId then
            return d
        end
    end
    return nil
end

--- 获取家具基础配置（来自 Furniture_Config 表）
---@param furnitureId number
---@return table
function ShipFurnitureManager:GetFurnitureConfig(furnitureId)
    local cfg = {}
    cfg.id                    = furnitureId
    cfg.name                  = GetTableData(TableName.Furniture_Config, furnitureId, "furniture_name")           or ""
    cfg.cfgId                 = furnitureId   -- 新表直接用 furnitureId 作为升级表列索引
    cfg.buildId               = GetTableNumber(TableName.Furniture_Config, furnitureId, "build_id")               or 0
    cfg.unlockBuildingLevel   = GetTableNumber(TableName.Furniture_Config, furnitureId, "unlock_building_level")   or 1
    return cfg
end

--- 解析 furniture{N}_lvup 列的字符串，返回结构化数据
--- 格式：家具id|解锁条件|消耗资源|产出加成
--- 产出加成格式：effType;effArg（如 "1;10"）
---@param rawStr string
---@return table|nil  {furnitureId, unlockCond, costStr, effType, effArg}
local function _ParseLvupColumn(rawStr)
    if not rawStr or rawStr == "" then return nil end
    local parts = string.split(rawStr, "|")
    if not parts or #parts < 4 then return nil end
    local effParts = string.split(parts[4], ";")
    return {
        furnitureId = tonumber(parts[1]) or 0,
        unlockCond  = parts[2] or "",
        costStr     = parts[3] or "",
        effType     = tonumber(effParts and effParts[1]) or 0,
        effArg      = tonumber(effParts and effParts[2]) or 0,
    }
end

--- 获取家具某等级的升级配置（来自 Furniture_Levelup_Config 表）
--- 新表结构：rowId = furniture_lv（等级），列 lvup_{furnitureId} 对应该家具
--- 列格式：家具id|解锁条件|消耗资源|产出加成（effType;effArg）
---@param furnitureId number  家具ID，直接对应升级表列 lvup_{furnitureId}
---@param targetLv number  目标等级（对应 Furniture_Levelup_Config 的 rowId = furniture_lv）
---@return table|nil  {furniture_lv, lvup_time, lvup_require1, effType, effArg, costStr}
function ShipFurnitureManager:GetFurnitureLevelConfig(furnitureId, targetLv)
    if not furnitureId or furnitureId <= 0 or not targetLv or targetLv <= 0 then return nil end

    -- 列名：lvup_{furnitureId}（行=等级，列=furnitureId）
    local colName = "lvup_" .. tostring(furnitureId)
    local rawStr  = GetTableData(TableName.Furniture_Levelup_Config, targetLv, colName)
    if not rawStr or rawStr == "" then return nil end

    local parsed = _ParseLvupColumn(rawStr)
    if not parsed then return nil end

    local cfg = {}
    cfg.furniture_lv         = targetLv
    cfg.lvup_time            = GetTableNumber(TableName.Furniture_Levelup_Config, targetLv, "lvup_time") or 0
    cfg.lvup_require1        = GetTableData(TableName.Furniture_Levelup_Config, targetLv, "lvup_require1") or ""
    cfg.lvup_require1_unlock = GetTableNumber(TableName.Furniture_Levelup_Config, targetLv, "lvup_require1_unlock") or 0
    cfg.effType              = parsed.effType
    cfg.effArg               = parsed.effArg
    cfg.costStr              = parsed.costStr
    cfg.unlockCond           = parsed.unlockCond
    return cfg
end

--- 检查建筑等级是否满足家具解锁条件
---@param furnitureId number
---@param buildingLevel number  当前建筑等级
---@return boolean
function ShipFurnitureManager:CheckUnlockCondition(furnitureId, buildingLevel)
    local cfg = self:GetFurnitureConfig(furnitureId)
    return buildingLevel >= cfg.unlockBuildingLevel
end

--- ---------------------------------------------------------------
--- 解锁家具
--- ---------------------------------------------------------------

---@param furnitureId number
---@param buildingLevel number  当前建筑等级（用于前置检查）
---@return boolean ok
---@return string|nil errMsg
function ShipFurnitureManager:UnlockFurniture(furnitureId, buildingLevel)
    local data = self:GetFurnitureByBuildAndId(
        GetTableNumber(TableName.Furniture_Config, furnitureId, "build_id") or 0,
        furnitureId)
    if not data then
        return false, "找不到家具数据 furnitureId=" .. tostring(furnitureId)
    end
    if data.unlock == 1 then
        return false, "家具已解锁"
    end
    if data:IsBusy() then
        return false, "家具正在升级中或待领取"
    end
    if not self:CheckUnlockCondition(furnitureId, buildingLevel) then
        local cfg = self:GetFurnitureConfig(furnitureId)
        return false, string.format("需要建筑达到 %d 级（当前 %d 级）",
            cfg.unlockBuildingLevel, buildingLevel)
    end

    -- 解锁第1级配置
    local lv1Cfg = self:GetFurnitureLevelConfig(data.furnitureId, 1)
    local unlockTime = lv1Cfg and lv1Cfg.lvup_time or 0

    local now = os.time()
    if unlockTime <= 0 then
        data.unlock     = 1
        data.level      = 1
        data.state      = ShipFurnitureState.Idle
        data.startTime  = now
        data.updateTime = now
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUnlockFinish,
            { furnitureId = furnitureId, uuid = data.uuid })
    else
        data.state      = ShipFurnitureState.Upgrading
        data.startTime  = now
        data.updateTime = now + unlockTime
        data.upgradeTargetLevel = 1
        self.upgradingSet[data.uuid] = true
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUpgradeStart,
            { furnitureId = furnitureId, uuid = data.uuid })
    end

    Logger.Log(string.format("[ShipFurnitureManager] 解锁家具 id=%d 耗时=%ds", furnitureId, unlockTime))
    return true
end

--- ---------------------------------------------------------------
--- 升级家具
--- ---------------------------------------------------------------

---@param furnitureId number
---@param maxLevel number  家具最大等级上限（由外部传入，通常为 Furniture_Levelup_Config 最大行）
---@return boolean ok
---@return string|nil errMsg
function ShipFurnitureManager:UpgradeFurniture(furnitureId, maxLevel)
    local buildId = GetTableNumber(TableName.Furniture_Config, furnitureId, "build_id") or 0
    local data = self:GetFurnitureByBuildAndId(buildId, furnitureId)
    if not data then
        return false, "找不到家具数据 furnitureId=" .. tostring(furnitureId)
    end
    if data.unlock ~= 1 then
        return false, "家具未解锁"
    end
    if data:IsBusy() then
        return false, "家具正在升级中或待领取"
    end
    if data.level >= maxLevel then
        return false, "家具已满级"
    end

    local nextLevel = data.level + 1
    local nextCfg   = self:GetFurnitureLevelConfig(data.furnitureId, nextLevel)
    if not nextCfg then
        return false, "找不到下一级配置 furnitureId=" .. tostring(data.furnitureId) .. " lv=" .. tostring(nextLevel)
    end

    local upgradeTime = nextCfg.lvup_time or 0
    local now = os.time()

    if upgradeTime <= 0 then
        -- 立即完成，进入待领取
        data.state              = ShipFurnitureState.Done
        data.startTime          = now
        data.updateTime         = now
        data.upgradeTargetLevel = nextLevel
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUpgradeDone,
            { furnitureId = furnitureId, uuid = data.uuid })
    else
        data.state              = ShipFurnitureState.Upgrading
        data.startTime          = now
        data.updateTime         = now + upgradeTime
        data.upgradeTargetLevel = nextLevel
        self.upgradingSet[data.uuid] = true
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUpgradeStart,
            { furnitureId = furnitureId, uuid = data.uuid })
    end

    Logger.Log(string.format("[ShipFurnitureManager] 升级家具 id=%d lv%d→lv%d 耗时=%ds",
        furnitureId, data.level, nextLevel, upgradeTime))
    return true
end

--- ---------------------------------------------------------------
--- 领取家具升级结果
--- ---------------------------------------------------------------

---@param uuid number
---@return boolean ok
---@return string|nil errMsg
function ShipFurnitureManager:CollectFurnitureResult(uuid)
    local data = self.furnitureMap[uuid]
    if not data then
        return false, "找不到家具数据 uuid=" .. tostring(uuid)
    end
    if not data:IsDone() then
        return false, "家具不在待领取状态"
    end

    local now = os.time()
    if data.unlock == 0 then
        -- 解锁完成
        data.unlock     = 1
        data.level      = 1
        data.state      = ShipFurnitureState.Idle
        data.updateTime = now
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUnlockFinish,
            { furnitureId = data.furnitureId, uuid = uuid })
    else
        -- 升级完成
        data.level      = data.upgradeTargetLevel
        data.state      = ShipFurnitureState.Idle
        data.updateTime = now
        EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUpgradeFinish,
            { furnitureId = data.furnitureId, uuid = uuid })
    end

    Logger.Log(string.format("[ShipFurnitureManager] 领取家具 uuid=%d furnitureId=%d level=%d",
        uuid, data.furnitureId, data.level))
    return true
end

--- ---------------------------------------------------------------
--- Tick：每秒检查升级是否自然完成
--- ---------------------------------------------------------------

function ShipFurnitureManager:Tick()
    for uuid, _ in pairs(self.upgradingSet) do
        local d = self.furnitureMap[uuid]
        if d and d:IsUpgradeFinished() then
            self:_FinishUpgrade(uuid)
        end
    end
end

function ShipFurnitureManager:_FinishUpgrade(uuid)
    local data = self.furnitureMap[uuid]
    if not data then return end
    if not data:IsUpgrading() then return end

    data.state          = ShipFurnitureState.Done
    data.updateTime     = os.time()
    self.upgradingSet[uuid] = nil

    EventManager:GetInstance():Broadcast(EventId.ShipFurnitureUpgradeDone,
        { furnitureId = data.furnitureId, uuid = uuid })
end

--- 获取某建筑下所有已解锁家具中 effType=1（产量加成）的累计 effArg
--- 新表结构：effType/effArg 从 furniture{N}_lvup 列解析，不再读 Furniture_Config.eff_type
---@param buildId number
---@return number  累计产出增量（直接加到 product_base 上）
function ShipFurnitureManager:GetBuildingOutputInc(buildId)
    local total = 0
    local list = self:GetFurnituresByBuildId(buildId)
    for _, data in ipairs(list) do
        if data.unlock == 1 and data.level > 0 then
            local lvCfg = self:GetFurnitureLevelConfig(data.furnitureId, data.level)
            if lvCfg and lvCfg.effType == 1 then
                total = total + lvCfg.effArg
            end
        end
    end
    return total
end

--- 获取某建筑下所有已解锁家具中 effType=2（减CD）的累计 effArg
--- 新表结构：effType/effArg 从 furniture{N}_lvup 列解析，不再读 Furniture_Config.eff_type
---@param buildId number
---@return number  累计CD减少量（秒，从 produce_cd 中减去）
function ShipFurnitureManager:GetBuildingCDDec(buildId)
    local total = 0
    local list = self:GetFurnituresByBuildId(buildId)
    for _, data in ipairs(list) do
        if data.unlock == 1 and data.level > 0 then
            local lvCfg = self:GetFurnitureLevelConfig(data.furnitureId, data.level)
            if lvCfg and lvCfg.effType == 2 then
                total = total + lvCfg.effArg
            end
        end
    end
    return total
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

function ShipFurnitureManager:InitFromServer(message)
    -- TODO: 服务器同步
    -- local furnitureArr = message["ship_furnitures"]
    -- if furnitureArr then
    --     for _, f in ipairs(furnitureArr) do
    --         local d = self:GetFurnitureByUuid(f["uuid"])
    --         if d then
    --             d:InitFromServer(f)
    --             if d:IsUpgrading() then
    --                 self.upgradingSet[d.uuid] = true
    --             end
    --         end
    --     end
    -- end
end

return ShipFurnitureManager
