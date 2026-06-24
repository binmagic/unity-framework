using System;
using UnityEngine;
using UnityEngine.EventSystems;

public class UIEventListener : EventTrigger
{
    public Action<GameObject> onClick;
    public Action<GameObject> onDown;
    public Action<GameObject> onEnter;
    public Action<GameObject> onExit;
    public Action<GameObject> onUp;
    public Action<GameObject> onSelect;
    public Action<GameObject> onUpdateSelect;

    public Action<GameObject, Vector2, Vector2> onDrag;
    public Action<GameObject, Vector2, Vector2> onEndDrag;
    public Action<GameObject, Vector2, Vector2> onBeginDrag;


    static public UIEventListener Get(GameObject go)
    {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if (listener == null) listener = go.AddComponent<UIEventListener>();
        return listener;
    }
    public override void OnDrag(PointerEventData eventData)
    {
        if (onDrag != null)
        {
            onDrag(this.gameObject, eventData.position, eventData.delta);
        }
    }
    public override void OnEndDrag(PointerEventData eventData)
    {
        if (onEndDrag != null)
        {
            onEndDrag(this.gameObject, eventData.position, eventData.delta);
        }
    }
    public override void OnBeginDrag(PointerEventData eventData)
    {
        if (onBeginDrag != null)
        {
            onBeginDrag(this.gameObject, eventData.position, eventData.delta);
        }
    }
    public override void OnPointerClick(PointerEventData eventData)
    {
        if (onClick != null) onClick(gameObject);
    }
    public override void OnPointerDown(PointerEventData eventData)
    {
        if (onDown != null) onDown(gameObject);
    }
    public override void OnPointerEnter(PointerEventData eventData)
    {
        if (onEnter != null) onEnter(gameObject);
    }
    public override void OnPointerExit(PointerEventData eventData)
    {
        if (onExit != null) onExit(gameObject);
    }
    public override void OnPointerUp(PointerEventData eventData)
    {
        if (onUp != null) onUp(gameObject);
    }
    public override void OnSelect(BaseEventData eventData)
    {
        if (onSelect != null) onSelect(gameObject);
    }
    public override void OnUpdateSelected(BaseEventData eventData)
    {
        if (onUpdateSelect != null) onUpdateSelect(gameObject);
    }
}





