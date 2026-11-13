-- Run in a ready UIPlaneBattle via Unity MCP. Synthetic choice offers exercise
-- real buttons, battle callbacks and visuals without changing saved level/hero data.
local v = assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle)).View
local mgr = DataCenter.PlaneBattleDataManager
local oldGold, oldPass = rawget(mgr, "AddGold"), rawget(mgr, "OnLevelPass")
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local function offer(ids)
    return v:_OpenGateChoice({ stgGate = { GetChoicePool = function() return ids end } })
end
local ids = { "eff_haste", "eff_freeze", "eff_weapon" }
local function start()
    v:_EnterLevel(1001)
    v:_HideGuide()
    return assert(v.logic)
end
mgr.AddGold, mgr.OnLevelPass = function() end, function() end
local ok, err = xpcall(function()
    for index = 1, 3 do
        local logic = start()
        local level = logic:GetWeaponLevel()
        check(offer(ids), "choice opens " .. index)
        check(not v:_SkipGateChoice(), "cannot skip available rewards")
        local before = v.battleTime
        v:Update()
        logic:Update(1)
        check(v.battleTime == before and logic.elapsed == 0, "choice pauses real view and logic")
        v.gateChoicePanel.cards[index].button.onClick:Invoke()
        check(not v.isChoicePaused and logic.pendingGateChoices == nil, "button resumes battle " .. index)
        check(not v.gateChoicePanel:Choose(index), "double click blocked " .. index)
        check(logic:GetBuffRemaining("haste") == (index == 1 and 5 or 0), "haste branch isolated")
        check(logic:GetBuffRemaining("freeze") == (index == 2 and 3 or 0), "freeze branch isolated")
        check(logic:GetWeaponLevel() == level + (index == 3 and 1 or 0), "weapon branch isolated")
        check(v.heroCombat.state.members[1].invincible >= 0.6, "resume grants short protection")
        check(v.gateFeedback.label.text:find("→", 1, true) or index == 1, "receipt shows actual change")
        if index == 1 then
            check(logic:GetFireRateMultiplier() == 1.6, "haste multiplies firing")
            logic:_UpdateTimedBuffs(5)
            check(logic:GetFireRateMultiplier() == 1, "haste expires")
        elseif index == 2 then
            v:_OnStgSpawnRequests({{ x=0, y=1700, metaId=8001, hp=30, speed=180, fireInterval=1 }})
            local enemy = v.enemies[1]
            local _, y = enemy:GetLocalPos()
            v:_UpdateEnemies(0.2)
            local _, frozenY = enemy:GetLocalPos()
            check(y == frozenY and (enemy.fireTimer or 0) == 0, "freeze stops real enemy movement and fire")
            v.bulletPool:Fire(0, 800, -1, 1, "enemy")
            local bullet = v.bulletPool:GetActiveList()[1]
            local bulletY = bullet.rt.anchoredPosition.y
            v.bulletPool:Update(0.1)
            check(bullet.rt.anchoredPosition.y < bulletY, "freeze does not stop existing bullets")
            logic:_UpdateTimedBuffs(3)
            v:_UpdateEnemies(0.2)
            local _, resumedY = enemy:GetLocalPos()
            check(resumedY < frozenY, "enemies resume after freeze")
        else
            local count = #v.bulletPool:GetActiveList()
            v:_UpdateWingmanFire(0.3)
            check(#v.bulletPool:GetActiveList() > count, "upgraded formation fires real projectiles")
        end
    end
    local logic = start()
    logic:UpgradeWeapon(2)
    check(offer(ids), "max-weapon pool opens")
    check(not v.gateChoicePanel.cards[3].button.interactable, "full weapon button disabled")
    check(not v:_ApplyGateChoice("eff_weapon") and v.isChoicePaused, "direct claim also rejects no-gain weapon")
    check(v.gateChoicePanel:Choose(2), "other reward remains usable")

    logic = start()
    local member = v.heroCombat.state.members[1]
    member.hp = member.maxHp - 1
    v.playerHull = member.hp
    check(offer({ "eff_repair", "eff_plus2", "eff_double" }), "repair pool opens")
    check(v.gateChoicePanel:Choose(1) and member.hp == member.maxHp, "repair restores actual hero armor")
    logic = start()
    local count = logic:GetWingmanCount()
    check(offer({ "eff_double", "eff_plus2", "eff_repair" }), "formation pool opens")
    check(v.gateChoicePanel:Choose(1) and logic:GetWingmanCount() == count * 2, "multiply applies displayed quantity")
    check(#v.wingmen == math.min(12, count * 2), "visible formation synchronized")

    logic = start()
    logic:UpgradeWeapon(2)
    check(offer({ "eff_weapon", "eff_repair", "eff_zero" }), "all unavailable pool opens")
    check(v.gateChoicePanel.canSkip and v.gateChoicePanel.skipGo.activeSelf, "no-gain pool provides continue button")
    check(v.gateChoicePanel:Skip() and not v.isChoicePaused and logic.pendingGateChoices == nil, "skip cannot lock simulation")
    check(not v.gateChoicePanel:Skip(), "repeat skip rejected")
    logic = start()
    logic:UpgradeWeapon(2)
    check(offer(ids), "leave capped preview open for visual inspection")
end, debug.traceback)
mgr.AddGold, mgr.OnLevelPass = oldGold, oldPass
assert(ok, err)
return "Unity reward branches PASS " .. checks .. "; save methods restored"
