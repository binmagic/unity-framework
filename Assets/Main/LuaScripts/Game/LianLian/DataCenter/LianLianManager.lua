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
local LianLianTheme = require "Game.LianLian.DataCenter.LianLianTheme"

local LianLianManager = BaseClass("LianLianManager", Singleton)

function LianLianManager:__init()
    self.state = LianLianState.New()
    -- 遮挡揭示规则开关：
    --   true  = 需将「上一层」全部消除后，本层才从灰变亮可操作
    --   false = 本层某格四角都无上层遮挡即可从灰变亮（默认，逐格揭示）
    self.fullClearReveal = false
    -- 当前主题 id（元素图池来源）；默认第 1 套主题
    self.themeId = 1
end

--- 取/设当前主题 id
function LianLianManager:getThemeId()
    return self.themeId or 1
end
function LianLianManager:setThemeId(id)
    self.themeId = tonumber(id) or 1
end

--- 取当前主题的元素总数（元素种类默认值 & 随机取用的池上界）
function LianLianManager:getThemeElementCount()
    local n = LianLianTheme.GetElementCount(self:getThemeId())
    n = math.floor(tonumber(n) or LianLianConst.KIND_MAX)
    -- 不超过图案 id 上界
    return math.min(math.max(n, 1), LianLianConst.KIND_MAX)
end

--- 取「是否需整层消除才揭示下层」开关
function LianLianManager:getFullClearReveal()
    return self.fullClearReveal and true or false
end

--- 设「是否需整层消除才揭示下层」开关；变更即广播，供 View 实时刷新遮挡态
function LianLianManager:setFullClearReveal(v)
    v = v and true or false
    if self.fullClearReveal == v then return end
    self.fullClearReveal = v
    EventManager:GetInstance():Broadcast("LianLian_OcclusionRuleChanged", { fullClearReveal = v })
end

--- 开始新游戏
--- @param part number 关卡号
function LianLianManager:startGame(part)
    self.state.part = part or 1
    LianLianState.reset(self.state)
    LianLianPlay.initData(self.state)
    -- 按 level 随机抽本盘移动方向并锁定；教学关 part 1 强制无移动
    self.state.direction = self:rollBoardDirection()

    -- 正式/新手关也走「单层」的 layers 结构，统一玩法代码路径（避免 compat 别名 bug）
    self.state.layers = {
        [1] = {
            grid = self.state.grid,
            rows = LianLianConst.INTERIOR_ROWS,
            cols = LianLianConst.INTERIOR_COLS,
            direction = self.state.direction,
            item_checked = self.state.item_checked,
        },
    }
    self.state.layerCount = 1

    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    self:dumpBoardLog(string.format("startGame part=%d direction=%s", self.state.part, tostring(self.state.direction)))

    -- 广播游戏开始事件
    EventManager:GetInstance():Broadcast("LianLian_GameStart", {
        part = self.state.part,
        direction = self.state.direction,
        layerCount = self.state.layerCount,
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
--- @param kindCount number 每层使用的元素种类数；缺省=当前主题元素个数；随机取用哪些元素
--- @param direction string 移动方向("" / up / down / left / right / divide_* / flock_*)
--- @param layer number 每格叠加层数(默认1=单层)
function LianLianManager:startGameCustom(rows, cols, kindCount, direction, layer)
    -- 校验并 clamp 参数（盘面生成规则在 Manager 侧统一管理）
    rows = math.floor(tonumber(rows) or LianLianConst.INTERIOR_ROWS)
    cols = math.floor(tonumber(cols) or LianLianConst.INTERIOR_COLS)
    local layerCount = math.max(math.floor(tonumber(layer) or 1), 1)
    rows = math.min(math.max(rows, 1), LianLianConst.INTERIOR_ROWS)
    cols = math.min(math.max(cols, 1), LianLianConst.INTERIOR_COLS)
    -- 元素池上界 = 当前主题元素个数；种类数缺省用满整池，不超过池上界
    local poolMax = self:getThemeElementCount()
    kindCount = math.floor(tonumber(kindCount) or poolMax)
    kindCount = math.min(math.max(kindCount, 1), poolMax)

    LianLianState.reset(self.state)
    -- 记录本盘参数，供 decreaseKind 等重生复用
    self.state.customRows = rows
    self.state.customCols = cols
    self.state.kindLimit = kindCount
    self.state.boardLayer = layerCount

    self:buildAndSetLayers(rows, cols, kindCount, layerCount, direction or "", poolMax)
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
--- @param poolMax number 元素 id 池上界（缺省=当前主题元素个数）
function LianLianManager:buildAndSetLayers(rows, cols, kindCount, layerCount, direction, poolMax)
    poolMax = poolMax or self:getThemeElementCount()
    local layers = LianLianPlay.buildLayers(rows, cols, kindCount, layerCount, poolMax)
    local count = 0
    for _, ly in pairs(layers) do
        ly.direction = direction or ""
        count = count + 1
    end
    self.state.layers = layers
    self.state.layerCount = count
    -- 兼容旧路径：state.grid 指向底层 grid（getBoardSize/getBoard 回退/单层 View）
    self.state.grid = layers[1] and layers[1].grid or {}

    -- 打印生成参数与各层结果，便于调试
    self:dumpBoardLog(string.format("buildLayers rows=%d cols=%d kindCount=%s layerCount=%d poolMax=%d dir=%s themeId=%d",
        rows, cols, tostring(kindCount), count, poolMax, tostring(direction or ""), self:getThemeId()))
end

--- 打印当前盘面各层的生成结果（尺寸/牌数/实际用到的元素种类及分布）
--- @param tag string 触发来源标签（如 buildLayers / decreaseKind / reshuffle）
function LianLianManager:dumpBoardLog(tag)
    local layers = self.state.layers
    if not layers then return end
    print(string.format("[LianLian][盘面] %s", tostring(tag)))
    -- 按层序输出
    local maxL = self.state.layerCount or 1
    for L = 1, maxL do
        local ly = layers[L]
        if ly then
            local cnt = {}          -- id -> 个数
            local total = 0
            for _, cell in pairs(ly.grid) do
                if cell.id and cell.id ~= 0 then
                    cnt[cell.id] = (cnt[cell.id] or 0) + 1
                    total = total + 1
                end
            end
            -- 组装「id:个数」列表（按 id 升序）
            local ids = {}
            for id in pairs(cnt) do ids[#ids + 1] = id end
            table.sort(ids)
            local parts = {}
            for _, id in ipairs(ids) do
                parts[#parts + 1] = string.format("%d×%d", id, cnt[id])
            end
            print(string.format("  [层%d] size=%dx%d kindCount=%s poolMax=%s 剩余牌=%d 种类=%d 分布{%s}",
                L, ly.rows or -1, ly.cols or -1,
                tostring(ly.kindCount), tostring(ly.poolMax),
                total, #ids, table.concat(parts, ",")))
        end
    end
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

--- Debug：图案种类数减 1，只作用「当前可操作层」（顶层）。
--- 不重新生成盘面：保留所有元素的位置和总数，只把「某一种」元素全部并入「另一种」，
--- 从而种类数 -1。因每种本就是偶数个，合并后仍为偶数，成对性不破坏。
--- 只剩 1 种时不再减少。
--- @param layer number 可选，指定层；缺省=顶层(可操作层)
function LianLianManager:decreaseKind(layer)
    layer = layer or self:getLayerCount() or 1
    local ld = self:getLayerData(layer)
    if not ld then return end

    -- 统计当前盘面实际存在的元素种类
    local kinds = {}          -- id -> true
    local idList = {}
    for _, cell in pairs(ld.grid) do
        if cell.id and cell.id ~= 0 and not kinds[cell.id] then
            kinds[cell.id] = true
            idList[#idList + 1] = cell.id
        end
    end
    -- 只剩 1 种（或空）时不再减少
    if #idList <= 1 then return end

    -- 随机挑一个「源种类」并入随机的「目标种类」（两者不同）
    local si = math.random(#idList)
    local srcId = idList[si]
    local ti = math.random(#idList - 1)
    if ti >= si then ti = ti + 1 end   -- 跳过 src，保证目标不同
    local dstId = idList[ti]

    -- 把源种类的所有格子改成目标 id：位置/总数不变，种类 -1
    self:cancelChecked(layer)
    for _, cell in pairs(ld.grid) do
        if cell.id == srcId then
            cell.id = dstId
        end
    end
    -- 更新记录的种类数（若有）
    if ld.kindCount then ld.kindCount = math.max(ld.kindCount - 1, 1) end
    ld.item_checked = {}
    if layer == 1 then self.state.grid = ld.grid end

    self:dumpBoardLog(string.format("decreaseKind layer=%d 合并 %d→%d 剩余种类=%d", layer, srcId, dstId, #idList - 1))

    -- 复用洗牌事件让 View 整体重刷该层（含遮挡）
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer })
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

    -- 死局检测：本层还有牌但已无可连消的对子 → 自动重排该层，避免卡死留下无法消除的元素
    if not LianLianItem.isAllEmpty(grid) and not self:hasClearablePair(layer) then
        self:autoReshuffle(layer)
    end

    return false
end

--- 本层是否还存在「可连线消除」的对子
function LianLianManager:hasClearablePair(layer)
    local ld = self:getLayerData(layer or 1)
    if not ld then return false end
    local pair = LianLianItem.getPair(ld.grid, function(grid, a, b)
        return LianLianGrid.getClearPath(grid, a, b)
    end)
    return pair ~= nil
end

--- 死局时自动重排本层（保留剩余元素个数，随机撒回），直到出现可消对子（有限次兜底）
function LianLianManager:autoReshuffle(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld then return end
    local rows = ld.rows or self.state.customRows or LianLianConst.INTERIOR_ROWS
    local cols = ld.cols or self.state.customCols or LianLianConst.INTERIOR_COLS
    for _ = 1, 20 do
        LianLianCard.reshuffleRegion(ld.grid, rows, cols)
        if self:hasClearablePair(layer) then break end
    end
    if layer == 1 then self.state.grid = ld.grid end
    self:dumpBoardLog(string.format("autoReshuffle(死局重排) layer=%d", layer))
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer })
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
