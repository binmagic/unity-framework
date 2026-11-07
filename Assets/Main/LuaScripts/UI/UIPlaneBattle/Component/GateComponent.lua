---
--- 探险玩法 战斗 — 数字门
--- 参考 barrel（D:\UnityProject\barrel）UpgradeableDuetGate 的设计思路：一对门左右各自独立，
--- 主机穿过哪一侧的 x 范围，就执行哪一侧配置的触发效果。换算成 2D：门是横排的一条 Image，
--- 从上往下移动，主机与门同一 Y 高度时按 x 落在左半/右半判定。
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

--- 保留原有尺寸与触发宽度，纯 UI 框架表现不改变门的玩法判定。
local GATE_VISUAL = {
    add      = { size = Vector2(140, 140), color = Color(0.25, 0.86, 1, 0.9) },
    subtract = { size = Vector2(150, 84), color = Color(1, 0.36, 0.23, 0.9) },
    lock     = { size = Vector2(500, 322), color = Color(1, 0.72, 0.22, 0.9) },
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
        local title = label(go.transform, 44, Vector2(width - 12, 24), 16)
        local reward = label(go.transform, 6, Vector2(width - 12, 54), 42)
        reward.outlineWidth = 0.18
        reward.outlineColor = Color(0.015, 0.05, 0.1, 1)
        local progress = label(go.transform, -35, Vector2(width - 16, 24), 14)
        local rails = {}
        for side = -1, 1, 2 do
            local post = GameObject("GatePost", RectTransform)
            post.transform:SetParent(go.transform, false)
            local pr = post:GetComponent(RectTransform)
            pr.anchoredPosition, pr.sizeDelta = Vector2(side * (width / 2 - 4), 0), Vector2(7, 136)
            local pi = post:AddComponent(Image)
            pi.raycastTarget, pi.color = false, Color(0.64, 0.77, 0.86, 1)
            local rim = GameObject("EnergyRim", RectTransform)
            rim.transform:SetParent(go.transform, false)
            local rr = rim:GetComponent(RectTransform)
            rr.anchoredPosition, rr.sizeDelta = Vector2(0, side * 60), Vector2(width - 12, 3)
            local ri = rim:AddComponent(Image); ri.raycastTarget = false
            table.insert(rails, ri)
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
        local fi = fill:AddComponent(Image)
        fi.raycastTarget = false
        table.insert(self.cards, { bg = bg, title = title, reward = reward, progress = progress, rails = rails,
            fillRt = fr, fillImg = fi, width = width - 20 })
    end
    self:RefreshStgDisplay()
end

function GateComponent:RefreshStgDisplay()
    local g = self.stgGate
    local duet = g.gateType == "gate_duet"
    local step = g.gateType == "gate_step"
    for i, card in ipairs(self.cards) do
        local value = step and g.accumulatedDamage or (duet and (i == 1 and g.leftValue or g.rightValue) or g.value)
        local effectId = duet and (i == 1 and g.leftEffectId or g.rightEffectId) or g.effectId
        local meta = EffectTable[effectId]
        local repair = meta ~= nil and meta.type == 60
        local weapon = meta ~= nil and meta.type == 50
        local negative = (duet and value < 0) or (meta ~= nil and meta.type == 20)
        local c = negative and Color(1, 0.4, 0.25, 1) or Color(0.3, 0.9, 1, 1)
        if repair then c = Color(0.35, 1, 0.6, 1) elseif weapon then c = Color(0.65, 0.65, 1, 1) end
        card.bg.color = negative and Color(0.65, 0.12, 0.10, 0.73) or Color(0.02, 0.46, 0.65, 0.66)
        if repair then card.bg.color = Color(0.015, 0.18, 0.08, 0.9) elseif weapon then card.bg.color = Color(0.08, 0.055, 0.23, 0.9) end
        card.reward.text = duet and value < 0 and string.format("%+d", value) or (meta and meta.text or "+0")
        if repair then card.reward.text = "装甲 +" .. tostring(meta.count or meta.para or 1) end
        card.reward.color, card.fillImg.color = c, c
        for _, rail in ipairs(card.rails or {}) do rail.color = c end
        if not duet then
            for _, img in ipairs(self.frameImages) do img.color = c end
        end
        card.title.text = negative and "危险 · 射击转正" or (duet and (i == 1 and "左路增援" or "右路增援") or (step and "火力充能" or "射击改造"))
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
            card.progress.text = duet and "通过此侧领取" or "已达最高档"
        end
        card.fillRt.sizeDelta = Vector2(card.width * ratio, 4)
    end
end

--- 子弹与移动门使用相对线段检测，高速子弹也不会穿过薄门。
function GateComponent:TryHitBullet(bullet)
    if self.hasTriggered or self.stgGate == nil then return false end
    local gx, gy = self:GetLocalPos()
    local p = bullet.rt.anchoredPosition
    local ax, ay = (bullet.previousX or p.x) - gx, (bullet.previousY or p.y) - (self.previousY or gy)
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
    self.stgGate:OnHit(bullet.damage, hitX <= 0)
    self:RefreshStgDisplay()
    local index = self.stgGate.gateType == "gate_duet" and (hitX <= 0 and 1 or 2) or 1
    self.cards[index].pulse = 0.16
    self.cards[index].reward.fontSize = 47
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
    local pos = self.rt.anchoredPosition
    self.previousY = pos.y
    self.rt.anchoredPosition = Vector2(pos.x, pos.y - FALL_SPEED * dt)
    for _, card in ipairs(self.cards or {}) do
        if card.pulse ~= nil then
            card.pulse = math.max(0, card.pulse - dt)
            card.reward.fontSize = 42 + 5 * card.pulse / 0.16
            if card.pulse == 0 then card.pulse = nil end
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
end

return GateComponent
