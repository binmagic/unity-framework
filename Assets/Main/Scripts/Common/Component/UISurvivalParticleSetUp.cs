// /***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description:
//  ***/

/**
 * [INPUT]: 依赖 UnityEngine 的 Renderer/Canvas，依赖 GetComponentInParentExt 扩展取父 Canvas，编辑器下依赖 Sirenix.OdinInspector 绘制面板
 * [OUTPUT]: 对外提供 UISurvivalParticleSetUp 组件、Refresh 与 SetLocalOrder，批量校准子 Renderer 的 sortingOrder 并支持特殊节点单独设序
 * [POS]: Common/Component 的粒子/渲染体层级配置器，继承 UIParticleSetUpBase，把整棵子树 Renderer 排序锚定父 Canvas 并允许 specialNodeList 例外，与 UIOrderInLayerSetUp/SpriteMaskSetUp 同族
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using System.Linq;
#if UNITY_EDITOR
using Sirenix.OdinInspector;
#endif
using UnityEngine;
using UnityEngine.Serialization;

[ExecuteInEditMode]
public class UISurvivalParticleSetUp : UIParticleSetUpBase
{
    [Serializable]
    public class SpecialNodeCfg
    {
        public Renderer render;
        public int order;
    }

#if UNITY_EDITOR
    [Title("父节点orderInLayer为：")]
    [ReadOnly]
#endif
    public int parentSortingOrder = 0;
    
#if UNITY_EDITOR
    [Title("当前最终orderInLayer为：")]
    [ReadOnly] 
#endif
    public int finalOrderInLayer = 0;

#if UNITY_EDITOR
    [FormerlySerializedAs("globalLayer")] [Title("默认order：")]
#endif
    public int orderInLayer = 1;
    
#if UNITY_EDITOR
    [Title("特殊节点设置：")]
#endif
    public SpecialNodeCfg[] specialNodeList;

    
    private void Start()
    {
        Refresh();
    }
    
#if UNITY_EDITOR
    [Button("设置")]
#endif
    public void Refresh()
    {
        var parentCanvas = transform.GetComponentInParentExt<Canvas>(false);
        parentSortingOrder = parentCanvas != null ? parentCanvas.sortingOrder : 0;
        
        finalOrderInLayer = parentSortingOrder + orderInLayer;
        
        var renderList = transform.GetComponentsInChildren<Renderer>();
        foreach (var renderer in renderList)
        {
            if(specialNodeList != null && specialNodeList.Any(x => x.render == renderer))
                continue;
            
            renderer.sortingLayerName = "Default";
            renderer.sortingOrder = finalOrderInLayer;
        }

        if (specialNodeList != null)
        {
            foreach (var t in specialNodeList)
            {
                if (t.render)
                {
                    t.render.sortingLayerName = "Default";
                    t.render.sortingOrder = parentSortingOrder + t.order;
                }
            }
        }
    }

    public void SetLocalOrder(int order)
    {
        orderInLayer = order;
        Refresh();
    }
}





