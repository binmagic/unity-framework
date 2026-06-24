using System.Collections.Generic;
using Sfs2X.Entities.Data;
using XLua;

[UnityEngine.Scripting.Preserve]
public class DCPlayer : BaseDataContainer
{
    // uid和serverId可以缓存一份
    // 一方面是用的实在太多，另一方面是只有这两个值是不变的；其中serverId表示玩家账号所在的服务器
    // 其他值就不要缓存了，需要的话从LUA端去获取
    public string Uid;
    public int serverId;
    public int crossServerId = -1;

    public string GetUid()
    {
        return Uid;
    }

    // 获取我账号服的服务器id
    public int GetSelfServerId()
    {
        return serverId;
    }

    public int GetCrossServerId()
    {
        return crossServerId;
    }

    public int GetCurServerId()
    {
        if (crossServerId >= 0)
        {
            return crossServerId;
        }

        return serverId;
    }

    public string GetAllianceId()
    {
        string allianceId = GameEntry.Lua.CallWithReturn<string>("LuaEntry.Player:GetAllianceUid");
        return allianceId;
    }

    public T GetValue<T>(string strKey)
    {
        // return GameEntry.Lua.CallWithReturn<T, string>("LuaEntry.Player:GetValue", strKey);
        return GameEntry.Lua.GetValue<T>("LuaEntry.Player", strKey);
    }
    
    public void SetValue<T>(string strKey, T value)
    {
        GameEntry.Lua.SetValue("LuaEntry.Player", strKey, value);
        // GameEntry.Lua.Call("LuaEntry.Player:SetValue", strKey, value);
    }

    public bool IsAllianceSelfCamp(string allianceId)
    {
        // var selfAllianceId = GetAllianceId();
        // if (selfAllianceId.IsNullOrEmpty() == false && allianceId.IsNullOrEmpty() == false)
        // {
        //     if (allianceServerCamp.ContainsKey(selfAllianceId) && allianceServerCamp.ContainsKey(allianceId))
        //     {
        //         if (allianceServerCamp[selfAllianceId] == allianceServerCamp[allianceId])
        //         {
        //             return true;
        //         }
        //     }
        // }

        return false;
    }
    
}





