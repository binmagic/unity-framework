-- Reusable child geometry; animation never changes the aircraft's hitbox or movement root.
local Visual = {}
Visual.__index = Visual
local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Vector2,Color = CS.UnityEngine.Vector2,CS.UnityEngine.Color
local Quaternion = CS.UnityEngine.Quaternion
local FX="Assets/Main/Sprites/STG/CombatFx/"
local function node(parent,name,x,y,w,h,color,sprite,angle)
    local go=GameObject(name,RectTransform);go.transform:SetParent(parent,false)
    local rt=go:GetComponent(RectTransform)
    rt.anchoredPosition,rt.sizeDelta=Vector2(x,y),Vector2(w,h)
    if angle then rt.localRotation=Quaternion.Euler(0,0,angle) end
    local img=go:AddComponent(Image);img.raycastTarget=false;img.color=color
    if sprite then img:LoadSprite(sprite) end
    return {go=go,rt=rt,img=img}
end
function Visual.New(parent,role,profile)
    local self=setmetatable({role=role,profile=profile,age=0,fireAge=1},Visual)
    local c=profile.color
    self.tint=Color(c[1],c[2],c[3],1)
    self.engines={}
    for i=1,profile.engines do
        local x=profile.engines==1 and 0 or (i==1 and -1 or 1)*profile.width*.2
        local tail=node(parent,"EnemyEngine"..i,x,profile.height*.38,10,profile.trail,
            Color(c[1],c[2],c[3],.8),FX.."energy_bolt.png")
        tail.rt.pivot=Vector2(.5,0)
        self.engines[i]=tail
    end
    -- A small silhouette badge, readable without Chinese text above every aircraft.
    self.badge=node(parent,"RoleBadge",0,profile.height*.5+18,24,20,Color(.035,.07,.12,.95))
    local bp=self.badge.go.transform
    if role=="armored" then
        node(bp,"ShieldLeft",-6,1,3,13,self.tint,nil,0)
        node(bp,"ShieldRight",6,1,3,13,self.tint,nil,0)
        node(bp,"ShieldTop",0,7,14,3,self.tint)
        node(bp,"ShieldBaseLeft",-3,-6,3,9,self.tint,nil,45)
        node(bp,"ShieldBaseRight",3,-6,3,9,self.tint,nil,-45)
    elseif role=="charger" then
        for y=-3,4,7 do
            node(bp,"ArrowLeft"..y,-3,y,3,10,self.tint,nil,40)
            node(bp,"ArrowRight"..y,3,y,3,10,self.tint,nil,-40)
        end
    else
        for i=-1,1 do node(bp,"SwarmDot"..i,i*6,0,3,7,self.tint) end
    end
    self.charge=node(parent,"WeaponCharge",0,-profile.height*.34,28,28,Color(1,.7,.2,0),FX.."impact.png")
    self.muzzle=node(parent,"EnemyMuzzle",0,-profile.height*.38,38,38,Color(1,.78,.35,0),FX.."impact.png")
    self.charge.go:SetActive(false);self.muzzle.go:SetActive(false)
    return self
end
function Visual:Update(dt,phase,warningProgress)
    self.age=self.age+math.max(0,dt)
    self.fireAge=math.min(1,self.fireAge+math.max(0,dt))
    local boost=phase=="charge" and 2.4 or (phase=="warning" and .6 or 1)
    for i,tail in ipairs(self.engines) do
        local pulse=1+.12*math.sin(self.age*22+i)
        tail.rt.sizeDelta=Vector2(phase=="charge" and 15 or 10,self.profile.trail*pulse*boost)
    end
    local charged=warningProgress~=nil
    self.charge.go:SetActive(charged)
    if charged then
        local pulse=.75+.25*math.sin(self.age*24)
        self.charge.rt.sizeDelta=Vector2(24+warningProgress*24,24+warningProgress*24)
        self.charge.img.color=Color(1,.65,.18,(.35+.55*warningProgress)*pulse)
    end
    local remaining=math.max(0,1-self.fireAge/.15)
    self.muzzle.go:SetActive(remaining>0)
    if remaining>0 then self.muzzle.img.color=Color(1,.8,.4,remaining) end
end
function Visual:PlayFire() self.fireAge=0 end
return Visual
