#if UNITY_EDITOR
using System.IO;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace VEngine.Editor
{
    /// <summary>
    ///     播放器打包处理器，打包前，自动复制资源到 StreamingAssets，打包后，为了避免触发 Reimport 会自动删除 StreamingAssets 下面的资源。
    /// </summary>
    public class PlayerBuildProcessor : IPreprocessBuildWithReport, IPostprocessBuildWithReport
    {
        public int callbackOrder => 0;

        public void OnPostprocessBuild(BuildReport report)
        {
            var directory = EditorUtility.BuildPlayerDataPath;
            if (!Directory.Exists(directory)) return;
            Directory.Delete(directory, true);
            if (Directory.GetFiles(Application.streamingAssetsPath).Length == 0)
            {
                Directory.Delete(Application.streamingAssetsPath);
            }
        }

        public void OnPreprocessBuild(BuildReport report)
        {
            //var settings = Settings.GetDefaultSettings();
            //settings.CopyToStreamingAssets();
        }
    }
}
#endif



