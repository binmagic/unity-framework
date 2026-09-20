---
--- STG 数字门基类
--- 对齐编辑器 StgTrapConfig.type == "digital_gate"
--- 门只维护计数器 + 区间表，效果交给 StgBattleLogic:ExecuteEffect
---
---@class StgGate
local StgGate = {}
StgGate.__index = StgGate

local Const = require "Game.STG.Const"

--- @param trapConfig table StgLevelConfig.trapById 里的一条（含预解析的 paraEntries）
--- @param logic table StgBattleLogic
function StgGate.New(trapConfig, logic)
    local self = setmetatable({}, StgGate)
    self.trapConfig = trapConfig
    self.logic = logic
    self.gateType = trapConfig.gateType or Const.GateType.Step
    self.value = trapConfig.initialValue or 0
    self.effectId = nil       -- 当前档位对应的效果
    self.effectIndex = nil    -- 当前档位索引
    self.hasTriggered = false -- 穿门是否已结算
    self:RecalcEffect()
    return self
end

function StgGate:GetGateType()
    return self.gateType
end

function StgGate:GetValue()
    return self.value
end

function StgGate:GetPosition()
    return self.trapConfig.positionX, self.trapConfig.positionY
end

function StgGate:GetPrefabPath()
    return self.trapConfig.prefabPath
end

--- 子类重写：根据当前 value 重算 effectId / effectIndex
function StgGate:RecalcEffect()
end

--- 子类重写：被打（子弹命中）
--- @param damage number
function StgGate:OnHit(damage)
end

--- 穿门结算：执行当前档位效果
--- @return boolean 是否成功触发
function StgGate:OnPass()
    if self.hasTriggered then
        return false
    end
    self.hasTriggered = true

    if self.effectId == nil or self.effectId == "" then
        Logger.Log('#STG# 门穿过了但无对应效果 value=' .. tostring(self.value) .. ' trapId=' .. tostring(self.trapConfig.trapId))
        return false
    end

    return self.logic:ExecuteEffect(self.effectId)
end

--- 取当前显示文本（UI 用）
function StgGate:GetDisplayText()
    if self.effectId == nil then
        return tostring(self.value)
    end
    local meta = require("Game.STG.Trigger.StgTriggerEnum").EffectTable[self.effectId]
    if meta ~= nil and meta.text ~= nil then
        return meta.text
    end
    return tostring(self.value)
end

--- 正/负判定（UI 红蓝配色）
function StgGate:IsPositive()
    return self.value >= 0
end

return StgGate
