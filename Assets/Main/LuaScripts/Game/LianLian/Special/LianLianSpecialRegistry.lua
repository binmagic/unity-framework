--[[
-- 连连看「特殊元素」注册表（策略模式）
--
-- 每种特殊元素 = 一个 def 表，实现约定的钩子接口（全部可选，不实现即用默认行为）。
-- 加新特殊元素 = 新建一个 Special/Types/XXX.lua，require 时调 register 自注册，
-- 不需要改动核心代码。
--
-- def 字段与钩子约定：
--   type        string  唯一标识（cell.specialType 存的就是它），必填
--   name        string  显示名（Debug 下拉展示用）
--   icon        string  可选，特殊显示图路径（角标/覆盖），供 onShow 默认装扮用
--
--   onShow(tile, cell)                    -- tile 创建/刷新时装扮：角标、变色、挂特效节点等
--   canMatch(grid, a, b) -> bool | nil    -- 覆盖默认配对判定；返回 nil 表示"用默认 isSameId"
--   onCleared(mgr, layer, pos, ctx)       -- 该元素被消除时触发：炸周围/解冻邻格…，可追加消除
--   playClearFx(tile)                     -- 消除动画时的特效表现
--]]

local LianLianSpecialRegistry = {}

-- type -> def
local _defs = {}
-- 注册顺序（供 Debug 下拉按注册序展示）
local _order = {}

--- 注册一个特殊元素定义
--- @param def table 见文件头约定，必须含 def.type
function LianLianSpecialRegistry.register(def)
    if type(def) ~= "table" or def.type == nil then
        Logger.LogError("[LianLian][Special] register 失败：def 缺少 type 字段")
        return
    end
    if _defs[def.type] == nil then
        _order[#_order + 1] = def.type
    end
    _defs[def.type] = def
end

--- 取某类型的 def；type 为 nil 或未注册返回 nil
function LianLianSpecialRegistry.get(type)
    if type == nil then return nil end
    return _defs[type]
end

--- 是否已注册该类型
function LianLianSpecialRegistry.has(type)
    return type ~= nil and _defs[type] ~= nil
end

--- 按专属 id 反查 def（cell.id 是特殊 id 时用）；无匹配返回 nil
function LianLianSpecialRegistry.getById(id)
    if id == nil then return nil end
    for _, def in pairs(_defs) do
        if def.id == id then return def end
    end
    return nil
end

--- 判断某 id 是否属于特殊元素（已注册的特殊 id）
function LianLianSpecialRegistry.isSpecialId(id)
    return LianLianSpecialRegistry.getById(id) ~= nil
end

--- 按注册顺序返回所有 def 列表 { def, def, ... }（供 Debug 下拉遍历）
function LianLianSpecialRegistry.all()
    local list = {}
    for _, t in ipairs(_order) do
        list[#list + 1] = _defs[t]
    end
    return list
end

--- 便捷：调用某类型的某个钩子（存在才调），返回钩子结果
--- @param stype string cell.specialType
--- @param hook string 钩子名（onShow/canMatch/onCleared/playClearFx）
function LianLianSpecialRegistry.invoke(stype, hook, ...)
    local def = LianLianSpecialRegistry.get(stype)
    if def and type(def[hook]) == "function" then
        return def[hook](...)
    end
    return nil
end

-- 注：类型的 require 放在独立的 LianLianSpecialTypes.lua 里统一触发，
-- 不在此处 require（否则与 Types 互相 require 造成循环加载）。

return LianLianSpecialRegistry
