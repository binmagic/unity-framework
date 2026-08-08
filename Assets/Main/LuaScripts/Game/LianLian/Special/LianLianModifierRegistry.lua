--[[
-- 连连看「格子修饰器」注册表（策略模式）
--
-- 修饰器 = 附着在格子上的持续状态（藤蔓/冰冻/石头/锁链/护盾…），与 cell.id 正交：
-- 一个格可同时有普通牌(或空)和若干修饰器。存储在 cell.mods = { [type]=state, ... }，
-- state 可为 true（开关型）或数字（层数/倒计时型，如冰冻剩 2 次）。
--
-- 加新修饰器 = 新建一个 Special/Modifiers/XXX.lua，require 时调 register 自注册，
-- 不改动核心代码。核心只在关键判定点（连线/选中/相邻消除/显示）遍历修饰器询问钩子。
--
-- def 字段与钩子约定（全部可选，不实现即默认）：
--   type          string  唯一标识（cell.mods 的 key），必填
--   name          string  显示名（Debug 用）
--   icon          string  覆盖图路径（onShow 默认装扮用）
--
--   blocksPath(cell, state) -> bool        -- 该修饰器是否阻挡连线穿过此格
--   blocksSelect(cell, state) -> bool      -- 该修饰器是否使此格不可选中
--   onNeighborCleared(mgr, layer, pos, state) -> newState|nil
--                                          -- 相邻格发生消除时触发；返回新 state
--                                          --   （nil=解除该修饰器；数字=递减后的层数；true=保持）
--   onShow(tile, state)                    -- tile 刷新时装扮外观（挂覆盖图/变色等）
--   defaultState                           -- Debug/布点时的初始 state（缺省 true）
--]]

local LianLianModifierRegistry = {}

-- type -> def
local _defs = {}
-- 注册顺序（供 Debug 遍历）
local _order = {}

--- 注册一个修饰器定义
function LianLianModifierRegistry.register(def)
    if type(def) ~= "table" or def.type == nil then
        Logger.LogError("[LianLian][Modifier] register 失败：def 缺少 type 字段")
        return
    end
    if _defs[def.type] == nil then
        _order[#_order + 1] = def.type
    end
    _defs[def.type] = def
end

--- 取某类型 def
function LianLianModifierRegistry.get(mtype)
    if mtype == nil then return nil end
    return _defs[mtype]
end

--- 按注册顺序返回所有 def（Debug 用）
function LianLianModifierRegistry.all()
    local list = {}
    for _, t in ipairs(_order) do
        list[#list + 1] = _defs[t]
    end
    return list
end

-- ===== 聚合查询：遍历一个 cell 上的所有修饰器，任一命中即生效 =====

--- 该格是否阻挡连线（任一修饰器 blocksPath 为真）
function LianLianModifierRegistry.cellBlocksPath(cell)
    if not cell or not cell.mods then return false end
    for mtype, state in pairs(cell.mods) do
        local def = _defs[mtype]
        if def and def.blocksPath and def.blocksPath(cell, state) then
            return true
        end
    end
    return false
end

--- 该格是否不可选中（任一修饰器 blocksSelect 为真）
function LianLianModifierRegistry.cellBlocksSelect(cell)
    if not cell or not cell.mods then return false end
    for mtype, state in pairs(cell.mods) do
        local def = _defs[mtype]
        if def and def.blocksSelect and def.blocksSelect(cell, state) then
            return true
        end
    end
    return false
end

--- 该格是否有任何修饰器
function LianLianModifierRegistry.cellHasAny(cell)
    if not cell or not cell.mods then return false end
    return next(cell.mods) ~= nil
end

return LianLianModifierRegistry
