local LianLianMainView = BaseClass("LianLianMainView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.startBtn = self:AddComponent(UIButton, "StartBtn")
    self.settingsBtn = self:AddComponent(UIButton, "SettingsBtn")
    self.skinBtn = self:AddComponent(UIButton, "SkinBtn")
    self.titleText = self:AddComponent(UIText, "Title")
    self.bgImage = self:AddComponent(UIImage, "Bg")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.titleText then
        self.titleText:SetText("连了又连")
    end
end

local function OnAddListener(self)
    base.OnAddListener(self)
end

local function OnRemoveListener(self)
    base.OnRemoveListener(self)
end

local function OnDisable(self)
    base.OnDisable(self)
end

local function OnDestroy(self)
    base.OnDestroy(self)
end

LianLianMainView.__init = __init
LianLianMainView.OnCreate = OnCreate
LianLianMainView.OnEnable = OnEnable
LianLianMainView.OnDisable = OnDisable
LianLianMainView.OnDestroy = OnDestroy
LianLianMainView.OnAddListener = OnAddListener
LianLianMainView.OnRemoveListener = OnRemoveListener

return LianLianMainView
