---
--- gate_counter 门：计数区间门
--- 对齐 barrel UpgradeableGate2：paraTable = "min|max|效果id;..."
--- 被打一次 value+1，按区间表找效果；穿门时执行
---@class StgGateCounter
local StgGateCounter = {}
StgGateCounter.__index = StgGateCounter

local base = require "Game.STG.Entity.Gate.StgGate"
local StgGateParaUtil = require "Game.STG.DataCenter.StgGateParaUtil"
-- 关键：让 StgGateCounter 的方法查找链回退到基类 StgGate（对齐 StgStagePlay 等
-- setmetatable(子类, 父类) 的写法）。漏了这行会导致 gate:IsPositive()/GetGateType()
-- 等只定义在基类上的方法查不到，报 "attempt to call a nil value"——
-- 因为 base.New() 返回的实例被 setmetatable(instance, StgGateCounter) 换掉了
-- metatable，如果 StgGateCounter 自己不再指向 base，基类方法就彻底丢失。
setmetatable(StgGateCounter, base)

function StgGateCounter.New(trapConfig, logic)
    -- base.New 里 RecalcEffect 走的还是基类空实现（metatable 尚未换成子类），
    -- 必须在 setmetatable 之后再算一次，否则 effectId 一直是 nil，穿门打
    -- "门穿过了但无对应效果"（关卡 1001 的 gate_plus2_left 就是这个现象）。
    local self = setmetatable(base.New(trapConfig, logic), StgGateCounter)
    self:RecalcEffect()
    return self
end

function StgGateCounter:RecalcEffect()
    local entries = self.trapConfig.paraEntries or {}
    local effectId, index = StgGateParaUtil.FindCounterEffect(entries, self.value)
    self.effectId = effectId
    self.effectIndex = index
end

function StgGateCounter:OnHit(damage)
    -- counter 门语义：每次受击 +1（对齐 barrel Gate2，不按伤害量）
    self.value = self.value + 1
    self:RecalcEffect()
    Logger.Log('#STG# gate_counter 受击 value=' .. self.value .. ' effect=' .. tostring(self.effectId))
end

function StgGateCounter:GetDisplayText()
    return string.format('%+d', self.value)
end

return StgGateCounter
