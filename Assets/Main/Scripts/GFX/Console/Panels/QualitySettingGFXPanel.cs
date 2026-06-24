using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class QualitySettingGFXPanel :BaseGFXPanel
{
    private Camera mainCamera;
    
    private int initScreenWidth;
    private int initScreenHeight;
    
    private int pixelWidthMax = 1920;
    private int pixelHeightMax = 1080;

    private int smaaQuality = 0;
    private string[] smaaQualityString =  {"低", "中", "高"};

    public QualitySettingGFXPanel() : base("品质设置")
    {
        initScreenWidth = Mathf.Max(Screen.width, Screen.height);
        initScreenHeight = Mathf.Min(Screen.width, Screen.height);
        mainCamera= GameObject.FindWithTag("MainCamera").GetComponent<Camera>();
    }
    
    public override void Init()
    {
        pixelWidthMax = Mathf.RoundToInt(initScreenWidth * 1f / initScreenHeight * pixelHeightMax);
        
        var urpData = mainCamera.GetComponent<UniversalAdditionalCameraData>();
        smaaQuality = (int)urpData.antialiasingQuality;
    }

    public override void DrawGUI()
    {
        //----------贴图分辨率费--------
        GUILayout.Label("贴图分辨率Full,HalfWidth,QuadWidth");
        GUILayout.BeginHorizontal();
       
        if (GUILayout.Button("1"))
        {
            QualitySettings.globalTextureMipmapLimit = 0;
        }
        if (GUILayout.Button("1/2"))
        {
            QualitySettings.globalTextureMipmapLimit = 1;
        }
        if (GUILayout.Button("1/4"))
        {
            QualitySettings.globalTextureMipmapLimit = 2;
        }
        if (GUILayout.Button("1/8"))
        {
            QualitySettings.globalTextureMipmapLimit = 3;
        }
        
        GUILayout.EndHorizontal();
        
        //-----------HDR-------------
        GUILayout.Space(30);

        var urpAsset = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        
        if (GUILayout.Button("URPAsset HDR:"+urpAsset.supportsHDR))
        {
            urpAsset.supportsHDR = !urpAsset.supportsHDR;
        }
        
        GUILayout.Space(30);
        
        GUILayout.BeginHorizontal();
        int oldWidthMax = pixelWidthMax;
        pixelWidthMax = Convert.ToInt32(DrawInputField("分辨率上限-宽：", pixelWidthMax.ToString()));
        if (pixelWidthMax != oldWidthMax)
        {
            pixelHeightMax = Mathf.RoundToInt(initScreenHeight * 1f / initScreenWidth * pixelWidthMax);
        }
        int oldHeightMax = pixelHeightMax;
        pixelHeightMax = Convert.ToInt32(DrawInputField("高: ", pixelHeightMax.ToString()));
        if (pixelHeightMax != oldHeightMax)
        {
            pixelWidthMax = Mathf.RoundToInt(initScreenWidth * 1f / initScreenHeight * pixelHeightMax);
        }
        GUILayout.EndHorizontal();
        if (GUILayout.Button("确定切换"))
        {
            SceneQualitySetting.SetPixelHeightMax(pixelHeightMax);
            SceneQualitySetting.SetResolutionQuality();
        }
        
        GUILayout.Space(30);

        
        //----------抗锯齿-----------
        GUILayout.Space(20);
        
        GUILayout.BeginHorizontal();
        var urpData = mainCamera.GetComponent<UniversalAdditionalCameraData>();
        GUILayout.Label($"抗锯齿模式:{GetAntialiasingModeText(urpData.antialiasing)}");
        if (GUILayout.Button("None"))
        {
            urpData.antialiasing = AntialiasingMode.None;
        }
        if (GUILayout.Button("FXAA"))
        {
            urpData.antialiasing = AntialiasingMode.FastApproximateAntialiasing;
        }
        if (GUILayout.Button("SMAA"))
        {
            urpData.antialiasing = AntialiasingMode.SubpixelMorphologicalAntiAliasing;
        }
        GUILayout.EndHorizontal();
        if (urpData.antialiasing == AntialiasingMode.SubpixelMorphologicalAntiAliasing)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("SMAA质量:" + GetSMAAQualityText((AntialiasingQuality)smaaQuality));
            var oldQuality = smaaQuality;
            smaaQuality = GUILayout.Toolbar(smaaQuality, smaaQualityString);
            if (smaaQuality != oldQuality)
            {
                urpData.antialiasingQuality = (AntialiasingQuality)smaaQuality;
            }
            GUILayout.EndHorizontal();
        }
        
        GUILayout.Space(30);
        GUILayout.Label("MSAA级别:"+urpAsset.msaaSampleCount);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("关闭"))
        {
            urpAsset.msaaSampleCount = (int)MsaaQuality.Disabled;
        }
        if (GUILayout.Button("2x"))
        {
            urpAsset.msaaSampleCount = (int)MsaaQuality._2x;
        }
        if (GUILayout.Button("4x"))
        {
            urpAsset.msaaSampleCount= (int)MsaaQuality._4x;
        }
        if (GUILayout.Button("8x"))
        {
            urpAsset.msaaSampleCount = (int)MsaaQuality._8x;
        }
        GUILayout.EndHorizontal();

        // Grading Mode
        GUILayout.Space(20);
        GUILayout.Label("Grading Mode:" + urpAsset.colorGradingMode);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("LDR"))
        {
            urpAsset.colorGradingMode = ColorGradingMode.LowDynamicRange;
        }
        if (GUILayout.Button("HDR"))
        {
            urpAsset.colorGradingMode = ColorGradingMode.HighDynamicRange;
        }
        GUILayout.EndHorizontal();
    }

    private string GetAntialiasingModeText(AntialiasingMode mode)
    {
        switch (mode)
        {
            case AntialiasingMode.None: return "None";
            case AntialiasingMode.FastApproximateAntialiasing: return "FXAA";
            case AntialiasingMode.SubpixelMorphologicalAntiAliasing: return "SMAA";
        }

        return "";
    }

    private string GetSMAAQualityText(AntialiasingQuality quality)
    {
        return smaaQualityString[(int)quality];
    }
}





