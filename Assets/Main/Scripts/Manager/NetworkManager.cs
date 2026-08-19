using System;
using System.Buffers;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using GameFramework;
using GameKit.Base;
using Main.Scripts.Network;
#if !UNITY_WEBGL
using Sfs2X;
using Sfs2X.Core;
#endif
using Sfs2X.Requests;
using Sfs2X.Entities.Data;
using UnityEngine;
using UnityEngine.Networking;

public class NetworkManager : IGameController, INetManager
{
    // 使用后一个全局的发送缓冲
    private byte[] send_buffer = new byte[2*8192];

    public NetworkManager()
    {
        MessageFactory.Instance.InitMessageHandlers();
        _futureManager = new FutureManager();
    }

    public string GetGameServerUrl()
    {
        var url = GameEntry.Lua.CallWithReturn<string>("LuaEntry.Network:GetGameServerUrl");
        return url;
    }

    public int GetGameServerPort()
    {
        var port = GameEntry.Lua.CallWithReturn<int>("LuaEntry.Network:GetGameServerPort");
        return port;
    }

    public string GetUid()
    {
        var uid = GameEntry.Lua.CallWithReturn<string>("LuaEntry.Network:GetUid");
        return uid;
    }

    public void OnUpdate(float elapseSeconds)
    {
    }

    public void Shutdown()
    {
        Log.Info("net work shut down");
    }

    public FutureManager getFutureManager()
    {
        return _futureManager;
    }

    public string getCurLine()
    {
        if (_curProxyCache == null)
        {
            return "noline";
        }

        return _curProxyCache.proxyName;
    }

#if !UNITY_WEBGL
    static public bool GetTcpNoDelay()
    {
        return SmartFox.TcpNoDelay;
    }

    static public void SetTcpNoDelay(bool b)
    {
        SmartFox.TcpNoDelay = b;
    }

    static public void SetUseAsyncTcp(int t)
    {
        SmartFox.UseAsyncTcp = t;
    }

    static public int GetUseAsyncTcp()
    {
        return SmartFox.UseAsyncTcp;
    }
#else
    // WebGL: SmartFox 不可用，返回默认值
    static public bool GetTcpNoDelay() => false;
    static public void SetTcpNoDelay(bool b) { }
    static public void SetUseAsyncTcp(int t) { }
    static public int GetUseAsyncTcp() => 0;
#endif

    #region SmartFoxClient

    private readonly FutureManager _futureManager;
    private INetProxy _curProxyCache; // 当前连接服务器的netproxy，每次在OnConnection的时候会重置

    // 这个函数由Lua调用，lua初始化完毕之后，会调用此接口设置一个合适的proxy
    public void SetCurProxy(INetProxy curProxy)
    {
        Log.Info("[NET] SetCurProxy");
        _curProxyCache = curProxy;

        if (curProxy != null)
        {
            Log.Info("[NET] SetCurProxy - {0}", curProxy.proxyName);
        }
        else
        {
            Log.Info("[NET] SetCurProxy - NULL");
        }
    }

    public bool IsConnected()
    {
        if (_curProxyCache != null)
        {
            return _curProxyCache.IsConnected;
        }

        return false;
    }

#if !UNITY_WEBGL
    public void Send(IRequest request)
    {
        if (_curProxyCache != null)
        {
            _curProxyCache.Send(request);
        }
        else
        {
            Debug.Log("!!no proxy but send!!");
        }
    }

    public void SendLuaMessage(string msgId, byte[] sfsObjBinary)
    {
        SFSObject sfsObj;
        if (sfsObjBinary != null)
        {
            sfsObj = SFSObject.NewFromBinaryData(new Sfs2X.Util.ByteArray(sfsObjBinary, 0, sfsObjBinary.Length));
        }
        else
        {
            sfsObj = SFSObject.NewInstance();
        }

        int fuId = _futureManager.getFutureId();
        sfsObj.PutInt("_id", fuId);
        _futureManager.onSendRequest(fuId, msgId);
        Send(new ExtensionRequest(msgId, sfsObj));
    }
#else
    // WebGL: 无 SmartFox 客户端，手动执行 Execute 填充内部 SFSObject 后序列化，通过 WebSocket 发送。
    // ExtensionRequest.Execute 不使用 sfs 参数；LoginRequest 仅在有密码时用 sfs，本项目登录用 params(password 为空)，故传 null 安全。
    public void Send(IRequest request)
    {
        if (_curProxyCache == null)
        {
            Debug.Log("!!no proxy but send!!");
            return;
        }

        request.Execute(null);
        var content = request.Message.Content; // {c, r, p} 的 SFSObject，等价于原生上行 payload
        var ba = content.ToBinary();
        _curProxyCache.Send(ba.GetRawBytes(), ba.DataLength);
    }

    // WebGL: 不使用 SFS ExtensionRequest，直接发送原始字节
    // 注意: WebGL 下 Lua 层应直接使用 SendLuaMessageEx（走 byte[] 通道）
    public void SendLuaMessage(string msgId, byte[] sfsObjBinary)
    {
        Debug.LogWarning("[NET] SendLuaMessage via SFS path not supported on WebGL, use SendLuaMessageEx instead");
    }
#endif

    // 消息在Lua栈上，这里发送的时候到C里去组合，增加效率
    public bool SendLuaMessageEx()
    {
        bool retBool = false;
        IntPtr baBytes = XLua.LuaDLL.Lua.GetStackTopBufLen(GameEntry.Lua.Env.L, out var len);
        int dataLength = (int)len;
        if (dataLength == 0)
        {
            Debug.LogError("SendLuaMessageEx Native Error [1]!");
            return false;
        }

        if (dataLength > 10 * 1024 * 1024)
        {
            Debug.LogErrorFormat("SendLuaMessageEx data too big! {0}", dataLength);
            return false;
        }

        // 一般来讲，消息都会小于16KB
        byte[] buffer;
        if (dataLength >= send_buffer.Length)
        {
            buffer = new byte[dataLength];
        }
        else
        {
            buffer = send_buffer;
        }

        try
        {
            var ret = XLua.LuaDLL.Lua.CopyAndFreeStackTopBuf(GameEntry.Lua.Env.L, baBytes, buffer, dataLength);
            if (ret == 0)
            {
                Debug.LogError("data length is 0?");
            }
            else
            {
                if (_curProxyCache != null)
                {
                    _curProxyCache.Send(buffer, dataLength);
                    retBool = true;
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogErrorFormat("SendLuaMessageEx exception: {0}", e.Message);
        }

        return retBool;
    }

    // ========== INetManager 实现 ==========

#if !UNITY_WEBGL
    // ---- 原生平台 (iOS/Android/PC): 使用 SFS BaseEvent ----

    public bool OnConnection(INetProxy proxy, BaseEvent e)
    {
        UnityEngine.Debug.Log($"OnConnection! proxyName:{proxy.proxyName}");
        try
        {
            if (e.Params == null)
            {
                UnityEngine.Debug.LogError("OnConnection - e.Params null???");
                return false;
            }

            if (GameEntry.Lua == null)
            {
                UnityEngine.Debug.LogError("OnConnection - no Lua???");
                return false;
            }

            bool success = false;
            if (e.Params.Contains("success"))
            {
                success = (bool) e.Params["success"];
            }

            if (success)
            {
                var ret = GameEntry.Lua.CallWithReturn<bool, INetProxy>("LuaEntry.Network:OnConnection", proxy);
                return ret;
            }
            else
            {
                var errCode = -1;
                string errorMessage = "";

                if (e.Params.Contains("errorCode"))
                {
                    errCode = (int) e.Params["errorCode"];
                }

                if (e.Params.Contains("errorMessage"))
                {
                    errorMessage = (string) e.Params["errorMessage"];
                }
                GameEntry.Lua.Call("LuaEntry.Network:OnConnectionError", proxy, errCode, errorMessage);
            }
        }
        catch (Exception excep)
        {
            Debug.LogErrorFormat("OnConnection exception! {0}\n{1}", excep.Message, excep.StackTrace);
        }

        return false;
    }

    public void OnConnectionLost(string reason, INetProxy proxy)
    {
        UnityEngine.Debug.Log("OnConnectionLost");
        try
        {
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.Call("LuaEntry.Network:OnConnectionLost", reason, proxy);
            }
            else
            {
                UnityEngine.Debug.LogError("OnConnectionLost - no Lua???");
                return;
            }
        }
        catch (Exception e)
        {
            Debug.LogErrorFormat("OnConnectionLost exception! {0}", e.Message);
        }
    }

    public void OnLogin(BaseEvent e)
    {
        var so = e.Params["data"] as SFSObject;
        if (so == null)
        {
            Log.Error("Login failed");
            GameEntry.Lua.Call("LuaEntry.Network:OnLogin", (object)null);
            return;
        }
#if UNITY_EDITOR
        Log.Debug("OnLogin: " + so.ToJson());
#endif
        GameEntry.Lua.Call("LuaEntry.Network:OnLogin", so.ToLuaTable(GameEntry.Lua.Env));
        return;
    }

    public void OnLoginError(BaseEvent e)
    {
        int errCode = 0;
        string errorMessage = "";
        try
        {
            errCode = (int) (short) e.Params["errorCode"];
            errorMessage = (string) e.Params["errorMessage"];
        }
        catch (Exception excep)
        {
            Debug.LogErrorFormat("OnLoginError exception! {0}", excep);
            errCode = -1;
            errorMessage = excep.Message;
        }
        finally
        {
            GameEntry.Lua.Call("LuaEntry.Network:OnLoginError", errCode, errorMessage);
        }
    }

    public void OnLogout(BaseEvent e)
    {
        GameEntry.Lua.Call("LuaEntry.Network:OnLogout");
    }

#else
    // ---- WebGL (微信小游戏): 不使用 SFS BaseEvent，参数已拆解 ----

    public bool OnConnection(INetProxy proxy, bool success, int errorCode, string errorMessage)
    {
        UnityEngine.Debug.Log($"[WebGL] OnConnection! proxyName:{proxy.proxyName} success:{success}");
        try
        {
            if (GameEntry.Lua == null)
            {
                UnityEngine.Debug.LogError("OnConnection - no Lua???");
                return false;
            }

            if (success)
            {
                var ret = GameEntry.Lua.CallWithReturn<bool, INetProxy>("LuaEntry.Network:OnConnection", proxy);
                return ret;
            }
            else
            {
                GameEntry.Lua.Call("LuaEntry.Network:OnConnectionError", proxy, errorCode, errorMessage);
            }
        }
        catch (Exception excep)
        {
            Debug.LogErrorFormat("OnConnection exception! {0}\n{1}", excep.Message, excep.StackTrace);
        }

        return false;
    }

    public void OnConnectionLost(string reason, INetProxy proxy)
    {
        UnityEngine.Debug.Log("[WebGL] OnConnectionLost");
        try
        {
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.Call("LuaEntry.Network:OnConnectionLost", reason, proxy);
            }
        }
        catch (Exception e)
        {
            Debug.LogErrorFormat("OnConnectionLost exception! {0}", e.Message);
        }
    }

    public void OnLogin(object data)
    {
        // WebGL: data 已经是 LuaTable 或 null
        if (data == null)
        {
            Log.Error("[WebGL] Login failed");
            GameEntry.Lua.Call("LuaEntry.Network:OnLogin", (object)null);
            return;
        }
        GameEntry.Lua.Call("LuaEntry.Network:OnLogin", data);
    }

    public void OnLoginError(int errorCode, string errorMessage)
    {
        GameEntry.Lua.Call("LuaEntry.Network:OnLoginError", errorCode, errorMessage);
    }

    public void OnLogout()
    {
        GameEntry.Lua.Call("LuaEntry.Network:OnLogout");
    }
#endif

    #endregion
}
