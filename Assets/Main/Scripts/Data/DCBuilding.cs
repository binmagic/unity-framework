using GameFramework;
using UnityEngine;
using XLua;

// 把Building相关的函数都放到这里，以后需要优化的话，直接修改实现即可
// 压入操作详细看XLua/Support/LuaFunction.cs!!

[UnityEngine.Scripting.Preserve]
public class DCBuilding : BaseDataContainer
{
    private LuaTable CSharpCallLuaInterface_;
    private LuaFunction luafunc_GetBuildingDataParamByUuid;
    private LuaFunction luafunc_GetBuildingDataParamByBuildId;
    private Vector2Int _cityCenterPos;//(49,49)

    private void init()
    {
        _cityCenterPos = Vector2Int.zero;
        CSharpCallLuaInterface_ = GameEntry.Lua.Env.Global.Get<LuaTable>("CSharpCallLuaInterface");
        luafunc_GetBuildingDataParamByUuid = CSharpCallLuaInterface_.Get<LuaFunction>("GetBuildingDataParamByUuid");
        luafunc_GetBuildingDataParamByBuildId = CSharpCallLuaInterface_.Get<LuaFunction>("GetBuildingDataParamByBuildId");
    }

    public LuaBuildData GetBuildingDataByUuid(long uuid)
    {
        if (CSharpCallLuaInterface_ == null)
        {
            init();
        }
        
        LuaBuildData data = null;
        if (luafunc_GetBuildingDataParamByUuid != null)
        {
            data = luafunc_GetBuildingDataParamByUuid.CallReturnBuildingData(uuid, 0);
        }

        return data;
    }

    public LuaBuildData GetBuildingDataByBuildId(int buildId)
    {
        if (CSharpCallLuaInterface_ == null)
        {
            init();
        }
        
        LuaBuildData data = null;
        if (luafunc_GetBuildingDataParamByBuildId != null)
        {
            data = luafunc_GetBuildingDataParamByBuildId.CallReturnBuildingData(0, buildId);
        }

        return data;
    }

    public bool IsInMyBaseInsideRange(int pointIndex)
    {
        bool b = GameEntry.Lua.CallWithReturn<bool, int>(
            "CSharpCallLuaInterface.IsInMyBaseInsideRange", pointIndex);
        return b;
    }

    public int GetMainLv()
    {
        int mainlv = GameEntry.Lua.CallWithReturn<int>("CSharpCallLuaInterface.GetMainLv");
        return mainlv;
    }

    //获取城市中心点（49，49）
    public Vector2Int GetMainPos()
    {
        if (_cityCenterPos == Vector2Int.zero)
        {
            _cityCenterPos = GameEntry.Lua.CallWithReturn<Vector2Int>("CSharpCallLuaInterface.GetMainPos");
        }
        return _cityCenterPos;
    }

    public void SetMainPos()
    {
        GameEntry.Lua.Call("CSharpCallLuaInterface.SetMainPos");
    }

    public int GetWorldMainPos()
    {
        var ret = GameEntry.Lua.CallWithReturn<int>("CSharpCallLuaInterface.GetWorldMainPos");
        return ret;
    }
}





