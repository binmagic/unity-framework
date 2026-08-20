--[[
-- 特殊元素：火箭(rocket)
-- 显示：Face 换成 rocket.png
-- 消除表现：火箭牌两两相连消除后，从该火箭元素中心发射 ROCKET_COUNT 枚火箭，
--          每枚飞向一个随机目标格，抵达后爆炸并消除该目标格。
--          → ROCKET_COUNT 同时 = 火箭枚数 = 消除的目标格数（一枚炸一个）。
--
-- 分层：Rocket 只定规则（发几枚/选哪些目标/特效参数）；
--       Manager 提供中性盘面操作（pickRandomCells / clearCells）；
--       View 消费 LianLian_RocketFx 播飞行+爆炸，并在每枚抵达时调 Manager 清该格。
--]]

local LianLianSpecial = require "Game.LianLian.Special.LianLianSpecialRegistry"

local ROCKET_SPRITE = "Assets/_Art_LianLian/ItemSprites/item_special/rocket.png"

-- ===== 火箭规则 & 表现参数（集中在此，方便调） =====
local ROCKET_COUNT = 4      -- 发射火箭枚数 = 消除的目标格数（一枚炸一个）
-- 表现参数（透传给 View 的特效）
local FX = {
    rocketSprite = ROCKET_SPRITE,  -- 火箭图
    rocketSize   = 80,             -- 火箭图尺寸(未缩放基准)
    flyDuration  = 0.35,           -- 单枚飞行时长
    flyEase      = "InQuad",       -- 飞行缓动(Ease 名)
    explodeScale = 1.6,            -- 爆炸放大倍数
    explodeDur   = 0.12,           -- 爆炸放大时长
    explodeHold  = 0.14,           -- 爆炸后停留(销毁延迟)
}

LianLianSpecial.register({
    type = "rocket",
    id = 1001,          -- 火箭专属 id（>=SPECIAL_ID_BASE，避免与普通图案 1..27 冲突）
    name = "火箭",
    icon = ROCKET_SPRITE,

    -- 显示：把 Face 换成火箭图
    onShow = function(tile, cell)
        if tile.SetFaceSprite then
            tile:SetFaceSprite(ROCKET_SPRITE)
        end
    end,

    -- 配对：仍按图案 id（此处特殊 id=1001）配对，两个火箭才能互消，不覆盖 canMatch

    -- 被消除时触发：从本火箭格(pos)中心发 ROCKET_COUNT 枚火箭，各炸一个随机目标格
    onCleared = function(mgr, layer, pos, ctx)
        -- 目标：随机挑 ROCKET_COUNT 个普通元素格（排除火箭自身格）
        local exclude = {}
        if pos then exclude[pos.r .. "_" .. pos.c] = true end
        local targets = mgr:pickRandomCells(layer, ROCKET_COUNT, exclude)
        if #targets == 0 then return end

        -- 发射源 = 本火箭格；请 View 播飞行+爆炸，并在每枚抵达时清对应目标格
        EventManager:GetInstance():Broadcast("LianLian_RocketFx", {
            layer = layer,
            origin = { r = pos.r, c = pos.c },   -- 发射起点格（火箭元素中心）
            targets = targets,                    -- 目标格列表（每枚炸一个）
            fx = FX,                              -- 表现参数
        })
    end,
})

return true
