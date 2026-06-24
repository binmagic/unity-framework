using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using System;
using Unity.Mathematics;

public class PageViewComponent : MonoBehaviour, IBeginDragHandler, IEndDragHandler {
    private ScrollRect rect;                        //滑动组件  
    private float targethorizontal = 0;             //滑动的起始坐标  
    private bool isDrag = false;                    //是否拖拽结束  
    private List<float> posList = new List<float> ();            //求出每页的临界角，页索引从0开始  
    private int currentPageIndex = -1;
    public Action<int> onPageChanged;
    public RectTransform item;
    public RectTransform Content;
    private bool stopMove = true;
    public float smooting = 4;      //滑动速度  
    public float sensitivity = 0;
    private float startTime;
    public bool _forceOneByOne = false;//强制每次只滑动一格
    public bool _emptyEnds = false;//两端用空位补齐
    
    private float startDragHorizontal; 
    
    public void Refresh (Action<int> onUpdate) {
        rect = transform.GetComponent<ScrollRect> ();
        //Content.rect.SetWidth(GetComponent<RectTransform> ().rect.width * rect.content.transform.childCount);
        float horizontalLength = rect.content.rect.width - GetComponent<RectTransform> ().rect.width;
        float itemCount = rect.content.rect.width / item.rect.width;
        posList.Add (0);
        for(int i = 1; i < itemCount - 1; i++) {
            posList.Add (GetComponent<RectTransform> ().rect.width * i / horizontalLength);
        }
        
        this.onPageChanged = onUpdate;
        posList.Add (1);
        
        // RefreshByCell(onUpdate);
    }

    /// <summary>
    /// 子物体左对齐
    /// 使用循环列表
    /// </summary>
    /// <param name="OnUpdate"></param>
    public void RefreshByCell(Action<int> OnUpdate)
    {
        rect = transform.GetComponent<ScrollRect> ();
        int cellNum = Mathf.RoundToInt(rect.content.rect.width / item.rect.width);
        float halfCellW = item.rect.width / 2;
        float halfSvW = GetComponent<RectTransform>().rect.width / 2;
        float temp = rect.content.rect.width - halfSvW * 2;
        float cellStepL = (float) halfCellW * 2 / temp;
        float cellL = halfCellW * 2 / rect.content.rect.width;

        float startPos = (halfSvW - halfCellW) / rect.content.rect.width;
        int cacheIndex = 0;
        
        posList.Clear();
        for (int i = 0; i < cellNum; i++)
        {
            float targetPos = 0;
            // if (i * halfCellW * 2 / rect.content.rect.width < startPos)
            if(i * cellL < startPos)
            {
                targetPos = 0;
                cacheIndex = i;
            }
            else
            {
                float tempPos = (cacheIndex + 1) * cellL - startPos + (i - (cacheIndex + 1)) * cellStepL;
                targetPos = Mathf.Min(tempPos, 1);
            }
            posList.Add(targetPos);
        }
        this.onPageChanged = OnUpdate;
        
        // //Content.rect.SetWidth(GetComponent<RectTransform> ().rect.width * rect.content.transform.childCount);
        // float horizontalLength = rect.content.rect.width - GetComponent<RectTransform> ().rect.width;
        // float itemCount = rect.content.rect.width / item.rect.width;
        // posList.Add (0);
        // for(int i = 1; i < itemCount - 1; i++) {
        //     posList.Add (GetComponent<RectTransform> ().rect.width * i / horizontalLength);
        // }
        //
        // this.onPageChanged = OnUpdate;
        // posList.Add (1);
    }

    private void Update () {
        if(!isDrag && !stopMove) {
            startTime += Time.deltaTime;
            float t = startTime * smooting;
            rect.horizontalNormalizedPosition = Mathf.Lerp (rect.horizontalNormalizedPosition , targethorizontal , t);
            if(t >= 1)
                stopMove = true;
        }
    }
    
    private void OnDestroy()
    {
        onPageChanged = null;
    }

    public void pageTo (int index) {
        if(index >= 0 && index < posList.Count) {
            rect.horizontalNormalizedPosition = posList[index];
            SetPageIndex(index);
        }
    }
    private void SetPageIndex (int index) {
        if(currentPageIndex != index) {
            currentPageIndex = index;
            if(onPageChanged != null)
                onPageChanged (index);
        }
    }

    public void OnBeginDrag (PointerEventData eventData) {
        isDrag = true;
        startDragHorizontal = rect.horizontalNormalizedPosition; 
    }

    public void OnEndDrag (PointerEventData eventData) {
        int index = 0;
        if (_forceOneByOne)
        {
            if (!Mathf.Approximately(rect.horizontalNormalizedPosition, startDragHorizontal))
            {
                bool isRight = rect.horizontalNormalizedPosition > startDragHorizontal;
                int offset = _emptyEnds ? 1 : 0;
                if (isRight)
                {
                    index = currentPageIndex + 1;
                    index = math.min(index, posList.Count - 1 - offset);
                }
                else
                {
                    index = currentPageIndex - 1;
                    index = math.max(index, offset);
                }
            }
            else
            {
                index = currentPageIndex;
            }
        }
        else
        {
            float posX = rect.horizontalNormalizedPosition;
            posX += ((posX - startDragHorizontal) * sensitivity);
            posX = posX < 1 ? posX : 1;
            posX = posX > 0 ? posX : 0;
            float offset = Mathf.Abs (posList[index] - posX);
            for(int i = 1; i < posList.Count; i++) {
                float temp = Mathf.Abs (posList[i] - posX);
                if(temp < offset) {
                    index = i;
                    offset = temp;
                }
            }
        }
        SetPageIndex (index);

        targethorizontal = posList[index]; //设置当前坐标，更新函数进行插值  
        isDrag = false;
        startTime = 0;
        stopMove = false;
    } 
}





