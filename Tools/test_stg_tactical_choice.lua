-- Standalone regression for LastWar-style three-choice and timed buff effects.
package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = { Log = function() end, LogError = function(message) error(message) end }
local Trigger = require "Game.STG.Trigger.StgTriggerEnum"
local Factory = require "Game.STG.Entity.Gate.StgGateFactory"
local checks = 0
local function check(ok, msg) assert(ok, msg); checks = checks + 1 end
local applied, buffs = {}, {}
local logic = {
    ExecuteEffect = function(_, id) applied[#applied + 1] = id; return true end,
    ApplyTimedBuff = function(_, id, duration) buffs[id] = duration; return true end,
}
local gate = Factory.Create({ type = "digital_gate", gateType = "gate_counter", initialValue = 0,
    paraEntries = {{ min = -100, max = 9999, effectId = "eff_plus1" }},
    choiceMode = "three", choicePool = "eff_haste, eff_freeze, eff_weapon" }, logic)
check(gate:IsChoiceGate(), "choice mode parsed")
local pool = gate:GetChoicePool()
check(#pool == 3 and pool[1] == "eff_haste" and pool[2] == "eff_freeze", "choice pool parsed")
check(gate:OnPass() == "choice", "choice gate defers reward")
check(#applied == 0, "choice gate does not auto apply")
check(Trigger.Execute("eff_haste", { TimedHaste = function(seconds) buffs.haste = seconds end }), "haste effect dispatch")
check(Trigger.Execute("eff_freeze", { FreezeEnemy = function(seconds) buffs.freeze = seconds end }), "freeze effect dispatch")
check(buffs.haste == 5 and buffs.freeze == 3, "timed buff durations")
local BattleLogic = require "Game.STG.Logic.StgBattleLogic"
local battle = BattleLogic.New()
local poolIds = { "eff_haste", "eff_freeze", "eff_weapon" }
check(not battle:BeginGateChoice({ "eff_haste", "eff_haste", "eff_weapon" }), "duplicate rewards rejected")
check(not battle:BeginGateChoice({ "eff_haste", "missing", "eff_weapon" }), "unknown reward rejected")
check(battle:BeginGateChoice(poolIds), "valid choice begins")
poolIds[1] = "eff_plus1"
check(battle.pendingGateChoices[1] == "eff_haste", "candidate list copied")
check(not battle:BeginGateChoice({ "eff_plus1", "eff_freeze", "eff_weapon" }), "pending choice cannot be replaced")
check(not battle:ResolveGateChoice("eff_plus1") and battle.pendingGateChoices ~= nil, "noncandidate rejected without consuming choice")
local ticks = 0
battle.fsm = { Update = function() ticks = ticks + 1 end }
battle:ApplyTimedBuff("freeze", 3, 0)
battle:Update(1)
check(ticks == 0 and battle:GetBuffRemaining("freeze") == 3, "choice pauses simulation and existing buffs")
check(battle:ResolveGateChoice("eff_haste") and battle.pendingGateChoices == nil, "candidate consumes pending choice")
check(battle:GetFireRateMultiplier() == 1.6, "haste multiplies fire rate")
check(not battle:ResolveGateChoice("eff_weapon") and battle.weaponLevel == 0, "second reward cannot be claimed")
battle:Update(1)
check(ticks == 1 and battle:GetBuffRemaining("haste") == 4 and battle:GetBuffRemaining("freeze") == 2, "simulation and countdown resume after choice")
battle:ApplyTimedBuff("haste", 2, 1.6)
check(battle:GetBuffRemaining("haste") == 4, "shorter buff never truncates existing duration")
battle:Update(2)
check(not battle:IsEnemyFrozen() and battle:GetBuffRemaining("freeze") == 0, "freeze expires at zero")
battle:Update(3)
check(battle:GetBuffRemaining("haste") == 0 and battle:GetFireRateMultiplier() == 1, "haste expires without negative time")
check(not battle:ApplyTimedBuff("haste", math.huge, 1.6) and not battle:ApplyTimedBuff("haste", -1, 1.6), "invalid buff durations rejected")
return "PASS: " .. checks .. " tactical choice checks"
