---
--- 探险玩法 战斗 — 数据管理
--- 关卡进度、局内金币等落地存档。首期本地存档（Setting:GetPrivateInt/SetPrivateInt），
--- 参考 ShipPlayerDataManager 风格，不接服务器，第二期养成上线时再考虑是否上行同步。
---@class PlaneBattleDataManager : Singleton
local PlaneBattleDataManager = BaseClass("PlaneBattleDataManager", Singleton)

local DEFAULT_LEVEL_ID = 1001

local CACHE_KEY_CurLevelId = "PlaneBattle_CurLevelId"
local CACHE_KEY_TotalGold  = "PlaneBattle_TotalGold"
local CACHE_KEY_Formation = "PlaneBattle_Formation_"

function PlaneBattleDataManager:__init()
    self.curLevelId = nil
    self.totalGold  = nil
end

--- 探险独立五槽存档。0 代表空位，不改变主玩法的单英雄出战配置。
function PlaneBattleDataManager:GetFormation()
    local heroes = DataCenter.HeroDataManager
    local slots, seen, hasSavedFormation = {}, {}, false
    for i = 1, 5 do
        -- -1 区分从未配置与玩家主动清空；0 是需要原样保留的空位。
        local id = Setting:GetPrivateInt(CACHE_KEY_Formation .. i, -1)
        if id ~= -1 then hasSavedFormation = true end
        if id > 0 and heroes:IsHeroOwned(id) and not seen[id] then
            slots[i], seen[id] = id, true
        else
            slots[i] = 0
        end
    end
    if not hasSavedFormation then
        local id = tonumber(heroes:GetDeployedHeroId()) or 0
        if id ~= 0 and heroes:IsHeroOwned(id) then slots[1] = id end
    end
    return slots
end

--- 所有机位都可下阵；已在队中的英雄与目标槽交换，包括移动到空护航位。
function PlaneBattleDataManager:SetFormationSlot(index, heroId)
    index, heroId = tonumber(index), tonumber(heroId)
    if index == nil or index % 1 ~= 0 or index < 1 or index > 5 then return false end
    if heroId == nil then return false end
    if heroId ~= 0 and not DataCenter.HeroDataManager:IsHeroOwned(heroId) then return false end
    local slots = self:GetFormation()
    local old = slots[index]
    for i = 1, 5 do
        if heroId ~= 0 and slots[i] == heroId and i ~= index then
            slots[i] = old
            break
        end
    end
    slots[index] = heroId
    for i = 1, 5 do Setting:SetPrivateInt(CACHE_KEY_Formation .. i, slots[i]) end
    return true
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
