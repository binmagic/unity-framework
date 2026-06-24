using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityGameFramework.Runtime;

public class ScrollPage : MonoBehaviour
{
    protected int count;
    public int Count
    {
        get
        {
            return count;
        }
    }
    protected GameObject adItemPrefab;
    protected Transform adItemParent;
    protected GameObject adPageItemPrefab;
    protected Transform adPageItemParent;

    /// <summary>
    /// 是否刚被拖拽过,限制在自动滚动时 太快
    /// </summary>
    protected bool isDraged;

    protected GameObject scroll;
    protected RectTransform gridLayoutGroupRect;
    protected GridLayoutGroup cellSize;

    /// <summary>
    /// 选中点
    /// </summary>
    protected List<GameObject> pageItems = new List<GameObject>();
    /// <summary>
    /// 广告图
    /// </summary>
    protected List<GameObject> adItems = new List<GameObject>();

    public float speed = 3000f;
    public float autoSpeed = 1000f;
    public float scrollSpeed = 3000f;
    protected float lerp;
    protected Vector2 beginPos;
    public int curIdx;
    public int preIdx;

    public Vector2 targetPos;
    public bool change;
    public float dis;

    public Action<GameObject> OnCreateItemEvent { get; set; }
    public Action<GameObject> OnRemoveItemEvent { get; set; }
    /// <summary>
    /// args 1=上一个索引,2=当前索引,3=是否为拖拽
    /// </summary>
    /// <value>The on change event.</value>
    public Action<int, int, bool> OnChangeEvent { get; set; }
    public Action<int> OnScrollEndEvent { get; set; }
    public bool idxLoop;
    public virtual void Initialize(int count, GameObject scroll, GridLayoutGroup gridLayoutGroup, GameObject adItem)
    {
        this.count = count;
        this.scroll = scroll;
        this.adItemPrefab = adItem;
        this.adItemParent = gridLayoutGroup.transform;
        this.gridLayoutGroupRect = gridLayoutGroup.GetComponent<RectTransform>();
        this.cellSize = gridLayoutGroup;
        if (count > 0)
        {
            SpawnPage();
        }

        UIEventListener.Get(scroll).onBeginDrag = OnBeginDrag;
        UIEventListener.Get(scroll).onEndDrag = OnEndDrag;
        targetPos = gridLayoutGroupRect.anchoredPosition;
    }

    public virtual void Initialize(int count, GameObject scroll, GridLayoutGroup adGridLayoutGroup, GameObject adItem, GridLayoutGroup pageGridLayoutGroup, GameObject pageItem)
    {
        this.count = count;
        this.scroll = scroll;
        this.adItemPrefab = adItem;
        this.adItemParent = adGridLayoutGroup.transform;
        this.gridLayoutGroupRect = adGridLayoutGroup.GetComponent<RectTransform>();
        this.cellSize = adGridLayoutGroup;

        this.adPageItemPrefab = pageItem;
        this.adPageItemParent = pageGridLayoutGroup.transform;

        if (count > 0)
        {
            SpawnPage();
        }
        UIEventListener.Get(scroll).onBeginDrag = OnBeginDrag;
        UIEventListener.Get(scroll).onEndDrag = OnEndDrag;
        targetPos = gridLayoutGroupRect.anchoredPosition;
    }

    public virtual void SetDragEventObj(GameObject go)
    {
        UIEventListener.Get(go).onBeginDrag = OnBeginDrag;
        UIEventListener.Get(go).onEndDrag = OnEndDrag;
    }

    public virtual void RemoveAll()
    {
        if (count > 0)
        {
            for (int i = count - 1; i >= 0; i--)
            {
                this.RemovePageByIdx(i, false);
            }
            count = 0;
        }
        //if (auToActionTask != null)
        //{
        //    GameEntry.Timer.RemoveTask(auToActionTask);
        //    auToActionTask = null;
        //}
    }

    /// <summary>
    /// Removes the index of the page by.
    /// 请使用倒序删除
    /// 注意这里传的索引idx 和 count的判断,不要连续调用 RemovePageByIdx 否则 count-- idx++会无法完成逻辑
    /// 如果要连续删除多个请在连续remove之后对count进行单独处理
    /// </summary>
    /// <returns>The page by index.</returns>
    /// <param name="idx">Index.</param>
    /// <param name="countAutoSubtract">是否自动减count</param>
    public virtual int RemovePageByIdx(int idx, bool countAutoSubtract = true)
    {
        if (idx < count && count > 0)
        {
            if (OnRemoveItemEvent != null)
            {
                OnRemoveItemEvent(adItems[idx]);
            }
            OnRemoveItem(adItems[idx]);
            adItems[idx].gameObject.Destroy();
            adItems.RemoveAt(idx);
            bool isBounds = (idx >= count - 1 || idx <= 0);
            if (pageItems.Count > 0)
            {
                pageItems[idx].gameObject.Destroy();
                pageItems.RemoveAt(idx);
            }
            //如果用作remove，不走reset逻辑
            if (!countAutoSubtract)
            {
                return curIdx;
            }
             
            //Reset Btn Event
            if (pageItems.Count > 0)
            {
                for (int i = 0; i < pageItems.Count; i++)
                {
                    GameObject pageItem = pageItems[i];
                    pageItem.name = i.ToString();
                    Transform off = pageItem.transform.Find("Off");
                    if (off)
                    {
                        Button btn = off.GetComponent<Button>();
                        if (btn)
                        {
                            btn.onClick.RemoveAllListeners();
                            btn.onClick.AddListener(() =>
                            {
                                ChangePage(pageItem.name.ToInt());
                            });
                        }
                    }
                }
            }

            if (curIdx > 0)
            {
                curIdx--;
                if (OnChangeEvent != null)
                {
                    OnChangeEvent(preIdx, curIdx, false);
                }
                OnChange(preIdx, curIdx);
            }

            preIdx = curIdx;
            if (pageItems.Count > 0)
            {
                SetPageState(pageItems[curIdx], true);
            }
            SetTarget();
            if (countAutoSubtract)
            {
                count--;
            }
        }
        return curIdx;
    }

    public virtual void OnChange(int preIdx, int curIdx)
    {

    }

    public virtual void SetTarget()
    {
        float pox = curIdx * -cellSize.cellSize.x;
        targetPos.x = pox;
        gridLayoutGroupRect.anchoredPosition = targetPos;
        this.lerp = 0;
    }

    public virtual void OnCreateItem(GameObject obj)
    {

    }
    public virtual void OnRemoveItem(GameObject obj)
    {

    }

    public virtual void SpawnOnePageItem()
    {
        GameObject adPageItem = adPageItemPrefab.Instantiate();
        adPageItem.transform.SetParent(adPageItemParent);
        adPageItem.name = count.ToString();
        adPageItem.gameObject.SetActive(true);
        adPageItem.transform.localScale = Vector3.one;
        Transform off = adPageItem.transform.Find("Off");
        if (off)
        {
            Button btn = off.GetComponent<Button>();
            if (btn)
            {
                btn.onClick.RemoveAllListeners();
                btn.onClick.AddListener(() =>
                {
                    speed = autoSpeed;
                    ChangePage(adPageItem.name.ToInt());
                });
            }
        }
        pageItems.Add(adPageItem);
    }

    public virtual GameObject SpawnOnePage()
    {
        GameObject ad = adItemPrefab.Instantiate();
        ad.transform.SetParent(adItemParent);
        if (OnCreateItemEvent != null)
        {
            OnCreateItemEvent(ad);
        }
        ad.transform.localScale = Vector3.one;
        //ad.transform.localPosition = Vector3.zero;
        OnCreateItem(ad);
        ad.gameObject.SetActive(true);
        adItems.Add(ad);
        if (adPageItemPrefab != null)
        {
            SpawnOnePageItem();
        }
        if (count == 0)
        {
            SetPageState(pageItems[0], true);
        }
        count++;
        return ad;
    }

    public int GetNextIndex()
    {
        int idx = 0;
        if (curIdx == count - 1)
        {
            idx = 0;
        }
        else
        {
            idx = curIdx + 1;
        }
        return idx;
    }

    public virtual void SpawnPage()
    {
        int tmepCount = count;
        count = 0;
        for (int i = 0; i < tmepCount; i++)
        {
            SpawnOnePage();
        }
    }

    public virtual void ChangePage(int idx)
    {
        if (change)
        {
            return;
        }
        preIdx = curIdx;
        curIdx = idx;
        IdxLogic();
        if (OnChangeEvent != null)
        {
            OnChangeEvent(preIdx, curIdx, false);
        }
        OnChange(preIdx, curIdx);
        if (pageItems.Count > 0)
        {
            SetPageState(this.pageItems[preIdx], false);
            SetPageState(this.pageItems[curIdx], true);
        }
    }

    public virtual void SetPageState(GameObject go, bool state)
    {
        go.transform.Find("Off/On").gameObject.SetActive(state);
    }

    public virtual void OnBeginDrag(GameObject arg1, Vector2 arg2, Vector2 arg3)
    {
        beginPos = Input.mousePosition;
    }
    /// <summary>
    /// 用来判断滑动鼠标时的距离达成目标值才做滚动
    /// </summary>
    public float scorllDis = 10;
    public virtual void OnEndDrag(GameObject arg1, Vector2 arg2, Vector2 arg3)
    {
        if (change)
        {
            return;
        }
        preIdx = curIdx;
        Vector2 vec = (Vector2)Input.mousePosition - beginPos;
        float mouseDis = Mathf.Abs(vec.x);
        Vector3 nor = Vector3.Normalize(vec);
        //Debug.LogFormat("nor.x======={0},dis.x={1}", nor.x, dis);
        if (nor.x > 0 && mouseDis > scorllDis)
        {
            //Debug.LogError("右边");
            curIdx--;
        }
        else if (nor.x < 0 && mouseDis > scorllDis)
        {
            curIdx++;
            //Debug.LogError("左边");
        }
        else
        {
            return;
        }
        IdxLogic();
        if (OnChangeEvent != null)
        {
            OnChangeEvent(preIdx, curIdx, true);
        }
        speed = scrollSpeed;
        isDraged = true;
        OnChange(preIdx, curIdx);
    }

    public virtual void CheckLoop(int idx)
    {
        //模拟单个间隔滑动效果,否则会有缓冲效果
        if (gridLayoutGroupRect.childCount >= 2)
        {
            Vector2 pos = gridLayoutGroupRect.anchoredPosition;
            pos.x = idx * -cellSize.cellSize.x;
            gridLayoutGroupRect.anchoredPosition = pos;
        }
    }

    public virtual void IdxLogic()
    {
        //出边界
        if (curIdx < 0)
        {
            if (idxLoop)
            {
                curIdx = gridLayoutGroupRect.childCount - 1;
                CheckLoop(curIdx - 1);
            }
            else
            {
                curIdx = 0;
            }
        }

        if (curIdx >= gridLayoutGroupRect.childCount)
        {
            if (idxLoop)
            {
                curIdx = 0;
                CheckLoop(curIdx + 1);
            }
            else
            {
                curIdx = gridLayoutGroupRect.childCount - 1;
            }
        }
        if (preIdx != curIdx)
        {
            change = true;
        }
        float pox = curIdx * -cellSize.cellSize.x;
        targetPos.x = pox;
        dis = Vector3.Distance(gridLayoutGroupRect.anchoredPosition, targetPos);
    }
    public virtual void OnScrollEnd(int curIdx)
    {

    }

    /// <summary>
    /// 用于在动画未结束直接定位到目标
    /// </summary>
    public virtual void TryChangeToTarget()
    {
        if (change)
        {
            EndLogic();
        }
    }

    private void EndLogic()
    {
        lerp = 0;
        change = false;
        if (OnScrollEndEvent != null)
        {
            OnScrollEndEvent(curIdx);
        }
        OnScrollEnd(curIdx);
        if (pageItems.Count > 0)
        {
            SetPageState(this.pageItems[preIdx], false);
            SetPageState(this.pageItems[curIdx], true);
        }
        gridLayoutGroupRect.anchoredPosition = targetPos;
    }

    // Update is called once per frame
    public virtual void Update()
    {
        if (change)
        {
            lerp += speed * Time.deltaTime / dis;
            gridLayoutGroupRect.anchoredPosition = Vector3.Lerp(gridLayoutGroupRect.anchoredPosition, targetPos, lerp);
            if (lerp >= 1)
            {
                EndLogic();
            }
        }
    }
}





