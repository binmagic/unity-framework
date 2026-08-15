/**
 * [INPUT]: 依赖 UnityEngine.UI 的 RawImage 及其材质关键字(_Layer_N)开关机制
 * [OUTPUT]: 对外提供 UIFormBlurEffect 组件,以 ShowBlurImage/HideBlurImage 按层级开启或关闭界面背景模糊
 * [POS]: UIExtension 的窗口背景虚化组件,通过实例化独立材质并启用层级关键字实现按 UI 层数叠加的模糊效果
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RawImage))]
public class UIFormBlurEffect : MonoBehaviour
{
    private RawImage blurImage;
    private string rfName = "";
    private string keyWorldName = "";
    private bool isOpen = false;
    private Material mat;
    private void Awake()
    {
        blurImage = GetComponent<RawImage>();
        blurImage.enabled = false;
    }

    private void OnEnable()
    {
    }

    private void OnDisable()
    {
        HideBlurImage();
    }
    
    private void OnDestroy()
    {
        HideBlurImage();
        if (mat != null)
        {
            Destroy(mat);
            mat = null;
        }
    }
    public void HideBlurImage()
    {
        if (isOpen)
        {
            blurImage.material.DisableKeyword(keyWorldName);
            blurImage.enabled = false;
            isOpen = false;
        }
    }

    public void CreateRt(int blurOrder)
    {
        
    }
    public void ShowBlurImage(int blurOrder)
    {
        if (blurOrder <= 0)
        {
            return;
        }
        mat = new Material(blurImage.material); 
        blurImage.material = mat;
        blurImage.enabled = true;
            
        keyWorldName = "_Layer_" + blurOrder;
        blurImage.material.EnableKeyword(keyWorldName);
        isOpen = true;
    }

}





