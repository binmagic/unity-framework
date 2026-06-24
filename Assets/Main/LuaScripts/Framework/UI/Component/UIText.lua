--[[
-- added by wsh @ 2017-12-08
-- Lua侧UIText
-- 使用方式：
-- self.xxx_text = self:AddComponent(UIInput, var_arg)--添加孩子，各种重载方式查看UIBaseContainer
-- TODO：本地化支持
--]]

---@class UIText : UIBaseComponent
local UIText = BaseClass("UIText", UIBaseComponent)
local base = UIBaseComponent
-- local UnityText = typeof(CS.UnityEngine.UI.Text)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_text = self.gameObject:GetComponent_Text()
end

-- 获取文本
local function GetText(self)
	return self.unity_text.text
end

-- 设置文本
local function SetText(self, text)
	--self.unity_text.text = text
	self.unity_text:Native_SetText(text)
end

local function SetLocalText(self, dialogId, ...)
	dialogId = Localization.GetRealId(dialogId)
	self.unity_text:SetLocalText(dialogId, ...)
end

local function SetText_Cache(self, text)
	self.unity_text:SetTextCacheID(_ToID(text))
end

-- 销毁
local function OnDestroy(self)
	self.unity_text = nil
	base.OnDestroy(self)
end

local function SetColorRGBA(self,r,g,b,a)
	--self.unity_image.color = value
	self.unity_text:Set_color(r, g, b, a)
end

local function SetColor(self,value)
	self.unity_text:Set_color(value.r, value.g, value.b, value.a)
end

local function GetColor(self)
	local r,g,b,a = self:GetColorRGBA()
	return Color.New(r,g,b,a)
end

local function GetColorRGBA(self)
	return self.unity_text:Get_color()
end

local function SetAlpha(self,value)
	local color = self:GetColor()
	self:SetColorRGBA(color.r,color.g,color.b,value)
end

local function GetAlpha(self)
	local r,g,b,a = self:GetColorRGBA()
	return a
end

local function GetWidth(self) 
	return self.unity_text.preferredWidth
end

local function GetHeight(self)
	return self.unity_text.preferredHeight
end

local function SetAlignment(self, _alignment ) 
	self.unity_text.alignment = _alignment
end

local function SetPreferSize(self, value)
	self.rectTransform:Set_sizeDelta(value.x, value.y)
end

local function SetFontSize(self, fontSize)
	self.unity_text.fontSize = fontSize
end

UIText.OnCreate = OnCreate
UIText.GetText = GetText
UIText.SetText = SetText
UIText.OnDestroy = OnDestroy
UIText.SetColor = SetColor
UIText.GetWidth = GetWidth
UIText.GetHeight = GetHeight
UIText.SetPreferSize = SetPreferSize
UIText.GetColor = GetColor
UIText.SetLocalText = SetLocalText
UIText.SetColorRGBA = SetColorRGBA
UIText.GetColorRGBA = GetColorRGBA
UIText.SetAlpha = SetAlpha
UIText.GetAlpha = GetAlpha
UIText.SetAlignment = SetAlignment
UIText.SetFontSize = SetFontSize
UIText.SetText_Cache = SetText_Cache
UIText.SetLocalText = SetLocalText

return UIText