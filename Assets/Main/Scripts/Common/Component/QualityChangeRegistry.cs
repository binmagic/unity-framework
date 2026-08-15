// /***
//  * Created by zhangliheng.
//  * DateTime: 2024/08/16 13:38 PM
//  * Description:
//  ***/

/**
 * [INPUT]: 依赖 GameEntry.Event 订阅 EventId.QualityChange，经 SceneQualitySetting.GetGraphicLevel 读画质档位，管理 QualityLimit 监听者
 * [OUTPUT]: 对外提供 QualityChangeRegistry 单例的 Register/Unregister 与 GetLastGraphicLevel，画质变更时统一刷新所有登记的 QualityLimit
 * [POS]: Common/Component 的画质变更调度中枢(非 MonoBehaviour 单例)，是 QualityLimit 组件与框架事件系统之间的注册表，用临时字典快照防遍历中增删
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections.Generic;

public class QualityChangeRegistry
{
    private static QualityChangeRegistry _instance;
    public static QualityChangeRegistry Instance => _instance ??= new QualityChangeRegistry();
    private readonly Dictionary<int, QualityLimit> _children = new Dictionary<int, QualityLimit>(16);
    private int _lastGraphicLevel = 1;
    
    private readonly Dictionary<int, QualityLimit> _tmpDict = new Dictionary<int, QualityLimit>(16);

    public void Init()
    {
        _lastGraphicLevel = SceneQualitySetting.GetGraphicLevel();
        GameEntry.Event.Subscribe(EventId.QualityChange, OnQualityChange);
    }

    public void UnInit()
    {
        GameEntry.Event.Subscribe(EventId.QualityChange, OnQualityChange);
    }

    public void Register(QualityLimit listener)
    {
        _children.Add(listener.GetInstanceID(), listener);
        listener.Refresh(_lastGraphicLevel);
    }

    public void Unregister(QualityLimit listener)
    {
        _children.Remove(listener.GetInstanceID());
    }
    
    
    public int GetLastGraphicLevel()
    {
        return _lastGraphicLevel;
    }
    
    private void OnQualityChange(object data)
    {
        int curGraphicLv = SceneQualitySetting.GetGraphicLevel();
        if (curGraphicLv == _lastGraphicLevel)
        {
            return;
        }
        
        _lastGraphicLevel = curGraphicLv;

        _tmpDict.Clear();
        foreach (var iter in _children)
        {
            _tmpDict.Add(iter.Key, iter.Value);
        }
        
        foreach (var t in _tmpDict)
        {
            t.Value.Refresh(curGraphicLv);
        }
    }
}





