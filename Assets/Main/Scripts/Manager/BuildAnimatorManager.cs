/**
 * [INPUT]: 依赖 GameEntry.Timer 获取服务器时间作为建造计时基准
 * [OUTPUT]: 对外提供 BuildAnimatorManager,维护建筑升级/建造的进度时间数据
 * [POS]: Manager 层的建筑动画状态管理器,由 GameEntry.BuildAnimatorManager 持有,为城建表现层提供正在建造建筑的起止时间查询
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using System.Collections;
using System.Collections.Generic;

public class BuildAnimatorManager
{
    public class BuildAnimatorParam
    {
        public long startTime;
        public long endTime;
        public int posIndex;
    }

    private Dictionary<int, BuildAnimatorParam> _buildBuilding;//正在升级的建筑
    
    
    
    public BuildAnimatorManager()
    {
        _buildBuilding = new Dictionary<int, BuildAnimatorParam>();
    }

    public void Shutdown()
    {
        _buildBuilding = new Dictionary<int, BuildAnimatorParam>();
    }
    
    //正在建造的建筑
    public void AddOneBuild(int posIndex,long startTime = -1,long endTime = -1)
    {
        if (startTime <= 0 && endTime <= 0)
        {
            startTime = GameEntry.Timer.GetServerTime();
            endTime = startTime + 10000;
        }

        if (_buildBuilding.ContainsKey(posIndex))
        {
            _buildBuilding[posIndex].startTime = startTime;
            _buildBuilding[posIndex].endTime = endTime;
        }
        else
        {
            var param = new BuildAnimatorParam()
            {
                startTime = startTime,
                endTime = endTime,
                posIndex = posIndex,
            };
            _buildBuilding.Add(posIndex,param);
        }
    }
    
    //建造结束
    public void RemoveOneBuild(int posIndex)
    {
        if (_buildBuilding.ContainsKey(posIndex))
        {
            _buildBuilding.Remove(posIndex);
        }
    }

    //获取正在建造的时间数据
    public BuildAnimatorParam GetBuildingParam(int posIndex)
    {
        if (_buildBuilding.ContainsKey(posIndex))
        {
            return  _buildBuilding[posIndex];
        }

        return null;
    }
    
    //是否正在建造
    public bool IsBuilding(int posIndex)
    {
        return _buildBuilding.ContainsKey(posIndex);
    }
    

}





