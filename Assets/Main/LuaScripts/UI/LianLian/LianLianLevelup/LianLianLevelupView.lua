--[[
-- 连连看升级弹窗视图（Part 1 教学关完成后）
--]]

local LianLianLevelupView = BaseClass("LianLianLevelupView", UIBaseView)
local base = UIBaseView

function LianLianLevelupView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianLevelupView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.descText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Desc")
    self.continueBtn = self:AddComponent(UIButton, "Panel/ContinueBtn")

    self.continueBtn:SetOnClick(BindCallback(self, self.OnContinueClick))
end

function LianLianLevelupView:DataDefine()
end

function LianLianLevelupView:DataDestroy()
end

function LianLianLevelupView:OnEnable()
    base.OnEnable(self)
    local args = {self:GetUserData()}
    local data = args[1] or {}

    if self.titleText then
        self.titleText:SetText("升级！")
    end
    if self.descText then
        self.descText:SetText("教学关完成，即将进入正式关卡")
    end
end

function LianLianLevelupView:OnContinueClick()
    self.ctrl:Continue()
end

function LianLianLevelupView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianLevelupView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianLevelupView:OnDisable()
    base.OnDisable(self)
end

function LianLianLevelupView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianLevelupView
