---
--- 英雄详情 — View
--- 布局：
---   属性Tab：稀有度 + 舰船信息条 + 立绘 + 战力数字 + 四维一行 + 升级/图鉴/出战
---   技能Tab：顶部称号、技能槽环绕立绘、技能详情卡、军衔加成列表、前往提升
---   军衔Tab：星级 + 英雄属性成长 ≫ + 技能槽 + 双提升军衔
--- 纯UI还原：立绘/卡面用项目内 Hero 资源；升级/提升不接真实消耗
---@class UIHeroDetailView : UIBaseView
---@field ctrl UIHeroDetailCtrl
local UIHeroDetailView = BaseClass("UIHeroDetailView", UIBaseView)
local base = UIBaseView

local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

local function ColorOf(rgba)
    return CS.UnityEngine.Color(rgba[1], rgba[2], rgba[3], rgba[4])
end

local COLOR_WHITE     = CS.UnityEngine.Color(1, 1, 1, 1)
local COLOR_POWER     = CS.UnityEngine.Color(1.00, 0.72, 0.08, 1)
local COLOR_TAB_IDLE  = CS.UnityEngine.Color(0.12, 0.25, 0.48, 1)
local COLOR_TAB_TEXT_IDLE = CS.UnityEngine.Color(0.72, 0.82, 0.95, 1)
local COLOR_TAB_SEL   = CS.UnityEngine.Color(0.22, 0.40, 0.62, 1)
local COLOR_LOCKED    = CS.UnityEngine.Color(0.55, 0.55, 0.6, 1)
local COLOR_STAR_ON   = CS.UnityEngine.Color(1, 0.85, 0.3, 1)
local COLOR_STAR_OFF  = CS.UnityEngine.Color(0.35, 0.35, 0.4, 1)
local COLOR_GROW_CUR  = CS.UnityEngine.Color(0.95, 0.55, 0.25, 1)
local COLOR_GROW_TGT  = CS.UnityEngine.Color(0.35, 0.90, 0.45, 1)
local COLOR_TAG_BG    = CS.UnityEngine.Color(0.95, 0.72, 0.20, 1)
local COLOR_DMG_BG    = CS.UnityEngine.Color(0.72, 0.40, 0.90, 1)
local COLOR_PANEL_BG  = CS.UnityEngine.Color(0.60, 0.72, 0.86, 0.96)
local COLOR_PORTRAIT  = CS.UnityEngine.Color(0.20, 0.66, 0.90, 1)
local COLOR_LEVEL_BAR = CS.UnityEngine.Color(0.49, 0.63, 0.82, 1)
local COLOR_STATS_BG  = CS.UnityEngine.Color(0.62, 0.73, 0.87, 0.96)
local COLOR_STAT_LBL  = CS.UnityEngine.Color(0.16, 0.29, 0.47, 1)
local COLOR_STAT_VAL  = CS.UnityEngine.Color(0.96, 0.98, 1.00, 1)
local COLOR_SUB       = CS.UnityEngine.Color(0.20, 0.36, 0.56, 1)
local COLOR_SHIP_PLATE= CS.UnityEngine.Color(0.25, 0.49, 0.74, 1)
local COLOR_BTN_GREEN = CS.UnityEngine.Color(0.22, 0.68, 0.35, 1)
local COLOR_BTN_BLUE  = CS.UnityEngine.Color(0.25, 0.45, 0.72, 1)
local COLOR_RANK_TIP  = CS.UnityEngine.Color(0.90, 0.25, 0.25, 1)
local SPR_STAR_ON     = "Assets/Main/Sprites/HeroUI/HeroUI_star_on.png"
local SPR_STAR_OFF    = "Assets/Main/Sprites/HeroUI/HeroUI_star_off.png"
local SPR_COIN        = "Assets/Main/Sprites/HeroUI/HeroUI_icon_coin_src.png"
local SPR_BOOK        = "Assets/Main/Sprites/HeroUI/HeroUI_icon_book_src.png"
local SPR_LOCK        = "Assets/Main/Sprites/HeroUI/HeroUI_lock.png"
local SPR_BACK        = "Assets/Main/Sprites/HeroUI/HeroUI_btn_back_src.png"
local SPR_SHIP        = "Assets/Main/Sprites/HeroUI/HeroUI_ship_warship.png"
local SPR_BG_DETAIL   = "Assets/Main/Sprites/HeroUI/HeroUI_bg_detail.png"
local SPR_FRAME       = "Assets/Main/Sprites/HeroUI/HeroUI_frame_gloss.png"
local SPR_STAT = {
    Firepower = "Assets/Main/Sprites/HeroUI/HeroUI_stat_fire.png",
    Durability = "Assets/Main/Sprites/HeroUI/HeroUI_stat_hp.png",
    Armor = "Assets/Main/Sprites/HeroUI/HeroUI_stat_armor.png",
    Troop = "Assets/Main/Sprites/HeroUI/HeroUI_stat_troop.png",
}
local SKILL_ICONS = {
    "Assets/Main/Sprites/HeroUI/HeroUI_skill_cannon.png",
    "Assets/Main/Sprites/HeroUI/HeroUI_skill_missile.png",
    "Assets/Main/Sprites/HeroUI/HeroUI_skill_shield.png",
    "Assets/Main/Sprites/HeroUI/HeroUI_skill_burst.png",
}
-- 稀有度主题：传说橙金 / 卓越及以下蓝
local THEME = {
    [1] = { portrait = {0.18,0.57,0.78,1}, panel = {0.59,0.71,0.85,0.96}, shell = {0.58,0.72,0.88,1}, accent = {0.35,0.75,0.50,1} },
    [2] = { portrait = {0.16,0.63,0.88,1}, panel = {0.60,0.73,0.88,0.96}, shell = {0.60,0.75,0.91,1}, accent = {0.30,0.55,0.85,1} },
    [3] = { portrait = {0.17,0.60,0.86,1}, panel = {0.62,0.73,0.88,0.96}, shell = {0.58,0.72,0.89,1}, accent = {0.45,0.40,0.85,1} },
    [4] = { portrait = {0.94,0.60,0.07,1}, panel = {0.86,0.72,0.47,0.96}, shell = {0.90,0.66,0.25,1}, accent = {1.00,0.78,0.16,1} },
}

local TABS = {
    { name = "属性", panelPath = "Panel/Panel_Attribute" },
    { name = "技能", panelPath = "Panel/Panel_Skill" },
    { name = "军衔", panelPath = "Panel/Panel_Rank" },
}

local SKILL_SLOT_LOCAL_POS = {
    [1] = CS.UnityEngine.Vector3(-265, 140, 0),
    [2] = CS.UnityEngine.Vector3(265, 140, 0),
    [3] = CS.UnityEngine.Vector3(-265, -60, 0),
    [4] = CS.UnityEngine.Vector3(265, -60, 0),
}

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local UnityImage    = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2
local TMPAlign      = CS.TMPro.TextAlignmentOptions

-- 详情 prefab 最初按横屏测试尺寸搭建；手机竖屏下，技能/军衔页的行节点只有 100 宽，
-- 长文案会逐字换行。统一把这些信息行重排为参考图中的横向阅读卡片。
local function SetTopRect(tf, x, y, w, h)
    if tf == nil then return end
    local rt = tf:GetComponent(RectTransform)
    if rt == nil then return end
    rt.anchorMin = Vector2(0.5, 1)
    rt.anchorMax = Vector2(0.5, 1)
    rt.pivot = Vector2(0.5, 0.5)
    rt.anchoredPosition = Vector2(x, y)
    rt.sizeDelta = Vector2(w, h)
end

local function SetTextRect(tf, x, y, w, h, align)
    SetTopRect(tf, x, y, w, h)
    if tf == nil then return end
    local tmp = tf:GetComponent(typeof(CS.NewTMPText))
    if tmp ~= nil then
        tmp.enableWordWrapping = true
        if align ~= nil then tmp.alignment = align end
    end
end

--- 运行时补一个 Image 子节点（不新建 TMP，避开 NewTMPText 坑）
local function EnsureImageChild(parent, name, w, h, ax, ay)
    if parent == nil then return nil end
    local exist = parent:Find(name)
    local go
    if exist ~= nil then
        go = exist.gameObject
        if go:GetComponent(UnityImage) == nil then
            go:AddComponent(UnityImage)
        end
    else
        go = GameObject(name, RectTransform)
        go.transform:SetParent(parent, false)
        go:AddComponent(UnityImage)
    end
    local rt = go:GetComponent(RectTransform)
    if rt ~= nil then
        rt.anchorMin = Vector2(0.5, 0.5)
        rt.anchorMax = Vector2(0.5, 0.5)
        rt.pivot = Vector2(0.5, 0.5)
        rt.sizeDelta = Vector2(w, h)
        rt.anchoredPosition = Vector2(ax or 0, ay or 0)
    end
    return go
end

-- 英雄详情页使用运行时纯色精灵搭建科技舞台，避免把海图整张图片当成人物背景。
-- 这些 1x1 精灵只服务于当前 Canvas，不会修改项目原有美术资源。
local function EnsureColorLayer(parent, name, x, y, w, h, color, sibling)
    if parent == nil then return nil end
    local go = parent:Find(name)
    if go == nil then
        go = GameObject(name, RectTransform).transform
        go:SetParent(parent, false)
        go.gameObject:AddComponent(UnityImage)
    end
    local rt = go:GetComponent(RectTransform)
    if rt ~= nil then
        rt.anchorMin = Vector2(0.5, 1)
        rt.anchorMax = Vector2(0.5, 1)
        rt.pivot = Vector2(0.5, 1)
        rt.anchoredPosition = Vector2(x, y)
        rt.sizeDelta = Vector2(w, h)
    end
    local img = go:GetComponent(UnityImage)
    if img ~= nil then
        img.sprite = nil
        img.color = color
        img.raycastTarget = false
    end
    if sibling ~= nil then go:SetSiblingIndex(sibling) end
    return go
end

local function StyleText(tf, size, color)
    if tf == nil then return end
    local tmp = tf:GetComponent(typeof(CS.NewTMPText))
    if tmp == nil then return end
    tmp.enableAutoSizing = false
    tmp.fontSize = size
    tmp.outlineWidth = 0
    tmp.color = color or COLOR_STAT_LBL
end

-- 手动坐标布局必须关闭旧 prefab 的 LayoutGroup，否则下一帧会重新覆盖这些坐标。
local function DisableAutoLayout(tf)
    if tf == nil then return end
    local group = tf:GetComponent(typeof(CS.UnityEngine.UI.LayoutGroup))
    if group ~= nil then group.enabled = false end
    local fitter = tf:GetComponent(typeof(CS.UnityEngine.UI.ContentSizeFitter))
    if fitter ~= nil then fitter.enabled = false end
end

--- 百分比描绿（截图：20.00%）
local function ColorizeSkillDesc(text)
    if text == nil or text == "" then return text end
    -- 先包住形如 20.00% / 20% 的数值
    local s = string.gsub(text, "(%d+%.?%d*%%)", '<color=#3ECF6E>%1</color>')
    return s
end

--- 「…（军衔N星）」括号段描红（截图技能加成行）
local function ColorizeBonusText(text)
    if text == nil or text == "" then return text end
    local main, tag = string.match(text, "^(.-)(（军衔[^）]*）)%s*$")
    if main == nil then
        main, tag = string.match(text, "^(.-)(%(军衔[^%)]*%))%s*$")
    end
    if main ~= nil and tag ~= nil then
        return main .. ' <color=#FF5A5A>' .. tag .. '</color>'
    end
    return text
end

--- 舰船星级：稀有度粗略映射（卓越3 / 传说5）
local function ShipStarCount(rarity)
    local r = tonumber(rarity) or 1
    if r >= 4 then return 5 end
    if r == 3 then return 3 end
    if r == 2 then return 2 end
    return 1
end

function UIHeroDetailView:OnCreate()
    base.OnCreate(self)

    self.txtRarity     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/TxtRarity")
    self.txtHeroName   = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/ShipInfoBar/TxtHeroName")
    self.txtHeroTitle  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/ShipInfoBar/TxtHeroTitle")
    self.imgShip       = SafeAddComponent(self, UIImage,             "Panel/ShipInfoBar/ImgShip")
    self.imgPortrait   = SafeAddComponent(self, UIImage,             "Panel/PortraitBg/ImgPortrait")
    self.txtPower      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/TxtPower")

    -- 属性Tab
    self.txtLevel      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/LevelBar/TxtLevel")
    self.txtFirepower  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatFirepower/TxtValue")
    self.txtDurability = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatDurability/TxtValue")
    self.txtArmor      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatArmor/TxtValue")
    self.txtTroop      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatTroop/TxtValue")
    self.btnUpgrade    = SafeAddComponent(self, UIButton,            "Panel/Panel_Attribute/BtnUpgrade")
    self.txtUpgrade    = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/BtnUpgrade/TxtLabel")
    self.txtUpgradeCost= SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/BtnUpgrade/TxtCost")
    self.btnBook       = SafeAddComponent(self, UIButton,            "Panel/Panel_Attribute/BtnBook")
    self.previewHint   = self.transform:Find("Panel/Panel_Attribute/TxtPreviewHint")

    self.txtStatNameFp = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatFirepower/TxtName")
    self.txtStatNameDu = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatDurability/TxtName")
    self.txtStatNameAr = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatArmor/TxtName")
    self.txtStatNameTr = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatTroop/TxtName")

    if self.btnUpgrade then
        self.btnUpgrade:SetOnClick(function()
            if not self._owned then
                UIUtil.ShowTips("英雄获取开发中")
                return
            end
            local ok, msg = self.ctrl:TryUpgrade(self.heroId)
            UIUtil.ShowTips(tostring(msg or (ok and "升级成功" or "升级失败")))
            if ok then self:_Refresh() self:_SelectTab(self.curTabIndex or 1) end
        end)
    end
    if self.btnBook then
        self.btnBook:SetOnClick(function() UIUtil.ShowTips("英雄图鉴开发中") end)
    end
    if self.txtStatNameFp then self.txtStatNameFp:SetText("火力") end
    if self.txtStatNameDu then self.txtStatNameDu:SetText("耐久") end
    if self.txtStatNameAr then self.txtStatNameAr:SetText("护甲") end
    if self.txtStatNameTr then self.txtStatNameTr:SetText("带兵量增加") end

    -- 技能Tab
    self.txtSkillName     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillName")
    self.txtSkillCooldown = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillCooldown")
    self.txtSkillTag      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillTagBox/TxtSkillTag")
    self.txtSkillDmgType  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillDmgTypeBox/TxtSkillDmgType")
    self.imgSkillTagBox   = SafeAddComponent(self, UIImage,             "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillTagBox")
    self.imgDmgTypeBox    = SafeAddComponent(self, UIImage,             "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillDmgTypeBox")
    self.txtSkillDesc     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillDesc")
    self.btnGoPromote     = SafeAddComponent(self, UIButton,            "Panel/Panel_Skill/BtnGoPromote")
    self.txtGoPromote     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/BtnGoPromote/TxtLabel")
    if self.btnGoPromote then
        self.btnGoPromote:SetOnClick(function() UIUtil.ShowTips("技能提升开发中") end)
    end

    self.rankRows = {}
    for i = 1, 5 do
        local rowPath = "Panel/Panel_Skill/SkillDetail/RankBonusList/RankRow_" .. i
        self.rankRows[i] = {
            row      = self.transform:Find(rowPath),
            txtStar  = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtStar"),
            txtBonus = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtBonus"),
        }
    end

    self.skillSlots = {}
    self:_BindSkillSlots()

    -- 军衔Tab
    self.stars = {}
    for i = 1, 5 do
        local p = "Panel/Panel_Rank/StarRow/Star_" .. i
        self.stars[i] = SafeAddComponent(self, UIImage, p .. "/Img")
        if self.stars[i] == nil then
            self.stars[i] = SafeAddComponent(self, UIImage, p)
        end
    end

    self.growRows = {}
    local growDefs = {
        { key = "Durability", label = "英雄耐久" },
        { key = "Firepower",  label = "英雄火力" },
        { key = "Armor",      label = "英雄护甲" },
    }
    for _, def in ipairs(growDefs) do
        local rowPath = "Panel/Panel_Rank/GrowList/GrowRow" .. def.key
        local txtName = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtName")
        if txtName then txtName:SetText(def.label) end
        self.growRows[def.key] = {
            label    = def.label,
            txtName  = txtName,
            txtCur   = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtCur"),
            txtArrow = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtArrow"),
            txtTarget= SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtTarget"),
        }
    end

    self.rankSkillSlots = {}
    for i = 1, 3 do
        self.rankSkillSlots[i] = {
            root = self.transform:Find("Panel/Panel_Rank/RankSkillSlots/RankSkillSlot_" .. i),
            txt  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Rank/RankSkillSlots/RankSkillSlot_" .. i .. "/TxtTag"),
            lock = self.transform:Find("Panel/Panel_Rank/RankSkillSlots/RankSkillSlot_" .. i .. "/LockIcon"),
            icon = SafeAddComponent(self, UIImage, "Panel/Panel_Rank/RankSkillSlots/RankSkillSlot_" .. i .. "/ImgIcon"),
        }
    end

    self.promoteBtns = {}
    self.promoteCosts = {}
    for i = 1, 2 do
        local btn = SafeAddComponent(self, UIButton, "Panel/Panel_Rank/PromoteRow/BtnPromote_" .. i)
        local cost = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Rank/PromoteRow/BtnPromote_" .. i .. "/TxtCost")
        local label = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Rank/PromoteRow/BtnPromote_" .. i .. "/TxtLabel")
        if label then label:SetText("提升军衔") end
        if btn then
            btn:SetOnClick(function()
                if not self._owned then
                    UIUtil.ShowTips("未拥有，无法提升军衔")
                    return
                end
                local ok, msg = self.ctrl:TryPromote(self.heroId)
                UIUtil.ShowTips(tostring(msg or (ok and "提升成功" or "提升失败")))
                if ok then self:_Refresh() self:_SelectTab(self.curTabIndex or 1) end
            end)
        end
        self.promoteBtns[i] = btn
        self.promoteCosts[i] = cost
    end

    -- 参考图的详情页没有单独的出战按钮；出战状态仍由列表卡的“出战中”标识呈现。
    self.btnDeploy     = SafeAddComponent(self, UIButton,            "Panel/BtnDeploy")
    self.txtBtnDeploy  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/BtnDeploy/TxtLabel")
    if self.btnDeploy then
        self.btnDeploy:SetOnClick(function() self:_OnClickDeploy() end)
    end

    self.btnBack = SafeAddComponent(self, UIButton, "Panel/BtnBack")
    if self.btnBack then self.btnBack:SetOnClick(function() self:CloseSelf() end) end

    -- 详情内左右切英雄（对齐截图）
    self.btnNavLeft = SafeAddComponent(self, UIButton, "Panel/BtnNavLeft")
    self.btnNavRight = SafeAddComponent(self, UIButton, "Panel/BtnNavRight")
    if self.btnNavLeft then
        self.btnNavLeft:SetOnClick(function() self:_NavHero(-1) end)
    end
    if self.btnNavRight then
        self.btnNavRight:SetOnClick(function() self:_NavHero(1) end)
    end
    self.btnInfo = SafeAddComponent(self, UIButton, "Panel/BtnInfo")
    if self.btnInfo then
        self.btnInfo:SetOnClick(function() UIUtil.ShowTips("英雄说明开发中") end)
    end

    self:_CreateTabs()
    self:_EnsureShipExtras()
    self:_EnsureCostIcons()
    self:_EnsureRankRowStars()
    self:_ApplyStaticStyle()
    self:_EnsureHeroStage()
end

--- 参考图的主视觉是一整页人物舞台，不是人物叠在一张海图卡片上。
--- 独立创建背景和立绘节点，旧 PortraitBg 只保留在 prefab 中作兼容回退。
function UIHeroDetailView:_EnsureHeroStage()
    local panel = self.transform:Find("Panel")
    if panel == nil then return end
    -- 旧版运行时曾创建一个矩形 Glow 层，它会压暗人物下半身；新舞台改为整页渐变后清除它。
    local legacyGlow = panel:Find("HeroStageGlow")
    if legacyGlow ~= nil then CS.UnityEngine.Object.Destroy(legacyGlow.gameObject) end
    self.heroStageBackdrop = EnsureColorLayer(panel, "HeroStageBackdrop", 0, -800, 920, 1625, COLOR_WHITE, 0)
    local bgRt = self.heroStageBackdrop:GetComponent(RectTransform)
    bgRt.anchorMin = Vector2(0, 0)
    bgRt.anchorMax = Vector2(1, 1)
    bgRt.offsetMin = Vector2(0, 0)
    bgRt.offsetMax = Vector2(0, 0)
    local viewport = panel:Find("HeroStageViewport")
    if viewport == nil then
        viewport = GameObject("HeroStageViewport", RectTransform).transform
        viewport:SetParent(panel, false)
        viewport.gameObject:AddComponent(typeof(CS.UnityEngine.UI.RectMask2D))
    end
    self.heroStageViewport = viewport
    viewport:SetSiblingIndex(1)

    local stagePortrait = viewport:Find("HeroStagePortrait") or panel:Find("HeroStagePortrait")
    if stagePortrait == nil then
        local go = GameObject("HeroStagePortrait", RectTransform)
        go.transform:SetParent(panel, false)
        go:AddComponent(UnityImage)
        stagePortrait = go.transform
    end
    stagePortrait:SetParent(viewport, false)
    local rt = stagePortrait:GetComponent(RectTransform)
    if rt ~= nil then
        rt.anchorMin = Vector2(0.5, 1)
        rt.anchorMax = Vector2(0.5, 1)
        rt.pivot = Vector2(0.5, 0.5)
        rt.anchoredPosition = Vector2(0, -342)
        rt.sizeDelta = Vector2(500, 650)
    end
    local img = stagePortrait:GetComponent(UnityImage)
    if img ~= nil then
        img.preserveAspect = true
        img.raycastTarget = false
        img.color = COLOR_WHITE
    end
    if self.heroStagePortrait == nil then
        self.heroStagePortrait = self:AddComponent(UIImage, stagePortrait.gameObject)
    end

    local portraitBg = self.transform:Find("Panel/PortraitBg")
    if portraitBg ~= nil then portraitBg.gameObject:SetActive(false) end
end

function UIHeroDetailView:_RefreshHeroStage(data)
    if data == nil then return end
    self:_EnsureHeroStage()
    local rarity = tonumber(data.rarity) or 3
    local bgImg = self.heroStageBackdrop ~= nil and self.heroStageBackdrop:GetComponent(UnityImage) or nil
    if bgImg ~= nil then
        local gold = rarity >= 4
        if self._stageGold ~= gold or self._stageTexture == nil then
            if self._stageSprite ~= nil then CS.UnityEngine.Object.Destroy(self._stageSprite) end
            if self._stageTexture ~= nil then CS.UnityEngine.Object.Destroy(self._stageTexture) end
            local tex = CS.UnityEngine.Texture2D(64, 128)
            tex.wrapMode = CS.UnityEngine.TextureWrapMode.Clamp
            for y = 0, 127 do
                local t = y / 127
                local top = gold and ColorOf({0.46,0.28,0.08,1}) or ColorOf({0.16,0.27,0.51,1})
                local mid = gold and ColorOf({0.90,0.66,0.24,1}) or ColorOf({0.12,0.67,0.87,1})
                local bottom = gold and ColorOf({0.87,0.79,0.62,1}) or ColorOf({0.71,0.78,0.88,1})
                local c = t < 0.40 and bottom or CS.UnityEngine.Color.Lerp(mid, top, (t - 0.40) / 0.60)
                if t >= 0.34 and t < 0.46 then c = CS.UnityEngine.Color.Lerp(bottom, mid, (t - 0.34) / 0.12) end
                for x = 0, 63 do
                    local shade = 1 - math.abs(x / 63 - 0.5) * 0.10
                    tex:SetPixel(x, y, CS.UnityEngine.Color(c.r * shade, c.g * shade, c.b * shade, 1))
                end
            end
            tex:Apply()
            self._stageTexture = tex
            self._stageSprite = CS.UnityEngine.Sprite.Create(tex, CS.UnityEngine.Rect(0,0,64,128), Vector2(0.5,0.5), 100)
            self._stageGold = gold
        end
        bgImg.sprite = self._stageSprite
        bgImg.color = COLOR_WHITE
    end
    if self.heroStagePortrait ~= nil then
        local stagePath = data.stagePortrait or data.portrait
        if stagePath ~= nil and stagePath ~= "" then
            self.heroStagePortrait:LoadSprite(stagePath)
            self.heroStagePortrait:SetColor(COLOR_WHITE)
        else
            self.heroStagePortrait:SetColor(ColorOf(data.rarityColor))
        end
    end
end

--- 舰船条：船下星级行 + 右侧小船格（对齐属性页截图）
function UIHeroDetailView:_EnsureShipExtras()
    local bar = self.transform:Find("Panel/ShipInfoBar")
    if bar == nil then return end
    self.shipStarRow = self.transform:Find("Panel/ShipInfoBar/ShipStarRow")
    if self.shipStarRow == nil then
        local rowGo = GameObject("ShipStarRow", RectTransform)
        rowGo.transform:SetParent(bar, false)
        local rt = rowGo:GetComponent(RectTransform)
        if rt ~= nil then
            rt.anchorMin = Vector2(0.5, 0.5)
            rt.anchorMax = Vector2(0.5, 0.5)
            rt.pivot = Vector2(0.5, 0.5)
            rt.sizeDelta = Vector2(120, 22)
            rt.anchoredPosition = Vector2(-90, -42)
        end
        self.shipStarRow = rowGo.transform
    end
    self.shipStars = {}
    for i = 1, 5 do
        local go = EnsureImageChild(self.shipStarRow, "Star_" .. i, 20, 20, (i - 3) * 22, 0)
        self.shipStars[i] = go
    end

    -- 右端小船/道具格
    local right = EnsureImageChild(bar, "ImgShipItem", 52, 52, 175, 0)
    self.shipRightCell = right
    if right ~= nil then
        local img = right:GetComponent(UnityImage)
        if img ~= nil then
            img.color = ColorOf(COLOR_SHIP_PLATE)
        end
        EnsureImageChild(right.transform, "ImgShipItemIcon", 40, 40, 0, 0)
        local icon = right.transform:Find("ImgShipItemIcon")
        if icon ~= nil then
            local ui = self:AddComponent(UIImage, icon.gameObject)
            if ui ~= nil then
                ui:LoadSprite(SPR_SHIP)
                ui:SetColor(COLOR_WHITE)
            end
        end
    end
end

--- 升级/提升军衔按钮：消耗前加材料小图标
function UIHeroDetailView:_EnsureCostIcons()
    self.costIcons = {}
    local targets = {
        { path = "Panel/Panel_Attribute/BtnUpgrade", key = "upgrade" },
        { path = "Panel/Panel_Rank/PromoteRow/BtnPromote_1", key = "p1" },
        { path = "Panel/Panel_Rank/PromoteRow/BtnPromote_2", key = "p2" },
    }
    for _, t in ipairs(targets) do
        local btn = self.transform:Find(t.path)
        if btn ~= nil then
            local go = EnsureImageChild(btn, "ImgCostIcon", 30, 30, -70, -56)
            self.costIcons[t.key] = go
            local ui = self:AddComponent(UIImage, go)
            if ui ~= nil then
                ui:LoadSprite(SPR_COIN)
                ui:SetColor(COLOR_WHITE)
            end
        end
    end
end

--- 技能加成行左侧星图标（截图灰星，不用 ★ 字符）
function UIHeroDetailView:_EnsureRankRowStars()
    self.rankRowStars = {}
    for i = 1, 5 do
        local rowPath = "Panel/Panel_Skill/SkillDetail/RankBonusList/RankRow_" .. i
        local row = self.transform:Find(rowPath)
        if row ~= nil then
            local go = EnsureImageChild(row, "ImgStar", 28, 28, -280, 0)
            self.rankRowStars[i] = go
            local ui = self:AddComponent(UIImage, go)
            if ui ~= nil then
                ui:LoadSprite(SPR_STAR_OFF)
                ui:SetColor(COLOR_WHITE)
            end
            -- 左侧文字星隐藏，避免和图标叠
            local txtStar = self.transform:Find(rowPath .. "/TxtStar")
            if txtStar ~= nil then txtStar.gameObject:SetActive(false) end
        end
    end
end

function UIHeroDetailView:_NavHero(dir)
    local ids = self.browseHeroIds
    if ids == nil or #ids == 0 then return end
    local cur = 1
    for i, id in ipairs(ids) do
        if id == self.heroId then cur = i break end
    end
    local nextIndex = cur + (dir or 1)
    if nextIndex < 1 then nextIndex = #ids end
    if nextIndex > #ids then nextIndex = 1 end
    self.heroId = ids[nextIndex]
    self:_Refresh()
    local tab = self.curTabIndex or 1
    if tab == 3 and not self._owned then tab = 1 end
    self:_SelectTab(tab)
end

function UIHeroDetailView:_BindSkillSlots()
    self.skillSlots = {}
    self.skillIconRow = self.transform:Find("Panel/Panel_Skill/SkillIconRow")
    for i = 1, 4 do
        local path = "Panel/Panel_Skill/SkillIconRow/SkillSlot_" .. i
        local root = self.transform:Find(path)
        if root == nil and i == 4 then
            local src = self.transform:Find("Panel/Panel_Skill/SkillIconRow/SkillSlot_1")
            if src ~= nil then
                local go = CS.UnityEngine.GameObject.Instantiate(src.gameObject, src.parent)
                go.name = "SkillSlot_4"
                go:SetActive(false)
                root = go.transform
            end
        end
        if root ~= nil then
            local txtTf = root:Find("TxtTag")
            local lockTf = root:Find("LockIcon")
            local iconTf = root:Find("ImgIcon")
            self.skillSlots[i] = {
                root = root,
                txt  = txtTf ~= nil and self:AddComponent(UITextMeshProUGUIEx, txtTf.gameObject) or nil,
                lock = lockTf,
                icon = iconTf ~= nil and self:AddComponent(UIImage, iconTf.gameObject) or nil,
            }
        end
    end
end

function UIHeroDetailView:_ApplyRarityTheme(data)
    local theme = THEME[tonumber(data.rarity) or 3] or THEME[3]
    local portBg = self.transform:Find("Panel/PortraitBg")
    if portBg ~= nil then
        local img = portBg:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if img ~= nil then
            -- 参考中传说英雄使用整页金色背景，不再混入普通英雄的蓝色海面图。
            img.enabled = (tonumber(data.rarity) or 0) < 4
            img.color = ColorOf(theme.portrait)
        end
    end
    local panels = {
        "Panel/Panel_Skill/SkillDetail",
        "Panel/Panel_Rank/GrowList",
    }
    for _, p in ipairs(panels) do
        local tf = self.transform:Find(p)
        if tf ~= nil then
            local img = tf:GetComponent(typeof(CS.UnityEngine.UI.Image))
            if img ~= nil then img.color = ColorOf(theme.panel) end
        end
    end
    -- 传说页签强调色可后续用 theme.accent
    self._theme = theme
end

function UIHeroDetailView:_ApplyStaticStyle()
    local portraitBg = self.transform:Find("Panel/PortraitBg")
    if portraitBg ~= nil then
        local ui = self:AddComponent(UIImage, "Panel/PortraitBg")
        if ui ~= nil and SPR_BG_DETAIL ~= nil then
            ui:LoadSprite(SPR_BG_DETAIL)
            ui:SetColor(COLOR_WHITE)
        else
            local imgBg = portraitBg:GetComponent(typeof(CS.UnityEngine.UI.Image))
            if imgBg ~= nil then imgBg.color = COLOR_PORTRAIT end
        end
    end

    -- 战力金币 / 图鉴书本 / 返回箭头
    local coin = self.transform:Find("Panel/ImgPowerCoin")
    if coin ~= nil then
        local img = coin:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if img ~= nil then img.color = COLOR_WHITE end
        local ui = self:AddComponent(UIImage, "Panel/ImgPowerCoin")
        if ui ~= nil then ui:LoadSprite(SPR_COIN) ui:SetColor(COLOR_WHITE) end
    end
    local btnBookImg = self.transform:Find("Panel/Panel_Attribute/BtnBook")
    if btnBookImg ~= nil then
        local ui = self:AddComponent(UIImage, "Panel/Panel_Attribute/BtnBook")
        if ui ~= nil then ui:LoadSprite(SPR_BOOK) ui:SetColor(COLOR_WHITE) end
    end
    local back = self.transform:Find("Panel/BtnBack")
    if back ~= nil then
        local ui = self:AddComponent(UIImage, "Panel/BtnBack")
        if ui ~= nil then ui:LoadSprite(SPR_BACK) ui:SetColor(COLOR_WHITE) end
    end

    -- 属性页：等级条浅蓝、属性面板浅灰蓝（对齐实机）
    local levelBar = self.transform:Find("Panel/Panel_Attribute/LevelBar")
    if levelBar ~= nil then
        local img = levelBar:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if img ~= nil then img.color = COLOR_LEVEL_BAR end
    end
    local statsRow = self.transform:Find("Panel/Panel_Attribute/StatsRow")
    if statsRow ~= nil then
        local img = statsRow:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if img ~= nil then img.color = COLOR_STATS_BG end
    end
    for _, key in ipairs({ "Firepower", "Durability", "Armor", "Troop" }) do
        local st = self.transform:Find("Panel/Panel_Attribute/StatsRow/Stat" .. key)
        if st ~= nil then
            local icon = st:Find("ImgIcon")
            if icon ~= nil then
                icon.gameObject:SetActive(true)
                local ui = self:AddComponent(UIImage, "Panel/Panel_Attribute/StatsRow/Stat" .. key .. "/ImgIcon")
                if ui ~= nil and SPR_STAT[key] ~= nil then
                    ui:LoadSprite(SPR_STAT[key])
                    ui:SetColor(COLOR_WHITE)
                end
            end
            local nm = st:Find("TxtName")
            if nm ~= nil then
                local tmp = nm:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
                if tmp ~= nil then tmp.color = COLOR_STAT_LBL end
            end
            local val = st:Find("TxtValue")
            if val ~= nil then
                local tmp = val:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
                if tmp ~= nil then tmp.color = COLOR_STAT_VAL end
            end
        end
    end
    local txtLevel = self.transform:Find("Panel/Panel_Attribute/LevelBar/TxtLevel")
    if txtLevel ~= nil then
        local tmp = txtLevel:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        if tmp ~= nil then tmp.color = COLOR_WHITE end
    end
    local preview = self.transform:Find("Panel/Panel_Attribute/TxtPreviewHint")
    if preview ~= nil then
        local tmp = preview:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
        if tmp ~= nil then tmp.color = COLOR_SUB end
    end

    local panels = {
        "Panel/Panel_Skill/SkillDetail",
        "Panel/Panel_Rank/GrowList",
    }
    for _, p in ipairs(panels) do
        local tf = self.transform:Find(p)
        if tf ~= nil then
            local img = tf:GetComponent(typeof(CS.UnityEngine.UI.Image))
            if img ~= nil then img.color = COLOR_PANEL_BG end
        end
    end

    if self.imgPortrait ~= nil then
        self.imgPortrait:SetColor(COLOR_WHITE)
    end
    if self.txtPower ~= nil then
        self.txtPower:SetColor(COLOR_POWER)
    end
    if self.imgSkillTagBox ~= nil then self.imgSkillTagBox:SetColor(COLOR_TAG_BG) end
    if self.imgDmgTypeBox ~= nil then self.imgDmgTypeBox:SetColor(COLOR_DMG_BG) end
end

function UIHeroDetailView:OnEnable()
    -- 画布相机与层级统一由 UIBaseView/UIManager 管理，避免覆盖根 Overlay 的渲染模式。
    base.OnEnable(self)
    self:ApplyUserData()
end

function UIHeroDetailView:OnDestroy()
    if self._stageSprite ~= nil then CS.UnityEngine.Object.Destroy(self._stageSprite) end
    if self._stageTexture ~= nil then CS.UnityEngine.Object.Destroy(self._stageTexture) end
    self.heroId = nil
    self.browseHeroIds = nil
    self.rankRows = nil
    self.growRows = nil
    self.stars = nil
    self.skillSlots = nil
    self.rankSkillSlots = nil
    self.tabBtns = nil
    self.tabTexts = nil
    self.tabImages = nil
    base.OnDestroy(self)
end

function UIHeroDetailView:ApplyUserData()
    local heroId, heroIds = self:GetUserData()
    self.heroId = heroId
    self.browseHeroIds = self.ctrl:GetBrowseHeroIds(heroId, heroIds)
    self:_Refresh()
    self:_SelectTab(1)
end

function UIHeroDetailView:_Refresh()
    local data = self.ctrl:GetDetailData(self.heroId)
    if data == nil then
        Logger.LogError('#Hero# 详情页找不到英雄数据 heroId=' .. tostring(self.heroId))
        return
    end
    self._data = data
    self._owned = data.owned
    self:_ApplyRarityTheme(data)
    self:_RefreshHeroStage(data)

    -- 顶部
    if self.txtRarity ~= nil then
        self.txtRarity:SetText(data.rarityName)
        self.txtRarity:SetColor(ColorOf(data.rarityColor))
    end
    -- 传说预览：稀有度金字更醒目（截图左上「传说」）
    if data.isLegendPreview and self.txtRarity ~= nil then
        self.txtRarity:SetColor(COLOR_POWER)
    end
    if self.txtHeroName ~= nil then self.txtHeroName:SetText(data.name) end
    if self.txtHeroTitle ~= nil then self.txtHeroTitle:SetText(data.title) end
    -- 舰船位：有战舰立绘则 LoadSprite，不再色板
    if self.imgShip ~= nil then
        local shipPath = data.aircraft.sprite
        if shipPath ~= nil and shipPath ~= "" then
            self.imgShip:LoadSprite(shipPath)
            self.imgShip:SetColor(COLOR_WHITE)
        else
            self.imgShip:SetColor(COLOR_SHIP_PLATE)
        end
    end
    self:_RefreshShipStars(data)
    local icon=self.transform:Find("Panel/ShipInfoBar/ImgShipItem/ImgShipItemIcon")
    if icon ~= nil then icon.gameObject:SetActive(false) end
    if self.imgPortrait ~= nil then
        if data.portrait ~= nil and data.portrait ~= "" then
            self.imgPortrait:LoadSprite(data.portrait)
            self.imgPortrait:SetColor(COLOR_WHITE)
        else
            self.imgPortrait:SetColor(ColorOf(data.rarityColor))
        end
    end
    if self.txtPower ~= nil then
        self.txtPower:SetText(data.powerText)
    end

    -- 属性Tab
    if self.txtLevel ~= nil then self.txtLevel:SetText(data.levelText) end
    if self.txtFirepower ~= nil then self.txtFirepower:SetText(tostring(data.firepower)) end
    if self.txtDurability ~= nil then self.txtDurability:SetText(tostring(data.durability)) end
    if self.txtArmor ~= nil then self.txtArmor:SetText(tostring(data.armor)) end
    if self.txtTroop ~= nil then self.txtTroop:SetText("+" .. tostring(data.troop)) end

    if self.txtUpgrade ~= nil then
        self.txtUpgrade:SetText(data.owned and "升级" or "获取")
    end
    -- 传说未拥有预览：截图升级钮为绿色「获取」、无消耗行
    if data.isLegendPreview and self.btnUpgrade ~= nil then
        local img = self.transform:Find("Panel/Panel_Attribute/BtnUpgrade")
        if img ~= nil then
            local uiImg = img:GetComponent(UnityImage)
            if uiImg ~= nil then uiImg.color = COLOR_BTN_GREEN end
        end
    end
    if self.txtUpgradeCost ~= nil then
        if data.owned and data.upgradeCost ~= nil and data.upgradeCost ~= "" and data.upgradeCost ~= "-" then
            self.txtUpgradeCost:SetText(data.upgradeCost)
            self.txtUpgradeCost.gameObject:SetActive(true)
        else
            self.txtUpgradeCost.gameObject:SetActive(false)
        end
    end
    self:_RefreshCostIcons(data, self.curTabIndex == 1, self.curTabIndex or 1)
    if self.previewHint ~= nil then
        self.previewHint.gameObject:SetActive(data.previewHint ~= nil)
        if data.previewHint ~= nil then
            local tmp = self.previewHint:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
            if tmp ~= nil then tmp.text = data.previewHint end
        end
    end

    -- 技能Tab
    if self.txtSkillName ~= nil then
        self.txtSkillName:SetText(data.skillName .. "  " .. data.skillLevelText)
    end
    if self.txtSkillCooldown ~= nil then self.txtSkillCooldown:SetText(data.cooldownText) end
    if self.txtSkillTag ~= nil then self.txtSkillTag:SetText(data.skillTag) end
    if self.txtSkillDmgType ~= nil then self.txtSkillDmgType:SetText(data.skillDmgType) end
    if self.txtSkillDesc ~= nil then
        self.txtSkillDesc:SetText(ColorizeSkillDesc(data.skillDesc))
    end
    if self.txtGoPromote ~= nil then
        if data.owned then
            self.txtGoPromote:SetText("前往提升")
        else
            self.txtGoPromote:SetText("技能满级属性预览")
        end
    end
    if self.btnGoPromote ~= nil then
        self.btnGoPromote:SetInteractable(data.owned)
    end

    self:_RefreshSkillSlots(data)
    self:_RefreshRankRows()
    self:_RefreshRankTab(data)
    self:_RefreshDeployButton(data)
end

function UIHeroDetailView:_RefreshSkillSlots(data)
    local slotCount = self.ctrl:GetSkillSlotCount(self.heroId)
    for i, slot in pairs(self.skillSlots) do
        if slot.root ~= nil then
            local show = (i <= slotCount)
            slot.root.gameObject:SetActive(show)
            if show then
                -- 技能图标
                if slot.icon ~= nil then
                    local iconPath = SKILL_ICONS[((i - 1) % #SKILL_ICONS) + 1]
                    if iconPath ~= nil then
                        slot.icon:LoadSprite(iconPath)
                        slot.icon:SetColor(COLOR_WHITE)
                    end
                end
                if data.owned then
                    if i == 1 or (data.star or 0) >= i - 1 then
                        if slot.lock ~= nil then slot.lock.gameObject:SetActive(false) end
                        if slot.txt ~= nil then
                            slot.txt:SetText((i == 1) and tostring(data.skillLevel) .. "级" or "1级")
                        end
                    else
                        if slot.lock ~= nil then
                            slot.lock.gameObject:SetActive(true)
                            local lockImg = self:AddComponent(UIImage, slot.lock.gameObject)
                            if lockImg ~= nil then
                                lockImg:LoadSprite(SPR_LOCK)
                                lockImg:SetColor(COLOR_WHITE)
                            end
                        end
                        if slot.txt ~= nil then slot.txt:SetText("满级") end
                    end
                else
                    if slot.lock ~= nil then slot.lock.gameObject:SetActive(false) end
                    if slot.txt ~= nil then slot.txt:SetText("满级") end
                end
            end
        end
    end
end

function UIHeroDetailView:_RefreshRankRows()
    local list = self.ctrl:GetSkillRankBonusList(self.heroId)
    for i, cell in ipairs(self.rankRows) do
        local data = list[i]
        if data == nil then
            if cell.row ~= nil then cell.row.gameObject:SetActive(false) end
        else
            if cell.row ~= nil then cell.row.gameObject:SetActive(true) end
            if cell.txtStar ~= nil then
                cell.txtStar:SetText("")
            end
            local starImg = self.rankRowStars and self.rankRowStars[i] or nil
            if starImg ~= nil then
                local ui = self:AddComponent(UIImage, starImg)
                if ui ~= nil then
                    ui:LoadSprite(data.unlocked and SPR_STAR_ON or SPR_STAR_OFF)
                    ui:SetColor(data.unlocked and COLOR_STAR_ON or COLOR_WHITE)
                end
            end
            if cell.txtBonus ~= nil then
                -- 主文案白色 + （军衔N星）红色，对齐截图
                cell.txtBonus:SetText(ColorizeBonusText(tostring(data.bonusText or "")))
                cell.txtBonus:SetColor(data.unlocked and COLOR_WHITE or COLOR_LOCKED)
            end
        end
    end
end

function UIHeroDetailView:_RefreshShipStars(data)
    if self.shipStars == nil then return end
    local filled = ShipStarCount(data and data.rarity or 1)
    if data ~= nil and not data.owned then
        -- 未拥有传说预览截图是满星
        filled = ShipStarCount(data.rarity)
    end
    for i, go in ipairs(self.shipStars) do
        if go ~= nil then
            local ui = self:AddComponent(UIImage, go)
            if ui ~= nil then
                ui:LoadSprite(i <= filled and SPR_STAR_ON or SPR_STAR_OFF)
                ui:SetColor(COLOR_WHITE)
            end
        end
    end
end

function UIHeroDetailView:_RefreshRankTab(data)
    local star = tonumber(data.star) or 0
    if not data.owned then star = 0 end
    for i, starNode in ipairs(self.stars) do
        if starNode ~= nil then
            local path = (i <= star) and SPR_STAR_ON or SPR_STAR_OFF
            if starNode.LoadSprite ~= nil then
                starNode:LoadSprite(path)
                starNode:SetColor((i <= star) and COLOR_STAR_ON or CS.UnityEngine.Color(0.58, 0.62, 0.70, 1))
            end
        end
    end

    local growValues = {
        Durability = { cur = data.durability or 0, target = data.rankDurability or 0 },
        Firepower  = { cur = data.firepower or 0,  target = data.rankFirepower or 0 },
        Armor      = { cur = data.armor or 0,      target = data.rankArmor or 0 },
    }
    -- 截图军衔页左侧常为0（当前军衔加成），右侧为满星目标
    local rankBonusCur = (data.star or 0) > 0 and nil or 0

    for key, cell in pairs(self.growRows) do
        local v = growValues[key] or { cur = 0, target = 0 }
        local curText = tostring(rankBonusCur ~= nil and rankBonusCur or v.cur)
        local targetText = self.ctrl:_FormatNumber(v.target)
        if cell.txtCur ~= nil then
            cell.txtCur:SetText(curText)
            cell.txtCur:SetColor(COLOR_GROW_CUR)
        end
        if cell.txtArrow ~= nil then
            cell.txtArrow:SetText("≫")
            cell.txtArrow:SetColor(COLOR_GROW_TGT)
        end
        if cell.txtTarget ~= nil then
            cell.txtTarget:SetText(targetText)
            cell.txtTarget:SetColor(COLOR_GROW_TGT)
        end
    end

    -- 军衔页技能槽
    for i, slot in ipairs(self.rankSkillSlots) do
        if slot.root ~= nil then
            slot.root.gameObject:SetActive(true)
            if slot.icon ~= nil then
                local iconPath = SKILL_ICONS[((i - 1) % #SKILL_ICONS) + 1]
                if iconPath ~= nil then
                    slot.icon:LoadSprite(iconPath)
                    slot.icon:SetColor(COLOR_WHITE)
                end
            end
            if slot.txt ~= nil then
                if data.owned then
                    if i == 1 then
                        slot.txt:SetText(tostring(data.skillLevel) .. "级")
                    else
                        slot.txt:SetText("满级")
                    end
                else
                    slot.txt:SetText("满级")
                end
            end
            if slot.lock ~= nil then
                local locked = data.owned and i > 1
                slot.lock.gameObject:SetActive(locked)
                if locked then
                    local lockImg = self:AddComponent(UIImage, slot.lock.gameObject)
                    if lockImg ~= nil then
                        lockImg:LoadSprite(SPR_LOCK)
                        lockImg:SetColor(COLOR_WHITE)
                    end
                end
            end
        end
    end

    local costs = { data.promoteCost1, data.promoteCost2 }
    for i = 1, 2 do
        if self.promoteCosts[i] ~= nil then
            local c = costs[i]
            if c ~= nil and c ~= "" and c ~= "-" then
                self.promoteCosts[i]:SetText(c)
                self.promoteCosts[i].gameObject:SetActive(true)
            else
                self.promoteCosts[i].gameObject:SetActive(false)
            end
        end
        if self.promoteBtns[i] ~= nil then
            self.promoteBtns[i]:SetInteractable(data.owned)
        end
    end
end

function UIHeroDetailView:_RefreshDeployButton(data)
    if self.btnDeploy == nil then return end
    self.btnDeploy.gameObject:SetActive(false)
    -- 未拥有不能出战
    self.btnDeploy:SetInteractable(data.owned and not data.isDeployed)
    if self.txtBtnDeploy ~= nil then
        if not data.owned then
            self.txtBtnDeploy:SetText("未拥有")
        else
            self.txtBtnDeploy:SetText(data.isDeployed and "出战中" or "设为出战")
        end
    end
end

function UIHeroDetailView:_OnClickDeploy()
    local ok, errMsg = self.ctrl:SetDeployed(self.heroId)
    if not ok then
        UIUtil.ShowTips(tostring(errMsg or "无法出战"))
        Logger.LogError('#Hero# 设为出战失败 ' .. tostring(errMsg))
        return
    end
    self:_RefreshDeployButton({ owned = true, isDeployed = true })
    UIUtil.ShowTips("已上阵 " .. tostring(self._data and self._data.name or "英雄"))
end

--- ---------------------------------------------------------------
--- Tab
--- ---------------------------------------------------------------

function UIHeroDetailView:_CreateTabs()
    self.tabBtns = {}
    self.tabTexts = {}
    self.tabImages = {}
    for i, tabDef in ipairs(TABS) do
        local path = "Panel/TabBar/Tab_" .. i
        self.tabBtns[i]   = SafeAddComponent(self, UIButton, path)
        self.tabTexts[i]  = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtLabel")
        self.tabImages[i] = SafeAddComponent(self, UIImage, path)
        if self.tabTexts[i] then self.tabTexts[i]:SetText(tabDef.name) end
        if self.tabBtns[i] then
            local idx = i
            self.tabBtns[i]:SetOnClick(function() self:_SelectTab(idx) end)
        end
    end
end

function UIHeroDetailView:_SelectTab(index)
    if TABS[index] == nil then return end
    self.curTabIndex = index
    local data = self._data
    local isSkillTab = (index == 2)
    local isRankTab = (index == 3)

    for i, tabInfo in ipairs(TABS) do
        local panel = self.transform:Find(tabInfo.panelPath)
        local visible = (i == index)
        -- 未拥有：隐藏军衔Tab（截图只有属性/技能）
        if i == 3 and data ~= nil and not data.owned then
            visible = false
        end
        if panel ~= nil then
            panel.gameObject:SetActive(visible)
        end
        if self.tabBtns[i] ~= nil then
            local hideRankTab = (i == 3 and data ~= nil and not data.owned)
            self.tabBtns[i]:SetInteractable(not hideRankTab)
            -- 未拥有截图只有属性/技能两页签，军衔页签整颗隐藏
            self.tabBtns[i].gameObject:SetActive(not hideRankTab)
        end
        if self.tabTexts[i] ~= nil then
            self.tabTexts[i]:SetColor(visible and COLOR_WHITE or COLOR_TAB_TEXT_IDLE)
        end
        if self.tabImages[i] ~= nil then
            if visible then
                self.tabImages[i]:SetColor(ColorOf((self._theme and self._theme.accent) or {0.45, 0.65, 0.90, 1}))
            else
                self.tabImages[i]:SetColor(COLOR_TAB_IDLE)
            end
        end
    end

    -- 技能Tab：技能槽上浮到立绘两侧（对齐截图环绕布局）
    self:_LayoutSkillSlots(isSkillTab)
    self:_LayoutDetailPanels(isSkillTab, isRankTab)
    self:_LayoutBottomBar(index, data)

    -- 顶部：属性页=稀有度+舰船条；技能/军衔页=居中名号（对齐截图）
    self:_LayoutTopChrome(index, data)
    self:_LayoutReferencePage(index)
end

--- 按 914x1625 的逻辑画布统一排版，避免内容面板各自再叠加一次 -760 的偏移。
function UIHeroDetailView:_LayoutReferencePage(index)
    local p = self.transform:Find("Panel")
    if p == nil then return end
    local attr = index == 1
    for _, name in ipairs({"Panel_Attribute", "Panel_Skill", "Panel_Rank"}) do
        local tf = p:Find(name)
        local rt = tf:GetComponent(RectTransform)
        rt.anchorMin = Vector2(0,0) rt.anchorMax = Vector2(1,1)
        rt.offsetMin = Vector2(0,0) rt.offsetMax = Vector2(0,0)
        local img = tf:GetComponent(UnityImage)
        if img ~= nil then img.enabled = false end
    end
    -- 技能/军衔页的内容区需要完整露出人物、战力和信息卡，舞台不再盖到说明卡边缘。
    SetTopRect(self.heroStageViewport, 0, attr and -535 or -390, 900, attr and 920 or 690)
    local portrait = self.heroStageViewport:Find("HeroStagePortrait")
    -- 立绘尺寸必须小于舞台裁切区；否则手机刘海区会截掉头部，形成“只剩半个人”的错误画面。
    SetTopRect(portrait, -15, attr and -485 or -325, attr and 460 or 330, attr and 860 or 590)
    SetTopRect(p:Find("TxtPower"), 0, attr and -1025 or -735, 380, 54)
    SetTopRect(p:Find("ImgPowerCoin"), -110, attr and -1025 or -735, 42, 42)
    SetTopRect(p:Find("BtnInfo"), 145, attr and -1025 or -735, 44, 44)
    StyleText(p:Find("TxtPower"), 42, COLOR_POWER)
    SetTopRect(p:Find("BtnNavLeft"), -400, attr and -530 or -430, 56, 64)
    SetTopRect(p:Find("BtnNavRight"), 400, attr and -530 or -430, 56, 64)
    local nav = p:Find("BtnNavLeft") if nav ~= nil then nav.gameObject:SetActive(false) end
    SetTopRect(p:Find("Panel_Attribute/LevelBar"), 0, -1120, 730, 58)
    SetTopRect(p:Find("Panel_Attribute/StatsRow"), 0, -1210, 730, 125)
    SetTopRect(p:Find("Panel_Attribute/BtnUpgrade"), 35, -1405, 360, 104)
    SetTopRect(p:Find("Panel_Attribute/BtnBook"), -355, -1405, 82, 90)
    SetTextRect(p:Find("Panel_Attribute/TxtPreviewHint"), 0, -1325, 700, 40, TMPAlign.Center)
    SetTextRect(p:Find("Panel_Attribute/LevelBar/TxtLevel"), 0, -29, 700, 50, TMPAlign.Center)
    StyleText(p:Find("Panel_Attribute/LevelBar/TxtLevel"), 34, COLOR_WHITE)
    for i, key in ipairs({"Firepower","Durability","Armor","Troop"}) do
        local st = p:Find("Panel_Attribute/StatsRow/Stat" .. key)
        SetTopRect(st, -270 + (i-1)*180, -60, 175, 110)
        SetTextRect(st:Find("TxtName"), 0, -18, 175, 40, TMPAlign.Center)
        SetTextRect(st:Find("TxtValue"), 0, -65, 175, 42, TMPAlign.Center)
        StyleText(st:Find("TxtName"), 25, COLOR_STAT_LBL)
        StyleText(st:Find("TxtValue"), 34, COLOR_WHITE)
        local icon=st:Find("ImgIcon") if icon ~= nil then icon.gameObject:SetActive(false) end
    end
    SetTextRect(p:Find("Panel_Attribute/BtnUpgrade/TxtLabel"), 0, -30, 320, 44, TMPAlign.Center)
    SetTextRect(p:Find("Panel_Attribute/BtnUpgrade/TxtCost"), 0, -75, 300, 36, TMPAlign.Center)
    if self.costIcons.upgrade ~= nil then self.costIcons.upgrade:SetActive(false) end
    StyleText(self._tfHeroName, attr and 27 or 38, COLOR_WHITE)
    StyleText(self._tfHeroTitle, attr and 22 or 30, COLOR_WHITE)
    -- 属性页左上：专属战机小卡 + 稀有度 + 英雄名字，对应战前编队中的同一机型。
    local bar=p:Find("ShipInfoBar")
    if attr and bar ~= nil then
        DisableAutoLayout(bar)
        SetTopRect(bar,-138,-108,540,130)
        local bg=bar:GetComponent(UnityImage)
        if bg ~= nil then bg.enabled=false end
        local plane=bar:Find("ImgShip")
        local frame=EnsureImageChild(bar,"AircraftFrame",100,116,-214,0)
        local frameImg=frame:GetComponent(UnityImage)
        frameImg.color=ColorOf({.18,.39,.64,1})
        frameImg:LoadSprite("Assets/Main/Sprites/HeroUI/HeroUI_tab_round.png")
        frameImg.raycastTarget=false
        frame.transform:SetAsFirstSibling()
        SetTopRect(plane,-214,-58,90,100)
        local img=plane:GetComponent(UnityImage)
        if img ~= nil then img.preserveAspect=true img.raycastTarget=false end
        local rarity=p:Find("TxtRarity")
        SetTopRect(rarity,-170,-68,175,58)
        StyleText(rarity,42,COLOR_WHITE)
        SetTopRect(self._tfHeroName,170,-25,270,42)
        SetTopRect(self._tfHeroTitle,170,-66,270,38)
        if self.shipStarRow ~= nil then self.shipStarRow.gameObject:SetActive(false) end
        if self.shipRightCell ~= nil then self.shipRightCell:SetActive(false) end
    end
end


--- 参考图的底栏只负责导航：左侧独立返回，右侧等宽页签。
--- 本项目的出战操作保留，但移动到属性页的升级按钮右侧，只在属性页显示。
function UIHeroDetailView:_LayoutBottomBar(index, data)
    local tabBar = self.transform:Find("Panel/TabBar")
    if tabBar ~= nil then
        local layout = tabBar:GetComponent(typeof(CS.UnityEngine.UI.HorizontalLayoutGroup))
        if layout ~= nil then layout.enabled = false end
        local image = tabBar:GetComponent(UnityImage)
        if image ~= nil then image.enabled = false end
        local rt = tabBar:GetComponent(RectTransform)
        if rt ~= nil then
            -- 旧 prefab 的 TabBar 是 stretch + 负 sizeDelta，竖屏会被裁到屏幕外。
            -- 固定为右侧导航区域，与左侧独立返回键形成参考图的底栏结构。
            rt.anchorMin = Vector2(0.5, 0)
            rt.anchorMax = Vector2(0.5, 0)
            rt.pivot = Vector2(0.5, 0.5)
            rt.anchoredPosition = Vector2(66, 65)
            rt.sizeDelta = Vector2(750, 130)
        end
    end
    local visibleTabs = (data ~= nil and not data.owned) and 2 or 3
    for i, btn in ipairs(self.tabBtns or {}) do
        if btn ~= nil and btn.gameObject.activeSelf then
            local rt = btn.gameObject:GetComponent(RectTransform)
            if rt ~= nil then
                -- 固定中心坐标，不受旧 TabBar 的 stretch/负 sizeDelta 影响。
                -- TabBar 的局部原点在左侧，使用 0/1/2 的格位而非以中点为 0。
                local x = (visibleTabs == 2) and ((i == 1) and -186 or 186) or ((i - 2) * 248)
                rt.anchorMin = Vector2(0.5, 0.5)
                rt.anchorMax = Vector2(0.5, 0.5)
                rt.pivot = Vector2(0.5, 0.5)
                rt.anchoredPosition = Vector2(x, 0)
                rt.sizeDelta = Vector2((visibleTabs == 2) and 366 or 242, 122)
            end
            local bgTf = btn.transform:Find("TabBg")
            if bgTf == nil then
                local bgGo = GameObject("TabBg", RectTransform)
                bgGo.transform:SetParent(btn.transform, false)
                bgGo:AddComponent(UnityImage)
                bgTf = bgGo.transform
                bgTf:SetAsFirstSibling()
            end
            local bgRt = bgTf:GetComponent(RectTransform)
            if bgRt ~= nil then
                bgRt.anchorMin = Vector2(0, 0)
                bgRt.anchorMax = Vector2(1, 1)
                bgRt.offsetMin = Vector2(0, 0)
                bgRt.offsetMax = Vector2(0, 0)
            end
            local bgImg = bgTf:GetComponent(UnityImage)
            if bgImg ~= nil then
                bgImg.sprite = nil
                -- 选中页签不再使用接近内容卡的浅蓝色，改成深蓝主块 + 亮青强调线。
                -- 这样属性、技能、军衔的当前状态在任何页都一眼可分辨。
                bgImg.color = (i == index) and ColorOf({0.05,0.19,0.43,1}) or ColorOf({0.22,0.39,0.65,1})
            end
            local lineTf = btn.transform:Find("TabActiveLine")
            if lineTf == nil then
                local lineGo = GameObject("TabActiveLine", RectTransform)
                lineGo.transform:SetParent(btn.transform, false)
                lineGo:AddComponent(UnityImage)
                lineTf = lineGo.transform
                lineTf:SetSiblingIndex(1)
            end
            local lineRt = lineTf:GetComponent(RectTransform)
            if lineRt ~= nil then
                lineRt.anchorMin = Vector2(0, 1)
                lineRt.anchorMax = Vector2(1, 1)
                lineRt.pivot = Vector2(0.5, 1)
                lineRt.anchoredPosition = Vector2(0, -5)
                lineRt.sizeDelta = Vector2(-18, 9)
            end
            lineTf.gameObject:SetActive(i == index)
            local lineImg = lineTf:GetComponent(UnityImage)
            if lineImg ~= nil then lineImg.sprite = nil lineImg.color = ColorOf({0.28,0.90,1.00,1}) end
            local label = self.tabTexts and self.tabTexts[i] or nil
            if label ~= nil then
                local labelRt = label.transform:GetComponent(RectTransform)
                if labelRt ~= nil then
                    -- 标签节点原本锚在顶部；底栏按钮重排后必须以按钮中心为锚点。
                    labelRt.anchorMin = Vector2(0.5, 0.5)
                    labelRt.anchorMax = Vector2(0.5, 0.5)
                    labelRt.pivot = Vector2(0.5, 0.5)
                    labelRt.anchoredPosition = Vector2(0, 0)
                    labelRt.sizeDelta = Vector2(225, 100)
                end
                StyleText(label.transform, 38, COLOR_WHITE)
                local tmp = label.transform:GetComponent(typeof(CS.NewTMPText))
                if tmp ~= nil then
                    tmp.alignment = TMPAlign.Center
                    tmp.enableWordWrapping = false
                end
            end
        end
    end
    if self.btnBack ~= nil then
        local rt = self.btnBack.gameObject:GetComponent(RectTransform)
        if rt ~= nil then
            rt.anchorMin = Vector2(0, 0)
            rt.anchorMax = Vector2(0, 0)
            rt.pivot = Vector2(0.5, 0.5)
            rt.anchoredPosition = Vector2(65, 65)
            rt.sizeDelta = Vector2(100, 100)
        end
    end
    if self.btnDeploy ~= nil then self.btnDeploy.gameObject:SetActive(false) end
    if self.btnUpgrade ~= nil then
        local rt = self.btnUpgrade.gameObject:GetComponent(RectTransform)
        if rt ~= nil then
            rt.anchoredPosition = Vector2(40, -270)
            rt.sizeDelta = Vector2(360, 88)
        end
    end
end

--- 手机竖屏的内容卡排版：技能说明、军衔加成和成长行均保留一行扫读宽度。
function UIHeroDetailView:_LayoutDetailPanels(isSkillTab, isRankTab)
    if self.transform == nil then return end
    if isSkillTab then
        local detail = self.transform:Find("Panel/Panel_Skill/SkillDetail")
        local bonusList = self.transform:Find("Panel/Panel_Skill/SkillDetail/RankBonusList")
        local detailImg = detail ~= nil and detail:GetComponent(UnityImage) or nil
        if detailImg ~= nil then detailImg.sprite = nil detailImg.color = ColorOf({0.64,0.74,0.86,0.98}) end
        -- 与战力行留出视觉呼吸区，避免卡片标题压到战力数字。
        SetTopRect(detail, 0, -1075, 730, 500)
        SetTopRect(bonusList, 0, -365, 680, 245)
        DisableAutoLayout(bonusList)
        SetTextRect(self.transform:Find("Panel/Panel_Skill/SkillDetail/TxtSkillName"), -112, -35, 450, 48, TMPAlign.Left)
        SetTextRect(self.transform:Find("Panel/Panel_Skill/SkillDetail/TxtSkillCooldown"), 235, -35, 235, 48, TMPAlign.Right)
        local tagRow = self.transform:Find("Panel/Panel_Skill/SkillDetail/TagRow")
        SetTopRect(tagRow, -88, -90, 430, 36)
        SetTopRect(self.transform:Find("Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillTagBox"), -112, 0, 104, 32)
        SetTopRect(self.transform:Find("Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillDmgTypeBox"), 4, 0, 116, 32)
        SetTextRect(self.transform:Find("Panel/Panel_Skill/SkillDetail/TxtSkillDesc"), 0, -167, 670, 88, TMPAlign.Left)
        for i, cell in ipairs(self.rankRows or {}) do
            if cell.row ~= nil then
                SetTopRect(cell.row, 0, -22 - (i - 1) * 47, 670, 42)
                DisableAutoLayout(cell.row)
                local rowImg = cell.row:GetComponent(UnityImage)
                if rowImg ~= nil then rowImg.sprite = nil rowImg.color = ColorOf({0.80,0.88,0.96,0.42}) end
            end
            SetTextRect(cell.txtBonus and cell.txtBonus.transform, 28, -21, 610, 42, TMPAlign.Left)
            StyleText(cell.txtBonus and cell.txtBonus.transform, 25, COLOR_STAT_LBL)
            if self.rankRowStars and self.rankRowStars[i] ~= nil then
                SetTopRect(self.rankRowStars[i], -320, -21, 32, 32)
            end
        end
        SetTopRect(self.transform:Find("Panel/Panel_Skill/BtnGoPromote"), 0, -1410, 320, 100)
        for _,node in ipairs({"TxtSkillName","TxtSkillCooldown","TxtSkillDesc"}) do
            StyleText(detail:Find(node), node == "TxtSkillName" and 33 or 27, COLOR_STAT_LBL)
        end
        local descTmp = self.transform:Find("Panel/Panel_Skill/SkillDetail/TxtSkillDesc"):GetComponent(typeof(CS.NewTMPText))
        if descTmp ~= nil then descTmp.enableWordWrapping = true descTmp.maxVisibleLines = 2 end
    end

    if isRankTab then
        local starRow = self.transform:Find("Panel/Panel_Rank/StarRow")
        DisableAutoLayout(starRow)
        SetTopRect(starRow, 0, -795, 600, 70)
        for i, starNode in ipairs(self.stars or {}) do
            if starNode ~= nil then
                local slot = starNode.transform.parent
                SetTopRect(slot, -144 + (i - 1) * 72, -35, 42, 42)
                if starNode.transform ~= slot then SetTopRect(starNode.transform, 0, -21, 42, 42) end
            end
        end
        local growList = self.transform:Find("Panel/Panel_Rank/GrowList")
        DisableAutoLayout(growList)
        local growImg = growList ~= nil and growList:GetComponent(UnityImage) or nil
        if growImg ~= nil then growImg.sprite = nil growImg.color = ColorOf({0.64,0.74,0.86,0.98}) end
        SetTopRect(growList, 0, -995, 730, 290)
        for index, key in ipairs({ "Durability", "Firepower", "Armor" }) do
            local row = self.transform:Find("Panel/Panel_Rank/GrowList/GrowRow" .. key)
            DisableAutoLayout(row)
            SetTopRect(row, 0, -55 - (index - 1) * 85, 650, 64)
            local rowImg = row ~= nil and row:GetComponent(UnityImage) or nil
            if rowImg ~= nil then rowImg.sprite = nil rowImg.color = ColorOf({0.80,0.88,0.96,0.42}) end
            SetTextRect(row:Find("TxtName"), -200, -32, 180, 48, TMPAlign.Left)
            SetTextRect(row:Find("TxtCur"), -42, -32, 72, 48, TMPAlign.Right)
            SetTextRect(row:Find("TxtArrow"), 38, -32, 58, 48, TMPAlign.Center)
            SetTextRect(row:Find("TxtTarget"), 150, -32, 170, 48, TMPAlign.Left)
            StyleText(row:Find("TxtName"), 30, COLOR_STAT_LBL)
            StyleText(row:Find("TxtCur"), 32, ColorOf({0.70,0.28,0.06,1}))
            StyleText(row:Find("TxtArrow"), 32, ColorOf({0.06,0.40,0.26,1}))
            StyleText(row:Find("TxtTarget"), 32, ColorOf({0.06,0.40,0.26,1}))
        end
        local rankSkills = self.transform:Find("Panel/Panel_Rank/RankSkillSlots")
        DisableAutoLayout(rankSkills)
        SetTopRect(rankSkills, 0, -1240, 700, 110)
        for i, slot in ipairs(self.rankSkillSlots or {}) do
            SetTopRect(slot.root, (i - 2) * 220, -55, 110, 110)
        end
        SetTopRect(self.transform:Find("Panel/Panel_Rank/PromoteRow"), 0, -1375, 730, 100)
        local promoteRow = self.transform:Find("Panel/Panel_Rank/PromoteRow")
        DisableAutoLayout(promoteRow)
        if promoteRow ~= nil then
            for i = 1, 2 do
                local btn = promoteRow:Find("BtnPromote_" .. i)
                if btn ~= nil then
                    SetTopRect(btn, i == 1 and -185 or 185, -50, 330, 95)
                    local lab = btn:Find("TxtLabel")
                    SetTextRect(lab, 0, -28, 290, 42, TMPAlign.Center)
                    StyleText(lab, 27, COLOR_WHITE)
                end
            end
        end
    end
end

--- 属性页：左稀有度 + 右舰船条（船/星级/小格 + 名称称号）
--- 技能/军衔页：顶部居中「名字 / 称号」，隐藏舰船装饰
function UIHeroDetailView:_LayoutTopChrome(index, data)
    local isAttr = (index == 1)
    local panel = self.transform:Find("Panel")
    local bar = self.transform:Find("Panel/ShipInfoBar")

    if self._tfHeroName == nil then
        self._tfHeroName = self.transform:Find("Panel/ShipInfoBar/TxtHeroName")
            or self.transform:Find("Panel/TxtHeroName")
    end
    if self._tfHeroTitle == nil then
        self._tfHeroTitle = self.transform:Find("Panel/ShipInfoBar/TxtHeroTitle")
            or self.transform:Find("Panel/TxtHeroTitle")
    end
    local nameTf = self._tfHeroName
    local titleTf = self._tfHeroTitle

    local imgShip = self.transform:Find("Panel/ShipInfoBar/ImgShip")
    if self.txtRarity ~= nil then
        self.txtRarity.gameObject:SetActive(isAttr)
        if isAttr and data ~= nil then
            self.txtRarity:SetText(data.rarityName)
            self.txtRarity:SetColor(ColorOf(data.rarityColor))
        end
    end

    if imgShip ~= nil then imgShip.gameObject:SetActive(isAttr) end
    if self.shipStarRow ~= nil then self.shipStarRow.gameObject:SetActive(isAttr) end
    if self.shipRightCell ~= nil then self.shipRightCell.gameObject:SetActive(isAttr) end

    if isAttr then
        if bar ~= nil then bar.gameObject:SetActive(true) end
        if nameTf ~= nil and bar ~= nil then
            nameTf:SetParent(bar, false)
            local rt = nameTf:GetComponent(RectTransform)
            if rt ~= nil then
                rt.anchorMin = Vector2(0.5, 0.5)
                rt.anchorMax = Vector2(0.5, 0.5)
                rt.pivot = Vector2(0.5, 0.5)
                rt.sizeDelta = Vector2(220, 40)
                rt.anchoredPosition = Vector2(70, 14)
            end
            self:_SetTmpAlign(nameTf, TMPAlign.Left)
        end
        if titleTf ~= nil and bar ~= nil then
            titleTf:SetParent(bar, false)
            local rt = titleTf:GetComponent(RectTransform)
            if rt ~= nil then
                rt.anchorMin = Vector2(0.5, 0.5)
                rt.anchorMax = Vector2(0.5, 0.5)
                rt.pivot = Vector2(0.5, 0.5)
                rt.sizeDelta = Vector2(220, 32)
                rt.anchoredPosition = Vector2(70, -18)
            end
            self:_SetTmpAlign(titleTf, TMPAlign.Left)
        end
    else
        if bar ~= nil then bar.gameObject:SetActive(false) end
        if panel == nil then panel = self.transform:Find("Panel") end
        if nameTf ~= nil and panel ~= nil then
            nameTf:SetParent(panel, false)
            local rt = nameTf:GetComponent(RectTransform)
            if rt ~= nil then
                rt.anchorMin = Vector2(0.5, 1)
                rt.anchorMax = Vector2(0.5, 1)
                rt.pivot = Vector2(0.5, 0.5)
                rt.sizeDelta = Vector2(480, 46)
                rt.anchoredPosition = Vector2(0, -36)
            end
            self:_SetTmpAlign(nameTf, TMPAlign.Center)
            nameTf.gameObject:SetActive(true)
        end
        if titleTf ~= nil and panel ~= nil then
            titleTf:SetParent(panel, false)
            local rt = titleTf:GetComponent(RectTransform)
            if rt ~= nil then
                rt.anchorMin = Vector2(0.5, 1)
                rt.anchorMax = Vector2(0.5, 1)
                rt.pivot = Vector2(0.5, 0.5)
                rt.sizeDelta = Vector2(480, 34)
                rt.anchoredPosition = Vector2(0, -78)
            end
            self:_SetTmpAlign(titleTf, TMPAlign.Center)
            titleTf.gameObject:SetActive(true)
        end
    end

    self:_RefreshCostIcons(data, isAttr, index)
end

function UIHeroDetailView:_SetTmpAlign(tf, align)
    if tf == nil then return end
    local tmp = tf:GetComponent(typeof(CS.NewTMPText))
    if tmp ~= nil then
        tmp.alignment = align
    end
end

function UIHeroDetailView:_RefreshCostIcons(data, isAttr, tabIndex)
    if self.costIcons == nil then return end
    local showUpgrade = isAttr and data ~= nil and data.owned
        and data.upgradeCost ~= nil and data.upgradeCost ~= "" and data.upgradeCost ~= "-"
    local showPromote = (tabIndex == 3) and data ~= nil and data.owned
    if self.costIcons.upgrade ~= nil then
        self.costIcons.upgrade:SetActive(showUpgrade)
    end
    if self.costIcons.p1 ~= nil then
        self.costIcons.p1:SetActive(showPromote and data.promoteCost1 ~= nil and data.promoteCost1 ~= "-" and data.promoteCost1 ~= "")
    end
    if self.costIcons.p2 ~= nil then
        self.costIcons.p2:SetActive(showPromote and data.promoteCost2 ~= nil and data.promoteCost2 ~= "-" and data.promoteCost2 ~= "")
    end
end

--- 技能Tab时把 SkillIconRow 挪到立绘上半区两侧
function UIHeroDetailView:_LayoutSkillSlots(inSkillTab)
    local row = self.skillIconRow or self.transform:Find("Panel/Panel_Skill/SkillIconRow")
    if row == nil then return end
    self.skillIconRow = row
    if not inSkillTab then
        row.gameObject:SetActive(false)
        return
    end
    row.gameObject:SetActive(true)
    DisableAutoLayout(row)

    local panel = self.transform:Find("Panel")
    if panel ~= nil and row.parent ~= panel then
        row:SetParent(panel, false)
    end
    local rt = row:GetComponent(typeof(CS.UnityEngine.RectTransform))
    if rt ~= nil then
        rt.anchorMin = CS.UnityEngine.Vector2(0.5, 1)
        rt.anchorMax = CS.UnityEngine.Vector2(0.5, 1)
        rt.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
        rt.anchoredPosition = CS.UnityEngine.Vector2(0, -420)
        rt.sizeDelta = CS.UnityEngine.Vector2(940, 420)
    end

    for i, slot in pairs(self.skillSlots) do
        if slot.root ~= nil then
            local srt = slot.root:GetComponent(typeof(CS.UnityEngine.RectTransform))
            if srt ~= nil then
                srt.anchorMin = CS.UnityEngine.Vector2(0.5, 0.5)
                srt.anchorMax = CS.UnityEngine.Vector2(0.5, 0.5)
                srt.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
                local pos = SKILL_SLOT_LOCAL_POS[i] or SKILL_SLOT_LOCAL_POS[1]
                srt.anchoredPosition = CS.UnityEngine.Vector2(pos.x, pos.y)
                srt.sizeDelta = CS.UnityEngine.Vector2(110, 110)
            end
        end
    end
end

return UIHeroDetailView
