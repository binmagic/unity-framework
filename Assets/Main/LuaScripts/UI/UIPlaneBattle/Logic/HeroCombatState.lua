--- 局内独立装甲、无敌、护盾与技能计时；不写养成存档。
local HeroCombatState = BaseClass("HeroCombatState")

function HeroCombatState:__init(team)
    self.members,self.byId={},{}
    self.hasteRemaining=0
    for _,hero in ipairs(team.members) do
        local state={hero=hero,hp=hero.hullMax,maxHp=hero.hullMax,dead=false,
            invincible=0,shield=0,shieldRemaining=0,cooldown=math.min(3,hero.activeCooldown),casts=0}
        table.insert(self.members,state)
        self.byId[hero.id]=state
    end
end

function HeroCombatState:Tick(dt)
    if dt<=0 then return end
    self.hasteRemaining=math.max(0,self.hasteRemaining-dt)
    for _,s in ipairs(self.members) do
        if not s.dead then
            s.invincible=math.max(0,s.invincible-dt)
            s.cooldown=math.max(0,s.cooldown-dt)
            s.shieldRemaining=math.max(0,s.shieldRemaining-dt)
            if s.shieldRemaining==0 then s.shield=0 end
        end
    end
end

function HeroCombatState:Damage(heroId,amount)
    local s=self.byId[heroId]
    if s==nil or s.dead or s.invincible>0 then return 0,0,false end
    amount=math.max(0,amount or 0)
    if amount==0 then return 0,0,false end
    local absorbed=math.min(s.shield,amount)
    s.shield=s.shield-absorbed
    local lost=math.min(s.hp,amount-absorbed)
    s.hp=s.hp-lost
    s.invincible=.7
    s.dead=s.hp<=0
    return lost,absorbed,s.dead
end

function HeroCombatState:Repair(heroId,amount)
    local s=self.byId[heroId]
    if s==nil or s.dead then return 0 end
    local restored=math.min(s.maxHp-s.hp,math.max(0,amount or 0))
    s.hp=s.hp+restored
    return restored
end

function HeroCombatState:CanCast(heroId)
    local s=self.byId[heroId]
    return s~=nil and not s.dead and s.cooldown<=0
end

function HeroCombatState:CommitCast(heroId)
    if not self:CanCast(heroId) then return false end
    local s=self.byId[heroId]
    s.cooldown,s.casts=s.hero.activeCooldown,s.casts+1
    return true
end

function HeroCombatState:GrantShield(amount,duration)
    for _,s in ipairs(self.members) do
        if not s.dead then
            s.shield=math.max(s.shield,amount)
            s.shieldRemaining=math.max(s.shieldRemaining,duration)
        end
    end
end

function HeroCombatState:GetFireRate()
    return self.hasteRemaining>0 and 1.6 or 1
end

function HeroCombatState:__delete()
    self.members,self.byId,self.hasteRemaining=nil,nil,nil
end

return HeroCombatState
