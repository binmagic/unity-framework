---
--- STG 怪物子系统 — 2D 刷怪调度器
--- 提炼自 ParkourBattle/Monster/GenMonsterTaskBase.lua 的三种生成算法，去掉了原实现里
--- 对 Scene.LWBattle.Const（怪物出生类型枚举）、队伍系统（RangeGen 圆心跟随队伍 Z 坐标）
--- 的依赖，改成纯参数驱动：谁在用这个调度器，谁负责每帧传入"跟随点"坐标（如卷轴当前位置）。
---
--- 三种模式：
---   FixPoint — 固定点，按 [intervalMin, intervalMax] 随机间隔在原点生成
---   Range    — 大圈内均匀分布，圆心跟随外部传入的 followPoint + offset
---   Round    — 固定圆周，圆心是配置的固定原点
--- 均匀采样算法（大圆切 7 个内切圆再逐个采样）原样保留，是这批代码里最有复用价值的部分。
---
--- 用法：
---   local task = SpawnScheduler2D.New(SpawnScheduler2D.Mode.Range, {
---       originX = 0, originY = 0, radiusOuter = 300, radiusInner = 0,
---       intervalSec = 1.0, limit = 20,
---   })
---   task:Update(dt, function(x, y) --[[ 在 (x,y) 生成一个怪 ]] end, followX, followY)
---
---@class SpawnScheduler2D
local SpawnScheduler2D = BaseClass("SpawnScheduler2D")

local Mode = {
    FixPoint = 1,   -- 固定点
    Range    = 2,   -- 大圈内均匀分布，跟随外部坐标
    Round    = 3,   -- 固定圆周
}
SpawnScheduler2D.Mode = Mode

--- @param mode number SpawnScheduler2D.Mode 的枚举值
--- @param cfg table
---   originX/originY  number  固定点/固定圆周模式的原点坐标
---   radiusOuter      number  Range 模式的大圈半径 / Round 模式的圆周半径
---   radiusInner      number  Range 模式内圈半径（暂只用于保留字段对齐旧配置，采样算法本身不使用）
---   followOffsetX/Y  number  Range 模式下，圆心 = followPoint + offset
---   intervalSec      number  Round/Range 固定间隔（秒）
---   intervalMinSec / intervalMaxSec  number  FixPoint 模式的随机间隔范围
---   limit            number  最多生成次数，达到后 IsFinished() 返回 true
function SpawnScheduler2D:__init(mode, cfg)
    self.mode = mode
    self.cfg = cfg or {}
    self.elapsedSinceLastGen = 0
    self.nextInterval = self:_RollInterval()
    self.genCount = 0
    self.limit = self.cfg.limit or math.huge

    self.inscribedCircleList = nil
    self.inscribedRadius = nil
    self.inscribedCircleIndex = 0
end

function SpawnScheduler2D:IsFinished()
    return self.genCount >= self.limit
end

function SpawnScheduler2D:_RollInterval()
    if self.mode == Mode.FixPoint then
        local mn = self.cfg.intervalMinSec or 1
        local mx = self.cfg.intervalMaxSec or mn
        return mn + math.random() * (mx - mn)
    end
    return self.cfg.intervalSec or 1
end

--- 在大圈内生成 7 个均分的小圈（1 个圆心 + 6 个按 60 度分布），坐标是相对大圈圆心的偏移。
--- 原样保留自 GenMonsterTaskBase:GenInscribedCircleList，仅把 Vector3(x,0,z) 换成 2D 的 {x,y}。
function SpawnScheduler2D:_GenInscribedCircleList()
    local radius = self.cfg.radiusOuter or 200
    local inscribedRadius = radius / 3

    local list = { { x = 0, y = 0 } }
    for i = 1, 6 do
        local radians = math.rad(60 * i)
        local x = inscribedRadius * 2 * math.cos(radians)
        local y = inscribedRadius * 2 * math.sin(radians)
        table.insert(list, { x = x, y = y })
    end

    self.inscribedCircleList = list
    self.inscribedRadius = inscribedRadius
end

--- 依次在均分的小圈内随机找点，尽可能均匀分布（平方根缩放采样避免中心过密）。
--- 原样保留自 GenMonsterTaskBase:GenRandomPosByInscribedCircle。
--- @return number, number 相对大圈圆心的偏移 x, y
function SpawnScheduler2D:_GenRandomPosByInscribedCircle()
    if self.inscribedCircleList == nil then
        self:_GenInscribedCircleList()
    end

    self.inscribedCircleIndex = (self.inscribedCircleIndex % 7) + 1
    local center = self.inscribedCircleList[self.inscribedCircleIndex]

    local angle = math.random() * 2 * math.pi
    local r = math.sqrt(math.random()) * self.inscribedRadius
    local x = center.x + r * math.cos(angle)
    local y = center.y + r * math.sin(angle)
    return x, y
end

--- 每帧推进，到点即通过 onSpawn(x, y) 回调产出一个生成点。
--- @param dt number
--- @param onSpawn fun(x:number, y:number)
--- @param followX number|nil Range 模式需要的跟随坐标（比如卷轴当前 Y），其他模式忽略
--- @param followY number|nil
function SpawnScheduler2D:Update(dt, onSpawn, followX, followY)
    if self:IsFinished() then
        return
    end

    self.elapsedSinceLastGen = self.elapsedSinceLastGen + dt
    if self.elapsedSinceLastGen < self.nextInterval then
        return
    end
    self.elapsedSinceLastGen = 0
    self.nextInterval = self:_RollInterval()

    self.genCount = self.genCount + 1

    local x, y
    if self.mode == Mode.FixPoint then
        x, y = self.cfg.originX or 0, self.cfg.originY or 0

    elseif self.mode == Mode.Range then
        local centerX = (followX or 0) + (self.cfg.followOffsetX or 0)
        local centerY = (followY or 0) + (self.cfg.followOffsetY or 0)
        local ox, oy = self:_GenRandomPosByInscribedCircle()
        x, y = centerX + ox, centerY + oy

    elseif self.mode == Mode.Round then
        local ox, oy = self:_GenRandomPosByInscribedCircle()
        x, y = (self.cfg.originX or 0) + ox, (self.cfg.originY or 0) + oy
    end

    if onSpawn ~= nil and x ~= nil then
        onSpawn(x, y)
    end

    if self.genCount >= self.limit and self.onFinished ~= nil then
        self.onFinished(self)
    end
end

--- 达到 limit 后的回调，供外部调度器（如批量管理多个 task 的上层）清理引用
function SpawnScheduler2D:SetOnFinished(callback)
    self.onFinished = callback
end

return SpawnScheduler2D
