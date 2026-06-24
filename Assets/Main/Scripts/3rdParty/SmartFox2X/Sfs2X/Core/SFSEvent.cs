using System.Collections;

namespace Sfs2X.Core
{
  public class SFSEvent : BaseEvent
  {
    public static readonly string HANDSHAKE = "handshake";
    public static readonly string UDP_INIT = "udpInit";
    public static readonly string CONNECTION = "connection";
    public static readonly string PING_PONG = "pingPong";
    public static readonly string SOCKET_ERROR = "socketError";
    public static readonly string SOCKET_EXCEPTION = "socketException";
    public static readonly string CONNECTION_LOST = "connectionLost";
    public static readonly string CONNECTION_RETRY = "connectionRetry";
    public static readonly string CONNECTION_RESUME = "connectionResume";
    public static readonly string CONNECTION_ATTEMPT_HTTP = "connectionAttemptHttp";
    public static readonly string CONFIG_LOAD_SUCCESS = "configLoadSuccess";
    public static readonly string CONFIG_LOAD_FAILURE = "configLoadFailure";
    public static readonly string LOGIN = "login";
    public static readonly string LOGIN_ERROR = "loginError";
    public static readonly string LOGOUT = "logout";
    public static readonly string PUBLIC_MESSAGE = "publicMessage";
    public static readonly string PRIVATE_MESSAGE = "privateMessage";
    public static readonly string MODERATOR_MESSAGE = "moderatorMessage";
    public static readonly string ADMIN_MESSAGE = "adminMessage";
    public static readonly string OBJECT_MESSAGE = "objectMessage";
    public static readonly string EXTENSION_RESPONSE = "extensionResponse";
    public static readonly string CRYPTO_INIT = "cryptoInit";

    public SFSEvent(string type, Hashtable data)
      : base(type, data)
    {
    }

    public SFSEvent(string type)
      : base(type, (Hashtable) null)
    {
    }
  }
}





