/**
 * [INPUT]: 继承 UnityEngine.UI.Mask，依赖 RectTransformUtility 做屏幕点包含判断
 * [OUTPUT]: 对外提供 HoleMask 组件，反转 Mask 的射线命中：只有点击落在遮罩矩形之外时才算有效
 * [POS]: HoleMask 模块的遮罩控制器，与 HoleImage 配合把矩形区域挖成"洞"，洞内点击穿透、洞外拦截，用于引导高亮等镂空交互
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;
using UnityEngine.UI;
public class HoleMask : Mask
{
    public override bool IsRaycastLocationValid(Vector2 sp, Camera eventCamera)
    {
        if (!isActiveAndEnabled)
            return true;
 
        return !RectTransformUtility.RectangleContainsScreenPoint(rectTransform, sp, eventCamera);
    }
}





