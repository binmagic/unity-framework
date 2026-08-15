/**
 * [INPUT]: 依赖 UnityEngine.UI 原生 ScrollRect 的 content/滚动方向与位置
 * [OUTPUT]: 对外提供 UIScrollArrow 组件(根据滚动位置显隐上/下(或左/右)可滚动提示箭头)
 * [POS]: UI 层的滚动提示件,面向原生 ScrollRect;与 UIScrollViewArrow(面向自研 ScrollView)逻辑同构、宿主不同
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIScrollArrow : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject upTarget;
    public GameObject downTarget;

    private ScrollRect scroll;
    private RectTransform scrollrect;
    private float max = 0f, min = 0f;
    private float cachedsize = 0f;
    void Awake()
    {
        scroll = GetComponent<ScrollRect>();
        if(scroll == null)
        {
            scroll = gameObject.GetComponentInParent<ScrollRect>();
        }
        ResetSize();
    }

    private void ResetSize()
    {
        if (scrollrect == null)
            scrollrect = scroll.GetComponent<RectTransform>();
        if (scroll == null || scroll.content == null)
            return;
        if (scroll.horizontal && !scroll.vertical)
        {
            min = -1 * ( scroll.content.rect.width * (1 - scroll.content.pivot.x) - scrollrect.rect.width * (1 - (scrollrect.pivot.x)));
            max = min + scroll.content.rect.width - scrollrect.rect.width;
            cachedsize = scroll.content.rect.width;
        }
        else if (!scroll.horizontal && scroll.vertical)
        {
            min = -1 * (scroll.content.rect.height * (1 - scroll.content.pivot.y) - scrollrect.rect.height * (1 - (scrollrect.pivot.y)));
            max = min + scroll.content.rect.height - scrollrect.rect.height;
            cachedsize = scroll.content.rect.height;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (scroll == null || scroll.content == null || (upTarget == null && downTarget == null))
            return;
        float value = 0f;
        float tempsize = 0f;
        if (scroll.horizontal && !scroll.vertical)
        {
            tempsize = scroll.content.rect.width;
            value = scroll.content.localPosition.x;
        }
        else if (!scroll.horizontal && scroll.vertical)
        {
            tempsize = scroll.content.rect.height;
            value = scroll.content.localPosition.y;
        }
        if (Mathf.Abs(tempsize - cachedsize) > 0.1)
            ResetSize();
        if(upTarget != null)
            upTarget.SetActive((value - min) > 5);
        if(downTarget != null)
            downTarget.SetActive((max - value) > 5); 
    }
}





