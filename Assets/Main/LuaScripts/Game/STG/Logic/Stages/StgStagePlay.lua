---
--- STG Stage：Play
--- 主玩法：推进时间轴 + 推进波次生成器
--- 结果由时间轴 level_complete / game_over / 时间轴跑完 触发
---@class StgStagePlay
local StgStagePlay = {}
StgStagePlay.__index = StgStagePlay

local FSMachine = require "Common.FSMachine"
local Const = require "Game.STG.Const"
setmetatable(StgStagePlay, FSMachine.State)

function StgStagePlay.Create()
    local copy = {}
    setmetatable(copy, StgStagePlay)
    copy:Init()
    return copy
end

function StgStagePlay:OnEnter()
    Logger.Log('#STG# Stage Play')
    local owner = self.owner
    if owner.callbacks.OnBattleStart then
        owner.callbacks.OnBattleStart()
    end
end

function StgStagePlay:OnUpdate(dt)
    local owner = self.owner
    if owner.cfg == nil then
        return
    end

    owner.elapsed = owner.elapsed + dt

    -- 1. 时间轴：触发到点事件（刷怪/门/Boss/结局）
    owner.runner:Update(dt)

    -- 2. 波次生成器：推进延时入场的编队，到点的请求吐给表现层
    owner.waveSpawner:Update(dt, function(requests)
        if owner.callbacks.OnSpawnRequests then
            owner.callbacks.OnSpawnRequests(requests)
        end
    end)

    -- 3. 通知表现层刷新（进度条等）
    if owner.callbacks.OnPlayUpdate then
        owner.callbacks.OnPlayUpdate(owner.elapsed, owner.runner:GetDuration())
    end
end

function StgStagePlay:OnExit()
end

function StgStagePlay:Dispose()
end

return StgStagePlay
