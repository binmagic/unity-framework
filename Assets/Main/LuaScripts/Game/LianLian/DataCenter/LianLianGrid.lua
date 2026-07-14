--[[
-- 连连看棋盘系统
-- 核心：路径判定算法（最多 2 个拐点）
-- 从 Cocos 项目 libs.grid.js 迁移
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"

local WIDTH = LianLianConst.GRID_WIDTH
local HEIGHT = LianLianConst.GRID_HEIGHT
local SIZE = LianLianConst.CELL_SIZE

local LianLianGrid = {}

--- 创建棋盘数据（10列×16行，key 为 "r_c"）
function LianLianGrid.create()
    local grid = {}
    for r = 0, HEIGHT - 1 do
        for c = 0, WIDTH - 1 do
            local key = r .. "_" .. c
            grid[key] = {
                x = (c + 0.5) * SIZE,
                y = -(r + 0.5) * SIZE,
                r = r,
                c = c,
                n = r * WIDTH + c,
                id = 0,
            }
        end
    end
    return grid
end

--- 获取内部有效格子数（去除四周边框）
function LianLianGrid.getLen()
    return (WIDTH - 2) * (HEIGHT - 2)
end

--- 序号 → {r, c}
function LianLianGrid.n2v(n)
    return { r = math.floor(n / WIDTH), c = n % WIDTH }
end

--- {r, c} → 序号
function LianLianGrid.v2n(v)
    return v.r * WIDTH + v.c
end

--- "r_c" 字符串 → {r, c}
function LianLianGrid.rc2v(rc)
    local parts = {}
    for s in rc:gmatch("[^_]+") do
        parts[#parts + 1] = tonumber(s)
    end
    return { r = parts[1], c = parts[2] }
end

--- {r, c} → "r_c" 字符串
function LianLianGrid.v2rc(v)
    return v.r .. "_" .. v.c
end

--- 序号 → "r_c"
function LianLianGrid.n2rc(n)
    return LianLianGrid.v2rc(LianLianGrid.n2v(n))
end

--- "r_c" → 序号
function LianLianGrid.rc2n(rc)
    return LianLianGrid.v2n(LianLianGrid.rc2v(rc))
end

--- 获取两点之间的直线路径（不含端点）
--- 只处理同行或同列的情况
function LianLianGrid.getStraightPath(a, b)
    local path = {}
    if a.r == b.r then
        local minC = math.min(a.c, b.c) + 1
        local maxC = math.max(a.c, b.c) - 1
        for c = minC, maxC do
            path[#path + 1] = { r = a.r, c = c }
        end
        return path
    end
    if a.c == b.c then
        local minR = math.min(a.r, b.r) + 1
        local maxR = math.max(a.r, b.r) - 1
        for r = minR, maxR do
            path[#path + 1] = { r = r, c = a.c }
        end
        return path
    end
    return nil
end

--- 根据拐点列表生成完整路径
function LianLianGrid.getPath(apexList)
    local path = LianLianGrid.getStraightPath(apexList[1], apexList[2])
    if not path then return nil end
    path[#path + 1] = apexList[2]

    if apexList[3] then
        local seg = LianLianGrid.getStraightPath(apexList[2], apexList[3])
        if not seg then return nil end
        for _, v in ipairs(seg) do path[#path + 1] = v end
        path[#path + 1] = apexList[3]
    end

    if apexList[4] then
        local seg = LianLianGrid.getStraightPath(apexList[3], apexList[4])
        if not seg then return nil end
        for _, v in ipairs(seg) do path[#path + 1] = v end
        path[#path + 1] = apexList[4]
    end

    -- 去掉最后一个端点（终点）
    table.remove(path)
    return path
end

--- 验证路径是否合法（所有中间格子为空）
--- @param grid table 棋盘数据
--- @param path table 路径点列表
function LianLianGrid.isVaildPath(grid, path)
    for _, pos in ipairs(path) do
        local key = pos.r .. "_" .. pos.c
        if grid[key] and grid[key].id ~= 0 then
            return false
        end
    end
    return true
end

--- 同行两点的候选拐点列表
function LianLianGrid.rowPathApex(a, b)
    local list = { {a, b} }  -- 直连
    for n = 1, HEIGHT - 1 do
        if a.r - n >= 0 then
            list[#list + 1] = { a, { r = a.r - n, c = a.c }, { r = a.r - n, c = b.c }, b }
        end
        if a.r + n < HEIGHT then
            list[#list + 1] = { a, { r = a.r + n, c = a.c }, { r = a.r + n, c = b.c }, b }
        end
    end
    return list
end

--- 同列两点的候选拐点列表
function LianLianGrid.colPathApex(a, b)
    local list = { {a, b} }  -- 直连
    for n = 1, WIDTH - 1 do
        if a.c + n < WIDTH then
            list[#list + 1] = { a, { r = a.r, c = a.c + n }, { r = b.r, c = a.c + n }, b }
        end
        if a.c - n >= 0 then
            list[#list + 1] = { a, { r = a.r, c = a.c - n }, { r = b.r, c = a.c - n }, b }
        end
    end
    return list
end

--- 不同行不同列的候选拐点列表
function LianLianGrid.bothPathApex(a, b)
    local list = {
        -- L 形（1 拐点）
        { a, { r = a.r, c = b.c }, b },
        { a, { r = b.r, c = a.c }, b },
    }

    -- Z 形（2 拐点）- 沿列方向偏移
    for n = 1, math.abs(a.c - b.c) - 1 do
        local c = a.c + (a.c < b.c and n or -n)
        list[#list + 1] = { a, { r = a.r, c = c }, { r = b.r, c = c }, b }
    end

    -- Z 形（2 拐点）- 沿行方向偏移
    for n = 1, math.abs(a.r - b.r) - 1 do
        local r = a.r + (a.r < b.r and n or -n)
        list[#list + 1] = { a, { r = r, c = a.c }, { r = r, c = b.c }, b }
    end

    -- 向左扩展
    for n = 1, WIDTH - 1 do
        local c = math.min(a.c, b.c) - n
        if c >= 0 then
            list[#list + 1] = { a, { r = a.r, c = c }, { r = b.r, c = c }, b }
        end
        c = math.max(a.c, b.c) + n
        if c < WIDTH then
            list[#list + 1] = { a, { r = a.r, c = c }, { r = b.r, c = c }, b }
        end
    end

    -- 向上扩展
    for n = 1, HEIGHT - 1 do
        local r = math.min(a.r, b.r) - n
        if r >= 0 then
            list[#list + 1] = { a, { r = r, c = a.c }, { r = r, c = b.c }, b }
        end
        r = math.max(a.r, b.r) + n
        if r < HEIGHT then
            list[#list + 1] = { a, { r = r, c = a.c }, { r = r, c = b.c }, b }
        end
    end

    return list
end

--- 核心算法：判断两个牌位之间是否存在合法路径
--- @param grid table 棋盘数据
--- @param a table 牌位A {r, c}
--- @param b table 牌位B {r, c}
--- @return table|nil 路径列表（含端点），或 nil 表示无合法路径
function LianLianGrid.getClearPath(grid, a, b)
    local apexList
    if a.r == b.r then
        apexList = LianLianGrid.rowPathApex(a, b)
    elseif a.c == b.c then
        apexList = LianLianGrid.colPathApex(a, b)
    else
        apexList = LianLianGrid.bothPathApex(a, b)
    end

    for _, apex in ipairs(apexList) do
        local path = LianLianGrid.getPath(apex)
        if path and LianLianGrid.isVaildPath(grid, path) then
            -- 返回完整路径（含端点）
            local fullPath = { a }
            for _, v in ipairs(path) do fullPath[#fullPath + 1] = v end
            fullPath[#fullPath + 1] = b
            return fullPath
        end
    end
    return nil
end

--- 将路径转换为连线渲染数据（带方向信息）
function LianLianGrid.getPathLine(path)
    -- 构建位置查找表
    local posMap = {}
    for _, pos in ipairs(path) do
        local key = pos.r .. "_" .. pos.c
        posMap[key] = pos
    end

    -- 生成带方向信息的点列表
    local lineList = {}
    for _, pos in ipairs(path) do
        lineList[#lineList + 1] = {
            r = pos.r,
            c = pos.c,
            top = posMap[(pos.r - 1) .. "_" .. pos.c] and 1 or 0,
            right = posMap[pos.r .. "_" .. (pos.c + 1)] and 1 or 0,
            bottom = posMap[(pos.r + 1) .. "_" .. pos.c] and 1 or 0,
            left = posMap[pos.r .. "_" .. (pos.c - 1)] and 1 or 0,
        }
    end

    -- 不合成拐角：拐角格保留两个方向标志（如 top=1 且 right=1），
    -- 渲染层用两条半边直线在格中心交汇拼成 L，自动对齐，无需独立拐角图。

    return lineList
end

return LianLianGrid
