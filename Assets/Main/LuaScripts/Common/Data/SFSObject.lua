local setmetatable = setmetatable
local tkeys = table.keys
local SFSDataType = require "Common.Data.SFSDataType"
local Serializer = require "Common.Data.SFSDataSerializer"
local DataTypeNames = SFSDataType.Names

---@class SFSObject
local SFSObject = {}
SFSObject.__index = SFSObject

function SFSObject.New()
    local o = {
        dataHolder = {},
    }
    return setmetatable(o, SFSObject)
end

function SFSObject.NewFromBinary(bytes)
    return Serializer.Binary2Object(bytes)
end

function SFSObject:ContainsKey(key)
    return self.dataHolder[key] ~= nil
end

function SFSObject:RemoveElement(key)
    self.dataHolder[key] = nil
end

function SFSObject:GetKeys()
    return tkeys(self.dataHolder)
end

function SFSObject:ToBinary()
    return Serializer.Object2Binary(self)
end

function SFSObject:ToJson()
    error("not implement")
end

local function ArrayToLuaTable(v)
	local t = {}
	for k1,v1 in pairs(v.Data) do
		if v.Type == SFSDataType.SFS_OBJECT or
		v.Type == SFSDataType.SFS_ARRAY then
			t[k1] = v.Data:ToLuaTable()
		else
			t[k1] = v1
		end
	end
	return t
end

function SFSObject:ToLuaTable()
	local t = {}
	for k,v in pairs(self.dataHolder) do
		if v.Type == SFSDataType.SFS_OBJECT or 
			v.Type == SFSDataType.SFS_ARRAY then
			
			t[k] = v.Data:ToLuaTable()
		elseif v.Type == SFSDataType.BOOL_ARRAY or
			v.Type == SFSDataType.BYTE_ARRAY or
			v.Type == SFSDataType.SHORT_ARRAY or
			v.Type == SFSDataType.INT_ARRAY or
			v.Type == SFSDataType.LONG_ARRAY or
			v.Type == SFSDataType.FLOAT_ARRAY or
			v.Type == SFSDataType.DOUBLE_ARRAY or
			v.Type == SFSDataType.UTF_STRING_ARRAY then
			
			t[k] = ArrayToLuaTable(v)
		else
			
			t[k] = v.Data
		end
	end
	
	return t
end

local function GetValue(self, key, type)
    local data = self.dataHolder[key]
    if data == nil then
        error("key not exist: " .. key)
    end
    if data.Type ~= type then
        error(string.format("value type error, expect: %s, got: %s", DataTypeNames[data.Type], DataTypeNames[type]))
    end
    return data.Data
end

function SFSObject:GetData(key)
    return self.dataHolder[key]
end

function SFSObject:IsNull(key)
    local data = self.dataHolder[key]
    if data == nil then
      return true
    end
    return data.Type == SFSDataType.NULL or data.Data == nil
end

function SFSObject:GetBool(key)
    return GetValue(self, key, SFSDataType.BOOL)
end

function SFSObject:GetByte(key)
    return GetValue(self, key, SFSDataType.BYTE)
end

function SFSObject:GetShort(key)
    return GetValue(self, key, SFSDataType.SHORT)
end

function SFSObject:GetInt(key)
    return GetValue(self, key, SFSDataType.INT)
end

function SFSObject:GetLong(key)
    return GetValue(self, key, SFSDataType.LONG)
end

function SFSObject:GetFloat(key)
    return GetValue(self, key, SFSDataType.FLOAT)
end

function SFSObject:GetDouble(key)
    return GetValue(self, key, SFSDataType.DOUBLE)
end

function SFSObject:GetUtfString(key)
    return GetValue(self, key, SFSDataType.UTF_STRING)
end

function SFSObject:GetText(key)
    return GetValue(self, key, SFSDataType.TEXT)
end

function SFSObject:GetBoolArray(key)
    return GetValue(self, key, SFSDataType.BOOL_ARRAY)
end

function SFSObject:GetByteArray(key)
    return GetValue(self, key, SFSDataType.BYTE_ARRAY)
end

function SFSObject:GetShortArray(key)
    return GetValue(self, key, SFSDataType.SHORT_ARRAY)
end

function SFSObject:GetIntArray(key)
    return GetValue(self, key, SFSDataType.INT_ARRAY)
end

function SFSObject:GetLongArray(key)
    return GetValue(self, key, SFSDataType.LONG_ARRAY)
end

function SFSObject:GetFloatArray(key)
    return GetValue(self, key, SFSDataType.FLOAT_ARRAY)
end

function SFSObject:GetDoubleArray(key)
    return GetValue(self, key, SFSDataType.DOUBLE_ARRAY)
end

function SFSObject:GetUtfStringArray(key)
    return GetValue(self, key, SFSDataType.UTF_STRING_ARRAY)
end

function SFSObject:GetSFSArray(key)
    return GetValue(self, key, SFSDataType.SFS_ARRAY)
end

function SFSObject:GetSFSObject(key)
    return GetValue(self, key, SFSDataType.SFS_OBJECT)
end

function SFSObject:PutNull(key)
    self.dataHolder[key] = { Type = SFSDataType.NULL }
end

function SFSObject:PutBool(key, val)
    self.dataHolder[key] = { Type = SFSDataType.BOOL, Data = val }
end

function SFSObject:PutByte(key, val)
    self.dataHolder[key] = { Type = SFSDataType.BYTE, Data = val }
end

function SFSObject:PutShort(key, val)
    self.dataHolder[key] = { Type = SFSDataType.SHORT, Data = val }
end

function SFSObject:PutInt(key, val)
    val = math.tointeger(val)
    if val == nil then
        Logger.LogError('SFSObject:PutInt val is nil!')
    end
    self.dataHolder[key] = { Type = SFSDataType.INT, Data =  val }
end

function SFSObject:PutLong(key, val)
    val = math.tointeger(val)
    if val == nil then
        Logger.LogError('SFSObject:PutLong val is nil!')
    end
    self.dataHolder[key] = { Type = SFSDataType.LONG, Data = val }
end

function SFSObject:PutFloat(key, val)
    val = tonumber(val)
    if val == nil then
        Logger.LogError('SFSObject:PutFloat val is nil!')
    end
    self.dataHolder[key] = { Type = SFSDataType.FLOAT, Data = val }
end

function SFSObject:PutDouble(key, val)
    val = tonumber(val)
    if val == nil then
        Logger.LogError('SFSObject:PutDouble val is nil!')
    end
    self.dataHolder[key] = { Type = SFSDataType.DOUBLE, Data = val }
end

function SFSObject:PutUtfString(key, val)
    val = tostring(val)
    self.dataHolder[key] = { Type = SFSDataType.UTF_STRING, Data = val }
end

function SFSObject:PutText(key, val)
    val = tostring(val)
    self.dataHolder[key] = { Type = SFSDataType.TEXT, Data = val }
end

function SFSObject:PutBoolArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.BOOL_ARRAY, Data = val }
end

function SFSObject:PutByteArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.BYTE_ARRAY, Data = val }
end

function SFSObject:PutShortArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.SHORT_ARRAY, Data = val }
end

function SFSObject:PutIntArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.INT_ARRAY, Data = val }
end

function SFSObject:PutLongArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.LONG_ARRAY, Data = val }
end

function SFSObject:PutFloatArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.FLOAT_ARRAY, Data = val }
end

function SFSObject:PutDoubleArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.DOUBLE_ARRAY, Data = val }
end

function SFSObject:PutUtfStringArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.UTF_STRING_ARRAY, Data = val }
end

function SFSObject:PutSFSArray(key, val)
    self.dataHolder[key] = { Type = SFSDataType.SFS_ARRAY, Data = val }
end

function SFSObject:PutSFSObject(key, val)
    self.dataHolder[key] = { Type = SFSDataType.SFS_OBJECT, Data = val }
end

function SFSObject:Put(key, dataWrapper)
    self.dataHolder[key] = dataWrapper
end

function SFSObject:PutLuaArray(key, val)
	if table.IsNullOrEmpty(val) then
		return 
	end
	
	local t = type(val[1])
	local isFloat = isFloat(val[1])
	
	local array = SFSArray.New()
	table.walk(val, 
		function (k,v)
			if t == "string" then
				array:AddUtfString(v)
			elseif t == "number" then
				if isFloat == true then
					array:AddFloat(v)
				else 
					array:AddLong(v)
				end
			end	
		end)
	
	self:PutSFSArray(key, array)
	return
end

function SFSObject:PutLuaTable(key, val)
	
	local tblObj = self
	if key ~= nil then
		tblObj = SFSObject.New()
	end
		
	for k, v in pairs(val) do
		local t = type(v)
		if t == "string" then
			tblObj:PutUtfString(k, v)
		elseif t == "number" then
			if math.type(v) == "float" then
				tblObj:PutDouble(k, v)
			else
				tblObj:PutLong(k, v)
			end
		elseif t == "table" then
			if table.isarray(t) then
				tblObj:PutLuaArray(k, v)
			else
				tblObj:PutLuaTable(k, v)
			end
		end
	end
	
	if tblObj ~= nil and tblObj ~= self then
		self:PutSFSObject(key, tblObj)
	end
	
	return
end


return SFSObject
