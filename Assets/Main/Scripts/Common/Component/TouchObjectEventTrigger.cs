/**
 * [INPUT]: 依赖 System.Action 作各类指针回调，依赖 UnityEngine.Events.UnityEvent 暴露可序列化点击事件
 * [OUTPUT]: 对外提供 TouchObjectEventTrigger 组件，聚合点击/双击/拖拽/长按/进出/按下抬起的委托与 On* 触发方法及 priority/distance 排序字段
 * [POS]: Common/Component 的场景对象触摸事件枢纽，由外部触摸系统按 priority+distance 命中排序后回调，是非 UGUI 世界对象接入统一交互分发的事件承载体
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using UnityEngine;
using UnityEngine.Events;

public class TouchObjectEventTrigger : MonoBehaviour
{
    [SerializeField]
    private float priority;
    
    public float Priority
    {
        set { priority = value;}
        get { return priority; }
    }
    
    //发现aps同priority的无法按z排序 因此加个hit distance用来排序 --zlh
    public float Distance { set; get; }


    /*public Vector2Int TilePos
    {
        get { return SceneManager.World.WorldToTile(transform.position); }
    }*/

    private int clickType = 0;
    public int GetClickType()
    {
        return clickType;
    }

    public void SetClickType(int setType)
    {
        clickType = setType;
    }

    public bool OnClick()
    {
        onPointerClickEvent?.Invoke();
        onPointerClick?.Invoke();
        return onPointerClick != null;
    }
    
    public bool OnDoubleClick()
    {
        onPointerDoubleClick?.Invoke();
        return onPointerDoubleClick != null;
    }

    public bool OnBeginDrag(Vector3 dragStartPos)
    {
        onBeginDrag?.Invoke(dragStartPos);
        return onBeginDrag != null;
    }

    public bool OnEndDrag(Vector3 dragStopPos)
    {
        onEndDrag?.Invoke(dragStopPos);
        return onEndDrag != null;
    }

    public bool OnDrag(Vector3 dragStartPos, Vector3 dragCurrPos)
    {
        onDrag?.Invoke(dragStartPos, dragCurrPos);
        return onDrag != null;
    }

    public bool OnBeginLongTap()
    {
        onBeginLongTab?.Invoke();
        return onBeginLongTab != null;
    }

    public bool OnEndLongTap()
    {
        onEndLongTab?.Invoke();
        return onEndLongTab != null;
    }

    public bool OnPointerEnter()
    {
        onPointerEnter?.Invoke();
        return onPointerEnter != null;
    }

    public bool OnPointerExit()
    {
        onPointerExit?.Invoke();
        return onPointerExit != null;
    }
    
    public bool OnPointerDown()
    {
        onPointerDownEvent?.Invoke();
        onPointerDown?.Invoke();
        return onPointerDown != null;
    }

    public bool OnPointerUp()
    {
        onPointerUpEvent?.Invoke();
        onPointerUp?.Invoke();
        return onPointerUp != null;
    }

    public void ClearAction()
    {
        onBeginDrag = null;
        onDrag = null;
        onEndDrag = null;
    
        onBeginLongTab = null;
        onEndLongTab = null;

        onPointerDown = null;
        onPointerClick = null;
        onPointerUp = null;
        onPointerDoubleClick = null;
    
        onPointerEnter = null;
        onPointerExit = null;
    }

    public Action<Vector3> onBeginDrag;
    public Action<Vector3, Vector3> onDrag;
    public Action<Vector3> onEndDrag;
    
    public Action onBeginLongTab;
    public Action onEndLongTab;

    public Action onPointerDown;
    public Action onPointerClick;
    public Action onPointerUp;
    public Action onPointerDoubleClick;
    
    public Action onPointerEnter;
    public Action onPointerExit;

    public UnityEvent onPointerClickEvent;
    public UnityEvent onPointerUpEvent;
    public UnityEvent onPointerDownEvent;
}





