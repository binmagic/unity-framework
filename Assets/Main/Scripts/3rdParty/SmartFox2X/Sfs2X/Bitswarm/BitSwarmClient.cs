using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading;
using System.Timers;
using Sfs2X.Controllers;
using Sfs2X.Core;
using Sfs2X.Core.Sockets;
using Sfs2X.Exceptions;
using Sfs2X.Logging;
using Sfs2X.Util;
using Timer = System.Timers.Timer;

namespace Sfs2X.Bitswarm
{
  public class BitSwarmClient : ISocketClient, IDispatchable
  {
    private readonly double reconnectionDelayMillis = 1000.0;
    private ISocketLayer socket;
    private Dictionary<int, IController> controllers = new Dictionary<int, IController>();
    private int compressionThreshold = 2000000;
    private int maxMessageSize = 10000;
    private int reconnectionSeconds;
    private bool attemptingReconnection;
    private DateTime firstReconnAttempt = DateTime.MinValue;
    private int reconnCounter = 1;
    private bool controllersInited;
    
    //private ThreadManager threadManager = new ThreadManager();
    private bool manualDisconnection;
    private Timer retryTimer;
    private IoHandler ioHandler;
    private SmartFox sfs;
    private string lastHost;
    private int lastTcpPort;
    private Logger log;
    private SystemController sysController;
    private ExtensionController extController;
    private EventDispatcher dispatcher;

    //public ThreadManager ThreadManager => threadManager;

    public string ConnectionMode { get; private set; }

    public bool Debug => sfs == null || sfs.Debug;

    public SmartFox Sfs => sfs;

    public bool Connected => socket != null && socket.IsConnected;

    public IoHandler IoHandler
    {
      get => ioHandler;
      set
      {
        if (ioHandler != null)
          throw new SFSError("IOHandler is already set!");
        ioHandler = value;
      }
    }

    public int CompressionThreshold
    {
      get => compressionThreshold;
      set
      {
        if (value <= 100)
          throw new ArgumentException("Compression threshold cannot be < 100 bytes");
        compressionThreshold = value;
      }
    }

    public int MaxMessageSize
    {
      get => maxMessageSize;
      set => maxMessageSize = value;
    }

    public SystemController SysController => sysController;

    public ExtensionController ExtController => extController;

    public ISocketLayer Socket => socket;

    public bool IsReconnecting
    {
      get => attemptingReconnection;
      set => attemptingReconnection = value;
    }

    public int ReconnectionSeconds
    {
      get => reconnectionSeconds;
      set => reconnectionSeconds = value < 0 ? 0 : value;
    }

    public bool IsBinProtocol => true;

    public EventDispatcher Dispatcher
    {
      get => dispatcher;
      set => dispatcher = value;
    }

    public Logger Log => sfs == null ? new Logger(null) : sfs.Log;

    public BitSwarmClient()
    {
      sfs = null;
      log = null;
    }

    public BitSwarmClient(SmartFox sfs)
    {
      this.sfs = sfs;
      log = sfs.Log;
      //threadManager.log = log;
    }

    public void Init()
    {
      if (dispatcher == null)
        dispatcher = new EventDispatcher(this);
      
      if (!controllersInited)
      { 
        InitControllers();
        controllersInited = true;
      }
      
      if (socket != null)
        return;
      
      socket = new AsyncTCPSocketLayer(this);
      socket.OnConnect += OnSocketConnect;
      socket.OnDisconnect += OnSocketClose;
      socket.OnData += OnSocketData;
      socket.OnError += OnSocketError;
    }

    public void Destroy()
    {
      socket.OnConnect -= OnSocketConnect;
      socket.OnDisconnect -= OnSocketClose;
      socket.OnData -= OnSocketData;
      socket.OnError -= OnSocketError;
      
      if (socket.IsConnected)
        socket.Disconnect();
      
      socket = null;
      //threadManager.Stop();
    }

    public IController GetController(int id)
    {
      return controllers[id];
    }

    public string ConnectionHost => !Connected ? "Not Connected" : lastHost;

    public int ConnectionPort => !Connected ? -1 : lastTcpPort;

    private void AddController(int id, IController controller)
    {
      if (controller == null)
        throw new ArgumentException("Controller is null, it can't be added.");
      if (controllers.ContainsKey(id))
        throw new ArgumentException("A controller with id: " + id + " already exists! Controller can't be added: " + controller);
      controllers[id] = controller;
    }

    private void AddCustomController(int id, Type controllerType)
    {
      IController instance = Activator.CreateInstance(controllerType) as IController;
      AddController(id, instance);
    }

    public void Connect()
    {
      Connect("127.0.0.1", 9933);
    }

    public void Connect(string host, int port)
    {
      lastHost = host;
      lastTcpPort = port;
      //threadManager.Start();

      socket.Connect(lastHost, lastTcpPort);
      ConnectionMode = ConnectionModes.SOCKET;
    }

    public void Send(IMessage message)
    {
      ioHandler.Codec.OnPacketWrite(message);
    }

    public void SendBinary(byte[] data, int dataLen)
    {
      ioHandler.Codec.OnPacketWrite(data, dataLen);
    }

    public void Disconnect()
    {
      Disconnect(null);
    }

    public void Disconnect(string reason)
    {
      socket.Disconnect(reason);
      ReleaseResources();
    }

    private void InitControllers()
    {
      sysController = new SystemController(this);
      extController = new ExtensionController(this);
      AddController(0, sysController);
      AddController(1, extController);
    }

    private void OnSocketConnect()
    {
      BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.CONNECT);
      evt.Params = new Hashtable
      {
        ["success"] = true,
        ["isReconnection"] = attemptingReconnection
      };
      DispatchEvent(evt);
    }

    public void StopReconnection()
    {
      attemptingReconnection = false;
      firstReconnAttempt = DateTime.MinValue;
      if (socket.IsConnected)
        socket.Disconnect();
      ExecuteDisconnection();
    }

    private void OnSocketClose()
    {
      if (sfs.GetReconnectionSeconds() == 0)
      {
        firstReconnAttempt = DateTime.MinValue;
        ExecuteDisconnection();
      }
      else if (attemptingReconnection)
      {
        Reconnect();
      }
      else
      {
        attemptingReconnection = true;
        firstReconnAttempt = DateTime.Now;
        reconnCounter = 1;
        DispatchEvent(new BitSwarmEvent(BitSwarmEvent.RECONNECTION_TRY));
        Reconnect();
      }
    }

    private void SetTimeout(ElapsedEventHandler handler, double timeout)
    {
      if (retryTimer == null)
      {
        retryTimer = new Timer(timeout);
        retryTimer.Elapsed += handler;
      }
      retryTimer.AutoReset = false;
      retryTimer.Enabled = true;
      retryTimer.Start();
    }

    private void OnRetryConnectionEvent(object source, ElapsedEventArgs e)
    {
      retryTimer.Enabled = false;
      retryTimer.Stop();
      socket.Connect(lastHost, lastTcpPort);
    }

    private void Reconnect()
    {
      if (!attemptingReconnection)
        return;
      
      TimeSpan timeSpan = firstReconnAttempt + new TimeSpan(0, 0, sfs.GetReconnectionSeconds()) - DateTime.Now;
      if (timeSpan > TimeSpan.Zero)
      {
        log.Info("Reconnection attempt: " + (object) reconnCounter + " - time left:" + (object) timeSpan.TotalSeconds + " sec.");
        SetTimeout(OnRetryConnectionEvent, reconnectionDelayMillis);
        ++reconnCounter;
      }
      else
        ExecuteDisconnection();
    }

    private void ExecuteDisconnection()
    {
      DispatchEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, new Hashtable
      {
        ["reason"] = ClientDisconnectionReason.UNKNOWN
      }));
      ReleaseResources();
    }

    private void ReleaseResources()
    {
      log.Info("ReleaseResources");
      //threadManager.Stop();
      // if (udpManager == null || !udpManager.Inited)
      //   return;
      // udpManager.Disconnect();
    }

    private void OnSocketData(ByteArray data)
    {
      ioHandler.OnDataRead(data);
    }

    private void OnSocketError(string message, SocketError se)
    {
      manualDisconnection = false;
      if (attemptingReconnection)
      {
        Reconnect();
      }
      else
      {
        BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.IO_ERROR);
        evt.Params = new Hashtable();
        evt.Params[nameof (message)] = message + " ==> " + se;
        DispatchEvent(evt);
      }
    }

    public void KillConnection()
    {
      socket.Kill();
      OnSocketClose();
    }

    public void AddEventListener(string eventType, EventListenerDelegate listener)
    {
      dispatcher.AddEventListener(eventType, listener);
    }

    private void DispatchEvent(BitSwarmEvent evt)
    {
      dispatcher.DispatchEvent(evt);
    }
  }
}





