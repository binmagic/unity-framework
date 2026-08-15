/**
 * [INPUT]: 依赖 BaseMessage 的请求收发骨架，依赖 GameEntry.Network 的 FutureManager 分配 futureId，依赖 SmartFox2X 的 SFSObject/ExtensionRequest 组包
 * [OUTPUT]: 对外提供 UserBindGaidMessage 类（消息号 bind.gaid），上报广告标识 gaid 完成账号绑定
 * [POS]: Network 消息定义层的一员，与其余 *Message 平级，由 MessageFactory 注册并统一分发；标记 [Hotfix] 支持 XLua 热修
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using UnityEngine;
using XLua;

[Hotfix]
[UnityEngine.Scripting.Preserve]
public class UserBindGaidMessage : BaseMessage
{
    public class Request
    {
        public string gaid;
    }
    public static UserBindGaidMessage Instance;
    public UserBindGaidMessage()
    {
        Instance = this;
    }
    public override string GetMsgId()
    {
        return "bind.gaid";
    }

    protected override IRequest CSSetData(params object[] args)
    {
        var req = args[0] as Request;
        ISFSObject retObj = new SFSObject();
        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        retObj.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        retObj.PutUtfString("gaid", req.gaid);
        return new ExtensionRequest(GetMsgId(), retObj);
    }
    protected override void CSHandleResponse(ISFSObject message)
    {

    }
}





