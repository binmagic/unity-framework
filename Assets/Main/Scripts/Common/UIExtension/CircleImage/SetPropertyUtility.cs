/**
 * [INPUT]: 依赖 UnityEngine 的 Color 类型
 * [OUTPUT]: 对外提供 SetPropertyUtilityExt 静态工具，暴露 SetColor/SetStruct/SetClass 三个带脏值判断的属性赋值方法
 * [POS]: CircleImage 模块的属性赋值助手，供 BaseImage 等在 setter 中判断值是否真正改变，避免无谓的 SetAllDirty 重绘
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;

internal static class SetPropertyUtilityExt
{
    public static bool SetColor(ref Color currentValue, Color newValue)
    {
        if (currentValue.r == newValue.r && currentValue.g == newValue.g && currentValue.b == newValue.b && currentValue.a == newValue.a)
            return false;

        currentValue = newValue;
        return true;
    }

    public static bool SetStruct<T>(ref T currentValue, T newValue) where T : struct
    {
        if (currentValue.Equals(newValue))
            return false;

        currentValue = newValue;
        return true;
    }

    public static bool SetClass<T>(ref T currentValue, T newValue) where T : class
    {
        if ((currentValue == null && newValue == null) || (currentValue != null && currentValue.Equals(newValue)))
            return false;

        currentValue = newValue;
        return true;
    }
}





