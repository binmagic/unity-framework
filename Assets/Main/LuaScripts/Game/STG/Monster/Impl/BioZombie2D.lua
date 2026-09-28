---
--- STG 怪物子系统 — 生化僵尸
--- 提炼自 ParkourBattle/Monster/MonsterImpl/BioZombie.lua。
--- 忠实说明：原文件本体没有任何独立数值逻辑，唯一的事是覆写 GenRunState 换成专属的
--- BarrelBioZombieStateRun.lua 跑动状态类（表现层面的差异，比如跑动姿态/音效不同），
--- 战斗数值和 CommonAIMonster 完全一致。这个文件同样很薄不是漏写，是如实还原原文件
--- "只换跑动表现，不改数值"的事实。
--- 2D 版本不需要覆写任何数值方法，只保留一个标识字段供表现层区分"这是生化僵尸，
--- 播放专属跑动动画/特效"，核心追踪-攻击-受击-死亡流程全部复用 Zombie2DBase。
---
--- 用法：
---   local zombie = BioZombie2D.New(parentTransform, x, y, {
---       hp = 30, speed = 60, attackRange = 40,
---       runSpritePath = "...",  -- 专属跑动表现，具体怎么播放由外部决定
---   })
---
---@class BioZombie2D : Zombie2DBase
local Zombie2DBase = require "Game.STG.Monster.Zombie2DBase"
local BioZombie2D = BaseClass("BioZombie2D", Zombie2DBase)

--- @param cfg table 继承 Zombie2DBase 全部字段，额外增加：
---   runSpritePath  string  生化僵尸专属跑动表现标识，2D 化后只是换一张图/一段序列帧，
---                          不像原版需要单独的 FSM 状态类
function BioZombie2D:__init(parentTransform, x, y, cfg)
    Zombie2DBase.__init(self, parentTransform, x, y, cfg)
    self.runSpritePath = cfg and cfg.runSpritePath
end

function BioZombie2D:GetGoName()
    return "BioZombie2D"
end

return BioZombie2D
