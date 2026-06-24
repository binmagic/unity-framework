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





