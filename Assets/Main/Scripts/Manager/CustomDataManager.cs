/**
 * [INPUT]: 依赖 BaseDataContainer 及其子类(DCPlayer/DCBuilding)的数据容器能力
 * [OUTPUT]: 对外提供 CustomDataManager,聚合并统一管理玩家自身各类业务数据容器
 * [POS]: Manager 层的玩家数据聚合入口,按类型注册并托管各 DataContainer 的生命周期,是 C# 侧玩家数据的门面
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;

//
// 玩家自己的数据
//
public class CustomDataManager
{
    private readonly Dictionary<string, BaseDataContainer> m_Datas = new Dictionary<string, BaseDataContainer>();

    private T AddData<T>() where T : BaseDataContainer
    {
        string typeName = typeof(T).Name;
        T t = System.Activator.CreateInstance(typeof(T)) as T;
        m_Datas[typeName] = t;

        return t;
    }
    
    public CustomDataManager()
    {
        Reset();
    }
    
    public void Release()
    {
        foreach (var d in m_Datas.Values)
        {
            d.Release();
        }

        m_Datas.Clear();
    }

    public void Reset()
    {
        Player = AddData<DCPlayer>();
        Building = AddData<DCBuilding>();
        //Fog = AddData<DCFog>();
        //Road = AddData<DCRoad>();
    }

    public DCPlayer Player
    {
        get;
        private set;
    }
    public DCBuilding Building
    {
        get;
        private set;
    }
    
    // public DCFog Fog
    // {
    //     get;
    //     private set;
    // }
    
    // public DCRoad Road
    // {
    //     get;
    //     private set;
    // }
    
}





