--[[
-- 连连看复活弹窗视图
--]]

local LianLianReviveView = BaseClass("LianLianReviveView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)

    self.titleText = self:AddComponent(UIText, "Title")
    self.descText = self:AddComponent(UIText, "Desc")
    self.videoBtn = self:AddComponent(UIButton, "VideoBtn")
    self.shareBtn = self:AddComponent(UIButton, "ShareBtn")
    self.closeBtn = self:AddComponent(UIButton, "CloseBtn")
end

local function OnEnable(self)
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

LianLianReviveView.__init = __init
LianLianReviveView.OnCreate = OnCreate
LianLianReviveView.OnEnable = OnEnable
LianLianReviveView.OnDisable = OnDisable
LianLianReviveView.OnDestroy = OnDestroy
LianLianReviveView.OnAddListener = OnAddListener
LianLianReviveView.OnRemoveListener = OnRemoveListener

return LianLianReviveView
