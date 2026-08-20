--[[
-- 随机填充生成策略（正式关 Part 2+）
-- 迁移自 LianLianPlay.getGrid 的 else 分支 + setLockGroup + initData 的锁定组逻辑。
-- 默认参数（difficulty 未配档时）逐格等价旧行为：8×14 居中、kindCount=27。
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.DataCenter.LianLianGrid"
local LianLianItem = require "Game.LianLian.DataCenter.LianLianItem"
local LianLianBase = require "Game.LianLian.DataCenter.Board.LianLianGenStrategyBase"
local LianLianBoardResult = require "Game.LianLian.DataCenter.Board.LianLianBoardResult"

local RandomFillStrategy = {}

RandomFillStrategy.name = "random"

--- 设置一个锁定组（2×2 方块，只能通过洗牌消除）
--- 迁移自 LianLianPlay.setLockGroup
local function setLockGroup(grid, rng, region)
    rng = rng or math.random
    -- 在激活区内随机取一个 2×2 左上角
    local r = region.originRow + rng(region.activeRows - 1) - 1
    local c = region.originCol + rng(region.activeCols - 1) - 1

    local a = grid[r .. "_" .. c]
    local b = grid[r .. "_" .. (c + 1)]
    local d = grid[(r + 1) .. "_" .. c]
    local e = grid[(r + 1) .. "_" .. (c + 1)]
    if not (a and b and d and e) then return end

    -- 确保对角相同，邻角不同
    if a.id == b.id then
        for _, cell in pairs(grid) do
            if cell.id ~= 0 and cell.id ~= a.id then
                b.id, cell.id = cell.id, b.id
                break
            end
        end
    end

    -- 找到与 a 相同的另一张牌放到 e（对角）
    for _, cell in pairs(grid) do
        if cell.id == a.id and not LianLianItem.isSamePos(a, cell) and not LianLianItem.isSamePos(e, cell) then
            e.id, cell.id = cell.id, e.id
            break
        end
    end

    -- 找到与 b 相同的另一张牌放到 d（对角）
    for _, cell in pairs(grid) do
        if cell.id == b.id and not LianLianItem.isSamePos(b, cell) and not LianLianItem.isSamePos(d, cell) then
            d.id, cell.id = cell.id, d.id
            break
        end
    end

    -- 将剩余的 a.id / b.id 牌替换为新的随机 ID（避免其他位置也有相同牌）
    local newId = LianLianItem.rndId(a.id, b.id)
    for _, cell in pairs(grid) do
        if cell.id == a.id and not LianLianItem.isSamePos(a, cell) and not LianLianItem.isSamePos(e, cell) then
            cell.id = newId
        end
        if cell.id == b.id and not LianLianItem.isSamePos(b, cell) and not LianLianItem.isSamePos(d, cell) then
            cell.id = newId
        end
    end
end

--- 生成盘面
--- @param ctx table { part, level, difficulty, rng }
function RandomFillStrategy.generate(ctx)
    local part = ctx.part
    local level = ctx.level or 0
    local rng = ctx.rng or math.random
    local difficulty = ctx.difficulty or {}

    -- 建全量物理格子（保持 cell.n = r*WIDTH+c 编码不变）
    local grid = LianLianGrid.create()

    -- 激活区（默认居中 8×14，等价旧行为）
    local region = LianLianBase.computeActiveRegion(difficulty)

    -- 成对 ID 池
    local pairCount = math.floor(region.activeRows * region.activeCols / 2)
    local kindCount = difficulty.kindCount
    local pairedIds = LianLianBase.buildIdPool(pairCount, kindCount, rng)

    -- 填充激活区
    for r = region.originRow, region.originRow + region.activeRows - 1 do
        for c = region.originCol, region.originCol + region.activeCols - 1 do
            local key = r .. "_" .. c
            local cell = grid[key]
            if cell and #pairedIds > 0 then
                cell.id = table.remove(pairedIds)
            end
        end
    end

    -- 锁定组（保持旧行为：仅 Part 2 按 LEVEL_LOCK_RATE 概率生成）
    local lockRate = difficulty.lockGroupRate
    if lockRate == nil and part == 2 then
        lockRate = LianLianConst.LEVEL_LOCK_RATE[level]
        if lockRate == nil then lockRate = LianLianConst.LEVEL_LOCK_RATE[0] end
    end
    if lockRate and lockRate > 0 and rng() < lockRate then
        local count = difficulty.lockGroupCount or 1
        for _ = 1, count do
            setLockGroup(grid, rng, region)
        end
    end

    local layout = {
        gridRows = LianLianConst.GRID_HEIGHT,
        gridCols = LianLianConst.GRID_WIDTH,
        activeRows = region.activeRows,
        activeCols = region.activeCols,
        originRow = region.originRow,
        originCol = region.originCol,
    }

    local LianLianLevel = require "Game.LianLian.Config.LianLianLevel"
    local meta = {
        strategy = RandomFillStrategy.name,
        direction = LianLianLevel.direction[part] or "",
        enterList = LianLianLevel.enterList[part] or LianLianLevel.enterList[2] or {},
    }

    return LianLianBoardResult.new(grid, layout, meta)
end

return RandomFillStrategy
