--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.TMPro.TMP_Dropdown 原生 TMP 下拉框
-- [OUTPUT]: 对外提供 UITMPDropdown 组件类，含 AddWithText/AddWithLocalText 追加选项、Clear、SetText/GetText、SetValue/GetValue/SetValueWithoutNotify、SetOnValueChanged 回调
-- [POS]: Component 层对 TMP_Dropdown 的 Lua 封装；与 UIDropdown（UGUI 版）对应，用于 TMP 字体下拉选择
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UITMPDropdown = BaseClass("UITMPDropdown", UIBaseContainer)
local base = UIBaseContainer
--local UnityDropdown = typeof(CS.UnityEngine.UI.Dropdown)
local UnityDropdown = typeof(CS.TMPro.TMP_Dropdown)
local OptionData = CS.TMPro.TMP_Dropdown.OptionData

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_dropdown = self.gameObject:GetComponent(UnityDropdown)
end

local function OnDestroy(self)
	if self.__onvaluechanged ~= nil then
		self.unity_dropdown.onValueChanged:RemoveListener(self.__onvaluechanged)
	end
	XPCALL(function() self.unity_dropdown.onValueChanged:Clear() end)
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
	if self.unity_dropdown.options then
		self.unity_dropdown.options:Clear()
	end
end

--local function Add(self,value)
--	self.unity_dropdown.options:Add(value)
--end                   

function UITMPDropdown:AddWithText(str)
	
	XPCALL(
		function() 
			local OptionData = CS.TMPro.TMP_Dropdown.OptionData
			local data = OptionData()
			data.text = str
			self.unity_dropdown.options:Add(data)
		end)
end

function UITMPDropdown:AddWithLocalText(dialogId)
	local str = Localization:GetString(dialogId)
	self:AddWithText(str)
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

UITMPDropdown.OnCreate = OnCreate
UITMPDropdown.OnDestroy = OnDestroy
UITMPDropdown.SetText = SetText
UITMPDropdown.GetText = GetText
UITMPDropdown.Clear = Clear
UITMPDropdown.SetOnValueChanged = SetOnValueChanged
UITMPDropdown.SetValue = SetValue
UITMPDropdown.SetValueWithoutNotify = SetValueWithoutNotify
UITMPDropdown.GetValue = GetValue

return UITMPDropdown