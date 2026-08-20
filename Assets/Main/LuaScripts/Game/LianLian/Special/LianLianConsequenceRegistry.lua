--[[
-- 连连看「消除后果」注册表（C 类：与具体元素无关的全局规则）
--
-- 后果 = 监听「每次成功消除」这一事件本身的规则（稀有度掉落/连击充能/潮汐补行…），
-- 不绑定任何具体格或元素，靠一个全局计数/状态驱动。
--
-- 加新后果 = 新建 Special/Consequences/XXX.lua，require 时调 register 自注册，
-- 不改核心。Manager 在 doClear 消除成功后调 fireAfterMatch，遍历所有后果。
--
-- def 字段与钩子约定：
--   type    string  唯一标识，必填
--   name    string  显示名
--   onAfterMatch(mgr, layer, ctx)   -- 每次成功消除后调用
--       ctx = { cells={a,b}, matchCount=该层累计消除对数, comboCount=预留 }
--]]

local LianLianConsequenceRegistry = {}

local _defs = {}
local _order = {}

--- 注册一个消除后果定义
function LianLianConsequenceRegistry.register(def)
    if type(def) ~= "table" or def.type == nil then
        Logger.LogError("[LianLian][Consequence] register 失败：def 缺少 type 字段")
        return
    end
    if _defs[def.type] == nil then
        _order[#_order + 1] = def.type
    end
    _defs[def.type] = def
end

--- 取某类型 def
function LianLianConsequenceRegistry.get(ctype)
    if ctype == nil then return nil end
    return _defs[ctype]
end

--- 按注册顺序返回所有 def
function LianLianConsequenceRegistry.all()
    local list = {}
    for _, t in ipairs(_order) do
        list[#list + 1] = _defs[t]
    end
    return list
end

return LianLianConsequenceRegistry
