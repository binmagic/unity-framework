using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 图片置灰
/// </summary>
public static class UIGray
{
    private static Material grayMat;
    private static Material etc1GrayMat;

    private static Material matSpriteRdGray;
    private static Material matSpriteRdNormal;


    private const string ETC1GrayShaderName = "UI/GrayETC1";
    private const string NormalGrayShaderName = "Custom/ImageGray";
    
    //zlh note:上述材质遇到etc1并且用到alpha的sprite会有问题 所以再加个etc1的材质
    //important: 如果是动态设置图片的话 置灰应该放在图片设置成功的回调里  因为设置前的sprite很可能和之后的不一致(一个用了etc1 一个没用)

    private static Material GetGraySpriteRenderer()
    {
        if (matSpriteRdGray == null)
        {
            var shader = GameEntry.Shader.Find("Custom/Luminance");
            if (shader == null)
            {
                Debug.LogError("GrayETC1 not found!");
                return null;
            }

            Material targetMat = new Material(shader);
            matSpriteRdGray = targetMat;
        }
        return matSpriteRdGray;
    }
    
    private static Material GetNormalSpriteRenderer()
    {
        if (matSpriteRdNormal == null)
        {
            var shader = GameEntry.Shader.Find("Sprites/Default");
            if (shader == null)
            {
                Debug.LogError("GrayETC1 not found!");
                return null;
            }

            Material targetMat = new Material(shader);
            matSpriteRdNormal = targetMat;
        }
        return matSpriteRdNormal;
    }

    //获取或创建一个ETC1的灰色材质
    private static Material GetEtc1GrayMaterial()
    {
        var targetMat = etc1GrayMat;
        if (targetMat == null)
        {
            var shader = GameEntry.Shader.Find(ETC1GrayShaderName);
            if (shader == null)
            {
                Debug.LogError("GrayETC1 not found!");
                return null;
            }

            targetMat = new Material(shader);
            etc1GrayMat = targetMat;
        }
        
        return targetMat;
    }

    private static Material GetNormalGrayMaterial()
    {
        var targetMat = grayMat;
        if (targetMat == null)
        {
            var shader = GameEntry.Shader.Find(NormalGrayShaderName);
            if (shader == null)
            {
                //GameEntry.Shader.Dump();
                Debug.LogErrorFormat("GetGrayMat shader is null!  {0}", NormalGrayShaderName);
                return null;
            }

            targetMat = new Material(shader);
            grayMat = targetMat;
        }
        
        return targetMat;
    }
    
    //add by zlh: 如果image当前是置灰状态 需要重新检查下 因为last sprite 和current sprite 有可能format不一致
    public static void DoCheckAfterSetSprite(Image image)
    {
        if (image == null || image.sprite == null || image.sprite.texture == null || image.material == null)
        {
            Debug.Log("DoCheckAfterSetSprite image == null or image.sprite == null");
            return;
        }

        var isEtc1 = image.sprite.texture.format == TextureFormat.ETC_RGB4; 
        //非置灰情况下 Unity的image会自动处理shader切换
        if (image.material.shader.name == "UI/Default" || image.material.shader.name == "UI/DefaultETC1")
        {
            return;
        }

        if (isEtc1)
        {
            if (image.material.shader.name != ETC1GrayShaderName)
            {
                image.material = GetEtc1GrayMaterial();
                image.SetMaterialDirty();
            }
        }
        else
        {
            if (image.material.shader.name != NormalGrayShaderName)
            {
                image.material = GetNormalGrayMaterial();
                image.SetMaterialDirty();
            }
        }
    }
    
    public static void SetGray(Transform parent, bool bGray, bool canClick = false, bool withGraphic = false)
    {
        var graphics = parent.GetComponentsInChildren<Graphic>(true);
        foreach(var graphic in graphics)
        {
            if (graphic is Image image)
            {
                var sprite = image.sprite;
                image.material = bGray
                    ? sprite != null && sprite.texture != null && sprite.texture.format == TextureFormat.ETC_RGB4
                        ?
                        GetEtc1GrayMaterial()
                        : GetNormalGrayMaterial()
                    : null;
                image.SetMaterialDirty();
            }
            else
            {
                //graphic.material = bGray && withGraphic ? GetNormalGrayMaterial() : null;
            }
        }

        Button[] buttons = parent.GetComponentsInChildren<Button>(true);
        foreach(var button in buttons) 
        {
            button.enabled = canClick;
        }

        Toggle[] Toggles = parent.GetComponentsInChildren<Toggle>();
        foreach (var toggle in Toggles)
        {
            toggle.enabled = canClick;
        }
    }
    
    
    public static void SetGrayWithIgnore(Transform parent, bool bGray, string ignoreName)
    {
        Image[] images = parent.GetComponentsInChildren<Image>(true);
        foreach(var image in images) 
        {
            if (image.name == ignoreName)
            {
                continue;
            }
            
            var sprite = image.sprite;
            image.material = bGray ? sprite != null && sprite.texture != null && sprite.texture.format == TextureFormat.ETC_RGB4 ? GetEtc1GrayMaterial() : GetNormalGrayMaterial() : null;
            image.SetMaterialDirty();
        }
    }
    
    public static void SetGraySpriteRender(Transform parent, bool bGray)
    {
        SpriteRenderer[] images = parent.GetComponentsInChildren<SpriteRenderer>(true);
        foreach(var image in images) 
        {
//            var sprite = image.sprite;
            image.material = bGray ? GetGraySpriteRenderer() : GetNormalSpriteRenderer();
            parent.gameObject.SetActive(false);
            parent.gameObject.SetActive(true);
        }
    }

    public static void SetGrayNotRecursively(Image image, bool bGray)
    {
        var sprite = image.sprite;
        image.material = bGray ? sprite != null && sprite.texture != null && sprite.texture.format == TextureFormat.ETC_RGB4 ? GetEtc1GrayMaterial() : GetNormalGrayMaterial() : null;
        
        image.SetMaterialDirty();
    }

    private static void SetGraphicGray (Graphic graphic)
    {
        if (graphic == null)
            return;

        if (graphic is Image image)
        {
            var sprite = image.sprite;
            image.material = sprite != null && sprite.texture != null && sprite.texture.format == TextureFormat.ETC_RGB4 ? GetEtc1GrayMaterial() : GetNormalGrayMaterial();
        }
        else
        {
            //graphic.material = GetNormalGrayMaterial ();
        }
        
        graphic.SetMaterialDirty ();
    }

    public static void SetGraphicGrayRecursively (Transform parent)
    {
        var graphics = parent.GetComponentsInChildren<Graphic> ();
        foreach (var g in graphics)
        {
            SetGraphicGray (g);
        }
    }

    public static void SetGraphicGrayRecursivelyWithIgnore (Transform parent, string ignore)
    {
        var graphics = parent.GetComponentsInChildren<Graphic> ();
        foreach (var g in graphics)
        {
            if (g.name == ignore)
                continue;
            SetGraphicGray (g);
        }
    }
    
}





