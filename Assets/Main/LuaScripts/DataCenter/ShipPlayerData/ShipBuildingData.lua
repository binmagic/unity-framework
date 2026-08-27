---
--- 飞船建筑本地内存数据对象
--- 保留旧结构（BuildingDate）字段命名风格，新增飞船建筑专用字段
--- 不依赖服务器，所有字段均在本地内存中维护
---
---@class ShipBuildingData
local ShipBuildingData = BaseClass("ShipBuildingData")

function ShipBuildingData:__init()
    self:Reset()
end

function ShipBuildingData:__delete()
    self:Reset()
end

--- ---------------------------------------------------------------
--- 字段定义（对标 BuildingDate，保留旧命名，新增飞船专用字段）
--- ---------------------------------------------------------------

function ShipBuildingData:Reset()
    --- ---- 基础标识（对标 BuildingDate）----
    self.uuid         = 0       -- 建筑唯一 ID（本地自增负数，服务器同步后替换）
    self.itemId       = 0       -- 建筑类型 ID，对应 Building_Config.id（对标 BuildingDate.itemId）
    self.level        = 0       -- 当前等级，0 = 未解锁（对标 BuildingDate.level）
    self.unlock       = 0       -- 解锁状态：0=未解锁，1=已解锁（对标 BuildingDate.unlock）

    --- ---- 状态（对标 BuildingDate）----
    --- 使用 ShipBuildingState 枚举：Locked / Idle / Unlocking / Upgrading
    self.state        = ShipBuildingState.Locked

    --- ---- 升级时间（对标 BuildingDate.startTime / updateTime）----
    self.startTime    = 0       -- 升级/解锁开始时间戳（秒）
    self.updateTime   = 0       -- 升级/解锁完成时间戳（秒），0 = 未在进行

    --- ---- 升级目标等级（新增，BuildingDate 无此字段）----
    self.upgradeTargetLevel = 0

    --- ---- 资源产出（对标 BuildingDate）----
    self.lastCollectTime  = 0   -- 上次收取资源时间戳（对标 BuildingDate.lastCollectTime）
    self.produceEndTime   = 0   -- 资源产出结束时间，0 = 无限产出（对标 BuildingDate.produceEndTime）
    self.cdAccum          = 0   -- 产出CD累计秒数（达到实际CD后产出并减去CD，保留余量）
    --- 上次产出结算的时间戳（秒），0 = 尚未结算过
    --- _TickProduction 用 now - lastProduceTime 推进 cdAccum，
    --- 这样漏 tick（切后台/卡顿）也能补回来，不依赖 Timer 精确每秒触发。
    self.lastProduceTime  = 0

    --- ---- 战力缓存（新增，BuildingDate 无此字段）----
    self.power            = 0   -- 当前等级战力，从 CfgBuildingLevel 读取后缓存

    --- ---- 帮助/NPC（对标 BuildingDate）----
    self.isHelped         = 0   -- 是否有人帮助（对标 BuildingDate.isHelped）

    --- ---- 废墟/修复（对标 BuildingDate）----
    self.destroyEndTime   = 0   -- 修复完成时间戳（对标 BuildingDate.destroyEndTime）
    self.destroyStartTime = 0   -- 修复开始时间戳（对标 BuildingDate.destroyStartTime）

    --- ---- 人口驻扎（对标 BuildingDate）----
    self.peopleStation    = 0   -- 驻扎人口数（对标 BuildingDate.peopleStation）

    --- ---- 经验进度（对标 BuildingDate）----
    self.mainExp          = 0   -- 建造总进度值（对标 BuildingDate.mainExp）
    self.subExp           = 0   -- 建造当前进度值（对标 BuildingDate.subExp）
end

--- ---------------------------------------------------------------
--- 状态判断
--- ---------------------------------------------------------------

--- 是否正在升级（对标 BuildingDate:IsUpgrading）
function ShipBuildingData:IsUpgrading()
    return self.state == ShipBuildingState.Upgrading
end

--- 升级倒计时是否已到期（时间到但还未写入 level）
function ShipBuildingData:IsUpgradeFinished()
    if not self:IsUpgrading() then return false end
    return os.time() >= self.updateTime
end

--- 是否正在解锁
function ShipBuildingData:IsUnlocking()
    return self.state == ShipBuildingState.Unlocking
end

--- 解锁倒计时是否已到期
function ShipBuildingData:IsUnlockFinished()
    if not self:IsUnlocking() then return false end
    return os.time() >= self.updateTime
end

--- 是否处于忙碌状态（升级中 / 解锁中 / 待领取）
--- 用于保护检查：忙碌时不允许再次发起升级/解锁
function ShipBuildingData:IsBusy()
    return self.state == ShipBuildingState.Upgrading
        or self.state == ShipBuildingState.Unlocking
        or self.state == ShipBuildingState.Done
end

--- 是否已解锁且可用（对标 BuildingDate:IsActive）
function ShipBuildingData:IsActive()
    return self.unlock == 1 and self.level > 0 and self.state == ShipBuildingState.Idle
end

--- 是否处于完成待领取状态
function ShipBuildingData:IsDone()
    return self.state == ShipBuildingState.Done
end

--- 待领取的是解锁还是升级
--- 返回 "unlock" / "upgrade" / nil
function ShipBuildingData:GetDoneType()
    if self.state ~= ShipBuildingState.Done then return nil end
    if self.unlock == 0 then
        return "unlock"   -- 解锁完成待领取
    else
        return "upgrade"  -- 升级完成待领取
    end
end

--- 是否处于废墟修复中（对标 BuildingDate:IsInFix）
function ShipBuildingData:IsInFix()
    return self.destroyEndTime > 0 and os.time() < self.destroyEndTime
end

--- 是否修复完成（对标 BuildingDate:IsFixFinish）
function ShipBuildingData:IsFixFinish()
    return self.destroyEndTime > 0 and os.time() >= self.destroyEndTime
end

--- 获取升级/解锁剩余秒数
function ShipBuildingData:GetRemainSeconds()
    if self.updateTime <= 0 then return 0 end
    local remain = self.updateTime - os.time()
    return remain > 0 and remain or 0
end

--- 建造进度 0~1（对标 BuildingDate:GetBuildProgress）
function ShipBuildingData:GetBuildProgress()
    return self.mainExp == 0 and 0 or (self.subExp / self.mainExp)
end

--- ---------------------------------------------------------------
--- 初始化
--- ---------------------------------------------------------------

--- 首次创建一栋新建筑（本地初始化，无服务器数据时调用）
function ShipBuildingData:InitNew(buildId, uuid)
    self:Reset()
    self.itemId   = buildId
    self.uuid     = uuid
    self.level    = 0
    self.unlock   = 0
    self.state    = ShipBuildingState.Locked
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

--- 从服务器数据包初始化（登录/重连时调用）
--- 字段命名对标 BuildingDate:UpdateInfo 中的 message 字段
function ShipBuildingData:InitFromServer(message)
    -- TODO: 服务器同步
    -- self.uuid             = message["uuid"]
    -- self.itemId           = message["bId"]
    -- self.level            = message["lv"]          or 0
    -- self.unlock           = message["unlock"]      or 0
    -- self.state            = message["state"]       or ShipBuildingState.Locked
    -- self.startTime        = message["sT"]          or 0
    -- self.updateTime       = message["uT"]          or 0
    -- self.lastCollectTime  = message["lCT"]         or 0
    -- self.produceEndTime   = message["pEndT"]       or 0
    -- self.isHelped         = message["help"]        or 0
    -- self.destroyEndTime   = message["dEndT"]       or 0
    -- self.destroyStartTime = message["dStT"]        or 0
    -- self.peopleStation    = message["peopleStation"] or 0
    -- self.mainExp          = message["mainExp"]     or 0
    -- self.subExp           = message["subExp"]      or 0
    -- -- 根据 state 推断 ShipBuildingState
    -- if self.unlock == 1 and self.level > 0 then
    --     if self.updateTime > 0 and os.time() < self.updateTime then
    --         self.state = ShipBuildingState.Upgrading
    --         self.upgradeTargetLevel = self.level + 1
    --     else
    --         self.state = ShipBuildingState.Idle
    --     end
    -- elseif self.updateTime > 0 and self.level == 0 then
    --     self.state = ShipBuildingState.Unlocking
    -- else
    --     self.state = ShipBuildingState.Locked
    -- end
end

--- 序列化为发给服务器的数据包
function ShipBuildingData:ToServerMessage()
    -- TODO: 服务器同步
    -- return {
    --     uuid    = self.uuid,
    --     bId     = self.itemId,
    --     lv      = self.level,
    --     unlock  = self.unlock,
    --     state   = self.state,
    --     sT      = self.startTime,
    --     uT      = self.updateTime,
    --     lCT     = self.lastCollectTime,
    --     pEndT   = self.produceEndTime,
    -- }
    return {}
end

return ShipBuildingData
