---
--- gate_duet 门：左右双生门
--- 对齐 barrel UpgradeableDuetGate：
---   paraTable      左栏 "min|max|效果id;..."
---   paraTableRight 右栏同格式
--- 打左/右独立计数；穿门时按主机落在左半还是右半结算
---@class StgGateDuet
local StgGateDuet = {}
StgGateDuet.__index = StgGateDuet

local base = require "Game.STG.Entity.Gate.StgGate"
local StgGateParaUtil = require "Game.STG.DataCenter.StgGateParaUtil"
-- 关键：让 StgGateDuet 的方法查找链回退到基类 StgGate，否则 gate:IsPositive()/
-- GetGateType() 等基类方法查不到会报 "attempt to call a nil value"（详见 StgGateCounter.lua 同位置注释）
setmetatable(StgGateDuet, base)

function StgGateDuet.New(trapConfig, logic)
    local self = setmetatable(base.New(trapConfig, logic), StgGateDuet)
    self.leftValue  = trapConfig.initialValue or 0
    self.rightValue = trapConfig.initialValue or 0
    self.leftEffectId  = nil
    self.rightEffectId = nil
    self:RecalcEffect()
    return self
end

function StgGateDuet:RecalcEffect()
    local leftEntries  = self.trapConfig.paraEntries or {}
    local rightEntries = self.trapConfig.paraEntriesRight or {}
    self.leftEffectId  = select(1, StgGateParaUtil.FindCounterEffect(leftEntries, self.leftValue))
    self.rightEffectId = select(1, StgGateParaUtil.FindCounterEffect(rightEntries, self.rightValue))
    -- 基类 effectId 保留给"未指定侧"的兜底，实际结算用 OnPass(isLeft)
    self.effectId = self.leftEffectId
end

--- @param damage number
--- @param isLeft boolean|nil 打的是左栏还是右栏；nil 时按 value>0 视为打左
function StgGateDuet:OnHit(damage, isLeft)
    if isLeft == nil then
        isLeft = true
    end
    if isLeft then
        self.leftValue = self.leftValue + 1
    else
        self.rightValue = self.rightValue + 1
    end
    self:RecalcEffect()
    Logger.Log('#STG# gate_duet 受击 side=' .. (isLeft and 'L' or 'R')
        .. ' L=' .. self.leftValue .. ' R=' .. self.rightValue)
end

--- 穿门：按落点在左半/右半结算
--- @param isLeft boolean 主机落在左半还是右半
--- @return boolean
function StgGateDuet:OnPass(isLeft)
    if self.hasTriggered then
        return false
    end
    self.hasTriggered = true

    local effectId = isLeft and self.leftEffectId or self.rightEffectId
    local value = isLeft and self.leftValue or self.rightValue

    if effectId == nil or effectId == "" then
        Logger.Log('#STG# gate_duet 穿过但无效果 side=' .. (isLeft and 'L' or 'R') .. ' value=' .. tostring(value))
        return false
    end

    -- 负数侧直接扣兵（对齐 barrel：不走 trigger，硬减）
    if value < 0 then
        self.logic:RemoveWingman(-value)
        return true
    end

    return self.logic:ExecuteEffect(effectId)
end

function StgGateDuet:GetDisplayText(isLeft)
    if isLeft then
        return string.format('%+d', self.leftValue)
    end
    return string.format('%+d', self.rightValue)
end

function StgGateDuet:GetLeftValue()
    return self.leftValue
end

function StgGateDuet:GetRightValue()
    return self.rightValue
end

return StgGateDuet
