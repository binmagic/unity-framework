--[[
-- added by zcf @ 2020-03-19
-- Lua侧UIToggle
-- 注意：
-- 由于原本的UIToggleButton是基于UIButton的自定义控件，不是UnityGUI的Toggle，这里扩展一个Unity的Toggle
--]]

---@class UIToggle
local UIToggle = BaseClass("UIToggle", UIBaseContainer)
local base = UIBaseContainer
local UnityToggle = typeof(CS.UnityEngine.UI.Toggle)
local ButtonRef = {}

function UIToggle.AddRef(btn)
	local ref = (ButtonRef[btn] or 0) + 1
	ButtonRef[btn] = ref
	return ref
end

function UIToggle.DecRef(btn)
	local ref = (ButtonRef[btn] or 0) - 1
	if ref <= 0 then
		ref = 0
		ButtonRef[btn] = nil
	else
		ButtonRef[btn] = ref
	end
	return ref
end

-- 创建
function UIToggle:OnCreate(relative_path)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_uitoggle = self.gameObject:GetComponent(UnityToggle)
	if self.unity_uitoggle then
		UIToggle.AddRef(self.unity_uitoggle)
	end
	-- 记录点击回调
	self.__onvaluechanged = nil
end

function UIToggle:SetIsOn(tf,force)
	if self.unity_uitoggle.isOn ~= tf then
		self.unity_uitoggle.isOn = tf
	else
		if force and self.__onvaluechanged then
			self.__onvaluechanged(tf)
		end
	end
end

function UIToggle:GetIsOn()
	return self.unity_uitoggle.isOn
end

function UIToggle:SetOnValueChanged(action)
	if action then
		if self.__onvaluechanged then
			self.unity_uitoggle.onValueChanged:RemoveListener(self.__onvaluechanged)
		end
		self.__onvaluechanged = action
		self.unity_uitoggle.onValueChanged:AddListener(self.__onvaluechanged)
	elseif self.__onvaluechanged then
		self.unity_uitoggle.onValueChanged:RemoveListener(self.__onvaluechanged)
		self.__onvaluechanged = nil
	end
end

function UIToggle:SetGroup(group)
	self.unity_uitoggle.group = group
end

-- 资源释放
function UIToggle:OnDestroy()
	if self.__onvaluechanged ~= nil then
		self.unity_uitoggle.onValueChanged:RemoveListener(self.__onvaluechanged)
	end
	if self.unity_uitoggle then
		local ref = UIToggle.DecRef(self.unity_uitoggle)
		if ref <= 0 then
			pcall(function() self.unity_uitoggle.onValueChanged:Clear() end)
		end
	end
	self.unity_uitoggle = nil
	self.__onvaluechanged = nil
	base.OnDestroy(self)
end

function UIToggle:SetInteractable(value)
	self.unity_uitoggle.interactable = value
end

function UIToggle:SetIsOnWithoutNotify(t)
	self.unity_uitoggle:SetIsOnWithoutNotify(t)
end

return UIToggle