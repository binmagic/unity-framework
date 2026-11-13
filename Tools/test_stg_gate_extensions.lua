-- Standalone: D:/lua/lua55.exe Tools/test_stg_gate_extensions.lua
-- Also safe to run in the Unity Lua VM: all state/rewards are isolated from player data.
package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = Logger or { Log = function() end, LogError = function(message) error(message) end }
local standalone = BaseClass == nil
if standalone then
    BaseClass = function()
        local class = {}; class.__index = class
        class.New = function(...) local self = setmetatable({}, class); self:__init(...); return self end
        return class
    end
end
local State = require "UI.UIPlaneBattle.Logic.HeroCombatState"
local Factory = require "Game.STG.Entity.Gate.StgGateFactory"
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local function near(a, b) return math.abs(a - b) < 0.000001 end
local team = { members = {
    { id = 11, slot = 1, hullMax = 3, activeCooldown = 10 },
    { id = 22, slot = 3, hullMax = 4, activeCooldown = 20 },
    { id = 33, slot = 5, hullMax = 3, activeCooldown = 12 },
} }
local state = State.New(team)
local effects, charges = {}, {}
local logic = {
    ExecuteEffect = function(_, id) effects[#effects + 1] = id; return true end,
    RemoveWingman = function(_, n) effects[#effects + 1] = -n end,
    ChargeHeroSkill = function(_, slot, percent)
        charges[#charges + 1] = { slot, percent }
        local _, count = state:ChargeSlot(slot, percent)
        return count > 0
    end,
}
local function gate(extra)
    local cfg = { type = "digital_gate", gateType = "gate_counter", initialValue = 0,
        paraEntries = { { min = -100, max = 9999, effectId = "eff_plus2" } },
        paraEntriesRight = { { min = -100, max = 9999, effectId = "eff_plus5" } } }
    for k, v in pairs(extra or {}) do cfg[k] = v end
    return Factory.Create(cfg, logic)
end
local ordinary = gate()
check(ordinary:IsUnlocked(), "old gates have no lock")
check(ordinary:OnHit(3) and ordinary.value == 1, "old gate accepts shots")
check(ordinary:OnPass() and effects[1] == "eff_plus2", "old gate still grants normal reward")
check(not ordinary:OnPass() and #effects == 1, "old gate remains single use")
local locked = gate({ unlockMode = "enemy_count", unlockRequired = 3 })
check(not locked:IsUnlocked() and not locked:OnHit(10), "locked gate cannot be shot to bypass its objective")
check(not locked:TryUnlock(2), "below threshold stays locked")
check(locked:GetUnlockProgress() == 2, "objective progress exposed")
check(not locked:TryUnlock(1) and locked:GetUnlockProgress() == 2, "progress never moves backwards")
check(locked:TryUnlock(3) and locked:IsUnlocked(), "exact threshold unlocks")
check(locked:TryUnlock(10) and #effects == 1, "unlocking does not grant reward")
check(locked:OnPass() and #effects == 2, "passing unlocked gate grants once")
check(not locked:OnPass() and #effects == 2, "unlocked gate cannot grant twice")
local missed = gate({ unlockMode = "enemy_count", unlockRequired = 2 })
check(not missed:OnPass() and missed.hasTriggered, "passing locked gate consumes without reward")
missed:TryUnlock(2)
check(not missed:OnPass() and #effects == 2, "unlock after missed pass cannot grant reward")
local duet = gate({ gateType = "gate_duet", unlockMode = "enemy_count", unlockRequired = 1 })
check(not duet:OnHit(10, false) and duet.rightValue == 0, "duet lock blocks both sides")
duet:TryUnlock(1)
check(duet:OnPass(false) and effects[#effects] == "eff_plus5", "unlocked duet keeps selected-side reward")
local bucket = gate({ unlockMode = "bucket_damage", unlockTargetId = "supply", unlockRequired = 15 })
check(not bucket:OnTargetBucketAttacked("other", 100), "wrong target damage ignored")
check(not bucket:OnTargetBucketAttacked("supply", 14), "matching damage below threshold")
check(bucket:OnTargetBucketAttacked("supply", 15), "matching target unlocks at threshold")
check(#effects == 3, "target damage does not grant before passing")
state.byId[11].cooldown, state.byId[22].cooldown = 8, 18
state.byId[33].dead = true
local seconds, count = state:ChargeSlot(3, 25)
check(near(seconds, 5) and count == 1 and state.byId[22].cooldown == 13, "charge uses selected slot and full skill cooldown")
check(state.byId[11].cooldown == 8, "other slot untouched")
seconds, count = state:ChargeSlot(2, 100)
check(seconds == 0 and count == 0, "empty position never falls back to another hero")
seconds, count = state:ChargeSlot(5, 100)
check(seconds == 0 and count == 0 and state.byId[33].dead, "dead hero neither charged nor revived")
seconds, count = state:ChargeSlot(0, 100)
check(near(seconds, 21) and count == 2 and state:CanCast(11) and state:CanCast(22), "all living heroes can become ready")
check(state.byId[11].casts == 0 and state.byId[22].casts == 0, "charging never casts skill")
seconds, count = state:ChargeSlot(0, 100)
check(seconds == 0 and count == 0, "already-ready heroes receive no extra charge")
state.byId[11].cooldown = 8
local charge = gate({ heroChargeSlot = 1, heroChargePercent = 50 })
check(charge:IsHeroChargeGate() and not charge:OnHit(10), "charge gate is a pass reward, not a shot counter")
check(charge:OnPass() and state.byId[11].cooldown == 3, "charge gate reduces selected hero cooldown")
check(#charges == 1 and charges[1][1] == 1 and charges[1][2] == 50 and #effects == 3, "charge replaces ordinary reward")
check(not charge:OnPass() and #charges == 1, "charge gate single settlement")
local empty = gate({ heroChargeSlot = 2, heroChargePercent = 50 })
check(not empty:OnPass() and empty.hasTriggered and #effects == 3, "empty slot does not grant fallback reward")
local nocharge = gate({ heroChargePercent = 0 })
check(not nocharge:IsHeroChargeGate() and nocharge:OnPass(), "explicit zero preserves normal gates")
if standalone then BaseClass = nil end
return "PASS: " .. checks .. " gate objective / hero charge checks"
