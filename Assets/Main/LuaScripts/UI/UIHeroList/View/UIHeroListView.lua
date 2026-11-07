---
--- 英雄图鉴列表 — View
--- 对齐截图：标题「英雄」+ 四页签 + 4列卡片（立绘/等级或碎片/星级/出战角标/未拥有遮罩）
---@class UIHeroListView : UIBaseView
---@field ctrl UIHeroListCtrl
local UIHeroListView = BaseClass("UIHeroListView", UIBaseView)
local base = UIBaseView

local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

local function SafeAddComponentByGo(self, componentType, go, subPath)
    if go == nil then return nil end
    local target = go
    if subPath ~= nil then
        local tf = go.transform:Find(subPath)
        if tf == nil then return nil end
        target = tf.gameObject
    end
    return self:AddComponent(componentType, target)
end

local CONTENT_PATH = "Panel/ScrollRect/Viewport/Content"
local CARD_PREFAB  = "Assets/Main/Prefabs/UI/UIHeroList/HeroCard.prefab"

local function ColorOf(rgba)
    return CS.UnityEngine.Color(rgba[1], rgba[2], rgba[3], rgba[4])
end

local COLOR_STAR_ON  = CS.UnityEngine.Color(1, 0.85, 0.3, 1)
local COLOR_STAR_OFF = CS.UnityEngine.Color(0.46, 0.56, 0.68, 1)
local COLOR_WHITE    = CS.UnityEngine.Color(1, 1, 1, 1)
local COLOR_GREY     = CS.UnityEngine.Color(0.72, 0.82, 0.93, 1)
local SPR_STAR_ON    = "Assets/Main/Sprites/HeroUI/HeroUI_star_on.png"
local SPR_STAR_OFF   = "Assets/Main/Sprites/HeroUI/HeroUI_star_off.png"
local SPR_CARD_BG    = "Assets/Main/Sprites/HeroUI/HeroUI_card_round.png"
local SPR_CARD_FRAME = "Assets/Main/Sprites/HeroUI/HeroUI_card_round_frame.png"
local SPR_CARD_FOOTER= "Assets/Main/Sprites/HeroUI/HeroUI_card_footer_round.png"
local SPR_TAB_IDLE   = "Assets/Main/Sprites/HeroUI/HeroUI_tab_round.png"
local SPR_TAB_ACTIVE = "Assets/Main/Sprites/HeroUI/HeroUI_tab_selected_round.png"
local SPR_RECRUIT_BUTTON = "Assets/Main/Sprites/HeroUI/HeroUI_recruit_button_round.png"
-- 1002 的旧卡图从嘴部开始，头部已被源图裁掉；列表使用完整立绘重新裁出的版本。
local CARD_ART_OVERRIDE = {
    [1002] = "Assets/Main/Sprites/Hero/Hero_card_1002_list.png",
}

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local UnityImage    = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

local function SetRect(rt, minX, minY, maxX, maxY, w, h, x, y, pivotX, pivotY)
    if rt == nil then return end
    rt.anchorMin = Vector2(minX, minY)
    rt.anchorMax = Vector2(maxX, maxY)
    rt.pivot = Vector2(pivotX or 0.5, pivotY or 0.5)
    rt.sizeDelta = Vector2(w or 0, h or 0)
    rt.anchoredPosition = Vector2(x or 0, y or 0)
end

--- 运行时补 Image 子节点（不新建 TMP）
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

function UIHeroListView:OnCreate()
    base.OnCreate(self)

    self.cards = {}
    self.pendingCards = {}
    self.pendingStamp = {}
    self._cardTemplate = nil
    self.cardCount = 0
    self.curFactionKey = nil
    self._lateRetryCount = 0
    self._lateScheduled = false

    self.txtTitle = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/TitleBar/TxtTitle")
    if self.txtTitle then self.txtTitle:SetText("英雄") end

    self.btnBack = SafeAddComponent(self, UIButton, "Panel/BtnBack")
    if self.btnBack then self.btnBack:SetOnClick(function() self:CloseSelf() end) end

    self:_ArrangeReferenceLayout()
    self:_CreateTabs()
    self:_FitGridLayout()
    -- 先取数据再绑卡/显示，避免克隆时 data 为空把卡全隐藏
    pcall(function()
        local mgr = DataCenter.HeroDataManager
        if mgr ~= nil and mgr.GetAllHeroIds ~= nil then mgr:GetAllHeroIds() end
    end)
    self:_SelectFactionTab(1)
    self:_EnsureCards(math.max(#(self.curList or {}), 18))
    if self.curList ~= nil then
        for i, data in ipairs(self.curList) do
            self:_RefreshCard(i, data)
        end
    end
    self:_ScheduleLateRefresh()
end

function UIHeroListView:OnEnable()
    base.OnEnable(self)
    self:_KeepBackButtonVisible()
    self._lateRetryCount = 0
    self._lateScheduled = false
    self:_FitGridLayout()
    self:_SelectFactionTab(self.curTabIndex or 1, true)
    self:_ScheduleLateRefresh()
end

--- 多级延迟重刷（只在 OnCreate/OnEnable 调度，禁止 _RefreshList 再入以免刷爆）
--- 首开配置/异步卡片可能晚到，用多档 DelayInvoke；self.DelayInvoke 优先
function UIHeroListView:_ScheduleLateRefresh()
    if self._closing then return end
    if self._lateScheduled then return end
    self._lateScheduled = true
    local delays = { 0.05, 0.15, 0.3, 0.6, 1.0 }
    for _, dt in ipairs(delays) do
        local function tick()
            if self._closing then return end
            if self.transform == nil or IsNull(self.transform) then return end
            if self.cards == nil then return end
            self:_FitGridLayout()
            self:_RefreshList(true)
        end
        if self.DelayInvoke ~= nil then
            self:DelayInvoke(tick, dt)
        else
            TimerManager:GetInstance():DelayInvoke(tick, dt)
        end
    end
end

--- 4列卡片必须完整落在视口内。
--- CanvasScaler 参考宽 750，ScrollRect 约 -20 内缩 → 按实际 viewport 宽度反算 cell。
function UIHeroListView:_FitGridLayout()
    local content = self.transform and self.transform:Find(CONTENT_PATH)
    if content == nil then return end
    local grid = content:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    if grid == nil then return end

    local viewportW = 0
    local viewport = self.transform:Find("Panel/ScrollRect/Viewport")
    if viewport ~= nil then
        local vrt = viewport:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if vrt ~= nil then
            -- 布局未跑完时 rect 可能是 0，用 rect 与 sizeDelta/父级估算兜底
            viewportW = vrt.rect.width
            if viewportW < 100 then
                local parent = vrt.parent
                if parent ~= nil then
                    local prt = parent:GetComponent(typeof(CS.UnityEngine.RectTransform))
                    if prt ~= nil then
                        viewportW = prt.rect.width
                        if viewportW < 100 then viewportW = prt.sizeDelta.x end
                    end
                end
            end
        end
    end
    if viewportW < 100 then viewportW = 720 end

    local padL, padR = 56, 56
    local padT, padB = 12, 14
    local spX, spY = 8, 10
    local cols = 4
    local cellW = math.floor((viewportW - padL - padR - spX * (cols - 1)) / cols)
    if cellW < 110 then cellW = 110 end
    local cellH = math.floor(cellW * 1.50)

    grid.cellSize = CS.UnityEngine.Vector2(cellW, cellH)
    grid.spacing = CS.UnityEngine.Vector2(spX, spY)
    grid.padding = CS.UnityEngine.RectOffset(padL, padR, padT, padB)
    grid.constraint = CS.UnityEngine.UI.GridLayoutGroup.Constraint.FixedColumnCount
    grid.constraintCount = cols
    grid.childAlignment = CS.UnityEngine.TextAnchor.UpperLeft
end

--- 对齐参考图的阅读节奏：紧凑标题/页签，卡片区紧贴页签，底部固定操作栏。
function UIHeroListView:_ArrangeReferenceLayout()
    local panel = self.transform and self.transform:Find("Panel")
    if panel == nil then return end

    local titleBar = panel:Find("TitleBar")
    if titleBar ~= nil then SetRect(titleBar:GetComponent(RectTransform), 0, 1, 1, 1, 0, 70, 0, 0, 0.5, 1) end
    local titleTf = panel:Find("TitleBar/TxtTitle")
    if titleTf ~= nil then
        local titleTmp = titleTf:GetComponent(typeof(CS.NewTMPText))
        if titleTmp ~= nil then titleTmp.fontSize = 30 end
    end

    local tabBar = panel:Find("TabBar")
    if tabBar ~= nil then
        SetRect(tabBar:GetComponent(RectTransform), 0, 1, 1, 1, 0, 64, 0, -70, 0.5, 1)
        local layout = tabBar:GetComponent(typeof(CS.UnityEngine.UI.HorizontalLayoutGroup))
        if layout ~= nil then
            layout.padding = CS.UnityEngine.RectOffset(72, 72, 6, 4)
            layout.spacing = 4
            layout.childAlignment = CS.UnityEngine.TextAnchor.MiddleCenter
        end
    end

    local scroll = panel:Find("ScrollRect")
    -- 让滚动区的顶部正好贴在页签下沿，底部避开固定操作栏。
    if scroll ~= nil then SetRect(scroll:GetComponent(RectTransform), 0, 0, 1, 1, -20, -250, 0, -13, 0.5, 0.5) end

    for i = 1, 4 do
        local tab = panel:Find("TabBar/Tab_" .. tostring(i))
        if tab ~= nil then
            local le = tab:GetComponent(typeof(CS.UnityEngine.UI.LayoutElement))
            if le ~= nil then
                le.preferredWidth = 142
                le.preferredHeight = 54
            end
            SetRect(tab:GetComponent(RectTransform), 0.5, 0.5, 0.5, 0.5, 142, 54, 0, 0)
            local icon = tab:Find("ImgIcon")
            if icon ~= nil then SetRect(icon:GetComponent(RectTransform), 0.5, 0.5, 0.5, 0.5, 34, 34, 0, 0) end
        end
    end

    local viewport = panel:Find("ScrollRect/Viewport")
    if viewport ~= nil then
        local viewImg = viewport:GetComponent(UnityImage)
        if viewImg ~= nil then viewImg.color = CS.UnityEngine.Color(0.72, 0.79, 0.89, 1) end
    end

    local scrollTf = panel:Find("ScrollRect")
    if scrollTf ~= nil then
        local backdropTf = scrollTf:Find("ListBackdrop")
        local backdrop
        if backdropTf ~= nil then
            backdrop = backdropTf.gameObject
        else
            backdrop = GameObject("ListBackdrop", RectTransform)
            backdrop.transform:SetParent(scrollTf, false)
            backdrop.transform:SetSiblingIndex(0)
            backdrop:AddComponent(UnityImage)
        end
        SetRect(backdrop:GetComponent(RectTransform), 0, 0, 1, 1, 0, 0, 0, 0)
        local backdropImg = backdrop:GetComponent(UnityImage)
        if backdropImg ~= nil then backdropImg.color = CS.UnityEngine.Color(0.68, 0.76, 0.87, 1) end
    end

    local footerTf = panel:Find("HeroListFooter")
    local footer
    if footerTf ~= nil then
        footer = footerTf.gameObject
    else
        footer = GameObject("HeroListFooter", RectTransform)
        footer.transform:SetParent(panel, false)
        footer:AddComponent(UnityImage)
    end
    local footerRt = footer:GetComponent(RectTransform)
    SetRect(footerRt, 0, 0, 1, 0, 0, 112, 0, 0, 0.5, 0)
    local footerImg = footer:GetComponent(UnityImage)
    if footerImg ~= nil then footerImg.color = CS.UnityEngine.Color(0.06, 0.18, 0.34, 1) end

    local recruit = EnsureImageChild(footer.transform, "BtnRecruit", 250, 82, 0, 0)
    if recruit ~= nil then
        local recruitImg = recruit:GetComponent(UnityImage)
        local recruitUi = self:AddComponent(UIImage, recruit)
        if recruitUi ~= nil then recruitUi:LoadSprite(SPR_RECRUIT_BUTTON) end
        if recruitImg ~= nil then recruitImg.color = COLOR_WHITE end
        local labelTf = recruit.transform:Find("TxtRecruit")
        local label
        if labelTf ~= nil then
            label = labelTf.gameObject
        else
            local titleTf = panel:Find("TitleBar/TxtTitle")
            if titleTf ~= nil then
                label = GameObject.Instantiate(titleTf.gameObject, recruit.transform)
                label.name = "TxtRecruit"
            end
        end
        if label ~= nil then
            -- 图片下方预留投影空间，文字对齐上层按钮面。
            SetRect(label:GetComponent(RectTransform), 0, 0, 1, 1, -16, -12, 0, 4)
            local tmp = label:GetComponent(typeof(CS.NewTMPText))
            if tmp ~= nil then
                tmp.text = "招募"
                tmp.fontSize = 32
                tmp.color = COLOR_WHITE
            end
        end
    end

    self:_KeepBackButtonVisible()
end

--- 固定底栏必须先排到最后，再将返回按钮置顶，避免移动底栏时反向盖住按钮。
function UIHeroListView:_KeepBackButtonVisible()
    local panel = self.transform and self.transform:Find("Panel")
    if panel == nil then return end
    local footer = panel:Find("HeroListFooter")
    if footer ~= nil then footer:SetAsLastSibling() end
    local backTf = panel:Find("BtnBack")
    if backTf ~= nil then
        backTf.gameObject:SetActive(true)
        SetRect(backTf:GetComponent(RectTransform), 0, 0, 0, 0, 92, 76, 24, 18, 0, 0)
        backTf:SetAsLastSibling()
        local image = backTf:GetComponent(UnityImage)
        if image ~= nil then
            image.enabled = true
            image.color = COLOR_WHITE
            image.raycastTarget = true
        end
    end
end

function UIHeroListView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.HeroDeployedChanged, self._OnHeroDeployedChanged)
end

function UIHeroListView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(EventId.HeroDeployedChanged, self._OnHeroDeployedChanged)
end

function UIHeroListView:_OnHeroDeployedChanged(heroId)
    self:_RefreshList()
end

function UIHeroListView:OnDestroy()
    self._closing = true
    for _, cell in pairs(self.cards or {}) do
        if cell.go ~= nil and not IsNull(cell.go) then
            cell.go:Destroy()
        end
    end
    self.cards = {}
    self.pendingCards = {}
    self.pendingStamp = {}
    self._cardTemplate = nil
    self.curList = nil
    self.tabBtns = nil
    base.OnDestroy(self)
end

function UIHeroListView:_CreateTabs()
    self.tabBtns = {}
    self.tabTexts = {}
    self.tabIcons = {}
    for i, tabDef in ipairs(self.ctrl.FactionTabs) do
        local path = "Panel/TabBar/Tab_" .. tostring(i)
        local btn = SafeAddComponent(self, UIButton, path)
        local txt = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtLabel")
        local tabTf = self.transform:Find(path)
        -- 参考图页签使用短文字更容易扫读；本项目保留四个阵营筛选。
        if txt then
            txt:SetText(tabDef.name)
            txt.gameObject:SetActive(true)
            local txtRt = txt.gameObject:GetComponent(RectTransform)
            SetRect(txtRt, 0, 0, 1, 1, 0, 0, 0, 0)
            local tmp = txt.gameObject:GetComponent(typeof(CS.NewTMPText))
            if tmp ~= nil then
                tmp.fontSize = 22
                tmp.alignment = CS.TMPro.TextAlignmentOptions.Center
            end
        end
        if i == 1 then
            -- 旧 prefab 中的星形图标会和“全部”叠在一起，图鉴页不使用它。
            local legacyIcon = tabTf and tabTf:Find("ImgIcon")
            if legacyIcon ~= nil then legacyIcon.gameObject:SetActive(false) end
            self.tabIcons[i] = nil
        else
            local iconGo = EnsureImageChild(tabTf, "ImgIcon", 30, 30, 0, 0)
            if iconGo ~= nil then iconGo:SetActive(false) end
            self.tabIcons[i] = iconGo
        end
        if btn then
            btn:SetOnClick(function() self:_SelectFactionTab(i) end)
        end
        self.tabBtns[i] = btn
        self.tabTexts[i] = txt
    end
end

function UIHeroListView:_SelectFactionTab(index, preserveScroll)
    local tabDef = self.ctrl and self.ctrl.FactionTabs and self.ctrl.FactionTabs[index]
    if tabDef == nil then return end
    self.curFactionKey = tabDef.key
    self.curTabIndex = index
    self._lateRetryCount = 0

    for i, txt in ipairs(self.tabTexts or {}) do
        if txt ~= nil and i == 1 then
            txt:SetColor(index == 1 and COLOR_WHITE or COLOR_GREY)
        end
        local imgPath = "Panel/TabBar/Tab_" .. tostring(i)
        local img = SafeAddComponent(self, UIImage, imgPath)
        if img ~= nil then
            if i == index then
                img:LoadSprite(SPR_TAB_ACTIVE)
                img:SetColor(CS.UnityEngine.Color(0.72, 0.82, 0.94, 1))
            else
                img:LoadSprite(SPR_TAB_IDLE)
                img:SetColor(CS.UnityEngine.Color(0.15, 0.25, 0.42, 1))
            end
        end
        local iconGo = self.tabIcons and self.tabIcons[i] or nil
        if iconGo ~= nil then
            local ui = self:AddComponent(UIImage, iconGo)
            if ui ~= nil then
                ui:SetColor(i == index and COLOR_WHITE or CS.UnityEngine.Color(0.56, 0.68, 0.82, 1))
            end
        end
        if txt ~= nil then
            txt:SetColor(i == index and CS.UnityEngine.Color(0.08, 0.17, 0.30, 1) or COLOR_GREY)
        end
    end

    -- 预热配置表，避免首刷 GetCardList 空
    pcall(function()
        local mgr = DataCenter.HeroDataManager
        if mgr ~= nil and mgr.GetAllHeroIds ~= nil then
            mgr:GetAllHeroIds()
        end
    end)
    self:_RefreshList()
    if not preserveScroll then
        local tf = self.transform:Find("Panel/ScrollRect")
        local scroll = tf and tf:GetComponent(typeof(CS.UnityEngine.UI.ScrollRect))
        if scroll ~= nil then scroll:StopMovement(); scroll.verticalNormalizedPosition = 1 end
    end
end

---@param fromLate boolean|nil 是否来自延迟重刷
function UIHeroListView:_RefreshList(fromLate)
    if self.ctrl == nil then return end
    -- 确保 faction 过滤键有效：首帧 nil=全部
    if self.curFactionKey == nil and self.curTabIndex == nil then
        self.curFactionKey = nil
    end
    local ok, list = pcall(function() return self.ctrl:GetCardList(self.curFactionKey) end)
    if not ok then list = {} end
    self.curList = list or {}
    local count = #self.curList
    if self._dbgLogged ~= true then
        self._dbgLogged = true
        Logger.Log("#HeroList# first refresh count=" .. tostring(count) .. " bound=" .. tostring(self.cardCount))
    end
    if count == 0 then
        -- 配置表可能还没就绪，直接再要一次全量
        ok, list = pcall(function() return self.ctrl:GetCardList(nil) end)
        if ok and list ~= nil and #list > 0 and self.curFactionKey == nil then
            self.curList = list
            count = #list
        end
    end
    self:_EnsureCards(math.max(count, 0))

    for i, data in ipairs(self.curList) do
        self:_RefreshCard(i, data)
    end
    -- 有数据时才隐藏多余预置卡；首刷空列表绝不清空（否则看起来像没英雄）
    if count > 0 then
        for i = count + 1, 18 do
            self:_RefreshCard(i, nil)
        end
    end

    local needRetry = (count == 0)
    if not needRetry then
        for i = 1, count do
            if self.cards == nil or self.cards[i] == nil then
                needRetry = true
                break
            end
        end
    end
    -- 不在这里 _ScheduleLateRefresh（会递归刷爆定时器）
    if needRetry and not fromLate then
        -- 仅轻量一次补刷
        if (self._lateRetryCount or 0) < 3 then
            self._lateRetryCount = (self._lateRetryCount or 0) + 1
            TimerManager:GetInstance():DelayInvoke(function()
                if self._closing or self.cards == nil then return end
                if self.transform == nil or IsNull(self.transform) then return end
                self:_RefreshList(true)
            end, 0.25)
        end
    end
end

function UIHeroListView:_EnsureCards(count)
    local content = self.transform and self.transform:Find(CONTENT_PATH)
    if content == nil then return end
    if self.cards == nil then self.cards = {} end

    -- prefab 里只有 CardTemplate：同步克隆，首开零异步
    local template = self._cardTemplate
    if template == nil or IsNull(template) then
        local tf = content:Find("CardTemplate")
        if tf == nil then tf = content:Find("HeroCard_1") end
        if tf ~= nil then
            self._cardTemplate = tf.gameObject
            template = self._cardTemplate
        end
    end

    for i = 1, count do
        if self.cards[i] == nil then
            local pre = content:Find("HeroCard_" .. i)
            if pre ~= nil then
                self:_BindCard(i, pre.gameObject)
            elseif template ~= nil and not IsNull(template) then
                self:_CloneCard(i, content)
            end
        end
    end

    for i = count + 1, self.cardCount do
        local cell = self.cards[i]
        if cell ~= nil and cell.go ~= nil and not IsNull(cell.go) then
            cell.go:SetActive(false)
        end
    end
end

function UIHeroListView:_BindCard(index, go)
    local cell = {
        go            = go,
        btn           = SafeAddComponentByGo(self, UIButton, go),
        imgBg         = SafeAddComponentByGo(self, UIImage, go, "ImgBg"),
        imgFrame      = SafeAddComponentByGo(self, UIImage, go, "ImgFrame"),
        imgPortrait   = SafeAddComponentByGo(self, UIImage, go, "ImgPortrait"),
        imgFactionDot = SafeAddComponentByGo(self, UIImage, go, "ImgFactionDot"),
        imgFooter     = SafeAddComponentByGo(self, UIImage, go, "Footer"),
        imgLockMask   = SafeAddComponentByGo(self, UIImage, go, "LockMask"),
        imgLevelIcon  = SafeAddComponentByGo(self, UIImage, go, "Footer/ImgLevelIcon"),
        txtLevel      = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "Footer/TxtLevel"),
        txtStar       = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "Footer/TxtStar"),
        txtDeployed   = go.transform:Find("TxtDeployed"),
        txtDeployedTmp= SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "TxtDeployed/TxtLabel"),
        redDot        = go.transform:Find("ImgRedDot"),
        lockMask      = go.transform:Find("LockMask"),
        txtShard      = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "LockMask/TxtShard"),
        repairBar     = go.transform:Find("RepairBar"),
        starRow       = go.transform:Find("Footer/StarRow"),
        stars         = {},
        heroId        = nil,
    }
    if cell.starRow ~= nil then
        for si = 1, 5 do
            local stf = cell.starRow:Find("Star_" .. si)
            if stf ~= nil then
                cell.stars[si] = SafeAddComponentByGo(self, UIImage, go, "Footer/StarRow/Star_" .. si)
            end
        end
    end
    if cell.txtDeployedTmp == nil then
        cell.txtDeployedTmp = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "TxtDeployed")
    end
    self.cards[index] = cell
    if index > self.cardCount then
        self.cardCount = index
    end
    return cell
end

function UIHeroListView:_CloneCard(index, content)
    local go = CS.UnityEngine.GameObject.Instantiate(self._cardTemplate, content)
    go.name = "HeroCard_" .. tostring(index)
    go.transform:SetSiblingIndex(index - 1)
    go.transform.localScale = CS.UnityEngine.Vector3.one
    self:_BindCard(index, go)
    local data = self.curList and self.curList[index]
    if data ~= nil then
        self:_RefreshCard(index, data)
    end
end

function UIHeroListView:_CreateCard(index)
    self:GameObjectInstantiateAsync(CARD_PREFAB, function(request)
        if self.pendingCards ~= nil then self.pendingCards[index] = nil end
        if self.pendingStamp ~= nil then self.pendingStamp[index] = nil end
        if self.cards == nil or self.transform == nil or IsNull(self.transform) then
            if request and request.gameObject then request.gameObject:Destroy() end
            return
        end

        if not request or request.isError or not request.gameObject then
            Logger.LogWarning("UIHeroListView 卡片加载失败 index=" .. tostring(index))
            return
        end

        local content = self.transform:Find(CONTENT_PATH)
        if content == nil then
            request.gameObject:Destroy()
            return
        end

        local go = request.gameObject
        go.name = "HeroCard_" .. tostring(index)
        go.transform:SetParent(content, false)
        go.transform.localScale = CS.UnityEngine.Vector3.one
        go.transform:SetSiblingIndex(index - 1)

        if self._cardTemplate == nil then
            self._cardTemplate = go
        end

        self:_BindCard(index, go)

        -- 同步补齐剩余卡片
        if self.curList ~= nil then
            local need = #self.curList
            for i = 1, need do
                if self.cards[i] == nil and self._cardTemplate ~= nil then
                    self:_CloneCard(i, content)
                end
            end
            for i, data in ipairs(self.curList) do
                self:_RefreshCard(i, data)
            end
        end
    end)
end

function UIHeroListView:_RefreshCard(index, data)
    local cell = self.cards[index]
    if cell == nil or cell.go == nil or IsNull(cell.go) then return end
    if data == nil then
        cell.go:SetActive(false)
        return
    end

    cell.go:SetActive(true)
    cell.heroId = data.id

    if cell.imgBg ~= nil then
        local r = tonumber(data.rarity) or 1
        local frame = COLOR_GREY
        if r == 4 then frame = CS.UnityEngine.Color(0.96, 0.76, 0.24, 1)
        elseif r == 3 then frame = CS.UnityEngine.Color(0.68, 0.48, 0.92, 1)
        elseif r == 2 then frame = CS.UnityEngine.Color(0.38, 0.64, 0.94, 1)
        elseif r == 1 then frame = CS.UnityEngine.Color(0.38, 0.72, 0.52, 1)
        end
        cell.imgBg:LoadSprite(SPR_CARD_BG)
        -- 稀有度只做柔和底色，避免高饱和直角色块抢走立绘注意力。
        cell.imgBg:SetColor(CS.UnityEngine.Color(frame.r * 0.82, frame.g * 0.82, frame.b * 0.82, 1))
    end
    if cell.imgFrame ~= nil then
        cell.imgFrame:LoadSprite(SPR_CARD_FRAME)
        cell.imgFrame:SetColor(CS.UnityEngine.Color(0.77, 0.86, 0.97, 0.38))
    end
    if cell.imgFooter ~= nil then
        cell.imgFooter:LoadSprite(SPR_CARD_FOOTER)
        cell.imgFooter:SetColor(CS.UnityEngine.Color(0.07, 0.17, 0.30, 0.90))
    end
    if cell.imgPortrait ~= nil then
        local cardPath = CARD_ART_OVERRIDE[data.id] or data.card
        if cardPath ~= nil and cardPath ~= "" then
            cell.imgPortrait:LoadSprite(cardPath)
            cell.imgPortrait:SetColor(COLOR_WHITE)
        else
            cell.imgPortrait:SetColor(ColorOf(data.factionColor))
        end
    end
    if cell.imgFactionDot ~= nil then
        if data.factionIcon ~= nil and data.factionIcon ~= "" then
            cell.imgFactionDot:LoadSprite(data.factionIcon)
            cell.imgFactionDot:SetColor(COLOR_WHITE)
        else
            cell.imgFactionDot:SetColor(ColorOf(data.factionColor))
        end
    end
    if cell.imgLevelIcon ~= nil then
        if data.roleIcon ~= nil and data.roleIcon ~= "" then
            cell.imgLevelIcon:LoadSprite(data.roleIcon)
            cell.imgLevelIcon:SetColor(COLOR_WHITE)
        end
    end
    if cell.txtLevel ~= nil then
        -- 对齐参考游戏的图鉴卡：列表只保留等级/碎片等扫读信息，姓名放在详情页展示。
        cell.txtLevel:SetText(data.levelText or "")
        cell.txtLevel:SetColor(data.owned and COLOR_WHITE or COLOR_GREY)
    end
    if cell.txtStar ~= nil then
        cell.txtStar:SetText("")
    end
    if cell.stars ~= nil then
        local filled = tonumber(data.starNum) or 0
        if not data.owned then filled = 0 end
        for si = 1, 5 do
            local img = cell.stars[si]
            if img ~= nil then
                local path = (si <= filled) and SPR_STAR_ON or SPR_STAR_OFF
                img:LoadSprite(path)
                img:SetColor(COLOR_WHITE)
            end
        end
    end
    -- 图鉴页面不显示“出战中”：阵容状态在编队/战斗入口表达，避免遮挡立绘。
    if cell.txtDeployed ~= nil then cell.txtDeployed.gameObject:SetActive(false) end

    -- 未拥有：保留立绘可读性，只叠加轻量锁定遮罩 + 碎片进度
    if cell.lockMask ~= nil then
        cell.lockMask.gameObject:SetActive(not data.owned)
    end
    if cell.imgLockMask ~= nil then
        cell.imgLockMask:LoadSprite(SPR_CARD_BG)
    end
    -- 参考图只在卡片底栏保留一行碎片进度，立绘中央不再重复显示。
    if cell.txtShard ~= nil then cell.txtShard.gameObject:SetActive(false) end
    if cell.repairBar ~= nil then
        local showRepair = data.needRepair == true
        cell.repairBar.gameObject:SetActive(showRepair)
        if showRepair then
            local lbl = cell.repairBar:Find("TxtLabel")
            if lbl ~= nil then
                local tmp = lbl:GetComponent(typeof(CS.NewTMPText))
                if tmp ~= nil then tmp.text = "待修复" end
            end
        end
    end
    -- 红点需要真实的可领取/可操作条件，不能把“已拥有但未出战”当作通知。
    if cell.redDot ~= nil then cell.redDot.gameObject:SetActive(false) end

    if cell.btn ~= nil then
        cell.btn:SetOnClick(function()
            self.ctrl:OpenHeroDetail(cell.heroId, self.curList)
        end)
    end
end

return UIHeroListView
