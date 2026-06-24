
local pack = string.pack
local unpack = string.unpack
local tconcat = table.concat
local ipairs = ipairs
local SFSDataType = require "Common.Data.SFSDataType"
local SFSObject
local SFSArray
local SFSDataSerializer = {}

local EncodeObject
local DecodeObject
local Object2Binary
local Binary2Object
local Array2Binary
local Binary2Array

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--- 二进制读写
local function WriteByte(buffer, val)
    buffer[#buffer + 1] = pack("B", val)
end

local function WriteBool(buffer, val)
    WriteByte(buffer, val and 1 or 0)
end

local function WriteInt16(buffer, val)
    buffer[#buffer + 1] = pack(">i2", val)
end

local function WriteUInt16(buffer, val)
    buffer[#buffer + 1] = pack(">I2", val)
end

local function WriteInt32(buffer, val)
    buffer[#buffer + 1] = pack(">i4", val)
end

local function WriteInt64(buffer, val)
    buffer[#buffer + 1] = pack(">i8", val)
end

local function WriteFloat(buffer, val)
    buffer[#buffer + 1] = pack(">f", val)
end

local function WriteDouble(buffer, val)
    buffer[#buffer + 1] = pack(">d", val)
end

local function WriteUTF(buffer, val)
    local len = #val
    if len > 32767 then
        error("String length cannot be greater than 32767 bytes!")
    end
    WriteUInt16(buffer, len)
    buffer[#buffer + 1] = pack("c" .. len, val)
end

local function WriteText(buffer, val)
    local len = #val
    WriteInt32(buffer, len)
    buffer[#buffer + 1] = pack("c" .. len, val)
end

local function ReadByte(s, i)
    return unpack("B", s, i)
end

local function ReadBool(s, i)
    local byte
    byte, i = ReadByte(s, i)
    return byte ~= 0 and true or false, i
end

local function ReadInt16(s, i)
    return unpack(">i2", s, i)
end

local function ReadUShort(s, i)
    return unpack(">I2", s, i)
end

local function ReadInt32(s, i)
    return unpack(">i4", s, i)
end

local function ReadInt64(s, i)
    return unpack(">i8", s, i)
end

local function ReadFloat(s, i)
    return unpack(">f", s, i)
end

local function ReadDouble(s, i)
    return unpack(">d", s, i)
end

local function ReadUTF(s, i)
    local len
    len, i = ReadUShort(s, i)
    return unpack("c" .. len, s, i)
end

local function ReadText(s, i)
    local len
    len, i = ReadInt32(s, i)
    return unpack("c" .. len, s, i)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--- 编码
local function BinEncode_NULL(buffer)
    WriteByte(buffer, SFSDataType.NULL)
end

local function BinEncode_BOOL(buffer, val)
    WriteByte(buffer, SFSDataType.BOOL)
    WriteBool(buffer, val)
end

local function BinEncode_BYTE(buffer, val)
    WriteByte(buffer, SFSDataType.BYTE)
    WriteByte(buffer, val)
end

local function BinEncode_SHORT(buffer, val)
    WriteByte(buffer, SFSDataType.SHORT)
    WriteInt16(buffer, val)
end

local function BinEncode_INT(buffer, val)
    WriteByte(buffer, SFSDataType.INT)
    WriteInt32(buffer, val)
end

local function BinEncode_LONG(buffer, val)
    WriteByte(buffer, SFSDataType.LONG)
    WriteInt64(buffer, val)
end

local function BinEncode_FLOAT(buffer, val)
    WriteByte(buffer, SFSDataType.FLOAT)
    WriteFloat(buffer, val)
end

local function BinEncode_DOUBLE(buffer, val)
    WriteByte(buffer, SFSDataType.DOUBLE)
    WriteDouble(buffer, val)
end

local function BinEncode_UTF_STRING(buffer, val)
    WriteByte(buffer, SFSDataType.UTF_STRING)
    WriteUTF(buffer, val)
end

local function BinEncode_BOOL_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.BOOL_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteBool(buffer, val[i])
    end
end

local function BinEncode_BYTE_ARRAY(buffer ,val)
    WriteByte(buffer, SFSDataType.BYTE_ARRAY)
    
    local len = #val
    WriteInt32(buffer, len)

    for i = 1, len do
        WriteByte(buffer, val[i])
    end
end

local function BinEncode_SHORT_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.SHORT_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteInt16(buffer, val[i])
    end
end

local function BinEncode_INT_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.INT_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteInt32(buffer, val[i])
    end
end

local function BinEncode_LONG_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.LONG_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteInt64(buffer, val[i])
    end
end

local function BinEncode_FLOAT_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.FLOAT_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteFloat(bufer, val[i])
    end
end

local function BinEncode_DOUBLE_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.DOUBLE_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteDouble(buffer, val[i])
    end
end

local function BinEncode_UTF_STRING_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.UTF_STRING_ARRAY)
    
    local len = #val
    WriteInt16(buffer, len)

    for i = 1, len do
        WriteUTF(buffer, val[i])
    end
end

local function BinEncode_SFS_ARRAY(buffer, val)
    WriteByte(buffer, SFSDataType.SFS_ARRAY)
    
    local size = val:Size()
    WriteInt16(buffer, val:Size())
    
    for i = 1, size do
        local data = val:GetWrappedElementAt(i)
        EncodeObject[data.Type](buffer, data.Data)
    end
end

local function BinEncode_SFS_OBJECT(buffer ,val)
    WriteByte(buffer, SFSDataType.SFS_OBJECT)
    
    local keys = val:GetKeys()
    WriteInt16(buffer, #keys)
    for i, key in ipairs(keys) do
        -- encode key
        WriteUTF(buffer, key)
        -- encode object
        local data = val:GetData(key)
        EncodeObject[data.Type](buffer, data.Data)
    end
end

local function BinEncode_CLASS(buffer, val)
    error("not implement")
end

local function BinEncode_TEXT(buffer, val)
    WriteByte(buffer, SFSDataType.TEXT)
    WriteText(buffer, val)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--- 解码
local function BinDecode_NULL(s, i)
    return { Type = SFSDataType.NULL }, i
end

local function BinDecode_BOOL(s, i)
    local data
    data, i = ReadBool(s, i)
    return { Type = SFSDataType.BOOL, Data = data }, i
end

local function BinDecode_BYTE(s, i)
    local data
    data, i = ReadByte(s, i)
    return { Type = SFSDataType.BYTE, Data = data }, i
end

local function BinDecode_SHORT(s, i)
    local data
    data, i = ReadInt16(s, i)
    return { Type = SFSDataType.SHORT, Data = data }, i
end

local function BinDecode_INT(s, i)
    local data
    data, i = ReadInt32(s, i)
    return { Type = SFSDataType.INT, Data = data }, i
end

local function BinDecode_LONG(s, i)
    local data
    data, i = ReadInt64(s, i)
    return { Type = SFSDataType.LONG, Data = data }, i
end

local function BinDecode_FLOAT(s, i)
    local data
    data, i = ReadFloat(s, i)
    return { Type = SFSDataType.FLOAT, Data = data }, i
end

local function BinDecode_DOUBLE(s, i)
    local data
    data, i = ReadDouble(s, i)
    return { Type = SFSDataType.DOUBLE, Data = data }, i
end

local function BinDecode_UTF_STRING(s, i)
    local data
    data, i = ReadUTF(s, i)
    return { Type = SFSDataType.UTF_STRING, Data = data }, i
end

local function BinDecode_BOOL_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadBool(s, i)
    end
    return { Type = SFSDataType.BOOL_ARRAY, Data = data }, i
end

local function BinDecode_BYTE_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt32(s, i)
    for k = 1, len do
        data[k], i = ReadByte(s, i)
    end
    return { Type = SFSDataType.BYTE_ARRAY, Data = data }, i
end

local function BinDecode_SHORT_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadInt16(s, i)
    end
    return { Type = SFSDataType.SHORT_ARRAY, Data = data }, i
end

local function BinDecode_INT_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadInt32(s, i)
    end
    return { Type = SFSDataType.INT_ARRAY, Data = data }, i
end

local function BinDecode_LONG_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadInt64(s, i)
    end
    return { Type = SFSDataType.LONG_ARRAY, Data = data }, i
end

local function BinDecode_FLOAT_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadFloat(s, i)
    end
    return { Type = SFSDataType.FLOAT_ARRAY, Data = data }, i
end

local function BinDecode_DOUBLE_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadDouble(s, i)
    end
    return { Type = SFSDataType.DOUBLE_ARRAY, Data = data }, i
end

local function BinDecode_UTF_STRING_ARRAY(s, i)
    local data = {}, len
    len, i = ReadInt16(s, i)
    for k = 1, len do
        data[k], i = ReadUTF(s, i)
    end
    return { Type = SFSDataType.UTF_STRING_ARRAY, Data = data }, i
end

local function BinDecode_SFS_ARRAY(s, i)
    local len
    len, i = ReadInt16(s, i)
    if len < 0 then
        error("Can't decode SFSArray. Size is negative: " .. len)
    end
    
    SFSArray = SFSArray or require "Common.Data.SFSArray"
    local sfsArray = SFSArray.New()
    for j = 1, len do
        local type, data
        type, i = ReadByte(s, i)
        data, i = DecodeObject[type](s, i)
        sfsArray:Add(data)
    end
    
    return { Type = SFSDataType.SFS_ARRAY, Data = sfsArray }, i
end

local function BinDecode_SFS_OBJECT(s, i)
    local len
    len, i = ReadInt16(s, i)
    if len < 0 then
        error("Can't decode SFSObject. Size is negative: " .. len)
    end
    
    SFSObject = SFSObject or require "Common.Data.SFSObject"
    local sfsObject = SFSObject.New()
    for j = 1, len do
        local key, type, data
        key, i = ReadUTF(s, i)
        type, i = ReadByte(s, i)
        data, i = DecodeObject[type](s, i)
        sfsObject:Put(key, data)
    end
    
    return { Type = SFSDataType.SFS_OBJECT, Data = sfsObject }, i
end

local function BinDecode_CLASS(s, i)
    error("not implement")
end

local function BinDecode_TEXT(s, i)
    local data
    data, i = ReadText(s, i)
    return { Type = SFSDataType.TEXT, Data = data }, i
end

EncodeObject = 
{
    [SFSDataType.NULL] = BinEncode_NULL,
    [SFSDataType.BOOL] = BinEncode_BOOL,
    [SFSDataType.BYTE] = BinEncode_BYTE,
    [SFSDataType.SHORT] = BinEncode_SHORT,
    [SFSDataType.INT] = BinEncode_INT,
    [SFSDataType.LONG] = BinEncode_LONG,
    [SFSDataType.FLOAT] = BinEncode_FLOAT,
    [SFSDataType.DOUBLE] = BinEncode_DOUBLE,
    [SFSDataType.UTF_STRING] = BinEncode_UTF_STRING,
    [SFSDataType.BOOL_ARRAY] = BinEncode_BOOL_ARRAY,
    [SFSDataType.BYTE_ARRAY] = BinEncode_BYTE_ARRAY,
    [SFSDataType.SHORT_ARRAY] = BinEncode_SHORT_ARRAY,
    [SFSDataType.INT_ARRAY] = BinEncode_INT_ARRAY,
    [SFSDataType.LONG_ARRAY] = BinEncode_LONG_ARRAY,
    [SFSDataType.FLOAT_ARRAY] = BinEncode_FLOAT_ARRAY,
    [SFSDataType.DOUBLE_ARRAY] = BinEncode_DOUBLE_ARRAY,
    [SFSDataType.UTF_STRING_ARRAY] = BinEncode_UTF_STRING_ARRAY,
    [SFSDataType.SFS_ARRAY] = BinEncode_SFS_ARRAY,
    [SFSDataType.SFS_OBJECT] = BinEncode_SFS_OBJECT,
    [SFSDataType.CLASS] = BinEncode_CLASS,
    [SFSDataType.TEXT] = BinEncode_TEXT,
}

DecodeObject = 
{
    [SFSDataType.NULL] = BinDecode_NULL,
    [SFSDataType.BOOL] = BinDecode_BOOL,
    [SFSDataType.BYTE] = BinDecode_BYTE,
    [SFSDataType.SHORT] = BinDecode_SHORT,
    [SFSDataType.INT] = BinDecode_INT,
    [SFSDataType.LONG] = BinDecode_LONG,
    [SFSDataType.FLOAT] = BinDecode_FLOAT,
    [SFSDataType.DOUBLE] = BinDecode_DOUBLE,
    [SFSDataType.UTF_STRING] = BinDecode_UTF_STRING,
    [SFSDataType.BOOL_ARRAY] = BinDecode_BOOL_ARRAY,
    [SFSDataType.BYTE_ARRAY] = BinDecode_BYTE_ARRAY,
    [SFSDataType.SHORT_ARRAY] = BinDecode_SHORT_ARRAY,
    [SFSDataType.INT_ARRAY] = BinDecode_INT_ARRAY,
    [SFSDataType.LONG_ARRAY] = BinDecode_LONG_ARRAY,
    [SFSDataType.FLOAT_ARRAY] = BinDecode_FLOAT_ARRAY,
    [SFSDataType.DOUBLE_ARRAY] = BinDecode_DOUBLE_ARRAY,
    [SFSDataType.UTF_STRING_ARRAY] = BinDecode_UTF_STRING_ARRAY,
    [SFSDataType.SFS_ARRAY] = BinDecode_SFS_ARRAY,
    [SFSDataType.SFS_OBJECT] = BinDecode_SFS_OBJECT,
    [SFSDataType.CLASS] = BinDecode_CLASS,
    [SFSDataType.TEXT] = BinDecode_TEXT,
}


Object2Binary = function(sfsObject)
    local buffer = {}
    BinEncode_SFS_OBJECT(buffer, sfsObject)
    return tconcat(buffer)
end

Binary2Object = function(bytes)
    local len = #bytes
    if len < 3 then
        error("Can't decode an SFSObject. Byte data is insufficient. Size: " .. len .. " byte(s)")
    end
    
    local type, i = ReadByte(bytes, 1)
    if type ~= SFSDataType.SFS_OBJECT then
        error("Invalid SFSDataType. Expected: " .. SFSDataType.SFS_OBJECT .. ", found: " .. type)
    end
    
    return BinDecode_SFS_OBJECT(bytes, i).Data
end

Array2Binary = function(sfsArray)
    local buffer = {}
    BinEncode_SFS_ARRAY(buffer, sfsArray)
    return tconcat(buffer)
end

Binary2Array = function(bytes)
    local len = #bytes
    if len < 3 then
        error("Can't decode an SFSArray. Byte data is insufficient. Size: " .. len .. " byte(s)")
    end

    local type, i = ReadByte(bytes, 1)
    if type ~= SFSDataType.SFS_ARRAY then
        error("Invalid SFSDataType. Expected: " .. SFSDataType.SFS_ARRAY .. ", found: " .. type)
    end
    
    return BinDecode_SFS_ARRAY(bytes, i).Data
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--- 导出函数
SFSDataSerializer.Object2Binary = Object2Binary
SFSDataSerializer.Binary2Object = Binary2Object
SFSDataSerializer.Array2Binary = Array2Binary
SFSDataSerializer.Binary2Array = Binary2Array

return SFSDataSerializer