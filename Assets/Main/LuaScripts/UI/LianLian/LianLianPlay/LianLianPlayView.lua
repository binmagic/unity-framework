--[[
-- 连连看游戏页视图
-- 核心 UI：棋盘 + 状态栏 + 道具栏
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"
local LianLianPlay = require "Game.LianLian.Model.LianLianPlay"
local LianLianCard = require "Game.LianLian.Model.LianLianCard"
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
    self.tileItems = {}
    self.lineItems = {}
end

function LianLianPlayView:DataDestroy()
    self:CancelTipTimer()
    self:CancelClearTimer()
    self:CancelFailTimer()
    self:CancelEnterTimer()
    self.tileItems = {}
    self.lineItems = {}
    self._lineNodes = nil
    self._heartText = nil
end

function LianLianPlayView:OnEnable()
    base.OnEnable(self)
    if self.ctrl then
        self.ctrl:InitGame(1)
    end
    self:RefreshView()
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
    local direction = LianLianPlay.getDirection(self.ctrl:GetPart())
    local spriteName = DIRECTION_SPRITE[direction] or "nomove"
    local path = string.format(DIRECTION_SPRITE_PATH, spriteName)
    self.directionImage:LoadSprite(path)
end

--- 计时器：每帧刷新 TimeText
function LianLianPlayView:Update()
    if not self.ctrl or not self.ctrl.manager then return end
    if not self.ctrl.manager.state.isPlaying then return end
    local ms = self.ctrl.manager:getPlayTime()
    if self.timeText then
        self.timeText:SetText(LianLianPlay.getTimeStr(ms))
    end
end

local TILE_PREFAB = "Assets/Main/Prefabs/UI/LianLian/PrePlayItem.prefab"

-- grid 内部坐标(r,c) -> Board 容器锚点坐标（以 Board 中心为原点）
function LianLianPlayView:GridToAnchor(cell)
    local cols = self._boardCols or LianLianConst.INTERIOR_COLS
    local rows = self._boardRows or LianLianConst.INTERIOR_ROWS
    local cellSize = self._cell or 40
    local x = (cell.c - (cols + 1) / 2) * cellSize
    local y = -(cell.r - (rows + 1) / 2) * cellSize
    return x, y
end

-- 首次绘制整个棋盘：为每个非空格子异步实例化一张牌（带入场序列）
function LianLianPlayView:DrawBoard()
    if not self.boardContainer then return end
    -- 清掉旧牌
    self.tileItems = {}

    -- 依据 Board 容器实际尺寸计算格子边长（正方格，取小边）
    local rt = self.boardContainer.rectTransform
    local cols = LianLianConst.INTERIOR_COLS
    local rows = LianLianConst.INTERIOR_ROWS
    self._boardCols = cols
    self._boardRows = rows
    if rt then
        local bw = rt.rect.width
        local bh = rt.rect.height
        self._cell = math.min(bw / cols, bh / rows)
    else
        self._cell = 40
    end

    local grid = self.ctrl.manager:getGrid()
    -- 先全部创建（初始隐藏），再按入场序列逐个显示
    for key, cell in pairs(grid) do
        if cell.id ~= 0 then
            self:CreateTile(cell, true)  -- hidden=true 入场前不可见
        end
    end
    self:PlayEnterAnim()
end

-- 按 enterList 顺序逐个显示 tile（入场动画）
function LianLianPlayView:PlayEnterAnim()
    self:CancelEnterTimer()
    local enterList = self.ctrl.manager:getEnterList()
    if not enterList or #enterList == 0 then
        -- 无入场序列，直接全部显示
        for _, tile in pairs(self.tileItems) do tile:SetVisible(true) end
        return
    end
    local idx = 0
    self._enterTimer = TimerManager:GetInstance():GetTimer(0.02, function()
        idx = idx + 1
        if idx > #enterList then
            self:CancelEnterTimer()
            -- 兜底：把还没显示的都显示出来
            for _, tile in pairs(self.tileItems) do tile:SetVisible(true) end
            return
        end
        local rc = enterList[idx]
        local n = LianLianGrid.rc2n(rc)
        local tile = self.tileItems[n]
        if tile then tile:SetVisible(true) end
    end, self, false, false, false)  -- one_shot=false 循环触发
    self._enterTimer:Start()
end

function LianLianPlayView:CancelEnterTimer()
    if self._enterTimer then
        self._enterTimer:Stop()
        self._enterTimer = nil
    end
end

-- 实例化单张牌
function LianLianPlayView:CreateTile(cell, hidden)
    local n = cell.n
    local pos = { r = cell.r, c = cell.c }
    local ax, ay = self:GridToAnchor(cell)
    self.boardContainer:GameObjectInstantiateAsync(TILE_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self.tileItems then return end
        local tile = self.boardContainer:AddComponent(LianLianTileItem, request.gameObject)
        local sz = (self._cell or 40) * 0.92
        tile:SetSize(sz, sz)
        tile:SetPosition(ax, ay)
        tile:SetData(pos, cell.id, function(p) self.ctrl:OnTileClick(p) end)
        if hidden then tile:SetVisible(false) end
        self.tileItems[n] = tile
    end, self.boardContainer.transform)
end

-- 依据某个位置取 tile
function LianLianPlayView:GetTile(pos)
    if not pos then return nil end
    local n = pos.r * LianLianConst.GRID_WIDTH + pos.c
    return self.tileItems and self.tileItems[n]
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

-- 连线：沿路径显示各 tile 的方向线段（简单版）
function LianLianPlayView:DrawLine(pathLine)
    if not pathLine then return end
    self._lineNodes = pathLine
    for _, node in ipairs(pathLine) do
        local tile = self:GetTile(node)
        if tile then tile:SetLines(node) end
    end
end

function LianLianPlayView:ClearLines()
    if self._lineNodes then
        for _, node in ipairs(self._lineNodes) do
            local tile = self:GetTile(node)
            if tile then tile:HideLines() end
        end
        self._lineNodes = nil
    end
end

function LianLianPlayView:ShowChecked(pos)
    local tile = self:GetTile(pos)
    if tile then tile:SetChecked(true) end
end

function LianLianPlayView:HideChecked()
    if not self.tileItems then return end
    for _, tile in pairs(self.tileItems) do
        tile:SetChecked(false)
    end
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
    if not self.tileItems then return end
    for _, tile in pairs(self.tileItems) do
        tile:SetTip(false)
    end
end

function LianLianPlayView:CancelTipTimer()
    if self._tipTimer then
        self._tipTimer:Stop()
        self._tipTimer = nil
    end
end

-- 依据 grid 最新 id 刷新棋盘（洗牌/消除后）
function LianLianPlayView:UpdateBoard()
    if not self.tileItems then return end
    local grid = self.ctrl.manager:getGrid()
    for key, cell in pairs(grid) do
        local tile = self.tileItems[cell.n]
        if cell.id == 0 then
            if tile then tile:SetVisible(false) end
        else
            if tile then
                tile:SetData({ r = cell.r, c = cell.c }, cell.id, function(p) self.ctrl:OnTileClick(p) end)
                tile:SetVisible(true)
            else
                self:CreateTile(cell)
            end
        end
    end
end

-- 消除动画：显示连线 -> 隐藏两张牌 -> 结束回调
function LianLianPlayView:OnPlayClear(data)
    if not data then return end
    self:ClearLines()
    self:DrawLine(data.pathLine)

    self:CancelClearTimer()
    self._clearTimer = TimerManager:GetInstance():GetTimer(0.2, function()
        self:ClearLines()
        -- 隐藏被消除的两张牌
        local a, b = data.posA, data.posB
        local ta, tb = self:GetTile(a), self:GetTile(b)
        if ta then ta:SetVisible(false) end
        if tb then tb:SetVisible(false) end
        -- 触发后续（移动 + 胜负判定）
        self.ctrl:OnClearEnd()
    end, self, true, false, false)
    self._clearTimer:Start()
end

function LianLianPlayView:CancelClearTimer()
    if self._clearTimer then
        self._clearTimer:Stop()
        self._clearTimer = nil
    end
end

-- 棋盘移动后刷新牌面位置
function LianLianPlayView:OnMove(data)
    self:UpdateBoard()
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

function LianLianPlayView:OnHideChecked()
    self:HideChecked()
end

function LianLianPlayView:OnShowTip(pair)
    self:ShowTip(pair)
end

function LianLianPlayView:OnItemUpdate(data)
    self:UpdateBoard()
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
