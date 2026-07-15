--[[
-- 固定摆位生成策略（教学关 / 主题造型关）
-- 从 LianLianLevel[part] 读取坐标表摆牌，从坐标 min/max 反推激活区。
-- 再加一张坐标表即可支持主题造型关，无需新代码路径。
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianLevel = require "Game.LianLian.Config.LianLianLevel"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"
local LianLianBase = require "Game.LianLian.Model.Board.LianLianGenStrategyBase"
local LianLianBoardResult = require "Game.LianLian.Model.Board.LianLianBoardResult"

local FixedLayoutStrategy = {}

FixedLayoutStrategy.name = "fixed"

--- 从坐标表反推激活区（origin + activeRows/activeCols）
local function computeRegionFromPositions(positions)
    local minR, maxR = math.huge, -math.huge
    local minC, maxC = math.huge, -math.huge
    for _, pos in ipairs(positions) do
        if pos.r < minR then minR = pos.r end
        if pos.r > maxR then maxR = pos.r end
        if pos.c < minC then minC = pos.c end
        if pos.c > maxC then maxC = pos.c end
    end
    return {
        activeRows = maxR - minR + 1,
        activeCols = maxC - minC + 1,
        originRow = minR,
        originCol = minC,
    }
end

--- 生成盘面
--- @param ctx table { part, level, difficulty, rng }
function FixedLayoutStrategy.generate(ctx)
    local part = ctx.part
    local rng = ctx.rng or math.random
    local positions = LianLianLevel[part]
    assert(positions and #positions > 0,
        "FixedLayoutStrategy: LianLianLevel[" .. tostring(part) .. "] 无坐标表")

    -- 建全量物理格子（保持 cell.n = r*WIDTH+c 编码不变）
    local grid = LianLianGrid.create()

    -- 成对 ID 池（教学关全部随机取 ID，等价旧 rndId 行为；缺省 kindCount=KIND_MAX）
    local kindCount = ctx.difficulty and ctx.difficulty.kindCount or nil
    local pairCount = math.floor(#positions / 2)
    local pairedIds = LianLianBase.buildIdPool(pairCount, kindCount, rng, true)

    -- 按坐标表摆牌
    for _, pos in ipairs(positions) do
        local key = pos.r .. "_" .. pos.c
        if grid[key] then
            grid[key].id = table.remove(pairedIds)
        end
    end

    -- 从坐标反推激活区
    local region = computeRegionFromPositions(positions)
    local layout = {
        gridRows = LianLianConst.GRID_HEIGHT,
        gridCols = LianLianConst.GRID_WIDTH,
        activeRows = region.activeRows,
        activeCols = region.activeCols,
        originRow = region.originRow,
        originCol = region.originCol,
    }

    local meta = {
        strategy = FixedLayoutStrategy.name,
        direction = LianLianLevel.direction[part] or "",
        enterList = LianLianLevel.enterList[part] or {},
    }

    return LianLianBoardResult.new(grid, layout, meta)
end

return FixedLayoutStrategy
