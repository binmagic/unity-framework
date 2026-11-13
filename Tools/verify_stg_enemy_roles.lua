-- Unity-only component checks. Real saved config, real bullets/warnings; no save writes.
local v=assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle)).View
local mgr=DataCenter.PlaneBattleDataManager
local oldGold,oldPass=rawget(mgr,"AddGold"),rawget(mgr,"OnLevelPass")
mgr.AddGold,mgr.OnLevelPass=function() end,function() end
local checks=0
local function check(ok,message) assert(ok,message);checks=checks+1 end
local ok,err=xpcall(function()
    v:_EnterLevel(1001);v:_HideGuide();v.isChoicePaused=true
    local logic=assert(v.logic)
    local function spawn(id,x,y)
        local wave=assert(logic.cfg.waveById[id])
        local request=logic.waveSpawner:BuildRequest(wave,{x=x/375,y=1700},1)
        v:_OnStgSpawnRequests({request})
        local enemy=v.enemies[#v.enemies]
        enemy:SetLocalPos(x,y)
        return enemy
    end
    local heavy=spawn("w_intro_armored",-170,1100)
    local chargeCfg=logic.cfg.waveById.w_intro_charger.behavior
    local charger=spawn("w_intro_charger",170,v.battleContentTf.rect.height*chargeCfg.chargeTriggerRatio+1)
    local swarm=spawn("w_intro_swarm",0,1300)
    check(heavy.rt.sizeDelta.x>charger.rt.sizeDelta.x and swarm.rt.sizeDelta.x<charger.rt.sizeDelta.x,"roles use distinct sizes")
    local n=#v.bulletPool:GetActiveList()
    v:_UpdateEnemyFire(heavy,heavy.fireInterval-heavy.warningDuration+.01)
    check(heavy.pendingShot~=nil and #v.bulletPool:GetActiveList()==n,"heavy windup cannot fire early")
    check(#heavy.warningLines==3 and heavy.warningLines[1].go.activeSelf,"three advertised firing lanes")
    local remaining=heavy.pendingShot.remaining
    local cx,cy=charger:GetLocalPos()
    logic:ApplyTimedBuff("freeze",3,0)
    v:_UpdateEnemies(.3)
    local fx,fy=charger:GetLocalPos()
    check(cx==fx and cy==fy and heavy.pendingShot.remaining==remaining,"freeze pauses charge movement and heavy countdown")
    check(heavy.freezeGo.activeSelf and charger.freezeGo.activeSelf,"freeze shells visible on both roles")
    logic:_UpdateTimedBuffs(3)
    v:_UpdateEnemyFire(heavy,remaining)
    check(heavy.pendingShot==nil and #v.bulletPool:GetActiveList()==n+3,"heavy fires exactly configured three rounds after warning")
    local bullets=v.bulletPool:GetActiveList()
    check(math.abs(bullets[n+1].vx-math.tan(-16*math.pi/180)*310)<.001 and bullets[n+2].vx==0,"burst trajectories match warning spread")
    check(not heavy.warningLines[1].go.activeSelf,"completed volley clears its warning")
    charger:Update(.1)
    check(charger.roleState.phase=="warning","charger locks lane at configured threshold")
    local x,y=charger:GetLocalPos()
    local chargeRemaining=charger.roleState.remaining
    v:Update()
    check(charger.roleState.remaining==chargeRemaining,"choice pause preserves windup")
    charger:Update(chargeRemaining*.5)
    local stillX,stillY=charger:GetLocalPos()
    check(x==stillX and y==stillY,"windup remains stationary in advertised lane")
    charger:Update(chargeRemaining*.5+.1)
    local chargedX,chargedY=charger:GetLocalPos()
    check(chargedX==x and math.abs((y-chargedY)-charger.speed*chargeCfg.chargeSpeedMultiplier*.1)<.01,"charge accelerates straight down after full warning")
    charger:UpdateFreezeVisual(0,0)
    check(math.abs(charger.img.color.r-charger.baseColor.r)<.001 and math.abs(charger.img.color.g-charger.baseColor.g)<.001,"unfreeze restores role tint")
    local heavy2=spawn("w_intro_armored",0,950)
    v:_UpdateEnemyFire(heavy,heavy.fireInterval)
    v:_UpdateEnemyFire(heavy2,heavy2.fireInterval)
    check(heavy.warningLines[1].go~=heavy2.warningLines[1].go,"each heavy owns independent warning geometry")
    v:_UpdateEnemyFire(heavy2,heavy2.pendingShot.remaining)
    check(heavy.warningLines[1].go.activeSelf and not heavy2.warningLines[1].go.activeSelf,"one volley cannot hide another enemy warning")
    heavy2:Destroy();table.remove(v.enemies,#v.enemies)
    for _,enemy in ipairs(v.enemies) do enemy:UpdateFreezeVisual(0,0) end
    -- Leave one heavy and one charger winding up for a real frame screenshot.
    charger.roleState.phase,charger.roleState.remaining="warning",charger.warningDuration*.6
    charger:SetLocalPos(170,v.battleContentTf.rect.height*chargeCfg.chargeTriggerRatio)
    charger:Update(.01)
end,debug.traceback)
mgr.AddGold,mgr.OnLevelPass=oldGold,oldPass
assert(ok,err)
return "Unity enemy roles PASS "..checks.."; paused warning preview; save methods restored"
