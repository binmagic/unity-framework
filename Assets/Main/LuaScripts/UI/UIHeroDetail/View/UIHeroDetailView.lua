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
local COLOR_POWER     = CS.UnityEngine.Color(0.95, 0.78, 0.25, 1)
local COLOR_TAB_IDLE  = CS.UnityEngine.Color(0.08, 0.14, 0.24, 1)
local COLOR_TAB_SEL   = CS.UnityEngine.Color(0.22, 0.40, 0.62, 1)
local COLOR_LOCKED    = CS.UnityEngine.Color(0.55, 0.55, 0.6, 1)
local COLOR_STAR_ON   = CS.UnityEngine.Color(1, 0.85, 0.3, 1)
local COLOR_STAR_OFF  = CS.UnityEngine.Color(0.35, 0.35, 0.4, 1)
local COLOR_GROW_CUR  = CS.UnityEngine.Color(0.95, 0.55, 0.25, 1)
local COLOR_GROW_TGT  = CS.UnityEngine.Color(0.35, 0.90, 0.45, 1)
local COLOR_TAG_BG    = CS.UnityEngine.Color(0.95, 0.72, 0.20, 1)
local COLOR_DMG_BG    = CS.UnityEngine.Color(0.72, 0.40, 0.90, 1)
local COLOR_PANEL_BG  = CS.UnityEngine.Color(0.10, 0.16, 0.28, 0.94)
local COLOR_PORTRAIT  = CS.UnityEngine.Color(0.14, 0.28, 0.48, 1)
local COLOR_LEVEL_BAR = CS.UnityEngine.Color(0.36, 0.52, 0.72, 1)
local COLOR_STATS_BG  = CS.UnityEngine.Color(0.55, 0.64, 0.76, 0.95)
local COLOR_STAT_LBL  = CS.UnityEngine.Color(0.20, 0.28, 0.40, 1)
local COLOR_STAT_VAL  = CS.UnityEngine.Color(0.08, 0.12, 0.20, 1)
local COLOR_SUB       = CS.UnityEngine.Color(0.65, 0.75, 0.88, 1)
local COLOR_SHIP_PLATE= CS.UnityEngine.Color(0.25, 0.40, 0.62, 1)
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
    [1] = { portrait = {0.12,0.22,0.32,1}, panel = {0.10,0.16,0.28,0.94}, accent = {0.45,0.75,0.50,1} },
    [2] = { portrait = {0.12,0.24,0.40,1}, panel = {0.10,0.16,0.28,0.94}, accent = {0.30,0.55,0.85,1} },
    [3] = { portrait = {0.14,0.28,0.48,1}, panel = {0.10,0.16,0.28,0.94}, accent = {0.45,0.40,0.85,1} },
    [4] = { portrait = {0.42,0.24,0.08,1}, panel = {0.28,0.16,0.06,0.94}, accent = {0.95,0.70,0.20,1} },
}

local TABS = {
    { name = "属性", panelPath = "Panel/Panel_Attribute" },
    { name = "技能", panelPath = "Panel/Panel_Skill" },
    { name = "军衔", panelPath = "Panel/Panel_Rank" },
}

local SKILL_SLOT_LOCAL_POS = {
    [1] = CS.UnityEngine.Vector3(-210, 250, 0),
    [2] = CS.UnityEngine.Vector3(210, 250, 0),
    [3] = CS.UnityEngine.Vector3(-230, 80, 0),
    [4] = CS.UnityEngine.Vector3(230, 80, 0),
}

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local UnityImage    = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2
local TMPAlign      = CS.TMPro.TextAlignmentOptions

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

    -- 出战按钮：截图详情页没有出战钮，但本项目需要；放在升级钮右侧，弱化视觉
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
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return end
    local ids = mgr:GetAllHeroIds()
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
    self:_SelectTab(self.curTabIndex or 1)
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
        if img ~= nil then img.color = ColorOf(theme.portrait) end
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

    -- 底栏页签：选中浅蓝、未选深色
    if self.tabImages ~= nil then
        for i, img in ipairs(self.tabImages) do
            if img ~= nil then
                img:SetColor((self.curTabIndex == i) and COLOR_TAB_SEL or COLOR_TAB_IDLE)
            end
        end
    end
end

function UIHeroDetailView:OnEnable()
    base.OnEnable(self)
    self:ApplyUserData()
end

function UIHeroDetailView:OnDestroy()
    self.heroId = nil
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
    self.heroId = self:GetUserData()
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
        local shipPath = SPR_SHIP
        if shipPath ~= nil and shipPath ~= "" then
            self.imgShip:LoadSprite(shipPath)
            self.imgShip:SetColor(COLOR_WHITE)
        else
            self.imgShip:SetColor(COLOR_SHIP_PLATE)
        end
    end
    self:_RefreshShipStars(data)
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
                starNode:SetColor(COLOR_WHITE)
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
            self.tabTexts[i]:SetColor(visible and COLOR_WHITE or COLOR_TAB_IDLE)
        end
        if self.tabImages[i] ~= nil then
            if visible then
                self.tabImages[i]:SetColor(COLOR_TAB_SEL)
            else
                self.tabImages[i]:SetColor(COLOR_TAB_IDLE)
            end
        end
    end

    -- 技能Tab：技能槽上浮到立绘两侧（对齐截图环绕布局）
    self:_LayoutSkillSlots(isSkillTab)

    -- 顶部：属性页=稀有度+舰船条；技能/军衔页=居中名号（对齐截图）
    self:_LayoutTopChrome(index, data)
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
