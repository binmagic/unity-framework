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





