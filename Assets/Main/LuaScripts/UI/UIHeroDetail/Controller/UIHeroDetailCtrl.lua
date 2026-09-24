---
--- 英雄详情 — Controller
--- 组装详情页展示数据：称号/战力/技能格式/军衔预览/立绘路径/拥有态
---@class UIHeroDetailCtrl : UIBaseCtrl
local UIHeroDetailCtrl = BaseClass("UIHeroDetailCtrl", UIBaseCtrl)

local RARITY_NAME = {
    [1] = "普通",
    [2] = "稀有",
    [3] = "卓越",
    [4] = "传说",
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
    [1] = { 0.35, 0.72, 0.40, 1 },
    [2] = { 0.30, 0.55, 0.90, 1 },
    [3] = { 0.45, 0.55, 0.95, 1 },
    [4] = { 0.95, 0.70, 0.20, 1 },
}

local FACTION_COLOR = {
    Empire     = { 0.75, 0.20, 0.20, 1 },
    Federation = { 0.20, 0.45, 0.80, 1 },
    FreeArmy   = { 0.55, 0.55, 0.55, 1 },
}

function UIHeroDetailCtrl:GetDetailData(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return nil end

    local cfg = mgr:GetHeroConfig(heroId)
    if cfg == nil then return nil end

    local owned = mgr:IsHeroOwned(heroId)
    local rarity = tonumber(cfg.rarity) or 1
    local star = tonumber(cfg.star) or 0
    local level = mgr:GetHeroLevel(heroId)
    local maxLevel = tonumber(cfg.max_level) or level
    local power = tonumber(cfg.power) or 0
    local skillLevel = tonumber(cfg.skill_level) or 1
    local skillMax = tonumber(cfg.skill_max_level) or 1
    local cooldown = tonumber(cfg.skill_cooldown) or 0
    local title = cfg.title
    if title == nil or title == "" then
        title = (FACTION_NAME[cfg.faction] or "") .. " · " .. (ROLE_NAME[cfg.role] or "")
    end

    -- 未拥有走满级预览：等级显示 max_level（截图传说位 150级）
    local showLevel = owned and level or maxLevel
    if not owned and showLevel <= 0 then
        showLevel = maxLevel
    end

    return {
        id              = cfg.id,
        name            = cfg.name,
        title           = title,
        factionName     = FACTION_NAME[cfg.faction] or "",
        roleName        = ROLE_NAME[cfg.role] or "",
        rarity          = rarity,
        rarityName      = RARITY_NAME[rarity] or "",
        rarityColor     = RARITY_COLOR[rarity] or RARITY_COLOR[1],
        factionColor    = FACTION_COLOR[cfg.faction] or { 0.5, 0.5, 0.5, 1 },
        firepower       = tonumber(cfg.base_firepower) or 0,
        durability      = tonumber(cfg.base_durability) or 0,
        armor           = tonumber(cfg.base_armor) or 0,
        troop           = tonumber(cfg.base_troop) or 0,
        owned           = owned,
        isDeployed      = (mgr:GetDeployedHeroId() == cfg.id),
        level           = level,
        levelText       = tostring(showLevel) .. "级",
        power           = power,
        powerText       = self:_FormatNumber(power),
        star            = mgr:GetHeroStar(heroId) or star,
        skillName       = cfg.skill_name or "",
        skillCooldown   = cooldown,
        cooldownText    = string.format("冷却: %.2f秒", cooldown),
        skillTag        = cfg.skill_tag or "",
        skillDmgType    = cfg.skill_dmg_type or "",
        skillDesc       = cfg.skill_desc or "",
        skillLevel      = skillLevel,
        skillMaxLevel   = skillMax,
        skillLevelText  = skillLevel .. "/" .. skillMax .. "级",
        portrait        = cfg.portrait,
        card            = cfg.card,
        avatar          = cfg.avatar,
        rankDurability  = tonumber(cfg.rank_durability) or 0,
        rankFirepower   = tonumber(cfg.rank_firepower) or 0,
        rankArmor       = tonumber(cfg.rank_armor) or 0,
        rankBonusText   = self:_FormatNumber(tonumber(cfg.rank_durability) or 0),
        upgradeCost     = cfg.upgrade_cost or "",
        promoteCost1    = cfg.promote_cost_1 or "",
        promoteCost2    = cfg.promote_cost_2 or "",
        shardProgress   = cfg.shard_progress or "0/10",
        maxLevel        = maxLevel,
        isLegendPreview = (not owned) and rarity >= 4,
        previewHint     = (not owned) and "英雄满级属性预览" or nil,
    }
end

function UIHeroDetailCtrl:_FormatNumber(n)
    n = math.floor(tonumber(n) or 0)
    local sign = n < 0 and "-" or ""
    local s = tostring(math.abs(n))
    local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return sign .. formatted
end

function UIHeroDetailCtrl:SetDeployed(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return false, "HeroDataManager 未初始化" end
    return mgr:SetDeployedHero(heroId)
end

function UIHeroDetailCtrl:TryUpgrade(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return false, "HeroDataManager 未初始化" end
    return mgr:TryUpgradeHero(heroId)
end

function UIHeroDetailCtrl:TryPromote(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return false, "HeroDataManager 未初始化" end
    return mgr:TryPromoteHero(heroId)
end

--- 技能页5行军衔加成
function UIHeroDetailCtrl:GetSkillRankBonusList(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return {} end

    local cfg = mgr:GetHeroConfig(heroId)
    if cfg == nil or cfg.skill_rank_bonus == nil or cfg.skill_rank_bonus == "" then
        return {}
    end

    local star = tonumber(cfg.star) or 0
    local owned = mgr:IsHeroOwned(heroId)
    local result = {}
    local index = 0
    for bonusText in string.gmatch(cfg.skill_rank_bonus, "([^|]+)") do
        index = index + 1
        local clean = string.gsub(bonusText, "^%s*%d+[★*]%-*%s*", "")
        clean = string.gsub(clean, "^%s*%d+[★*]%s*", "")
        table.insert(result, {
            starLevel = index,
            bonusText = clean,
            -- 未拥有：截图展示满级预览时文案保持可读，不强行锁灰
            unlocked  = (not owned) or (index <= star),
        })
    end
    return result
end

--- 技能槽数量：传说/高稀有截图可能4槽，默认3槽
function UIHeroDetailCtrl:GetSkillSlotCount(heroId)
    local data = self:GetDetailData(heroId)
    if data == nil then return 3 end
    if (data.rarity or 0) >= 4 then return 4 end
    return 3
end

return UIHeroDetailCtrl
