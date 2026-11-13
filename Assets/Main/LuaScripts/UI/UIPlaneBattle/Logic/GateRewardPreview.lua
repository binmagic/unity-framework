-- Reward descriptions use the same live state as battle resolution; no save writes.
local Preview = {}
local T = require("Game.STG.Trigger.StgTriggerEnum").Type
local weapons = { [0] = "单发", [1] = "双发", [2] = "散射" }

function Preview.Build(meta, state)
    state = state or {}
    local p, t = meta and meta.para or 0, meta and meta.type
    local r = { available = true, button = "领 取", icon = "HeroUI_stat_troop.png" }
    local function unavailable(reason)
        r.available, r.button = false, reason
    end
    if t == T.UpgradeWeapon then
        local before = state.weaponLevel or 0
        local after = math.min(2, before + math.floor(p))
        r.title, r.value, r.icon = "武器升级", "Lv." .. (before + 1) .. " → " .. (after + 1), "HeroUI_skill_cannon.png"
        r.detail = after == 1 and "双发主炮 · 追踪导弹\n仅在本局有效" or "散射主炮 · 脉冲激光\n仅在本局有效"
        r.receipt = weapons[before] .. " → " .. weapons[after]
        if after <= before then unavailable("已满级"); r.detail = "当前已是最高三级\n请选择其他补给" end
    elseif t == T.SetRouteChoice then
        local labels = { mass = "编队翻倍路线", pierce = "穿透路线", homing = "追踪路线" }
        r.title, r.value, r.icon = "路线构筑", labels[p] or tostring(p), "HeroUI_stat_troop.png"
        r.detail = p == "mass" and "僚机数量翻倍\n后续出现密集集群" or (p == "pierce" and "切换穿透弹\n后续出现重装纵列敌群" or "切换追踪弹\n后续出现高速机动敌群")
        r.receipt = "路线锁定：" .. (labels[p] or tostring(p))
        if state.routeChoice == p then unavailable("已锁定") end
    elseif t == T.SetWeaponMode then
        r.title, r.value, r.icon = "武器流派", meta.text, "HeroUI_skill_cannon.png"
        r.detail = p == "pierce" and "直线穿过最多3个目标\n适合纵列与密集敌群" or "弹道追踪前方敌机\n适合侧翼与机动目标"
        r.receipt = "主炮与僚机切换为" .. meta.text
        if state.weaponMode == p then unavailable("已装备") end
    elseif t == T.RepairHull then
        local hp, total, restored, affected = 0, 0, 0, 0
        for _, member in ipairs(state.members or {}) do
            if not member.dead then
                hp, total = hp + member.hp, total + member.maxHp
                local n = math.min(member.maxHp - member.hp, math.max(0, math.floor(p)))
                restored = restored + n
                if n > 0 then affected = affected + 1 end
            end
        end
        r.title, r.value, r.icon = "全队装甲修复", hp .. " → " .. (hp + restored), "HeroUI_stat_armor.png"
        r.detail = string.format("%d 架恢复，共 +%d 装甲\n存活战机总装甲 / %d\n不复活阵亡战机", affected, restored, total)
        r.receipt = string.format("%d 架恢复 · 总装甲 %d → %d", affected, hp, hp + restored)
        if restored == 0 then unavailable("无需修复"); r.detail = "存活战机装甲完好\n不能复活阵亡战机" end
    elseif t == T.TimedHaste or t == T.FreezeEnemy then
        local haste = t == T.TimedHaste
        local before = haste and (state.hasteRemaining or 0) or (state.freezeRemaining or 0)
        local after = math.max(before, p)
        r.title, r.value = haste and "极速火力" or "时间禁锢", haste and "射速 +60%" or "冻结 " .. p .. " 秒"
        r.icon = haste and "HeroUI_skill_burst.png" or "HeroUI_skill_shield.png"
        r.detail = string.format("剩余 %.1f → %.1f 秒\n", before, after)
            .. (haste and "全队主炮与僚机速射\n与英雄速射取较高值" or "敌机停止移动与开火\n已发射敌弹继续飞行")
        r.receipt = string.format("%s · 剩余 %.1f → %.1f 秒", haste and "射速 +60%" or "敌机冻结", before, after)
        if after <= before then unavailable("无需刷新") end
    elseif t == T.AddWingman or t == T.MultiplyWingman or t == T.RemoveWingman then
        local before = state.wingmanCount or 0
        local after = t == T.MultiplyWingman and math.floor(before * p)
            or math.max(0, before + (t == T.RemoveWingman and -p or p))
        r.title = t == T.RemoveWingman and "编队减员" or "僚机增援"
        r.value = before .. " → " .. after
        r.detail = "增援僚机数量\n英雄战机不受影响"
        if after > 12 then r.detail = "超出12架折算火力\n火力最多按24架计算" end
        r.receipt = "增援僚机 " .. before .. " → " .. after
        if after == before then unavailable("数量不变") end
    elseif t == T.AddGold then
        r.title, r.value, r.detail = "金币补给", "+" .. p, "获得金币\n计入探险金币余额"
        r.icon, r.receipt = "HeroUI_stat_hp.png", "金币 +" .. p
        if p <= 0 then unavailable("无收益") end
    else
        r.title, r.value, r.detail = "补给不可用", "—", "未配置的奖励类型"
        unavailable("不可领取")
    end
    return r
end

return Preview
