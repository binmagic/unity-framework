using Sfs2X.Entities.Data;

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
public static class MessageExtension
{
    public static int TryGetInt(this ISFSObject obj, string key)
    {
        return (int)MessageExtension.TryGetNumber(obj, key);
    }
    public static float TryGetFloat(this ISFSObject obj, string key)
    {
        return (float)MessageExtension.TryGetNumber(obj, key);
    }
    public static long TryGetLong(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                SFSDataType _t = obj.GetData(key).Type;
                if (_t == SFSDataType.BYTE)
                {
                    return obj.GetByte(key);
                }
                else if (_t == SFSDataType.SHORT)
                {
                    return obj.GetShort(key);
                }
                else if (_t == SFSDataType.INT)
                {
                    return obj.GetInt(key);
                }
                else if (_t == SFSDataType.LONG)
                {
                    return obj.GetLong(key);
                }
                else if (_t == SFSDataType.DOUBLE)
                {
                    return (long)obj.GetDouble(key);
                }
                else if (_t == SFSDataType.FLOAT)
                {
                    return (long)obj.GetFloat(key);
                }
                else if (_t == SFSDataType.UTF_STRING)
                {
                    //没想到吧， 居然还有可能是 string 类型。
                    long _d = 0;
                    long.TryParse(obj.GetUtfString(key), out _d);
                    return _d;
                }
            }
        }
        return 0;
    }
    public static double TryGetDouble(this ISFSObject obj, string key)
    {
        return MessageExtension.TryGetNumber(obj, key);
    }

    /// <summary>
    /// 针对 收到的  不确定的数字类型
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static double TryGetNumber(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                SFSDataType _t = obj.GetData(key).Type;
                if (_t == SFSDataType.BYTE)
                {
                    return obj.GetByte(key);
                }
                else if (_t == SFSDataType.SHORT)
                {
                    return obj.GetShort(key);
                }
                else if (_t == SFSDataType.INT)
                {
                    return obj.GetInt(key);
                }
                else if (_t == SFSDataType.LONG)
                {
                    return obj.GetLong(key);
                }
                else if (_t == SFSDataType.DOUBLE)
                {
                    return obj.GetDouble(key);
                }
                else if (_t == SFSDataType.FLOAT)
                {
                    return obj.GetFloat(key);
                }
                else if (_t == SFSDataType.UTF_STRING)
                {
                    //没想到吧， 居然还有可能是 string 类型。
                    double _d = 0;
                    double.TryParse(obj.GetUtfString(key), out _d);
                    return _d;
                }
            }
        }
        return 0;
    }
    public static bool TryGetBool(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                SFSDataType _t = obj.GetData(key).Type;
                if (_t == SFSDataType.BOOL)
                {
                    return obj.GetBool(key);
                }
                else if (_t == SFSDataType.INT)
                {    //
                    return obj.TryGetNumber(key) != 0;
                }

            }
        }
        return false;
    }
    public static string TryGetString(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {

                SFSDataType _t = obj.GetData(key).Type;
                if (_t == SFSDataType.UTF_STRING)
                {
                    return obj.GetUtfString(key);
                }
                else
                {
                    return obj.TryGetNumber(key).ToString();
                }
                if (_t == SFSDataType.INT)
                {    //
                    return obj.TryGetNumber(key).ToString();
                }
                if (_t == SFSDataType.LONG)
                {
                    return obj.TryGetNumber(key).ToString();
                }
            }
        }
        return "";
    }

    public static string TryMergeString(this ISFSObject obj, string key)
    {
        if (obj.ContainsKey(key)){
            var contentsArr = obj.GetSFSArray(key);
            string fullData = string.Empty;
            for (int i = 0; i < contentsArr.Count; i++)
            {
                string tmp = contentsArr.GetUtfString(i);
                if (!string.IsNullOrEmpty(tmp))
                {
                    fullData += tmp;
                }
            }
            return fullData;
        }
        return "";
    }

    public static ISFSObject TryGetObj(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                SFSDataType _t = obj.GetData(key).Type;
                if (_t == SFSDataType.SFS_OBJECT)
                {
                    return obj.GetSFSObject(key);
                }
            }
        }
        return null;
    }
    public static ISFSArray TryGetArray(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                return obj.GetSFSArray(key);
            }
        }
        return null;
    }

    public static int[] TryGetIntArray(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                return obj.GetIntArray(key);
            }
        }
        return null;
    }

    public static long GetLong(this ISFSObject obj, string key)
    {
        if (obj != null)
        {
            if (obj.ContainsKey(key))
            {
                return obj.GetLong(key);
            }
        }
        return 0;
    }

    public static bool IsNullOrEmpty(this ISFSArray obj)
    {
        return obj == null || obj.Count == 0;
    }
}





