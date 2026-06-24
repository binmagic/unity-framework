---
--- NewTMPText
--- 这个指的是我们自己封装的TextMeshPro的处理
--- 等同于UITextMeshProUGUIEx，以后不要使用UITextMeshProUGUIEx
---

local NewTMPText = BaseClass("NewTMPText", UIBaseComponent)
local base = UIBaseComponent
local CS_NewTMPText = typeof(CS.NewTMPText)
local Resource = CS.GameEntry.Resource

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_tmpro = self.gameObject:GetComponent(CS_NewTMPText)
end

-- 获取文本
local function GetText(self)
	return self.unity_tmpro.text
end

-- 设置文本
local function SetText(self, text)
	self.unity_tmpro:Native_SetText(text)
end

local function SetLocalText(self, dialogId, ...)
	dialogId = Localization.GetRealId(dialogId)
	self.unity_tmpro:SetLocalText(dialogId, ...)
end

local function ForceMeshUpdate(self)
	self.unity_tmpro:ForceMeshUpdate()
end

local function GetTotalCharacterCount(self)
	local totalVisibleCharacters = self.unity_tmpro.textInfo.characterCount;
	return totalVisibleCharacters
end

local function SetMaxVisibleCharacters(self, count)
	self.unity_tmpro.maxVisibleCharacters = count
end

-- 销毁
local function OnDestroy(self)
	if not IsNull(self.unity_tmpro) then
		self.unity_tmpro.onPointerClick = nil
	else
		if (self.unity_tmpro) then
			Logger.LogError("self.unity_tmpro invalid!24")
		end
	end
	self.unity_tmpro = nil
	
	if self.materialModel then
		self.materialModel:Release()
		self.materialModel = nil
	end
	base.OnDestroy(self)
end

local function SetColor(self,value)
	self.unity_tmpro.color = value
end

local function GetColor(self)
	return self.unity_tmpro.color
end

local function GetWidth(self)
	return self.unity_tmpro.preferredWidth
end

local function GetHeight(self)
	return self.unity_tmpro.preferredHeight
end

local function GetLinkInfo(self)
	return self.unity_tmpro.textInfo.linkInfo
end

local function OnPointerClick(self,onPointerClick)
	self.unity_tmpro.onPointerClick = onPointerClick
end

local function SetCodeEffectText(self, str, callback, startIndex, speed)
	if (speed == nil and startIndex ~= nil) then
		self.unity_tmpro:SetCodeEffectText(str, callback, startIndex)
	elseif speed == nil and startIndex == nil then
		self.unity_tmpro:SetCodeEffectText(str, callback)
	else
		self.unity_tmpro:SetCodeEffectText(str, callback, startIndex, speed)
	end
end

local function SetCodeSpeed(self, speed)
	self.unity_tmpro:SetCodeSpeed(speed)
end

local function SetPreferSize(self, value)
	self.rectTransform.sizeDelta = value
end

local function ShowCodeTextEffDirect(self)
	self.unity_tmpro:ShowCodeTextEffDirect()
end

local function SetFontMaterialByType(self,materialType)
	if materialType then
		if MediumFontMaterialType[materialType] == nil  then
			Logger.LogError("未注册对应的字体材质")
			return
		end
		if self.materialModel then
			self.materialModel:Release()
			self.materialModel = nil
		end

		self.materialModel = Resource:LoadAssetAsync(string.format(LoadPath.TMPMaterialPath,MediumFontMaterialType[materialType]), typeof(CS.UnityEngine.Material))
		if self.materialModel == nil then
			return
		end
		self.materialModel:completed('+', function(req)
			if self.materialModel and self.materialModel.asset then
				local material = self.materialModel.asset
				cast(material, typeof(CS.UnityEngine.Material))
				self:SetMaterialPreset(material)
			end
		end)
	end
end

--传入一个材质装上
local function SetMaterialPreset(self,material)
	self.unity_tmpro.fontMaterial = material
end

NewTMPText.ShowCodeTextEffDirect = ShowCodeTextEffDirect
NewTMPText.ForceMeshUpdate = ForceMeshUpdate
NewTMPText.GetTotalCharacterCount = GetTotalCharacterCount
NewTMPText.SetMaxVisibleCharacters = SetMaxVisibleCharacters
NewTMPText.SetCodeEffectText = SetCodeEffectText
NewTMPText.SetCodeSpeed = SetCodeSpeed
NewTMPText.SetPreferSize = SetPreferSize

NewTMPText.OnCreate = OnCreate
NewTMPText.GetText = GetText
NewTMPText.SetText = SetText
NewTMPText.SetLocalText = SetLocalText
NewTMPText.OnDestroy = OnDestroy
NewTMPText.SetColor = SetColor
NewTMPText.GetWidth = GetWidth
NewTMPText.GetHeight = GetHeight
NewTMPText.GetColor = GetColor
NewTMPText.GetLinkInfo = GetLinkInfo
NewTMPText.OnPointerClick = OnPointerClick
NewTMPText.SetMaterialPreset = SetMaterialPreset
NewTMPText.SetFontMaterialByType = SetFontMaterialByType

return NewTMPText