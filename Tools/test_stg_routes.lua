-- Standalone route-gate regression: real effects, gates and timeline callbacks.
package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = { Log = function() end, LogError = function(message) error(message) end }
local Logic = require "Game.STG.Logic.StgBattleLogic"
local Runner = require "Game.STG.Spawner.StgTimelineRunner"
local Factory = require "Game.STG.Entity.Gate.StgGateFactory"
local Effects = require "Game.STG.Trigger.StgTriggerEnum"
local Preview = require "UI.UIPlaneBattle.Logic.GateRewardPreview"
local Report = require "UI.UIPlaneBattle.Logic.GateBattleReport"
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local function gate(battle)
    return Factory.Create({type="digital_gate", gateType="gate_duet", initialValue=0,
        paraEntries={{min=-100,max=9999,effectId="eff_route_mass"}},
        paraEntriesRight={{min=-100,max=9999,effectId="eff_route_pierce"}}}, battle)
end
for _,side in ipairs({true, false}) do
    local battle=Logic.New()
    battle.wingmanCount=5
    local g=gate(battle)
    check(g:OnPass(side), "route side grants reward")
    check(battle:GetRouteChoice()==(side and "mass" or "pierce"), "crossing selects correct route")
    check(battle:GetWingmanCount()==(side and 10 or 5), "only mass doubles wingmen")
    check(battle:GetWeaponMode()==(side and "spread" or "pierce"), "pierce changes weapon")
    check(not g:OnPass(not side), "same gate cannot grant a second route")
    check(battle:GetWingmanCount()==(side and 10 or 5), "duplicate crossing cannot multiply again")
end
local events = {{time=1,type="spawn_enemy_wave",templateId="common"}}
for _,route in ipairs({"mass","pierce","homing","balanced"}) do
    events[#events+1]={time=2,type="spawn_enemy_wave",templateId=route,routeChoice=route}
    events[#events+1]={time=2,type="show_banner",text=route,routeChoice=route}
end
for _,route in ipairs({"mass","pierce","homing","balanced"}) do
    local battle,spawned,shown=Logic.New(),{},{}
    battle.callbacks.OnShowBanner=function(text) shown[#shown+1]=text end
    battle.fsm={Switch=function() end}
    battle.routeChoice=route
    battle.waveSpawner={SpawnWave=function(_,id) spawned[#spawned+1]=id end}
    local runner=Runner.New(battle:_BuildRunnerCallbacks())
    runner:Reset({duration=3,events=events})
    runner:Update(2.5)
    check(#spawned==2 and spawned[1]=="common" and spawned[2]==route,"only selected branch and common wave dispatch: "..route)
    check(#shown==1 and shown[1]==route,"only selected route forecast appears: "..route)
    runner:Update(2)
    check(#spawned==2 and runner:IsFinished(),"skipped branches are consumed once: "..route)
end
local battle=Logic.New()
check(not battle:SetRouteChoice("unknown") and battle:GetRouteChoice()=="balanced","invalid route cannot replace default")
battle.wingmanCount=4
local before=Report.Snapshot({wingmanCount=4,routeChoice="balanced"})
check(battle:ExecuteEffect("eff_route_mass"),"route effect is registered")
local after=Report.Snapshot({wingmanCount=battle:GetWingmanCount(),routeChoice=battle:GetRouteChoice()})
local report=Report.New()
Report.Record(report,"eff_route_mass",before,after,"gate",25)
check(report.reinforcements==4 and report.entries[1].delta.routeChoice=="mass","supply report records actual route and reinforcement delta")
check(Preview.Build(Effects.EffectTable.eff_route_mass,{}).detail:find("密集集群",1,true),"mass preview matches actual formation")
check(Preview.Build(Effects.EffectTable.eff_route_pierce,{}).detail:find("重装纵列",1,true),"pierce preview exposes its enemy branch")
check(not Preview.Build(Effects.EffectTable.eff_route_mass,{routeChoice="mass"}).available,"preview marks current route as selected")
local init=require "Game.STG.Logic.Stages.StgStageInit"
battle.fsm={Switch=function() end}
init.OnEnter({owner=battle},1001)
check(battle:GetRouteChoice()=="balanced" and battle:GetWeaponMode()=="spread","new battle clears previous route and weapon")
check(battle:GetWingmanCount()==0,"new battle clears route reinforcement")
return "STG routes PASS "..checks
