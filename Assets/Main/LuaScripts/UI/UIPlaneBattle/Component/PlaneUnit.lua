---
--- 探险玩法 战斗 — 战斗单位（僚机 / 敌机 / boss 共用）
--- 首期不做索敌AI，僚机固定向正上方开火（贴合截图：编队跟主机一起平移，
--- 子弹垂直打向前方），命中判定在 View 的主循环里用圆形距离做，不放在单位自身。
---
---@class PlaneUnit
local PlaneUnit = {}
PlaneUnit.__index = PlaneUnit
local FlightVisual = require "UI.UIPlaneBattle.Component.FlightVisual"

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2
local Color         = CS.UnityEngine.Color

--- 从原图集裁出的独立飞机帧，避免把弹药/特效单元一起显示。
local RES_DIR = "Assets/Main/Sprites/STG/Aircraft/"

--- 简易内置属性表（首期不建独立怪物配置表，第二期若要扩展再拆出去）
local UNIT_META = {
    [8001] = { size = Vector2(65, 70),  sprite = "enemy_scout", hp = 30,  speed = 220, collideRadius = 35 },
    [8002] = { size = Vector2(90, 77), sprite = "enemy_interceptor", hp = 60,  speed = 260, collideRadius = 40 },
    [9001] = { size = Vector2(180, 155),sprite = "boss", hp = 500, speed = 0, collideRadius = 80 },
}

--- @param kind string "wingman" | "enemy" | "boss"
--- @param metaId number 仅 enemy/boss 需要，查 UNIT_META
function PlaneUnit.New(parentTransform, kind, metaId, aircraftPath)
    local self = setmetatable({}, PlaneUnit)
    self.kind = kind
    self.metaId = metaId
    self.isDead = false
    self.hitFlashTime = 0

    local meta = UNIT_META[metaId]

    local go = GameObject(kind == "wingman" and "Wingman" or (kind == "boss" and "Boss" or "Enemy"), RectTransform)
    go.transform:SetParent(parentTransform, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)

    local img = go:AddComponent(Image)
    img.raycastTarget = false

    if kind == "wingman" then
        rt.sizeDelta = Vector2(42, 51)
        -- 根节点仍是编队/射击的坐标，机身浮动和倾斜留在独立子节点。
        img.color = Color(1, 1, 1, 0)
        self.flightVisual = FlightVisual.New(go.transform, rt.sizeDelta, aircraftPath or "Assets/Main/Sprites/STG/SpaceRaid/wingman_orange.png")
        img = self.flightVisual.bodyImg
        self.hp = 1
        self.maxHp = 1
        self.collideRadius = 24
        self.speed = 0
        self.fireCd = 0
        self.fireInterval = 0.5 -- 每 0.5 秒开一次火
    else
        rt.sizeDelta = meta and meta.size or Vector2(70, 70)
        img:LoadSprite(RES_DIR .. (meta and meta.sprite or "enemy_scout") .. ".png")
        self.hp = meta and meta.hp or 30
        self.maxHp = self.hp
        self.collideRadius = meta and meta.collideRadius or 35
        self.speed = meta and meta.speed or 200 -- 向下移动速度（像素/秒）
        self.flightTime = 0
        self.spawnX = 0
        self.swayAmplitude = 0
        self.swayFrequency = 0
        self.swayPhase = 0
        self.fireTimer = 0
        self.fireInterval = 0
    end

    self.go = go
    self.rt = rt
    self.img = img

    return self
end

function PlaneUnit:SetLocalPos(x, y)
    if self.rt == nil or IsNull(self.rt) then
        return
    end
    self.rt.anchoredPosition = Vector2(x, y)
end

function PlaneUnit:GetLocalPos()
    if self.rt == nil or IsNull(self.rt) then
        return 0, 0
    end
    local pos = self.rt.anchoredPosition
    return pos.x, pos.y
end

--- 敌机/boss 每帧向下推进（僚机的位置由编队逻辑在 View 里统一驱动，这里不管）
function PlaneUnit:Update(dt)
    if self.kind == "wingman" or self.isDead then
        return
    end
    self.flightTime = (self.flightTime or 0) + dt
    self.hitFlashTime = math.max(0, self.hitFlashTime - dt)
    self.img.color = self.hitFlashTime > 0 and Color(1, 0.4, 0.25, 1) or Color(1, 1, 1, 1)
    if self.healthBarGo ~= nil then
        self.healthBarTime = math.max(0, self.healthBarTime - dt)
        self.healthBarGo:SetActive(self.healthBarTime > 0)
    end
    local x, y = self:GetLocalPos()
    if self.stationY ~= nil and (self.stationEntered or y <= self.stationY) then
        self.stationEntered = true
        local phase = self.flightTime * (self.swayFrequency or 1)
        local stationX = (self.spawnX or 0) + math.sin(phase) * self.swayAmplitude
        local stationY = self.stationY
        -- Boss 二阶段的 figure_eight：横纵两条正弦曲线组合，形成可辨识的 8 字巡航。
        if self.movePattern == "figure_eight" then
            stationY = stationY + math.sin(phase * 2) * (self.verticalSwayAmplitude or 58)
        end
        self:SetLocalPos(stationX, stationY)
    elseif self.speed and self.speed ~= 0 then
        if self.swayAmplitude and self.swayAmplitude > 0 then
            x = (self.spawnX or x) + math.sin(self.flightTime * (self.swayFrequency or 1.5) + (self.swayPhase or 0)) * self.swayAmplitude
        end
        self:SetLocalPos(x, y - self.speed * dt)
    end
end

--- 扣血，返回是否死亡
function PlaneUnit:TakeDamage(damage)
    if self.isDead then
        return true
    end
    self.hp = self.hp - (damage or 0)
    self.hitFlashTime = 0.1
    if self.hp <= 0 then
        self.hp = 0
        self.isDead = true
        return true
    end
    -- 普通敌机仅受损时短暂显示血条，首领继续使用顶部独立血条。
    if self.kind == "enemy" then
        self:_ShowHealthBar()
    end
    return false
end

function PlaneUnit:_ShowHealthBar()
    if self.healthBarGo == nil then
        local go = GameObject("DamageHealthBar", RectTransform)
        go.transform:SetParent(self.go.transform, false)
        local rt = go:GetComponent(RectTransform)
        rt.sizeDelta = Vector2(48, 6)
        rt.anchoredPosition = Vector2(0, self.rt.sizeDelta.y * 0.5 + 10)
        local bg = go:AddComponent(Image)
        bg.color = Color(0.03, 0.06, 0.09, 0.9)
        bg.raycastTarget = false
        local fillGo = GameObject("Fill", RectTransform)
        fillGo.transform:SetParent(go.transform, false)
        local fillRt = fillGo:GetComponent(RectTransform)
        fillRt.anchorMin = Vector2(0, 0.5)
        fillRt.anchorMax = Vector2(0, 0.5)
        fillRt.pivot = Vector2(0, 0.5)
        fillRt.anchoredPosition = Vector2(1, 0)
        local fill = fillGo:AddComponent(Image)
        fill.color = Color(1, 0.68, 0.2, 1)
        fill.raycastTarget = false
        self.healthBarGo = go
        self.healthBarFillRt = fillRt
    end
    self.healthBarTime = 1.2
    self.healthBarFillRt.sizeDelta = Vector2(46 * math.max(0, math.min(1, self.hp / self.maxHp)), 4)
    self.healthBarGo:SetActive(true)
end

function PlaneUnit:Destroy()
    if self.go ~= nil and not IsNull(self.go) then
        self.go:Destroy()
    end
    self.go = nil
    self.rt = nil
    self.img = nil
    self.flightVisual = nil
    self.healthBarGo = nil
    self.healthBarFillRt = nil
    self.healthBarTime = nil
end

return PlaneUnit
