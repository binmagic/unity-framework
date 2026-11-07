--- 战机英雄独立受击、装甲条与手动技能表现；全部伤害继续通过 View 的命中/死亡路径。
local HeroCombatController = BaseClass("HeroCombatController")
local HeroCombatState = require "UI.UIPlaneBattle.Logic.HeroCombatState"
local GameObject=CS.UnityEngine.GameObject
local RectTransform=typeof(CS.UnityEngine.RectTransform)
local Image=typeof(CS.UnityEngine.UI.Image)
local Button=typeof(CS.UnityEngine.UI.Button)
local TMPText=typeof(CS.TMPro.TextMeshProUGUI)
local Vector2=CS.UnityEngine.Vector2
local Color=CS.UnityEngine.Color

function HeroCombatController:__init(view,requestFont)
    self.view,self.requestFont=view,requestFont
    self.state=HeroCombatState.New(view.battleTeam)
    self.pending,self.cards,self.badges={},{},{}
    self.lastRefresh=0
    self.go,self.rt=self:Node(view.hudContentTf,"HeroSkills",0,0,750,0)
    self.rt.anchorMin,self.rt.anchorMax=Vector2(0,0),Vector2(1,0)
    self.rt.sizeDelta=Vector2(0,0)
    local plate,plateRt=self:Node(self.go.transform,"SkillPlate",0,95,0,190)
    plateRt.anchorMin,plateRt.anchorMax=Vector2(0,0),Vector2(1,0)
    self:Image(plate,Color(.06,.14,.24,.96))
    local statusGo,statusRt=self:Node(view.hudContentTf,"HeroSkillNotice",0,-315,660,96)
    statusRt.anchorMin,statusRt.anchorMax=Vector2(.5,1),Vector2(.5,1)
    self.statusGo=statusGo
    self:Image(statusGo,Color(.06,.17,.27,.94))
    self.status=self:Text(statusGo.transform,"Status","",0,0,636,88,26)
    self.status.enableWordWrapping=true
    statusGo:SetActive(false)
    local count=#self.state.members
    local width=math.min(260,708/math.max(1,count)-8)
    for i,s in ipairs(self.state.members) do
        local id=s.hero.id
        if s.hero.slot==1 then
            s.rt,s.body,s.parent=view.playerPlaneRt,view.playerPlaneImg,view.playerPlaneGo
        else
            for _,unit in ipairs(view.heroEscorts) do
                if unit.hero.id==id then
                    s.unit,s.rt,s.body,s.parent=unit,unit.rt,unit.img,unit.go
                    unit.combatState=s
                end
            end
        end
        s.radius=s.hero.slot==1 and 33 or 24
        local bubble=self:Node(s.parent.transform,"TemporaryShield",0,0,125,125)
        self:Image(bubble,Color(.3,.75,1,.5)):LoadSprite("Assets/Main/Sprites/STG/CombatFx/shield_hit.png")
        bubble.transform:SetAsFirstSibling()
        bubble:SetActive(false)
        s.bubble=bubble
        local card=self:Node(self.go.transform,"Skill_"..id,(i-(count+1)/2)*(width+8),73,width,126)
        local bg=self:Image(card,Color(.12,.33,.49,1),true)
        local avatar=self:Node(card.transform,"Avatar",-width/2+33,32,50,50)
        avatar:AddComponent(typeof(CS.UnityEngine.UI.RectMask2D))
        local art=self:Node(avatar.transform,"Art",0,-6.25,50,62.5)
        local cfg=DataCenter.HeroDataManager:GetHeroConfig(id)
        local portrait=tonumber(id)==1002 and "Assets/Main/Sprites/HeroUI/HeroUI_formation_nurse.png"
            or (cfg and cfg.card or s.hero.avatar)
        self:Image(art,Color(1,1,1,1)):LoadSprite(portrait)
        self:Text(card.transform,"Name",s.hero.name,0,-7,width-12,34,22)
        local hp=self:Text(card.transform,"HP","",27,32,width-66,60,20)
        local cd=self:Text(card.transform,"Cooldown","",0,-42,width-8,34,22)
        local hpTrack=self:Node(card.transform,"ArmorTrack",0,-25,width-14,5)
        self:Image(hpTrack,Color(.03,.09,.15,1))
        local hpGo,hpRt=self:Node(hpTrack.transform,"Fill",0,0,width-14,5)
        hpRt.anchorMin,hpRt.anchorMax,hpRt.pivot=Vector2(0,.5),Vector2(0,.5),Vector2(0,.5)
        hpRt.anchoredPosition=Vector2(0,0)
        self:Image(hpGo,Color(.35,1,.65,1))
        local track=self:Node(card.transform,"Track",0,-60,width-8,3)
        self:Image(track,Color(.03,.09,.15,1))
        local fill,fr=self:Node(track.transform,"Fill",0,0,width-8,3)
        fr.anchorMin,fr.anchorMax,fr.pivot=Vector2(0,.5),Vector2(0,.5),Vector2(0,.5)
        fr.anchoredPosition=Vector2(0,0)
        self:Image(fill,Color(.35,.9,1,1))
        local btn=card:AddComponent(Button);btn.onClick:AddListener(function() self:Cast(id) end)
        self.cards[id]={go=card,bg=bg,hp=hp,cd=cd,fill=fr,width=width-8,btn=btn,hpFill=hpRt}

        -- 飞机旁只保留血条；人物和数值统一在底部技能卡查看。
        local badge=self:Node(s.parent.transform,"HeroStatus",0,-48,76,7)
        local bar=self:Node(badge.transform,"ArmorTrack",0,0,76,7)
        self:Image(bar,Color(.1,.14,.18,1))
        local barFill,barRt=self:Node(bar.transform,"Fill",0,0,76,7)
        barRt.anchorMin,barRt.anchorMax,barRt.pivot=Vector2(0,.5),Vector2(0,.5),Vector2(0,.5)
        barRt.anchoredPosition=Vector2(0,0)
        local barImg=self:Image(barFill,Color(.3,1,.55,1))
        self.badges[id]={go=badge,fill=barRt,img=barImg}
    end
    self:Refresh()
end

function HeroCombatController:Node(parent,name,x,y,w,h)
    local go=GameObject(name,RectTransform);go.transform:SetParent(parent,false)
    local rt=go:GetComponent(RectTransform);rt.anchoredPosition,rt.sizeDelta=Vector2(x,y),Vector2(w,h)
    return go,rt
end

function HeroCombatController:Image(go,color,raycast)
    local img=go:AddComponent(Image);img.color,img.raycastTarget=color,raycast==true
    return img
end

function HeroCombatController:Text(parent,name,value,x,y,w,h,size)
    local go=self:Node(parent,name,x,y,w,h)
    local text=go:AddComponent(TMPText)
    text.text,text.fontSize,text.alignment=value,size,CS.TMPro.TextAlignmentOptions.Center
    text.color,text.raycastTarget=Color(.88,.95,1,1),false;self.requestFont(text)
    text.fontStyle=CS.TMPro.FontStyles.Normal
    text.enableWordWrapping=false
    return text
end

function HeroCombatController:Refresh()
    for _,s in ipairs(self.state.members) do
        local card,badge=self.cards[s.hero.id],self.badges[s.hero.id]
        card.hp.text=string.format("%s\n%d/%d",s.shield>0 and ("盾 "..s.shield) or "装甲",s.hp,s.maxHp)
        card.cd.text=s.dead and "已阵亡" or (s.cooldown>0 and string.format("%d秒",math.ceil(s.cooldown)) or "释放技能")
        card.cd.color=s.dead and Color(.65,.69,.75,1) or (s.cooldown>0 and Color(.8,.88,.96,1) or Color(.6,1,.8,1))
        card.bg.color=s.dead and Color(.12,.15,.2,1) or (s.cooldown>0 and Color(.1,.22,.35,1) or Color(.12,.36,.49,1))
        card.hpFill.sizeDelta=Vector2((card.width-6)*s.hp/s.maxHp,5)
        card.fill.sizeDelta=Vector2(card.width*(1-s.cooldown/s.hero.activeCooldown),3)
        -- 冷却时仍接收点击，可展示技能说明；阵亡状态禁用。
        card.btn.interactable=not s.dead
        badge.fill.sizeDelta=Vector2(76*s.hp/s.maxHp,7)
        badge.img.color=s.hp==1 and Color(1,.35,.22,1) or Color(.3,1,.55,1)
        s.bubble:SetActive(not s.dead and s.shield>0)
        if not s.dead then
            s.body.color=s.invincible>0 and Color(1,.4,.35,1) or Color(1,1,1,1)
        end
    end
end

function HeroCombatController:Tick(dt)
    if dt<=0 then return end
    self.state:Tick(dt)
    for i=#self.pending,1,-1 do
        local p=self.pending[i]
        p.remaining=p.remaining-dt
        if p.remaining<=0 then
            table.remove(self.pending,i)
            if p.go then p.go:Destroy() end
            local caster=self.state.byId[p.sourceId]
            if caster and not caster.dead then
                local targets={}
                for _,enemy in ipairs(self.view.enemies) do table.insert(targets,enemy) end
                for _,enemy in ipairs(targets) do
                    if not enemy.isDead then
                        local x,y=enemy:GetLocalPos()
                        if (x-p.x)^2+(y-p.y)^2<=(130+(enemy.collideRadius or 0))^2 then
                            self.view:_DamageFromHeroSkill(enemy,65,p.sourceId,x,y)
                            if self.view.bossDefeat~=nil or self.view.isBattleOver then self:CancelPending();return end
                        end
                    end
                end
                self.view:_SpawnCombatFx("explosion.png",p.x,p.y,260,Color(.6,.8,1,1),.45)
            end
        end
    end
    if self.state.hasteRemaining>0 then
        self.status.text=string.format("战术指挥 · 射速 +60%%  %d秒",math.ceil(self.state.hasteRemaining))
        self.statusGo:SetActive(true)
    elseif self.noticeRemaining and self.noticeRemaining>0 then
        self.noticeRemaining=math.max(0,self.noticeRemaining-dt)
    else
        self.status.text=""
        self.statusGo:SetActive(false)
    end
    self.lastRefresh=self.lastRefresh+dt
    if self.lastRefresh>=.1 then self.lastRefresh=0;self:Refresh() end
end

function HeroCombatController:FindTarget(s)
    local px,py=s.rt.anchoredPosition.x,s.rt.anchoredPosition.y
    local best,distance=nil,math.huge
    local top=self.view.battleContentTf.rect.height-240
    for _,enemy in ipairs(self.view.enemies) do
        local x,y=enemy:GetLocalPos()
        if not enemy.isDead and y>py+35 and y<top then
            local d=(x-px)^2+(y-py)^2
            if d<distance then best,distance=enemy,d end
        end
    end
    return best
end

function HeroCombatController:Notice(text)
    self.status.text=text;self.noticeRemaining=3
    self.statusGo:SetActive(true)
end

function HeroCombatController:Cast(heroId)
    local v=self.view
    if v.isBattleOver or v.isInLevelSelect or v.bossDefeat~=nil or CS.UnityEngine.Time.timeScale<=0 then return false end
    local s=self.state.byId[heroId]
    if s==nil or s.dead then return false end
    self:Notice(s.hero.activeDescription.." · 冷却"..s.hero.activeCooldown.."秒")
    if not self.state:CanCast(heroId) then return false end
    local kind=s.hero.activeKind
    local target=(kind=="double" or kind=="blast") and self:FindTarget(s) or nil
    if (kind=="double" or kind=="blast") and target==nil then self:Notice("前方没有目标，保留技能");return false end
    if kind=="double" and #v.bulletPool:GetActiveList()>190 then
        self:Notice("弹幕密集，稍后释放拦截技能");return false
    end
    if not self.state:CommitCast(heroId) then return false end
    local px,py=s.rt.anchoredPosition.x,s.rt.anchoredPosition.y
    if kind=="haste" then
        self.state.hasteRemaining=5
        for _,member in ipairs(self.state.members) do
            if not member.dead then
                local p=member.rt.anchoredPosition
                v:_SpawnCombatFx("shield_hit.png",p.x,p.y,110,Color(.3,1,.7,.85),.6)
            end
        end
    elseif kind=="shield" then
        self.state:GrantShield(2,4)
        for _,member in ipairs(self.state.members) do
            if not member.dead then
                local p=member.rt.anchoredPosition
                v:_SpawnCombatFx("shield_hit.png",p.x,p.y,145,Color(.3,.8,1,.9),.7)
            end
        end
    elseif kind=="blast" then
        local x,y=target:GetLocalPos()
        local go,rt=self:Node(v.battleContentTf,"HeroStrikeWarning",x,y,260,260)
        rt.anchorMin,rt.anchorMax=Vector2(.5,0),Vector2(.5,0);rt.anchoredPosition=Vector2(x,y)
        self:Image(go,Color(.35,.65,1,.45)):LoadSprite("Assets/Main/Sprites/STG/CombatFx/shield_hit.png")
        table.insert(self.pending,{remaining=.55,sourceId=heroId,x=x,y=y,go=go})
    else
        local x,y=target:GetLocalPos()
        for _,offset in ipairs({-10,10}) do
            local vx=math.max(-650,math.min(650,(x-px-offset)/math.max(40,y-py-40)*900))
            v.bulletPool:Fire(px+offset,py+40,1,30,"player",vx,2,true,heroId,true)
        end
        v:_SpawnCombatFx("impact.png",px,py+40,100,Color(1,.8,.3,1),.3)
    end
    self:Refresh()
    return true
end

--- 敌弹使用线段扫掠检测，避免低帧率越过小体积英雄机。每颗弹只选最先命中的英雄。
function HeroCombatController:CheckEnemyBullets()
    local bullets=self.view.bulletPool:GetActiveList()
    local i=1
    while i<=#bullets do
        local b=bullets[i]
        local hit,first=nil,math.huge
        if b.faction=="enemy" then
            local p=b.rt.anchoredPosition
            local ax,ay=b.previousX or p.x,b.previousY or p.y
            local dx,dy=p.x-ax,p.y-ay
            local len=dx*dx+dy*dy
            for _,s in ipairs(self.state.members) do
                if not s.dead then
                    local h=s.rt.anchoredPosition
                    local t=math.max(0,math.min(1,((h.x-ax)*dx+(h.y-ay)*dy)/math.max(.001,len)))
                    if (ax+t*dx-h.x)^2+(ay+t*dy-h.y)^2<=(s.radius+5)^2 and t<first then hit,first=s,t end
                end
            end
        end
        if hit then
            self.view.bulletPool:Remove(b)
            self:Damage(hit.hero.id,1)
            if self.view.isBattleOver then return end
        else i=i+1 end
    end
end

function HeroCombatController:Damage(heroId,amount)
    if self.view.isBattleOver or self.view.isInLevelSelect then return 0 end
    local lost,absorbed,dead=self.state:Damage(heroId,amount)
    if lost+absorbed==0 then return 0 end
    local s=self.state.byId[heroId]
    local v=self.view
    v.battleStats.taken[heroId]=(v.battleStats.taken[heroId] or 0)+lost
    v.battleStats.absorbed[heroId]=(v.battleStats.absorbed[heroId] or 0)+absorbed
    local p=s.rt.anchoredPosition
    v:_SpawnCombatFx(dead and "explosion.png" or "shield_hit.png",p.x,p.y,dead and 150 or 110,
        dead and Color(1,.65,.3,1) or Color(.45,.8,1,1),.4)
    if s.hero.slot==1 then v.playerHull=s.hp;v:_RefreshHudHull() end
    if dead then
        s.parent:SetActive(false)
        if s.unit then s.unit.isDead=true end
        for i=#self.pending,1,-1 do
            if self.pending[i].sourceId==heroId then
                if self.pending[i].go then self.pending[i].go:Destroy() end
                table.remove(self.pending,i)
            end
        end
        self:Notice(s.hero.name.."战机被击毁")
        self.view:_RefreshBattleHeroHud()
        if s.hero.slot==1 then
            if v.logic then v.logic:Lose() else v:_OnBattleLose() end
        end
    end
    self:Refresh()
    return lost
end

function HeroCombatController:Repair(amount)
    for _,s in ipairs(self.state.members) do self.state:Repair(s.hero.id,amount) end
    self.view.playerHull=self.state.byId[self.view.battleHero.id].hp
    self.view:_RefreshHudHull();self:Refresh()
end

function HeroCombatController:CancelPending()
    for _,p in ipairs(self.pending) do if p.go then p.go:Destroy() end end
    self.pending={}
end

function HeroCombatController:__delete()
    self:CancelPending()
    for _,badge in pairs(self.badges) do if not IsNull(badge.go) then badge.go:Destroy() end end
    for _,s in ipairs(self.state.members) do if not IsNull(s.bubble) then s.bubble:Destroy() end end
    if self.go and not IsNull(self.go) then self.go:SetActive(false);self.go:Destroy() end
    if self.statusGo and not IsNull(self.statusGo) then self.statusGo:Destroy() end
    self.statusGo=nil
    self.state:Delete()
    self.go,self.rt,self.view,self.requestFont,self.state=nil,nil,nil,nil,nil
    self.pending,self.cards,self.badges,self.status,self.noticeRemaining,self.lastRefresh=nil,nil,nil,nil,nil,nil
end

return HeroCombatController
