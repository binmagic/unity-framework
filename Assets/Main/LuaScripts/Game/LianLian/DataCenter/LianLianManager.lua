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
local LianLianSpecial = require "Game.LianLian.Special.LianLianSpecialRegistry"
require "Game.LianLian.Special.LianLianSpecialTypes"   -- 触发各特殊元素类型自注册
local LianLianModifier = require "Game.LianLian.Special.LianLianModifierRegistry"
require "Game.LianLian.Special.LianLianModifierTypes"  -- 触发各格子修饰器自注册
local LianLianConsequence = require "Game.LianLian.Special.LianLianConsequenceRegistry"
require "Game.LianLian.Special.LianLianConsequenceTypes" -- 触发各消除后果自注册

local LianLianManager = BaseClass("LianLianManager", Singleton)

function LianLianManager:__init()
    self.state = LianLianState.New()
    -- 遮挡揭示规则开关：
    --   true  = 需将「上一层」全部消除后，本层才从灰变亮可操作
    --   false = 本层某格四角都无上层遮挡即可从灰变亮（默认，逐格揭示）
    self.fullClearReveal = false
    -- 当前主题 id（元素图池来源）；默认第 1 套主题
    self.themeId = 1
    -- 死局自动重排开关：默认关（调试时保持真实盘面，不打乱）；正式需要时可置 true
    self.autoReshuffleEnabled = false
    -- 保证可解开关：默认开，生成时验证盘面可解（不可解则重洗重试）
    self.ensureSolvable = true
    -- 无限生成开关：默认关。开启后全清不弹结算，用当前关卡设定重新生成盘面
    self.infiniteRegen = false
    -- 棋盘格线显示开关：默认关。开启后为棋盘画红色细网格线（调试用）
    self.showGridLine = false
    -- 扣血开关：默认开。关闭后配对失败不扣血、不触发失败结算（调试用）
    self.hpEnabled = true
    -- 本关启用的 C 类消除后果集合 { [ctype]=true }；由关卡配置注入，缺省空=不启用任何后果
    self._enabledConsequences = {}
end

--- 取/设「扣血」开关（关闭后 loseHp 空转，便于调试不被踢到复活/失败页）
function LianLianManager:getHpEnabled()
    return self.hpEnabled ~= false
end
function LianLianManager:setHpEnabled(v)
    self.hpEnabled = v and true or false
end

--- 取/设「棋盘格线显示」开关；变更即广播，供 PlayView 实时刷新
function LianLianManager:getShowGridLine()
    return self.showGridLine and true or false
end
function LianLianManager:setShowGridLine(v)
    v = v and true or false
    if self.showGridLine == v then return end
    self.showGridLine = v
    EventManager:GetInstance():Broadcast("LianLian_GridLineChanged", { on = v })
end

--- 取/设「保证可解」开关（生成期读取，改后下次 Gen 生效）
function LianLianManager:getEnsureSolvable()
    return self.ensureSolvable and true or false
end
function LianLianManager:setEnsureSolvable(v)
    self.ensureSolvable = v and true or false
end

--- 取/设「无限生成」开关：开启后全清不弹结算，用当前关卡设定重新生成
function LianLianManager:getInfiniteRegen()
    return self.infiniteRegen and true or false
end
function LianLianManager:setInfiniteRegen(v)
    self.infiniteRegen = v and true or false
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
    -- Debug 直开默认不启用任何 C 类后果（保持纯净盘面）；startGameByLevel 会按关卡配置再注入
    self:setEnabledConsequences(nil)
    -- 记录本盘参数，供 decreaseKind 等重生复用
    self.state.customRows = rows
    self.state.customCols = cols
    self.state.kindLimit = kindCount
    self.state.boardLayer = layerCount

    self:buildAndSetLayers(rows, cols, kindCount, layerCount, direction or "", poolMax)
    self.state.direction = direction or ""
    self.state.isPlaying = true
    self.state.startTime = os.time() * 1000

    -- 开局重置已启用后果的内部状态（Debug 直开：启用集为空则空转）
    self:fireGameStartConsequences(1)

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
    local layers = LianLianPlay.buildLayers(rows, cols, kindCount, layerCount, poolMax, self:getEnsureSolvable())
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
    -- 注入本关启用的 C 类后果（须在 startGameCustom 之后，因其会清空启用集）
    self:setEnabledConsequences(conf.consequences)
    -- 启用集变了，重新触发开局重置（限步初始化步数等）
    self:fireGameStartConsequences(1)
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

--- 当前「可操作层」：从顶层往下找第一个还有牌(未清空)的层。
--- 顶层消完后，可操作层自动下移到下一层。全空则返回 1。
function LianLianManager:getTopActiveLayer()
    local count = self.state.layerCount or 1
    for L = count, 1, -1 do
        local ld = self:getLayerData(L)
        if ld and ld.grid and not LianLianItem.isAllEmpty(ld.grid) then
            return L
        end
    end
    return 1
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
    -- 记录最近点击格，供 Debug「把选中格改成特殊元素」定位
    self._lastClickPos = { r = pos.r, c = pos.c, layer = layer }
    EventManager:GetInstance():Broadcast("LianLian_ItemShowChecked", pos)
end

--- Debug：把「最近点击的格子」设为某特殊类型（未点过则无效果）
--- @param stype string|nil 特殊类型；nil=还原普通
function LianLianManager:setLastClickSpecial(stype)
    local p = self._lastClickPos
    if not p then return end
    self:setCellSpecial(p.layer, p.r, p.c, stype)
end

--- 取消某层选中（layer 缺省=1）
function LianLianManager:cancelChecked(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if ld then ld.item_checked = {} end
    EventManager:GetInstance():Broadcast("LianLian_ItemHideChecked", { layer = layer })
end

-- ============ 特殊元素辅助（框架接入点） ============

--- 取格子的特殊类型（nil=普通）
function LianLianManager:getCellSpecial(grid, pos)
    local cell = grid[pos.r .. "_" .. pos.c]
    return cell and cell.specialType or nil
end

--- 清除格子的特殊类型（消除后与 id 一同清空）
function LianLianManager:clearCellSpecial(grid, pos)
    local cell = grid[pos.r .. "_" .. pos.c]
    if cell then cell.specialType = nil end
end

--- 特殊配对钩子：任一格是特殊元素且其 canMatch 有实现，则用它裁决；否则返回 nil（用默认 isSameId）
function LianLianManager:specialCanMatch(grid, a, b)
    local sa = self:getCellSpecial(grid, a)
    local sb = self:getCellSpecial(grid, b)
    for _, st in ipairs({ sa, sb }) do
        local def = LianLianSpecial.get(st)
        if def and def.canMatch then
            local r = def.canMatch(grid, a, b)
            if r ~= nil then return r end
        end
    end
    return nil
end

--- 某格特殊元素被消除时触发其 onCleared（连锁效果；def 内可再调 Manager 追加消除）
function LianLianManager:fireSpecialCleared(layer, pos, stype)
    local def = LianLianSpecial.get(stype)
    if def and def.onCleared then
        def.onCleared(self, layer, pos, {})
    end
end

--- 设置某格的特殊类型（Debug 改元素用），改后广播刷新该层显示
--- @param stype string|nil 特殊类型，nil=还原普通牌
function LianLianManager:setCellSpecial(layer, r, c, stype)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    local cell = ld.grid[r .. "_" .. c]
    if not cell or cell.id == 0 then return end   -- 只改有牌的格子

    if stype then
        -- 设为特殊元素：cell.id 换成该类型专属 id（先存原图案 id 供还原）
        local def = LianLianSpecial.get(stype)
        print(string.format("[LianLian][GM] setCellSpecial (%d,%d) stype=%s def=%s def.id=%s 改前id=%s",
            r, c, tostring(stype), tostring(def), def and tostring(def.id) or "nil", tostring(cell.id)))
        if def and def.id then
            cell._originId = cell._originId or cell.id
            cell.id = def.id
        end
        cell.specialType = stype
        print(string.format("[LianLian][GM] setCellSpecial 改后 cell.id=%s specialType=%s",
            tostring(cell.id), tostring(cell.specialType)))
    else
        -- 还原普通：id 回到原图案，清除特殊标记
        if cell._originId then
            cell.id = cell._originId
            cell._originId = nil
        end
        cell.specialType = nil
    end
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer or 1 })
end

-- ============ 格子修饰器（藤蔓/冰冻/石头…：持续状态，挡连线/禁选/相邻消除响应） ============

--- 设置/清除某格的某个修饰器（state=nil 清除；缺省用 def.defaultState 或 true）
--- @param mtype string 修饰器类型（vine/ice/…）
--- @param state any|nil 状态；nil=清除该修饰器
function LianLianManager:setCellModifier(layer, r, c, mtype, state)
    local ld = self:getLayerData(layer or 1)
    if not ld or not mtype then return end
    local cell = ld.grid[r .. "_" .. c]
    if not cell then return end
    if state == nil then
        -- 清除
        if cell.mods then
            cell.mods[mtype] = nil
            if next(cell.mods) == nil then cell.mods = nil end
        end
    else
        cell.mods = cell.mods or {}
        cell.mods[mtype] = state
    end
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer or 1 })
end

--- Debug：给「最近点击的格」切换某修饰器（有则清、无则加 defaultState）
function LianLianManager:toggleLastClickModifier(mtype)
    local p = self._lastClickPos
    if not p or not mtype then return end
    local ld = self:getLayerData(p.layer or 1)
    if not ld then return end
    local cell = ld.grid[p.r .. "_" .. p.c]
    if not cell then return end
    local has = cell.mods and cell.mods[mtype] ~= nil
    if has then
        self:setCellModifier(p.layer, p.r, p.c, mtype, nil)
    else
        local def = LianLianModifier.get(mtype)
        local st = def and def.defaultState
        if st == nil then st = true end
        self:setCellModifier(p.layer, p.r, p.c, mtype, st)
    end
end

--- 相邻消除通知：传入本次被消除的格，通知其上下左右相邻格上的每个修饰器
--- onNeighborCleared（返回 nil=解除；否则更新为新 state），供藤蔓断裂/冰冻递减等。
--- @param cells table { {r,c}, ... }
function LianLianManager:notifyNeighborsCleared(layer, cells)
    local ld = self:getLayerData(layer or 1)
    if not ld or not cells then return end
    local grid = ld.grid
    local DIRS = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
    local changed = false
    for _, pos in ipairs(cells) do
        for _, d in ipairs(DIRS) do
            local nb = grid[(pos.r + d[1]) .. "_" .. (pos.c + d[2])]
            if nb and nb.mods then
                for mtype, state in pairs(nb.mods) do
                    local def = LianLianModifier.get(mtype)
                    if def and def.onNeighborCleared then
                        local newState = def.onNeighborCleared(self, layer, { r = nb.r, c = nb.c }, state)
                        if newState ~= state then
                            nb.mods[mtype] = newState   -- nil=解除；数字/true=更新
                            changed = true
                        end
                    end
                end
                if next(nb.mods) == nil then nb.mods = nil end
            end
        end
    end
    if changed then
        EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer or 1 })
    end
end

-- ============ 消除后果（C 类：每次消除后的全局规则，如稀有度掉落/连击） ============

--- 每次成功消除后调用：累计计数并广播给所有已注册的消除后果
--- @param cells table 本次被消除的格 { a, b }
function LianLianManager:fireAfterMatch(layer, cells)
    layer = layer or 1
    self._matchCount = self._matchCount or {}
    self._matchCount[layer] = (self._matchCount[layer] or 0) + 1
    local count = self._matchCount[layer]
    local ctx = {
        cells = cells,
        matchCount = count,
        comboCount = nil,   -- 预留：连击数
        -- 通用周期助手：每 n 对触发一次（消除各后果里重复的取模判断）
        everyN = function(n) return n and n > 0 and count > 0 and count % n == 0 end,
    }
    for _, def in ipairs(LianLianConsequence.all()) do
        -- 只触发「本关启用列表」里的后果（方案 B：关卡准入）
        if self._enabledConsequences[def.type] and def.onAfterMatch then
            def.onAfterMatch(self, layer, ctx)
        end
    end
end

--- 开局：遍历本关启用的后果调 onGameStart，重置其内部状态（限步重置步数/潮汐清计数）
function LianLianManager:fireGameStartConsequences(layer)
    layer = layer or 1
    self._matchCount = self._matchCount or {}
    self._matchCount[layer] = 0
    for _, def in ipairs(LianLianConsequence.all()) do
        if self._enabledConsequences[def.type] and def.onGameStart then
            def.onGameStart(self, layer)
        end
    end
end

--- 设置本关启用的 C 类后果列表（数组 → set）；nil/空=不启用任何后果
--- @param list table|nil 形如 { "rare_drop", ... }
function LianLianManager:setEnabledConsequences(list)
    local set = {}
    if list then
        for _, ctype in ipairs(list) do set[ctype] = true end
    end
    self._enabledConsequences = set
end

--- 读某后果是否启用（Debug 用）
function LianLianManager:isConsequenceEnabled(ctype)
    return ctype ~= nil and self._enabledConsequences[ctype] == true
end

--- 开/关某个后果（Debug 用，不影响其它已启用项）
function LianLianManager:setConsequenceEnabled(ctype, on)
    if ctype == nil then return end
    self._enabledConsequences[ctype] = on and true or nil
end

-- ---- 限步目标服务（供 StepLimit 后果用）----

--- 初始化步数目标（开局重置）
function LianLianManager:initStepGoal(limit)
    self.state.stepLimit = math.max(math.floor(tonumber(limit) or 0), 0)
    self.state.stepUsed = 0
    EventManager:GetInstance():Broadcast("LianLian_StepUpdate", {
        left = self.state.stepLimit, limit = self.state.stepLimit,
    })
end

--- 消耗步数并广播剩余；返回剩余步数
function LianLianManager:consumeStep(k)
    if not self.state.stepLimit then return nil end
    self.state.stepUsed = (self.state.stepUsed or 0) + (k or 1)
    local left = self:getStepLeft()
    EventManager:GetInstance():Broadcast("LianLian_StepUpdate", {
        left = left, limit = self.state.stepLimit,
    })
    return left
end

--- 剩余步数
function LianLianManager:getStepLeft()
    if not self.state.stepLimit then return nil end
    return math.max(self.state.stepLimit - (self.state.stepUsed or 0), 0)
end

-- ---- 潮汐服务（供 Tide 后果用）----

--- 盘面整体下移 n 行，顶部补 n 行成对新牌；溢出底边的牌丢弃。
--- 搬运整格内容（id/specialType/mods），特殊元素与修饰器随之移动。
function LianLianManager:tideShiftDown(layer, n)
    n = math.max(math.floor(tonumber(n) or 1), 1)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    local grid = ld.grid
    local W = LianLianConst.GRID_WIDTH
    local H = LianLianConst.GRID_HEIGHT

    -- 从底部往上搬：新行 r 的内容 = 原行 (r-n) 的内容
    for r = H - 1, 0, -1 do
        for c = 0, W - 1 do
            local dst = grid[r .. "_" .. c]
            if dst then
                local srcR = r - n
                if srcR >= 0 then
                    local src = grid[srcR .. "_" .. c]
                    dst.id = src and src.id or 0
                    dst.specialType = src and src.specialType or nil
                    dst._originId = src and src._originId or nil
                    dst.mods = src and src.mods or nil
                else
                    -- 顶部 n 行：清空，稍后补新牌
                    dst.id = 0
                    dst.specialType = nil
                    dst._originId = nil
                    dst.mods = nil
                end
            end
        end
    end

    -- 顶部 n 行补成对新牌（用本层现存种类，保证可配对）
    self:fillTopRows(layer, n)

    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer or 1 })
    self:checkEndAfterBatchClear(layer or 1)
end

--- 顶部 n 行填成对新牌（内部，供 tideShiftDown 用）
function LianLianManager:fillTopRows(layer, n)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    local grid = ld.grid
    local W = LianLianConst.GRID_WIDTH
    -- 用本层现存普通种类；没有则用 1..kindLimit
    local kinds = self:getKinds(layer)
    if #kinds == 0 then
        local km = self.state.kindLimit or LianLianConst.KIND_MAX
        for i = 1, km do kinds[i] = i end
    end
    -- 收集顶部 n 行的内部可填格（避开边框列 0 与 W-1）
    local slots = {}
    for r = 0, n - 1 do
        for c = 1, W - 2 do
            slots[#slots + 1] = grid[r .. "_" .. c]
        end
    end
    -- 成对生成 id 列表（偶数个）
    local pairCount = math.floor(#slots / 2)
    local ids = {}
    for i = 1, pairCount do
        local id = kinds[((i - 1) % #kinds) + 1]
        ids[#ids + 1] = id
        ids[#ids + 1] = id
    end
    for i = #ids, 2, -1 do
        local j = math.random(i)
        ids[i], ids[j] = ids[j], ids[i]
    end
    for _, cell in ipairs(slots) do
        cell.id = table.remove(ids) or 0
        cell.specialType = nil
        cell._originId = nil
        cell.mods = nil
    end
end

--- 把指定普通格刷成道具（特殊元素）；已是特殊/空格则跳过。供掉落等后果调用。
function LianLianManager:dropPropAt(layer, r, c, stype)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    local cell = ld.grid[r .. "_" .. c]
    if not cell or cell.id == 0 then return end       -- 只刷有牌的普通格
    if cell.specialType then return end               -- 已是特殊元素则跳过
    self:setCellSpecial(layer, r, c, stype)           -- 复用：换专属 id + specialType + 刷新
end

--- 随机挑本层若干个「普通元素格」（不成对、不含特殊/空格），供掉落等按格取用。
--- 与 pickRandomCells（按对选）不同：这里纯随机取 N 个，不保证成对。
function LianLianManager:pickCellsLoose(layer, count, excludeSet)
    local ld = self:getLayerData(layer or 1)
    if not ld then return {} end
    local pool = {}
    for _, cell in pairs(ld.grid) do
        if cell.id and cell.id ~= 0 and cell.id < LianLianConst.SPECIAL_ID_BASE and not cell.specialType then
            local key = cell.r .. "_" .. cell.c
            if not (excludeSet and excludeSet[key]) then
                pool[#pool + 1] = { r = cell.r, c = cell.c }
            end
        end
    end
    for i = #pool, 2, -1 do
        local j = math.random(i)
        pool[i], pool[j] = pool[j], pool[i]
    end
    local n = math.min(count or 0, #pool)
    local picked = {}
    for i = 1, n do picked[i] = pool[i] end
    return picked
end

-- ============ 通用盘面原子操作（与具体特殊元素无关，供任意元素/道具复用） ============

--- 查询本层现存的所有图案种类 id（去重）
--- @param layer number 作用层
--- @return table 数组 { id, id, ... }
function LianLianManager:getKinds(layer)
    local ld = self:getLayerData(layer or 1)
    if not ld then return {} end
    -- 只统计「普通图案」种类（id < SPECIAL_ID_BASE）；特殊元素 id 不算普通种类，
    -- 避免火箭等随机选类时把特殊元素当普通类误消。
    local seen, kinds = {}, {}
    for _, cell in pairs(ld.grid) do
        if cell.id and cell.id ~= 0 and cell.id < LianLianConst.SPECIAL_ID_BASE and not seen[cell.id] then
            seen[cell.id] = true
            kinds[#kinds + 1] = cell.id
        end
    end
    return kinds
end

--- 清除本层指定的「若干类」元素（中性操作，不关心调用者是谁）：
--- 把这些 id 的所有格子清空(id=0/specialType=nil)，刷新显示并做收尾判定(胜利/死局)。
--- @param layer number 作用层
--- @param kindList table 要清除的 id 列表（数组或以 id 为 key 的集合皆可）
--- @return table 被清除的格子坐标 { {r=,c=}, ... }（供调用方做特效定位）
function LianLianManager:clearKinds(layer, kindList)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld or not kindList then return {} end
    local grid = ld.grid

    -- 归一化成 id->true 集合（兼容传数组或集合）
    local chosen = {}
    if kindList[1] ~= nil then
        for _, id in ipairs(kindList) do chosen[id] = true end
    else
        for id, v in pairs(kindList) do if v then chosen[id] = true end end
    end

    -- 清除并收集坐标
    local cleared = {}
    for _, cell in pairs(grid) do
        if cell.id and cell.id ~= 0 and chosen[cell.id] then
            cleared[#cleared + 1] = { r = cell.r, c = cell.c }
            cell.id = 0
            cell.specialType = nil
        end
    end

    -- 刷新显示 + 收尾判定（胜利/死局）
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer })
    self:checkEndAfterBatchClear(layer)
    return cleared
end

--- 中性操作：随机挑本层若干个「普通元素」格子（不含特殊元素、不含空格）
--- @param layer number 作用层
--- @param count number 要挑几个格
--- @param excludeSet table|nil 可选，排除的格 key 集合（如触发火箭自身的格）
--- @return table 数组 { {r=,c=}, ... }（不足 count 则返回全部）
function LianLianManager:pickRandomCells(layer, count, excludeSet)
    local ld = self:getLayerData(layer or 1)
    if not ld then return {} end

    -- 按普通 id 分组候选格（排除特殊 id/空格/excludeSet）
    local byId = {}
    for _, cell in pairs(ld.grid) do
        if cell.id and cell.id ~= 0 and cell.id < LianLianConst.SPECIAL_ID_BASE then
            local key = cell.r .. "_" .. cell.c
            if not (excludeSet and excludeSet[key]) then
                byId[cell.id] = byId[cell.id] or {}
                local list = byId[cell.id]
                list[#list + 1] = { r = cell.r, c = cell.c }
            end
        end
    end

    -- 每个 id 内组成「整对」：同 id 两张即可配对；奇数张丢掉多的 1 张
    local pairs_ = {}   -- 每个元素是一对 { {r,c}, {r,c} }
    for _, list in pairs(byId) do
        -- 组内打乱，保证多于一对时随机取哪两张
        for i = #list, 2, -1 do
            local j = math.random(i)
            list[i], list[j] = list[j], list[i]
        end
        local pairNum = math.floor(#list / 2)
        for p = 1, pairNum do
            pairs_[#pairs_ + 1] = { list[p * 2 - 1], list[p * 2] }
        end
    end

    -- 打乱所有对，取前 floor(count/2) 对，展平成格列表（格数为偶数、≤count）
    for i = #pairs_, 2, -1 do
        local j = math.random(i)
        pairs_[i], pairs_[j] = pairs_[j], pairs_[i]
    end
    local wantPairs = math.min(math.floor((count or 0) / 2), #pairs_)
    local picked = {}
    for p = 1, wantPairs do
        picked[#picked + 1] = pairs_[p][1]
        picked[#picked + 1] = pairs_[p][2]
    end
    return picked
end

--- 中性操作：清除「指定的具体格子」（不是按类），刷新显示 + 收尾判定。
--- 供火箭等"逐格命中"的特殊元素在命中时调用（可单格调用，实现逐个爆炸消除）。
--- @param layer number 作用层
--- @param cells table 要清除的格 { {r=,c=}, ... }（单格也用数组包一层）
function LianLianManager:clearCells(layer, cells)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld or not cells then return end
    local grid = ld.grid
    for _, pos in ipairs(cells) do
        local cell = grid[pos.r .. "_" .. pos.c]
        if cell and cell.id ~= 0 then
            cell.id = 0
            cell.specialType = nil
        end
    end
    EventManager:GetInstance():Broadcast("LianLian_ItemUpdate", { shuffle = true, layer = layer })
    self:checkEndAfterBatchClear(layer)
end

--- 批量清除后的统一收尾判定（胜利/死局），供 clearKinds/clearCells 复用
function LianLianManager:checkEndAfterBatchClear(layer)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    if self:isAllLayersEmpty() then
        self:win()
    elseif not LianLianItem.isAllEmpty(ld.grid) and not self:hasClearablePair(layer or 1) then
        if self.autoReshuffleEnabled then self:autoReshuffle(layer or 1) end
    end
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

    -- 修饰器拦截：被藤蔓/冰冻等标记为不可选的格，视为无效点击（不扣血）
    local ca = grid[a.r .. "_" .. a.c]
    local cb = grid[b.r .. "_" .. b.c]
    if LianLianModifier.cellBlocksSelect(ca) or LianLianModifier.cellBlocksSelect(cb) then
        self:cancelChecked(layer)
        return false, nil
    end

    -- 配对判定：特殊元素可用 canMatch 钩子覆盖默认 isSameId（返回 nil=用默认）
    print(string.format("[LianLian][配对] A(%d,%d)id=%s special=%s  B(%d,%d)id=%s special=%s",
        a.r, a.c, tostring(grid[a.r.."_"..a.c] and grid[a.r.."_"..a.c].id),
        tostring(grid[a.r.."_"..a.c] and grid[a.r.."_"..a.c].specialType),
        b.r, b.c, tostring(grid[b.r.."_"..b.c] and grid[b.r.."_"..b.c].id),
        tostring(grid[b.r.."_"..b.c] and grid[b.r.."_"..b.c].specialType)))
    local matched = self:specialCanMatch(grid, a, b)
    if matched == nil then
        matched = LianLianItem.isSameId(grid, a, b)
    end
    if not matched then
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

    -- 消除前先记下两格的特殊类型（del 后 grid 上取不到），供 onCleared 连锁触发
    local specialA = self:getCellSpecial(grid, a)
    local specialB = self:getCellSpecial(grid, b)

    -- 消除成功
    LianLianItem.del(grid, a)
    LianLianItem.del(grid, b)
    self:clearCellSpecial(grid, a)
    self:clearCellSpecial(grid, b)
    self:cancelChecked(layer)

    -- 特殊元素被消除的连锁效果（炸周围/解冻邻格…，可能追加消除）
    -- 一对牌若是「相同特殊类型」（如两个火箭配对），整体只触发一次 onCleared，避免效果翻倍；
    -- 类型不同则各触发各的。
    if specialA and specialA == specialB then
        self:fireSpecialCleared(layer, a, specialA)
    else
        self:fireSpecialCleared(layer, a, specialA)
        self:fireSpecialCleared(layer, b, specialB)
    end

    -- 相邻消除通知：本次消除的两格，通知相邻格修饰器（藤蔓断裂/冰冻递减等）
    self:notifyNeighborsCleared(layer, { a, b })

    -- 消除后果（C 类：稀有度掉落/连击等，与具体元素无关）
    self:fireAfterMatch(layer, { a, b })

    -- 消除后打印本层棋盘元素信息，便于调试
    self:dumpBoardElements(layer, string.format("消除(%d,%d)+(%d,%d)", a.r, a.c, b.r, b.c))

    -- 生成连线数据
    local pathLine = LianLianGrid.getPathLine(path)

    return true, pathLine
end

--- 打印某层棋盘上现存元素信息（按 行_列=id[special] 列出 + 种类统计），调试用
function LianLianManager:dumpBoardElements(layer, tag)
    local ld = self:getLayerData(layer or 1)
    if not ld then return end
    local grid = ld.grid
    local cells = {}          -- 按 r,c 排序输出
    local kindCnt = {}        -- id -> 个数
    local total = 0
    for _, cell in pairs(grid) do
        if cell.id and cell.id ~= 0 then
            local mark = cell.specialType and ("[" .. tostring(cell.specialType) .. "]") or ""
            cells[#cells + 1] = { r = cell.r, c = cell.c, s = string.format("%d_%d=%d%s", cell.r, cell.c, cell.id, mark) }
            kindCnt[cell.id] = (kindCnt[cell.id] or 0) + 1
            total = total + 1
        end
    end
    table.sort(cells, function(x, y)
        if x.r ~= y.r then return x.r < y.r end
        return x.c < y.c
    end)
    local parts = {}
    for _, c in ipairs(cells) do parts[#parts + 1] = c.s end
    -- 种类统计（按 id 升序）
    local ids = {}
    for id in pairs(kindCnt) do ids[#ids + 1] = id end
    table.sort(ids)
    local kparts = {}
    for _, id in ipairs(ids) do kparts[#kparts + 1] = string.format("%d×%d", id, kindCnt[id]) end

    print(string.format("[LianLian][盘面元素] %s layer=%d 剩余=%d 种类=%d 分布{%s}",
        tostring(tag), layer or 1, total, #ids, table.concat(kparts, ",")))
    print(string.format("[LianLian][盘面元素]   格子: %s", table.concat(parts, " ")))
end

--- 消除后的处理（移动 + 胜利判定），只作用在 layer 层
function LianLianManager:afterClear(layer)
    layer = layer or 1
    local ld = self:getLayerData(layer)
    if not ld then return false end
    local grid = ld.grid

    -- 移动方向：优先本层锁定方向，回退到全局
    local direction = (ld.direction and ld.direction ~= "") and ld.direction or self:getDirection()
    -- 本层边界：让重力/移动只在本层 rows×cols 内进行，避免多层时牌滑出本层区域
    local bounds = { rows = ld.rows, cols = ld.cols }
    local moveList = LianLianPlay.getMoveList(grid, direction, bounds)

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

    -- 死局检测：本层还有牌但已无可连消的对子。
    -- autoReshuffleEnabled 关（默认）时只打印、不重排，保持真实盘面便于调试。
    if not LianLianItem.isAllEmpty(grid) and not self:hasClearablePair(layer) then
        if self.autoReshuffleEnabled then
            print(string.format("[LianLian][盘面] 死局检测触发 → autoReshuffle layer=%d", layer))
            self:autoReshuffle(layer)
        else
            print(string.format("[LianLian][盘面] 死局检测：layer=%d 无可连对子（自动重排已关，保持原盘面）", layer))
        end
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
    -- 扣血关闭时（调试）直接空转：不扣血、不触发失败结算
    if self.hpEnabled == false then return end

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
    -- 无限生成：不弹结算，用当前关卡设定重新生成盘面
    if self.infiniteRegen then
        print("[LianLian][盘面] 无限生成：全清后按当前设定重新生成")
        if self.state.customRows then
            -- Debug 直传盘面：用保存的 行/列/种类/方向/层 参数重生
            self:startGameCustom(
                self.state.customRows,
                self.state.customCols,
                self.state.kindLimit,
                self.state.direction,
                self.state.boardLayer)
        else
            -- 正式/新手关：按当前关卡重开
            self:startGame(self.state.part)
        end
        return
    end

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
