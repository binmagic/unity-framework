local UIDropdown = BaseClass("UIDropdown", UIBaseContainer)
local base = UIBaseContainer
local UnityDropdown = typeof(CS.UnityEngine.UI.Dropdown)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_dropdown = self.gameObject:GetComponent(UnityDropdown)
end

local function OnDestroy(self)
	if self.__onvaluechanged ~= nil then
		self.unity_dropdown.onValueChanged:RemoveListener(self.__onvaluechanged)
	end
	pcall(function() self.unity_dropdown.onValueChanged:Clear() end)
	self.unity_dropdown = nil
	self.__onvaluechanged = nil
	base.OnDestroy(self)
end

local function SetText(self,value)
	self.unity_dropdown.captionText.text = value
end

local function GetText(self)
	return self.unity_dropdown.captionText.text
end

local function Clear(self)
	self.unity_dropdown.options:Clear()
end

local function Add(self,value)
	self.unity_dropdown.options:Add(value)
end

local function SetOnValueChanged(self, action)
	if action then
		if self.__onvaluechanged then
			self.unity_dropdown.onValueChanged:RemoveListener(self.__onvaluechanged)
		end
		self.__onvaluechanged = action
		self.unity_dropdown.onValueChanged:AddListener(self.__onvaluechanged)
	elseif self.__onvaluechanged then
		self.unity_dropdown.onValueChanged:RemoveListener(self.__onvaluechanged)
		self.__onvaluechanged = nil
	end
end

local function SetValue(self,value)
	self.unity_dropdown.value = value
end

local function SetValueWithoutNotify(self, value)
	self.unity_dropdown:SetValueWithoutNotify(value)
end

local function GetValue(self)
	return self.unity_dropdown.value
end

UIDropdown.OnCreate = OnCreate
UIDropdown.OnDestroy = OnDestroy
UIDropdown.SetText = SetText
UIDropdown.GetText = GetText
UIDropdown.Clear = Clear
UIDropdown.Add = Add
UIDropdown.SetOnValueChanged = SetOnValueChanged
UIDropdown.SetValue = SetValue
UIDropdown.SetValueWithoutNotify = SetValueWithoutNotify
UIDropdown.GetValue = GetValue

return UIDropdown