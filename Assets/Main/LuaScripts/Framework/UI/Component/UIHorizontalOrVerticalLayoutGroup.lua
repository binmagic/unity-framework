--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.UnityEngine.UI.HorizontalOrVerticalLayoutGroup 原生布局组
-- [OUTPUT]: 对外提供 UIHorizontalOrVerticalLayoutGroup 组件类，含 GetSpacing/SetSpacing 间距、SetPaddingLeft/Right/Top/Bottom 与 GetPadding 内边距控制
-- [POS]: Component 层对水平/垂直自动布局组的 Lua 封装，用于运行时调整子元素排布间距与边距
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UIHorizontalOrVerticalLayoutGroup = BaseClass("UIHorizontalOrVerticalLayoutGroup", UIBaseContainer)
local base = UIBaseContainer
local UnityHorizontalOrVerticalLayoutGroup = typeof(CS.UnityEngine.UI.HorizontalOrVerticalLayoutGroup)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_horizontalOrVerticalLayoutGroup = self.gameObject:GetComponent(UnityHorizontalOrVerticalLayoutGroup)
end

local function OnDestroy(self)
	self.unity_horizontalOrVerticalLayoutGroup = nil
	base.OnDestroy(self)
end

local function GetPadding(self) 
	return self.unity_horizontalOrVerticalLayoutGroup.padding
end

local function GetSpacing(self)
	return self.unity_horizontalOrVerticalLayoutGroup.spacing
end

local function SetSpacing(self,value)
	self.unity_horizontalOrVerticalLayoutGroup.spacing = value
end

local function SetPaddingLeft(self,value)
	self.unity_horizontalOrVerticalLayoutGroup.padding.left = value
end

local function SetPaddingRight(self,value)
	self.unity_horizontalOrVerticalLayoutGroup.padding.right = value
end

local function SetPaddingTop(self,value)
	self.unity_horizontalOrVerticalLayoutGroup.padding.top = value
end

local function SetPaddingBottom(self,value)
	self.unity_horizontalOrVerticalLayoutGroup.padding.bottom = value
end


UIHorizontalOrVerticalLayoutGroup.OnCreate = OnCreate
UIHorizontalOrVerticalLayoutGroup.OnDestroy = OnDestroy
UIHorizontalOrVerticalLayoutGroup.GetPadding = GetPadding
UIHorizontalOrVerticalLayoutGroup.GetSpacing = GetSpacing
UIHorizontalOrVerticalLayoutGroup.SetSpacing = SetSpacing
UIHorizontalOrVerticalLayoutGroup.SetPaddingLeft = SetPaddingLeft
UIHorizontalOrVerticalLayoutGroup.SetPaddingRight = SetPaddingRight
UIHorizontalOrVerticalLayoutGroup.SetPaddingTop = SetPaddingTop
UIHorizontalOrVerticalLayoutGroup.SetPaddingBottom = SetPaddingBottom

return UIHorizontalOrVerticalLayoutGroup