/***
 * Created by Darcy
 * Date: Monday, 30 November 2020
 * Time: 19:08:38
 * Description: 该脚本是用来处理当上层一个UI响应点击事件后，不阻挡该点击事件，能再往下面传递一层 
 ***/

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





