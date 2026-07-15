--[[
-- 连连看关卡/游戏流程管理
-- 从 Cocos 项目 libs.play.js 迁移
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianLevel = require "Game.LianLian.Config.LianLianLevel"
local LianLianItem = require "Game.LianLian.Model.LianLianItem"
local LianLianBoardGenerator = require "Game.LianLian.Model.Board.LianLianBoardGenerator"

local WIDTH = LianLianConst.GRID_WIDTH
local HEIGHT = LianLianConst.GRID_HEIGHT

local LianLianPlay = {}

--- 获取最大关卡数
function LianLianPlay.getPartMax()
    local count = 0
    for _ in pairs(LianLianLevel.direction) do
        count = count + 1
    end
    return count
end

--- 判断当前关卡是否已完成
function LianLianPlay.isPartDone(part)
    part = part or 0
    return part > LianLianPlay.getPartMax()
end

--- 获取时间显示字符串
function LianLianPlay.getTimeStr(ms)
    if ms < 3600000 then
        local totalSec = math.floor(ms / 1000)
        local min = math.floor(totalSec / 60)
        local sec = totalSec % 60
        return string.format("%02d分%02d秒", min, sec)
    else
        local totalMin = math.floor(ms / 60000)
        local hour = math.floor(totalMin / 60)
        local min = totalMin % 60
        return string.format("%02d时%02d分", hour, min)
    end
end

--- 初始化关卡数据
--- @param state table 运行时状态
function LianLianPlay.initData(state)
    state.board = LianLianPlay.getGrid(state.part, state.level)
    state.grid = state.board.grid
    state.items = {}
    state.item_checked = {}
    state.hp = LianLianConst.HP_NUM
    state.revive_times = 0
    state.card_used = {}
end

--- 生成棋盘（委托给盘面生成子系统）
--- @param part number 当前关卡
--- @param level number 当前层级
--- @return table LianLianBoardResult（含 grid / layout / meta）
function LianLianPlay.getGrid(part, level)
    return LianLianBoardGenerator.generate(part, level or 0)
end

--- 获取当前层级的难度参数集（委托给盘面生成子系统）
--- @param level number 当前层级
--- @return table 难度参数集
function LianLianPlay.getDifficulty(level)
    return LianLianBoardGenerator.getDifficulty(level or 0)
end

--- 获取牌面进入动画的顺序
--- @param part number 当前关卡
--- @return table 进入顺序列表 {r_c, ...}
function LianLianPlay.getItemEnterList(part)
    return LianLianLevel.enterList[part] or LianLianLevel.enterList[2]
end

--- 获取当前关卡的移动方向
--- @param part number 当前关卡
--- @return string 移动方向
function LianLianPlay.getDirection(part)
    return LianLianLevel.direction[part] or ""
end

--- 消除成功后的棋盘移动
--- @param grid table 棋盘数据
--- @param direction string 移动方向
--- @return table 移动列表 {{oldRc, newRc}, ...}
function LianLianPlay.getMoveList(grid, direction)
    if direction == "" then return {} end

    if direction:find("^flock") then
        return LianLianPlay._getFlockList(grid, direction)
    elseif direction:find("^divide") then
        return LianLianPlay._getDivideList(grid, direction)
    else
        return LianLianPlay._getMoveList(grid, direction)
    end
end

--- 单方向移动列表
function LianLianPlay._getMoveList(grid, direction)
    local list = {}
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then
            local emptyNum = LianLianPlay._getEmptyNum(grid, cell, direction)
            if emptyNum > 0 then
                local newRc
                if direction == "up" then
                    newRc = (cell.r - emptyNum) .. "_" .. cell.c
                elseif direction == "down" then
                    newRc = (cell.r + emptyNum) .. "_" .. cell.c
                elseif direction == "left" then
                    newRc = cell.r .. "_" .. (cell.c - emptyNum)
                elseif direction == "right" then
                    newRc = cell.r .. "_" .. (cell.c + emptyNum)
                end
                list[#list + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = newRc }
            end
        end
    end

    -- down 和 right 需要反转顺序
    if direction == "down" or direction == "right" then
        local reversed = {}
        for i = #list, 1, -1 do
            reversed[#reversed + 1] = list[i]
        end
        return reversed
    end
    return list
end

--- 分散移动列表
function LianLianPlay._getDivideList(grid, direction)
    local listA = {}
    local listB = {}

    for _, cell in pairs(grid) do
        if cell.id ~= 0 then
            if direction == "divide_up_down" then
                if LianLianPlay._isDirection(cell, "up") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "up")
                    if n > 0 then
                        listA[#listA + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = (cell.r - n) .. "_" .. cell.c }
                    end
                end
                if LianLianPlay._isDirection(cell, "down") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "down")
                    if n > 0 then
                        listB[#listB + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = (cell.r + n) .. "_" .. cell.c }
                    end
                end
            elseif direction == "divide_left_right" then
                if LianLianPlay._isDirection(cell, "left") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "left")
                    if n > 0 then
                        listA[#listA + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = cell.r .. "_" .. (cell.c - n) }
                    end
                end
                if LianLianPlay._isDirection(cell, "right") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "right")
                    if n > 0 then
                        listB[#listB + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = cell.r .. "_" .. (cell.c + n) }
                    end
                end
            end
        end
    end

    -- 合并，B 列表反转
    local result = {}
    for _, v in ipairs(listA) do result[#result + 1] = v end
    for i = #listB, 1, -1 do result[#result + 1] = listB[i] end
    return result
end

--- 聚拢移动列表
function LianLianPlay._getFlockList(grid, direction)
    local listA = {}
    local listB = {}

    for _, cell in pairs(grid) do
        if cell.id ~= 0 then
            if direction == "flock_up_down" then
                if LianLianPlay._isDirection(cell, "up") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "flock_up")
                    if n > 0 then
                        listA[#listA + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = (cell.r + n) .. "_" .. cell.c }
                    end
                end
                if LianLianPlay._isDirection(cell, "down") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "flock_down")
                    if n > 0 then
                        listB[#listB + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = (cell.r - n) .. "_" .. cell.c }
                    end
                end
            elseif direction == "flock_left_right" then
                if LianLianPlay._isDirection(cell, "left") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "flock_left")
                    if n > 0 then
                        listA[#listA + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = cell.r .. "_" .. (cell.c + n) }
                    end
                end
                if LianLianPlay._isDirection(cell, "right") then
                    local n = LianLianPlay._getEmptyNum(grid, cell, "flock_right")
                    if n > 0 then
                        listB[#listB + 1] = { oldRc = cell.r .. "_" .. cell.c, newRc = cell.r .. "_" .. (cell.c - n) }
                    end
                end
            end
        end
    end

    local result = {}
    for _, v in ipairs(listB) do result[#result + 1] = v end
    for i = #listA, 1, -1 do result[#result + 1] = listA[i] end
    return result
end

--- 计算指定方向上的空位数
function LianLianPlay._getEmptyNum(grid, cell, direction)
    local count = 0
    if direction == "up" then
        for r = 1, cell.r - 1 do
            if LianLianItem.isEmpty(grid, { r = r, c = cell.c }) then count = count + 1 end
        end
    elseif direction == "down" then
        for r = HEIGHT - 2, cell.r + 1, -1 do
            if LianLianItem.isEmpty(grid, { r = r, c = cell.c }) then count = count + 1 end
        end
    elseif direction == "left" then
        for c = 1, cell.c - 1 do
            if LianLianItem.isEmpty(grid, { r = cell.r, c = c }) then count = count + 1 end
        end
    elseif direction == "right" then
        for c = WIDTH - 2, cell.c + 1, -1 do
            if LianLianItem.isEmpty(grid, { r = cell.r, c = c }) then count = count + 1 end
        end
    elseif direction == "flock_up" then
        for r = math.floor(HEIGHT / 2) - 1, cell.r + 1, -1 do
            if LianLianItem.isEmpty(grid, { r = r, c = cell.c }) then count = count + 1 end
        end
    elseif direction == "flock_down" then
        for r = math.ceil(HEIGHT / 2), cell.r - 1 do
            if LianLianItem.isEmpty(grid, { r = r, c = cell.c }) then count = count + 1 end
        end
    elseif direction == "flock_left" then
        for c = math.floor(WIDTH / 2) - 1, cell.c + 1, -1 do
            if LianLianItem.isEmpty(grid, { r = cell.r, c = c }) then count = count + 1 end
        end
    elseif direction == "flock_right" then
        for c = math.ceil(WIDTH / 2), cell.c - 1 do
            if LianLianItem.isEmpty(grid, { r = cell.r, c = c }) then count = count + 1 end
        end
    end
    return count
end

--- 判断牌位是否在指定方向的半区
function LianLianPlay._isDirection(cell, direction)
    local halfW = WIDTH / 2
    local halfH = HEIGHT / 2
    if direction == "up" then return cell.r < halfH
    elseif direction == "down" then return cell.r >= halfH
    elseif direction == "left" then return cell.c < halfW
    elseif direction == "right" then return cell.c >= halfW
    end
    return false
end

return LianLianPlay
