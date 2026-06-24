using System;
using System.Buffers;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using Sfs2X.Bitswarm;
using Sfs2X.Util;
using UnityEngine;

// 异步socket处理
namespace Sfs2X.Core.Sockets
{
  // 这个用于BeginWrite时的数据重叠问题
  // 因为我们是异步发送的，所以这里必须要把数据缓存一下，否则发送过程中（没有发送完成时），数据被修改了，就有可能出错
  public class WriteInfo
  {
    public byte[] data; // allocate from pool
    public TcpClient writeClient;
  }

  public class ObjectPool<T> where T : new()
  {
    private Queue<T> pool = new Queue<T>();
    private Func<T> objectGenerator;

    public ObjectPool(Func<T> objectGenerator)
    {
      if (objectGenerator == null)
      {
        Debug.LogError("objectGenerator == null");
        return;
      }

      this.objectGenerator = objectGenerator;
    }

    public T GetObject()
    {
      lock (pool)
      {
        if (pool.Count > 0)
          return pool.Dequeue();
      }

      // 如果对象池为空，则创建一个新对象
      return objectGenerator();
    }

    public void ReturnObject(T item)
    {
      if (item == null)
      {
        Debug.LogError("ReturnObject item = null!");
        return;
      }

      lock (pool)
      {
        pool.Enqueue(item);
      }
    }
  }
  
  public class AsyncTCPSocketLayer : BaseSocketLayer, ISocketLayer
  {
    private static readonly int READ_BUFFER_SIZE = 4096 * 8;
    
    private OnDataDelegate onData;
    private OnErrorDelegate onError;
    
    private string host;
    private int socketNumber;
    
    private TcpClient connection;
    private NetworkStream networkStream;
    
    private ConnectionDelegate onConnect;
    private ConnectionDelegate onDisconnect;

    private ObjectPool<WriteInfo> Pool = new ObjectPool<WriteInfo>(() => new WriteInfo());
    // 做一个全局的ByteArray用来接收
    private ByteArray recvByteArray = new ByteArray(READ_BUFFER_SIZE);
    
    public AsyncTCPSocketLayer(BitSwarmClient bs)
    {
      socketClient = bs;
      log = bs.Log;
      InitStates();
    }
    
    private void LogError(string msg)
    {
      Debug.LogErrorFormat("[AsyncTCPSocketLayer] {0}", msg);
    }
    
    private void HandleError(string err, SocketError se = SocketError.NotSocket)
    {
      // 如果网络已经断开了，就不再汇报了，因为不属于异常，关闭网络的时候会有大量的异常
      if (isDisconnecting || State == States.Disconnected)
      {
        return;
      }
      
      // 因为这个触发主要是在异步线程中，所以这里不要去处理任何东西，要将这个处理扔到主线程中执行
      LogError(err);

      if (socketClient != null)
      {
        socketClient.Sfs.DispatchEvent(new SFSEvent(SFSEvent.SOCKET_EXCEPTION, new Hashtable
        {
          ["errorMessage"] = err,
          ["SocketError"] = (int)se,
        }));
      }
      else
      {
        // 如果无法派发到主线程，这里简单处理一下断开；等pingpong超时
        HandleDisconnection("internal error");
      }
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
    
    private void HandleBinaryData(byte[] buf, int size)
    {
      recvByteArray.DataLength = size;
      
      // onData一般就是
      // BitSwarmClient:OnSocketData(ByteArray data)
      try
      {
        if (onData != null)
        {
          onData(recvByteArray);
        }
      }
      catch (Exception e)
      {
        LogError("HandleBinaryData exception: " + e.Message);
      }
    }
    
    
    public static bool IsIPv6Address(string host)
    {
      // 如果输入字符串是空或null，则不可能是有效的IPv6地址
      if (string.IsNullOrEmpty(host))
      {
        return false;
      }

      // 尝试将字符串解析为 IP 地址
      // IPAddress.TryParse 方法会尝试将字符串解析为 IPv4 或 IPv6 地址
      if (IPAddress.TryParse(host, out IPAddress address))
      {
        // 如果解析成功，检查解析出来的是否是 IPv6 地址
        return address.AddressFamily == AddressFamily.InterNetworkV6;
      }
      else
      {
        // 如果不能解析为任何 IP 地址，则它肯定不是 IPv6 (也不是 IPv4)
        return false;
      }
    }

    public void Connect(string host, int port)
    {
      if (State != States.Disconnected)
      {
        LogError("Call to Connect method ignored, as the socket is already connected");
        Disconnect();
      }

      this.host = host;
      socketNumber = port;
      fsm.ApplyTransition((int) Transitions.StartConnect);

      try
      {
        var tcpNoDelay = SmartFox.TcpNoDelay;
        bool isIpV6 = IsIPv6Address(host);
        if (isIpV6)
        {
          connection = new TcpClient(AddressFamily.InterNetworkV6);
        }
        else
        {
          connection = new TcpClient();
        }

        connection.NoDelay = tcpNoDelay;
        connection.BeginConnect(host, port, ConnectCallback, connection);
        //LogInfo("BeginConnect");
      }
      catch (SocketException ex)
      {
        HandleError("Connection error: " + ex.Message, ex.SocketErrorCode);
      }
      catch (Exception ex)
      {
        HandleError("General exception on connection: " + ex.Message);
      }
      
    }
    
    private void ConnectCallback(IAsyncResult result)
    {
      if (isDisconnecting || State == States.Disconnected)
      {
        // 如果正在断开连接或连接已断开，不处理回调
        return;
      }
      
      try
      {
        TcpClient tcpClient = (TcpClient) result.AsyncState;
        tcpClient.EndConnect(result);

        // Start receiving data asynchronously
        if (connection != tcpClient || connection == null)
        {
          LogError("socket not same!");
          return;
        }
        
        networkStream = connection.GetStream();
        fsm.ApplyTransition((int)Transitions.ConnectionSuccess);
        CallOnConnect();

        // 发起一个异步接收
        var byteBuffer = recvByteArray.GetRawBytes();
        networkStream.BeginRead(byteBuffer, 0, byteBuffer.Length, ReceiveCallback, connection);
      }
      catch (SocketException ex)
      {
        HandleError("ConnectCallback error: " + ex.Message, ex.SocketErrorCode);
      }
      catch (Exception ex)
      {
        HandleError("General exception on ConnectCallback: " + ex.Message);
      }
    }
    
    private void ReceiveCallback(IAsyncResult ar)
    {
      // 注意，这个ReceiveCallbak，是在一个线程池中执行的，非主线程。
      // 是socket最后停止时处理的尾巴，因为还是异步处理的，一定要注意此时很多变量已经无效了。
      
      if (isDisconnecting || State == States.Disconnected)
      {
        // 如果正在断开连接或连接已断开，不处理回调
        return;
      }
      
      try
      {
        TcpClient tcpClient = (TcpClient) ar.AsyncState;
        if (tcpClient != connection || networkStream == null)
        {
          return;
        }

        // 注意这里的调用有可能会抛异常，当socket已经断开这种，也算异常
        int bytesRead = networkStream.EndRead(ar);

        if (bytesRead > 0)
        {

          HandleBinaryData(null, bytesRead);

          // Continue receiving data
          var byteBuffer = recvByteArray.GetRawBytes();
          networkStream.BeginRead(byteBuffer, 0, byteBuffer.Length, ReceiveCallback, connection);
        }
        else
        {
          // HandleDisconnection("Connection closed by server.");
          // connection.Close();
          HandleError("Connection closed by server.", SocketError.Success);
        }
      }
      catch (SocketException ex)
      {
        HandleError("Receive error: " + ex.Message, ex.SocketErrorCode);
      }
      catch (Exception ex)
      {
        HandleError("General exception on Receive: " + ex.Message);
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
        LogError("Calling disconnect when the socket is not connected");
      }
      else
      {
        isDisconnecting = true;
        try
        {
          if (connection.Client != null && connection.Client.Connected)
          {
            connection.Client.Shutdown(SocketShutdown.Both);
          }
          
          // connection在Close的时候，会Dispose他的networkstream
          //networkStream.Close();
          networkStream = null;
          connection.Close();
        }
        catch (Exception ex)
        {
          LogError("Trying to disconnect a non-connected tcp socket." + ex.Message);
        }
        
        HandleDisconnection(reason);
        isDisconnecting = false;
        //LogInfo("Disconnect: " + reason);
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
      // 关闭状态就不能再去写入了，否则会持续抛异常
      if (State != States.Connected)
      {
        LogError("Trying to write to disconnected socket");
        return;
      }
      
      try
      {
        // 为了避免重叠发送（Overlapped），所以这里需要生成一个临时对象缓存这个数据。但这就不是Zero-Copy了
        WriteInfo writeInfo = Pool.GetObject();
        writeInfo.writeClient = connection;
        writeInfo.data = ArrayPool<byte>.Shared.Rent(len);
        Buffer.BlockCopy(data, 0, writeInfo.data, 0, len * sizeof(byte));
        
        networkStream.BeginWrite(writeInfo.data, offset, len, SendCallback, writeInfo);
        //LogInfo("Write bytes: " + len.ToString());
      }
      catch (Exception ex)
      {
        HandleError("General exception on Write: " + ex.Message);
      }
    }
    
    private void SendCallback(IAsyncResult ar)
    {
      // 如果已经处于断开状态了，那么就不处理。因为断开处理的时候，这里肯定要进行回调的，表示终止。
      WriteInfo writeInfo = ar.AsyncState as WriteInfo;
      if (writeInfo == null)
      {
        LogError("SendCallback null!");
        return;
      }
      
      try
      {
        if (isDisconnecting || State == States.Disconnected)
        {
          // 如果正在断开连接或连接已断开，不处理回调
          return;
        }
        
        writeInfo.writeClient.GetStream().EndWrite(ar);
      }
      catch (Exception ex)
      {
        HandleError("General exception on SendCallback: " + ex.Message);
      }
      finally
      {
        // 使用完成后归还给byte池
        ArrayPool<byte>.Shared.Return(writeInfo.data);
        Pool.ReturnObject(writeInfo);
      }
    }
    
    public void Write(string data)
    {
      LogError("Method Write(string data) is not implemented because it is reserved to websocket communication");
      //throw new NotImplementedException();
    }
    
  }

}



