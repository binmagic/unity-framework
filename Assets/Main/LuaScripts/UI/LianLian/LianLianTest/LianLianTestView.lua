--[[
-- 连连看测试视图（最简）
--]]

local LianLianTestView = BaseClass("LianLianTestView", UIBaseView)
local base = UIBaseView

function LianLianTestView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function LianLianTestView:ComponentDefine()
    self.bgImage = self:AddComponent(UIImage, "Bg")
end

function LianLianTestView:DataDefine()
end

function LianLianTestView:DataDestroy()
end

function LianLianTestView:OnEnable()
    base.OnEnable(self)
end

function LianLianTestView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianTestView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianTestView:OnDisable()
    base.OnDisable(self)
end

function LianLianTestView:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

return LianLianTestView
