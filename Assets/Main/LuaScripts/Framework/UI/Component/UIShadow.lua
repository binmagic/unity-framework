--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.UnityEngine.UI.Shadow 原生阴影组件
-- [OUTPUT]: 对外提供 UIShadow 组件类，含 Enable/AllEnable 开关、SetAllColor 阴影颜色
-- [POS]: Component 层对 UGUI Shadow 的 Lua 封装，用于文本/图片投影效果控制
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UIShadow = BaseClass("UIShadow", UIBaseContainer)
local base = UIBaseContainer
local UnityShadow = typeof(CS.UnityEngine.UI.Shadow)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_shadows = self.gameObject:GetComponents(UnityShadow)
end

local function OnDestroy(self)
	self.unity_shadows = nil
	base.OnDestroy(self)
end

local function Enable(self,value)
	self.unity_shadows[0].enabled = value
end

local function AllEnable(self,value)
	for i=0,self.unity_shadows.Length -1 do
		self.unity_shadows[i].enabled = value
	end
end
local function SetAllColor(self,value)
	for i=0,self.unity_shadows.Length -1 do
		self.unity_shadows[i].effectColor = value
	end
end

UIShadow.OnCreate = OnCreate
UIShadow.OnDestroy = OnDestroy
UIShadow.Enable = Enable
UIShadow.AllEnable = AllEnable
UIShadow.SetAllColor = SetAllColor

return UIShadow