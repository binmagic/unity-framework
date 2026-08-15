--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.UnityEngine.CanvasGroup 原生组件
-- [OUTPUT]: 对外提供 UICanvasGroup 组件类，含 SetAlpha 整体透明度、SetInteractable 可交互、SetBlocksRaycasts 射线拦截
-- [POS]: Component 层对 CanvasGroup 的 Lua 封装，用于整组 UI 的淡入淡出与交互开关
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
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