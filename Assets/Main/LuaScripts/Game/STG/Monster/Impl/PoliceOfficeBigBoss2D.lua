---
--- STG 怪物子系统 — 警察局 Boss
--- 提炼自 ParkourBattle/Monster/MonsterImpl/PoliceOfficeBigBoss.lua 的核心语义：和
--- PushCarZombie2D 共享同一个"血量百分比阈值表 → 找当前阶段"算法（原版两者是分别独立实现的，
--- 这里把算法思路对齐但不强行合并成同一个基类——两者触发的表现不同，一个切外观子节点，
--- 一个切跑动动画名+短暂受击硬直，保留成两个独立文件更符合"1:1 对应原文件"的要求）。
--- 阶段变化时会有一次短暂的"受击硬直"表现（对齐原版 __checkStage 里播放一次 Hurt 动画、
---延迟后才切回 Run 状态），2D 版本用 Zombie2DBase 的 Hurt 状态复用这个硬直窗口。
---
--- 用法：
---   local boss = PoliceOfficeBigBoss2D.New(parentTransform, x, y, {
---       hp = 500, speed = 30, attackRange = 60,
---       stageThresholds = { 0.75, 0.5, 0.25 },  -- 4 个阶段的跑动表现
---       runAniNames = { "run_stage1", "run_stage2", "run_stage3", "run_stage4" },
---       stageHurtDurationSec = 0.4,
---       onStageChanged = function(aniName, stage, zombie) --[[ 切换跑动动画 ]] end,
---   })
---
---@class PoliceOfficeBigBoss2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local PoliceOfficeBigBoss2D = BaseClass("PoliceOfficeBigBoss2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 全部字段，额外增加：
---   stageThresholds        number[]  从高到低排列的血量百分比阈值
---   runAniNames            string[]  长度应为 #stageThresholds+1，对应各阶段的跑动表现标识
---   stageHurtDurationSec   number  阶段切换时的硬直时长，默认 0.4（原版这里是一次 Hurt 动画的播放时长）
---   onStageChanged         fun(aniName:string, stage:number, zombie:PoliceOfficeBigBoss2D)
function PoliceOfficeBigBoss2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.stageThresholds = (cfg and cfg.stageThresholds) or {}
    self.runAniNames = (cfg and cfg.runAniNames) or {}
    self.stageHurtDurationSec = (cfg and cfg.stageHurtDurationSec) or 0.4
    self.onStageChanged = cfg and cfg.onStageChanged
    self.curStage = 1
    self.curRunAniName = self.runAniNames[1]
end

function PoliceOfficeBigBoss2D:GetGoName()
    return "PoliceOfficeBigBoss2D"
end

--- 与 PushCarZombie2D:_CalcStage 算法一致：从高到低比较阈值表，命中第一个满足的档位
--- @return number
function PoliceOfficeBigBoss2D:_CalcStage()
    local percent = self.hp / self.maxHp
    for i, threshold in ipairs(self.stageThresholds) do
        if percent >= threshold then
            return i
        end
    end
    return #self.stageThresholds + 1
end

--- 覆写受击：扣血后检查阶段变化，变化时播放一次硬直（对齐原版 __PlayOnceHurt 之后延迟切回 Run）
--- @param damage number
--- @return boolean isDead
function PoliceOfficeBigBoss2D:TakeDamage(damage)
    if self.isDead then
        return true
    end
    local isDead = Zombie2DBase.TakeDamage(self, damage)
    if not isDead then
        self:_CheckStage()
    end
    return isDead
end

function PoliceOfficeBigBoss2D:_CheckStage()
    local newStage = self:_CalcStage()
    local clampedStage = math.min(newStage, #self.runAniNames)
    if clampedStage == self.curStage then
        return
    end
    self.curStage = clampedStage
    self.curRunAniName = self.runAniNames[clampedStage]

    if self.onStageChanged ~= nil then
        self.onStageChanged(self.curRunAniName, clampedStage, self)
    end

    -- 阶段切换的硬直窗口：借用 Hurt 状态表达"短暂停顿"，时长按配置而不是父类默认的 0.5 秒
    -- （对齐原版这里用的是一次 Hurt 动画的播放时长，不是固定值）
    self:EnterHurt(self.stageHurtDurationSec)
end

function PoliceOfficeBigBoss2D:GetCurRunAniName()
    return self.curRunAniName
end

return PoliceOfficeBigBoss2D
