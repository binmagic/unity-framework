-- Snapshot real state, not configured reward amounts (full armor/caps may yield zero).
local Report = {}
function Report.New()
    return {reinforcements=0, lost=0, weapon=0, repair=0, haste=0, freeze=0, gold=0, entries={}, choices={},
        routeChoice="balanced", routeReinforcements=0}
end
local routeNames = {mass="编队翻倍路线", pierce="穿透路线", homing="追踪路线", balanced="未选择路线"}
function Report.RouteName(route) return routeNames[route] or routeNames.balanced end
function Report.RouteSummary(report)
    if not report or not report.routeChoice or report.routeChoice=="balanced" then return nil end
    local reward = report.routeChoice=="mass" and ("实得 +"..(report.routeReinforcements or 0).." 僚机")
        or (report.routeChoice=="pierce" and "已解锁穿透弹" or "已解锁追踪弹")
    return Report.RouteName(report.routeChoice).." · "..reward
end
function Report.Snapshot(state)
    local armor = 0
    for _, member in ipairs(state.members or {}) do
        if not member.dead then armor = armor + math.max(0, member.hp or 0) end
    end
    return {reinforcements=state.wingmanCount or 0, weapon=state.weaponLevel or 0, weaponMode=state.weaponMode or "spread", routeChoice=state.routeChoice or "balanced",
        repair=armor, gold=state.gold or 0, haste=state.hasteRemaining or 0, freeze=state.freezeRemaining or 0}
end
local names = {eff_route_mass="编队翻倍路线", eff_route_pierce="穿透路线", eff_pierce="穿透弹", eff_homing="追踪弹", eff_haste="速射", eff_freeze="冻结", eff_weapon="武器升级", eff_repair="装甲修复",
    eff_plus1="僚机增援",eff_plus2="僚机增援",eff_plus5="僚机增援",eff_double="编队翻倍",
    eff_minus1="僚机减少",eff_minus2="僚机减少",["20001"]="僚机增援",["20002"]="僚机增援",
    ["20003"]="僚机减少",["20004"]="金币补给",["20005"]="金币补给"}
function Report.Record(report, id, before, after, source, time)
    if not before or not after then return end
    local delta, changed = {}, false
    for _, key in ipairs({"reinforcements", "weapon", "repair", "haste", "freeze", "gold"}) do
        local value = (after[key] or 0) - (before[key] or 0)
        if key == "reinforcements" and value < 0 then
            report.lost = report.lost - value
        else
            report[key] = report[key] + math.max(0, value)
        end
        delta[key] = value
        if math.abs(value) > .001 then changed = true end
    end
    if before.weaponMode ~= after.weaponMode then delta.weaponMode = after.weaponMode; changed = true end
    if before.routeChoice ~= after.routeChoice then
        delta.routeChoice = after.routeChoice
        report.routeChoice = after.routeChoice
        report.routeReinforcements = math.max(0, delta.reinforcements or 0)
        changed = true
    end
    report.entries[#report.entries+1] = {id=id, source=source or "gate", time=time or 0, delta=delta, changed=changed}
    if source == "choice" and changed then report.choices[#report.choices+1] = names[id] or id end
end
return Report
