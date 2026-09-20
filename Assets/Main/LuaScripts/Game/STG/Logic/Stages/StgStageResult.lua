---
--- STG Stage：Result
--- 战斗结束：通知表现层弹结算，等待表现层调用逻辑侧的收尾接口
---@class StgStageResult
local StgStageResult = {}
StgStageResult.__index = StgStageResult

local FSMachine = require "Common.FSMachine"
local Const = require "Game.STG.Const"
setmetatable(StgStageResult, FSMachine.State)

function StgStageResult.Create()
    local copy = {}
    setmetatable(copy, StgStageResult)
    copy:Init()
    return copy
end

function StgStageResult:OnEnter(result)
    local owner = self.owner
    Logger.Log('#STG# Stage Result result=' .. tostring(result))

    -- OnBattleWin / OnBattleLose 由 owner 在切到本 Stage 前已回调过
    -- 这里只做终态标记，表现层可随时查询 owner:GetResult()
    if owner.callbacks.OnStageChanged then
        owner.callbacks.OnStageChanged(Const.BattleStage.Result)
    end
end

function StgStageResult:OnUpdate(dt)
    -- 结算阶段不再推进战斗
end

function StgStageResult:OnExit()
end

function StgStageResult:Dispose()
end

return StgStageResult
