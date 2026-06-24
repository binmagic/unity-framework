using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("UI/GridInfinityScrollView")]
public class GridInfinityScrollView : InfinityScrollViewBase
{
	[SerializeField]
	public RectOffset padding;
	[SerializeField]
	private int minColumnCount;
	[SerializeField]
	private int maxColumnCount;
	[SerializeField]
	private int columnCount;
	
	public override void Init( Action<GameObject,int> onInit, Action<GameObject, int, int> onUpdate, Action<GameObject, int> onDestroy)
	{
		if( minColumnCount != 0 && maxColumnCount != 0 )
		{
			rectTransform = transform as RectTransform;
			RectTransform rectTrans = transform.parent.GetComponent<RectTransform>();
			maskSize = new Vector2( rectTrans.rect.width, rectTrans.rect.height );
			columnCount = Mathf.CeilToInt(maskSize.x / GetItemSizeX());
			columnCount = Math.Min(maxColumnCount, columnCount);
			columnCount = Math.Max(minColumnCount, columnCount);
		}
		base.Init( onInit, onUpdate, onDestroy );
	}

    public override void ForceUpdate()
    {
        base.ForceUpdate();
    }

    public override void ForceUpdateCell()
    {
        base.ForceUpdateCell();
    }

    public override void SetItemCount(int itemCount)
    {
        base.SetItemCount(itemCount);
    }

    public override void Dispose()
    {
	    base.Dispose();
    }

    /// <summary>
    /// 移动到index上的cell
    /// </summary>
    /// <param name="index"></param>
    /// <param name="延迟 填0就行"></param>
    public override void MoveItemByIndex( int index, float delay )
	{
        if (rectDic == null)
        {
            return;
        }
        if ( index < 0 | index > rectDic.Count )
		{
			return;
		}
		// index = Math.Min(index, rectDic.Count - itemCount);
		// index = Math.Max(0, index);
		Vector2 pos = rectTransform.anchoredPosition;
		int row = index / columnCount;
		Vector2 moveToPos = new Vector2(pos.x, row * GetItemSizeY());
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
			UpdateRender(moveToPos, true);
		}
		
	}

    public  void LaterItemByIndex(int index, float delay)
    {
        if (index < 0 | index > rectDic.Count)
        {
            return;
        }
        if (_coroutine != null)
        {
                
            StopCoroutine(_coroutine);
        }
        _coroutine = StartCoroutine(TweenUpdateToPoss(index, delay));
    }

    protected override Vector2 GetItemAnchoredPos(int index)
    {
		Vector2 result = Vector2.zero;
		if (index < 0 | index > rectDic.Count)
		{
			return result;
		}

		Vector2 pos = rectTransform.anchoredPosition;
		int row = index / columnCount;
        int column = index % columnCount;
        result.Set(column * GetItemSizeX(), row * (GetItemSizeY()* -1));
		return result;
	}

    public override int GetColumnCount()
	{
		return columnCount;
	}

	protected override int CalculationItemCount()
	{
		return columnCount * ( Mathf.CeilToInt( maskSize.y / GetItemSizeY() ) + 2 );
	}

	protected override void SetRenderListSize( int itemCount )
	{
		rectTransform.sizeDelta = new Vector2( rectTransform.sizeDelta.x, Mathf.CeilToInt( itemCount * 1f / columnCount ) * GetItemSizeY() - spacingSize.y + padding.vertical);
		maskRect = new Rect( 0, -maskSize.y, maskSize.x, maskSize.y );
	}

	protected override void UpdateDynmicRects( int itemCount )
	{
		rectDic = new Dictionary<int, InfinityRect>();
		for( int i = 0; i < itemCount; ++i )
		{
			int row = i / columnCount;
			int column = i % columnCount;
			InfinityRect rect = new InfinityRect( column * GetItemSizeX(), -row * GetItemSizeY() - cellSize.y, cellSize.x, cellSize.y, i );
			rectDic[i] = rect;
		}
	}

	protected override void UpdateItemTransformPos( GameObject item, int index )
	{
		int row = index / columnCount;
		int column = index % columnCount;
		Vector2 pos = new Vector2();
		pos.x = column * GetItemSizeX();
		pos.y = row * ( GetItemSizeY() * -1 ) - padding.top;
		( (RectTransform)item.transform ).anchoredPosition3D = Vector3.zero;
		( (RectTransform)item.transform ).anchoredPosition = pos;
	}

	protected override void UpdateMaskRect()
	{
		maskRect.y = -maskSize.y - rectTransform.anchoredPosition.y;
	}
}





