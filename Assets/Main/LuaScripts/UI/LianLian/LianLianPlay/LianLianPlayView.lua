--[[
-- 连连看游戏页视图
-- 核心 UI：棋盘 + 状态栏 + 道具栏
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.DataCenter.LianLianGrid"
local LianLianPlay = require "Game.LianLian.DataCenter.LianLianPlay"
local LianLianCard = require "Game.LianLian.DataCenter.LianLianCard"
local LianLianEnum = require "Game.LianLian.Config.LianLianEnum"
local LianLianTileItem = require "UI.LianLian.LianLianPlay.LianLianTileItem"

-- 移动方向 → Direction 图集 sprite 名（对应 _Art_LianLian/Direction/*.png）
local DIRECTION_SPRITE = {
    [LianLianEnum.MoveDirection.NONE] = "nomove",
    [LianLianEnum.MoveDirection.LEFT] = "left",
    [LianLianEnum.MoveDirection.RIGHT] = "right",
    [LianLianEnum.MoveDirection.UP] = "up",
    [LianLianEnum.MoveDirection.DOWN] = "down",
    [LianLianEnum.MoveDirection.DIVIDE_LEFT_RIGHT] = "divide_left_right",
    [LianLianEnum.MoveDirection.DIVIDE_UP_DOWN] = "divide_up_down",
    [LianLianEnum.MoveDirection.FLOCK_LEFT_RIGHT] = "flock_left_right",
    [LianLianEnum.MoveDirection.FLOCK_UP_DOWN] = "flock_up_down",
}
local DIRECTION_SPRITE_PATH = "Assets/_Art_LianLian/Direction/%s.png"

-- 入场动画：无论牌数多少，总时长固定 = 错峰窗口 + 单张弹出时长
local ENTER_TOTAL = 0.8                        -- 入场总时长（固定）
local ENTER_POP = 0.3                          -- 单张牌缩放弹出时长
local ENTER_STAGGER = ENTER_TOTAL - ENTER_POP  -- 首张到末张的错峰铺开窗口 = 0.5

local LianLianPlayView = BaseClass("LianLianPlayView", UIBaseView)
local base = UIBaseView

function LianLianPlayView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianPlayView:ComponentDefine()
    -- 顶部状态栏
    self.levelText = self:AddComponent(UITextMeshProUGUIEx, "TopBar/LevelText")
    self.timeText = self:AddComponent(UITextMeshProUGUIEx, "TopBar/TimeText")
    self.directionImage = self:AddComponent(UIImage, "TopBar/DirectionIcon")
    self.heartContainer = self:AddComponent(UIBaseContainer, "TopBar/Hearts")
    self.backBtn = self:AddComponent(UIButton, "TopBar/BackBtn")

    -- 棋盘容器
    self.boardContainer = self:AddComponent(UIBaseContainer, "Board")

    -- 连线容器
    self.lineContainer = self:AddComponent(UIBaseContainer, "Lines")

    -- 底部道具栏
    self.tipBtn = self:AddComponent(UIButton, "BottomBar/TipBtn")
    self.tipCountText = self:AddComponent(UITextMeshProUGUIEx, "BottomBar/TipBtn/Count")
    self.shuffleBtn = self:AddComponent(UIButton, "BottomBar/ShuffleBtn")
    self.shuffleCountText = self:AddComponent(UITextMeshProUGUIEx, "BottomBar/ShuffleBtn/Count")
    self.hpBtn = self:AddComponent(UIButton, "BottomBar/HpBtn")
    self.hpCountText = self:AddComponent(UITextMeshProUGUIEx, "BottomBar/HpBtn/Count")

    self.backBtn:SetOnClick(BindCallback(self, self.OnBackClick))
    self.tipBtn:SetOnClick(BindCallback(self, self.OnTipClick))
    self.shuffleBtn:SetOnClick(BindCallback(self, self.OnShuffleClick))
    self.hpBtn:SetOnClick(BindCallback(self, self.OnHpClick))
end

function LianLianPlayView:DataDefine()
    -- 多层：每层一套 tile 表 tileItemsByLayer[L][n]
    self.tileItemsByLayer = {}
    self._lineSegments = nil
end

function LianLianPlayView:DataDestroy()
    self:CancelTipTimer()
    self:CancelClearTimer()
    self:CancelFailTimer()
    self:CancelOcclusionTimer()
    self:KillEnterAnim()
    self:ClearLines()
    self.tileItemsByLayer = {}
    self._heartText = nil
end

--- 取（或建）某层的 tile 表
function LianLianPlayView:LayerTiles(layer)
    layer = layer or 1
    self.tileItemsByLayer = self.tileItemsByLayer or {}
    self.tileItemsByLayer[layer] = self.tileItemsByLayer[layer] or {}
    return self.tileItemsByLayer[layer]
end

--- 遍历所有层所有 tile：fn(tile, layer, n)
function LianLianPlayView:ForEachTile(fn)
    if not self.tileItemsByLayer then return end
    for layer, tiles in pairs(self.tileItemsByLayer) do
        for n, tile in pairs(tiles) do
            fn(tile, layer, n)
        end
    end
end

function LianLianPlayView:OnEnable()
    base.OnEnable(self)
    if self.ctrl then
        self.ctrl:InitGame(1)
    end
    -- 不再手动调 RefreshView —— InitGame 内的 startGame 会广播 LianLian_GameStart，
    -- OnGameStart 监听器已经调了 RefreshView。去掉这里避免双重 DrawBoard 产生重叠 tile。
end

function LianLianPlayView:RefreshView()
    if self.levelText then
        self.levelText:SetText(string.format("第 %d 关", self.ctrl:GetPart()))
    end
    -- 方向图标
    self:UpdateDirectionIcon()
    self:UpdateHearts()
    self:UpdateCardCounts()
    self:DrawBoard()
end

--- 更新方向图标
function LianLianPlayView:UpdateDirectionIcon()
    if not self.directionImage then return end
    local direction = self.ctrl.manager:getDirection()
    local spriteName = DIRECTION_SPRITE[direction] or "nomove"
    local path = string.format(DIRECTION_SPRITE_PATH, spriteName)
    self.directionImage:LoadSprite(path)
end

--- 计时器：每帧刷新 TimeText
function LianLianPlayView:Update()
    if not self.ctrl or not self.ctrl.manager then return end
    if not self.ctrl.manager.state.isPlaying then return end
    if self.timeText then
        self.timeText:SetText(self.ctrl.manager:getPlayTimeStr())
    end
end

local TILE_PREFAB = "Assets/Main/Prefabs/UI/LianLian/PrePlayItem.prefab"
local RENDER_CELL = 160    -- 渲染格距（=连线资源原生尺寸；数据层 CELL_SIZE 不受影响）

-- grid 物理坐标(r,c) -> Board 容器锚点坐标（以 Board 中心为原点）
-- 依据盘面 layout 的激活区（origin + activeRows/activeCols）定位，
-- 不再假设固定的 8×14 内部区域，激活区自动居中。
-- grid 物理坐标(r,c) -> Board 容器锚点坐标；layer 决定半格偏移
-- 定位统一以底层 base rows×cols 为参考系；上层往「右上」偏 (layer-1)×cell×0.5
function LianLianPlayView:GridToAnchor(cell, layer)
    layer = layer or 1
    local baseCols = self._boardCols or LianLianConst.INTERIOR_COLS
    local baseRows = self._boardRows or LianLianConst.INTERIOR_ROWS
    local cellSize = self._cell or RENDER_CELL
    -- 各层同心：用「本层」尺寸 (base-(layer-1)) 做居中定位。
    -- 因上层比下层小一圈，同心居中会让上层格心自然落在下层的半格处
    -- → 形成半格交错的金字塔（无需额外 stagger，中心即下层中心）。
    local lcols = baseCols - (layer - 1)
    local lrows = baseRows - (layer - 1)
    local x = (cell.c - (lcols + 1) / 2) * cellSize
    local y = -(cell.r - (lrows + 1) / 2) * cellSize
    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)
    return x, y
end

-- 清除棋盘上所有牌面 GameObject（所有层）
function LianLianPlayView:ClearBoard()
    -- 兜底：销毁 Board 容器下所有子节点（含异步还没进 tileItems 的孤儿 GO）
    if self.boardContainer and self.boardContainer.transform then
        local tf = self.boardContainer.transform
        for i = tf.childCount - 1, 0, -1 do
            CS.UnityEngine.GameObject.Destroy(tf:GetChild(i).gameObject)
        end
    end
    self.tileItemsByLayer = {}
    self:ClearLines()
end

-- 首次绘制整个棋盘：为每个非空格子异步实例化一张牌（带入场序列）
function LianLianPlayView:DrawBoard()
    if not self.boardContainer then return end
    -- 清掉旧牌（销毁 GameObject）
    self:ClearBoard()

    -- 行列数从 Ctrl 取（当前盘面实际尺寸，含 Debug 自定义）
    local rt = self.boardContainer.rectTransform
    local rows, cols = self.ctrl:GetBoardSize()
    cols = cols or LianLianConst.INTERIOR_COLS
    rows = rows or LianLianConst.INTERIOR_ROWS
    self._boardCols = cols
    self._boardRows = rows

    -- 格距固定 160（连线原生尺寸），连线/牌面均按 160 基准布局、不缩放
    self._cell = RENDER_CELL
    -- 整体缩放：让内容适配 Board 容器实际像素（取小边只缩不放）
    -- 多层半格右上偏移会让内容额外向右上扩 (layerCount-1)×cell×0.5，缩放时计入避免溢出
    local layerCount0 = self.ctrl.manager:getLayerCount() or 1
    local staggerExtent = (layerCount0 - 1) * RENDER_CELL * 0.5
    local s = 1
    if rt then
        local bw = rt.rect.width
        local bh = rt.rect.height
        local contentW = cols * RENDER_CELL + staggerExtent
        local contentH = rows * RENDER_CELL + staggerExtent
        if contentW > 0 and contentH > 0 then
            s = math.min(bw / contentW, bh / contentH)
        end
    end
    -- Board 与 Lines 两个容器同步缩放，保证牌面层与连线层坐标系一致
    -- 注意：Set_localScale 走 .transform（Transform），rectTransform 上未绑定该方法
    if self.boardContainer.transform then
        self.boardContainer.transform:Set_localScale(s, s, 1)
    end
    if self.lineContainer and self.lineContainer.transform then
        self.lineContainer.transform:Set_localScale(s, s, 1)
    end

    -- 逐层绘制：底层先画，高层后画（盖在上面）；每层半格右上偏移
    local layerCount = self.ctrl.manager:getLayerCount() or 1
    for layer = 1, layerCount do
        local grid = self.ctrl.manager:getGrid(layer)
        if grid then
            -- 每层独立算入场错峰延迟
            local delayByN = self:BuildEnterDelays(grid)
            for _, cell in pairs(grid) do
                if cell.id ~= 0 then
                    self:CreateTile(cell, delayByN[cell.n] or 0, layer)
                end
            end
        end
    end

    -- tile 异步实例化，入场窗口结束后统一刷新遮挡态（多层才需要）
    if layerCount > 1 then
        self:CancelOcclusionTimer()
        self._occTimer = TimerManager:GetInstance():GetTimer(ENTER_TOTAL, function()
            self:RefreshOcclusion()
        end, self, true, false, false)
        self._occTimer:Start()
    end
end

function LianLianPlayView:CancelOcclusionTimer()
    if self._occTimer then
        self._occTimer:Stop()
        self._occTimer = nil
    end
end

-- 物理坐标 (r,c) -> tile 索引 n（= r*gridCols+c，与 grid 的 cell.n 编码一致）
function LianLianPlayView:PosToN(r, c)
    local cols = (self._layout and self._layout.gridCols) or LianLianConst.GRID_WIDTH
    return r * cols + c
end

-- "r_c" 字符串 -> tile 索引 n
function LianLianPlayView:RcToN(rc)
    local r, c = rc:match("^(%d+)_(%d+)$")
    if not r then return nil end
    return self:PosToN(tonumber(r), tonumber(c))
end

-- 依据盘面 meta.enterList 计算每个非空格子的入场延迟：
-- 按入场序列排名把延迟均摊到固定的错峰窗口内 → 总时长恒定，与牌数无关。
-- @return table { [n] = delaySeconds }
function LianLianPlayView:BuildEnterDelays(grid)
    -- 收集所有非空格子的 n
    local pending = {}   -- [n] = true
    for _, cell in pairs(grid) do
        if cell.id ~= 0 then pending[cell.n] = true end
    end

    -- 按 enterList 顺序排名，未覆盖的非空格子追加到末尾（兜底）
    local ranked = {}
    local enterList = self.ctrl.manager:getEnterList()
    if enterList then
        for _, rc in ipairs(enterList) do
            local n = self:RcToN(rc)
            if n and pending[n] then
                ranked[#ranked + 1] = n
                pending[n] = nil
            end
        end
    end
    for n in pairs(pending) do
        ranked[#ranked + 1] = n
    end

    -- 均摊延迟：第 i 张 delay = (i-1)/(count-1) * 错峰窗口
    local count = #ranked
    local delayByN = {}
    local denom = math.max(count - 1, 1)
    for i, n in ipairs(ranked) do
        delayByN[n] = (i - 1) / denom * ENTER_STAGGER
    end
    return delayByN
end

-- 中断所有牌的入场动画（把 scale 复位为 1）
function LianLianPlayView:KillEnterAnim()
    self:ForEachTile(function(tile)
        if tile.KillPopIn then tile:KillPopIn() end
    end)
end

-- 实例化单张牌
-- @param popDelay number|nil 入场缩放弹出的错峰延迟（秒），缺省 0（即刻弹出）
-- @param layer number 所属层(缺省1)
function LianLianPlayView:CreateTile(cell, popDelay, layer)
    layer = layer or 1
    local n = cell.n
    local pos = { r = cell.r, c = cell.c, layer = layer }
    local ax, ay = self:GridToAnchor(cell, layer)
    self.boardContainer:GameObjectInstantiateAsync(TILE_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        local tiles = self:LayerTiles(layer)
        if not tiles then return end
        local tile = self.boardContainer:AddComponent(LianLianTileItem, request.gameObject)
        local sz = (self._cell or RENDER_CELL) * 0.92
        tile:SetSize(sz, sz)
        tile:SetPosition(ax, ay)
        tile:SetData(pos, cell.id, function(p) self.ctrl:OnTileClick(p) end)
        tiles[n] = tile
        -- 高层后实例化，天然叠在上面（同容器按创建顺序渲染）
        -- 按错峰延迟播放缩放弹出
        tile:PlayPopIn(popDelay or 0, ENTER_POP)
    end, self.boardContainer.transform)
end

-- 依据某个位置取 tile（pos.layer 决定层，缺省1）
function LianLianPlayView:GetTile(pos)
    if not pos then return nil end
    local tiles = self.tileItemsByLayer and self.tileItemsByLayer[pos.layer or 1]
    if not tiles then return nil end
    local n = self:PosToN(pos.r, pos.c)
    return tiles[n]
end

-- 某层某格 (r,c) 是否被更高层遮挡。
-- 几何：上层同心、比下层小一圈、半格右上错位 → 每张上层牌只压住下层牌的「一个象限」，
-- 对应 4 个上层格：(r-1,c-1)/(r-1,c)/(r,c-1)/(r,c) 各盖住下层格的一个 1/4。
-- 规则：4 个象限「全部」无遮挡 → 亮色可点；只要「任一」象限被上层活牌盖住 → 灰/不可选。
function LianLianPlayView:IsCellOccluded(r, c, layer)
    local higher = self.ctrl.manager:getGrid(layer + 1)
    if not higher then return false end
    -- 覆盖下层(r,c) 4 象限的上层格
    local quads = {
        { r - 1, c - 1 }, { r - 1, c }, { r, c - 1 }, { r, c },
    }
    for _, rc in ipairs(quads) do
        local hr, hc = rc[1], rc[2]
        if hr >= 1 and hc >= 1 then
            local hcell = higher[hr .. "_" .. hc]
            -- 任一象限被上层活牌盖住 → 判定遮挡
            if hcell and hcell.id and hcell.id ~= 0 then
                return true
            end
        end
    end
    return false
end

-- 刷新所有层所有牌的遮挡态（置灰+禁点）；顶层永不被遮挡
function LianLianPlayView:RefreshOcclusion()
    local layerCount = self.ctrl.manager:getLayerCount() or 1
    self:ForEachTile(function(tile, layer, n)
        if not tile or not tile.pos then return end
        -- 已消除(隐藏)的不处理
        if tile.id == 0 then return end
        local occluded = false
        if layer < layerCount then
            occluded = self:IsCellOccluded(tile.pos.r, tile.pos.c, layer)
        end
        tile:SetOccluded(occluded)
    end)
end

function LianLianPlayView:UpdateHearts()
    local hp = self.ctrl and self.ctrl:GetHp() or 0
    local maxHp = LianLianConst.HP_MAX
    -- 用心形符号显示 HP（❤=有, ♡=空）
    local hearts = ""
    for i = 1, maxHp do
        if i <= hp then
            hearts = hearts .. "❤"
        else
            hearts = hearts .. "♡"
        end
    end
    -- Hearts 容器没有子 TMP 节点，用 levelText 旁不合适；用 heartContainer 上的 TMP（若有）
    -- 兜底：直接在 heartContainer 上找或创建文本
    if not self._heartText and self.heartContainer then
        -- 尝试找 Hearts 下的文本子节点
        local tf = self.heartContainer.transform:Find("HpText")
        if tf then
            self._heartText = self:AddComponent(UITextMeshProUGUIEx, "TopBar/Hearts/HpText")
        end
    end
    if self._heartText then
        self._heartText:SetText(hearts)
    end
    self._hp = hp
end

function LianLianPlayView:UpdateCardCounts()
    local state = self.ctrl and self.ctrl.manager and self.ctrl.manager.state
    if not state then return end
    local tipLeft = LianLianConst.CARD_MAX - LianLianCard.getNum(state.card_used, LianLianConst.CARD_TIP)
    local shuffleLeft = LianLianConst.CARD_MAX - LianLianCard.getNum(state.card_used, LianLianConst.CARD_SHUFFLE)
    local hpLeft = LianLianConst.CARD_MAX - LianLianCard.getNum(state.card_used, LianLianConst.CARD_HP)
    if self.tipCountText then self.tipCountText:SetText(tostring(tipLeft)) end
    if self.shuffleCountText then self.shuffleCountText:SetText(tostring(shuffleLeft)) end
    if self.hpCountText then self.hpCountText:SetText(tostring(hpLeft)) end
end

-- 连线：只用 line_1(半边直线) 一张图，靠旋转拼出直线与拐角
-- line_1 (160×160, pivot 0.5,0.5): 竖条居中于 x 轴，从格中心(y≈0)向下延伸到接近格底边(y≈-78)
--   即"从格中心到某条边"的半边直线。四方向靠旋转，拐角=两条垂直半直线在格中心交汇。
-- 格距固定 = 160（连线资源原生尺寸），连线 sizeDelta 恒 160×160 不缩放；屏幕适配靠容器整体 localScale。
local LINE_SEG_PREFAB = "Assets/Main/Prefabs/UI/LianLian/PreLineSegment.prefab"
local LINE_STRAIGHT = "Assets/_Art_LianLian/Line/line_1"   -- 半边直线：从中心向下延伸
local LINE_OVERLAP = 3     -- 半直线沿延伸方向外移的像素，令相邻半条在格边重叠、消除接缝

-- 直线方向 → Z轴旋转角度（line_1 默认向下延伸=0°）
local DIR_ANGLE = { top = 180, right = 90, bottom = 0, left = 270 }
-- 方向单位向量（Unity UI：右=+x, 上=+y），用于沿延伸方向做重叠外移
local DIR_VEC = {
    top = { 0, 1 }, bottom = { 0, -1 }, left = { -1, 0 }, right = { 1, 0 },
}

function LianLianPlayView:DrawLine(pathLine, layer)
    self:ClearLines()
    if not pathLine or #pathLine == 0 then return end
    self._lineSegments = {}
    for _, node in ipairs(pathLine) do
        self:CreateLineSegments(node, layer or 1)
    end
end

-- 为路径节点生成线段：每个连通方向放一条 line_1 半直线（中心→该边），
-- 直线格 = 两条相对半直线，拐角格 = 两条垂直半直线，在格中心交汇，自动对齐。
-- 所有半直线尺寸恒为 RENDER_CELL×RENDER_CELL（不缩放），沿延伸方向外移 LINE_OVERLAP 消缝。
function LianLianPlayView:CreateLineSegments(node, layer)
    local cx, cy = self:GridToAnchor({ r = node.r, c = node.c }, layer or 1)
    for dir, angle in pairs(DIR_ANGLE) do
        if node[dir] == 1 then
            local v = DIR_VEC[dir]
            local x = cx + v[1] * LINE_OVERLAP
            local y = cy + v[2] * LINE_OVERLAP
            self:SpawnLine(LINE_STRAIGHT, x, y, RENDER_CELL, RENDER_CELL, angle)
        end
    end
end

-- 实例化一个线段 Image（异步，在 Lines 容器里）
-- spritePath: 完整资产路径（如 LINE_STRAIGHT）
function LianLianPlayView:SpawnLine(spritePath, x, y, w, h, angle)
    if not self.lineContainer then return end
    self.lineContainer:GameObjectInstantiateAsync(LINE_SEG_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self._lineSegments then
            CS.UnityEngine.GameObject.Destroy(request.gameObject)
            return
        end
        local img = self.lineContainer:AddComponent(UIImage, request.gameObject)
        local rt = img.rectTransform
        if rt then
            rt:Set_anchorMin(0.5, 0.5)
            rt:Set_anchorMax(0.5, 0.5)
            rt:Set_pivot(0.5, 0.5)
            rt:Set_sizeDelta(w, h)
            rt:Set_anchoredPosition(x, y)
            rt:Set_localEulerAngles(0, 0, angle)
        end
        img:LoadSprite(spritePath)
        self._lineSegments[#self._lineSegments + 1] = request.gameObject
    end, self.lineContainer.transform)
end

function LianLianPlayView:ClearLines()
    if self._lineSegments then
        for _, go in ipairs(self._lineSegments) do
            if go then CS.UnityEngine.GameObject.Destroy(go) end
        end
    end
    self._lineSegments = nil
end

function LianLianPlayView:ShowChecked(pos)
    local tile = self:GetTile(pos)
    if tile then tile:SetChecked(true) end
end

function LianLianPlayView:HideChecked()
    self:ForEachTile(function(tile) tile:SetChecked(false) end)
end

function LianLianPlayView:ShowTip(pair)
    if not pair then return end
    for _, pos in ipairs(pair) do
        local tile = self:GetTile(pos)
        if tile then tile:SetTip(true) end
    end
    -- 一段时间后取消提示
    self:CancelTipTimer()
    self._tipTimer = TimerManager:GetInstance():GetTimer(2, function()
        self:HideTip()
    end, self, true, false, false)
    self._tipTimer:Start()
end

function LianLianPlayView:HideTip()
    self:ForEachTile(function(tile) tile:SetTip(false) end)
end

function LianLianPlayView:CancelTipTimer()
    if self._tipTimer then
        self._tipTimer:Stop()
        self._tipTimer = nil
    end
end

-- 依据 grid 最新 id 刷新棋盘（洗牌/消除后）；layer 缺省刷新所有层
function LianLianPlayView:UpdateBoard(layer)
    if layer then
        self:UpdateBoardLayer(layer)
    else
        local layerCount = self.ctrl.manager:getLayerCount() or 1
        for L = 1, layerCount do
            self:UpdateBoardLayer(L)
        end
    end
    -- 消除/移动/洗牌后遮挡关系可能变化（某层清空露出下层），整体刷新遮挡态
    self:RefreshOcclusion()
end

-- 刷新单层
function LianLianPlayView:UpdateBoardLayer(layer)
    local tiles = self:LayerTiles(layer)
    local grid = self.ctrl.manager:getGrid(layer)
    if not grid then return end
    for _, cell in pairs(grid) do
        local tile = tiles[cell.n]
        if cell.id == 0 then
            if tile then tile:SetVisible(false) end
        else
            if tile then
                tile:SetData({ r = cell.r, c = cell.c, layer = layer }, cell.id, function(p) self.ctrl:OnTileClick(p) end)
                tile:SetVisible(true)
            else
                self:CreateTile(cell, 0, layer)
            end
        end
    end
end

-- 消除动画：显示连线（该层坐标）-> 隐藏两张牌 -> 结束回调（只作用该层）
function LianLianPlayView:OnPlayClear(data)
    if not data then return end
    local layer = data.layer or 1
    self:ClearLines()
    self:DrawLine(data.pathLine, layer)

    self:CancelClearTimer()
    self._clearTimer = TimerManager:GetInstance():GetTimer(0.5, function()
        self:ClearLines()
        -- 消除两张牌：直接隐藏（先杀入场动画避免干扰）
        local a, b = data.posA, data.posB
        local ta, tb = self:GetTile(a), self:GetTile(b)
        if ta then ta:KillPopIn(); ta:SetVisible(false) end
        if tb then tb:KillPopIn(); tb:SetVisible(false) end
        -- 触发后续（移动 + 胜负判定），只作用该层
        self.ctrl:OnClearEnd(layer)
        -- 消除后遮挡关系变化（上层牌消失可能露出下层）：无移动时 OnMove 不会触发，这里兜底刷新
        self:RefreshOcclusion()
    end, self, true, false, false)
    self._clearTimer:Start()
end

function LianLianPlayView:CancelClearTimer()
    if self._clearTimer then
        self._clearTimer:Stop()
        self._clearTimer = nil
    end
end

-- 棋盘移动：未消元素从旧位滑到新位（DOTween），动画中锁输入；只作用事件所属层
function LianLianPlayView:OnMove(data)
    local layer = (data and data.layer) or 1
    if not data or not data.moveList or #data.moveList == 0 then
        self:UpdateBoard(layer)
        return
    end
    local tiles = self:LayerTiles(layer)
    if not tiles then return end

    local W = LianLianConst.GRID_WIDTH

    -- 解析每步：旧索引 oldN / 新索引 newN / 新锚点坐标（带层偏移）
    local moves = {}
    for _, mv in ipairs(data.moveList) do
        local orr, oc = mv.oldRc:match("^(%d+)_(%d+)$")
        local nr, nc = mv.newRc:match("^(%d+)_(%d+)$")
        if orr and nr then
            orr, oc, nr, nc = tonumber(orr), tonumber(oc), tonumber(nr), tonumber(nc)
            local oldN = orr * W + oc
            local tile = tiles[oldN]
            if tile then
                local nx, ny = self:GridToAnchor({ r = nr, c = nc }, layer)
                moves[#moves + 1] = {
                    tile = tile, oldN = oldN, newN = nr * W + nc,
                    nx = nx, ny = ny, r = nr, c = nc,
                }
            end
        end
    end

    if #moves == 0 then
        self:UpdateBoard(layer)
        return
    end

    -- 先从旧索引整体摘除，避免"某步的 newN 恰是另一步的 oldN"造成覆盖
    for _, m in ipairs(moves) do
        if tiles[m.oldN] == m.tile then
            tiles[m.oldN] = nil
        end
    end

    -- 重挂到新索引并播放滑动，全部完成后解锁 + 兜底校正
    self:SetInputLock(true)
    local total = #moves
    local done = 0
    for _, m in ipairs(moves) do
        tiles[m.newN] = m.tile
        m.tile.pos = { r = m.r, c = m.c, layer = layer }
        m.tile:MoveTo(m.nx, m.ny, LianLianConst.MOVE_DURATION, function()
            done = done + 1
            if done >= total then
                self:UpdateBoard(layer)
                self:SetInputLock(false)
            end
        end)
    end
end

-- 输入锁（动画期间禁止点击），供 Ctrl 查询
function LianLianPlayView:SetInputLock(bLock)
    if self.ctrl then
        self.ctrl._inputLocked = bLock and true or false
    end
end

function LianLianPlayView:OnBackClick()
    self.ctrl:BackToMain()
end

function LianLianPlayView:OnTipClick()
    self.ctrl:UseTip()
end

function LianLianPlayView:OnShuffleClick()
    self.ctrl:UseShuffle()
end

function LianLianPlayView:OnHpClick()
    self.ctrl:UseHp()
end

function LianLianPlayView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener("LianLian_HpUpdate", self.OnHpUpdate)
    self:AddUIListener("LianLian_ItemShowChecked", self.OnShowChecked)
    self:AddUIListener("LianLian_ItemHideChecked", self.OnHideChecked)
    self:AddUIListener("LianLian_ItemShowTip", self.OnShowTip)
    self:AddUIListener("LianLian_ItemUpdate", self.OnItemUpdate)
    self:AddUIListener("LianLian_GameOver", self.OnGameOver)
    self:AddUIListener("LianLian_PlayClear", self.OnPlayClear)
    self:AddUIListener("LianLian_Move", self.OnMove)
    self:AddUIListener("LianLian_MatchFail", self.OnMatchFail)
    self:AddUIListener("LianLian_GameStart", self.OnGameStart)
end

-- 游戏开局（初次进 Play 或 Debug 重生）：重绘棋盘
function LianLianPlayView:OnGameStart(data)
    self:RefreshView()
end

function LianLianPlayView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianPlayView:OnHpUpdate(data)
    self:UpdateHearts()
end

function LianLianPlayView:OnShowChecked(pos)
    self:ShowChecked(pos)
end

function LianLianPlayView:OnHideChecked(data)
    -- data 可能是 { layer = L }；HideChecked 清所有层选中框，够用
    self:HideChecked()
end

function LianLianPlayView:OnShowTip(data)
    -- data = { pair = {a,b}, layer }；pair 内 pos 已带 layer
    local pair = data and data.pair or data
    self:ShowTip(pair)
end

function LianLianPlayView:OnItemUpdate(data)
    -- 洗牌/重排只作用某层；带 layer 则只刷该层，否则全刷
    self:UpdateBoard(data and data.layer)
    self:UpdateCardCounts()
end

-- 配对失败：两张牌闪烁反馈
function LianLianPlayView:OnMatchFail(data)
    if not data then return end
    local ta, tb = self:GetTile(data.posA), self:GetTile(data.posB)
    if ta then ta:SetChecked(true) end
    if tb then tb:SetChecked(true) end
    self:CancelFailTimer()
    self._failTimer = TimerManager:GetInstance():GetTimer(0.3, function()
        if ta then ta:SetChecked(false) end
        if tb then tb:SetChecked(false) end
    end, self, true, false, false)
    self._failTimer:Start()
end

function LianLianPlayView:CancelFailTimer()
    if self._failTimer then
        self._failTimer:Stop()
        self._failTimer = nil
    end
end

function LianLianPlayView:OnGameOver(data)
    if data.isWin then
        UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianWin, data)
    elseif data.canRevive then
        UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianRevive, data)
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianLose, data)
    end
end

function LianLianPlayView:OnDisable()
    base.OnDisable(self)
end

function LianLianPlayView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianPlayView
