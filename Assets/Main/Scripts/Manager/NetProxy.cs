using System;
using GameFramework;
using UnityEngine;

namespace GameKit.Base
{
    public enum ProxyStatus
    {
        init,
        connecting,
        connected,
        connectError,
    }

#if !UNITY_WEBGL
    public class NetProxy : INetProxy
    {
        private Sfs2X.Requests.PingPongRequest _pingPongRequest = new Sfs2X.Requests.PingPongRequest();
        private float _sendPingPongCounter = 0f;

        private float lastPingPongTime;
        public float _sendPingPongInterval = 5.0f;
        public int offMaxTime = 16;  // 默认心跳时间

        public string proxyName { get; private set; }
        private string host;
        private int port;
        private Sfs2X.SmartFox m_Client;
        private INetManager parent;

        public ProxyStatus Status { get; private set; }

        public NetProxy(string name, string h, int p, INetManager net)
        {
            this.proxyName = name;
            this.host = h;
            this.port = p;
            this.Status = ProxyStatus.init;
            this.parent = net;
        }

        public bool IsConnected
        {
            get
            {
                return m_Client != null && m_Client.IsConnected;
            }
        }

        public bool IsConnecting
        {
            get
            {
                return m_Client != null && m_Client.IsConnecting;
            }
        }

        private void initSmartFox()
        {
            m_Client = new Sfs2X.SmartFox
            {
                ThreadSafeMode = true,
            };

#if UNITY_EDITOR
            m_Client.Debug = true;
            m_Client.AddLogListener(Sfs2X.Logging.LogLevel.ERROR, OnLogError);
#endif
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.CONNECTION, OnConnection);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.CONNECTION_LOST, OnConnectionLost);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.EXTENSION_RESPONSE, OnExtensionResponse);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.PUBLIC_MESSAGE, OnPublicMessage);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.LOGIN, OnLogin);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.LOGIN_ERROR, OnLoginError);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.LOGOUT, OnLogout);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.PING_PONG, OnPingPong);
            m_Client.AddEventListener(Sfs2X.Core.SFSEvent.SOCKET_EXCEPTION, OnSocketException);
            if (m_Client.SocketClient.Socket != null)
            {
                m_Client.SocketClient.Socket.OnError += OnRawSocketError;
            }
        }

        public void UpdateSmartFoxClient()
        {
            if (m_Client == null)
                return;

            try
            {
                m_Client.ProcessEvents();
            }
            catch (Exception ex)
            {
                Debug.LogErrorFormat("UpdateSmartFoxClient exception : {0}", ex.Message);

                Status = ProxyStatus.connectError;
                parent.OnConnectionLost("exception", this);
                return;
            }

            _sendPingPongCounter += Time.deltaTime;
            if (_sendPingPongCounter >= _sendPingPongInterval)
            {
                _sendPingPongCounter = 0;
                if (m_Client != null)
                {
                    m_Client.Send(_pingPongRequest);
                }
            }
        }

        public void Connect()
        {
            SyncPingPong();

            if (m_Client == null)
            {
                initSmartFox();
            }
            m_Client.Connect(host, port);
            Status = ProxyStatus.connecting;
            Log.Info("smart Connect line {0} ip {1}, Port {2}", proxyName, host, port);
        }

        private void OnConnection(Sfs2X.Core.BaseEvent e)
        {
            bool success = (bool) e.Params["success"];
            if (success)
            {
                Status = ProxyStatus.connected;
            }
            else
            {
                Status = ProxyStatus.connectError;
            }
            parent.OnConnection(this, e);
        }

        private void OnConnectionLost(Sfs2X.Core.BaseEvent evt)
        {
            Status = ProxyStatus.connectError;
            parent.OnConnectionLost((string)evt.Params["reason"], this);
        }

        private void OnLogout(Sfs2X.Core.BaseEvent e)
        {
            parent.OnLogout(e);
        }

        private void OnExtensionResponse(Sfs2X.Core.BaseEvent e)
        {
            SyncPingPong();
            MessageFactory.Instance.DispatchResponse(e);
        }

        private void OnLogin(Sfs2X.Core.BaseEvent e)
        {
            SyncPingPong();
            parent.OnLogin(e);
        }

        private void OnLoginError(Sfs2X.Core.BaseEvent e)
        {
            parent.OnLoginError(e);
        }

        private void OnPublicMessage(Sfs2X.Core.BaseEvent e)
        {
            Log.Debug("public message");
        }

        private void OnLogError(Sfs2X.Core.BaseEvent e)
        {
            string message = (string)e.Params["message"];
            Log.Error(message);
        }

        void OnRawSocketError(string error, System.Net.Sockets.SocketError se)
        {
            string msg = string.Format("Socket error : {0}_{1}_{2}", proxyName, se, error);
            Log.Error(msg);
            PostEventLog.Record(PostEventLog.Defines.SOCKET_ERROR, msg);
        }

        private void OnPingPong(Sfs2X.Core.BaseEvent evt)
        {
            SyncPingPong();
        }

        private void OnSocketException(Sfs2X.Core.BaseEvent evt)
        {
            string message = (string)evt.Params["message"];
            System.Net.Sockets.SocketError socket_error = (System.Net.Sockets.SocketError)evt.Params["SocketError"];

            if (socket_error == System.Net.Sockets.SocketError.NotSocket)
            {
            }

            if (message != null)
            {
                UnityEngine.Debug.Log(message);
                PostEventLog.Record(PostEventLog.Defines.SOCKET_ERROR, message);
            }

            if (IsConnected || IsConnecting || Status != ProxyStatus.connectError)
            {
                Status = ProxyStatus.connectError;
                parent.OnConnectionLost("exception", this);
            }
        }

        public void SyncPingPong(int time = -1)
        {
            if (time == -1)
            {
                lastPingPongTime = Time.realtimeSinceStartup;
            }
            else
            {
                lastPingPongTime = time;
            }
        }

        public bool IsPingPongTimeOut
        {
            get
            {
                if (lastPingPongTime == 0)
                {
                    return false;
                }

                if (offMaxTime > 0 && lastPingPongTime + offMaxTime < Time.realtimeSinceStartup)
                {
                    return true;
                }

                return false;
            }
        }

        public void Disconnect()
        {
            if (m_Client != null)
            {
                m_Client.RemoveAllEventListeners();
                if (m_Client.SocketClient.Socket != null)
                {
                    m_Client.SocketClient.Socket.OnError -= OnRawSocketError;
                }

                m_Client.Disconnect();
                m_Client = null;

                Status = ProxyStatus.init;
                Log.Info("smart line {0} disconnect", proxyName);
            }
        }

        public void Send(Sfs2X.Requests.IRequest request)
        {
            if (m_Client != null)
                m_Client.Send(request);
        }

        public void Send(byte[] data, int dataLen)
        {
            if (m_Client != null)
                m_Client.Send(data, dataLen);
        }

        public bool SendPingpong()
        {
            if (m_Client != null)
            {
                _sendPingPongCounter = 0;
                m_Client.Send(_pingPongRequest);
                return true;
            }

            return false;
        }

        public void KillConnection()
        {
            if (m_Client != null)
                m_Client.KillConnection();
        }
    }
#endif
}
