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





