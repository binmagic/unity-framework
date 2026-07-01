local LianLianLevelupView = BaseClass("LianLianLevelupView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.titleText = self:AddComponent(UIText, "Title")
    self.descText = self:AddComponent(UIText, "Desc")
    self.continueBtn = self:AddComponent(UIButton, "ContinueBtn")
end

local function OnEnable(self)
    base.OnEnable(self)
    if self.titleText then self.titleText:SetText("升级！") end
    if self.descText then self.descText:SetText("教学关完成，即将进入正式关卡") end
end

local function OnAddListener(self) base.OnAddListener(self) end
local function OnRemoveListener(self) base.OnRemoveListener(self) end
local function OnDisable(self) base.OnDisable(self) end
local function OnDestroy(self) base.OnDestroy(self) end

LianLianLevelupView.__init = __init
LianLianLevelupView.OnCreate = OnCreate
LianLianLevelupView.OnEnable = OnEnable
LianLianLevelupView.OnDisable = OnDisable
LianLianLevelupView.OnDestroy = OnDestroy
LianLianLevelupView.OnAddListener = OnAddListener
LianLianLevelupView.OnRemoveListener = OnRemoveListener

return LianLianLevelupView
