namespace Sfs2X.Core.Sockets
{
  public interface ISocketLayer
  {
    void Connect(string host, int port);

    bool IsConnected { get; }

    bool RequiresConnection { get; }

    void Disconnect();

    void Disconnect(string reason);

    ConnectionDelegate OnConnect { get; set; }

    ConnectionDelegate OnDisconnect { get; set; }

    void Write(byte[] data, int offset, int length);

    void Write(string data);

    OnDataDelegate OnData { get; set; }

    OnStringDataDelegate OnStringData { get; set; }

    OnErrorDelegate OnError { get; set; }

    void Kill();
  }
}





