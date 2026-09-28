---
--- STG 怪物子系统 — 推车僵尸
--- 提炼自 ParkourBattle/Monster/MonsterImpl/PushCarZombie.lua 的核心语义：按当前血量百分比
--- 对照一张阈值表（`stageThresholds`，从高到低排列）找到当前应处的外观阶段，阶段变化时通知
--- 外部切换表现（对齐原版按 `stage1..stageN` 子节点做可见性切换）；掉到阈值表最后一档以下
--- （即"血量百分比比最后一个阈值还低"）算进入最终阶段，触发一次性的最终阶段回调（原版在这里
--- 替换普通攻击子弹为特殊子弹，2D 版本把"替换子弹"这个决定交给外部在回调里处理）。
---
--- 用法：
---   local zombie = PushCarZombie2D.New(parentTransform, x, y, {
---       hp = 100, speed = 40, attackRange = 40,
---       stageThresholds = { 0.66, 0.33 },  -- 血量高于66%是阶段1，33%~66%是阶段2，低于33%是最终阶段
---       onStageChanged = function(stage, zombie) --[[ 切换外观子节点 ]] end,
---       onFinalStage = function(zombie) --[[ 替换攻击方式等 ]] end,
---   })
---
---@class PushCarZombie2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local PushCarZombie2D = BaseClass("PushCarZombie2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 全部字段，额外增加：
---   stageThresholds  number[]  从高到低排列的血量百分比阈值，长度 N 表示有 N+1 个阶段
---   onStageChanged   fun(stage:number, zombie:PushCarZombie2D)  阶段变化时触发（含最终阶段）
---   onFinalStage     fun(zombie:PushCarZombie2D)  首次进入最终阶段时额外触发一次
function PushCarZombie2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.stageThresholds = (cfg and cfg.stageThresholds) or {}
    self.onStageChanged = cfg and cfg.onStageChanged
    self.onFinalStage = cfg and cfg.onFinalStage
    self.isFinalStage = false
    self.curStage = 1
end

function PushCarZombie2D:GetGoName()
    return "PushCarZombie2D"
end

--- 按当前血量百分比在阈值表里找档位，从第一档（血量最高）依次比较，命中第一个
--- percent >= threshold 的档位就是当前阶段；全部不满足则是最后一档（最终阶段）。
--- 原样对齐原版 __refreshSubStageNodes 的查找方式。
--- @return number 阶段序号，1 ~ #stageThresholds+1
function PushCarZombie2D:_CalcStage()
    local percent = self.hp / self.maxHp
    for i, threshold in ipairs(self.stageThresholds) do
        if percent >= threshold then
            return i
        end
    end
    return #self.stageThresholds + 1
end

--- 覆写受击：扣血后重新计算阶段，阶段变化才触发回调（避免每次受击都触发一次表现刷新）
--- @param damage number
--- @return boolean isDead
function PushCarZombie2D:TakeDamage(damage)
    local isDead = Zombie2DBase.TakeDamage(self, damage)
    if not isDead then
        self:_RefreshStage()
    end
    return isDead
end

function PushCarZombie2D:_RefreshStage()
    local newStage = self:_CalcStage()
    if newStage == self.curStage then
        return
    end
    self.curStage = newStage

    if self.onStageChanged ~= nil then
        self.onStageChanged(newStage, self)
    end

    if newStage == #self.stageThresholds + 1 and not self.isFinalStage then
        self.isFinalStage = true
        if self.onFinalStage ~= nil then
            self.onFinalStage(self)
        end
    end
end

function PushCarZombie2D:GetCurStage()
    return self.curStage
end

function PushCarZombie2D:IsFinalStage()
    return self.isFinalStage
end

return PushCarZombie2D
