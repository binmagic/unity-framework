---
--- 英雄模块 — 数据管理
--- 职责：包装 Hero_Config 配置表读取 + 出战英雄的本地存档。
--- 首期不做抽卡/碎片解锁：配置表里的英雄默认视为全部已拥有，等级固定为1，
--- 不接升级消耗流程（那是养成玩法的核心数值循环，超出"打通英雄模块出战联动"的范围）。
--- 出战英雄做**全局单选**（不是设计文档 §5 的多槎位部署系统），足够支撑
--- "出战英雄的带兵量增加 → 抬高探险战斗僚机初始数量" 这条联动链路。
---@class HeroDataManager : Singleton
local HeroDataManager = BaseClass("HeroDataManager", Singleton)

local CACHE_KEY_DeployedHeroId = "Hero_DeployedHeroId"

function HeroDataManager:__init()
    self.deployedHeroId = nil  -- nil = 还没从存档读过；0 = 存档里就是没选（走默认兜底）
    self.allHeroIds = nil      -- 缓存一次配置表全部 id，避免每次 GetAllHeroIds 都 visitTable
end

--- ---------------------------------------------------------------
--- 配置表读取
--- ---------------------------------------------------------------

--- 获取单个英雄配置（不存在返回 nil）
--- 返回 { id, name, faction, role, rarity, base_firepower, base_durability, base_armor, base_troop }
function HeroDataManager:GetHeroConfig(heroId)
    if heroId == nil then return nil end
    local line = LocalController:instance():getLine(TableName.Hero_Config, heroId)
    if line == nil then
        return nil
    end

    return {
        id               = line:getValue("id"),
        name             = line:getValue("name"),
        faction          = line:getValue("faction"),
        role             = line:getValue("role"),
        rarity           = line:getValue("rarity"),
        base_firepower   = line:getValue("base_firepower"),
        base_durability  = line:getValue("base_durability"),
        base_armor       = line:getValue("base_armor"),
        base_troop       = line:getValue("base_troop"),
        star             = line:getValue("star"),
        skill_name       = line:getValue("skill_name"),
        skill_cooldown   = line:getValue("skill_cooldown"),
        skill_tag        = line:getValue("skill_tag"),
        skill_desc       = line:getValue("skill_desc"),
        skill_rank_bonus = line:getValue("skill_rank_bonus"),
    }
end

--- 获取全部英雄 id 列表（按配置表定义顺序，不保证稳定顺序，UI 侧如需固定顺序自行 sort）
function HeroDataManager:GetAllHeroIds()
    if self.allHeroIds == nil then
        self.allHeroIds = {}
        LocalController:instance():visitTable(TableName.Hero_Config, function(id, lineData)
            table.insert(self.allHeroIds, id)
        end)
        table.sort(self.allHeroIds)
    end
    return self.allHeroIds
end

--- 按阵营筛选英雄 id 列表；faction 为 nil 时返回全部（对应"全部"页签）
--- @param faction string|nil "Empire"|"Federation"|"FreeArmy"|nil
function HeroDataManager:GetHeroIdsByFaction(faction)
    local allIds = self:GetAllHeroIds()
    if faction == nil then
        return allIds
    end

    local result = {}
    for _, heroId in ipairs(allIds) do
        local cfg = self:GetHeroConfig(heroId)
        if cfg ~= nil and cfg.faction == faction then
            table.insert(result, heroId)
        end
    end
    return result
end

--- ---------------------------------------------------------------
--- 拥有 / 等级（首期占位：全部已拥有，等级固定1，不接升级流程）
--- ---------------------------------------------------------------

function HeroDataManager:IsHeroOwned(heroId)
    return self:GetHeroConfig(heroId) ~= nil
end

function HeroDataManager:GetHeroLevel(heroId)
    return 1
end

--- 当前军衔星级（0~5），来自配置表 `star` 字段，纯展示用，不接真实军衔提升消耗流程
function HeroDataManager:GetHeroStar(heroId)
    local cfg = self:GetHeroConfig(heroId)
    return cfg ~= nil and (cfg.star or 0) or 0
end

--- ---------------------------------------------------------------
--- 出战英雄（全局单选）
--- ---------------------------------------------------------------

--- 获取当前出战英雄 id；存档为空或指向的英雄配置已不存在时，兜底选配置表第一个英雄
function HeroDataManager:GetDeployedHeroId()
    if self.deployedHeroId == nil then
        self.deployedHeroId = Setting:GetPrivateInt(CACHE_KEY_DeployedHeroId, 0)
    end

    if self.deployedHeroId == 0 or self:GetHeroConfig(self.deployedHeroId) == nil then
        local allIds = self:GetAllHeroIds()
        if #allIds > 0 then
            self.deployedHeroId = allIds[1]
        end
    end

    return self.deployedHeroId
end

--- 设置出战英雄；heroId 必须是已拥有的合法英雄，否则忽略并返回 false
function HeroDataManager:SetDeployedHero(heroId)
    if not self:IsHeroOwned(heroId) then
        Logger.LogError('#Hero# 尝试设置出战英雄失败，英雄不存在 heroId=' .. tostring(heroId))
        return false
    end

    self.deployedHeroId = heroId
    Setting:SetPrivateInt(CACHE_KEY_DeployedHeroId, heroId)
    EventManager:GetInstance():Broadcast(EventId.HeroDeployedChanged, heroId)
    return true
end

--- 便捷方法：直接拿当前出战英雄的配置（给 PlaneBattle 等外部模块用，nil = 没有可出战英雄）
function HeroDataManager:GetDeployedHeroConfig()
    local heroId = self:GetDeployedHeroId()
    if heroId == nil or heroId == 0 then
        return nil
    end
    return self:GetHeroConfig(heroId)
end

return HeroDataManager
