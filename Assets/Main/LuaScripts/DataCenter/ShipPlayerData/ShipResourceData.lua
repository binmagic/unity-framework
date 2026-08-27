---
--- 飞船玩家资源本地内存数据对象
--- 对标项目中的 ResourceInfo + ResourceItemData
--- 统一管理基础资源（食材/金属/电力等）和道具（加速券/资源包等）
---
---@class ShipResourceData
local ShipResourceData = BaseClass("ShipResourceData")

function ShipResourceData:__init()
    self:Reset()
end

function ShipResourceData:__delete()
    self:Reset()
end

function ShipResourceData:Reset()
    --- 基础资源，key = itemId（对应 CfgBuildingLevel.lvup_cost 中的资源 id）
    --- 例：102001=食材, 102002=金属, 102003=电力, 102004=有机质, 102005=科技点
    ---@type table<number, number>
    self.resources = {}

    --- 基础资源上限，key = itemId
    ---@type table<number, number>
    self.resourceMax = {}

    --- 道具背包，key = itemId，value = 数量
    --- 例：加速券、资源包等消耗型道具
    ---@type table<number, number>
    self.items = {}

    --- 道具背包上限（-1 表示无上限）
    self.itemMax = -1

    --- 钻石（硬货币）
    self.diamond = 0

    --- 金币（软货币）
    self.gold = 0
end

--- ---------------------------------------------------------------
--- 基础资源操作
--- ---------------------------------------------------------------

--- 获取某类资源当前数量
---@param itemId number
---@return number
function ShipResourceData:GetResource(itemId)
    return self.resources[itemId] or 0
end

--- 获取某类资源上限（0 表示未设置上限）
---@param itemId number
---@return number
function ShipResourceData:GetResourceMax(itemId)
    return self.resourceMax[itemId] or 0
end

--- 设置某类资源数量（直接赋值，用于服务器同步回写）
---@param itemId number
---@param amount number
function ShipResourceData:SetResource(itemId, amount)
    self.resources[itemId] = math.max(0, amount)
end

--- 设置某类资源上限
---@param itemId number
---@param maxAmount number
function ShipResourceData:SetResourceMax(itemId, maxAmount)
    self.resourceMax[itemId] = maxAmount
end

--- 增加资源（不超过上限，上限为 0 时不限制）
---
--- 上限只拦"增加"，不会把已经超出上限的存量倒扣回去：
--- 服务器下发、活动补偿、测试默认值都可能让存量高于当前仓库容量，
--- 那种情况下继续产出应该是"涨不上去"，而不是"一产出就被没收到上限"。
---@param itemId number
---@param delta number  正数增加，负数减少
---@return boolean  是否操作成功（减少时资源不足返回 false）
function ShipResourceData:ChangeResource(itemId, delta)
    local cur = self:GetResource(itemId)
    local newVal = cur + delta
    if newVal < 0 then
        return false
    end
    local maxVal = self:GetResourceMax(itemId)
    if maxVal > 0 and delta > 0 and newVal > maxVal then
        -- already-over-cap 时保持原值（cur），否则夹到上限
        newVal = math.max(cur, maxVal)
    end
    self.resources[itemId] = newVal
    return true
end

--- 某资源是否已达/超过上限（上限为 0 视为不限制，永不满）
---@param itemId number
---@return boolean
function ShipResourceData:IsResourceFull(itemId)
    local maxVal = self:GetResourceMax(itemId)
    if maxVal <= 0 then return false end
    return self:GetResource(itemId) >= maxVal
end

--- 批量消耗资源（原子操作：全部满足才扣除，否则不扣）
--- costList 格式：{{itemId=102001, count=200000}, ...}
---@param costList table
---@return boolean ok
---@return number|nil lackItemId  第一个不足的 itemId
function ShipResourceData:ConsumeCostList(costList)
    if not costList or #costList == 0 then return true end
    -- 先检查全部是否足够
    for _, cost in ipairs(costList) do
        if self:GetResource(cost.itemId) < cost.count then
            return false, cost.itemId
        end
    end
    -- 全部足够，统一扣除
    for _, cost in ipairs(costList) do
        self.resources[cost.itemId] = self.resources[cost.itemId] - cost.count
    end
    return true
end

--- ---------------------------------------------------------------
--- 道具操作
--- ---------------------------------------------------------------

--- 获取某道具数量
---@param itemId number
---@return number
function ShipResourceData:GetItemCount(itemId)
    return self.items[itemId] or 0
end

--- 设置某道具数量（直接赋值，用于服务器同步回写）
---@param itemId number
---@param count number
function ShipResourceData:SetItemCount(itemId, count)
    self.items[itemId] = math.max(0, count)
end

--- 增减道具数量
---@param itemId number
---@param delta number
---@return boolean
function ShipResourceData:ChangeItem(itemId, delta)
    local cur = self:GetItemCount(itemId)
    local newVal = cur + delta
    if newVal < 0 then return false end
    self.items[itemId] = newVal
    return true
end

--- ---------------------------------------------------------------
--- 货币操作
--- ---------------------------------------------------------------

--- 消耗钻石
---@param amount number
---@return boolean
function ShipResourceData:ConsumeDiamond(amount)
    if self.diamond < amount then return false end
    self.diamond = self.diamond - amount
    return true
end

--- 消耗金币
---@param amount number
---@return boolean
function ShipResourceData:ConsumeGold(amount)
    if self.gold < amount then return false end
    self.gold = self.gold - amount
    return true
end

--- ---------------------------------------------------------------
--- 服务器同步接口（暂不实现，留好接口）
--- ---------------------------------------------------------------

--- 从服务器下发的资源数据包初始化
--- message: 服务器返回的 resource 字段 table
function ShipResourceData:InitFromServer(message)
    -- TODO: 服务器同步 — 解析 message 填充 resources / items / diamond / gold
    -- 示例：
    -- local res = message["resource"]
    -- if res then
    --     self.resources[102001] = res["food"]   or 0
    --     self.resources[102002] = res["metal"]  or 0
    --     self.resources[102003] = res["power"]  or 0
    --     self.resources[102004] = res["organic"] or 0
    --     self.resources[102005] = res["tech"]   or 0
    --     self.diamond = res["diamond"] or 0
    --     self.gold    = res["gold"]    or 0
    -- end
    -- local items = message["resource_items"]
    -- if items then
    --     for _, item in ipairs(items) do
    --         self.items[item["itemId"]] = item["number"] or item["count"] or 0
    --     end
    -- end
end

--- 序列化为发给服务器的数据包
function ShipResourceData:ToServerMessage()
    -- TODO: 服务器同步 — 将本对象字段打包为协议格式
    return {}
end

--- 从服务器增量更新（UserResSynNew 协议推送时调用）
--- message: 服务器推送的资源变化 table
function ShipResourceData:ApplyServerDelta(message)
    -- TODO: 服务器同步 — 解析增量变化并更新本地数据
    -- 示例：
    -- local res = message["resource"]
    -- if res then
    --     for itemId, amount in pairs(res) do
    --         self:SetResource(tonumber(itemId), amount)
    --     end
    -- end
end

return ShipResourceData
