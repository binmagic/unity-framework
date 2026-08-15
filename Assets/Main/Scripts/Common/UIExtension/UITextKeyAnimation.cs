/**
 * [INPUT]: 依赖第三方 SuperTextMesh 组件的 OnUpdate 接口与 Shader 属性 _Alpha
 * [OUTPUT]: 对外提供 UITextKeyAnimation 组件,以 alpha 参数逐帧驱动 SuperTextMesh 的透明度关键帧表现
 * [POS]: UIExtension 中衔接 SuperTextMesh 富文本插件的动画桥接件,把外部动画曲线/时间轴对 alpha 的驱动透传给文本材质
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class UITextKeyAnimation : MonoBehaviour
{
 
    public static int key = Shader.PropertyToID("_Alpha");
    public float alpha = 1;
    private Material mat;
    private SuperTextMesh textMesh;
    private void Awake()
    {
         textMesh = GetComponent<SuperTextMesh>();

    }
    // Update is called once per frame
    void Update()
    {
        if(textMesh != null)
        {
            alpha = Mathf.Clamp(alpha,0, 1);
            textMesh.OnUpdate(alpha);
        }
    }
}





