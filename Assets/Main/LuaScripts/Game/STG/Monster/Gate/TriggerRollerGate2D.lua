---
--- STG 怪物子系统 — 滚轮锁定门（对应原版 TriggerRollerGate）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/TriggerRollerGate.lua：继承 TargetBuffGate2D 的
--- "锁定/解锁"骨架，但把解锁条件从"打碎 N 个靶块"换成"指定的百分比木桶（BucketPercent2D）
--- 累计受击伤害达到阈值"。原版解锁条件是 `bucketId|damage` 这种字符串编码，这里直接传两个
--- 独立字段，不再需要旧的 `string.split_ii_array` 解析。
---
--- 用法：
---   local gate = TriggerRollerGate2D.New(parentTransform, x, y, {
---       targetBucketId = "bucket_01", requiredDamage = 50,
---       effectId = "eff_unlock_buff",
---       onLockStateChanged = function(isActive, gate) --[[ 切换锁/解锁特效节点 ]] end,
---   })
---   -- 目标百分比木桶每次受击都调用一次（对接 BucketPercent2D 的 onPercentAttacked 回调）：
---   gate:OnTargetBucketAttacked(bucketId, accumulatedDamage)
---
---@class TriggerRollerGate2D : TargetBuffGate2D
local TargetBuffGate2D = require "Game.STG.Monster.Gate.TargetBuffGate2D"
local TriggerRollerGate2D = BaseClass("TriggerRollerGate2D", TargetBuffGate2D)

--- @param cfg table 继承 TargetBuffGate2D 全部字段（activeCondition 会被本类忽略，解锁条件
---                   改用 targetBucketId/requiredDamage 表达），额外增加：
---   targetBucketId  any     要监听的目标百分比木桶标识
---   requiredDamage  number  该木桶累计受击伤害达到此值即解锁
function TriggerRollerGate2D:__init(parentTransform, x, y, cfg)
    TargetBuffGate2D.__init(self, parentTransform, x, y, cfg)
    self.targetBucketId = cfg and cfg.targetBucketId
    self.requiredDamage = (cfg and cfg.requiredDamage) or 0
    self.isAlreadyActive = self.requiredDamage <= 0  -- 覆写基类的解锁初始判断，改用木桶伤害阈值
end

function TriggerRollerGate2D:GetGoName()
    return "TriggerRollerGate2D"
end

--- 目标百分比木桶每次受击都应调用这个方法，累计伤害达到阈值即解锁
--- （对齐原版 TryActive 里查 `GetPercentBucketDamageRecord` 的语义，这里由调用方主动推送
--- 累计值，不内置一个全局的"伤害记录表"，避免这个门类反过来依赖木桶管理器）
--- @param bucketId any
--- @param accumulatedDamage number 该木桶目前累计受到的总伤害
--- @return boolean 解锁后返回 true
function TriggerRollerGate2D:OnTargetBucketAttacked(bucketId, accumulatedDamage)
    if self.isAlreadyActive then
        return true
    end
    if bucketId ~= self.targetBucketId then
        return false
    end

    if accumulatedDamage >= self.requiredDamage then
        self.isAlreadyActive = true
        if self.onLockStateChanged ~= nil then
            self.onLockStateChanged(true, self)
        end
        return true
    end
    return false
end

--- 覆写 TryUnlock：这个门类不使用"计数"式解锁，避免误用基类接口，明确报错提示改用
--- OnTargetBucketAttacked
function TriggerRollerGate2D:TryUnlock(counter)
    Logger.LogError("TriggerRollerGate2D 使用 OnTargetBucketAttacked 解锁，不支持 TryUnlock")
    return self.isAlreadyActive
end

return TriggerRollerGate2D
