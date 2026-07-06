--[[
-- 连连看主菜单视图
--]]

local LianLianMainView = BaseClass("LianLianMainView", UIBaseView)
local base = UIBaseView

function LianLianMainView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianMainView:ComponentDefine()
    self.bgImage = self:AddComponent(UIImage, "Bg")
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Content/Title")
    self.startBtn = self:AddComponent(UIButton, "Content/StartBtn")
    self.settingsBtn = self:AddComponent(UIButton, "Content/SettingsBtn")
    self.skinBtn = self:AddComponent(UIButton, "Content/SkinBtn")

    self.startBtn:SetOnClick(BindCallback(self, self.OnStartClick))
    self.settingsBtn:SetOnClick(BindCallback(self, self.OnSettingsClick))
    self.skinBtn:SetOnClick(BindCallback(self, self.OnSkinClick))
end

function LianLianMainView:DataDefine()
end

function LianLianMainView:DataDestroy()
end

function LianLianMainView:OnEnable()
    base.OnEnable(self)
    self:RefreshView()
end

function LianLianMainView:RefreshView()
    if self.titleText then
        self.titleText:SetText("连了又连")
    end
end

function LianLianMainView:OnStartClick()
    self.ctrl:StartGame()
end

function LianLianMainView:OnSettingsClick()
    self.ctrl:OpenSettings()
end

function LianLianMainView:OnSkinClick()
    self.ctrl:OpenSkin()
end

function LianLianMainView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianMainView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianMainView:OnDisable()
    base.OnDisable(self)
end

function LianLianMainView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianMainView
