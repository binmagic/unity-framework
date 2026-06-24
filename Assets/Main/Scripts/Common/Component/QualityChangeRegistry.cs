// /***
//  * Created by zhangliheng.
//  * DateTime: 2024/08/16 13:38 PM
//  * Description:
//  ***/


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





