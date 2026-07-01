--[[
-- 连连看测试视图（最简）
--]]

local LianLianTestView = BaseClass("LianLianTestView", UIBaseView)
local base = UIBaseView

local function __init(self, holder, winName, ctrl, config)
    base.__init(self, holder, winName, ctrl, config)
end

local function OnCreate(self)
    base.OnCreate(self)
    -- 只绑定一个背景图
    self.bgImage = self:AddComponent(UIImage, "Bg")
end

local function OnEnable(self)
    base.OnEnable(self)
end

local function OnDisable(self)
    base.OnDisable(self)
end

local function OnDestroy(self)
    base.OnDestroy(self)
end

LianLianTestView.__init = __init
LianLianTestView.OnCreate = OnCreate
LianLianTestView.OnEnable = OnEnable
LianLianTestView.OnDisable = OnDisable
LianLianTestView.OnDestroy = OnDestroy

return LianLianTestView
