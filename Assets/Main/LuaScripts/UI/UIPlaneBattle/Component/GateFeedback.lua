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
    self.preview, self.previewBg, self.previewLabel = preview, previewBg, previewLabel
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
    self.badgeText.text = string.format("僚机 %d  ·  %s%s", count, names[self.weaponLevel] or "散射", secondary)
end

function GateFeedback:Show(before, after)
    local delta = after - before
    if delta == 0 then return end
    local oldCount, newCount = math.min(24, before), math.min(24, after)
    local title = delta > 0 and "编队增援" or "编队受损"
    local detail = string.format("僚机 %d → %d", oldCount, newCount)
    if delta > 0 and oldCount == 24 then detail = "编队已达显示上限 24" end
    self:ShowMessage(string.format("%s  %+d", title, delta), detail,
        delta > 0 and Color(0.4, 0.95, 1, 1) or Color(1, 0.48, 0.3, 1))
end

function GateFeedback:ShowPreview(title, detail, color, key)
    if self.preview == nil or IsNull(self.preview) then return end
    key = key or (title .. detail)
    if self.previewKey == key and self.preview.activeSelf then return end
    self.previewKey = key
    self.previewLabel.text = string.format("%s\n<size=23>%s</size>", title, detail or "")
    self.previewLabel.color = color or Color(0.45, 0.9, 1, 1)
    self.previewBg.color = Color(0.02, 0.08, 0.14, 0.92)
    self.preview:SetActive(true)
end

function GateFeedback:HidePreview()
    self.previewKey = nil
    if self.preview ~= nil and not IsNull(self.preview) then self.preview:SetActive(false) end
end

function GateFeedback:ShowMessage(title, detail, color)
    self.label.text = string.format("%s\n<size=25>%s</size>", title, detail)
    self.label.color = color or Color(0.4, 0.95, 1, 1)
    self.age = 0
    self.group.alpha = 1
    self.popupRt.anchoredPosition = Vector2(0, 430)
    self.popupRt.localScale = Vector3(0.9, 0.9, 1)
    self.popup:SetActive(true)
end

function GateFeedback:Update(dt)
    if self.age == nil then return end
    self.age = self.age + dt
    local scale = 0.9 + 0.1 * math.min(1, self.age / 0.14)
    self.popupRt.localScale = Vector3(scale, scale, 1)
    self.popupRt.anchoredPosition = Vector2(0, 430 + math.min(1, self.age / 1.4) * 24)
    self.group.alpha = math.min(1, math.max(0, (1.4 - self.age) / 0.3))
    if self.age >= 1.4 then self.age = nil; self.popup:SetActive(false) end
end

function GateFeedback:Reset()
    self.age = nil
    self.weaponLevel = 0
    self:HidePreview()
    self.popup:SetActive(false)
end

function GateFeedback:Destroy()
    self.secondaryText = nil
    if self.go ~= nil and not IsNull(self.go) then self.go:Destroy() end
    self.go, self.popup, self.popupRt, self.label, self.group, self.badgeText = nil, nil, nil, nil, nil, nil
    self.preview, self.previewBg, self.previewLabel = nil, nil, nil
end

return GateFeedback
