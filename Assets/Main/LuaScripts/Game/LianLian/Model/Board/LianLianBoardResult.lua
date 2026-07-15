--[[
-- 连连看盘面描述对象（BoardResult）
-- 生成器统一返回此结构，把 View 需要的布局/元信息全部显式带出，
-- 让 View 无需再读 LianLianConst 里写死的棋盘尺寸常量。
--]]

local LianLianBoardResult = {}

--- 构造盘面描述对象
--- @param grid table   棋盘数据 { ["r_c"] = { r, c, n, id, x, y }, ... }
--- @param layout table 布局元信息 { gridRows, gridCols, activeRows, activeCols, originRow, originCol }
--- @param meta table   附加元信息 { strategy, direction, enterList }
--- @return table BoardResult
function LianLianBoardResult.new(grid, layout, meta)
    assert(type(grid) == "table", "BoardResult: grid 必须是 table")
    assert(type(layout) == "table", "BoardResult: layout 必须是 table")

    layout.gridRows = layout.gridRows or 0
    layout.gridCols = layout.gridCols or 0
    layout.activeRows = layout.activeRows or layout.gridRows
    layout.activeCols = layout.activeCols or layout.gridCols
    layout.originRow = layout.originRow or 0
    layout.originCol = layout.originCol or 0

    assert(layout.activeRows > 0 and layout.activeCols > 0,
        "BoardResult: activeRows/activeCols 必须为正")

    meta = meta or {}
    meta.strategy = meta.strategy or "unknown"
    meta.direction = meta.direction or ""
    meta.enterList = meta.enterList or {}

    return {
        grid = grid,
        layout = layout,
        meta = meta,
    }
end

return LianLianBoardResult
