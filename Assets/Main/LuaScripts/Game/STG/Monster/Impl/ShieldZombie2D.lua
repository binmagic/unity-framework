---
--- STG 怪物子系统 — 盾牌僵尸
--- 提炼自 ParkourBattle/Monster/MonsterImpl/ShieldZombie.lua 的核心语义：护盾是独立于本体血量
--- 的一层数值，先扣护盾、护盾耗尽才开始扣本体血量，护盾破碎后攻击/跑动表现切换成"无盾"版。
--- 去掉了原实现里 DropShield FSM 状态的动画/特效播放，改成单次回调通知外部播放"破盾"表现。
---
--- 用法：
---   local zombie = ShieldZombie2D.New(parentTransform, x, y, {
---       hp = 30, shieldValue = 20, speed = 60, attackRange = 40,
---       onShieldBroken = function(zombie) --[[ 播放破盾特效/切换贴图 ]] end,
---   })
---
---@class ShieldZombie2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local ShieldZombie2D = BaseClass("ShieldZombie2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 的全部字段，额外增加：
---   shieldValue      number  初始护盾值，<=0 表示没有护盾，直接扣本体血量
---   onShieldBroken   fun(zombie:ShieldZombie2D)  护盾耗尽时触发一次
function ShieldZombie2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.shieldValue = (cfg and cfg.shieldValue) or 0
    self.shieldHasDestroyed = self.shieldValue <= 0
    self.onShieldBroken = cfg and cfg.onShieldBroken
end

function ShieldZombie2D:GetGoName()
    return "ShieldZombie2D"
end

--- 覆写受击：护盾未破前，伤害只扣护盾；护盾耗尽的那一刻触发一次 onShieldBroken 回调，
--- 不会在同一次命中里把溢出伤害继续扣到本体血量（对齐原版 CalcHpByHurt 的 if/else 分支，
--- 护盾归零那一次命中不掉本体血量）。
--- @param damage number
--- @return boolean isDead
function ShieldZombie2D:TakeDamage(damage)
    if self.isDead then
        return true
    end

    if self.shieldValue > 0 then
        self.shieldValue = math.max(self.shieldValue - (damage or 0), 0)
        if self.shieldValue <= 0 and not self.shieldHasDestroyed then
            self.shieldHasDestroyed = true
            if self.onShieldBroken ~= nil then
                self.onShieldBroken(self)
            end
        end
        return false
    end

    return Zombie2DBase.TakeDamage(self, damage)
end

function ShieldZombie2D:HasShield()
    return not self.shieldHasDestroyed
end

function ShieldZombie2D:GetShieldValue()
    return self.shieldValue
end

return ShieldZombie2D
