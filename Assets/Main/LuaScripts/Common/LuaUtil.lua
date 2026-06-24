--[[
-- added by wsh @ 2017-12-01
-- Lua全局工具类，全部定义为全局函数、变量
-- TODO:
-- 1、SafePack和SafeUnpack会被大量使用，到时候看需要需要做记忆表降低GC
**************************************************
	注释：
	作者用的lua版本应该是5.1，5.2之后的pack就支持...中间有hole了。
	所以尽量使用系统提供的pack吧。即table.pack 和 table.unpack
	1. table.pack会返回一个顺序填充的table，然后table会有一个属性n，
	   这个n主要用来表示这个table被填充的数量（包括末尾填充的nil）。
       所以n >= #table。你对table进行#操作，遇到nil之后就返回了。
	2. select主要用来返回...的长度（传入#）和具体某个位置的值（传入pos）
	3. 这里的优化主要是做了一些判断，如果不需要pack的话，就不pack了，
	   毕竟pack操作会产生一个临时的table。
--]]

local unpack = unpack or table.unpack
local pack = table.pack or function(...) return { n = select("#", ...), ... } end
local isEditor = CS.CommonUtils.IsEditor()
local debugTable = {}

-- 解决原生pack的nil截断问题，SafePack与SafeUnpack要成对使用
function SafePack(...)
	--local params = {...}
	--params.n = select('#', ...)
	--return params
	return pack(...)
end

-- 解决原生unpack的nil截断问题，SafePack与SafeUnpack要成对使用
function SafeUnpack(safe_pack_tb)
	return unpack(safe_pack_tb, 1, safe_pack_tb.n)
end

-- 对两个SafePack的表执行连接
function ConcatSafePack(safe_pack_l, safe_pack_r)
	local concat = {}
	for i = 1,safe_pack_l.n do
		concat[i] = safe_pack_l[i]
	end
	for i = 1,safe_pack_r.n do
		concat[safe_pack_l.n + i] = safe_pack_r[i]
	end
	concat.n = safe_pack_l.n + safe_pack_r.n
	return concat
end

-- 闭包绑定，单一参数，为了减少一些无用的GC
local function BindNone(self, func)
	local dstFun = function(...)
		if self ~= nil then
			func(self, ...)
		else
			func(...)
		end
	end

	-- !!!FIXME!!!
if isEditor then
	-- 勿删！ note: 关闭游戏时如果遇到BindNone中的匿名Delegate回调函数未释放 打开下方调试信息用于定位源信息 --add by zlh
	-- 使用方法：拿print_func_ref_by_csharp打印的出问题的addr和这里的比对 然后再根据此处打印的源信息定位最终出问题的代码文件
	local dstFunAddress = get_mem_addr(dstFun)
	local info = debug.getinfo(func)
	local srcFuncInfoStr = string.format(' %s:%d', info.short_src, info.linedefined)
	debugTable[dstFunAddress] = srcFuncInfoStr
	--Logger.Log("#zlh-delegate# addr: " .. dstFunAddress .. ", srcFuncInfoStr:" .. srcFuncInfoStr)
end
	
	return dstFun
end

-- 输出addr的相关信息
function OutputLeakAddress(addr)
	if isEditor then
		local infoStr = debugTable[addr]
		if infoStr then
			Logger.LogError("[Not Release, DO YOU UNDERSTAND?!]: ", infoStr)
		end
	end
end

local function BindSingle(self, func, param)
	assert(param ~= nil)
	return function(...)
		if self ~= nil then
			func(self, param, ...)
		else
			func(param, ...)
		end
	end
end

-- 闭包绑定
function Bind(self, func, ...)
	assert(self == nil or type(self) == "table")
	assert(func ~= nil and type(func) == "function")
	
	-- 如果0~1个参数的话特殊处理一下
	local pcount = select('#', ...)
	if pcount == 0 then
		return BindNone(self, func)
	elseif pcount == 1 then
		return BindSingle(self, func, select('1', ...))
	end
	
	local params = nil
	if self == nil then
		params = SafePack(...)
	else
		params = SafePack(self, ...)
	end
	return function(...)
		local args = ConcatSafePack(params, SafePack(...))
		func(SafeUnpack(args))
	end
end


-- 回调绑定
-- 重载形式：
-- 1、成员函数、私有函数绑定：BindCallback(obj, callback, ...)
-- 2、闭包绑定：BindCallback(callback, ...)
function BindCallback(...)
	
	local bindFunc = nil
	local param1, param2 = select(1, ...)
	
	if type(param1) == "table" and type(param2) == "function" then
		bindFunc = Bind(...)
	elseif type(param1) == "function" then
		bindFunc = Bind(nil, ...)
	else
		error("BindCallback : error params list!")
	end
	return bindFunc
end


-- 深拷贝对象
function DeepCopy(object)
	local lookup_table = {}
	
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end

		return setmetatable(new_table, getmetatable(object))
	end

	return _copy(object)
end

-- 序列化表
function Serialize(tb, flag)
	local result = ""
	result = string.format("%s{", result)

	local filter = function(str)
		str = string.gsub(str, "%[", " ")
		str = string.gsub(str, "%]", " ")
		str = string.gsub(str, '\"', " ")
		str	= string.gsub(str, "%'", " ")
		str	= string.gsub(str, "\\", " ")
		str	= string.gsub(str, "%%", " ")
		return str
	end

	for k,v in pairs(tb) do
		if type(k) == "number" then
			if type(v) == "table" then
				result = string.format("%s[%d]=%s,", result, k, Serialize(v))
			elseif type(v) == "number" then
				result = string.format("%s[%d]=%d,", result, k, v)
			elseif type(v) == "string" then
				result = string.format("%s[%d]=%q,", result, k, v)
			elseif type(v) == "boolean" then
				result = string.format("%s[%d]=%s,", result, k, tostring(v))
			else
				if flag then
					result = string.format("%s[%d]=%q,", result, k, type(v))
				else
					error("the type of value is a function or userdata")
				end
			end
		else
			if type(v) == "table" then
				result = string.format("%s%s=%s,", result, k, Serialize(v, flag))
			elseif type(v) == "number" then
				result = string.format("%s%s=%d,", result, k, v)
			elseif type(v) == "string" then
				result = string.format("%s%s=%q,", result, k, v)
			elseif type(v) == "boolean" then
				result = string.format("%s%s=%s,", result, k, tostring(v))
			else
				if flag then
					result = string.format("%s[%s]=%q,", result, k, type(v))
				else
					error("the type of value is a function or userdata")
				end
			end
		end
	end
	result = string.format("%s}", result)
	return result
end

-- 将阿拉伯数字转换为罗马数字 (1 ~ 3999)
function NumToRoman(num)
	-- 必须是正整数
	if type(num) ~= "number" or math.type(num) ~= "integer" or num <= 0 then
		return ""
	end
	
	local v = { 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1 }
	local r = { "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I" }
	local str = ""
	for i = 1, 13 do
		while num >= v[i] do
			num = num - v[i]
			str = str .. r[i]
		end
	end
	return str
end

-- 对于高度不是750的分辨率，所有长度都要缩放
function GetStandardScale()
	return CS.UnityEngine.Screen.height / 750
end

-- debug 不开启xpcall，快速发现问题
function XPCALL(fn, errFn, ...)
	if App.IsEditor() then	
		return true, fn(...)
	end
	
	local status, result = pcall(fn, ...)
	if status == false then
		Logger.LogError(result)
	end
	return status, result
end

-- 创建table，可以设置表的初始capacity，等同C的API接口lua_createtable
-- narr : array 元素预分配大小
-- nrec : hash 元素预分配大小
function createtable(narr, nrec)
	--return {}
	return cutils.lua_createtable(narr, nrec)
end

-- 
function unrequire(m)
	package.loaded[m] = nil
	_G[m] = nil
end

-- 专门用来设置TouchObjectEventTrigger:onPointerClick = nil
-- 因为这地方崩溃较多，所以专门提取一个函数来设置，并且打印日志看看究竟怎么回事
-- 默认不传tt，所以是nil
function SetPointerClick(obj, tt)
	if not IsNull(obj) then
		obj.onPointerClick = nil --tt
	else
		if obj then
			Logger.LogError(debug.traceback("Obj is not nil but invalid!!", 4))
		end
	end
end