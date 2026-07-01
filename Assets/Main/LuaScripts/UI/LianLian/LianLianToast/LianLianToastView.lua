--[[
-- 连连看提示弹窗视图（Toast）
--]]

local LianLianToastView = BaseClass("LianLianToastView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    self.descText = self:AddComponent(UIText, "Desc")
    self.iconImage = self:AddComponent(UIImage, "Icon")
end

local function OnEnable(self)
    base.OnEnable(self)

    local args = {self:GetUserData()}
    local data = args[1] or {}

    if self.descText and data.desc then
        self.descText:SetText(data.desc)
    end

    -- 自动关闭
    TimerManager:GetInstance():DelayInvoke(function()
        self:CloseSelf()
    end, data.duration or 1.5)
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

LianLianToastView.__init = __init
LianLianToastView.OnCreate = OnCreate
LianLianToastView.OnEnable = OnEnable
LianLianToastView.OnDisable = OnDisable
LianLianToastView.OnDestroy = OnDestroy
LianLianToastView.OnAddListener = OnAddListener
LianLianToastView.OnRemoveListener = OnRemoveListener

return LianLianToastView
