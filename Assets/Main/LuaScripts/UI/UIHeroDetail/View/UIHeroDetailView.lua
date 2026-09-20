---
--- 英雄详情 — View
--- 布局按隆隆冒险号截图复刻：
---   顶部：左上稀有度大字 + 右上舰船信息条（舰船图/英雄名/称号）+ 立绘大图（占上半屏）+ 战力行
---   中部：三Tab内容区（属性/技能/军衔），同一块区域切换显示
---   底部：Tab条贴屏幕底边横贯全宽；返回按钮左下，出战按钮右下
--- 技能/军衔只做展示，升级/提升军衔按钮点击弹"开发中"提示
--- （参照项目既有约定，见 UIShipCabinView.lua 的 ShowTips("...开发中") 系列）
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
local COLOR_TAB_IDLE  = CS.UnityEngine.Color(0.72, 0.76, 0.82, 1)
local COLOR_LOCKED    = CS.UnityEngine.Color(0.55, 0.55, 0.6, 1)
local COLOR_STAR_ON   = CS.UnityEngine.Color(1, 0.85, 0.3, 1)
local COLOR_STAR_OFF  = CS.UnityEngine.Color(0.35, 0.35, 0.4, 1)

--- 三个Tab：index 对应 TabBar/Tab_N，panelPath 是要切换显示的内容面板
local TABS = {
    { name = "属性", panelPath = "Panel/Panel_Attribute" },
    { name = "技能", panelPath = "Panel/Panel_Skill" },
    { name = "军衔", panelPath = "Panel/Panel_Rank" },
}

function UIHeroDetailView:OnCreate()
    base.OnCreate(self)

    -- 顶部：稀有度 / 舰船信息条 / 立绘 / 战力
    self.txtRarity     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/TxtRarity")
    self.txtHeroName   = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/ShipInfoBar/TxtHeroName")
    self.txtHeroTitle  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/ShipInfoBar/TxtHeroTitle")
    self.imgPortrait   = SafeAddComponent(self, UIImage,             "Panel/PortraitBg/ImgPortrait")
    self.txtPower      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/TxtPower")

    -- 属性Tab
    self.txtLevel      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/LevelBar/TxtLevel")
    self.txtFirepower  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatFirepower/TxtValue")
    self.txtDurability = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatDurability/TxtValue")
    self.txtArmor      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatArmor/TxtValue")
    self.txtTroop      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Attribute/StatsRow/StatTroop/TxtValue")
    self.btnUpgrade    = SafeAddComponent(self, UIButton,            "Panel/Panel_Attribute/BtnUpgrade")
    self.btnBook       = SafeAddComponent(self, UIButton,            "Panel/Panel_Attribute/BtnBook")
    self.previewHint   = self.transform:Find("Panel/Panel_Attribute/TxtPreviewHint")
    if self.btnUpgrade then
        self.btnUpgrade:SetOnClick(function() UIUtil.ShowTips("英雄升级开发中") end)
    end
    if self.btnBook then
        self.btnBook:SetOnClick(function() UIUtil.ShowTips("英雄图鉴开发中") end)
    end

    -- 技能Tab
    self.txtSkillName     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillName")
    self.txtSkillCooldown = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillCooldown")
    self.txtSkillTag      = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillTagBox/TxtSkillTag")
    self.txtSkillDmgType  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TagRow/TxtSkillDmgTypeBox/TxtSkillDmgType")
    self.txtSkillDesc     = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Skill/SkillDetail/TxtSkillDesc")
    self.btnGoPromote     = SafeAddComponent(self, UIButton,            "Panel/Panel_Skill/BtnGoPromote")
    if self.btnGoPromote then
        self.btnGoPromote:SetOnClick(function() UIUtil.ShowTips("技能提升开发中") end)
    end

    -- 技能Tab：5行军衔加成（在 SkillDetail/RankBonusList 下）
    self.rankRows = {}
    for i = 1, 5 do
        local rowPath = "Panel/Panel_Skill/SkillDetail/RankBonusList/RankRow_" .. i
        self.rankRows[i] = {
            row      = self.transform:Find(rowPath),
            txtStar  = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtStar"),
            txtBonus = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtBonus"),
        }
    end

    -- 军衔Tab：5颗大星
    self.stars = {}
    for i = 1, 5 do
        self.stars[i] = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/Panel_Rank/StarRow/Star_" .. i)
    end

    -- 军衔Tab：三行"当前 ≫ 目标"
    self.growRows = {}
    local growKeys = { "Durability", "Firepower", "Armor" }
    for _, key in ipairs(growKeys) do
        local rowPath = "Panel/Panel_Rank/GrowList/GrowRow" .. key
        self.growRows[key] = {
            txtCur    = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtCur"),
            txtTarget = SafeAddComponent(self, UITextMeshProUGUIEx, rowPath .. "/TxtTarget"),
        }
    end

    -- 军衔Tab：双提升按钮
    for i = 1, 2 do
        local btn = SafeAddComponent(self, UIButton, "Panel/Panel_Rank/PromoteRow/BtnPromote_" .. i)
        if btn then
            btn:SetOnClick(function() UIUtil.ShowTips("提升军衔开发中") end)
        end
    end

    -- 出战按钮（跨三个Tab常驻）
    self.btnDeploy     = SafeAddComponent(self, UIButton,            "Panel/BtnDeploy")
    self.txtBtnDeploy  = SafeAddComponent(self, UITextMeshProUGUIEx, "Panel/BtnDeploy/TxtLabel")
    if self.btnDeploy then
        self.btnDeploy:SetOnClick(function() self:_OnClickDeploy() end)
    end

    self.btnBack = SafeAddComponent(self, UIButton, "Panel/BtnBack")
    if self.btnBack then self.btnBack:SetOnClick(function() self:CloseSelf() end) end

    self:_CreateTabs()
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
    self.tabBtns = nil
    self.tabTexts = nil
    self.tabImages = nil
    base.OnDestroy(self)
end

--- 每次打开都重新读取（窗口可能被复用，不会重新走 OnCreate）
function UIHeroDetailView:ApplyUserData()
    self.heroId = self:GetUserData()
    self:_Refresh()
    self:_SelectTab(1) -- 每次打开默认回到"属性"Tab
end

function UIHeroDetailView:_Refresh()
    local data = self.ctrl:GetDetailData(self.heroId)
    if data == nil then
        Logger.LogError('#Hero# 详情页找不到英雄数据 heroId=' .. tostring(self.heroId))
        return
    end

    -- 顶部
    if self.txtRarity ~= nil then
        self.txtRarity:SetText(data.rarityName)
        self.txtRarity:SetColor(ColorOf(data.rarityColor))
    end
    if self.txtHeroName ~= nil then self.txtHeroName:SetText(data.name) end
    if self.txtHeroTitle ~= nil then self.txtHeroTitle:SetText(data.factionName .. " · " .. data.roleName) end
    if self.imgPortrait ~= nil then self.imgPortrait:SetColor(ColorOf(data.rarityColor)) end
    -- 战力：四维简单加总，作为展示值（真实战力公式等养成系统上线再定）
    if self.txtPower ~= nil then
        local power = (data.firepower or 0) + (data.durability or 0) + (data.armor or 0) + (data.troop or 0) * 10
        self.txtPower:SetText("战力 " .. tostring(power))
    end

    -- 属性Tab
    if self.txtLevel ~= nil then self.txtLevel:SetText(data.level .. "级") end
    if self.txtFirepower ~= nil then self.txtFirepower:SetText(tostring(data.firepower)) end
    if self.txtDurability ~= nil then self.txtDurability:SetText(tostring(data.durability)) end
    if self.txtArmor ~= nil then self.txtArmor:SetText(tostring(data.armor)) end
    if self.txtTroop ~= nil then self.txtTroop:SetText("+" .. tostring(data.troop)) end

    -- 技能Tab
    if self.txtSkillName ~= nil then
        self.txtSkillName:SetText(data.skillName .. "  " .. tostring(data.star) .. "/5级")
    end
    if self.txtSkillCooldown ~= nil then self.txtSkillCooldown:SetText("冷却 " .. tostring(data.skillCooldown) .. "秒") end
    if self.txtSkillTag ~= nil then self.txtSkillTag:SetText(data.skillTag) end
    if self.txtSkillDesc ~= nil then self.txtSkillDesc:SetText(data.skillDesc) end

    self:_RefreshRankRows()
    self:_RefreshRankTab(data)
    self:_RefreshDeployButton(data.isDeployed)
end

--- 技能Tab的5行军衔加成：已解锁正常显示，未解锁置灰加锁标记
function UIHeroDetailView:_RefreshRankRows()
    local list = self.ctrl:GetSkillRankBonusList(self.heroId)
    for i, cell in ipairs(self.rankRows) do
        local data = list[i]
        if data == nil then
            if cell.row ~= nil then cell.row.gameObject:SetActive(false) end
        else
            if cell.row ~= nil then cell.row.gameObject:SetActive(true) end
            -- 用 * 不用 ★：NotoSansSC-Bold SDF 源字体没有 ★ 字形会显示成方块
            if cell.txtStar ~= nil then cell.txtStar:SetText(data.starLevel .. "*") end
            if cell.txtBonus ~= nil then
                cell.txtBonus:SetText(data.bonusText)
                cell.txtBonus:SetColor(data.unlocked and COLOR_WHITE or COLOR_LOCKED)
            end
        end
    end
end

--- 军衔Tab：星级点亮 + 三行属性"当前 ≫ 下一级目标"
--- 目标值按当前值 +15% 估算（真实军衔成长表等养成系统上线再接）
function UIHeroDetailView:_RefreshRankTab(data)
    for i, star in ipairs(self.stars) do
        if star ~= nil then
            star:SetColor(i <= (data.star or 0) and COLOR_STAR_ON or COLOR_STAR_OFF)
        end
    end

    local growValues = {
        Durability = data.durability or 0,
        Firepower  = data.firepower or 0,
        Armor      = data.armor or 0,
    }
    for key, cell in pairs(self.growRows) do
        local cur = growValues[key] or 0
        local target = math.floor(cur * 1.15 + 0.5)
        if cell.txtCur ~= nil then cell.txtCur:SetText(tostring(cur)) end
        if cell.txtTarget ~= nil then cell.txtTarget:SetText(tostring(target)) end
    end
end

function UIHeroDetailView:_RefreshDeployButton(isDeployed)
    if self.btnDeploy == nil then return end

    self.btnDeploy:SetInteractable(not isDeployed)
    if self.txtBtnDeploy ~= nil then
        self.txtBtnDeploy:SetText(isDeployed and "出战中" or "设为出战")
    end
end

function UIHeroDetailView:_OnClickDeploy()
    local ok, errMsg = self.ctrl:SetDeployed(self.heroId)
    if not ok then
        Logger.LogError('#Hero# 设为出战失败 ' .. tostring(errMsg))
        return
    end
    self:_RefreshDeployButton(true)
end

--- ---------------------------------------------------------------
--- Tab切换（属性/技能/军衔）
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
        if self.tabBtns[i] then
            local idx = i
            self.tabBtns[i]:SetOnClick(function() self:_SelectTab(idx) end)
        end
    end
end

function UIHeroDetailView:_SelectTab(index)
    if TABS[index] == nil then return end
    self.curTabIndex = index

    for i, tabInfo in ipairs(TABS) do
        local panel = self.transform:Find(tabInfo.panelPath)
        if panel ~= nil then
            panel.gameObject:SetActive(i == index)
        end
        if self.tabTexts[i] ~= nil then
            self.tabTexts[i]:SetColor(i == index and COLOR_WHITE or COLOR_TAB_IDLE)
        end
        if self.tabImages[i] ~= nil then
            if i == index then
                self.tabImages[i]:SetColor(CS.UnityEngine.Color(0.20, 0.35, 0.55, 1))
            else
                self.tabImages[i]:SetColor(CS.UnityEngine.Color(0.10, 0.13, 0.20, 1))
            end
        end
    end
end

return UIHeroDetailView
