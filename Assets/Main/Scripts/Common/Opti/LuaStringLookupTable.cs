/**
 * [INPUT]: 依赖 XLua 的 LuaTable 做初始化导入,依赖 IL2CPP/Preserve 特性防裁剪
 * [OUTPUT]: 对外提供 LuaStringLookupTable,用整数 id 换取字符串,减少 Lua-C# 间字符串传递的 GC
 * [POS]: Common/Opti 的字符串驻留表,以 id 代理字符串跨语言传参,是 xLua 优化组的数据支撑设施
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections.Generic;
using UnityEngine;
using XLua;


[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
[UnityEngine.Scripting.Preserve]
public static class LuaStringLookupTable
{
    private static Dictionary<int, string> _lookupTable = new Dictionary<int, string>(512);
    private static int _tableIndex = 200000000; // 自动增长id

    // 初始化，Lua那边有个表格，用来静态初始化，一般都用作动态初始化
    public static void Init(LuaTable luaTable)
    {
        luaTable.ForEach<int, string>((key, value) =>
        {
            _lookupTable.Add(key, value);
        });
    }

    // 往字典里添加字符串
    public static int Add(string str)
    {
        int index = _tableIndex++;
        _lookupTable[index] = str;
        return index;
    }

    public static string Get(int id)
    {
        if (_lookupTable != null && _lookupTable.TryGetValue(id, out var value))
        {
            return value;
        }

        return string.Empty;
    }

    public static void Clear()
    {
        _lookupTable.Clear();
    }
}





