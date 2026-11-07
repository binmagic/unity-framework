--- 编队真实战报：英雄输出按来源统计，独立装甲承伤与临时护盾吸收分开显示。
local BattleResultPanel = BaseClass("BattleResultPanel")
local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Button = typeof(CS.UnityEngine.UI.Button)
local TMPText = typeof(CS.TMPro.TextMeshProUGUI)
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color

function BattleResultPanel:__init(parent, requestFont, onBack, onNext)
    self.requestFont,self.onBack,self.onNext=requestFont,onBack,onNext
    self.go,self.rt=self:Node(parent,"FormationResult",0,0,750,1334)
    self.rt.anchorMin,self.rt.anchorMax=Vector2(0,0),Vector2(1,1)
    self.rt.offsetMin,self.rt.offsetMax=Vector2(0,0),Vector2(0,0)
    self:Image(self.go,Color(.025,.07,.15,1),true)
    local heroCard,heroCardRt=self:Node(self.go.transform,"HeroCard",0,-350,680,610,1)
    self:Image(heroCard,Color(.035,.12,.2,.96),false)
    heroCardRt:SetAsFirstSibling()
    local accent,accentRt=self:Node(heroCard.transform,"Accent",0,284,620,4)
    self:Image(accent,Color(.25,.78,1,1),false)
    self.title=self:Text(self.go.transform,"Title","胜 利",0,-80,600,75,50,1)
    self.title.color=Color(1,.84,.35,1)
    self.subtitle=self:Text(self.go.transform,"Subtitle","",0,-144,680,40,22,1)
    self.summary=self:Text(self.go.transform,"Summary","",0,-214,700,56,17,1)
    self.summary.color=Color(.55,.88,1,1)
    -- 评级独占姓名下方一行，与立绘区域（顶部 -245）完全分离。
    local ratingCard=self:Node(self.go.transform,"RatingCard",0,-620,300,44,1)
    self:Image(ratingCard,Color(.07,.24,.32,1),false)
    self.rating=self:Text(ratingCard.transform,"Rating","",0,0,284,40,22)
    self.rating.color=Color(1,.82,.35,1)
    local portrait,pr=self:Node(self.go.transform,"Portrait",0,-394,360,288,1)
    self.portrait=self:Image(portrait,Color(1,1,1,1));self.portrait.preserveAspect=true
    self.mvp=self:Text(self.go.transform,"MVP","",0,-565,680,45,27,1)
    -- 汇总信息单独盖板，保证角色立绘和统计文字不会互相遮挡。
    local summaryBg,summaryBgRt=self:Node(self.go.transform,"SummaryCard",0,-214,700,58,1)
    local summaryBgImg=self:Image(summaryBg,Color(.025,.09,.16,.96),false)
    summaryBgRt:SetAsLastSibling()
    self.summary.transform:SetAsLastSibling()
    self.rating.transform:SetAsLastSibling()
    local body,br=self:Node(self.go.transform,"Report",0,0,700,550)
    br.anchorMin,br.anchorMax=Vector2(.5,.42),Vector2(.5,.42)
    br.anchoredPosition=Vector2(0,0)
    local _,outbg=self:Action(body.transform,"Output","输 出",-170,230,330,60,function() self:SetMode("output") end)
    local _,inbg=self:Action(body.transform,"Taken","承 伤",170,230,330,60,function() self:SetMode("taken") end)
    self.outbg,self.inbg=outbg,inbg
    self.rows={}
    for i=1,6 do
        local row=self:Node(body.transform,"Row_"..i,0,160-(i-1)*67,680,59)
        self:Image(row,Color(.055,.14,.24,1))
        local avatar=self:Node(row.transform,"Avatar",-300,0,46,46)
        local ai=self:Image(avatar,Color(1,1,1,1))
        local name=self:Text(row.transform,"Name","",-68,12,410,26,20)
        name.alignment=CS.TMPro.TextAlignmentOptions.Left
        local value=self:Text(row.transform,"Value","",265,12,120,26,21)
        local track=self:Node(row.transform,"Track",23,-15,570,10)
        self:Image(track,Color(.025,.06,.11,1))
        local fill,fr=self:Node(track.transform,"Fill",0,0,0,10)
        fr.anchorMin,fr.anchorMax,fr.pivot=Vector2(0,.5),Vector2(0,.5),Vector2(0,.5)
        fr.anchoredPosition=Vector2(0,0)
        self:Image(fill,Color(1,.75,.15,1))
        self.rows[i]={go=row,avatar=avatar,img=ai,name=name,value=value,fill=fr}
    end
    self.note=self:Text(body.transform,"Note","",0,-260,680,60,17)
    self.note.enableWordWrapping=true
    self:Action(self.go.transform,"Back","返回编队",-170,90,300,76,function() self.onBack() end,0)
    self.next=self:Action(self.go.transform,"Next","下一关",170,90,300,76,function() self.onNext() end,0)
    self.go:SetActive(false)
end

function BattleResultPanel:Node(parent,name,x,y,w,h,anchor)
    local go=GameObject(name,RectTransform);go.transform:SetParent(parent,false)
    local rt=go:GetComponent(RectTransform)
    if anchor~=nil then rt.anchorMin,rt.anchorMax=Vector2(.5,anchor),Vector2(.5,anchor) end
    rt.anchoredPosition,rt.sizeDelta=Vector2(x,y),Vector2(w,h)
    return go,rt
end

function BattleResultPanel:Image(go,color,raycast)
    local img=go:AddComponent(Image);img.color,img.raycastTarget=color,raycast==true
    return img
end

function BattleResultPanel:Text(parent,name,value,x,y,w,h,size,anchor)
    local go=self:Node(parent,name,x,y,w,h,anchor)
    local text=go:AddComponent(TMPText)
    text.text,text.fontSize,text.alignment=value,size,CS.TMPro.TextAlignmentOptions.Center
    text.color,text.raycastTarget=Color(.9,.95,1,1),false
    text.fontStyle=CS.TMPro.FontStyles.Normal
    self.requestFont(text)
    return text
end

function BattleResultPanel:Action(parent,name,value,x,y,w,h,callback,anchor)
    local go=self:Node(parent,name,x,y,w,h,anchor)
    local bg=self:Image(go,Color(.09,.3,.48,1),true)
    self:Text(go.transform,"Text",value,0,0,w-8,h-4,25)
    go:AddComponent(Button).onClick:AddListener(callback)
    return go,bg
end

function BattleResultPanel:Show(isWin,team,stats,time,levelName,hasNext)
    self.team,self.stats=team,stats
    self.title.text=isWin and "胜 利" or "挑战结束"
    self.title.color=isWin and Color(1,.84,.35,1) or Color(1,.5,.4,1)
    self.subtitle.text=string.format("%s    %02d:%02d",levelName or "探险",math.floor(time/60),math.floor(time%60))
    self.next:SetActive(isWin and hasNext)
    local best=team.leader
    for _,hero in ipairs(team.members) do
        if (stats.damage[hero.id] or 0)>(stats.damage[best.id] or 0) then best=hero end
    end
    local cfg=best.id and DataCenter.HeroDataManager:GetHeroConfig(best.id)
    local path=cfg and (cfg.portrait~="" and cfg.portrait or cfg.avatar)
    self.portrait.gameObject:SetActive(path~=nil)
    if path then self.portrait:LoadSprite(path) end
    self.mvp.text=(isWin and "表现最佳 · " or "编队驾驶员 · ")..best.name
    local totalDamage,totalTaken,totalAbsorbed=0,0,0
    for _,hero in ipairs(team.members) do
        totalDamage=totalDamage+(stats.damage[hero.id] or 0)
        totalTaken=totalTaken+((stats.taken or {})[hero.id] or 0)
        totalAbsorbed=totalAbsorbed+((stats.absorbed or {})[hero.id] or 0)
    end
    totalDamage=totalDamage+(stats.damage.reinforcement or 0)
    local reward=isWin and 50 or 0
    self.summary.text=string.format("总输出 %d    总承伤 %d\n护盾吸收 %d    %s",
        math.floor(totalDamage),math.floor(totalTaken),math.floor(totalAbsorbed),
        isWin and "通关奖励 +"..reward.." 金币" or "未获得通关奖励")
    self.summary.color=isWin and Color(.55,.95,1,1) or Color(1,.62,.48,1)
    local rating="B"
    if isWin then
        rating=(totalTaken<=3 and time<=100 and "S") or (totalTaken<=8 and "A") or "B"
    end
    self.rating.text="战斗评级  "..rating
    self.rating.color=rating=="S" and Color(1,.86,.3,1) or (rating=="A" and Color(.5,1,.72,1) or Color(.65,.8,.9,1))
    self.go:SetActive(true)
    self:SetMode("output")
end

function BattleResultPanel:SetMode(mode)
    self.mode=mode
    self.outbg.color=mode=="output" and Color(.15,.46,.65,1) or Color(.045,.12,.22,1)
    self.inbg.color=mode=="taken" and Color(.15,.46,.65,1) or Color(.045,.12,.22,1)
    local entries={}
    if mode=="output" then
        for _,hero in ipairs(self.team.members) do
            table.insert(entries,{name=hero.name,avatar=hero.avatar,value=self.stats.damage[hero.id] or 0})
        end
        table.insert(entries,{name="普通僚机",value=self.stats.damage.reinforcement or 0})
        table.sort(entries,function(a,b) return a.value>b.value end)
        self.note.text="统计敌机与首领实际扣血；主机副武器计入主机驾驶员，普通僚机单独统计。"
    else
        for _,hero in ipairs(self.team.members) do
            local absorbed=(self.stats.absorbed or {})[hero.id] or 0
            table.insert(entries,{name=hero.name..(absorbed>0 and (" · 护盾吸收 "..absorbed) or ""),
                avatar=hero.avatar,value=(self.stats.taken or {})[hero.id] or 0})
        end
        table.sort(entries,function(a,b) return a.value>b.value end)
        self.note.text="按各英雄实际装甲损失统计，临时护盾吸收单列；无敌期间不重复计入。"
    end
    local maximum=1
    for _,e in ipairs(entries) do maximum=math.max(maximum,e.value) end
    for i,row in ipairs(self.rows) do
        local e=entries[i]
        row.go:SetActive(e~=nil)
        if e then
            row.name.text=tostring(i).."  "..e.name
            row.value.text=math.abs(e.value-math.floor(e.value))<.01 and tostring(math.floor(e.value)) or string.format("%.1f",e.value)
            row.fill.sizeDelta=Vector2(570*e.value/maximum,10)
            row.avatar:SetActive(e.avatar~=nil and e.avatar~="")
            if e.avatar and e.avatar~="" then row.img:LoadSprite(e.avatar) end
        end
    end
    local noteRt=self.note:GetComponent(RectTransform)
    noteRt.anchoredPosition=Vector2(0,112-#entries*67)
end

function BattleResultPanel:__delete()
    if self.go~=nil and not IsNull(self.go) then self.go:Destroy() end
    self.go,self.rt,self.requestFont,self.onBack,self.onNext=nil,nil,nil,nil,nil
    self.title,self.subtitle,self.summary,self.rating,self.portrait,self.mvp,self.outbg,self.inbg=nil,nil,nil,nil,nil,nil,nil,nil
    self.rows,self.note,self.next,self.team,self.stats,self.mode=nil,nil,nil,nil,nil,nil
end

return BattleResultPanel
