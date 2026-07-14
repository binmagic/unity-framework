--[[
-- 连连看盘面生成策略基类 / 公共工具
-- 每个策略是一个纯函数式表模块（与 LianLianPlay/LianLianItem 风格一致），
-- 约定导出：
--   strategy.name              唯一名，如 "fixed" / "random"
--   strategy.generate(ctx)     核心：产出 LianLianBoardResult
-- ctx = { part, level, difficulty, rng }
--   difficulty = { activeRows, activeCols, originRow, originCol, kindCount,
--                  lockGroupCount, lockGroupRate, directions, ... }
--   rng = function 随机源（默认 math.random，便于测试/复现）
--
-- 本模块同时提供各策略复用的公共工具，避免重复代码。
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"

local LianLianGenStrategyBase = {}

--- 计算居中激活子矩形（在物理网格内，四周留边）
--- @param difficulty table 难度参数集（可含 activeRows/activeCols/originRow/originCol）
--- @return table { gridRows, gridCols, activeRows, activeCols, originRow, originCol }
function LianLianGenStrategyBase.computeActiveRegion(difficulty)
    difficulty = difficulty or {}
    local gridRows = LianLianConst.GRID_HEIGHT
    local gridCols = LianLianConst.GRID_WIDTH

    local activeRows = difficulty.activeRows or LianLianConst.INTERIOR_ROWS
    local activeCols = difficulty.activeCols or LianLianConst.INTERIOR_COLS

    -- 未显式指定 origin 时，居中放置激活区
    local originRow = difficulty.originRow
    local originCol = difficulty.originCol
    if originRow == nil then
        originRow = math.floor((gridRows - activeRows) / 2)
    end
    if originCol == nil then
        originCol = math.floor((gridCols - activeCols) / 2)
    end

    return {
        gridRows = gridRows,
        gridCols = gridCols,
        activeRows = activeRows,
        activeCols = activeCols,
        originRow = originRow,
        originCol = originCol,
    }
end

--- Fisher-Yates 洗牌（就地）
--- @param list table 数组
--- @param rng function 随机源，签名同 math.random
function LianLianGenStrategyBase.shuffle(list, rng)
    rng = rng or math.random
    for i = #list, 2, -1 do
        local j = rng(i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

--- 构造成对牌 ID 池（已洗牌）
--- 默认：前 kindCount 对使用固定 ID 1..kindCount，其余随机取自 1..kindCount，
--- 保证每种图案至少出现一对，行为与旧正式关 getGrid 逐格等价（kindCount 默认 KIND_MAX）。
--- randomAll=true：全部对随机取 ID（等价旧教学关 rndId 行为）。
--- @param pairCount number 需要的对数
--- @param kindCount number 图案种类上限
--- @param rng function 随机源
--- @param randomAll boolean 是否全部随机取 ID
--- @return table 已洗牌的 ID 数组（长度 = pairCount*2）
function LianLianGenStrategyBase.buildIdPool(pairCount, kindCount, rng, randomAll)
    rng = rng or math.random
    kindCount = kindCount or LianLianConst.KIND_MAX

    local ids = {}
    for i = 1, pairCount do
        if randomAll then
            ids[#ids + 1] = rng(kindCount)
        elseif i <= kindCount then
            ids[#ids + 1] = i
        else
            ids[#ids + 1] = rng(kindCount)
        end
    end

    -- 复制成对
    local paired = {}
    for _, id in ipairs(ids) do
        paired[#paired + 1] = id
        paired[#paired + 1] = id
    end

    LianLianGenStrategyBase.shuffle(paired, rng)
    return paired
end

return LianLianGenStrategyBase
