using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ScrollControl : MonoBehaviour
{
    /// <summary>
    /// 是否需要进行滑动方向判定
    /// </summary>
    private bool mNeedCaculate = false;

    /// <summary>
    /// 是否进行竖向滚动
    /// </summary>
    private bool mIsScollV = false;
    /// <summary>
    /// 滑动敏感值
    /// </summary>
    public float m_Sensitive;
    private ScrollRect rect;                            // 滑动组件 
    private List<float> posList = new List<float>();    // 求出每页的临界角，页索引从0开始  
    private float m_HorizontalLength;                   // 滑动区域长度
    private float mPageWidth;                           // 宽度
    private ScrollRect m_CurTransform;                  // 当前page
    private float targethorizontal = 0;                 // 滑动的起始坐标
    private bool isDrag = false;                        // 是否拖拽结束  
    private bool stopMove = true;                       // 是否停止滑动
    public float smooting = 3;                          // 滑动速度  
    private int m_Num;
    private Vector3 mOldPosition;
    private float startTime;
    private float startDragHorizontal;

    private int m_CurPage = 0;

    [SerializeField]
    private InputControl inputControl = null;

    void Awake()
    {
        rect = transform.GetComponent<ScrollRect>();
    }

    public int AllNum
    {
        get { return m_Num; }
    }

    public int CurPage
    {
        get { return m_CurPage; }
    }

    public void Refresh()
    {
        rect = transform.GetComponent<ScrollRect>();
        m_Num = rect.content.transform.childCount;
        m_Num = m_Num > 0 ? m_Num : 1;
        mPageWidth = GetComponent<RectTransform>().rect.width;
        m_HorizontalLength = rect.content.rect.width - mPageWidth;
        m_CurTransform = GetTransformByIndex(GetCurrentIndex());
        m_CurPage = GetCurrentIndex();
        posList.Clear();
        catchScrollRect.Clear();
        /*posList.Add(0);
        for (int i = 1; i < rect.content.transform.childCount - 1; i++)
        {
            posList.Add(GetComponent<RectTransform>().rect.width * i / m_HorizontalLength);
        }
        posList.Add(1);*/
        //xiadonghui 20190124 修改分页计算horizontalNormalizedPosition值的计算方式
        int chCount = rect.content.transform.childCount;
        float pre = 1f / ((float)chCount - 1);
        for (int i = 0; i < chCount; i++)
        {
            posList.Add(i * pre);
        }

        targethorizontal = posList[0];
    }

    private void OnPointerDown(Vector2 mousePosition)
    {
        mNeedCaculate = true;
        isDrag = true;
        startDragHorizontal = rect.horizontalNormalizedPosition;
        mOldPosition = Input.mousePosition;
    }

    private void OnDrag(Vector2 mousePosition)
    {
        Vector2 dragVector = Input.mousePosition - mOldPosition;

        if (Mathf.Abs(dragVector.x) < 6 && Mathf.Abs(dragVector.y) < 6)
        {
            return;
        }

        if (mNeedCaculate)
        {
            mNeedCaculate = false;

            if (Mathf.Abs(dragVector.x) > Mathf.Abs(dragVector.y))
            {
                mIsScollV = false;
            }
            else
            {
                mIsScollV = true;
            }
        }

        DragScreen(dragVector);

        mOldPosition = Input.mousePosition;
    }

    private void OnPointerUp(Vector2 mousePosition)
    {
        if (mIsScollV)
        {

        }
        else
        {
            int index = GetCurrentIndex();
            m_CurPage = index;
            targethorizontal = posList[index]; //设置当前坐标，更新函数进行插值  
            isDrag = false;
            startTime = 0;
            stopMove = false;
        }
    }

    private int GetCurrentIndex()
    {
        /*int index = (int)(rect.horizontalNormalizedPosition * rect.content.rect.width / (mPageWidth + 1));
        if (index < 0)
        {
            index = 0;
        }
        else if (index > m_Num -1)
        {
            index = m_Num - 1;
        }
        return index;*/
        //xiadonghui 20190124 修改计算当前页计算方式
        if (posList.Count < 2)
        {
            return 0;
        }
        else
        {
            float horPos = rect.horizontalNormalizedPosition;
            for (int i = 0; i < posList.Count; i++)
            {
                if(posList[i] == horPos)
                {
                    return i;
                }

                if(i + 1 == posList.Count)
                {
                    return i;
                }
                else
                {
                    if (posList[i] < horPos && posList[i + 1] > horPos)
                    {
                        if (horPos >= posList[i] + ((posList[i + 1] - posList[i]) / 2))
                        {
                            return i + 1;
                        }
                        else
                        {
                            return i;
                        }
                    }
                }

            }
            return 0;
        }
    }

    private Dictionary<int, ScrollRect> catchScrollRect = new Dictionary<int, ScrollRect>();
    private ScrollRect GetTransformByIndex(int index)
    {
        if (index > rect.content.transform.childCount - 1)
        {
            return null;
        }

        //xiadonghui 20190124 对ScrollRect进行缓存，这里必须缓存，GetTransformByIndex函数在update函数有调用
        if (catchScrollRect.ContainsKey(index) == false)
        {
            catchScrollRect.Add(index,rect.content.transform.GetChild(index).GetComponent<ScrollRect>());
        }

        return catchScrollRect[index];
    }

    private void DragScreen(Vector2 pDragVector)
    {
        if (mIsScollV)
        {

        }
        else
        {
            //xiadonghui 20190124 修改 这里计算需要考虑总页数，horizontalNormalizedPosition 0--1代表全部。
            rect.horizontalNormalizedPosition -= (pDragVector.x / Screen.width * m_Sensitive) / posList.Count;
            if (rect.horizontalNormalizedPosition < 0)
            {
                rect.horizontalNormalizedPosition = 0;
            }
            else if (rect.horizontalNormalizedPosition > 1)
            {
                rect.horizontalNormalizedPosition = 1;
            }
        }
    }

    void Start()
    {
        inputControl.EVENT_MOUSE_DOWN += OnPointerDown;
        inputControl.EVENT_MOUSE_UP += OnPointerUp;
        inputControl.EVENT_MOUSE_DRAG += OnDrag;
    }

    void OnDestory()
    {
        inputControl.EVENT_MOUSE_DOWN -= OnPointerDown;
        inputControl.EVENT_MOUSE_UP -= OnPointerUp;
        inputControl.EVENT_MOUSE_DRAG -= OnDrag;
    }

    void Update()
    {
        if (!isDrag && !stopMove)
        {
            if (mIsScollV)
            {

            }
            else
            {
                startTime += Time.deltaTime;
                float t = startTime * smooting;
                rect.horizontalNormalizedPosition = Mathf.Lerp(rect.horizontalNormalizedPosition, targethorizontal, t);
                if (t >= 1)
                {
                    m_CurTransform = GetTransformByIndex(GetCurrentIndex());
                    stopMove = true;
                }
            }

        }
    }
}





