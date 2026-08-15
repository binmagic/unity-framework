--[[
-- [INPUT]: 纯 Lua 常量表,无外部模块依赖
-- [OUTPUT]: 对外提供 UIStrCache(按索引返回预置的 UI 节点路径字符串)
-- [POS]: Util 的 UI 字符串缓存,把高频 UI 节点路径预生成为常量表,避免运行期反复拼接字符串产生 GC,服务常用界面渲染
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
-- 一些UI中常用的字符串，为了减少无用的组合GC
-- 这里做好缓存机制
-- 尤其是常用UI，避免字符串来回的组合处理


local UIStrCache = {}


--------------------
-- PromptView --
local tPromptView_BarText = {
	"Bars1/Bar/Text", "Bars2/Bar/Text", "Bars3/Bar/Text", "Bars4/Bar/Text",
}
local tPromptView_ItemIcon = {
	"Bars1/Bar/ItemIcon", "Bars2/Bar/ItemIcon", "Bars3/Bar/ItemIcon", "Bars4/Bar/ItemIcon",
}
local tPromptView_PText = {
	"ParentObject/P/HP1/HP1", "ParentObject/P/HP2/HP2", "ParentObject/P/HP3/HP3", 
	"ParentObject/P/HP4/HP4", "ParentObject/P/HP5/HP5", "ParentObject/P/HP6/HP6", 
	"ParentObject/P/HP7/HP7", "ParentObject/P/HP8/HP8", "ParentObject/P/HP9/HP9"
}

local tPromptView_Z = {
	"ParentObject/Z1", "ParentObject/Z2", "ParentObject/Z3",
	"ParentObject/Z4", "ParentObject/Z5", "ParentObject/Z6",
	"ParentObject/Z7", "ParentObject/Z8", "ParentObject/Z9"
}

local tPromptView_ZText = {
	"/HP1/HP1", "/HP2/HP2", "/HP3/HP3", 
	"/HP4/HP4", "/HP5/HP5", "/HP6/HP6", 
	"/HP7/HP7", "/HP8/HP8", "/HP9/HP9"
}

function UIStrCache.PromptView_BarText(index)
	return tPromptView_BarText[index]
end

function UIStrCache.PromptView_ItemIcon(index)
	return tPromptView_ItemIcon[index]
end

function UIStrCache.PromptView_PText(index)
	return tPromptView_PText[index]
end

function UIStrCache.PromptView_Z(index)
	return tPromptView_Z[index]
end

function UIStrCache.PromptView_ZText(index)
	return tPromptView_ZText[index]
end



return UIStrCache
