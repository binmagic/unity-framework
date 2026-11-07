-- Run in the project's Lua environment; no Unity nodes, saves or live roster are mutated.
local State=require "UI.UIPlaneBattle.Logic.HeroCombatState"
local Profile=require "UI.UIPlaneBattle.Logic.BattleHeroProfile"
local profiles={
    Profile.FromConfig({id=1001,role="Output"}),
    Profile.FromConfig({id=1002,role="Output"}),
    Profile.FromConfig({id=1004,role="Support"}),
    Profile.FromConfig({id=1005,role="Defense",skill_cooldown=1}),
}
local c=State.New({members=profiles})
assert(c.byId[1005].hp==4)
assert(c.byId[1005].hero.activeKind=="shield")
assert(c.byId[1005].hero.activeCooldown>=8)
assert(not c:CanCast(1001))
c:Tick(0)
assert(c.byId[1001].cooldown==3)
c:Tick(3)
assert(c:CommitCast(1001) and not c:CommitCast(1001))
assert(c.byId[1001].casts==1 and c.byId[1001].cooldown==10)
local lost,absorbed,dead=c:Damage(1002,1)
assert(lost==1 and absorbed==0 and not dead)
assert(c.byId[1001].hp==3 and c.byId[1002].hp==2)
assert(c:Damage(1002,1)==0)
c:Tick(.8)
c:GrantShield(2,4)
lost,absorbed=c:Damage(1002,1)
assert(lost==0 and absorbed==1 and c.byId[1002].hp==2)
c:Tick(.8)
lost,absorbed,dead=c:Damage(1002,9)
assert(lost==2 and absorbed==1 and dead)
assert(not c:CanCast(1002) and not c:CommitCast(1002))
assert(c:Repair(1002,99)==0 and c.byId[1002].dead)
local cd=c.byId[1002].cooldown
c:Tick(5)
assert(c.byId[1002].cooldown==cd)
assert(c.byId[1001].shield==0)
c.hasteRemaining=5
assert(c:GetFireRate()==1.6)
c:Tick(5)
assert(c:GetFireRate()==1)
assert(c:Damage(9999,1)==0 and c:Repair(9999,1)==0 and not c:CanCast(9999))
assert(profiles[2].hp==nil,"runtime HP leaked into hero config")
c:Delete()
return "hero_combat_state_spec: passed"
