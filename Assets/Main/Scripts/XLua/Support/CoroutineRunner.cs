/**
 * [INPUT]: 依赖 UnityEngine 协程,依赖 XLua 的 [Hotfix] 与 Action 回调
 * [OUTPUT]: 对外提供 CoroutineRunner MonoBehaviour,让 Lua 把 yield 指令交给 C# 协程驱动并回调
 * [POS]: XLua/Support 的协程宿主,补足 Lua 无法直接使用 Unity 协程的空缺,与 LuaUpdater(帧驱动)分工
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using XLua;
using System.Collections.Generic;
using System.Collections;
using System;

[Hotfix]
public class CoroutineRunner : MonoBehaviour
{
    public void YieldAndCallback(object toYield, Action callback)
    {
        StartCoroutine(CoBody(toYield, callback));
    }

    private IEnumerator CoBody(object toYield, Action callback)
    {
        if (toYield is IEnumerator)
            yield return StartCoroutine((IEnumerator)toYield);
        else
            yield return toYield;
        callback();
    }
}

#if UNITY_EDITOR
public static class CoroutineRunnerExporter
{
    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp = new List<Type>() {
                typeof(WaitForSeconds),
                typeof(WaitForEndOfFrame),
                typeof(WaitForFixedUpdate),
                //typeof(WWW),
        };
}
#endif





