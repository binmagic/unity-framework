---@class UISimpleAnimation:UIBaseContainer
local UISimpleAnimation = BaseClass("UISimpleAnimation", UIBaseContainer)
local base = UIBaseContainer
local SimpleAnimation = typeof(CS.SimpleAnimation)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.simpleAnimation = self.gameObject:GetComponent(SimpleAnimation)
end

local function OnDestroy(self)
	self.simpleAnimation = nil
	base.OnDestroy(self)
end

local function Play(self,name)
	self.simpleAnimation:Play(_ToID(name))
end

local function Enable(self,value)
	self.simpleAnimation.enabled = value
end

--做动画并返回动画时间
local function PlayAnimationReturnTime(self,animName)
	self.simpleAnimation:Play(_ToID(animName))
	return true, self.simpleAnimation:GetClipLength(_ToID(animName))
end

--不做动画返回动画时间
local function GetAnimationReturnTime(self,animName)
	if self:HasState(animName) then
		return false
	end

	return true, self.simpleAnimation:GetClipLength(_ToID(animName))
end

local function IsPlaying(self,animName)
	if self:HasState(animName) then
		return false
	end
	
	return self.simpleAnimation:IsPlaying(_ToID(animName))
end

local function Stop(self)
	self.simpleAnimation:Stop()
end

local function Rewind(self, animName)
	self.simpleAnimation:Rewind(_ToID(animName))
end

local function HasState(self, animName)
	if self.simpleAnimation then
		return self.simpleAnimation:HasState(_ToID(animName))
	end
	
	return false
end

UISimpleAnimation.OnCreate = OnCreate
UISimpleAnimation.OnDestroy = OnDestroy
UISimpleAnimation.Play = Play
UISimpleAnimation.Rewind = Rewind
UISimpleAnimation.Enable = Enable
UISimpleAnimation.PlayAnimationReturnTime = PlayAnimationReturnTime
UISimpleAnimation.GetAnimationReturnTime = GetAnimationReturnTime
UISimpleAnimation.IsPlaying = IsPlaying
UISimpleAnimation.Stop = Stop
UISimpleAnimation.HasState = HasState
return UISimpleAnimation