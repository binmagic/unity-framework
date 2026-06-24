using System;
using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;


public class UIScrollController : MonoBehaviour
{
    public enum Arrangement { Horizontal, Vertical, }
    public Arrangement movement = Arrangement.Horizontal;
    /// <summary>
    /// Item之间的距离
    /// </summary>
    [Range(0, 20)]
    public float cellPadiding = 2;
    /// <summary>
    /// Item的宽高
    /// </summary>
    public float cellWidth = 500;
    /// <summary>
    /// Item的高度
    /// </summary>
    public float cellHeight = 140;
    /// <summary>
    /// 默认加载的Item个数，一般比可显示个数大2~3个
    /// </summary>
    [Range(0, 20)]
    public int viewCount = 6;

    /// <summary>
    /// 需要动态赋值
    /// </summary>
    public GameObject itemPrefab;
    /// <summary>
    /// 需要动态赋值
    /// </summary>
    public RectTransform content;

    /// <summary>
    /// 当前第一行的Item索引
    /// </summary>
    public int currentPosIndex;

    public float currentPosY;
    public float currentContentPosY;
    /// <summary>
    /// 是否为向上滚动
    /// </summary>
    public bool isUpwardScroll;

    /// <summary>
    /// 记录上次滑动的位置,方便判断向上滚动还是向下滚动
    /// </summary>
    private Vector3 lastTimePos;

    private int index = -1;
    public List<UIScrollItem> itemList;
    public int dataCount;
    /// <summary>
    /// 将未显示出来的Item存入未使用队列里面，等待需要使用的时候直接取出
    /// </summary>
    private Queue<UIScrollItem> unUsedQueue;

    public Action<Vector2> OnValueChanged { get; set; }
    public Action<UIScrollItem> OnAddItem { get; set; }
    public Action<UIScrollItem> OnRemoveItem { get; set; }
    public Action<UIScrollItem> OnDelItem { get; set; }
    public Action<List<UIScrollItem>> OnInitItem { get; set; }

    public int DataCount
    {
        get
        {
            return dataCount;
        }
        set
        {
            dataCount = value;
            UpdateTotalWidth();
        }
    }
    public bool test;
    public int testCount;
    private void Start()
    {
        if (test)
        {
            ScrollRect scrollRect = transform.GetComponent<ScrollRect>();
            Init(testCount, scrollRect);
        }
    }

    public void Init(int initCount, ScrollRect rect)
    {
        itemList = new List<UIScrollItem>();
        unUsedQueue = new Queue<UIScrollItem>();
        DataCount = initCount;
        OnValueChange(Vector2.zero);
        if (OnInitItem != null)
        {
            OnInitItem(itemList);
        }
        //ScrollRect rect = content.parent.GetComponent<ScrollRect>();
        rect.onValueChanged.AddListener(OnValueChange);
    }

    public void RemoveScript()
    {
        Destroy(this);
    }

    public void OnValueChange(Vector2 pos)
    {
        int currentIndex = GetPosIndex();

        #region UnUsed
        float y = lastTimePos.y - pos.y;

        if (y > 0)
        {
            isUpwardScroll = true;
        }
        else
        {
            isUpwardScroll = false;
        }
        lastTimePos = pos;
        currentPosIndex = currentIndex;
        currentPosY = currentPosIndex * -(cellHeight + cellPadiding);
        //currentContentPosY = ((currentPosIndex == -1 ? 0 : currentPosIndex) + 1) * cellHeight;
        currentContentPosY = (currentPosIndex == -1 ? 0 : currentPosIndex) * (cellHeight + cellPadiding);

        #endregion

        if (this.index != currentIndex /*&& currentIndex >= -1 && currentIndex < dataCount - 1*/)
        {
            if (currentIndex < 0)
            {
                this.index = 0;
            }
            else if (currentIndex > dataCount - 1)
            {
                this.index = dataCount - 1;
            }
            else
            {
                this.index = currentIndex;
            }

            for (int i = itemList.Count; i > 0; i--)
            {
                UIScrollItem item = itemList[i - 1];
                if (item.Index < this.index || (item.Index >= this.index + viewCount))
                {
                    RemoveItem(item);
                    if (OnRemoveItem != null)
                    {
                        OnRemoveItem(item);
                    }
                }
            }
            for (int i = this.index; i < this.index + viewCount; i++)
            {
                if (i >= 0 && i < dataCount)
                {
                    bool isExisted = false;
                    foreach (UIScrollItem item in itemList)
                    {
                        if (item.Index == i)
                        {
                            isExisted = true;
                            break;
                        }
                    }
                    if (!isExisted)
                    {
                        CreateItem(i);
                    }
                }
            }
        }

        if (OnValueChanged != null)
            OnValueChanged(pos);
    }

    /// <summary>
    /// 提供给外部的方法，添加指定位置的Item
    /// </summary>
    public UIScrollItem AddItem(int index)
    {
        if (index > dataCount)
        {
            UnityEngine.Debug.LogError("添加错误:" + index);
            return null;
        }
        UIScrollItem uiItem = AddItemIntoPanel(index);
        DataCount += 1;
        return uiItem;
    }

    /// <summary>
    /// 提供给外部的方法，删除指定位置的Item
    /// </summary>
    public void DelItem(int index)
    {
        Debug.LogWarning("dataCount == " + dataCount + "       index == " + index);
        if (index < 0 || index > dataCount)
        {
            UnityEngine.Debug.LogError("删除错误:" + index);
            return;
        }
        DelItemFromPanel(index);
        DataCount -= 1;
    }

    private UIScrollItem AddItemIntoPanel(int index)
    {
        for (int i = 0; i < itemList.Count; i++)
        {
            UIScrollItem item = itemList[i];
            if (item.Index >= index) item.Index += 1;
        }
        return CreateItem(index);
    }

    private void DelItemFromPanel(int index)
    {
        int maxIndex = -1;
        int minIndex = int.MaxValue;
        for (int i = itemList.Count; i > 0; i--)
        {
            UIScrollItem item = itemList[i - 1];
            if (item.Index == index)
            {
                if (OnDelItem != null)
                {
                    OnDelItem(item);
                }
                GameObject.Destroy(item.gameObject);
                itemList.Remove(item);
            }
            if (item.Index > maxIndex)
            {
                maxIndex = item.Index;
            }
            if (item.Index < minIndex)
            {
                minIndex = item.Index;
            }
            if (item.Index > index)
            {
                item.Index -= 1;
            }
        }
        if (maxIndex < DataCount - 1)
        {
            Debug.LogWarning("CreateItem");
            CreateItem(maxIndex);
        }
    }

    private UIScrollItem CreateItem(int index)
    {
        UIScrollItem itemBase;
        if (unUsedQueue.Count > 0)
        {
            itemBase = unUsedQueue.Dequeue();
        }
        else
        {
            //UnityEngine.Debug.LogError("没有可使用UIScrollItem的了");
            GameObject item = GameObject.Instantiate(itemPrefab);
            item.transform.SetParent(content);
            item.transform.localScale = Vector3.one;
            item.transform.localPosition = Vector3.zero;
            itemBase = item.GetComponent<UIScrollItem>();
            //itemBase = content.AddChild(itemPrefab).GetComponent<UIScrollItem>();
        }
        if (!itemBase.gameObject.activeInHierarchy)
        {
            itemBase.gameObject.SetActive(true);
        }
        itemBase.Scroller = this;
        itemBase.Index = index;
        itemList.Add(itemBase);
        if (OnAddItem != null)
        {
            OnAddItem(itemBase);
        }
        return itemBase;
    }

    private void RemoveItem(UIScrollItem item)
    {
        if (item != null && itemList.Contains(item))
        {
            itemList.Remove(item);
            unUsedQueue.Enqueue(item);
            item.gameObject.SetActive(false);
            item.gameObject.name = "[InPool]";
        }
    }

    private int GetPosIndex()
    {
        switch (movement)
        {
            case Arrangement.Horizontal:
                return Mathf.FloorToInt(content.anchoredPosition.x / -(cellWidth + cellPadiding));
            case Arrangement.Vertical:
                return Mathf.FloorToInt(content.anchoredPosition.y / (cellHeight + cellPadiding));
        }
        return 0;
    }

    public Vector3 GetPosition(int i)
    {
        switch (movement)
        {
            case Arrangement.Horizontal:
                return new Vector3(i * (cellWidth + cellPadiding), 0f, 0f);
            case Arrangement.Vertical:
                return new Vector3(0f, i * -(cellHeight + cellPadiding), 0f);
        }
        return Vector3.zero;
    }

    private void UpdateTotalWidth()
    {
        switch (movement)
        {
            case Arrangement.Horizontal:
                content.sizeDelta = new Vector2(cellWidth * dataCount + cellPadiding * (dataCount - 1), content.sizeDelta.y);
                break;
            case Arrangement.Vertical:
                content.sizeDelta = new Vector2(content.sizeDelta.x, cellHeight * dataCount + cellPadiding * (dataCount - 1));
                break;
        }
    }
}





