using System;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[AddComponentMenu("UI/HorizontalInfinityScrollView")]
public class HorizontalInfinityScrollView : InfinityScrollViewBase
{
    public override void Init( Action<GameObject,int> onInit, Action<GameObject, int, int> onUpdate, Action<GameObject, int> onDestroy)
	{
		base.Init( onInit, onUpdate, onDestroy);
	}

	public override void MoveItemByIndex( int index, float delay )
	{
		if( index < 0 | index > rectDic.Count )
		{
			return;
		}
		index = Math.Min(index, rectDic.Count);
		index = Math.Max(0, index);
		Vector2 pos = rectTransform.anchoredPosition;
		Vector2 moveToPos = new Vector2(index * -GetItemSizeX(), pos.y);
		var sizeDelta = scrollRect.content.sizeDelta;
		float limitX = -( sizeDelta.x - maskSize.x );
		float limitY = -( sizeDelta.y - maskSize.y );
		if( scrollRect.horizontal && moveToPos.x < limitX )
		{
			moveToPos.x = limitX;
		}
		else if( scrollRect.vertical && moveToPos.y < limitY )
		{
			moveToPos.y = limitY;
		}
		if (delay > 0)
		{
			if (_coroutine != null)
			{
				StopCoroutine(_coroutine);
			}
			_coroutine = StartCoroutine(TweenMoveToPos(pos, moveToPos, delay));
		}
		else
		{
			rectTransform.anchoredPosition = moveToPos;
			UpdateRender(moveToPos);
		}
	}

    public override void ForceUpdate()
    {
        base.ForceUpdate();
    }

    protected override int CalculationItemCount()
	{
		return Mathf.CeilToInt( maskSize.x / GetItemSizeX() ) + 1;
	}

	public override void Dispose()
	{
		base.Dispose();
	}

    public override void SetItemCount( int itemCount )
	{
		base.SetItemCount( itemCount );
	}

	public override InfinityItem GetInfinityItemByIndex(int index)
    {
        return base.GetInfinityItemByIndex(index);
    }

    public void SetScrollRectHorizontal(bool enable)
    {
        scrollRect.horizontal = enable;
    }

    protected override void UpdateDynmicRects( int itemCount )
	{
		rectDic = new Dictionary<int, InfinityRect>();
		for( int i = 0; i < itemCount; ++ i )
		{
			InfinityRect rect = new InfinityRect( i * GetItemSizeX(), 0, cellSize.x, cellSize.y, i );
			rectDic[i] = rect;
		}
	}

	protected override void SetRenderListSize( int itemCount )
	{
		rectTransform.sizeDelta = new Vector2( itemCount * GetItemSizeX(), rectTransform.sizeDelta.y );
		maskRect = new Rect( 0, 0, maskSize.x, maskSize.y );
	}

    protected override Vector2 GetItemAnchoredPos(int index)
    {
        Vector2 result = Vector2.zero;
        if (index < 0 | index > rectDic.Count)
        {
            return result;
        }

        index = Math.Min(index, rectDic.Count);
        index = Math.Max(0, index);
        Vector2 pos = rectTransform.anchoredPosition;
        result.Set(index * -GetItemSizeX(), pos.y);
        return result;
    }

    protected override void UpdateItemTransformPos( GameObject item, int index )
	{
		Vector2 pos = new Vector2( index * GetItemSizeX(), 0 );
		( (RectTransform)item.transform ).anchoredPosition3D = Vector3.zero;
		( (RectTransform)item.transform ).anchoredPosition = pos;
	}

	protected override void UpdateMaskRect()
	{
		maskRect.x = -rectTransform.anchoredPosition.x;
	}
}





