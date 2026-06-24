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





