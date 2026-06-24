--[[
-- added by wsh @ 2017-12-18
-- Lua侧UISlider
-- 使用方式：
-- self.xxx_text = self:AddComponent(UISlider, var_arg)--添加孩子，各种重载方式查看UIBaseContainer
--]]

---@class UISlider : UIBaseComponent
local UISlider = BaseClass("UISlider", UIBaseComponent)
local base = UIBaseComponent
local UnitySlider = typeof(CS.UnityEngine.UI.Slider)
local UnityImage = typeof(CS.UnityEngine.UI.Image)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_uislider = self.gameObject:GetComponent(UnitySlider)
	self.unity_fillImage = self.unity_uislider.fillRect:GetComponent(UnityImage)
	
	if self.unity_uislider == nil then
		Logger.LogError("unity_uislider is nil!!")
	end
end

-- 获取进度
local function GetValue(self)
	return self.unity_uislider.value
end

-- 设置进度
local function SetValue(self, value)
	self.unity_uislider.value = value
end

local function SetOnValueChanged(self, action)
	if action then
		if self.__onvaluechanged then
			self.unity_uislider.onValueChanged:RemoveListener(self.__onvaluechanged)
		end
		self.__onvaluechanged = function ()
			if action then
				action(self:GetValue())
			end
			end
		self.unity_uislider.onValueChanged:AddListener(self.__onvaluechanged)
	elseif self.__onvaluechanged then
		self.unity_uislider.onValueChanged:RemoveListener(self.__onvaluechanged)
		self.__onvaluechanged = nil
	end
end

-- 销毁
local function OnDestroy(self)
	if self.__onvaluechanged ~= nil then
		self.unity_uislider.onValueChanged:RemoveListener(self.__onvaluechanged)
	end
	pcall(function() self.unity_uislider.onValueChanged:Invoke() end)
	self.unity_uislider = nil
	self.__onvaluechanged = nil
	base.OnDestroy(self)
end

local function SetInteractable(self,value)
	self.unity_uislider.interactable = value
end

local function DOValue(self,endValue,duration,callBack)
	local tween = self.unity_uislider:DOValue(endValue,duration)
	tween:OnComplete(function()
		callBack()
	end)
	return tween
end

local function SetFillColor(self, value)
	if self.unity_fillImage == nil then
		return
	end

	self.unity_fillImage:Set_color(value.r, value.g, value.b, value.a)
end

function UISlider:IsNil()  
	return self.unity_uislider == nil
end

-- 获取进度
function UISlider.SetMaxValue(self,maxValue)
	self.unity_uislider.maxValue = maxValue
end

UISlider.OnCreate = OnCreate
UISlider.GetValue = GetValue
UISlider.SetValue = SetValue
UISlider.SetOnValueChanged = SetOnValueChanged
UISlider.SetFillColor = SetFillColor
UISlider.OnDestroy = OnDestroy
UISlider.SetInteractable = SetInteractable
UISlider.DOValue = DOValue

return UISlider