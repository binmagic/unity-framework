--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.UnityEngine.BoxCollider2D 原生 2D 碰撞盒
-- [OUTPUT]: 对外提供 UIBoxCollider2D 组件类，含 GetBounds 取碰撞盒包围盒
-- [POS]: Component 层对 2D 盒碰撞体的 Lua 封装，用于需要 2D 碰撞判定或区域包围盒的 UI 元素
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
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