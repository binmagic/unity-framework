using System;
using System.Net.Sockets;
using GameFramework;
using Sfs2X;
using Sfs2X.Core;
using Sfs2X.Requests;
using Sfs2X.Util;
using UnityEditor;
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

    public class NetProxy : INetProxy
    {
        private PingPongRequest _pingPongRequest = new PingPongRequest();
        private float _sendPingPongCounter = 0f;
        
        private float lastPingPongTime;
        public float _sendPingPongInterval = 5.0f;
        public int offMaxTime = 16;  // 默认心跳时间
        
        public string proxyName { get; private set; }
        private string host;
        private int port;
        private SmartFox m_Client;
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
            m_Client = new SmartFox
            {
                ThreadSafeMode = true,
            };

#if UNITY_EDITOR
            m_Client.Debug = true;
            m_Client.AddLogListener(Sfs2X.Logging.LogLevel.ERROR, OnLogError);
#endif
            m_Client.AddEventListener(SFSEvent.CONNECTION, OnConnection);
            m_Client.AddEventListener(SFSEvent.CONNECTION_LOST, OnConnectionLost);
            m_Client.AddEventListener(SFSEvent.EXTENSION_RESPONSE, OnExtensionResponse);
            m_Client.AddEventListener(SFSEvent.PUBLIC_MESSAGE, OnPublicMessage);
            m_Client.AddEventListener(SFSEvent.LOGIN, OnLogin);
            m_Client.AddEventListener(SFSEvent.LOGIN_ERROR, OnLoginError);
            m_Client.AddEventListener(SFSEvent.LOGOUT, OnLogout);
            m_Client.AddEventListener(SFSEvent.PING_PONG, OnPingPong);
            m_Client.AddEventListener(SFSEvent.SOCKET_EXCEPTION, OnSocketException);
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
                //m_Client.Disconnect();
                Debug.LogErrorFormat("UpdateSmartFoxClient exception : {0}", ex.Message);
                
                Status = ProxyStatus.connectError;
                parent.OnConnectionLost("exception", this);
                return;
            }

            // 这里需要判断m_Client是否为NULL；因为m_Client.ProcessEvents();之后有可能会在LUA设置m_Client=NULL
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
            // parent.getFutureManager().reset();
            Status = ProxyStatus.connecting;
            Log.Info("smart Connect line {0} ip {1}, Port {2}", proxyName, host, port);
        }
        
        private void OnConnection(BaseEvent e)
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
        
        private void OnConnectionLost(BaseEvent evt)
        {
            Status = ProxyStatus.connectError;
            parent.OnConnectionLost((string)evt.Params["reason"], this);
        }
        
        private void OnLogout(BaseEvent e)
        {
            parent.OnLogout(e);
        }

        private void OnExtensionResponse(BaseEvent e)
        {
            SyncPingPong();
            MessageFactory.Instance.DispatchResponse(e);
        }
        
        private void OnLogin(BaseEvent e)
        {
            SyncPingPong();
            parent.OnLogin(e);
        }
        
        private void OnLoginError(BaseEvent e)
        {
            parent.OnLoginError(e);
        }

        private void OnPublicMessage(BaseEvent e)
        {
            Log.Debug("public message");
        }

        private void OnLogError(BaseEvent e)
        {
            string message = (string)e.Params["message"];
            Log.Error(message);
            // PostEventLog.Record(PostEventLog.Defines.SOCKET_ERROR, $"socket error: {message}");
        }
        
        void OnRawSocketError(string error, SocketError se)
        {
            string msg = string.Format("Socket error : {0}_{1}_{2}", proxyName, se, error);
            Log.Error(msg);
            PostEventLog.Record(PostEventLog.Defines.SOCKET_ERROR, msg);
        }

        private void OnPingPong(BaseEvent evt)
        {
            SyncPingPong();
            // Log.Debug("OnPingPong");
        }

        private void OnSocketException(BaseEvent evt)
        {
            string message = (string)evt.Params["message"];
            SocketError socket_error = (SocketError)evt.Params["SocketError"];
            
            // 有一些类型的网络错误不打日志
            if (socket_error == SocketError.NotSocket)
            {
                    
            }

            if (message != null)
            {
                UnityEngine.Debug.Log(message);
                PostEventLog.Record(PostEventLog.Defines.SOCKET_ERROR, message);
            }
            else
            {
                int a = 0;
            }

            // 如果在连接中或者连接状态，才去通知断开，否则这个情况直接忽略
            // 另外这个地方不能直接Disconnect，必须要抛给LUA层，让LUA进行释放
            if (IsConnected || IsConnecting || Status != ProxyStatus.connectError)
            {
                Status = ProxyStatus.connectError;
                parent.OnConnectionLost("exception", this);
            }
            else
            {
                int a = 0;
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
        
        // 注意: 这个Disconnec不能在C#中关闭，因为lua对其进行了包装。如果这里删除了，但是LUA没删除，就会导致错误；
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
        
        public void Send(IRequest request)
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
}





