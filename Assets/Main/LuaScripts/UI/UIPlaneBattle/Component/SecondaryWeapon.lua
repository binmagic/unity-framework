--- 副武器的短生命周期节点与索敌；不改关卡/英雄存档，伤害与死亡交回 View。
local SecondaryWeapon = BaseClass("SecondaryWeapon")
local GameObject = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image = typeof(CS.UnityEngine.UI.Image)
local Vector2 = CS.UnityEngine.Vector2
local Quaternion = CS.UnityEngine.Quaternion
local Color = CS.UnityEngine.Color
local BOLT = "Assets/Main/Sprites/STG/CombatFx/energy_bolt.png"
local IMPACT = "Assets/Main/Sprites/STG/CombatFx/impact.png"
local MISSILE_INTERVAL, LASER_INTERVAL, LASER_DURATION = 1.8, 2.8, 0.45

local function imageNode(parent, name, width, height, color, sprite)
    local go = GameObject(name, RectTransform)
    go.transform:SetParent(parent, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchorMin, rt.anchorMax = Vector2(0.5, 0), Vector2(0.5, 0)
    rt.sizeDelta = Vector2(width, height)
    local img = go:AddComponent(Image)
    img.raycastTarget = false
    img.color = color
    if sprite then img:LoadSprite(sprite) end
    return { go = go, rt = rt, img = img }
end

function SecondaryWeapon:__init(parent)
    self.root = GameObject("SecondaryWeapons", RectTransform)
    self.root.transform:SetParent(parent, false)
    local rt = self.root:GetComponent(RectTransform)
    rt.anchorMin, rt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    rt.offsetMin, rt.offsetMax = Vector2.zero, Vector2.zero
    self.topY = math.max(1625, parent.rect.height)
    self.missiles, self.free = {}, {}
    self.missileTimer, self.laserTimer, self.laserRemaining = 0, 0, 0
    self.level = 0
    self.beam = imageNode(self.root.transform, "PulseLaser", 18, 1, Color(0.15, 0.65, 1, 0.3))
    self.core = imageNode(self.beam.go.transform, "Core", 3, 1, Color(0.8, 1, 1, 0.95))
    self.core.rt.anchorMin, self.core.rt.anchorMax = Vector2(0.5, 0.5), Vector2(0.5, 0.5)
    self.origin = imageNode(self.root.transform, "LaserEmitterFlare", 58, 68, Color(0.45, 0.85, 1, 0.9), IMPACT)
    self.contact = imageNode(self.root.transform, "LaserContactFlare", 65, 65, Color(0.6, 0.95, 1, 0.9), IMPACT)
    self:_HideLaser()
end

function SecondaryWeapon:_HideLaser()
    self.beam.go:SetActive(false)
    self.origin.go:SetActive(false)
    self.contact.go:SetActive(false)
end

function SecondaryWeapon:__delete()
    if self.root ~= nil and not IsNull(self.root) then self.root:Destroy() end
    self.root, self.beam, self.core = nil, nil, nil
    self.origin, self.contact = nil, nil
    self.missiles, self.free = nil, nil
    self.topY, self.level = nil, nil
    self.missileTimer, self.laserTimer, self.laserRemaining = nil, nil, nil
end

function SecondaryWeapon:Reset()
    for i = #self.missiles, 1, -1 do self:_Recycle(i) end
    self.missileTimer, self.laserTimer, self.laserRemaining = 0, 0, 0
    self.level = 0
    self:_HideLaser()
end

function SecondaryWeapon:_FindTarget(enemies, x, y, minimumY)
    local best, nearest = nil, math.huge
    for _, enemy in ipairs(enemies) do
        if not enemy.isDead and enemy.rt ~= nil and not IsNull(enemy.rt) then
            local ex, ey = enemy:GetLocalPos()
            local distance = (ex - x)^2 + (ey - y)^2
            if ey > minimumY and ey < self.topY - 120 and math.abs(ex) < 400 and distance < nearest then
                best, nearest = enemy, distance
            end
        end
    end
    return best
end

function SecondaryWeapon:_Launch(x, y, side, target)
    if #self.missiles >= 8 then return end
    local m = table.remove(self.free)
    if m == nil then
        m = imageNode(self.root.transform, "HomingMissile", 15, 38, Color(0.55, 0.9, 1, 1), BOLT)
        m.tail = imageNode(m.go.transform, "Exhaust", 10, 50, Color(0.25, 0.65, 1, 0.65), BOLT)
        m.tail.rt.anchorMin, m.tail.rt.anchorMax = Vector2(0.5, 0.5), Vector2(0.5, 0.5)
        m.tail.rt.anchoredPosition = Vector2(0, -30)
        m.tail.rt.localRotation = Quaternion.Euler(0, 0, 180)
        -- 固定六段轨迹随导弹回池，轨迹不参与伤害和射线输入。
        m.trail = {}
        for j = 1, 6 do
            local segment = imageNode(self.root.transform, "MissileWake", 3, 1, Color(0.25, 0.75, 1, 0.3))
            segment.go:SetActive(false)
            table.insert(m.trail, segment)
        end
    end
    m.age, m.vx, m.vy, m.target = 0, side * 230, 300, target
    m.points, m.trailTimer = { { x = x, y = y } }, 0
    m.rt.anchoredPosition = Vector2(x, y)
    m.rt.localRotation = Quaternion.Euler(0, 0, -side * 35)
    m.go:SetActive(true)
    table.insert(self.missiles, m)
end

function SecondaryWeapon:_Recycle(index)
    local m = table.remove(self.missiles, index)
    m.go:SetActive(false)
    m.target = nil
    m.points = nil
    for _, segment in ipairs(m.trail) do segment.go:SetActive(false) end
    table.insert(self.free, m)
end

function SecondaryWeapon:_UpdateTrail(m, dt, x, y)
    m.trailTimer = m.trailTimer + dt
    if m.trailTimer >= 0.035 then
        m.trailTimer = m.trailTimer % 0.035
        table.insert(m.points, 1, { x = x, y = y })
        if #m.points > 7 then table.remove(m.points) end
    end
    local head = { x = x, y = y }
    for j, segment in ipairs(m.trail) do
        local point = m.points[j]
        local dx, dy = point and head.x - point.x or 0, point and head.y - point.y or 0
        local length = math.sqrt(dx * dx + dy * dy)
        segment.go:SetActive(length > 0.5)
        if length > 0.5 then
            segment.rt.anchoredPosition = Vector2((head.x + point.x) * 0.5, (head.y + point.y) * 0.5)
            segment.rt.sizeDelta = Vector2(4 * (1 - j / 8), length + 1)
            segment.rt.localRotation = Quaternion.Euler(0, 0, math.atan(-dx, dy) * 180 / math.pi)
            segment.img.color = Color(0.25, 0.75, 1, 0.4 * (1 - j / 7))
        end
        if point then head = point end
    end
end

function SecondaryWeapon:MoveEmitter(x)
    if self.beam.go.activeSelf then
        local p = self.beam.rt.anchoredPosition
        self.beam.rt.anchoredPosition = Vector2(x, p.y)
        local op = self.origin.rt.anchoredPosition
        self.origin.rt.anchoredPosition = Vector2(x, op.y)
        self.contact.go:SetActive(false) -- 拖动后的新命中点由下一帧碰撞计算确认。
    end
end

function SecondaryWeapon:Update(dt, level, x, y, enemies, onHit)
    if dt <= 0 then return end
    if level ~= self.level then
        self:Reset()
        self.level = level
    end
    local nearest = level >= 1 and self:_FindTarget(enemies, x, y, y + 60) or nil
    if level >= 1 then
        self.missileTimer = math.min(MISSILE_INTERVAL, self.missileTimer + dt)
        if nearest ~= nil and self.missileTimer >= MISSILE_INTERVAL then
            self.missileTimer = 0
            for side = -1, 1, 2 do self:_Launch(x + side * 35, y + 18, side, nearest) end
        end
    end
    for i = #self.missiles, 1, -1 do
        local m = self.missiles[i]
        m.age = m.age + dt
        local p = m.rt.anchoredPosition
        local target = m.target
        local targetY = target ~= nil and not target.isDead and target.rt ~= nil and not IsNull(target.rt)
            and select(2, target:GetLocalPos()) or nil
        if targetY == nil or targetY <= y + 40 or targetY >= self.topY - 120 then
            target = self:_FindTarget(enemies, p.x, p.y, y + 40)
            m.target = target
        end
        if target ~= nil and m.age > 0.12 then
            local tx, ty = target:GetLocalPos()
            local dx, dy = tx - p.x, ty - p.y
            local distance = math.max(1, math.sqrt(dx * dx + dy * dy))
            local blend = 1 - math.exp(-6 * dt)
            m.vx = m.vx + (dx / distance * 670 - m.vx) * blend
            m.vy = m.vy + (dy / distance * 670 - m.vy) * blend
        end
        local nx, ny = p.x + m.vx * dt, p.y + m.vy * dt
        m.rt.anchoredPosition = Vector2(nx, ny)
        m.rt.localRotation = Quaternion.Euler(0, 0, math.atan(-m.vx, m.vy) * 180 / math.pi)
        self:_UpdateTrail(m, dt, nx, ny)
        local hit = false
        if target ~= nil then
            local tx, ty = target:GetLocalPos()
            local dx, dy = nx - p.x, ny - p.y
            local t = math.max(0, math.min(1, ((tx-p.x)*dx + (ty-p.y)*dy) / math.max(0.001, dx*dx+dy*dy)))
            hit = (p.x + t*dx - tx)^2 + (p.y + t*dy - ty)^2 <= ((target.collideRadius or 35) + 8)^2
        end
        if hit then
            self:_Recycle(i)
            if onHit(target, 10, nx, ny) then return end
        elseif m.age >= 3.5 or ny > self.topY + 80 or ny < 0 or math.abs(nx) > 480 then
            self:_Recycle(i)
        end
    end
    if level < 2 then return end
    self.laserTimer = math.min(LASER_INTERVAL, self.laserTimer + dt)
    if self.laserRemaining <= 0 and nearest ~= nil and self.laserTimer >= LASER_INTERVAL then
        self.laserRemaining, self.laserTimer = LASER_DURATION, 0
    end
    if self.laserRemaining <= 0 then self:_HideLaser(); return end
    local activeDt = math.min(dt, self.laserRemaining)
    self.laserRemaining = math.max(0, self.laserRemaining - dt)
    self.beam.go:SetActive(self.laserRemaining > 0)
    local startY, endY, first = y + 46, self.topY - 125, nil
    for _, enemy in ipairs(enemies) do
        if not enemy.isDead then
            local ex, ey = enemy:GetLocalPos()
            local radius = (enemy.collideRadius or 35) + 6
            if ey > startY and ey < self.topY - 120 and math.abs(ex - x) <= radius then
                local front = math.max(startY, ey - math.sqrt(radius^2 - (ex-x)^2))
                if front < endY then first, endY = enemy, front end
            end
        end
    end
    local length = math.max(1, endY - startY)
    self.beam.rt.anchoredPosition = Vector2(x, startY + length * 0.5)
    self.beam.rt.sizeDelta = Vector2(18 + math.sin(self.laserRemaining * 70) * 3, length)
    self.core.rt.sizeDelta = Vector2(3, length)
    local visible = self.laserRemaining > 0
    self.origin.go:SetActive(visible)
    self.origin.rt.anchoredPosition = Vector2(x, startY)
    local pulse = 50 + math.sin(self.laserRemaining * 70) * 8
    self.origin.rt.sizeDelta = Vector2(pulse, pulse * 1.2)
    self.contact.go:SetActive(visible and first ~= nil)
    self.contact.rt.anchoredPosition = Vector2(x, endY)
    self.contact.rt.sizeDelta = Vector2(pulse * 1.3, pulse * 1.3)
    if first ~= nil then onHit(first, 24 * activeDt, x, endY) end
end

return SecondaryWeapon
