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
        local progress = math.min(1, self.joinAge / 0.45)
        local remaining = (1 - progress) * (1 - progress)
        self.rt.anchoredPosition = Vector2(0, -65 * remaining)
        self.rt.localScale = Vector3(1 - 0.25 * remaining, 1 - 0.25 * remaining, 1)
        if progress >= 1 then self.joinAge = nil end
    end
    local pulse = 1 + math.sin(time * 25 + self.phase) * 0.16
    local boost = math.min(0.35, math.abs(speed) / 1000)
    self.tailRt.sizeDelta = Vector2(self.tailWidth, self.tailLength * (pulse + boost))
    if self.fireAge ~= nil then
        self.fireAge = self.fireAge + dt
        local remaining = math.max(0, 1 - self.fireAge / 0.12)
        self.bodyRt.anchoredPosition = Vector2(0, -3 * remaining)
        for _, muzzle in ipairs(self.muzzles) do
            muzzle.img.color = Color(self.fireColor.r, self.fireColor.g, self.fireColor.b, remaining)
            muzzle.rt.sizeDelta = Vector2(self.muzzleSize * (0.6 + remaining * 0.4), self.muzzleSize)
            if remaining <= 0 then muzzle.go:SetActive(false) end
        end
        if remaining <= 0 then self.fireAge = nil end
    end
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
    self.fireColor = level >= 2 and Color(1, 0.75, 0.25, 1) or Color(0.5, 0.9, 1, 1)
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
    self.fireAge = nil
    self.bodyRt.anchoredPosition = Vector2(0, 0)
    for _, muzzle in ipairs(self.muzzles) do muzzle.go:SetActive(false) end
    self.rt.localScale = Vector3.one
    self.rt.localRotation = Quaternion.identity
    self.rt.anchoredPosition = Vector2(0, 0)
    self.tailRt.sizeDelta = Vector2(self.tailWidth, self.tailLength)
end

function FlightVisual:PlayJoin()
    self.joinAge = 0
    self.rt.anchoredPosition = Vector2(0, -65)
    self.rt.localScale = Vector3(0.75, 0.75, 1)
end

return FlightVisual
