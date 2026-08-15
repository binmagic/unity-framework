/**
 * [INPUT]: 继承 UnityEngine.UI.Image，依赖 StencilMaterial/MaskUtilities 与 UnityEngine.Rendering 的模板比较枚举
 * [OUTPUT]: 对外提供 HoleImage 组件，重写 GetModifiedMaterial 用 NotEqual 模板测试实现"只在遮罩区域外绘制"的反向裁剪
 * [POS]: HoleMask 模块的图像渲染件，配合 HoleMask 把模板比较从常规 Equal 改成 NotEqual，构成镂空遮罩效果的绘制侧
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;
public class HoleImage : Image {
    public override Material GetModifiedMaterial(Material baseMaterial)
    {
        var toUse = baseMaterial;
 
        if (m_ShouldRecalculateStencil)
        {
            var rootCanvas = MaskUtilities.FindRootSortOverrideCanvas(transform);
            m_StencilValue = maskable ? MaskUtilities.GetStencilDepth(transform, rootCanvas) : 0;
            m_ShouldRecalculateStencil = false;
        }
 
        // if we have a enabled Mask component then it will
        // generate the mask material. This is an optimisation
        // it adds some coupling between components though :(
        Mask maskComponent = GetComponent<Mask>();
        if (m_StencilValue > 0 && (maskComponent == null || !maskComponent.IsActive()))
        {
            var maskMat = StencilMaterial.Add(toUse, (1 << m_StencilValue) - 1, StencilOp.Keep, CompareFunction.NotEqual, ColorWriteMask.All, (1 << m_StencilValue) - 1, 0);
            StencilMaterial.Remove(m_MaskMaterial);
            m_MaskMaterial = maskMat;
            toUse = m_MaskMaterial;
        }
        return toUse;
    }
}





