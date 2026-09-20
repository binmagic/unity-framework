---
--- 探险玩法 战斗 — 油桶（血量数字）
--- 参考 barrel（D:\UnityProject\barrel）Bucket.lua 的设计思路：顶着一个数字当血量，
--- 被僚机子弹命中扣血，文本实时刷新，血量到 0 播放消失并触发掉落效果。
---
---@class BucketComponent
local BucketComponent = {}
BucketComponent.__index = BucketComponent

local GameObject     = CS.UnityEngine.GameObject
local RectTransform  = typeof(CS.UnityEngine.RectTransform)
local Image          = typeof(CS.UnityEngine.UI.Image)
local Text           = typeof(CS.UnityEngine.UI.Text)
local Vector2        = CS.UnityEngine.Vector2
local Color          = CS.UnityEngine.Color

--- 美术资源目录（从 D:\UnityProject\UiSource\雷霆战机 迁入，命名前缀 PlaneBattle_）
local RES_DIR = "Assets/Main/Sprites/PlaneBattle/"

local BUCKET_SIZE    = Vector2(111, 78)
local FALL_SPEED     = 200
local COLLIDE_RADIUS = 40

--- @param hp number 初始血量
--- @param triggerMeta table|nil 血量打空后触发的掉落效果
function BucketComponent.New(parentTransform, x, y, hp, triggerMeta)
    local self = setmetatable({}, BucketComponent)
    self.triggerMeta = triggerMeta
    self.hp = tonumber(hp) or 1
    self.maxHp = self.hp
    self.isDead = false
    self.collideRadius = COLLIDE_RADIUS

    local go = GameObject("Bucket", RectTransform)
    go.transform:SetParent(parentTransform, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)
    rt.sizeDelta = BUCKET_SIZE
    rt.anchoredPosition = Vector2(x, y)

    local img = go:AddComponent(Image)
    img:LoadSprite(RES_DIR .. "PlaneBattle_bucket.png")

    local txtGo = GameObject("Text", RectTransform)
    txtGo.transform:SetParent(go.transform, false)
    local txtRt = txtGo:GetComponent(RectTransform)
    txtRt.anchorMin = Vector2(0, 0)
    txtRt.anchorMax = Vector2(1, 1)
    txtRt.offsetMin = Vector2(0, 0)
    txtRt.offsetMax = Vector2(0, 10)
    local txt = txtGo:AddComponent(Text)
    txt.font      = CS.UnityEngine.Resources.GetBuiltinResource(typeof(CS.UnityEngine.Font), "LegacyRuntime.ttf")
    txt.fontSize  = 28
    txt.fontStyle = CS.UnityEngine.FontStyle.Bold
    txt.alignment = CS.UnityEngine.TextAnchor.MiddleCenter
    txt.color     = Color(1, 1, 1, 1)

    self.go  = go
    self.rt  = rt
    self.txt = txt
    self:_RefreshText()

    return self
end

function BucketComponent:_RefreshText()
    if self.txt ~= nil and not IsNull(self.txt) then
        self.txt.text = tostring(math.max(0, math.floor(self.hp)))
    end
end

function BucketComponent:GetLocalPos()
    if self.rt == nil or IsNull(self.rt) then
        return 0, 0
    end
    local pos = self.rt.anchoredPosition
    return pos.x, pos.y
end

function BucketComponent:Update(dt)
    if self.rt == nil or IsNull(self.rt) then
        return
    end
    local pos = self.rt.anchoredPosition
    self.rt.anchoredPosition = Vector2(pos.x, pos.y - FALL_SPEED * dt)
end

--- 扣血，返回是否本次打空（死亡）
function BucketComponent:TakeDamage(damage)
    if self.isDead then
        return false
    end
    self.hp = self.hp - (damage or 0)
    if self.hp <= 0 then
        self.hp = 0
        self.isDead = true
        self:_RefreshText()
        return true
    end
    self:_RefreshText()
    return false
end

function BucketComponent:IsOutOfBounds(bottomY)
    local _, y = self:GetLocalPos()
    return y < bottomY
end

function BucketComponent:Destroy()
    if self.go ~= nil and not IsNull(self.go) then
        self.go:Destroy()
    end
    self.go  = nil
    self.rt  = nil
    self.txt = nil
end

return BucketComponent
