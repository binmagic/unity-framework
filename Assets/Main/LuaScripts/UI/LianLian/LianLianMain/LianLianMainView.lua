--[[
-- 连连看主菜单视图
--]]

local LianLianMainView = BaseClass("LianLianMainView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)

    -- 按钮绑定
    self.startBtn = self:AddComponent(UIButton, "StartBtn")
    self.settingsBtn = self:AddComponent(UIButton, "SettingsBtn")
    self.skinBtn = self:AddComponent(UIButton, "SkinBtn")

    -- 标题
    self.titleText = self:AddComponent(UIText, "Title")

    -- 背景图
    self.bgImage = self:AddComponent(UIImage, "Bg")

    -- 按钮点击事件
    self.startBtn:SetOnClick(function()
        self.ctrl:StartGame()
    end)

    self.settingsBtn:SetOnClick(function()
        self.ctrl:OpenSettings()
    end)

    self.skinBtn:SetOnClick(function()
        self.ctrl:OpenSkin()
    end)
end

local function OnEnable(self)
    base.OnEnable(self)
    self:RefreshView()
end

function LianLianMainView:RefreshView()
    if self.titleText then
        self.titleText:SetText("连了又连")
    end
end

local function OnAddListener(self)
    base.OnAddListener(self)
    -- 监听皮肤切换事件
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
