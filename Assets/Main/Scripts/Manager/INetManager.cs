using System;
using GameKit.Base;
#if !UNITY_WEBGL
using Sfs2X.Core;
#endif

public interface INetManager
{
#if !UNITY_WEBGL
    bool OnConnection(INetProxy proxy, BaseEvent e);
    void OnConnectionLost(string reason, INetProxy proxy);
    void OnLogout(BaseEvent e);
    void OnLogin(BaseEvent e);
    void OnLoginError(BaseEvent e);
#else
    // WebGL: 使用简化签名，不依赖 SFS BaseEvent
    bool OnConnection(INetProxy proxy, bool success, int errorCode, string errorMessage);
    void OnConnectionLost(string reason, INetProxy proxy);
    void OnLogout();
    void OnLogin(object data);
    void OnLoginError(int errorCode, string errorMessage);
#endif
}
