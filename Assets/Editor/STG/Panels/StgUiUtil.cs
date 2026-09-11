using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

// 面板间共享的小工具方法，避免重复代码
public static class StgUiUtil
{
    public static int SafeIndexOf(string[] options, string value)
    {
        int idx = System.Array.IndexOf(options, value);
        return idx >= 0 ? idx : 0;
    }

    public static VisualElement SectionLabel(string text)
    {
        var label = new Label(text);
        label.style.unityFontStyleAndWeight = FontStyle.Bold;
        label.style.marginTop = 8;
        label.style.marginBottom = 2;
        return label;
    }

    public static VisualElement SectionBox(string title)
    {
        var box = new VisualElement();
        box.style.marginBottom = 10;
        box.style.paddingLeft = 8;
        box.style.paddingRight = 8;
        box.style.paddingTop = 6;
        box.style.paddingBottom = 6;
        box.style.borderLeftWidth = 1;
        box.style.borderLeftColor = new Color(0.3f, 0.3f, 0.3f);

        var label = new Label(title);
        label.style.unityFontStyleAndWeight = FontStyle.Bold;
        label.style.marginBottom = 4;
        box.Add(label);

        return box;
    }

    // 供左侧主列表 (ListView) 的行渲染：显示标题文字，并把当前数据项存进 userData 供行内回调读取
    public static VisualElement MakeMasterRow()
    {
        var label = new Label { name = "title" };
        label.style.paddingLeft = 4;
        return label;
    }

    public static void BindMasterRow(VisualElement el, string title, object dataItem)
    {
        ((Label)el).text = string.IsNullOrEmpty(title) ? "(未命名)" : title;
        el.userData = dataItem;
    }

    public static Label HintLabel(string text, bool isWarning = false)
    {
        var label = new Label(text);
        label.style.whiteSpace = WhiteSpace.Normal;
        label.style.fontSize = 11;
        label.style.color = isWarning ? new Color(0.85f, 0.4f, 0.4f) : new Color(0.6f, 0.6f, 0.6f);
        return label;
    }
}
