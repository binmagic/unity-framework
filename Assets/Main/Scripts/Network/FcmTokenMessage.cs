/**
 * [INPUT]: 依赖 BaseMessage 收发骨架，依赖 GameEntry.Network 的 FutureManager 分配 futureId，依赖 SmartFox2X 组包
 * [OUTPUT]: 对外提供 FcmTokenMessage 类（消息号 change.user.parseid），上报 Firebase 推送 token 与 appId 用于消息推送寻址
 * [POS]: Network 消息定义层的一员，与其余 *Message 平级，由 MessageFactory 注册分发；对接推送体系，与 PushRecordMessage 同属推送相关消息
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using UnityEngine;
using XLua;
using UnityGameFramework.Runtime;

[UnityEngine.Scripting.Preserve]
public class FcmTokenMessage : BaseMessage
{
    public class Request
    {
        public string token;
        public string fireabaseAppId;
    }

    public static FcmTokenMessage Instance;
    public FcmTokenMessage()
    {
        Instance = this;
    }
    public override string GetMsgId()
    {
        return "change.user.parseid";
    }

    protected override IRequest CSSetData(params object[] args)
    {
        var req = args[0] as Request;

        ISFSObject retObj = new SFSObject();
        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        retObj.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        if (!req.token.IsNullOrEmpty() && !req.token.Equals("|") && !req.token.Equals("|fcm"))
        {
            retObj.PutUtfString("parseRegisterId", req.token);
        }
        if (!req.fireabaseAppId.IsNullOrEmpty())
        {
            retObj.PutUtfString("fireabaseAppId", req.fireabaseAppId);
        }

        return new ExtensionRequest(GetMsgId(), retObj);
    }
    protected override void CSHandleResponse(ISFSObject message)
    {

    }
}





