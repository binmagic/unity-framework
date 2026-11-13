package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
Logger = {Log=function() end, LogError=function(message) error(message) end}
local Role = require "UI.UIPlaneBattle.Logic.EnemyRoleBehavior"
local Spawner = require "Game.STG.Spawner.StgWaveSpawner"
local checks = 0
local function check(ok, message) assert(ok, message); checks=checks+1 end
local s = Role.New({role="charger", warningDuration=1, chargeTriggerRatio=.5, chargeSpeedMultiplier=3})
check(Role.Step(s, 900, 1000, 200, .5)==100 and s.phase=="approach", "approach uses base speed")
check(Role.Step(s, 550, 1000, 200, .5)==50 and s.phase=="warning" and s.remaining==.75, "threshold crossing consumes only leftover warning time")
check(Role.Step(s, 500, 1000, 200, .5)==0 and s.remaining==.25, "windup remains stationary")
local remaining=s.remaining
check(Role.Step(s,500,1000,200,0)==0 and s.remaining==remaining, "zero dt never advances warning")
check(s.remaining==remaining, "not ticking during freeze or choice preserves warning")
check(Role.Step(s, 500, 1000, 200, .5)==150 and s.phase=="charge", "acceleration only after full warning")
check(Role.Step(s, 350, 1000, 200, .2)==120, "charge persists after threshold")
for _, role in ipairs({"standard","swarm","armored"}) do
    check(Role.Step(Role.New({role=role}), 400, 1000, 125, .2)==25, "non-charger retains speed "..role)
end
local bad=Role.Config({role="unknown",shotCount=100,spreadAngle=-1,warningDuration=0/0,chargeTriggerRatio=2,chargeSpeedMultiplier=math.huge})
check(bad.role=="standard" and bad.shotCount==7 and bad.spreadAngle==0, "invalid roles / burst settings clamped")
check(bad.warningDuration==.75 and bad.chargeTriggerRatio==.8 and bad.chargeSpeedMultiplier==2.4, "nonfinite / unsafe motion config handled")
local wave={enemyType="8002",hp=300,entryPath={speed=125},behavior={role="armored",shotCount=3,spreadAngle=32,warningDuration=.85}}
local request=Spawner.New():BuildRequest(wave,{x=0,y=1700},1)
check(request.behavior==wave.behavior and request.hp==300, "spawner preserves behavior and HP")
local cfg=Role.Config(request.behavior)
check(cfg.role=="armored" and cfg.shotCount==3 and cfg.spreadAngle==32 and cfg.warningDuration==.85, "heavy volley receives editor settings")
local function simulate(fps)
    local state=Role.New({role="charger",chargeTriggerRatio=.74,warningDuration=1.15,chargeSpeedMultiplier=2.1})
    local y=1705
    for i=1,fps*5 do y=y-Role.Step(state,y,1625,220,1/fps) end
    return y,state.phase
end
local slow,phase=simulate(30)
local fast=simulate(60)
check(math.abs(slow-fast)<.001 and phase=="charge", "windup and charge distance match at 30 / 60 FPS")
local varied=simulate(50)
check(math.abs(slow-varied)<.001, "editor 50 FPS uses same movement timing")
print("enemy role checks="..checks)
