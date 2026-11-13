-- Editor-only harness, executed by StgRuntimeBattleVerifier; also accepts dofile() for 1001.
-- Real frames and simulated drag only. Does not change HP/damage/time scale or player formation.
local levelId, expectedText, captureDir, choiceIndex, routeSide = ...
levelId = tonumber(levelId) or 1001
choiceIndex = choiceIndex or 1
assert(choiceIndex == 1 or choiceIndex == 2 or choiceIndex == 3, "choice index must be 1, 2 or 3")
routeSide = routeSide or 0
assert(routeSide == 0 or routeSide == 1 or routeSide == 2, "route side must be 0, 1 or 2")
captureDir = captureDir or (CS.UnityEngine.Application.dataPath .. "/../Captures")
if STGPlaythrough and STGPlaythrough.running then error("playthrough already running") end
local v = assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle), "battle window missing").View
local mgr = DataCenter.PlaneBattleDataManager
assert(mgr:GetFormation()[1] ~= 0, "主机未上阵英雄，请先在探险配置阵容后重试")
assert(LocalController:instance():getLine(TableName.PlaneLevel_Config, levelId), "该关尚未登记 PlaneLevel_Config")
local asset = assert(CS.UnityEngine.Resources.Load("STG/Levels/" .. levelId, typeof(CS.UnityEngine.TextAsset)), "missing level JSON")
expectedText = expectedText or asset.text
assert(asset.text == expectedText, "保存文件与 Resources TextAsset 内容不同，资源尚未刷新或验证期间被改写")
local expected = CommonUtil.JsonDecode(expectedText)
local r = { running=true, events={}, timeline={}, failures={}, checks=0, choices=0, frames=0,
    roles={}, warnings={}, waveUnits=0, gatesCreated=0, bosses=0, phases=0, shieldStarts=0, shieldBreaks=0,
    weaponModes={}, wingmanPeak=0, movingGateTravel=0, levelId=levelId, routeWaves={}, waveCalls={},
    unitInfo={}, waveStats={}, routeBanners={}, totalDamage=0, totalTaken=0 }
STGPlaythrough = r
local restore = {}
local oldGold, oldPass = rawget(mgr,"AddGold"), rawget(mgr,"OnLevelPass")
local oldUpdate, update = rawget(v,"Update"), v.Update
local logic, runner, oldDispatch, oldSetWeaponMode, oldSetRouteChoice, oldSpawnWave, oldBanner
local routeHooked=false
local function hook(name, observe)
    local original, old = v[name], rawget(v,name)
    restore[name] = { old=old }
    v[name] = function(self, ...)
        local result = original(self, ...)
        observe(self, ...)
        return result
    end
end
function r:Check(ok, message)
    self.checks = self.checks + 1
    if not ok then self.failures[#self.failures+1] = message end
end
local function same(a,b)
    if type(a) ~= type(b) then return false end
    if type(a) == "number" then return math.abs(a-b) < 0.0001 end
    if type(a) ~= "table" then return a == b end
    for k,value in pairs(a) do if not same(value,b[k]) then return false end end
    for k in pairs(b) do if a[k] == nil then return false end end
    return true
end
-- Check each explicitly saved field in sections whose parsed shape is unchanged.
local function fields(saved, loaded, path)
    if type(saved) ~= 'table' then return end
    for key,value in pairs(saved) do
        if type(value) == "table" then fields(value, loaded and loaded[key], path.."."..key)
        else r:Check(same(value,loaded and loaded[key]), path.."."..key.." differs") end
    end
end
function r:Describe()
    local lines = {
        "result="..tostring(self.result).." (1=Win,2=Lose)",
        string.format("battleTime=%.3f\nhp=%s\nchecks=%d\nmismatches=%d\nresultVisible=%s",
            self.time or 0,tostring(self.hp),self.checks,#self.failures,tostring(self.resultVisible)),
        string.format("waveUnits=%d\ngatesCreated=%d\nbosses=%d\nphases=%d\nshieldStarts=%d\nshieldBreaks=%d\nchoices=%d",
            self.waveUnits,self.gatesCreated,self.bosses,self.phases,self.shieldStarts,self.shieldBreaks,self.choices),
        "wingmanPeak="..tostring(self.wingmanPeak).."\nmovingGateTravel="..string.format("%.1f",self.movingGateTravel),
        "route="..tostring(self.route).."\nrouteWaves="..table.concat(self.routeWaves,","),
        string.format("totalDamage=%.1f\ntotalTaken=%.1f\nbossCombatSeconds=%.3f",self.totalDamage,self.totalTaken,
            self.bossDeadAt and self.bossSpawnAt and self.bossDeadAt-self.bossSpawnAt or -1),
        "bossWeapon="..tostring(self.bossWeapon).."\ncomparisonMovingGate="..(routeSide>0 and "left/pierce" or "auto"),
        "persistentOverridesRestored="..tostring(self.restored),
        "error="..tostring(self.error),
        "[timeline: scheduled -> actual runner seconds]",
    }
    for _,e in ipairs(self.timeline) do
        lines[#lines+1]=string.format("%.3f -> %.3f | %s | %s",e.expected,e.actual,e.kind,e.id)
    end
    lines[#lines+1]="[wave metrics: spawn to kill; missed means left the screen]"
    local ids={}; for id in pairs(self.waveStats) do ids[#ids+1]=id end; table.sort(ids)
    for _,id in ipairs(ids) do
        local w=self.waveStats[id]
        lines[#lines+1]=string.format("wave=%s spawned=%d killed=%d missed=%d clearSeconds=%.3f meanKillSeconds=%.3f",id,w.spawned,w.killed,w.missed or 0,
            w.killed==w.spawned and w.lastKill-w.firstSpawn or -1,w.killed>0 and w.killLife/w.killed or -1)
    end
    lines[#lines+1]="[observations]"
    for _,e in ipairs(self.events) do lines[#lines+1]=e end
    for _,f in ipairs(self.failures) do lines[#lines+1]="FAIL: "..f end
    return table.concat(lines,"\n")
end
function r:Stop(reason)
    if not self.running then return end
    self.running=false
    self.time, self.result, self.hp = v.battleTime, logic and logic.result, v.playerHull
    self.route=logic and logic.GetRouteChoice and logic:GetRouteChoice() or "balanced"
    self.resultVisible = v.resultPanelGo and v.resultPanelGo.activeSelf or false
    for _,value in pairs(v.battleStats and v.battleStats.damage or {}) do self.totalDamage=self.totalDamage+value end
    for _,value in pairs(v.battleStats and v.battleStats.taken or {}) do self.totalTaken=self.totalTaken+value end
    local expectedDamage=0
    for enemy,unit in pairs(self.unitInfo) do
        expectedDamage=expectedDamage+unit.maxHp-math.max(0,enemy.hp or 0)
        if not unit.killed and enemy.go==nil then local w=self.waveStats[unit.id]; w.missed=(w.missed or 0)+1 end
    end
    if self.bossTarget then expectedDamage=expectedDamage+self.bossTarget.maxHp-math.max(0,self.bossTarget.hp or 0) end
    if reason == "finished" then
        self:Check(self.result==1,"battle did not win; this run did not cover all victory checks")
        self:Check(self.resultVisible,"result panel not visible")
        self:Check(math.abs(self.totalDamage-expectedDamage)<.01,"damage ledger differs from enemy/boss actual HP loss")
        if self.hasRouteEvents and routeSide > 0 then
            self:Check(self.expectedRoute ~= nil and self.route == self.expectedRoute, "requested route side was not crossed")
            self:Check(#self.routeWaves > 0, "selected route did not dispatch its wave")
        end
        for index,event in ipairs(runner and runner.events or {}) do
            if event.time <= runner.time and not self.dispatched[event] then
                self:Check(false,"due timeline event missing: "..index..":"..event.type)
            elseif event.time > runner.time then
                self.events[#self.events+1]=string.format("UNOBSERVED future event %.2f %s (battle already ended)",event.time,event.type)
                self:Check(false,'timeline coverage incomplete: '..event.type..'@'..event.time)
            end
        end
        self.reason = #self.failures==0 and "passed" or "failed"
    else self.reason=reason end
    v.Update=oldUpdate
    for name,state in pairs(restore) do v[name]=state.old end
    if logic and oldSetWeaponMode then logic.SetWeaponMode=oldSetWeaponMode end
    if logic and routeHooked then logic.SetRouteChoice=oldSetRouteChoice end
    if runner then
        runner._Dispatch=oldDispatch
        if oldSpawnWave then runner.callbacks.OnSpawnEnemyWave=oldSpawnWave end
        if oldBanner then runner.callbacks.OnShowBanner=oldBanner end
    end
    mgr.AddGold,mgr.OnLevelPass=oldGold,oldPass
    self.restored=rawget(mgr,"AddGold")==oldGold and rawget(mgr,"OnLevelPass")==oldPass and rawget(v,"Update")==oldUpdate
    if self.resultVisible then
        local supply=v.battleStats and v.battleStats.supplies
        if supply then
            self.events[#self.events+1]=string.format("supplies gained=%d lost=%d weapon=%d armor=%d haste=%.2f freeze=%.2f choices=%s",
                supply.reinforcements,supply.lost,supply.weapon,supply.repair,supply.haste,supply.freeze,table.concat(supply.choices,","))
            if reason=="finished" then self:Check(#supply.choices==self.choices,"supply choices not recorded exactly once") end
            if reason=="finished" and self.route~="balanced" then
                self:Check(supply.routeChoice==self.route,"supply route summary differs")
                self:Check(v.resultView.routeSummary and v.resultView.routeSummary.gameObject.activeSelf,"result route summary is hidden")
            end
        end
        for role,count in pairs(self.roles) do self.events[#self.events+1]="role="..role.." spawned="..count end
        v.resultView:SetMode("supplies")
        CS.UnityEngine.ScreenCapture.CaptureScreenshot(captureDir.."/stg_full_run_result.png")
    end
    if reason=="finished" then self.reason=#self.failures==0 and "passed" or "failed" end
end

-- Intercept only save methods; logical battle gold and actual gameplay remain intact.
mgr.AddGold=function() end
mgr.OnLevelPass=function() end
local ok, err = xpcall(function()
    hook("_OnStgSpawnRequests", function(self,requests)
        for index,request in ipairs(requests or {}) do
            local enemy=self.enemies[#self.enemies-#requests+index]
            local wave=logic and logic.cfg.waveById[request.templateId]
            r.waveUnits=r.waveUnits+1
            if enemy then
                local w=r.waveStats[request.templateId] or {spawned=0,killed=0,killLife=0,firstSpawn=self.battleTime}
                r.waveStats[request.templateId]=w
                w.spawned=w.spawned+1
                r.unitInfo[enemy]={id=request.templateId,spawnAt=self.battleTime,maxHp=enemy.maxHp}
            end
            r:Check(enemy and enemy.stgTemplateId==request.templateId,"wave visual missing")
            if enemy and wave then
                local role=wave.behavior.role or "standard"
                r.roles[role]=(r.roles[role] or 0)+1
                r:Check(enemy.enemyRole==role,"enemy role differs: "..request.templateId)
                r:Check(enemy.shotCount==wave.behavior.shotCount,"enemy volley count differs: "..request.templateId)
                r:Check(enemy.spreadAngle==wave.behavior.spreadAngle,"enemy spread differs: "..request.templateId)
                r:Check(enemy.maxHp==wave.hp,"wave HP differs: "..request.templateId)
                r:Check(math.abs(enemy.speed-wave.entryPath.speed)<0.001,"wave speed differs: "..request.templateId)
            end
        end
    end)
    hook("_OnEnemyDead",function(self,enemy)
        local unit=r.unitInfo[enemy]
        if unit and not unit.killed then
            unit.killed=true
            local w=r.waveStats[unit.id]
            w.killed=w.killed+1; w.lastKill=self.battleTime; w.killLife=w.killLife+self.battleTime-unit.spawnAt
        elseif enemy.kind=="boss" then r.bossDeadAt=self.battleTime end
    end)
    hook("_CreateStgGateVisual", function(self,config)
        local visual=self.gates[#self.gates]
        r.gatesCreated=r.gatesCreated+1
        r:Check(visual and visual.stgGate and visual.stgGate.trapConfig==config,"gate visual/config mismatch: "..tostring(config.trapId))
        r.events[#r.events+1]=string.format("gate@%.2f %s type=%s",self.battleTime,config.trapId,config.gateType)
    end)
    local presentationSeen={}
    hook("_PlayEnemySound",function(self,event)
        if not presentationSeen[event] then
            presentationSeen[event]=true
            r.events[#r.events+1]=string.format("enemy-cue@%.2f %s",self.battleTime,event)
        end
    end)
    local roleKills={}
    hook("_SpawnEnemyDefeatFx",function(self,enemy)
        local role=enemy.enemyRole
        if role and role~="standard" and not roleKills[role] then
            roleKills[role]=true
            r.events[#r.events+1]=string.format("role-killed@%.2f %s",self.battleTime,role)
        end
    end)
    local phaseSeen={}
    hook("_RefreshBossPhase", function(self,boss)
        if boss and boss.phaseId and phaseSeen[boss]~=boss.phaseId then
            phaseSeen[boss]=boss.phaseId
            r.phases=r.phases+1
            if (boss.rageShield or 0)>0 then r.shieldStarts=r.shieldStarts+1 end
            local ratio=(boss.hp or 0)/math.max(1,boss.maxHp or 1)
            r.events[#r.events+1]=string.format("phase@%.2f id=%s hpRatio=%.3f shield=%s",self.battleTime,boss.phaseId,ratio,tostring(boss.rageShield))
            local selected=boss.bossConfig.phases[1]
            for _,phase in ipairs(boss.bossConfig.phases) do if ratio<=phase.hpThreshold then selected=phase end end
            r:Check(boss.phaseId==selected.phaseId,"boss phase threshold differs")
            local skill=selected.skills and selected.skills[1]
            if skill then
                r:Check(boss.fireInterval==skill.interval,"boss fire interval differs")
                local counterplay = logic.cfg.bossCounterplay and boss.counterLargeFormation and selected.phaseId >= 2
                r:Check(counterplay and boss.shotCount==skill.bulletCount+2 or boss.shotCount==skill.bulletCount,"boss bullet count differs")
            end
        end
    end)
    hook("_OnStgSpawnBoss",function(self,id)
        r.bosses=r.bosses+1
        r.bossSpawnAt=self.battleTime
        local boss=self.boss
        r.bossTarget=boss
        r.bossWeapon=boss and boss.counterMode
        if routeSide>0 then r:Check(r.bossWeapon=="pierce","comparison run did not keep common moving-gate weapon") end
        r:Check(boss and boss.maxHp==self.logic.cfg.bossById[id].totalHp,"boss visual HP differs")
        r.events[#r.events+1]=string.format("boss@%.2f %s",self.battleTime,id)
        CS.UnityEngine.ScreenCapture.CaptureScreenshot(captureDir.."/stg_full_run_boss.png")
    end)
    v:_EnterLevel(levelId)
    assert(not v.isInLevelSelect,"主机未上阵，无法进入关卡")
    v:_HideGuide()
    logic=assert(v.logic,"failed to enter STG battle")
    oldSetWeaponMode=logic.SetWeaponMode
    logic.SetWeaponMode=function(self,mode)
        local result=oldSetWeaponMode(self,mode)
        if result then
            r.weaponModes[#r.weaponModes+1]=mode
            r.events[#r.events+1]=string.format("weapon-mode@%.2f %s",v.battleTime,mode)
        end
        return result
    end
    oldSetRouteChoice=rawget(logic,"SetRouteChoice")
    local setRouteChoice=logic.SetRouteChoice
    logic.SetRouteChoice=function(self,route)
        local before=self:GetWingmanCount()
        local result=setRouteChoice(self,route)
        if result then
            r.route=self:GetRouteChoice()
            r.events[#r.events+1]=string.format("route@%.2f %s wingmen=%d->%d",v.battleTime,r.route,before,self:GetWingmanCount())
            r:Check(r.route==route,"route reward did not set route")
            if route=="mass" then r:Check(self:GetWingmanCount()==before*2,"mass route did not double formation")
            else r:Check(self:GetWeaponMode()==route,"route weapon differs") end
        end
        return result
    end
    routeHooked=true
    local cfg=assert(logic.cfg,"no runtime config")
    fields(expected.basicScroll,cfg.basicScroll,"basicScroll")
    fields(expected.playerRules,cfg.playerRules,"playerRules")
    for index,layer in ipairs(expected.backgroundLayers or {}) do
        local loaded=cfg.backgroundLayers[index]
        r:Check(loaded~=nil,'background layer missing: '..index)
        for key,value in pairs(layer) do
            if key=='scatterInterval' and type(value)=='table' then
                r:Check(same(value[1],loaded and loaded.scatterIntervalMin) and same(value[2],loaded and loaded.scatterIntervalMax),'scatter interval differs')
            elseif key=='scatterRules' and type(value)=='table' then
                for ruleIndex,rule in ipairs(value) do
                    local actual=loaded and loaded.scatterRules[ruleIndex]
                    for ruleKey,ruleValue in pairs(rule) do
                        if ruleKey=='sizeRange' then
                            r:Check(actual and same(ruleValue[1],actual.sizeRangeMin) and same(ruleValue[2],actual.sizeRangeMax),'scatter size differs')
                        else r:Check(actual and same(ruleValue,actual[ruleKey]),'scatter rule differs: '..ruleKey) end
                    end
                end
            else r:Check(loaded and same(value,loaded[key]),'background field differs: '..key) end
        end
    end
    fields(expected.enemyWaveTemplates,cfg.waveTemplates,"enemyWaveTemplates")
    fields(expected.bossConfigs,cfg.bossConfigs,"bossConfigs")
    fields({levelId=expected.levelId,levelName=expected.levelName,seed=expected.seed},cfg,'root')
    r:Check(#(expected.timeline.events or {})==#cfg.timeline.events,'timeline event count differs')
    r:Check(same(expected.timeline.duration,cfg.timeline.duration),'timeline duration differs')
    -- JSON event positions/offsets are flattened by the runtime parser. Match events independently
    -- of ordering at identical timestamps, then verify every explicitly saved event field.
    local matched={}
    for _,saved in ipairs(expected.timeline.events or {}) do
        if saved.routeChoice and saved.routeChoice~="" then r.hasRouteEvents=true end
        local actual
        for i,event in ipairs(cfg.timeline.events) do
            if not matched[i] and event.time==saved.time and event.type==saved.type
                and (not saved.trapId or event.trapId==saved.trapId)
                and (not saved.templateId or event.templateId==saved.templateId)
                and (not saved.bossId or event.bossId==saved.bossId)
                and (not saved.routeChoice or event.routeChoice==saved.routeChoice)
                and (not saved.text or event.text==saved.text) then
                actual=event; matched[i]=true; break
            end
        end
        r:Check(actual~=nil,'saved event missing: '..saved.type)
        if actual then
            for key,value in pairs(saved) do
                if key=='position' then
                    r:Check(same(value.x,actual.positionX) and same(value.y,actual.positionY),'timeline position differs')
                elseif key=='offsetRange' then
                    for axis,bound in pairs(value) do
                        local mapped='offset'..axis:sub(1,1):upper()..axis:sub(2)
                        r:Check(same(bound,actual[mapped]),'timeline offset differs: '..axis)
                    end
                elseif key=='interval' and saved.type=='drop_digital_gate' then
                    r:Check(same(value,actual.dropIntervalSec),'drop interval differs')
                else r:Check(same(value,actual[key]),'timeline field differs: '..key) end
            end
        end
    end
    for _,saved in ipairs(expected.trapConfigs or {}) do
        local loaded=cfg.trapById[saved.trapId]
        r:Check(loaded~=nil,"trap not loaded: "..saved.trapId)
        if loaded then
            fields(saved.params,loaded.params,"trap."..saved.trapId..".params")
            for key,value in pairs(type(saved.params)=='table' and saved.params or {}) do
                if loaded[key]~=nil then r:Check(same(value,loaded[key]),"trap parsed field differs: "..saved.trapId.."."..key) end
            end
        end
    end
    r:Check(v.bgRenderer and #v.bgRenderer.layers==#(expected.backgroundLayers or {}),"background layer count differs")
    local backgroundChecked=false
    runner=assert(logic.runner)
    r.dispatched={}
    oldDispatch=rawget(runner,"_Dispatch")
    oldSpawnWave=runner.callbacks.OnSpawnEnemyWave
    oldBanner=runner.callbacks.OnShowBanner
    runner.callbacks.OnShowBanner=function(text,duration)
        r.routeBanners[#r.routeBanners+1]=text
        return oldBanner(text,duration)
    end
    runner.callbacks.OnSpawnEnemyWave=function(id,offset)
        r.waveCalls[#r.waveCalls+1]=id
        return oldSpawnWave(id,offset)
    end
    local dispatch=runner._Dispatch
    runner._Dispatch=function(self,event)
        r.dispatched[event]=true
        local gated=event.routeChoice and event.routeChoice~=""
        local allowed=not gated or event.routeChoice==logic:GetRouteChoice()
        r.timeline[#r.timeline+1]={expected=event.time,actual=self.time,kind=event.type,
            id=event.templateId~="" and event.templateId or (event.trapId~="" and event.trapId or event.bossId or "")}
        if gated and not allowed then r.timeline[#r.timeline].kind=event.type.." [skipped:"..event.routeChoice.."]" end
        r:Check(self.time>=event.time and self.time-event.time<=math.max(0.1,CS.UnityEngine.Time.deltaTime+0.01),"event late: "..event.type)
        local before=#r.waveCalls
        local bannersBefore=#r.routeBanners
        local result=dispatch(self,event)
        if gated and event.type=="show_banner" then
            r:Check(#r.routeBanners-bannersBefore==(allowed and 1 or 0),"route banner filter differs")
            if allowed then
                r.events[#r.events+1]="route-banner: "..event.text
                CS.UnityEngine.ScreenCapture.CaptureScreenshot(captureDir.."/stg_route_forecast_"..routeSide..".png")
            end
        end
        if gated and event.type=="spawn_enemy_wave" then
            r:Check(#r.waveCalls-before==(allowed and 1 or 0),"route filter dispatched wrong wave: "..event.templateId)
            if allowed then
                r:Check(r.waveCalls[#r.waveCalls]==event.templateId,"route wave template differs")
                r.routeWaves[#r.routeWaves+1]=event.templateId
            end
        end
        return result
    end
    local shieldWasUp=false
    v.Update=function(self)
        local frameOk,frameErr=xpcall(function()
            if self.isInLevelSelect or self.logic~=logic or not self.gameObject.activeInHierarchy then r:Stop("cancelled"); return end
            if self.isChoicePaused then
                r.choices=r.choices+1
                local panel = self.gateChoicePanel
                local selected = choiceIndex
                if panel.cards and not panel.cards[selected].button.interactable then
                    selected = nil
                    for i, card in ipairs(panel.cards) do if card.button.interactable then selected = i; break end end
                end
                r.events[#r.events+1]=string.format("choice@%.2f requested=%d selected=%s",self.battleTime,choiceIndex,tostring(selected or 'skip'))
                assert(selected and panel:Choose(selected) or (selected == nil and panel:Skip()),"choice failed")
            end
            if not self.isBattleOver and self.bossDefeat==nil then
                local px,py=self:GetPlayerPlanePos()
                local target,nearest=0,math.huge
                for _,enemy in ipairs(self.enemies) do
                    local ex,ey=enemy:GetLocalPos()
                    if not enemy.isDead and ey>py+100 and ey<nearest then target,nearest=ex,ey end
                end
                for _,gate in ipairs(self.gates) do
                    local gx,gy=gate:GetLocalPos()
                    if gy>py and gy<py+500 and gate.kind~="subtract" then target=gx; break end
                end
                for _,b in ipairs(self.bulletPool:GetActiveList()) do
                    local p=b.rt.anchoredPosition
                    if b.faction=="enemy" and p.y>py and p.y<py+160 and math.abs(p.x-target)<50 then
                        target=p.x>0 and p.x-80 or p.x+80
                    end
                end
                if routeSide>0 then
                    for _,gate in ipairs(self.gates) do
                        local g=gate.stgGate
                        local gx,gy=gate:GetLocalPos()
                        local id=g and (routeSide==1 and g.leftEffectId or g.rightEffectId)
                        local meta=id and require("Game.STG.Trigger.StgTriggerEnum").EffectTable[id]
                        if not gate.hasTriggered and meta and meta.type==100 and gy>py and gy<py+850 then
                            target=gx+gate.cards[routeSide].rt.anchoredPosition.x
                            r.expectedRoute=meta.para
                            if not r.routeCaptured and gy<py+550 then
                                r.routeCaptured=true
                                CS.UnityEngine.ScreenCapture.CaptureScreenshot(captureDir.."/stg_route_side_"..routeSide..".png")
                            end
                            break
                        elseif not gate.hasTriggered and g and g.gateType=="gate_duet"
                            and g.trapConfig.moveMode=="horizontal_sine" and gy>py and gy<py+850 then
                            -- Compare route rewards with the same later weapon selection.
                            target=gx+gate.cards[1].rt.anchoredPosition.x
                            break
                        end
                    end
                end
                local step=math.max(-8,math.min(8,target-px))
                self:_OnDragPlayerPlane({delta=CS.UnityEngine.Vector2(step*(self.inputCanvas and self.inputCanvas.scaleFactor or 1),0)})
            end
            update(self)
            r.wingmanPeak=math.max(r.wingmanPeak,logic:GetWingmanCount() or 0)
            for _,gate in ipairs(self.gates or {}) do
                local config=gate.stgGate and gate.stgGate.trapConfig
                if config and config.moveMode=="horizontal_sine" and gate.spawnX then
                    local gx=gate:GetLocalPos()
                    r.movingGateTravel=math.max(r.movingGateTravel,math.abs(gx-gate.spawnX))
                end
            end
            for _,enemy in ipairs(self.enemies) do
                local role=enemy.enemyRole
                if role and role~="standard" and not r.warnings[role]
                    and (enemy.pendingShot or (enemy.roleState and enemy.roleState.phase=="warning")) then
                    r.warnings[role]=true
                    r.events[#r.events+1]=string.format("warning@%.2f %s",self.battleTime,role)
                    CS.UnityEngine.ScreenCapture.CaptureScreenshot(captureDir.."/stg_role_"..role..".png")
                end
            end
            r.frames=r.frames+1
            r.time,r.hp=self.battleTime,self.playerHull
            if not r.routeHudChecked and self.battleTime>32 then
                r.routeHudChecked=true
                local hud=self.hudRouteText
                r:Check(hud and hud.gameObject.activeSelf==not not r.hasRouteEvents,"route HUD visibility differs")
                if r.hasRouteEvents then
                    r:Check(hud and hud.text:find(require("UI.UIPlaneBattle.Logic.GateBattleReport").RouteName(logic:GetRouteChoice()),1,true),"route HUD label differs")
                end
            end
            if not backgroundChecked and r.frames>=10 then
                backgroundChecked=true
                for _,layer in ipairs(self.bgRenderer and self.bgRenderer.layers or {}) do
                    if layer.cfg.useTileLoop then
                        r:Check(#layer.tiles>=2,"background strip missing: "..layer.cfg.layerId)
                        for _,tile in ipairs(layer.tiles) do
                            local img=tile.go:GetComponent(typeof(CS.UnityEngine.UI.Image))
                            r:Check(img.sprite~=nil,"background sprite missing: "..layer.cfg.layerId)
                        end
                    end
                end
            end
            local shieldUp=self.boss and (self.boss.rageShield or 0)>0 or false
            if shieldWasUp and not shieldUp then
                r.shieldBreaks=r.shieldBreaks+1
                r.events[#r.events+1]=string.format("shield-broken@%.2f",self.battleTime)
            end
            shieldWasUp=shieldUp
            if self.isBattleOver and self.bossDefeat==nil then r:Stop("finished") end
            if self.battleTime>math.max(180,cfg.timeline.duration*3) then r:Stop("timeout") end
        end,debug.traceback)
        if not frameOk then r.error=frameErr; r:Stop("error"); Logger.LogError(frameErr) end
    end
end, debug.traceback)
if not ok then r.error=err; r:Stop("error"); error(err) end
return "started natural "..levelId.." playthrough"

