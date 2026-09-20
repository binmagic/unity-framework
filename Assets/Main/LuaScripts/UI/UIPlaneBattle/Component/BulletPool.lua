---
--- 探险玩法 战斗 — 子弹对象池
--- 同屏子弹数量有上限，超过上限的开火请求直接丢弃（不排队），避免 Lua<->C# 调用堆积。
--- 子弹本身是最简单的 Image 节点，直线向上飞，飞出屏幕或命中后回池。
---
local BulletPool = {}

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

--- 美术资源目录（从 D:\UnityProject\UiSource\雷霆战机 迁入，命名前缀 PlaneBattle_）
local RES_DIR = "Assets/Main/Sprites/PlaneBattle/"

local BULLET_SIZE   = Vector2(11, 40)
local BULLET_SPEED  = 900 -- 像素/秒
local MAX_ACTIVE    = 60  -- 同屏子弹上限
local SCREEN_TOP_Y  = 1000 -- 超出这个高度视为飞出屏幕（略大于参考分辨率半高）

function BulletPool.New(parentTransform)
    local self = {
        parent  = parentTransform,
        freeList = {},   -- 空闲子弹节点池
        active   = {},   -- 当前飞行中的子弹 { go, rt, vx, vy, damage, faction }
    }
    setmetatable(self, { __index = BulletPool })
    return self
end

--- 从池里取一个子弹节点（没有就新建）
function BulletPool:_Acquire()
    local go = table.remove(self.freeList)
    if go ~= nil and not IsNull(go) then
        go:SetActive(true)
        return go
    end

    go = GameObject("Bullet", RectTransform)
    go.transform:SetParent(self.parent, false)
    local rt = go:GetComponent(RectTransform)
    rt.sizeDelta = BULLET_SIZE
    local img = go:AddComponent(Image)
    img:LoadSprite(RES_DIR .. "PlaneBattle_bullet.png")
    return go
end

--- 发射一颗子弹
--- @param x number 起始点 anchoredPosition.x
--- @param y number 起始点 anchoredPosition.y
--- @param dirY number 飞行方向：1=向上(僚机打敌机) -1=向下(敌机打主机)
--- @param damage number 伤害
function BulletPool:Fire(x, y, dirY, damage)
    if #self.active >= MAX_ACTIVE then
        return -- 同屏子弹已达上限，直接丢弃这次开火请求
    end

    local go = self:_Acquire()
    local rt = go:GetComponent(RectTransform)
    rt.anchoredPosition = Vector2(x, y)

    table.insert(self.active, {
        go     = go,
        rt     = rt,
        vy     = BULLET_SPEED * (dirY or 1),
        damage = damage or 1,
    })
end

--- 每帧推进所有子弹，超出边界的回收
--- @param dt number Time.deltaTime
--- @param onOutOfBounds function(bullet) 可选：子弹飞出屏幕时的回调（首期不需要额外处理）
function BulletPool:Update(dt)
    local i = 1
    while i <= #self.active do
        local b = self.active[i]
        if IsNull(b.go) then
            table.remove(self.active, i)
        else
            local pos = b.rt.anchoredPosition
            local newY = pos.y + b.vy * dt
            if newY > SCREEN_TOP_Y or newY < -SCREEN_TOP_Y then
                b.go:SetActive(false)
                table.insert(self.freeList, b.go)
                table.remove(self.active, i)
            else
                b.rt.anchoredPosition = Vector2(pos.x, newY)
                i = i + 1
            end
        end
    end
end

--- 命中判定用：遍历当前活跃子弹（只读，调用方自行做距离判定后调用 :Remove(b)）
function BulletPool:GetActiveList()
    return self.active
end

--- 命中后移除子弹（回池）
function BulletPool:Remove(bullet)
    for i, b in ipairs(self.active) do
        if b == bullet then
            if not IsNull(b.go) then
                b.go:SetActive(false)
                table.insert(self.freeList, b.go)
            end
            table.remove(self.active, i)
            return
        end
    end
end

function BulletPool:Clear()
    for _, b in ipairs(self.active) do
        if not IsNull(b.go) then
            b.go:Destroy()
        end
    end
    self.active = {}

    for _, go in ipairs(self.freeList) do
        if not IsNull(go) then
            go:Destroy()
        end
    end
    self.freeList = {}
end

return BulletPool
