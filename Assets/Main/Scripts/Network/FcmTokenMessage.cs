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





