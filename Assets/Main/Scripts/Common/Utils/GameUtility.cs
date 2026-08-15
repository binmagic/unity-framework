/**
 * [INPUT]: 依赖 UnityEngine 的 Application/RuntimePlatform,依赖 System.IO 路径拼接
 * [OUTPUT]: 对外提供 GameUtility 静态类,统一解析 AssetBundle 输出目录/StreamingAssets/平台名等运行时路径
 * [POS]: Common/Utils 的平台路径中枢,资源加载与热更的路径来源,与 FileUtils(文件读写)分工
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using UnityEngine;
using System.IO;
using System.Threading;

/// <summary>
/// 功能：通用静态方法
/// </summary>
public static class GameUtility
{
    public const string AssetBundlesOutputPath = "AssetBundles";

    public static string GetStreamingAssetsDirectory()
    {
        if (Application.isEditor)
        {
            var p = Path.Combine(
                System.Environment.CurrentDirectory,
                AssetBundlesOutputPath,
                GetPlatformName());
            
            return p.Replace("\\", "/"); // Use the build output folder directly.
        }
        else if (Application.platform == RuntimePlatform.Android)
            return Application.dataPath + "!assets";
        else // todo console platform maybe can not run well
            return Application.streamingAssetsPath;
    }

    public static string GetPlatformName()
    {
#if UNITY_EDITOR
        return GetPlatformForEditor(UnityEditor.EditorUserBuildSettings.activeBuildTarget);
#else
		return GetPlatformForApp(Application.platform);
#endif
    }

#if UNITY_EDITOR
    private static string GetPlatformForEditor(UnityEditor.BuildTarget target)
    {
        switch (target)
        {
            case UnityEditor.BuildTarget.Android:
                return "Android";
            case UnityEditor.BuildTarget.iOS:
                return "iOS";
            case UnityEditor.BuildTarget.StandaloneWindows:
            case UnityEditor.BuildTarget.StandaloneWindows64:
                return "StandaloneWindows";
            case UnityEditor.BuildTarget.StandaloneOSX:
                return "StandaloneOSXUniversal";
            default:
                return string.Empty;
        }
    }
#endif

    private static string GetPlatformForApp(RuntimePlatform platform)
    {
        switch (platform)
        {
            case RuntimePlatform.Android:
                return "Android";
            case RuntimePlatform.IPhonePlayer:
                return "iOS";
            case RuntimePlatform.WebGLPlayer:
                return "WebGL";
            case RuntimePlatform.WindowsPlayer:
                return "StandaloneWindows";
            case RuntimePlatform.OSXPlayer:
                return "StandaloneOSXUniversal";
            default:
                return string.Empty;
        }
    }

    public static void SetThreadName(this Thread t, string name)
    {
        try
        {
            t.Name = name;
        }
        catch (Exception e)
        {
            // 线程名字只能设置一次，设置多次会抛异常
        }
    }
}





