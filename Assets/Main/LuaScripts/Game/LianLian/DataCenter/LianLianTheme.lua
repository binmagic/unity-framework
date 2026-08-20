--[[
-- 连连看主题/元素配置读取（Theme_Config）
-- 遵循配置表读取规范：走 GetTableData 系列全局函数 + TableName 常量，不手动 require 表。
-- 提供主题列表、元素数量、元素图路径。
--]]

local LianLianTheme = {}

-- 取不到 type_count 时的兜底元素数
local DEFAULT_ELEMENT_COUNT = 1

--- 获取主题列表（按 id 升序）
--- @return table 数组 {{id, name, atlas, typeCount, desc}, ...}
function LianLianTheme.GetThemeList()
    local list = {}
    LocalController:instance():visitTable(TableName.Theme, function(id, lineData)
        list[#list + 1] = {
            id = tonumber(id),
            name = lineData:getStrValue("name") or ("主题" .. tostring(id)),
            atlas = lineData:getStrValue("atlas") or "",
            typeCount = lineData:getIntValue("type_count") or DEFAULT_ELEMENT_COUNT,
            desc = lineData:getStrValue("desc") or "",
        }
    end)
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

--- 获取某主题的元素数量（1 .. type_count）
--- @param themeId number
--- @return number
function LianLianTheme.GetElementCount(themeId)
    local typeCount = GetTableNumber(TableName.Theme, themeId, "type_count")
    if not typeCount or typeCount <= 0 then
        typeCount = DEFAULT_ELEMENT_COUNT
    end
    return typeCount
end

--- 获取某主题某元素的图路径
--- atlas 列是带 {%d} 占位符的完整路径模板，如
--- "Assets/_Art_LianLian/ItemSprites/item_1/{%d}.png"，把 elementId 填入 {%d} 即得完整路径。
--- @param themeId number
--- @param elementId number
--- @return string|nil
function LianLianTheme.GetElementSpritePath(themeId, elementId)
    local template = GetTableString(TableName.Theme, themeId, "atlas")
    if not template or template == "" then return nil end
    -- 把模板里的 {%d} 占位符替换成元素 id（{%%d} 匹配字面量 {%d}）
    return (template:gsub("{%%d}", tostring(elementId)))
end

return LianLianTheme
