--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.UnityEngine.UI.LayoutElement 原生布局元素
-- [OUTPUT]: 对外提供 UILayoutElement 组件类，含 SetPreferredWidth/Height、SetMinWidth/Height 与 GetMinWidth/Height、GetUnityHandler 取原生组件
-- [POS]: Component 层对 LayoutElement 的 Lua 封装，配合布局组控制单个元素的首选/最小尺寸
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UILayoutElement = BaseClass("UILayoutElement", UIBaseContainer)
local base = UIBaseContainer
local UnityLayoutElement = typeof(CS.UnityEngine.UI.LayoutElement)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_LayoutElement = self.gameObject:GetComponent(UnityLayoutElement)
end

local function OnDestroy(self)
	self.unity_LayoutElement = nil
	base.OnDestroy(self)
end

local function GetUnityHandler(self)
	return self.unity_LayoutElement
end

local function SetPreferredHeight(self,value)
	self.unity_LayoutElement.preferredHeight = value
end

local function SetPreferredWidth(self,value)
	self.unity_LayoutElement.preferredWidth = value
end

local function SetMinHeight(self,value)
	self.unity_LayoutElement.minHeight = value
end

local function SetMinWidth(self, value)
	self.unity_LayoutElement.minWidth = value
end

local function GetMinWidth(self)
	return self.unity_LayoutElement.minWidth
end

local function GetMinHeight(self)
	return self.unity_LayoutElement.minHeight
end

UILayoutElement.OnCreate = OnCreate
UILayoutElement.OnDestroy = OnDestroy
UILayoutElement.SetPreferredHeight = SetPreferredHeight
UILayoutElement.SetPreferredWidth = SetPreferredWidth
UILayoutElement.SetMinHeight = SetMinHeight
UILayoutElement.SetMinWidth = SetMinWidth
UILayoutElement.GetMinWidth = GetMinWidth
UILayoutElement.GetMinHeight = GetMinHeight
UILayoutElement.GetUnityHandler = GetUnityHandler

return UILayoutElement