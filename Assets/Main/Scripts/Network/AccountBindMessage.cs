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





