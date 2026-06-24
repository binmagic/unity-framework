--[[
	这个文件里就是一些常用的短小函数
	基本上都是全局函数
]]


--[[--

检查并尝试转换为数值，如果无法转换则返回 0

@param mixed value 要检查的值
@param [integer base] 进制，默认为十进制

@return number

]]
function checknumber(value, base)
	return tonumber(value, base) or 0
end

function checkstring(value)
	return tostring(value) or ""
end

function BoolToInt(value)
	if value == nil or value == false or value == 0 then
		return 0
	end

	return 1
end

function IntToBool(value)
	if value == nil or value == 0 or value == false then
		return false
	end

	return true
end

-- 是否为浮点数
function isFloat(value)
	if type(value) == "number" and math.type(value) == "float" then
		return true
	end
	return false
end

function isInteger(value)
	if type(value) == "number" and math.type(value) == "integer" then
		return true
	end
	return false
end

function checktable(value)
	if type(value) ~= "table" then value = {} end
	return value
end

-- 字符串转成整数！
-- 加个兼容：如果是小数字符串的话，就直接取整吧
function toInt(value)
	local number = tonumber(value)
	if number then
		local int = math.tointeger(number)
		if int then
			return int
		end
		
		int = math.floor(number)
		return int
	end
	
	return 0
end

-- 两个浮点数比较
function float_equal(x,v)
	local EPSILON = 0.0000001
	local r = math.abs(x - v) < EPSILON
	return r
end

-- 等同于C#的 is
local is_generic
function IsType(obj, typeClass)
	if obj == nil then
		return false
	end

	if is_generic == nil then
		is_generic = xlua.get_generic_method(CS.CommonUtils, 'Is') --取得泛型方法
	end

	local is_func = is_generic(typeClass) --为泛型方法指定类型
	local ret = is_func(obj)
	return ret
end

--zlh: 把参数表转成URL查询字符串
function BuildQueryString(params)
	local UnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
	local parts = {}
	for k, v in pairs(params) do
		table.insert(parts, UnityWebRequest.EscapeURL(k) .. "=" .. UnityWebRequest.EscapeURL(v))
	end
	return table.concat(parts, "&")
end