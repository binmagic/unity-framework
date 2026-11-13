package.path="Assets/Main/LuaScripts/?.lua;"..package.path
Logger={Log=function() end,LogError=function(message) error(message) end}
local Report=require "UI.UIPlaneBattle.Logic.GateBattleReport"
local Logic=require "Game.STG.Logic.StgBattleLogic"
local checks=0
local function check(ok,message) assert(ok,message); checks=checks+1 end
local battle, report, member=Logic.New(),Report.New(),{hp=2,maxHp=3}
battle.wingmanCount=3
local function snapshot()
    return Report.Snapshot({wingmanCount=battle.wingmanCount,weaponLevel=battle.weaponLevel,
        gold=battle:GetGold(),members={member,{hp=0,dead=true}},hasteRemaining=battle:GetBuffRemaining("haste"),freezeRemaining=battle:GetBuffRemaining("freeze")})
end
battle.callbacks={OnEffectStarted=snapshot,OnEffectExecuted=function(id,before,source) Report.Record(report,id,before,snapshot(),source,12) end,
    OnRepairHull=function(n) member.hp=math.min(member.maxHp,member.hp+n) end}
check(battle:ExecuteEffect("eff_plus2") and report.reinforcements==2, "initial formation excluded; actual gain counted")
battle:ExecuteEffect("eff_double")
check(report.reinforcements==7, "multiplication uses actual reinforcement delta")
battle:ExecuteEffect("eff_minus2")
check(report.lost==2 and report.reinforcements==7, "losses counted separately")
battle:ExecuteEffect("eff_repair"); battle:ExecuteEffect("eff_repair")
check(report.repair==1, "full armor does not create fictitious healing")
battle:ExecuteEffect("eff_weapon");battle:ExecuteEffect("eff_weapon");battle:ExecuteEffect("eff_weapon")
check(report.weapon==2, "weapon cap does not overcount")
battle:ExecuteEffect("eff_haste");battle:ExecuteEffect("eff_haste")
check(report.haste==5, "non-stacking refresh counted once")
battle:_UpdateTimedBuffs(2);battle:ExecuteEffect("eff_haste")
check(report.haste==7, "refresh counts only effective added duration")
check(battle:BeginGateChoice({"eff_haste","eff_freeze","eff_weapon"}) and battle:ResolveGateChoice("eff_freeze"), "choice resolves")
check(report.freeze==3 and #report.choices==1 and report.choices[1]=="冻结", "chosen supply recorded once")
check(not battle:ResolveGateChoice("eff_freeze") and #report.choices==1, "repeat clicks cannot duplicate record")
local count=#report.entries
Logger.LogError=function() end
check(not battle:ExecuteEffect("missing") and #report.entries==count, "invalid effect not recorded")
check(report.entries[1].time==12 and report.entries[#report.entries].source=="choice", "entries preserve source and battle time")
battle:BeginGateChoice({"20004","eff_plus2","eff_repair"});battle:ResolveGateChoice("20004")
check(report.gold==15 and report.choices[2]=="金币补给", "gold choice counted without including victory reward")
local fresh=Report.New()
check(fresh.reinforcements==0 and #fresh.choices==0 and fresh.entries~=report.entries, "new battle owns fresh totals")
local before=Report.Snapshot({members={member}}); member.hp=1
check(before.repair==3, "snapshots do not retain mutable member references")
print("supply report checks="..checks)
local routed=Report.New()
Report.Record(routed,"eff_route_mass",Report.Snapshot({wingmanCount=6}),
    Report.Snapshot({wingmanCount=12,routeChoice="mass"}),"gate",25)
check(routed.routeChoice=="mass" and routed.routeReinforcements==6,"route reward has its own actual gain")
check(Report.RouteSummary(routed):find("+6 僚机",1,true),"result summary uses actual reinforcement gain")
Report.Record(routed,"eff_plus2",Report.Snapshot({wingmanCount=12,routeChoice="mass"}),
    Report.Snapshot({wingmanCount=14,routeChoice="mass"}),"gate",40)
check(routed.reinforcements==8 and routed.routeReinforcements==6,"later rewards cannot inflate route gain")
local piercing=Report.New()
Report.Record(piercing,"eff_route_pierce",Report.Snapshot({}),Report.Snapshot({routeChoice="pierce",weaponMode="pierce"}),"gate",25)
check(Report.RouteSummary(piercing):find("已解锁穿透弹",1,true),"pierce summary records unlocked weapon")
check(Report.RouteSummary(Report.New())==nil,"new battle has no stale route summary")
print("route supply checks="..checks)
