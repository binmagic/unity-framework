--[[
-- 连连看游戏总管理器
-- 整合所有子模块，提供统一接口
--]]

require "Framework.Common.BaseClass"
local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianEnum = require "Game.LianLian.Config.LianLianEnum"
local LianLianGrid = require "Game.LianLian.DataCenter.LianLianGrid"
local LianLianItem = require "Game.LianLian.DataCenter.LianLianItem"
local LianLianPlay = require "Game.LianLian.DataCenter.LianLianPlay"
local LianLianCard = require "Game.LianLian.DataCenter.LianLianCard"
local LianLianState = require "Game.LianLian.DataCenter.LianLianState"

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
    -- 按 level 随机抽本盘移动方向并锁定；教学关 part 1 强制无移动
    self.state.direction = self:rollBoardDirection()
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    -- 广播游戏开始事件
    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
    })
end

--- 抽取本盘移动方向（教学关 part 1 强制无移动）
function LianLianManager:rollBoardDirection()
    if self.state.part == 1 then return "" end
    return LianLianPlay.rollDirection(self.state.level)
end

--- Debug：按自定义 rows×cols 重新生成棋盘
--- @param rows number 行数
--- @param cols number 列数
--- @param part number 关卡号(用于移动方向等)
--- @param moveType string|nil 指定移动方向；nil 时随机抽取
function LianLianManager:startGameCustom(rows, cols, part, moveType)
    -- 校验并 clamp 参数（盘面生成规则在 Manager 侧统一管理）
    rows = math.floor(tonumber(rows) or LianLianConst.INTERIOR_ROWS)
    cols = math.floor(tonumber(cols) or LianLianConst.INTERIOR_COLS)
    part = math.floor(tonumber(part) or 1)
    rows = math.min(math.max(rows, 1), LianLianConst.INTERIOR_ROWS)
    cols = math.min(math.max(cols, 1), LianLianConst.INTERIOR_COLS)
    part = math.min(math.max(part, 1), LianLianPlay.getPartMax() or 10)

    self.state.part = part
    LianLianState.reset(self.state)
    -- 记录本盘参数，供 decreaseKind 等重生复用
    self.state.customRows = rows
    self.state.customCols = cols
    self.state.kindLimit = self.state.kindLimit or LianLianConst.KIND_MAX
    LianLianPlay.initDataCustom(self.state, rows, cols, self.state.kindLimit)
    -- 指定了移动类型则固定使用，否则随机抽取
    if moveType ~= nil then
        self.state.direction = moveType
    else
        self.state.direction = self:rollBoardDirection()
    end
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
    })
end

--- Debug：图案种类数减 1，用当前行列/方向重新生成盘面
function LianLianManager:decreaseKind()
    local cur = self.state.kindLimit or LianLianConst.KIND_MAX
    self.state.kindLimit = math.max(cur - 1, 1)
    local rows = self.state.customRows or LianLianConst.INTERIOR_ROWS
    local cols = self.state.customCols or LianLianConst.INTERIOR_COLS
    local direction = self.state.direction  -- reset 会清空，先保存

    LianLianState.reset(self.state)
    LianLianPlay.initDataCustom(self.state, rows, cols, self.state.kindLimit)
    self.state.direction = direction
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
    })
end

--- 获取当前盘面行列数（从 grid 非空格子推算）
--- @return number rows, number cols
function LianLianManager:getBoardSize()
    local maxR, maxC = 0, 0
    if self.state and self.state.grid then
        for _, cell in pairs(self.state.grid) do
            if cell.id and cell.id ~= 0 then
                if cell.r > maxR then maxR = cell.r end
                if cell.c > maxC then maxC = cell.c end
            end
        end
    end
    if maxR == 0 then maxR = LianLianConst.INTERIOR_ROWS end
    if maxC == 0 then maxC = LianLianConst.INTERIOR_COLS end
    return maxR, maxC
end

--- 获取棋盘数据
function LianLianManager:getGrid()
    return self.state.grid
end

--- 获取完整盘面描述对象（含 grid / layout / meta）
function LianLianManager:getBoard()
    return self.state.board
end

--- 获取盘面布局元信息（activeRows/activeCols/origin 等）
function LianLianManager:getLayout()
    return self.state.board and self.state.board.layout
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
    local direction = self:getDirection()
    local moveList = LianLianPlay.getMoveList(self.state.grid, direction)

    -- 把牌面 id 按移动列表迁移到新格（数据层生效），再广播给 View 播滑动动画
    if #moveList > 0 then
        LianLianPlay.applyMoveList(self.state.grid, moveList)
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

--- 获取游戏时长显示字符串
function LianLianManager:getPlayTimeStr()
    return LianLianPlay.getTimeStr(self:getPlayTime())
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

--- 盘面重排：按当前关卡难度把剩余元素重新摆放位置
--- 与洗牌(useShuffle)的区别：位置也变，非仅原地换 id
function LianLianManager:rearrangeBoard()
    self:cancelChecked()
    local difficulty = LianLianPlay.getDifficulty(self.state.level)
    LianLianCard.rearrange(self.state.grid, difficulty)
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { rearrange = true })
end

--- 使用加血道具
function LianLianManager:useHp()
    self.state.hp = LianLianCard.addHp(self.state.hp)
    EventManager:GetInstance():Broadcast("LianLian_HpUpdate", { hp = self.state.hp })
end

--- 获取进入动画列表（优先取盘面 meta，回退到 LianLianPlay）
function LianLianManager:getEnterList()
    local board = self.state.board
    if board and board.meta and board.meta.enterList then
        return board.meta.enterList
    end
    return LianLianPlay.getItemEnterList(self.state.part)
end

--- 获取移动方向（优先 Debug 覆盖，其次盘面 meta，回退到 LianLianPlay）
function LianLianManager:getDirection()
    -- Debug 覆盖优先
    if self.state.direction and self.state.direction ~= "" then
        return self.state.direction
    end
    -- 盘面 meta 次之
    local board = self.state.board
    if board and board.meta and board.meta.direction and board.meta.direction ~= "" then
        return board.meta.direction
    end
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
