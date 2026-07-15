--[[
-- 连连看盘面生成门面（Generator）
-- 统一生成入口 + 策略注册表 + 策略选择。
-- 新增一种生成算法 = 加一个 Strategies/XxxStrategy.lua + 在 STRATEGIES 里加一行，
-- View / Manager / Ctrl 全程不动。
--]]

local FixedLayoutStrategy = require "Game.LianLian.Model.Board.Strategies.FixedLayoutStrategy"
local RandomFillStrategy = require "Game.LianLian.Model.Board.Strategies.RandomFillStrategy"

local LianLianBoardGenerator = {}

-- 策略注册表（按 name 索引）
local STRATEGIES = {
    [FixedLayoutStrategy.name] = FixedLayoutStrategy,
    [RandomFillStrategy.name] = RandomFillStrategy,
    -- [ReverseGenStrategy.name] = ReverseGenStrategy,  -- 逆向有解，后补
}

--- 难度参数集（扩展点桩）
--- 本期返回默认档（等价现状：8×14 居中、kindCount=KIND_MAX）。
--- 后续接难度曲线时，改为查 LEVEL_CURVE 表。
--- @param level number 当前层级
--- @return table 难度参数集
function LianLianBoardGenerator.getDifficulty(level)
    -- 空表即代表"全部走默认值"，由 computeActiveRegion/buildIdPool 兜底。
    return {}
end

--- 选择生成策略
--- @param ctx table 生成上下文
--- @return table 策略模块
function LianLianBoardGenerator._select(ctx)
    if ctx.part == 1 then
        return STRATEGIES[FixedLayoutStrategy.name]
    end
    return STRATEGIES[RandomFillStrategy.name]
end

--- 生成盘面
--- @param part number 当前关卡
--- @param level number 当前层级
--- @return table LianLianBoardResult
function LianLianBoardGenerator.generate(part, level)
    local ctx = {
        part = part,
        level = level or 0,
        difficulty = LianLianBoardGenerator.getDifficulty(level or 0),
        rng = math.random,
    }
    local strategy = LianLianBoardGenerator._select(ctx)
    assert(strategy, "LianLianBoardGenerator: 未找到可用策略")
    return strategy.generate(ctx)
end

return LianLianBoardGenerator
