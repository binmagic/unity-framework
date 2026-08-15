--[[
-- added by wsh @ 2017-12-08
-- Lua侧UILayer
--]]

--[[
-- [INPUT]: 依赖 UIBaseComponent 基类、UILayer 的层级配置（Name/OrderInLayer）
-- [OUTPUT]: 对外提供 UILayerComponent 组件类，含 GetConfig 取层配置、GetOrderInLayer 取排序基准、GetActiveInHierarchy
-- [POS]: Component 层中代表一个 UI 层级节点（World/Normal/Dialog 等）的组件，由 UIManager 为每层创建；是窗口视图 view 归属判定的顶层（UIBaseComponent.OnCreate 据此确定 view）
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UILayerComponent = BaseClass("UILayerComponent", UIBaseComponent)
local base = UIBaseComponent

local function OnCreate(self, cfg)
    base.OnCreate(self)
    self.__name = self.__var_arg
	self.cfg = cfg

    self.gameObject.layer = LayerMask.NameToLayer("UI")
    local tfx = self.gameObject:GetComponent_RectTransform()
	tfx:Set_localScale(1, 1, 1)
	tfx:Set_offsetMin(0, 0)
	tfx:Set_offsetMax(0, 0)
	tfx:Set_anchorMin(0, 0)
	tfx:Set_anchorMax(1, 1)
end

function UILayerComponent:GetConfig()
	return self.cfg
end

function UILayerComponent:GetOrderInLayer()
	return self.cfg and self.cfg.OrderInLayer or 0
end

local function GetActiveInHierarchy(self)
	return self.activeSelf
end

UILayerComponent.OnCreate = OnCreate
UILayerComponent.GetActiveInHierarchy = GetActiveInHierarchy

return UILayerComponent