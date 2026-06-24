using Sfs2X.Requests;

namespace GameKit.Base
{
    public interface INetProxy
    {
        string proxyName { get;}

        bool IsConnected { get; }

        bool IsConnecting { get; }

        void Connect();
        
        void Disconnect();

        void Send(IRequest request);
        void Send(byte[] data, int dataLen);

        void SyncPingPong(int time = -1);

        bool IsPingPongTimeOut { get; }

        ProxyStatus Status { get;}

        void UpdateSmartFoxClient();
    }
}





