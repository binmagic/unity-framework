--
-- 此文件是用来读取策划的配置表
--
-- 游戏的配置表，保存在LuaDatatable目录下
-- 每个配置表都是由原始的Excel导出至XML然后转成LUA table（此过程在后台php中自动完成）
-- 配置表的每行会有一个ID作为索引，列作为具体的配置功能
-- 
-- 通常获取配置表的方式如下：
-- 遍历某个表：
-- LocalController:instance():visitTable(<TableName.XXXX>, function(id,lineData) ... end)
--
-- 获取表某个ID的多个列：
-- local LineData = LocalController:instance():getLine(<TableName.XXXX>, <ID>)
-- local value1 = LineData:getValue(<"attr1">)
-- local value2 = LineData:getValue(<"attr2">)
-- 
-- 获取表某个ID的单个列：
-- local value = GetTableData(<TableName.XXXX>, <ID>, "<attr>")
-- local number = GetTableNumber(<TableName.XXXX>, <ID>, "<attr>")
--
-- 从性能来说，GetTableData最直接也最高效，它直接获取表格数据的列项，不会产生任何临时数据
-- 所以获取表格的原始数据来说，优先使用GetTableData
-- 但是也会有一个问题，当原始数据需要解析的话，譬如原始数据是: 1,2,3,4,5
-- 你就必须获取之后再去解析，如果是一个频繁调用的代码，就会比较耗时。
-- local value = GetTableData(<TableName.XXXX>, <ID>, "<attr>")
-- local arr = string.split(value, ",")
-- ** 上述代码禁止在多次或循环时使用。
--
-- 另一种获取表格数据的方法是，建立一个XXXTemplate，用一个lua的结构去表示策划表中的某一行
-- 然后再建立一个XXXTemplateManager用来管理整个表，
-- 相当于对lua table的数据做一个预处理，转换成最终的格式，然后去读取。
-- 譬如：
-- local item = DataCenter.XXXXTemplateManager:GetXXXXXTemplate(Id)
-- local value = item.attr1
-- 这种方法的优点是数据进行了预处理，所以使用起来相对方便，高效；适用于某个表中需要预处理数据较多的情况。
-- 但是缺点是需要建立一个Template类，如果表格中仅仅有某一，两列需要预处理，就会比较麻烦。
-- 同时此方法的缺点是增加了文件，增加了代码复杂度。
--
-- 最终为了平衡代码和优化，我增加了几个获取表格的函数
-- 这个函数会缓存某些列的数据，做到相对搞笑，且编码不会很麻烦。
-- 譬如：此代码是获取某一列中的数据，原始字符串是"1,2,3,4,5"，返回的就是一个table array[1,2,3,4,5]
-- GetTable_array_i(<TableName.XXXX>, <ID>, "<attr>")
-- 此接口同时会缓存这个结果数据，下次再获取的时候会直接返回
-- 切记，此方法仅适用于表格中仅仅有某一，两列数据需要解析处理的时候
-- 如果需要预处理的数据比较多，请使用上述XXXTemplate的方式！！
-- 注意：cached数据和原始数据存在两个地方，获取的时候可以获取原始数据，也可以获取cached数据！！取决于调用的接口！！
--
-- 附加的话，我们在生成表格lua table的时候，其实是支持按照配置的列的属性去生成的
-- 譬如某一列到底是int，还是float还是分割字符串
-- 但是由于策划改动一直比较大，经常改变列的格式或者定义，此方法不是很适合扩展
-- 譬如某一列之前是int，最后变成了int array，那么之前的所有代码都需要适应这种类型的改变，
-- 对应lua来讲，改动会比较大，所以最终为了权衡，基本舍弃了预设类型这种方式
--



LocalController = BaseClass("LocalController")
local instance_ = nil
local es = ''

function LocalController.instance()
    if not instance_ then
        instance_ = LocalController.New()
    end

    return instance_
end

function LocalController.__delete()
    if instance_ then
        instance_ = nil
    end
end


function LocalController:__init()
    --Logger.Log("LocalController:ctor")
    self.xmlValue={}
    self.xmlPath = "LuaDatatable."
    self.DataConfig = {}

    self.mtDataLine = {
        __index = function(t, key) 
                    return t:getValue(key) 
                end,
    }
	
	-- cached数据
	self.cached_data = {}
	self.et = {}
end

function LocalController:__delete()
	Logger.Log("LocalController:delete")
	self.xmlValue = nil
	self.xmlPath = nil
	self.DataConfig = nil
	self.mtDataLine = nil
	self.cached_data = nil
	self.et = nil
end

-- 设置表格路径
-- 表格热更或者什么，就需要进行设置了，设置目标目录
function LocalController:setTablePath(path)
end

-- 获取数据
function LocalController:getValue(xmlType, xmlId, xmlAttr, defValue)
	
	-- 表格没有初始化则去初始化
	local typeTable = self.xmlValue[xmlType]
	if typeTable == nil then
		typeTable = self:getTable(xmlType)
		if typeTable == nil then
			return defValue or es
		end
	end
	
	local lineData = typeTable["data"][xmlId]
	if lineData == nil then
		if type(xmlId) ~= 'number' then
			if App.IsEditor() then
				Logger.LogError(debug.traceback("xmlId is not number!"))
			end
		end	
		
		local xmlId = tonumber(xmlId)
		lineData = typeTable["data"][xmlId]
		if lineData == nil then
			return defValue or es
		end	
	end
	
	local indexData = typeTable["index"][xmlAttr]
	if indexData == nil then
		local strxmlAttr = tostring(xmlAttr)
		indexData = typeTable["index"][strxmlAttr]
		if indexData == nil then
			return defValue or es
		end
	end

	-- 索引数据
    local col = indexData[1]
	local value = lineData[col]
	if value == nil or value == "" then
		return defValue or es
	end
    return value
end

function LocalController:getIntValue(xmlType, xmlId, xmlAttr, defValue)
    local rValue = self:getValue(xmlType, xmlId, xmlAttr, defValue)
    -- 这里如果rValue == ''就表示表格中填的就是''，就走默认值
	if rValue == '' then
		return defValue or 0
	end
		
    return tonumber(rValue) or defValue or 0
end

function LocalController:getStrValue(xmlType, xmlId, xmlAttr, defValue)
    local rValue = self:getValue(xmlType, xmlId, xmlAttr, defValue)
    return tostring(rValue)
end

-- 获取表的某一个行，直接返回相应的table中的value值
function LocalController:getLineInternal(xmlType, xmlId)
    local ixmlId = tonumber(xmlId)

    -- 表格没有初始化初始化
    local t = self:getTable(xmlType)
    return t["data"][ixmlId]
end

-- 返回表示每一行数据
-- 就是一个包装类，用来方便访问具体的每一行数据
function LocalController:getLine(xmlType, xmlId)

    local ixmlId = tonumber(xmlId)
    local tbl = self:getTable(xmlType)

    -- 创建一个行访问器
    local LineData = self:createLineData(xmlType, ixmlId)
    LineData._indexData = tbl["index"]
    LineData._lineData = self:getLineInternal(xmlType, xmlId)
    if LineData._lineData == nil then
        return nil
    end

    -- LineData.lineData = self:getLineInternal(xmlType, xmlId)
    -- LineData.indexData = self.xmlValue[xmlType]["index"]

    return LineData
end

function LocalController:HasTableInMem( xmlType )
    return self.xmlValue[xmlType] ~= nil
end

-- 加载一个表文件
function LocalController:LoadTable(tableName)
	local t = nil
	local ret, error = pcall(
		function ()
			local before = 0
			local after
			
			if App.IsDebug() then
				before = collectgarbage("count")
			end

			local _xmlpath = self.xmlPath .. tostring(tableName)
			t = require(_xmlpath)

			if App.IsDebug() then
				after = collectgarbage("count")
				local changem = (after - before) / 1024
				if changem > 1 then
					print("[MEM]Table - ", tostring(tableName), ": (M):", changem)
				end
			end
		end)
	
	if ret == false then
		Logger.Log("LoadTable:", error)
		return nil
	end
	
	return t
end

-- 加载AB表
function LocalController:GetABTestTableName(tableName)
	if LuaEntry.DataConfig:CheckSwitch("ABtest_".. tableName) then
		local useAB = true
		if useAB and LuaEntry.Player.abTest ~= ABTestType.A then
			
			local bigname = tableName.."_B"
			if LocalController:instance():LoadTable(bigname) ~= nil then
				return bigname
			end
			
			local smallName = tableName.."_b"
			if LocalController:instance():LoadTable(smallName) ~= nil then
				return smallName
			end

		end
	elseif LuaEntry.Player:GetGMFlag() > 0 and LuaEntry.DataConfig:CheckSwitch(tableName .. "_GM") then
		local bigname = tableName.."_B"
		local smallName = tableName.."_b"

		if LocalController:instance():LoadTable(bigname) ~= nil then
			return bigname
		end

		if LocalController:instance():LoadTable(smallName) ~= nil then
			return smallName
		end
	end

	return tableName
end

-- 获取表
function LocalController:getTable(xmlType)
	
	-- 表格类型不存在吗？
	if xmlType == nil then
		print(debug.traceback())
        local str = debug.traceback()
        local newstr = "Error_NoXmlType_" .. str
        PostEventLog.Record(newstr)
		return nil
	end

	local xmlTable = rawget(self.xmlValue, xmlType)
	
	---------------------------------------------
    -- 表格没有初始化初始化
    if (xmlTable == nil) then
		
		if (string.contains(xmlType, "_B")) then
			local t
		end

		-- ab表直接写死在底层吧，应该不会有手动更换ab表的需求吧？
		-- 如果是b表的话，这个函数其实已经加载了表，而且同时返回了表的名字。
		local newXmlType = self:GetABTestTableName(xmlType)
		
		if App.IsEditor() then
			if newXmlType ~= xmlType then
				Logger.Log("@@@ abTest Read B Table : ", newXmlType)
			end
		end
		
		self.xmlValue[xmlType] = self:LoadTable(newXmlType)
		xmlTable = self.xmlValue[xmlType]
    end

    return xmlTable
end

-- 独立出来local 函数
local function _getValue(self, xmlAttr, defValue)

	if self._indexData[xmlAttr] ~= nil and self._lineData ~= nil then
		local t = self._lineData[self._indexData[xmlAttr][1]]
		return t
	end
	if (defValue ~= nil) then
		return defValue
	end

	return nil
end

local function _getIntValue(self, xmlAttr, defValue)
	local val = self.getValue(self, xmlAttr)
	return tonumber(val) or defValue or 0
end

local function _getStrValue(self, xmlAttr, defValue)
	local val = self.getValue(self, xmlAttr)
	if val then
		return tostring(val)
	end

	return defValue or es
end

-- 创建一个行访问器
-- 行访问器可以方便的访问一行数据
function LocalController:createLineData(xmlType, xmlId)
    local LineData = 
    {
        _xmlType = xmlType,
        _xmlId = xmlId,

        _indexData = nil,

		-- 访问数据的函数
        getValue = _getValue,
        getIntValue = _getIntValue,
		getStrValue = _getStrValue,
    }

    -- 设置LineData的元方法，主要是为了方便DataLine通过  table["value"] 来进行访问
    setmetatable(LineData, self.mtDataLine)
    return LineData
end

-- 访问每一行
function LocalController:visitTable(xmlType, callback)
    if callback == nil then
        return
    end

    local tbl = self:getTable(xmlType)
	if tbl == nil then
		Logger.LogError("visitTable but table not found - ", tostring(xmlType))
		return
	end
    -- DumpTable(tbl)

    -- 创建一个行访问器
    local LineData = self:createLineData(xmlType, -1)
    LineData._indexData = tbl["index"]

    local t = tbl["data"]
    --print("visitTable : " .. tostring(LineData))

    for k, v in pairs(t) do

        LineData._xmlId = k
        LineData._lineData = v
        
        -- DumpTable(LineData)
        local stop = callback(k, LineData)
        if stop then 
            break
        end 
    end
end
--获取表的长度
function LocalController:GetTableLength(xmlType)
    local length = 0
    local tbl = self:getTable(xmlType)
    if tbl~=nil then
        local t = tbl["data"]
        if t~=nil then
            length = table.count(t)
        end
    end
    return length
end

-- 获取cache类数据
-- 一个列的数据会需要缓存两种类型吗？我感觉没必要
function LocalController:get_cached_table(xmlType, xmlId)

	local t1 = self.cached_data[xmlType]
	if t1 then
		local t2 = t1[xmlId]
		if t2 then
			return t2
		else
			t1[xmlId] = {}
		end
	else
		self.cached_data[xmlType] = {}
	end
			
	return self:get_cached_table(xmlType, xmlId)
end

function LocalController:get_array_s_data(xmlType, xmlId, xmlAttr, sep)
	sep = sep or "|"
	
	local t = self:get_cached_table(xmlType, xmlId)
	local v = t[xmlAttr]
	if v then
		return v
	end
	
	local array_s_data
	local value = self:getValue(xmlType, xmlId, xmlAttr)
	if value == "" then
		array_s_data = self.et
	else
	 	array_s_data = string.string2array_s(value, sep)
	end
	
	t[xmlAttr] = array_s_data
	return array_s_data
	
end

function LocalController:get_array_i_data(xmlType, xmlId, xmlAttr, sep)
	sep = sep or "|"

	local t = self:get_cached_table(xmlType, xmlId)
	local v = t[xmlAttr]
	if v then
		return v
	end

	local array_s_data
	local value = self:getValue(xmlType, xmlId, xmlAttr)
	if value == "" then
		array_s_data = self.et
	else
		array_s_data = string.string2array_i(value, sep)
	end

	t[xmlAttr] = array_s_data
	return array_s_data

end

function LocalController:get_array_f_data(xmlType, xmlId, xmlAttr, sep)
	sep = sep or "|"

	local t = self:get_cached_table(xmlType, xmlId)
	local v = t[xmlAttr]
	if v then
		return v
	end

	local array_s_data
	local value = self:getValue(xmlType, xmlId, xmlAttr)
	if value == "" then
		array_s_data = self.et
	else
		array_s_data = string.string2array_f(value, sep)
	end

	t[xmlAttr] = array_s_data
	return array_s_data

end

-- 获取游戏中的表格信息，尽量用这个全局函数来获取
-- type: 表格类型，或者名字
-- itemId: 行的id
-- name: 要获取的列
function GetTableData(_type, itemId, name, defaultValue)
	return LocalController:instance():getValue(_type, itemId, name, defaultValue)
end

-- 获取指定数据行
function GetTableDataLine(_type, itemId)
	return LocalController:instance():getLine(_type, itemId)
end

-- 获取指定数据行
function GetTableDataLine(_type, itemId)
	return LocalController:instance():getLine(_type, itemId)	
end

-- 获取指定数据行
function GetTableDataLine(_type, itemId)
	return LocalController:instance():getLine(_type, itemId)	
end

-- 这个接口其实返回的是一个number
function GetTableNumber(_type, itemId, name)
	return LocalController:instance():getIntValue(_type, itemId, name)
end

-- 这个接口其实返回的是一个number
function GetTableString(_type, itemId, name)
	return LocalController:instance():getStrValue(_type, itemId, name)
end




-- 下面是cached获取数据的接口
function GetTable_array_s(_type, itemId, name, sep)
	return LocalController:instance():get_array_s_data(_type, itemId, name, sep)
end

function GetTable_array_i(_type, itemId, name, sep)
	return LocalController:instance():get_array_i_data(_type, itemId, name, sep)
end

function GetTable_array_f(_type, itemId, name, sep)
	return LocalController:instance():get_array_f_data(_type, itemId, name, sep)
end

return LocalController
