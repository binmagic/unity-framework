using System;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[Hotfix]
public class LuaUpdater : MonoBehaviour
{
    Action<float, float> luaUpdate = null;

    public void OnInit(LuaEnv luaEnv)
    {
        Restart(luaEnv);
    }

    public void Restart(LuaEnv luaEnv)
    {
        // event.lua 里面的更新器
        luaUpdate = luaEnv.Global.Get<Action<float, float>>("Update");
    }

    void Update()
    {
        if (luaUpdate != null)
        {
            try
            {
                luaUpdate(Time.deltaTime, Time.unscaledDeltaTime);
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogError("luaUpdate err : " + ex.Message + "\n" + ex.StackTrace);
            }
        }
    }

    public void Dispose()
    {
        luaUpdate = null;
    }
}

#if UNITY_EDITOR
public static class LuaUpdaterExporter
{
    [CSharpCallLua]
    public static List<Type> CSharpCallLua = new List<Type>()
    {
        typeof(Action<float>),
        typeof(Action<float, float>),
    };
}
#endif





