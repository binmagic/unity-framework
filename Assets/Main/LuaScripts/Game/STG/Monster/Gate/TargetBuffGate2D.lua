---
--- STG 怪物子系统 — 锁定门（对应原版 TargetBuffGate）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/TargetBuffGate.lua 的核心语义：门体初始处于
--- 锁定态，需要满足一个外部条件（原版是"打碎 N 个箭塔靶块"）才能解锁，解锁后才允许触发
--- 效果，解锁前碰撞不产生任何效果。去掉了原实现里的 3D 挂点特效节点切换，改成
--- onLockStateChanged 回调通知外部切换锁定/解锁表现。
---
--- 解锁条件是"计数达到阈值"，具体计数来源不内置（对应 ArcheryTarget2D 的存活靶块变化），
--- 由外部在靶块被打碎时调用 TryUnlock(counter) 传入最新计数。
---
--- 用法：
---   local gate = TargetBuffGate2D.New(parentTransform, x, y, {
---       activeCondition = 3,  -- 打碎 3 个靶块解锁，0 表示无条件已解锁
---       effectId = "eff_unlock_buff",
---       onLockStateChanged = function(isActive, gate) --[[ 切换锁/解锁特效节点 ]] end,
---   })
---   -- 每打碎一个靶块：
---   gate:TryUnlock(destroyedCount)
---
---@class TargetBuffGate2D : TriggerGate2D
local TriggerGate2D = require "Game.STG.Monster.Gate.TriggerGate2D"
local TargetBuffGate2D = BaseClass("TargetBuffGate2D", TriggerGate2D)

--- @param cfg table 继承 TriggerGate2D 全部字段，额外增加：
---   activeCondition       number  解锁所需的计数阈值，<=0 表示初始即已解锁
---   onLockStateChanged    fun(isActive:boolean, gate:TargetBuffGate2D)  锁定态变化时触发
function TargetBuffGate2D:__init(parentTransform, x, y, cfg)
    TriggerGate2D.__init(self, parentTransform, x, y, cfg)
    self.activeCondition = (cfg and cfg.activeCondition) or 0
    self.isAlreadyActive = self.activeCondition <= 0
    self.onLockStateChanged = cfg and cfg.onLockStateChanged
end

function TargetBuffGate2D:GetGoName()
    return "TargetBuffGate2D"
end

function TargetBuffGate2D:IsAlreadyActive()
    return self.isAlreadyActive
end

--- 尝试解锁：外部把最新计数传进来，达到阈值即解锁并通知一次（对齐原版 TryActive 的语义，
--- 已经解锁的情况下直接返回 true，不重复触发回调）
--- @param counter number
--- @return boolean 解锁后返回 true
function TargetBuffGate2D:TryUnlock(counter)
    if self.isAlreadyActive then
        return true
    end

    if counter >= self.activeCondition then
        self.isAlreadyActive = true
        if self.onLockStateChanged ~= nil then
            self.onLockStateChanged(true, self)
        end
        return true
    end

    return false
end

--- 覆写触发：未解锁时碰撞不产生任何效果（对齐原版锁定态不响应效果的语义）
function TargetBuffGate2D:Trigger()
    if not self.isAlreadyActive then
        return
    end
    if self.onTrigger ~= nil then
        self.onTrigger(self.effectId, self)
    end
end

return TargetBuffGate2D
