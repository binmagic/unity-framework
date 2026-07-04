--[[
-- 连连看皮肤管理弹窗视图
--]]

local LianLianSkinView = BaseClass("LianLianSkinView", UIBaseView)
local base = UIBaseView

function LianLianSkinView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianSkinView:ComponentDefine()
    self.titleText = self:AddComponent(UITextMeshProUGUIEx, "Panel/Title")
    self.skinList = self:AddComponent(UIScrollView, "Panel/SkinList")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
end

function LianLianSkinView:DataDefine()
end

function LianLianSkinView:DataDestroy()
end

function LianLianSkinView:OnEnable()
    base.OnEnable(self)
    if self.titleText then
        self.titleText:SetText("皮肤管理")
    end
    -- TODO: 加载皮肤列表数据
end

function LianLianSkinView:OnCloseClick()
    self.ctrl:CloseSelf()
end

function LianLianSkinView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianSkinView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianSkinView:OnDisable()
    base.OnDisable(self)
end

function LianLianSkinView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianSkinView
