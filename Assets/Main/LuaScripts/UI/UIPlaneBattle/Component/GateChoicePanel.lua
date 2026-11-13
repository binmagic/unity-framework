--- LastWar 风格三选一奖励面板。
--- 这是局内临时选择，不写入养成数据；面板显示时由 View 暂停战斗推进。
local GateChoicePanel = {}
GateChoicePanel.__index = GateChoicePanel

local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Button = typeof(CS.UnityEngine.UI.Button)
local TMPText = typeof(CS.TMPro.TextMeshProUGUI)
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color
local RewardPreview = require "UI.UIPlaneBattle.Logic.GateRewardPreview"
local ART = "Assets/Main/Sprites/HeroUI/"

local function node(parent, name, position, size)
    local go = GameObject(name, RectTransform)
    go.transform:SetParent(parent, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchoredPosition, rt.sizeDelta = position, size
    return go, rt
end

function GateChoicePanel.New(parent, requestFont, onChoice, onSkip)
    local self = setmetatable({}, GateChoicePanel)
    self.onChoice, self.requestFont = onChoice, requestFont
    self.onSkip = onSkip
    local root, rootRt = node(parent, "GateChoicePanel", Vector2(0, 0), Vector2(0, 0))
    rootRt.anchorMin, rootRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    rootRt.offsetMin, rootRt.offsetMax = Vector2(0, 0), Vector2(0, 0)
    local shade = root:AddComponent(Image)
    shade.color, shade.raycastTarget = Color(0.01, 0.025, 0.06, 0.82), true
    self.go, self.cards = root, {}
    root:SetActive(false)

    local panel, panelRt = node(root.transform, "ChoiceWindow", Vector2(0, 80), Vector2(700, 550))
    local panelBg = panel:AddComponent(Image)
    panelBg.color, panelBg.raycastTarget = Color(0.035, 0.11, 0.19, 0.98), false
    panelBg:LoadSprite(ART .. "HeroUI_card_round.png")
    self.panelRt = panelRt

    local titleGo, titleRt = node(panel.transform, "Title", Vector2(0, 205), Vector2(660, 54))
    local title = titleGo:AddComponent(TMPText)
    title.text, title.fontSize = "战术补给 · 选择一项", 34
    title.alignment, title.color = CS.TMPro.TextAlignmentOptions.Center, Color(0.75, 0.95, 1, 1)
    title.raycastTarget = false
    requestFont(title)
    local hintGo = node(panel.transform, "Hint", Vector2(0, 160), Vector2(650, 36))
    local hint = hintGo:AddComponent(TMPText)
    hint.text, hint.fontSize = "战场已暂停 · 选择后获得0.6秒保护", 22
    hint.alignment, hint.color = CS.TMPro.TextAlignmentOptions.Center, Color(0.5, 0.72, 0.82, 1)
    hint.raycastTarget = false
    requestFont(hint)

    local positions = { -224, 0, 224 }
    for i = 1, 3 do
        local shadow = node(panel.transform, "CardShadow" .. i, Vector2(positions[i], -37), Vector2(202, 330))
        local shadowImage = shadow:AddComponent(Image)
        shadowImage.color, shadowImage.raycastTarget = Color(0, 0.01, 0.03, 0.65), false
        shadowImage:LoadSprite(ART .. "HeroUI_card_round.png")
        local card, cardRt = node(panel.transform, "RewardCard" .. i, Vector2(positions[i], -30), Vector2(202, 330))
        local bg = card:AddComponent(Image)
        bg.color, bg.raycastTarget = Color(0.06, 0.27, 0.39, 1), true
        bg:LoadSprite(ART .. "HeroUI_card_round.png")
        local stripe, stripeRt = node(card.transform, "Stripe", Vector2(0, 152), Vector2(176, 4))
        local stripeImg = stripe:AddComponent(Image)
        stripeImg.raycastTarget = false
        local iconGo = node(card.transform, "Icon", Vector2(0, 110), Vector2(64, 64))
        local icon = iconGo:AddComponent(Image)
        icon.raycastTarget, icon.preserveAspect = false, true
        local nameGo = node(card.transform, "Name", Vector2(0, 52), Vector2(184, 46))
        local name = nameGo:AddComponent(TMPText)
        name.fontSize, name.alignment, name.raycastTarget = 24, CS.TMPro.TextAlignmentOptions.Center, false
        name.enableAutoSizing, name.fontSizeMin, name.fontSizeMax = true, 21, 24
        name.color = Color(0.9, 0.98, 1, 1)
        requestFont(name)
        local rewardGo = node(card.transform, "Reward", Vector2(0, 0), Vector2(184, 48))
        local reward = rewardGo:AddComponent(TMPText)
        reward.fontSize, reward.alignment = 32, CS.TMPro.TextAlignmentOptions.Center
        reward.enableAutoSizing, reward.fontSizeMin, reward.fontSizeMax = true, 21, 32
        reward.fontStyle, reward.raycastTarget = CS.TMPro.FontStyles.Normal, false
        reward.color = Color(0.8, 1, 1, 1)
        requestFont(reward)
        local detailGo = node(card.transform, "Detail", Vector2(0, -70), Vector2(184, 82))
        local detail = detailGo:AddComponent(TMPText)
        detail.fontSize, detail.alignment = 18, CS.TMPro.TextAlignmentOptions.Center
        detail.enableWordWrapping, detail.raycastTarget = true, false
        detail.color = Color(0.78, 0.9, 0.95, 1)
        requestFont(detail)
        local chooseGo = node(card.transform, "Choose", Vector2(0, -137), Vector2(166, 46))
        local chooseBg = chooseGo:AddComponent(Image)
        chooseBg.color, chooseBg.raycastTarget = Color(0.08, 0.57, 0.72, 1), true
        chooseBg:LoadSprite(ART .. "HeroUI_tab_selected_round.png")
        local chooseTextGo = node(chooseGo.transform, "Text", Vector2(0, 0), Vector2(158, 42))
        local chooseText = chooseTextGo:AddComponent(TMPText)
        chooseText.text, chooseText.fontSize = "领 取", 23
        chooseText.alignment, chooseText.color = CS.TMPro.TextAlignmentOptions.Center, Color(1, 1, 1, 1)
        chooseText.raycastTarget = false
        requestFont(chooseText)
        local btn = chooseGo:AddComponent(Button)
        local index = i
        local function select() self:Choose(index) end
        btn.onClick:AddListener(select)
        local cardButton = card:AddComponent(Button)
        cardButton.onClick:AddListener(select)
        self.cards[i] = { bg = bg, stripe = stripeImg, icon = icon, name = name, reward = reward, detail = detail,
            button = btn, cardButton = cardButton, chooseText = chooseText, chooseBg = chooseBg }
    end
    local skipGo = node(panel.transform, "ContinueWithoutReward", Vector2(0, -235), Vector2(410, 44))
    local skipBg = skipGo:AddComponent(Image)
    skipBg.color = Color(0.12, 0.45, 0.56, 1)
    skipBg:LoadSprite(ART .. "HeroUI_tab_selected_round.png")
    local skipTextGo = node(skipGo.transform, "Text", Vector2(0, 0), Vector2(398, 42))
    local skipText = skipTextGo:AddComponent(TMPText)
    skipText.text, skipText.fontSize = "补给均无收益 · 继续作战", 22
    skipText.alignment, skipText.color, skipText.raycastTarget = CS.TMPro.TextAlignmentOptions.Center, Color(1, 1, 1, 1), false
    requestFont(skipText)
    skipGo:AddComponent(Button).onClick:AddListener(function() self:Skip() end)
    self.skipGo = skipGo
    root:SetActive(false)
    return self
end

function GateChoicePanel:Show(effectIds, effectTable, state)
    if effectIds == nil or #effectIds ~= 3 then return false end
    for _, id in ipairs(effectIds) do if effectTable[id] == nil then return false end end
    self.effects = { effectIds[1], effectIds[2], effectIds[3] }
    local colors = {
        Color(0.16, 0.72, 0.92, 1), Color(0.55, 0.38, 0.98, 1), Color(0.98, 0.58, 0.2, 1)
    }
    local available = 0
    for i = 1, 3 do
        local id = self.effects[i]
        local meta = effectTable[id]
        local c = colors[i]
        local card = self.cards[i]
        card.bg.color = Color(0.15 + c.r * 0.25, 0.19 + c.g * 0.22, 0.24 + c.b * 0.22, 1)
        card.stripe.color = c
        local preview = RewardPreview.Build(meta, state)
        card.preview = preview
        card.name.text, card.reward.text = preview.title, preview.value
        card.reward.color = preview.available and c or Color(0.67, 0.74, 0.8, 1)
        card.detail.text = preview.detail
        card.icon.color = Color(1, 1, 1, 1)
        card.icon:LoadSprite(ART .. preview.icon)
        card.chooseText.text = preview.button
        card.chooseBg.color = preview.available and Color(0.08, 0.57, 0.72, 1) or Color(0.24, 0.32, 0.4, 1)
        card.button.interactable, card.cardButton.interactable = preview.available, preview.available
        if preview.available then available = available + 1 end
    end
    self.canSkip = available == 0
    self.skipGo:SetActive(self.canSkip)
    self.active = true
    self.go.transform:SetAsLastSibling()
    self.go:SetActive(true)
    return true
end

function GateChoicePanel:Choose(index)
    if not self.active or self.resolving or self.effects == nil or self.effects[index] == nil then return false end
    if not self.cards[index].preview.available then return false end
    self.resolving = true
    local accepted = self.onChoice ~= nil and self.onChoice(self.effects[index]) == true
    self.resolving = false
    if accepted then self:Hide() end
    return accepted
end

function GateChoicePanel:Skip()
    if not self.active or self.resolving or not self.canSkip then return false end
    self.resolving = true
    local accepted = self.onSkip ~= nil and self.onSkip() == true
    self.resolving = false
    if accepted then self:Hide() end
    return accepted
end

function GateChoicePanel:Hide()
    self.active = false
    self.effects = nil
    if self.go ~= nil and not IsNull(self.go) then self.go:SetActive(false) end
end

function GateChoicePanel:Destroy()
    if self.go ~= nil and not IsNull(self.go) then self.go:Destroy() end
    self.go, self.cards, self.effects = nil, nil, nil
end

return GateChoicePanel
