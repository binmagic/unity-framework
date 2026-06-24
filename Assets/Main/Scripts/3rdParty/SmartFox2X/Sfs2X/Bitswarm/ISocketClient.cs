using Sfs2X.Controllers;
using Sfs2X.Core;
using Sfs2X.Core.Sockets;
using Sfs2X.Logging;
using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public interface ISocketClient
    {
        string ConnectionMode { get; }

        bool Debug { get; }

        SmartFox Sfs { get; }

        bool Connected { get; }

        IoHandler IoHandler { get; set; }

        int CompressionThreshold { get; set; }

        int MaxMessageSize { get; set; }

        SystemController SysController { get; }

        ExtensionController ExtController { get; }

        ISocketLayer Socket { get; }

        bool IsReconnecting { get; set; }

        int ReconnectionSeconds { get; set; }

        EventDispatcher Dispatcher { get; set; }

        Logger Log { get; }

        void Init();

        void Destroy();

        IController GetController(int id);

        string ConnectionHost { get; }

        int ConnectionPort { get; }

        void Connect();

        void Connect(string host, int port);

        void Send(IMessage message);
        void SendBinary(byte[] data, int dataLen);

        void Disconnect();

        void Disconnect(string reason);

        void StopReconnection();

        void KillConnection();

        void AddEventListener(string eventType, EventListenerDelegate listener);

        bool IsBinProtocol { get; }
    }
}





