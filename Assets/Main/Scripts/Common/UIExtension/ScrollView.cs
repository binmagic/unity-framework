using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;


[AddComponentMenu("UI/ScrollView", 51)]
[DisallowMultipleComponent]
[RequireComponent(typeof(RectTransform))]
public class ScrollView : UIBehaviour, IInitializePotentialDragHandler, IBeginDragHandler, IEndDragHandler, IDragHandler, IScrollHandler, ICanvasElement, ILayoutElement, ILayoutGroup,IPointerDownHandler
{
    private static GameObject objectPoolRoot;
    private static Transform ObjectPoolRoot
    {
        get
        {
            if (objectPoolRoot == null)
            {
                objectPoolRoot = new GameObject("ScrollViewObjectPoolRoot");
                //这里需要SetActive(false) 或者扔到UIRootCanvas下, 不然带有Canvas的子节点 进池以后 sizeDelta会发生改变， 这里就简单active false吧
                objectPoolRoot.SetActive(false);
                DontDestroyOnLoad(objectPoolRoot);
            }
            return objectPoolRoot.transform;
        }
    }
    
    //==========LoopScrollRect==========
    [SerializeField]
    private GameObject itemTemplate;

    private class ItemObject
    {
        public bool used;
        public GameObject gameObject;
    }
    private List<ItemObject> itemObjectPool = new List<ItemObject>();

    [Tooltip("Total count, negative means INFINITE mode")]
    public int totalCount;

    protected float threshold = 0;

    [Tooltip("Reverse direction for dragging")]
    public bool reverseDirection = false;

    [Tooltip("Rubber scale for outside")]
    public float rubberScale = 1;

    /// <summary>
    /// 开始的偏移量
    /// </summary>
    protected int itemTypeStart = 0;
    protected int itemTypeEnd = 0;
    
    private Vector2 extraFillSize = Vector2.zero;

    public float GetPreferredWidth(RectTransform item)
    {
        var layout = item.GetComponent<LayoutElement>();
        if (layout != null)
        {
            return Mathf.Max(layout.minWidth, layout.preferredWidth); 
        }

        return item.sizeDelta.x;
    }

    public float GetPreferredHeight(RectTransform item)
    {
        var layout = item.GetComponent<LayoutElement>();
        if (layout != null)
        {
            return Mathf.Max(layout.minHeight, layout.preferredHeight);
        }

        return item.sizeDelta.y;
    }
    
    protected float GetSize(RectTransform item)
    {
        if (layoutType == ScrollViewLayoutType.Horizontal)
        {
            float size = contentSpacing;
            if (m_GridLayout != null)
            {
                size += m_GridLayout.cellSize.x;
            }
            else
            {
                //zlh: 这里用LayoutUtility获取PreferredSize有个坑，如果item activeInHierarchy是false的话，获取的是0, 就会导致直接加载了totalDataCount个item
                //size += LayoutUtility.GetPreferredWidth(item);
                size += GetPreferredWidth(item);
            }

            return size;
        }
        else
        {
            float size = contentSpacing;
            if (m_GridLayout != null)
            {
                size += m_GridLayout.cellSize.y;
            }
            else
            {
                //zlh: 这里用LayoutUtility获取PreferredSize有个坑，如果item activeInHierarchy是false的话，获取的是0, 就会导致直接加载了totalDataCount个item
                //size += LayoutUtility.GetPreferredHeight(item);
                size += GetPreferredHeight(item);
            }

            return size;
        }
    }

    protected float GetDimension(Vector2 vector)
    {
        return layoutType == ScrollViewLayoutType.Horizontal ? -vector.x : vector.y;
    }

    protected Vector2 GetVector(float value)
    {
        return layoutType == ScrollViewLayoutType.Horizontal ? new Vector2(-value, 0) : new Vector2(0, value);
    }

    /// <summary>
    /// 1 表示 水平方向  -1 表示 竖直方向  0 默认值
    /// </summary>
    protected int directionSign = 0;

    private float m_ContentSpacing = -1;
    protected GridLayoutGroup m_GridLayout = null;

    protected float contentSpacing
    {
        get
        {
            if (m_ContentSpacing >= 0)
            {
                return m_ContentSpacing;
            }

            m_ContentSpacing = 0;
            if (content != null)
            {
                HorizontalOrVerticalLayoutGroup layout1 = content.GetComponent<HorizontalOrVerticalLayoutGroup>();
                if (layout1 != null)
                {
                    m_ContentSpacing = layout1.spacing;
                }

                m_GridLayout = content.GetComponent<GridLayoutGroup>();
                if (m_GridLayout != null)
                {
                    m_ContentSpacing = Mathf.Abs(GetDimension(m_GridLayout.spacing));
                }
            }

            return m_ContentSpacing;
        }
    }

    //by zzl GridLayoutGroup中的constraintCount值根据界面动态修改，开放接口到lua中进行重置
    public int m_ContentConstraintCount = 0;

    /// <summary>
    /// 查看每列持有几个cell,如果在scrollview上设置的话就按设置的,如果没有设置的话,则取content上是否是grid,根据上面的数值来决定
    /// </summary>
    protected int contentConstraintCount
    {
        get
        {
            if (m_ContentConstraintCount > 0)
            {
                return m_ContentConstraintCount;
            }

            m_ContentConstraintCount = 1;
            if (content != null)
            {
                GridLayoutGroup layout2 = content.GetComponent<GridLayoutGroup>();
                if (layout2 != null)
                {
                    if (layout2.constraint == GridLayoutGroup.Constraint.Flexible)
                    {
                        Debug.LogWarning("[LoopScrollRect] Flexible not supported yet");
                    }

                    m_ContentConstraintCount = layout2.constraintCount;
                }
            }

            return m_ContentConstraintCount;
        }
    }

    // the first line
    int StartLine
    {
        get { return Mathf.CeilToInt((float)(itemTypeStart) / contentConstraintCount); }
    }

    // how many lines we have for now
    int CurrentLines
    {
        get { return Mathf.CeilToInt((float)(itemTypeEnd - itemTypeStart) / contentConstraintCount); }
    }

    // how many lines we have in total
    int TotalLines
    {
        get { return Mathf.CeilToInt((float)(totalCount) / contentConstraintCount); }
    }

    protected virtual bool UpdateItems(Bounds viewBounds, Bounds contentBounds)
    {
        bool changed = false;

        if (layoutType == ScrollViewLayoutType.Horizontal)
        {
            if (viewBounds.max.x + extraFillSize.x > contentBounds.max.x)
            {
                float size = NewItemAtEnd(), totalSize = size;
                while (size > 0 && viewBounds.max.x + extraFillSize.x > contentBounds.max.x + totalSize)
                {
                    size = NewItemAtEnd();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.min.x - extraFillSize.x < contentBounds.min.x)
            {
                float size = NewItemAtStart(), totalSize = size;
                while (size > 0 && viewBounds.min.x - extraFillSize.x < contentBounds.min.x - totalSize)
                {
                    size = NewItemAtStart();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.max.x + extraFillSize.x < contentBounds.max.x - threshold)
            {
                float size = DeleteItemAtEnd(), totalSize = size;
                while (size > 0 && viewBounds.max.x + extraFillSize.x < contentBounds.max.x - threshold - totalSize)
                {
                    size = DeleteItemAtEnd();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.min.x - extraFillSize.x > contentBounds.min.x + threshold)
            {
                float size = DeleteItemAtStart(), totalSize = size;
                while (size > 0 && viewBounds.min.x - extraFillSize.x > contentBounds.min.x + threshold + totalSize)
                {
                    size = DeleteItemAtStart();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }
        }
        else
        {
            if (viewBounds.min.y - extraFillSize.y < contentBounds.min.y)
            {
                float size = NewItemAtEnd(), totalSize = size;
                while (size > 0 && viewBounds.min.y - extraFillSize.y < contentBounds.min.y - totalSize)
                {
                    size = NewItemAtEnd();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.max.y + extraFillSize.y > contentBounds.max.y)
            {
                float size = NewItemAtStart(), totalSize = size;
                while (size > 0 && viewBounds.max.y + extraFillSize.y > contentBounds.max.y + totalSize)
                {
                    size = NewItemAtStart();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.min.y - extraFillSize.y > contentBounds.min.y + threshold)
            {
                float size = DeleteItemAtEnd(), totalSize = size;
                while (size > 0 && viewBounds.min.y - extraFillSize.y > contentBounds.min.y + threshold + totalSize)
                {
                    size = DeleteItemAtEnd();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }

            if (viewBounds.max.y + extraFillSize.y < contentBounds.max.y - threshold)
            {
                float size = DeleteItemAtStart(), totalSize = size;
                while (size > 0 && viewBounds.max.y + extraFillSize.y < contentBounds.max.y - threshold - totalSize)
                {
                    size = DeleteItemAtStart();
                    totalSize += size;
                }

                if (totalSize > 0)
                    changed = true;
            }
        }

        return changed;
    }
    //==========LoopScrollRect==========

    public enum MovementType
    {
        Unrestricted, // Unrestricted movement -- can scroll forever
        Elastic, // Restricted but flexible -- can go past the edges, but springs back in place
        Clamped, // Restricted movement where it's not possible to go past the edges
    }

    public enum ScrollbarVisibility
    {
        Permanent,
        AutoHide,
        AutoHideAndExpandViewport,
    }

    public enum ScrollViewLayoutType
    {
        Horizontal,
        Vertical
    }

    [SerializeField]
    private ScrollViewLayoutType layoutType;

    public ScrollViewLayoutType LayoutType
    {
        get { return layoutType; }
        //set { layoutType = value; }
    }

    [Serializable]
    public class ScrollRectEvent : UnityEvent<Vector2>
    {
    }

    [SerializeField]
    private RectTransform m_Content;

    public RectTransform content
    {
        get { return m_Content; }
        set { m_Content = value; }
    }

    [SerializeField]
    private MovementType m_MovementType = MovementType.Elastic;

    public MovementType movementType
    {
        get { return m_MovementType; }
        set { m_MovementType = value; }
    }

    [SerializeField]
    private float m_Elasticity = 0.1f; // Only used for MovementType.Elastic

    public float elasticity
    {
        get { return m_Elasticity; }
        set { m_Elasticity = value; }
    }

    [SerializeField]
    private bool m_Inertia = true;

    public bool inertia
    {
        get { return m_Inertia; }
        set { m_Inertia = value; }
    }

    [SerializeField]
    private float m_DecelerationRate = 0.135f; // Only used when inertia is enabled

    public float decelerationRate
    {
        get { return m_DecelerationRate; }
        set { m_DecelerationRate = value; }
    }

    [SerializeField]
    private float m_ScrollSensitivity = 1.0f;

    public float scrollSensitivity
    {
        get { return m_ScrollSensitivity; }
        set { m_ScrollSensitivity = value; }
    }

    [SerializeField]
    private RectTransform m_Viewport;

    public RectTransform viewport
    {
        get { return m_Viewport; }
        set
        {
            m_Viewport = value;
            SetDirtyCaching();
        }
    }

    [SerializeField]
    private Scrollbar m_HorizontalScrollbar;

    public Scrollbar horizontalScrollbar
    {
        get { return m_HorizontalScrollbar; }
        set
        {
            if (m_HorizontalScrollbar)
                m_HorizontalScrollbar.onValueChanged.RemoveListener(SetHorizontalNormalizedPosition);
            m_HorizontalScrollbar = value;
            if (m_HorizontalScrollbar)
                m_HorizontalScrollbar.onValueChanged.AddListener(SetHorizontalNormalizedPosition);
            SetDirtyCaching();
        }
    }

    [SerializeField]
    private Scrollbar m_VerticalScrollbar;

    public Scrollbar verticalScrollbar
    {
        get { return m_VerticalScrollbar; }
        set
        {
            if (m_VerticalScrollbar)
                m_VerticalScrollbar.onValueChanged.RemoveListener(SetVerticalNormalizedPosition);
            m_VerticalScrollbar = value;
            if (m_VerticalScrollbar)
                m_VerticalScrollbar.onValueChanged.AddListener(SetVerticalNormalizedPosition);
            SetDirtyCaching();
        }
    }

    [SerializeField]
    private ScrollbarVisibility m_HorizontalScrollbarVisibility;

    public ScrollbarVisibility horizontalScrollbarVisibility
    {
        get { return m_HorizontalScrollbarVisibility; }
        set
        {
            m_HorizontalScrollbarVisibility = value;
            SetDirtyCaching();
        }
    }

    [SerializeField]
    private ScrollbarVisibility m_VerticalScrollbarVisibility;

    public ScrollbarVisibility verticalScrollbarVisibility
    {
        get { return m_VerticalScrollbarVisibility; }
        set
        {
            m_VerticalScrollbarVisibility = value;
            SetDirtyCaching();
        }
    }

    [SerializeField]
    private float m_HorizontalScrollbarSpacing;

    public float horizontalScrollbarSpacing
    {
        get { return m_HorizontalScrollbarSpacing; }
        set
        {
            m_HorizontalScrollbarSpacing = value;
            SetDirty();
        }
    }

    [SerializeField]
    private float m_VerticalScrollbarSpacing;

    public float verticalScrollbarSpacing
    {
        get { return m_VerticalScrollbarSpacing; }
        set
        {
            m_VerticalScrollbarSpacing = value;
            SetDirty();
        }
    }

    [SerializeField]
    private ScrollRectEvent m_OnValueChanged = new ScrollRectEvent();

    public ScrollRectEvent onValueChanged
    {
        get { return m_OnValueChanged; }
        set { m_OnValueChanged = value; }
    }

    // The offset from handle position to mouse down position
    private Vector2 m_PointerStartLocalCursor = Vector2.zero;
    private Vector2 m_ContentStartPosition = Vector2.zero;

    private RectTransform m_ViewRect;

    protected RectTransform viewRect
    {
        get
        {
            if (m_ViewRect == null)
                m_ViewRect = m_Viewport;
            if (m_ViewRect == null)
                m_ViewRect = (RectTransform)transform;
            return m_ViewRect;
        }
    }

    private Bounds m_ContentBounds;
    private Bounds m_ViewBounds;

    private Vector2 m_Velocity;

    public Vector2 velocity
    {
        get { return m_Velocity; }
        set { m_Velocity = value; }
    }

    private bool m_Dragging;
    private bool m_viewportChanged = false;
    private Vector2 m_PrevPosition = Vector2.zero;
    private Bounds m_PrevContentBounds;
    private Bounds m_PrevViewBounds;

    [NonSerialized]
    private bool m_HasRebuiltLayout = false;

    private bool m_HSliderExpand;
    private bool m_VSliderExpand;
    private float m_HSliderHeight;
    private float m_VSliderWidth;

    [System.NonSerialized]
    private RectTransform m_Rect;

    private RectTransform rectTransform
    {
        get
        {
            if (m_Rect == null)
                m_Rect = GetComponent<RectTransform>();
            return m_Rect;
        }
    }

    private RectTransform m_HorizontalScrollbarRect;
    private RectTransform m_VerticalScrollbarRect;

    private DrivenRectTransformTracker m_Tracker;

    protected override void Awake()
    {
        base.Awake();
        CheckComponentConflict();
        
        flexibleWidth = -1;
        directionSign = layoutType == ScrollViewLayoutType.Horizontal ? 1 : -1;
        GridLayoutGroup layout = content.GetComponent<GridLayoutGroup>();
        if (layout != null 
            && ((layoutType == ScrollViewLayoutType.Horizontal && layout.constraint != GridLayoutGroup.Constraint.FixedRowCount)
                || (layoutType == ScrollViewLayoutType.Vertical && layout.constraint != GridLayoutGroup.Constraint.FixedColumnCount)))
        {
            //Debug.LogError("[LoopHorizontalScrollRect] unsupported GridLayoutGroup constraint");
        }
 
        RefillCells();
    }

    protected override void OnDestroy()
    {
        ClearRoute();
        foreach (var obj in itemObjectPool)
        {
            Destroy(obj.gameObject);
        }
    }

    //==========LoopScrollRect==========

    public void ClearCells()
    {
        if (Application.isPlaying)
        {
            itemTypeStart = 0;
            itemTypeEnd = 0;
            totalCount = 0;
            for (int i = content.childCount - 1; i >= 0; i--)
            {
                ReturnItemObject(content.GetChild(i).gameObject);
            }
        }
    }

    public void ScrollToCell(int index, float speed)
    {
        if (totalCount >= 0 && (index < 0 || index >= totalCount))
        {
            Debug.LogWarningFormat("invalid index {0}", index);
            return;
        }

        if (speed <= 0)
        {
            Debug.LogWarningFormat("invalid speed {0}", speed);
            return;
        }

        StopAllCoroutines();
        StartCoroutine(ScrollToCellCoroutine(index, speed));
    }

    public void StopScrollToCell(object obj)
    {
        StopAllCoroutines();
    }

    IEnumerator ScrollToCellCoroutine(int index, float speed)
    {
        bool needMoving = true;
        while (needMoving)
        {
            yield return null;
            if (!m_Dragging)
            {
                float move = 0;
                if (index < itemTypeStart)
                {
                    move = -Time.deltaTime * speed;
                }
                else if (index >= itemTypeEnd)
                {
                    move = Time.deltaTime * speed;
                }
                else
                {
                    m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
                    var m_ItemBounds = GetBounds4Item(index);
                    var offset = 0.0f;
                    if (directionSign == -1)
                        offset = reverseDirection ? (m_ViewBounds.min.y - m_ItemBounds.min.y) : (m_ViewBounds.max.y - m_ItemBounds.max.y);
                    else if (directionSign == 1)
                        offset = reverseDirection ? (m_ItemBounds.max.x - m_ViewBounds.max.x) : (m_ItemBounds.min.x - m_ViewBounds.min.x);
                    // check if we cannot move on
                    if (totalCount >= 0)
                    {
                        if (offset > 0 && itemTypeEnd == totalCount && !reverseDirection)
                        {
                            m_ItemBounds = GetBounds4Item(totalCount - 1);
                            // reach bottom
                            if ((directionSign == -1 && m_ItemBounds.min.y > m_ViewBounds.min.y) ||
                                (directionSign == 1 && m_ItemBounds.max.x < m_ViewBounds.max.x))
                            {
                                needMoving = false;
                                break;
                            }
                        }
                        else if (offset < 0 && itemTypeStart == 0 && reverseDirection)
                        {
                            m_ItemBounds = GetBounds4Item(0);
                            if ((directionSign == -1 && m_ItemBounds.max.y < m_ViewBounds.max.y) ||
                                (directionSign == 1 && m_ItemBounds.min.x > m_ViewBounds.min.x))
                            {
                                needMoving = false;
                                break;
                            }
                        }
                    }

                    float maxMove = Time.deltaTime * speed;
                    if (Mathf.Abs(offset) < maxMove)
                    {
                        needMoving = false;
                        move = offset;
                    }
                    else
                        move = Mathf.Sign(offset) * maxMove;
                }

                if (move != 0)
                {
                    Vector2 offset = GetVector(move);
                    content.anchoredPosition += offset;
                    m_PrevPosition += offset;
                    m_ContentStartPosition += offset;
                }
            }
        }

        StopMovement();
        UpdatePrevData();
    }

    // 刷新当前视口显示项
    public void RefreshCells()
    {
        if (Application.isPlaying && this.isActiveAndEnabled)
        {
            itemTypeEnd = itemTypeStart;
            // recycle items if we can
            for (int i = 0; i < content.childCount; i++)
            {
                var child = content.GetChild(i);
                if (itemTypeEnd < totalCount)
                {
                    OnItemMoveOut(child.gameObject, itemTypeEnd);
                    OnItemMoveIn(child.gameObject, itemTypeEnd);
                    itemTypeEnd++;
                }
                else
                {
                    OnItemMoveOut(child.gameObject, itemTypeStart + i);
                    ReturnItemObject(child.gameObject);
                    i--;
                }
            }
        }
    }

    public void RefillCellsFromEnd(int offset = 0)
    {
        if (!Application.isPlaying || itemTemplate == null)
            return;

        StopMovement();
        itemTypeEnd = reverseDirection ? offset : totalCount - offset;
        itemTypeStart = itemTypeEnd;

        if (totalCount >= 0 && itemTypeStart % contentConstraintCount != 0)
            Debug.LogWarning("Grid will become strange since we can't fill items in the last line");

        for (int i = m_Content.childCount - 1; i >= 0; i--)
        {
            var go = m_Content.GetChild(i).gameObject;
            OnItemMoveOut(go, --itemTypeEnd);
            ReturnItemObject(go);
        }

        float sizeToFill = 0, sizeFilled = 0;
        if (directionSign == -1)
            sizeToFill = viewRect.rect.size.y;
        else
            sizeToFill = viewRect.rect.size.x;

        while (sizeToFill > sizeFilled)
        {
            float size = reverseDirection ? NewItemAtEnd() : NewItemAtStart();
            if (size <= 0) break;
            sizeFilled += size;
        }

        Vector2 pos = m_Content.anchoredPosition;
        float dist = Mathf.Max(0, sizeFilled - sizeToFill);
        if (reverseDirection)
            dist = -dist;
        if (directionSign == -1)
            pos.y = dist;
        else if (directionSign == 1)
            pos.x = -dist;
        m_Content.anchoredPosition = pos;
    }

    public void SetExtraFillSize(float extraSizeX, float extraSizeY)
    {
        extraFillSize = new Vector2(extraSizeX, extraSizeY);
    }

    //
    //
    public void RefillCells(int offset = 0, bool fillViewRect = false)
    {
        if (!Application.isPlaying || itemTemplate == null)
            return;

        if (offset < 0 || offset >= totalCount)
        {
            //Debug.LogErrorFormat("offset {0} out of range: [{1}, {2}]", offset, 0, totalCount - 1);
            offset = 0;
        }

        StopMovement();

        //如果之前有残留,则先删除之前的
        // Don't `Canvas.ForceUpdateCanvases();` here, or it will new/delete cells to change itemTypeStart/End
        for (int i = m_Content.childCount - 1; i >= 0; i--)
        {
            var go = m_Content.GetChild(i).gameObject;
            OnItemMoveOut(go, --itemTypeEnd);
            ReturnItemObject(go);
        }

        itemTypeStart = reverseDirection ? totalCount - offset : offset;
        itemTypeEnd = itemTypeStart;

        //在这块会做一个警告处理,比如说我们总共12个,每行按照设置应该显示2个,那么我们经过上方的处理,我们需要按照行去减,如果下方不能整除,则表示显示会异常
        if (totalCount >= 0 && itemTypeStart % contentConstraintCount != 0)
            Debug.LogWarning("Grid will become strange since we can't fill items in the first line");


        if (directionSign == 0)
        {
            Debug.LogWarning("Awake还没执行到就调用了Refill!");
            return;  
        }

        float sizeToFill = 0, sizeFilled = 0;
        // m_ViewBounds may be not ready when RefillCells on Start
        //计算出当水平或竖直方向上,我们需要填充的区域大小
        if (directionSign == -1)
            sizeToFill = viewRect.rect.size.y + extraFillSize.y;
        else
            sizeToFill = viewRect.rect.size.x + extraFillSize.x;

        float itemSize = 0;

        //如果需要填充的大于已经填充的,则while去填充
        while (sizeToFill > sizeFilled)
        {
            float size = reverseDirection ? NewItemAtStart() : NewItemAtEnd();
            if (size <= 0) break;
            else 
                itemSize = size;
            sizeFilled += size;
        }

        float startPos = 0;
        if (extraFillSize.x > 0 || extraFillSize.y > 0)
        {
            if (directionSign == -1)
                sizeToFill += extraFillSize.y;
            else
                sizeToFill += extraFillSize.x;
            while (sizeToFill > sizeFilled)
            {
                float size = reverseDirection ? NewItemAtEnd() : NewItemAtStart();
                if (size <= 0) break;
                else itemSize = size;
                startPos -= size;
                sizeFilled += size;
            }
        }

        if (fillViewRect && itemSize > 0 && sizeFilled < sizeToFill)
        {
            int itemsToAddCount = (int)((sizeToFill - sizeFilled) / itemSize); //calculate how many items can be added above the offset, so it still is visible in the view
            int newOffset = offset - itemsToAddCount;
            if (newOffset < 0) newOffset = 0;
            if (newOffset != offset) RefillCells(newOffset); //refill again, with the new offset value, and now with fillViewRect disabled.
        }

        Vector2 pos = m_Content.anchoredPosition;
        if (directionSign == -1)
            pos.y = startPos;
        else if (directionSign == 1)
            pos.x = startPos;
        m_Content.anchoredPosition = pos;
    }

    protected float NewItemAtStart()
    {
        if (totalCount >= 0 && itemTypeStart - contentConstraintCount < 0)
        {
            return 0;
        }

        float size = 0;
        for (int i = 0; i < contentConstraintCount; i++)
        {
            itemTypeStart--;
            RectTransform newItem = InstantiateNextItem(itemTypeStart);
            newItem.SetAsFirstSibling();
            var preferredSize = GetSize(newItem);
            size = Mathf.Max(preferredSize, size);
            OnItemMoveIn(newItem.gameObject, itemTypeStart);
        }

        threshold = Mathf.Max(threshold, size * 1.5f);

        if (!reverseDirection)
        {
            Vector2 offset = GetVector(size);
            content.anchoredPosition += offset;
            m_PrevPosition += offset;
            m_ContentStartPosition += offset;
        }

        return size;
    }

    protected float DeleteItemAtStart()
    {
        // special case: when moving or dragging, we cannot simply delete start when we've reached the end
        if (((m_Dragging || m_Velocity != Vector2.zero) && totalCount >= 0 && itemTypeEnd >= totalCount - 1)
            || content.childCount == 0)
        {
            return 0;
        }

        float size = 0;
        for (int i = 0; i < contentConstraintCount; i++)
        {
            RectTransform oldItem = content.GetChild(0) as RectTransform;
            size = Mathf.Max(GetSize(oldItem), size);
            OnItemMoveOut(oldItem.gameObject, itemTypeStart);
            ReturnItemObject(oldItem.gameObject);

            itemTypeStart++;

            if (content.childCount == 0)
            {
                break;
            }
        }

        if (!reverseDirection)
        {
            Vector2 offset = GetVector(size);
            content.anchoredPosition -= offset;
            m_PrevPosition -= offset;
            m_ContentStartPosition -= offset;
        }

        return size;
    }


    protected float NewItemAtEnd()
    {
        if (totalCount >= 0 && itemTypeEnd >= totalCount)
        {
            return 0;
        }

        float size = 0;
        // issue 4: fill lines to end first
        int count = contentConstraintCount - (content.childCount % contentConstraintCount);
        for (int i = 0; i < count; i++)
        {
            RectTransform newItem = InstantiateNextItem(itemTypeEnd);
            size = Mathf.Max(GetSize(newItem), size);
            OnItemMoveIn(newItem.gameObject, itemTypeEnd);
            itemTypeEnd++;
            if (totalCount >= 0 && itemTypeEnd >= totalCount)
            {
                break;
            }
        }

        threshold = Mathf.Max(threshold, size * 1.5f);

        if (reverseDirection)
        {
            Vector2 offset = GetVector(size);
            content.anchoredPosition -= offset;
            m_PrevPosition -= offset;
            m_ContentStartPosition -= offset;
        }

        return size;
    }

    protected float DeleteItemAtEnd()
    {
        if (((m_Dragging || m_Velocity != Vector2.zero) && totalCount >= 0 && itemTypeStart < contentConstraintCount)
            || content.childCount == 0)
        {
            return 0;
        }

        float size = 0;
        for (int i = 0; i < contentConstraintCount; i++)
        {
            RectTransform oldItem = content.GetChild(content.childCount - 1) as RectTransform;
            size = Mathf.Max(GetSize(oldItem), size);
            OnItemMoveOut(oldItem.gameObject, --itemTypeEnd);
            ReturnItemObject(oldItem.gameObject);

            if (itemTypeEnd % contentConstraintCount == 0 || content.childCount == 0)
            {
                break; //just delete the whole row
            }
        }

        if (reverseDirection)
        {
            Vector2 offset = GetVector(size);
            content.anchoredPosition += offset;
            m_PrevPosition += offset;
            m_ContentStartPosition += offset;
        }

        return size;
    }

    private RectTransform InstantiateNextItem(int itemIdx)
    {
        RectTransform nextItem = GetItemObject(content, false).transform as RectTransform;
        if (nextItem != null)
        {
            nextItem.gameObject.SetActive(true);
        }
        
        return nextItem;
    }
    //==========LoopScrollRect==========

    public virtual void Rebuild(CanvasUpdate executing)
    {
        if (executing == CanvasUpdate.Prelayout)
        {
            UpdateCachedData();
        }

        if (executing == CanvasUpdate.PostLayout)
        {
            UpdateBounds();
            UpdateScrollbars(Vector2.zero);
            UpdatePrevData();

            m_HasRebuiltLayout = true;
        }
    }

    public virtual void LayoutComplete()
    {
    }

    public virtual void GraphicUpdateComplete()
    {
    }

    void UpdateCachedData()
    {
        Transform transform = this.transform;
        m_HorizontalScrollbarRect = m_HorizontalScrollbar == null ? null : m_HorizontalScrollbar.transform as RectTransform;
        m_VerticalScrollbarRect = m_VerticalScrollbar == null ? null : m_VerticalScrollbar.transform as RectTransform;

        // These are true if either the elements are children, or they don't exist at all.
        bool viewIsChild = (viewRect.parent == transform);
        bool hScrollbarIsChild = (!m_HorizontalScrollbarRect || m_HorizontalScrollbarRect.parent == transform);
        bool vScrollbarIsChild = (!m_VerticalScrollbarRect || m_VerticalScrollbarRect.parent == transform);
        bool allAreChildren = (viewIsChild && hScrollbarIsChild && vScrollbarIsChild);

        m_HSliderExpand = allAreChildren && m_HorizontalScrollbarRect && horizontalScrollbarVisibility == ScrollbarVisibility.AutoHideAndExpandViewport;
        m_VSliderExpand = allAreChildren && m_VerticalScrollbarRect && verticalScrollbarVisibility == ScrollbarVisibility.AutoHideAndExpandViewport;
        m_HSliderHeight = (m_HorizontalScrollbarRect == null ? 0 : m_HorizontalScrollbarRect.rect.height);
        m_VSliderWidth = (m_VerticalScrollbarRect == null ? 0 : m_VerticalScrollbarRect.rect.width);
    }

    protected override void OnEnable()
    {
        base.OnEnable();

        GameEntry.Event.Subscribe(EventId.StopSvAutoToCell, StopScrollToCell);
        
        if (m_HorizontalScrollbar)
            m_HorizontalScrollbar.onValueChanged.AddListener(SetHorizontalNormalizedPosition);
        if (m_VerticalScrollbar)
            m_VerticalScrollbar.onValueChanged.AddListener(SetVerticalNormalizedPosition);

        CanvasUpdateRegistry.RegisterCanvasElementForLayoutRebuild(this);
    }

    protected override void OnDisable()
    {
        CanvasUpdateRegistry.UnRegisterCanvasElementForRebuild(this);
        
        GameEntry.Event.Unsubscribe(EventId.StopSvAutoToCell, StopScrollToCell);

        if (m_HorizontalScrollbar)
            m_HorizontalScrollbar.onValueChanged.RemoveListener(SetHorizontalNormalizedPosition);
        if (m_VerticalScrollbar)
            m_VerticalScrollbar.onValueChanged.RemoveListener(SetVerticalNormalizedPosition);

        m_HasRebuiltLayout = false;
        m_Tracker.Clear();
        m_Velocity = Vector2.zero;
        LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
        base.OnDisable();
    }

    public override bool IsActive()
    {
        return base.IsActive() && m_Content != null;
    }

    private void EnsureLayoutHasRebuilt()
    {
        if (!m_HasRebuiltLayout && !CanvasUpdateRegistry.IsRebuildingLayout())
            Canvas.ForceUpdateCanvases();
    }

    public virtual void StopMovement()
    {
        m_Velocity = Vector2.zero;
    }

    public virtual void OnScroll(PointerEventData data)
    {
        if (!IsActive())
            return;

        EnsureLayoutHasRebuilt();
        UpdateBounds();

        Vector2 delta = data.scrollDelta;
        // Down is positive for scroll events, while in UI system up is positive.
        delta.y *= -1;
        if (layoutType == ScrollViewLayoutType.Vertical)
        {
            if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y))
                delta.y = delta.x;
            delta.x = 0;
        }

        if (layoutType == ScrollViewLayoutType.Horizontal)
        {
            if (Mathf.Abs(delta.y) > Mathf.Abs(delta.x))
                delta.x = delta.y;
            delta.y = 0;
        }

        Vector2 position = m_Content.anchoredPosition;
        position += delta * m_ScrollSensitivity;
        if (m_MovementType == MovementType.Clamped)
            position += CalculateOffset(position - m_Content.anchoredPosition);

        SetContentAnchoredPosition(position);
        UpdateBounds();
    }

    public virtual void OnInitializePotentialDrag(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        m_Velocity = Vector2.zero;
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        StopAllCoroutines();
    }

    #region 嵌套滚动处理

    public bool nestedScrolling = false;
    
    private bool _routing;
    private GameObject _routeObject;

    private void RoutePointerEvent<T>(PointerEventData eventData, ExecuteEvents.EventFunction<T> functor) where T : IEventSystemHandler
    {
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventData, results);

        if (_routeObject != null)
        {
            ExecuteEvents.Execute(_routeObject, eventData, functor); 
            return;
        }
        
        foreach (var result in results)
        {
            // Skip self to avoid duplicate handling
            if (result.gameObject == gameObject) continue;

            if (result.gameObject.GetComponent<IDragHandler>() == null) 
                continue;
            
            _routeObject = result.gameObject;
            ExecuteEvents.Execute(result.gameObject, eventData, functor);
            // Debug.Log($"{gameObject.name}, raycasted {result.gameObject.name}");
            break;
        }
    }

    private void ClearRoute()
    {
        _routing = false;
        _routeObject = null; 
    }
    
    #endregion
    
    public virtual void OnBeginDrag(PointerEventData eventData)
    {
        if (nestedScrolling)
        {
            switch (layoutType)
            {
                case ScrollViewLayoutType.Vertical when Math.Abs(eventData.delta.x) > Math.Abs(eventData.delta.y):
                case ScrollViewLayoutType.Horizontal when Math.Abs(eventData.delta.x) < Math.Abs(eventData.delta.y):
                    _routing = true;
                    break;
                default:
                    _routing = false;
                    break;
            }
        }

        if (_routing)
        {
            RoutePointerEvent(eventData, ExecuteEvents.beginDragHandler);
            return;
        }
        
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        if (!IsActive())
            return;

        StopScrollToCell(null);
        UpdateBounds();

        m_PointerStartLocalCursor = Vector2.zero;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(viewRect, eventData.position, eventData.pressEventCamera, out m_PointerStartLocalCursor);
        m_ContentStartPosition = m_Content.anchoredPosition;
        m_Dragging = true;
    }

    public virtual void OnEndDrag(PointerEventData eventData)
    {
        if (_routing)
        {
            RoutePointerEvent(eventData, ExecuteEvents.endDragHandler);
            ClearRoute();
        }
        
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        m_Dragging = false;
    }

    public virtual void OnDrag(PointerEventData eventData)
    {
        if (_routing)
        {
            RoutePointerEvent(eventData, ExecuteEvents.dragHandler);
            return;
        }
        
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        if (!IsActive())
            return;

        Vector2 localCursor;
        if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(viewRect, eventData.position, eventData.pressEventCamera, out localCursor))
            return;

        UpdateBounds();

        var pointerDelta = localCursor - m_PointerStartLocalCursor;
        Vector2 position = m_ContentStartPosition + pointerDelta;

        // Offset to get content into place in the view.
        Vector2 offset = CalculateOffset(position - m_Content.anchoredPosition);
        position += offset;
        if (m_MovementType == MovementType.Elastic)
        {
            //==========LoopScrollRect==========
            if (offset.x != 0)
                position.x = position.x - RubberDelta(offset.x, m_ViewBounds.size.x) * rubberScale;
            if (offset.y != 0)
                position.y = position.y - RubberDelta(offset.y, m_ViewBounds.size.y) * rubberScale;
            //==========LoopScrollRect==========
        }

        SetContentAnchoredPosition(position);
    }

    protected virtual void SetContentAnchoredPosition(Vector2 position)
    {
        if (layoutType == ScrollViewLayoutType.Vertical)
            position.x = m_Content.anchoredPosition.x;
        if (layoutType == ScrollViewLayoutType.Horizontal)
            position.y = m_Content.anchoredPosition.y;

        if (position != m_Content.anchoredPosition)
        {
            m_Content.anchoredPosition = position;
            UpdateBounds(true);
        }
    }

    protected virtual void LateUpdate()
    {
        if (!m_Content)
            return;

        EnsureLayoutHasRebuilt();
        UpdateScrollbarVisibility();
        UpdateBounds(m_viewportChanged, true);
        float deltaTime = Time.unscaledDeltaTime;
        Vector2 offset = CalculateOffset(Vector2.zero);
        if (!m_Dragging && (offset != Vector2.zero || m_Velocity != Vector2.zero))
        {
            Vector2 position = m_Content.anchoredPosition;
            for (int axis = 0; axis < 2; axis++)
            {
                // Apply spring physics if movement is elastic and content has an offset from the view.
                if (m_MovementType == MovementType.Elastic && offset[axis] != 0)
                {
                    float speed = m_Velocity[axis];
                    position[axis] = Mathf.SmoothDamp(m_Content.anchoredPosition[axis], m_Content.anchoredPosition[axis] + offset[axis], ref speed, m_Elasticity, Mathf.Infinity, deltaTime);
                    m_Velocity[axis] = speed;
                }
                // Else move content according to velocity with deceleration applied.
                else if (m_Inertia)
                {
                    m_Velocity[axis] *= Mathf.Pow(m_DecelerationRate, deltaTime);
                    if (Mathf.Abs(m_Velocity[axis]) < 1)
                        m_Velocity[axis] = 0;
                    position[axis] += m_Velocity[axis] * deltaTime;
                }
                // If we have neither elaticity or friction, there shouldn't be any velocity.
                else
                {
                    m_Velocity[axis] = 0;
                }
            }

            if (m_Velocity != Vector2.zero)
            {
                if (m_MovementType == MovementType.Clamped)
                {
                    offset = CalculateOffset(position - m_Content.anchoredPosition);
                    position += offset;
                }

                SetContentAnchoredPosition(position);
            }
        }

        if (m_Dragging && m_Inertia)
        {
            Vector3 newVelocity = (m_Content.anchoredPosition - m_PrevPosition) / deltaTime;
            m_Velocity = Vector3.Lerp(m_Velocity, newVelocity, deltaTime * 10);
        }

        if (m_ViewBounds != m_PrevViewBounds || m_ContentBounds != m_PrevContentBounds || m_Content.anchoredPosition != m_PrevPosition)
        {
            UpdateScrollbars(offset);
            m_OnValueChanged.Invoke(normalizedPosition);
            UpdatePrevData();
        }
    }

    private void UpdatePrevData()
    {
        if (m_Content == null)
            m_PrevPosition = Vector2.zero;
        else
            m_PrevPosition = m_Content.anchoredPosition;
        m_PrevViewBounds = m_ViewBounds;
        m_PrevContentBounds = m_ContentBounds;
    }

    private void UpdateScrollbars(Vector2 offset)
    {
        if (m_HorizontalScrollbar)
        {
            //==========LoopScrollRect==========
            if (m_ContentBounds.size.x > 0 && totalCount > 0)
            {
                m_HorizontalScrollbar.size = Mathf.Clamp01((m_ViewBounds.size.x - Mathf.Abs(offset.x)) / m_ContentBounds.size.x * CurrentLines / TotalLines);
            }
            //==========LoopScrollRect==========
            else
                m_HorizontalScrollbar.size = 1;

            m_HorizontalScrollbar.value = horizontalNormalizedPosition;
        }

        if (m_VerticalScrollbar)
        {
            //==========LoopScrollRect==========
            if (m_ContentBounds.size.y > 0 && totalCount > 0)
            {
                m_VerticalScrollbar.size = Mathf.Clamp01((m_ViewBounds.size.y - Mathf.Abs(offset.y)) / m_ContentBounds.size.y * CurrentLines / TotalLines);
            }
            //==========LoopScrollRect==========
            else
                m_VerticalScrollbar.size = 1;

            m_VerticalScrollbar.value = verticalNormalizedPosition;
        }
    }

    public Vector2 normalizedPosition
    {
        get { return new Vector2(horizontalNormalizedPosition, verticalNormalizedPosition); }
        set
        {
            SetNormalizedPosition(value.x, 0);
            SetNormalizedPosition(value.y, 1);
        }
    }

    public float horizontalNormalizedPosition
    {
        get
        {
            UpdateBounds();
            //==========LoopScrollRect==========
            if (totalCount > 0 && itemTypeEnd > itemTypeStart)
            {
                //TODO: consider contentSpacing
                float elementSize = m_ContentBounds.size.x / CurrentLines;
                float totalSize = elementSize * TotalLines;
                float offset = m_ContentBounds.min.x - elementSize * StartLine;

                if (totalSize <= m_ViewBounds.size.x)
                    return (m_ViewBounds.min.x > offset) ? 1 : 0;
                return (m_ViewBounds.min.x - offset) / (totalSize - m_ViewBounds.size.x);
            }
            else
                return 0.5f;

            //==========LoopScrollRect==========
        }
        set { SetNormalizedPosition(value, 0); }
    }

    public float verticalNormalizedPosition
    {
        get
        {
            UpdateBounds();
            //==========LoopScrollRect==========
            if (totalCount > 0 && itemTypeEnd > itemTypeStart)
            {
                //TODO: consider contentSpacinge
                float elementSize = m_ContentBounds.size.y / CurrentLines;
                float totalSize = elementSize * TotalLines;
                float offset = m_ContentBounds.max.y + elementSize * StartLine;

                if (totalSize <= m_ViewBounds.size.y)
                    return (offset > m_ViewBounds.max.y) ? 1 : 0;
                return (offset - m_ViewBounds.max.y) / (totalSize - m_ViewBounds.size.y);
            }
            else
                return 0.5f;

            //==========LoopScrollRect==========
        }
        set { SetNormalizedPosition(value, 1); }
    }

    private void SetHorizontalNormalizedPosition(float value)
    {
        SetNormalizedPosition(value, 0);
    }

    private void SetVerticalNormalizedPosition(float value)
    {
        SetNormalizedPosition(value, 1);
    }

    private void SetNormalizedPosition(float value, int axis)
    {
        //==========LoopScrollRect==========
        if (totalCount <= 0 || itemTypeEnd <= itemTypeStart)
            return;
        //==========LoopScrollRect==========

        EnsureLayoutHasRebuilt();
        UpdateBounds();

        //==========LoopScrollRect==========
        Vector3 localPosition = m_Content.localPosition;
        float newLocalPosition = localPosition[axis];
        if (axis == 0)
        {
            float elementSize = m_ContentBounds.size.x / CurrentLines;
            float totalSize = elementSize * TotalLines;
            float offset = m_ContentBounds.min.x - elementSize * StartLine;

            newLocalPosition += m_ViewBounds.min.x - value * (totalSize - m_ViewBounds.size[axis]) - offset;
        }
        else if (axis == 1)
        {
            float elementSize = m_ContentBounds.size.y / CurrentLines;
            float totalSize = elementSize * TotalLines;
            float offset = m_ContentBounds.max.y + elementSize * StartLine;

            newLocalPosition -= offset - value * (totalSize - m_ViewBounds.size.y) - m_ViewBounds.max.y;
        }
        //==========LoopScrollRect==========

        if (Mathf.Abs(localPosition[axis] - newLocalPosition) > 0.01f)
        {
            localPosition[axis] = newLocalPosition;
            m_Content.localPosition = localPosition;
            m_Velocity[axis] = 0;
            UpdateBounds(true);
        }
    }

    private static float RubberDelta(float overStretching, float viewSize)
    {
        return (1 - (1 / ((Mathf.Abs(overStretching) * 0.55f / viewSize) + 1))) * viewSize * Mathf.Sign(overStretching);
    }

    protected override void OnRectTransformDimensionsChange()
    {
        SetDirty();
    }

    private bool hScrollingNeeded
    {
        get
        {
            if (Application.isPlaying)
                return m_ContentBounds.size.x > m_ViewBounds.size.x + 0.01f;
            return true;
        }
    }

    private bool vScrollingNeeded
    {
        get
        {
            if (Application.isPlaying)
                return m_ContentBounds.size.y > m_ViewBounds.size.y + 0.01f;
            return true;
        }
    }

    public virtual void CalculateLayoutInputHorizontal()
    {
    }

    public virtual void CalculateLayoutInputVertical()
    {
    }

    public virtual float minWidth
    {
        get { return -1; }
    }

    public virtual float preferredWidth
    {
        get { return -1; }
    }

    public virtual float flexibleWidth { get; private set; }

    public virtual float minHeight
    {
        get { return -1; }
    }

    public virtual float preferredHeight
    {
        get { return -1; }
    }

    public virtual float flexibleHeight
    {
        get { return -1; }
    }

    public virtual int layoutPriority
    {
        get { return -1; }
    }

    public virtual void SetLayoutHorizontal()
    {
        m_Tracker.Clear();

        if (m_HSliderExpand || m_VSliderExpand)
        {
            m_Tracker.Add(this, viewRect,
                DrivenTransformProperties.Anchors |
                DrivenTransformProperties.SizeDelta |
                DrivenTransformProperties.AnchoredPosition);

            // Make view full size to see if content fits.
            viewRect.anchorMin = Vector2.zero;
            viewRect.anchorMax = Vector2.one;
            viewRect.sizeDelta = Vector2.zero;
            viewRect.anchoredPosition = Vector2.zero;

            // Recalculate content layout with this size to see if it fits when there are no scrollbars.
            LayoutRebuilder.ForceRebuildLayoutImmediate(content);
            m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
            m_ContentBounds = GetBounds();
        }

        // If it doesn't fit vertically, enable vertical scrollbar and shrink view horizontally to make room for it.
        if (m_VSliderExpand && vScrollingNeeded)
        {
            viewRect.sizeDelta = new Vector2(-(m_VSliderWidth + m_VerticalScrollbarSpacing), viewRect.sizeDelta.y);

            // Recalculate content layout with this size to see if it fits vertically
            // when there is a vertical scrollbar (which may reflowed the content to make it taller).
            LayoutRebuilder.ForceRebuildLayoutImmediate(content);
            m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
            m_ContentBounds = GetBounds();
        }

        // If it doesn't fit horizontally, enable horizontal scrollbar and shrink view vertically to make room for it.
        if (m_HSliderExpand && hScrollingNeeded)
        {
            viewRect.sizeDelta = new Vector2(viewRect.sizeDelta.x, -(m_HSliderHeight + m_HorizontalScrollbarSpacing));
            m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
            m_ContentBounds = GetBounds();
        }

        // If the vertical slider didn't kick in the first time, and the horizontal one did,
        // we need to check again if the vertical slider now needs to kick in.
        // If it doesn't fit vertically, enable vertical scrollbar and shrink view horizontally to make room for it.
        if (m_VSliderExpand && vScrollingNeeded && viewRect.sizeDelta.x == 0 && viewRect.sizeDelta.y < 0)
        {
            viewRect.sizeDelta = new Vector2(-(m_VSliderWidth + m_VerticalScrollbarSpacing), viewRect.sizeDelta.y);
        }
    }

    public virtual void SetLayoutVertical()
    {
        UpdateScrollbarLayout();
        m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
        m_ContentBounds = GetBounds();
    }

    void UpdateScrollbarVisibility()
    {
        if (m_VerticalScrollbar && m_VerticalScrollbarVisibility != ScrollbarVisibility.Permanent && m_VerticalScrollbar.gameObject.activeSelf != vScrollingNeeded)
            m_VerticalScrollbar.gameObject.SetActive(vScrollingNeeded);

        if (m_HorizontalScrollbar && m_HorizontalScrollbarVisibility != ScrollbarVisibility.Permanent && m_HorizontalScrollbar.gameObject.activeSelf != hScrollingNeeded)
            m_HorizontalScrollbar.gameObject.SetActive(hScrollingNeeded);
    }

    void UpdateScrollbarLayout()
    {
        if (m_VSliderExpand && m_HorizontalScrollbar)
        {
            m_Tracker.Add(this, m_HorizontalScrollbarRect,
                DrivenTransformProperties.AnchorMinX |
                DrivenTransformProperties.AnchorMaxX |
                DrivenTransformProperties.SizeDeltaX |
                DrivenTransformProperties.AnchoredPositionX);
            m_HorizontalScrollbarRect.anchorMin = new Vector2(0, m_HorizontalScrollbarRect.anchorMin.y);
            m_HorizontalScrollbarRect.anchorMax = new Vector2(1, m_HorizontalScrollbarRect.anchorMax.y);
            m_HorizontalScrollbarRect.anchoredPosition = new Vector2(0, m_HorizontalScrollbarRect.anchoredPosition.y);
            if (vScrollingNeeded)
                m_HorizontalScrollbarRect.sizeDelta = new Vector2(-(m_VSliderWidth + m_VerticalScrollbarSpacing), m_HorizontalScrollbarRect.sizeDelta.y);
            else
                m_HorizontalScrollbarRect.sizeDelta = new Vector2(0, m_HorizontalScrollbarRect.sizeDelta.y);
        }

        if (m_HSliderExpand && m_VerticalScrollbar)
        {
            m_Tracker.Add(this, m_VerticalScrollbarRect,
                DrivenTransformProperties.AnchorMinY |
                DrivenTransformProperties.AnchorMaxY |
                DrivenTransformProperties.SizeDeltaY |
                DrivenTransformProperties.AnchoredPositionY);
            m_VerticalScrollbarRect.anchorMin = new Vector2(m_VerticalScrollbarRect.anchorMin.x, 0);
            m_VerticalScrollbarRect.anchorMax = new Vector2(m_VerticalScrollbarRect.anchorMax.x, 1);
            m_VerticalScrollbarRect.anchoredPosition = new Vector2(m_VerticalScrollbarRect.anchoredPosition.x, 0);
            if (hScrollingNeeded)
                m_VerticalScrollbarRect.sizeDelta = new Vector2(m_VerticalScrollbarRect.sizeDelta.x, -(m_HSliderHeight + m_HorizontalScrollbarSpacing));
            else
                m_VerticalScrollbarRect.sizeDelta = new Vector2(m_VerticalScrollbarRect.sizeDelta.x, 0);
        }
    }

    private void UpdateBounds(bool updateItems = false, bool checkBounds = false)
    {
        m_ViewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
        m_viewportChanged = m_PrevViewBounds != m_ViewBounds;
        var oldContentBounds = m_ContentBounds;
        m_ContentBounds = GetBounds();
        bool boundsChange = oldContentBounds != m_ContentBounds;
        if (m_Content == null)
            return;

        // ============LoopScrollRect============
        // Don't do this in Rebuild
        if (Application.isPlaying && (updateItems) && UpdateItems(m_ViewBounds, m_ContentBounds))
        {
            LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform);
            m_ContentBounds = GetBounds();
        }
        // ============LoopScrollRect============

        // Make sure content bounds are at least as large as view by adding padding if not.
        // One might think at first that if the content is smaller than the view, scrolling should be allowed.
        // However, that's not how scroll views normally work.
        // Scrolling is *only* possible when content is *larger* than view.
        // We use the pivot of the content rect to decide in which directions the content bounds should be expanded.
        // E.g. if pivot is at top, bounds are expanded downwards.
        // This also works nicely when ContentSizeFitter is used on the content.
        Vector3 contentSize = m_ContentBounds.size;
        Vector3 contentPos = m_ContentBounds.center;
        Vector3 excess = m_ViewBounds.size - contentSize;
        if (excess.x > 0)
        {
            contentPos.x -= excess.x * (m_Content.pivot.x - 0.5f);
            contentSize.x = m_ViewBounds.size.x;
        }

        if (excess.y > 0)
        {
            contentPos.y -= excess.y * (m_Content.pivot.y - 0.5f);
            contentSize.y = m_ViewBounds.size.y;
        }

        m_ContentBounds.size = contentSize;
        m_ContentBounds.center = contentPos;
    }

    private readonly Vector3[] m_Corners = new Vector3[4];

    private Bounds GetBounds()
    {
        if (m_Content == null)
            return new Bounds();

        var vMin = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
        var vMax = new Vector3(float.MinValue, float.MinValue, float.MinValue);

        var toLocal = viewRect.worldToLocalMatrix;
        m_Content.GetLocalCorners(m_Corners);
        var bounds1 = new Bounds();
        bounds1.SetMinMax(m_Corners[0], m_Corners[2]);
        
        m_Content.GetWorldCorners(m_Corners);
        for (int j = 0; j < 4; j++)
        {
            Vector3 v = toLocal.MultiplyPoint3x4(m_Corners[j]);
            vMin = Vector3.Min(v, vMin);
            vMax = Vector3.Max(v, vMax);
        }

        var bounds = new Bounds(vMin, Vector3.zero);
        bounds.Encapsulate(vMax);
        //Debug.Log($">>>bounds1: name: {transform.name} center: {bounds1.center}  size: {bounds1.extents}  bound center: {bounds.center}  size: {bounds.extents}");
        return bounds;
    }

    private Bounds GetBounds4Item(int index)
    {
        if (m_Content == null)
            return new Bounds();

        var vMin = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
        var vMax = new Vector3(float.MinValue, float.MinValue, float.MinValue);

        var toLocal = viewRect.worldToLocalMatrix;
        int offset = index - itemTypeStart;
        if (offset < 0 || offset >= m_Content.childCount)
            return new Bounds();
        var rt = m_Content.GetChild(offset) as RectTransform;
        if (rt == null)
            return new Bounds();
        rt.GetWorldCorners(m_Corners);
        for (int j = 0; j < 4; j++)
        {
            Vector3 v = toLocal.MultiplyPoint3x4(m_Corners[j]);
            vMin = Vector3.Min(v, vMin);
            vMax = Vector3.Max(v, vMax);
        }

        var bounds = new Bounds(vMin, Vector3.zero);
        bounds.Encapsulate(vMax);
        return bounds;
    }

    private Vector2 CalculateOffset(Vector2 delta)
    {
        Vector2 offset = Vector2.zero;
        if (m_MovementType == MovementType.Unrestricted)
            return offset;
        if (m_MovementType == MovementType.Clamped)
        {
            if (totalCount < 0)
                return offset;
            if (GetDimension(delta) < 0 && itemTypeStart > 0)
                return offset;
            if (GetDimension(delta) > 0 && itemTypeEnd < totalCount)
                return offset;
        }

        Vector2 min = m_ContentBounds.min;
        Vector2 max = m_ContentBounds.max;

        if (layoutType == ScrollViewLayoutType.Horizontal)
        {
            min.x += delta.x;
            max.x += delta.x;
            if (min.x > m_ViewBounds.min.x)
                offset.x = m_ViewBounds.min.x - min.x;
            else if (max.x < m_ViewBounds.max.x)
                offset.x = m_ViewBounds.max.x - max.x;
        }
        else if (layoutType == ScrollViewLayoutType.Vertical)
        {
            min.y += delta.y;
            max.y += delta.y;
            if (max.y < m_ViewBounds.max.y)
                offset.y = m_ViewBounds.max.y - max.y;
            else if (min.y > m_ViewBounds.min.y)
                offset.y = m_ViewBounds.min.y - min.y;
        }

        return offset;
    }

    protected void SetDirty()
    {
        if (!IsActive())
            return;

        LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
    }

    protected void SetDirtyCaching()
    {
        if (!IsActive())
            return;

        CanvasUpdateRegistry.RegisterCanvasElementForLayoutRebuild(this);
        LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
    }

    private GameObject GetItemObject(Transform parent, bool worldPositionStays)
    {
        ItemObject itemObj = itemObjectPool.Find(i => !i.used);
        if (itemObj != null)
        {
            itemObj.gameObject.transform.SetParent(content, false);
            itemObj.used = true;
            return itemObj.gameObject;
        }

        var go = Instantiate(itemTemplate, parent, worldPositionStays);
        var trans = go.GetComponent<RectTransform>();
        trans.anchoredPosition3D = Vector3.zero;
        trans.localScale = Vector3.one;

        itemObj = new ItemObject {gameObject = go, used = true};
        itemObjectPool.Add(itemObj);
        
        return go;
    }

    private void ReturnItemObject(GameObject go)
    {
        go.transform.SetParent(ObjectPoolRoot, false);
        go.SetActive(false);
        
        var itemObj = itemObjectPool.Find(i => i.gameObject == go);
        if(itemObj != null)
            itemObj.used = false;
    }

    private void OnItemMoveIn(GameObject itemObj, int index)
    {
        onItemMoveIn?.Invoke(itemObj, index);
    }
    
    private void OnItemMoveOut(GameObject itemObj, int index)
    {
        onItemMoveOut?.Invoke(itemObj, index);
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        SetDirtyCaching();
    }
#endif

    private void CheckComponentConflict()
    {
        var scrollRectCom = GetComponent<ScrollRect>();
        if (scrollRectCom != null)
        {
            Debug.LogError("#zlh# 挂有ScrollView的GameObject不应该再包含ScrollRect! 功能冗余且会出现位置异常！ 请手动清理!!!");
#if UNITY_EDITOR
            DestroyImmediate(scrollRectCom);
#else
            Destroy(scrollRectCom);
#endif
        }
    }
    
    public delegate void MoveItemDelegate(GameObject itemObj, int index);

    public MoveItemDelegate onItemMoveIn;
    public MoveItemDelegate onItemMoveOut;
}





