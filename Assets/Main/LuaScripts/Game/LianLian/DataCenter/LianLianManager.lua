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

--- Debug：直传版——全部外部传入，直接生成（不查 LEVEL_BOARD_CONFIG/池）
--- @param rows number 行数(1..INTERIOR_ROWS)
--- @param cols number 列数(1..INTERIOR_COLS)
--- @param kindLimit number 图案种类数(1..KIND_MAX)
--- @param direction string 移动方向("" / up / down / left / right / divide_* / flock_*)
--- @param layer number 每格叠加层数(默认1=单层)
function LianLianManager:startGameCustom(rows, cols, kindLimit, direction, layer)
    -- 校验并 clamp 参数（盘面生成规则在 Manager 侧统一管理）
    rows = math.floor(tonumber(rows) or LianLianConst.INTERIOR_ROWS)
    cols = math.floor(tonumber(cols) or LianLianConst.INTERIOR_COLS)
    kindLimit = math.floor(tonumber(kindLimit) or LianLianConst.KIND_MAX)
    local layerCount = math.max(math.floor(tonumber(layer) or 1), 1)
    rows = math.min(math.max(rows, 1), LianLianConst.INTERIOR_ROWS)
    cols = math.min(math.max(cols, 1), LianLianConst.INTERIOR_COLS)
    kindLimit = math.min(math.max(kindLimit, 1), LianLianConst.KIND_MAX)

    LianLianState.reset(self.state)
    -- 记录本盘参数，供 decreaseKind 等重生复用
    self.state.customRows = rows
    self.state.customCols = cols
    self.state.kindLimit = kindLimit
    self.state.boardLayer = layerCount

    self:buildAndSetLayers(rows, cols, kindLimit, layerCount, direction or "")
    self.state.direction = direction or ""
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
        layerCount = self.state.layerCount,
    })
end

--- 生成多层独立盘并写入 state（每层一盘连连看，底大顶小；state.grid 指向底层做兼容）
--- @param direction string 各层统一使用的移动方向（"" 表示无移动）
function LianLianManager:buildAndSetLayers(rows, cols, kindLimit, layerCount, direction)
    local layers = LianLianPlay.buildLayers(rows, cols, kindLimit, layerCount)
    local count = 0
    for _, ly in pairs(layers) do
        ly.direction = direction or ""
        count = count + 1
    end
    self.state.layers = layers
    self.state.layerCount = count
    -- 兼容旧路径：state.grid 指向底层 grid（getBoardSize/getBoard 回退/单层 View）
    self.state.grid = layers[1] and layers[1].grid or {}
end

--- Debug：配置池版——只传 level，rows/cols/kindLimit/方向全从 LEVEL_BOARD_CONFIG 读
--- @param level number 分层(难度档位)
function LianLianManager:startGameByLevel(level)
    level = math.floor(tonumber(level) or 1)
    local pool = LianLianConst.LEVEL_BOARD_CONFIG or {}
    local conf = pool[level]
    if conf == nil then
        -- 越界取最高档（平台期）
        local maxLv = -1
        for lv in pairs(pool) do
            if lv > maxLv then maxLv = lv end
        end
        conf = pool[maxLv]
    end
    if conf == nil then return end   -- 无配置，兜底不生成

    self.state.level = level
    -- 从该档方向池随机抽一个方向
    local dir = ""
    if conf.dirPool and #conf.dirPool > 0 then
        dir = conf.dirPool[math.random(#conf.dirPool)]
    end
    -- 复用直传版生成逻辑（rows/cols/kindLimit/direction/layer 全来自配置）
    self:startGameCustom(conf.rows, conf.cols, conf.kindLimit, dir, conf.layer)
end

--- Debug：图案种类数减 1，用当前行列/方向重新生成盘面
function LianLianManager:decreaseKind()
    local cur = self.state.kindLimit or LianLianConst.KIND_MAX
    local newKind = math.max(cur - 1, 1)
    local rows = self.state.customRows or LianLianConst.INTERIOR_ROWS
    local cols = self.state.customCols or LianLianConst.INTERIOR_COLS
    local layerCount = self.state.boardLayer or 1
    local direction = self.state.direction  -- reset 会清空，先保存

    LianLianState.reset(self.state)
    self.state.kindLimit = newKind
    self.state.customRows = rows
    self.state.customCols = cols
    self.state.boardLayer = layerCount
    self:buildAndSetLayers(rows, cols, newKind, layerCount, direction)
    self.state.direction = direction
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
        layerCount = self.state.layerCount,
    })
end

--- 取指定层的运行数据（layer 缺省=1）；多层未初始化时回退到单层兼容视图
--- @return table|nil { grid, rows, cols, direction, item_checked }
function LianLianManager:getLayerData(layer)
    layer = layer or 1
    if self.state.layers and self.state.layers[layer] then
        return self.state.layers[layer]
    end
    -- 兼容：无 layers 时用旧单层字段拼一个
    if layer == 1 then
        self.state._compatLayer = self.state._compatLayer or {}
        local cl = self.state._compatLayer
        cl.grid = self.state.grid
        cl.item_checked = self.state.item_checked
        cl.direction = self.state.direction
        return cl
    end
    return nil
end

--- 层数
function LianLianManager:getLayerCount()
    return self.state.layerCount or 1
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

--- 获取棋盘数据（layer 缺省=1，回退到兼容单层视图）
function LianLianManager:getGrid(layer)
    local ld = self:getLayerData(layer or 1)
    return ld and ld.grid or self.state.grid
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

--- 选中牌面（只作用在 pos.layer 那一层）
--- @param index number 选中序号 (1=第一次, 2=第二次)
--- @param pos table {r, c, layer}
function LianLianManager:checkTile(index, pos)
    local layer = pos.layer or 1
    local ld = self:getLayerData(layer)
    if ld then ld.item_checked[index] = pos end
    EventManager:GetInstance():Broadcast("LianLian_ItemShowChecked", pos)
end

--- 取消某层选中（layer 缺省=1）
function LianLianManager:cancelChecked(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if ld then ld.item_checked = {} end
    EventManager:GetInstance():Broadcast("LianLian_ItemHideChecked", { layer = layer })
end

--- 执行消除判定（只在 layer 层内判定/消除）
--- @param layer number 操作层(缺省=1)
--- @return boolean 是否成功消除
--- @return table|nil 路径数据
function LianLianManager:doClear(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld then return false, nil end
    local grid = ld.grid
    local checked = ld.item_checked
    if #checked < 2 then return false, nil end

    local a = checked[1]
    local b = checked[2]

    -- 检查是否同一位置
    if LianLianItem.isSamePos(a, b) then
        self:cancelChecked(layer)
        return false, nil
    end

    -- 检查是否相同 ID
    if not LianLianItem.isSameId(grid, a, b) then
        self:cancelChecked(layer)
        self:loseHp()
        return false, nil
    end

    -- 检查路径
    local path = LianLianGrid.getClearPath(grid, a, b)
    if not path then
        self:cancelChecked(layer)
        self:loseHp()
        return false, nil
    end

    -- 消除成功
    LianLianItem.del(grid, a)
    LianLianItem.del(grid, b)
    self:cancelChecked(layer)

    -- 生成连线数据
    local pathLine = LianLianGrid.getPathLine(path)

    return true, pathLine
end

--- 消除后的处理（移动 + 胜利判定），只作用在 layer 层
function LianLianManager:afterClear(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld then return false end
    local grid = ld.grid

    -- 移动方向：优先本层锁定方向，回退到全局
    local direction = (ld.direction and ld.direction ~= "") and ld.direction or self:getDirection()
    local moveList = LianLianPlay.getMoveList(grid, direction)

    -- 把牌面 id 按移动列表迁移到新格（数据层生效），再广播给 View 播滑动动画
    if #moveList > 0 then
        LianLianPlay.applyMoveList(grid, moveList)
        EventManager:GetInstance():Broadcast("LianLian_Move", {
            direction = direction,
            moveList = moveList,
            layer = layer,
        })
    end

    -- 胜利条件：所有层都清空（HP 全局共享）
    if self:isAllLayersEmpty() then
        self:win()
        return true
    end

    return false
end

--- 是否所有层都已清空
function LianLianManager:isAllLayersEmpty()
    if self.state.layers then
        for _, ly in pairs(self.state.layers) do
            if not LianLianItem.isAllEmpty(ly.grid) then return false end
        end
        return true
    end
    return LianLianItem.isAllEmpty(self.state.grid)
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

--- 使用提示道具（只提示 layer 层内的一对，pair 带 layer）
function LianLianManager:useTip(layer)
    layer = layer or 1
    self:cancelChecked(layer)
    local ld = self:getLayerData(layer)
    if not ld then return nil end
    local pair = LianLianItem.getPair(ld.grid, function(grid, a, b)
        return LianLianGrid.getClearPath(grid, a, b)
    end)
    if pair then
        -- pair 是 {a, b}，各带 layer 供 View 定位
        if pair[1] then pair[1].layer = layer end
        if pair[2] then pair[2].layer = layer end
        EventManager:GetInstance():Broadcast("LianLian_ItemShowTip", { pair = pair, layer = layer })
    end
    return pair
end

--- 使用洗牌道具（只洗 layer 层）
function LianLianManager:useShuffle(layer)
    layer = layer or 1
    self:cancelChecked(layer)
    local ld = self:getLayerData(layer)
    if not ld then return end
    -- 区域重排：保留剩余元素个数，随机撒回整层区域（空位也可能被占）
    local rows = ld.rows or self.state.customRows or LianLianConst.INTERIOR_ROWS
    local cols = ld.cols or self.state.customCols or LianLianConst.INTERIOR_COLS
    LianLianCard.reshuffleRegion(ld.grid, rows, cols)
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer })
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
