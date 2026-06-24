using System;
using Sfs2X.Util;

namespace Sfs2X.Entities.Data
{
  public class SFSArrayLite : SFSArray
  {
    public static new ISFSArray NewInstance()
    {
      return new SFSArrayLite();
    }

    public override object GetClass(int index)
    {
      throw new NotSupportedException("SFSArrayLite doesn't support class serialization");
    }

    public override byte GetByte(int index)
    {
      int num = GetInt(index);
      if (num < 0)
        num = 256 + num;
      return Convert.ToByte(num);
    }

    public override short GetShort(int index)
    {
      return Convert.ToInt16(GetInt(index));
    }

    public override long GetLong(int index)
    {
      SFSDataWrapper wrappedElementAt = GetWrappedElementAt(index);
      if (wrappedElementAt == null)
        return 0;
      object data = wrappedElementAt.Data;
      return data is int ? Convert.ToInt64(data) : (long) data;
    }

    public override float GetFloat(int index)
    {
      return Convert.ToSingle(GetDouble(index));
    }

    public override bool[] GetBoolArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      bool[] flagArray = new bool[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        flagArray.SetValue(sfsArray.GetBool(index1), index1);
      return flagArray;
    }

    public override ByteArray GetByteArray(int index)
    {
      throw new NotSupportedException("SFSArrayLite doesn't support ByteArray transmission");
    }

    public override short[] GetShortArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      short[] numArray = new short[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        numArray.SetValue((short) sfsArray.GetInt(index1), index1);
      return numArray;
    }

    public override int[] GetIntArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      int[] numArray = new int[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        numArray.SetValue(sfsArray.GetInt(index1), index1);
      return numArray;
    }

    public override long[] GetLongArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      long[] numArray = new long[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        numArray.SetValue(sfsArray.GetLong(index1), index1);
      return numArray;
    }

    public override float[] GetFloatArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      float[] numArray = new float[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        numArray.SetValue((float) sfsArray.GetDouble(index1), index1);
      return numArray;
    }

    public override double[] GetDoubleArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      double[] numArray = new double[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        numArray.SetValue(sfsArray.GetDouble(index1), index1);
      return numArray;
    }

    public override string[] GetUtfStringArray(int index)
    {
      ISFSArray sfsArray = GetSFSArray(index);
      if (sfsArray == null)
        return null;
      string[] strArray = new string[sfsArray.Size()];
      for (int index1 = 0; index1 < sfsArray.Size(); ++index1)
        strArray.SetValue(sfsArray.GetUtfString(index1), index1);
      return strArray;
    }
  }
}





