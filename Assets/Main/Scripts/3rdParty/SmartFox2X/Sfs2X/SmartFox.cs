using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using Sfs2X.Bitswarm;
using Sfs2X.Core;
using Sfs2X.Entities.Data;
//using Sfs2X.Entities.Managers;
using Sfs2X.Exceptions;
using Sfs2X.Logging;
using Sfs2X.Requests;
using Sfs2X.Util;
using UnityEngine.Profiling;

namespace Sfs2X
{
  public class SmartFox : IDispatchable
  {
    private int majVersion = 1;
    private int minVersion = 7;
    private int subVersion = 8;
    private string clientDetails = "ReadyGo";
    private bool isJoining;
    private bool inited;
    private bool debug;
    private bool threadSafeMode = true;
    private bool isConnecting;
    private object eventsLocker = new object();
    private Queue<BaseEvent> eventsQueue = new Queue<BaseEvent>();
    private BaseEvent[] processEventsArray = new BaseEvent[256];
    private ISocketClient socketClient;
    
    private string mySelf;
    private string sessionToken;
    private Logger log;
    
    //private ConfigData config;
    private string currentZone;
    private string lastHost;
    private EventDispatcher dispatcher;

    public ISocketClient SocketClient
    {
      get
      {
        return socketClient;
      }
    }

    public Logger Log
    {
      get
      {
        return log;
      }
    }

    public SmartFox()
    {
      Initialize(false);
    }

    public SmartFox(bool debug)
    {
      Initialize(debug);
    }
    
    private void Initialize(bool debug)
    {
      if (inited)
        return;
      log = new Logger(this);
      this.debug = debug;
      if (dispatcher == null)
        dispatcher = new EventDispatcher(this);
      
      {
        socketClient = new BitSwarmClient(this);
        socketClient.IoHandler = new SFSIOHandler(socketClient);
      }
      
      socketClient.Init();
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.CONNECT, OnSocketConnect);
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.DISCONNECT, OnSocketClose);
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.RECONNECTION_TRY, OnSocketReconnectionTry);
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.IO_ERROR, OnSocketIOError);
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.SECURITY_ERROR, OnSocketSecurityError);
      socketClient.Dispatcher.AddEventListener(BitSwarmEvent.DATA_ERROR, OnSocketDataError);
      inited = true;
      Reset();
    }

    private void Reset()
    {
      isJoining = false;
      currentZone = null;
      sessionToken = null;
      mySelf = null;
    }
    
    public bool IsConnecting
    {
      get
      {
        return isConnecting;
      }
    }

    public ISocketClient GetSocketEngine()
    {
      return socketClient;
    }

    public bool IsConnected
    {
      get
      {
        bool flag = false;
        if (socketClient != null)
          flag = socketClient.Connected;
        return flag;
      }
    }
    
    static public bool TcpNoDelay { get; set; } = true;

    static public int UseAsyncTcp { get; set; } = 1;

    public int CompressionThreshold
    {
      get
      {
        return socketClient.CompressionThreshold;
      }
    }

    public int MaxMessageSize
    {
      get
      {
        return socketClient.MaxMessageSize;
      }
    }
    
    public void KillConnection()
    {
      socketClient.KillConnection();
    }

    public void Connect(string host, int port)
    {
      if (IsConnected)
        log.Warn("Already connected");
      else if (isConnecting)
      {
        log.Warn("A connection attempt is already in progress");
      }
      else
      {
        // if (config == null)
        // {
        //   config = new ConfigData();
        //   // config.UseBlueBox = UseBlueBox;
        //   config.Debug = Debug;
        // }
        // if (host == null)
        //   host = config.Host;
        // if (port == -1)
        //   port = config.Port;
        if (host == null || host.Length == 0)
          throw new ArgumentException("Invalid connection host name / IP address");
        if (port < 0 || port > ushort.MaxValue)
          throw new ArgumentException("Invalid connection port");
        lastHost = host;
        isConnecting = true;
        socketClient.Connect(host, port);
      }
    }

    public void Disconnect()
    {
      if (IsConnected)
      {
        if (socketClient.ReconnectionSeconds > 0)
        {
          Send(new ManualDisconnectionRequest());
          Thread.Sleep(50);
        }
        HandleClientDisconnection(ClientDisconnectionReason.MANUAL);
      }
      else
        log.Info("You are not connected");
    }

    public bool Debug
    {
      get
      {
        return debug;
      }
      set
      {
        debug = value;
      }
    }

    public string CurrentIp
    {
      get
      {
        return socketClient.ConnectionHost;
      }
    }

    public int CurrentPort
    {
      get
      {
        return socketClient.ConnectionPort;
      }
    }

    public string CurrentZone
    {
      get
      {
        return currentZone;
      }
    }

    public string MySelf
    {
      get => mySelf;
      set => mySelf = value;
    }

    public Logger Logger
    {
      get
      {
        return log;
      }
    }
    
    public string SessionToken
    {
      get
      {
        return sessionToken;
      }
    }

    public EventDispatcher Dispatcher
    {
      get
      {
        return dispatcher;
      }
    }

    public bool ThreadSafeMode
    {
      get
      {
        return threadSafeMode;
      }
      set
      {
        threadSafeMode = value;
      }
    }

    public int GetReconnectionSeconds()
    {
      return socketClient.ReconnectionSeconds;
    }

    public void SetReconnectionSeconds(int seconds)
    {
      socketClient.ReconnectionSeconds = seconds;
    }

    public void Send(IRequest request)
    {

      if (!IsConnected)
      {
        log.Warn("You are not connected. Request cannot be sent: " + (object) request);
        return;
      }
      
      try
      {
        request.Validate(this);
        request.Execute(this);
        socketClient.Send(request.Message);
      }
      catch (Exception ex)
      {
        UnityEngine.Debug.LogErrorFormat("Send exception: {0}", ex.Message);
      }
      
    }
    
    public void Send(byte[] data, int dataLen)
    {
      if (!IsConnected)
      {
        log.Warn("You are not connected. Request cannot be sent: ");
        return;
      }
      
      try
      {
        socketClient.SendBinary(data, dataLen);
      }
      catch (Exception e)
      {
        UnityEngine.Debug.LogErrorFormat("Send Error! {0}", e.Message);
      }

    }

    public void AddLogListener(LogLevel logLevel, EventListenerDelegate eventListener)
    {
      AddEventListener(LoggerEvent.LogEventType(logLevel), eventListener);
      log.EnableEventDispatching = true;
    }

    public void RemoveLogListener(LogLevel logLevel, EventListenerDelegate eventListener)
    {
      RemoveEventListener(LoggerEvent.LogEventType(logLevel), eventListener);
    }

    private void OnSocketConnect(BaseEvent e)
    {
      BitSwarmEvent bitSwarmEvent = e as BitSwarmEvent;
      if ((bool) bitSwarmEvent.Params["success"])
      {
        SendHandshakeRequest((bool) bitSwarmEvent.Params["isReconnection"]);
      }
      else
      {
        log.Warn("Connection attempt failed");
        HandleConnectionProblem(bitSwarmEvent);
      }
    }

    private void OnSocketClose(BaseEvent e)
    {
      UnityEngine.Debug.Log("OnSocketClose");
      BitSwarmEvent bitSwarmEvent = e as BitSwarmEvent;
      Reset();
      DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, new Hashtable
      {
        ["reason"] = bitSwarmEvent.Params["reason"]
      }));
    }

    private void OnSocketReconnectionTry(BaseEvent e)
    {
      DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RETRY));
    }

    private void OnSocketDataError(BaseEvent e)
    {
      DispatchEvent(new SFSEvent(SFSEvent.SOCKET_ERROR, new Hashtable
      {
        ["errorMessage"] = e.Params["message"]
      }));
    }

    private void OnSocketIOError(BaseEvent e)
    {
      BitSwarmEvent bitSwarmEvent = e as BitSwarmEvent;
      if (!isConnecting)
        return;
      HandleConnectionProblem(bitSwarmEvent);
    }

    private void OnSocketSecurityError(BaseEvent e)
    {
      BitSwarmEvent bitSwarmEvent = e as BitSwarmEvent;
      if (!isConnecting)
        return;
      HandleConnectionProblem(bitSwarmEvent);
    }
    
    public void HandleHandShake(BaseEvent evt)
    {
      UnityEngine.Debug.Log("HandleHandShake");
      ISFSObject sfsObject = evt.Params["message"] as ISFSObject;
      if (sfsObject.IsNull(BaseRequest.KEY_ERROR_CODE))
      {
        sessionToken = sfsObject.GetUtfString(HandshakeRequest.KEY_SESSION_TOKEN);
        socketClient.CompressionThreshold = sfsObject.GetInt(HandshakeRequest.KEY_COMPRESSION_THRESHOLD);
        socketClient.MaxMessageSize = sfsObject.GetInt(HandshakeRequest.KEY_MAX_MESSAGE_SIZE);
        if (debug)
          log.Debug($"Handshake response: tk => {sessionToken}, ct => {socketClient.CompressionThreshold}, maxMessageSize => {socketClient.MaxMessageSize}");
        
        if (socketClient.IsReconnecting)
        {
          UnityEngine.Debug.Log("HandleHandShake - CONNECTION_RESUME");
          socketClient.IsReconnecting = false;
          DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RESUME));
        }
        else
        {
          UnityEngine.Debug.Log("HandleHandShake - CONNECTION");
          isConnecting = false;
          DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, new Hashtable
          {
            ["success"] = true
          }));
        }
      }
      else
      {
        short num = sfsObject.GetShort(BaseRequest.KEY_ERROR_CODE);
        string errorMessage = SFSErrorCodes.GetErrorMessage(num, log, sfsObject.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
        DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, new Hashtable
        {
          ["success"] = false,
          ["errorMessage"] = errorMessage,
          ["errorCode"] = num
        }));
      }
    }

    public void HandleLogin(BaseEvent evt)
    {
      currentZone = evt.Params["zone"] as string;
    }

    public void HandleClientDisconnection(string reason)
    {
      socketClient.ReconnectionSeconds = 0;
      socketClient.Disconnect(reason);
      Reset();
      if (reason == null)
        return;
      
      UnityEngine.Debug.LogFormat("HandleClientDisconnection : {0}", reason);
      DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, new Hashtable
      {
        {
          nameof (reason),
          reason
        }
      }));
    }

    public void HandleLogout()
    {
      //roomManager = new SFSRoomManager(this);
      isJoining = false;
      currentZone = null;
      mySelf = null;
    }

    private void HandleConnectionProblem(BaseEvent e)
    {
      BitSwarmEvent bitSwarmEvent = e as BitSwarmEvent;
      DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, new Hashtable
      {
        ["success"] = false,
        ["errorMessage"] = bitSwarmEvent.Params["message"]
      }));
      isConnecting = false;
      socketClient.Destroy();
    }

    public void HandleReconnectionFailure()
    {
      SetReconnectionSeconds(0);
      socketClient.StopReconnection();
    }

    private void SendHandshakeRequest(bool isReconnection)
    {
      Send(new HandshakeRequest("1.7.8", isReconnection ? sessionToken : null, clientDetails));
    }

    internal void DispatchEvent(BaseEvent evt)
    {
      // if (!threadSafeMode)
      //   Dispatcher.DispatchEvent(evt);
      // else
      
      // 发事件的时候，压入队列，下一帧处理。这里同时可以处理多线程的消息分发。
        EnqueueEvent(evt);
    }

    private void EnqueueEvent(BaseEvent evt)
    {
      lock (eventsLocker)
        eventsQueue.Enqueue(evt);
    }

    public void ProcessEvents()
    {
      if (!threadSafeMode)
        return;
      
      if (eventsQueue.Count == 0)
        return;
      
      // 用一个全局的临时数组来处理。如果数量较大的话，新分配一个，
      // 不过经验值告诉我们不可能超过默认值。
      BaseEvent[] array;
      int array_count = 0;
      lock (eventsLocker)
      {
        if (eventsQueue.Count > processEventsArray.Length)
        {
          array = eventsQueue.ToArray();
        }
        else
        {
          array = this.processEventsArray;
          eventsQueue.CopyTo(array, 0);
        }

        array_count = eventsQueue.Count;
        eventsQueue.Clear();
      }
      
      for (int index = 0; index < array_count; ++index)
        Dispatcher.DispatchEvent(array[index]);
    }

    public void AddEventListener(string eventType, EventListenerDelegate listener)
    {
      dispatcher.AddEventListener(eventType, listener);
    }

    public void RemoveEventListener(string eventType, EventListenerDelegate listener)
    {
      dispatcher.RemoveEventListener(eventType, listener);
    }

    public void RemoveAllEventListeners()
    {
      dispatcher.RemoveAll();
    }
  }
}





