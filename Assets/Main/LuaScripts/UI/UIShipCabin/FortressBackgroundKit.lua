---
--- 移动堡垒可拼装背景 V1
---
--- 背景结构的唯一配置入口。层顺序即渲染顺序；每层独立声明素材、尺寸、
--- 平铺份数、色调和相对车速。View 只负责按表创建节点，视差模块只消费 ratio。
---
local FortressBackgroundKit = {}

FortressBackgroundKit.CANVAS_WIDTH = 1672
FortressBackgroundKit.CANVAS_HEIGHT = 941
FortressBackgroundKit.HORIZON_RATIO = 192 / 941
FortressBackgroundKit.DEFAULT_THEME = "day"

local ROOT = "Assets/Main/Sprites/UIShipFortress/"
local DERIVED = ROOT .. "background_v1/"
local SKY_V2 = ROOT .. "sky_v2/"
local LIGHTING = ROOT .. "lighting_v1/"
local VARIANTS = { "a", "b" }

local function VariantPaths(prefix)
    local paths = {}
    for _, suffix in ipairs(VARIANTS) do
        table.insert(paths, DERIVED .. prefix .. "_" .. suffix .. ".png")
    end
    return paths
end

local function SkyVariantPaths(prefix)
    return { SKY_V2 .. prefix .. "_a.png", SKY_V2 .. prefix .. "_b.png" }
end

FortressBackgroundKit.LAYERS = {
    {
        id = "sky",
        role = "sky",
        sprite = SKY_V2 .. "sky_gradient.png",
        nativeW = 1672, nativeH = 941, tiles = 1, speedRatio = 0,
        tint = { 0.78, 0.88, 1.00, 1 },
    },
    {
        id = "cloudFar",
        role = "sky_cloud_far",
        sprites = SkyVariantPaths("cloud_far"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 0.055,
        tint = { 0.80, 0.87, 0.96, 0.34 },
    },
    {
        id = "cloudMid",
        role = "sky_cloud_mid",
        sprites = SkyVariantPaths("cloud_mid"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 0.13,
        tint = { 0.92, 0.84, 0.74, 0.46 },
    },
    {
        id = "far",
        role = "far",
        sprites = VariantPaths("bg_far"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 0.24,
        tint = { 0.40, 0.44, 0.51, 1 },
    },
    {
        id = "haze",
        role = "horizon_haze",
        sprites = SkyVariantPaths("horizon_haze"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 0.08,
        tint = { 1.00, 0.88, 0.72, 0.48 },
    },
    {
        id = "midground",
        role = "midground",
        sprites = VariantPaths("bg_midground"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 0.58,
        tint = { 0.47, 0.49, 0.54, 1 },
    },
    {
        id = "ground",
        role = "ground",
        sprites = VariantPaths("bg_ground_contact"),
        nativeW = 1672, nativeH = 941, tiles = 2, speedRatio = 1.0,
        tint = { 0.52, 0.53, 0.56, 1 },
    },
    {
        id = "foreground",
        role = "foreground",
        sprites = VariantPaths("bg_foreground"),
        nativeW = 1480, nativeH = 941, tiles = 2, speedRatio = 1.75,
        tint = { 0.62, 0.63, 0.67, 1 },
    },
}

--- 主题只覆盖视觉参数，不改变层几何、平铺周期或速度约束。
--- 这样换主题不会影响车身水平、履带零打滑或 ScrollRect 范围。
FortressBackgroundKit.THEMES = {
    day = {
        label = "昼间废土",
        variantSeed = 20261028,
        tint = {
            sky = { 0.78, 0.88, 1.00, 1 },
            cloudFar = { 0.80, 0.87, 0.96, 0.34 },
            cloudMid = { 0.92, 0.84, 0.74, 0.46 },
            far = { 0.40, 0.44, 0.51, 1 },
            haze = { 1.00, 0.88, 0.72, 0.48 },
            midground = { 0.47, 0.49, 0.54, 1 },
            ground = { 0.52, 0.53, 0.56, 1 },
            foreground = { 0.62, 0.63, 0.67, 1 },
        },
        vehicleTint = { 1, 1, 1, 1 },
        wheelTint = { 1, 1, 1, 1 },
        warmLightAlpha = 0.10,
        beaconAlpha = 0.10,
        shadowTint = { 0.46, 0.37, 0.28, 0.58 },
        dustTint = { 1.00, 0.94, 0.82, 0.78 },
    },
    dusk = {
        label = "黄昏废土",
        variantSeed = 20261029,
        tint = {
            sky = { 0.70, 0.46, 0.49, 1 },
            cloudFar = { 0.56, 0.36, 0.44, 0.30 },
            cloudMid = { 0.82, 0.48, 0.34, 0.42 },
            far = { 0.53, 0.34, 0.30, 1 },
            haze = { 1.00, 0.56, 0.30, 0.52 },
            midground = { 0.60, 0.40, 0.31, 1 },
            ground = { 0.64, 0.45, 0.34, 1 },
            foreground = { 0.72, 0.47, 0.35, 1 },
        },
        vehicleTint = { 1.00, 0.90, 0.78, 1 },
        wheelTint = { 0.92, 0.78, 0.65, 1 },
        warmLightAlpha = 0.42,
        beaconAlpha = 0.34,
        shadowTint = { 0.43, 0.20, 0.16, 0.70 },
        dustTint = { 0.92, 0.66, 0.45, 0.62 },
    },
    night = {
        label = "夜间废土",
        variantSeed = 20261030,
        tint = {
            sky = { 0.24, 0.34, 0.60, 1 },
            cloudFar = { 0.30, 0.38, 0.58, 0.20 },
            cloudMid = { 0.40, 0.43, 0.58, 0.28 },
            far = { 0.22, 0.27, 0.38, 1 },
            haze = { 0.38, 0.42, 0.58, 0.22 },
            midground = { 0.29, 0.31, 0.38, 1 },
            ground = { 0.34, 0.34, 0.39, 1 },
            foreground = { 0.44, 0.40, 0.43, 1 },
        },
        vehicleTint = { 0.62, 0.70, 0.82, 1 },
        wheelTint = { 0.56, 0.61, 0.70, 1 },
        warmLightAlpha = 0.86,
        beaconAlpha = 0.74,
        shadowTint = { 0.08, 0.11, 0.18, 0.80 },
        dustTint = { 0.42, 0.48, 0.58, 0.34 },
    },
}

FortressBackgroundKit.LIGHTING = {
    warmSprite = LIGHTING .. "warm_glow.png",
    beaconSprite = LIGHTING .. "red_beacon.png",
    --- 坐标使用 1872×941 的堡垒画布。灯是独立挂件，不写进车身 PNG。
    points = {
        { id = "bridge", kind = "warm", x = 366,  y = 386, w = 210, h = 110 },
        { id = "hangar", kind = "warm", x = 838,  y = 500, w = 360, h = 150 },
        { id = "rooms",  kind = "warm", x = 1410, y = 472, w = 520, h = 250 },
        { id = "mast",   kind = "beacon", x = 313, y = 65, w = 50, h = 50 },
        { id = "gantry", kind = "beacon", x = 1255, y = 159, w = 42, h = 42 },
    },
}

function FortressBackgroundKit.GetTheme(name)
    return FortressBackgroundKit.THEMES[name or FortressBackgroundKit.DEFAULT_THEME]
end

function FortressBackgroundKit.GetLayers(themeName)
    local theme = FortressBackgroundKit.GetTheme(themeName) or FortressBackgroundKit.GetTheme()
    local layers = {}
    for _, source in ipairs(FortressBackgroundKit.LAYERS) do
        local layer = {}
        for key, value in pairs(source) do layer[key] = value end
        local tint = theme.tint[layer.id]
        if tint ~= nil then layer.tint = tint end
        table.insert(layers, layer)
    end
    return layers
end

--- 稳定种子只改变同一层内的排列，不在运行中随机跳图。
--- 每层使用不同偏移，避免所有层恰好同时显示同一字母变体。
function FortressBackgroundKit.GetTileSprites(layer, seed)
    if layer.sprites == nil or #layer.sprites == 0 then
        local result = {}
        for tile = 1, layer.tiles do result[tile] = layer.sprite end
        return result
    end

    local count = #layer.sprites
    local start = ((seed or 0) + (#layer.id * 7)) % count
    local result = {}
    for tile = 1, layer.tiles do
        local index = ((start + tile - 1) % count) + 1
        table.insert(result, layer.sprites[index])
    end
    -- 末尾重复第一张，作为整组回绕时的可见缓冲；循环周期不包含这张缓冲图。
    table.insert(result, result[1])
    return result
end

return FortressBackgroundKit
