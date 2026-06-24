using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 
/// </summary>
public class ScreenGFXPanel :BaseGFXPanel
{
    //URP主相机分辨率
    private float urpResolutionScale = 1f;
    
    //满分辨率
    private float fullResolutionScale = 1f;
    
    private int initScreenWidth;
    private int initScreenHeight;

    private int targetFramerate=60;

    public ScreenGFXPanel() : base("屏幕")
    {
        initScreenWidth = Mathf.Max(Screen.width, Screen.height);
        initScreenHeight = Mathf.Min(Screen.width, Screen.height);
        targetFramerate = Application.targetFrameRate;
    }

    public override void Init()
    {
        var urpAsset = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        urpResolutionScale = urpAsset.renderScale;
    }

    public override void DrawGUI()
    {
        //分辨率
        GUILayout.Label($"原始屏幕分辨率:{initScreenWidth} {initScreenHeight}");
        GUILayout.Label($"URP主相机分辨率:{(int)(Camera.main.pixelWidth * urpResolutionScale)} {(int)(Camera.main.pixelHeight * urpResolutionScale)}");
        urpResolutionScale = DrawSlider("URP主相机缩放", urpResolutionScale, 0.25f, 1);
        if (GUILayout.Button("确定切换"))
        {
            //Debug.Log("切换了分辨率"+resolutionScale);
            var urpAsset = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
            urpAsset.renderScale = urpResolutionScale;
        }
        GUILayout.Space(30);
        
        fullResolutionScale = DrawSlider("总屏幕缩放", fullResolutionScale, 0.25f, 1);

        if (GUILayout.Button("确定切换"))
        {
            //Debug.Log("切换了分辨率"+resolutionScale);
            var ww = (int)(initScreenWidth * fullResolutionScale);
            var hh = (int)(initScreenHeight * fullResolutionScale);
            Screen.SetResolution(ww,hh,true);
        }
        
        GUILayout.Space(30);
        
        //帧频
        GUILayout.Label($"帧频:{Application.targetFrameRate}");
     
        targetFramerate = (int)GUILayout.HorizontalSlider(targetFramerate, 5, 60);

        if (GUI.changed)
        {
            Application.targetFrameRate = targetFramerate;
            //Debug.Log("切换了帧频"+targetFramerate);
        }
        
        GUILayout.Space(30);
    }
}





