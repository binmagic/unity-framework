#if !UNITY_WEBGL
using Sfs2X.Requests;
#endif

namespace GameKit.Base
{
    public interface INetProxy
    {
        string proxyName { get;}

        bool IsConnected { get; }

        bool IsConnecting { get; }

        void Connect();

        void Disconnect();

#if !UNITY_WEBGL
        void Send(IRequest request);
#endif
        void Send(byte[] data, int dataLen);

        void SyncPingPong(int time = -1);

        bool IsPingPongTimeOut { get; }

        ProxyStatus Status { get;}

        void UpdateSmartFoxClient();
    }
}
