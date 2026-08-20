--[[
-- 连连看道具系统
-- 从 Cocos 项目 libs.card.js 迁移
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianItem = require "Game.LianLian.DataCenter.LianLianItem"
local LianLianBase = require "Game.LianLian.DataCenter.Board.LianLianGenStrategyBase"

local LianLianCard = {}

--- 区域重排：保留「剩余元素个数」不变，位置不保留，随机撒回整个 rows×cols 区域
--- （空位也可能被占上）。id 多重集不变 → 成对关系仍可消。
--- @param grid table 层棋盘
--- @param rows number 该层行数
--- @param cols number 该层列数
function LianLianCard.reshuffleRegion(grid, rows, cols)
    rows = rows or 1
    cols = cols or 1
    -- 1) 收集剩余元素的 id（保留个数与图案）
    local ids = {}
    for _, cell in pairs(grid) do
        if cell.id and cell.id ~= 0 then
            ids[#ids + 1] = cell.id
        end
    end
    -- 打乱 id
    for i = #ids, 2, -1 do
        local j = math.random(i)
        ids[i], ids[j] = ids[j], ids[i]
    end

    -- 2) 收集区域内所有格 key（含当前空格），打乱后取前 #ids 个安放
    local cells = {}
    for r = 1, rows do
        for c = 1, cols do
            local key = r .. "_" .. c
            if grid[key] then cells[#cells + 1] = key end
        end
    end
    for i = #cells, 2, -1 do
        local j = math.random(i)
        cells[i], cells[j] = cells[j], cells[i]
    end

    -- 3) 先全清区域，再把 ids 撒到打乱后的前 N 个格
    for _, key in ipairs(cells) do
        grid[key].id = 0
    end
    for i = 1, #ids do
        local key = cells[i]
        if not key then break end
        grid[key].id = ids[i]
    end
end

--- 获取道具持有数量
--- @param cardList table 道具列表数据
--- @param id number 道具 ID
function LianLianCard.getNum(cardList, id)
    return (cardList[id] and cardList[id].num) or 0
end

--- 设置道具数量
function LianLianCard.setNum(cardList, id, num)
    cardList[id] = cardList[id] or {}
    cardList[id].num = num
end

--- 增加道具数量
function LianLianCard.incNum(cardList, id, delta)
    cardList[id] = cardList[id] or { num = 0 }
    cardList[id].num = cardList[id].num + delta
end

--- 判断道具是否已达上限
function LianLianCard.isMax(cardList, id)
    return LianLianCard.getNum(cardList, id) >= LianLianConst.CARD_MAX
end

--- 判断所有道具是否都满了
function LianLianCard.isAllMax(cardList)
    for id = 1, 3 do
        if not LianLianCard.isMax(cardList, id) then return false end
    end
    return true
end

--- 获取剩余复活次数
function LianLianCard.getReviveTimes(reviveTimes)
    if not LianLianConst.REVIVE_TIMES_MAX then return 1 end
    local remaining = LianLianConst.REVIVE_TIMES_MAX - reviveTimes
    return remaining > 0 and remaining or 0
end

--- 提示道具：高亮一对可消除的牌
--- @param pair table {cellA, cellB}
function LianLianCard.tip(pair)
    -- 返回需要高亮的两个牌位
    if pair and #pair >= 2 then
        return pair[1], pair[2]
    end
    return nil
end

--- 洗牌道具：随机重排所有牌面
--- @param grid table 棋盘数据
function LianLianCard.shuffle(grid)
    -- 检查是否只剩锁定组
    if LianLianItem.onlyLockGroup(grid) then
        local tiles = {}
        for _, cell in pairs(grid) do
            if cell.id ~= 0 then tiles[#tiles + 1] = cell end
        end
        -- 锁定组特殊处理：交换两个相邻角
        if math.random(0, 1) == 0 then
            tiles[1].id, tiles[2].id = tiles[2].id, tiles[1].id
        else
            tiles[1].id, tiles[3].id = tiles[3].id, tiles[1].id
        end
    else
        -- 普通洗牌：收集所有 ID，打乱，重新分配
        local ids = {}
        for _, cell in pairs(grid) do
            if LianLianItem.isVaild(grid, cell) then
                ids[#ids + 1] = cell.id
            end
        end
        -- Fisher-Yates 洗牌
        for i = #ids, 2, -1 do
            local j = math.random(i)
            ids[i], ids[j] = ids[j], ids[i]
        end
        -- 重新分配
        for _, cell in pairs(grid) do
            if LianLianItem.isVaild(grid, cell) then
                cell.id = table.remove(ids)
            end
        end
    end
end

--- 盘面重排：把剩余元素随机散布到难度激活区内的格子
--- 与 shuffle 的区别：位置也重排（shuffle 仅原地换 id）
--- @param grid table 棋盘数据
--- @param difficulty table 关卡难度参数集（决定激活区）
function LianLianCard.rearrange(grid, difficulty)
    -- 1) 收集剩余 id
    local ids = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then ids[#ids + 1] = cell.id end
    end
    if #ids == 0 then return end

    -- 2) 清空整盘
    for _, cell in pairs(grid) do cell.id = 0 end

    -- 3) 依难度取激活区内所有格子
    local region = LianLianBase.computeActiveRegion(difficulty)
    local cells = {}
    for r = region.originRow, region.originRow + region.activeRows - 1 do
        for c = region.originCol, region.originCol + region.activeCols - 1 do
            local cell = grid[r .. "_" .. c]
            if cell then cells[#cells + 1] = cell end
        end
    end

    -- 4) 打乱目标格子顺序，把剩余 id 依次放入 → 位置全随机
    LianLianBase.shuffle(cells)
    for i = 1, #ids do
        cells[i].id = ids[i]
    end
end

--- 加血道具：恢复 HP
--- @param hp number 当前 HP
--- @return number 新的 HP 值
function LianLianCard.addHp(hp)
    local newHp = hp + LianLianConst.HP_NUM
    if newHp > LianLianConst.HP_MAX then
        newHp = LianLianConst.HP_MAX
    end
    return math.max(newHp, 1)
end

return LianLianCard
