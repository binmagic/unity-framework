/**
 * [INPUT]: 依赖 BaseMessage 收发骨架，依赖 GameEntry.Network 的 FutureManager、SmartFox2X 组包，响应时依赖 PushManager 清理本地推送缓存
 * [OUTPUT]: 对外提供 PushRecordMessage 类（消息号 push.record），上报推送到达/点击埋点数据并在回执后清缓存
 * [POS]: Network 消息定义层的一员，与其余 *Message 平级，由 MessageFactory 注册分发；与 FcmTokenMessage 同属推送体系，负责推送效果回收
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;

[UnityEngine.Scripting.Preserve]
public class PushRecordMessage : BaseMessage
{
    public class Request
    {
        public string record;
        public string click;
    }

    public static PushRecordMessage Instance;
    public PushRecordMessage()
    {
        Instance = this;
    }
    public override string GetMsgId()
    {
        return "push.record";
    }

    protected override IRequest CSSetData(params object[] args)
    {
        var req = args[0] as Request;
        ISFSObject retObj = new SFSObject();

        retObj.PutUtfString("pushRecordData", req.record);
        retObj.PutUtfString("pushClickData", req.click);

        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        retObj.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        return new ExtensionRequest(GetMsgId(), retObj);
    }
    protected override void CSHandleResponse(ISFSObject message)
    {
        PushManager.Instance.clearPushCache();
    }
}





