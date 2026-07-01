--[[
-- 连连看游戏页视图
-- 核心 UI：棋盘 + 状态栏 + 道具栏
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"

local LianLianPlayView = BaseClass("LianLianPlayView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
    self.tileItems = {}     -- 牌面 UI 对象
    self.lineItems = {}     -- 连线 UI 对象
end

local function OnCreate(self)
    base.OnCreate(self)

    -- 顶部状态栏
    self.levelText = self:AddComponent(UIText, "TopBar/LevelText")
    self.timeText = self:AddComponent(UIText, "TopBar/TimeText")
    self.directionImage = self:AddComponent(UIImage, "TopBar/DirectionIcon")

    -- 生命值心形容器
    self.heartContainer = self:AddComponent(UIBaseContainer, "TopBar/Hearts")

    -- 棋盘容器
    self.boardContainer = self:AddComponent(UIBaseContainer, "Board")

    -- 底部道具栏
    self.tipBtn = self:AddComponent(UIButton, "BottomBar/TipBtn")
    self.shuffleBtn = self:AddComponent(UIButton, "BottomBar/ShuffleBtn")
    self.hpBtn = self:AddComponent(UIButton, "BottomBar/HpBtn")
    self.tipCountText = self:AddComponent(UIText, "BottomBar/TipBtn/Count")
    self.shuffleCountText = self:AddComponent(UIText, "BottomBar/ShuffleBtn/Count")
    self.hpCountText = self:AddComponent(UIText, "BottomBar/HpBtn/Count")

    -- 返回按钮
    self.backBtn = self:AddComponent(UIButton, "BackBtn")

    -- 连线容器
    self.lineContainer = self:AddComponent(UIBaseContainer, "Lines")
end

local function OnEnable(self)
    base.OnEnable(self)

    -- 初始化游戏
    if self.ctrl then
        self.ctrl:InitGame(1)
    end

    self:RefreshView()
end

--- 刷新界面
function LianLianPlayView:RefreshView()
    -- 更新关卡显示
    if self.levelText then
        self.levelText:SetText(string.format("第 %d 关", self.ctrl:GetPart()))
    end

    -- 更新生命值
    self:UpdateHearts()

    -- 更新道具数量
    self:UpdateCardCounts()
end

--- 更新生命值心形显示
function LianLianPlayView:UpdateHearts()
    local hp = self.ctrl:GetHp()
    -- TODO: 根据 hp 值显示/隐藏心形图标
end

--- 更新道具数量显示
function LianLianPlayView:UpdateCardCounts()
    -- TODO: 从管理器获取道具数量并更新文本
end

--- 绘制连线
--- @param pathLine table 连线数据
function LianLianPlayView:DrawLine(pathLine)
    -- TODO: 在 lineContainer 中创建连线 UI
end

--- 清除连线
function LianLianPlayView:ClearLines()
    -- TODO: 销毁所有连线 UI
end

--- 高亮选中的牌
function LianLianPlayView:ShowChecked(pos)
    -- TODO: 给指定位置的牌添加高亮效果
end

--- 取消所有高亮
function LianLianPlayView:HideChecked()
    -- TODO: 移除所有牌的高亮效果
end

--- 高亮提示牌对
function LianLianPlayView:ShowTip(pair)
    -- TODO: 给提示的两张牌添加特殊高亮
end

--- 更新棋盘（洗牌后）
function LianLianPlayView:UpdateBoard()
    -- TODO: 刷新所有牌面的显示
end

local function OnAddListener(self)
    base.OnAddListener(self)

    self:AddUIListener("LianLian_HpUpdate", self.OnHpUpdate)
    self:AddUIListener("LianLian_ItemShowChecked", self.OnShowChecked)
    self:AddUIListener("LianLian_ItemHideChecked", self.OnHideChecked)
    self:AddUIListener("LianLian_ItemShowTip", self.OnShowTip)
    self:AddUIListener("LianLian_ItemUpdate", self.OnItemUpdate)
    self:AddUIListener("LianLian_GameOver", self.OnGameOver)
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

local function OnRemoveListener(self)
    base.OnRemoveListener(self)
end

local function OnDisable(self)
    base.OnDisable(self)
end

local function OnDestroy(self)
    self.tileItems = {}
    self.lineItems = {}
    base.OnDestroy(self)
end

LianLianPlayView.__init = __init
LianLianPlayView.OnCreate = OnCreate
LianLianPlayView.OnEnable = OnEnable
LianLianPlayView.OnDisable = OnDisable
LianLianPlayView.OnDestroy = OnDestroy
LianLianPlayView.OnAddListener = OnAddListener
LianLianPlayView.OnRemoveListener = OnRemoveListener

return LianLianPlayView
