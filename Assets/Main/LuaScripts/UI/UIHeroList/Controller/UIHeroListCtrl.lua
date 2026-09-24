---
--- 英雄图鉴列表 — Controller
--- 卡片数据：已拥有优先 + 等级/星级/立绘/碎片进度
---@class UIHeroListCtrl : UIBaseCtrl
local UIHeroListCtrl = BaseClass("UIHeroListCtrl", UIBaseCtrl)

UIHeroListCtrl.FactionTabs = {
    { key = nil,            name = "全部",   icon = "Assets/Main/Sprites/HeroUI/HeroUI_faction_all.png" },
    { key = "Empire",       name = "帝国",   icon = "Assets/Main/Sprites/HeroUI/HeroUI_faction_empire.png" },
    { key = "Federation",   name = "联邦",   icon = "Assets/Main/Sprites/HeroUI/HeroUI_faction_federation.png" },
    { key = "FreeArmy",     name = "自由军", icon = "Assets/Main/Sprites/HeroUI/HeroUI_faction_freearmy.png" },
}

--- 截图里带「待修复」黄条的英雄位（纯展示，不接修复流程）
local NEED_REPAIR = {
    [1013] = true, -- 琪拉（对齐截图猫耳位）
    [1010] = true,
}

local FACTION_NAME = {
    Empire     = "帝国",
    Federation = "联邦",
    FreeArmy   = "自由军",
}

local ROLE_NAME = {
    Output  = "输出",
    Defense = "防守",
    Support = "辅助",
}

local RARITY_COLOR = {
    [1] = { 0.20, 0.48, 0.30, 1 },
    [2] = { 0.16, 0.34, 0.62, 1 },
    [3] = { 0.40, 0.24, 0.62, 1 },
    [4] = { 0.70, 0.48, 0.14, 1 },
}

local FACTION_COLOR = {
    Empire     = { 0.75, 0.20, 0.20, 1 },
    Federation = { 0.20, 0.45, 0.80, 1 },
    FreeArmy   = { 0.55, 0.55, 0.55, 1 },
}

local FACTION_ICON = {
    Empire     = "Assets/Main/Sprites/HeroUI/HeroUI_faction_empire.png",
    Federation = "Assets/Main/Sprites/HeroUI/HeroUI_faction_federation.png",
    FreeArmy   = "Assets/Main/Sprites/HeroUI/HeroUI_faction_freearmy.png",
}

local ROLE_ICON = {
    Output  = "Assets/Main/Sprites/HeroUI/HeroUI_role_output.png",
    Defense = "Assets/Main/Sprites/HeroUI/HeroUI_role_defense.png",
    Support = "Assets/Main/Sprites/HeroUI/HeroUI_role_support.png",
}

function UIHeroListCtrl:GetFactionIcon(faction)
    return FACTION_ICON[faction]
end

function UIHeroListCtrl:GetRoleIcon(role)
    return ROLE_ICON[role]
end

function UIHeroListCtrl:GetFactionName(faction)
    return FACTION_NAME[faction] or ""
end

function UIHeroListCtrl:GetRoleName(role)
    return ROLE_NAME[role] or ""
end

function UIHeroListCtrl:GetRarityColor(rarity)
    return RARITY_COLOR[rarity] or RARITY_COLOR[1]
end

function UIHeroListCtrl:GetFactionColor(faction)
    return FACTION_COLOR[faction] or { 0.5, 0.5, 0.5, 1 }
end

--- 星级文本：字体无★字形，用 * / - + 颜色区分
local function StarText(star)
    star = tonumber(star) or 0
    local filled = math.min(math.max(star, 0), 5)
    return string.rep("*", filled) .. string.rep("-", 5 - filled)
end

--- 组装卡片列表：已拥有优先，其次按 id
function UIHeroListCtrl:GetCardList(faction)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return {} end

    local ok, result = pcall(function()
        return self:_BuildCardList(mgr, faction)
    end)
    if not ok then
        Logger.LogWarning("UIHeroListCtrl GetCardList err " .. tostring(result))
        return {}
    end
    return result or {}
end

function UIHeroListCtrl:_BuildCardList(mgr, faction)
    local deployedId = mgr:GetDeployedHeroId()
    local heroIds = mgr:GetHeroIdsByFaction(faction)
    if heroIds == nil or #heroIds == 0 then
        heroIds = mgr:GetAllHeroIds()
    end
    local result = {}

    for _, heroId in ipairs(heroIds or {}) do
        local cfg = mgr:GetHeroConfig(heroId)
        if cfg ~= nil then
            local owned = mgr:IsHeroOwned(cfg.id)
            local level = mgr:GetHeroLevel(cfg.id)
            local star = tonumber(mgr.GetHeroStar and mgr:GetHeroStar(cfg.id) or cfg.star) or 0
            local levelText
            if owned then
                levelText = tostring(level) .. "级"
            else
                levelText = cfg.shard_progress or "0/10"
            end
            local maxLevel = tonumber(cfg.max_level) or 0
            table.insert(result, {
                id             = cfg.id,
                name           = cfg.name,
                title          = cfg.title or "",
                faction        = cfg.faction,
                factionName    = self:GetFactionName(cfg.faction),
                role           = cfg.role,
                roleName       = self:GetRoleName(cfg.role),
                rarity         = tonumber(cfg.rarity) or 1,
                rarityColor    = self:GetRarityColor(cfg.rarity),
                factionColor   = self:GetFactionColor(cfg.faction),
                owned          = owned,
                isDeployed     = (cfg.id == deployedId),
                level          = level,
                levelText      = levelText,
                starText       = StarText(star),
                star           = star,
                card           = cfg.card,
                avatar         = cfg.avatar,
                shardProgress  = cfg.shard_progress or "0/10",
                factionIcon    = self:GetFactionIcon(cfg.faction),
                roleIcon       = self:GetRoleIcon(cfg.role),
                starNum        = star,
                needRepair     = (not owned) and NEED_REPAIR[cfg.id] == true,
                maxLevel       = maxLevel,
            })
        end
    end

    table.sort(result, function(a, b)
        if a.owned ~= b.owned then
            return a.owned
        end
        if a.owned and b.owned and a.level ~= b.level then
            return a.level > b.level
        end
        return a.id < b.id
    end)

    return result
end

function UIHeroListCtrl:OpenHeroDetail(heroId)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroDetail, { anim = true }, heroId)
end

return UIHeroListCtrl
