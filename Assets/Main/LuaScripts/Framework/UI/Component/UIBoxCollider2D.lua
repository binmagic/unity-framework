local UIBoxCollider2D = BaseClass("UIBoxCollider2D", UIBaseContainer)
local base = UIBaseContainer
local UnityBoxCollider2D = typeof(CS.UnityEngine.BoxCollider2D)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_box_collider = self.gameObject:GetComponent(UnityBoxCollider2D)
end

local function OnDestroy(self)
	self.unity_box_collider = nil
	base.OnDestroy(self)
end

local function GetBounds(self)
	return self.unity_box_collider.bounds
end

UIBoxCollider2D.OnCreate = OnCreate
UIBoxCollider2D.OnDestroy = OnDestroy
UIBoxCollider2D.GetBounds = GetBounds

return UIBoxCollider2D