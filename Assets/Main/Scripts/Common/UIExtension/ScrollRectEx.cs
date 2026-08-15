/***
 * Created by Darcy
 * Date: Tuesday, 01 December 2020
 * Time: 11:13:32
 * Description: https://forum.unity.com/threads/nested-scrollrect.268551/
 * Edit by darcy 
 ***/

/**
 * [INPUT]: 依赖 UnityEngine.UI.ScrollRect 基类与 EventSystems 的拖拽处理器接口
 * [OUTPUT]: 对外提供 ScrollRectEx 组件，替代原生 ScrollRect 支持嵌套滚动
 * [POS]: UIExtension 的嵌套滚动扩展，按拖拽方向判定是自身响应还是沿父链路由事件给父级 ScrollRect，解决横竖嵌套冲突
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;
using System;
using UnityEngine.EventSystems;

public class ScrollRectEx : ScrollRect
{

    private bool routeToParent;


    /// <summary>
    /// Do for parents
    /// </summary>
    /// <param name="action"></param>
    /// <param name="onlyForFirstParent">是否只传递给第一个符合条件的 parent </param>
    /// <typeparam name="T"></typeparam>
    private void DoForParents<T> (Action<T> action, bool onlyForFirstParent = false) where T : IEventSystemHandler
    {
        var parent = transform.parent;
        while (parent != null)
        {
            foreach (var component in parent.GetComponents<Component> ())
            {
                if (!(component is T))
                    continue;
                action ((T) (IEventSystemHandler) component);
                
                // 只传递一个的时候和 scrollSnap 有冲突 不清楚具体原因，所以先去掉了
                // //理论上只传递给第一个符合条件的parent就足够了
                // if (onlyForFirstParent)
                //     return;
            }

            parent = parent.parent;
        }
    }

    /// <summary>
    /// Always route initialize potential drag event to parents
    /// </summary>
    public override void OnInitializePotentialDrag (PointerEventData eventData)
    {
        DoForParents<IInitializePotentialDragHandler> (parent => { parent.OnInitializePotentialDrag (eventData); },
            true);
        base.OnInitializePotentialDrag (eventData);
    }

    /// <summary>
    /// Drag event
    /// </summary>
    public override void OnDrag (PointerEventData eventData)
    {
        if (routeToParent)
            DoForParents<IDragHandler> (parent => { parent.OnDrag (eventData); }, true);
        else
            base.OnDrag (eventData);
    }

    /// <summary>
    /// Begin drag event
    /// </summary>
    public override void OnBeginDrag (PointerEventData eventData)
    {
        if (!horizontal && Math.Abs (eventData.delta.x) > Math.Abs (eventData.delta.y))
            routeToParent = true;
        else if (!vertical && Math.Abs (eventData.delta.x) < Math.Abs (eventData.delta.y))
            routeToParent = true;
        else
            routeToParent = false;

        if (routeToParent)
            DoForParents<IBeginDragHandler> (parent => { parent.OnBeginDrag (eventData); }, true);
        else
            base.OnBeginDrag (eventData);
    }

    /// <summary>
    /// End drag event
    /// </summary>
    public override void OnEndDrag (PointerEventData eventData)
    {
        if (routeToParent)
            DoForParents<IEndDragHandler> (parent => { parent.OnEndDrag (eventData); }, true);
        else
            base.OnEndDrag (eventData);
        routeToParent = false;
    }
}





