package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
dofile("Assets/Main/LuaScripts/Framework/Common/BaseClass.lua")
typeof = function(x) return x end
CS = { UnityEngine = { GameObject = {}, RectTransform = {}, UI = { Image = {} },
    Quaternion = { Euler = function() return {} end }, Color = function() return {} end,
    Vector2 = function(x,y) return {x=x,y=y} end } }
IsNull = function(x) return x == nil end
local Weapon = require "UI.UIPlaneBattle.Component.SecondaryWeapon"
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local function go() return { SetActive=function(self,value) self.activeSelf=value end } end
local target = { rt={}, GetLocalPos=function() return 0,100 end }
local function missile()
    return { go=go(), rt={anchoredPosition={x=0,y=100}}, age=.2,vx=0,vy=0,target=target,trail={} }
end
for _,resetInCallback in ipairs({true,false}) do
    local w=setmetatable({missiles={missile(),missile()},free={},level=1,missileTimer=0,
        laserTimer=0,laserRemaining=0,topY=1000,beam={go=go()},origin={go=go()},contact={go=go()},
        _UpdateTrail=function() end},{__index=Weapon})
    local hits=0
    w:Update(.01,1,0,0,{target},function()
        hits=hits+1
        if resetInCallback then w:Reset() end
        -- Deliberately no return: cleanup invalidation must stop safely by itself.
    end)
    check(#w.missiles==0,"all missiles returned to pool")
    check(#w.free==2,"each missile recycled exactly once")
    check(hits==(resetInCallback and 1 or 2),"reset stops old loop; ordinary hits continue")
    check(w.level==(resetInCallback and 0 or 1),"reset level cannot be overwritten")
    check(w.laserRemaining==0,"no laser starts after reset")
end
print("STG secondary reset PASS "..checks)
