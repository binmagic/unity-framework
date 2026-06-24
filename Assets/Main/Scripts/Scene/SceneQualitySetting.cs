using System;
using GameFramework;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public static class SceneQualitySetting
{
    private static int pixelHeightMax = 1080;
    
    public static void ChangeQualitySetting()
    {
        /*if (SceneManager.World != null)
        {
            SceneManager.World.ChangeQualitySetting();
        }*/
        SetResolutionQuality();
    }
    public static float GetScale()
    {
        return 1;
    }
    static bool CheckLowMemory()
    {
        if (SystemInfo.systemMemorySize <= 5000)
        {
            return true;
        }
        return false;
    }

    public static void SetResolutionQuality()
    {
        //float renderScale = 1;
        //if (Screen.height > pixelHeightMax)
        //{
        //    renderScale = pixelHeightMax / (float)Screen.height;
        //}

        //var lv = GameEntry.Setting.GetPublicInt(GameDefines.QualitySetting.Resolution, GameDefines.QualityLevel_High);
        //var ql = QualitySettings.GetQualityLevel();
        //var urp = QualitySettings.GetRenderPipelineAssetAt(ql) as UniversalRenderPipelineAsset;
        //if(CheckLowMemory())
        //{
        //    urp.supportsHDR = false;
        //}
        //if (lv == GameDefines.QualityLevel_Low)
        //{
        //    if (SystemInfo.systemMemorySize <= 4000)
        //    {
        //        int width = (int) Math.Round(Screen.width * renderScale);
        //        int height = (int)Math.Round(Screen.height * renderScale);
        //        Log.Debug("SetResolution from {0}_{1} to {2}_{3} mem : {4}", Screen.width, Screen.height, width, height, SystemInfo.systemMemorySize);
        //        Screen.SetResolution(width, height, true);
        //    }
            
        //    urp.renderScale = renderScale * GetScale();
        //}
        //else if (lv == GameDefines.QualityLevel_High)
        //{
        //    urp.renderScale = renderScale * GetScale();
        //}
        //Log.Debug($"SetResolutionQuality {Screen.width}x{Screen.height} renderScale:{urp.renderScale}");
    }

    public static void SetPixelHeightMax(int heightMax)
    {
        pixelHeightMax = heightMax;
    }
    
    public static int GetGraphicLevel()
    {
        return GameEntry.Setting.GetPublicInt(GameDefines.SettingKeys.SCENE_GRAPHIC_LEVEL,
            GameDefines.QualityLevel_Middle);
    }

    public static int GetTerrainLevel()
    {
        return GameEntry.Setting.GetPublicInt(GameDefines.QualitySetting.Terrain,
            GameDefines.QualityLevel_Low);
    }
}





