--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
-- added by wsh @ 2017-12-28
-- 注意：
-- 1、已经被修改，别从tolua轻易替换来做升级
---@class Common.Tools.UnityEngine.Vector3

local math  = math
local acos	= math.acos
local sqrt 	= math.sqrt
local max 	= math.max
local min 	= math.min
local clamp = Mathf.Clamp
local cos	= math.cos
local sin	= math.sin
local abs	= math.abs
local sign	= Mathf.Sign
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget
local type = type

local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

local Vector3 = {}
local _getter = {}
local unity_vector3 = CS.UnityEngine.Vector3
local Distance3D = cutils.Distance3D
local Distance2D = cutils.Distance2D
local Vector3_MoveTowards = CS.OptiUtils.Vector3_MoveTowards
--local Vector3_Angle = CS.OptiUtils.Vector3_Angle
------------------------------------------------
-- 做一个Vector3的池列表
local v3count = 0
local vector3PoolList = {}

local function __popATable()
	local c = #vector3PoolList
	local ret
	if c > 0 then
		ret = vector3PoolList[c]
		vector3PoolList[c] = nil

		--print("Vector3 new: " .. tostring(ret))
	else
		ret = {x = 0, y = 0, z = 0}
	end

	return ret
end

local function __recycleATable(t)
	if #vector3PoolList < 2048 and t ~= nil then
		setmetatable(t, Vector3)
		vector3PoolList[#vector3PoolList + 1] = t
		--table.insert(vector3PoolList, t)

		--print("Vector3 delete: " .. tostring(t))
	end
end

-----------------------------------------------


Vector3.__index = function(t,k)
	local var = rawget(Vector3, k)
	if var ~= nil then
		return var
	end

	var = rawget(_getter, k)
	if var ~= nil then
		return var(t)
	end

	return rawget(unity_vector3, k)
end

Vector3.__gc = function(t)
	v3count = v3count - 1
	--print("Vector3 -- gc -- " .. tostring(t) .. ", count = " .. tostring(v3count))
	__recycleATable(t)
end

function Vector3.HorizonDistance(va, vb)--水平距离
	return sqrt((va.x - vb.x)^2 + (va.z - vb.z)^2)
end

function Vector3.ManhattanDistance(va, vb)--曼哈顿距离
	return abs(va.x - vb.x) + abs(va.y - vb.y) + abs(va.z - vb.z)
end

function Vector3.ManhattanDistanceXZ(va, vb)--曼哈顿距离
	return abs(va.x - vb.x) + abs(va.z - vb.z)
end

function Vector3.New(x, y, z)
	v3count = v3count + 1

	local t = __popATable()
	setmetatable(t, Vector3)
	t:Set(x, y, z)

	return t
	--local t = {x = x or 0, y = y or 0, z = z or 0}

	--v3count = v3count + 1
	--print("Vector3 -- new -- " .. tostring(t) .. ", count = " .. tostring(v3count))

	--setmetatable(t, Vector3)						
	--return t
end


local _new = Vector3.New

Vector3.__call = function(t,x,y,z)
	return _new(x,y,z)
	--local t = {x = x or 0, y = y or 0, z = z or 0}

	--v3count = v3count + 1
	--print("Vector3 -- new -- " .. tostring(t) .. ", count = " .. tostring(v3count))

	--setmetatable(t, Vector3)					
	--return t
end

function Vector3:Set(x,y,z)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
end

function Vector3:SetPos(pos)
	self.x = pos.x or 0
	self.y = pos.y or 0
	self.z = pos.z or 0
end

function Vector3.Get(v)
	return v.x, v.y, v.z
end

function Vector3:Clone()
	return setmetatable({x = self.x, y = self.y, z = self.z}, Vector3)
end

function Vector3.Distance(va, vb)
	return Distance3D(va.x, va.y, va.z, vb.x, vb.y, vb.z)
	--return sqrt((va.x - vb.x)^2 + (va.y - vb.y)^2 + (va.z - vb.z)^2)
end

-- 在xz平面上的距离
function Vector3.Distance2D_XZ(va, vb)
	return Distance2D(va.x, va.z, vb.x, vb.z)
end

-- 某两个维度上的距离
function Vector3.Distance2D(x1, z1, x2, z2)
	return Distance2D(x1, z1, x2, z2)
end

function Vector3.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function Vector3.Lerp(from, to, t)
	t = clamp(t, 0, 1)
	return _new(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t)
end

function Vector3:Magnitude()
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vector3.Max(lhs, rhs)
	return _new(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
end

function Vector3.Min(lhs, rhs)
	return _new(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
end

function Vector3.Normalize(v)
	local x,y,z = v.x, v.y, v.z
	local num = sqrt(x * x + y * y + z * z)

	if num > 1e-5 then
		return setmetatable({x = x / num, y = y / num, z = z / num}, Vector3)
	end

	return setmetatable({x = 0, y = 0, z = 0}, Vector3)
end

function Vector3:SetNormalize()
	local num = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)

	if num > 1e-5 then
		self.x = self.x / num
		self.y = self.y / num
		self.z = self.z /num
	else
		self.x = 0
		self.y = 0
		self.z = 0
	end

	return self
end

function Vector3:SqrMagnitude()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector3:SqrDistance(other)
	local deltaX = self.x - other.x
	local deltaY = self.y - other.y
	local deltaZ = self.z - other.z
	return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
end

local dot = Vector3.Dot

function Vector3.Angle(from, to)
	return acos(clamp(dot(from:Normalize(), to:Normalize()), -1, 1)) * rad2Deg
	--return Vector3_Angle(from.x, from.y, from.z, to.x, to.y, to.z)
end

function Vector3:ClampMagnitude(maxLength)
	if self:SqrMagnitude() > (maxLength * maxLength) then
		self:SetNormalize()
		self:Mul(maxLength)
	end

	return self
end


function Vector3.OrthoNormalize(va, vb, vc)
	va:SetNormalize()
	vb:Sub(vb:Project(va))
	vb:SetNormalize()

	if vc == nil then
		return va, vb
	end

	vc:Sub(vc:Project(va))
	vc:Sub(vc:Project(vb))
	vc:SetNormalize()
	return va, vb, vc
end

function Vector3.MoveTowardsXYZ(current, target, maxDistanceDelta)

	local x,y,z = Vector3_MoveTowards(current.x, current.y, current.z,
			target.x, target.y, target.z, maxDistanceDelta)
	return x,y,z
end

function Vector3.MoveTowards(current, target, maxDistanceDelta)
	local delta = target - current
	local sqrDelta = delta:SqrMagnitude()
	local sqrDistance = maxDistanceDelta * maxDistanceDelta

	if sqrDelta > sqrDistance then
		local magnitude = sqrt(sqrDelta)

		if magnitude > 1e-6 then
			delta:Mul(maxDistanceDelta / magnitude)
			delta:Add(current)
			return delta
		else
			return current:Clone()
		end
	end

	return target:Clone()
end

function ClampedMove(lhs, rhs, clampedDelta)
	local delta = rhs - lhs

	if delta > 0 then
		return lhs + min(delta, clampedDelta)
	else
		return lhs - min(-delta, clampedDelta)
	end
end

local overSqrt2 = 0.7071067811865475244008443621048490

local function OrthoNormalVector(vec)
	local res = _new()

	if abs(vec.z) > overSqrt2 then
		local a = vec.y * vec.y + vec.z * vec.z
		local k = 1 / sqrt (a)
		res.x = 0
		res.y = -vec.z * k
		res.z = vec.y * k
	else
		local a = vec.x * vec.x + vec.y * vec.y
		local k = 1 / sqrt (a)
		res.x = -vec.y * k
		res.y = vec.x * k
		res.z = 0
	end

	return res
end

function Vector3.RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta)
	local len1 = current:Magnitude()
	local len2 = target:Magnitude()

	if len1 > 1e-6 and len2 > 1e-6 then
		local from = current / len1
		local to = target / len2
		local cosom = dot(from, to)

		if cosom > 1 - 1e-6 then
			return Vector3.MoveTowards (current, target, maxMagnitudeDelta)
		elseif cosom < -1 + 1e-6 then
			local axis = OrthoNormalVector(from)
			local q = Quaternion.AngleAxis(maxRadiansDelta * rad2Deg, axis)
			local rotated = q:MulVec3(from)
			local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
			rotated:Mul(delta)
			return rotated
		else
			local angle = acos(cosom)
			local axis = Vector3.Cross(from, to)
			axis:SetNormalize ()
			local q = Quaternion.AngleAxis(min(maxRadiansDelta, angle) * rad2Deg, axis)
			local rotated = q:MulVec3(from)
			local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
			rotated:Mul(delta)
			return rotated
		end
	end

	return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
end

--[[这个函数太耗了 先屏掉走cs的
function Vector3.SmoothDamp(current, target, currentVelocity, smoothTime)
	local maxSpeed = Mathf.Infinity
	local deltaTime = Time.deltaTime
    smoothTime = max(0.0001, smoothTime)
    local num = 2 / smoothTime
    local num2 = num * deltaTime
    local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)    
    local vector2 = target:Clone()
    local maxLength = maxSpeed * smoothTime
	local vector = current - target
    vector:ClampMagnitude(maxLength)
    target = current - vector
    local vec3 = (currentVelocity + (vector * num)) * deltaTime
    currentVelocity = (currentVelocity - (vec3 * num)) * num3
    local vector4 = target + (vector + vec3) * num3	
	
    if Vector3.Dot(vector2 - current, vector4 - vector2) > 0 then    
        vector4 = vector2
        currentVelocity:Set(0,0,0)
    end
	
    return vector4, currentVelocity
end	
--]]

function Vector3.Scale(a, b)
	local x = a.x * b.x
	local y = a.y * b.y
	local z = a.z * b.z
	return _new(x, y, z)
end

function Vector3.Cross(lhs, rhs)
	local x = lhs.y * rhs.z - lhs.z * rhs.y
	local y = lhs.z * rhs.x - lhs.x * rhs.z
	local z = lhs.x * rhs.y - lhs.y * rhs.x
	return _new(x,y,z)
end

function Vector3:Equals(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end

function Vector3.Reflect(inDirection, inNormal)
	local num = -2 * dot(inNormal, inDirection)
	inNormal = inNormal * num
	inNormal:Add(inDirection)
	return inNormal
end


function Vector3.Project(vector, onNormal)
	local num = onNormal:SqrMagnitude()

	if num < 1.175494e-38 then
		return _new(0,0,0)
	end

	local num2 = dot(vector, onNormal)
	local v3 = onNormal:Clone()
	v3:Mul(num2/num)
	return v3
end

function Vector3.ProjectOnPlane(vector, planeNormal)
	local v3 = Vector3.Project(vector, planeNormal)
	v3:Mul(-1)
	v3:Add(vector)
	return v3
end

function Vector3.Slerp(from, to, t)
	local omega, sinom, scale0, scale1

	if t <= 0 then
		return from:Clone()
	elseif t >= 1 then
		return to:Clone()
	end

	local v2 	= to:Clone()
	local v1 	= from:Clone()
	local len2 	= to:Magnitude()
	local len1 	= from:Magnitude()
	v2:Div(len2)
	v1:Div(len1)

	local len 	= (len2 - len1) * t + len1
	local cosom = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z

	if cosom > 1 - 1e-6 then
		scale0 = 1 - t
		scale1 = t
	elseif cosom < -1 + 1e-6 then
		local axis = OrthoNormalVector(from)
		local q = Quaternion.AngleAxis(180.0 * t, axis)
		local v = q:MulVec3(from)
		v:Mul(len)
		return v
	else
		omega 	= acos(cosom)
		sinom 	= sin(omega)
		scale0 	= sin((1 - t) * omega) / sinom
		scale1 	= sin(t * omega) / sinom
	end

	v1:Mul(scale0)
	v2:Mul(scale1)
	v2:Add(v1)
	v2:Mul(len)
	return v2
end


function Vector3:Mul(q)
	if type(q) == "number" then
		self.x = self.x * q
		self.y = self.y * q
		self.z = self.z * q
	else
		self:MulQuat(q)
	end

	return self
end

function Vector3:Div(d)
	self.x = self.x / d
	self.y = self.y / d
	self.z = self.z / d

	return self
end

function Vector3:Add(vb)
	self.x = self.x + vb.x
	self.y = self.y + vb.y
	self.z = self.z + vb.z

	return self
end

function Vector3:Sub(vb)
	self.x = self.x - vb.x
	self.y = self.y - vb.y
	self.z = self.z - vb.z

	return self
end

function Vector3:MulQuat(quat)
	do
		local x, y,z = quat:MulVec3XYZ(self)
		self:Set(x, y, z)
		return self
	end
	
	local num 	= quat.x * 2
	local num2 	= quat.y * 2
	local num3 	= quat.z * 2
	local num4 	= quat.x * num
	local num5 	= quat.y * num2
	local num6 	= quat.z * num3
	local num7 	= quat.x * num2
	local num8 	= quat.x * num3
	local num9 	= quat.y * num3
	local num10 = quat.w * num
	local num11 = quat.w * num2
	local num12 = quat.w * num3

	local x = (((1 - (num5 + num6)) * self.x) + ((num7 - num12) * self.y)) + ((num8 + num11) * self.z)
	local y = (((num7 + num12) * self.x) + ((1 - (num4 + num6)) * self.y)) + ((num9 - num10) * self.z)
	local z = (((num8 - num11) * self.x) + ((num9 + num10) * self.y)) + ((1 - (num4 + num5)) * self.z)

	self:Set(x, y, z)
	return self
end

function Vector3.AngleAroundAxis (from, to, axis)
	from = from - Vector3.Project(from, axis)
	to = to - Vector3.Project(to, axis)
	local angle = Vector3.Angle (from, to)
	return angle * (Vector3.Dot (axis, Vector3.Cross (from, to)) < 0 and -1 or 1)
end

function Vector3:Split()
	return self.x, self.y, self.z
end


--Vector3.__tostring = function(self)
--return "["..self.x..","..self.y..","..self.z.."]"
--end

function Vector3:ToString()
	return "["..self.x..","..self.y..","..self.z.."]"
end

Vector3.__div = function(va, d)
	return _new(va.x / d, va.y / d, va.z / d)
end

Vector3.__mul = function(va, d)
	if type(d) == "number" then
		return _new(va.x * d, va.y * d, va.z * d)
	else
		local vec = va:Clone()
		vec:MulQuat(d)
		return vec
	end
end

Vector3.__add = function(va, vb)
	return _new(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

Vector3.__sub = function(va, vb)
	return _new(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

Vector3.__unm = function(va)
	return _new(-va.x, -va.y, -va.z)
end

Vector3.__eq = function(a,b)
	local diff_x = a.x - b.x
	local diff_y = a.y - b.y
	local diff_z = a.z - b.z

	if math.abs(diff_x) < 1e-10 and
			math.abs(diff_y) < 1e-10 and
			math.abs(diff_z) < 1e-10 then
		return true
	end

	return false
	--local diff_y = a.y - b.y
	--local diff_z = a.z - b.z

	--if diff_x < 1e-10

	--local v = a - b
	--local delta = v:SqrMagnitude()
	--return delta < 1e-10
end


-- https://www.lua.org/pil/13.4.5.html
function readOnly (t)
	local proxy = {}
	local mt = {       -- create metatable
		__index = t,
		__newindex = function (t,k,v)
			Logger.LogError("(const) can not be writed : "..k)
		end
	}
	setmetatable(proxy, mt)
	return proxy
end

local ConstVector3 = DeepCopy(Vector3)
ConstVector3.__newindex = function(tb, key, value)
	if ConstVector3[key] == nil then
		Logger.LogError(tb.__cname.." write err: No key named : "..key.."\n"..table.dump(tb), 2)
	else
		Logger.LogError(tb.__cname.."(const) can not be writed : "..key, 2)
	end
end

function Vector3.ConstNew(x1, y1, z1)
	local t = setmetatable({x = x1, y = y1, z = z1}, ConstVector3)
	--t = readOnly(t)
	-- 打开上面这行会导致loading界面黑屏，不知道什么原因
	return t
end

-- 这个优化成一个静态只读共享的变量
-- 我们大部分代码都是按照常量方式去做的，
-- ********** 注意 **********
-- 这种优化的缺点是丢失了Vector3的元表，但是也可以修复，以后需要的话
local table_up 		= nil
local table_down 	= nil
local table_right 	= nil
local table_left 	= nil
local table_forward = nil
local table_back 	= nil
local table_zero 	= nil
local table_one 	= nil

_getter.up 		= function()
	--if table_up == nil then table_up = Vector3.ConstNew(0,1,0) end
	--return table_up
	return Vector3.New(0,1,0)
end

_getter.down 	= function()
	--if table_down == nil then table_down = Vector3.ConstNew(0,-1,0) end
	--return table_down
	return Vector3.New(0,-1,0)
end

_getter.right	= function()
	--if table_right == nil then table_right = Vector3.ConstNew(1,0,0) end
	--return table_right
	return Vector3.New(1,0,0)
end

_getter.left	= function()
	--if table_left == nil then table_left = Vector3.ConstNew(-1,0,0) end
	--return table_left
	return Vector3.New(-1,0,0)
end

_getter.forward = function()
	--if table_forward == nil then table_forward = Vector3.ConstNew(0,0,1) end
	--return table_forward
	return Vector3.New(0,0,1)
end

_getter.back	= function()
	--if table_back == nil then table_back = Vector3.ConstNew(0,0,-1) end
	--return table_back
	return Vector3.New(0,0,-1)
end

_getter.zero	= function()
	--if table_zero == nil then table_zero = Vector3.ConstNew(0,0,0) end
	--return table_zero
	return Vector3.New(0,0,0)
end

_getter.one		= function()
	--if table_one == nil then table_one = Vector3.ConstNew(1,1,1) end
	--return table_one
	return Vector3.New(1,1,1)
end


_getter.magnitude	= Vector3.Magnitude
_getter.normalized	= Vector3.Normalize
_getter.sqrMagnitude= Vector3.SqrMagnitude

Vector3.unity_vector3 = CS.UnityEngine.Vector3
CS.UnityEngine.Vector3 = Vector3
setmetatable(Vector3, Vector3)

--table.set_const(Vector3.zero)

return Vector3
