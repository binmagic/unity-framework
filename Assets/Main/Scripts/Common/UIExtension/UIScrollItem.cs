using UnityEngine;
using UnityEngine.UI;

public class UIScrollItem : MonoBehaviour
{
    public Text indexTxt;
    private UIScrollController scroller;
    public int index;
    public int oldIndex = -1;
    void Awake()
    {

    }

    void Start()
    {

    }

    public int Index
    {
        get
        {
            return index;
        }
        set
        {
            index = value;
            if (oldIndex == -1)
            {
                oldIndex = index;
            }
            transform.localPosition = scroller.GetPosition(index);
            gameObject.name = "Scroll" + index.ToString();
            //RefreshItem();
        }
    }

    public UIScrollController Scroller
    {
        set { scroller = value; }
    }

    public void RefreshItem()
    {
        if (indexTxt)
        {
            indexTxt.text = index.ToString();
        }
    }
}





