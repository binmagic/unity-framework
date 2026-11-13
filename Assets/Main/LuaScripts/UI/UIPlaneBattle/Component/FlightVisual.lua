--- 飞行表现只驱动子节点，不改变主机拖动、编队或碰撞坐标。
local FlightVisual = {}
FlightVisual.__index = FlightVisual

local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color
local Quaternion = CS.UnityEngine.Quaternion
local Vector3 = CS.UnityEngine.Vector3
local CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)

function FlightVisual.New(parent, size, spritePath, phase, showArmament)
    local self = setmetatable({}, FlightVisual)
    self.phase = phase or 0
    self.spritePath = spritePath
    self.bank = 0
    self.lastX = nil
    local go = GameObject("FlightVisual", RectTransform)
    go.transform:SetParent(parent, false)
    self.rt = go:GetComponent(RectTransform)
    self.rt.sizeDelta = size
    self.go = go
    self.group = go:AddComponent(CanvasGroup)
    self.group.alpha = 1
    self.group.blocksRaycasts, self.group.interactable = false, false

    -- 速射光环放在机身后面，使用现有透明特效，不改变碰撞或拖动坐标。
    local hasteGo = GameObject("HasteAura", RectTransform)
    hasteGo.transform:SetParent(go.transform, false)
    self.hasteRt = hasteGo:GetComponent(RectTransform)
    self.hasteRt.sizeDelta = Vector2(size.x * 1.5, size.y * 1.3)
    self.hasteImg = hasteGo:AddComponent(Image)
    self.hasteImg.raycastTarget = false
    self.hasteImg:LoadSprite("Assets/Main/Sprites/STG/CombatFx/shield_hit.png")
    hasteGo:SetActive(false)
    self.hasteGo, self.hasteRemaining = hasteGo, 0

    -- 使用项目已有的透明火焰状子弹精灵作发动机尾焰，子节点不拦输入。
    local tailGo = GameObject("EngineTrail", RectTransform)
    tailGo.transform:SetParent(go.transform, false)
    self.tailRt = tailGo:GetComponent(RectTransform)
    self.tailRt.anchoredPosition = Vector2(0, -size.y * 0.31)
    self.tailRt.localRotation = Quaternion.Euler(0, 0, 180)
    -- 倒转后尾焰尖端向后；pivot 设在其原图底部，保持发动机接点固定。
    self.tailRt.pivot = Vector2(0.5, 0)
    self.tailWidth = size.x * 0.22
    self.tailLength = size.y * 0.42
    self.tailRt.sizeDelta = Vector2(self.tailWidth, self.tailLength)
    self.tailImg = tailGo:AddComponent(Image)
    self.tailImg.raycastTarget = false
    self.tailImg.color = Color(0.3, 0.85, 1, 0.85)
    self.tailImg:LoadSprite("Assets/Main/Sprites/PlaneBattle/PlaneBattle_bullet.png")

    local bodyGo = GameObject("Body", RectTransform)
    bodyGo.transform:SetParent(go.transform, false)
    local bodyRt = bodyGo:GetComponent(RectTransform)
    bodyRt.sizeDelta = size
    self.bodyImg = bodyGo:AddComponent(Image)
    self.bodyImg.raycastTarget = false
    self.bodyImg.preserveAspect = true
    self.bodyImg:LoadSprite(spritePath)
    self.bodyRt = bodyRt
    self.weaponLevel, self.deploy = 0, 0
    if showArmament then
        self.weaponPods = {}
        for side = -1, 1, 2 do
            local pod = GameObject("WeaponPod" .. side, RectTransform)
            pod.transform:SetParent(go.transform, false)
            local pr = pod:GetComponent(RectTransform)
            pr.sizeDelta = Vector2(size.x * 0.13, size.y * 0.38)
            local plate = pod:AddComponent(Image)
            plate.color, plate.raycastTarget = Color(0.17, 0.24, 0.3, 1), false
            local light = GameObject("EnergyRail", RectTransform)
            light.transform:SetParent(pod.transform, false)
            local lr = light:GetComponent(RectTransform)
            lr.sizeDelta = Vector2(size.x * 0.045, size.y * 0.3)
            local glow = light:AddComponent(Image)
            glow.color, glow.raycastTarget = Color(0.35, 0.85, 1, 0.95), false
            glow:LoadSprite("Assets/Main/Sprites/STG/CombatFx/energy_bolt.png")
            pod:SetActive(false)
            table.insert(self.weaponPods, { go = pod, rt = pr, glow = glow, side = side })
        end
        self.podOffset, self.podY = size.x * 0.5, size.y * 0.05
    end
    self.muzzles = {}
    for i = 1, 3 do
        local muzzleGo = GameObject("MuzzleFlash" .. i, RectTransform)
        muzzleGo.transform:SetParent(go.transform, false)
        local muzzleRt = muzzleGo:GetComponent(RectTransform)
        muzzleRt.anchoredPosition = Vector2((i - 2) * 7, size.y * 0.43)
        local muzzleImg = muzzleGo:AddComponent(Image)
        muzzleImg.raycastTarget = false
        muzzleImg:LoadSprite("Assets/Main/Sprites/STG/CombatFx/impact.png")
        muzzleGo:SetActive(false)
        self.muzzles[i] = { go = muzzleGo, rt = muzzleRt, img = muzzleImg }
    end
    self.muzzleSize = size.x * 0.45
    self.fireAge = nil
    return self
end

function FlightVisual:Update(dt, x, time)
    if dt <= 0 then return end
    local speed = self.lastX and (x - self.lastX) / dt or 0
    self.lastX = x
    local target = math.max(-11, math.min(11, -speed * 0.045))
    self.bank = self.bank + (target - self.bank) * math.min(1, dt * 10)
    self.rt.localRotation = Quaternion.Euler(0, 0, self.bank)
    self.rt.anchoredPosition = Vector2(0, math.sin(time * 3.2 + self.phase) * 1.5)
    if self.weaponPods ~= nil then
        self.deploy = math.min(1, self.deploy + dt / 0.3)
        local slide = 1 - (1 - self.deploy)^3
        for _, pod in ipairs(self.weaponPods) do
            pod.rt.anchoredPosition = Vector2(pod.side * self.podOffset * (0.65 + 0.35 * slide), self.podY)
            pod.glow.color = self.weaponLevel >= 2 and Color(1, 0.75, 0.25, 0.95)
                or Color(0.35, 0.85, 1, 0.95)
        end
    end
    if self.joinAge ~= nil then
        self.joinAge = self.joinAge + dt
        if self.joinAge < 0 then
            -- 分批入场：等待前一架完成一小段飞入，避免多架叠在同一位置。
            self.rt.anchoredPosition = Vector2(self.joinStartX or 0, -65)
            self.rt.localScale = Vector3(0.75, 0.75, 1)
        else
            local progress = math.min(1, self.joinAge / (self.joinDuration or 0.45))
            local eased = 1 - (1 - progress) * (1 - progress)
            local overshoot = progress < 1 and math.sin(progress * math.pi) * 8 or 0
            self.rt.anchoredPosition = Vector2((self.joinStartX or 0) * (1 - eased), -65 * (1 - eased) + overshoot)
            local scale = 0.75 + 0.25 * (1 - (1 - progress) * (1 - progress))
            self.rt.localScale = Vector3(scale, scale, 1)
            if progress >= 1 then self.joinAge = nil end
        end
    end
    if self.leaveAge ~= nil then
        self.leaveAge = self.leaveAge + dt
        if self.leaveAge >= 0 then
            local progress = math.min(1, self.leaveAge / (self.leaveDuration or 0.38))
            local eased = progress * progress
            local side = self.leaveSide or 1
            self.rt.anchoredPosition = Vector2(side * 105 * eased, -18 * eased - 72 * eased * eased)
            local scale = 1 - 0.52 * eased
            self.rt.localScale = Vector3(scale, scale, 1)
            self.rt.localRotation = Quaternion.Euler(0, 0, side * 34 * eased)
            self.group.alpha = 1 - progress
            if progress >= 1 then self.leaveAge, self.leaveDone = nil, true end
        end
    end
    local pulse = 1 + math.sin(time * 25 + self.phase) * 0.16
    local boost = math.min(0.35, math.abs(speed) / 1000)
    local hasted = self.hasteRemaining > 0
    local visible = hasted and (self.hasteRemaining > 1 or math.sin(time * 18) > 0)
    if self.hasteVisible ~= visible then
        self.hasteVisible = visible
        self.hasteGo:SetActive(visible)
    end
    if visible then
        local strength = self.supportStyle and 0.5 or 1
        self.hasteImg.color = Color(0.25, 1, 0.9, (0.28 + 0.1 * math.sin(time * 8 + self.phase)) * strength)
    end
    self.tailImg.color = hasted and Color(0.3, 1, 0.75, 1) or Color(0.3, 0.85, 1, 0.85)
    self.tailRt.sizeDelta = Vector2(self.tailWidth * (hasted and 1.3 or 1),
        self.tailLength * (pulse + boost) * (hasted and 1.45 or 1))
    if self.fireAge ~= nil then
        self.fireAge = self.fireAge + dt
        local remaining = math.max(0, 1 - self.fireAge / 0.12)
        self.bodyRt.anchoredPosition = Vector2(0, -3 * remaining)
        for _, muzzle in ipairs(self.muzzles) do
            muzzle.img.color = Color(self.fireColor.r, self.fireColor.g, self.fireColor.b, remaining)
            local size = self.muzzleSize * (hasted and 1.3 or 1)
            muzzle.rt.sizeDelta = Vector2(size * (0.6 + remaining * 0.4), size)
            if remaining <= 0 then muzzle.go:SetActive(false) end
        end
        if remaining <= 0 then self.fireAge = nil end
    end
end

--- 普通增援机减少尾焰和炮口面积，主机与英雄护航机保留完整反馈。
function FlightVisual:SetSupportStyle()
    if self.supportStyle then return end
    self.supportStyle = true
    self.muzzleSize = self.muzzleSize * 0.55
    self.tailWidth, self.tailLength = self.tailWidth * 0.75, self.tailLength * 0.75
end

function FlightVisual:SetHaste(remaining)
    self.hasteRemaining = math.max(0, remaining or 0)
end

function FlightVisual:SetAircraft(spritePath)
    if spritePath == nil or spritePath == self.spritePath then return end
    self.spritePath = spritePath
    self.bodyImg:LoadSprite(spritePath)
end

function FlightVisual:SetWeaponLevel(level)
    if self.weaponLevel == level then return end
    self.weaponLevel, self.deploy = level, 0
    for _, pod in ipairs(self.weaponPods or {}) do pod.go:SetActive(level >= 1) end
end

function FlightVisual:PlayFire(level)
    self.fireAge = 0
    self.fireColor = self.hasteRemaining > 0 and Color(0.45, 1, 0.75, 1)
        or (level >= 2 and Color(1, 0.75, 0.25, 1) or Color(0.5, 0.9, 1, 1))
    self.bodyRt.anchoredPosition = Vector2(0, -3)
    for i, muzzle in ipairs(self.muzzles) do
        local visible = level == 0 and i == 2 or level == 1 and i ~= 2 or level >= 2
        muzzle.go:SetActive(visible)
        muzzle.img.color = self.fireColor
        muzzle.rt.sizeDelta = Vector2(self.muzzleSize, self.muzzleSize)
    end
end

function FlightVisual:Reset(x)
    self:SetWeaponLevel(0)
    self.bank = 0
    self.lastX = x
    self.joinAge = nil
    self.leaveAge, self.leaveDone = nil, false
    self.group.alpha = 1
    self.fireAge = nil
    self.hasteRemaining, self.hasteVisible = 0, false
    self.hasteGo:SetActive(false)
    self.tailImg.color = Color(0.3, 0.85, 1, 0.85)
    self.bodyRt.anchoredPosition = Vector2(0, 0)
    for _, muzzle in ipairs(self.muzzles) do muzzle.go:SetActive(false) end
    self.rt.localScale = Vector3.one
    self.rt.localRotation = Quaternion.identity
    self.rt.anchoredPosition = Vector2(0, 0)
    self.tailRt.sizeDelta = Vector2(self.tailWidth, self.tailLength)
end

function FlightVisual:PlayJoin(delay, side)
    self.leaveAge, self.leaveDone = nil, false
    self.group.alpha = 1
    self.joinAge = -(math.max(0, tonumber(delay) or 0))
    self.joinDuration = 0.45
    self.joinStartX = (tonumber(side) or 0) * 58
    self.rt.anchoredPosition = Vector2(self.joinStartX, -65)
    self.rt.localScale = Vector3(0.75, 0.75, 1)
end

function FlightVisual:PlayLeave(delay, side)
    self.joinAge = nil
    self.leaveDone = false
    self.leaveAge = -(math.max(0, tonumber(delay) or 0))
    self.leaveDuration = 0.38
    self.leaveSide = (tonumber(side) or 1) < 0 and -1 or 1
    self.group.alpha = 1
end

function FlightVisual:IsLeaveDone()
    return self.leaveDone == true
end

return FlightVisual
