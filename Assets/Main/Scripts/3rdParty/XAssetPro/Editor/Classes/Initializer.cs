#if UNITY_EDITOR
using System;
using System.IO;
using UnityEngine;

namespace VEngine.Editor
{
    /// <summary>
    ///     初始化类，提供了编辑器的初始化操作
    /// </summary>
    public static class Initializer
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void Init()
        {
            var settings = Settings.GetDefaultSettings();
            Versions.DownloadDataPath = Path.Combine(Application.persistentDataPath, Utility.buildPath);
            Versions.PlatformName = EditorUtility.GetPlatformName();
            var config = settings.GetPlayerSettings();
            config.manifests = settings.manifests.ConvertAll(m => m.name);
            switch (settings.scriptPlayMode)
            {
                case ScriptPlayMode.Simulation:
                    Versions.FuncCreateAsset = EditorAsset.Create;
                    Versions.FuncIsAssetDownloaded = EditorAsset.IsAssetDownloaded;
                    Versions.FuncCreateScene = EditorScene.Create;
                    Versions.FuncCreateManifest = EditorManifestFile.Create;
                    Versions.SkipUpdate = true;
                    Versions.IsSimulation = true;
                    break;
                case ScriptPlayMode.Preload:
                    Versions.PlayerDataPath =
                        Path.Combine(Environment.CurrentDirectory, EditorUtility.PlatformBuildPath);
                    Versions.SkipUpdate = true;
                    Versions.IsSimulation = false;
                    break;
                // case ScriptPlayMode.Incremental:
                //     if (!Directory.Exists(Path.Combine(Application.streamingAssetsPath, Utility.buildPath)))
                //     {
                //         config.assets.Clear();
                //     }
                //     Versions.SkipUpdate = false;
                //     Versions.IsSimulation = false;
                //     break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}
#endif



