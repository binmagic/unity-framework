---
--- 英雄图鉴列表 — View
--- 顶部：标题 + 返回；四阵营页签（全部/帝国/联邦/自由军）；卡片网格（色块代替真实立绘）
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

--- 卡片网格容器路径（ScrollRect/Viewport/Content，GridLayoutGroup 挂在 Content 上）
local CONTENT_PATH = "Panel/ScrollRect/Viewport/Content"
local CARD_PREFAB  = "Assets/Main/Prefabs/UI/UIHeroList/HeroCard.prefab"

local function ColorOf(rgba)
    return CS.UnityEngine.Color(rgba[1], rgba[2], rgba[3], rgba[4])
end

function UIHeroListView:OnCreate()
    base.OnCreate(self)

    self.cards = {}         -- index -> cell { go, btn, imgBg, imgFactionDot, txtName, txtRole, txtDeployed, heroId }
    self.pendingCards = {}
    self.cardCount = 0
    self.curFactionKey = nil  -- nil = "全部"

    self.btnBack = SafeAddComponent(self, UIButton, "Panel/BtnBack")
    if self.btnBack then self.btnBack:SetOnClick(function() self:CloseSelf() end) end

    self:_CreateTabs()
end

function UIHeroListView:OnEnable()
    base.OnEnable(self)
    self:_SelectFactionTab(1) -- 每次打开默认回到"全部"页签
end

function UIHeroListView:OnAddListener()
    base.OnAddListener(self)
    -- 从详情页"设为出战"回来时，本窗口没有被真正关闭过（详情页只是盖在上层），
    -- 不会重新走 OnEnable，所以出战角标的刷新必须靠事件驱动，不能只靠 OnEnable。
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
    for _, cell in pairs(self.cards) do
        if cell.go ~= nil and not IsNull(cell.go) then
            cell.go:Destroy()
        end
    end
    self.cards = {}
    self.pendingCards = {}
    self.tabBtns = nil
    base.OnDestroy(self)
end

--- ---------------------------------------------------------------
--- 阵营页签
--- ---------------------------------------------------------------

function UIHeroListView:_CreateTabs()
    self.tabBtns = {}
    self.tabTexts = {}
    for i, tabDef in ipairs(self.ctrl.FactionTabs) do
        local path = "Panel/TabBar/Tab_" .. tostring(i)
        local btn = SafeAddComponent(self, UIButton, path)
        local txt = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtLabel")
        if txt then txt:SetText(tabDef.name) end
        if btn then
            btn:SetOnClick(function() self:_SelectFactionTab(i) end)
        end
        self.tabBtns[i] = btn
        self.tabTexts[i] = txt
    end
end

function UIHeroListView:_SelectFactionTab(index)
    local tabDef = self.ctrl.FactionTabs[index]
    if tabDef == nil then return end
    self.curFactionKey = tabDef.key
    self.curTabIndex = index

    -- 选中态：简单用文字颜色区分（白=选中，灰=未选中），不需要额外美术
    for i, txt in ipairs(self.tabTexts) do
        if txt ~= nil then
            if i == index then
                txt:SetColor(CS.UnityEngine.Color(1, 1, 1, 1))
            else
                txt:SetColor(CS.UnityEngine.Color(0.6, 0.6, 0.65, 1))
            end
        end
    end

    self:_RefreshList()
end

--- ---------------------------------------------------------------
--- 卡片列表
--- ---------------------------------------------------------------

function UIHeroListView:_RefreshList()
    local list = self.ctrl:GetCardList(self.curFactionKey)
    self.curList = list
    self:_EnsureCards(#list)

    for i, data in ipairs(list) do
        self:_RefreshCard(i, data)
    end
end

--- 确保已实例化 count 个卡片（只增不减，多余的隐藏），异步加载
function UIHeroListView:_EnsureCards(count)
    local content = self.transform and self.transform:Find(CONTENT_PATH)
    if content == nil then return end

    for i = 1, count do
        if self.cards[i] == nil and not self.pendingCards[i] then
            self.pendingCards[i] = true
            self:_CreateCard(i)
        end
    end

    for i = count + 1, self.cardCount do
        local cell = self.cards[i]
        if cell ~= nil and cell.go ~= nil and not IsNull(cell.go) then
            cell.go:SetActive(false)
        end
    end
end

function UIHeroListView:_CreateCard(index)
    self:GameObjectInstantiateAsync(CARD_PREFAB, function(request)
        self.pendingCards[index] = nil

        if not request or request.isError or not request.gameObject then
            Logger.LogWarning("UIHeroListView 卡片加载失败 index=" .. tostring(index))
            return
        end

        local content = self.transform and self.transform:Find(CONTENT_PATH)
        if content == nil then
            request.gameObject:Destroy()
            return
        end

        local go = request.gameObject
        go.name = "HeroCard_" .. tostring(index)
        go.transform:SetParent(content, false)
        go.transform.localScale = CS.UnityEngine.Vector3.one
        go.transform:SetSiblingIndex(index - 1)

        local cell = {
            go            = go,
            btn           = SafeAddComponentByGo(self, UIButton, go),
            imgBg         = SafeAddComponentByGo(self, UIImage, go, "ImgBg"),
            imgPortrait   = SafeAddComponentByGo(self, UIImage, go, "ImgPortrait"),
            imgFactionDot = SafeAddComponentByGo(self, UIImage, go, "ImgFactionDot"),
            txtLevel      = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "Footer/TxtLevel"),
            txtStar       = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "Footer/TxtStar"),
            txtDeployed   = go.transform:Find("TxtDeployed"),
            redDot        = go.transform:Find("ImgRedDot"),
            lockMask      = go.transform:Find("LockMask"),
            txtShard      = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "LockMask/TxtShard"),
            repairBar     = go.transform:Find("RepairBar"),
            heroId        = nil,
        }
        self.cards[index] = cell
        if index > self.cardCount then
            self.cardCount = index
        end

        local data = self.curList and self.curList[index]
        if data ~= nil then
            self:_RefreshCard(index, data)
        end
    end)
end

function UIHeroListView:_RefreshCard(index, data)
    local cell = self.cards[index]
    if cell == nil or cell.go == nil or IsNull(cell.go) then return end

    cell.go:SetActive(true)
    cell.heroId = data.id

    -- 底板走稀有度色（对应截图的卡面稀有度边框），立绘位暂用阵营色块占位（等美术给图替换）
    if cell.imgBg ~= nil then cell.imgBg:SetColor(ColorOf(data.rarityColor)) end
    if cell.imgPortrait ~= nil then cell.imgPortrait:SetColor(ColorOf(data.factionColor)) end
    if cell.imgFactionDot ~= nil then cell.imgFactionDot:SetColor(ColorOf(data.factionColor)) end
    if cell.txtLevel ~= nil then cell.txtLevel:SetText(data.levelText) end
    if cell.txtStar ~= nil then cell.txtStar:SetText(data.starText) end
    if cell.txtDeployed ~= nil then cell.txtDeployed.gameObject:SetActive(data.isDeployed) end

    -- 未拥有态（暗色遮罩 + 碎片进度）/ 待修复警示条：本期配置表里的英雄默认全部已拥有，
    -- 这两块节点先保留在 prefab 里但不显示，等做残章收集/修复流程时直接接数据即可
    if cell.lockMask ~= nil then cell.lockMask.gameObject:SetActive(false) end
    if cell.repairBar ~= nil then cell.repairBar.gameObject:SetActive(false) end
    if cell.redDot ~= nil then cell.redDot.gameObject:SetActive(false) end

    if cell.btn ~= nil then
        cell.btn:SetOnClick(function()
            self.ctrl:OpenHeroDetail(cell.heroId)
        end)
    end
end

return UIHeroListView
