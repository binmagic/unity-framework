/**
 * [INPUT]: 依赖 INetProxy 作为连接主体,依赖 Sfs2X.Core.BaseEvent(原生平台)传递连接/登录事件
 * [OUTPUT]: 对外提供 INetManager 接口,定义连接建立/丢失、登录/登出/登录失败的回调契约
 * [POS]: Manager 网络族的上层契约,由 NetworkManager 实现、被各 NetProxy 回调,通过 #if 区分原生(SFS 事件)与 WebGL(拆解参数)两套签名
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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
