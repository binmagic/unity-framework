--[[
-- 消除后果：稀有度掉落(rare_drop) — C 类
-- 机制：每消除 DROP_EVERY 对，全盘随机把 DROP_COUNT 个普通格刷成道具（当前掉火箭）。
-- 成对掉落（DROP_COUNT=2）保证盘面仍可配对/可解，避免落单道具卡死。
--
-- 这是「消除后果框架」的第一个后果，加新后果（连击充能/潮汐补行…）仿此新建一个文件。
--]]

local LianLianConsequence = require "Game.LianLian.Special.LianLianConsequenceRegistry"

-- 配置（集中，方便调）
local DROP_EVERY = 5              -- 每消几对触发一次掉落
local DROP_COUNT = 2              -- 每次掉几个道具（成对=保证可配对）
local DROP_TABLE = { "rocket" }   -- 可掉的道具类型（后续可加权重/更多类型）

LianLianConsequence.register({
    type = "rare_drop",
    name = "稀有度掉落",

    every = DROP_EVERY,   -- 声明触发周期（供 Debug/文档展示）

    onAfterMatch = function(mgr, layer, ctx)
        if not (ctx and ctx.everyN and ctx.everyN(DROP_EVERY)) then return end
        local count = ctx.matchCount

        -- 随机选 DROP_COUNT 个普通格（排除已是特殊的格）
        local cells = mgr:pickCellsLoose(layer, DROP_COUNT, nil)
        if #cells == 0 then return end

        -- 随机挑一种道具类型，成组刷到选中的格
        local stype = DROP_TABLE[math.random(#DROP_TABLE)]
        for _, pos in ipairs(cells) do
            mgr:dropPropAt(layer, pos.r, pos.c, stype)
        end
        print(string.format("[LianLian][掉落] 第%d对触发：刷%d个%s道具", count, #cells, stype))
    end,
})

return true
