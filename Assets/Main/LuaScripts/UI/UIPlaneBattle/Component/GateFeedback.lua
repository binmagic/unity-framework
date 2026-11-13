--- 数字门结算提示：复用一组节点，数字取实际结算结果，不自行执行奖励。
local GateFeedback = {}
GateFeedback.__index = GateFeedback
local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local TMPText = typeof(CS.TMPro.TextMeshProUGUI)
local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3
local Color = CS.UnityEngine.Color

function GateFeedback.New(parent, requestFont)
    local self = setmetatable({}, GateFeedback)
    local go = GameObject("GateFeedback", RectTransform)
    go.transform:SetParent(parent, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchorMin, rt.anchorMax = Vector2(0.5, 0), Vector2(0.5, 0)
    rt.sizeDelta = Vector2(400, 0)
    self.go = go
    local function textNode(name, y, height, fontSize)
        local node = GameObject(name, RectTransform)
        node.transform:SetParent(go.transform, false)
        local nr = node:GetComponent(RectTransform)
        nr.anchoredPosition = Vector2(0, y)
        nr.sizeDelta = Vector2(708, height)
        local text = node:AddComponent(TMPText)
        text.fontSize = fontSize
        text.alignment = CS.TMPro.TextAlignmentOptions.Center
        text.fontStyle = CS.TMPro.FontStyles.Normal
        text.raycastTarget = false
        requestFont(text)
        return node, nr, text
    end
    local _, _, badgeText = textNode("Firepower", 169, 34, 23)
    badgeText.color = Color(0.7, 0.94, 1, 1)
    self.badgeText = badgeText

    local preview = GameObject("IncomingPreview", RectTransform)
    preview.transform:SetParent(go.transform, false)
    local previewRt = preview:GetComponent(RectTransform)
    previewRt.anchoredPosition = Vector2(0, 505)
    previewRt.sizeDelta = Vector2(620, 78)
    local previewBg = preview:AddComponent(Image)
    previewBg.color = Color(0.02, 0.08, 0.14, 0.92)
    previewBg.raycastTarget = false
    local previewLabelGo = GameObject("Label", RectTransform)
    previewLabelGo.transform:SetParent(preview.transform, false)
    local previewLabelRt = previewLabelGo:GetComponent(RectTransform)
    previewLabelRt.anchorMin, previewLabelRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    previewLabelRt.offsetMin, previewLabelRt.offsetMax = Vector2(10, 0), Vector2(-10, 0)
    local previewLabel = previewLabelGo:AddComponent(TMPText)
    previewLabel.fontSize = 26
    previewLabel.alignment = CS.TMPro.TextAlignmentOptions.Center
    previewLabel.fontStyle = CS.TMPro.FontStyles.Normal
    previewLabel.raycastTarget = false
    requestFont(previewLabel)
    self.preview, self.previewRt, self.previewBg, self.previewLabel = preview, previewRt, previewBg, previewLabel

    -- 航线提示落在战场左右两侧，只用低透明光带和流动箭头，不遮挡敌弹与门本体。
    local route = GameObject("RouteGuide", RectTransform)
    route.transform:SetParent(go.transform, false)
    local routeRt = route:GetComponent(RectTransform)
    routeRt.anchoredPosition = Vector2(0, 500)
    routeRt.sizeDelta = Vector2(720, 420)
    local function routeLane(name, x)
        local laneGo = GameObject(name, RectTransform)
        laneGo.transform:SetParent(route.transform, false)
        local laneRt = laneGo:GetComponent(RectTransform)
        laneRt.anchoredPosition = Vector2(x, 0)
        laneRt.sizeDelta = Vector2(286, 390)
        local laneImg = laneGo:AddComponent(Image)
        laneImg.raycastTarget = false

        local arrowGo = GameObject("Arrows", RectTransform)
        arrowGo.transform:SetParent(laneGo.transform, false)
        local arrowRt = arrowGo:GetComponent(RectTransform)
        arrowRt.anchorMin, arrowRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
        arrowRt.offsetMin, arrowRt.offsetMax = Vector2(0, 0), Vector2(0, 0)
        local arrows = arrowGo:AddComponent(TMPText)
        arrows.text = "↑\n↑\n↑"
        arrows.fontSize = 54
        arrows.alignment = CS.TMPro.TextAlignmentOptions.Center
        arrows.fontStyle = CS.TMPro.FontStyles.Bold
        arrows.raycastTarget = false
        arrows.lineSpacing = 18
        requestFont(arrows)

        local labelGo = GameObject("Label", RectTransform)
        labelGo.transform:SetParent(laneGo.transform, false)
        local labelRt = labelGo:GetComponent(RectTransform)
        labelRt.anchoredPosition = Vector2(0, -145)
        labelRt.sizeDelta = Vector2(270, 52)
        local label = labelGo:AddComponent(TMPText)
        label.fontSize = 24
        label.alignment = CS.TMPro.TextAlignmentOptions.Center
        label.fontStyle = CS.TMPro.FontStyles.Bold
        label.raycastTarget = false
        requestFont(label)
        return { go = laneGo, rt = laneRt, img = laneImg, arrowRt = arrowRt, arrows = arrows, label = label }
    end
    self.route, self.routeRt = route, routeRt
    self.routeLeft, self.routeRight = routeLane("LeftLane", -178), routeLane("RightLane", 178)
    local popup = GameObject("UpgradeNotice", RectTransform)
    popup.transform:SetParent(go.transform, false)
    local popupRt = popup:GetComponent(RectTransform)
    popupRt.anchoredPosition = Vector2(0, 430)
    popupRt.sizeDelta = Vector2(560, 96)
    local bg = popup:AddComponent(Image)
    bg.color = Color(0.02, 0.07, 0.11, 0.88)
    bg.raycastTarget = false
    -- 背板需位于文字下面，文字独立在子节点，避免同物体 Graphic 相互覆盖。
    local labelGo = GameObject("Label", RectTransform)
    labelGo.transform:SetParent(popup.transform, false)
    local lr = labelGo:GetComponent(RectTransform)
    lr.anchorMin, lr.anchorMax = Vector2(0, 0), Vector2(1, 1)
    lr.offsetMin, lr.offsetMax = Vector2(8, 0), Vector2(-8, 0)
    local label = labelGo:AddComponent(TMPText)
    label.fontSize, label.alignment = 30, CS.TMPro.TextAlignmentOptions.Center
    label.fontStyle = CS.TMPro.FontStyles.Normal
    label.raycastTarget = false
    requestFont(label)
    self.popup, self.popupRt, self.label = popup, popupRt, label
    self.group = popup:AddComponent(typeof(CS.UnityEngine.CanvasGroup))
    self.group.blocksRaycasts, self.group.interactable = false, false
    self:Reset()
    return self
end

function GateFeedback:SetCount(count, weaponLevel)
    self.weaponLevel = weaponLevel or self.weaponLevel or 0
    local names = { [0] = "单发", "双发", "散射" }
    local secondary = self.weaponLevel >= 2 and " · 导弹/激光" or (self.weaponLevel == 1 and " · 导弹" or "")
    local mode = self.weaponMode == "pierce" and "穿透" or (self.weaponMode == "homing" and "追踪" or names[self.weaponLevel])
    self.badgeText.text = string.format("僚机 %d  ·  %s%s", count, mode or "散射", secondary)
end

function GateFeedback:Show(before, after)
    local delta = after - before
    if delta == 0 then return end
    local title = delta > 0 and "编队增援" or "编队受损"
    local detail = string.format("僚机 %d → %d", before, after)
    if after > 12 then detail = detail .. (before >= 24 and after >= 24 and " · 火力已达上限" or " · 超出12架折算火力") end
    self:ShowMessage(string.format("%s  %+d", title, delta), detail,
        delta > 0 and Color(0.4, 0.95, 1, 1) or Color(1, 0.48, 0.3, 1))
end

function GateFeedback:_ApplyRouteLane(lane, data, recommended)
    if lane == nil then return end
    data = data or { state = "neutral", text = "观察航线" }
    local state = data.state or "neutral"
    local color = state == "bad" and Color(1, 0.2, 0.12, 1)
        or (state == "good" and Color(0.15, 0.95, 0.8, 1) or Color(0.35, 0.65, 0.9, 1))
    lane.baseColor = color
    lane.recommended = recommended == true
    lane.img.color = Color(color.r, color.g, color.b, recommended and 0.14 or (state == "bad" and 0.1 or 0.035))
    lane.arrows.color = Color(color.r, color.g, color.b, recommended and 0.9 or 0.38)
    lane.label.color = Color(color.r, color.g, color.b, recommended and 1 or 0.7)
    lane.label.text = data.text or (state == "bad" and "危险" or "可通行")
end

function GateFeedback:SetRouteGuide(guide)
    if self.route == nil or IsNull(self.route) then return end
    if guide == nil then self.route:SetActive(false); return end
    self:_ApplyRouteLane(self.routeLeft, guide.left, guide.recommended == "left" or guide.recommended == "both")
    self:_ApplyRouteLane(self.routeRight, guide.right, guide.recommended == "right" or guide.recommended == "both")
    self.route:SetActive(true)
end

function GateFeedback:ShowPreview(title, detail, color, key, positionY, routeGuide)
    if self.preview == nil or IsNull(self.preview) then return end
    key = key or (title .. detail)
    if self.previewKey == key and self.preview.activeSelf then return end
    self.previewKey = key
    self.previewRt.anchoredPosition = Vector2(0, positionY or 505)
    self.previewLabel.text = string.format("%s\n<size=23>%s</size>", title, detail or "")
    self.previewLabel.color = color or Color(0.45, 0.9, 1, 1)
    self.previewBg.color = Color(0.02, 0.08, 0.14, 0.92)
    self.preview:SetActive(true)
    self:SetRouteGuide(routeGuide)
end

function GateFeedback:HidePreview()
    self.previewKey = nil
    if self.preview ~= nil and not IsNull(self.preview) then self.preview:SetActive(false) end
    if self.route ~= nil and not IsNull(self.route) then self.route:SetActive(false) end
end

function GateFeedback:ShowMessage(title, detail, color, duration)
    self.label.text = string.format("%s\n<size=25>%s</size>", title, detail)
    self.label.color = color or Color(0.4, 0.95, 1, 1)
    self.age = 0
    self.duration = math.max(0.6, tonumber(duration) or 1.4)
    self.group.alpha = 1
    self.popupRt.anchoredPosition = Vector2(0, 430)
    self.popupRt.localScale = Vector3(0.9, 0.9, 1)
    self.popup:SetActive(true)
end

function GateFeedback:Update(dt)
    if self.route ~= nil and not IsNull(self.route) and self.route.activeSelf then
        self.routePulse = (self.routePulse or 0) + dt
        local drift = math.sin(self.routePulse * 5) * 10
        for _, lane in ipairs({ self.routeLeft, self.routeRight }) do
            lane.arrowRt.anchoredPosition = Vector2(0, drift)
            local c = lane.baseColor or Color(0.35, 0.65, 0.9, 1)
            local pulse = lane.recommended and (0.82 + 0.18 * math.sin(self.routePulse * 7)) or 0.38
            lane.arrows.color = Color(c.r, c.g, c.b, pulse)
        end
    end
    if self.age == nil then return end
    self.age = self.age + dt
    local duration = self.duration or 1.4
    local scale = 0.9 + 0.1 * math.min(1, self.age / 0.14)
    self.popupRt.localScale = Vector3(scale, scale, 1)
    self.popupRt.anchoredPosition = Vector2(0, 430 + math.min(1, self.age / duration) * 24)
    self.group.alpha = math.min(1, math.max(0, (duration - self.age) / 0.3))
    if self.age >= duration then self.age, self.duration = nil, nil; self.popup:SetActive(false) end
end

function GateFeedback:Reset()
    self.age, self.duration = nil, nil
    self.routePulse = 0
    self.weaponLevel = 0
    self.weaponMode = "spread"
    self:HidePreview()
    self.popup:SetActive(false)
end

function GateFeedback:Destroy()
    self.secondaryText = nil
    if self.go ~= nil and not IsNull(self.go) then self.go:Destroy() end
    self.go, self.popup, self.popupRt, self.label, self.group, self.badgeText = nil, nil, nil, nil, nil, nil
    self.preview, self.previewRt, self.previewBg, self.previewLabel = nil, nil, nil, nil
    self.route, self.routeRt, self.routeLeft, self.routeRight = nil, nil, nil, nil
end

return GateFeedback
