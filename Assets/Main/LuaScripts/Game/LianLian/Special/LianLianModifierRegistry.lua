--[[
-- [INPUT]: 依赖 Logger 的 LogError；被 LianLianModifierTypes 触发各 Modifiers/*.lua 的 register
-- [OUTPUT]: 对外提供 register/get/all + 聚合查询 cellBlocksPath/cellBlocksSelect/cellHasAny
-- [POS]: 格子修饰器子系统的策略注册中枢，与 LianLianSpecialRegistry（特殊元素）平级；
--        核心逻辑只依赖本表的稳定接口，具体修饰器（Vine/Ice…）挂在这里，加元素不改核心
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--
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
--   onShow(tile, state)                    -- tile 刷新时装扮「静态外观」（挂覆盖图/变色等）；
--                                          --   幂等：视图层每次刷新都会对现存修饰器调它以恢复显示，
--                                          --   故此钩子内不要放一次性动画（动画走 onEnter/onRemove）
--   onEnter(tile, state)                   -- 修饰器由「无」变「有」时的入场过场（结冰铺开/淡入…）；
--                                          --   视图层仅在「新出现」那一刻调一次，保持态不重播。
--                                          --   不实现则无入场动画（如藤蔓，直接显示）
--   onRemove(tile, state, onDone)          -- 修饰器由「有」变「无」时的消亡过场（震碎/消融…）；
--                                          --   视图层在真正隐藏覆盖层前调此钩子播动画，
--                                          --   动画结束须调 onDone() 让视图收尾。
--                                          --   不实现则默认立即隐藏（如藤蔓，直接 SetActive(false)）
--   -- onEnter/onRemove 是一对对称的「生/死」过场；onShow 只管「此刻长什么样」
--   defaultState                           -- Debug/布点时的初始 state（缺省 true）
--   dbg           table   可选：暴露给 Debug 面板实时调节的表现参数（如 { fps, enterDur, tintA }）；
--                         钩子内读 def.dbg 取值，Debug 侧经 get(type).dbg 就地读写，实现「不改代码调手感」
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
