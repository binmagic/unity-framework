/**
 * [INPUT]: 依赖 UnityEngine 的 SkinnedMeshRenderer/Material/Shader，在子物体中定位 "Effect_C/Liuguang" 材质
 * [OUTPUT]: 对外提供 LightSweepEffect 组件，逐帧驱动材质 _UV.z 偏移在 range 区间循环，speed 控制流光速度
 * [POS]: Common/Component 的角色流光扫光特效，与 LightSweepEffect 不同于 GhostEffect 之处在于直接改材质 UV 而非绘制残影
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System;
using UnityEngine;

/*
 *  这个是一个流光特效
 *  怎么控制这个呢,我们设置一个perTimeDt, 表示多长时间循环一次
 *  通过speed来控制速度
 */
public class LightSweepEffect : MonoBehaviour
{
    //_UV("UV", Vector) = (1,1,0,0)
    private int propertyId = Shader.PropertyToID("_UV");
    private Material lightSweepMat;
    private Vector4 _UV;
    public float speed = 0.0f;
    public Vector2 range = new Vector2(0, 2);
    private float curOffset = 0.0f;
    
    private void Awake()
    {
        var allSkinMesh = GetComponentsInChildren<SkinnedMeshRenderer>();
        for (int i = 0; i < allSkinMesh.Length; ++i)
        {
            var mats = allSkinMesh[i].materials;
            foreach (var mat in mats)
            {
                if (mat.shader.name == "Effect_C/Liuguang")
                {
                    lightSweepMat = mat;
                    break;
                }
            }
        }

        

        if (lightSweepMat != null)
        {
            _UV = lightSweepMat.GetVector(propertyId);
        }
    }

    private void Update()
    {
        if (lightSweepMat == null)
            return;
        if (curOffset > range.y)
        {
            curOffset = range.x;
        }

        curOffset += Time.deltaTime * speed;
        _UV.z = curOffset;
        lightSweepMat.SetVector(propertyId, _UV);
    }
}





