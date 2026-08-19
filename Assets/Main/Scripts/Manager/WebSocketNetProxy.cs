#if UNITY_WEBGL
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using GameFramework;
using Sfs2X.Entities.Data;
using Sfs2X.Util;
using UnityEngine;

namespace GameKit.Base
{
    /// <summary>
    /// 微信小游戏 WebSocket 网络代理
    /// 替代 TCP 版本的 NetProxy，传输层使用 WebSocket，协议格式仍为 SFSObject 二进制
    /// </summary>
    public class WebSocketNetProxy : INetProxy
    {
        // JsBridge 外部声明
        [DllImport("__Internal")]
        private static extern void ws_connect(string url, string callbackObj, string callbackMethod);

        [DllImport("__Internal")]
        private static extern void ws_send(byte[] data, int length);

        [DllImport("__Internal")]
        private static extern void ws_close();

        // 心跳相关
        private float _sendPingPongCounter = 0f;
        private float lastPingPongTime;
        public float _sendPingPongInterval = 5.0f;
        public int offMaxTime = 16;

        public string proxyName { get; private set; }
        private string host;
        private int port;
        private string wsUrl;
        private INetManager parent;

        public ProxyStatus Status { get; private set; }

        // 消息队列 — WebSocket 回调在 JS 线程，需要在主线程处理
        private readonly Queue<byte[]> _receiveQueue = new Queue<byte[]>();
        private readonly object _queueLock = new object();

        // 连接状态回调队列
        private enum WsCallbackType { Connected, Disconnected, Error }
        private struct WsCallback
        {
            public WsCallbackType type;
            public string data;
        }
        private readonly Queue<WsCallback> _callbackQueue = new Queue<WsCallback>();

        public WebSocketNetProxy(string name, string h, int p, INetManager net)
        {
            this.proxyName = name;
            this.host = h;
            this.port = p;
            this.parent = net;
            this.Status = ProxyStatus.init;

            // 构造 WebSocket URL — SmartFox2X Server WebSocket 端口通常比 TCP 端口大 1
            // 例如 TCP 9933 → WS 9934, 或使用配置的端口
            this.wsUrl = $"ws://{h}:{p}";
            Log.Info("[WebSocketNetProxy] created: {0} url={1}", name, wsUrl);
        }

        public bool IsConnected => Status == ProxyStatus.connected;
        public bool IsConnecting => Status == ProxyStatus.connecting;

        public void Connect()
        {
            SyncPingPong();
            Status = ProxyStatus.connecting;
            Log.Info("[WebSocketNetProxy] Connect to {0}", wsUrl);

            try
            {
                ws_connect(wsUrl, "WebSocketNetProxy", "OnWsCallback");
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] Connect exception: {0}", e.Message);
                Status = ProxyStatus.connectError;
            }
        }

        public void Disconnect()
        {
            Log.Info("[WebSocketNetProxy] Disconnect {0}", proxyName);
            try
            {
                ws_close();
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] Disconnect exception: {0}", e.Message);
            }
            Status = ProxyStatus.init;
        }

        public void Send(byte[] data, int dataLen)
        {
            if (Status != ProxyStatus.connected)
            {
                Log.Warning("[WebSocketNetProxy] Send while not connected, ignored");
                return;
            }

            try
            {
                if (dataLen == data.Length)
                {
                    ws_send(data, dataLen);
                }
                else
                {
                    // 需要截取
                    byte[] trimmed = new byte[dataLen];
                    Buffer.BlockCopy(data, 0, trimmed, 0, dataLen);
                    ws_send(trimmed, dataLen);
                }
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] Send exception: {0}", e.Message);
            }
        }

        // IRequest 版本 — WebGL 接口中已 #if 掉，此方法不应被调用
        // 但为安全起见提供一个空实现（不会被编译进接口）

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
                    return false;
                if (offMaxTime > 0 && lastPingPongTime + offMaxTime < Time.realtimeSinceStartup)
                    return true;
                return false;
            }
        }

        public void UpdateSmartFoxClient()
        {
            // 处理连接/断开回调
            lock (_callbackQueue)
            {
                while (_callbackQueue.Count > 0)
                {
                    var cb = _callbackQueue.Dequeue();
                    switch (cb.type)
                    {
                        case WsCallbackType.Connected:
                            Status = ProxyStatus.connected;
                            Log.Info("[WebSocketNetProxy] Connected!");
                            parent.OnConnection(this, true, 0, "");
                            break;
                        case WsCallbackType.Disconnected:
                            Status = ProxyStatus.connectError;
                            parent.OnConnectionLost(cb.data ?? "disconnected", this);
                            break;
                        case WsCallbackType.Error:
                            Status = ProxyStatus.connectError;
                            parent.OnConnectionLost(cb.data ?? "error", this);
                            break;
                    }
                }
            }

            // 处理接收消息队列
            lock (_queueLock)
            {
                while (_receiveQueue.Count > 0)
                {
                    byte[] data = _receiveQueue.Dequeue();
                    try
                    {
                        ProcessReceivedData(data);
                    }
                    catch (Exception e)
                    {
                        Log.Error("[WebSocketNetProxy] ProcessReceivedData error: {0}", e.Message);
                    }
                }
            }

            // 心跳
            _sendPingPongCounter += Time.deltaTime;
            if (_sendPingPongCounter >= _sendPingPongInterval)
            {
                _sendPingPongCounter = 0;
                SendPingPongMessage();
            }
        }

        private void ProcessReceivedData(byte[] data)
        {
            if (data == null || data.Length == 0)
                return;

            // 尝试解析为 SFSObject — SFS WebSocket 协议格式
            // SmartFox2X WebSocket 消息格式: [2 bytes header length][header][payload]
            // 简化处理: 直接将整个 data 传给 MessageFactory 的 byte[] 分发
            try
            {
                var ba = new ByteArray(data, 0, data.Length);
                // SFS WebSocket 消息结构: 第一个字节是消息类型
                // 0x00 = System/Control, 0x01 = Extension
                // 实际格式取决于 SFS Server 配置
                // 这里假设已经过 JsBridge 预处理，直接是 Extension 消息的 cmd + rawData
                MessageFactory.Instance.DispatchResponse("", data);
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] Parse SFS data error: {0}", e.Message);
            }
        }

        private void SendPingPongMessage()
        {
            // 构造心跳包 — SFSObject 格式
            try
            {
                var sfsObj = SFSObject.NewInstance();
                sfsObj.PutUtfString("t", "ping");
                var ba = new ByteArray();
                sfsObj.ToBinary(ba);
                byte[] bytes = ba.GetBytes();
                Send(bytes, bytes.Length);
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] SendPingPong error: {0}", e.Message);
            }
        }

        // ========== JsBridge 回调方法（由 JS 调用） ==========

        /// <summary>
        /// WebSocket 连接成功回调 — 由 JsBridge 调用
        /// </summary>
        public void OnWsOpen()
        {
            lock (_callbackQueue)
            {
                _callbackQueue.Enqueue(new WsCallback { type = WsCallbackType.Connected });
            }
        }

        /// <summary>
        /// WebSocket 收到消息回调 — 由 JsBridge 调用
        /// </summary>
        public void OnWsMessage(string base64Data)
        {
            try
            {
                byte[] data = Convert.FromBase64String(base64Data);
                lock (_queueLock)
                {
                    _receiveQueue.Enqueue(data);
                }
            }
            catch (Exception e)
            {
                Log.Error("[WebSocketNetProxy] OnWsMessage decode error: {0}", e.Message);
            }
        }

        /// <summary>
        /// WebSocket 连接关闭回调 — 由 JsBridge 调用
        /// </summary>
        public void OnWsClose(string reason)
        {
            lock (_callbackQueue)
            {
                _callbackQueue.Enqueue(new WsCallback { type = WsCallbackType.Disconnected, data = reason });
            }
        }

        /// <summary>
        /// WebSocket 错误回调 — 由 JsBridge 调用
        /// </summary>
        public void OnWsError(string error)
        {
            lock (_callbackQueue)
            {
                _callbackQueue.Enqueue(new WsCallback { type = WsCallbackType.Error, data = error });
            }
        }
    }
}
#endif
