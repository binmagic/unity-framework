using System;
using UnityEngine;

namespace Sfs2X.Entities.Data
{
  public class SFSDataWrapper
  {
    private SFSDataType type;
    private object data;
    private long long_data;

    public SFSDataType Type => type;

    public object Data
    {
      get
      {
        switch (type)
        {
          case SFSDataType.BOOL: 
            return long_data == 1 ? true : false;
          case SFSDataType.BYTE: 
            return (byte) long_data;
          case SFSDataType.SHORT: 
            return (short) long_data;
          case SFSDataType.INT: 
            return (int) long_data;
          case SFSDataType.LONG: 
            return long_data;
        }
        
        return data;
      }
    }
    
    public SFSDataWrapper(SFSDataType tp, object data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.BOOL: 
        case SFSDataType.BYTE: 
        case SFSDataType.SHORT:
        case SFSDataType.INT: 
        case SFSDataType.LONG: 
          long_data = (long)data;
          return;
      }
      
      this.data = data;
    }
    
    // 以下是为了防止装箱拆箱加的一些函数    
    // 把所有常用的整形存储到一个long变量，这样可以避免常用类型的装箱
    
    public bool IsNull()
    {
      if (type == SFSDataType.NULL)
      {
        return true;
      }

      // 这些类型不能称为NULL
      switch (type)
        {
          case SFSDataType.BOOL:
          case SFSDataType.BYTE:
          case SFSDataType.SHORT:
          case SFSDataType.INT:
          case SFSDataType.LONG:
            case SFSDataType.FLOAT:
              case SFSDataType.DOUBLE:
            return false;
        }

      return data == null;
    }
    
    
    public SFSDataWrapper(SFSDataType tp, bool data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.BOOL:
          long_data = data ? 1 : 0;
          return;
      }
      
      Debug.LogError("SFSDataWrapper type not match!!!");
    }
    
    public SFSDataWrapper(SFSDataType tp, byte data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.BYTE:
          long_data = data;
          return;
      }
      
      Debug.LogError("SFSDataWrapper type not match!!!");
    }
    
    public SFSDataWrapper(SFSDataType tp, short data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.SHORT:
          long_data = data;
          return;
      }
      
      Debug.LogError("SFSDataWrapper type not match!!!");
    }
    
    public SFSDataWrapper(SFSDataType tp, int data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.INT:
          long_data = data;
          return;
      }
      
      Debug.LogError("SFSDataWrapper type not match!!!");
    }
    
    public SFSDataWrapper(SFSDataType tp, long data)
    {
      type = tp;
      switch (type)
      {
        case SFSDataType.LONG:
          long_data = data;
          return;
      }
      
      Debug.LogError("SFSDataWrapper type not match!!!");
    }
    
    public SFSDataWrapper(bool data)
    {
      this.type = SFSDataType.BOOL;
      this.long_data = data ? 1 : 0;
    }
    
    public SFSDataWrapper(byte data)
    {
      this.type = SFSDataType.BYTE;
      this.long_data = data;
    }
    
    public SFSDataWrapper(short data)
    {
      this.type = SFSDataType.SHORT;
      this.long_data = data;
    }

    public SFSDataWrapper(int data)
    {
      this.type = SFSDataType.INT;
      this.long_data = data;
    }
    
    public SFSDataWrapper(long data)
    {
      this.type = SFSDataType.LONG;
      this.long_data = data;
    }

    public long LongData
    {
      get
      {
        switch (type)
        {
          case SFSDataType.BOOL:
          case SFSDataType.BYTE:
          case SFSDataType.SHORT:
          case SFSDataType.INT:
          case SFSDataType.LONG: return long_data;
        }

        try
        {
          return Convert.ToInt64(data);
        }
        catch (Exception e)
        {
          return 0;
        }
      }
    }
    public bool BoolData
    {
      get
      {
        long d = LongData;
        return d == 0 ? false : true;
      }
    }

    public byte ByteData
    {
      get
      {
        long d = LongData;
        return (byte) d;
      }
    }

    public short ShortData
    {
      get
      {
        long d = LongData;
        return (short) d;
      }
    }
    
    public int IntData
    {
      get
      {
        long d = LongData;
        return (int) d;
      }
    }
  }
}





