--- 英雄与专属战机的统一外观配置。详情、编队和实战均按英雄 ID 取值，机位不决定机型。
local HeroAircraftCatalog = {}
local AIRCRAFT = {
    [1001] = "苍穹拦截者", [1002] = "蔷薇突击机", [1003] = "赤焰先锋",
    [1004] = "曙光指挥机", [1005] = "铁壁护卫", [1006] = "绯红猎隼",
    [1007] = "极光之翼", [1008] = "翡翠守望", [1009] = "紫鸢信使",
    [1010] = "落日游侠", [1011] = "碧空领航", [1012] = "樱色闪电",
    [1013] = "金羽突袭", [1014] = "寒霜堡垒", [1015] = "月影支援",
    [1016] = "银翼战机", [1017] = "星辉侦察", [1018] = "黑曜重卫",
}

function HeroAircraftCatalog.Get(heroId)
    local id = tonumber(heroId)
    if AIRCRAFT[id] == nil then id = 1001 end
    return {
        name = AIRCRAFT[id],
        sprite = "Assets/Main/Sprites/STG/HeroAircraft/hero_" .. id .. ".png",
    }
end

return HeroAircraftCatalog
