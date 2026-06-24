using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 这个控件不判定当前组件是否激活,目的是手动使用其drag事件
/// </summary>
public class ScrollRectWithoutEnable : ScrollRect
{
    public override bool IsActive()
    {
        return gameObject.activeSelf && content != null;
    }
}





