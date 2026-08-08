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
    self:ClearGridLines()
    self:CancelRocketFx()
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

    -- 按当前开关补画棋盘格线（重生盘面后保持）
    self:RefreshGridLines()
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
        tile:SetSpecial(cell.specialType)   -- 特殊元素装扮（普通牌 nil 无效果）
        tile:SetModifiers(cell.mods)        -- 格子修饰器覆盖（无修饰器 nil 无效果）
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

    -- 规则A（fullClearReveal=true）：只要「上一层」还有任一活牌，本层就整体被遮挡；
    -- 上一层全消后本层才亮。
    if self.ctrl.manager:getFullClearReveal() then
        for _, hcell in pairs(higher) do
            if hcell.id and hcell.id ~= 0 then
                return true
            end
        end
        return false
    end

    -- 规则B（默认，逐格揭示）：覆盖下层(r,c) 4 象限的上层格，任一象限被活牌盖住即遮挡
    local quads = {
        { r - 1, c - 1 }, { r - 1, c }, { r, c - 1 }, { r, c },
    }
    for _, rc in ipairs(quads) do
        local hr, hc = rc[1], rc[2]
        if hr >= 1 and hc >= 1 then
            local hcell = higher[hr .. "_" .. hc]
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
local LINE_CORNER = "Assets/_Art_LianLian/Line/line_5"     -- 拐角图：一张图覆盖 L 形转角
local LINE_OVERLAP = 3     -- 半直线沿延伸方向外移的像素，令相邻半条在格边重叠、消除接缝

-- 直线方向 → Z轴旋转角度（line_1 默认向下延伸=0°）
local DIR_ANGLE = { top = 180, right = 90, bottom = 0, left = 270 }
-- 方向单位向量（Unity UI：右=+x, 上=+y），用于沿延伸方向做重叠外移
local DIR_VEC = {
    top = { 0, 1 }, bottom = { 0, -1 }, left = { -1, 0 }, right = { 1, 0 },
}

-- 拐角(两条垂直半直线)的方向组合 → line_5 旋转角度。
-- 约定 line_5 默认(0°)连接「下 + 右」(bottom+right, └ 形的镜像即 ┌ 朝右下)。
-- 其余三种由 90° 步进旋转得到；若实机方向不对，调整这里的角度即可。
-- line_5 默认(0°)连接「上 + 左」；实机在此基础上整体 +180° 才对齐
local CORNER_ANGLE = {
    top_left = 0,
    right_top = 270,
    bottom_right = 180,
    left_bottom = 90,
}

-- 判断节点是否为拐角：恰好两个连通方向且互相垂直；返回归一化的组合 key
local function GetCornerKey(node)
    local dirs = {}
    for _, d in ipairs({ "top", "right", "bottom", "left" }) do
        if node[d] == 1 then dirs[#dirs + 1] = d end
    end
    if #dirs ~= 2 then return nil end
    local a, b = dirs[1], dirs[2]
    -- 排除对向直线(top+bottom / left+right)，只保留垂直组合
    if (a == "top" and b == "bottom") or (a == "bottom" and b == "top") then return nil end
    if (a == "left" and b == "right") or (a == "right" and b == "left") then return nil end
    -- 归一化为 CORNER_ANGLE 里的四种 key 之一（key 名 = 实际显示的拐角方向）
    -- 注：方向标志集合与屏幕视觉是对角关系，故命名取「对角」以匹配实际显示
    local set = { [a] = true, [b] = true }
    if set.bottom and set.right then return "top_left" end
    if set.left and set.bottom then return "right_top" end
    if set.top and set.left then return "bottom_right" end
    if set.right and set.top then return "left_bottom" end
    return nil
end

function LianLianPlayView:DrawLine(pathLine, layer)
    self:ClearLines()
    if not pathLine or #pathLine == 0 then return end
    self._lineSegments = {}
    self._segCount = 0
    self._segSeen = {}     -- half-edge 判重表（仅在重复时打印告警）
    self._segDup = 0
    for _, node in ipairs(pathLine) do
        self:CreateLineSegments(node, layer or 1)
    end
    self._segSeen = nil
end

-- 记录一条「半边(half-edge)」并检测视觉重复。
-- 一段线覆盖的是「格心(r,c) → 某条边(dir)」这半条边。视觉重叠 = 同一条 half-edge 被画两次，
-- 无论它由直线段、拐角臂、还是相邻格反向画出（锚点/sprite 不同也算重复）。
-- 归一化：half-edge 唯一标识 = 格坐标 + 方向（不合并到整边，保留半边粒度）。
-- @param src string 段来源描述
function LianLianPlayView:_TrackHalfEdge(r, c, dir, src)
    self._segSeen = self._segSeen or {}
    local key = string.format("%d_%d_%s", r, c, dir)
    if self._segSeen[key] then
        self._segDup = (self._segDup or 0) + 1
        print(string.format("[LianLian][重复半边!] half-edge=%s 本次来源=%s 先前来源=%s", key, src, self._segSeen[key]))
    else
        self._segSeen[key] = src
    end
end

-- 为路径节点生成线段：每个连通方向放一条 line_1 半直线（中心→该边），
-- 直线格 = 两条相对半直线，拐角格 = 两条垂直半直线，在格中心交汇，自动对齐。
-- 所有半直线尺寸恒为 RENDER_CELL×RENDER_CELL（不缩放），沿延伸方向外移 LINE_OVERLAP 消缝。
function LianLianPlayView:CreateLineSegments(node, layer)
    local cx, cy = self:GridToAnchor({ r = node.r, c = node.c }, layer or 1)
    -- 拐角格：用一张 line_5 拐角图（旋转对应方向），而不是两条 line_1 直线拼接
    local cornerKey = GetCornerKey(node)
    if cornerKey then
        local angle = CORNER_ANGLE[cornerKey]
        -- 拐角图锚点直接放格心，不再为对准转角点做偏移（该偏移会把整图推向邻格、右臂 overshoot 与邻格直线重叠）。
        -- line_5 的肘部(两臂交点)在图片「图心上方 67px」(像素实测)，而肘部才该落在格心。
        -- 故图心放在 格心 − rotate((0,67), angle)，使肘部对准格心；偏移随拐角角度旋转。
        local ELBOW = 67
        local rad = math.rad(angle)
        local ox = -(-ELBOW * math.sin(rad))   -- = ELBOW*sin(angle)
        local oy = -(ELBOW * math.cos(rad))    -- = -ELBOW*cos(angle)
        local fx = math.floor(cx + ox + 0.5)
        local fy = math.floor(cy + oy + 0.5)
        -- 参考：本拐角连通的两条边，各自「边中点」目标坐标(格心±半格)。
        -- 拐角肘部应落在格心(cx,cy)、两臂分别伸向这两个边中点，用于对照实际显示。
        local half = RENDER_CELL / 2
        local ref = {}
        for _, d in ipairs({ "top", "right", "bottom", "left" }) do
            if node[d] == 1 then
                local v = DIR_VEC[d]
                ref[#ref + 1] = string.format("%s->(%.0f,%.0f)", d, cx + v[1] * half, cy + v[2] * half)
            end
        end
        self._segCount = (self._segCount or 0) + 1
        local segTag = string.format("第%d段_拐角_行%d_列%d_类型%s", self._segCount, node.r, node.c, tostring(cornerKey))
        print(string.format("[LianLian][连线段] 连线名称=Line_%s 类型=拐角 拐角类型=%s 节点=(行%d,列%d) 旋转角度=%d 格心=(%.1f,%.1f) 图落点=(%d,%d) 偏移=(%.1f,%.1f) 两臂目标=%s 格距=%d",
            segTag, tostring(cornerKey), node.r, node.c, angle, cx, cy, fx, fy, ox, oy, table.concat(ref, " "), RENDER_CELL))
        -- 拐角覆盖它连通的两条 half-edge，各自登记判重
        for _, d in ipairs({ "top", "right", "bottom", "left" }) do
            if node[d] == 1 then
                self:_TrackHalfEdge(node.r, node.c, d, string.format("拐角(%d,%d)%s", node.r, node.c, tostring(cornerKey)))
            end
        end
        self:SpawnLine(LINE_CORNER, fx, fy, RENDER_CELL, RENDER_CELL, angle, segTag)
        return
    end
    -- 直线/端点格：每个连通方向放一条 line_1 半直线（中心→该边）
    for dir, angle in pairs(DIR_ANGLE) do
        if node[dir] == 1 then
            local v = DIR_VEC[dir]
            local x = cx + v[1] * LINE_OVERLAP
            local y = cy + v[2] * LINE_OVERLAP
            self._segCount = (self._segCount or 0) + 1
            local segTag = string.format("第%d段_直线_行%d_列%d_方向%s", self._segCount, node.r, node.c, dir)
            print(string.format("[LianLian][连线段] 连线名称=Line_%s 类型=直线 方向=%s 节点=(行%d,列%d) 旋转角度=%d 格心=(%.1f,%.1f) 落点=(%.1f,%.1f) 格距=%d",
                segTag, dir, node.r, node.c, angle, cx, cy, x, y, RENDER_CELL))
            self:_TrackHalfEdge(node.r, node.c, dir, string.format("直线(%d,%d)%s", node.r, node.c, dir))
            self:SpawnLine(LINE_STRAIGHT, x, y, RENDER_CELL, RENDER_CELL, angle, segTag)
        end
    end
end

-- 实例化一个线段 Image（异步，在 Lines 容器里）
-- spritePath: 完整资产路径（如 LINE_STRAIGHT）
-- @param segTag string|nil 段标签（用于给 GameObject 命名 + 打印，便于对照日志）
function LianLianPlayView:SpawnLine(spritePath, x, y, w, h, angle, segTag)
    if not self.lineContainer then return end
    self.lineContainer:GameObjectInstantiateAsync(LINE_SEG_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self._lineSegments then
            CS.UnityEngine.GameObject.Destroy(request.gameObject)
            return
        end
        local go = request.gameObject
        -- 命名 GameObject 便于在 Hierarchy 对照日志
        if segTag then go.name = "Line_" .. segTag end
        local img = self.lineContainer:AddComponent(UIImage, go)
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
        self._lineSegments[#self._lineSegments + 1] = go
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

-- 棋盘格线粗细（未缩放的基准像素）
local GRID_LINE_THICK = 2

-- 生成一条棋盘红线（复用 PreLineSegment 纯色 Image，染红、拉成细线）
function LianLianPlayView:SpawnGridLine(x, y, w, h)
    if not self.lineContainer then return end
    self.lineContainer:GameObjectInstantiateAsync(LINE_SEG_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self._gridLines then
            CS.UnityEngine.GameObject.Destroy(request.gameObject)
            return
        end
        local go = request.gameObject
        go.name = "GridLine"
        local img = self.lineContainer:AddComponent(UIImage, go)
        local rt = img.rectTransform
        if rt then
            rt:Set_anchorMin(0.5, 0.5)
            rt:Set_anchorMax(0.5, 0.5)
            rt:Set_pivot(0.5, 0.5)
            rt:Set_sizeDelta(w, h)
            rt:Set_anchoredPosition(x, y)
            rt:Set_localEulerAngles(0, 0, 0)
        end
        if img.SetColorRGBA then img:SetColorRGBA(1, 0, 0, 1) end   -- 红色
        self._gridLines[#self._gridLines + 1] = go
    end, self.lineContainer.transform)
end

-- 画棋盘格线：按底层 base rows×cols 画竖线(cols+1)+横线(rows+1)，红色细线
function LianLianPlayView:DrawGridLines()
    self:ClearGridLines()
    self._gridLines = {}
    local cols = self._boardCols or LianLianConst.INTERIOR_COLS
    local rows = self._boardRows or LianLianConst.INTERIOR_ROWS
    local cell = self._cell or RENDER_CELL
    local totalW = cols * cell
    local totalH = rows * cell
    -- 网格线以 Board 中心为原点：竖线 x ∈ [-totalW/2, +totalW/2] 均分 cols 段
    local x0 = -totalW / 2
    local y0 = -totalH / 2
    -- 竖线（cols+1 条）：全高 totalH
    for c = 0, cols do
        local x = x0 + c * cell
        self:SpawnGridLine(x, 0, GRID_LINE_THICK, totalH)
    end
    -- 横线（rows+1 条）：全宽 totalW
    for r = 0, rows do
        local y = y0 + r * cell
        self:SpawnGridLine(0, y, totalW, GRID_LINE_THICK)
    end
end

function LianLianPlayView:ClearGridLines()
    if self._gridLines then
        for _, go in ipairs(self._gridLines) do
            if go then CS.UnityEngine.GameObject.Destroy(go) end
        end
    end
    self._gridLines = nil
end

-- 依 Manager 开关刷新棋盘格线：开→画，关→清
function LianLianPlayView:RefreshGridLines()
    local on = self.ctrl and self.ctrl.manager and self.ctrl.manager:getShowGridLine()
    if on then
        self:DrawGridLines()
    else
        self:ClearGridLines()
    end
end

-- Debug 开关变更事件：实时刷新格线
function LianLianPlayView:OnGridLineChanged()
    self:RefreshGridLines()
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
    -- 先清掉上一次的提示，再高亮本次这一对
    self:HideTip()
    for _, pos in ipairs(pair) do
        local tile = self:GetTile(pos)
        if tile then tile:SetTip(true) end
    end
    -- 不自动还原：提示常驻，直到任何盘面操作触发 HideTip
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
        local hasMod = cell.mods and next(cell.mods) ~= nil
        if cell.id == 0 and not hasMod then
            -- 空格且无修饰器：隐藏
            if tile then tile:SetVisible(false) end
        else
            -- 有牌 或 空格带修饰器（如藤蔓障碍，需显示覆盖层）
            if tile then
                tile:SetData({ r = cell.r, c = cell.c, layer = layer }, cell.id, function(p) self.ctrl:OnTileClick(p) end)
                tile:SetSpecial(cell.specialType)   -- 刷新特殊元素装扮
                tile:SetModifiers(cell.mods)        -- 刷新格子修饰器覆盖
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
    self:HideTip()   -- 消除是盘面操作：还原提示底图
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
    self:HideTip()   -- 移动是盘面操作：还原提示底图
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
    self:AddUIListener("LianLian_OcclusionRuleChanged", self.OnOcclusionRuleChanged)
    self:AddUIListener("LianLian_GridLineChanged", self.OnGridLineChanged)
    self:AddUIListener("LianLian_RocketFx", self.OnRocketFx)
end

-- Ease 名 → Ease 枚举（供 FX 参数用字符串指定缓动）
local EASE_MAP = {
    InQuad = Ease.InQuad, OutQuad = Ease.OutQuad, Linear = Ease.Linear,
    InBack = Ease.InBack, OutBack = Ease.OutBack,
}

-- 火箭特效：从「发射源格 origin」为每个目标格发一枚火箭飞过去，抵达后爆炸并「逐格消除」该目标。
-- 数据未预先清除——由本函数在每枚火箭抵达时调 manager:clearCells 清对应格（表现与消除同步）。
-- data = { layer, origin={r,c}, targets={ {r,c},... }, fx={...表现参数} }
function LianLianPlayView:OnRocketFx(data)
    if not data then return end
    local layer = data.layer or 1
    local targets = data.targets or {}
    local fx = data.fx or {}
    print(string.format("[LianLian][火箭] layer=%d 目标格=%d origin=(%s,%s)",
        layer, #targets, tostring(data.origin and data.origin.r), tostring(data.origin and data.origin.c)))

    if #targets == 0 or not self.boardContainer then
        self:UpdateBoard(layer)
        return
    end

    -- 发射起点：origin 格中心（无 origin 兜底棋盘中心）
    local sx, sy = 0, 0
    if data.origin then sx, sy = self:GridToAnchor({ r = data.origin.r, c = data.origin.c }, layer) end

    self:CancelRocketFx()
    self._rocketFxGos = {}

    -- 每个目标格发一枚火箭（枚数 = 目标数），抵达时清该格
    for _, tgt in ipairs(targets) do
        local tx, ty = self:GridToAnchor({ r = tgt.r, c = tgt.c }, layer)
        self:SpawnRocket(sx, sy, tx, ty, fx, function()
            -- 抵达并爆炸后：消除该目标格（逐格）
            self.ctrl.manager:clearCells(layer, { { r = tgt.r, c = tgt.c } })
        end)
    end
end

-- 生成一枚火箭图，从 (sx,sy) 飞到 (tx,ty)，抵达后爆炸销毁并回调 onHit
-- @param fx table 表现参数（rocketSprite/rocketSize/flyDuration/flyEase/explodeScale/explodeDur/explodeHold）
function LianLianPlayView:SpawnRocket(sx, sy, tx, ty, fx, onHit)
    fx = fx or {}
    local sprite = fx.rocketSprite or "Assets/_Art_LianLian/ItemSprites/item_special/rocket.png"
    local size = fx.rocketSize or 80
    local flyDur = fx.flyDuration or 0.35
    local ease = EASE_MAP[fx.flyEase] or Ease.InQuad
    local exScale = fx.explodeScale or 1.6
    local exDur = fx.explodeDur or 0.12
    local exHold = fx.explodeHold or 0.14

    self.boardContainer:GameObjectInstantiateAsync(TILE_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self._rocketFxGos then
            CS.UnityEngine.GameObject.Destroy(request.gameObject)
            return
        end
        local go = request.gameObject
        go.name = "RocketFx"
        local img = self.boardContainer:AddComponent(UIImage, go)
        local rt = img.rectTransform
        if rt then
            rt:Set_anchorMin(0.5, 0.5)
            rt:Set_anchorMax(0.5, 0.5)
            rt:Set_pivot(0.5, 0.5)
            rt:Set_sizeDelta(size, size)
            rt:Set_anchoredPosition(sx, sy)
        end
        img:LoadSprite(sprite)
        self._rocketFxGos[#self._rocketFxGos + 1] = go

        -- 朝向目标（火箭头指向飞行方向）
        local dx, dy = tx - sx, ty - sy
        local ang = 0
        if math.atan2 then
            ang = math.deg(math.atan2(dy, dx)) - 90
        else
            ang = math.deg(math.atan(dy, dx)) - 90
        end
        if rt then rt:Set_localEulerAngles(0, 0, ang) end

        -- 飞行 tween（非链式写法，稳妥）
        local flyTween = DOTween.To(function(t)
            if rt then rt:Set_anchoredPosition(sx + dx * t, sy + dy * t) end
        end, 0, 1, flyDur)
        flyTween:SetEase(ease)
        flyTween:OnComplete(function()
            -- 抵达：爆炸（放大）后销毁 + 回调消除该格
            if go then
                if go.transform then
                    go.transform:DOScale(Vector3.New(exScale, exScale, 1), exDur)
                end
                local killTimer = TimerManager:GetInstance():GetTimer(exHold, function()
                    if go then CS.UnityEngine.GameObject.Destroy(go) end
                    if onHit then onHit() end   -- 爆炸后消除目标格
                end, self, true, false, false)
                killTimer:Start()
            elseif onHit then
                onHit()
            end
        end)
    end, self.boardContainer.transform)
end

-- 清理进行中的火箭特效 GameObject
function LianLianPlayView:CancelRocketFx()
    if self._rocketFxGos then
        for _, go in ipairs(self._rocketFxGos) do
            if go then CS.UnityEngine.GameObject.Destroy(go) end
        end
    end
    self._rocketFxGos = nil
end

-- 遮挡规则开关变更：实时重算全盘遮挡态
function LianLianPlayView:OnOcclusionRuleChanged()
    self:RefreshOcclusion()
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
    -- 任何点击选中都算盘面操作：还原提示底图
    self:HideTip()
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
    self:HideTip()   -- 洗牌/重排/类型-1 是盘面操作：还原提示底图
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
