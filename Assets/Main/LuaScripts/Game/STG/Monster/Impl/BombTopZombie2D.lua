---
--- STG 怪物子系统 — 顶雷僵尸
--- 提炼自 ParkourBattle/Monster/MonsterImpl/BombTopZombie.lua 的核心语义：进入攻击范围后
--- 不发起普通攻击，而是自爆一次（只触发一次，`hasBoomed` 防重复），随后按原版"先播放攻击动作
--- 延时结算死亡"的节奏，通过延时回调通知外部造成范围伤害。去掉了原实现里的子弹模板查表
--- （DataCenter.PveBulletTemplateManager）和旧计时器（TimerManager），改成直接把延时秒数和
--- 伤害半径当作配置传入，由外部决定"炸弹"具体是什么。
---
--- 用法：
---   local zombie = BombTopZombie2D.New(parentTransform, x, y, {
---       hp = 20, speed = 60, attackRange = 30, boomDelaySec = 0.5,
---       onBoom = function(zombie) --[[ 在 zombie 当前位置造成范围伤害 ]] end,
---   })
---   zombie:Update(dt)  -- 需要外部在 Update 循环里累计 boomDelaySec 计时（见下方 Update 覆写）
---
---@class BombTopZombie2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local BombTopZombie2D = BaseClass("BombTopZombie2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 全部字段，额外增加：
---   boomDelaySec  number  进入攻击态到实际引爆的延时（对齐原版"播放攻击动作后延时结算死亡"）
---   onBoom        fun(zombie:BombTopZombie2D)  引爆时触发一次，供外部结算范围伤害
function BombTopZombie2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.boomDelaySec = (cfg and cfg.boomDelaySec) or 0.5
    self.onBoom = cfg and cfg.onBoom
    self.hasBoomed = false
    self.boomTimer = 0
    self.isBooming = false
end

function BombTopZombie2D:GetGoName()
    return "BombTopZombie2D"
end

--- 覆写攻击态：不走父类"冷却后重复攻击"的循环，进入攻击范围即锁定一次自爆流程
--- （对齐原版 ChangeToAttack 直接调用 __selfBoom，不经过技能系统的目标/范围二次校验）
function BombTopZombie2D:_UpdateAttack(dt)
    if self.hasBoomed then
        return
    end
    if not self.isBooming then
        self.isBooming = true
        self.boomTimer = 0
    end

    self.boomTimer = self.boomTimer + dt
    if self.boomTimer >= self.boomDelaySec then
        self:_DoBoom()
    end
end

function BombTopZombie2D:_DoBoom()
    if self.hasBoomed then
        return
    end
    self.hasBoomed = true
    if self.onBoom ~= nil then
        self.onBoom(self)
    end
    self:TakeDamage(self.hp)  -- 自爆后自身也算死亡，对齐原版"临时计数结算"的效果
end

return BombTopZombie2D
