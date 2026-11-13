-- Exercise the actual view methods without constructing Unity UI.
local f=assert(io.open("Assets/Main/LuaScripts/UI/UIPlaneBattle/View/UIPlaneBattleView.lua","r"))
local source=f:read("*a"); f:close()
local methods=assert(source:match("(function UIPlaneBattleView:_TakeBattleTargetDamage.-)\nfunction UIPlaneBattleView:_OnEnemyDead"))
local View=assert(load("local UIPlaneBattleView={}\nlocal Color=function() end\n"..methods.."\nreturn UIPlaneBattleView"))()
local checks=0
local function check(ok,msg) assert(ok,msg); checks=checks+1 end
local function target(hp,shield,kind)
    return {hp=hp,kind=kind or "enemy",rageShield=shield or 0,nextShieldFxAt=999,
        GetLocalPos=function() return 0,0 end,
        TakeDamage=function(self,n) self.hp=math.max(0,self.hp-n); self.isDead=self.hp==0; return self.isDead end}
end
local v=setmetatable({battleTime=0,battleStats={damage={}},
    _SpawnCombatFx=function() end,_ShowBossPhaseNotice=function() end},{__index=View})
local e=target(7)
check(v:_TakeBattleTargetDamage(e,20),"lethal hit kills")
check(v._lastDamageApplied==7,"overkill capped at pre-hit HP")
v:_RecordBattleDamage(e,v._lastDamageApplied,"primary")
check(v.battleStats.damage.primary==7,"lethal hit remains in damage ledger")
e=target(10)
v:_TakeBattleTargetDamage(e,6); v:_RecordBattleDamage(e,v._lastDamageApplied,"primary")
check(e.hp==4 and v.battleStats.damage.primary==13,"nonlethal hit counts full loss even near zero")
e=target(9,5,"boss")
check(not v:_TakeBattleTargetDamage(e,3) and e.hp==9 and v._lastDamageApplied==0,"shield-only hit does not count as hull output")
check(v:_TakeBattleTargetDamage(e,30) and v._lastDamageApplied==9,"shield spill caps damage at boss HP")
v:_RecordBattleDamage(e,v._lastDamageApplied,"primary")
check(v.battleStats.damage.primary==22,"boss kill counted once with shield excluded")
v:_TakeBattleTargetDamage(e,30); v:_RecordBattleDamage(e,v._lastDamageApplied,"primary")
check(v.battleStats.damage.primary==22,"dead target cannot award repeated output")
v:_RecordBattleDamage(target(5,0,"bucket"),5,"primary")
check(v.battleStats.damage.primary==22,"barrels excluded")
print("STG damage accounting PASS "..checks)
