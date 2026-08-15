--[[
-- [INPUT]: 依赖 UIBaseComponent 基类、CS.UnityEngine.UI.Empty4Raycast 原生组件
-- [OUTPUT]: 对外提供 UIEmpty4Raycast 组件类，含 SetColor/SetAlpha 颜色透明度、SetMaterial 材质、SetRaycastTarget/SetEnable 射线拦截开关
-- [POS]: ComponentExt 扩展组件，封装无绘制开销的射线遮挡图形；用作全屏点击拦截或引导遮罩，避免真实 Image 的顶点渲染成本
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--- Created by shimin.
--- DateTime: 2022/7/13 16:58
--- Empty4Raycast

---@class UIEmpty4Raycast : UIBaseComponent
local UIEmpty4Raycast = BaseClass("UIEmpty4Raycast", UIBaseComponent)
local base = UIBaseComponent
local UnityEmpty4RayCast = typeof(CS.UnityEngine.UI.Empty4Raycast)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	self.unity_empty_ray_cast = self.gameObject:GetComponent(UnityEmpty4RayCast)
end

-- 销毁
local function OnDestroy(self)
	self.unity_empty_ray_cast = nil
	base.OnDestroy(self)
end

local function SetMaterial(self,value)
	self.unity_empty_ray_cast.material = value
end

local function GetMaterial(self)
	return self.unity_empty_ray_cast.material
end

local function SetColor(self,value)
	self.unity_empty_ray_cast:Set_color(value.r, value.g, value.b, value.a)
end

local function SetColorRGBA(self,r,g,b,a)
	self.unity_empty_ray_cast:Set_color(r, g, b, a)
end

local function GetColorRGBA(self)
	return self.unity_empty_ray_cast:Get_color()
end

local function GetColor(self)
	local r,g,b,a = self:GetColorRGBA()
	return Color.New(r,g,b,a)
end

local function SetAlpha(self,value)
	local color = self:GetColor()
	self:SetColorRGBA(color.r,color.g,color.b,value)
end


local function SetEnable(self,enable)
	self.unity_empty_ray_cast.enabled = enable
end

local function SetRaycastTarget(self,enable)
	self.unity_empty_ray_cast.raycastTarget = enable
end

UIEmpty4Raycast.OnCreate = OnCreate
UIEmpty4Raycast.OnDestroy = OnDestroy
UIEmpty4Raycast.SetMaterial = SetMaterial
UIEmpty4Raycast.GetMaterial = GetMaterial
UIEmpty4Raycast.SetColor = SetColor
UIEmpty4Raycast.SetColorRGBA = SetColorRGBA
UIEmpty4Raycast.GetColorRGBA = GetColorRGBA
UIEmpty4Raycast.GetColor = GetColor
UIEmpty4Raycast.SetAlpha = SetAlpha
UIEmpty4Raycast.SetEnable = SetEnable
UIEmpty4Raycast.SetRaycastTarget = SetRaycastTarget
return UIEmpty4Raycast