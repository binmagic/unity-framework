--[[
-- PlayerInfo - 玩家自身数据实体
-- 存放玩家核心信息：uid、等级、VIP 等，由 LuaEntry.Player 持有。
-- 登录消息回来时通过 Parse(message) 从网络下发数据填充。
--]]

---@class PlayerInfo
local PlayerInfo = BaseClass("PlayerInfo")

-- 盘面题材配置表（LuaDatatable.Theme_Config）：
-- 字段 { id, name, desc, atlas, type_count, unlock_reward, sort }
-- 每个题材的"类型总数"由配置 type_count 驱动，玩家数据只存"已解锁了哪些类型"。
local THEME_CONFIG = "Theme_Config"

--- 读取某题材配置的类型总数（type_count）
--- @param themeId number 题材 ID
--- @return number 类型总数（读不到配置返回 0）
local function getThemeTypeCount(themeId)
    local cfg = require("LuaDatatable." .. THEME_CONFIG)
    if cfg == nil or cfg.data == nil or cfg.index == nil then return 0 end
    local row = cfg.data[themeId]
    if row == nil then return 0 end
    local col = cfg.index["type_count"]
    if col == nil then return 0 end
    return row[col[1]] or 0
end

local function __init(self)
    self.uid = 0            -- 玩家唯一 ID
    self.name = ""          -- 玩家昵称
    self.level = 1          -- 玩家等级
    self.exp = 0            -- 当前经验
    self.vip = 0            -- VIP 等级
    self.vipExp = 0         -- VIP 经验
    self.avatar = ""        -- 头像
    self.power = 0          -- 战力

    -- 框架读表 AB 测试逻辑期望的成员（GetABTestTableName）
    self.abTest = 0         -- AB 分组（0=A 组，不切换 B 表）
    self.gmFlag = 0         -- GM 标记（0=非 GM，不走 GM 表）

    -- 盘面题材解锁数据（只存已解锁的类型，题材总数由 Theme_Config.type_count 驱动）
    -- 结构：{ [themeId] = { [typeIndex] = true, ... } }
    -- typeIndex 为题材内类型序号(1..type_count)；类型在游戏中逐个解锁，
    -- 当某题材已解锁数达到配置 type_count 时，该题材整体可用。
    self.themeUnlock = {}
end

local function __delete(self)
    self.uid = nil
    self.name = nil
    self.level = nil
    self.exp = nil
    self.vip = nil
    self.vipExp = nil
    self.avatar = nil
    self.power = nil
    self.abTest = nil
    self.gmFlag = nil
    self.themeUnlock = nil
end

--- 获取（必要时创建）某题材的已解锁类型集合
--- @param themeId number 题材 ID
--- @return table { [typeIndex] = true }
local function getUnlockedSet(self, themeId)
    local set = self.themeUnlock[themeId]
    if set == nil then
        set = {}
        self.themeUnlock[themeId] = set
    end
    return set
end

--- 解锁某题材下的一个类型
--- @param themeId number 题材 ID（对应 Theme_Config.id）
--- @param typeIndex number 题材内类型序号(1..type_count)
local function UnlockThemeType(self, themeId, typeIndex)
    getUnlockedSet(self, themeId)[typeIndex] = true
end

--- 判断某题材下的某个类型是否已解锁
--- @param themeId number 题材 ID
--- @param typeIndex number 题材内类型序号
--- @return boolean
local function IsThemeTypeUnlocked(self, themeId, typeIndex)
    local set = self.themeUnlock[themeId]
    return set ~= nil and set[typeIndex] == true
end

--- 获取某题材已解锁的类型数量
--- @param themeId number 题材 ID
--- @return number
local function GetUnlockedTypeCount(self, themeId)
    local set = self.themeUnlock[themeId]
    if set == nil then return 0 end
    local count = 0
    for _ in pairs(set) do
        count = count + 1
    end
    return count
end

--- 判断某题材是否整体解锁（所有类型都已解锁 → 可使用）
--- 总数由 Theme_Config.type_count 驱动
--- @param themeId number 题材 ID
--- @return boolean
local function IsThemeUnlocked(self, themeId)
    local total = getThemeTypeCount(themeId)
    if total <= 0 then return false end
    return GetUnlockedTypeCount(self, themeId) >= total
end

--- 获取 GM 标记（框架读表 AB 逻辑用；0=非 GM）
--- @return number
local function GetGMFlag(self)
    return self.gmFlag or 0
end

--- 从网络下发数据解析填充
--- @param message table 服务器下发的玩家数据
local function Parse(self, message)
    if message == nil then return end
    if message["uid"] ~= nil then self.uid = message["uid"] end
    if message["name"] ~= nil then self.name = message["name"] end
    if message["level"] ~= nil then self.level = message["level"] end
    if message["exp"] ~= nil then self.exp = message["exp"] end
    if message["vip"] ~= nil then self.vip = message["vip"] end
    if message["vipExp"] ~= nil then self.vipExp = message["vipExp"] end
    if message["avatar"] ~= nil then self.avatar = message["avatar"] end
    if message["power"] ~= nil then self.power = message["power"] end

    -- themeUnlock 下发格式：{ [themeId] = { typeIndex, ... } }（已解锁的类型序号数组）
    if message["themeUnlock"] ~= nil then
        self.themeUnlock = {}
        for themeId, unlockedList in pairs(message["themeUnlock"]) do
            local set = getUnlockedSet(self, themeId)
            for _, typeIndex in ipairs(unlockedList) do
                set[typeIndex] = true
            end
        end
    end
end

PlayerInfo.__init = __init
PlayerInfo.__delete = __delete
PlayerInfo.Parse = Parse
PlayerInfo.UnlockThemeType = UnlockThemeType
PlayerInfo.IsThemeTypeUnlocked = IsThemeTypeUnlocked
PlayerInfo.GetUnlockedTypeCount = GetUnlockedTypeCount
PlayerInfo.IsThemeUnlocked = IsThemeUnlocked
PlayerInfo.GetGMFlag = GetGMFlag

return PlayerInfo
