--[[
-- added by wsh @ 2017-12-08
-- Lua侧UIImage
--]]

---@class UIImage : UIBaseComponent
--[[
-- [INPUT]: 依赖 UIBaseComponent 基类、CS.UnityEngine.UI.Image 原生组件（经 GetComponent_Image/LoadSprite/LoadHeadEx 底层扩展）
-- [OUTPUT]: 对外提供 UIImage 组件类，含 LoadSprite 加载贴图、LoadHeadEx 加载头像、SetFillAmount/GetFillAmount 填充、SetColor/SetAlpha 颜色、SetMaterial、SetNativeSize/SetSizeByWidth/SetSizeByHeight 尺寸、SetRaycastTarget/SetEnable
-- [POS]: Component 层最基础的图片组件，界面绝大多数静态图使用；与 CircleImage/UIRawImage 分别对应圆形与纹理场景
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UIImage = BaseClass("UIImage", UIBaseComponent)
local base = UIBaseComponent
local UnityImage = typeof(CS.UnityEngine.UI.Image)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	self.unity_image = self.gameObject:GetComponent_Image()
end

local function LoadSprite(self, sprite_path, default_sprite)
	if self.spritePath == sprite_path then
		return
	end
	self.spritePath = sprite_path
	-- 直接在底层处理一下
	self.unity_image:LoadSprite(_ToID(sprite_path), default_sprite)
end

--加载头像
local function LoadHeadEx(self, uid, pic, picVer, default_sprite, callback)
	self.unity_image:LoadHeadEx(uid, pic, picVer, default_sprite, callback)
end

-- 销毁
local function OnDestroy(self)
	self.unity_image = nil
	base.OnDestroy(self)
end

local function SetFillAmount(self,value)
	self.unity_image.fillAmount = value
end

local function GetFillAmount(self)
	return self.unity_image.fillAmount
end

local function SetMaterial(self,value)
	self.unity_image.material = value
end

local function GetMaterial(self)
	return self.unity_image.material
end

local function GetImage(self)
	return self.unity_image.sprite
end

local function SetImage(self,value)
	self.unity_image.sprite = value
end

local function SetColor(self,value)
	--self.unity_image.color = value
	self.unity_image:Set_color(value.r, value.g, value.b, value.a)
end

local function SetColorRGBA(self,r,g,b,a)
	--self.unity_image.color = value
	self.unity_image:Set_color(r, g, b, a)
end

local function GetColorRGBA(self)
	return self.unity_image:Get_color()
end

local function GetColor(self)
	local r,g,b,a = self:GetColorRGBA()
	return Color.New(r,g,b,a)
end

local function SetAlpha(self,value)
	local color = self:GetColor()
	self:SetColorRGBA(color.r,color.g,color.b,value)
end

local function SetNativeSize(self)
	self.unity_image:SetNativeSize()
end

local function SetEnable(self,enable)
	self.unity_image.enabled = enable
end

local function SetRaycastTarget(self,raycastTarget)
	self.unity_image.raycastTarget = raycastTarget
end

-- 按原始比例设置图片尺寸到指定宽
local function SetSizeByWidth(self, width)
	self.unity_image:SetNativeSize()
	local w, h = self.unity_image.rectTransform:Get_sizeDelta()
	local scale = w / width
	local height = h / scale
	self.unity_image.rectTransform:Set_sizeDelta(width, height)
end

-- 按原始比例设置图片尺寸到指定高
local function SetSizeByHeight(self, height)
	self.unity_image:SetNativeSize()
	local w, h = self.unity_image.rectTransform:Get_sizeDelta()
	local scale = h / height
	local width = w / scale
	self.unity_image.rectTransform:Set_sizeDelta(width, height)
end

-- 按原始比例设置图片尺寸到指定宽或高(宽/高中的大值)
local function SetSizeByWidthOrHeight(self, value)
	self.unity_image:SetNativeSize()
	local w, h = self.unity_image.rectTransform:Get_sizeDelta()
	if w > h then
		local scale = w / value
		local height = h / scale
		self.unity_image.rectTransform:Set_sizeDelta(value, height)
	else
		local scale = h / value
		local width = w / scale
		self.unity_image.rectTransform:Set_sizeDelta(width, value)
	end
end

local function SetWidth(self, width)
	local w, h = self.unity_image.rectTransform:Get_sizeDelta()
	self.unity_image.rectTransform:Set_sizeDelta(width, h)
end

local function SetHeight(self, height)
	local w, h = self.unity_image.rectTransform:Get_sizeDelta()
	self.unity_image.rectTransform:Set_sizeDelta(w, height)
end

UIImage.OnCreate = OnCreate
UIImage.LoadSprite = LoadSprite
UIImage.OnDestroy = OnDestroy
UIImage.SetFillAmount = SetFillAmount
UIImage.GetFillAmount = GetFillAmount
UIImage.SetMaterial = SetMaterial
UIImage.GetMaterial = GetMaterial
UIImage.GetImage = GetImage
UIImage.SetImage = SetImage
UIImage.LoadHeadEx = LoadHeadEx
UIImage.SetColor = SetColor
UIImage.SetColorRGBA = SetColorRGBA
UIImage.GetColorRGBA = GetColorRGBA
UIImage.GetColor = GetColor
UIImage.SetAlpha = SetAlpha
UIImage.SetNativeSize = SetNativeSize
UIImage.SetEnable = SetEnable
UIImage.SetRaycastTarget = SetRaycastTarget
UIImage.SetSizeByWidth = SetSizeByWidth
UIImage.SetSizeByHeight = SetSizeByHeight
UIImage.SetSizeByWidthOrHeight = SetSizeByWidthOrHeight
UIImage.SetWidth = SetWidth
UIImage.SetHeight = SetHeight

return UIImage