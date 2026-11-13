---
--- 探险玩法 战斗 — 数字门
--- 参考 barrel（D:\UnityProject\barrel）UpgradeableDuetGate 的设计思路：一对门左右各自独立，
--- 主机穿过哪一侧的 x 范围，就执行哪一侧配置的触发效果。换算成 2D：门是横排的一条 Image，
--- 从上往下移动，主机与门同一 Y 高度时按动态分隔线选边。
---
--- 三种门（kind）：
---   add      青蓝补给门，text 形如 "+2"
---   subtract 橙红危险门，text 形如 "-1"
---   lock     锁定门（阈值门），横跨全屏（不分左右），text 是纯数字阈值（如 "6"），
---            不接 TriggerEventManager，命中时由 View 直接比较当前兵力与阈值
---
---@class GateComponent
local GateComponent = {}
GateComponent.__index = GateComponent

local GameObject     = CS.UnityEngine.GameObject
local RectTransform  = typeof(CS.UnityEngine.RectTransform)
local Image          = typeof(CS.UnityEngine.UI.Image)
local Text           = typeof(CS.UnityEngine.UI.Text)
local Outline        = typeof(CS.UnityEngine.UI.Outline)
local Vector2        = CS.UnityEngine.Vector2
local Color          = CS.UnityEngine.Color
local EffectTable    = require("Game.STG.Trigger.StgTriggerEnum").EffectTable
local ICONS = {
    reinforcement = "Assets/Main/Sprites/STG/SpaceRaid/wingman_orange.png",
    weapon = "Assets/Main/Sprites/HeroUI/HeroUI_stat_fire.png",
    repair = "Assets/Main/Sprites/HeroUI/HeroUI_stat_armor.png",
    gold = "Assets/Main/Sprites/PlaneBattle/PlaneBattle_gold.png",
}

--- 保留原有尺寸与触发宽度，纯 UI 框架表现不改变门的玩法判定。
local GATE_VISUAL = {
    add      = { size = Vector2(140, 140), color = Color(0.25, 0.86, 1, 0.9) },
    subtract = { size = Vector2(150, 84), color = Color(1, 0.36, 0.23, 0.9) },
    lock     = { size = Vector2(500, 112), color = Color(1, 0.72, 0.22, 0.9) },
}

local FALL_SPEED     = 200 -- 像素/秒，向下移动速度，和 PlaneUnit 敌机保持一致节奏
local TRIGGER_HALF_H = 40  -- 与主机同高判定的容差（|gateY - playerY| < 此值即触发）

--- @param x number 出生点横坐标（anchoredPosition.x）
--- @param y number 出生点纵坐标
--- @param text string 门上显示的文本：add/subtract 是算式如 "+2"/"-1"，lock 是阈值数字如 "6"
--- @param triggerMeta table|nil 关联的 PlaneTrigger_Config 行数据，lock 门不使用，传 nil
--- @param kind string|nil "add"|"subtract"|"lock"，不传时按 text 有无 "-" 自动判定 add/subtract
function GateComponent.New(parentTransform, x, y, text, triggerMeta, kind)
    local self = setmetatable({}, GateComponent)
    self.triggerMeta = triggerMeta
    self.hasTriggered = false
    self.spawnX, self.moveAge = x, 0

    local isNegative = string.find(text or "", "-") ~= nil
    self.kind = kind or (isNegative and "subtract" or "add")
    self.threshold = self.kind == "lock" and tonumber(text) or nil

    local visual = GATE_VISUAL[self.kind] or GATE_VISUAL.add
    self.sizeX = visual.size.x

    local go = GameObject("Gate", RectTransform)
    go.transform:SetParent(parentTransform, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)
    rt.sizeDelta = visual.size
    rt.anchoredPosition = Vector2(x, y)

    local img = go:AddComponent(Image)
    img.color = Color(0.015, 0.07, 0.12, 0.62)
    img.raycastTarget = false
    -- 四条独立边框形成透空的能量门，避免木箱遮住飞机。
    self.frameImages = {}
    for i = 1, 4 do
        local edge = GameObject("Frame", RectTransform)
        edge.transform:SetParent(go.transform, false)
        local edgeRt = edge:GetComponent(RectTransform)
        if i <= 2 then
            local x = i - 1
            edgeRt.anchorMin = Vector2(x, 0)
            edgeRt.anchorMax = Vector2(x, 1)
            edgeRt.pivot = Vector2(x, 0.5)
            edgeRt.sizeDelta = Vector2(4, 0)
        else
            local y = i - 3
            edgeRt.anchorMin = Vector2(0, y)
            edgeRt.anchorMax = Vector2(1, y)
            edgeRt.pivot = Vector2(0.5, y)
            edgeRt.sizeDelta = Vector2(0, 2)
        end
        edgeRt.anchoredPosition = Vector2(0, 0)
        local edgeImg = edge:AddComponent(Image)
        edgeImg.color = visual.color
        edgeImg.raycastTarget = false
        table.insert(self.frameImages, edgeImg)
    end

    local txtGo = GameObject("Text", RectTransform)
    txtGo.transform:SetParent(go.transform, false)
    local txtRt = txtGo:GetComponent(RectTransform)
    txtRt.anchorMin = Vector2(0, 0)
    txtRt.anchorMax = Vector2(1, 1)
    txtRt.offsetMin = Vector2(0, 0)
    txtRt.offsetMax = Vector2(0, 0)
    local txt = txtGo:AddComponent(Text)
    txt.font      = CS.UnityEngine.Resources.GetBuiltinResource(typeof(CS.UnityEngine.Font), "LegacyRuntime.ttf")
    txt.text      = text or ""
    txt.fontSize  = 36
    txt.fontStyle = CS.UnityEngine.FontStyle.Bold
    txt.alignment = CS.UnityEngine.TextAnchor.MiddleCenter
    txt.color     = visual.color
    txt.raycastTarget = false

    -- 换真实美术后底图不再是纯色块，白字直接叠上去容易被贴图花纹吃掉，补黑色描边保证可读性
    local outline = txtGo:AddComponent(Outline)
    outline.effectColor = Color(0, 0, 0, 1)
    outline.effectDistance = Vector2(2, -2)

    self.go = go
    self.rt = rt
    self.legacyText = txt

    return self
end

--- 旧表阈值门：明确展示判定对象和后果，不让裸数字大框覆盖编队。
function GateComponent:ConfigureThresholdGate(requestFont, wingmanCount)
    self.legacyText.enabled = false
    local function label(name, y, height, fontSize)
        local go = GameObject(name, RectTransform)
        go.transform:SetParent(self.go.transform, false)
        local rt = go:GetComponent(RectTransform)
        rt.anchoredPosition, rt.sizeDelta = Vector2(0, y), Vector2(480, height)
        local text = go:AddComponent(typeof(CS.TMPro.TextMeshProUGUI))
        text.fontSize, text.fontStyle = fontSize, CS.TMPro.FontStyles.Normal
        text.alignment, text.raycastTarget = CS.TMPro.TextAlignmentOptions.Center, false
        text.enableWordWrapping = false
        requestFont(text)
        return text
    end
    local title = label("ThresholdTitle", 37, 24, 18)
    title.text, title.color = "编队数量检查", Color(0.85, 0.92, 1, 1)
    self.thresholdCountText = label("ThresholdCount", 6, 40, 30)
    self.thresholdHintText = label("ThresholdHint", -34, 24, 18)
    self:RefreshThresholdDisplay(wingmanCount)
end

function GateComponent:RefreshThresholdDisplay(wingmanCount)
    if self.thresholdCountText == nil or self.thresholdDisplayCount == wingmanCount then return end
    self.thresholdDisplayCount = wingmanCount
    local count, required = tonumber(wingmanCount) or 0, self.threshold or 0
    local enough = count >= required
    local color = enough and Color(0.35, 1, 0.65, 1) or Color(1, 0.72, 0.3, 1)
    self.thresholdCountText.text = string.format("僚机 %d / %d", count, required)
    self.thresholdCountText.color = color
    self.thresholdHintText.text = enough and "数量达标 · 可安全通过" or "数量不足 · 穿过将判负"
    self.thresholdHintText.color = color
    for _, image in ipairs(self.frameImages) do image.color = color end
end

--- STG 门面显示实际奖励，计数与升档进度分开，左右双选门各自独立。
function GateComponent:ConfigureStg(requestFont)
    self.legacyText.enabled = false
    local duet = self.stgGate.gateType == "gate_duet"
    self.sizeX = duet and 520 or 200
    self.rt.sizeDelta = Vector2(self.sizeX, 132)
    self.cards = {}
    local function label(parent, y, size, fontSize)
        local go = GameObject("GateLabel", RectTransform)
        go.transform:SetParent(parent, false)
        local rt = go:GetComponent(RectTransform)
        rt.anchoredPosition = Vector2(0, y)
        rt.sizeDelta = size
        local text = go:AddComponent(typeof(CS.TMPro.TextMeshProUGUI))
        text.alignment = CS.TMPro.TextAlignmentOptions.Center
        text.fontSize = fontSize
        text.fontStyle = CS.TMPro.FontStyles.Normal
        text.enableAutoSizing = true
        text.fontSizeMin = math.max(9, fontSize * 0.45)
        text.fontSizeMax = fontSize
        text.enableWordWrapping = false
        text.raycastTarget = false
        requestFont(text)
        return text
    end
    for i = 1, duet and 2 or 1 do
        local go = GameObject("GateChoice", RectTransform)
        go.transform:SetParent(self.go.transform, false)
        local rt = go:GetComponent(RectTransform)
        local width = duet and 252 or 192
        rt.sizeDelta = Vector2(width, 124)
        rt.anchoredPosition = Vector2(duet and (i == 1 and -130 or 130) or 0, 0)
        local bg = go:AddComponent(Image)
        bg.raycastTarget = false
        local flashGo = GameObject("HitFlash", RectTransform)
        flashGo.transform:SetParent(go.transform, false)
        local flashRt = flashGo:GetComponent(RectTransform)
        flashRt.anchorMin, flashRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
        flashRt.offsetMin, flashRt.offsetMax = Vector2(0, 0), Vector2(0, 0)
        local flash = flashGo:AddComponent(Image)
        flash.color, flash.raycastTarget = Color(1, 1, 1, 0), false
        local title = label(go.transform, 44, Vector2(width - 12, 24), 16)
        local reward = label(go.transform, 6, Vector2(width - 12, 54), 42)
        reward.outlineWidth = 0.08
        reward.outlineColor = Color(0.015, 0.05, 0.1, 1)
        local progress = label(go.transform, -35, Vector2(width - 16, 24), 14)
        local iconGo = GameObject("RewardIcon", RectTransform)
        iconGo.transform:SetParent(go.transform, false)
        local iconRt = iconGo:GetComponent(RectTransform)
        iconRt.anchoredPosition = Vector2(-width / 2 + 25, 42)
        iconRt.sizeDelta = Vector2(28, 28)
        local icon = iconGo:AddComponent(Image)
        icon.preserveAspect, icon.raycastTarget = true, false
        title.rectTransform.anchoredPosition = Vector2(17, 44)
        title.rectTransform.sizeDelta = Vector2(width - 58, 24)
        local notice = label(go.transform, 82, Vector2(width, 30), 22)
        notice.text = ""
        local rails, posts, rims = {}, {}, {}
        for side = -1, 1, 2 do
            local post = GameObject("GatePost", RectTransform)
            post.transform:SetParent(go.transform, false)
            local pr = post:GetComponent(RectTransform)
            pr.anchoredPosition, pr.sizeDelta = Vector2(side * (width / 2 - 4), 0), Vector2(7, 136)
            local pi = post:AddComponent(Image)
            pi.raycastTarget, pi.color = false, Color(0.64, 0.77, 0.86, 1)
            table.insert(posts, pr)
            local rim = GameObject("EnergyRim", RectTransform)
            rim.transform:SetParent(go.transform, false)
            local rr = rim:GetComponent(RectTransform)
            rr.anchoredPosition, rr.sizeDelta = Vector2(0, side * 60), Vector2(width - 12, 3)
            local ri = rim:AddComponent(Image); ri.raycastTarget = false
            table.insert(rails, ri)
            table.insert(rims, rr)
        end
        local track = GameObject("ChargeTrack", RectTransform)
        track.transform:SetParent(go.transform, false)
        local tr = track:GetComponent(RectTransform)
        tr.sizeDelta = Vector2(width - 20, 4)
        tr.anchoredPosition = Vector2(0, -52)
        local ti = track:AddComponent(Image)
        ti.color, ti.raycastTarget = Color(0.04, 0.1, 0.14, 1), false
        local fill = GameObject("ChargeFill", RectTransform)
        fill.transform:SetParent(track.transform, false)
        local fr = fill:GetComponent(RectTransform)
        fr.anchorMin, fr.anchorMax, fr.pivot = Vector2(0, 0.5), Vector2(0, 0.5), Vector2(0, 0.5)
        fr.anchoredPosition, fr.sizeDelta = Vector2(0, 0), Vector2(0, 4)
        local fi = fill:AddComponent(Image)
        fi.raycastTarget = false
        table.insert(self.cards, { rt = rt, bg = bg, title = title, reward = reward, progress = progress,
            icon = icon, iconRt = iconRt, flash = flash, notice = notice,
            rails = rails, posts = posts, rims = rims, trackRt = tr,
            fillRt = fr, fillImg = fi, width = width - 20 })
    end
    if duet then
        local separator = GameObject("GateSeparator", RectTransform)
        separator.transform:SetParent(self.go.transform, false)
        self.separatorRt = separator:GetComponent(RectTransform)
        self.separatorRt.sizeDelta = Vector2(5, 144)
        local separatorImage = separator:AddComponent(Image)
        separatorImage.color, separatorImage.raycastTarget = Color(0.85, 0.95, 1, 1), false
        for _, img in ipairs(self.frameImages) do img.color = Color(0.64, 0.77, 0.86, 1) end
    end
    self:RefreshStgLayout()
    self:RefreshStgDisplay()
end

--- 宽度只取逻辑层的占比；不拉伸文字，窄侧自动缩字号保持完整。
function GateComponent:RefreshStgLayout()
    if self.stgGate.gateType ~= "gate_duet" then return end
    local leftWidth = self.sizeX * self.stgGate.leftRatio
    for i, card in ipairs(self.cards) do
        local sideWidth = i == 1 and leftWidth or self.sizeX - leftWidth
        local width = sideWidth - 8
        card.rt.sizeDelta = Vector2(width, 124)
        card.rt.anchoredPosition = Vector2(i == 1 and (-self.sizeX / 2 + sideWidth / 2)
            or (self.sizeX / 2 - sideWidth / 2), 0)
        card.width = width - 20
        local showIcon = width >= 150
        card.icon.gameObject:SetActive(showIcon)
        card.iconRt.anchoredPosition = Vector2(-width / 2 + 25, 42)
        card.title.rectTransform.anchoredPosition = Vector2(showIcon and 17 or 0, 44)
        card.title.rectTransform.sizeDelta = Vector2(width - (showIcon and 58 or 12), 24)
        card.reward.rectTransform.sizeDelta = Vector2(width - 12, 54)
        card.progress.rectTransform.sizeDelta = Vector2(width - 16, 24)
        card.notice.rectTransform.sizeDelta = Vector2(width, 30)
        for j, post in ipairs(card.posts) do
            post.anchoredPosition = Vector2((j == 1 and -1 or 1) * (width / 2 - 4), 0)
        end
        for _, rim in ipairs(card.rims) do rim.sizeDelta = Vector2(width - 12, 3) end
        card.trackRt.sizeDelta = Vector2(card.width, 4)
    end
    self.separatorRt.anchoredPosition = Vector2(self.stgGate:GetSeparatorX(self.sizeX), 0)
end

function GateComponent:IsLeftAt(worldX)
    local gateX = self:GetLocalPos()
    if self.stgGate ~= nil and self.stgGate.gateType == "gate_duet" then
        return self.stgGate:IsLeftAt(worldX - gateX, self.sizeX)
    end
    return worldX <= gateX
end

--- 左/右效果允许为空，必须显式选侧，不能用 and/or 回退到另一侧。
function GateComponent:GetStgSideState(isLeft)
    local g = self.stgGate
    local value, effectId = g.value, g.effectId
    if g.gateType == "gate_duet" then
        if isLeft then value, effectId = g.leftValue, g.leftEffectId
        else value, effectId = g.rightValue, g.rightEffectId end
    elseif g.gateType == "gate_step" then
        value = g.accumulatedDamage
    end
    local meta = EffectTable[effectId]
    local negative = (g.gateType == "gate_duet" and value < 0) or (meta ~= nil and meta.type == 20)
    return { value = value, effectId = effectId, negative = negative }
end

function GateComponent:RefreshStgDisplay()
    local g = self.stgGate
    local locked = g.IsUnlocked ~= nil and not g:IsUnlocked()
    local duet = g.gateType == "gate_duet"
    local step = g.gateType == "gate_step"
    for i, card in ipairs(self.cards) do
        -- 三选一门没有射击充能；隐藏整条进度，避免默认 RectTransform 的色块遮住奖励。
        local choice = g.IsChoiceGate ~= nil and g:IsChoiceGate()
        card.trackRt.gameObject:SetActive(not choice)
        card.fillRt.sizeDelta = Vector2(0, 4)
        local value = step and g.accumulatedDamage or (duet and (i == 1 and g.leftValue or g.rightValue) or g.value)
        local effectId = g.effectId
        if duet then
            effectId = g.rightEffectId
            if i == 1 then effectId = g.leftEffectId end
        end
        local meta = EffectTable[effectId]
        if locked then
            card.bg.color = Color(0.08, 0.12, 0.2, 0.9)
            card.reward.text = "锁定"
            card.reward.color = Color(0.65, 0.78, 0.95, 1)
            card.title.text = g.unlockMode == "bucket_damage" and "目标伤害解锁" or "击破敌机解锁"
            card.title.color = Color(0.8, 0.9, 1, 1)
            local progress, required = g:GetUnlockProgress()
            card.progress.text = string.format("%s %.0f / %.0f", g.unlockMode == "bucket_damage" and "伤害" or "击破", progress, required)
            card.progress.color = Color(0.55, 0.72, 0.9, 1)
            card.fillRt.sizeDelta = Vector2(card.width * math.max(0, math.min(1, progress / math.max(1, required))), 4)
            card.icon.gameObject:SetActive(not duet or card.width >= 130)
            local path = "Assets/Main/Sprites/HeroUI/HeroUI_lock.png"
            if card.iconPath ~= path then card.icon:LoadSprite(path); card.iconPath = path end
            card.icon.color = Color(0.75, 0.85, 1, 1)
            card.accent = Color(0.45, 0.7, 1, 1)
            card.fillImg.color = card.accent
            for _, rail in ipairs(card.rails or {}) do rail.color = card.accent end
            for _, img in ipairs(self.frameImages) do img.color = card.accent end
            goto continue_card
        end
        if g.IsHeroChargeGate ~= nil and g:IsHeroChargeGate() then
            card.bg.color = Color(0.16, 0.08, 0.3, 0.92)
            card.reward.text = string.format("充能 +%.0f%%", tonumber(g.trapConfig.heroChargePercent) or 0)
            card.reward.color = Color(0.85, 0.72, 1, 1)
            card.title.text = "英雄技能充能"
            card.title.color = Color(0.9, 0.85, 1, 1)
            card.progress.text = self.chargeTargetName or "通过后减少技能冷却"
            card.progress.color = Color(0.75, 0.66, 1, 1)
            card.icon.gameObject:SetActive(true)
            local skillPath = self.chargeIconPath
            if skillPath == nil or skillPath == "" then skillPath = "Assets/Main/Sprites/HeroUI/HeroUI_skill_burst.png" end
            if card.iconPath ~= skillPath then card.icon:LoadSprite(skillPath); card.iconPath = skillPath end
            card.icon.color = Color(1, 1, 1, 1)
            card.accent = Color(0.8, 0.65, 1, 1)
            card.fillImg.color = card.accent
            card.fillRt.sizeDelta = Vector2(card.width * g.trapConfig.heroChargePercent / 100, 4)
            for _, rail in ipairs(card.rails or {}) do rail.color = card.accent end
            for _, img in ipairs(self.frameImages) do img.color = card.accent end
            goto continue_card
        end
        if g.IsChoiceGate ~= nil and g:IsChoiceGate() then
            card.bg.color = Color(0.08, 0.24, 0.42, 0.95)
            card.reward.text = "三选一"
            card.reward.color = Color(0.55, 0.88, 1, 1)
            card.title.text = "战术补给"
            card.title.color = Color(0.75, 0.92, 1, 1)
            card.progress.text = "穿门后暂停战场"
            card.progress.color = Color(0.55, 0.8, 1, 1)
            card.icon.gameObject:SetActive(true)
            local choicePath = "Assets/Main/Sprites/HeroUI/HeroUI_skill_burst.png"
            if card.iconPath ~= choicePath then card.icon:LoadSprite(choicePath); card.iconPath = choicePath end
            card.icon.color = Color(0.55, 0.88, 1, 1)
            card.accent = Color(0.35, 0.78, 1, 1)
            card.fillImg.color = card.accent
            for _, rail in ipairs(card.rails or {}) do rail.color = card.accent end
            for _, img in ipairs(self.frameImages) do img.color = card.accent end
            goto continue_card
        end
        local narrow = duet and card.width < 120
        card.icon.gameObject:SetActive(not duet or card.width >= 130)
        local negative = (duet and value < 0) or (meta ~= nil and meta.type == 20)
        local repair = not negative and meta ~= nil and meta.type == 60
        local route = not negative and meta ~= nil and meta.type == 100 and meta.para
        local weapon = not negative and meta ~= nil and (meta.type == 50 or meta.type == 90 or (route and route ~= "mass"))
        local c = negative and Color(1, 0.4, 0.25, 1) or Color(0.3, 0.9, 1, 1)
        if repair then c = Color(0.35, 1, 0.6, 1) elseif weapon then c = Color(0.65, 0.65, 1, 1) end
        card.bg.color = negative and Color(0.65, 0.12, 0.10, 0.73) or Color(0.02, 0.46, 0.65, 0.66)
        if repair then card.bg.color = Color(0.015, 0.18, 0.08, 0.9) elseif weapon then card.bg.color = Color(0.08, 0.055, 0.23, 0.9) end
        card.reward.text = duet and value < 0 and string.format("%+d", value) or (meta and meta.text or "+0")
        if repair then card.reward.text = "装甲 +" .. tostring(meta.count or meta.para or 1) end
        if narrow then
            if repair then card.reward.text = "+" .. tostring(meta.count or meta.para or 1)
            elseif weapon then card.reward.text = "升级" end
        end
        card.reward.color, card.fillImg.color = c, c
        local path = repair and ICONS.repair or (weapon and ICONS.weapon or (meta and meta.type == 30 and ICONS.gold or ICONS.reinforcement))
        if card.iconPath ~= path then card.icon:LoadSprite(path); card.iconPath = path end
        card.icon.color = negative and Color(1, 0.55, 0.4, 1) or Color(1, 1, 1, 1)
        card.accent = c
        for _, rail in ipairs(card.rails or {}) do rail.color = c end
        if not duet then
            for _, img in ipairs(self.frameImages) do img.color = c end
        end
        card.title.text = negative and (narrow and "射击转正" or "危险 · 射击转正") or (duet and (i == 1 and "左路增援" or "右路增援") or (step and "火力充能" or "射击改造"))
        if repair then card.title.text = "生存补给" elseif weapon then card.title.text = "弹道强化" end
        card.title.color = Color(0.8, 0.9, 0.95, 1)
        card.progress.color = c
        local entries = duet and (i == 1 and g.trapConfig.paraEntries or g.trapConfig.paraEntriesRight) or g.trapConfig.paraEntries
        local nextEntry, current = nil, math.min(0, g.trapConfig.initialValue or 0)
        for _, entry in ipairs(entries or {}) do
            local threshold = step and entry.threshold or entry.min
            if threshold > value then nextEntry = threshold; break end
            current = math.max(current, threshold)
        end
        local ratio = 1
        if nextEntry ~= nil then
            ratio = math.max(0, math.min(1, (value - current) / math.max(1, nextEntry - current)))
            card.progress.text = string.format("%s %d %s升档", step and "再打" or "再中", math.ceil(nextEntry - value), step and "伤害" or "次")
        else
            card.progress.text = duet and (narrow and "穿门领取" or "通过此侧领取") or "已达最高档"
        end
        if route then
            card.title.text = route == "mass" and "编队路线" or (route == "pierce" and "穿透路线" or "追踪路线")
            card.reward.text = route == "mass" and "编队 ×2" or (route == "pierce" and "穿透弹" or "追踪弹")
            card.progress.text = "后续：" .. (route == "mass" and "密集集群" or (route == "pierce" and "重装纵列" or "高速机动"))
        end
        card.fillRt.sizeDelta = Vector2(card.width * ratio, 4)
        ::continue_card::
    end
end

function GateComponent:ShowUnlocked()
    for _, card in ipairs(self.cards or {}) do
        card.pulse, card.pulseDuration = 0.36, 0.36
        card.notice.text = "目标达成 · 已解锁"
        card.noticeColor = Color(0.4, 1, 0.7, 1)
        card.notice.color, card.noticeAge = card.noticeColor, 0
    end
end

--- 子弹与移动门使用相对线段检测，高速子弹也不会穿过薄门。
function GateComponent:TryHitBullet(bullet)
    if self.hasTriggered or self.stgGate == nil then return false end
    if not self.stgGate:IsUnlocked() or self.stgGate:IsHeroChargeGate() or self.stgGate:IsChoiceGate() then return false end
    local gx, gy = self:GetLocalPos()
    local p = bullet.rt.anchoredPosition
    local ax, ay = (bullet.previousX or p.x) - (self.previousX or gx), (bullet.previousY or p.y) - (self.previousY or gy)
    local bx, by = p.x - gx, p.y - gy
    local low, high = 0, 1
    local function clip(a, b, extent)
        local delta = b - a
        if math.abs(delta) < 0.001 then return math.abs(a) <= extent end
        local t1, t2 = (-extent - a) / delta, (extent - a) / delta
        if t1 > t2 then t1, t2 = t2, t1 end
        low, high = math.max(low, t1), math.min(high, t2)
        return low <= high
    end
    if not clip(ax, bx, self.sizeX / 2) or not clip(ay, by, 62) then return false end
    local hitX = ax + (bx - ax) * low
    local isLeft = self:IsLeftAt(gx + hitX)
    local before = self:GetStgSideState(isLeft)
    local accepted = self.stgGate:OnHit(bullet.damage, isLeft)
    if accepted ~= false then
        self:RefreshStgLayout()
        self:RefreshStgDisplay()
        local index = self.stgGate.gateType == "gate_duet" and (isLeft and 1 or 2) or 1
        local after = self:GetStgSideState(isLeft)
        local turnedPositive = before.negative and not after.negative
        local upgraded = before.effectId ~= after.effectId and after.effectId ~= nil and after.effectId ~= ""
        local card = self.cards[index]
        card.pulse = (upgraded or turnedPositive) and 0.36 or 0.16
        card.pulseDuration = card.pulse
        card.reward.fontSizeMax = (upgraded or turnedPositive) and 52 or 47
        if upgraded or turnedPositive then
            card.notice.text = turnedPositive and "危险解除" or "奖励升档"
            card.noticeColor = turnedPositive and Color(0.4, 1, 0.7, 1) or Color(1, 0.9, 0.4, 1)
            card.notice.color = card.noticeColor
            card.noticeAge = 0
        end
        if self.onHitFeedback then self.onHitFeedback(self, index, turnedPositive and "positive" or (upgraded and "upgrade" or "hit")) end
    end
    -- 冷却中的命中也拦截子弹，不让它穿门命中后方敌人。
    return true
end

function GateComponent:GetLocalPos()
    if self.rt == nil or IsNull(self.rt) then
        return 0, 0
    end
    local pos = self.rt.anchoredPosition
    return pos.x, pos.y
end

function GateComponent:Update(dt)
    if self.rt == nil or IsNull(self.rt) then
        return
    end
    if self.stgGate ~= nil then self.stgGate:Update(dt) end
    local pos = self.rt.anchoredPosition
    self.previousX, self.previousY = pos.x, pos.y
    local cfg = self.stgGate and self.stgGate.trapConfig
    local x = pos.x
    if cfg and cfg.moveMode == "horizontal_sine" then
        self.moveAge = self.moveAge + dt
        local amplitude = math.min(cfg.moveAmplitude or 0, math.max(0, 350 - self.sizeX / 2 - math.abs(self.spawnX)))
        x = self.spawnX + math.sin(self.moveAge * (cfg.moveFrequency or 0.8) * math.pi * 2) * amplitude
    end
    self.rt.anchoredPosition = Vector2(x, pos.y - FALL_SPEED * dt)
    for _, card in ipairs(self.cards or {}) do
        if card.pulse ~= nil then
            card.pulse = math.max(0, card.pulse - dt)
            local ratio = card.pulse / card.pulseDuration
            card.reward.fontSizeMax = 42 + (card.pulseDuration > 0.2 and 10 or 5) * ratio
            card.flash.color = Color(card.accent.r, card.accent.g, card.accent.b, 0.24 * ratio)
            if card.pulse == 0 then card.pulse = nil end
        end
        if card.noticeAge ~= nil then
            card.noticeAge = card.noticeAge + dt
            local c = card.noticeColor
            card.notice.color = Color(c.r, c.g, c.b, math.max(0, math.min(1, (0.85 - card.noticeAge) / 0.25)))
            card.notice.rectTransform.anchoredPosition = Vector2(0, 82 + 16 * math.min(1, card.noticeAge / 0.85))
            if card.noticeAge >= 0.85 then card.noticeAge = nil; card.notice.text = "" end
        end
    end
end

--- 检查是否与主机同高、且主机 x 落在本门范围内；命中后只触发一次
--- 门只有半个屏幕宽（除了 lock 门吃满全屏，语义上是"整条通道"的阈值判定，不分左右），
--- 必须主机飞到这一侧才算穿过这一扇门——这是"蓝门加/红门减"选边玩法的核心判定，
--- 不能只看 y 不看 x；但 lock 门不参与选边，命中只看 y。
--- @return boolean 本帧是否命中（命中后调用方应执行 context 效果）
function GateComponent:CheckTrigger(playerX, playerY)
    if self.hasTriggered or self.rt == nil or IsNull(self.rt) then
        return false
    end
    local gateX, gateY = self:GetLocalPos()
    local inX = self.kind == "lock" or math.abs(playerX - gateX) < self.sizeX / 2
    local previousY = self.previousY or gateY
    local crossed = previousY >= playerY and gateY <= playerY
    if (math.abs(gateY - playerY) < TRIGGER_HALF_H or crossed) and inX then
        self.hasTriggered = true
        return true
    end
    return false
end

--- 是否已经飞出屏幕下方，可以回收
function GateComponent:IsOutOfBounds(bottomY)
    local _, y = self:GetLocalPos()
    return y < bottomY
end

function GateComponent:Destroy()
    if self.go ~= nil and not IsNull(self.go) then
        self.go:Destroy()
    end
    self.go = nil
    self.rt = nil
    self.cards = nil
    self.frameImages = nil
    self.legacyText = nil
    self.separatorRt = nil
    self.onHitFeedback = nil
    self.thresholdCountText, self.thresholdHintText, self.thresholdDisplayCount = nil, nil, nil
end

return GateComponent
