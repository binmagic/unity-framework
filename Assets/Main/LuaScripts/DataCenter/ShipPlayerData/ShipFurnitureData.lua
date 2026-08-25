---
--- 飞船家具本地内存数据对象
--- 对应 Furniture_Config 表中的一条家具记录
--- 每个建筑可拥有多件家具，每件家具独立升级
---
---@class ShipFurnitureData
local ShipFurnitureData = BaseClass("ShipFurnitureData")

--- 家具状态枚举（与 ShipBuildingState 风格一致）
ShipFurnitureState = ShipFurnitureState or {
    Locked    = 0,   -- 未解锁（建筑等级不够）
    Idle      = 1,   -- 已解锁，空闲
    Upgrading = 2,   -- 升级中（倒计时）
    Done      = 3,   -- 升级完成，待领取
}

function ShipFurnitureData:__init()
    self:Reset()
end

function ShipFurnitureData:__delete()
    self:Reset()
end

--- ---------------------------------------------------------------
--- 字段定义
--- ---------------------------------------------------------------

function ShipFurnitureData:Reset()
    self.uuid         = 0       -- 家具唯一 ID（本地自增负数）
    self.furnitureId  = 0       -- 家具类型 ID，对应 Furniture_Config.id
    self.buildId      = 0       -- 所属建筑 ID，对应 Furniture_Config.build_id
    self.cfgId        = 0       -- 升级配置 ID（新表中等于 furnitureId，对应 Furniture_Levelup_Config 列 lvup_{cfgId}）
    self.level        = 0       -- 当前等级，0 = 未解锁
    self.unlock       = 0       -- 解锁状态：0=未解锁，1=已解锁
    self.state        = ShipFurnitureState.Locked

    self.startTime    = 0       -- 升级开始时间戳（秒）
    self.updateTime   = 0       -- 升级完成时间戳（秒）

    self.upgradeTargetLevel = 0 -- 升级目标等级
    self.power        = 0       -- 当前等级战力缓存
end

--- ---------------------------------------------------------------
--- 状态判断
--- ---------------------------------------------------------------

function ShipFurnitureData:IsUpgrading()
    return self.state == ShipFurnitureState.Upgrading
end

function ShipFurnitureData:IsUpgradeFinished()
    if not self:IsUpgrading() then return false end
    return os.time() >= self.updateTime
end

function ShipFurnitureData:IsDone()
    return self.state == ShipFurnitureState.Done
end

function ShipFurnitureData:IsBusy()
    return self.state == ShipFurnitureState.Upgrading
        or self.state == ShipFurnitureState.Done
end

function ShipFurnitureData:IsActive()
    return self.unlock == 1 and self.level > 0 and self.state == ShipFurnitureState.Idle
end

function ShipFurnitureData:GetRemainSeconds()
    if self.updateTime <= 0 then return 0 end
    local remain = self.updateTime - os.time()
    return remain > 0 and remain or 0
end

--- ---------------------------------------------------------------
--- 初始化
--- ---------------------------------------------------------------

function ShipFurnitureData:InitNew(furnitureId, buildId, cfgId, uuid)
    self:Reset()
    self.furnitureId = furnitureId
    self.buildId     = buildId
    self.cfgId       = cfgId
    self.uuid        = uuid
    self.level       = 0
    self.unlock      = 0
    self.state       = ShipFurnitureState.Locked
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

function ShipFurnitureData:InitFromServer(message)
    -- TODO: 服务器同步
    -- self.uuid                = message["uuid"]
    -- self.furnitureId         = message["fId"]
    -- self.buildId             = message["buildId"]
    -- self.cfgId               = message["cfgId"]
    -- self.level               = message["lv"]      or 0
    -- self.unlock              = message["unlock"]  or 0
    -- self.state               = message["state"]   or ShipFurnitureState.Locked
    -- self.startTime           = message["sT"]      or 0
    -- self.updateTime          = message["uT"]      or 0
    -- self.upgradeTargetLevel  = message["targetLv"] or 0
end

function ShipFurnitureData:ToServerMessage()
    -- TODO: 服务器同步
    return {}
end

return ShipFurnitureData
