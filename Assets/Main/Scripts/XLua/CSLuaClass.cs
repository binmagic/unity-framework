/**
 * [INPUT]: 依赖 UnityEngine 基础
 * [OUTPUT]: 对外提供 LuaBuildData 等 POCO,承载 C# 调用 Lua 时返回的固定结构(如建筑数据)
 * [POS]: XLua 的跨语言数据载体,给 DCBuilding 等 Data 层做强类型返回,避免 LuaTable 反复解包的开销
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

/// <summary>
// 用于C#调用lua返回一些固定结构
/// </summary>

public class LuaBuildData
{
    public long uuid;//建筑uuid
    public int pointId;//建筑坐标点
    public int state;//建筑状态
    public int buildId;//建筑id
    public int level;//建筑等级
    public int connect;//连接状态
    public long buildUpdateTime;//研究结束时间

    public LuaBuildData(long uid, long updateTime,int point, int tempState, int itemId, int lv,int tempConnect)
    {
        uuid = uid;
        buildUpdateTime = updateTime;
        pointId = point;
        state = tempState;
        buildId = itemId;
        level = lv;
        connect = tempConnect;
    }

    public LuaBuildData()
    {
        
    }

    public bool IsActive()
    {
        return state != (int) BuildingStateType.FoldUp && level > 0;
    }
}





