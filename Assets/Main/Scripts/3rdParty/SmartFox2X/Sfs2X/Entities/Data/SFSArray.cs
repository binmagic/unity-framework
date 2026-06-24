using Sfs2X.Exceptions;
using Sfs2X.Protocol.Serialization;
using Sfs2X.Util;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace Sfs2X.Entities.Data
{
  public class SFSArray : ISFSArray
  {
    private ISFSDataSerializer serializer;
    private List<SFSDataWrapper> dataHolder;

    public static SFSArray NewFromBinaryData(ByteArray ba)
    {
      return DefaultSFSDataSerializer.Instance.Binary2Array(ba) as SFSArray;
    }

    public static ISFSArray NewFromJsonData(string js)
    {
      return DefaultSFSDataSerializer.Instance.Json2Array(js);
    }

    public static SFSArray NewInstance()
    {
      return new SFSArray();
    }

    public SFSArray()
    {
      this.dataHolder = new List<SFSDataWrapper>();
      this.serializer = (ISFSDataSerializer) DefaultSFSDataSerializer.Instance;
    }

    public bool Contains(object obj)
    {
      if (obj is ISFSArray || obj is ISFSObject)
        throw new SFSError("ISFSArray and ISFSObject are not supported by this method.");
      for (int index = 0; index < this.Size(); ++index)
      {
        if (object.Equals(this.GetElementAt(index), obj))
          return true;
      }
      return false;
    }

    public SFSDataWrapper GetWrappedElementAt(int index)
    {
      return this.dataHolder[index];
    }

    public object GetElementAt(int index)
    {
      object obj = (object) null;
      if (this.dataHolder[index] != null)
        obj = this.dataHolder[index].Data;
      return obj;
    }

    public object RemoveElementAt(int index)
    {
      if (index >= this.dataHolder.Count)
        return (object) null;
      SFSDataWrapper sfsDataWrapper = this.dataHolder[index];
      this.dataHolder.RemoveAt(index);
      return sfsDataWrapper.Data;
    }

    public int Size()
    {
      return this.dataHolder.Count;
    }

    public ByteArray ToBinary()
    {
      ByteArray ba = new ByteArray();
      return this.serializer.Array2Binary((ISFSArray) this, ba);
    }

    public string ToJson()
    {
      return this.serializer.Array2Json(this.flatten());
    }

    private List<object> flatten()
    {
      List<object> list = new List<object>();
      DefaultSFSDataSerializer.Instance.flattenArray(list, (ISFSArray) this);
      return list;
    }

    public string GetDump()
    {
      return this.GetDump(true);
    }

    public string GetDump(bool format)
    {
      return !format ? this.Dump() : DefaultObjectDumpFormatter.PrettyPrintDump(this.Dump());
    }

    private string Dump()
    {
      StringBuilder stringBuilder = new StringBuilder(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_OPEN));
      for (int index = 0; index < this.dataHolder.Count; ++index)
      {
        SFSDataWrapper sfsDataWrapper = this.dataHolder[index];
        int type = (int)sfsDataWrapper.Type;
        string str;
        switch (type)
        {
          case 0:
            str = "NULL";
            break;
          case 17:
            str = (sfsDataWrapper.Data as SFSArray).GetDump(false);
            break;
          case 18:
            str = (sfsDataWrapper.Data as SFSObject).GetDump(false);
            break;
          default:
            str = type <= 8 || type >= 19 ? sfsDataWrapper.Data.ToString() : "[" + sfsDataWrapper.Data + "]";
            break;
        }
        stringBuilder.Append("(" + ((SFSDataType) type).ToString().ToLower() + ") ");
        stringBuilder.Append(str);
        stringBuilder.Append(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_DIVIDER));
      }
      string str1 = stringBuilder.ToString();
      if (this.Size() > 0)
        str1 = str1.Substring(0, str1.Length - 1);
      return str1 + Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_CLOSE);
    }

    public string GetHexDump()
    {
      return DefaultObjectDumpFormatter.HexDump(this.ToBinary());
    }

    public void AddNull()
    {
      this.AddObject((object) null, SFSDataType.NULL);
    }

    public void AddBool(bool val)
    {
      this.AddObject((object) val, SFSDataType.BOOL);
    }

    public void AddByte(byte val)
    {
      this.AddObject((object) val, SFSDataType.BYTE);
    }

    public void AddShort(short val)
    {
      this.AddObject((object) val, SFSDataType.SHORT);
    }

    public void AddInt(int val)
    {
      this.AddObject((object) val, SFSDataType.INT);
    }

    public void AddLong(long val)
    {
      this.AddObject((object) val, SFSDataType.LONG);
    }

    public void AddFloat(float val)
    {
      this.AddObject((object) val, SFSDataType.FLOAT);
    }

    public void AddDouble(double val)
    {
      this.AddObject((object) val, SFSDataType.DOUBLE);
    }

    public void AddUtfString(string val)
    {
      this.AddObject((object) val, SFSDataType.UTF_STRING);
    }

    public void AddText(string val)
    {
      this.AddObject((object) val, SFSDataType.TEXT);
    }

    public void AddBoolArray(bool[] val)
    {
      this.AddObject((object) val, SFSDataType.BOOL_ARRAY);
    }

    public void AddByteArray(ByteArray val)
    {
      this.AddObject((object) val, SFSDataType.BYTE_ARRAY);
    }

    public void AddShortArray(short[] val)
    {
      this.AddObject((object) val, SFSDataType.SHORT_ARRAY);
    }

    public void AddIntArray(int[] val)
    {
      this.AddObject((object) val, SFSDataType.INT_ARRAY);
    }

    public void AddLongArray(long[] val)
    {
      this.AddObject((object) val, SFSDataType.LONG_ARRAY);
    }

    public void AddFloatArray(float[] val)
    {
      this.AddObject((object) val, SFSDataType.FLOAT_ARRAY);
    }

    public void AddDoubleArray(double[] val)
    {
      this.AddObject((object) val, SFSDataType.DOUBLE_ARRAY);
    }

    public void AddUtfStringArray(string[] val)
    {
      this.AddObject((object) val, SFSDataType.UTF_STRING_ARRAY);
    }

    public void AddSFSArray(ISFSArray val)
    {
      this.AddObject((object) val, SFSDataType.SFS_ARRAY);
    }

    public void AddSFSObject(ISFSObject val)
    {
      this.AddObject((object) val, SFSDataType.SFS_OBJECT);
    }

    public void AddClass(object val)
    {
      this.AddObject(val, SFSDataType.CLASS);
    }

    public void Add(SFSDataWrapper wrappedObject)
    {
      this.dataHolder.Add(wrappedObject);
    }

    private void AddObject(object val, SFSDataType tp)
    {
      this.Add(new SFSDataWrapper(tp, val));
    }

    private T GetValue<T>(int index)
    {
      return (T) this.dataHolder[index].Data;
    }

    public bool IsNull(int index)
    {
      return this.dataHolder[index].Type == 0;
    }

    public virtual bool GetBool(int index)
    {
      if (index >= 0 && index < dataHolder.Count)
      {
        return dataHolder[index].BoolData;
      }

      return false;
      //return this.GetValue<bool>(index);
    }

    public virtual byte GetByte(int index)
    {
      if (index >= 0 && index < dataHolder.Count)
      {
        return dataHolder[index].ByteData;
      }

      return 0;
      
      //return this.GetValue<byte>(index);
    }

    public virtual short GetShort(int index)
    {
      if (index >= 0 && index < dataHolder.Count)
      {
        return dataHolder[index].ShortData;
      }

      return 0;
      //return this.GetValue<short>(index);
    }

    public virtual int GetInt(int index)
    {
      if (index >= 0 && index < dataHolder.Count)
      {
        return dataHolder[index].IntData;
      }

      return 0;
      //return this.GetValue<int>(index);
    }

    public virtual long GetLong(int index)
    {
      if (index >= 0 && index < dataHolder.Count)
      {
        return dataHolder[index].LongData;
      }

      return 0;
      //return this.GetValue<long>(index);
    }

    public virtual float GetFloat(int index)
    {
      return this.GetValue<float>(index);
    }

    public virtual double GetDouble(int index)
    {
      return this.GetValue<double>(index);
    }

    public string GetUtfString(int index)
    {
      return this.GetValue<string>(index);
    }

    public string GetText(int index)
    {
      return this.GetValue<string>(index);
    }

    private ICollection GetArray(int index)
    {
      return this.GetValue<ICollection>(index);
    }

    public virtual bool[] GetBoolArray(int index)
    {
      return (bool[]) this.GetArray(index);
    }

    public virtual ByteArray GetByteArray(int index)
    {
      return this.GetValue<ByteArray>(index);
    }

    public virtual short[] GetShortArray(int index)
    {
      return (short[]) this.GetArray(index);
    }

    public virtual int[] GetIntArray(int index)
    {
      return (int[]) this.GetArray(index);
    }

    public virtual long[] GetLongArray(int index)
    {
      return (long[]) this.GetArray(index);
    }

    public virtual float[] GetFloatArray(int index)
    {
      return (float[]) this.GetArray(index);
    }

    public virtual double[] GetDoubleArray(int index)
    {
      return (double[]) this.GetArray(index);
    }

    public virtual string[] GetUtfStringArray(int index)
    {
      return (string[]) this.GetArray(index);
    }

    public virtual ISFSArray GetSFSArray(int index)
    {
      return this.GetValue<ISFSArray>(index);
    }

    public virtual object GetClass(int index)
    {
      return this.dataHolder[index]?.Data;
    }

    public virtual ISFSObject GetSFSObject(int index)
    {
      return this.GetValue<ISFSObject>(index);
    }

    void ICollection.CopyTo(Array toArray, int index)
    {
      foreach (SFSDataWrapper sfsDataWrapper in this.dataHolder)
      {
        toArray.SetValue((object) sfsDataWrapper, index);
        ++index;
      }
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
      return (IEnumerator) new SFSArrayEnumerator(this.dataHolder);
    }

    bool ICollection.IsSynchronized
    {
      get
      {
        return false;
      }
    }

    object ICollection.SyncRoot
    {
      get
      {
        return (object) this;
      }
    }

    int ICollection.Count
    {
      get
      {
        return this.dataHolder.Count;
      }
    }
  }
}





