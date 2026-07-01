local LianLianSkinView = BaseClass("LianLianSkinView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.titleText = self:AddComponent(UIText, "Title")
    self.skinList = self:AddComponent(UIScrollView, "SkinList")
    self.closeBtn = self:AddComponent(UIButton, "CloseBtn")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.titleText then self.titleText:SetText("皮肤管理") end
end

local function OnAddListener(self) base.OnAddListener(self) end
local function OnRemoveListener(self) base.OnRemoveListener(self) end
local function OnDisable(self) base.OnDisable(self) end
local function OnDestroy(self) base.OnDestroy(self) end

LianLianSkinView.__init = __init
LianLianSkinView.OnCreate = OnCreate
LianLianSkinView.OnEnable = OnEnable
LianLianSkinView.OnDisable = OnDisable
LianLianSkinView.OnDestroy = OnDestroy
LianLianSkinView.OnAddListener = OnAddListener
LianLianSkinView.OnRemoveListener = OnRemoveListener

return LianLianSkinView
