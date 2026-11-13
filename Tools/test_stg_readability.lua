-- Standalone: formation geometry. Unity Lua VM: also run real View firing methods with isolated units.
package.path = "Assets/Main/LuaScripts/?.lua;" .. package.path
local Layout = require "UI.UIPlaneBattle.Logic.FormationLayout"
local checks = 0
local function check(value, message) assert(value, message); checks = checks + 1 end
for count = 0, 12 do
    local offsets = Layout.GetOffsets(count)
    check(#offsets == count, "formation preserves visible count")
    for i, a in ipairs(offsets) do
        check(a.y >= 100, "formation remains ahead of main aircraft")
        for j = i+1, #offsets do
            local b = offsets[j]
            check((a.x-b.x)^2+(a.y-b.y)^2 >= 60^2, "aircraft silhouettes stay separated")
        end
    end
    for _, x in ipairs({-300, 0, 300}) do
        local shift = Layout.GetHorizontalShift(offsets,x,347)
        for _, a in ipairs(offsets) do
            check(math.abs(x+a.x+shift) <= 347.001, "edge drag keeps formation inside screen")
        end
    end
end
if CS ~= nil then
    local View = require "UI.UIPlaneBattle.View.UIPlaneBattleView"
    for _, dt in ipairs({.01,.02,.05,.1}) do
        local counts, damage, peak, frameShots = {}, 0, 0, 0
        local v = setmetatable({ primaryFireTimer=0, wingmen={}, heroEscorts={}, battleHero={id=1002},
            logic={GetFireRateMultiplier=function() return 1 end, GetWingmanCount=function() return 22 end},
            _GetBattleWeaponLevel=function() return 2 end, GetPlayerPlanePos=function() return 0,200 end,
            bulletPool={Fire=function(_,x,y,dir,amount,faction,vx,level,primary)
                if not primary then
                    local index = math.floor(x/100+.5)
                    counts[index]=(counts[index] or 0)+1
                    damage=damage+amount
                    frameShots=frameShots+1
                end
                return true
            end}}, {__index=View})
        for i=1,12 do
            local index=i
            v.wingmen[i]={fireCd=((i-1)%3)*.5/3,GetLocalPos=function() return index*100,200 end}
        end
        for _=1,math.floor(10/dt+.5) do
            frameShots=0
            v:_UpdateWingmanFire(dt)
            peak=math.max(peak,frameShots)
        end
        for i=1,12 do check(math.abs((counts[i] or 0)-60)<=3, "each support aircraft retains two triple volleys/second") end
        check(math.abs(damage-6600)<331, "logical 22-aircraft total damage retained within one volley")
        check(peak<=12, "support fire distributed across three batches")
    end
end
return "PASS: " .. checks .. " formation / staggered-fire checks"
