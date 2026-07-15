--[[
-- 连连看主题/元素配置读取（Theme_Config）
-- 提供主题列表、元素数量、元素图路径
--]]

local LianLianTheme = {}

local TABLE_NAME = "Theme_Config"
-- 磁盘上实际存在的元素图套数（目前只有 item_1，共 27 张）
local ATLAS_INDEX = 1
local ELEMENT_SPRITE_MAX = 27
local ELEMENT_PATH = "Assets/_Art_LianLian/ItemSprites/item_%d/%d.png"

--- 获取主题列表（按 sort/顺序）
--- @return table 数组 {{id, name, atlas, typeCount, desc}, ...}
function LianLianTheme.GetThemeList()
    local list = {}
    local LC = LocalController:instance()
    LC:visitTable(TABLE_NAME, function(id, line)
        list[#list + 1] = {
            id = tonumber(id),
            name = line:getValue("name") or ("主题" .. tostring(id)),
            atlas = line:getValue("atlas") or "item_1",
            typeCount = tonumber(line:getValue("type_count")) or ELEMENT_SPRITE_MAX,
            desc = line:getValue("desc") or "",
        }
    end)
    -- 按 id 升序
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

--- 获取某主题的元素数量（clamp 到实际有图的数量）
--- @param themeId number
--- @return number
function LianLianTheme.GetElementCount(themeId)
    local LC = LocalController:instance()
    local typeCount = LC:getIntValue(TABLE_NAME, themeId, "type_count", ELEMENT_SPRITE_MAX)
    -- 磁盘只有 27 张图，超出部分无图可显示
    return math.min(typeCount, ELEMENT_SPRITE_MAX)
end

--- 获取某主题某元素的图路径
--- 注：目前所有主题共用 item_1 资源（磁盘只有这套）
--- @param themeId number
--- @param elementId number
--- @return string
function LianLianTheme.GetElementSpritePath(themeId, elementId)
    return string.format(ELEMENT_PATH, ATLAS_INDEX, elementId)
end

return LianLianTheme
