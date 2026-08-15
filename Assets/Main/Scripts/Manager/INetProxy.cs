/**
 * [INPUT]: 依赖 Sfs2X.Requests.IRequest(原生平台)作为上行消息类型
 * [OUTPUT]: 对外提供 INetProxy 接口与 ProxyStatus,抽象一条底层连接的连接/断开/发送/心跳/状态能力
 * [POS]: Manager 网络族的传输层抽象,屏蔽 NetProxy(TCP/SFS)与 WebSocketNetProxy(WebGL)的实现差异,供 NetworkManager 以统一接口驱动当前连接
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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
