---
--- STG 怪物子系统 — 2D 怪物/机关基类
--- 提炼自 ParkourBattle/Monster/MonsterImpl/MonsterObj.lua 的职责（位置管理/血量/死亡流程），
--- 但去掉了原实现里的 3D 预制体异步加载、旧战斗框架单例依赖，改成对齐 STG PlaneUnit.lua 的写法：
--- 用 UGUI Image 承载表现，构造时直接创建 GameObject，不经过 Prefab。
---
--- 子类通过 super 继承拿到位置/血量/死亡的通用实现，只需要覆写 GetSpritePath/OnDeath 等钩子。
--- 移动方式统一为直线/插值（不做寻路避障），朝向用水平翻转表达，不使用 3D 旋转。
---
--- 用法：
---   local obj = SomeMonster2D.New(parentTransform, x, y, hp, spritePath)
---   obj:Update(dt)          -- 每帧调用，驱动直线移动
---   obj:TakeDamage(amount)  -- 返回是否死亡
---   obj:Destroy()
---
---@class Monster2DBase
local Monster2DBase = BaseClass("Monster2DBase")

local GameObject     = CS.UnityEngine.GameObject
local RectTransform  = typeof(CS.UnityEngine.RectTransform)
local Image          = typeof(CS.UnityEngine.UI.Image)
local Vector2        = CS.UnityEngine.Vector2

--- @param parentTransform userdata UI 父节点
--- @param x number 初始屏幕 X
--- @param y number 初始屏幕 Y
--- @param hp number 初始血量
--- @param sizeVec2 userdata|nil Vector2，默认 70x70
function Monster2DBase:__init(parentTransform, x, y, hp, sizeVec2)
    self.isDead = false
    self.hp = hp or 1
    self.maxHp = self.hp
    self.speed = 0          -- 直线移动速度（像素/秒），静止物体保持 0
    self.moveDirX = 0       -- 移动方向单位向量，默认不移动
    self.moveDirY = -1

    local go = GameObject(self:GetGoName(), RectTransform)
    go.transform:SetParent(parentTransform, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)
    rt.sizeDelta = sizeVec2 or Vector2(70, 70)
    rt.anchoredPosition = Vector2(x or 0, y or 0)

    local img = go:AddComponent(Image)
    local spritePath = self:GetSpritePath()
    if spritePath ~= nil and spritePath ~= "" then
        img:LoadSprite(spritePath)
    end

    self.go = go
    self.rt = rt
    self.img = img
end

--- 子类覆写：GameObject 显示名，默认用类名
function Monster2DBase:GetGoName()
    return "Monster2D"
end

--- 子类覆写：初始贴图路径，基类不强制要求（比如箭塔可能有多段子节点贴图，自己在 InitView 里处理）
function Monster2DBase:GetSpritePath()
    return nil
end

function Monster2DBase:SetLocalPos(x, y)
    if self.rt == nil or IsNull(self.rt) then
        return
    end
    self.rt.anchoredPosition = Vector2(x, y)
end

function Monster2DBase:GetLocalPos()
    if self.rt == nil or IsNull(self.rt) then
        return 0, 0
    end
    local pos = self.rt.anchoredPosition
    return pos.x, pos.y
end

--- 设置直线移动方向和速度（方向会被归一化），speed=0 表示静止
--- @param dirX number
--- @param dirY number
--- @param speed number 像素/秒
function Monster2DBase:SetMove(dirX, dirY, speed)
    local len = math.sqrt(dirX * dirX + dirY * dirY)
    if len > 0.0001 then
        self.moveDirX = dirX / len
        self.moveDirY = dirY / len
    end
    self.speed = speed or 0
    self:_RefreshFacing()
end

--- 朝向表达：水平翻转 sprite，不使用 3D 旋转（对齐用户确认的 2D 化方向）
function Monster2DBase:_RefreshFacing()
    if self.rt == nil or IsNull(self.rt) then
        return
    end
    if self.moveDirX < -0.0001 then
        self.rt.localScale = Vector2(-1, 1)
    elseif self.moveDirX > 0.0001 then
        self.rt.localScale = Vector2(1, 1)
    end
end

--- 每帧推进：按 SetMove 设置的方向和速度做直线位移。静止物体（speed=0）跳过。
--- 需要更复杂运动（追踪/正弦摆动等）的子类应覆写此方法。
function Monster2DBase:Update(dt)
    if self.isDead or self.speed == 0 then
        return
    end
    local x, y = self:GetLocalPos()
    self:SetLocalPos(x + self.moveDirX * self.speed * dt, y + self.moveDirY * self.speed * dt)
end

--- 扣血，返回是否死亡。子类可覆写 OnDeath 钩子处理死亡表现（掉落/死亡动画等）。
--- @param damage number
--- @return boolean isDead
function Monster2DBase:TakeDamage(damage)
    if self.isDead then
        return true
    end
    self.hp = self.hp - (damage or 0)
    if self.hp <= 0 then
        self.hp = 0
        self.isDead = true
        self:OnDeath()
        return true
    end
    return false
end

--- 子类覆写：死亡时的表现钩子（原 ParkourBattle 版本这里是 ragdoll 物理，
--- 2D 化后按用户确认的方向直接改成"只播放死亡动画"，具体动画由子类决定）
function Monster2DBase:OnDeath()
end

function Monster2DBase:GetHp()
    return self.hp
end

function Monster2DBase:IsDead()
    return self.isDead
end

function Monster2DBase:Destroy()
    if self.go ~= nil and not IsNull(self.go) then
        self.go:Destroy()
    end
    self.go = nil
    self.rt = nil
    self.img = nil
end

return Monster2DBase
