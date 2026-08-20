--[[
-- 连连看设置弹窗视图
--]]

local LianLianSettingsView = BaseClass("LianLianSettingsView", UIBaseView)
local base = UIBaseView

function LianLianSettingsView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianSettingsView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.soundToggle = self:AddComponent(UIToggle, "Panel/SoundToggle")
    self.bgmToggle = self:AddComponent(UIToggle, "Panel/BgmToggle")
    self.vibrateToggle = self:AddComponent(UIToggle, "Panel/VibrateToggle")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
end

function LianLianSettingsView:DataDefine()
end

function LianLianSettingsView:DataDestroy()
end

function LianLianSettingsView:OnEnable()
    base.OnEnable(self)
    if self.titleText then
        self.titleText:SetText("设置")
    end
    -- TODO: 从存储中读取设置状态
end

function LianLianSettingsView:OnCloseClick()
    self.ctrl:CloseSelf()
end

function LianLianSettingsView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianSettingsView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianSettingsView:OnDisable()
    base.OnDisable(self)
end

function LianLianSettingsView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianSettingsView
