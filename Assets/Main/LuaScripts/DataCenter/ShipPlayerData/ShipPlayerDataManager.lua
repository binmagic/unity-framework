---
--- 飞船玩家数据管理器（本地内存版）
--- 统一管理建筑数据 + 资源数据
---
--- 设计原则：
---   1. 所有操作只修改本地内存，不直接发网络请求
---   2. 网络发送由调用方（Controller）负责，Manager 只负责数据一致性
---   3. 服务器回包后调用 ApplyServerXxx 系列接口更新本地数据
---   4. 数据变更后广播 EventId，UI 层监听刷新
---
---@class ShipPlayerDataManager
local ShipPlayerDataManager = BaseClass("ShipPlayerDataManager")

local ShipBuildingData    = require "DataCenter.ShipPlayerData.ShipBuildingData"
local ShipResourceData    = require "DataCenter.ShipPlayerData.ShipResourceData"
local ShipSelfPlayerData  = require "DataCenter.ShipPlayerData.ShipSelfPlayerData"
local ShipOtherPlayerData = require "DataCenter.ShipPlayerData.ShipOtherPlayerData"

--- 本地 uuid 自增计数器（服务器同步前使用负数，避免与服务器 uuid 冲突）
local LOCAL_UUID_COUNTER = -1
local function NextLocalUuid()
    LOCAL_UUID_COUNTER = LOCAL_UUID_COUNTER - 1
    return LOCAL_UUID_COUNTER
end

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function ShipPlayerDataManager:__init()
    ---@type table<number, ShipBuildingData>  key = uuid
    self.buildingMap  = {}
    ---@type table<number, number[]>  key = itemId，value = uuid 列表
    self.buildIdIndex = {}
    ---@type ShipResourceData
    self.resourceData = ShipResourceData.New()
    ---@type ShipSelfPlayerData
    self.selfPlayer   = ShipSelfPlayerData.New()
    ---@type table<string, ShipOtherPlayerData>  key = uid
    self.otherPlayers = {}
    ---@type table<number, boolean>  升级中的建筑 uuid 集合
    self.upgradingSet = {}
    ---@type table<number, boolean>  解锁中的建筑 uuid 集合
    self.unlockingSet = {}
    self.tickTimer    = nil

    self:_InitDefaultBuildings()
    self:_InitDefaultResources()
    self:_InitDefaultSelfPlayer()
end

function ShipPlayerDataManager:__delete()
    self:_StopTimer()
    self.buildingMap  = nil
    self.buildIdIndex = nil
    self.resourceData = nil
    self.selfPlayer   = nil
    self.otherPlayers = nil
    self.upgradingSet = nil
    self.unlockingSet = nil
end

--- 游戏启动后由框架调用，启动每秒 Tick
function ShipPlayerDataManager:Startup()
    self:_StartTimer()
end

function ShipPlayerDataManager:_StartTimer()
    if self.tickTimer then return end
    self.tickTimer = TimerManager:GetInstance():GetTimer(1, self.Tick, self, false, false, false)
    self.tickTimer:Start()
end

function ShipPlayerDataManager:_StopTimer()
    if self.tickTimer then
        self.tickTimer:Stop()
        self.tickTimer = nil
    end
end

--- ---------------------------------------------------------------
--- 初始化
--- ---------------------------------------------------------------

--- 根据 Building_Config 表创建所有建筑的初始本地数据
function ShipPlayerDataManager:_InitDefaultBuildings()
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        local buildId = tonumber(rowId)
        if not buildId then return end
        local data = ShipBuildingData.New()
        data:InitNew(buildId, NextLocalUuid())
        self:_AddToIndex(data)
    end)
end

--- 初始化本地测试用资源默认值
--- 服务器联调后由 InitFromServer 替换，届时可删除此函数
function ShipPlayerDataManager:_InitDefaultResources()
    self.resourceData:SetResource(102001, 999999999)  -- 食材
    self.resourceData:SetResource(102002, 999999999)  -- 金属
    self.resourceData:SetResource(102003, 999999999)  -- 电力
    self.resourceData:SetResource(102004, 999999999)  -- 有机质
    self.resourceData:SetResource(102005, 999999999)  -- 科技点
    self.resourceData:SetResource(102006, 0)          -- 科技点（新增，科技研究中心产出）
end

--- 初始化本地测试用玩家数据默认值
--- 服务器联调后由 InitFromServer 替换，届时可删除此函数
---
--- level 给 30 而不是 1：Building_Levelup_Config 的升级前置是
--- "建筑升到 N 级需要玩家 N 级"（condType=3, require1_unlock=N，N 最大 8）。
--- 玩家停在 1 级时只能解锁、升 2 级就被拦住，本地测试根本走不到后续内容
--- （家具升级不查等级，但它依赖建筑等级，于是一起卡死）。
local DEFAULT_TEST_PLAYER_LEVEL = 30

function ShipPlayerDataManager:_InitDefaultSelfPlayer()
    self.selfPlayer.uid       = "local_player"
    self.selfPlayer.name      = "指挥官"
    self.selfPlayer.level     = DEFAULT_TEST_PLAYER_LEVEL
    self.selfPlayer.exp       = 0
    self.selfPlayer.gold      = 9999
    self.selfPlayer.shipName  = "我的空间站"
    self.selfPlayer.shipLevel = DEFAULT_TEST_PLAYER_LEVEL
end

--- ---------------------------------------------------------------
--- 建筑索引维护（内部）
--- ---------------------------------------------------------------

function ShipPlayerDataManager:_AddToIndex(buildData)
    self.buildingMap[buildData.uuid] = buildData
    if not self.buildIdIndex[buildData.itemId] then
        self.buildIdIndex[buildData.itemId] = {}
    end
    table.insert(self.buildIdIndex[buildData.itemId], buildData.uuid)
end

function ShipPlayerDataManager:_RemoveFromIndex(buildData)
    self.buildingMap[buildData.uuid] = nil
    local list = self.buildIdIndex[buildData.itemId]
    if list then
        for i, uuid in ipairs(list) do
            if uuid == buildData.uuid then
                table.remove(list, i)
                break
            end
        end
    end
end

--- ---------------------------------------------------------------
--- 建筑查询
--- ---------------------------------------------------------------

---@param uuid number
---@return ShipBuildingData|nil
function ShipPlayerDataManager:GetBuildingByUuid(uuid)
    return self.buildingMap[uuid]
end

--- 获取某类型建筑的所有数据列表
---@param buildId number  对应 Building_Config.id（即 ShipBuildingData.itemId）
---@return ShipBuildingData[]
function ShipPlayerDataManager:GetBuildingsByBuildId(buildId)
    local result = {}
    local uuids  = self.buildIdIndex[buildId]
    if not uuids then return result end
    for _, uuid in ipairs(uuids) do
        local d = self.buildingMap[uuid]
        if d then table.insert(result, d) end
    end
    return result
end

--- 获取某类型建筑中等级最高的那栋
---@param buildId number
---@return ShipBuildingData|nil
function ShipPlayerDataManager:GetMaxLevelBuilding(buildId)
    local list = self:GetBuildingsByBuildId(buildId)
    local best = nil
    for _, d in ipairs(list) do
        if not best or d.level > best.level then
            best = d
        end
    end
    return best
end

--- 获取某类型建筑的最高等级（未拥有返回 0）
---@param buildId number
---@return number
function ShipPlayerDataManager:GetMaxBuildingLevel(buildId)
    local d = self:GetMaxLevelBuilding(buildId)
    return d and d.level or 0
end

--- 检查某类型建筑是否已解锁（unlock == 1 且 level > 0）
---@param buildId number
---@return boolean
function ShipPlayerDataManager:IsBuildingUnlocked(buildId)
    local d = self:GetMaxLevelBuilding(buildId)
    return d ~= nil and d.unlock == 1 and d.level > 0
end

--- 获取所有已解锁建筑的 buildId 列表（去重，按 Building_Config 顺序）
---@return number[]
function ShipPlayerDataManager:GetUnlockedBuildIdList()
    local result  = {}
    local visited = {}
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        local bid = tonumber(rowId)
        if bid and not visited[bid] and self:IsBuildingUnlocked(bid) then
            visited[bid] = true
            table.insert(result, bid)
        end
    end)
    return result
end

--- 获取所有建筑的 buildId 列表（含未解锁，按 Building_Config 顺序）
--- 返回配置表全量数据，不做数量裁剪。
--- 展示层如需限制格子数，由 View 自行截取（见 UIShipCabinView 的 MAX_ROOM_DISPLAY）。
---@return number[]
function ShipPlayerDataManager:GetAllBuildIdList()
    local result  = {}
    local visited = {}
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        local bid = tonumber(rowId)
        if bid and not visited[bid] then
            visited[bid] = true
            table.insert(result, bid)
        end
    end)
    return result
end

--- ---------------------------------------------------------------
--- 玩家数据查询
--- ---------------------------------------------------------------

--- 获取自身玩家数据
---@return ShipSelfPlayerData
function ShipPlayerDataManager:GetSelfPlayer()
    return self.selfPlayer
end

--- 获取自身玩家等级
---@return number
function ShipPlayerDataManager:GetSelfLevel()
    return self.selfPlayer.level
end

--- 获取自身玩家名称（优先飞船名）
---@return string
function ShipPlayerDataManager:GetSelfDisplayName()
    return self.selfPlayer:GetDisplayName()
end

--- 获取自身总战力（所有已解锁建筑战力之和，实时计算）
---@return number
function ShipPlayerDataManager:CalcTotalPower()
    local total = 0
    for _, buildData in pairs(self.buildingMap) do
        if buildData.unlock == 1 and buildData.level > 0 then
            total = total + buildData.power
        end
    end
    self.selfPlayer.totalPower = total
    return total
end

--- 获取其他玩家数据（有缓存且未过期则直接返回，否则返回 nil 需重新拉取）
---@param uid string
---@return ShipOtherPlayerData|nil
function ShipPlayerDataManager:GetOtherPlayer(uid)
    local d = self.otherPlayers[uid]
    if d and d:IsCacheValid() then
        return d
    end
    return nil
end

--- 缓存其他玩家数据（服务器回包后调用）
---@param uid string
---@param data ShipOtherPlayerData
function ShipPlayerDataManager:CacheOtherPlayer(uid, data)
    self.otherPlayers[uid] = data
end

--- 清除其他玩家缓存（退出查看界面时调用）
---@param uid string
function ShipPlayerDataManager:ClearOtherPlayerCache(uid)
    self.otherPlayers[uid] = nil
end

--- ---------------------------------------------------------------
--- 资源查询
--- ---------------------------------------------------------------

---@param itemId number
---@return number
function ShipPlayerDataManager:GetResourceCount(itemId)
    return self.resourceData:GetResource(itemId)
end

---@param itemId number
---@return number
function ShipPlayerDataManager:GetItemCount(itemId)
    return self.resourceData:GetItemCount(itemId)
end

--- 统计某资源的每分钟产出速率（供资源栏显示 "N/分钟" 副标签）
--- 遍历所有已解锁且有等级的产出建筑，累加 realOutput / realCD * 60
--- 计算方式与 _TickProduction 保持一致（含家具的产量加成和CD缩减）
---@param itemId number 资源ID
---@return number 每分钟产出量（向下取整）
function ShipPlayerDataManager:GetResourceRatePerMinute(itemId)
    local total = 0
    for _, buildData in pairs(self.buildingMap) do
        if buildData.unlock == 1 and buildData.level > 0 then
            local produceCD = GetTableNumber(TableName.Building_Config, buildData.itemId, "produce_cd") or 0
            if produceCD > 0 then
                local productRaw = GetTableData(TableName.Building_Config, buildData.itemId, "product") or ""
                local productId  = tonumber(string.match(productRaw, "^(%d+)")) or 0
                if productId == itemId then
                    local productBase = GetTableNumber(TableName.Building_Config, buildData.itemId, "product_base") or 0
                    local outputInc, cdDec = 0, 0
                    if DataCenter.ShipFurnitureManager then
                        outputInc = DataCenter.ShipFurnitureManager:GetBuildingOutputInc(buildData.itemId)
                        cdDec     = DataCenter.ShipFurnitureManager:GetBuildingCDDec(buildData.itemId)
                    end
                    local realOutput = productBase + outputInc
                    local realCD     = math.max(produceCD - cdDec, 1)
                    total = total + realOutput / realCD * 60
                end
            end
        end
    end
    return math.floor(total)
end

--- 检查费用列表是否全部满足
--- costList 格式：{{itemId=102001, count=200000}, ...}
---@return boolean ok
---@return number|nil lackItemId
function ShipPlayerDataManager:CheckCostEnough(costList)
    if not costList or #costList == 0 then return true end
    for _, cost in ipairs(costList) do
        if self.resourceData:GetResource(cost.itemId) < cost.count then
            return false, cost.itemId
        end
    end
    return true
end

--- ---------------------------------------------------------------
--- 解锁建筑（本地内存操作）
--- ---------------------------------------------------------------

--- 开始解锁建筑
--- 调用方（Controller）负责校验完成后调用此函数，再发网络请求
--- 服务器回包后调用 ApplyServerUnlockResult
---@param buildId number
---@param costList table
---@param unlockSeconds number  0 = 立即完成
---@return boolean ok
---@return string|nil errMsg
function ShipPlayerDataManager:StartUnlockBuilding(buildId, costList, unlockSeconds)
    local buildData = self:GetMaxLevelBuilding(buildId)
    if not buildData then
        return false, "找不到建筑数据 buildId=" .. tostring(buildId)
    end
    if buildData.unlock == 1 then
        return false, "建筑已解锁"
    end
    if buildData:IsBusy() then
        return false, "建筑正在解锁/升级中或待领取"
    end

    local ok, lackItemId = self.resourceData:ConsumeCostList(costList)
    if not ok then
        return false, "资源不足 itemId=" .. tostring(lackItemId)
    end

    local now = os.time()
    if unlockSeconds <= 0 then
        -- 立即完成：直接写入解锁状态，不走待领取流程
        buildData.unlock      = 1
        buildData.level       = 1
        buildData.state       = ShipBuildingState.Idle
        buildData.startTime   = now
        buildData.updateTime  = now
        self:_RefreshBuildingPower(buildData)
        self:CalcTotalPower()
        EventManager:GetInstance():Broadcast(EventId.ShipBuildingUnlockFinish,
            { buildId = buildId, uuid = buildData.uuid })
        EventManager:GetInstance():Broadcast(EventId.ShipPlayerInfoUpdated)
    else
        buildData.state       = ShipBuildingState.Unlocking
        buildData.startTime   = now
        buildData.updateTime  = now + unlockSeconds
        self.unlockingSet[buildData.uuid] = true
        -- 提交到建造队列（仅占位，不走队列自动完成）
        if DataCenter.ShipWorkQueueManager then
            DataCenter.ShipWorkQueueManager:SubmitTask(
                ShipWorkQueueTaskType.Unlock, buildId, buildData.uuid, 1, unlockSeconds)
        end
    end

    EventManager:GetInstance():Broadcast(EventId.ShipBuildingUnlockStart,
        { buildId = buildId, uuid = buildData.uuid })
    return true
end

--- 完成解锁（Tick 到期后进入 Done 待领取状态）
---@param uuid number
function ShipPlayerDataManager:FinishUnlockBuilding(uuid)
    local buildData = self.buildingMap[uuid]
    if not buildData then return end
    if not buildData:IsUnlocking() then return end

    -- 进入待领取状态，不立即写入 unlock/level，等玩家手动领取
    buildData.state             = ShipBuildingState.Done
    buildData.updateTime        = os.time()
    self.unlockingSet[uuid]     = nil

    EventManager:GetInstance():Broadcast(EventId.ShipBuildingUnlockDone,
        { buildId = buildData.itemId, uuid = uuid })
end

--- ---------------------------------------------------------------
--- 领取建筑结果（玩家手动点领取后调用）
--- 适用于解锁完成待领取 / 升级完成待领取
--- ---------------------------------------------------------------

---@param uuid number
---@return boolean ok
---@return string|nil errMsg
function ShipPlayerDataManager:CollectBuildingResult(uuid)
    local buildData = self.buildingMap[uuid]
    if not buildData then
        return false, "找不到建筑数据 uuid=" .. tostring(uuid)
    end
    if not buildData:IsDone() then
        return false, "建筑不在待领取状态 state=" .. tostring(buildData.state)
    end

    local doneType = buildData:GetDoneType()
    local now      = os.time()

    if doneType == "unlock" then
        -- 解锁完成：写入解锁状态
        buildData.unlock     = 1
        buildData.level      = 1
        buildData.state      = ShipBuildingState.Idle
        buildData.updateTime = now
        self:_RefreshBuildingPower(buildData)
        EventManager:GetInstance():Broadcast(EventId.ShipBuildingUnlockFinish,
            { buildId = buildData.itemId, uuid = uuid })

    elseif doneType == "upgrade" then
        -- 升级完成：写入新等级
        buildData.level      = buildData.upgradeTargetLevel
        buildData.state      = ShipBuildingState.Idle
        buildData.updateTime = now
        self:_RefreshBuildingPower(buildData)
        EventManager:GetInstance():Broadcast(EventId.ShipBuildingUpgradeFinish,
            { buildId = buildData.itemId, uuid = uuid })
    else
        return false, "未知 doneType"
    end

    -- 刷新总战力并通知 UI
    self:CalcTotalPower()
    EventManager:GetInstance():Broadcast(EventId.ShipPlayerInfoUpdated)

    -- 清理建造队列中的对应槽位
    if DataCenter.ShipWorkQueueManager then
        DataCenter.ShipWorkQueueManager:ClearTaskByBuildUuid(uuid)
    end

    local buildName = GetTableData(TableName.Building_Config, buildData.itemId, "name") or "?"
    Logger.Log(string.format("[ShipPlayerDataManager] CollectBuildingResult uuid=%d name=%s doneType=%s level=%d power=%d totalPower=%d",
        uuid, buildName, tostring(doneType), buildData.level, buildData.power, self.selfPlayer.totalPower))
    return true
end

--- ---------------------------------------------------------------
--- 升级建筑（本地内存操作）
--- ---------------------------------------------------------------

--- 开始升级建筑
--- 调用方（Controller）负责校验完成后调用此函数，再发网络请求
--- 服务器回包后调用 ApplyServerUpgradeResult
---@param buildId number
---@param costList table
---@param upgradeSeconds number  0 = 立即完成
---@param nextLevel number
---@return boolean ok
---@return string|nil errMsg
function ShipPlayerDataManager:StartUpgradeBuilding(buildId, costList, upgradeSeconds, nextLevel)
    local buildData = self:GetMaxLevelBuilding(buildId)
    if not buildData then
        return false, "找不到建筑数据 buildId=" .. tostring(buildId)
    end
    if buildData.unlock ~= 1 then
        return false, "建筑未解锁"
    end
    if buildData:IsBusy() then
        local reason = ({
            [ShipBuildingState.Upgrading] = "升级中",
            [ShipBuildingState.Unlocking] = "解锁中",
            [ShipBuildingState.Done]      = "待领取",
        })[buildData.state] or "忙碌"
        Logger.LogWarning(string.format("[ShipPlayerDataManager] StartUpgradeBuilding 拒绝 buildId=%d uuid=%d 当前状态=%s(%s)",
            buildId, buildData.uuid, reason, tostring(buildData.state)))
        return false, "建筑正在升级中或待领取"
    end

    local maxLevel = GetTableNumber(TableName.Building_Config, buildId, "level_limit") or 1
    if buildData.level >= maxLevel then
        return false, "建筑已满级"
    end

    local ok, lackItemId = self.resourceData:ConsumeCostList(costList)
    if not ok then
        return false, "资源不足 itemId=" .. tostring(lackItemId)
    end

    local now = os.time()
    if upgradeSeconds <= 0 then
        -- 立即完成也走待领取流程，保持体验统一
        buildData.state               = ShipBuildingState.Done
        buildData.startTime           = now
        buildData.updateTime          = now
        buildData.upgradeTargetLevel  = nextLevel
        Logger.Log(string.format("[ShipPlayerDataManager] 升级开始(立即完成) buildId=%d uuid=%d lv%d→lv%d 耗时=0s → 直接进入待领取",
            buildId, buildData.uuid, buildData.level, nextLevel))
        EventManager:GetInstance():Broadcast(EventId.ShipBuildingUpgradeDone,
            { buildId = buildId, uuid = buildData.uuid })
    else
        buildData.state               = ShipBuildingState.Upgrading
        buildData.startTime           = now
        buildData.updateTime          = now + upgradeSeconds
        buildData.upgradeTargetLevel  = nextLevel
        self.upgradingSet[buildData.uuid] = true
        -- 提交到建造队列（仅占位，不走队列自动完成）
        if DataCenter.ShipWorkQueueManager then
            DataCenter.ShipWorkQueueManager:SubmitTask(
                ShipWorkQueueTaskType.Upgrade, buildId, buildData.uuid, nextLevel, upgradeSeconds)
        end
        Logger.Log(string.format("[ShipPlayerDataManager] 升级开始 buildId=%d uuid=%d lv%d→lv%d 耗时=%ds 完成时间=%d upgradingSet大小=%d",
            buildId, buildData.uuid, buildData.level, nextLevel, upgradeSeconds, buildData.updateTime, self:_CountSet(self.upgradingSet)))
    end

    EventManager:GetInstance():Broadcast(EventId.ShipBuildingUpgradeStart,
        { buildId = buildId, uuid = buildData.uuid })
    return true
end

--- 完成升级（Tick 到期后进入 Done 待领取状态）
---@param uuid number
function ShipPlayerDataManager:FinishUpgradeBuilding(uuid)
    local buildData = self.buildingMap[uuid]
    if not buildData then return end
    if not buildData:IsUpgrading() then return end

    -- 进入待领取状态，不立即写入 level，等玩家手动领取
    buildData.state          = ShipBuildingState.Done
    buildData.updateTime     = os.time()
    self.upgradingSet[uuid]  = nil

    Logger.Log(string.format("[ShipPlayerDataManager] 升级完成(待领取) buildId=%d uuid=%d 目标等级=%d → 请点击领取",
        buildData.itemId, uuid, buildData.upgradeTargetLevel))

    EventManager:GetInstance():Broadcast(EventId.ShipBuildingUpgradeDone,
        { buildId = buildData.itemId, uuid = uuid })
end

--- ---------------------------------------------------------------
--- Tick：每秒检查升级/解锁是否自然完成
--- ---------------------------------------------------------------

function ShipPlayerDataManager:Tick()
    for uuid, _ in pairs(self.upgradingSet) do
        local d = self.buildingMap[uuid]
        if d and d:IsUpgradeFinished() then
            self:FinishUpgradeBuilding(uuid)
        end
    end
    for uuid, _ in pairs(self.unlockingSet) do
        local d = self.buildingMap[uuid]
        if d and d:IsUnlockFinished() then
            self:FinishUnlockBuilding(uuid)
        end
    end
    self:_TickProduction()
end

--- ---------------------------------------------------------------
--- 产出 Tick：每秒累计产出CD，达到实际CD后产出资源
--- 仅处理 Building_Config.produce_cd > 0 的建筑
--- ---------------------------------------------------------------

function ShipPlayerDataManager:_TickProduction()
    for _, buildData in pairs(self.buildingMap) do
        -- 只处理已解锁且有等级的建筑
        if buildData.unlock ~= 1 or buildData.level <= 0 then
            goto continue
        end

        local produceCD = GetTableNumber(TableName.Building_Config, buildData.itemId, "produce_cd") or 0
        if produceCD <= 0 then
            goto continue  -- 非产出建筑跳过
        end

        local productBase = GetTableNumber(TableName.Building_Config, buildData.itemId, "product_base") or 0
        -- product 字段格式：资源ID 或 资源ID,数量（取逗号前的部分）
        local productRaw  = GetTableData(TableName.Building_Config, buildData.itemId, "product") or ""
        local productId   = tonumber(string.match(productRaw, "^(%d+)")) or 0
        if productId <= 0 then
            goto continue  -- 没有配置产出资源ID，跳过
        end

        -- 读家具效果（需要 ShipFurnitureManager 已初始化）
        local outputInc = 0
        local cdDec     = 0
        if DataCenter.ShipFurnitureManager then
            outputInc = DataCenter.ShipFurnitureManager:GetBuildingOutputInc(buildData.itemId)
            cdDec     = DataCenter.ShipFurnitureManager:GetBuildingCDDec(buildData.itemId)
        end

        local realOutput = productBase + outputInc
        local realCD     = math.max(produceCD - cdDec, 1)  -- CD最小1秒，防止除零

        buildData.cdAccum = buildData.cdAccum + 1
        if buildData.cdAccum >= realCD then
            buildData.cdAccum = buildData.cdAccum - realCD  -- 保留余量，不归零
            self.resourceData:ChangeResource(productId, realOutput)
            EventManager:GetInstance():Broadcast(EventId.ShipResourceUpdated,
                { itemId = productId, delta = realOutput })
            Logger.Log(string.format("[ShipPlayerDataManager] 产出触发 buildId=%d productId=%d output=%s realCD=%.2fs",
                buildData.itemId, productId, tostring(realOutput), realCD))
        end

        ::continue::
    end
end

--- ---------------------------------------------------------------
--- 内部工具
--- ---------------------------------------------------------------

--- 统计 set 表的元素数量（用于日志）
function ShipPlayerDataManager:_CountSet(set)
    local n = 0
    for _ in pairs(set) do n = n + 1 end
    return n
end

--- Building_Levelup_Config 缓存索引: [buildLv][buildId] = power
local _powerIndex = nil
local function _GetBuildingPowerFromConfig(buildId, level)
    if _powerIndex == nil then
        _powerIndex = {}
        LocalController:instance():visitTable(TableName.Building_Levelup_Config, function(rowId, lineData)
            local blv = tonumber(lineData:getValue("build_lv"))
            if not blv then return end
            if not _powerIndex[blv] then _powerIndex[blv] = {} end
            -- 遍历 lvup_unlock_1..37，解析每个建筑的战力
            -- 字段格式：buildId|effType;effArg  例 "1|1;10" = 建筑1 效果类型1(战力) 值10
            -- 多个效果之间用 ; 分隔时形如 "1|1;10;2;5"，即 | 之后是 effType;effArg 交替序列
            for n = 1, 37 do
                local unlockVal = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_unlock_" .. n)
                if unlockVal and unlockVal ~= "" then
                    local bid = tonumber(string.match(unlockVal, "^(%d+)|"))
                    if bid then
                        local rest = string.match(unlockVal, "^%d+|(.+)$") or ""
                        -- 按 ; 拆成扁平序列，成对取 (effType, effArg)
                        local parts = {}
                        for seg in string.gmatch(rest, "[^;]+") do
                            table.insert(parts, seg)
                        end
                        for i = 1, #parts - 1, 2 do
                            local effType = tonumber(parts[i])
                            local effArg  = tonumber(parts[i + 1])
                            if effType == 1 then
                                _powerIndex[blv][bid] = effArg or 0
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
    if _powerIndex[level] then
        return _powerIndex[level][buildId] or 0
    end
    return 0
end

--- 刷新建筑战力缓存（从 Building_Levelup_Config 读取）
function ShipPlayerDataManager:_RefreshBuildingPower(buildData)
    if buildData.level <= 0 then
        buildData.power = 0
        return
    end
    buildData.power = _GetBuildingPowerFromConfig(buildData.itemId, buildData.level)
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

--- 服务器初始化数据下发（登录/重连时调用）
function ShipPlayerDataManager:InitFromServer(message)
    -- TODO: 服务器同步
    -- -- 玩家基础数据
    -- self.selfPlayer:InitFromServer(message)
    --
    -- -- 建筑数据
    -- self.buildingMap  = {}
    -- self.buildIdIndex = {}
    -- local buildings = message["ship_buildings"]
    -- if buildings then
    --     for _, b in ipairs(buildings) do
    --         local d = ShipBuildingData.New()
    --         d:InitFromServer(b)
    --         self:_AddToIndex(d)
    --         self:_RefreshBuildingPower(d)
    --         if d:IsUpgrading() then
    --             self.upgradingSet[d.uuid] = true
    --         elseif d:IsUnlocking() then
    --             self.unlockingSet[d.uuid] = true
    --         end
    --     end
    -- end
    --
    -- -- 资源数据
    -- self.resourceData:InitFromServer(message)
    --
    -- -- 刷新总战力
    -- self:CalcTotalPower()
end

--- 服务器玩家信息增量推送（改名、升级、战力变化等）
function ShipPlayerDataManager:ApplyServerPlayerDelta(message)
    -- TODO: 服务器同步
    -- self.selfPlayer:ApplyServerDelta(message)
    -- EventManager:GetInstance():Broadcast(EventId.ShipPlayerInfoUpdated)
end

--- 服务器其他玩家数据回包（查看他人信息时调用）
function ShipPlayerDataManager:ApplyServerOtherPlayerData(message)
    -- TODO: 服务器同步
    -- local uid = tostring(message["uid"] or "")
    -- if uid == "" then return end
    -- local d = ShipOtherPlayerData.New()
    -- d:InitFromServer(message)
    -- self:CacheOtherPlayer(uid, d)
    -- EventManager:GetInstance():Broadcast(EventId.ShipOtherPlayerDataUpdated, { uid = uid })
end

--- 服务器解锁结果回包
function ShipPlayerDataManager:ApplyServerUnlockResult(message)
    -- TODO: 服务器同步
    -- local uuid = message["uuid"]
    -- local d = self.buildingMap[uuid]
    -- if d then
    --     d:InitFromServer(message)
    --     self:_RefreshBuildingPower(d)
    --     self.unlockingSet[uuid] = nil
    -- end
    -- self.resourceData:ApplyServerDelta(message)
    -- self:CalcTotalPower()
    -- EventManager:GetInstance():Broadcast(EventId.ShipBuildingUnlockFinish, { uuid = uuid })
end

--- 服务器升级结果回包
function ShipPlayerDataManager:ApplyServerUpgradeResult(message)
    -- TODO: 服务器同步
    -- local uuid = message["uuid"]
    -- local d = self.buildingMap[uuid]
    -- if d then
    --     d:InitFromServer(message)
    --     self:_RefreshBuildingPower(d)
    --     self.upgradingSet[uuid] = nil
    -- end
    -- self.resourceData:ApplyServerDelta(message)
    -- self:CalcTotalPower()
    -- EventManager:GetInstance():Broadcast(EventId.ShipBuildingUpgradeFinish, { uuid = uuid })
end

--- 服务器资源增量推送
function ShipPlayerDataManager:ApplyServerResourceDelta(message)
    -- TODO: 服务器同步
    -- self.resourceData:ApplyServerDelta(message)
    -- EventManager:GetInstance():Broadcast(EventId.ShipResourceUpdated)
end

return ShipPlayerDataManager
