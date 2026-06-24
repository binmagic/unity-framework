using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public abstract class InfinityScrollViewBase : MonoBehaviour
{
	[SerializeField]
	protected private Vector2 cellSize;
	[SerializeField]
	protected private Vector2 spacingSize;

	[SerializeField]
	private GameObject itemTemplate;
	protected RectTransform rectTransform;
	protected ScrollRect scrollRect;

	protected int itemCount;
	protected Vector2 maskSize;
	protected Rect maskRect;

	protected List<InfinityItem> infinityItems;
	protected Dictionary<int, InfinityRect> rectDic;

	protected bool inited = false;

	public Action<GameObject, int, int> onUpdate;
	public Action<GameObject, int> onDestroy;

	private Dictionary<int, InfinityRect> inOverlaps = new Dictionary<int, InfinityRect>();
	private int lastNumber = 0;
	private int lastKey = 0;	//当前显示中最后一条
	private bool isMove = false;
	
	protected Coroutine _coroutine;
	
	public virtual void Init( Action<GameObject,int> onInit, Action<GameObject, int, int> onUpdate, Action<GameObject, int> onDestroy)
	{
  //      if ( inited )
		//{
		//	return;
		//}

		rectTransform = transform as RectTransform;

		RectTransform rectTrans = transform.parent.GetComponent<RectTransform>();
		maskSize = new Vector2( rectTrans.rect.width, rectTrans.rect.height );
		scrollRect = transform.parent.GetComponent<ScrollRect>();
		if( scrollRect != null )
		{
			scrollRect.onValueChanged.AddListener(OnScrollChange);
		}

		itemCount = CalculationItemCount();
		infinityItems = new List<InfinityItem>();
		for( int i = 0; i < itemCount; ++i )
		{
			GameObject temp = GameObject.Instantiate(itemTemplate, transform);
			//temp.transform.SetParent( transform );
			temp.transform.localRotation = Quaternion.identity;
			temp.transform.localScale = Vector3.one;
			temp.layer = gameObject.layer;
            temp.name = Convert.ToString(i + 1);

			InfinityItem infinityItem = temp.AddComponent<InfinityItem>();
			infinityItems.Add( infinityItem );

			onInit( temp,i+1);
			temp.transform.localScale = Vector3.zero;
			UpdateItemTransformPos( temp, i );
		}

		UpdateDynmicRects( itemCount );
		isMove = false;
		this.onUpdate = onUpdate;
		this.onDestroy = onDestroy;

		inited = true;
	}

	private void OnDestroy()
	{
		if( inited )
		{
			Dispose();	
		}
	}

	public virtual void Dispose()
	{
		onUpdate = null;
		onDestroy = null;
		if (scrollRect != null)
		{
			scrollRect.onValueChanged.RemoveAllListeners();
		}
		StopLocateCoroutine();
	}


	public virtual void SetItemCount( int itemCount )
	{

        UpdateDynmicRects( itemCount );
		SetRenderListSize( itemCount );
		ClearAllRender();
		UpdateRender( Vector2.zero );
	}

    public virtual void ForceUpdate()
    {
        UpdateRender(Vector2.zero, true);
    }

    public virtual void ForceUpdateCell()
    {
        UpdateRender(Vector2.zero, true);
    }

    public virtual int GetColumnCount()
	{
		return 1;
	}

	public virtual int GetRenderCount()
	{
		return inOverlaps.Count;
	}
	
	protected float GetItemSizeX()
	{
		return cellSize.x + spacingSize.x;
	}

	protected float GetItemSizeY()
	{
		return cellSize.y + spacingSize.y;
	}

	protected InfinityItem GetInfinityItem( InfinityRect rect )
	{
		int length = infinityItems.Count;
		for( int i = 0; i < length; ++i )
		{
			InfinityItem item = infinityItems[i];
			if( item.Rect == null )
			{
				continue;
			}
			if( rect.Index == item.Rect.Index )
			{
				return item;
			}
		}
		return null;
	}

    public virtual InfinityItem GetInfinityItemByIndex(int index)
    {
        return infinityItems[index];
    }

    protected InfinityItem GetNullInfinityItem()
	{
		int length = infinityItems.Count;
		for( int i = 0; i < length; ++i )
		{
			InfinityItem item = infinityItems[i];
			if( item.Rect == null )
			{
				return item;
			}
		}
		return null;
	}

	protected void ClearAllRender()
	{
		if( infinityItems == null )
		{
			return;
		}

		for( int i = 0; i < infinityItems.Count; ++i )
		{
			InfinityItem item = infinityItems[i];
			if( item.Rect != null )
			{
				int index = item.Rect.Index;
				if( onDestroy != null )
				{
					onDestroy( item.gameObject, index );
				}
				item.Rect = null;
			}
		}
		lastNumber = 0;
	}

	protected abstract void UpdateDynmicRects( int itemCount );
	protected abstract void SetRenderListSize( int itemCount );
	protected abstract void UpdateItemTransformPos( GameObject item, int index );
	protected abstract void UpdateMaskRect();
	protected abstract int CalculationItemCount();
	public abstract void MoveItemByIndex( int index, float delay );
    protected abstract Vector2 GetItemAnchoredPos(int index);

    public virtual void StopLocateCoroutine()
    {
        if (null != _coroutine)
        {
            StopCoroutine(_coroutine);
        }
		_coroutine = null;
	}

    private void OnScrollChange(Vector2 pos)
    {
	    //特定位移过程中滑动不刷新Render
	    if (!isMove)
	    {
		    UpdateRender(pos, false);
	    }
    }


    protected void UpdateRender( Vector2 pos, bool isForce = false )
	{
		UpdateMaskRect();

		inOverlaps.Clear();

		int number = 0;
		foreach( InfinityRect itemRect in rectDic.Values )
		{
			if( itemRect.Overlaps(maskRect) )
			{
				inOverlaps.Add(itemRect.Index, itemRect);
				number += ( itemRect.Index + 1 );
				lastKey = itemRect.Index;
			}
		}

		if( !isForce && lastNumber == number )
		{
			return;
		}

        lastNumber = number;

		int length = infinityItems.Count;

		for( int i = 0; i < length; ++ i )
		{
			InfinityItem infinityItem = infinityItems[i];
			if( infinityItem.Rect != null && !inOverlaps.ContainsKey(infinityItem.Rect.Index) )
			{
				int index = infinityItem.Rect.Index;
				if( this.onDestroy != null )
				{
                    if(infinityItem.gameObject != null)
					    this.onDestroy(infinityItem.gameObject, index);
				}
				infinityItem.Rect = null;
			}
		}
		
		foreach( InfinityRect rect in inOverlaps.Values )
		{
			InfinityItem item = GetInfinityItem(rect);
			if (item == null )
			{
				item = GetNullInfinityItem();
				item.Rect = rect;
				UpdateItemTransformPos(item.gameObject, item.Rect.Index);
				onUpdate(item.gameObject, item.Rect.Index, this.inOverlaps.Count);
			}
			else if(isForce)
            {
                //item.Rect = rect;
                //UpdateItemTransformPos(item.gameObject, item.Rect.Index);
                onUpdate(item.gameObject, item.Rect.Index, this.inOverlaps.Count);
			}
		}
		
	}

	protected IEnumerator TweenMoveToPos( Vector2 pos, Vector2 toPos, float delay )
	{
		bool running = true;
		float passedTime = 0f;

		while( running )
		{
			yield return new WaitForEndOfFrame();
			passedTime += Time.deltaTime;
			Vector2 currentPos;
			if( passedTime >= delay )
			{
				currentPos = toPos;
				running = false;
				StopCoroutine(_coroutine);
				_coroutine = null;
			}
			else
			{
				currentPos = Vector2.Lerp(pos, toPos, passedTime / delay);
			} 
			rectTransform.anchoredPosition = currentPos;
		}
	}

    protected IEnumerator TweenUpdateToPoss(int index,float delay)
    {
        bool running = true;
        float passedTime = 0f;
        isMove = true;
        //找到下一条
        foreach (InfinityRect itemRect in rectDic.Values )
        {
	        if ((lastKey + 1) == itemRect.Index)
	        {
		        if (!inOverlaps.ContainsKey(itemRect.Index))
		        {
			        inOverlaps.Add(itemRect.Index, itemRect);
		        }
	        } 
        }
        //将下一条填充信息
        foreach (InfinityRect rect in inOverlaps.Values)
        {
	        if (rect.Index == lastKey + 1)
	        {
		        InfinityItem item = GetInfinityItem(rect);
		        if (item == null)
		        {
		         item = GetNullInfinityItem();
		         item.Rect = rect;
		         UpdateItemTransformPos(item.gameObject, item.Rect.Index);
		         onUpdate(item.gameObject, item.Rect.Index, this.inOverlaps.Count);
		        }
	        }
        }
        //yield return new WaitForSeconds(0.1f);
        running = true;
         while (running)
         {
             yield return new WaitForEndOfFrame();
             passedTime += Time.deltaTime;
             Vector2 currentPos;
             if (passedTime >= delay)
             {
	             running = false;
                 StopCoroutine(_coroutine);
                 _coroutine = null;
                 InfinityItem itemss = GetInfinityItem(inOverlaps[index -1]);
                 itemss.Rect = null;
                 GameEntry.Event.Fire(EventId.OnTaskForceRefreshFinish);
                 isMove = false;
             }
             else
             {
                 
                 foreach (InfinityRect rect in inOverlaps.Values)
                 {
                     if (index <= rect.Index)
                     {
                         InfinityItem item = GetInfinityItem(rect);
                         if (item == null)
                         {
                             item = GetNullInfinityItem();
                             item.Rect = rect;
                         }
                         Vector2 targetPos = GetItemAnchoredPos(rect.Index - 1);
                         currentPos = Vector2.Lerp(((RectTransform)item.gameObject.transform).anchoredPosition, targetPos, passedTime / delay);
                         ((RectTransform)item.gameObject.transform).anchoredPosition = currentPos;
                         
                     }
                 }
             }
         }  
    }
    


    void Update()
	{
		if( !inited )
		{
			return;
		}
	}
}

public class InfinityRect
{
	private Rect rect;
	private int index;

	public int Index
	{
		get
		{
			return index;
		}
	}
    public float RectX
    {
        set
        {
            rect.x = value;
        }
        get
        {
            return rect.x;
        }
    }
    public float RectY
    {
        set
        {
            rect.y = value;
        }
        get
        {
            return rect.y;
        }
    }
    public float RectWidth
    {
        set
        {
            rect.width = value;
        }
        get
        {
            return rect.width;
        }
    }
    public float RectHeight
    {
        set
        {
            rect.height = value;
        }
        get
        {
            return rect.height;
        }
    }

	public InfinityRect( float x, float y, float width, float height, int index )
	{
		this.index = index;
		this.rect = new Rect( x, y, width, height );
	}

	public bool Overlaps( Rect otherRect )
	{
		bool isIn = rect.Overlaps( otherRect );
		return isIn;
	}
}

public class InfinityItem : MonoBehaviour
{
	private InfinityRect infinityRect;

	public InfinityRect Rect
	{
		get
		{
			return infinityRect;
		}
		set
		{
			infinityRect = value;
			//gameObject.SetActive( value != null );
			gameObject.transform.localScale = value == null ? Vector3.zero : Vector3.one;
		}
	}
}





