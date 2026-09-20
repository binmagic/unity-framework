---
--- 数字门工厂：按 gateType 创建对应实例
---@class StgGateFactory
local StgGateFactory = {}

local Const        = require "Game.STG.Const"
local StgGateStep   = require "Game.STG.Entity.Gate.StgGateStep"
local StgGateCounter= require "Game.STG.Entity.Gate.StgGateCounter"
local StgGateDuet   = require "Game.STG.Entity.Gate.StgGateDuet"

--- @param trapConfig table StgLevelConfig.trapById 里 type=="digital_gate" 的一条
--- @param logic table StgBattleLogic
--- @return table|nil gate 实例
function StgGateFactory.Create(trapConfig, logic)
    if trapConfig == nil or trapConfig.type ~= Const.TrapType.DigitalGate then
        Logger.LogError('#StgGateFactory# trapConfig 不是 digital_gate trapId='
            .. tostring(trapConfig and trapConfig.trapId))
        return nil
    end

    local gateType = trapConfig.gateType
    if gateType == Const.GateType.Step then
        return StgGateStep.New(trapConfig, logic)
    elseif gateType == Const.GateType.Counter then
        return StgGateCounter.New(trapConfig, logic)
    elseif gateType == Const.GateType.Duet then
        return StgGateDuet.New(trapConfig, logic)
    end

    Logger.LogError('#StgGateFactory# 未知 gateType=' .. tostring(gateType)
        .. ' trapId=' .. tostring(trapConfig.trapId))
    return nil
end

return StgGateFactory
