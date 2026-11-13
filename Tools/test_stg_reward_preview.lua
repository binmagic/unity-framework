package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = { Log = function() end, LogError = function(message) error(message) end }
local Preview = require "UI.UIPlaneBattle.Logic.GateRewardPreview"
local Effects = require "Game.STG.Trigger.StgTriggerEnum"
local Logic = require "Game.STG.Logic.StgBattleLogic"
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local function preview(id, state) return Preview.Build(Effects.EffectTable[id], state) end
local state = { weaponLevel = 1, wingmanCount = 5, members = {
    { hp = 2, maxHp = 3 }, { hp = 1, maxHp = 4 }, { hp = 0, maxHp = 5, dead = true },
} }
local p = preview("eff_weapon", state)
check(p.available and p.value == "Lv.2 → 3", "weapon preview shows actual level")
check(not preview("eff_weapon", { weaponLevel = 2 }).available, "max weapon cannot waste choice")
p = preview("eff_repair", state)
check(p.available and p.value == "3 → 5", "repair sums living members only")
check(p.detail:find("2 架恢复", 1, true), "repair includes damaged escort even when primary is full")
check(state.members[1].hp == 2 and state.weaponLevel == 1, "preview never mutates battle state")
check(not preview("eff_repair", { members = {{ hp = 3, maxHp = 3 }, { hp = 0, maxHp = 3, dead = true }} }).available, "full team / dead units cannot consume repair")
check(preview("eff_double", state).value == "5 → 10", "multiply shows exact quantity")
check(not preview("eff_double", { wingmanCount = 0 }).available, "multiply zero is unavailable")
check(preview("eff_plus5", { wingmanCount = 11 }).detail:find("24", 1, true), "large formation explains firepower cap")
check(preview("eff_minus2", { wingmanCount = 1 }).value == "1 → 0", "negative gate cannot preview negative formation")
check(not preview("eff_zero", state).available, "zero gain is unavailable")
check(preview("20004", state).value == "+15", "gold preview uses effect table")
check(not Preview.Build(nil, state).available, "unknown effect is not selectable")
check(preview("eff_haste", { hasteRemaining = 2 }).detail:find("2.0 → 5.0", 1, true), "haste refresh uses max duration, not stacking")
check(not preview("eff_haste", { hasteRemaining = 8 }).available, "longer hero haste cannot be shortened or wasted")
check(preview("eff_freeze", {}).detail:find("已发射敌弹继续飞行", 1, true), "freeze states projectile limitation")
check(not preview("eff_freeze", { freezeRemaining = 3 }).available, "already full freeze unavailable")
for index, id in ipairs({ "eff_haste", "eff_freeze", "eff_weapon" }) do
    local battle = Logic.New()
    check(battle:BeginGateChoice({ "eff_haste", "eff_freeze", "eff_weapon" }), "branch begins " .. index)
    check(battle:ResolveGateChoice(id), "branch resolves " .. index)
    check(battle.pendingGateChoices == nil, "branch resumes simulation " .. index)
    check(not battle:ResolveGateChoice(id), "double claim rejected " .. index)
    check(battle:GetBuffRemaining("haste") == (index == 1 and 5 or 0), "haste exclusive " .. index)
    check(battle:GetBuffRemaining("freeze") == (index == 2 and 3 or 0), "freeze exclusive " .. index)
    check(battle:GetWeaponLevel() == (index == 3 and 1 or 0), "weapon exclusive " .. index)
end
local battle = Logic.New()
check(not battle:SkipGateChoice(), "skip without pending request rejected")
check(battle:BeginGateChoice({ "eff_zero", "eff_weapon", "eff_repair" }), "no-gain pool begins")
check(battle:SkipGateChoice() and battle.pendingGateChoices == nil, "no-gain pool can be dismissed")
check(not battle:SkipGateChoice() and battle.weaponLevel == 0 and battle.gold == 0, "skip grants nothing and cannot repeat")
print("STG reward preview PASS " .. checks)
