// /***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description:
//  ***/

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





