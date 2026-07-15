--[[
-- 连连看玩家数据（解锁状态等）
-- 单例，PlayerPrefs 持久化。key = themeId .. "_" .. elementId
--]]

require "Framework.Common.BaseClass"

local PREFS_KEY = "LianLian_UnlockData"

local LianLianPlayer = BaseClass("LianLianPlayer", Singleton)

function LianLianPlayer:__init()
    self.unlocked = {}   -- { ["1_5"] = true, ... }
    self:LoadFromPrefs()
end

--- 组装解锁 key
local function makeKey(themeId, elementId)
    return tostring(themeId) .. "_" .. tostring(elementId)
end

--- 从 PlayerPrefs 载入（逗号分隔的 key 串）
function LianLianPlayer:LoadFromPrefs()
    self.unlocked = {}
    local str = CS.UnityEngine.PlayerPrefs.GetString(PREFS_KEY, "")
    if str and str ~= "" then
        for token in string.gmatch(str, "([^,]+)") do
            self.unlocked[token] = true
        end
    end
end

--- 持久化到 PlayerPrefs
function LianLianPlayer:SaveToPrefs()
    local list = {}
    for key, v in pairs(self.unlocked) do
        if v then list[#list + 1] = key end
    end
    CS.UnityEngine.PlayerPrefs.SetString(PREFS_KEY, table.concat(list, ","))
    CS.UnityEngine.PlayerPrefs.Save()
end

--- 某元素是否已解锁
--- @param themeId number
--- @param elementId number
--- @return boolean
function LianLianPlayer:IsElementUnlocked(themeId, elementId)
    return self.unlocked[makeKey(themeId, elementId)] == true
end

--- 解锁某元素（写入 + 保存 + 广播）
--- @param themeId number
--- @param elementId number
function LianLianPlayer:UnlockElement(themeId, elementId)
    local key = makeKey(themeId, elementId)
    if self.unlocked[key] then return end
    self.unlocked[key] = true
    self:SaveToPrefs()
    EventManager:GetInstance():Broadcast("LianLian_UnlockUpdate", {
        themeId = themeId,
        elementId = elementId,
    })
end

--- 主题是否有任意元素解锁（可选，供主题级高亮）
--- @param themeId number
--- @return boolean
function LianLianPlayer:IsThemeUnlocked(themeId)
    local prefix = tostring(themeId) .. "_"
    for key, v in pairs(self.unlocked) do
        if v and key:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

return LianLianPlayer
