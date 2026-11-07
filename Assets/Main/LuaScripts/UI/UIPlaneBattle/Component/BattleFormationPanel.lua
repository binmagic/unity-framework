--- 探险战前编队：五槽、职业筛选、已拥有英雄、关卡切换。
local BattleFormationPanel = BaseClass("BattleFormationPanel")
local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Button = typeof(CS.UnityEngine.UI.Button)
local TMPText = typeof(CS.TMPro.TextMeshProUGUI)
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color
local Profile = require "UI.UIPlaneBattle.Logic.BattleHeroProfile"
local HeroAircraftCatalog = require "DataCenter.Hero.HeroAircraftCatalog"
local ROLE_NAMES = { Output = "突击", Defense = "护航", Support = "指挥" }
local ROLES = { false, "Output", "Defense", "Support" }
local SLOT_POS = { {0,-100}, {-125,105}, {125,105}, {-235,-100}, {235,-100} }
local ART = "Assets/Main/Sprites/HeroUI/"

function BattleFormationPanel:__init(parent, requestFont, ctrl, onStart, onClose)
    self.requestFont, self.ctrl, self.onStart, self.onClose = requestFont, ctrl, onStart, onClose
    self.selectedSlot, self.filter, self.levelIndex = 1, 1, 1
    self.slots, self.filterButtons, self.cards = {}, {}, {}
    self.go, self.rt = self:Node(parent, "BattleFormation", 0, 0, 750, 1334)
    self.rt.anchorMin, self.rt.anchorMax = Vector2(0,0), Vector2(1,1)
    self.rt.offsetMin, self.rt.offsetMax = Vector2(0,0), Vector2(0,0)
    self:Background(self.go, Color(.08,.22,.36,1), true)
    local nebula, nr = self:Node(self.go.transform, "Nebula", 0, 0, 750, 1334)
    nr.anchorMin, nr.anchorMax = Vector2(0,0), Vector2(1,1)
    nr.offsetMin, nr.offsetMax = Vector2(0,0), Vector2(0,0)
    -- 战前使用独立提亮版，避免改变战斗中太空背景的明暗层级。
    local ni = self:Background(nebula, Color(1,1,1,1))
    ni:LoadSprite(ART.."HeroUI_formation_space.png")
    local header=self:Node(self.go.transform,"Header",0,-76,750,152,1)
    self:Background(header,Color(.08,.23,.39,.75))
    self:Label(self.go.transform, "Title", "出战编队", 0, -49, 340, 50, 34, 1)
    self.gold = self:Label(self.go.transform, "Gold", "", 270,-49,190,40,24,1)
    self.levelText = self:Label(self.go.transform, "Level", "", 0,-112,490,50,28,1)
    local _,prevBg,prevText=self:Action(self.go.transform,"Previous","‹",-300,-120,64,50,1,function() self:ChangeLevel(-1) end)
    local _,nextBg,nextText=self:Action(self.go.transform,"Next","›",300,-120,64,50,1,function() self:ChangeLevel(1) end)
    prevBg.color,nextBg.color=Color(.36,.59,.82,1),Color(.36,.59,.82,1)
    prevText.fontSize,nextText.fontSize=38,38

    local formation, fr = self:Node(self.go.transform,"Formation",0,0,720,460)
    fr.anchorMin, fr.anchorMax = Vector2(.5,0), Vector2(.5,0)
    fr.anchoredPosition=Vector2(0,700)
    for i = 1, 5 do
        local slot = i
        local pos = SLOT_POS[i]
        local go = self:Node(formation.transform,"Slot_"..i,pos[1],pos[2],174,176)
        local bg = self:Background(go,Color(1,1,1,1),true)
        bg:LoadSprite(ART.."HeroUI_formation_slot.png")
        local caption = self:Label(go.transform,"Caption",i==1 and "主机" or "护航 "..(i-1),0,-99,180,28,22)
        local plane, pr = self:Node(go.transform,"Aircraft",0,3,138,126)
        local pi = self:Background(plane,Color(1,1,1,1))
        pi.preserveAspect=true
        local avatar,ai = self:Portrait(go.transform,"Portrait",-53,86,48)
        local plus = self:Label(go.transform,"Empty","+",0,7,120,100,80)
        local name = self:Label(go.transform,"Hero","",0,-66,174,30,24)
        local level = self:Label(go.transform,"Level","",23,86,106,32,24)
        local btn = go:AddComponent(Button)
        btn.onClick:AddListener(function() self.selectedSlot=slot; self:Refresh() end)
        self.slots[i]={go=go,bg=bg,caption=caption,plane=plane,avatar=avatar,
            planeImg=pi,avatarImg=ai,plus=plus,name=name,level=level}
    end
    self.summary = self:Label(formation.transform,"TeamBonus","",0,-228,710,36,22)
    self.summary.color=Color(.84,.95,1,1)

    local roster, rr = self:Node(self.go.transform,"HeroRoster",0,288,750,312)
    rr.anchorMin, rr.anchorMax = Vector2(.5,0),Vector2(.5,0)
    self:Background(roster,Color(.75,.82,.91,1))
    self.hint = self:Label(roster.transform,"Hint","",-108,132,450,35,24)
    self.hint.color=Color(.13,.27,.43,1)
    local remove,removeBg,removeText,removeButton = self:Action(roster.transform,"Remove","下阵",278,130,148,48,nil,function()
        if DataCenter.PlaneBattleDataManager:SetFormationSlot(self.selectedSlot,0) then self:Refresh() end
    end)
    self.remove=remove
    -- 浅蓝列表上的独立操作需要深色底与白字，避免白底页签样式淹没“下阵”。
    removeBg.color=Color(.68,.17,.06,1)
    removeText.color,removeText.fontSize=Color(1,1,1,1),26
    removeButton.targetGraphic=removeBg
    local shadow=remove:AddComponent(typeof(CS.UnityEngine.UI.Shadow))
    shadow.effectColor,shadow.effectDistance=Color(.12,.2,.3,.3),Vector2(0,-3)
    for i,name in ipairs({"全部","突击","护航","指挥"}) do
        local filter=i
        local _,bg,label=self:Action(roster.transform,"Filter_"..i,name,-261+(i-1)*174,82,166,46,nil,function()
            self.filter=filter; self:Refresh()
        end)
        self.filterButtons[i]={bg=bg,label=label}
    end
    local viewport, vr = self:Node(roster.transform,"Viewport",0,-38,702,192)
    self:Background(viewport,Color(0,0,0,0))
    viewport:AddComponent(typeof(CS.UnityEngine.UI.RectMask2D))
    local content, cr = self:Node(viewport.transform,"Cards",0,0,702,192)
    cr.anchorMin,cr.anchorMax,cr.pivot=Vector2(0,.5),Vector2(0,.5),Vector2(0,.5)
    cr.anchoredPosition=Vector2(0,0)
    self.cardRoot, self.cardRt = content,cr
    local scroll=viewport:AddComponent(typeof(CS.UnityEngine.UI.ScrollRect))
    scroll.viewport,scroll.content,scroll.horizontal,scroll.vertical=vr,cr,true,false
    scroll.movementType=CS.UnityEngine.UI.ScrollRect.MovementType.Clamped
    self.scroll=scroll
    local help=self:Label(roster.transform,"Help","选择位置，再点英雄上阵 · 已上阵英雄可交换",0,-141,710,26,20)
    help.color=Color(.2,.34,.49,1)
    local footer=self:Node(self.go.transform,"Footer",0,66,750,132,0)
    self:Background(footer,Color(.09,.19,.34,1))
    local _,backBg=self:Action(self.go.transform,"Close","",-302,66,92,76,0,function() self.onClose() end)
    backBg.color=Color(1,1,1,1)
    backBg:LoadSprite(ART.."HeroUI_btn_back_src.png")
    self.start,self.startBg,self.startText=self:Action(self.go.transform,"Start","战 斗",0,66,280,90,0,function()
        local lv=self.levels[self.levelIndex]
        local ids=DataCenter.PlaneBattleDataManager:GetFormation()
        if ids[1]==0 then self:Refresh();return end
        if lv and tonumber(lv.id)<=tonumber(self.ctrl:GetCurLevelId()) then self.onStart(tonumber(lv.id)) end
    end)
    self.startBg:LoadSprite(ART.."HeroUI_recruit_button_round.png")
    self.startText.fontSize=34
    -- 编队页包含大量中文。首次加载字体期间保持整页隐藏，字体回调完成后再显示，
    -- 避免 TMP 默认字体把首帧渲染成方块。
    self.fontReady,self.pendingShow=false,false
    self.requestFont(nil,function() self:_OnFontReady() end)
    self.go:SetActive(false)
end

function BattleFormationPanel:_OnFontReady()
    self.fontReady=true
    if self.pendingShow then
        self.pendingShow=false
        self:Show()
    end
end

function BattleFormationPanel:Node(parent,name,x,y,w,h,anchor)
    local go=GameObject(name,RectTransform);go.transform:SetParent(parent,false)
    local rt=go:GetComponent(RectTransform)
    if anchor~=nil then rt.anchorMin,rt.anchorMax=Vector2(.5,anchor),Vector2(.5,anchor) end
    rt.anchoredPosition,rt.sizeDelta=Vector2(x,y),Vector2(w,h)
    return go,rt
end

function BattleFormationPanel:Background(go,color,raycast)
    local img=go:AddComponent(Image);img.color,img.raycastTarget=color,raycast==true
    return img
end

function BattleFormationPanel:Label(parent,name,value,x,y,w,h,size,anchor)
    local go=self:Node(parent,name,x,y,w,h,anchor)
    local text=go:AddComponent(TMPText)
    text.text,text.fontSize,text.alignment=value,size,CS.TMPro.TextAlignmentOptions.Center
    text.color,text.raycastTarget=Color(.9,.95,1,1),false
    text.fontStyle=CS.TMPro.FontStyles.Normal
    text.enableWordWrapping=false
    -- 图集 padding 为 8；额外采样会把相邻字形边缘带进来。
    text.extraPadding=false
    self.requestFont(text,function()
        if self.go==nil or IsNull(self.go) or IsNull(text) then return end
        -- 独立材质去掉字体资源自带的粗黑描边，不修改其他页面共用的字体材质。
        if self.textMaterial==nil then
            self.textMaterial=CS.UnityEngine.Material(text.font.material)
            self.textMaterial:SetFloat("_OutlineWidth",0)
            self.textMaterial:SetFloat("_FaceDilate",0)
            self.textMaterial:DisableKeyword("OUTLINE_ON")
            self.textMaterial:DisableKeyword("UNDERLAY_ON")
            self.textMaterial:DisableKeyword("UNDERLAY_INNER")
        end
        text.fontSharedMaterial=self.textMaterial
    end)
    return text
end

-- 卡图保留完整头部；不能沿用已经裁掉头部的旧圆头像。
function BattleFormationPanel:Portrait(parent,name,x,y,size)
    local go=self:Node(parent,name,x,y,size,size)
    go:AddComponent(typeof(CS.UnityEngine.UI.RectMask2D))
    local art=self:Node(go.transform,"Art",0,-size*.125,size,size*1.25)
    return go,self:Background(art,Color(1,1,1,1))
end

function BattleFormationPanel:HeroArt(id,cfg)
    if tonumber(id)==1002 then return ART.."HeroUI_formation_nurse.png" end
    return cfg.card or cfg.avatar
end

function BattleFormationPanel:Action(parent,name,value,x,y,w,h,anchor,callback)
    local go=self:Node(parent,name,x,y,w,h,anchor)
    local bg=self:Background(go,Color(1,1,1,1),true)
    bg:LoadSprite(ART.."HeroUI_tab_round.png")
    local text=self:Label(go.transform,"Text",value,0,0,w-8,h-4,24)
    local btn=go:AddComponent(Button);btn.onClick:AddListener(callback)
    return go,bg,text,btn
end

function BattleFormationPanel:Show()
    self.levels=self.ctrl:GetAllLevels()
    if self.lastLevelId==nil then
        for i,lv in ipairs(self.levels) do
            if tonumber(lv.id)==tonumber(self.ctrl:GetCurLevelId()) then self.levelIndex=i end
        end
    end
    self.levelIndex=math.max(1,math.min(self.levelIndex,#self.levels))
    self:Refresh()
    if not self.fontReady then
        self.pendingShow=true
        self.go:SetActive(false)
        return
    end
    self.go:SetActive(true)
end

function BattleFormationPanel:ChangeLevel(delta)
    self.levelIndex=math.max(1,math.min(#self.levels,self.levelIndex+delta))
    self:Refresh()
end

function BattleFormationPanel:Assign(heroId)
    if DataCenter.PlaneBattleDataManager:SetFormationSlot(self.selectedSlot,heroId) then
        self:Refresh()
    else
        self.hint.text="该英雄暂时无法上阵，请重新选择"
    end
end

function BattleFormationPanel:Refresh()
    local mgr=DataCenter.HeroDataManager
    local ids=DataCenter.PlaneBattleDataManager:GetFormation()
    local team=Profile.BuildFormation(ids,mgr)
    for i,slot in ipairs(self.slots) do
        local id=ids[i]
        local cfg=id~=0 and mgr:GetHeroConfig(id) or nil
        local selected=i==self.selectedSlot
        slot.bg.color=selected and Color(.9,.68,1,1) or Color(.76,.94,1,.85)
        slot.caption.color=selected and Color(1,.88,1,1) or Color(.78,.91,1,1)
        slot.plane:SetActive(cfg~=nil);slot.avatar:SetActive(cfg~=nil);slot.plus.gameObject:SetActive(cfg==nil)
        slot.name.text=cfg and cfg.name or "待上阵"
        slot.level.text=cfg and ("Lv."..mgr:GetHeroLevel(id)) or ""
        if cfg then
            slot.avatarImg:LoadSprite(self:HeroArt(id,cfg))
            local aircraft=HeroAircraftCatalog.Get(id)
            slot.planeImg:LoadSprite(aircraft.sprite)
        end
    end
    self.summary.text=string.format("出战 %d/5    %s    增援僚机 +%d",#team.members,
        team.weaponLevel>0 and "开局双发" or "开局单发",team.wingmanBonus)
    self.gold.text="金币 "..DataCenter.PlaneBattleDataManager:GetTotalGold()
    self.hint.text=self.selectedSlot==1 and "选择主机驾驶员" or ("选择护航 "..(self.selectedSlot-1).." 驾驶员")
    self.remove:SetActive(ids[self.selectedSlot]~=0)
    local hasLeader=ids[1]~=0
    if not hasLeader then
        self.summary.text="请上阵主机驾驶员"
        self.summary.color=Color(1,.86,.58,1)
    else
        self.summary.color=Color(.84,.95,1,1)
    end
    for i,tab in ipairs(self.filterButtons) do
        local selected=i==self.filter
        tab.bg.color=selected and Color(.92,.98,1,1) or Color(.48,.65,.83,1)
        tab.bg:LoadSprite(ART..(selected and "HeroUI_tab_selected_round.png" or "HeroUI_tab_round.png"))
        tab.label.color=selected and Color(.12,.28,.46,1) or Color(.94,.97,1,1)
    end
    for _,card in ipairs(self.cards) do card:SetActive(false);card:Destroy() end
    self.cards={}
    local index=0
    for _,id in ipairs(mgr:GetAllHeroIds()) do
        local cfg=mgr:GetHeroConfig(id)
        if mgr:IsHeroOwned(id) and (not ROLES[self.filter] or cfg.role==ROLES[self.filter]) then
            index=index+1
            local heroId=id
            local card,cardRt=self:Node(self.cardRoot.transform,"Hero_"..id,77+(index-1)*158,0,146,184)
            cardRt.anchorMin,cardRt.anchorMax=Vector2(0,.5),Vector2(0,.5)
            cardRt.anchoredPosition=Vector2(77+(index-1)*158,0)
            local assigned=nil
            for i=1,5 do if tonumber(ids[i])==tonumber(id) then assigned=i end end
            self:Background(card,Color(.22,.38,.58,1),true):LoadSprite(ART.."HeroUI_card_round.png")
            local _,portrait=self:Portrait(card.transform,"Portrait",0,20,136)
            portrait:LoadSprite(self:HeroArt(id,cfg))
            local strip=self:Node(card.transform,"Info",0,-44,142,86)
            self:Background(strip,Color(.94,.97,1,1)):LoadSprite(ART.."HeroUI_card_footer_round.png")
            local name=self:Label(card.transform,"Name",cfg.name,0,-16,140,30,24)
            name.color=Color(.1,.23,.39,1)
            local level=self:Label(card.transform,"Level","Lv."..mgr:GetHeroLevel(id).."  "..(ROLE_NAMES[cfg.role] or ""),0,-43,140,26,21)
            level.color=Color(.22,.36,.5,1)
            local tag=self:Label(card.transform,"Status",assigned and (assigned==1 and "主机 · 上阵" or "护航 · 上阵") or "点击上阵",0,-70,140,26,20)
            tag.color=assigned and Color(.08,.47,.38,1) or Color(.2,.4,.62,1)
            local frame=self:Node(card.transform,"Frame",0,0,146,184)
            self:Background(frame,assigned and Color(.42,1,.82,1) or Color(.7,.82,.94,1)):LoadSprite(ART.."HeroUI_card_round_frame.png")
            local btn=card:AddComponent(Button);btn.onClick:AddListener(function() self:Assign(heroId) end)
            table.insert(self.cards,card)
        end
    end
    if index==0 then
        local empty=self:Label(self.cardRoot.transform,"Empty","暂无该职业的已拥有英雄",351,0,690,80,26)
        empty.color=Color(.2,.34,.49,1)
        local er=empty:GetComponent(RectTransform)
        er.anchorMin,er.anchorMax=Vector2(0,.5),Vector2(0,.5)
        er.anchoredPosition=Vector2(351,0)
        table.insert(self.cards,empty.gameObject)
    end
    self.cardRt.sizeDelta=Vector2(math.max(702,index*158),192)
    self.scroll.horizontalNormalizedPosition=0
    local lv=self.levels and self.levels[self.levelIndex]
    if lv then
        self.lastLevelId=tonumber(lv.id)
        local unlocked=self.lastLevelId<=tonumber(self.ctrl:GetCurLevelId())
        self.levelText.text=(lv.name or "关卡")..(unlocked and "" or " · 未解锁")
        local canStart=unlocked and hasLeader
        self.start:GetComponent(Button).interactable=canStart
        self.startText.text=not unlocked and "尚未解锁" or (hasLeader and "战 斗" or "请上阵主机")
        self.startText.fontSize=canStart and 34 or 26
        self.startBg.color=canStart and Color(1,1,1,1) or Color(.55,.63,.72,1)
    end
end

function BattleFormationPanel:__delete()
    if self.go~=nil and not IsNull(self.go) then self.go:Destroy() end
    if self.textMaterial~=nil then CS.UnityEngine.Object.Destroy(self.textMaterial);self.textMaterial=nil end
    self.go,self.rt,self.requestFont,self.ctrl,self.onStart,self.onClose=nil,nil,nil,nil,nil,nil
    self.selectedSlot,self.filter,self.levelIndex,self.lastLevelId,self.fontReady,self.pendingShow=nil,nil,nil,nil,nil,nil
    self.slots,self.filterButtons,self.cards,self.levels=nil,nil,nil,nil
    self.gold,self.levelText,self.summary,self.hint,self.remove=nil,nil,nil,nil,nil
    self.cardRoot,self.cardRt,self.scroll,self.start,self.startBg,self.startText=nil,nil,nil,nil,nil,nil
end

return BattleFormationPanel
