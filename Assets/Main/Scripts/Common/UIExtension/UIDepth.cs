/**
 * [INPUT]: 依赖 UnityEngine 的 Canvas overrideSorting 与 Renderer sortingOrder 机制
 * [OUTPUT]: 对外提供 UIDepth 组件,统一控制 UI(Canvas) 或 3D(Renderer) 对象的渲染排序层级
 * [POS]: UIExtension 的渲染层级调整工具,以 isUI 开关兼容 UGUI 与 3D 混排场景的深度覆盖需求
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using System.Collections;
using UnityEngine.UI;
[ExecuteAlways]
public class UIDepth : MonoBehaviour
{
    public int order;
    public bool isUI = true;

    public bool isUpdate = false;
    void Start()
    {
        if (isUI)
        {
            Canvas canvas = GetComponent<Canvas>();
            if (canvas == null)
            {
                canvas = gameObject.AddComponent<Canvas>();
            }
            canvas.overrideSorting = true;
            canvas.sortingOrder = order;
        }
        else
        {
            Renderer[] renders = GetComponentsInChildren<Renderer>();

            foreach (Renderer render in renders)
            {
                render.sortingOrder = order;
            }
        }
    }

    private void FixedUpdate()
    {
        if (isUpdate)
        {
            Start();
            isUpdate = false;
        }
    }
}





