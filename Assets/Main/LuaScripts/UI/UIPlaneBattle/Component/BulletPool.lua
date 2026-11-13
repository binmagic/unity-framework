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
local Color         = CS.UnityEngine.Color

local BULLET_SIZE   = Vector2(11, 40)
local BULLET_SPEED  = 900 -- 像素/秒
local MAX_ACTIVE    = 240 -- 三发编队的容量，同时为敌弹保留空间
local PLAYER_SOFT_LIMIT = 192
local SCREEN_SIDE_X = 440 -- 已完全离开横向战场的散射弹立即回池

function BulletPool.New(parentTransform)
    local self = {
        parent  = parentTransform,
        freeList = {},   -- 空闲子弹节点池
        active   = {},   -- 当前飞行中的子弹 { go, rt, vx, vy, damage, faction }
        topY = math.max(1625, parentTransform.rect.height) + 100,
    }
    setmetatable(self, { __index = BulletPool })
    local function layer(name)
        local go = GameObject(name, RectTransform)
        go.transform:SetParent(parentTransform, false)
        local rt = go:GetComponent(RectTransform)
        rt.anchorMin, rt.anchorMax = Vector2(0, 0), Vector2(1, 1)
        rt.offsetMin, rt.offsetMax = Vector2(0, 0), Vector2(0, 0)
        return go.transform
    end
    self.playerLayer = layer("PlayerBullets")
    local background = parentTransform:Find("BackgroundRoot")
    if background ~= nil then self.playerLayer:SetSiblingIndex(background:GetSiblingIndex()+1) end
    self.enemyLayer = layer("EnemyBullets")
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
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.sizeDelta = BULLET_SIZE
    local img = go:AddComponent(Image)
    img.raycastTarget = false
    img:LoadSprite("Assets/Main/Sprites/STG/CombatFx/energy_bolt.png")
    local coreGo = GameObject("BrightCore", RectTransform)
    coreGo.transform:SetParent(go.transform, false)
    local coreRt = coreGo:GetComponent(RectTransform)
    coreRt.anchorMin, coreRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    coreRt.offsetMin, coreRt.offsetMax = Vector2(3, 3), Vector2(-3, -3)
    local core = coreGo:AddComponent(Image)
    core.raycastTarget = false
    core.color = Color(1, 1, 1, 0.85)
    core:LoadSprite("Assets/Main/Sprites/STG/CombatFx/energy_bolt.png")
    local haloGo = GameObject("EnemyHalo", RectTransform)
    haloGo.transform:SetParent(go.transform, false)
    haloGo.transform:SetAsFirstSibling()
    local haloRt = haloGo:GetComponent(RectTransform)
    haloRt.anchorMin, haloRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    haloRt.offsetMin, haloRt.offsetMax = Vector2(-6, -4), Vector2(6, 4)
    local halo = haloGo:AddComponent(Image)
    halo.color, halo.raycastTarget = Color(1, 0.14, 0.2, 0.7), false
    halo:LoadSprite("Assets/Main/Sprites/STG/CombatFx/shield_hit.png")
    haloGo:SetActive(false)
    return go
end

--- 发射一颗子弹
--- @param x number 起始点 anchoredPosition.x
--- @param y number 起始点 anchoredPosition.y
--- @param dirY number 飞行方向：1=向上(僚机打敌机) -1=向下(敌机打主机)
--- @param damage number 伤害
--- faction: "player" | "enemy"；由 View 按阵营分别处理命中。
--- vx: 横向速度，用于散射弹道。
function BulletPool:Fire(x, y, dirY, damage, faction, vx, weaponLevel, primary, sourceId, heroSkill, weaponMode)
    if #self.active >= MAX_ACTIVE then
        return false -- 同屏子弹已达上限，直接丢弃这次开火请求
    end
    if (faction or "player") == "player" and #self.active >= PLAYER_SOFT_LIMIT then return false end

    local go = self:_Acquire()
    local bulletLayer = faction == "enemy" and self.enemyLayer or self.playerLayer
    go.transform:SetParent(bulletLayer, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchoredPosition = Vector2(x, y)
    local img = go:GetComponent(Image)
    faction = faction or "player"
    local vy = (faction == "enemy" and 310 or BULLET_SPEED) * (dirY or 1)
    vx = vx or 0
    rt.localRotation = CS.UnityEngine.Quaternion.Euler(0, 0, math.atan(-vx, vy) * 180 / math.pi)
    img.color = faction == "enemy" and Color(1, 0.3, 0.22, 0.95) or Color(0.45, 0.9, 1, 1)
    rt.sizeDelta = BULLET_SIZE
    if faction == "player" and (weaponLevel or 0) > 0 then
        img.color = weaponLevel == 1 and Color(0.45, 0.65, 1, 1) or Color(1, 0.65, 0.25, 1)
        rt.sizeDelta = Vector2(9, weaponLevel == 1 and 44 or 34)
    end
    if faction == "player" and primary then
        -- 主炮更粗、更亮；池化复用时上面的默认值先恢复，避免污染敌弹/僚机弹。
        rt.sizeDelta = Vector2(14, (weaponLevel or 0) >= 2 and 46 or 58)
        img.color = (weaponLevel or 0) >= 2 and Color(1, 0.85, 0.4, 1) or Color(0.65, 0.95, 1, 1)
    end

    local core = go.transform:Find("BrightCore"):GetComponent(Image)
    local haloGo = go.transform:Find("EnemyHalo").gameObject
    haloGo:SetActive(faction == "enemy")
    if faction == "enemy" then
        rt.sizeDelta, img.color = Vector2(16, 26), Color(1, 0.18, 0.28, 1)
        core.color = Color(1, 0.85, 0.7, 1)
        -- 敌弹优先画在友军火力上面，保留可躲避的红色轮廓。
        self.enemyLayer:SetAsLastSibling()
    else
        if not primary and not heroSkill then
            local hero = sourceId ~= nil
            rt.sizeDelta = hero and Vector2(9, 32) or Vector2(6, 24)
            img.color = hero and Color(0.45, 0.85, 1, 0.9) or Color(0.35, 0.7, 1, 0.68)
            core.color = Color(0.7, 0.92, 1, hero and 0.55 or 0.2)
        else
            core.color = Color(1, 1, 1, 0.85)
        end
    end

    weaponMode = faction == "player" and not heroSkill and weaponMode or "spread"
    if weaponMode == "pierce" then
        img.color = Color(0.7, 0.4, 1, 1)
        rt.sizeDelta = Vector2(primary and 15 or 8, primary and 76 or 42)
    elseif weaponMode == "homing" then
        img.color = Color(0.3, 1, 0.6, 1)
    end
    table.insert(self.active, {
        go     = go,
        rt     = rt,
        vy     = vy,
        vx     = vx,
        damage = damage or 1,
        faction = faction,
        primary = primary == true,
        sourceId = sourceId,
        heroSkill = heroSkill == true,
        previousX = x,
        previousY = y,
        weaponMode = weaponMode,
        remainingHits = weaponMode == "pierce" and 3 or 1,
        hitTargets = weaponMode == "pierce" and {} or nil,
    })
    return true
end

--- 每帧推进所有子弹，超出边界的回收
--- @param dt number Time.deltaTime
--- @param onOutOfBounds function(bullet) 可选：子弹飞出屏幕时的回调（首期不需要额外处理）
function BulletPool:Update(dt, enemies)
    local i = 1
    while i <= #self.active do
        local b = self.active[i]
        if IsNull(b.go) then
            table.remove(self.active, i)
        else
            local pos = b.rt.anchoredPosition
            b.previousX, b.previousY = pos.x, pos.y
            if b.weaponMode == "homing" then
                local target, nearest = nil, math.huge
                for _, enemy in ipairs(enemies or {}) do
                    if not enemy.isDead then
                        local ex, ey = enemy:GetLocalPos()
                        local dx, dy = ex - pos.x, ey - pos.y
                        local distance = dx * dx + dy * dy
                        if dy > 0 and distance < nearest then target, nearest = dx, distance end
                    end
                end
                if target ~= nil then
                    local desired = math.max(-480, math.min(480, target * 4))
                    b.vx = b.vx + (desired - b.vx) * math.min(1, dt * 7)
                    b.rt.localRotation = CS.UnityEngine.Quaternion.Euler(0, 0, math.atan(-b.vx, b.vy) * 180 / math.pi)
                end
            end
            local newY = pos.y + b.vy * dt
            local newX = pos.x + (b.vx or 0) * dt
            if newY > self.topY or newY < -60 or math.abs(newX) > SCREEN_SIDE_X then
                b.go:SetActive(false)
                table.insert(self.freeList, b.go)
                table.remove(self.active, i)
            else
                b.rt.anchoredPosition = Vector2(newX, newY)
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
