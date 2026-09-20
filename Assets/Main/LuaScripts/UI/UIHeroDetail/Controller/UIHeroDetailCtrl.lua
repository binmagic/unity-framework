---
--- 英雄详情 — Controller
--- 职责：读取单个英雄的展示数据 + 出战状态判定/切换
---@class UIHeroDetailCtrl : UIBaseCtrl
local UIHeroDetailCtrl = BaseClass("UIHeroDetailCtrl", UIBaseCtrl)

--- 稀有度中文名（对应设计文档：普通/稀有/卓越/传说）
local RARITY_NAME = {
    [1] = "普通",
    [2] = "稀有",
    [3] = "卓越",
    [4] = "传说",
}

--- 阵营中文名
local FACTION_NAME = {
    Empire     = "帝国",
    Federation = "联邦",
    FreeArmy   = "自由军",
}

--- 定位中文名
local ROLE_NAME = {
    Output  = "输出",
    Defense = "防守",
    Support = "辅助",
}

--- 稀有度 → 底色（与 UIHeroListCtrl 保持一致，立绘占位色块用）
local RARITY_COLOR = {
    [1] = { 0.35, 0.72, 0.40, 1 },
    [2] = { 0.30, 0.55, 0.90, 1 },
    [3] = { 0.60, 0.35, 0.85, 1 },
    [4] = { 0.95, 0.70, 0.20, 1 },
}

--- 组装详情展示数据；heroId 不存在返回 nil
--- 返回 { id, name, factionName, roleName, rarityName, rarityColor,
---        firepower, durability, armor, troop, isDeployed, level,
---        star, skillName, skillCooldown, skillTag, skillDesc }
function UIHeroDetailCtrl:GetDetailData(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return nil end

    local cfg = mgr:GetHeroConfig(heroId)
    if cfg == nil then return nil end

    return {
        id            = cfg.id,
        name          = cfg.name,
        factionName   = FACTION_NAME[cfg.faction] or "",
        roleName      = ROLE_NAME[cfg.role] or "",
        rarityName    = RARITY_NAME[cfg.rarity] or "",
        rarityColor   = RARITY_COLOR[cfg.rarity] or RARITY_COLOR[1],
        firepower     = cfg.base_firepower,
        durability    = cfg.base_durability,
        armor         = cfg.base_armor,
        troop         = cfg.base_troop,
        isDeployed    = (mgr:GetDeployedHeroId() == cfg.id),
        level         = mgr:GetHeroLevel(cfg.id),
        star          = cfg.star or 0,
        skillName     = cfg.skill_name or "",
        skillCooldown = cfg.skill_cooldown or 0,
        skillTag      = cfg.skill_tag or "",
        skillDesc     = cfg.skill_desc or "",
    }
end

--- 设为出战；返回 ok, errMsg
function UIHeroDetailCtrl:SetDeployed(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return false, "HeroDataManager 未初始化" end
    return mgr:SetDeployedHero(heroId)
end

--- 军衔星级加成列表（5档），仅展示、不接真实解锁流程：
--- 已达到的星级(index<=star)标记 unlocked=true，未达到的锁灰显示
--- 返回 { { starLevel=1..5, bonusText, unlocked }, ... }
function UIHeroDetailCtrl:GetSkillRankBonusList(heroId)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return {} end

    local cfg = mgr:GetHeroConfig(heroId)
    if cfg == nil or cfg.skill_rank_bonus == nil or cfg.skill_rank_bonus == "" then
        return {}
    end

    local star = cfg.star or 0
    local result = {}
    local index = 0
    for bonusText in string.gmatch(cfg.skill_rank_bonus, "([^|]+)") do
        index = index + 1
        table.insert(result, {
            starLevel = index,
            -- 去掉配置表文案里的"N★ "前缀：UI 侧左列已经单独显示星级了，
            -- 不去掉会出现"1★ | 1★ 伤害+5%"的重复
            bonusText = (string.gsub(bonusText, "^%s*%d+★%s*", "")),
            unlocked  = (index <= star),
        })
    end
    return result
end

return UIHeroDetailCtrl
