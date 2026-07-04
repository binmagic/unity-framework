--[[
-- 连连看游戏页视图
-- 核心 UI：棋盘 + 状态栏 + 道具栏
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"
local LianLianTileItem = require "UI.LianLian.LianLianPlay.LianLianTileItem"

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
    self.tileItems = {}
    self.lineItems = {}
    self._lineNodes = nil
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
    self:UpdateHearts()
    self:UpdateCardCounts()
    self:DrawBoard()
end

local TILE_PREFAB = "Assets/Main/Prefabs/UI/LianLian/PrePlayItem.prefab"
local CELL = LianLianConst.CELL_SIZE
local OFFSET_X = -(LianLianConst.GRID_WIDTH * CELL) / 2   -- 居中偏移
local OFFSET_Y = (LianLianConst.GRID_HEIGHT * CELL) / 2

-- grid 坐标(cocos 系) -> Board 容器锚点坐标
function LianLianPlayView:GridToAnchor(cell)
    return cell.x + OFFSET_X, cell.y + OFFSET_Y
end

-- 首次绘制整个棋盘：为每个非空格子异步实例化一张牌
function LianLianPlayView:DrawBoard()
    if not self.boardContainer then return end
    -- 清掉旧牌
    self.tileItems = {}

    local grid = self.ctrl.manager:getGrid()
    for key, cell in pairs(grid) do
        if cell.id ~= 0 then
            self:CreateTile(cell)
        end
    end
end

-- 实例化单张牌
function LianLianPlayView:CreateTile(cell)
    local n = cell.n
    local pos = { r = cell.r, c = cell.c }
    local ax, ay = self:GridToAnchor(cell)
    self.boardContainer:GameObjectInstantiateAsync(TILE_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self.tileItems then return end
        local tile = self.boardContainer:AddComponent(LianLianTileItem, request.gameObject)
        tile:SetSize(CELL, CELL)
        tile:SetPosition(ax, ay)
        tile:SetData(pos, cell.id, function(p) self.ctrl:OnTileClick(p) end)
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
    if not self.heartText then
        -- Hearts 容器下没有独立心图标时，用文本兜底显示
        self.heartText = self.heartText
    end
    local hp = self.ctrl and self.ctrl:GetHp() or 0
    -- 简单显示：优先尝试给 Hearts 容器子节点显隐，否则忽略
    if self.levelText then
        -- 不覆盖关卡文本，这里仅在有独立 hp 文本时更新
    end
    self._hp = hp
end

function LianLianPlayView:UpdateCardCounts()
    -- 占位：道具数量暂固定显示，逻辑闭环后接入真实库存
    if self.tipCountText then self.tipCountText:SetText("1") end
    if self.shuffleCountText then self.shuffleCountText:SetText("1") end
    if self.hpCountText then self.hpCountText:SetText("1") end
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
