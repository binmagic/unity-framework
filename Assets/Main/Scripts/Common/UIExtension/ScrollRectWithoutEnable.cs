/**
 * [INPUT]: 依赖 UnityEngine.UI.ScrollRect 基类，仅重写 IsActive 判定
 * [OUTPUT]: 对外提供 ScrollRectWithoutEnable 组件
 * [POS]: UIExtension 的 ScrollRect 变体，绕过组件启用状态判定以便代码手动触发拖拽事件，与 ScrollRectEx 同为原生 ScrollRect 的定制子类
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





