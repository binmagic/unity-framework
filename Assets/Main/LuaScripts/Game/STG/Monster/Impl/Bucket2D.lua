---
--- STG 怪物子系统 — 可破坏静态物
--- 提炼自 ParkourBattle/Monster/MonsterImpl/Bucket.lua 的核心语义："随机血量范围 + 打破后
--- 掉落"，去掉了原实现里的子模型武器挂点加载、材质描边缓存、旧战斗框架 buff 触发链等
--- 与"可破坏静态物"这个概念无关的耦合逻辑。静态物不移动，直接用 Monster2DBase 的 hp/死亡
--- 流程，不需要覆写 Update。
---
--- 用法：
---   local bucket = Bucket2D.New(parentTransform, x, y, {
---       hpMin = 20, hpMax = 40, spritePath = "...", dropId = "gold_small",
---       onBreak = function(dropId, bucket) --[[ 掉落表现 ]] end,
---   })
---   bucket:TakeDamage(10)
---
---@class Bucket2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local Bucket2D = BaseClass("Bucket2D", Monster2DBase)

--- @param cfg table
---   hpMin/hpMax  number  血量随机范围（对齐原版 bornMeta.para 的 "min|max" 语义）
---   spritePath   string  贴图路径
---   sizeVec2     userdata  Vector2，可选
---   dropId       any     打破后要结算的掉落标识，含义由调用方解释
---   onBreak      fun(dropId:any, bucket:Bucket2D)
function Bucket2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    local hpMin = self.cfg.hpMin or 1
    local hpMax = self.cfg.hpMax or hpMin
    local hp = math.random(hpMin, hpMax)

    Monster2DBase.__init(self, parentTransform, x, y, hp, self.cfg.sizeVec2)
end

function Bucket2D:GetGoName()
    return "Bucket2D"
end

function Bucket2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 打破时结算掉落，具体表现（掉金币动画等）交给调用方在回调里处理，
--- 这里不做任何掉落判定的概率计算——那属于关卡玩法层的决策，不是"可破坏物"这个类该管的事
function Bucket2D:OnDeath()
    if self.cfg.onBreak ~= nil then
        self.cfg.onBreak(self.cfg.dropId, self)
    end
end

return Bucket2D
