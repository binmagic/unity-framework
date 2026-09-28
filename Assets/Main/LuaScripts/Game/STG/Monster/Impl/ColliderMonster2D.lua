---
--- STG 怪物子系统 — 静态碰撞障碍物
--- 提炼自 ParkourBattle/Monster/MonsterImpl/ColliderMonster.lua 的核心语义：不移动的静态物，
--- 可选血量（`hpBarEnabled`），核心特色是"距离触发播放动画"——原版按 `bornMeta.para3` 配置
--- 一个距离阈值，玩家/目标进入该距离内才开始播放动画，配置为 0 则默认常驻播放。去掉了原实现
--- 里的 HpBarCell UI 组件、旧战斗框架的关卡阶段判断（GetParkourStage），血量显示交给外部通过
--- onHpChanged 回调自行处理。
---
--- 用法：
---   local prop = ColliderMonster2D.New(parentTransform, x, y, {
---       hp = 20, startAnimDistance = 100,
---       onAnimStateChanged = function(playing, monster) --[[ 开始/停止播放动画 ]] end,
---       onHpChanged = function(hp, maxHp, monster) --[[ 更新血条 ]] end,
---   })
---   prop:CheckPlayAnim(distanceToTarget)  -- 每帧由外部传入到目标的距离
---
---@class ColliderMonster2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local ColliderMonster2D = BaseClass("ColliderMonster2D", Monster2DBase)

--- @param cfg table
---   hp                   number  初始血量，默认 1
---   startAnimDistance    number  开始播放动画的距离阈值，默认 0（0 表示不设阈值，常驻播放）
---   spritePath           string  可选
---   onAnimStateChanged   fun(isPlaying:boolean, monster:ColliderMonster2D)  播放状态变化时触发
---   onHpChanged          fun(hp:number, maxHp:number, monster:ColliderMonster2D)  受击后触发
function ColliderMonster2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    Monster2DBase.__init(self, parentTransform, x, y, self.cfg.hp or 1, self.cfg.sizeVec2)

    self.startAnimDistance = self.cfg.startAnimDistance or 0
    self.isAnimPlaying = self.startAnimDistance <= 0  -- 对齐原版：距离没配或配 0，默认播放状态
    self.onAnimStateChanged = self.cfg.onAnimStateChanged
    self.onHpChanged = self.cfg.onHpChanged
end

function ColliderMonster2D:GetGoName()
    return "ColliderMonster2D"
end

function ColliderMonster2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 每帧由外部传入"到目标的距离"，进入阈值内才开始播放（对齐原版 CheckPlayAnim 的距离判定，
--- 原版是自己算到玩家的距离，2D 版本不内置"玩家"概念，交给外部决定这个距离怎么算）
--- @param distanceToTarget number
function ColliderMonster2D:CheckPlayAnim(distanceToTarget)
    if self.startAnimDistance <= 0 or self.isAnimPlaying then
        return
    end
    if distanceToTarget <= self.startAnimDistance then
        self.isAnimPlaying = true
        if self.onAnimStateChanged ~= nil then
            self.onAnimStateChanged(true, self)
        end
    end
end

--- 覆写受击：扣血后通知外部刷新血条表现（对齐原版 BeAttack 里的 hpBar:SetHp 调用）
--- @param damage number
--- @return boolean isDead
function ColliderMonster2D:TakeDamage(damage)
    local isDead = Monster2DBase.TakeDamage(self, damage)
    if not isDead and self.onHpChanged ~= nil then
        self.onHpChanged(self.hp, self.maxHp, self)
    end
    return isDead
end

return ColliderMonster2D
