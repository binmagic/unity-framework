/**
 * [INPUT]: 继承 UnityEngine.UI.BaseMeshEffect，依赖 UnityEngine.Gradient 颜色曲线与 VertexHelper 顶点流
 * [OUTPUT]: 对外提供 Gradient 网格特效组件及 GradientType(横/纵)、Blend(覆盖/叠加/相乘) 枚举，按顶点位置采样渐变色并混合
 * [POS]: UIExtension 的顶点着色特效，挂在 UI 图元上对其网格顶点做水平或垂直方向的颜色渐变，是纯顶点级的美术增强件
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections.Generic;


public enum GradientType
{  
    Horizontal,  
    Vertical  
}  
  
  
public enum Blend  
{  
    Override,  
    Add,  
    Multiply  
}  
  
  
namespace UnityEngine.UI  
{  
    [AddComponentMenu("UI/Effects/UGUI_Gradient")]  
    public class Gradient : BaseMeshEffect  
    {  
        [SerializeField]  
        GradientType _gradientType;  
  
  
        [SerializeField]  
        Blend _blendMode = Blend.Multiply;  
  
  
        [SerializeField]  
        [Range(-1, 1)]  
        float _offset = 0f;  
  
  
        [SerializeField]  
        UnityEngine.Gradient _effectGradient = new UnityEngine.Gradient()  
        { colorKeys = new GradientColorKey[] { new GradientColorKey(Color.black, 0), new GradientColorKey(Color.white, 1) } };  
 
 
        #region Properties  
        public Blend BlendMode  
        {  
            get { return _blendMode; }  
            set { _blendMode = value; }  
        }  
  
  
        public UnityEngine.Gradient EffectGradient  
        {  
            get { return _effectGradient; }  
            set { _effectGradient = value; }  
        }  
  
  
        public GradientType GradientType  
        {  
            get { return _gradientType; }  
            set { _gradientType = value; }  
        }  
  
  
        public float Offset  
        {  
            get { return _offset; }  
            set { _offset = value; }  
        }  
        #endregion  
  
  
        public override void ModifyMesh(VertexHelper helper)  
        {  
            if (!IsActive() || helper.currentVertCount == 0)  
                return;  
  
  
            List<UIVertex> _vertexList = new List<UIVertex>();  
  
  
            helper.GetUIVertexStream(_vertexList);  
  
  
            int nCount = _vertexList.Count;  
            switch (GradientType)  
            {  
                case GradientType.Horizontal:  
                    {  
                        float left = _vertexList[0].position.x;  
                        float right = _vertexList[0].position.x;  
                        float x = 0f;  
                        for (int i = nCount - 1; i >= 1; --i)  
                        {  
                            x = _vertexList[i].position.x;  
  
  
                            if (x > right) right = x;  
                            else if (x < left) left = x;  
                        }  
                        float width = 1f / (right - left);  
                        UIVertex vertex = new UIVertex();  
  
  
                        for (int i = 0; i < helper.currentVertCount; i++)  
                        {  
                            helper.PopulateUIVertex(ref vertex, i);  
  
  
                            vertex.color = BlendColor(vertex.color, EffectGradient.Evaluate((vertex.position.x - left) * width - Offset));  
  
  
                            helper.SetUIVertex(vertex, i);  
                        }  
                    }  
                    break;  
  
  
                case GradientType.Vertical:  
                    {  
                        float bottom = _vertexList[0].position.y;  
                        float top = _vertexList[0].position.y;  
                        float y = 0f;  
                        for (int i = nCount - 1; i >= 1; --i)  
                        {  
                            y = _vertexList[i].position.y;  
  
  
                            if (y > top) top = y;  
                            else if (y < bottom) bottom = y;  
                        }  
                        float height = 1f / (top - bottom);  
                        UIVertex vertex = new UIVertex();  
  
  
                        for (int i = 0; i < helper.currentVertCount; i++)  
                        {  
                            helper.PopulateUIVertex(ref vertex, i);  
  
  
                            vertex.color = BlendColor(vertex.color, EffectGradient.Evaluate((vertex.position.y - bottom) * height - Offset));  
  
  
                            helper.SetUIVertex(vertex, i);  
                        }  
                    }  
                    break;  
            }  
        }  
  
  
        Color BlendColor(Color colorA, Color colorB)  
        {  
            switch (BlendMode)  
            {  
                default: return colorB;  
                case Blend.Add: return colorA + colorB;  
                case Blend.Multiply: return colorA * colorB;  
            }  
        }  
    }  
}





