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
    UpgradeWeapon   = 50,
    RepairHull      = 60,
    TimedHaste      = 70,
    FreezeEnemy     = 80,
    SetWeaponMode   = 90,
    SetRouteChoice  = 100,
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
    ["eff_double"] = { type = TriggerEnum.Type.MultiplyWingman, para = 2, text = "×2" },
    ["eff_weapon"] = { type = TriggerEnum.Type.UpgradeWeapon, para = 1, text = "武器升级" },
    ["eff_repair"] = { type = TriggerEnum.Type.RepairHull, para = 1, text = "护盾 +1" },
    ["eff_minus1"] = { type = TriggerEnum.Type.RemoveWingman,   para = 1,  text = "-1" },
    ["eff_minus2"] = { type = TriggerEnum.Type.RemoveWingman,   para = 2,  text = "-2" },
    ["eff_haste"]  = { type = TriggerEnum.Type.TimedHaste,      para = 5,  text = "速射 +60%", icon = "haste" },
    ["eff_freeze"] = { type = TriggerEnum.Type.FreezeEnemy,      para = 3,  text = "冻结敌机", icon = "freeze" },
    ["eff_pierce"] = { type = TriggerEnum.Type.SetWeaponMode, para = "pierce", text = "穿透弹" },
    ["eff_homing"] = { type = TriggerEnum.Type.SetWeaponMode, para = "homing", text = "追踪弹" },
    ["eff_route_mass"] = { type = TriggerEnum.Type.SetRouteChoice, para = "mass", text = "编队翻倍路线" },
    ["eff_route_pierce"] = { type = TriggerEnum.Type.SetRouteChoice, para = "pierce", text = "穿透路线" },

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
    elseif t == TriggerEnum.Type.UpgradeWeapon and callbacks.UpgradeWeapon then
        callbacks.UpgradeWeapon(p)
    elseif t == TriggerEnum.Type.RepairHull and callbacks.RepairHull then
        callbacks.RepairHull(p)
    elseif t == TriggerEnum.Type.TimedHaste and callbacks.TimedHaste then
        callbacks.TimedHaste(p)
    elseif t == TriggerEnum.Type.FreezeEnemy and callbacks.FreezeEnemy then
        callbacks.FreezeEnemy(p)
    elseif t == TriggerEnum.Type.SetWeaponMode and callbacks.SetWeaponMode then
        callbacks.SetWeaponMode(p)
    elseif t == TriggerEnum.Type.SetRouteChoice and callbacks.SetRouteChoice then
        callbacks.SetRouteChoice(p)
    else
        Logger.LogError('#STG# 触发效果未处理 type=' .. tostring(t) .. ' effectId=' .. tostring(effectId))
        return false
    end

    Logger.Log('#STG# 执行触发效果 effectId=' .. tostring(effectId) .. ' type=' .. tostring(t) .. ' para=' .. tostring(p))
    return true
end

return TriggerEnum
