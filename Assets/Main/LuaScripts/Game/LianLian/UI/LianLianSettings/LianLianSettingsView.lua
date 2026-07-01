local LianLianSettingsView = BaseClass("LianLianSettingsView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.titleText = self:AddComponent(UIText, "Title")
    self.soundToggle = self:AddComponent(UIToggle, "SoundToggle")
    self.bgmToggle = self:AddComponent(UIToggle, "BgmToggle")
    self.vibrateToggle = self:AddComponent(UIToggle, "VibrateToggle")
    self.closeBtn = self:AddComponent(UIButton, "CloseBtn")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.titleText then self.titleText:SetText("设置") end
end

local function OnAddListener(self) base.OnAddListener(self) end
local function OnRemoveListener(self) base.OnRemoveListener(self) end
local function OnDisable(self) base.OnDisable(self) end
local function OnDestroy(self) base.OnDestroy(self) end

LianLianSettingsView.__init = __init
LianLianSettingsView.OnCreate = OnCreate
LianLianSettingsView.OnEnable = OnEnable
LianLianSettingsView.OnDisable = OnDisable
LianLianSettingsView.OnDestroy = OnDestroy
LianLianSettingsView.OnAddListener = OnAddListener
LianLianSettingsView.OnRemoveListener = OnRemoveListener

return LianLianSettingsView
