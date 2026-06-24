using System;
using System.Collections.Generic;
using System.Buffers.Binary;
using System.Collections.Concurrent;
using System.Text;
using Sfs2X.Entities.Data;
using UnityEngine;

namespace Sfs2X.Util
{
  public class ByteArray
  {
    //仅适用于替换函数内局部变量使用 这样不用每次从池里取和回收
    // 这个地方要注意，因为Read和Write是两个线程，所以这里是单独给这两个线程分别一个独立的buffer
    // 维护的时候一定要注意线程并发的问题
    
    [ThreadStatic] private static byte[] _readTempBuff;
    [ThreadStatic] private static byte[] _writeTempBuff;
    [ThreadStatic] private static char[] _tempChars;
    [ThreadStatic] private static Dictionary<int, string> _bToSCache;
    
    //上面变量在子线程第一次访问时是默认值null 通过一个属性去包装下进行初始化
    private static byte[] ReadTempBuff => _readTempBuff ?? (_readTempBuff = new byte[16]);
    private static byte[] WriteTempBuff => _writeTempBuff ?? (_writeTempBuff = new byte[16]);
    private static char[] TempChars
    {
      get => _tempChars ?? (_tempChars = new char[80]);
      set => _tempChars = value;
    }

    private static Dictionary<int, string> BToSCache => _bToSCache ?? (_bToSCache = new Dictionary<int, string>(128));

    
    private int _position;
    private bool _compressed;
    private byte[] _buffer;
    private int _realDataLength;     //真实数据长度

    #if UNITY_EDITOR
    public int UniqueNo;
    #endif
    
    public int DataLength
    {
      get => _realDataLength;
      set => _realDataLength = value;  // 这个函数不要轻易调用，除非你知道自己在做什么
    } 

    public int Position
    {
      get => _position;
      set => _position = value;
    }

    public int BytesAvailable
    {
      get
      {
        int num = DataLength - _position;
        if (num > DataLength || num < 0)
          num = 0;
        return num;
      }
    }

    public bool Compressed
    {
      get => _compressed;
      set => _compressed = value;
    }

    public ByteArray()
    {
        _buffer = new byte[128];
        _realDataLength = 0;
    }

    public ByteArray(int dataLen)
    {
      var len = Mathf.CeilToInt(dataLen / 128.0f) * 128;
      _buffer = new byte[len];
      _realDataLength = 0;
    }
    
    public ByteArray(byte[] buf)
    {
        // 如果是直接赋值的话，这里直接赋值成传入的byte[]，并且直接使用 
        _buffer = buf;
        _realDataLength = buf.Length;
    }
    
    public ByteArray(byte[] buf, int ofs, int length)
    {
        _buffer = new byte[length];
        Buffer.BlockCopy(buf, 0, _buffer, 0, length);
        _realDataLength = length;
    }

    public void Reset()
    {
      _position = 0;
      _compressed = false;
      _realDataLength = 0;
    }
    
    public void SetData(byte[] buf, int ofs, int length)
    {
      if (_buffer.Length < length)
      {
        var len = Mathf.CeilToInt(length / 128.0f) * 128;
        _buffer = new byte[len];
      }
      
      Buffer.BlockCopy(buf, 0, _buffer, 0, length);
      _realDataLength = length;
    }
    
    public byte GetByte(int index)
    {
        if (index < 0 || index >= DataLength)
        {
            throw new ArgumentException($"index error! index:{index}");
        }

        return _buffer[index];
    }

    /// <summary>
    /// 仅限smartfox内部使用来避免频繁gc
    /// </summary>
    /// <returns></returns>
    public byte[] GetRawBytes()
    {
        return _buffer;
    }
    
    public byte[] GetBytes()
    {
        var dst = new byte[DataLength];
        Buffer.BlockCopy(_buffer, 0, dst, 0, DataLength);
        return dst;
    }
    
    
    public void Compress()
    {
      if (_compressed)
      {
        throw new Exception("Buffer is already compressed");
      }
      
#if false
      var memoryStream = new MemoryStream();
      using (var zoutputStream = new ZOutputStream(memoryStream, 9))
      {
        zoutputStream.Write(_buffer, 0, DataLength);
        zoutputStream.Flush();
      }

      memoryStream.TryGetBuffer(out var outBuf);
      //检查当前_buffer是否够容纳解压后的数据
      if (_buffer.Length < outBuf.Count)
      {
        _buffer = new byte[Mathf.CeilToInt(outBuf.Count/128.0f) * 128];
      }
      
      Buffer.BlockCopy(outBuf.Array ?? throw new InvalidOperationException(), outBuf.Offset, _buffer, 0, outBuf.Count);
      _realDataLength = outBuf.Count;
#else
      var reserveLen = XLua.LuaDLL.Lua.ZLibCompressBound(DataLength);
      var dstBuf = ArrayPoolHelper.SpawnByteArrayFromPool(reserveLen + 64);
      int level = 9;
      // 如果小于256，那么就不要使用最大压缩了，没必要。发送1字节和发送512字节区别不大。
      if (reserveLen < 256)
      {
        level = 1;
      }
      
      var dstLen = XLua.LuaDLL.Lua.ZLibCompress(_buffer, DataLength, dstBuf, dstBuf.Length, level);
      if (dstLen == -1)
      {
        ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
        throw new Exception("ByteArray Compress Native Error [1]!");
      }

      if (_buffer.Length < dstLen)
      {
        _buffer = new byte[dstLen];
      }
      Buffer.BlockCopy(dstBuf, 0, _buffer, 0, dstLen);
      _realDataLength = dstLen;
      ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
#endif
      
      _position = 0;
      _compressed = true;
    }

    public void Uncompress()
    {
#if false
      var memoryStream = new MemoryStream();
      using (var zoutputStream = new ZOutputStream(memoryStream))
      {
        zoutputStream.Write(_buffer, 0, DataLength);
        zoutputStream.Flush();
      }
      
      memoryStream.TryGetBuffer(out var outBuf);
      //检查当前_buffer是否够容纳解压后的数据
      if (_buffer.Length < outBuf.Count)
      {
        _buffer = new byte[Mathf.CeilToInt(outBuf.Count/128.0f) * 128];
      }
      
      Buffer.BlockCopy(outBuf.Array ?? throw new InvalidOperationException(), outBuf.Offset, _buffer, 0, outBuf.Count);
      _realDataLength = outBuf.Count;
#else

      int dstLen = -1;
      var reserveLen = _realDataLength * 4;
      if (reserveLen < 2048)
      {
        reserveLen = 2048; // 尽量第一次就分配够
      }
      byte[] dstBuf = ArrayPoolHelper.SpawnByteArrayFromPool(reserveLen);
      for (var i = 0; i < 10; i++)
      {
          dstLen = XLua.LuaDLL.Lua.ZLibUnCompress( _buffer, DataLength, dstBuf, dstBuf.Length);
          if (dstLen != -1)
          {
            break;
          }
          
          ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
          reserveLen *= 2;
          dstBuf = ArrayPoolHelper.SpawnByteArrayFromPool(reserveLen);
      }

      if (dstLen == -1)
      {
          ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
          Debug.LogError("ByteArray UnCompress Native Error!");
          return;
      }
      
      if (_buffer.Length < dstLen)
      {
        _buffer = new byte[dstLen];
      }

      try
      {
        //Offset and length were out of bounds for the array or count is greater than the number of elements from index to the end of the source collection
        Buffer.BlockCopy(dstBuf, 0, _buffer, 0, dstLen);
      }
      catch (Exception e)
      {
        ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
        Console.WriteLine(e);
        throw;
      }
      
      _realDataLength = dstLen;
      ArrayPoolHelper.RecycleByteArrayToPool(dstBuf);
#endif
      
      
      _position = 0;
      _compressed = false;
    }

    private void CheckCompressedWrite()
    {
      if (_compressed)
        throw new Exception("Only raw bytes can be written to a compressed array. Call Uncompress first.");
    }

    private void CheckCompressedRead()
    {
      if (_compressed)
        throw new Exception("Only raw bytes can be read from a compressed array.");
    }

    private static byte[] ReverseOrder(byte[] buff, int len = -1)
    {
      if (!BitConverter.IsLittleEndian)
        return buff;
      
      int length = len == -1 ? buff.Length : len;
          
      if (length < 2)
        return buff;
      int num1 = length / 2;
      for (int index1 = 0; index1 < num1; ++index1)
      {
        byte num2 = buff[index1];
        int index2 = length - index1 - 1;
        buff[index1] = buff[index2];
        buff[index2] = num2;
      }
      return buff;
    }

    public void Clear()
    {
        //_buffer = new byte[128];
        _realDataLength = 0;
        _position = 0;
    }
    
    public void WriteByte(SFSDataType tp)
    {
        WriteByte(Convert.ToByte((int) tp));
    }

    public void WriteByte(byte b)
    {
        WriteTempBuff[0] = b;
        WriteBytes(WriteTempBuff, 0, 1);
    }
    
    public void WriteBytes(byte[] data)
    {
      WriteBytes(data, 0, data.Length);
    }

    public void WriteBytes(byte[] data, int ofs, int length)
    {
      var dstLen = DataLength + length;
      if (_buffer.Length < dstLen)
      {
          var len = Mathf.CeilToInt(dstLen / 128.0f) * 128;
          var newBuffer = new byte[len];
          Buffer.BlockCopy(_buffer, 0, newBuffer, 0, DataLength);
          _buffer = newBuffer;
      }
      
      //将新的数据追加到原buffer中
      Buffer.BlockCopy(data, ofs, _buffer, DataLength, length);
      _realDataLength = dstLen;
    }

    public void WriteBytes(ByteArray other)
    {
        WriteBytes(other.GetRawBytes(), 0, other.DataLength);
    }
    
    public void WriteBool(bool b)
    {
      CheckCompressedWrite();
      WriteByte(b ? (byte) 1 : (byte) 0);
    }

    public void WriteInt(int i)
    {
      CheckCompressedWrite();
      
      const int size = sizeof(int);
      BinaryPrimitives.TryWriteInt32BigEndian(WriteTempBuff, i);
      WriteBytes(WriteTempBuff, 0, size);
    }

    public void WriteUShort(ushort us)
    {
      CheckCompressedWrite();
      
      const int size = sizeof(ushort);
      BinaryPrimitives.TryWriteUInt16BigEndian(WriteTempBuff, us);
      WriteBytes(WriteTempBuff, 0, size);
    }

    public void WriteShort(short s)
    {
      CheckCompressedWrite();
      
      const int size = sizeof(short);
      BinaryPrimitives.TryWriteInt16BigEndian(WriteTempBuff, s);
      WriteBytes(WriteTempBuff, 0, size);
    }

    public void WriteLong(long l)
    {
      CheckCompressedWrite();
      
      const int size = sizeof(long);
      BinaryPrimitives.TryWriteInt64BigEndian(WriteTempBuff, l);
      WriteBytes(WriteTempBuff, 0, size);
    }

    public void WriteFloat(float f)
    {
      CheckCompressedWrite();
      var buf = ReverseOrder(BitConverter.GetBytes(f));
      WriteBytes(buf, 0, buf.Length);

      //unsafe edition
      // const int size = sizeof(float);
      // var val = *(int*)&f;
      // BinaryPrimitives.TryWriteInt32BigEndian(TempBytes, val);
      // WriteBytes(TempBytes, 0, size);
    }
    
    public void WriteDouble(double d)
    {
        CheckCompressedWrite();
        var buf = ReverseOrder(BitConverter.GetBytes(d));
        WriteBytes(buf, 0, buf.Length);
  
        //unsafe edition
        // const int size = sizeof(double);
        // var val = *(long*)&d;
        // BinaryPrimitives.TryWriteInt64BigEndian(TempBytes, val);
        // WriteBytes(TempBytes, 0, size);
    }

    private int GetByteCount(string str)
    {
        var strLen = str.Length;
        if (TempChars.Length < strLen)
        {
            TempChars = new char[strLen];
        }
        str.CopyTo(0, TempChars, 0, strLen);
        var byteCount = Encoding.UTF8.GetByteCount(TempChars, 0, strLen);
        return byteCount;
    }
    
    public void WriteUTF(string str)
    {
        CheckCompressedWrite();
        
        var byteCount = GetByteCount(str);
        if (byteCount > short.MaxValue)
        {
            throw new FormatException("String length cannot be greater than " + short.MaxValue + " bytes!");
        }
        WriteUShort(Convert.ToUInt16(byteCount));
        var dstLen = _realDataLength + byteCount;
        if (_buffer.Length < dstLen)
        {
            var len = Mathf.CeilToInt(dstLen / 128.0f) * 128;
            var newBuffer = new byte[len];
            Buffer.BlockCopy(_buffer, 0, newBuffer, 0, _realDataLength);
            _buffer = newBuffer;
        }
        
        Encoding.UTF8.GetBytes(str, 0, str.Length, _buffer, _realDataLength);
        _realDataLength = dstLen;

    }

    public void WriteText(string str)
    {
      CheckCompressedWrite();

      byte[] bytes = Encoding.UTF8.GetBytes(str);
      WriteInt(bytes.Length);
      WriteBytes(bytes, 0, bytes.Length);
    }

    public byte ReadByte()
    {
      CheckCompressedRead();
      return _buffer[_position++];
    }
    
    public byte[] ReadBytes(int count)
    {
      byte[] numArray = new byte[count];
      Buffer.BlockCopy(_buffer, _position, numArray, 0, count);
      _position += count;
      return numArray;
    }

    public void ReadBytes(byte[] dst, int count)
    {
      if (dst.Length < count)
        throw new ArgumentException("dst length small than count!");
      
      Buffer.BlockCopy(_buffer, _position, dst, 0, count);
      _position += count;
    }

    public bool ReadBool()
    {
      CheckCompressedRead();
      return _buffer[_position++] == 1;
    }

    public int ReadInt()
    {
      CheckCompressedRead();
      
      const int len = sizeof(int);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToInt32(ReverseOrder(ReadTempBuff, len), 0);
    }

    public ushort ReadUShort()
    {
      CheckCompressedRead();
      
      const int len = sizeof(ushort);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToUInt16(ReverseOrder(ReadTempBuff, len), 0);
    }

    public short ReadShort()
    {
      CheckCompressedRead();
      
      const int len = sizeof(short);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToInt16(ReverseOrder(ReadTempBuff, len), 0);
    }

    public long ReadLong()
    {
      CheckCompressedRead();
      
      const int len = sizeof(long);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToInt64(ReverseOrder(ReadTempBuff, len), 0);
    }

    public float ReadFloat()
    {
      CheckCompressedRead();
      
      const int len = sizeof(float);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToSingle(ReverseOrder(ReadTempBuff, len), 0);
    }

    public double ReadDouble()
    {
      CheckCompressedRead();
      
      const int len = sizeof(double);
      ReadBytes(ReadTempBuff, len);
      return BitConverter.ToDouble(ReverseOrder(ReadTempBuff, len), 0);
    }

    public string ReadUTF()
    {
        CheckCompressedRead();
        ushort num = ReadUShort();

        //test
        if (_position + num > DataLength)
        {
            int a = 1;
        }
        
        var key = -1;
        if (num <= 4)
        {
            //将需要用的空间先擦除
            Array.Clear(ReadTempBuff, 0, 4);
            Buffer.BlockCopy(_buffer, _position, ReadTempBuff, 0, num);
            key = BitConverter.ToInt32(ReadTempBuff, 0); //ReverseOrder(TempBytes, num),

            if (BToSCache.TryGetValue(key, out var ss))
            {
                _position += num;
                return ss;
            }
        }

        string str = Encoding.UTF8.GetString(_buffer, _position, num);
        if (num <= 4)
        {
            BToSCache.Add(key, str);
        }

        _position += num;
        return str;
    }

    public string ReadText()
    {
        CheckCompressedRead();
        int count = ReadInt();
        string str = Encoding.UTF8.GetString(_buffer, _position, count);
        _position += count;
        return str;
    }
    
    // 直接跳过字符串
    public void SkipUTF()
    {
      CheckCompressedRead();
      ushort num = ReadUShort();
      _position += num;
    }
    
    public void SkipInt()
    {
      CheckCompressedRead();
      
      const int len = sizeof(int);
      _position += len;
    }

    public void SkipLong()
    {
      CheckCompressedRead();
      
      const int len = sizeof(long);
      _position += len;
    }
  }



  //加一个对象池 来减少GC消耗
  public static class ByteArrayPool
  {
      private static readonly ConcurrentBag<ByteArray> Pool = new ConcurrentBag<ByteArray>();
      public static ByteArray Rent(int size = 128)
      {
#if UNITY_EDITOR
          //Debug.Log($"#ByteArrayPool# Rent size:{size}, current count:{_pool.Count}");
#endif
        
          if (Pool.TryTake(out var item))
          {
              item.Reset();
              return item;
          }

          return new ByteArray(size);
      }

      public static void Recycle(ByteArray b)
      {
        // 如果数量太多的话，就不放到池了，让gc
          if (Pool.Count > 30)
          {
              Debug.Log($"#ByteArrayPool# pool's count exceeded 50 !");
              return;
          }

          if (b.GetRawBytes().Length > 8192)
          {
            Debug.Log($"Length too big!");
            return;
          }
        
          Pool.Add(b);
      }
      
  }
}





