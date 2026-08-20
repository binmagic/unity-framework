--[[
-- 连连看失败弹窗视图
--]]

local LianLianLoseView = BaseClass("LianLianLoseView", UIBaseView)
local base = UIBaseView

function LianLianLoseView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianLoseView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.failImage = self:AddComponent(UIImage, "Panel/FailImage")
    self.retryBtn = self:AddComponent(UIButton, "Panel/RetryBtn")
    self.shareBtn = self:AddComponent(UIButton, "Panel/ShareBtn")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.retryBtn:SetOnClick(BindCallback(self, self.OnRetryClick))
    self.shareBtn:SetOnClick(BindCallback(self, self.OnShareClick))
    self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
end

function LianLianLoseView:DataDefine()
end

function LianLianLoseView:DataDestroy()
end

function LianLianLoseView:OnEnable()
    base.OnEnable(self)
    local args = {self:GetUserData()}
    local data = args[1] or {}

    if self.titleText then
        self.titleText:SetText("失败")
    end
end

function LianLianLoseView:OnRetryClick()
    self.ctrl:Retry()
end

function LianLianLoseView:OnShareClick()
    self.ctrl:Share()
end

function LianLianLoseView:OnCloseClick()
    self.ctrl:CloseSelf()
end

function LianLianLoseView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianLoseView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianLoseView:OnDisable()
    base.OnDisable(self)
end

function LianLianLoseView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianLoseView
