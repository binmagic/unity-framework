---
--- 探险玩法 战斗 — 数字门
--- 参考 barrel（D:\UnityProject\barrel）UpgradeableDuetGate 的设计思路：一对门左右各自独立，
--- 主机穿过哪一侧的 x 范围，就执行哪一侧配置的触发效果。换算成 2D：门是横排的一条 Image，
--- 从上往下移动，主机与门同一 Y 高度时按 x 落在左半/右半判定。
---
--- 三种门（kind）：
---   add      加兵木箱门，text 形如 "+2"
---   subtract 减兵红铁栅栏门，text 形如 "-1"
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

--- 美术资源目录（冒险号素材包 D:\UnityProject\UiSource\冒险号 迁入，命名前缀 PlaneBattle_）
local RES_DIR = "Assets/Main/Sprites/PlaneBattle/"

--- 每种门的显示尺寸（按素材原始长宽比估算，避免拉伸变形）+ 对应贴图
local GATE_VISUAL = {
    add      = { size = Vector2(140, 140), sprite = "PlaneBattle_gate_add.png" },
    subtract = { size = Vector2(150, 84),  sprite = "PlaneBattle_gate_subtract.png" },
    lock     = { size = Vector2(500, 322), sprite = "PlaneBattle_gate_lock.png" },
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
    img:LoadSprite(RES_DIR .. visual.sprite)

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
    txt.color     = Color(1, 1, 1, 1)

    -- 换真实美术后底图不再是纯色块，白字直接叠上去容易被贴图花纹吃掉，补黑色描边保证可读性
    local outline = txtGo:AddComponent(Outline)
    outline.effectColor = Color(0, 0, 0, 1)
    outline.effectDistance = Vector2(2, -2)

    self.go = go
    self.rt = rt

    return self
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
    self.rt.anchoredPosition = Vector2(pos.x, pos.y - FALL_SPEED * dt)
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
    if math.abs(gateY - playerY) < TRIGGER_HALF_H and inX then
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
end

return GateComponent
