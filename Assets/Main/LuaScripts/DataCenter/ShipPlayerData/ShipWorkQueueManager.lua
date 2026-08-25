---
--- 飞船建造队列管理器（本地内存版）
--- 管理多条并行建造队列，支持建筑升级/解锁任务排队
---
--- 配置表：
---   WorkQueue_Config — 队列槽位配置（id, season, group, type, icon, jumpid, is_free, cost, bonues）
---
--- 设计：
---   - 第1条队列默认解锁（免费）
---   - 后续队列需要消耗资源或满足条件解锁
---   - 每条队列同时只能处理一个任务
---   - 任务完成后自动通知 ShipPlayerDataManager 写入建筑等级
---
---@class ShipWorkQueueManager
local ShipWorkQueueManager = BaseClass("ShipWorkQueueManager")

local ShipWorkQueueData = require "DataCenter.ShipPlayerData.ShipWorkQueueData"

--- 解析费用字符串 "101001,500" -> {{itemId=101001,count=500}}
local function ParseCostString(costStr)
    local result = {}
    if not costStr or costStr == "" then
        return result
    end
    for segment in string.gmatch(costStr, "[^;]+") do
        local itemId, count = string.match(segment, "%s*(%d+)%s*,%s*(%d+)%s*")
        if itemId and count then
            table.insert(result, { itemId = tonumber(itemId), count = tonumber(count) })
        end
    end
    return result
end

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function ShipWorkQueueManager:__init()
    ---@type ShipWorkQueueData[]  index = slotIndex（1-based）
    self.slots      = {}
    ---@type table<number, table>  index = slotIndex, 解锁消耗配置
    self.slotCosts  = {}
    self.tickTimer  = nil

    self:_InitDefaultSlots()
end

function ShipWorkQueueManager:__delete()
    self:_StopTimer()
    self.slots = nil
    self.slotCosts = nil
end

function ShipWorkQueueManager:Startup()
    self:_StartTimer()
end

function ShipWorkQueueManager:_StartTimer()
    if self.tickTimer then return end
    self.tickTimer = TimerManager:GetInstance():GetTimer(1, self.Tick, self, false, false, false)
    self.tickTimer:Start()
end

function ShipWorkQueueManager:_StopTimer()
    if self.tickTimer then
        self.tickTimer:Stop()
        self.tickTimer = nil
    end
end

--- ---------------------------------------------------------------
--- 初始化：根据 WorkQueue_Config 表创建队列槽位
--- WorkQueue_Config 目前数据为空，默认创建 2 条队列（第1条免费解锁）
--- ---------------------------------------------------------------

function ShipWorkQueueManager:_InitDefaultSlots()
    local slotList = {}
    LocalController:instance():visitTable(TableName.WorkQueue_Config, function(rowId, lineData)
        local id      = tonumber(lineData:getValue("id")) or 0
        local isFree  = tonumber(lineData:getValue("is_free")) or 0
        local cost    = lineData:getValue("cost") or ""
        if id > 0 then
            table.insert(slotList, { id = id, isFree = isFree, cost = cost })
        end
    end)

    -- 按 id 排序
    table.sort(slotList, function(a, b) return a.id < b.id end)

    -- 配置表为空时默认 2 条队列
    if #slotList == 0 then
        slotList = {{id=1, isFree=1, cost=""}, {id=2, isFree=1, cost=""}}
    end

    for i, info in ipairs(slotList) do
        local slot = ShipWorkQueueData.New()
        slot:InitSlot(i, info.isFree == 1)
        self.slots[i] = slot
        self.slotCosts[i] = ParseCostString(info.cost)
    end

    Logger.Log(string.format("[ShipWorkQueueManager] 初始化 %d 条建造队列", #slotList))
end

--- ---------------------------------------------------------------
--- 查询接口
--- ---------------------------------------------------------------

--- 获取所有队列槽位
---@return ShipWorkQueueData[]
function ShipWorkQueueManager:GetAllSlots()
    return self.slots
end

--- 获取指定槽位
---@param slotIndex number  1-based
---@return ShipWorkQueueData|nil
function ShipWorkQueueManager:GetSlot(slotIndex)
    return self.slots[slotIndex]
end

--- 获取总队列数
---@return number
function ShipWorkQueueManager:GetSlotCount()
    return #self.slots
end

--- 获取已解锁的队列数
---@return number
function ShipWorkQueueManager:GetUnlockedSlotCount()
    local count = 0
    for _, slot in ipairs(self.slots) do
        if slot.isUnlocked then count = count + 1 end
    end
    return count
end

--- 查找第一个空闲且已解锁的槽位
---@return ShipWorkQueueData|nil
function ShipWorkQueueManager:FindIdleSlot()
    for _, slot in ipairs(self.slots) do
        if slot.isUnlocked and slot:IsIdle() then
            return slot
        end
    end
    return nil
end

--- 查找某建筑是否已在队列中
---@param buildId number
---@return ShipWorkQueueData|nil
function ShipWorkQueueManager:FindSlotByBuildId(buildId)
    for _, slot in ipairs(self.slots) do
        if not slot:IsIdle() and slot.buildId == buildId then
            return slot
        end
    end
    return nil
end

--- 获取当前正在运行的任务数
---@return number
function ShipWorkQueueManager:GetRunningCount()
    local count = 0
    for _, slot in ipairs(self.slots) do
        if not slot:IsIdle() then count = count + 1 end
    end
    return count
end

--- ---------------------------------------------------------------
--- 解锁队列槽位
--- ---------------------------------------------------------------

---@param slotIndex number
---@return boolean ok
---@return string|nil errMsg
function ShipWorkQueueManager:UnlockSlot(slotIndex)
    local slot = self.slots[slotIndex]
    if not slot then
        return false, "槽位不存在 slotIndex=" .. tostring(slotIndex)
    end
    if slot.isUnlocked then
        return false, "槽位已解锁"
    end

    -- 检查解锁资源消耗
    local costList = self.slotCosts[slotIndex]
    if costList and #costList > 0 then
        local ok, lackItemId = DataCenter.ShipPlayerDataManager:CheckCostEnough(costList)
        if not ok then
            return false, "资源不足 itemId=" .. tostring(lackItemId)
        end
        -- 扣除资源
        DataCenter.ShipPlayerDataManager.resourceData:ConsumeCostList(costList)
    end

    slot.isUnlocked = true
    Logger.Log(string.format("[ShipWorkQueueManager] 解锁队列槽位 %d", slotIndex))
    EventManager:GetInstance():Broadcast(EventId.ShipWorkQueueSlotUnlocked, { slotIndex = slotIndex })
    return true
end

--- ---------------------------------------------------------------
--- 提交任务到队列
--- ---------------------------------------------------------------

--- 将建筑升级/解锁任务提交到空闲队列
---@param taskType number  ShipWorkQueueTaskType
---@param buildId number
---@param buildUuid number
---@param targetLevel number
---@param durationSeconds number
---@return boolean ok
---@return string|nil errMsg  失败原因 / "queue_full" 表示队列满
function ShipWorkQueueManager:SubmitTask(taskType, buildId, buildUuid, targetLevel, durationSeconds)
    -- 检查该建筑是否已在队列中
    local existing = self:FindSlotByBuildId(buildId)
    if existing then
        return false, "该建筑已在建造队列中 slotIndex=" .. tostring(existing.slotIndex)
    end

    local slot = self:FindIdleSlot()
    if not slot then
        return false, "queue_full"
    end

    slot:StartTask(taskType, buildId, buildUuid, targetLevel, durationSeconds)

    Logger.Log(string.format("[ShipWorkQueueManager] 提交任务 slot=%d taskType=%d buildId=%d targetLv=%d 耗时=%ds",
        slot.slotIndex, taskType, buildId, targetLevel, durationSeconds))

    EventManager:GetInstance():Broadcast(EventId.ShipWorkQueueTaskStart, {
        slotIndex    = slot.slotIndex,
        taskType     = taskType,
        buildId      = buildId,
        buildUuid    = buildUuid,
        targetLevel  = targetLevel,
    })
    return true
end

--- 根据建筑 uuid 清理队列中的任务（领取建筑完成后调用）
---@param buildUuid number
function ShipWorkQueueManager:ClearTaskByBuildUuid(buildUuid)
    for _, slot in ipairs(self.slots) do
        if not slot:IsIdle() and slot.buildUuid == buildUuid then
            Logger.Log(string.format("[ShipWorkQueueManager] 清理队列槽位 %d buildUuid=%d",
                slot.slotIndex, buildUuid))
            slot:ClearTask()
            EventManager:GetInstance():Broadcast(EventId.ShipWorkQueueTaskFinish, {
                slotIndex = slot.slotIndex,
            })
            return
        end
    end
end

--- 根据建筑 buildId 清理队列中的任务（测试重置时调用）
---@param buildId number
function ShipWorkQueueManager:ClearTaskByBuildId(buildId)
    for _, slot in ipairs(self.slots) do
        if not slot:IsIdle() and slot.buildId == buildId then
            Logger.Log(string.format("[ShipWorkQueueManager] 清理队列槽位 %d buildId=%d",
                slot.slotIndex, buildId))
            slot:ClearTask()
            return
        end
    end
end

--- ---------------------------------------------------------------
--- 立即完成（加速）
--- ---------------------------------------------------------------

---@param slotIndex number
---@return boolean ok
---@return string|nil errMsg
function ShipWorkQueueManager:SpeedUpSlot(slotIndex)
    local slot = self.slots[slotIndex]
    if not slot or slot:IsIdle() then
        return false, "槽位空闲或不存在"
    end
    -- 立即将完成时间设为当前时间，Tick 会在下一秒处理
    slot.finishTime = os.time()
    Logger.Log(string.format("[ShipWorkQueueManager] 加速队列槽位 %d", slotIndex))
    return true
end

--- ---------------------------------------------------------------
--- Tick：每秒检查任务是否自然完成
--- ---------------------------------------------------------------

function ShipWorkQueueManager:Tick()
    for _, slot in ipairs(self.slots) do
        if not slot:IsIdle() then
            -- 方式1：自然倒计时结束
            if slot:IsFinished() then
                self:_OnTaskFinished(slot)
            else
                -- 方式2：建筑状态已变为 Done（可能由外部直接完成或手动设置）
                local buildData = DataCenter.ShipPlayerDataManager
                    and DataCenter.ShipPlayerDataManager.buildingMap
                    and DataCenter.ShipPlayerDataManager.buildingMap[slot.buildUuid]
                if buildData and buildData:IsDone() then
                    self:_OnTaskFinished(slot)
                end
            end
        end
    end
end

function ShipWorkQueueManager:_OnTaskFinished(slot)
    local taskType   = slot.taskType
    local buildId    = slot.buildId
    local buildUuid  = slot.buildUuid
    local targetLevel = slot.targetLevel

    Logger.Log(string.format("[ShipWorkQueueManager] 任务完成 slot=%d taskType=%d buildId=%d targetLv=%d",
        slot.slotIndex, taskType, buildId, targetLevel))

    -- 通知 ShipPlayerDataManager 完成建筑升级/解锁
    if taskType == ShipWorkQueueTaskType.Unlock then
        DataCenter.ShipPlayerDataManager:FinishUnlockBuilding(buildUuid)
    elseif taskType == ShipWorkQueueTaskType.Upgrade then
        DataCenter.ShipPlayerDataManager:FinishUpgradeBuilding(buildUuid)
    end

    -- 清空槽位
    slot:ClearTask()

    EventManager:GetInstance():Broadcast(EventId.ShipWorkQueueTaskFinish, {
        slotIndex   = slot.slotIndex,
        taskType    = taskType,
        buildId     = buildId,
        buildUuid   = buildUuid,
        targetLevel = targetLevel,
    })
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

function ShipWorkQueueManager:InitFromServer(message)
    -- TODO: 服务器同步
    -- local queueArr = message["ship_work_queues"]
    -- if queueArr then
    --     for _, q in ipairs(queueArr) do
    --         local slotIndex = q["slot"] or 1
    --         local slot = self.slots[slotIndex]
    --         if slot then
    --             slot:InitFromServer(q)
    --         end
    --     end
    -- end
end

return ShipWorkQueueManager
