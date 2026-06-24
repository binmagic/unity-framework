---@class UICanvasGroup : UIBaseContainer
local UICanvasGroup = BaseClass("UICanvasGroup", UIBaseContainer)
local base = UIBaseContainer
local UnityCanvasGroup = typeof(CS.UnityEngine.CanvasGroup)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_canvas_group = self.gameObject:GetComponent(UnityCanvasGroup)
end

local function OnDestroy(self)
	self.unity_canvas_group = nil
	base.OnDestroy(self)
end

local function Play(self,name,layer,normalizedTime)
	self.unity_canvas_group:Play(name,layer,normalizedTime)
end

local function SetAlpha(self,value)
	self.unity_canvas_group.alpha = value
end

local function SetInteractable(self,value)
	self.unity_canvas_group.interactable = value
end

local function SetBlocksRaycasts(self,value)
	self.unity_canvas_group.blocksRaycasts = value
end


UICanvasGroup.OnCreate = OnCreate
UICanvasGroup.OnDestroy = OnDestroy
UICanvasGroup.SetAlpha = SetAlpha
UICanvasGroup.SetInteractable = SetInteractable
UICanvasGroup.SetBlocksRaycasts = SetBlocksRaycasts

return UICanvasGroup