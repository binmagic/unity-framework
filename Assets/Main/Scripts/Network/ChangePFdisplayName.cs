using System;
using System.Text;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using UnityEngine;

[UnityEngine.Scripting.Preserve]
public class ChangePFdisplayName : BaseMessage
{
    public static ChangePFdisplayName Instance;


    public ChangePFdisplayName()
    {
        Instance = this;
    }
    public override string GetMsgId()
    {
        return "user.modify.nickName.google";
    }

    protected override IRequest CSSetData(params object[] args)
    {
        PostEventLog.Record("google_signin_c_send");
        SFSObject so = new SFSObject();
        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        so.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        so.PutUtfString("nickName", GameEntry.Sdk.pf_displayname);
        return new ExtensionRequest(GetMsgId(), so);
    }

    protected override void CSHandleResponse(ISFSObject message)
    {
        if (message.ContainsKey("errorMessage"))
        {
            return;
        }
        
        string newName = message.GetText("newName");
        PostEventLog.Record("google_signin_c_get_" + newName);
        GameEntry.Lua.SetValue<string>("LuaEntry.Player", "nickName", newName);
    }
}





