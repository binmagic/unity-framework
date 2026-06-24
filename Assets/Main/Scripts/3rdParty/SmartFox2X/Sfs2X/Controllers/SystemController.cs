using System.Collections;
using System.Collections.Generic;
using Sfs2X.Bitswarm;
using Sfs2X.Core;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using Sfs2X.Util;

namespace Sfs2X.Controllers
{
  public delegate void RequestDelegate(IMessage msg);

  
  public class SystemController : BaseController
  {
    public static readonly string KEY_PARAMS = "p";

    private Dictionary<int, RequestDelegate> requestHandlers;

    public SystemController(ISocketClient socketClient)
      : base(socketClient)
    {
      requestHandlers = new Dictionary<int, RequestDelegate>(8);
      InitRequestHandlers();
    }

    private void InitRequestHandlers()
    {
      requestHandlers[0] = FnHandshake;
      requestHandlers[1] = FnLogin;
      requestHandlers[2] = FnLogout;
      requestHandlers[29] = FnPingPong;
      requestHandlers[1005] = FnClientDisconnection;
      requestHandlers[1006] = FnReconnectionFailure;
    }

    public override void HandleMessage(IMessage message)
    {
      if (sfs.Debug)
      {
        log.Info("Message: " + (object) (RequestType) message.Id + " " + (object) message);
      }

      if (!requestHandlers.ContainsKey(message.Id))
      {
        log.Warn("Unknown message id: " + (object) message.Id);
      }
      else
      {
        if (message.Content == null)
        {
          var requestObject = SFSObject.NewFromBinaryData(message.RawData);
          message.Content = requestObject.GetSFSObject(KEY_PARAMS);
        }

        requestHandlers[message.Id](message);
      }
    }

    private void FnHandshake(IMessage msg)
    {
      SFSEvent sfsEvent = new SFSEvent(SFSEvent.HANDSHAKE, new Hashtable
      {
        ["message"] = msg.Content
      });
      sfs.HandleHandShake(sfsEvent);
      sfs.DispatchEvent(sfsEvent);
    }
    
    private void FnLogin(IMessage msg)
    {
      ISFSObject content = msg.Content;
      Hashtable data = new Hashtable();
      if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
      {
        this.sfs.MySelf = content.GetInt(LoginRequest.KEY_ID).ToString();
        sfs.SetReconnectionSeconds(content.GetShort(LoginRequest.KEY_RECONNECTION_SECONDS));
        data["zone"] = content.GetUtfString(LoginRequest.KEY_ZONE_NAME);
        data["user"] = sfs.MySelf;
        data["data"] = content.GetSFSObject(LoginRequest.KEY_PARAMS);
        SFSEvent sfsEvent = new SFSEvent(SFSEvent.LOGIN, data);
        sfs.HandleLogin(sfsEvent);
        sfs.DispatchEvent(sfsEvent);
      }
      else
      {
        short num = content.GetShort(BaseRequest.KEY_ERROR_CODE);
        string errorMessage = SFSErrorCodes.GetErrorMessage(num, sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
        data["errorMessage"] = errorMessage;
        data["errorCode"] = num;
        sfs.DispatchEvent(new SFSEvent(SFSEvent.LOGIN_ERROR, data));
      }
    }
    
    private void FnLogout(IMessage msg)
    {
      sfs.HandleLogout();
      ISFSObject content = msg.Content;
      sfs.DispatchEvent(new SFSEvent(SFSEvent.LOGOUT, new Hashtable
      {
        ["zoneName"] = content.GetUtfString(LogoutRequest.KEY_ZONE_NAME)
      }));
    }

    private void FnPingPong(IMessage msg)
    {
      sfs.DispatchEvent(new SFSEvent(SFSEvent.PING_PONG));
    }
    
    private void FnClientDisconnection(IMessage msg)
    {
      sfs.HandleClientDisconnection(ClientDisconnectionReason.GetReason(msg.Content.GetByte("dr")));
    }
    
    private void FnReconnectionFailure(IMessage msg)
    {
      sfs.HandleReconnectionFailure();
    }
  }
}





