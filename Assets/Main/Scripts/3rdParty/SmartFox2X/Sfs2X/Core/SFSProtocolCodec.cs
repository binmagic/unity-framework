using System;
using Sfs2X.Bitswarm;
using Sfs2X.Entities.Data;
using Sfs2X.Exceptions;
using Sfs2X.Protocol;
using Sfs2X.Protocol.Serialization;
using Sfs2X.Util;
using UnityEngine;
using Logger = Sfs2X.Logging.Logger;

namespace Sfs2X.Core
{
  public class SFSProtocolCodec : IProtocolCodec
  {
    private static readonly string CONTROLLER_ID = "c";
    private static readonly string ACTION_ID = "a";
    private static readonly string PARAM_ID = "p";
    private static readonly string USER_ID = "u";
    private static readonly string UDP_PACKET_ID = "i";
    private IoHandler ioHandler;
    private Logger log;
    private ISocketClient bitSwarm;

    public IoHandler IOHandler
    {
      get
      {
        return ioHandler;
      }
      set
      {
        if (ioHandler != null)
          throw new SFSError("IOHandler is already defined for thir ProtocolHandler instance: " + this);
        ioHandler = value;
      }
    }

    public SFSProtocolCodec(IoHandler ioHandler, ISocketClient bitSwarm)
    {
      this.ioHandler = ioHandler;
      log = bitSwarm.Log;
      this.bitSwarm = bitSwarm;
    }

    public void OnPacketRead(ByteArray packet)
    {
#if false
      Debug.LogError($"#zlh# OnPacketRead: buffer:{ConvertExt.ToHexString(packet.GetBytes())}");
      var sfs = SFSObject.NewFromBinaryData(packet);
      Debug.LogError($"#zlh# OnPacketRead: sfs:{sfs.ToJson()}");
      DispatchRequest(sfs);
#else
      DispatchRequest(packet);
#endif
    }

    public void OnPacketRead(ISFSObject packet)
    {
      DispatchRequest(packet);
    }

    public void OnPacketWrite(IMessage message)
    {
      if (bitSwarm.Debug)
      {
        log.Debug("Writing message " + message.Content.GetHexDump());
      }
      
      var sfsObject = PrepareTCPPacket(message);
      message.Content = sfsObject;
      ioHandler.OnDataWrite(message);
    }
    
    public void OnPacketWrite(byte[] data, int dataLen)
    {
      ioHandler.OnDataWrite(data, dataLen);
    }

    private ISFSObject PrepareTCPPacket(IMessage message)
    {
      ISFSObject sfsObject = new SFSObject();
      sfsObject.PutByte(CONTROLLER_ID, Convert.ToByte(message.TargetController));
      sfsObject.PutShort(ACTION_ID, Convert.ToInt16(message.Id));
      sfsObject.PutSFSObject(PARAM_ID, message.Content);
      return sfsObject;
    }

    private void DispatchRequest(ISFSObject requestObject)
    {
      IMessage message = new Message();
      if (requestObject.IsNull(CONTROLLER_ID))
        throw new SFSCodecError("Request rejected: No Controller ID in request!");
      if (requestObject.IsNull(ACTION_ID))
        throw new SFSCodecError("Request rejected: No Action ID in request!");
      message.Id = Convert.ToInt32(requestObject.GetShort(ACTION_ID));
      message.Content = requestObject.GetSFSObject(PARAM_ID);
      message.IsUDP = requestObject.ContainsKey(UDP_PACKET_ID);
      if (message.IsUDP)
        message.PacketId = requestObject.GetLong(UDP_PACKET_ID);
      int id = requestObject.GetByte(CONTROLLER_ID);
      IController controller = bitSwarm.GetController(id);
      if (controller == null)
        throw new SFSError("Cannot handle server response. Unknown controller, id: " + id);
      controller.HandleMessage(message);
    }

    private void DispatchRequest(ByteArray requestBuff)
    {
      
#if UNITY_EDITOR
      // 消息调试打印
      // var obj = SFSObject.NewFromBinaryData(requestBuff);
      // string dump = obj.GetDump(true);
      // UnityEngine.Debug.LogErrorFormat("dump : {0}", dump);
#endif
      
      var cmdId = UnrealDefaultSFSDataSerializer.Instance.DecodeSFSObject_CmdID(requestBuff);
      if (cmdId == null)
      {
        // 非应用层消息，直接冗余处理吧
        DispatchRequest(SFSObject.NewFromBinaryData(requestBuff));
        return;
      }
      
      // 游戏内逻辑消息处理，直接调用处理，不去转临时结构了
      Controllers.ExtensionController controller = bitSwarm.GetController(1) as Controllers.ExtensionController;
      if (controller != null)
      {
         controller.HandleExtensionResponse(cmdId, requestBuff);
      }

      // if (true)
      // {
      //   IMessage message = new Message();
      //   if (requestObject.IsNull(CONTROLLER_ID))
      //     throw new SFSCodecError("Request rejected: No Controller ID in request!");
      //
      //   if (requestObject.IsNull(ACTION_ID))
      //     throw new SFSCodecError("Request rejected: No Action ID in request!");
      //
      //   message.Id = Convert.ToInt32(requestObject.GetShort(ACTION_ID));
      //   message.Header = requestObject;
      //   message.RawData = requestBuff;
      //
      //   message.IsUDP = false;
      //   int id = requestObject.GetByte(CONTROLLER_ID);
      //   IController controller = bitSwarm.GetController(id);
      //   if (controller == null)
      //     throw new SFSError("Cannot handle server response. Unknown controller, id: " + id);
      //
      //   controller.HandleMessage(message);
      // }

    }
  }
}





