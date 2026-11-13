-- Real Unity objects: role geometry, freeze-safe animation and pooled death effects.
local v=assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle)).View
local Profiles=require "UI.UIPlaneBattle.Logic.EnemyRolePresentation"
local mgr=DataCenter.PlaneBattleDataManager
local oldGold,oldPass=rawget(mgr,"AddGold"),rawget(mgr,"OnLevelPass")
mgr.AddGold,mgr.OnLevelPass=function() end,function() end
local checks=0
local function check(ok,message) assert(ok,message);checks=checks+1 end
local ok,err=xpcall(function()
    v:_EnterLevel(1001);v:_HideGuide();v.isChoicePaused=true
    local logic=v.logic
    local function spawn(id,x,y)
        local wave=assert(logic.cfg.waveById[id])
        v:_OnStgSpawnRequests({logic.waveSpawner:BuildRequest(wave,{x=x/375,y=1700},1)})
        local enemy=v.enemies[#v.enemies];enemy:SetLocalPos(x,y);return enemy
    end
    local swarm=spawn("w_intro_swarm",-220,1200)
    local heavy=spawn("w_intro_armored",0,1100)
    local charger=spawn("w_intro_charger",220,1000)
    for _,enemy in ipairs({swarm,heavy,charger}) do
        local p=Profiles.Get(enemy.enemyRole)
        check(enemy.rt.sizeDelta.x==p.width and enemy.rt.sizeDelta.y==p.height,"distinct role dimensions "..enemy.enemyRole)
        check(#enemy.roleVisual.engines==p.engines,"configured engine count "..enemy.enemyRole)
        local input=false
        for _,image in ipairs({enemy.roleVisual.engines[1].img,enemy.roleVisual.badge.img,enemy.roleVisual.muzzle.img}) do input=input or image.raycastTarget end
        check(not input,"decorations do not intercept drag "..enemy.enemyRole)
        enemy.roleVisual:Update(.15,"approach")
        local x,y=enemy:GetLocalPos()
        check(y==({swarm=1200,armored=1100,charger=1000})[enemy.enemyRole],"visual animation preserves root position")
    end
    check(Profiles.Get("swarm").sprite~=Profiles.Get("charger").sprite and Profiles.Get("armored").sprite~=Profiles.Get("charger").sprite,"unique aircraft frames")
    charger.roleState.phase,charger.roleState.remaining="warning",charger.warningDuration*.5
    charger:ShowAttackWarning(1,0,900,.5,true)
    check(#charger.laneParts==14 and charger.laneParts[1].go.activeSelf and charger.laneParts[3].go.activeSelf,"rails and downward chevrons visible")
    local children=charger.go.transform.childCount
    for i=1,20 do charger:ShowAttackWarning(1,0,900,i/20,true) end
    check(charger.go.transform.childCount==children,"warning nodes reused across frames")
    charger:HideAttackWarning()
    check(not charger.laneParts[1].go.activeSelf and not charger.warningLines[1].go.activeSelf,"warning cleanup hides rails and fill")
    v:_UpdateEnemyFire(heavy,heavy.fireInterval)
    heavy:UpdateRoleVisual(.1)
    check(heavy.roleVisual.charge.go.activeSelf,"heavy charging glow active during windup")
    local age=heavy.roleVisual.age
    logic:ApplyTimedBuff("freeze",3,0);v:_UpdateEnemies(.2)
    check(heavy.roleVisual.age==age,"freeze stops visual animation too")
    logic:_UpdateTimedBuffs(3)
    v:_UpdateEnemyFire(heavy,heavy.pendingShot.remaining)
    heavy:UpdateRoleVisual(.01)
    check(heavy.roleVisual.muzzle.go.activeSelf and not heavy.roleVisual.charge.go.activeSelf,"muzzle flash replaces charge glow after volley")
    v:_UpdateCombatFx(1)
    v:_SpawnEnemyDefeatFx(swarm,-200,900)
    local lightCount=#v.combatFx
    v:_UpdateCombatFx(1)
    v:_SpawnEnemyDefeatFx(heavy,0,900)
    check(#v.combatFx>lightCount,"heavy death has extra shockwave and debris")
    v:_UpdateCombatFx(1)
    v:_SpawnEnemyDefeatFx(charger,200,900)
    local debris
    for _,fx in ipairs(v.combatFx) do if fx.vy then debris=fx;break end end
    check(debris and debris.vy==160,"charger debris keeps forward flight direction")
    local px=debris.rt.anchoredPosition.x;v:_UpdateCombatFx(.1)
    check(debris.rt.anchoredPosition.x~=px,"debris visibly moves")
    v:_UpdateCombatFx(1)
    local fx=v:_AcquireCombatFx("Assets/Main/Sprites/STG/CombatFx/energy_bolt.png",0,800,28,CS.UnityEngine.Color(1,1,1,1),.3,false)
    check(fx.vx==nil and fx.vy==nil and fx.spin==nil,"recycled hit effects clear debris motion")
    check(fx.rt.localRotation.eulerAngles.z==0,"recycled effects clear debris rotation")
    v:_UpdateCombatFx(1)
    for _,enemy in ipairs(v.enemies) do enemy:UpdateFreezeVisual(0,0) end
    -- Preview all three roles with readable warnings, without invoking collisions or save writes.
    heavy.fireTimer=heavy.fireInterval;v:_UpdateEnemyFire(heavy,.01);heavy:UpdateRoleVisual(.1)
    charger:ShowAttackWarning(1,0,900,.55,true);charger:UpdateRoleVisual(.1)
end,debug.traceback)
mgr.AddGold,mgr.OnLevelPass=oldGold,oldPass
assert(ok,err)
return "Unity role presentation PASS "..checks.."; paused preview; save methods restored"
