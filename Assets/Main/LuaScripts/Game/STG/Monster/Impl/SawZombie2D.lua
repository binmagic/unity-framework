---
--- STG 怪物子系统 — 电锯冲刺僵尸
--- 提炼自 ParkourBattle/Monster/MonsterImpl/SawZombie.lua。
--- 忠实说明：原文件本体只有一行有效逻辑——进入攻击范围时不走普通攻击，而是切到专属的
--- Sprint（冲刺）状态，真正的冲刺判定/位移/命中逻辑在原版 FSM 状态类
--- MonsterImpl/FSM/CommonAI/ZombieStateSprint.lua 里，不在 SawZombie.lua 本体。
--- 这个文件同样很薄不是漏写，是如实还原原文件"纯转发"的事实。
--- 2D 版本把"冲刺攻击"表达成：进入攻击态后先冲向目标一段距离，冲到即造成一次伤害，
--- 不是父类默认的"原地攻击"。
---
--- 用法：
---   local zombie = SawZombie2D.New(parentTransform, x, y, {
---       hp = 30, speed = 60, attackRange = 40,
---       sprintSpeed = 300, sprintDurationSec = 0.4,
---       onAttack = function(zombie) --[[ 冲刺命中时造成伤害 ]] end,
---   })
---
---@class SawZombie2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local SawZombie2D = BaseClass("SawZombie2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 全部字段，额外增加：
---   sprintSpeed         number  冲刺速度（像素/秒），默认是 chaseSpeed 的 3 倍
---   sprintDurationSec   number  冲刺持续时长，默认 0.4
function SawZombie2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.sprintSpeed = (cfg and cfg.sprintSpeed) or (self.chaseSpeed * 3)
    self.sprintDurationSec = (cfg and cfg.sprintDurationSec) or 0.4
end

function SawZombie2D:GetGoName()
    return "SawZombie2D"
end

--- 覆写攻击态为冲刺：朝目标方向以 sprintSpeed 冲刺 sprintDurationSec 秒后触发一次 onAttack，
--- 对齐原版"ChangeToAttack 直接重定向到 Sprint 状态"的行为——不做冷却重复攻击，冲一次就回 Run
function SawZombie2D:_UpdateAttack(dt)
    if self.getTargetX ~= nil and self.stateTimer < self.sprintDurationSec then
        local tx, ty = self.getTargetX(), self.getTargetY()
        local x, y = self:GetLocalPos()
        local dx, dy = tx - x, ty - y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0.0001 then
            self:SetLocalPos(x + dx / dist * self.sprintSpeed * dt, y + dy / dist * self.sprintSpeed * dt)
            self:SetMove(dx, dy, 0)
        end
        return
    end

    if self.onAttack ~= nil then
        self.onAttack(self)
    end
    self:_ChangeState(Zombie2DBase.State.Run)
end

return SawZombie2D
