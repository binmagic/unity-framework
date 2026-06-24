using System;
using System.Collections.Generic;
using System.Reflection;
using Sfs2X.Entities.Data;
using Sfs2X.Util;
using UnityEngine;
using XLua;
using LuaAPI = XLua.LuaDLL.Lua;

public static class SFSObjectExtention
{
    
    private static FieldInfo _fiDataHolder;
    /// <summary>
    /// 通过反射获取dataHolder
    /// </summary>
    /// <param name="sfsData"></param>
    /// <returns></returns>
    // private static Dictionary<string, SFSDataWrapper> GetDataHolder(this SFSObject sfsData)
    // {
    //     if (_fiDataHolder == null)
    //     {
    //         _fiDataHolder = typeof(SFSObject).GetField("dataHolder", BindingFlags.NonPublic | BindingFlags.Instance);
    //         if (_fiDataHolder == null)
    //         {
    //             Debug.LogError("GetDataHolder Error FieldInfo is null!");
    //             return null;
    //         }
    //     }
    //     
    //     var dataHolder = (Dictionary<string, SFSDataWrapper>)_fiDataHolder.GetValue(sfsData);
    //     return dataHolder;
    // }

    
    
    //*////////////////////////////////////////////////////////////////////////////////////
#if !NETCMD_USE_LUATABLE
    public static LuaStackTable ToLuaTable(this bool[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (bool b in array)
        {
            fastTable.SetBool(++index, b);
        }

        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this short[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (short b in array)
        {
            fastTable.SetShort(++index, b);
        }

        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this int[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (int b in array)
        {
            fastTable.SetInt(++index, b);
        }
        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this long[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (long b in array)
        {
            fastTable.SetLong(++index, b);
        }
        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this float[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (float b in array)
        {
            fastTable.SetFloat(++index, b);
        }
        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this double[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L,array.Length, 0);
        int index = 0;
        foreach (double b in array)
        {
            fastTable.SetDouble(++index, b);
        }
        return fastTable;
    }
    public static LuaStackTable ToLuaTable(this string[] array, LuaEnv env)
    {
        LuaStackTable fastTable = new LuaStackTable(env.L, array.Length, 0);
        int index = 0;
        foreach (string b in array)
        {
            fastTable.SetString(++index, b);
        }
        return fastTable;
    }

    public static LuaStackTable ToLuaTable(this SFSObject sfsData, LuaEnv env)
    {
        LuaStackTable t = new LuaStackTable(env.L, 0, sfsData.Size() + 4);
        var L = GameEntry.Lua.Env.L;
        
        //var d = GetDataHolder(sfsData);
        var d = sfsData.dataHolder;
        foreach (var v in d)
        {
            SFSDataType _st = (SFSDataType) v.Value.Type;
            string key = v.Key;
            switch (_st)
            {
                case SFSDataType.BOOL:
                    t.SetBool(key, (bool)v.Value.Data);
                    break;
                case SFSDataType.BYTE:
                    t.SetByte(key, sfsData.GetByte(key));
                    break;
                case SFSDataType.SHORT:
                    t.SetShort(key, sfsData.GetShort(key));
                    break;
                case SFSDataType.INT:
                    t.SetInt(key, (int)v.Value.Data);
                    break;
                case SFSDataType.LONG:
                    t.SetLong(key, (long)v.Value.Data);
                    break;
                case SFSDataType.FLOAT:
                    t.SetFloat(key, (float)v.Value.Data);
                    break;
                case SFSDataType.DOUBLE:
                    t.SetDouble(key, (double)v.Value.Data);
                    break;
                case SFSDataType.UTF_STRING:
                    t.SetString(key, (string)v.Value.Data);
                    break;
                case SFSDataType.BOOL_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetBoolArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.BYTE_ARRAY:
                    t.SetBytes(key, sfsData.GetByteArray(key).GetRawBytes());
                    break;
                case SFSDataType.SHORT_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetShortArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.INT_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetIntArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.LONG_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetLongArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.FLOAT_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetFloatArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.DOUBLE_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetDoubleArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.UTF_STRING_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, sfsData.GetUtfStringArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_ARRAY:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, ((SFSArray)sfsData.GetSFSArray(key)).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_OBJECT:
                    LuaAPI.lua_pushstring(L, key);
                    t.SetStackTable(key, ((SFSObject)sfsData.GetSFSObject(key)).ToLuaTable(env));
                    break;
                case SFSDataType.TEXT:
                    t.SetString(key, sfsData.GetText(key));
                    break;
                case SFSDataType.NULL:
                    t.SetString(key, null as string);
                    break;
                default:
                    Debug.LogWarningFormat("Unsupport type {0}", _st);
                    break;
            }
        }

        return t;
    }

    public static LuaStackTable ToLuaTable(this SFSArray array, LuaEnv env)
    {
        LuaStackTable t = new LuaStackTable(env.L, array.Size(), 0);
        int index = 0;
        var L = GameEntry.Lua.Env.L;
        
        for (int i = 0; i < array.Size(); ++i)
        {
            SFSDataType _st = (SFSDataType)array.GetWrappedElementAt(i).Type;
            // Debug.Log($">>>key 2 type: {_st}");
            switch (_st)
            {
                case SFSDataType.BOOL:
                    t.SetBool(++index, array.GetBool(i));
                    break;
                case SFSDataType.BYTE:
                    t.SetByte(++index, array.GetByte(i));
                    break;
                case SFSDataType.SHORT:
                    t.SetShort(++index, array.GetShort(i));
                    break;
                case SFSDataType.INT:
                    t.SetInt(++index, array.GetInt(i));
                    break;
                case SFSDataType.LONG:
                    t.SetLong(++index, array.GetLong(i));
                    break;
                case SFSDataType.FLOAT:
                    t.SetFloat(++index, array.GetFloat(i));
                    break;
                case SFSDataType.DOUBLE:
                    t.SetDouble(++index, array.GetDouble(i));
                    break;
                case SFSDataType.UTF_STRING:
                    t.SetString(++index, array.GetUtfString(i));
                    break;
                case SFSDataType.BOOL_ARRAY:
                    LuaAPI.xlua_pushinteger(GameEntry.Lua.Env.L, ++index);
                    t.SetStackTable(index, array.GetBoolArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.BYTE_ARRAY:
                    t.SetBytes(++index, array.GetByteArray(i).GetRawBytes());
                    break;
                case SFSDataType.SHORT_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetShortArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.INT_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetIntArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.LONG_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetLongArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.FLOAT_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetFloatArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.DOUBLE_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetDoubleArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.UTF_STRING_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, array.GetUtfStringArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_ARRAY:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, ((SFSArray)array.GetSFSArray(i)).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_OBJECT:
                    LuaAPI.xlua_pushinteger(L, ++index);
                    t.SetStackTable(index, ((SFSObject)array.GetSFSObject(i)).ToLuaTable(env));
                    break;
                case SFSDataType.TEXT:
                    t.SetString(++index, array.GetText(i));
                    break;
                default:
                    Debug.LogWarningFormat("Unsupport type {0}", _st);
                    break;
            }
        }

        return t;
    }
    // ================================================================================================
#else
    // ================================================================================================
    // ================================================================================================
    // ================================================================================================
    // 使用LuaTable

    public static LuaTable ToLuaTable(this SFSObject sfsData, LuaEnv env)
    {
        LuaTable t = env.NewTable();
        var d = GetDataHolder(sfsData);
        foreach (var v in d)
        {
            SFSDataType _st = (SFSDataType) v.Value.Type;
            string key = v.Key;
            switch (_st)
            {
                case SFSDataType.BOOL:
                    t.Set(key, (bool)v.Value.Data);
                    break;
                case SFSDataType.BYTE:
                    t.Set(key, sfsData.GetByte(key));
                    break;
                case SFSDataType.SHORT:
                    t.Set(key, sfsData.GetShort(key));
                    break;
                case SFSDataType.INT:
                    t.SetInt(key, (int)v.Value.Data);
                    break;
                case SFSDataType.LONG:
                    t.SetLong(key, (long)v.Value.Data);
                    break;
                case SFSDataType.FLOAT:
                    t.SetFloat(key, (float)v.Value.Data);
                    break;
                case SFSDataType.DOUBLE:
                    t.SetDouble(key, (double)v.Value.Data);
                    break;
                case SFSDataType.UTF_STRING:
                    t.SetString(key, (string)v.Value.Data);
                    break;
                case SFSDataType.BOOL_ARRAY:
                    t.SetTable(key, sfsData.GetBoolArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.BYTE_ARRAY:
                    t.Set(key, sfsData.GetByteArray(key).Bytes);
                    break;
                case SFSDataType.SHORT_ARRAY:
                    t.SetTable(key, sfsData.GetShortArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.INT_ARRAY:
                    t.SetTable(key, sfsData.GetIntArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.LONG_ARRAY:
                    t.SetTable(key, sfsData.GetLongArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.FLOAT_ARRAY:
                    t.SetTable(key, sfsData.GetFloatArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.DOUBLE_ARRAY:
                    t.SetTable(key, sfsData.GetDoubleArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.UTF_STRING_ARRAY:
                    t.SetTable(key, sfsData.GetUtfStringArray(key).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_ARRAY:
                    t.SetTable(key, ((SFSArray)sfsData.GetSFSArray(key)).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_OBJECT:
                    t.SetTable(key, ((SFSObject)sfsData.GetSFSObject(key)).ToLuaTable(env));
                    break;
                case SFSDataType.TEXT:
                    t.SetString(key, sfsData.GetText(key));
                    break;
                case SFSDataType.NULL:
                    t.Set(key, null as string);
                    break;
                default:
                    Debug.LogWarningFormat("Unsupport type {0}", _st);
                    break;
            }
        }

        return t;
    }

    public static LuaTable ToLuaTable<T>(this T[] array, LuaEnv env)
    {
        LuaTable t = env.NewTable();
        int index = 0;
        foreach (T b in array)
        {
            t.Set(++index, b);
        }

        return t;
    }

    public static LuaTable ToLuaTable(this ByteArray array, LuaEnv env)
    {
        LuaTable t = env.NewTable();
        int index = 0;
        foreach (byte b in array.Bytes)
        {
            t.Set(++index, b);
        }

        return t;
    }

    public static LuaTable ToLuaTable(this SFSArray array, LuaEnv env)
    {
        LuaTable t = env.NewTable();
        int index = 0;
        for (int i = 0; i < array.Size(); ++i)
        {
            SFSDataType _st = (SFSDataType)array.GetWrappedElementAt(i).Type;
            switch (_st)
            {
                case SFSDataType.BOOL:
                    t.Set(++index, array.GetBool(i));
                    break;
                case SFSDataType.BYTE:
                    t.Set(++index, array.GetByte(i));
                    break;
                case SFSDataType.SHORT:
                    t.Set(++index, array.GetShort(i));
                    break;
                case SFSDataType.INT:
                    t.SetInt(++index, array.GetInt(i));
                    break;
                case SFSDataType.LONG:
                    t.SetLong(++index, array.GetLong(i));
                    break;
                case SFSDataType.FLOAT:
                    t.SetFloat(++index, array.GetFloat(i));
                    break;
                case SFSDataType.DOUBLE:
                    t.SetDouble(++index, array.GetDouble(i));
                    break;
                case SFSDataType.UTF_STRING:
                    t.SetString(++index, array.GetUtfString(i));
                    break;
                case SFSDataType.BOOL_ARRAY:
                    t.SetTable(++index, array.GetBoolArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.BYTE_ARRAY:
                    t.Set(++index, array.GetByteArray(i).Bytes);
                    break;
                case SFSDataType.SHORT_ARRAY:
                    t.SetTable(++index, array.GetShortArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.INT_ARRAY:
                    t.SetTable(++index, array.GetIntArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.LONG_ARRAY:
                    t.SetTable(++index, array.GetLongArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.FLOAT_ARRAY:
                    t.SetTable(++index, array.GetFloatArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.DOUBLE_ARRAY:
                    t.SetTable(++index, array.GetDoubleArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.UTF_STRING_ARRAY:
                    t.SetTable(++index, array.GetUtfStringArray(i).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_ARRAY:
                    t.SetTable(++index, ((SFSArray)array.GetSFSArray(i)).ToLuaTable(env));
                    break;
                case SFSDataType.SFS_OBJECT:
                    t.SetTable(++index, ((SFSObject)array.GetSFSObject(i)).ToLuaTable(env));
                    break;
                case SFSDataType.TEXT:
                    t.SetString(++index, array.GetText(i));
                    break;
                default:
                    Debug.LogWarningFormat("Unsupport type {0}", _st);
                    break;
            }
        }

        return t;
    }
#endif
}





