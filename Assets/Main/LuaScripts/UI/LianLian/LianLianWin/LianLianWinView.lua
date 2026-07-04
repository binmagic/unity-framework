--[[
-- 连连看胜利弹窗视图
--]]

local LianLianPlay = require "Game.LianLian.Model.LianLianPlay"

local LianLianWinView = BaseClass("LianLianWinView", UIBaseView)
local base = UIBaseView

function LianLianWinView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianWinView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.timeText = self:AddComponent(UITextMeshProUGUIEx, "Panel/TimeText")
    self.rewardText = self:AddComponent(UITextMeshProUGUIEx, "Panel/RewardText")
    self.nextBtn = self:AddComponent(UIButton, "Panel/NextBtn")
    self.shareBtn = self:AddComponent(UIButton, "Panel/ShareBtn")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.nextBtn:SetOnClick(BindCallback(self, self.OnNextClick))
    self.shareBtn:SetOnClick(BindCallback(self, self.OnShareClick))
    self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
end

function LianLianWinView:DataDefine()
end

function LianLianWinView:DataDestroy()
end

function LianLianWinView:OnEnable()
    base.OnEnable(self)
    local args = {self:GetUserData()}
    local data = args[1] or {}

    if self.titleText then
        self.titleText:SetText("胜利！")
    end
    if self.timeText and data.time then
        self.timeText:SetText("用时: " .. LianLianPlay.getTimeStr(data.time))
    end
end

function LianLianWinView:OnNextClick()
    self.ctrl:NextLevel()
end

function LianLianWinView:OnShareClick()
    self.ctrl:Share()
end

function LianLianWinView:OnCloseClick()
    self.ctrl:CloseSelf()
end

function LianLianWinView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianWinView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianWinView:OnDisable()
    base.OnDisable(self)
end

function LianLianWinView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianWinView
