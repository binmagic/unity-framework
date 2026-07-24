--[[
-- 连连看牌面逻辑
-- 从 Cocos 项目 libs.item.js 迁移
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"

local LianLianItem = {}

local KIND_MAX = LianLianConst.KIND_MAX

--- 生成随机牌面 ID（排除指定 ID）
function LianLianItem.rndId(...)
    local exclude = { ... }
    local pool = {}
    for i = 1, KIND_MAX do
        local skip = false
        for _, v in ipairs(exclude) do
            if v == i then skip = true; break end
        end
        if not skip then pool[#pool + 1] = i end
    end
    return pool[math.random(#pool)]
end

--- 生成随机 ID 列表（n 个不重复的）
function LianLianItem.rndIdList(n)
    local list = {}
    for i = 1, KIND_MAX do list[i] = i end
    -- Fisher-Yates 洗牌
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
    local result = {}
    for i = 1, math.min(n, #list) do
        result[i] = list[i]
    end
    return result
end

--- 获取指定位置的牌面 ID
--- @param grid table 棋盘数据
--- @param pos table {r, c}
function LianLianItem.getId(grid, pos)
    local key = pos.r .. "_" .. pos.c
    local cell = grid[key]
    return cell and cell.id or 0
end

--- 判断位置是否有牌
function LianLianItem.isVaild(grid, pos)
    return LianLianItem.getId(grid, pos) ~= 0
end

--- 判断位置是否为空
function LianLianItem.isEmpty(grid, pos)
    return LianLianItem.getId(grid, pos) == 0
end

--- 判断两个位置的牌是否相同
function LianLianItem.isSameId(grid, a, b)
    if not a or not b then return false end
    local idA = LianLianItem.getId(grid, a)
    local idB = LianLianItem.getId(grid, b)
    return idA ~= 0 and idA == idB
end

--- 判断两个位置是否相同
function LianLianItem.isSamePos(a, b)
    if not a or not b then return false end
    return a.r == b.r and a.c == b.c
end

--- 判断棋盘是否已清空（胜利条件）
function LianLianItem.isAllEmpty(grid)
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then return false end
    end
    return true
end

--- 判断指定位置是否已被选中
function LianLianItem.isChecked(checkedList, pos)
    for _, checked in ipairs(checkedList) do
        if LianLianItem.isSamePos(checked, pos) then return true end
    end
    return false
end

--- 按 ID 统计剩余牌数
function LianLianItem.subtotalById(grid)
    local counts = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then
            counts[cell.id] = (counts[cell.id] or 0) + 1
        end
    end
    return counts
end

--- 判断是否只剩锁定组（2×2 方块）
function LianLianItem.onlyLockGroup(grid)
    local tiles = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then tiles[#tiles + 1] = cell end
    end
    if #tiles ~= 4 then return false end

    -- 检查是否形成 2×2 方块
    -- 排序：按行再按列
    table.sort(tiles, function(a, b)
        if a.r ~= b.r then return a.r < b.r end
        return a.c < b.c
    end)

    -- 验证 2×2 结构
    if tiles[1].r ~= tiles[2].r then return false end
    if tiles[3].r ~= tiles[4].r then return false end
    if tiles[1].r + 1 ~= tiles[3].r then return false end
    if tiles[1].c ~= tiles[3].c then return false end
    if tiles[2].c ~= tiles[4].c then return false end
    if tiles[1].c + 1 ~= tiles[2].c then return false end

    -- 验证对角相同
    return tiles[1].id == tiles[4].id and tiles[2].id == tiles[3].id
end

--- 找到一对可消除的牌（用于提示）
--- @param grid table 棋盘数据
--- @param getClearPath function 路径判定函数
function LianLianItem.getPair(grid, getClearPath)
    local tiles = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then tiles[#tiles + 1] = cell end
    end

    for i = 1, #tiles do
        for j = i + 1, #tiles do
            if tiles[i].id == tiles[j].id then
                local path = getClearPath(grid, tiles[i], tiles[j])
                if path then
                    return { tiles[i], tiles[j] }
                end
            end
        end
    end
    return nil
end

--- 找到所有可消除的牌对
function LianLianItem.getAllPair(grid, getClearPath)
    local pairs = {}
    local tiles = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then tiles[#tiles + 1] = cell end
    end

    for i = 1, #tiles do
        for j = i + 1, #tiles do
            if tiles[i].id == tiles[j].id then
                local path = getClearPath(grid, tiles[i], tiles[j])
                if path then
                    pairs[#pairs + 1] = { tiles[i], tiles[j] }
                end
            end
        end
    end
    return pairs
end

--- 删除指定位置的牌
function LianLianItem.del(grid, pos)
    local key = pos.r .. "_" .. pos.c
    if grid[key] then grid[key].id = 0 end
end

return LianLianItem
