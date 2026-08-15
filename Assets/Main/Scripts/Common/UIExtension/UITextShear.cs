/**
 * [INPUT]: 依赖 UnityEngine.UI 的 BaseMeshEffect 与 VertexHelper 顶点修改接口
 * [OUTPUT]: 对外提供 UITextShear 组件,按 kx/ky 系数对 UI(文本/图形)网格顶点施加斜切变形
 * [POS]: UIExtension 的网格后处理特效,挂在 Graphic 上以最低成本实现文字倾斜/斜体效果,与其他 BaseMeshEffect 效果可叠加
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;

public class UITextShear : BaseMeshEffect
{
    public float kx = 0;
    public float ky = 0;

    public override void ModifyMesh(VertexHelper vh)
    {
        UIVertex vert = new UIVertex();
        for (int i = 0; i < vh.currentVertCount; i++)
        {
            vh.PopulateUIVertex(ref vert, i);
            var pos = vert.position;
            vert.position.x = pos.x + pos.y * kx;
            vert.position.y = pos.y + pos.x * ky;
            vh.SetUIVertex(vert, i);
        }
    }
}





