/**
 * [INPUT]: 依赖 GameEntry.Network 的发送通道与 FutureManager，依赖 SmartFox2X 的 SFSObject/ExtensionRequest，依赖 UIUtils 展示错误、GameEntry.Event 派发 ServerError
 * [OUTPUT]: 对外提供抽象基类 BaseMessage，定义 Send/Handle 收发模板与 CSSetData/CSHandleResponse 扩展点及统一错误码处理
 * [POS]: Network 消息定义层的根基，所有具体 *Message 均继承它以复用组包与错误处理，是本模块的抽象契约
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using GameFramework;

[UnityEngine.Scripting.Preserve]
public abstract class BaseMessage
{
    public abstract string GetMsgId();
    
    public virtual void Handle(ISFSObject message)
    {
        if (message.ContainsKey("errorCode"))
        {
            if (showErrorCode())
            {
                ShowErrorMessage(message);
            }
            GameEntry.Event.Fire(EventId.ServerError, GetMsgId());
            //return;//错误处理return会导致对应模块无法处理。 zbc 2019.4.11
        }

        CSHandleResponse(message);
    }

    private static void ShowErrorMessage(ISFSObject message)
    {
        var code = message.GetUtfString("errorCode");
        string[] paras = null;
        if (message.ContainsKey("errorPara2"))
        {
            paras = message.GetUtfStringArray("errorPara2");
        }
        if(code == "E190003")//资源不足
        {
            UIUtils.ShowTips("120246");
        }
        else if(code == "E100173")//队列已完成
        {
        }
        else if (paras == null)
        {
            UIUtils.ShowTips(code);
        }
        else
        {
            UIUtils.ShowTips(code,3f, paras);
        }
    }

    public virtual void Send(params object[] args)
    {
        try
        {
            var request = CSSetData(args);
            //if (CommonUtils.IsDebug())
            //{
            //    Log.Warning(string.Format("<color=green>send msg <{0}> |</color>", GetMsgId()));
            //}
            GameEntry.Network.Send(request);
        }catch (System.Exception e){
            Log.Error("send msg {0} error, {1}", GetMsgId(), e);
        }
    }

    protected virtual void CSHandleResponse(ISFSObject message)
    {

	}

    protected virtual IRequest CSSetData(params object[] args)
    {
        ISFSObject sfsObj = new SFSObject();
        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        sfsObj.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        return new ExtensionRequest(GetMsgId(), sfsObj);
    }

    protected virtual bool showErrorCode(){
        return false;
    }
}





