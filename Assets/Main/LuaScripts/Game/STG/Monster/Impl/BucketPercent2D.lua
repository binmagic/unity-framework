---
--- STG 怪物子系统 — 百分比结算木桶
--- 提炼自 ParkourBattle/Monster/MonsterImpl/BucketPercent.lua 的核心语义：继承 Bucket2D 的
--- 随机血量范围+死亡掉落，额外增加"按当前血量百分比实时压缩外观宽度"的表现（原版用
--- `nodeRoot.transform:Set_localScale(percent, 1, 1)` 压缩子节点，2D 版本压缩 sizeDelta.x），
--- 并且每次受击都会触发一次 onPercentAttacked 回调（对齐原版 `monsterMgr:OnAttackPercentBucket`，
--- 通知外部"这个百分比木桶被打了多少伤害"，用于场景里可能存在的多目标协同判定）。
---
--- 用法：
---   local bucket = BucketPercent2D.New(parentTransform, x, y, {
---       hpMin = 20, hpMax = 20,
---       onPercentAttacked = function(hurt, bucket) --[[ 通知外部协同判定 ]] end,
---   })
---
---@class BucketPercent2D : Bucket2D
local Bucket2D = require "Game.STG.Monster.Impl.Bucket2D"
local BucketPercent2D = BaseClass("BucketPercent2D", Bucket2D)

local Vector2 = CS.UnityEngine.Vector2

--- @param cfg table 继承 Bucket2D 全部字段，额外增加：
---   onPercentAttacked  fun(hurt:number, bucket:BucketPercent2D)  每次受击都触发（不只是死亡时）
function BucketPercent2D:__init(parentTransform, x, y, cfg)
    Bucket2D.__init(self, parentTransform, x, y, cfg)
    self.onPercentAttacked = cfg and cfg.onPercentAttacked
    self.originWidth = self.rt.sizeDelta.x
end

function BucketPercent2D:GetGoName()
    return "BucketPercent2D"
end

--- 覆写受击：先按原版顺序调用基类扣血逻辑，血量>0 时按百分比压缩宽度表现当前"剩余量"，
--- 无论是否死亡都要触发一次 onPercentAttacked（对齐原版 BeAttack 结尾无条件调用 OnAttackPercentBucket）
--- @param damage number
--- @return boolean isDead
function BucketPercent2D:TakeDamage(damage)
    local isDead = Bucket2D.TakeDamage(self, damage)
    if not isDead and self.hp > 0 then
        local percent = math.max(0, math.min(1, self.hp / self.maxHp))
        self.rt.sizeDelta = Vector2(self.originWidth * percent, self.rt.sizeDelta.y)
    end

    if self.onPercentAttacked ~= nil then
        self.onPercentAttacked(damage, self)
    end
    return isDead
end

return BucketPercent2D
