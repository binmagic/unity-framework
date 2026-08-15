/**
 * [INPUT]: 依赖兄弟文件 UIScrollController 提供的 GetPosition 计算行坐标,依赖 UnityEngine.UI 的 Text
 * [OUTPUT]: 对外提供 UIScrollItem 组件,代表滚动列表中的一"行",通过 Index 赋值时自动定位并重命名 GameObject
 * [POS]: UIScroll 家族的行单元,被 UIScrollController 池化管理,是 UIScrollBase 组织多列 cell 的行容器
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





