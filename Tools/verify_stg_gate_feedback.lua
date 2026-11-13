-- Run in Unity Play Mode through GameEntry.Lua.Env.DoString(File.ReadAllText(...)).
-- Uses a separate logic stub: no rewards, progress or formation saves are changed.
local view = assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle)).View
assert(view and view.logic, "Enter a STG level first")
local checks = 0
local function check(ok, message)
    assert(ok, message)
    checks = checks + 1
end
local Factory = require "Game.STG.Entity.Gate.StgGateFactory"
local originalLogic = view.logic
local originalSound = view._PlayGateSound
local originalFx = view._SpawnCombatFx
local gates, feedback = {}, {}
local applied = {}
local stub = {
    ExecuteEffect = function(_, id) applied[#applied + 1] = id; return true end,
    RemoveWingman = function(_, n) applied[#applied + 1] = -n end,
}
local initialGateCount, initialLogicCount = #view.gates, #view.stgGates
local function create(config)
    config.type = "digital_gate"
    view.logic = stub
    view:_CreateStgGateVisual(config)
    view.logic = originalLogic
    local gate = view.gates[#view.gates]
    gates[#gates + 1] = gate
    return gate
end
local function hit(gate, x, damage)
    local gx, gy = gate:GetLocalPos()
    gate.previousY = gy
    return gate:TryHitBullet({ damage = damage or 10, previousX = gx + x, previousY = gy - 150,
        rt = { anchoredPosition = CS.UnityEngine.Vector2(gx + x, gy + 100) } })
end
local ok, result = xpcall(function()
    -- Exercise the real drop event handler and factory, including explicit zero values.
    local template = { trapId = "verification", type = "digital_gate", gateType = "gate_duet",
        initialValue = -1, initialLeftRatio = 0.65, minSideRatio = 0.3,
        ratioChangePerHit = 0, hitCooldown = 0.2, positionX = 0.9, positionY = 1450,
        prefabPath = "kept-prefab", effectTableRef = "kept-effects", customField = "future-field",
        paraEntries = { { min = -100, max = 0, effectId = "eff_minus1" }, { min = 0, max = 99, effectId = "eff_plus2" } },
        paraEntriesRight = { { min = -100, max = 99, effectId = "eff_double" } },
    }
    local captured = {}
    local receiver = {
        logic = { GetConfig = function() return { gateTemplates = { template } } end },
        _CreateStgGateVisual = function(_, config) captured[#captured + 1] = config end,
    }
    view._OnStgDropDigitalGate(receiver, { gateType = "gate_duet", count = 2, offsetXMin = -0.4,
        offsetXMax = 0.4, positionY = 1300 })
    check(#captured == 2 and captured[1] ~= captured[2] and captured[1] ~= template, "separate drop configs")
    for _, config in ipairs(captured) do
        check(config.hitCooldown == 0.2 and config.initialLeftRatio == 0.65, "cooldown and initial ratio inherited")
        check(config.ratioChangePerHit == 0 and config.minSideRatio == 0.3, "zero expansion preserved")
        check(config.prefabPath == "kept-prefab" and config.effectTableRef == "kept-effects"
            and config.customField == "future-field", "all template fields preserved")
    end
    check(captured[1].positionX == -0.4 and captured[2].positionX == 0.4 and captured[1].positionY == 1300,
        "drop position overrides")
    check(template.positionX == 0.9 and template.positionY == 1450, "source template untouched")
    local first, second = Factory.Create(captured[1], stub), Factory.Create(captured[2], stub)
    first:OnHit(10, true)
    check(first.leftValue == 0 and second.leftValue == -1, "drop instances have independent counters")
    check(first.leftRatio == 0.65 and first.hitCooldown == 0.2, "factory receives template behavior")

    view._PlayGateSound = function(_, event) feedback[#feedback + 1] = event end
    view._SpawnCombatFx = function() end
    local counter = create({ trapId = "verify_counter", gateType = "gate_counter", positionX = 0,
        positionY = 950, initialValue = -1, hitCooldown = 0.2,
        paraEntries = { { min = -100, max = 0, effectId = "eff_minus2" },
            { min = 0, max = 2, effectId = "eff_plus1" }, { min = 2, max = 99, effectId = "eff_plus5" } } })
    check(counter.cards[1].reward.text == "-2", "red gate shows actual loss")
    check(hit(counter, 0), "swept bullet hits gate")
    check(feedback[#feedback] == "positive" and counter.cards[1].notice.text == "危险解除", "red-to-blue transition feedback")
    check(counter.cards[1].reward.text == "+1" and #applied == 0, "shooting previews reward without granting it")
    local count = #feedback
    hit(counter, 0)
    check(#feedback == count and counter.stgGate.value == 0, "cooldown absorbs bullet without feedback or upgrade")
    counter:Update(0.2); hit(counter, 0)
    check(feedback[#feedback] == "hit", "ordinary hit has no tier announcement")
    counter:Update(0.2); hit(counter, 0)
    check(feedback[#feedback] == "upgrade" and counter.cards[1].reward.text == "+5", "reward threshold triggers upgrade")
    check(#applied == 0, "tier-up grants no early reward")
    check(counter.stgGate:OnPass() and applied[1] == "eff_plus5", "crossing applies final reward")
    check(not counter.stgGate:OnPass() and #applied == 1, "one crossing grants once")
    count = #feedback; hit(counter, 0)
    check(#feedback == count, "resolved gate emits no feedback")
    counter:Update(1)
    check(counter.cards[1].notice.text == "" and counter.cards[1].flash.color.a == 0, "feedback fades completely")

    local duet = create({ trapId = "verify_duet", gateType = "gate_duet", positionX = 0,
        positionY = 1100, initialValue = 0, hitCooldown = 0,
        paraEntries = {}, paraEntriesRight = { { min = 0, max = 99, effectId = "eff_double" } } })
    check(duet:GetStgSideState(true).effectId == nil and duet:GetStgSideState(false).effectId == "eff_double",
        "missing left reward never uses right reward")
    duet.stgGate.leftValue = -1
    duet.stgGate.trapConfig.paraEntries = { { min = -100, max = 99, effectId = "eff_weapon" } }
    duet.stgGate:RecalcEffect(); duet:RefreshStgDisplay()
    check(duet.cards[1].reward.text == "-1" and duet.cards[1].accent.r > duet.cards[1].accent.b,
        "negative side stays red even when its effect table points at weapon upgrade")
    hit(duet, -100)
    check(feedback[#feedback] == "positive" and duet.cards[1].notice.text == "危险解除", "duet left turns positive independently")
    check(duet.cards[2].notice.text == "" and duet.stgGate.rightValue == 0, "opposite side has no false upgrade")
    for _ = 1, 60 do hit(duet, -200) end
    check(duet.cards[2].rt.sizeDelta.x > 0 and not duet.cards[2].icon.gameObject.activeSelf,
        "narrow side hides icon to protect text")

    local step = create({ trapId = "verify_step", gateType = "gate_step", positionX = 0,
        positionY = 1250, hitCooldown = 0,
        paraEntries = { { threshold = 0, effectId = "eff_plus1" }, { threshold = 20, effectId = "eff_plus2" } } })
    hit(step, 0, 20)
    check(feedback[#feedback] == "upgrade" and step.cards[1].reward.text == "+2", "damage charge upgrades on threshold")
    check(step.stgGate.accumulatedDamage == 20, "charge gate still counts damage")
    return "PASS: " .. checks .. " Unity digital gate feedback checks"
end, debug.traceback)
view.logic = originalLogic
view._PlayGateSound = originalSound
view._SpawnCombatFx = originalFx
for _, gate in ipairs(gates) do gate:Destroy() end
while #view.gates > initialGateCount do table.remove(view.gates) end
while #view.stgGates > initialLogicCount do table.remove(view.stgGates) end
assert(ok, result)
return result
