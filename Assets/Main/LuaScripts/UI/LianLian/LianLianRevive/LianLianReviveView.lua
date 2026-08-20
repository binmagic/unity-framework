--[[
-- 连连看复活弹窗视图
--]]

local LianLianReviveView = BaseClass("LianLianReviveView", UIBaseView)
local base = UIBaseView

function LianLianReviveView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianReviveView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.descText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Desc")
    self.videoBtn = self:AddComponent(UIButton, "Panel/VideoBtn")
    self.shareBtn = self:AddComponent(UIButton, "Panel/ShareBtn")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.videoBtn:SetOnClick(BindCallback(self, self.OnVideoClick))
    self.shareBtn:SetOnClick(BindCallback(self, self.OnShareClick))
    self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
end

function LianLianReviveView:DataDefine()
end

function LianLianReviveView:DataDestroy()
end

function LianLianReviveView:OnEnable()
    base.OnEnable(self)
    local args = {self:GetUserData()}
    local data = args[1] or {}

    if self.titleText then
        self.titleText:SetText("复活")
    end
    if self.descText then
        local reviveTimes = data.reviveTimes or 0
        self.descText:SetText(string.format("观看视频可恢复3点生命值\n剩余复活次数: %d", 3 - reviveTimes))
    end
end

function LianLianReviveView:OnVideoClick()
    self.ctrl:WatchVideo()
end

function LianLianReviveView:OnShareClick()
    self.ctrl:Share()
end

function LianLianReviveView:OnCloseClick()
    self.ctrl:CloseSelf()
end

function LianLianReviveView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianReviveView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianReviveView:OnDisable()
    base.OnDisable(self)
end

function LianLianReviveView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianReviveView
