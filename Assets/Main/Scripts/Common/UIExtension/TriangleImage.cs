/**
 * [INPUT]: 依赖 UnityEngine.UI 的 VertexHelper 网格构建能力,继承项目内 BaseImage 基类
 * [OUTPUT]: 对外提供 TriangleImage 组件,以三个顶点绘制可填充的三角形 UI 图元
 * [POS]: UIExtension 的自定义 Graphic 绘制扩展,与其他 UI*Image 类并列,专注非矩形形状的顶点级渲染
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Sprites;

[AddComponentMenu("UI/Triangle Image")]
public class TriangleImage : BaseImage
{
    public Vector2 p1 = new Vector2(10, 10);
    public Vector2 p2 = new Vector2(50, 50);
    public Vector2 p3 = new Vector2(100, 10);
    public Color color = Color.white;
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();
        vh.AddVert(p1, color, Vector2.zero);
        vh.AddVert(p2, color, Vector2.zero);
        vh.AddVert(p3, color, Vector2.zero);
        var index = vh.currentIndexCount;
        vh.AddTriangle(index, index + 1, index + 2);
    }
}





