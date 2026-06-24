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





