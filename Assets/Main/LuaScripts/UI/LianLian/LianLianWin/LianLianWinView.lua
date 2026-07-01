--[[
-- 连连看胜利弹窗视图
--]]

local LianLianPlay = require "Game.LianLian.Model.LianLianPlay"

local LianLianWinView = BaseClass("LianLianWinView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)

    self.titleText = self:AddComponent(UIText, "Title")
    self.timeText = self:AddComponent(UIText, "TimeText")
    self.rewardText = self:AddComponent(UIText, "RewardText")
    self.nextBtn = self:AddComponent(UIButton, "NextBtn")
    self.closeBtn = self:AddComponent(UIButton, "CloseBtn")
    self.shareBtn = self:AddComponent(UIButton, "ShareBtn")
end

local function OnEnable(self)
    base.OnEnable(self)

    local args = {self:GetUserData()}
    local data = args[1] or {}

    -- 显示游戏时间
    if self.timeText and data.time then
        self.timeText:SetText("用时: " .. LianLianPlay.getTimeStr(data.time))
    end

    -- 判断是否每日完成
    if self.titleText then
        self.titleText:SetText("胜利！")
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

LianLianWinView.__init = __init
LianLianWinView.OnCreate = OnCreate
LianLianWinView.OnEnable = OnEnable
LianLianWinView.OnDisable = OnDisable
LianLianWinView.OnDestroy = OnDestroy
LianLianWinView.OnAddListener = OnAddListener
LianLianWinView.OnRemoveListener = OnRemoveListener

return LianLianWinView
