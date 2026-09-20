---
--- gate_step 门：累计伤害升级
--- 对齐 barrel UpgradeableGate：paraTable = "阈值|效果id;..."
--- 子弹打门累计伤害，达到阈值后切换到下一档效果
---@class StgGateStep
local StgGateStep = {}
StgGateStep.__index = StgGateStep

local base = require "Game.STG.Entity.Gate.StgGate"
local StgGateParaUtil = require "Game.STG.DataCenter.StgGateParaUtil"
-- 关键：让 StgGateStep 的方法查找链回退到基类 StgGate，否则 gate:IsPositive()/
-- GetGateType() 等基类方法查不到会报 "attempt to call a nil value"（详见 StgGateCounter.lua 同位置注释）
setmetatable(StgGateStep, base)

function StgGateStep.New(trapConfig, logic)
    local self = setmetatable(base.New(trapConfig, logic), StgGateStep)
    self.accumulatedDamage = 0
    -- 同 StgGateCounter.New：base.New 里的 RecalcEffect 是基类空实现，换 metatable 后再算
    self:RecalcEffect()
    return self
end

function StgGateStep:RecalcEffect()
    local entries = self.trapConfig.paraEntries or {}
    local effectId, index = StgGateParaUtil.FindStepEffect(entries, self.accumulatedDamage)
    self.effectId = effectId
    self.effectIndex = index
end

function StgGateStep:OnHit(damage)
    damage = tonumber(damage) or 0
    if damage <= 0 then
        return
    end
    self.accumulatedDamage = self.accumulatedDamage + damage
    self:RecalcEffect()
    Logger.Log('#STG# gate_step 受击 dmg=' .. damage .. ' total=' .. self.accumulatedDamage
        .. ' effect=' .. tostring(self.effectId))
end

--- UI 显示：当前累计伤害 / 下一档阈值
function StgGateStep:GetDisplayText()
    local entries = self.trapConfig.paraEntries or {}
    local nextEntry = nil
    if self.effectIndex ~= nil then
        nextEntry = entries[self.effectIndex + 1]
    elseif #entries > 0 then
        nextEntry = entries[1]
    end
    if nextEntry ~= nil then
        return tostring(math.floor(self.accumulatedDamage)) .. "/" .. tostring(math.floor(nextEntry.threshold))
    end
    return tostring(math.floor(self.accumulatedDamage))
end

return StgGateStep
