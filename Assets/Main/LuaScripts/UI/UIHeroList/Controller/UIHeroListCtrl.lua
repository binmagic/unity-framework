---
--- 英雄图鉴列表 — Controller
--- 职责：组装卡片数据（阵营筛选 + 稀有度/定位展示信息 + 出战角标）
---@class UIHeroListCtrl : UIBaseCtrl
local UIHeroListCtrl = BaseClass("UIHeroListCtrl", UIBaseCtrl)

--- 阵营筛选页签定义：nil = 全部。UI 侧按这个顺序渲染四个 Tab 按钮
UIHeroListCtrl.FactionTabs = {
    { key = nil,            name = "全部" },
    { key = "Empire",       name = "帝国" },
    { key = "Federation",   name = "联邦" },
    { key = "FreeArmy",     name = "自由军" },
}

--- 阵营中文名（卡片/详情页展示用）
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

--- 稀有度 → 底色（无美术资源，用纯色块代替卡面，对应设计文档：绿/蓝/紫/橙金）
local RARITY_COLOR = {
    [1] = { 0.35, 0.72, 0.40, 1 }, -- 普通 绿
    [2] = { 0.30, 0.55, 0.90, 1 }, -- 稀有 蓝
    [3] = { 0.60, 0.35, 0.85, 1 }, -- 卓越/史诗 紫
    [4] = { 0.95, 0.70, 0.20, 1 }, -- 传说 橙金
}

--- 阵营 → 强调色（左上角圆点/详情页立绘区底色）
local FACTION_COLOR = {
    Empire     = { 0.75, 0.20, 0.20, 1 }, -- 帝国 红
    Federation = { 0.20, 0.45, 0.80, 1 }, -- 联邦 蓝
    FreeArmy   = { 0.55, 0.55, 0.55, 1 }, -- 自由军 灰
}

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

--- 星级 → 显示字符串，如 star=3 时返回 "***--"（对应截图卡片右下角的星级行）
--- 用 * 不用 ★：NotoSansSC-Bold SDF 源字体没有 ★/☆ 字形，TryAddCharacters 也加不进来，
--- 实测会被替换成方块 □（参考 [[dynamic-tmp-chinese-font-loading]] 同类坑）
local function StarText(star)
    star = star or 0
    local filled = math.min(math.max(star, 0), 5)
    return string.rep("*", filled) .. string.rep("-", 5 - filled)
end

--- 组装某个筛选页签下的卡片数据列表
--- @param faction string|nil nil = 全部
--- 返回 { { id, name, faction, factionName, role, roleName, rarity, rarityColor, factionColor,
---        isDeployed, level, levelText, starText }, ... }
function UIHeroListCtrl:GetCardList(faction)
    local mgr = DataCenter.HeroDataManager
    if mgr == nil then return {} end

    local deployedId = mgr:GetDeployedHeroId()
    local heroIds = mgr:GetHeroIdsByFaction(faction)
    local result = {}

    for _, heroId in ipairs(heroIds) do
        local cfg = mgr:GetHeroConfig(heroId)
        if cfg ~= nil then
            local level = mgr:GetHeroLevel(cfg.id)
            table.insert(result, {
                id           = cfg.id,
                name         = cfg.name,
                faction      = cfg.faction,
                factionName  = self:GetFactionName(cfg.faction),
                role         = cfg.role,
                roleName     = self:GetRoleName(cfg.role),
                rarity       = cfg.rarity,
                rarityColor  = self:GetRarityColor(cfg.rarity),
                factionColor = self:GetFactionColor(cfg.faction),
                isDeployed   = (cfg.id == deployedId),
                level        = level,
                levelText    = level .. "级",
                starText     = StarText(cfg.star),
            })
        end
    end

    return result
end

--- 点卡片打开详情
function UIHeroListCtrl:OpenHeroDetail(heroId)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIHeroDetail, { anim = true }, heroId)
end

return UIHeroListCtrl
