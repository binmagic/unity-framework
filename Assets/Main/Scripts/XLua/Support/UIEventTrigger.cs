using System;
using UnityEngine.EventSystems;
using UnityEngine;

public class UIEventTrigger : EventTrigger
{
	private bool mIsDown = false;//是否按下
	private float mTimePressStarted;//按下时间
	private PointerEventData mPointDownEventData = null;
	public float durationThreshold = 0.3f; //长按触发时间
	private bool mLongPressTriggered = false;
	private bool mHasDragged = false; //是否已被拖动
	
	public override void OnBeginDrag(PointerEventData data)
	{
		onBeginDrag?.Invoke(data);
	}
	
	public override void OnDrag(PointerEventData data)
	{
		onDrag?.Invoke(data);
		mHasDragged = true;
	}

	public override void OnDrop(PointerEventData data)
	{
		onDrop?.Invoke(data);
	}

	public override void OnEndDrag(PointerEventData data)
	{
		onEndDrag?.Invoke(data);
	}

	public override void OnPointerClick(PointerEventData data)
	{
		onPointerClick?.Invoke(data);
	}
	
	public override void OnPointerDown(PointerEventData data)
	{
		onPointerDown?.Invoke(data);
		mIsDown = true;
		mTimePressStarted = Time.time;
		mPointDownEventData = data;
		mLongPressTriggered = false;
		mHasDragged = false;
	}
	
	/// <summary>
	/// onLongPress方法需要为对象添加Selectable组件才能使用
	/// </summary>
	/// <param name="data"></param>
	public override void OnUpdateSelected(BaseEventData data)
	{
		//按下、未触发长按、未拖动时，才触发长按
		if (mIsDown && !mLongPressTriggered && !mHasDragged)
		{
			if (Time.time - mTimePressStarted >= durationThreshold)
			{
				mLongPressTriggered = true;
				onLongPress?.Invoke(mPointDownEventData);
			}
		}
	}

	public override void OnPointerEnter(PointerEventData data)
	{
		onPointerEnter?.Invoke(data);
	}

	public override void OnPointerExit(PointerEventData data)
	{
		onPointerExit?.Invoke(data);
	}

	public override void OnPointerUp(PointerEventData data)
	{
		onPointerUp?.Invoke(data);
		mIsDown = false;
	}

	public Action<PointerEventData> onBeginDrag;
	
	public Action<PointerEventData> onDrag;

	public Action<PointerEventData> onDrop;

	public Action<PointerEventData> onEndDrag;

	public Action<PointerEventData> onPointerClick;

	public Action<PointerEventData> onPointerDown;

	public Action<PointerEventData> onLongPress;

	public Action<PointerEventData> onPointerEnter;

	public Action<PointerEventData> onPointerExit;

	public Action<PointerEventData> onPointerUp;

}





