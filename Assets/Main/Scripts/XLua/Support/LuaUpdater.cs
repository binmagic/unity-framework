/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 帧循环,依赖 XLua 的 LuaEnv 与 [Hotfix]
 * [OUTPUT]: 对外提供 LuaUpdater MonoBehaviour,把 Unity 的 Update/帧回调转发给 Lua 侧的 update 函数
 * [POS]: XLua/Support 的帧驱动桥,是 Lua 层每帧逻辑的心跳来源,与 CoroutineRunner(协程)共同支撑 Lua 时序
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





