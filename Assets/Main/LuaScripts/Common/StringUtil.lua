--[[
-- added by wsh @ 2017-12-18
-- string扩展工具类，对string不支持的功能执行扩展
--]]

local unpack = unpack or table.unpack
local split_ss_array_ = string.split_ss_array

-- 字符串分割
-- @split_string：被分割的字符串
-- @pattern：分隔符，可以为模式匹配
-- @init：起始位置
-- @plain：为true禁用pattern模式匹配；为false则开启模式匹配
local function lua_split(split_string, pattern, search_pos_begin, plain)
	search_pos_begin = search_pos_begin or 1
	plain = plain or true
	local split_result = {}
	assert(type(split_string) == "string")
	assert(type(pattern) == "string" and #pattern > 0)
	pattern = pattern or ","
	if type(split_string) ~= "string" then
		return split_result
	end	

	while true do
		local find_pos_begin, find_pos_end = string.find(split_string, pattern, search_pos_begin, plain)
		if not find_pos_begin then
			break
		end
		local cur_str = ""
		if find_pos_begin > search_pos_begin then
			cur_str = string.sub(split_string, search_pos_begin, find_pos_begin - 1)
		end
		split_result[#split_result + 1] = cur_str
		search_pos_begin = find_pos_end + 1
	end

	if search_pos_begin <= string.len(split_string) then
		split_result[#split_result + 1] = string.sub(split_string, search_pos_begin)
	else
		split_result[#split_result + 1] = ""
	end

	return split_result
end

local function split(split_string, pattern)
	return string.split_ss_array(split_string, pattern)
end

-- 字符串连接
function join(join_table, joiner)
	return table.concat(join_table, joiner)
end

-- 是否包含
-- 注意：plain为true时，关闭模式匹配机制，此时函数仅做直接的 “查找子串”的操作
function contains(target_string, pattern, plain)
	plain = plain or true
	local find_pos_begin, find_pos_end = string.find(target_string, pattern, 1, plain)
	return find_pos_begin ~= nil
end

-- 以某个字符串开始
--function startswith(target_string, str)
	--local find_pos_begin, find_pos_end = string.find(target_string, str, 1, true)
	--return find_pos_begin == 1
--end
function startswith(target_string, str)
	local target_len = #target_string
	local str_len = #str

	-- 如果目标字符串的长度小于子串的长度，直接返回 false
	if target_len < str_len then
		return false
	end

	-- 使用 string.byte 按字节逐一比较，避免使用 sub
	for i = 1, str_len do
		if string.byte(target_string, i) ~= string.byte(str, i) then
			return false
		end
	end

	return true
end

-- 以某个字符串结尾
function endswith(target_string, str)
	local find_pos_begin, find_pos_end = string.find(target_string, str, -#str, true)
	return find_pos_end == #target_string
end

--数字以K,M，G表示
local function GetFormattedStr(value)
	if value == nil then
		Logger.LogError(debug.traceback("value is nil!!", 5))
		value = 0
	end
	
	if value == 0 then
		return "0"
	end

	local unit = ""
	if value < 0 then
		value = -value
		unit = "-"
	end

	--zlh：这里之所以要先整除后再除10是为了规避Lua %.1f默认的四舍五入，和改之前保持语义一致
	if value >= 1e9 then
		return string.format("%s%.1fG", unit, value // 1e8 / 10)
	elseif value >= 1e6 then
		return string.format("%s%.1fM", unit, value // 1e5 / 10)
	elseif value >= 1e3 then
		return string.format("%s%.1fK", unit, value // 1e2 / 10)
	else
		return string.format("%s%d", unit, math.floor(value))
	end
end

--数字以K,M，G表示，保留小数点后两位
local function GetFormattedStrDot2(value)
	if value == nil then
		Logger.LogError("value is nil!!")
		value = 0
	end
	
	if value == 0 then
		return "0"
	end

	local unit = ""
	if value < 0 then
		value = -value
		unit = "-"
	end

	--zlh：这里之所以要先整除后再除10是为了规避Lua %.1f默认的四舍五入，和改之前保持语义一致
	if value >= 1e9 then
		string.format("%s%.2fG", unit, value // 1e8 / 10)
	elseif value >= 1e6 then
		return string.format("%s%.2fM", unit, value // 1e5 / 10)
	elseif value >= 1e3 then
		return string.format("%s%.2fK", unit, value // 1e2 / 10)
	else
		return string.format("%s%d", unit, math.floor(value))
	end
end

--数字以K,M，G表示，保留小数点后两位(不四舍五入)
local function GetFormattedStrDot2_NotRound(value)
	if value == nil then
		Logger.LogError("value is nil!!")
		value = 0
	end

	if value == 0 then
		return "0"
	end

	local unit = ""
	if value < 0 then
		value = -value
		unit = "-"
	end

	if value >= 1e9 then
		return string.format("%s%.2fG", unit, value / 1e9)
	elseif value >= 1e6 then
		return string.format("%s%.2fM", unit, value / 1e6)
	elseif value >= 1e3 then
		return string.format("%s%.2fK", unit, value / 1e3)
	else
		return string.format("%s%d", unit, math.floor(value))
	end
end



--千位分隔符
local function GetFormattedSeperatorNum(n)
	if n == nil then
		Logger.LogError("GetFormattedSeperatorNum is 0!")
		return '0'
	end
		
	if type(n) ~= 'number' then
		n = tonumber(n)
		if App.IsEditor() then
			Logger.LogError("n must be a number!!!!!!!")
		end
	end

	-- 如果是< 1000的值，没必要去做,号分割了
	-- 同时返回一个数字而非字符串了。因为这个代码最终处理是要显示一个值，
	-- :SetText 这个函数；传数字底层一样可以处理
	if n < 1000 then
		--return tostring(n)
		return n
	end
	
	local left, num, right = string.match(tostring(n), '^([^%d]*%d)(%d*)(.-)$')
	if not num or #num == 0 then
		return left .. right
	end
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

local function GetFormattedSpecial(value)
	if value>= 1000000 then
		return string.GetFormattedStr(value)
	else
		return string.GetFormattedSeperatorNum(math.floor(value))
	end
end

local function GetFormattedGoldNum(value)
	value = tonumber(value) or 0
	if value>= 100000 then
		return string.GetFormattedStr(value)
	else
		return string.GetFormattedSeperatorNum(math.floor(value))
	end
end

local function GetFormattedOfflineNum(value)
	if value >= 10000 then
		return string.GetFormattedStr(value)
	else
		return string.GetFormattedSeperatorNum(math.floor(value))
	end
end

local function GetFormattedPowerStr(value)
	value = tonumber(value) or 0
	if value>= 10000000 then
		return string.GetFormattedStr(value)
	elseif value >= 100000 then
		return string.format("%.1fK", value / 1000)
	else
		return string.GetFormattedSeperatorNum(math.floor(value))
	end
end

local function GetFormattedPowerStr2(value)
	if value > 10000 then
		return string.format("%.1fK", value / 1000)
	else
		return string.GetFloatStr(value)
	end
end

--浮点数
local function GetFloatStr(value)
	if value ==0 then
		return "0"
	end
	return string.format("%.1f",value)
end

--不进行四舍五入
local function GetFloatStr_NotRound(value)
	if value == 0 then
		return "0"
	end
	
	value = math.floor(value * 10)
	return tostring(value / 10)
end

--百分比
local function GetFormattedPercentStr(value)
	value = value *100
	return string.format("%.1f%%",value)
end

--百分比--小数点后两位
local function GetFormattedPercentStrSpecial(value)
	value = value *100
	return string.format("%.2f%%",value)
end

--百分比
local function GetFormattedThousandthStr(value)
	value = value *1000
	return string.format("%.1f%‰",value)
end

local function IsNullOrEmpty(str)
	if str == nil or str == "" then
		return true
	end
	return false
end

function string.findlast(s, pattern, plain)
	local curr = 0
	repeat
		local next = s:find(pattern, curr + 1, plain)
		if (next) then curr = next end
	until (not next)
	if (curr > 0) then
		return curr
	end
end


local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end


function string.IsNullOrEmpty(value)
	if (value == nil or value == "") then
		return true
	end
	return false
end

-- string[i]
local function at(str, pos)
	return string.sub(str, pos, pos)
end

-- 计算字符串的字符个数
-- https://blog.csdn.net/fightsyj/article/details/83589997
local function word_count(input)
	local len  = string.len(input)
	local left = len
	local cnt  = 0
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i   = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

-- string解析成table
-- a=b;c=d
-- 解析成<int, int>
local function string2table_ii(str, sep1, sep2)
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_ii_map(str, sep1, sep2)
	return t
	
	--local t = {}
	
	--local ts = string.split(str, sep2)
	--for _, v in ipairs(ts) do
		--local ts2 = string.split(v, sep1)
		--if ts2 and #ts2 == 2 then
			--local k = math.tointeger(ts2[1])
			--local v = math.tointeger(ts2[2])
			--if k and v then
				--t[k] = v
			--end
		--end
	--end

	--return t
end

local function string2table_ss(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_ss_map(str, sep1, sep2)
	return t
end

local function string2table_si(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_si_map(str, sep1, sep2)
	return t
end

local function string2table_is(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_is_map(str, sep1, sep2)
	return t
end

local function string2table_sf(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_sf_map(str, sep1, sep2)
	return t
end

local function string2table_if(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ";"
	sep2 = sep2 or "="

	local t = string.split_if_map(str, sep1, sep2)
	return t
end


-- 字符串变成array
-- 譬如"1,2,3,4,5" => {1,2,3,4,5}
local function string2array_i(str, sep1)
	str = str or ""
	sep1 = sep1 or ","

	local t = string.split_ii_array(str, sep1)
	return t
end

-- FIXME: 这个地方做一个兼容处理
local function string2array_s(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ","

	if sep2 == nil then
		local t = string.split_ss_array(str, sep1)
		return t
	end
	
	Logger.Error("error! please use string2array2d_s instead!!")
	return string.string2array2d_s(str, sep1, sep2)
end

local function string2array_f(str, sep1)
	str = str or ""
	sep1 = sep1 or ","

	local t = string.split_ff_array(str, sep1)
	return t
end

-- 变成一个2维数组
-- a,b,c,d|e,f,g,h => {{a,b,c,d}, {e,f,g,h}}
local function string2array2d_s(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ","
	sep2 = sep2 or "|"
	
	local t = {}

	local ts = string.split(str, sep2)
	for _, v in ipairs(ts) do
		local ts2 = string.split(v, sep1)
		table.insert(t, ts2 or {})
	end
	
	return t
end

-- 1,2,3,4|5,6,7,8 => {{1,2,3,4}, {5,6,7,8}}
local function string2array2d_i(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ","
	sep2 = sep2 or "|"

	local t = {}

	local ts = string.split(str, sep2)
	for _, v in ipairs(ts) do
		local ts2 = string.string2array_i(v, sep1)
		table.insert(t, ts2 or {})
	end

	return t
end

local function string2array2d_f(str, sep1, sep2)
	str = str or ""
	sep1 = sep1 or ","
	sep2 = sep2 or "|"

	local t = {}

	local ts = string.split(str, sep2)
	for _, v in ipairs(ts) do
		local ts2 = string.string2array_f(v, sep1)
		table.insert(t, ts2 or {})
	end

	return t
end

-- 字符串分割成两个int
-- a=b形式
local function string2_ii(str, sep)
	str = str or ""
	sep = sep or "="

	local k,v = string.split_ii(str, sep)
	return k,v
end

local function string2_ss(str, sep)
	str = str or ""
	sep = sep or "="

	local k,v = string.split_ss(str, sep)
	return k,v
end

local function string2xy_i(str, sep)
	str = str or ""
	sep = sep or "="
	
	if string.IsNullOrEmpty(str) then
		return 0,0
	end

	local k,v = string.split_ii(str, sep)
	if k == nil or v == nil then
		local s = "string2xy_i error!" .. tostring(str)
		Logger.Log(debug.traceback(s, 5))
	end
	
	k = k or 0
	v = v or 0
	return k,v
end

local function string2xy_f(str, sep)
	str = str or ""
	sep = sep or "="

	local k,v = string.split_ff(str, sep)
	if k == nil or v == nil then
		Logger.LogError(debug.traceback("string2xy_f error!" .. tostring(str), 3))
	end
	
	k = k or 0
	v = v or 0
	return k,v
end

-- FIXME: 这个以后放到C中，暂时先用lua写
-- 这个是把1-5;6-10;这样的字符串变成一个table，含有{1,2,3,4,5,6,7,8,9,10}
local function string2_indextable(str, tbl)
	table.clear(tbl)
	if not string.IsNullOrEmpty(str) then
		local ss = string.split(str, ";")
		for _, str in ipairs(ss) do
			local spl = string.split_ii_array(str, "-")
			if #spl == 1 then
				table.insert(tbl, spl[1])
			elseif #spl == 2 then
				for i = spl[1], spl[2] do
					table.insert(tbl, i)
				end
			end
		end
	end
end

--local function split_ss(str, sep)
	--return string.split_ss(str, sep)
--end

local function split_ss_array(str, sep)
	if string.IsNullOrEmpty(str) then
		return {}
	end
	
	return split_ss_array_(str, sep)
end

---字符串解析  234234|234#234#453
---@param originTxt string
local function GetDialogIdAndParam(originTxt)
	--先把DialogId分离出来
	local arr = string.split(originTxt,"|")
	local dialogId = arr[1]
	local count = #arr
	if count == 1 then
		return dialogId, {}
	else
		--分离参数
		local arr2 = string.split(arr[2], "#")
		local tab = {}
		for i = 1, #arr2 do
			local v = tonumber(arr2[i])
			if v then
				table.insert(tab, v)
			else
				table.insert(tab, arr2[i])
			end
		end
		return dialogId, tab
	end
end

--local function _split_ii_array(str, sep)
	--return string.split_ii_array(str, sep)
--end

--local function _split_ff_array(str, sep)
	--return string.split_ff_array(str, sep)
--end

--string._split_ii_array = _split_ii_array
--string._split_ff_array = _split_ff_array

local function GetBytes(char)
	if not char then
		return 0
	end
	local code = string.byte(char)
	if code < 127 then
		return 1
	elseif code <= 223 then
		return 2
	elseif code <= 239 then
		return 3
	elseif code <= 247 then
		return 4
	else
		return 0
	end
end

local function SubStr(str, startIndex, endIndex)
	local tempStr = str
	local byteStart = 1 -- string.sub截取的开始位置
	local byteEnd = -1 -- string.sub截取的结束位置
	local index = 0  -- 字符记数
	local bytes = 0  -- 字符的字节记数

	startIndex = math.max(startIndex, 1)
	endIndex = endIndex or -1
	while string.len(tempStr) > 0 do
		if index == startIndex - 1 then
			byteStart = bytes+1
		elseif index == endIndex then
			byteEnd = bytes
			break
		end
		bytes = bytes + GetBytes(tempStr)
		tempStr = string.sub(str, bytes+1)

		index = index + 1
	end
	return string.sub(str, byteStart, byteEnd)
end

local function PrintHex(data, datalen)
	local t = {}
	for i = 1, datalen do
		local char = string.sub(data, i, i)
		table.insert(t, string.format("%02x", string.byte(char)))
	end
	
	local str = table.concat(t, ' ')
	print(str)
end

local function GetRealLen(str)
	if not str or type(str) ~= "string" or #str <= 0 then
		return 0
	end

	local length = 0
	local i = 1
	while true do
		local curByte = string.byte(str, i)
		local byteCount = 1
		if curByte > 239 then
			byteCount = 4
		elseif curByte > 223 then
			byteCount = 3
		elseif curByte > 128 then
			byteCount = 2
		else
			byteCount = 1
		end
		i = i + byteCount
		length = length + 1
		if i > #str then
			break
		end
	end
	return length
end

function string.Str2ColorTable(hex)
    hex = hex:gsub("#","")
	if hex:len() == 3 then
		return Color.New((tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255)
	  else
		return Color.New(tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255)
	  end
end

local function insert(str,index,insertStr, flag)
	if flag and string.find(str, flag) ~=nil then
		index = index + #flag
	end
	local pre = string.sub(str, 1, index -1)
	local tail = string.sub(str, index, -1)
	local createStr = string.format("%s%s%s", pre, insertStr, tail)
	return createStr
end

--2位百分号显示
local function GetReasonPercent(num)
	local effectValueX, effectValueY = math.modf(num)
	if effectValueY < ModfRange then
		return effectValueX .. "%"
	else
		effectValueX, effectValueY = math.modf(num * 10)
		if effectValueY < ModfRange then
			return string.format("%.1f%%", num)
		else
			return string.format("%.2f%%", num)
		end
	end
end

local NUMBERIC_UNIT =
{
	[1] = "",
	[2] = "K",
	[3] = "M",
	[4] = "B",
	-- [5] = "t",
	-- [6] = "q",
	-- [7] = "Q",
	-- [8] = "s",
	-- [9] = "S",
}

-- 取换算为大数词头的数量字符串
local floor = math.floor;

local function numbericFormationWithPrefix(value, digits, sep)
	digits = digits or 5
	digits = math.max(digits, 1)

	local sign = ""
	if value < 0 then
		value = -value
		sign = "-"
	end
	value = floor(value);

	local judge = 1
	for i = 1, digits do
		judge = judge * 10
	end

	local unitIdx = 1;
	local remainder = 0;
	while value >= judge and value >= 1000 and unitIdx < #NUMBERIC_UNIT do
		remainder = value % 1000;
		value = floor(value / 1000);
		unitIdx = unitIdx + 1;
	end

	local str = tostring(value)
	local fillDigits = digits - string.len(str)
	if sep then
		local count = floor((string.len(str) - 1) / 3)
		for i = 1, count do
			local index = string.len(str) - i * 3 + 1 - (i - 1)
			str = string.insert(str, index, sep)
		end
	end
	if fillDigits > 0 and unitIdx > 1 then
		str = str..'.'
		str = str .. string.sub(string.format("%03d", remainder), 1, fillDigits)
	end
	return sign .. str .. NUMBERIC_UNIT[unitIdx]
end

---只支持颜色的富文本
---@param text string
local function GetRichTextOnlyColor(text)
	-- 检查输入是否为字符串
	if string.IsNullOrEmpty(text) or type(text) ~= "string" then
		-- 如果输入不是字符串或为空，直接返回空字符串
		return ""
	end
	
	-- 使用 gsub 替换掉所有非颜色的富文本标签
	local result = text:gsub("<(.-)>", function(tag)
		-- 检查是否是颜色标签
		if tag:match("^color=[\"']?#?%w+['\"]?") or tag == "/color" then
			-- 如果是颜色标签，保留
			return "<" .. tag .. ">"
		else
			-- 去除非颜色标签
			return ""
		end
	end)
	
	return result
end

local function SubStrByNum(str,length)
	local tempStr = str
	local arr = {}
	if #str>length then
		local count = 0
		while #tempStr>0 and count<100 do
			local a = string.sub(tempStr,1,length)
			local b = ""
			if #tempStr>=length+1 then
				b = string.sub(tempStr,length+1,#tempStr)
			end
			table.insert(arr,a)
			tempStr = b
			count = count+1
		end
	else
		table.insert(arr,tempStr)
	end
	return arr
end

local function SubStrByNum_ChatGPT(str, length)
	-- 输入校验
	if not str or type(str) ~= "string" or length <= 0 then
		error("Invalid input: str must be a string and length must be greater than 0")
	end

	local arr = {}
	local strLen = #str
	local i = 1

	-- 按指定长度切分字符串
	while i <= strLen do
		local segment = string.sub(str, i, i + length - 1)
		table.insert(arr, segment)
		i = i + length
	end

	return arr
end


--string._split_ss_array = _split_ss_array
string.split_ss_array = split_ss_array
--string._split_ss = _split_ss
string.split = split
string.join = join
string.contains = contains
string.startswith = startswith
string.endswith = endswith
string.GetFormattedStr = GetFormattedStr
string.GetFormattedStrDot2 = GetFormattedStrDot2
string.GetFormattedStrDot2_NotRound = GetFormattedStrDot2_NotRound
string.GetFormattedGoldNum = GetFormattedGoldNum
string.GetFormattedSeperatorNum = GetFormattedSeperatorNum
string.GetFormattedPowerStr = GetFormattedPowerStr
string.GetFormattedPowerStr2 = GetFormattedPowerStr2
string.GetFloatStr = GetFloatStr
string.GetFloatStr_NotRound = GetFloatStr_NotRound
string.GetFormattedPercentStr = GetFormattedPercentStr
string.GetFormattedPercentStrSpecial = GetFormattedPercentStrSpecial
string.IsNullOrEmpty = IsNullOrEmpty
string.at = at
string.trim = trim
string.word_count = word_count
string.GetFormattedThousandthStr = GetFormattedThousandthStr
string.string2table_ii = string2table_ii
string.string2table_ss = string2table_ss
string.string2table_si = string2table_si
string.string2table_is = string2table_is
string.string2table_sf = string2table_sf
string.string2table_if = string2table_if
string.string2array_i = string2array_i
string.string2array_s = string2array_s
string.string2array_f = string2array_f
string.string2_ii = string2_ii
string.string2_ss = string2_ss
string.string2_indextable = string2_indextable
string.string2array2d_s = string2array2d_s
string.string2array2d_i = string2array2d_i
string.string2array2d_f = string2array2d_f
string.string2xy_i = string2xy_i
string.string2xy_f = string2xy_f
string.GetDialogIdAndParam = GetDialogIdAndParam
string.GetRichTextOnlyColor = GetRichTextOnlyColor

string.numbericFormationWithPrefix = numbericFormationWithPrefix
string.insert = insert
string.GetFormattedOfflineNum = GetFormattedOfflineNum
string.GetReasonPercent = GetReasonPercent

string.GetFormattedSpecial = GetFormattedSpecial
string.GetBytes = GetBytes
string.SubStr = SubStr
string.PrintHex = PrintHex
string.GetRealLen = GetRealLen
string.SubStrByNum = SubStrByNum
string.SubStrByNum_ChatGPT = SubStrByNum_ChatGPT