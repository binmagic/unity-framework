---
--- STG 触发效果枚举与执行
--- 门/机关命中后通过 effectId 查效果表并执行
--- 首期效果表用本地 Lua 表，后续可改为读策划配置
---@class StgTriggerEnum
local TriggerEnum = {}

TriggerEnum.Type = {
    AddWingman      = 10,  -- para = 数量
    RemoveWingman   = 20,  -- para = 数量
    AddGold         = 30,  -- para = 数量
    MultiplyWingman = 40,  -- para = 倍率
}

--- 效果表：effectId -> { type, para, text, icon }
--- 对齐编辑器 trap.params.effectTableRef / paraTable 里的 effectId
--- 首期硬编码，后续抽到配置表
TriggerEnum.EffectTable = {
    -- 数字门常用（样例 1001 关引用）
    ["eff_zero"]   = { type = TriggerEnum.Type.AddWingman,      para = 0,  text = "+0" },
    ["eff_plus1"]  = { type = TriggerEnum.Type.AddWingman,      para = 1,  text = "+1" },
    ["eff_plus2"]  = { type = TriggerEnum.Type.AddWingman,      para = 2,  text = "+2" },
    ["eff_plus5"]  = { type = TriggerEnum.Type.AddWingman,      para = 5,  text = "+5" },
    ["eff_minus1"] = { type = TriggerEnum.Type.RemoveWingman,   para = 1,  text = "-1" },
    ["eff_minus2"] = { type = TriggerEnum.Type.RemoveWingman,   para = 2,  text = "-2" },

    -- 旧 PlaneTrigger_Config 兼容（20001~20005），数值对齐原表
    ["20001"] = { type = TriggerEnum.Type.AddWingman, para = 2, text = "+2" },
    ["20002"] = { type = TriggerEnum.Type.AddWingman, para = 1, text = "+1" },
    ["20003"] = { type = TriggerEnum.Type.RemoveWingman, para = 1, text = "-1" },
    ["20004"] = { type = TriggerEnum.Type.AddGold, para = 15, text = "+15金" },
    ["20005"] = { type = TriggerEnum.Type.AddGold, para = 25, text = "+25金" },
}

--- 按 effectId 执行效果
--- @param effectId string
--- @param callbacks table { AddWingman=fn(n), RemoveWingman=fn(n), AddGold=fn(n), MultiplyWingman=fn(k) }
--- @return boolean 是否执行成功
function TriggerEnum.Execute(effectId, callbacks)
    if effectId == nil or effectId == "" then
        return false
    end
    local meta = TriggerEnum.EffectTable[effectId]
    if meta == nil then
        Logger.LogError('#STG# 触发效果不存在 effectId=' .. tostring(effectId))
        return false
    end

    local t = meta.type
    local p = meta.para or 0

    if t == TriggerEnum.Type.AddWingman and callbacks.AddWingman then
        callbacks.AddWingman(p)
    elseif t == TriggerEnum.Type.RemoveWingman and callbacks.RemoveWingman then
        callbacks.RemoveWingman(p)
    elseif t == TriggerEnum.Type.AddGold and callbacks.AddGold then
        callbacks.AddGold(p)
    elseif t == TriggerEnum.Type.MultiplyWingman and callbacks.MultiplyWingman then
        callbacks.MultiplyWingman(p)
    else
        Logger.LogError('#STG# 触发效果未处理 type=' .. tostring(t) .. ' effectId=' .. tostring(effectId))
        return false
    end

    Logger.Log('#STG# 执行触发效果 effectId=' .. tostring(effectId) .. ' type=' .. tostring(t) .. ' para=' .. tostring(p))
    return true
end

return TriggerEnum
