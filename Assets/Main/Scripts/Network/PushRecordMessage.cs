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





