// /***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description:
//  ***/

using GameKit.Base;
#if UNITY_EDITOR
using Sirenix.OdinInspector;
#endif
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class UIOrderInLayerSetUp : UIParticleSetUpBase
{
    public enum EType
    {
        Canvas,
        Renderer
    }

#if UNITY_EDITOR
    [Title("父节点orderInLayer为：")]
    [ReadOnly]
#endif
    public int parentSortingOrder = 0;
    
#if UNITY_EDITOR
    [Title("当前全局order：")]
    [ReadOnly]
#endif
    public int finalOrder = 0;

#if UNITY_EDITOR
    [Space]
    [Title("Local代表是在父节点的基础上追加")]
#endif
    public bool Local = true;
    public EType MyType = EType.Canvas;
    public int sortingOrder = 0;

    private Canvas parentCanvas;
    
    private void Start()
    {
        Refresh();
    }

    private void RefreshForCanvas()
    {
        var canvas = transform.GetOrAddComponent<Canvas>();
        canvas.renderMode = parentCanvas != null ? parentCanvas.renderMode : RenderMode.ScreenSpaceCamera;
        if (canvas.renderMode == RenderMode.ScreenSpaceCamera)
        {
            canvas.worldCamera = parentCanvas != null ? parentCanvas.worldCamera : null;
        }
        canvas.overrideSorting = true;
        canvas.sortingLayerName = "Default";
        canvas.sortingOrder = finalOrder;

        var graphicRaycaster = transform.GetOrAddComponent<GraphicRaycaster>();
    }

    private void RefreshForRender()
    {
        var graphicRaycaster = transform.GetOrAddComponent<GraphicRaycaster>();
        if (graphicRaycaster)
        {
#if UNITY_EDITOR
            DestroyImmediate(graphicRaycaster);
#else
            Destroy(graphicRaycaster);
#endif
        }
        
        var renderer = transform.GetComponent<Renderer>();
        if (renderer == null)
        {
            if (MyType == EType.Renderer)
            {
                Debug.LogWarning("renderer is not found!");
            }
            
            return;
        }
            
        renderer.sortingLayerName = "Default";
        renderer.sortingOrder = finalOrder;
    }
    
#if UNITY_EDITOR
    [Button("设置")]
#endif
    public void Refresh()
    {
        parentCanvas = transform.GetComponentInParentExt<Canvas>(false);
        parentSortingOrder = Local && parentCanvas != null ? parentCanvas.sortingOrder : 0;
        if (Local && parentCanvas == null)
        {
            Debug.LogWarning("parentCanvas not found!");
        }

        finalOrder = Local ? parentSortingOrder + sortingOrder : sortingOrder;
        
        if (MyType == EType.Canvas)
        {
            RefreshForCanvas();
            // var renderer = transform.GetComponent<Renderer>();
            // if (renderer)
            // {
            //     Debug.LogError("Canvas上不要挂Renderer!", gameObject);
            // }
        }
        else if(MyType == EType.Renderer)
        {
            RefreshForRender();
        }
    }

    
}





