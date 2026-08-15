/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour/Shader/Material，依赖 UnityEngine.UI 的 Image 取材质
 * [OUTPUT]: 对外提供 FlowAniCtrl 组件，将 Inspector 的 _Tick/_Power 实时写入 UI Image 材质的同名 Shader 属性
 * [POS]: Common/Component 的 UI 流动特效驱动器，标记 [ExecuteAlways] 以便编辑期预览，是 Shader 参数与美术调参之间的桥
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
[ExecuteAlways]
public class FlowAniCtrl : MonoBehaviour
{
    public float _Tick;
    public float _Power;
    private static int _TickId = Shader.PropertyToID("_Tick");
    private static int _PowerId = Shader.PropertyToID("_Power");
    private Material mat;
    private void Awake()
    {
        var image = GetComponent<Image>();
        if(image!=null)
        {
            mat = image.material;
        }
  
    }
    void Update()
    {
        if(mat==null)
        {
            return;
        }
        mat.SetFloat(_TickId, _Tick);
        mat.SetFloat(_PowerId, _Power);
   
    }
    private void OnDestroy()
    {
    
    }
}





