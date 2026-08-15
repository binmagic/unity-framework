--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
-- added by wsh @ 2017-12-28
-- 注意：
-- 1、已经被修改，别从tolua轻易替换来做升级
--[[
-- [INPUT]: 依赖 Vector3 承接命中点/法向,回填 CS.UnityEngine.RaycastHit
-- [OUTPUT]: 对外提供纯 Lua 版 RaycastHit(point/normal/distance/collider 等命中信息访问)
-- [POS]: Common/Tools/UnityEngine 的射线命中结果结构体封装(源自 tolua),承接物理射线检测的返回数据供 Lua 侧读取
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

local rawget = rawget
local setmetatable = setmetatable

RaycastBits = 
{
	Collider = 1,
    Normal = 2,
    Point = 4,
    Rigidbody = 8,
    Transform = 16,
    ALL = 31,
}
	
local RaycastBits = RaycastBits
local RaycastHit = {}
local unity_raycasthit = CS.UnityEngine.RaycastHit

RaycastHit.__index = function(t,k)
	local var = rawget(RaycastHit, k)
	if var ~= nil then
		return var
	end
	
	return rawget(unity_raycasthit, k)
end

--c# 创建
function RaycastHit.New(collider, distance, normal, point, rigidbody, transform)
	local hit = {collider = collider, distance = distance, normal = normal, point = point, rigidbody = rigidbody, transform = transform}
	setmetatable(hit, RaycastHit)
	return hit
end

function RaycastHit:Init(collider, distance, normal, point, rigidbody, transform)
	self.collider 	= collider
	self.distance 	= distance
	self.normal 	= normal
	self.point 		= point
	self.rigidbody 	= rigidbody
	self.transform 	= transform
end

function RaycastHit:Get()
	return self.collider, self.distance, self.normal, self.point, self.rigidbody, self.transform
end

function RaycastHit:Destroy()				
	self.collider 	= nil			
	self.rigidbody 	= nil					
	self.transform 	= nil		
end

function RaycastHit.GetMask(...)
	local arg = {...}
	local value = 0	

	for i = 1, #arg do		
		local n = RaycastBits[arg[i]] or 0
		
		if n ~= 0 then
			value = value + n				
		end
	end	
		
	if value == 0 then value = RaycastBits["all"] end
	return value
end

RaycastHit.unity_raycasthit = CS.UnityEngine.RaycastHit
CS.UnityEngine.RaycastHit = RaycastHit
setmetatable(RaycastHit, RaycastHit)
return RaycastHit