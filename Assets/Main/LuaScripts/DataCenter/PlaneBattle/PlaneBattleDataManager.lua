---
--- 探险玩法 战斗 — 数据管理
--- 关卡进度、局内金币等落地存档。首期本地存档（Setting:GetPrivateInt/SetPrivateInt），
--- 参考 ShipPlayerDataManager 风格，不接服务器，第二期养成上线时再考虑是否上行同步。
---@class PlaneBattleDataManager : Singleton
local PlaneBattleDataManager = BaseClass("PlaneBattleDataManager", Singleton)

local DEFAULT_LEVEL_ID = 1001

local CACHE_KEY_CurLevelId = "PlaneBattle_CurLevelId"
local CACHE_KEY_TotalGold  = "PlaneBattle_TotalGold"

function PlaneBattleDataManager:__init()
    self.curLevelId = nil
    self.totalGold  = nil
end

--- 当前应挑战的关卡ID（未通关过任何关卡时给默认关卡）
function PlaneBattleDataManager:GetCurLevelId()
    if self.curLevelId == nil then
        self.curLevelId = Setting:GetPrivateInt(CACHE_KEY_CurLevelId, DEFAULT_LEVEL_ID)
    end
    return self.curLevelId
end

--- 通关结算：推进到下一关，累加金币
--- nextLevelId 由调用方决定（本轮固定用 levelId+1，第二期若要非线性关卡图再改）
function PlaneBattleDataManager:OnLevelPass(levelId, rewardGold)
    local nextLevelId = (tonumber(levelId) or DEFAULT_LEVEL_ID) + 1
    if nextLevelId > self:GetCurLevelId() then
        self.curLevelId = nextLevelId
        Setting:SetPrivateInt(CACHE_KEY_CurLevelId, self.curLevelId)
    end

    if rewardGold ~= nil and rewardGold > 0 then
        self:AddGold(rewardGold)
    end
end

function PlaneBattleDataManager:GetTotalGold()
    if self.totalGold == nil then
        self.totalGold = Setting:GetPrivateInt(CACHE_KEY_TotalGold, 0)
    end
    return self.totalGold
end

function PlaneBattleDataManager:AddGold(count)
    self.totalGold = self:GetTotalGold() + (tonumber(count) or 0)
    Setting:SetPrivateInt(CACHE_KEY_TotalGold, self.totalGold)
    EventManager:GetInstance():Broadcast(EventId.PlaneGoldChanged, self.totalGold)
end

return PlaneBattleDataManager
