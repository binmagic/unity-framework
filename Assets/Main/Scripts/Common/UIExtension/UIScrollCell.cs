/**
 * [INPUT]: 依赖 UnityEngine.UI 的 Text,以自身 GameObject 名称解析所绑定的数据索引
 * [OUTPUT]: 对外提供 UIScrollCell 组件,滚动行内单个 cell 的最小示例载体,RefreshItem 按索引刷新显示
 * [POS]: UIScroll 家族中行(UIScrollItem)下的列单元占位实现,由 UIScrollBase 按 numPerLine 组织,业务通常以自定义 cell 替代
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;

public class UIScrollCell : MonoBehaviour
{
    public Text indexTxt;

    public void RefreshItem()
    {
        if (indexTxt)
        {
            int idx = 0;
            int.TryParse(name, out idx);
            indexTxt.text = idx.ToString();
        }
    }
}





