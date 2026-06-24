using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Sfs2X.Entities.Data;
using Sfs2X.Exceptions;
using Sfs2X.Util;
using LitJson;



namespace Sfs2X.Protocol.Serialization
{
  public class UnrealDefaultSFSDataSerializer
  {
    private static readonly string CLASS_MARKER_KEY = "$C";
    private static readonly string CLASS_FIELDS_KEY = "$F";
    private static readonly string FIELD_NAME_KEY = "N";
    private static readonly string FIELD_VALUE_KEY = "V";
    private static Assembly runningAssembly;
    private static UnrealDefaultSFSDataSerializer instance;

    public static UnrealDefaultSFSDataSerializer Instance
    {
      get
      {
        if (instance == null)
          instance = new UnrealDefaultSFSDataSerializer();
        return instance;
      }
    }

    public static Assembly RunningAssembly
    {
      get
      {
        return runningAssembly;
      }
      set
      {
        runningAssembly = value;
      }
    }

    public UnrealDefaultSFSDataSerializer()
    {
    }

    public ByteArray Object2Binary(ISFSObject obj, ByteArray buffer)
    {
      //ByteArray buffer = new ByteArray();
      buffer.WriteByte(Convert.ToByte((int)SFSDataType.SFS_OBJECT));
      buffer.WriteShort(Convert.ToInt16(obj.Size()));
      return Obj2bin(obj, buffer);
    }

    private ByteArray Obj2bin(ISFSObject obj, ByteArray buffer)
    {
      obj.Traverse((key, data)=>
      {
        buffer = EncodeSFSObjectKey(buffer, key);
        buffer = EncodeObject2(buffer, data);
      });
      
      return buffer;
    }

    public ByteArray Array2Binary(ISFSArray array, ByteArray buffer)
    {
      //todo: gc 这里会递归调用因此不能用个全局的来替换 后续想想怎么搞
      //ByteArray buffer = new ByteArray();
      buffer.WriteByte(Convert.ToByte((int)SFSDataType.SFS_ARRAY));
      buffer.WriteShort(Convert.ToInt16(array.Size()));
      return Arr2bin(array, buffer);
      //return buffer;
    }

    private ByteArray Arr2bin(ISFSArray array, ByteArray buffer)
    {
      for (int index = 0; index < array.Size(); ++index)
      {
        SFSDataWrapper wrappedElementAt = array.GetWrappedElementAt(index);
        buffer = EncodeObject2(buffer, wrappedElementAt);
      }
      return buffer;
    }
    
    public ISFSObject ParseHeaderAndCmd(ByteArray data)
    {
      if (data.DataLength < 3)
      {
        throw new SFSCodecError("Can't decode an SFSObject. Byte data is insufficient. Size: " + data.DataLength + " byte(s)");
      }
      
      data.Position = 0;
      var ret = DecodeSFSObject_1stLevel(data);
      data.Position = 0;
      return ret;
    }

    private ISFSObject DecodeSFSObject_1stLevel(ByteArray buffer)
    {
      SFSObject sfsObject = SFSObject.NewInstance();
      byte num1 = buffer.ReadByte();
      if (num1 != Convert.ToByte((int)SFSDataType.SFS_OBJECT))
      {
        throw new SFSCodecError("Invalid SFSDataType. Expected: " + SFSDataType.SFS_OBJECT + ", found: " + num1);
      }
      
      int num2 = buffer.ReadShort();
      if (num2 < 0)
      {
        throw new SFSCodecError("Can't decode SFSObject. Size is negative: " + num2);
      }
      
      try
      {
        for (int index = 0; index < num2; ++index)
        {
          string key = buffer.ReadUTF();
          //先获取下第一层的各value类型 如果是Int的则放到sfsObj中 否则则进入虚拟解析
          SFSDataType int32 = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
          
          if (int32 == SFSDataType.SHORT)
          {
            sfsObject.Put(key, new SFSDataWrapper(SFSDataType.SHORT, buffer.ReadShort()));
          }
          else if (int32 == SFSDataType.BYTE)
          {
            sfsObject.Put(key, new SFSDataWrapper(SFSDataType.BYTE, buffer.ReadByte()));
          }
          else
          {
            //进入虚拟解析 仅对Position进行移动
            var ret = DecodeSFSObject_2ndLevel(buffer, out var cmdWrapper);
            if (ret == 1)//非应用层消息
            {
              sfsObject.Put("cmd", cmdWrapper);
            }
            else
            {
              return null;
            }
          }
        }
      }
      catch (SFSCodecError ex)
      {
        throw ex;
      }
      return sfsObject;
    }
    private int DecodeSFSObject_2ndLevel(ByteArray buffer, out SFSDataWrapper cmdWrapper)
    {
      cmdWrapper = null;
      //应用层的消息第二层类型固定是SFSObj
      --buffer.Position;
      byte num1 = buffer.ReadByte();
      if (num1 != Convert.ToByte((int)SFSDataType.SFS_OBJECT))
      {
        //非应用层消息
        return -1;
      }
      
      int num2 = buffer.ReadShort();
      if (num2 != 2)
      {
        //非应用层消息
        return -2;
      }
      
      for (int index = 0; index < num2; ++index)
      {
        string key = buffer.ReadUTF();
      
        if (key == "c")
        {
          ++buffer.Position;//第一个字节是类型 已确定是UTF_STRING 直接累加Position
          cmdWrapper = new SFSDataWrapper(SFSDataType.UTF_STRING, buffer.ReadUTF());
        }
        else if(key == "p")
        {
          //如果key不是"c"的话，应该是"p"走虚拟解析来移动position,用于最终解析"c"对应的value(message command)
          DecodeObject(buffer);
        }
        else
        {
          //应用层的消息只有"p"和"c" 如果出现其他的字段则可能是网络层消息
          return -3;
        }
      }
      
      return 1;//1代表应用正常解析了应用层消息
    }
    
    // 从缓冲中读取应用层的消息id
    public string DecodeSFSObject_CmdID(ByteArray buffer)
    {
      buffer.Position = 0;
      byte paramType = buffer.ReadByte();
      if (paramType != Convert.ToByte((int)SFSDataType.SFS_OBJECT))
      {
        return null;
      }
      
      int paramCount = buffer.ReadShort();
      
      // 这里先读取第一层结构：p,a,c
      for (int index = 0; index < paramCount; ++index)
      {
        string key = buffer.ReadUTF();
        SFSDataType int32 = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
        
        if (int32 == SFSDataType.SHORT)
        {
          short aType = buffer.ReadShort();
        }
        else if (int32 == SFSDataType.BYTE)
        {
          byte actionId = buffer.ReadByte();
          if (actionId == 0)
          {
            // 非应用层消息，不用处理了
            return null;
          }
        }
        else if (int32 == SFSDataType.SFS_OBJECT)
        {
          // 这里开始解析第二层消息，主要有c,p,r，一般情况下，r没有。
          // c是我们要解析的内容。但是比较恶心的是，p在c的前面，导致这里需要整体跳过p，而p一般又是一个比较大的结构。。。

#if UNITY_EDITOR
          if (key != "p")
          {
            UnityEngine.Debug.LogError("not p, error!!");
          }
#endif

          short num2 = buffer.ReadShort();
          if (num2 != 2)
          {
            // 因为对于应用的消息来说，一般数量就是2个，即c，p，r。没有r
            // 所以这里做个快速判断，不是应用消息直接丢
            return null;
          }
          
          for (int ii = 0; ii < num2; ++ii)
          {
            string key2 = buffer.ReadUTF();

            if (key2 == "c")
            {
              byte cType = buffer.ReadByte();
              string cmd = buffer.ReadUTF();
              return cmd;
            }
            else if (key2 == "p")
            {
              //如果key不是"c"的话，应该是"p"走虚拟解析来移动position,用于最终解析"c"对应的value(message command)
              DecodeObject(buffer);
            }
            else
            {
              //应用层的消息只有"p"和"c" 如果出现其他的字段则可能是网络层消息
#if UNITY_EDITOR
              UnityEngine.Debug.LogError("not p, error!!");
#endif
              return null;
            }
          }
        }
      }
      
      return null; 
    }
 
    private void DecodeSFSObject(ByteArray buffer)
    {
      byte num1 = buffer.ReadByte();
      if (num1 != Convert.ToByte((int)SFSDataType.SFS_OBJECT))
        throw new SFSCodecError("Invalid SFSDataType. Expected: " + SFSDataType.SFS_OBJECT + ", found: " + num1);
      int num2 = buffer.ReadShort();
      if (num2 < 0)
        throw new SFSCodecError("Can't decode SFSObject. Size is negative: " + num2);
      
      try
      {
        for (int index = 0; index < num2; ++index)
        {
          //string key = buffer.ReadUTF();
          buffer.SkipUTF();
          DecodeObject(buffer);
        }
      }
      catch (SFSCodecError ex)
      {
        throw ex;
      }
    }

    public ISFSArray Binary2Array(ByteArray data)
    {
      if (data.DataLength < 3)
        throw new SFSCodecError("Can't decode an SFSArray. Byte data is insufficient. Size: " + data.DataLength + " byte(s)");
      data.Position = 0;
      DecodeSFSArray(data);

      return null;
    }
    private void DecodeSFSArray(ByteArray buffer)
    {
      SFSDataType int32 = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
      if (int32 != SFSDataType.SFS_ARRAY)
        throw new SFSCodecError("Invalid SFSDataType. Expected: " + SFSDataType.SFS_ARRAY + ", found: " + int32);
      int num = buffer.ReadShort();
      if (num < 0)
        throw new SFSCodecError("Can't decode SFSArray. Size is negative: " + num);
      try
      {
        for (int index = 0; index < num; ++index)
        {
          DecodeObject(buffer);
        }
      }
      catch (SFSCodecError ex)
      {
        throw ex;
      }
    }
    
    private void DecodeObject(ByteArray buffer)
    {
      SFSDataType int32 = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
      //SFSDataWrapper sfsDataWrapper;
      switch (int32)
      {
        case SFSDataType.NULL:
          break;
        case SFSDataType.BOOL:
          buffer.ReadBool();
          break;
        case SFSDataType.BYTE:
          buffer.ReadByte();
          break;
        case SFSDataType.SHORT:
          buffer.ReadShort();
          break;
        case SFSDataType.INT:
          buffer.SkipInt();
          break;
        case SFSDataType.LONG:
          buffer.SkipLong();
          break;
        case SFSDataType.FLOAT:
          buffer.ReadFloat();
          break;
        case SFSDataType.DOUBLE:
          buffer.ReadDouble();
          break;
        case SFSDataType.UTF_STRING:
          //buffer.ReadUTF();
          buffer.SkipUTF();
          break;
        case SFSDataType.BOOL_ARRAY:
        {
          int typedArraySize = GetTypedArraySize(buffer);
          for (int index = 0; index < typedArraySize; ++index)
          {
            buffer.ReadBool();
          }
        }
          break;
        case SFSDataType.BYTE_ARRAY:
        {
          int count = buffer.ReadInt();
          if (count < 0)
            throw new SFSCodecError("Array negative size: " + count);
          buffer.ReadBytes(count);
        }
          break;
        case SFSDataType.SHORT_ARRAY:
        {
          BinDecode_SHORT_ARRAY(buffer);
        }
          break;
        case SFSDataType.INT_ARRAY:
          BinDecode_INT_ARRAY(buffer);
          break;
        case SFSDataType.LONG_ARRAY:
          BinDecode_LONG_ARRAY(buffer);
          break;
        case SFSDataType.FLOAT_ARRAY:
          BinDecode_FLOAT_ARRAY(buffer);
          break;
        case SFSDataType.DOUBLE_ARRAY:
          BinDecode_DOUBLE_ARRAY(buffer);
          break;
        case SFSDataType.UTF_STRING_ARRAY:
          BinDecode_UTF_STRING_ARRAY(buffer);
          break;
        case SFSDataType.SFS_ARRAY:
          --buffer.Position;
          DecodeSFSArray(buffer);
          break;
        case SFSDataType.SFS_OBJECT:
          --buffer.Position;
          DecodeSFSObject(buffer);
          break;
        case SFSDataType.TEXT:
          BinDecode_TEXT(buffer);
          break;
        default:
          throw new Exception("Unknow SFSDataType ID: " + int32);
      }
    }

#if false
    private ByteArray EncodeObject(ByteArray buffer, SFSDataType typeId, object data)
    {
      switch (typeId)
      {
        case SFSDataType.NULL:
          buffer = BinEncode_NULL(buffer);
          break;
        case SFSDataType.BOOL:
          buffer = BinEncode_BOOL(buffer, (bool) data);
          break;
        case SFSDataType.BYTE:
          buffer = BinEncode_BYTE(buffer, (byte) data);
          break;
        case SFSDataType.SHORT:
          buffer = BinEncode_SHORT(buffer, (short) data);
          break;
        case SFSDataType.INT:
          buffer = BinEncode_INT(buffer, (int) data);
          break;
        case SFSDataType.LONG:
          buffer = BinEncode_LONG(buffer, (long) data);
          break;
        case SFSDataType.FLOAT:
          buffer = BinEncode_FLOAT(buffer, (float) data);
          break;
        case SFSDataType.DOUBLE:
          buffer = BinEncode_DOUBLE(buffer, (double) data);
          break;
        case SFSDataType.UTF_STRING:
          buffer = BinEncode_UTF_STRING(buffer, (string) data);
          break;
        case SFSDataType.BOOL_ARRAY:
          buffer = BinEncode_BOOL_ARRAY(buffer, (bool[]) data);
          break;
        case SFSDataType.BYTE_ARRAY:
          buffer = BinEncode_BYTE_ARRAY(buffer, (ByteArray) data);
          break;
        case SFSDataType.SHORT_ARRAY:
          buffer = BinEncode_SHORT_ARRAY(buffer, (short[]) data);
          break;
        case SFSDataType.INT_ARRAY:
          buffer = BinEncode_INT_ARRAY(buffer, (int[]) data);
          break;
        case SFSDataType.LONG_ARRAY:
          buffer = BinEncode_LONG_ARRAY(buffer, (long[]) data);
          break;
        case SFSDataType.FLOAT_ARRAY:
          buffer = BinEncode_FLOAT_ARRAY(buffer, (float[]) data);
          break;
        case SFSDataType.DOUBLE_ARRAY:
          buffer = BinEncode_DOUBLE_ARRAY(buffer, (double[]) data);
          break;
        case SFSDataType.UTF_STRING_ARRAY:
          buffer = BinEncode_UTF_STRING_ARRAY(buffer, (string[]) data);
          break;
        case SFSDataType.SFS_ARRAY:
          buffer = AddData(buffer, Array2Binary((ISFSArray) data));
          break;
        case SFSDataType.SFS_OBJECT:
          buffer = AddData(buffer, Object2Binary((ISFSObject) data));
          break;
        case SFSDataType.CLASS:
          buffer = AddData(buffer, Object2Binary(Cs2Sfs(data)));
          break;
        case SFSDataType.TEXT:
          buffer = BinEncode_TEXT(buffer, (string) data);
          break;
        default:
          throw new SFSCodecError("Unrecognized type in SFSObject serialization: " + typeId);
      }
      return buffer;
    }
#endif
    
    private ByteArray EncodeObject2(ByteArray buffer, SFSDataWrapper dataWrapper)
    {
      switch (dataWrapper.Type)
      {
        case SFSDataType.NULL:
          buffer = BinEncode_NULL(buffer);
          break;
        case SFSDataType.BOOL:
          buffer = BinEncode_BOOL(buffer, dataWrapper.BoolData);
          break;
        case SFSDataType.BYTE:
          buffer = BinEncode_BYTE(buffer, dataWrapper.ByteData);
          break;
        case SFSDataType.SHORT:
          buffer = BinEncode_SHORT(buffer, dataWrapper.ShortData);
          break;
        case SFSDataType.INT:
          buffer = BinEncode_INT(buffer, dataWrapper.IntData);
          break;
        case SFSDataType.LONG:
          buffer = BinEncode_LONG(buffer, dataWrapper.LongData);
          break;
        case SFSDataType.FLOAT:
          buffer = BinEncode_FLOAT(buffer, (float) dataWrapper.Data);
          break;
        case SFSDataType.DOUBLE:
          buffer = BinEncode_DOUBLE(buffer, (double) dataWrapper.Data);
          break;
        case SFSDataType.UTF_STRING:
          buffer = BinEncode_UTF_STRING(buffer, (string) dataWrapper.Data);
          break;
        case SFSDataType.BOOL_ARRAY:
          buffer = BinEncode_BOOL_ARRAY(buffer, (bool[]) dataWrapper.Data);
          break;
        case SFSDataType.BYTE_ARRAY:
          buffer = BinEncode_BYTE_ARRAY(buffer, (ByteArray) dataWrapper.Data);
          break;
        case SFSDataType.SHORT_ARRAY:
          buffer = BinEncode_SHORT_ARRAY(buffer, (short[]) dataWrapper.Data);
          break;
        case SFSDataType.INT_ARRAY:
          buffer = BinEncode_INT_ARRAY(buffer, (int[]) dataWrapper.Data);
          break;
        case SFSDataType.LONG_ARRAY:
          buffer = BinEncode_LONG_ARRAY(buffer, (long[]) dataWrapper.Data);
          break;
        case SFSDataType.FLOAT_ARRAY:
          buffer = BinEncode_FLOAT_ARRAY(buffer, (float[]) dataWrapper.Data);
          break;
        case SFSDataType.DOUBLE_ARRAY:
          buffer = BinEncode_DOUBLE_ARRAY(buffer, (double[]) dataWrapper.Data);
          break;
        case SFSDataType.UTF_STRING_ARRAY:
          buffer = BinEncode_UTF_STRING_ARRAY(buffer, (string[]) dataWrapper.Data);
          break;
        case SFSDataType.SFS_ARRAY:
          //buffer = AddData(buffer, Array2Binary((ISFSArray) dataWrapper.Data));
          buffer = Array2Binary((ISFSArray) dataWrapper.Data, buffer);
          break;
        case SFSDataType.SFS_OBJECT:
          //buffer = AddData(buffer, Object2Binary((ISFSObject) dataWrapper.Data));
          buffer = Object2Binary((ISFSObject) dataWrapper.Data, buffer);
          break;
        case SFSDataType.CLASS:
          //buffer = AddData(buffer, Object2Binary(Cs2Sfs(dataWrapper.Data)));
          buffer = Object2Binary(Cs2Sfs(dataWrapper.Data), buffer);
          break;
        case SFSDataType.TEXT:
          buffer = BinEncode_TEXT(buffer, (string) dataWrapper.Data);
          break;
        default:
          throw new SFSCodecError("Unrecognized type in SFSObject serialization: " + dataWrapper.Type);
      }
      return buffer;
    }

    private void BinDecode_TEXT(ByteArray buffer)
    {
      buffer.ReadText();
    }
    
    private void BinDecode_SHORT_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
        buffer.ReadShort();
    }

    private void BinDecode_INT_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
      {
        // buffer.ReadInt();
        buffer.SkipInt();
      }
    }

    private void BinDecode_LONG_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
      {
        //buffer.ReadLong();
        buffer.SkipLong();
      }
        
    }

    private void BinDecode_FLOAT_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
        buffer.ReadFloat();
    }

    private void BinDecode_DOUBLE_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
        buffer.ReadDouble();
    }

    private void BinDecode_UTF_STRING_ARRAY(ByteArray buffer)
    {
      int typedArraySize = GetTypedArraySize(buffer);
      for (int index = 0; index < typedArraySize; ++index)
      {
        buffer.SkipUTF();
      }
        //buffer.ReadUTF();
    }

    private int GetTypedArraySize(ByteArray buffer)
    {
      short num = buffer.ReadShort();
      if (num < 0)
        throw new SFSCodecError("Array negative size: " + num);
      return num;
    }

    public ByteArray BinEncode_NULL(ByteArray buffer)
    {
      buffer.WriteByte((byte)0);
      return buffer;
    }

    public ByteArray BinEncode_BOOL(ByteArray buffer, bool val)
    {
      buffer.WriteByte(SFSDataType.BOOL);
      buffer.WriteBool(val);
      return buffer;
    }

    public ByteArray BinEncode_BYTE(ByteArray buffer, byte val)
    {
      buffer.WriteByte(SFSDataType.BYTE);
      buffer.WriteByte(val);
      return buffer;
    }

    public ByteArray BinEncode_SHORT(ByteArray buffer, short val)
    {
      buffer.WriteByte(SFSDataType.SHORT);
      buffer.WriteShort(val);
      return buffer;
    }

    public ByteArray BinEncode_INT(ByteArray buffer, int val)
    {
      buffer.WriteByte(SFSDataType.INT);
      buffer.WriteInt(val);
      return buffer;
    }

    public ByteArray BinEncode_LONG(ByteArray buffer, long val)
    {
      buffer.WriteByte(SFSDataType.LONG);
      buffer.WriteLong(val);
      return buffer;
    }

    public ByteArray BinEncode_FLOAT(ByteArray buffer, float val)
    {
      buffer.WriteByte(SFSDataType.FLOAT);
      buffer.WriteFloat(val);
      return buffer;
    }

    public ByteArray BinEncode_DOUBLE(ByteArray buffer, double val)
    {
      buffer.WriteByte(SFSDataType.DOUBLE);
      buffer.WriteDouble(val);
      return buffer;
    }

    public ByteArray BinEncode_INT(ByteArray buffer, double val)
    {
      buffer.WriteByte(SFSDataType.DOUBLE);
      buffer.WriteDouble(val);
      return buffer;
    }

    public ByteArray BinEncode_UTF_STRING(ByteArray buffer, string val)
    {
      buffer.WriteByte(SFSDataType.UTF_STRING);
      buffer.WriteUTF(val);
      return buffer;
    }

    public ByteArray BinEncode_TEXT(ByteArray buffer, string val)
    {
      buffer.WriteByte(SFSDataType.TEXT);
      buffer.WriteText(val);
      return buffer;
    }

    public ByteArray BinEncode_BOOL_ARRAY(ByteArray buffer, bool[] val)
    {
      buffer.WriteByte(SFSDataType.BOOL_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteBool(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_BYTE_ARRAY(ByteArray buffer, ByteArray val)
    {
      buffer.WriteByte(SFSDataType.BYTE_ARRAY);
      buffer.WriteInt(val.DataLength);
      buffer.WriteBytes(val);
      return buffer;
    }

    public ByteArray BinEncode_SHORT_ARRAY(ByteArray buffer, short[] val)
    {
      buffer.WriteByte(SFSDataType.SHORT_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteShort(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_INT_ARRAY(ByteArray buffer, int[] val)
    {
      buffer.WriteByte(SFSDataType.INT_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteInt(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_LONG_ARRAY(ByteArray buffer, long[] val)
    {
      buffer.WriteByte(SFSDataType.LONG_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteLong(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_FLOAT_ARRAY(ByteArray buffer, float[] val)
    {
      buffer.WriteByte(SFSDataType.FLOAT_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteFloat(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_DOUBLE_ARRAY(ByteArray buffer, double[] val)
    {
      buffer.WriteByte(SFSDataType.DOUBLE_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteDouble(val[index]);
      }
      return buffer;
    }

    public ByteArray BinEncode_UTF_STRING_ARRAY(ByteArray buffer, string[] val)
    {
      buffer.WriteByte(SFSDataType.UTF_STRING_ARRAY);
      buffer.WriteShort(Convert.ToInt16(val.Length));
      for (int index = 0; index < val.Length; ++index)
      {
        buffer.WriteUTF(val[index]);
      }
      return buffer;
    }

    public ByteArray EncodeSFSObjectKey(ByteArray buffer, string val)
    {
      buffer.WriteUTF(val);
      return buffer;
    }

    public ByteArray AddData(ByteArray buffer, ByteArray newData)
    {
      buffer.WriteBytes(newData);
      return buffer;
    }

    public string Object2Json(Dictionary<string, object> map)
    {
      return JsonMapper.ToJson(map);
    }

    public void flattenObject(Dictionary<string, object> map, ISFSObject sfsObj)
    {
      sfsObj.Traverse((key, data)=>
      {
        if (data.Type == SFSDataType.SFS_OBJECT)
        {
          var dt = (ISFSObject) data.Data;
          var map1 = new Dictionary<string, object>(dt.Size());
          map.Add(key, map1);
          flattenObject(map1, dt);
        }
        else if (data.Type == SFSDataType.SFS_ARRAY)
        {
          var dt = (ISFSArray) data.Data;
          var list = new List<object>(dt.Size());
          map.Add(key, list);
          flattenArray(list, dt);
        }
        else
        {
          map.Add(key, data.Data);
        }
      });
      
    }

    public string Array2Json(List<object> list)
    {
      return JsonMapper.ToJson(list);
    }

    public void flattenArray(List<object> list, ISFSArray sfsArray)
    {
      for (int index = 0; index < sfsArray.Size(); ++index)
      {
        SFSDataWrapper wrappedElementAt = sfsArray.GetWrappedElementAt(index);
        if (wrappedElementAt.Type == SFSDataType.SFS_OBJECT)
        {
          Dictionary<string, object> map = new Dictionary<string, object>();
          list.Add(map);
          flattenObject(map, (ISFSObject) wrappedElementAt.Data);
        }
        else if (wrappedElementAt.Type == SFSDataType.SFS_ARRAY)
        {
          List<object> list1 = new List<object>();
          list.Add(list1);
          flattenArray(list1, (ISFSArray) wrappedElementAt.Data);
        }
        else
          list.Add(wrappedElementAt.Data);
      }
    }

    public ISFSObject Json2Object(string jsonStr)
    {
      if (jsonStr.Length < 2)
        throw new InvalidOperationException("Can't decode SFSObject: JSON String is too short. Len: " + jsonStr.Length);
      return decodeSFSObject(JsonMapper.ToObject(jsonStr));
    }

    public ISFSArray Json2Array(string jsonStr)
    {
      if (jsonStr.Length < 2)
        throw new InvalidOperationException("Can't decode SFSArray: JSON String is too short. Len: " + jsonStr.Length);
      return decodeSFSArray(JsonMapper.ToObject(jsonStr));
    }

    private ISFSObject decodeSFSObject(JsonData jdo)
    {
      ISFSObject sfsObject = SFSObjectLite.NewInstance();
      foreach (string key in jdo.Keys)
      {
        SFSDataWrapper val = decodeJsonObject(jdo[key]);
        if (val == null)
          throw new InvalidOperationException("JSON > ISFSObject error: could not decode value for key: " + key);
        sfsObject.Put(key, val);
      }
      return sfsObject;
    }

    private ISFSArray decodeSFSArray(JsonData jdo)
    {
      ISFSArray sfsArray = SFSArrayLite.NewInstance();
      for (int index = 0; index < jdo.Count; ++index)
      {
        JsonData jdo1 = jdo[index];
        SFSDataWrapper val = decodeJsonObject(jdo1);
        if (val == null)
          throw new InvalidOperationException("JSON > ISFSArray error: could not decode value for object: " + jdo1);
        sfsArray.Add(val);
      }
      return sfsArray;
    }

    private SFSDataWrapper decodeJsonObject(JsonData jdo)
    {
      if (jdo == null)
        return new SFSDataWrapper(SFSDataType.NULL, jdo);
      if (jdo.IsInt)
        return new SFSDataWrapper(SFSDataType.INT, (int) jdo);
      if (jdo.IsLong)
        return new SFSDataWrapper(SFSDataType.LONG, (long) jdo);
      if (jdo.IsDouble)
        return new SFSDataWrapper(SFSDataType.DOUBLE, (double) jdo);
      if (jdo.IsBoolean)
        return new SFSDataWrapper(SFSDataType.BOOL, (bool) jdo);
      if (jdo.IsString)
        return new SFSDataWrapper(SFSDataType.UTF_STRING, (string) jdo);
      if (jdo.IsObject)
        return jdo.Keys.Count == 0 ? new SFSDataWrapper(SFSDataType.NULL, null) : new SFSDataWrapper(SFSDataType.SFS_OBJECT, decodeSFSObject(jdo));
      if (jdo.IsArray)
        return new SFSDataWrapper(SFSDataType.SFS_ARRAY, decodeSFSArray(jdo));
      throw new ArgumentException(string.Format("Unrecognized DataType while converting JsonData object to SFSObject. Object: %s, Type: %s", jdo, jdo == null ? "null" : (object) jdo.GetType().ToString()));
    }

    public ISFSObject Cs2Sfs(object csObj)
    {
      ISFSObject sfsObj = SFSObject.NewInstance();
      ConvertCsObj(csObj, sfsObj);
      return sfsObj;
    }

    private void ConvertCsObj(object csObj, ISFSObject sfsObj)
    {
      Type type = csObj.GetType();
      string fullName = type.FullName;
      if (!(csObj is SerializableSFSType))
        throw new SFSCodecError("Cannot serialize object: " + csObj + ", type: " + fullName + " -- It doesn't implement the SerializableSFSType interface");
      ISFSArray val1 = SFSArray.NewInstance();
      sfsObj.PutUtfString(CLASS_MARKER_KEY, fullName);
      sfsObj.PutSFSArray(CLASS_FIELDS_KEY, val1);
      foreach (FieldInfo field in type.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic))
      {
        string name = field.Name;
        object val2 = field.GetValue(csObj);
        ISFSObject val3 = SFSObject.NewInstance();
        SFSDataWrapper val4 = WrapField(val2);
        if (val4 != null)
        {
          val3.PutUtfString(FIELD_NAME_KEY, name);
          val3.Put(FIELD_VALUE_KEY, val4);
          val1.AddSFSObject(val3);
        }
        else
          throw new SFSCodecError("Cannot serialize field of object: " + csObj + ", field: " + name + ", type: " + field.GetType().Name + " -- unsupported type!");
      }
    }

    private SFSDataWrapper WrapField(object val)
    {
      if (val == null)
        return new SFSDataWrapper(SFSDataType.NULL, null);
      SFSDataWrapper sfsDataWrapper = null;
      if (val is bool)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.BOOL, val);
      else if (val is byte)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.BYTE, val);
      else if (val is short)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.SHORT, val);
      else if (val is int)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.INT, val);
      else if (val is long)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.LONG, val);
      else if (val is float)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.FLOAT, val);
      else if (val is double)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.DOUBLE, val);
      else if (val is string)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.UTF_STRING, val);
      else if (val is ArrayList)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.SFS_ARRAY, UnrollArray(val as ArrayList));
      else if (val is SerializableSFSType)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.SFS_OBJECT, Cs2Sfs(val));
      else if (val is Hashtable)
        sfsDataWrapper = new SFSDataWrapper(SFSDataType.SFS_OBJECT, UnrollDictionary(val as Hashtable));
      return sfsDataWrapper;
    }

    private ISFSArray UnrollArray(ArrayList arr)
    {
      ISFSArray sfsArray = SFSArray.NewInstance();
      foreach (object val1 in arr)
      {
        SFSDataWrapper val2 = WrapField(val1);
        if (val2 == null)
          throw new SFSCodecError("Cannot serialize field of array: " + val1 + " -- unsupported type!");
        sfsArray.Add(val2);
      }
      return sfsArray;
    }

    private ISFSObject UnrollDictionary(Hashtable dict)
    {
      ISFSObject sfsObject = SFSObject.NewInstance();
      foreach (string key in dict.Keys)
      {
        SFSDataWrapper val = WrapField(dict[key]);
        if (val == null)
          throw new SFSCodecError("Cannot serialize field of dictionary with key: " + key + ", " + dict[key] + " -- unsupported type!");
        sfsObject.Put(key, val);
      }
      return sfsObject;
    }

    public object Sfs2Cs(ISFSObject sfsObj)
    {
      if (!sfsObj.ContainsKey(CLASS_MARKER_KEY) || !sfsObj.ContainsKey(CLASS_FIELDS_KEY))
        throw new SFSCodecError("The SFSObject passed does not represent any serialized class.");
      string utfString = sfsObj.GetUtfString(CLASS_MARKER_KEY);
      Type type = runningAssembly != null ? runningAssembly.GetType(utfString) : Type.GetType(utfString);
      if (type == null)
        throw new SFSCodecError("Cannot find type: " + utfString);
      object instance = Activator.CreateInstance(type);
      if (!(instance is SerializableSFSType))
        throw new SFSCodecError("Cannot deserialize object: " + instance + ", type: " + utfString + " -- It doesn't implement the SerializableSFSType interface");
      ConvertSFSObject(sfsObj.GetSFSArray(CLASS_FIELDS_KEY), instance, type);
      return instance;
    }

    private void ConvertSFSObject(ISFSArray fieldList, object csObj, Type objType)
    {
      for (int index = 0; index < fieldList.Size(); ++index)
      {
        ISFSObject sfsObject = fieldList.GetSFSObject(index);
        string utfString = sfsObject.GetUtfString(FIELD_NAME_KEY);
        object obj = UnwrapField(sfsObject.GetData(FIELD_VALUE_KEY));
        objType.GetField(utfString, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)?.SetValue(csObj, obj);
      }
    }

    private object UnwrapField(SFSDataWrapper wrapper)
    {
      object obj = null;
      int type = (int)wrapper.Type;
      if (type <= 8)
        obj = wrapper.Data;
      else if (type == 17)
        obj = RebuildArray(wrapper.Data as ISFSArray);
      else if (type == 18)
      {
        ISFSObject data = wrapper.Data as ISFSObject;
        obj = !data.ContainsKey(CLASS_MARKER_KEY) || !data.ContainsKey(CLASS_FIELDS_KEY) ? RebuildDict(wrapper.Data as ISFSObject) : Sfs2Cs(data);
      }
      else if (type == 19)
        obj = wrapper.Data;
      return obj;
    }

    private ArrayList RebuildArray(ISFSArray sfsArr)
    {
      ArrayList arrayList = new ArrayList();
      for (int index = 0; index < sfsArr.Size(); ++index)
        arrayList.Add(UnwrapField(sfsArr.GetWrappedElementAt(index)));
      return arrayList;
    }

    private Hashtable RebuildDict(ISFSObject sfsObj)
    {
      var hashtable = new Hashtable(sfsObj.Size());
      sfsObj.Traverse((key, data) =>
      {
        hashtable[key] = UnwrapField(data);
      });
      
      return hashtable;
    }
  }
}





