---
--- 探险玩法 战斗 — Controller
--- 关卡数据读取、进度判定、结算
---@class UIPlaneBattleCtrl : UIBaseCtrl
local UIPlaneBattleCtrl = BaseClass("UIPlaneBattleCtrl", UIBaseCtrl)

--- 默认关卡（新玩家/参数缺失兜底）
local DEFAULT_LEVEL_ID = 1001

--- 读取关卡元数据（PlaneLevel_Config）
--- 返回 { id, name, duration, boss_id, win_condition, bg_asset, base_wingman } 或 nil
function UIPlaneBattleCtrl:GetLevelMeta(levelId)
    levelId = levelId or DEFAULT_LEVEL_ID
    local line = LocalController:instance():getLine(TableName.PlaneLevel_Config, levelId)
    if line == nil then
        Logger.LogError('#PlaneBattle# 策划配置错误！关卡不存在！levelId:' .. tostring(levelId))
        return nil
    end

    return {
        id            = line:getValue("id"),
        name          = line:getValue("name"),
        duration      = line:getValue("duration"),
        boss_id       = line:getValue("boss_id"),
        win_condition = line:getValue("win_condition"),
        bg_asset      = line:getValue("bg_asset"),
        base_wingman  = line:getValue("base_wingman"),
    }
end

--- 读取该关卡的出生点时间轴（PlaneSpawn_Config），按 time 升序排列
--- 返回 { { id, time, type, x, para, trigger_id }, ... }
function UIPlaneBattleCtrl:GetSpawnTimeline(levelId)
    levelId = levelId or DEFAULT_LEVEL_ID
    local result = {}

    LocalController:instance():visitTable(TableName.PlaneSpawn_Config, function(id, lineData)
        if lineData:getValue("level_id") == levelId then
            table.insert(result, {
                id         = lineData:getValue("id"),
                time       = lineData:getValue("time"),
                type       = lineData:getValue("type"),
                x          = lineData:getValue("x"),
                para       = lineData:getValue("para"),
                trigger_id = lineData:getValue("trigger_id"),
            })
        end
    end)

    table.sort(result, function(a, b) return a.time < b.time end)
    return result
end

--- 读取触发效果配置（PlaneTrigger_Config）
--- 返回 { id, type, para, icon } 或 nil
function UIPlaneBattleCtrl:GetTriggerMeta(triggerId)
    if triggerId == nil or triggerId == 0 then
        return nil
    end

    local line = LocalController:instance():getLine(TableName.PlaneTrigger_Config, triggerId)
    if line == nil then
        Logger.LogError('#PlaneBattle# 策划配置错误！触发效果不存在！triggerId:' .. tostring(triggerId))
        return nil
    end

    return {
        id   = line:getValue("id"),
        type = line:getValue("type"),
        para = line:getValue("para"),
        icon = line:getValue("icon"),
    }
end

--- 读取全部关卡配置，按 id 升序。选关界面用。
--- 返回 { { id, name, base_wingman, duration }, ... }
function UIPlaneBattleCtrl:GetAllLevels()
    local result = {}
    LocalController:instance():visitTable(TableName.PlaneLevel_Config, function(id, lineData)
        table.insert(result, {
            id           = lineData:getValue("id"),
            name         = lineData:getValue("name"),
            base_wingman = lineData:getValue("base_wingman"),
            duration     = lineData:getValue("duration"),
        })
    end)
    table.sort(result, function(a, b) return a.id < b.id end)
    return result
end

--- 某关是否已解锁：id <= 当前进度关卡 即可打（含已通关的和当前待挑战的）
function UIPlaneBattleCtrl:IsLevelUnlocked(levelId)
    local mgr = DataCenter.PlaneBattleDataManager
    if mgr == nil then
        return levelId == DEFAULT_LEVEL_ID
    end
    return levelId <= mgr:GetCurLevelId()
end

--- 当前应该进入的关卡ID（存档进度 + 1，新玩家给默认值）
--- 存档进度可能超前于配置表（比如测试环境只填了1001一条数据就把关卡打穿存了1002），
--- 这里做兜底：进度指向的关卡在配置表里不存在时退回默认关卡，避免整局没有任何内容可打。
function UIPlaneBattleCtrl:GetCurLevelId()
    local mgr = DataCenter.PlaneBattleDataManager
    if mgr == nil then
        return DEFAULT_LEVEL_ID
    end

    local levelId = mgr:GetCurLevelId()
    if LocalController:instance():getLine(TableName.PlaneLevel_Config, levelId) == nil then
        Logger.Log('#PlaneBattle# 存档关卡levelId=' .. tostring(levelId) .. '在配置表里不存在，退回默认关卡' .. DEFAULT_LEVEL_ID)
        return DEFAULT_LEVEL_ID
    end

    return levelId
end

--- 通关结算：记录进度、发结算事件
function UIPlaneBattleCtrl:OnBattleWin(levelId, rewardGold)
    local mgr = DataCenter.PlaneBattleDataManager
    if mgr ~= nil then
        mgr:OnLevelPass(levelId, rewardGold)
    end
    EventManager:GetInstance():Broadcast(EventId.PlaneBattleWin, { levelId = levelId, rewardGold = rewardGold })
end

function UIPlaneBattleCtrl:OnBattleLose(levelId)
    EventManager:GetInstance():Broadcast(EventId.PlaneBattleLose, { levelId = levelId })
end

return UIPlaneBattleCtrl
