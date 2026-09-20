---
--- STG 时间轴驱动器
--- 消费 StgLevelConfig.timeline，按 time 推进并分发事件
--- 对齐编辑器 TimelineEditorPanel 的事件类型
---
--- 用法（由 StgBattleLogic 每帧调用）：
---   runner:Reset(cfg.timeline)
---   runner:Update(dt)   -- 内部回调 SpawnWave / SpawnBoss / DropGate / ...
---@class StgTimelineRunner
local StgTimelineRunner = {}
StgTimelineRunner.__index = StgTimelineRunner

local Const = require "Game.STG.Const"

function StgTimelineRunner.New(callbacks)
    local self = setmetatable({}, StgTimelineRunner)
    self.callbacks = callbacks or {}  -- 见下方 _Dispatch 注释
    self.events = {}
    self.cursor = 1
    self.time = 0
    self.duration = 0
    self.finished = false
    return self
end

--- @param timeline table StgLevelConfig.timeline { duration, events[] }
function StgTimelineRunner:Reset(timeline)
    self.events   = (timeline and timeline.events) or {}
    self.duration = (timeline and timeline.duration) or 60
    self.cursor   = 1
    self.time     = 0
    self.finished = false
end

--- @return boolean 时间轴是否已跑完（所有事件已触发且超过 duration）
function StgTimelineRunner:IsFinished()
    return self.finished
end

function StgTimelineRunner:GetTime()
    return self.time
end

function StgTimelineRunner:GetDuration()
    return self.duration
end

function StgTimelineRunner:Update(dt)
    if self.finished then
        return
    end

    self.time = self.time + dt

    -- 按 time 升序触发所有已到期事件
    while self.cursor <= #self.events do
        local ev = self.events[self.cursor]
        if ev.time > self.time then
            break
        end
        self:_Dispatch(ev)
        self.cursor = self.cursor + 1
    end

    if self.time >= self.duration and self.cursor > #self.events then
        self.finished = true
        if self.callbacks.OnTimelineFinished then
            self.callbacks.OnTimelineFinished()
        end
    end
end

--- 事件分发
--- callbacks 约定（全部可选，未注册的事件只打日志）：
---   OnSpawnEnemyWave(templateId, offsetX)
---   OnSpawnBoss(bossId)
---   OnSpawnTrap(trapId, x, y)
---   OnSpawnAreaStart(spawnAreaId, startTime, endTime)
---   OnSpawnAreaStop(spawnAreaId)
---   OnDropDigitalGate(ev)   -- ev 含 gateType/count/dropIntervalSec/offsetXMin..YMax/dropAniDuration/positionX/Y
---   OnSpawnItem(itemId, pattern, count, spacing, x, y)
---   OnChangeScrollSpeed(speed)
---   OnShowBanner(text, duration)
---   OnPlayBgm(bgmId, fadeDuration)
---   OnPauseEnemySpawn(duration)
---   OnResumeEnemySpawn()
---   OnLevelComplete()
---   OnGameOver()
---   OnTriggerCutscene(cutsceneId)
function StgTimelineRunner:_Dispatch(ev)
    local t = ev.type
    local cb = self.callbacks

    if t == Const.TimelineEventType.SpawnEnemyWave then
        if cb.OnSpawnEnemyWave then cb.OnSpawnEnemyWave(ev.templateId, ev.offsetX) end

    elseif t == Const.TimelineEventType.SpawnBoss then
        if cb.OnSpawnBoss then cb.OnSpawnBoss(ev.bossId) end

    elseif t == Const.TimelineEventType.SpawnTrap then
        if cb.OnSpawnTrap then cb.OnSpawnTrap(ev.trapId, ev.positionX, ev.positionY) end

    elseif t == Const.TimelineEventType.SpawnAreaStart then
        if cb.OnSpawnAreaStart then cb.OnSpawnAreaStart(ev.spawnAreaId, ev.startTime, ev.endTime) end

    elseif t == Const.TimelineEventType.SpawnAreaStop then
        if cb.OnSpawnAreaStop then cb.OnSpawnAreaStop(ev.spawnAreaId) end

    elseif t == Const.TimelineEventType.DropDigitalGate then
        if cb.OnDropDigitalGate then cb.OnDropDigitalGate(ev) end

    elseif t == Const.TimelineEventType.SpawnItem then
        if cb.OnSpawnItem then cb.OnSpawnItem(ev.itemId, ev.pattern, ev.count, ev.spacing, ev.positionX, ev.positionY) end

    elseif t == Const.TimelineEventType.ChangeScrollSpeed then
        if cb.OnChangeScrollSpeed then cb.OnChangeScrollSpeed(ev.speed) end

    elseif t == Const.TimelineEventType.ShowBanner then
        if cb.OnShowBanner then cb.OnShowBanner(ev.text, ev.duration) end

    elseif t == Const.TimelineEventType.PlayBgm then
        if cb.OnPlayBgm then cb.OnPlayBgm(ev.bgmId, ev.fadeDuration) end

    elseif t == Const.TimelineEventType.PauseEnemySpawn then
        if cb.OnPauseEnemySpawn then cb.OnPauseEnemySpawn(ev.duration) end

    elseif t == Const.TimelineEventType.ResumeEnemySpawn then
        if cb.OnResumeEnemySpawn then cb.OnResumeEnemySpawn() end

    elseif t == Const.TimelineEventType.LevelComplete then
        if cb.OnLevelComplete then cb.OnLevelComplete() end

    elseif t == Const.TimelineEventType.GameOver then
        if cb.OnGameOver then cb.OnGameOver() end

    elseif t == Const.TimelineEventType.TriggerCutscene then
        if cb.OnTriggerCutscene then cb.OnTriggerCutscene(ev.cutsceneId) end

    else
        Logger.Log('#STG# 未处理的时间轴事件 type=' .. tostring(t) .. ' time=' .. tostring(ev.time))
    end
end

return StgTimelineRunner
