---
--- 英雄模块 — 数据管理
--- 包装 Hero_Config（称号/等级/立绘路径/军衔预览等截图对齐字段）+ 出战英雄本地存档。
--- owned=0 的英雄参与图鉴展示，但不可出战；详情页走满级预览/获取。
---@class HeroDataManager : Singleton
local HeroDataManager = BaseClass("HeroDataManager", Singleton)

local CACHE_KEY_DeployedHeroId = "Hero_DeployedHeroId"

function HeroDataManager:__init()
    self.deployedHeroId = nil
    self.allHeroIds = nil
    self.runtimeLevel = {}
    self.runtimeStar = {}
end

--- ---------------------------------------------------------------
--- 配置表读取
--- ---------------------------------------------------------------

function HeroDataManager:GetHeroConfig(heroId)
    if heroId == nil then return nil end
    local line = LocalController:instance():getLine(TableName.Hero_Config, heroId)
    if line == nil then
        return nil
    end

    return {
        id               = line:getValue("id"),
        name             = line:getValue("name"),
        title            = line:getValue("title"),
        faction          = line:getValue("faction"),
        role             = line:getValue("role"),
        rarity           = line:getValue("rarity"),
        base_firepower   = line:getValue("base_firepower"),
        base_durability  = line:getValue("base_durability"),
        base_armor       = line:getValue("base_armor"),
        base_troop       = line:getValue("base_troop"),
        star             = line:getValue("star"),
        owned            = line:getValue("owned"),
        level            = line:getValue("level"),
        power            = line:getValue("power"),
        skill_name       = line:getValue("skill_name"),
        skill_cooldown   = line:getValue("skill_cooldown"),
        skill_tag        = line:getValue("skill_tag"),
        skill_dmg_type   = line:getValue("skill_dmg_type"),
        skill_desc       = line:getValue("skill_desc"),
        skill_rank_bonus = line:getValue("skill_rank_bonus"),
        skill_level      = line:getValue("skill_level"),
        skill_max_level  = line:getValue("skill_max_level"),
        portrait         = line:getValue("portrait"),
        card             = line:getValue("card"),
        avatar           = line:getValue("avatar"),
        rank_durability  = line:getValue("rank_durability"),
        rank_firepower   = line:getValue("rank_firepower"),
        rank_armor       = line:getValue("rank_armor"),
        upgrade_cost     = line:getValue("upgrade_cost"),
        promote_cost_1   = line:getValue("promote_cost_1"),
        promote_cost_2   = line:getValue("promote_cost_2"),
        shard_progress   = line:getValue("shard_progress"),
        max_level        = line:getValue("max_level"),
    }
end

function HeroDataManager:GetAllHeroIds()
    -- 空结果绝不缓存：首开配置表偶发未就绪
    if self.allHeroIds ~= nil and #self.allHeroIds > 0 then
        return self.allHeroIds
    end
    local ids = {}
    local ok = pcall(function()
        LocalController:instance():visitTable(TableName.Hero_Config, function(id, lineData)
            table.insert(ids, id)
        end)
    end)
    if not ok or #ids == 0 then
        self.allHeroIds = nil
        return {}
    end
    table.sort(ids)
    self.allHeroIds = ids
    return self.allHeroIds
end

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
--- 拥有 / 等级
--- ---------------------------------------------------------------

function HeroDataManager:IsHeroOwned(heroId)
    local cfg = self:GetHeroConfig(heroId)
    if cfg == nil then return false end
    local owned = cfg.owned
    if owned == nil then return true end
    return tonumber(owned) == 1
end

function HeroDataManager:GetHeroLevel(heroId)
    local cfg = self:GetHeroConfig(heroId)
    if cfg == nil then return 0 end
    return tonumber(cfg.level) or 0
end

function HeroDataManager:GetHeroStar(heroId)
    local cfg = self:GetHeroConfig(heroId)
    return cfg ~= nil and (cfg.star or 0) or 0
end

--- ---------------------------------------------------------------
--- 出战英雄（全局单选，仅已拥有）
--- ---------------------------------------------------------------

function HeroDataManager:GetDeployedHeroId()
    if self.deployedHeroId == nil then
        self.deployedHeroId = Setting:GetPrivateInt(CACHE_KEY_DeployedHeroId, 0)
    end

    local valid = self.deployedHeroId ~= nil
        and self.deployedHeroId ~= 0
        and self:IsHeroOwned(self.deployedHeroId)
    if not valid then
        local allIds = self:GetAllHeroIds()
        self.deployedHeroId = 0
        for _, heroId in ipairs(allIds) do
            if self:IsHeroOwned(heroId) then
                self.deployedHeroId = heroId
                break
            end
        end
    end

    return self.deployedHeroId
end

function HeroDataManager:SetDeployedHero(heroId)
    if not self:IsHeroOwned(heroId) then
        Logger.LogError('#Hero# 尝试设置出战英雄失败，英雄不存在或未拥有 heroId=' .. tostring(heroId))
        return false
    end

    self.deployedHeroId = heroId
    Setting:SetPrivateInt(CACHE_KEY_DeployedHeroId, heroId)
    EventManager:GetInstance():Broadcast(EventId.HeroDeployedChanged, heroId)
    return true
end

function HeroDataManager:GetDeployedHeroConfig()
    local heroId = self:GetDeployedHeroId()
    if heroId == nil or heroId == 0 then
        return nil
    end
    return self:GetHeroConfig(heroId)
end

--- ---------------------------------------------------------------
--- 升级 / 军衔（本地运行时状态，对齐截图的消耗展示）
--- 消耗格式 "have/need"，have 不足则失败
--- ---------------------------------------------------------------

local function ParseCost(cost)
    if cost == nil or cost == "" or cost == "-" then return nil, nil end
    local have, need = string.match(tostring(cost), "^(%d+)/(%d+)")
    if have == nil then return nil, nil end
    return tonumber(have), tonumber(need)
end

function HeroDataManager:TryUpgradeHero(heroId)
    if not self:IsHeroOwned(heroId) then
        return false, "未拥有该英雄"
    end
    local cfg = self:GetHeroConfig(heroId)
    if cfg == nil then return false, "配置缺失" end
    local maxLv = tonumber(cfg.max_level) or 150
    local have, need = ParseCost(cfg.upgrade_cost)
    if have == nil then
        return false, "无升级消耗配置"
    end
    if have < need then
        return false, "材料不足 " .. tostring(have) .. "/" .. tostring(need)
    end
    self.runtimeLevel = self.runtimeLevel or {}
    local cur = self.runtimeLevel[heroId] or (tonumber(cfg.level) or 1)
    if cur >= maxLv then
        return false, "已满级"
    end
    self.runtimeLevel[heroId] = cur + 1
    EventManager:GetInstance():Broadcast(EventId.HeroDeployedChanged, heroId)
    return true, "升级成功 " .. (cur + 1) .. "级"
end

function HeroDataManager:TryPromoteHero(heroId)
    if not self:IsHeroOwned(heroId) then
        return false, "未拥有该英雄"
    end
    local cfg = self:GetHeroConfig(heroId)
    if cfg == nil then return false, "配置缺失" end
    local have1, need1 = ParseCost(cfg.promote_cost_1)
    local have2, need2 = ParseCost(cfg.promote_cost_2)
    if have1 == nil and have2 == nil then
        return false, "无军衔消耗配置"
    end
    if have1 ~= nil and have1 < need1 then
        return false, "材料不足"
    end
    if have2 ~= nil and have2 < need2 then
        return false, "材料不足"
    end
    self.runtimeStar = self.runtimeStar or {}
    local cur = self.runtimeStar[heroId] or (tonumber(cfg.star) or 0)
    if cur >= 5 then
        return false, "军衔已满"
    end
    self.runtimeStar[heroId] = cur + 1
    EventManager:GetInstance():Broadcast(EventId.HeroDeployedChanged, heroId)
    return true, "提升军衔成功 " .. (cur + 1) .. "星"
end

function HeroDataManager:GetHeroLevel(heroId)
    if self.runtimeLevel ~= nil and self.runtimeLevel[heroId] ~= nil then
        return self.runtimeLevel[heroId]
    end
    local cfg = self:GetHeroConfig(heroId)
    if cfg == nil then return 0 end
    return tonumber(cfg.level) or 0
end

function HeroDataManager:GetHeroStar(heroId)
    if self.runtimeStar ~= nil and self.runtimeStar[heroId] ~= nil then
        return self.runtimeStar[heroId]
    end
    local cfg = self:GetHeroConfig(heroId)
    return cfg ~= nil and (tonumber(cfg.star) or 0) or 0
end

return HeroDataManager
