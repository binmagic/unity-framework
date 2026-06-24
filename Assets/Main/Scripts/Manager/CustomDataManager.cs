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





