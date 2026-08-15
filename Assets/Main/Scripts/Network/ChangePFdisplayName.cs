/**
 * [INPUT]: 依赖 BaseMessage 收发骨架，依赖 GameEntry.Sdk.pf_displayname 取平台昵称、GameEntry.Lua 回写玩家昵称，依赖 PostEventLog 埋点、SmartFox2X 组包
 * [OUTPUT]: 对外提供 ChangePFdisplayName 类（消息号 user.modify.nickName.google），把 Google 平台昵称同步到服务端并更新本地 Player
 * [POS]: Network 消息定义层的一员，与其余 *Message 平级，由 MessageFactory 注册分发；专责第三方登录昵称落地
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





