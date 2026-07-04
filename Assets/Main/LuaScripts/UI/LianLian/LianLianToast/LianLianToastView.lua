--[[
-- 连连看提示弹窗视图（Toast）
--]]

local LianLianToastView = BaseClass("LianLianToastView", UIBaseView)
local base = UIBaseView

function LianLianToastView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianToastView:ComponentDefine()
    self.descText = self:AddComponent(UITextMeshProUGUIEx, "ToastBg/Desc")
    self.iconImage = self:AddComponent(UIImage, "ToastBg/Icon")
end

function LianLianToastView:DataDefine()
end

function LianLianToastView:DataDestroy()
end

function LianLianToastView:OnEnable()
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

function LianLianToastView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianToastView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianToastView:OnDisable()
    base.OnDisable(self)
end

function LianLianToastView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianToastView
