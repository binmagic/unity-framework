/**
 * [INPUT]: 依赖 Sfs2X.Entities.Data 的 ISFSObject 服务端数据对象
 * [OUTPUT]: 对外提供 BaseDataContainer 抽象基类,定义 Init/Update/Release 与可重写的 CSInit/CSUpdate 钩子
 * [POS]: Data 层的数据容器基类,统一 C# 侧数据对象与 SmartFox 消息的注入契约,被 DCPlayer/DCBuilding 继承
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using Sfs2X.Entities.Data;

public abstract class BaseDataContainer
{

    public void Update(ISFSObject obj)
    {
        CSUpdate(obj);
    }

    public void Init(ISFSObject obj)
    {
        CSInit(obj);
    }

    public virtual void CSUpdate(ISFSObject obj)
    {

    }

    public virtual void CSInit(ISFSObject obj)
    {

    }

    public virtual void Release()
    {

    }
}





