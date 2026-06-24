using System;
using Sfs2X.Util;

namespace Sfs2X.Entities.Data
{
  public class SFSObjectLite : SFSObject
  {
    public static new ISFSObject NewInstance()
    {
      return new SFSObjectLite();
    }

    public override object GetClass(string key)
    {
      throw new NotSupportedException("SFSObjectLite doesn't support class serialization");
    }

    public override byte GetByte(string key)
    {
      int num = GetInt(key);
      if (num < 0)
        num = 256 + num;
      return Convert.ToByte(num);
    }

    public override short GetShort(string key)
    {
      return Convert.ToInt16(GetInt(key));
    }

    public override long GetLong(string key)
    {
      SFSDataWrapper data1 = GetData(key);
      if (data1 == null)
        return 0;
      object data2 = data1.Data;
      return data2 is int ? Convert.ToInt64(data2) : (long) data2;
    }

    public override float GetFloat(string key)
    {
      return Convert.ToSingle(GetDouble(key));
    }

    public override bool[] GetBoolArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      bool[] flagArray = new bool[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        flagArray.SetValue(sfsArray.GetBool(index), index);
      return flagArray;
    }

    public override ByteArray GetByteArray(string key)
    {
      throw new NotSupportedException("SFSObjectLite doesn't support ByteArray transmission");
    }

    public override short[] GetShortArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      short[] numArray = new short[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        numArray.SetValue((short) sfsArray.GetInt(index), index);
      return numArray;
    }

    public override int[] GetIntArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      int[] numArray = new int[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        numArray.SetValue(sfsArray.GetInt(index), index);
      return numArray;
    }

    public override long[] GetLongArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      long[] numArray = new long[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        numArray.SetValue(sfsArray.GetLong(index), index);
      return numArray;
    }

    public override float[] GetFloatArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      float[] numArray = new float[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        numArray.SetValue((float) sfsArray.GetDouble(index), index);
      return numArray;
    }

    public override double[] GetDoubleArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      double[] numArray = new double[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        numArray.SetValue(sfsArray.GetDouble(index), index);
      return numArray;
    }

    public override string[] GetUtfStringArray(string key)
    {
      ISFSArray sfsArray = GetSFSArray(key);
      if (sfsArray == null)
        return null;
      string[] strArray = new string[sfsArray.Size()];
      for (int index = 0; index < sfsArray.Size(); ++index)
        strArray.SetValue(sfsArray.GetUtfString(index), index);
      return strArray;
    }
  }
}





