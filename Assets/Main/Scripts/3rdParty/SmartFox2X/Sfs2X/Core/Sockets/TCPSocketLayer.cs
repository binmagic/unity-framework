using System;
using System.Collections;
using System.Net.Sockets;
using System.Threading;
using Sfs2X.Bitswarm;
using Sfs2X.Util;
using UnityEngine;
/*
namespace Sfs2X.Core.Sockets
{
  public class TCPSocketLayer : BaseSocketLayer, ISocketLayer
  {
    private static readonly int READ_BUFFER_SIZE = 4096 * 4;
    private static int connId;
    private byte[] byteBuffer = new byte[READ_BUFFER_SIZE];
    private OnDataDelegate onData;
    private OnErrorDelegate onError;
    private int socketPollSleep;
    private Thread thrConnect;
    private string host;
    private int socketNumber;
    private TcpClient connection;
    private NetworkStream networkStream;
    private Thread thrSocketReader;
    private ConnectionDelegate onConnect;
    private ConnectionDelegate onDisconnect;

    public TCPSocketLayer(BitSwarmClient bs)
    {
      socketClient = bs;
      log = bs.Log;
      InitStates();
    }

    private void LogWarn(string msg)
    {
      log?.Warn("[TCPSocketLayer] " + msg);
    }

    private void LogError(string msg)
    {
      log?.Error("[TCPSocketLayer] " + msg);
    }

    private void ConnectThread()
    {
//      Thread.CurrentThread.Name = "ConnectionThread" + connId++;
      try
      {
        var tcpNoDelay = SmartFox.TcpNoDelay;
        connection = new TcpClient(host, socketNumber) {NoDelay = tcpNoDelay};
        networkStream = connection.GetStream();
        fsm.ApplyTransition((int)Transitions.ConnectionSuccess);
        CallOnConnect();
        thrSocketReader = new Thread(Read) {IsBackground = true};
        thrSocketReader.SetThreadName("TCPSocketReader");
        thrSocketReader.Start();
      }
      catch (SocketException ex)
      {
        HandleError("Connection error: " + ex.Message + " " + ex.StackTrace, ex.SocketErrorCode);
      }
      catch (Exception ex)
      {
        HandleError("General exception on connection: " + ex.Message + " " + ex.StackTrace);
      }
    }

    private void HandleError(string err, SocketError se = SocketError.NotSocket)
    {
      ((BitSwarmClient) socketClient).ThreadManager.EnqueueCustom(HandleErrorCallback, new InPacket
      {
        StrError = err,
        SocketError = se
      });
    }

    private void HandleErrorCallback(object o)
    {
      if (o is InPacket inPacket)
      {
        var msg = inPacket.StrError;
        var socketError = inPacket.SocketError;      
        fsm.ApplyTransition((int)Transitions.ConnectionFailure);
        if (!isDisconnecting)
        {
          LogError(msg);
          CallOnError(msg, socketError);
        }
      }

      HandleDisconnection();
    }

    private void HandleDisconnection()
    {
      HandleDisconnection(null);
    }

    private void HandleDisconnection(string reason)
    {
      if (State == States.Disconnected)
        return;
      fsm.ApplyTransition((int)Transitions.Disconnect);
      if (reason != null)
        return;
      CallOnDisconnect();
    }

    private void WriteSocket(byte[] buf, int offset, int length)
    {
      if (State != States.Connected)
      {
        LogError("Trying to write to disconnected socket");
      }
      else
      {
        try
        {
          // var str = BitConverter.ToString(buf, offset, length);
          // Debug.Log($"WriteSocket: {str}");
          
          networkStream.Write(buf, offset, length);
        }
        catch (SocketException ex)
        {
          HandleError("Error writing to socket: " + ex.Message, ex.SocketErrorCode);
        }
        catch (Exception ex)
        {
          HandleError("General error writing to socket: " + ex.Message + " " + ex.StackTrace);
        }
      }
    }

    private static void Sleep(int ms)
    {
      Thread.Sleep(10);
    }

    private void Read()
    {
      while (true)
      {
        try
        {
          if (State != States.Connected)
            break;
          if (socketPollSleep > 0)
            Sleep(socketPollSleep);
          
          int size = networkStream.Read(byteBuffer, 0, READ_BUFFER_SIZE);
          if (size < 1)
          {
            HandleError("#zlh# Connection closed by the remote side");
            break;
          }
          HandleBinaryData(byteBuffer, size);
        }
        catch (Exception ex)
        {
          // 如果已经不在连接状态了，就不去处理了。应该就是网络断开了，无法读取
          if (State != States.Connected)
            break;
          
          HandleError("Error reading data from socket: " + ex.Message);
          break;
        }
      }
      
      LogError("Read function over!");
    }

    private void HandleBinaryData(byte[] buf, int size)
    {
      //byte[] data = new byte[size];
      //Buffer.BlockCopy(buf, 0, data, 0, size);
      //将上面的new byte[] 直接改成ByteArray传递
      
      //var array = new ByteArray(buf, 0, size);
      var byteArray = ByteArrayPool.Rent(size);
      byteArray.SetData(buf, 0, size);
      
      // var str = BitConverter.ToString(data, 0, data.Length);
      // UnityEngine.Debug.Log($"size:{size}, HandleBinaryData: {str}");

      CallOnData(byteArray);
    }

    public void Connect(string host, int port)
    {
      if ((uint) State > 0U)
      {
        LogWarn("Call to Connect method ignored, as the socket is already connected");
      }
      else
      {
        this.host = host;
        socketNumber = port;
        fsm.ApplyTransition((int)Transitions.StartConnect);
        thrConnect = new Thread(ConnectThread);
        thrConnect.SetThreadName("ConnectionThread" + connId++);
        thrConnect.Start();
      }
    }

    public void Disconnect()
    {
      Disconnect(null);
    }

    public void Disconnect(string reason)
    {
      if (State != States.Connected)
      {
        LogWarn("Calling disconnect when the socket is not connected");
      }
      else
      {
        isDisconnecting = true;
        try
        {
          connection.Client.Shutdown(SocketShutdown.Both);
          connection.Close();
          networkStream.Close();
        }
        catch (Exception ex)
        {
          LogWarn("Trying to disconnect a non-connected tcp socket");
        }
        HandleDisconnection(reason);
        isDisconnecting = false;
      }
    }

    public void Kill()
    {
      fsm.ApplyTransition((int)Transitions.Disconnect);
      connection.Close();
    }

    public bool IsConnected => State == States.Connected;

    public OnDataDelegate OnData
    {
      get => onData;
      set => onData = value;
    }

    public OnStringDataDelegate OnStringData
    {
      get => null;
      set
      {
      }
    }

    private void CallOnData(ByteArray data)
    {
      if (onData == null)
        return;
      ((BitSwarmClient) socketClient).ThreadManager.EnqueueDataCall(onData, data);
    }

    public OnErrorDelegate OnError
    {
      get => onError;
      set => onError = value;
    }

    private void CallOnError(string msg, SocketError se)
    {
      onError?.Invoke(msg, se);
    }

    public ConnectionDelegate OnConnect
    {
      get => onConnect;
      set => onConnect = value;
    }

    private void CallOnConnect()
    {
      onConnect?.Invoke();
    }

    public ConnectionDelegate OnDisconnect
    {
      get => onDisconnect;
      set => onDisconnect = value;
    }

    private void CallOnDisconnect()
    {
      onDisconnect?.Invoke();
    }

    public bool RequiresConnection => true;

    public void Write(byte[] data, int offset, int len)
    {
      WriteSocket(data, offset, len);
    }

    public void Write(string data)
    {
      LogError("Method Write(string data) is not implemented because it is reserved to websocket communication");
      //throw new NotImplementedException();
    }

    public int SocketPollSleep
    {
      get => socketPollSleep;
      set => socketPollSleep = value;
    }
  }
}
*/





