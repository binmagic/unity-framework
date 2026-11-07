--- 将全局英雄配置转译成战机玩法的可读被动；不写入 Hero_Config，也不修改全局出战存档。
local BattleHeroProfile = {}
local HeroAircraftCatalog = require "DataCenter.Hero.HeroAircraftCatalog"

local ROLE_PROFILE = {
    Output = { name = "突击驾驶员", passive = "开局武器升级为双发", weaponLevel = 1, hullMax = 3, wingmanBonus = 0 },
    Defense = { name = "护航驾驶员", passive = "自身装甲上限 +1", weaponLevel = 0, hullMax = 4, wingmanBonus = 0 },
    Support = { name = "编队指挥官", passive = "开局额外增援 +2", weaponLevel = 0, hullMax = 3, wingmanBonus = 2 },
}

local ACTIVE_SKILLS = {
    [1001]={kind="double",cooldown=10,description="双发拦截：向前方目标发射2枚重弹，每枚30伤害"},
    [1002]={kind="blast",cooldown=12,description="定点打击：锁定目标位置，0.55秒后对130范围造成65伤害"},
    [1004]={kind="haste",cooldown=15,description="战术指挥：全队射速提高60%，持续5秒"},
}

function BattleHeroProfile.FromConfig(cfg)
    if cfg == nil then
        return { name = "未配置", title = "", avatar = "", role = "", profileName = "无驾驶员",
            passive = "未获得英雄加成", weaponLevel = 0, hullMax = 3, wingmanBonus = 0, troopBonus = 0 }
    end
    local base = ROLE_PROFILE[cfg.role] or ROLE_PROFILE.Support
    -- 手动技能使用独立冷却；原表的1秒技能为普攻技。
    local active=ACTIVE_SKILLS[tonumber(cfg.id)] or {
        kind=cfg.role=="Defense" and "shield" or (cfg.role=="Support" and "haste" or "double"),
        cooldown=math.max(8,tonumber(cfg.skill_cooldown) or 12),
        description=cfg.role=="Defense" and "全队获得2层临时护盾，持续4秒"
            or (cfg.role=="Support" and "全队射速提高60%，持续5秒" or "向前方目标发射2枚重弹，每枚30伤害") }
    return {
        id = cfg.id, name = cfg.name or "驾驶员", title = cfg.title or "", avatar = cfg.avatar or "",
        role = cfg.role or "", profileName = base.name, passive = base.passive,
        aircraft = HeroAircraftCatalog.Get(cfg.id),
        weaponLevel = base.weaponLevel, hullMax = base.hullMax, wingmanBonus = base.wingmanBonus,
        -- 原英雄表数值用于其他主玩法；战机中压到 24 的逻辑上限内。
        troopBonus = math.max(0, tonumber(cfg.base_troop) or 0),
        skillName = cfg.skill_name or "", skillCooldown = tonumber(cfg.skill_cooldown) or 0,
        activeKind=active.kind,activeCooldown=active.cooldown,activeDescription=active.description,
    }
end

--- 全队职业规则：突击提供双发，护航有更高独立装甲，指挥增加普通僚机。
function BattleHeroProfile.BuildFormation(slots, heroManager, playerRules)
    playerRules = playerRules or {}
    local armorMultiplier = math.max(0.01, tonumber(playerRules.heroArmorMultiplier) or 1)
    local cooldownMultiplier = math.max(0.01, tonumber(playerRules.heroSkillCooldownMultiplier) or 1)
    local team = { members = {}, weaponLevel = 0, hullMax = 3, wingmanBonus = 0 }
    for slot = 1, 5 do
        local id = slots[slot]
        if id ~= nil and id ~= 0 and heroManager:IsHeroOwned(id) then
            local hero = BattleHeroProfile.FromConfig(heroManager:GetHeroConfig(id))
            hero.hullMax = math.max(1, math.floor((hero.hullMax or 3) * armorMultiplier + 0.5))
            hero.activeCooldown = math.max(0.1, (hero.activeCooldown or 10) * cooldownMultiplier)
            hero.slot = slot
            hero.level = heroManager:GetHeroLevel(id)
            table.insert(team.members, hero)
            if slot == 1 then team.leader = hero end
            team.weaponLevel = math.max(team.weaponLevel, hero.weaponLevel)
            team.wingmanBonus = team.wingmanBonus + hero.wingmanBonus
        end
    end
    team.leader = team.leader or BattleHeroProfile.FromConfig(nil)
    team.hullMax=team.leader.hullMax or 3
    return team
end

return BattleHeroProfile
