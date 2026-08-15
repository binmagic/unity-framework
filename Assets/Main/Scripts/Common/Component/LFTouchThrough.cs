/***
 * Created by Darcy
 * Date: Monday, 30 November 2020
 * Time: 19:08:38
 * Description: 该脚本是用来处理当上层一个UI响应点击事件后，不阻挡该点击事件，能再往下面传递一层 
 ***/

/**
 * [INPUT]: 依赖 UnityEngine.EventSystems 的指针接口与 ExecuteEvents/RaycastAll，编辑器下用 GameFramework.Log 打印命中目标
 * [OUTPUT]: 对外提供 LFTouchThrough 组件的 ToggleThrough 开关，实现点击/拖拽事件向下层 UI 穿透一层
 * [POS]: Common/Component 的 UI 事件穿透器，标记 [DisallowMultipleComponent]，解决上层 UI 拦截点击后需继续下发的场景
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;


[DisallowMultipleComponent]
public class LFTouchThrough : MonoBehaviour, IPointerClickHandler,IBeginDragHandler, IEndDragHandler, IDragHandler
{

    [SerializeField] private bool _passClick = true;
    private readonly List<RaycastResult> _results = new List<RaycastResult> (8);

    private void PassEvent<T> (PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        _results.Clear();

        //是按照射线检测顺序排序过的
        EventSystem.current.RaycastAll (data, _results);
        
        if (_results.Count < 1)
            return;
        
        var source = data.pointerCurrentRaycast.gameObject;

        foreach (var result in _results)
        {
            if (result.gameObject == gameObject)
            {
                continue;
            }

            if (result.gameObject == source)
            {
                continue;
            }

#if UNITY_EDITOR
            GameFramework.Log.Info("TargetObjectName: {0}", result.gameObject.name);
#endif
            ExecuteEvents.Execute(result.gameObject, data, function);
            break;
        }
    }

    public void OnPointerClick (PointerEventData eventData)
    {
        if (!_passClick)
            return;
        PassEvent (eventData, ExecuteEvents.pointerClickHandler);
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (!_passClick)
            return;
        PassEvent (eventData, ExecuteEvents.beginDragHandler);
    }
    public void OnEndDrag(PointerEventData eventData)
    {
        if (!_passClick)
            return;
        PassEvent (eventData, ExecuteEvents.endDragHandler);
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!_passClick)
            return;
        PassEvent (eventData, ExecuteEvents.dragHandler);
    }
    

    public void ToggleThrough(bool t)
    {
        _passClick = t;
    }
}





