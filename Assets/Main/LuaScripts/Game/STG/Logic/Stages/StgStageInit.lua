---
--- STG Stage：Init
--- 加载关卡配置、初始化时间轴、通知表现层准备
---@class StgStageInit
local StgStageInit = {}
StgStageInit.__index = StgStageInit

local FSMachine = require "Common.FSMachine"
local Const = require "Game.STG.Const"
setmetatable(StgStageInit, FSMachine.State)

function StgStageInit.Create()
    local copy = {}
    setmetatable(copy, StgStageInit)
    copy:Init()
    return copy
end

function StgStageInit:OnEnter(levelId)
    local owner = self.owner
    Logger.Log('#STG# Stage Init levelId=' .. tostring(levelId))

    owner.pendingLevelId = levelId
    owner.cfg = nil
    owner.result = Const.BattleResult.None
    owner.elapsed = 0
    owner.wingmanCount = 0
    owner.gold = 0

    -- 立刻进 Load（首期没有异步资源预载，Init 只做状态归零）
    owner.fsm:Switch(Const.BattleStage.Load)
end

function StgStageInit:OnUpdate(dt)
end

function StgStageInit:OnExit()
end

function StgStageInit:Dispose()
end

return StgStageInit
