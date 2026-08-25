---
--- 飞船建造队列单条任务数据对象
--- 每个队列槽位对应一个 ShipWorkQueueData 实例
--- 支持建筑升级/解锁任务排队
---
---@class ShipWorkQueueData
local ShipWorkQueueData = BaseClass("ShipWorkQueueData")

--- 队列任务类型
ShipWorkQueueTaskType = ShipWorkQueueTaskType or {
    None    = 0,   -- 空闲
    Unlock  = 1,   -- 解锁建筑
    Upgrade = 2,   -- 升级建筑
}

function ShipWorkQueueData:__init()
    self:Reset()
end

function ShipWorkQueueData:__delete()
    self:Reset()
end

--- ---------------------------------------------------------------
--- 字段定义
--- ---------------------------------------------------------------

function ShipWorkQueueData:Reset()
    self.slotIndex    = 0       -- 队列槽位索引（1 = 第一条队列，2 = 第二条，...）
    self.taskType     = ShipWorkQueueTaskType.None
    self.buildId      = 0       -- 正在处理的建筑 ID
    self.buildUuid    = 0       -- 正在处理的建筑 uuid
    self.targetLevel  = 0       -- 目标等级
    self.startTime    = 0       -- 任务开始时间戳（秒）
    self.finishTime   = 0       -- 任务完成时间戳（秒）
    self.isUnlocked   = false   -- 该槽位是否已解锁（第1条默认解锁，其余需要条件）
end

--- ---------------------------------------------------------------
--- 状态判断
--- ---------------------------------------------------------------

--- 槽位是否空闲（无任务）
function ShipWorkQueueData:IsIdle()
    return self.taskType == ShipWorkQueueTaskType.None
end

--- 任务是否正在进行中（倒计时未结束）
function ShipWorkQueueData:IsRunning()
    return self.taskType ~= ShipWorkQueueTaskType.None
        and self.finishTime > os.time()
end

--- 任务是否已自然完成（倒计时结束，等待系统处理）
function ShipWorkQueueData:IsFinished()
    return self.taskType ~= ShipWorkQueueTaskType.None
        and self.finishTime > 0
        and os.time() >= self.finishTime
end

--- 获取剩余秒数
function ShipWorkQueueData:GetRemainSeconds()
    if self.finishTime <= 0 then return 0 end
    local remain = self.finishTime - os.time()
    return remain > 0 and remain or 0
end

--- ---------------------------------------------------------------
--- 初始化
--- ---------------------------------------------------------------

function ShipWorkQueueData:InitSlot(slotIndex, isUnlocked)
    self:Reset()
    self.slotIndex  = slotIndex
    self.isUnlocked = isUnlocked
end

--- 开始一个任务
---@param taskType number  ShipWorkQueueTaskType
---@param buildId number
---@param buildUuid number
---@param targetLevel number
---@param durationSeconds number  0 = 立即完成
function ShipWorkQueueData:StartTask(taskType, buildId, buildUuid, targetLevel, durationSeconds)
    local now = os.time()
    self.taskType    = taskType
    self.buildId     = buildId
    self.buildUuid   = buildUuid
    self.targetLevel = targetLevel
    self.startTime   = now
    self.finishTime  = durationSeconds > 0 and (now + durationSeconds) or now
end

--- 清空任务（任务完成后调用）
function ShipWorkQueueData:ClearTask()
    self.taskType    = ShipWorkQueueTaskType.None
    self.buildId     = 0
    self.buildUuid   = 0
    self.targetLevel = 0
    self.startTime   = 0
    self.finishTime  = 0
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

function ShipWorkQueueData:InitFromServer(message)
    -- TODO: 服务器同步
    -- self.slotIndex   = message["slot"]       or 0
    -- self.taskType    = message["taskType"]   or ShipWorkQueueTaskType.None
    -- self.buildId     = message["buildId"]    or 0
    -- self.buildUuid   = message["buildUuid"]  or 0
    -- self.targetLevel = message["targetLv"]   or 0
    -- self.startTime   = message["sT"]         or 0
    -- self.finishTime  = message["fT"]         or 0
    -- self.isUnlocked  = message["unlocked"]   or false
end

function ShipWorkQueueData:ToServerMessage()
    -- TODO: 服务器同步
    return {}
end

return ShipWorkQueueData
