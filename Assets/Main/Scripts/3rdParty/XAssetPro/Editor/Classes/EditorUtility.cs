#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace VEngine.Editor
{
    /// <summary>
    ///     编辑器资源辅助类
    /// </summary>
    public static class EditorUtility
    {
        /// <summary>
        ///     打包后资源的输出目录
        /// </summary>
        public static string PlatformBuildPath
        {
            get
            {
                var dir = Utility.buildPath + $"/{GetPlatformName()}";
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }

                return dir;
            }
        }

        /// <summary>
        ///     打包后的资源，复制到播放器中（包体）目录
        /// </summary>
        public static string BuildPlayerDataPath => $"{Application.streamingAssetsPath}/{Utility.buildPath}";

        public static string GetPlatformName()
        {
            switch (EditorUserBuildSettings.activeBuildTarget)
            {
                case BuildTarget.Android:
                    return "Android";
                case BuildTarget.StandaloneOSX:
                    return "OSX";
                case BuildTarget.StandaloneWindows:
                case BuildTarget.StandaloneWindows64:
                    return "Windows";
                case BuildTarget.iOS:
                    return "iOS";
                case BuildTarget.WebGL:
                    return "WebGL";
                default:
                    return Utility.unsupportedPlatform;
            }
        }

        public static void PingWithSelected(Object target)
        {
            Selection.activeObject = target;
            EditorGUIUtility.PingObject(target);
        }

        /// <summary>
        ///     获取或创建一个 Scriptable 对象
        /// </summary>
        /// <param name="path">对象 在 Assets 下的路径</param>
        /// <typeparam name="T">对象的类型</typeparam>
        /// <returns></returns>
        internal static T GetOrCreateAsset<T>(string path) where T : ScriptableObject
        {
            var asset = AssetDatabase.LoadAssetAtPath<T>(path);
            if (asset != null)
            {
                return asset;
            }

            var dir = Path.GetDirectoryName(path);
            if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            asset = ScriptableObject.CreateInstance<T>();
            AssetDatabase.CreateAsset(asset, path);
            return asset;
        }

        internal static T GetAsset<T>(string path) where T : ScriptableObject
        {
            var asset = AssetDatabase.LoadAssetAtPath<T>(path);
            if (asset != null)
            {
                return asset;
            }

            return null;
        }

        /// <summary>
        ///     保存对象
        /// </summary>
        /// <param name="asset"></param>
        internal static void SaveAsset(Object asset)
        {
            UnityEditor.EditorUtility.SetDirty(asset);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        public static string FormatBytes(ulong bytes)
        {
            return Utility.FormatBytes(bytes);
        }

        public static void DisplayProgressBar(string title, string content, int index, int max)
        {
            UnityEditor.EditorUtility.DisplayProgressBar($"{title}({index}/{max}) ", content,
                index * 1f / max);
        }

        public static void ClearProgressBar()
        {
            UnityEditor.EditorUtility.ClearProgressBar();
        }
    }
}
#endif



