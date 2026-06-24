--[[
	table表的一些高级操作
	主要是二分查找和二分插入
]]

-- Avoid heap allocs for performance
local default_fcompval = function( value ) return value end
local fcompf = function( a,b ) return a < b end
local fcompr = function( a,b ) return a > b end

-- 二分查找
-- http://lua-users.org/wiki/BinarySearch
function table.binsearch( tbl,value,fcompval,reversed )
	-- Initialise functions
	local fcompval = fcompval or default_fcompval
	local fcomp = reversed and fcompr or fcompf
	--  Initialise numbers
	local iStart,iEnd,iMid = 1,#tbl,0
	-- Binary Search
	while iStart <= iEnd do
		-- calculate middle
		iMid = math.floor( (iStart+iEnd)/2 )
		-- get compare value
		local value2 = fcompval( tbl[iMid] )
		-- get all values that match
		if value == value2 then
			local tfound,num = { iMid,iMid },iMid - 1
			while value == fcompval( tbl[num] ) do -- ERROR: this may cause fail in fcompval if num is out of range and tbl[num] is nil
				tfound[1],num = num,num - 1
			end
			num = iMid + 1
			while value == fcompval( tbl[num] ) do -- ERROR: this may cause fail in fcompval if num is out of range and tbl[num] is nil
				tfound[2],num = num,num + 1
			end
			return tfound
			-- keep searching
		elseif fcomp( value,value2 ) then
			iEnd = iMid - 1
		else
			iStart = iMid + 1
		end
	end
end



--[[
	table.bininsert( table, value [, comp] )
	
	Inserts a given value through BinaryInsert into the table sorted by [, comp].
	
	If 'comp' is given, then it must be a function that receives
	two table elements, and returns true when the first is less
	than the second, e.g. comp = function(a, b) return a > b end,
	will give a sorted table, with the biggest value on position 1.
	[, comp] behaves as in table.sort(table, value [, comp])
	returns the index where 'value' was inserted
]]--

-- 二分插入；在已经排序的table中，找到合适的位置并插入
-- http://lua-users.org/wiki/BinaryInsert
function table.bininsert(t, value, fcomp)
	-- Initialise compare function
	local fcomp = fcomp or fcompf
	--  Initialise numbers
	local iStart,iEnd,iMid,iState = 1,#t,1,0
	-- Get insert position
	while iStart <= iEnd do
		-- calculate middle
		iMid = math.floor( (iStart+iEnd)/2 )
		-- compare
		if fcomp( value,t[iMid] ) then
			iEnd,iState = iMid - 1,0
		else
			iStart,iState = iMid + 1,1
		end
	end
	table.insert( t,(iMid+iState),value )
	return (iMid+iState)
end


-- 这个算法中，first是最终要返回的位置
-- 传入的t，必须是array格式
function table.lower_bound(t, value, fcomp)
	-- Initialise compare function
	local fcomp = fcomp or fcompf
	--  Initialise numbers
	local iStart,iEnd,iMid,iState = 1,#t,1,0
	-- Get insert position
	while iStart <= iEnd do
		-- calculate middle
		iMid = math.floor( (iStart+iEnd)/2 )
		-- compare
		if fcomp( value,t[iMid] ) then
			iEnd,iState = iMid - 1,0
		else
			iStart,iState = iMid + 1,1
		end
	end
	
	return (iMid+iState)
end

--function table.upper_bound(t, value, fcomp)
	---- Initialise compare function
	--local fcomp = fcomp or fcompf
	----  Initialise numbers
	--local iStart,iEnd,iMid,iState = 1,#t,1,0
	---- Get insert position
	--while iStart <= iEnd do
		---- calculate middle
		--iMid = math.floor( (iStart+iEnd)/2 )
		---- compare
		--if fcomp( value,t[iMid] ) then
			--iEnd,iState = iMid - 1,0
		--else
			--iStart,iState = iMid + 1,1
		--end
	--end
--end

-- 从表中随机取一个key
function table.randomKey(tbl)
	local c = table.count(tbl)
	local idx = math.random(1, c)
	local i = 1
	
	for k, v in pairs(tbl) do
		if i == idx then
			return k
		end	
		i = i + 1
	end
	
	return nil
end

