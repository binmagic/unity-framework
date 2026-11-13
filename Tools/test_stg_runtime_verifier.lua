-- Standalone regression checks for editor harness failure/cancellation cleanup (no Unity required).
local checks=0
local function check(ok,msg) assert(ok,msg); checks=checks+1 end
local harness=assert(loadfile('Tools/verify_stg_level_playthrough.lua'))
typeof=function(x) return x end
CS={UnityEngine={Resources={Load=function() return {text='{}'} end},TextAsset={}}}
local mgr={GetFormation=function() return {1,0,0,0,0} end,AddGold=function() end,OnLevelPass=function() end}
DataCenter={PlaneBattleDataManager=mgr}
LocalController={instance=function() return {getLine=function() return true end} end}
TableName={PlaneLevel_Config='levels'}
UIWindowNames={UIPlaneBattle='battle'}
local methods={Update=function() end,_OnStgSpawnRequests=function() end,_CreateStgGateVisual=function() end,
    _RefreshBossPhase=function() end,_OnStgSpawnBoss=function() end,_HideGuide=function() end}
local v=setmetatable({battleTime=0,playerHull=3},{__index=methods})
UIManager={GetInstance=function() return {GetWindow=function() return {View=v} end} end}
CommonUtil={JsonDecode=function() return {timeline={duration=1,events={}},backgroundLayers={}} end}
local gold,pass=mgr.AddGold,mgr.OnLevelPass
local function restored()
    check(mgr.AddGold==gold and mgr.OnLevelPass==pass,'persistent methods restored')
    check(rawget(v,'Update')==nil,'Update override removed')
    for name in pairs(methods) do check(rawget(v,name)==nil,'view method override removed: '..name) end
    if v.logic then check(rawget(v.logic,'SetRouteChoice')==nil,'route observer removed after cleanup') end
end

local ok,err=pcall(harness,1001,'different saved JSON','unused')
check(not ok and tostring(err):find('TextAsset',1,true),'stale TextAsset rejected')
restored()

methods._EnterLevel=function() error('fixture startup failure') end
ok,err=pcall(harness,1001,'{}','unused')
check(not ok and tostring(err):find('fixture startup failure',1,true),'startup failure surfaced')
check(STGPlaythrough.running==false and STGPlaythrough.reason=='error','startup failure stops harness')
restored()

local future={time=5,type='spawn_boss'}
methods._EnterLevel=function(self)
    self.logic={cfg={timeline={duration=1,events={}},backgroundLayers={},waveTemplates={},bossConfigs={},trapById={}},
        runner={events={future},time=0,_Dispatch=function() end,callbacks={OnSpawnEnemyWave=function() end}},result=1}
    self.bgRenderer={layers={}}
end
harness(1001,'{}','unused')
check(STGPlaythrough.running and mgr.AddGold~=gold,'test intercepts installed during run')
STGPlaythrough:Stop('cancelled')
check(STGPlaythrough.reason=='cancelled' and STGPlaythrough.restored,'cancel restores state')
restored()

harness(1001,'{}','unused')
STGPlaythrough:Stop('finished')
check(STGPlaythrough.reason=='failed','incomplete coverage/result panel cannot pass')
check(#STGPlaythrough.failures>=2,'missing result and future event are reported')
restored()
print('STG runtime verifier PASS '..checks)
