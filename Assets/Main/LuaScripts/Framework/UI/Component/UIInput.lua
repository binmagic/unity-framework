--[[
-- added by wsh @ 2017-12-08
-- Lua侧UIInput
-- 使用方式：
-- self.xxx_input = self:AddComponent(UIInput, var_arg)--添加孩子，各种重载方式查看UIBaseContainer
--]]

---@class UIInput : UIBaseComponent
local UIInput = BaseClass("UIInput", UIBaseComponent)
local base = UIBaseComponent
local UnityInputField = typeof(CS.UnityEngine.UI.InputField)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_uiinput = self.gameObject:GetComponent(UnityInputField)
end

local function IsEnabled(self,isToggle)
	self.unity_uiinput.enabled=isToggle
end

-- 获取文本
local function GetText(self)
	return self.unity_uiinput.text
end

-- 设置文本
local function SetText(self, text)
	self.unity_uiinput.text = text
end

local function SetLocalText(self, text)
	self.unity_uiinput:SetLocalText(text)
end

-- 销毁
local function OnDestroy(self)
	if self.__onEndEdit ~= nil then
		self.unity_uiinput.onEndEdit:RemoveListener(self.__onEndEdit)
	end
	if self.__onValueChange ~= nil then
		self.unity_uiinput.onValueChanged:RemoveListener(self.__onValueChange)
	end
	pcall(function()
		self.unity_uiinput.onEndEdit:Clear()
		self.unity_uiinput.onValueChanged:Clear()
	end)

	self.unity_uiinput = nil
	self.__onEndEdit = nil
	self.__onValueChange = nil
	base.OnDestroy(self)
end

local function SetOnEndEdit(self, action)
	if action then
		if self.__onEndEdit then
			self.unity_uiinput.onEndEdit:RemoveListener(self.__onEndEdit)
		end
		self.__onEndEdit = action
		self.unity_uiinput.onEndEdit:AddListener(self.__onEndEdit)
	elseif self.__onEndEdit then
		self.unity_uiinput.onEndEdit:RemoveListener(self.__onEndEdit)
		self.__onEndEdit = nil
	end
end
local function SetOnValueChange(self,action)
	if action then
		if self.__onValueChange then
			self.unity_uiinput.onValueChanged:RemoveListener(self.__onValueChange)
		end
		self.__onValueChange = action
		self.unity_uiinput.onValueChanged:AddListener(self.__onValueChange)
	elseif self.__onValueChange then
		self.unity_uiinput.onValueChanged:RemoveListener(self.__onValueChange)
		self.__onValueChange = nil
	end
end

local function SetInteractable(self,value)
	self.unity_uiinput.interactable = value
end

local function SetEnable(self, value) 
	self.unity_uiinput.enabled = value
end

local function Select(self)
	self.unity_uiinput:Select()
	self.unity_uiinput:ActivateInputField()
end

UIInput.OnCreate = OnCreate
UIInput.GetText = GetText
UIInput.SetText = SetText
UIInput.SetOnEndEdit = SetOnEndEdit
UIInput.SetOnValueChange = SetOnValueChange
UIInput.OnDestroy = OnDestroy
UIInput.SetInteractable = SetInteractable
UIInput.SetEnable = SetEnable
UIInput.IsEnabled=IsEnabled
UIInput.Select=Select
UIInput.SetLocalText = SetLocalText

return UIInput