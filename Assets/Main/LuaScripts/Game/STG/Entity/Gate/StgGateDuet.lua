---
--- gate_duet 门：左右双生门
--- 对齐 barrel UpgradeableDuetGate：
---   paraTable      左栏 "min|max|效果id;..."
---   paraTableRight 右栏同格式
--- 打左/右独立计数并扩大受击侧；显示、受击和穿门使用同一条动态分界线。
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
    self.minSideRatio = math.max(0.2, math.min(0.5, tonumber(trapConfig.minSideRatio) or 0.2))
    self.ratioChangePerHit = math.max(0, math.min(0.2, tonumber(trapConfig.ratioChangePerHit) or 0.02))
    self.leftRatio = math.max(self.minSideRatio, math.min(1 - self.minSideRatio,
        tonumber(trapConfig.initialLeftRatio) or 0.5))
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
--- @param isLeft boolean|nil 打的是左栏还是右栏；nil 默认左栏
function StgGateDuet:OnHit(damage, isLeft)
    if not self:TryAcceptHit(damage) then return false end
    if isLeft == nil then
        isLeft = true
    end
    if isLeft then
        self.leftValue = self.leftValue + 1
    else
        self.rightValue = self.rightValue + 1
    end
    self.leftRatio = math.max(self.minSideRatio, math.min(1 - self.minSideRatio,
        self.leftRatio + (isLeft and self.ratioChangePerHit or -self.ratioChangePerHit)))
    self:RecalcEffect()
    return true
end

function StgGateDuet:GetSeparatorX(totalWidth)
    return (self.leftRatio - 0.5) * totalWidth
end

--- localX 是相对门中心的横坐标，不是相对屏幕中心。
function StgGateDuet:IsLeftAt(localX, totalWidth)
    return localX <= self:GetSeparatorX(totalWidth)
end

--- 穿门：按落点在左半/右半结算
--- @param isLeft boolean 主机落在左半还是右半
--- @return boolean
function StgGateDuet:OnPass(isLeft)
    if self.hasTriggered then
        return false
    end
    self.hasTriggered = true
    if not self:IsUnlocked() then return false end

    -- 不用 and/or 选择可空的效果 ID，否则左侧 nil 会错误领取右侧奖励。
    local effectId = self.rightEffectId
    if isLeft then effectId = self.leftEffectId end
    local value = isLeft and self.leftValue or self.rightValue

    -- 负数收益直接减员，不依赖效果表是否覆盖该区间。
    if value < 0 then
        self.logic:RemoveWingman(-value)
        return true
    end

    if effectId == nil or effectId == "" then
        Logger.Log('#STG# gate_duet 穿过但无效果 side=' .. (isLeft and 'L' or 'R') .. ' value=' .. tostring(value))
        return false
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
