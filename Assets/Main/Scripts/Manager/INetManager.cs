using System;
using GameKit.Base;
using Sfs2X.Core;

public interface INetManager
{
    bool OnConnection(INetProxy proxy, BaseEvent e);
    void OnConnectionLost(string reason, INetProxy proxy);
    void OnLogout(BaseEvent e);
    void OnLogin(BaseEvent e);
    void OnLoginError(BaseEvent e);
}





