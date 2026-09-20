---
--- 探险玩法 战斗 — 战斗单位（僚机 / 敌机 / boss 共用）
--- 首期不做索敌AI，僚机固定向正上方开火（贴合截图：编队跟主机一起平移，
--- 子弹垂直打向前方），命中判定在 View 的主循环里用圆形距离做，不放在单位自身。
---
---@class PlaneUnit
local PlaneUnit = {}
PlaneUnit.__index = PlaneUnit

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

--- 美术资源目录（从 D:\UnityProject\UiSource\雷霆战机 迁入，命名前缀 PlaneBattle_）
local RES_DIR = "Assets/Main/Sprites/PlaneBattle/"

--- 简易内置属性表（首期不建独立怪物配置表，第二期若要扩展再拆出去）
local UNIT_META = {
    [8001] = { size = Vector2(85, 29),  sprite = "PlaneBattle_enemy1", hp = 30,  speed = 220, collideRadius = 35 }, -- 普通敌机
    [8002] = { size = Vector2(60, 121), sprite = "PlaneBattle_enemy2", hp = 60,  speed = 260, collideRadius = 40 }, -- 进阶敌机
    [9001] = { size = Vector2(180, 134),sprite = "PlaneBattle_boss",   hp = 500, speed = 0,   collideRadius = 80 }, -- 首关boss
}

--- @param kind string "wingman" | "enemy" | "boss"
--- @param metaId number 仅 enemy/boss 需要，查 UNIT_META
function PlaneUnit.New(parentTransform, kind, metaId)
    local self = setmetatable({}, PlaneUnit)
    self.kind = kind
    self.metaId = metaId
    self.isDead = false

    local meta = UNIT_META[metaId]

    local go = GameObject(kind == "wingman" and "Wingman" or (kind == "boss" and "Boss" or "Enemy"), RectTransform)
    go.transform:SetParent(parentTransform, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)

    local img = go:AddComponent(Image)

    if kind == "wingman" then
        rt.sizeDelta = Vector2(46, 73)
        img:LoadSprite(RES_DIR .. "PlaneBattle_wingman.png")
        self.hp = 1
        self.maxHp = 1
        self.collideRadius = 24
        self.speed = 0
        self.fireCd = 0
        self.fireInterval = 0.5 -- 每 0.5 秒开一次火
    else
        rt.sizeDelta = meta and meta.size or Vector2(70, 70)
        img:LoadSprite(RES_DIR .. (meta and meta.sprite or "PlaneBattle_enemy1") .. ".png")
        self.hp = meta and meta.hp or 30
        self.maxHp = self.hp
        self.collideRadius = meta and meta.collideRadius or 35
        self.speed = meta and meta.speed or 200 -- 向下移动速度（像素/秒）
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
    if self.speed and self.speed ~= 0 then
        local x, y = self:GetLocalPos()
        self:SetLocalPos(x, y - self.speed * dt)
    end
end

--- 扣血，返回是否死亡
function PlaneUnit:TakeDamage(damage)
    if self.isDead then
        return true
    end
    self.hp = self.hp - (damage or 0)
    if self.hp <= 0 then
        self.hp = 0
        self.isDead = true
        return true
    end
    return false
end

function PlaneUnit:Destroy()
    if self.go ~= nil and not IsNull(self.go) then
        self.go:Destroy()
    end
    self.go = nil
    self.rt = nil
    self.img = nil
end

return PlaneUnit
