/**
 * [INPUT]: 依赖 UnityEngine.UI 的 RawImage 与 ILayoutElement 布局接口
 * [OUTPUT]: 对外提供 UIObject3DRawImage 组件,一个屏蔽默认布局尺寸推断的 RawImage 子类
 * [POS]: UIObject3D 模块的贴图载体,被 UIObject3D 挂载以显示 3D 渲染纹理,以最低布局优先级避免 LayoutGroup 干扰其尺寸
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;


/// <summary>
/// Subclass of the Unity 'Image' component which avoids the default layout sizing behaviour
/// </summary>
[RequireComponent(typeof(RectTransform)), DisallowMultipleComponent, ExecuteInEditMode]
public class UIObject3DRawImage : RawImage, ILayoutElement
{
    void ILayoutElement.CalculateLayoutInputHorizontal()
    {
    }

    void ILayoutElement.CalculateLayoutInputVertical()
    {
    }

    float ILayoutElement.flexibleHeight
    {
        get { return 1; }
    }

    float ILayoutElement.flexibleWidth
    {
        get { return 1; }
    }

    int ILayoutElement.layoutPriority
    {
        get { return -1; }
    }

    float ILayoutElement.minHeight
    {
        get { return 0; }
    }

    float ILayoutElement.minWidth
    {
        get { return 0; }
    }

    float ILayoutElement.preferredHeight
    {
        get { return 0; }
    }

    float ILayoutElement.preferredWidth
    {
        get { return 0; }
    }
}





