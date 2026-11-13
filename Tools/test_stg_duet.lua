-- Run from project root: D:\lua\lua55.exe Tools/test_stg_duet.lua
package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = { Log = function() end, LogError = function(message) error(message) end }
local Duet = require "Game.STG.Entity.Gate.StgGateDuet"
local Counter = require "Game.STG.Entity.Gate.StgGateCounter"
local Step = require "Game.STG.Entity.Gate.StgGateStep"
local count = 0
local function check(ok, message)
    assert(ok, message)
    count = count + 1
end
local function near(a, b) return math.abs(a - b) < 0.00001 end
local function newGate(extra)
    local config = {
        gateType = "gate_duet", initialValue = 0,
        paraEntries = { { min = 0, max = 99, effectId = "left" } },
        paraEntriesRight = { { min = 0, max = 99, effectId = "right" } },
    }
    for k, v in pairs(extra or {}) do config[k] = v end
    local events = {}
    local logic = {
        ExecuteEffect = function(_, id) events[#events + 1] = id; return true end,
        RemoveWingman = function(_, n) events[#events + 1] = -n end,
    }
    return Duet.New(config, logic), events
end

local gate = newGate()
check(near(gate.leftRatio, 0.5), "old configs default to equal width")
check(gate:OnHit(10, true), "first shot counts")
check(gate.leftValue == 1 and gate.rightValue == 0, "damage does not multiply hit count")
check(near(gate.leftRatio, 0.52), "left shot expands left by two percent")
check(gate:IsLeftAt(5, 520), "point right of old center now belongs to expanded left")
check(not gate:IsLeftAt(11, 520), "point beyond moving separator belongs to right")
check(not gate:OnHit(10, false), "same-frame opposite shot shares cooldown")
check(gate.rightValue == 0 and near(gate.leftRatio, 0.52), "blocked shot changes neither count nor width")
gate:Update(0.025)
check(not gate:OnHit(1, true), "half cooldown remains blocked")
gate:Update(0.025)
check(gate:OnHit(1, false), "shot at exact cooldown expiry counts")
check(near(gate.leftRatio, 0.5) and gate.rightValue == 1, "right shot expands right")
gate:Update(1)
check(not gate:OnHit(0, true), "zero damage cannot expand gate")
check(not gate:OnHit(-1, true), "negative damage cannot expand gate")
for _ = 1, 100 do gate:Update(0.05); gate:OnHit(1, true) end
check(near(gate.leftRatio, 0.8), "left width stops at eighty percent")
for _ = 1, 100 do gate:Update(0.05); gate:OnHit(1, false) end
check(near(gate.leftRatio, 0.2), "right width stops at eighty percent")
check(near(gate:GetSeparatorX(520), -156), "separator is based on local gate width")
local events
gate, events = newGate({ initialLeftRatio = 0.7 })
check(near(gate.leftRatio, 0.7) and gate:IsLeftAt(50, 520), "configured initial ratio affects selection")
gate:OnPass(gate:IsLeftAt(50, 520))
check(events[1] == "left", "expanded left area grants left reward")
check(not gate:OnPass(false) and #events == 1, "passing grants only one reward")
check(not gate:OnHit(1, true), "resolved gate cannot change state")
gate, events = newGate({ paraEntries = {} })
check(not gate:OnPass(true) and #events == 0, "missing left effect must never fall back to right")
gate, events = newGate({ initialValue = -3, paraEntries = {} })
check(gate:OnPass(true) and events[1] == -3, "negative side subtracts displayed amount even without effect entry")
gate = newGate({ ratioChangePerHit = 0, hitCooldown = 0 })
gate:OnHit(1, true); gate:OnHit(1, true)
check(near(gate.leftRatio, 0.5) and gate.leftValue == 2, "zero shift and zero cooldown are respected")
gate = newGate({ minSideRatio = 0.3, initialLeftRatio = 0.1 })
check(near(gate.leftRatio, 0.3), "out-of-range initial ratio is clamped")
local counter = Counter.New({ gateType = "gate_counter", initialValue = -1, paraEntries = {} }, {})
counter:OnHit(2); counter:OnHit(2)
check(counter.value == 0, "counter also limits simultaneous pellets")
counter:Update(0.05); counter:OnHit(2)
check(counter.value == 1, "counter resumes after cooldown")
local step = Step.New({ gateType = "gate_step", paraEntries = {}, hitCooldown = 0.05 }, {})
check(step:OnHit(3), "step first shot counts")
check(not step:OnHit(5), "step cooldown blocks simultaneous shot")
step:Update(0.05)
check(step:OnHit(5), "step resumes after cooldown")
check(step.accumulatedDamage == 8, "damage-based charge gate keeps cumulative damage semantics")
print("PASS: " .. count .. " digital gate regression checks")
