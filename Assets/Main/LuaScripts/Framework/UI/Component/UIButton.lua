--[[
-- added by wsh @ 2017-12-08
-- Lua侧UIButton
-- 注意：
-- 1、按钮一般会带有其他的组件，如带一个UIText、或者一个UIImange标识说明按钮功能，所以这里是一个容器类
-- 2、UIButton组件必须挂载在根节点，其下某个子节点有个Unity侧原生Button即可，如果有多个，需要指派相对路径
-- 使用方式：
-- self.xxx_btn = self:AddComponent(UIButton, var_arg)--添加孩子，各种重载方式查看UIBaseContainer
--]]

---@class UIButton : UIBaseContainer
local UIButton = BaseClass("UIButton", UIBaseContainer)
local base = UIBaseContainer
local UnityButton = typeof(CS.UnityEngine.UI.Button)
local UnityImage = typeof(CS.UnityEngine.UI.Image)
local ButtonRef = {}

function UIButton.AddRef(btn)
	local ref = (ButtonRef[btn] or 0) + 1
	ButtonRef[btn] = ref
	return ref
end

function UIButton.DecRef(btn)
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
local function OnCreate(self, relative_path)
	base.OnCreate(self)
	-- Unity侧原生组件
	self.unity_uibutton = self.gameObject:GetComponent_Button()
	--self.unity_image = self.gameObject:GetComponent_Image()
	
	if self.unity_uibutton then
		local ref = UIButton.AddRef(self.unity_uibutton)
	end
	
	-- 记录点击回调
	self.__onclick = nil
	
	-- 连点的处理
	self.safeClickMode = false
	self.stopClicking = false
end

-- 虚拟点击
local function Click(self)
	if self.__onclick  ~= nil then
		self.__onclick()
	end
end

-- 设置回调
local function SetOnClick(self, action)
	if action then
		if self.__onclick then
			if not IsNull(self.unity_uibutton) then
				self.unity_uibutton.onClick:RemoveListener(self.__onclick)
			end
		end
		
		local interAction = function()
			if self.stopClicking then
				UIUtil.ShowTipsId(120289)
				return
			end
			-- 在按钮上绑定一个UIExtraData组件，里面设置soundId，就可以播放音乐了
			if self.gameObject and self.soundId == nil then
				self.soundId = self.gameObject:GetComponent_UIExtraSound()
			end
			if self.soundId ~= nil and self.soundId > 0 then
				SUSoundUtil.PlaySoundById(self.soundId)
			end
			
			action(self.param)
			if self.safeClickMode then
				self.stopClicking = true
				self.preventTimer = TimerManager:GetInstance():DelayInvoke(function()
					self.stopClicking = false
					self.preventTimer = nil
				end, 0.5)
			end
		end
		
		self.__onclick = interAction
		if not IsNull(self.unity_uibutton) then
			self.unity_uibutton.onClick:AddListener(self.__onclick)
		end
	elseif self.__onclick then
		if not IsNull(self.unity_uibutton) then
			self.unity_uibutton.onClick:RemoveListener(self.__onclick)
		end
		self.__onclick = nil
	end
end

function UIButton:SetSafeClickMode(on)
	self.safeClickMode = on
end

-- 资源释放
local function OnDestroy(self)
	
	if not IsNull(self.unity_uibutton) then
		if self.__onclick ~= nil then
			self.unity_uibutton.onClick:RemoveListener(self.__onclick)
		end
		
		--先屏蔽跑跑看
		--local ref = UIButton.DecRef(self.unity_uibutton)
		--if ref <= 0 then
		--	XPCALL(function() 
		--			self.unity_uibutton.onClick:Clear() 
		--			end)
		--end
	else
		-- Logger.LogError("Button OnDestroy but unity_uibutton not exist?????")
	end
	if self.preventTimer then
		self.preventTimer:Stop()
		self.preventTimer = nil
	end
	self.safeClickMode = false
	self.stopClicking = false
	self.unity_uibutton = nil
	self.unity_image = nil
	self.spritePath = nil
	self.__onclick = nil
	base.OnDestroy(self)
end

local function SetInteractable(self,value)
	self.unity_uibutton.interactable = value
end

function UIButton:SetEnabled(value)
	local selfEnabled = self.unity_uibutton.enabled
	if (selfEnabled ~= value) then
		self.unity_uibutton.enabled = value
	end
end

local function GetButtonImageComponent(self)
	if self.unity_image ~= nil then
		return self.unity_image
	end
	
	self.unity_image = self.gameObject:GetComponent_Image()
	return self.unity_image
end

local function SetSprite(self, spr)
	local btnImage = self:GetButtonImageComponent()
	if (btnImage ~= nil) then
		btnImage.sprite = spr
	end
end

local function SetMaterial(self, value)
	local btnImage = self:GetButtonImageComponent()
	if (btnImage ~= nil) then
		btnImage.material = value
	end
end

local function LoadSprite(self, sprite_path, default_sprite)
	if self.spritePath == sprite_path then
		return
	end
	self.spritePath = sprite_path
	
	local btnImage = self:GetButtonImageComponent()
	if btnImage~=nil then
		btnImage:LoadSprite(_ToID(sprite_path), default_sprite)
	end
	
end

local function SetNativeSize(self)
	local btnImage = self:GetButtonImageComponent()
	if btnImage~=nil then
		btnImage:SetNativeSize()
	end
end

local function SetParam(self, param)
	self.param = param
end

local function GetParam()
	return self.param
end

UIButton.OnCreate = OnCreate
UIButton.SetOnClick = SetOnClick
UIButton.Click = Click
UIButton.OnDestroy = OnDestroy
UIButton.SetInteractable = SetInteractable
UIButton.SetSprite = SetSprite
UIButton.SetMaterial = SetMaterial
UIButton.LoadSprite = LoadSprite
UIButton.SetNativeSize = SetNativeSize
UIButton.SetParam = SetParam
UIButton.GetParam = GetParam
UIButton.GetButtonImageComponent = GetButtonImageComponent
return UIButton