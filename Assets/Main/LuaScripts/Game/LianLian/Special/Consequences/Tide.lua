--[[
-- 消除后果：潮汐(tide) — C 类
-- 机制：每消 TIDE_EVERY 对，盘面整体下移 TIDE_ROWS 行，顶部补同样行数的成对新牌。
-- 无限模式续局用：不断补充新牌，制造新通路。
--
-- 用到框架能力：onAfterMatch + ctx.everyN 周期助手 + Manager 中性服务 tideShiftDown。
--]]

local LianLianConsequence = require "Game.LianLian.Special.LianLianConsequenceRegistry"

local TIDE_EVERY = 8   -- 每消几对触发一次潮汐
local TIDE_ROWS = 1    -- 每次下移/补充的行数

LianLianConsequence.register({
    type = "tide",
    name = "潮汐",
    every = TIDE_EVERY,

    onAfterMatch = function(mgr, layer, ctx)
        if not (ctx and ctx.everyN and ctx.everyN(TIDE_EVERY)) then return end
        mgr:tideShiftDown(layer, TIDE_ROWS)
        print(string.format("[LianLian][潮汐] 第%d对触发：下移%d行+补新牌", ctx.matchCount, TIDE_ROWS))
    end,
})

return true
