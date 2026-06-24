local setmetatable = setmetatable
local SFSDataType = require "Common.Data.SFSDataType"
local Serializer = require "Common.Data.SFSDataSerializer"
local tremove = table.remove
local DataTypeNames = SFSDataType.Names

local SFSArray = {}
SFSArray.__index = SFSArray

function SFSArray.New()
    local o = {
        dataHolder = {},
    }
    return setmetatable(o, SFSArray)
end

function SFSArray.NewFromBinary(bytes)
    return Serializer.Binary2Array(bytes)
end

function SFSArray:GetElementAt(index)
    return self.dataHolder[index].Data
end

function SFSArray:RemoveElementAt(index)
    tremove(self.dataHolder, index)
end

function SFSArray:GetWrappedElementAt(index)
    return self.dataHolder[index]
end

function SFSArray:ToBinary()
    return Serializer.Array2Binary(self)
end

function SFSArray:ToJson()
    error("not implement")
end

function SFSArray:ToLuaTable()
	local t = {}
	for k,v in pairs(self.dataHolder) do
		if v.Type == SFSDataType.SFS_OBJECT or
			v.Type == SFSDataType.BOOL_ARRAY or
			v.Type == SFSDataType.BYTE_ARRAY or
			v.Type == SFSDataType.SHORT_ARRAY or
			v.Type == SFSDataType.INT_ARRAY or
			v.Type == SFSDataType.LONG_ARRAY or
			v.Type == SFSDataType.FLOAT_ARRAY or
			v.Type == SFSDataType.DOUBLE_ARRAY or
			v.Type == SFSDataType.UTF_STRING_ARRAY or
			v.Type == SFSDataType.SFS_ARRAY or
			v.Type == SFSDataType.SFS_OBJECT
			then

            if v.Data.ToLuaTable then
                t[k] = v.Data:ToLuaTable()
            else
                t[k] = v.Data
            end
		else
			t[k] = v.Data
		end
	end

	return t
end

function SFSArray:Size()
    return #self.dataHolder
end

function SFSArray:AddNull()
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.NULL }
end

function SFSArray:AddBool(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.BOOL, Data = val }
end

function SFSArray:AddByte(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.BYTE, Data = val }
end

function SFSArray:AddShort(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.SHORT, Data = val }
end

function SFSArray:AddInt(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.INT, Data = val }
end

function SFSArray:AddLong(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.LONG, Data = val }
end

function SFSArray:AddFloat(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.FLOAT, Data = val }
end

function SFSArray:AddDouble(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.DOUBLE, Data = val }
end

function SFSArray:AddUtfString(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.UTF_STRING, Data = val }
end

function SFSArray:AddText(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.TEXT, Data = val }
end

function SFSArray:AddBoolArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.BOOL_ARRAY, Data = val }
end

function SFSArray:AddByteArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.BYTE_ARRAY, Data = val }
end

function SFSArray:AddShortArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.SHORT_ARRAY, Data = val }
end

function SFSArray:AddIntArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.INT_ARRAY, Data = val }
end

function SFSArray:AddLongArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.LONG_ARRAY, Data = val }
end

function SFSArray:AddFloatArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.FLOAT_ARRAY, Data = val }
end

function SFSArray:AddDoubleArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.DOUBLE_ARRAY, Data = val }
end

function SFSArray:AddUtfStringArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.UTF_STRING_ARRAY, Data = val }
end

function SFSArray:AddSFSArray(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.SFS_ARRAY, Data = val }
end

function SFSArray:AddSFSObject(val)
    self.dataHolder[#self.dataHolder + 1] = { Type = SFSDataType.SFS_OBJECT, Data = val }
end

function SFSArray:Add(dataWrapper)
    self.dataHolder[#self.dataHolder + 1] = dataWrapper
end

function SFSArray:IsNull(index)
    local data = self.dataHolder[index]
    if data == nil then
        error("data not exist at index " .. index)
    end
    return data.Type == SFSDataType.NULL
end

local function GetValue(self, index, type)
    local data = self.dataHolder[index]
    if data == nil then
        error("data not exist at index " .. index)
    end

    if data.Type ~= type then
        error(string.format("value type error, expect: %s, got: %s", DataTypeNames[data.Type], DataTypeNames[type]))
    end
    
    return data.Data
end

function SFSArray:GetBool(index)
    return GetValue(self, index, SFSDataType.BOOL)
end

function SFSArray:GetByte(index)
    return GetValue(self, index, SFSDataType.BYTE)
end

function SFSArray:GetShort(index)
    return GetValue(self, index, SFSDataType.SHORT)
end

function SFSArray:GetInt(index)
    return GetValue(self, index, SFSDataType.INT)
end

function SFSArray:GetLong(index)
    return GetValue(self, index, SFSDataType.LONG)
end

function SFSArray:GetFloat(index)
    return GetValue(self, index, SFSDataType.FLOAT)
end

function SFSArray:GetDouble(index)
    return GetValue(self, index, SFSDataType.DOUBLE)
end

function SFSArray:GetUtfString(index)
    return GetValue(self, index, SFSDataType.UTF_STRING)
end

function SFSArray:GetText(index)
    return GetValue(self, index, SFSDataType.TEXT)
end

function SFSArray:GetBoolArray(index)
    return GetValue(self, index, SFSDataType.BOOL_ARRAY)
end

function SFSArray:GetByteArray(index)
    return GetValue(self, index, SFSDataType.BYTE_ARRAY)
end

function SFSArray:GetShortArray(index)
    return GetValue(self, index, SFSDataType.SHORT_ARRAY)
end

function SFSArray:GetIntArray(index)
    return GetValue(self, index, SFSDataType.INT_ARRAY)
end

function SFSArray:GetLongArray(index)
    return GetValue(self, index, SFSDataType.LONG_ARRAY)
end

function SFSArray:GetFloatArray(index)
    return GetValue(self, index, SFSDataType.FLOAT_ARRAY)
end

function SFSArray:GetDoubleArray(index)
    return GetValue(self, index, SFSDataType.DOUBLE_ARRAY)
end

function SFSArray:GetUtfStringArray(index)
    return GetValue(self, index, SFSDataType.UTF_STRING_ARRAY)
end

function SFSArray:GetSFSArray(index)
    return GetValue(self, index, SFSDataType.SFS_ARRAY)
end

function SFSArray:GetSFSObject(index)
    return GetValue(self, index, SFSDataType.SFS_OBJECT)
end

return SFSArray