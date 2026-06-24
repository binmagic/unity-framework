using System;
using System.Threading;
using GameFramework;
using Sfs2X.Bitswarm;
using Sfs2X.Exceptions;
using Sfs2X.FSM;
using Sfs2X.Protocol;
using Sfs2X.Protocol.Serialization;
using Sfs2X.Util;
using UnityEngine;
using UnityEngine.PlayerLoop;
using UnityEngine.Profiling;
using Logger = Sfs2X.Logging.Logger;

namespace Sfs2X.Core
{
  public class SFSIOHandler : IoHandler
  {
    public static readonly int SHORT_BYTE_SIZE = 2;
    public static readonly int INT_BYTE_SIZE = 4;
    private int skipBytes;
    private BitSwarmClient bitSwarm;
    private Logger log;
    private PendingPacket pendingPacket = new PendingPacket();
    private IProtocolCodec protocolCodec;
    private IPacketEncrypter packetEncrypter;
    private FiniteStateMachine fsm;

    private readonly ByteArray _arrayForSend = new ByteArray();
    private readonly ByteArray _tempArray = new ByteArray();
    
    public IProtocolCodec Codec
    {
      get
      {
        return protocolCodec;
      }
    }

    private PacketReadState ReadState
    {
      get
      {
        return (PacketReadState) fsm.GetCurrentState();
      }
    }

    public SFSIOHandler(ISocketClient bitSwarm)
    {
      this.bitSwarm = bitSwarm as BitSwarmClient;
      log = bitSwarm.Log;
      //packetEncrypter = new DefaultPacketEncrypter(this.bitSwarm);
      protocolCodec = new SFSProtocolCodec(this, bitSwarm);
      InitStates();
    }

    private void InitStates()
    {
      fsm = new FiniteStateMachine();
      fsm.AddAllStates(typeof (PacketReadState));
      fsm.AddStateTransition((int)PacketReadState.WAIT_NEW_PACKET, (int)PacketReadState.WAIT_DATA_SIZE, (int)PacketReadTransition.HeaderReceived);
      fsm.AddStateTransition((int)PacketReadState.WAIT_DATA_SIZE, (int)PacketReadState.WAIT_DATA, (int)PacketReadTransition.SizeReceived);
      fsm.AddStateTransition((int)PacketReadState.WAIT_DATA_SIZE, (int)PacketReadState.WAIT_DATA_SIZE_FRAGMENT, (int)PacketReadTransition.IncompleteSize);
      fsm.AddStateTransition((int)PacketReadState.WAIT_DATA_SIZE_FRAGMENT, (int)PacketReadState.WAIT_DATA, (int)PacketReadTransition.WholeSizeReceived);
      fsm.AddStateTransition((int)PacketReadState.WAIT_DATA, (int)PacketReadState.WAIT_NEW_PACKET, (int)PacketReadTransition.PacketFinished);
      fsm.AddStateTransition((int)PacketReadState.WAIT_DATA, (int)PacketReadState.INVALID_DATA, (int)PacketReadTransition.InvalidData);
      fsm.AddStateTransition((int)PacketReadState.INVALID_DATA, (int)PacketReadState.WAIT_NEW_PACKET, (int)PacketReadTransition.InvalidDataFinished);
      fsm.SetCurrentState((int)PacketReadState.WAIT_NEW_PACKET);
    }

    public void OnDataRead(ByteArray array)
    {
      //_arrayForRead.Clear();
      //_arrayForRead.WriteBytes(buf, 0, buf.Length);
      
      if (array.DataLength == 0)
        throw new SFSError("Unexpected empty packet data: no readable bytes available!");
      if (bitSwarm != null && bitSwarm.Sfs.Debug)
      {
        if (array.DataLength > 1024)
          log.Info("Data Read: Size > 1024, dump omitted");
        else
          log.Info("Data Read: " + DefaultObjectDumpFormatter.HexDump(array));
      }
      array.Position = 0;
      
      //1. WAIT_NEW_PACKET: start a brand new packet constructions
      //2. WAIT_DATA_SIZE: waiting for the DATA_SIZE field to come next
      //3. WAIT_DATA_SIZE_FRAGMENT: handle DATA_SIZE field fragmentation, if it didn't come through all at once
      //4. WAIT_DATA: handle the DATA field until DATA_SIZE(or more)is reached.
      while (array.DataLength > 0)
      {
        if (ReadState == PacketReadState.WAIT_NEW_PACKET)
          array = HandleNewPacket(array);
        else if (ReadState == PacketReadState.WAIT_DATA_SIZE)
          array = HandleDataSize(array);
        else if (ReadState == PacketReadState.WAIT_DATA_SIZE_FRAGMENT)
          array = HandleDataSizeFragment(array);
        else if (ReadState == PacketReadState.WAIT_DATA)
          array = HandlePacketData(array);
        else if (ReadState == PacketReadState.INVALID_DATA)
          array = HandleInvalidData(array);
      }
    }

    public void OnDataRead(string jsonData)
    {
    }

    private ByteArray HandleNewPacket(ByteArray data)
    {
      if(bitSwarm.Debug)
        log.Debug("Handling New Packet of size " + (object) data.DataLength);
      
      byte num = data.ReadByte();
      if (~(num & 128) > 0)
      {
        throw new SFSError("Unexpected header byte: " + num + "\n" + DefaultObjectDumpFormatter.HexDump(data));
      }
      
      //pendingPacket = new PendingPacket(PacketHeader.FromBinary(num));
      
      // 这里每次接收新包，会生成一个新的
      // FIXME: 这个缓冲暂时不修改成pool，因为传递的比较远，同时跨越了线程。防止出问题吧，所以每次new一个
      pendingPacket.Header = PacketHeader.FromBinary(num);
      pendingPacket.Buffer = new ByteArray();
      //pendingPacket.Buffer.Clear();
      
      fsm.ApplyTransition((int)PacketReadTransition.HeaderReceived);
      return ResizeByteArray(data, 1, data.DataLength - 1);
    }

    private ByteArray HandleDataSize(ByteArray data)
    {
      if(bitSwarm.Debug)
        log.Debug("Handling Header Size. Length: " + (object) data.DataLength + " (" + (pendingPacket.Header.BigSized ? (object) "big" : (object) "small") + ")");
  
      int num = -1;
      int pos = SHORT_BYTE_SIZE;
      if (pendingPacket.Header.BigSized)
      {
        if (data.DataLength >= INT_BYTE_SIZE)
          num = data.ReadInt();
        pos = 4;
      }
      else if (data.DataLength >= SHORT_BYTE_SIZE)
      {
        num = data.ReadUShort();
      }
      
      if(bitSwarm.Debug)
        log.Debug("Data size is " + (object) num);

      if (num != -1)
      {
        //pendingPacket.Header.ExpectedLength = num;
        var header = pendingPacket.Header;
        header.ExpectedLength = num;
        pendingPacket.Header = header;
        
        data = ResizeByteArray(data, pos, data.DataLength - pos);
        fsm.ApplyTransition((int)PacketReadTransition.SizeReceived);
      }
      else
      {
        fsm.ApplyTransition((int)PacketReadTransition.IncompleteSize);
        pendingPacket.Buffer.WriteBytes(data);
        //data = EMPTY_BUFFER;
        data.Clear();
      }
      return data;
    }

    private ByteArray HandleDataSizeFragment(ByteArray data)
    {
      if(bitSwarm.Debug)
        log.Debug("Handling Size fragment. Data: " + (object) data.DataLength);

      int leftSpace = pendingPacket.Header.BigSized ? INT_BYTE_SIZE - pendingPacket.Buffer.DataLength : SHORT_BYTE_SIZE - pendingPacket.Buffer.DataLength;

      //如果pendingPacket中用来表示数据长度的字节还没写满 且data.DataLength小于剩余空间 则直接继续写
      if (data.DataLength < leftSpace)
      {
        pendingPacket.Buffer.WriteBytes(data);
        data.Clear();
        return data;
      }

      //如果新来的数据能直接写满pendingPacket中用来表示数据长度的字节
      //则追加到pendingPacket.Buffer 之后读出pendingPacket.Buffer中对应字节<==>dataSize 存放到pendingPacket.Header.ExpectedLength字段中
      //之后清空pendingPacket.Buffer 同时清除data中已处理的这些用来表示数据长度的字节
      
      pendingPacket.Buffer.WriteBytes(data.GetRawBytes(), 0, leftSpace);
      int count = pendingPacket.Header.BigSized ? 4 : 2;
      
      //这里应该只是想要读出dataSize 理论上直接将pendingPacket.Buffer position置0 直接读就行
      _tempArray.Clear();
      _tempArray.WriteBytes(pendingPacket.Buffer.GetRawBytes(), 0, count);
      _tempArray.Position = 0;//这行看似不必要
      int dataSize = pendingPacket.Header.BigSized ? _tempArray.ReadInt() : _tempArray.ReadShort();

      if(bitSwarm.Debug)
        log.Debug("DataSize is ready: " + (object) dataSize + " bytes");
      
      var header = pendingPacket.Header;
      header.ExpectedLength = dataSize;
      pendingPacket.Header = header;
      
      pendingPacket.Buffer.Clear();
      fsm.ApplyTransition((int)PacketReadTransition.WholeSizeReceived);
      
      //Remove bytes that were analyzed
      if (data.DataLength == leftSpace)
      {
        data.Clear();
      }
      else
      {
        //把data中剩余的数据拷贝到一个新的byteArray中 (相当于从data中把上面解析过的[0,leftSpace)区间的数据移除了)
        data = ResizeByteArray(data, leftSpace, data.DataLength - leftSpace);
      }
      
      return data;
    }

    private ByteArray HandlePacketData(ByteArray data)
    {
      int leftSpace = pendingPacket.Header.ExpectedLength - pendingPacket.Buffer.DataLength;
      bool flag = data.DataLength > leftSpace;
      try
      {
        if(bitSwarm.Debug)
          log.Debug("Handling Data: " + (object) data.DataLength + ", previous state: " + (object) pendingPacket.Buffer.DataLength + "/" + (object) pendingPacket.Header.ExpectedLength);
        
        if (data.DataLength >= leftSpace)
        {
          pendingPacket.Buffer.WriteBytes(data.GetRawBytes(), 0, leftSpace);
          log.Debug("<<< Packet Complete >>>");
          
          if (pendingPacket.Header.Encrypted)
            packetEncrypter.Decrypt(pendingPacket.Buffer);
          
          if (pendingPacket.Header.Compressed)
            pendingPacket.Buffer.Uncompress();
          
          protocolCodec.OnPacketRead(pendingPacket.Buffer);
          fsm.ApplyTransition((int)PacketReadTransition.PacketFinished);
        }
        else
        {
          pendingPacket.Buffer.WriteBytes(data);
        }
        
        //data = !flag ? EMPTY_BUFFER : ResizeByteArray(data, num, data.DataLength - num);
        if (!flag)
        {
          data.Clear();
        }
        else
        {
          data = ResizeByteArray(data, leftSpace, data.DataLength - leftSpace);
        }
      }
      catch (Exception ex)
      {
        log.Error("Error handling data: " + ex.Message + " " + ex.StackTrace);

        skipBytes = leftSpace;
        fsm.ApplyTransition((int) PacketReadTransition.InvalidData);
          
        return data;
      }
      
      return data;
    }

    private ByteArray HandleInvalidData(ByteArray data)
    {
      if (skipBytes == 0)
      {
        fsm.ApplyTransition((int)PacketReadTransition.InvalidDataFinished);
        return data;
      }
      int pos = Math.Min(data.DataLength, skipBytes);
      data = ResizeByteArray(data, pos, data.DataLength - pos);
      skipBytes -= pos;
      return data;
    }

    //这个函数作用就只是把array中[0, pos)区间的数据擦除了 更像是SubArray
    private ByteArray ResizeByteArray(ByteArray array, int pos, int len)
    {
      // 创建一个新的数组来存储调整大小后的数据；写这个主要是防止内存重叠区域的BlockCopy
      var buf = ArrayPoolHelper.SpawnByteArrayFromPool(len);
        
      // 复制数据到新数组
      Buffer.BlockCopy(array.GetRawBytes(), pos, buf, 0, len);
        
      // 清空原始数组并写入新数据
      array.Clear();
      array.WriteBytes(buf, 0, len);
        
      // 回收临时数组到对象池
      ArrayPoolHelper.RecycleByteArrayToPool(buf);
      return array;
    }

    private void WriteBinaryData(PacketHeader header, byte[] Data, int DataLength)
    {
      _arrayForSend.Clear();

      _arrayForSend.WriteByte(header.Encode());
      if (header.BigSized)
      {
        _arrayForSend.WriteInt(DataLength);
      }
      else
      {
        _arrayForSend.WriteUShort(Convert.ToUInt16(DataLength));
      }
      
      _arrayForSend.WriteBytes(Data, 0, DataLength);
      
      if (!bitSwarm.Socket.IsConnected)
        return;
      
      WriteTCP(_arrayForSend);
    }

    public void OnDataWrite(IMessage message)
    {
      ByteArray binary = null;
      try
      {
        // 从对象池租借一个 ByteArray 对象
        binary = ByteArrayPool.Rent();
        message.Content.ToBinary(binary);

        OnDataWrite(binary.GetRawBytes(), binary.DataLength);
      }
      catch (Exception e)
      {
        UnityEngine.Debug.LogErrorFormat("OnDataWrite Message Expection: {0}", e.Message);
      }
      finally
      {
        if (binary != null)
        {
          ByteArrayPool.Recycle(binary);
        }
      }
    }

    // 我们必须保证发送数据就在一个线程中，之前的代码使用的是 ArrayPool<byte>.Shared.Rent
    // 后来考虑我们只在一个线程中处理，就直接使用全局数组了
    // 目前只有第一个登录握手消息是在其他线程中发送的。
    public void OnDataWrite(byte[] data, int dataLen)
    {
      int DataLength = dataLen;

      bool compressed = false; //binary.DataLength > bitSwarm.CompressionThreshold;
      //bool encrypted = bitSwarm.CryptoKey != null && !bitSwarm.IsReconnecting;
      
      if (DataLength > bitSwarm.MaxMessageSize)
      {
        log.Error("Message size is too big: " + DataLength + ", the server limit is: " + bitSwarm.MaxMessageSize);
        return;
      }
      
      int num = SHORT_BYTE_SIZE;
      if (DataLength > ushort.MaxValue)
        num = INT_BYTE_SIZE;
      
      PacketHeader header = new PacketHeader(false, compressed, num == INT_BYTE_SIZE);
      
      // 如果是异步，则直接发送
      WriteBinaryData(header, data, DataLength);
    }

    private void WriteTCP(ByteArray writeBuffer)
    {
      bitSwarm.Socket.Write(writeBuffer.GetRawBytes(), 0, writeBuffer.DataLength);
    }

    // private void WriteUDP(ByteArray writeBuffer)
    // {
    //   bitSwarm.UdpManager.Send(writeBuffer, 0, writeBuffer.DataLength);
    // }
  }
}





