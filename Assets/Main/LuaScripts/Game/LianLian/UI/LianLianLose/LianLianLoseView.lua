local LianLianLoseView = BaseClass("LianLianLoseView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.titleText = self:AddComponent(UIText, "Title")
    self.failImage = self:AddComponent(UIImage, "FailImage")
    self.retryBtn = self:AddComponent(UIButton, "RetryBtn")
    self.closeBtn = self:AddComponent(UIButton, "CloseBtn")
    self.shareBtn = self:AddComponent(UIButton, "ShareBtn")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.titleText then self.titleText:SetText("失败") end
end

local function OnAddListener(self) base.OnAddListener(self) end
local function OnRemoveListener(self) base.OnRemoveListener(self) end
local function OnDisable(self) base.OnDisable(self) end
local function OnDestroy(self) base.OnDestroy(self) end

LianLianLoseView.__init = __init
LianLianLoseView.OnCreate = OnCreate
LianLianLoseView.OnEnable = OnEnable
LianLianLoseView.OnDisable = OnDisable
LianLianLoseView.OnDestroy = OnDestroy
LianLianLoseView.OnAddListener = OnAddListener
LianLianLoseView.OnRemoveListener = OnRemoveListener

return LianLianLoseView
