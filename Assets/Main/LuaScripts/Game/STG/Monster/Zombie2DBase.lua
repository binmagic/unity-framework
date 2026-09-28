---
--- STG 怪物子系统 — 僵尸类共享骨架
--- 提炼自 ParkourBattle/Monster/MonsterImpl/CommonAIMonster.lua 的核心状态机骨架：
--- Idle → Run（追踪目标）→ Attack（进入范围发起攻击）→ Hurt/Stun（受击打断）→ Die。
--- 去掉了原实现里的 RVO 寻路（LWBattleRVOAgent）、SkillManager 技能系统、HpBar UI、
--- ragdoll 死亡物理，移动改成直线朝目标点插值（对齐用户确认的 2D 化方向），受击/攻击的
--- 判定改成纯几何距离比较，不依赖旧战斗框架的目标查找/技能释放接口。
---
--- 子类通过覆写 GetAttackAniName/GetRunAniName 等钩子表达差异化表现，
--- 通过覆写 OnAttack/OnHurt/OnDeath 表达差异化数值逻辑（护盾层、分阶段外观等）。
---
--- 状态机（对齐原版 ZombieState 五态，去掉了 Ragdoll）：
---   Idle  — 静止等待，OnGameStart 后转 Run
---   Run   — 朝目标追踪移动，进入 attackRange 后转 Attack
---   Attack— 停止移动，执行一次攻击回调，冷却后转回 Run 或保持 Attack（由子类决定）
---   Hurt  — 受击硬直态，短暂持续后转回 Run
---   Stun  — 更长的眩晕态，外部调用触发
---   Die   — 死亡，停止一切更新
---
--- 用法：
---   local zombie = Zombie2DBase.New(parentTransform, x, y, {
---       hp = 30, speed = 60, attackRange = 40, attackCooldownSec = 1,
---       onAttack = function(zombie) --[[ 造成伤害/生成子弹 ]] end,
---   })
---   zombie:SetTarget(targetXGetter, targetYGetter)  -- 传两个返回坐标的函数，不强依赖具体目标类型
---   zombie:Update(dt)
---
---@class Zombie2DBase : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local Zombie2DBase = BaseClass("Zombie2DBase", Monster2DBase)

--- 对齐原版 ZombieState 枚举，去掉 Ragdoll（2D 化不做骨骼死亡物理，直接播放死亡动画）
local State = {
    Idle   = "idle",
    Run    = "run",
    Attack = "attack",
    Hurt   = "hurt",
    Stun   = "stun",
    Die    = "die",
}
Zombie2DBase.State = State

local HURT_DURATION_SEC = 0.5  -- 对齐原版 BeAttack 里 self.fsm:ChangeState(ZombieState.Hurt, 0.5)

--- @param cfg table
---   hp                 number  初始血量
---   speed              number  追踪移动速度（像素/秒）
---   attackRange         number  进入该距离即从 Run 切到 Attack
---   attackCooldownSec   number  两次攻击之间的冷却
---   sizeVec2           userdata Vector2，可选
---   spritePath         string  可选
---   onAttack           fun(zombie:Zombie2DBase)  进入攻击态时触发一次
function Zombie2DBase:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    Monster2DBase.__init(self, parentTransform, x, y, self.cfg.hp or 1, self.cfg.sizeVec2)

    self.chaseSpeed = self.cfg.speed or 60
    self.attackRange = self.cfg.attackRange or 40
    self.attackCooldownSec = self.cfg.attackCooldownSec or 1
    self.onAttack = self.cfg.onAttack

    self.state = State.Idle
    self.stateTimer = 0
    self.getTargetX = nil
    self.getTargetY = nil
end

function Zombie2DBase:GetGoName()
    return "Zombie2DBase"
end

function Zombie2DBase:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 设置追踪目标：传两个取坐标的函数，不强绑定具体的目标类型（僚机编队/玩家角色都可以）
function Zombie2DBase:SetTarget(getTargetX, getTargetY)
    self.getTargetX = getTargetX
    self.getTargetY = getTargetY
end

--- 对齐原版 OnGameStart：外部调用后从 Idle 切到 Run，开始追踪
function Zombie2DBase:OnGameStart()
    if self.state == State.Idle then
        self:_ChangeState(State.Run)
    end
end

function Zombie2DBase:_ChangeState(newState)
    self.state = newState
    self.stateTimer = 0
end

--- 每帧驱动状态机，覆盖 Monster2DBase 的直线移动（僵尸的移动方向要每帧朝目标重算，
--- 不是固定方向，所以不复用父类 SetMove 的固定方向逻辑，直接在这里算位移）
function Zombie2DBase:Update(dt)
    if self.isDead then
        return
    end
    self.stateTimer = self.stateTimer + dt

    if self.state == State.Run then
        self:_UpdateRun(dt)
    elseif self.state == State.Attack then
        self:_UpdateAttack(dt)
    elseif self.state == State.Hurt then
        if self.stateTimer >= (self.hurtDurationSec or HURT_DURATION_SEC) then
            self:_ChangeState(State.Run)
        end
    end
    -- Idle/Stun/Die 不做位移，Stun 的解除由外部 UnFreeze 调用触发，Die 不再更新
end

--- 追踪态：朝目标直线插值移动，距离进入 attackRange 即切到 Attack（对齐原版 45 度角判定
--- 在 2D 里简化为纯距离判定，不做朝向锥形角度检查——2D 精灵没有朝向锥形攻击的必要性）
function Zombie2DBase:_UpdateRun(dt)
    if self.getTargetX == nil then
        return
    end
    local tx, ty = self.getTargetX(), self.getTargetY()
    local x, y = self:GetLocalPos()
    local dx, dy = tx - x, ty - y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist <= self.attackRange then
        self:_ChangeState(State.Attack)
        return
    end

    if dist > 0.0001 then
        local moveX = dx / dist * self.chaseSpeed * dt
        local moveY = dy / dist * self.chaseSpeed * dt
        self:SetLocalPos(x + moveX, y + moveY)
        self:SetMove(dx, dy, 0)  -- 只借用父类的朝向翻转，speed 传 0 避免重复位移
    end
end

--- 攻击态：冷却结束触发一次 onAttack 回调，之后按目标是否还在范围内决定留在 Attack 还是回到 Run
function Zombie2DBase:_UpdateAttack(dt)
    if self.stateTimer < self.attackCooldownSec then
        return
    end
    self.stateTimer = 0

    if self.onAttack ~= nil then
        self.onAttack(self)
    end

    if self.getTargetX ~= nil then
        local tx, ty = self.getTargetX(), self.getTargetY()
        local x, y = self:GetLocalPos()
        local dx, dy = tx - x, ty - y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > self.attackRange then
            self:_ChangeState(State.Run)
        end
    end
end

--- 受击：对齐原版 BeAttack 的核心分支——扣血、判断是否致命、非致命才进 Hurt 硬直。
--- 子类（护盾类）应覆写此方法先处理护盾层，再调用 Zombie2DBase.TakeDamage(self, damage) 处理本体血量。
--- @param damage number
--- @return boolean isDead
function Zombie2DBase:TakeDamage(damage)
    if self.isDead then
        return true
    end
    local isDead = Monster2DBase.TakeDamage(self, damage)
    if not isDead and self.state ~= State.Attack then
        self:EnterHurt()
    end
    return isDead
end

--- 进入 Hurt 硬直态，可选覆盖本次硬直的持续时长（不传则用默认 0.5 秒）。
--- 提供给需要"非标准硬直时长"的子类（如 PoliceOfficeBigBoss2D 阶段切换时的硬直窗口）调用，
--- 避免子类直接摆弄 stateTimer/State 内部字段。
--- @param durationSec number|nil
function Zombie2DBase:EnterHurt(durationSec)
    self.hurtDurationSec = durationSec  -- nil 时 _UpdateRun/Update 会回退到默认 HURT_DURATION_SEC
    self:_ChangeState(State.Hurt)
end

--- 眩晕：外部调用触发，比 Hurt 更长，需要外部调用 UnFreeze 解除（对齐原版 Freeze/UnFreeze 语义）
function Zombie2DBase:Freeze()
    self:_ChangeState(State.Stun)
end

function Zombie2DBase:UnFreeze()
    if self.state == State.Stun then
        self:_ChangeState(State.Run)
    end
end

--- 死亡：对齐原版 Death 分支，但去掉 ragdoll 判断，直接进 Die 状态（只播放死亡动画）
function Zombie2DBase:OnDeath()
    self:_ChangeState(State.Die)
end

function Zombie2DBase:GetState()
    return self.state
end

return Zombie2DBase
