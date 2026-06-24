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