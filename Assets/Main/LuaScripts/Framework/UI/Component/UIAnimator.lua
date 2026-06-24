
---@class UIAnimator : UIBaseContainer
local UIAnimator = BaseClass("UIAnimator", UIBaseContainer)
local base = UIBaseContainer
local UnityAnimator = typeof(CS.UnityEngine.Animator)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_animator = self.gameObject:GetComponent_Animator()
end

local function OnDestroy(self)
	self.unity_animator = nil
	base.OnDestroy(self)
end

local function Play(self,name,layer,normalizedTime)
	--self.unity_animator:Play(_ToID(name),layer,normalizedTime)
	local hashId = GlobalCache.Animator_StringToHash(name)
	self.unity_animator:Play(hashId,layer,normalizedTime)
end

local function Enable(self,value)
	self.unity_animator.enabled = value
end

local function SetBool(self, name, val)
	local hashId = GlobalCache.Animator_StringToHash(name)
	self.unity_animator:SetBool(hashId, val)
end

local function SetTrigger(self,name)
	local hashId = GlobalCache.Animator_StringToHash(name)
	self.unity_animator:SetTrigger(hashId)
end

local function ResetTrigger(self,name)
	local hashId = GlobalCache.Animator_StringToHash(name)
	self.unity_animator:ResetTrigger(hashId)
end

--做动画并返回动画时间
local function PlayAnimationReturnTime(self,animName)
	local duration = 0
	local clips = self.unity_animator.runtimeAnimatorController.animationClips
	for i = 0, clips.Length - 1 do
		if string.endswith(clips[i].name,animName) then
			duration = clips[i].length
			self:Play(animName, 0, 0)
			return true, duration
		end
	end

	return false
end


local function GetFloat(self, name)
	local hashId = GlobalCache.Animator_StringToHash(name)
	return self.unity_animator:GetFloat(hashId)
end


--不做动画返回动画时间
local function GetAnimationReturnTime(self,animName)
	local duration = 0
	
	if self.unity_animator == nil or 
		self.unity_animator.runtimeAnimatorController == nil then
		return false
	end
	
	local clips = self.unity_animator.runtimeAnimatorController.animationClips
	for i = 0, clips.Length - 1 do
		if string.endswith(clips[i].name,animName) then
			duration = clips[i].length
			return true, duration
		end
	end

	return false
end
--设置动画整体速度
local function SetSpeed(self, speed)
	self.unity_animator.speed = speed
end
--获取动画整体速度
local function GetSpeed(self)
	return self.unity_animator.speed
end

function UIAnimator:GetCurrentAnimatorClipInfo(layer)
	local clipInfoArr = self.unity_animator:GetCurrentAnimatorClipInfo(layer or 0)
	if clipInfoArr.Length > 0 then
		return clipInfoArr[0]
	end
	
	return nil
end

UIAnimator.OnCreate = OnCreate
UIAnimator.OnDestroy = OnDestroy
UIAnimator.Play = Play
UIAnimator.Enable = Enable
UIAnimator.SetBool = SetBool
UIAnimator.PlayAnimationReturnTime = PlayAnimationReturnTime
UIAnimator.GetFloat = GetFloat
UIAnimator.GetAnimationReturnTime = GetAnimationReturnTime
UIAnimator.SetTrigger = SetTrigger
UIAnimator.ResetTrigger = ResetTrigger
UIAnimator.SetSpeed = SetSpeed
UIAnimator.GetSpeed = GetSpeed

return UIAnimator