/**
 * [INPUT]: 依赖 UnityEngine.Object 与 XLua、GameKit.Base
 * [OUTPUT]: 对外提供 UnityEngineObjectExtention 扩展方法,统一 Lua 侧对 UnityEngine.Object 的判空等操作
 * [POS]: XLua/Support 的对象判空适配,规避 Lua 无法感知 Unity 假空对象的坑,是 Lua 操作 U3D 对象的安全垫
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using System.Collections;
using XLua;
using System.Collections.Generic;
using System;
using GameKit.Base;

/// <summary>
/// 说明：xlua中的扩展方法
///     
/// @by wsh 2017-12-28
/// </summary>

public static class UnityEngineObjectExtention
{
    // 说明：lua侧判Object为空全部使用这个函数
    public static bool IsNull(this UnityEngine.Object o)
    {
        return o == null;
    }
}

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
public static class UnityEngineGameObjectExtention
{
    public static void GameObjectCreatePool(this GameObject prefab)
    {
        prefab.CreatePool();
    }

    public static GameObject GameObjectSpawn(this GameObject prefab)
    {
        return prefab.Spawn();
    }

    public static GameObject GameObjectSpawn(this GameObject prefab, Transform parent)
    {
        return prefab.Spawn(parent);
    }

    public static void GameObjectRecycle(this GameObject obj)
    {
        obj.Recycle();
    }

    public static void GameObjectRecycleAll(this GameObject prefab)
    {
        prefab.RecycleAll();
    }
}





