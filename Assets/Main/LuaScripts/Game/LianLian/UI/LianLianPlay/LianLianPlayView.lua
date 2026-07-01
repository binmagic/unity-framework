local LianLianConst = require "Game.LianLian.Config.LianLianConst"
local LianLianGrid = require "Game.LianLian.Model.LianLianGrid"

local LianLianPlayView = BaseClass("LianLianPlayView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
    self.tileItems = {}
    self.lineItems = {}
end

local function OnCreate(self)
    base.OnCreate(self)
    self.levelText = self:AddComponent(UIText, "TopBar/LevelText")
    self.timeText = self:AddComponent(UIText, "TopBar/TimeText")
    self.directionImage = self:AddComponent(UIImage, "TopBar/DirectionIcon")
    self.heartContainer = self:AddComponent(UIBaseContainer, "TopBar/Hearts")
    self.boardContainer = self:AddComponent(UIBaseContainer, "Board")
    self.tipBtn = self:AddComponent(UIButton, "BottomBar/TipBtn")
    self.shuffleBtn = self:AddComponent(UIButton, "BottomBar/ShuffleBtn")
    self.hpBtn = self:AddComponent(UIButton, "BottomBar/HpBtn")
    self.tipCountText = self:AddComponent(UIText, "BottomBar/TipBtn/Count")
    self.shuffleCountText = self:AddComponent(UIText, "BottomBar/ShuffleBtn/Count")
    self.hpCountText = self:AddComponent(UIText, "BottomBar/HpBtn/Count")
    self.backBtn = self:AddComponent(UIButton, "BackBtn")
    self.lineContainer = self:AddComponent(UIBaseContainer, "Lines")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.levelText then
        self.levelText:SetText(string.format("第 %d 关", self.ctrl:GetPart()))
    end
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

function LianLianPlayView:OnHpUpdate(data) end
function LianLianPlayView:OnShowChecked(pos) end
function LianLianPlayView:OnHideChecked() end
function LianLianPlayView:OnShowTip(pair) end
function LianLianPlayView:OnItemUpdate(data) end

function LianLianPlayView:OnGameOver(data)
    if data.isWin then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianWin, data)
    elseif data.canRevive then
        UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianRevive, data)
    else
        UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianLose, data)
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
