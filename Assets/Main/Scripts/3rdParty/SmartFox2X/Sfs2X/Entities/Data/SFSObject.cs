using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Sfs2X.Protocol.Serialization;
using Sfs2X.Util;

namespace Sfs2X.Entities.Data
{
  public class SFSObject : ISFSObject
  {
    public Dictionary<string, SFSDataWrapper> dataHolder;
    private ISFSDataSerializer serializer;

    public static SFSObject NewFromBinaryData(ByteArray ba)
    {
      return DefaultSFSDataSerializer.Instance.Binary2Object(ba) as SFSObject;
    }

    public static ISFSObject NewFromJsonData(string js)
    {
      return DefaultSFSDataSerializer.Instance.Json2Object(js);
    }

    public static SFSObject NewInstance()
    {
      return new SFSObject();
    }

    public SFSObject()
    {
      dataHolder = new Dictionary<string, SFSDataWrapper>(8);
      serializer = DefaultSFSDataSerializer.Instance;
    }

    private string Dump()
    {
      StringBuilder stringBuilder = new StringBuilder();
      stringBuilder.Append(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_OPEN));
      foreach (KeyValuePair<string, SFSDataWrapper> keyValuePair in dataHolder)
      {
        SFSDataWrapper sfsDataWrapper = keyValuePair.Value;
        string key = keyValuePair.Key;
        int type = (int)sfsDataWrapper.Type;
        stringBuilder.Append("(" + ((SFSDataType) type).ToString().ToLower() + ")");
        stringBuilder.Append(" " + key + ": ");
        switch (type)
        {
          case 17: // SFSDataType.SFS_ARRAY:
            stringBuilder.Append(((SFSArray) sfsDataWrapper.Data).GetDump(false));
            break;
          case 18: // SFSDataType.SFS_OBJECT:
            stringBuilder.Append(((SFSObject) sfsDataWrapper.Data).GetDump(false));
            break;
          default:
            if (type > 8 && type < 19)
            {
              stringBuilder.Append("[" + sfsDataWrapper.Data + "]");
              break;
            }
            stringBuilder.Append(sfsDataWrapper.Data);
            break;
        }
        stringBuilder.Append(DefaultObjectDumpFormatter.TOKEN_DIVIDER);
      }
      string str = stringBuilder.ToString();
      if (Size() > 0)
        str = str.Substring(0, str.Length - 1);
      return str + DefaultObjectDumpFormatter.TOKEN_INDENT_CLOSE;
    }

    private T GetValue<T>(string key)
    {
      if (dataHolder.TryGetValue(key, out var v))
      {
        return (T) v.Data;
      }

      return default;
      //return !dataHolder.ContainsKey(key) ? default : (T) dataHolder[key].Data;
    }

    public SFSDataWrapper GetData(string key)
    {
      return dataHolder[key];
    }

    public bool IsNull(string key)
    {
      if (!ContainsKey(key))
        return true;
      SFSDataWrapper sfsDataWrapper = dataHolder[key];
      return sfsDataWrapper.IsNull();
      //return sfsDataWrapper.Type == 0 || sfsDataWrapper.Data == null;
    }

    public virtual bool GetBool(string key)
    {
      if (dataHolder.TryGetValue(key, out var v))
      {
        return v.BoolData;
      }

      return false;
      //return GetValue<bool>(key);
    }

    public virtual byte GetByte(string key)
    {
//      return GetValue<byte>(key);
      if (dataHolder.TryGetValue(key, out var v))
      {
        return v.ByteData;
      }

      return 0;
    }

    public virtual short GetShort(string key)
    {
      //return GetValue<short>(key);
      if (dataHolder.TryGetValue(key, out var v))
      {
        return v.ShortData;
      }

      return 0;
    }

    public virtual int GetInt(string key)
    {
      //return GetValue<int>(key);
      if (dataHolder.TryGetValue(key, out var v))
      {
        return v.IntData;
      }

      return 0;
    }

    public virtual long GetLong(string key)
    {
      //return GetValue<long>(key);
      if (dataHolder.TryGetValue(key, out var v))
      {
        return v.LongData;
      }

      return 0;
    }

    public virtual float GetFloat(string key)
    {
      return GetValue<float>(key);
    }

    public virtual double GetDouble(string key)
    {
      return GetValue<double>(key);
    }

    public virtual string GetUtfString(string key)
    {
      return GetValue<string>(key);
    }

    public virtual string GetText(string key)
    {
      return GetValue<string>(key);
    }

    private ICollection GetArray(string key)
    {
      return GetValue<ICollection>(key);
    }

    public virtual bool[] GetBoolArray(string key)
    {
      return (bool[]) GetArray(key);
    }

    public virtual ByteArray GetByteArray(string key)
    {
      return GetValue<ByteArray>(key);
    }

    public virtual short[] GetShortArray(string key)
    {
      return (short[]) GetArray(key);
    }

    public virtual int[] GetIntArray(string key)
    {
      return (int[]) GetArray(key);
    }

    public virtual long[] GetLongArray(string key)
    {
      return (long[]) GetArray(key);
    }

    public virtual float[] GetFloatArray(string key)
    {
      return (float[]) GetArray(key);
    }

    public virtual double[] GetDoubleArray(string key)
    {
      return (double[]) GetArray(key);
    }

    public virtual string[] GetUtfStringArray(string key)
    {
      return (string[]) GetArray(key);
    }

    public virtual ISFSArray GetSFSArray(string key)
    {
      return GetValue<ISFSArray>(key);
    }

    public virtual ISFSObject GetSFSObject(string key)
    {
      return GetValue<ISFSObject>(key);
    }

    public virtual object GetClass(string key)
    {
      if (!ContainsKey(key))
        return null;
      return dataHolder[key]?.Data;
    }

    public void PutNull(string key)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.NULL, null);
    }

    public void PutBool(string key, bool val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.BOOL, val);
    }

    public void PutByte(string key, byte val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.BYTE, val);
    }

    public void PutShort(string key, short val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.SHORT, val);
    }

    public void PutInt(string key, int val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.INT, val);
    }

    public void PutLong(string key, long val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.LONG, val);
    }

    public void PutFloat(string key, float val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.FLOAT, val);
    }

    public void PutDouble(string key, double val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.DOUBLE, val);
    }

    public void PutUtfString(string key, string val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.UTF_STRING, val);
    }

    public void PutText(string key, string val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.TEXT, val);
    }

    public void PutBoolArray(string key, bool[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.BOOL_ARRAY, val);
    }

    public void PutByteArray(string key, ByteArray val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.BYTE_ARRAY, val);
    }

    public void PutShortArray(string key, short[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.SHORT_ARRAY, val);
    }

    public void PutIntArray(string key, int[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.INT_ARRAY, val);
    }

    public void PutLongArray(string key, long[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.LONG_ARRAY, val);
    }

    public void PutFloatArray(string key, float[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.FLOAT_ARRAY, val);
    }

    public void PutDoubleArray(string key, double[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.DOUBLE_ARRAY, val);
    }

    public void PutUtfStringArray(string key, string[] val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.UTF_STRING_ARRAY, val);
    }

    public void PutSFSArray(string key, ISFSArray val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.SFS_ARRAY, val);
    }

    public void PutSFSObject(string key, ISFSObject val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.SFS_OBJECT, val);
    }

    public virtual void PutClass(string key, object val)
    {
      dataHolder[key] = new SFSDataWrapper(SFSDataType.CLASS, val);
    }

    public void Put(string key, SFSDataWrapper val)
    {
      dataHolder[key] = val;
    }

    public bool ContainsKey(string key)
    {
      return dataHolder.ContainsKey(key);
    }

    public string GetDump(bool format)
    {
      return !format ? Dump() : DefaultObjectDumpFormatter.PrettyPrintDump(Dump());
    }

    public string GetDump()
    {
      return GetDump(true);
    }

    public string GetHexDump()
    {
      return DefaultObjectDumpFormatter.HexDump(ToBinary());
    }

    public string[] GetKeys()
    {
      string[] array = new string[dataHolder.Keys.Count];
      dataHolder.Keys.CopyTo(array, 0);
      return array;
    }

    public void Traverse(Action<string, SFSDataWrapper> action)
    {
      foreach (var pair in dataHolder)
      {
        action(pair.Key, pair.Value);
      }
    }
    
    public void RemoveElement(string key)
    {
      dataHolder.Remove(key);
    }

    public int Size()
    {
      return dataHolder.Count;
    }

    public ByteArray ToBinary()
    {
      ByteArray ba = new ByteArray();
      return serializer.Object2Binary(this, ba);
    }

    public ByteArray ToBinary(ByteArray dst)
    {
      return serializer.Object2Binary(this, dst);
    }
    
    public string ToJson()
    {
      return serializer.Object2Json(flatten());
    }

    private Dictionary<string, object> flatten()
    {
      Dictionary<string, object> map = new Dictionary<string, object>();
      DefaultSFSDataSerializer.Instance.flattenObject(map, this);
      return map;
    }
  }
}





