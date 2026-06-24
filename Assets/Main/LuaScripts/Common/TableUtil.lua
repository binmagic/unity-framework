--[[
-- added by wsh @ 2017-12-11
-- table扩展工具类，对table不支持的功能执行扩展
-- 注意：
-- 1、所有参数带hashtable的函数，将把table当做哈希表对待
-- 2、所有参数带array的函数，将把table当做可空值数组对待
-- 3、所有参数带tb的函数，对表通用，不管是哈希表还是数组
--]]

-- 计算哈希表长度
local function count(hashtable)
	if type(hashtable) ~= "table" then
		return 0
	end
	local count = 0
	for _,_ in pairs(hashtable) do
		count = count + 1
	end
	return count
end

-- 计算数据长度
local function length(array)
	if array.n ~= nil then
		return array.n
	end
	
	local count = 0
	for i,_ in pairs(array) do
		if count < i then
			count = i
		end		
	end
	return count
end

-- 获取哈希表所有键
local function keys(hashtable)
    local keys = {}
	local i = 1
    for k, v in pairs(hashtable) do
        keys[i] = k
		i = i + 1
    end
    return keys
end

-- 获取哈希表所有值
local function values(hashtable)
    local values = {}
	local i = 1
    for k, v in pairs(hashtable) do
        values[i] = v
		i = i + 1
    end
    return values
end

-- 合并哈希表：将src_hashtable表合并到dest_hashtable表，相同键值执行覆盖
local function merge(dest_hashtable, src_hashtable)
    for k, v in pairs(src_hashtable) do
        dest_hashtable[k] = v
    end
end

-- 合并数组：将src_array数组从begin位置开始替换到dest_array数组
-- 注意：begin <= 0被认为没有指定起始位置，则将两个数组执行拼接
local function insertto(dest_array, src_array, begin)
	assert(begin == nil or type(begin) == "number")
	if begin == nil or begin <= 0 then
		begin = #dest_array + 1
	end

	local src_len = #src_array
	for i = 0, src_len - 1 do
		dest_array[i + begin] = src_array[i + 1]
	end
end

-- 从数组中查找指定值，返回其索引，没找到返回false
local function indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then 
			return i 
		end
    end
	return false
end

-- 从哈希表查找指定值，返回其键，没找到返回nil
-- 注意：
-- 1、containskey用hashtable[key] ~= nil快速判断
-- 2、containsvalue由本函数返回结果是否为nil判断
local function keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then 
			return k 
		end
    end
    return nil
end

-- 从数组中删除指定值，返回删除的值的个数
function table.removebyvalue(array, value, removeall)
    local remove_count = 0
	for i = #array, 1, -1 do
		if array[i] == value then
			table.remove(array, i)
			remove_count = remove_count + 1
            if not removeall then 
				break 
			end
		end
	end
	return remove_count
end

-- 从数组中删除指定值，返回删除的值的个数
function table.removebyfunc(array, predict)
	local remove_count = 0
	if type(predict) ~= "function" then
		return remove_count
	end
	
	for i = #array, 1, -1 do
		if predict(array[i]) == true then
			table.remove(array, i)
			remove_count = remove_count + 1
		end
	end
	return remove_count
end

-- 遍历写：用函数返回值更新表格内容
local function map(tb, func)
    for k, v in pairs(tb) do
        tb[k] = func(k, v)
    end
end

-- 遍历读：不修改表格
local function walk(tb, func)
	if tb == nil or func == nil then
		return
	end
	
    for k,v in pairs(tb) do
        func(k, v)
    end
end

-- lua对于有UpValue的Closure，内部大概率会每次new一个新的
-- 所以我们这里将UpValue彻底拿出去，使用传参的形式传入。减少无意义的GC
-- 在lua中，只有Closure类型，普通函数只是没有UpValue的Closure
-- 所以在比较频繁的调用里，请使用walkex传递参数的版本，
-- 第一个参数为返回值(一般用来计数或者返回遍历的数据)
-- 也可以把self通过...传进去，然后赋值
local function walkex(tb, func, ret, ...)
	for k,v in pairs(tb) do
		ret = func(k, v, ret, ...)
	end
	
	return ret
end

-- 按指定的排序方式遍历：不修改表格
local function walksort(tb, sort_func, walk_func)
	local keys = table.keys(tb)
	table.sort(keys, function(lkey, rkey)
		return sort_func(lkey, rkey)
	end)
	for i = 1, #keys do
		walk_func(keys[i], tb[keys[i]])
	end
end

-- 过滤掉符合条件的项：不对原表执行操作
local function filter(tb, func)
	local filter = {}
    for k, v in pairs(tb) do
        if not func(k, v) then 
			filter[k] = v
		end
    end
	return filter
end

-- 筛选出符合条件的项：不对原表执行操作
local function choose(tb, func)
	local choose = {}
    for k, v in pairs(tb) do
        if func(k, v) then 
			choose[k] = v
		end
    end
	return choose
end


-- dump表
local function dump(tb, dump_metatable, max_level)
	local lookup_table = {}
	local level = 0
	local rep = string.rep
	local dump_metatable = dump_metatable
	local max_level = max_level or 1

	local function _dump(tb, level)
		local str = "\n" .. rep("\t", level) .. "{\n"
		for k,v in pairs(tb) do
			local k_is_str = type(k) == "string" and 1 or 0
			local v_is_str = type(v) == "string" and 1 or 0
			str = str..rep("\t", level + 1).."["..rep("\"", k_is_str)..(tostring(k) or type(k))..rep("\"", k_is_str).."]".." = "
			if type(v) == "table" then
				if not lookup_table[v] and ((not max_level) or level < max_level) then
					lookup_table[v] = true
					str = str.._dump(v, level + 1, dump_metatable).."\n"
				else
					str = str..(tostring(v) or type(v))..",\n"
				end
			else
				str = str..rep("\"", v_is_str)..(tostring(v) or type(v))..rep("\"", v_is_str)..",\n"
			end
		end
		if dump_metatable then
			local mt = getmetatable(tb)
			if mt ~= nil and type(mt) == "table" then
				str = str..rep("\t", level + 1).."[\"__metatable\"]".." = "
				if not lookup_table[mt] and ((not max_level) or level < max_level) then
					lookup_table[mt] = true
					str = str.._dump(mt, level + 1, dump_metatable).."\n"
				else
					str = str..(tostring(v) or type(v))..",\n"
				end
			end
		end
		str = str..rep("\t", level) .. "},"
		return str
	end
	
	return _dump(tb, level)
end

local function reverse(tab)
	local tmp = {}
	for i = 1, #tab do
		tmp[i] = table.remove(tab)
	end

	return tmp
end

local function hasvalue(t, value)
	for k,v in pairs(t) do
		if (v == value) then
			return true
		end	
	end
	
	return false
end

local function containsKey( tab, key )
	for k, _ in pairs(tab) do
		if (k == key) then
			return true
		end
	end
	return false
end

local function IsEmpty(table)
	if type(table) ~= "table" then
		print("not a table!!!")
		return true
	end
	return next(table) == nil
end

local function IsNotEmpty(table)
	-- 检查参数是否为表类型，并且表不为空
	return type(table) == "table" and next(table) ~= nil
end

local function IsNullOrEmpty(table)
	if table == nil then
		return true
	end
	
	return IsEmpty(table)
end

-- 简单判断一个table是不是array
local function isarray(t)
	return #t > 0 and next(t, #t) == nil
end

-- table变成string
-- 最后变成a=b;c=d
local function table2string(t, sep1, sep2)
	sep1 = sep1 or ";"
	sep2 = sep2 or "="
	
	local msg = ""
	local i = 1
	for k,v in pairs(t) do
		if i == 1 then
			msg = msg .. k .. sep2 .. v
		else
			msg = msg .. sep1 .. k .. sep2 .. v
		end
		i = i + 1
	end
	
	return msg, i
end

-- 数组变字符串，没有key
-- 譬如LUA array = {{1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}}
-- 变成字符串1,2,3,4,5|6,7,8,9,10；其中sep1="," sep2="|"
local function array2string(t, sep1, sep2)
	sep1 = sep1 or ","
	sep2 = sep2 or "|"

	local msg = ""
	local i = 1
	for _,v in ipairs(t) do
		local segment
		if type(v) == "table" then
			segment = table.concat(v, sep1)
		else 
			segment = tostring(v)
		end
		
		if i == 1 then
			msg = segment
		else
			msg = msg .. sep2 .. segment
		end
		i = i + 1
	end

	return msg, i
end

-- 递归打印整个table
-- t: 打印table
-- r: 递归深度
-- https://blog.csdn.net/u012503639/article/details/98109164
local function print_r(t,r)
	r = r or 3
	local print_r_cache={}
	local function sub_print_r(t,d,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					local key = (type(pos)=="table" or type(pos)=="userdata") and "<"..type(pos)..">" or pos -- Beef edited
					if (type(val)=="table") then
						if d<=r then
							print(indent.."["..key.."] => "..tostring(t).." {")
							sub_print_r(val,d+1,indent..string.rep(" ",string.len(key)+8))
						else
							print(indent.."["..key.."] => "..tostring(t).." {...")
						end
						print(indent..string.rep(" ",string.len(key)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..key..'] => "'..val..'"')
					else
						print(indent.."["..key.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,1,"  ")
		print("}")
	else
		sub_print_r(t,1,"  ")
	end
	print()
end


-- 从表中随机取一个key
-- 注意table必须是一个array!
local function randomArrayValue(tbl)
	local idx = math.random(1, #tbl)
	return tbl[idx]
end

-- 清除一个table
local function clear(tbl)
	if not tbl then return end
	
	for k in pairs (tbl) do
		tbl [k] = nil
	end
end

-- 将两个个array合并
local function mergeArray(tbl1, tbl2)
	local tbl = {}
	for _, v in pairs(tbl1) do
		table.insert(tbl, v)
	end
	for _, v in pairs(tbl2) do
		table.insert(tbl, v)
	end
	return tbl
end

-- 将两个个array合并
local function mergeArray2(destTbl, tbl1, tbl2)
	
	local t = 1
	for _, v in pairs(tbl1) do
		destTbl[t] = v
		t = t + 1
	end
	for _, v in pairs(tbl2) do
		destTbl[t] = v
		t = t + 1
	end
	
	return destTbl
end

-- 将两个个array合并(di)
local function mergeTable(a, b)
	local result = {}
	if a ~= nil then
		for _, v in pairs(a) do
			table.insert(result, v)
		end
	end
	if b ~= nil then
		for _, v in pairs(b) do
			table.insert(result, v)
		end
	end

	return result
end

local function ToArray(a)
	local result = {}
	if a ~= nil then
		for _, v in pairs(a) do
			table.insert(result, v)
		end
	end
	return result
end

-- 插入不重复项，仅数组
local function unique_insert(tbl, value)
	for _,v in ipairs(tbl) do
		if v == value then
			return false
		end
	end
	
	tbl[#tbl+1] = value
	return true
end

local function removeSameValueOfTwoList(list1, list2, func)
	local deleteKeys = {}
	for k, value in pairs(list1) do
		local index = table.indexof(list2, value)
		if index then
			table.remove(list2, index)
			table.insert(deleteKeys, k)
			if func then func(value) end
		end
	end

	for _, k in pairs(deleteKeys) do
		table.remove(list1, k)
	end
end

local mt = {
	__newindex = function(t, k, v)
		Logger.LogError("attempt to set const table! " .. tostring(k) .. "=" .. tostring(v))
	end
}

local function set_const(t)
	setmetatable(t, mt)
	return t
end

local et = {}
setmetatable(et, mt)
table.empty = et

local function const_table(t)
	set_const(t)
	return t
end

--简单重新对一个table随机打乱
local function againObtain(tbl)
	local list = {}
	for i = 1 ,3 do
		local value = math.random(1, table.count(tbl))
		table.insert(list,value)
	end
	table.sort(list,function(a,b)
		if a < b then
			return true
		end
		return false
	end)
	local list1 = {}
	local list2 = {}
	for i = 1 ,table.count(tbl) do
		if i <= list[2] then
			table.insert(list1,1,tbl[i])
		else
			table.insert(list2,1,tbl[i])
		end
	end
	return table.mergeArray(list1,list2)
end

--table中如果存在值返回k
local function hasvalueForKey(t, value)
	for k,v in pairs(t) do
		if (v == value) then
			return k
		end
	end

	return false
end

--hashtable的第一个
local function first(hashTable)
	local key, value
	for k, v in pairs(hashTable) do
		key = k
		value = v
		break
	end
	return key, value
end


table.count = count
table.length = length
table.keys = keys
table.values = values
table.merge = merge
table.insertto = insertto
table.indexof = indexof
table.keyof = keyof
table.map = map
table.walk = walk
table.walkex = walkex
table.walksort = walksort
table.filter = filter
table.choose = choose
table.dump = dump
table.reverse = reverse
table.hasvalue = hasvalue
table.hasvalueForKey = hasvalueForKey
table.containsKey = containsKey
table.IsEmpty = IsEmpty
table.IsNotEmpty = IsNotEmpty
table.IsNullOrEmpty = IsNullOrEmpty
table.isarray = isarray
table.table2string = table2string
table.print = print_r
table.randomArrayValue = randomArrayValue
table.clear = clear
table.mergeArray = mergeArray
table.mergeArray2 = mergeArray2
table.mergeTable = mergeTable
table.unique_insert = unique_insert
table.removeSameValueOfTwoList = removeSameValueOfTwoList
table.set_const = set_const
table.againObtain = againObtain
table.const_table = const_table
table.first = first
table.ToArray = ToArray
