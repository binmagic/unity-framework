---
--- STG Stage：Load
--- 读 JSON 配置、重置时间轴、通知表现层创建战斗内容
--- 资源异步预载可后续加在本 Stage 的 OnUpdate 里（加载完成再切 Play）
---@class StgStageLoad
local StgStageLoad = {}
StgStageLoad.__index = StgStageLoad

local FSMachine = require "Common.FSMachine"
local Const = require "Game.STG.Const"
local StgLevelConfig = require "Game.STG.DataCenter.StgLevelConfig"
setmetatable(StgStageLoad, FSMachine.State)

function StgStageLoad.Create()
    local copy = {}
    setmetatable(copy, StgStageLoad)
    copy:Init()
    return copy
end

function StgStageLoad:OnEnter()
    local owner = self.owner
    local levelId = owner.pendingLevelId
    Logger.Log('#STG# Stage Load levelId=' .. tostring(levelId))

    local cfg = StgLevelConfig.Load(levelId)
    if cfg == nil then
        Logger.LogError('#STG# Load 失败，配置不存在 levelId=' .. tostring(levelId))
        owner:Fail(Const.BattleResult.Lose)
        return
    end

    owner.cfg = cfg
    owner.levelId = tostring(levelId)

    -- 重置时间轴与波次生成器
    owner.runner:Reset(cfg.timeline)
    owner.waveSpawner:Reset(cfg)

    -- 通知表现层：关卡数据就绪，可以搭场景/主机/HUD
    if owner.callbacks.OnLevelLoaded then
        owner.callbacks.OnLevelLoaded(cfg)
    end

    -- 首期无异步加载，直接进 Play
    -- 后续若要预载 prefab/贴图，在这里改成加载完成回调再 Switch
    owner.fsm:Switch(Const.BattleStage.Play)
end

function StgStageLoad:OnUpdate(dt)
end

function StgStageLoad:OnExit()
end

function StgStageLoad:Dispose()
end

return StgStageLoad
