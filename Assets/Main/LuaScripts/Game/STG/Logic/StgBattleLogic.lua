---
--- STG 战斗主逻辑
--- 职责：Stage FSM 驱动关卡流程 + 时间轴 + 波次生成 + 数值/结算
--- 不持有 GameObject，表现由 View 回调实现
---
--- 用法：
---   local logic = require("Game.STG.Logic.StgBattleLogic").New()
---   logic:Init(callbacks)
---   logic:StartLevel("1001")
---   logic:Update(dt)        -- 每帧
---   logic:Destroy()
---
---@class StgBattleLogic
local StgBattleLogic = {}
StgBattleLogic.__index = StgBattleLogic

local FSMachine          = require "Common.FSMachine"
local Const              = require "Game.STG.Const"
local StgTimelineRunner  = require "Game.STG.Spawner.StgTimelineRunner"
local StgWaveSpawner     = require "Game.STG.Spawner.StgWaveSpawner"
local StgTriggerEnum     = require "Game.STG.Trigger.StgTriggerEnum"

function StgBattleLogic.New()
    local self = setmetatable({}, StgBattleLogic)
    self.cfg = nil
    self.levelId = nil
    self.pendingLevelId = nil
    self.result = Const.BattleResult.None
    self.wingmanCount = 0
    self.gold = 0
    self.elapsed = 0
    self.runner = nil
    self.waveSpawner = nil
    self.callbacks = {}
    self.fsm = nil
    return self
end

--- 注册表现层回调
--- 时间轴事件（透传）：
---   OnSpawnBoss(bossId) / OnSpawnTrap(trapId,x,y) / OnDropDigitalGate(ev)
---   OnSpawnAreaStart / OnSpawnAreaStop / OnSpawnItem
---   OnChangeScrollSpeed / OnShowBanner / OnPlayBgm / OnTriggerCutscene
---   OnPauseEnemySpawn(duration) / OnResumeEnemySpawn()
--- 波次生成：
---   OnSpawnRequests(requests)   -- StgWaveSpawner 产出的敌机生成请求列表
--- 流程：
---   OnLevelLoaded(cfg) / OnBattleStart()
---   OnPlayUpdate(elapsed, duration)
---   OnBattleWin() / OnBattleLose()
---   OnStageChanged(stage)
--- 数值：
---   OnWingmanCountChanged(count) / OnGoldChanged(total)
function StgBattleLogic:Init(callbacks)
    self.callbacks = callbacks or {}
    self.runner = StgTimelineRunner.New(self:_BuildRunnerCallbacks())
    self.waveSpawner = StgWaveSpawner.New()
    self:_InitFSM()
end

function StgBattleLogic:_InitFSM()
    self.fsm = FSMachine.Create(self)
    self.fsm:Add(Const.BattleStage.Init,   require("Game.STG.Logic.Stages.StgStageInit").Create())
    self.fsm:Add(Const.BattleStage.Load,   require("Game.STG.Logic.Stages.StgStageLoad").Create())
    self.fsm:Add(Const.BattleStage.Play,   require("Game.STG.Logic.Stages.StgStagePlay").Create())
    self.fsm:Add(Const.BattleStage.Result, require("Game.STG.Logic.Stages.StgStageResult").Create())
end

function StgBattleLogic:_BuildRunnerCallbacks()
    local cb = self.callbacks
    local runnerCb = {}

    -- 波次：交给 WaveSpawner 算编队，不再直接透传 templateId
    runnerCb.OnSpawnEnemyWave = function(templateId, offsetX)
        self.waveSpawner:SpawnWave(templateId, offsetX)
    end

    -- 暂停/恢复刷怪：同时控制 WaveSpawner
    runnerCb.OnPauseEnemySpawn = function(duration)
        self.waveSpawner:PauseSpawn(duration)
        if cb.OnPauseEnemySpawn then cb.OnPauseEnemySpawn(duration) end
    end
    runnerCb.OnResumeEnemySpawn = function()
        self.waveSpawner:ResumeSpawn()
        if cb.OnResumeEnemySpawn then cb.OnResumeEnemySpawn() end
    end

    -- 原样透传的事件
    runnerCb.OnSpawnBoss        = cb.OnSpawnBoss
    runnerCb.OnSpawnTrap        = cb.OnSpawnTrap
    runnerCb.OnSpawnAreaStart   = cb.OnSpawnAreaStart
    runnerCb.OnSpawnAreaStop    = cb.OnSpawnAreaStop
    runnerCb.OnDropDigitalGate  = cb.OnDropDigitalGate
    runnerCb.OnSpawnItem        = cb.OnSpawnItem
    runnerCb.OnChangeScrollSpeed= cb.OnChangeScrollSpeed
    runnerCb.OnShowBanner       = cb.OnShowBanner
    runnerCb.OnPlayBgm          = cb.OnPlayBgm
    runnerCb.OnTriggerCutscene  = cb.OnTriggerCutscene

    -- 结局事件由逻辑接管
    runnerCb.OnLevelComplete = function()
        self:Win()
    end
    runnerCb.OnGameOver = function()
        self:Lose()
    end
    runnerCb.OnTimelineFinished = function()
        if self.result == Const.BattleResult.None then
            self:Win()
        end
    end

    return runnerCb
end

--- 开始一关（入口，切到 Init Stage）
--- @param levelId string|number
function StgBattleLogic:StartLevel(levelId)
    self.pendingLevelId = levelId
    self.fsm:Switch(Const.BattleStage.Init, levelId)
end

function StgBattleLogic:Update(dt)
    if self.fsm == nil then
        return
    end
    -- Play Stage 内部驱动 runner / waveSpawner，这里只推 FSM
    self.fsm:Update(dt)
end

--- ---------- 战斗数值（供门/机关触发） ----------

function StgBattleLogic:AddWingman(count)
    self.wingmanCount = math.max(0, self.wingmanCount + (tonumber(count) or 0))
    if self.callbacks.OnWingmanCountChanged then
        self.callbacks.OnWingmanCountChanged(self.wingmanCount)
    end
end

function StgBattleLogic:RemoveWingman(count)
    self:AddWingman(-(tonumber(count) or 0))
end

function StgBattleLogic:MultiplyWingman(factor)
    self.wingmanCount = math.floor(self.wingmanCount * (tonumber(factor) or 1))
    if self.callbacks.OnWingmanCountChanged then
        self.callbacks.OnWingmanCountChanged(self.wingmanCount)
    end
end

function StgBattleLogic:AddGold(count)
    self.gold = self.gold + (tonumber(count) or 0)
    if self.callbacks.OnGoldChanged then
        self.callbacks.OnGoldChanged(self.gold)
    end
end

--- 门/机关命中时按 effectId 执行效果
function StgBattleLogic:ExecuteEffect(effectId)
    return StgTriggerEnum.Execute(effectId, {
        AddWingman      = function(n) self:AddWingman(n) end,
        RemoveWingman   = function(n) self:RemoveWingman(n) end,
        AddGold         = function(n) self:AddGold(n) end,
        MultiplyWingman = function(k) self:MultiplyWingman(k) end,
    })
end

--- ---------- 结算 ----------

function StgBattleLogic:Win()
    self:_Finish(Const.BattleResult.Win, self.callbacks.OnBattleWin)
end

function StgBattleLogic:Lose()
    self:_Finish(Const.BattleResult.Lose, self.callbacks.OnBattleLose)
end

function StgBattleLogic:Fail(result)
    self:_Finish(result or Const.BattleResult.Lose, self.callbacks.OnBattleLose)
end

function StgBattleLogic:_Finish(result, cb)
    if self.result ~= Const.BattleResult.None then
        return
    end
    self.result = result
    self.fsm:Switch(Const.BattleStage.Result, result)
    Logger.Log('#STG# 战斗结束 result=' .. tostring(result) .. ' levelId=' .. tostring(self.levelId))
    if cb then
        cb()
    end
end

--- ---------- 查询 ----------

function StgBattleLogic:GetWingmanCount() return self.wingmanCount end
function StgBattleLogic:GetGold() return self.gold end
function StgBattleLogic:GetConfig() return self.cfg end
function StgBattleLogic:GetLevelId() return self.levelId end
function StgBattleLogic:GetResult() return self.result end
function StgBattleLogic:GetStage()
    if self.fsm == nil then return Const.BattleStage.None end
    return self.fsm.currStateName or Const.BattleStage.None
end
function StgBattleLogic:GetProgress()
    if self.runner == nil then return 0 end
    local d = self.runner:GetDuration()
    if d <= 0 then return 0 end
    return math.min(1, self.runner:GetTime() / d)
end

function StgBattleLogic:Destroy()
    if self.fsm ~= nil then
        self.fsm:Dispose()
        self.fsm = nil
    end
    self.cfg = nil
    self.runner = nil
    self.waveSpawner = nil
    self.callbacks = {}
    self.result = Const.BattleResult.None
end

return StgBattleLogic
