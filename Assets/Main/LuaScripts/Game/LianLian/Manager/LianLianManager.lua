--[[
-- 连连看游戏总管理器
-- 整合所有子模块，提供统一接口
--]]

require "Framework.Common.BaseClass"
local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianEnum = require "Game.LianLian.Config.LianLianEnum"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"
local LianLianItem = require "Game.LianLian.Model.LianLianItem"
local LianLianPlay = require "Game.LianLian.Model.LianLianPlay"
local LianLianCard = require "Game.LianLian.Model.LianLianCard"
local LianLianState = require "Game.LianLian.Model.LianLianState"

local LianLianManager = BaseClass("LianLianManager", Singleton)

function LianLianManager:__init()
    self.state = LianLianState.New()
end

--- 开始新游戏
--- @param part number 关卡号
function LianLianManager:startGame(part)
    self.state.part = part or 1
    LianLianState.reset(self.state)
    LianLianPlay.initData(self.state)
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    -- 广播游戏开始事件
    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = LianLianPlay.getDirection(self.state.part),
    })
end

--- 获取棋盘数据
function LianLianManager:getGrid()
    return self.state.grid
end

--- 获取当前生命值
function LianLianManager:getHp()
    return self.state.hp
end

--- 获取当前关卡
function LianLianManager:getPart()
    return self.state.part
end

--- 选中牌面
--- @param index number 选中序号 (1=第一次, 2=第二次)
--- @param pos table {r, c}
function LianLianManager:checkTile(index, pos)
    self.state.item_checked[index] = pos
    EventManager:GetInstance():Broadcast("LianLian_ItemShowChecked", pos)
end

--- 取消选中
function LianLianManager:cancelChecked()
    self.state.item_checked = {}
    EventManager:GetInstance():Broadcast("LianLian_ItemHideChecked")
end

--- 执行消除判定
--- @return boolean 是否成功消除
--- @return table|nil 路径数据
function LianLianManager:doClear()
    local checked = self.state.item_checked
    if #checked < 2 then return false, nil end

    local a = checked[1]
    local b = checked[2]

    -- 检查是否同一位置
    if LianLianItem.isSamePos(a, b) then
        self:cancelChecked()
        return false, nil
    end

    -- 检查是否相同 ID
    if not LianLianItem.isSameId(self.state.grid, a, b) then
        self:cancelChecked()
        self:loseHp()
        return false, nil
    end

    -- 检查路径
    local path = LianLianGrid.getClearPath(self.state.grid, a, b)
    if not path then
        self:cancelChecked()
        self:loseHp()
        return false, nil
    end

    -- 消除成功
    LianLianItem.del(self.state.grid, a)
    LianLianItem.del(self.state.grid, b)
    self:cancelChecked()

    -- 生成连线数据
    local pathLine = LianLianGrid.getPathLine(path)

    return true, pathLine
end

--- 消除后的处理（移动 + 胜利判定）
function LianLianManager:afterClear()
    -- 获取移动方向
    local direction = LianLianPlay.getDirection(self.state.part)
    local moveList = LianLianPlay.getMoveList(self.state.grid, direction)

    -- 广播移动事件
    if #moveList > 0 then
        EventManager:GetInstance():Broadcast("LianLian_Move", {
            direction = direction,
            moveList = moveList,
        })
    end

    -- 检查胜利条件
    if LianLianItem.isAllEmpty(self.state.grid) then
        self:win()
        return true
    end

    return false
end

--- 扣减生命值
function LianLianManager:loseHp()
    self.state.hp = self.state.hp - 1
    EventManager:GetInstance():Broadcast("LianLian_HpUpdate", { hp = self.state.hp })

    if self.state.hp <= 0 then
        self:gameOver()
    end
end

--- 游戏结束（生命值归零）
function LianLianManager:gameOver()
    self.state.isPlaying = false
    self.state.endTime = os.time() * 1000

    -- 检查是否可以复活
    local canRevive = LianLianCard.getReviveTimes(self.state.revive_times) > 0

    EventManager:GetInstance():Broadcast("LianLian_GameOver", {
        canRevive = canRevive,
        reviveTimes = self.state.revive_times,
    })
end

--- 复活
function LianLianManager:revive()
    self.state.revive_times = self.state.revive_times + 1
    self.state.hp = LianLianConst.HP_NUM
    self.state.isPlaying = true

    EventManager:GetInstance():Broadcast("LianLian_HpUpdate", { hp = self.state.hp })
end

--- 胜利
function LianLianManager:win()
    self.state.isPlaying = false
    self.state.endTime = os.time() * 1000

    EventManager:GetInstance():Broadcast("LianLian_GameOver", {
        isWin = true,
        part = self.state.part,
        time = self:getPlayTime(),
    })
end

--- 获取游戏时长（毫秒）
function LianLianManager:getPlayTime()
    if self.state.startTime == 0 then return 0 end
    local endTime = self.state.endTime > 0 and self.state.endTime or (os.time() * 1000)
    return endTime - self.state.startTime
end

--- 使用提示道具
function LianLianManager:useTip()
    self:cancelChecked()
    local pair = LianLianItem.getPair(self.state.grid, function(grid, a, b)
        return LianLianGrid.getClearPath(grid, a, b)
    end)
    if pair then
        EventManager:GetInstance():Broadcast("LianLian_ItemShowTip", pair)
    end
    return pair
end

--- 使用洗牌道具
function LianLianManager:useShuffle()
    self:cancelChecked()
    LianLianCard.shuffle(self.state.grid)
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true })
end

--- 使用加血道具
function LianLianManager:useHp()
    self.state.hp = LianLianCard.addHp(self.state.hp)
    EventManager:GetInstance():Broadcast("LianLian_HpUpdate", { hp = self.state.hp })
end

--- 获取进入动画列表
function LianLianManager:getEnterList()
    return LianLianPlay.getItemEnterList(self.state.part)
end

--- 获取移动方向
function LianLianManager:getDirection()
    return LianLianPlay.getDirection(self.state.part)
end

--- 进入下一关
function LianLianManager:nextPart()
    self.state.part = self.state.part + 1
    if LianLianPlay.isPartDone(self.state.part) then
        -- 一局完成，重新开始
        self.state.part = 2
        self.state.level = self.state.level + 1
    end
end

--- 删除管理器
function LianLianManager:__delete()
    self.state = nil
end

return LianLianManager
