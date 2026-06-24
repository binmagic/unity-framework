#if UNITY_EDITOR
using System;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace VEngine.Editor
{
    /// <summary>
    ///     编辑器菜单工具
    /// </summary>
    public static class MenuItems
    {
        // /// <summary>
        // ///     l
        // ///     打包分组
        // /// </summary>
        [MenuItem("XASSET/检查Mainfest资源引用")]
        public static void CheckManifestRefs()
        {
             BuildScript.CheckManifestRefs();
        }

        /// <summary>
        ///     查看选中资源的 crc
        /// </summary>
        [MenuItem("XASSET/Compute CRC")]
        public static void ComputeCRC()
        {
            Logger.T(action: () =>
            {
                var target = Selection.activeObject;
                var path = AssetDatabase.GetAssetPath(target);
                var crc32 = Utility.ComputeCRC32(File.OpenRead(path));
                Logger.W("{0}={1}", path, crc32);
            }, name: "ComputeCRC");
        }


        /// <summary>
        ///     打包资源
        /// </summary>
        [MenuItem("XASSET/Build/Bundles")]
        public static void BuildBundles()
        {
            BuildScript.BuildBundles();
        }

        // [MenuItem("XASSET/Build/BundlesFast")]
        // public static void BuildBundlesFast()
        // {
        //     BuildScript.BuildBundles();
        // }

        /// <summary>
        ///     打包播放器
        /// </summary>
        [MenuItem("XASSET/Build/Player")]
        public static void BuildPlayer()
        {
            BuildScript.BuildPlayer();
        }

        /// <summary>
        ///     复制路径
        /// </summary>
        [MenuItem("XASSET/Build/Copy To StreamingAssets")]
        public static void CopyToStreamingAssets()
        {
            BuildScript.CopyToStreamingAssets();
        }

        /// <summary>
        ///     清理所有数据
        /// </summary>
        [MenuItem("XASSET/Build/Clear")]
        public static void Clear()
        {
            BuildScript.Clear();
        }

        [MenuItem("XASSET/Build/Clear History")]
        public static void ClearHistory()
        {
            BuildScript.ClearHistory();
        }

        /// <summary>
        ///     查看打包的资源设置
        /// </summary>
        [MenuItem("XASSET/View/Settings")]
        public static void ViewSettings()
        {
            EditorUtility.PingWithSelected(Settings.GetDefaultSettings());
        }

        [MenuItem("XASSET/Clear Progress Bar")]
        public static void ClearProgressBar()
        {
            EditorUtility.ClearProgressBar();
        }

        /// <summary>
        ///     查看打包后的资源
        /// </summary>
        [MenuItem("XASSET/View/Build Path")]
        public static void ViewBuildPath()
        {
            UnityEditor.EditorUtility.OpenWithDefaultApp(EditorUtility.PlatformBuildPath);
        }

        /// <summary>
        ///     查看下载目录的资源
        /// </summary>
        [MenuItem("XASSET/View/Download Path")]
        public static void ViewDownloadPath()
        {
            UnityEditor.EditorUtility.OpenWithDefaultApp(Application.persistentDataPath);
        }

        /// <summary>
        ///     查看临时目录的资源
        /// </summary>
        [MenuItem("XASSET/View/Temporary")]
        public static void ViewTemporary()
        {
            UnityEditor.EditorUtility.OpenWithDefaultApp(Application.temporaryCachePath);
        }


        /// <summary>
        ///     复制路径
        /// </summary>
        [MenuItem("XASSET/Copy Path")]
        public static void CopyAssetPath()
        {
            EditorGUIUtility.systemCopyBuffer = AssetDatabase.GetAssetPath(Selection.activeObject);
        }

        // [MenuItem("XASSET/Incremental")]
        // public static void Incremental()
        // {
        //     XLuaMenu.Lua2Txt();
        //     BuildScript.Clear();
        //     BuildScript.BuildBundles();
        //     BuildScript.CopyToStreamingAssets();
        //     Settings.GetDefaultSettings().scriptPlayMode = ScriptPlayMode.Incremental;
        //     Settings.GetDefaultSettings().Save();
        //     Debug.Log("Set Incremental ok");
        // }
        //

        [MenuItem("XASSET/构建本地ABMode环境", false, 200)]
        public static void Build_ABEnvironment()
        {
            //XLuaMenu.Lua2Txt();
            BuildScript.Clear();
            BuildScript.BuildBundles();
            //Settings.GetDefaultSettings().scriptPlayMode = ScriptPlayMode.Preload;
            Settings.GetDefaultSettings().Save();
            Debug.Log("Build_ABEnvironment ok");
        }
        
        [MenuItem("XASSET/构建本地LuaTxt", false, 201)]
        public static void Build_LocalLuaTxt()
        {
            XLuaMenu.Lua2Txt();
            Debug.Log("Build_LocalLuaTxt ok");
        }
        
        
        [MenuItem("XASSET/ABMode", false, 101)]
        public static void Preload()
        {
            // XLuaMenu.Lua2Txt();
            // BuildScript.Clear();
            // BuildScript.BuildBundles();
            Settings.GetDefaultSettings().scriptPlayMode = ScriptPlayMode.Preload;
            Settings.GetDefaultSettings().Save();
            Debug.Log("Set Preload ok");
        }
        [MenuItem("XASSET/ABMode", true, 101)]
        static bool IsPreload()
        {
            bool b = Settings.GetDefaultSettings().scriptPlayMode == ScriptPlayMode.Preload;
            Menu.SetChecked("XASSET/ABMode", b);
            return true;
        }

        [MenuItem("XASSET/Simulation", false, 100)]
        public static void Simulation()
        {
            Settings.GetDefaultSettings().scriptPlayMode = ScriptPlayMode.Simulation;
            Settings.GetDefaultSettings().Save();
            Debug.Log("Set Simulation ok");
        }
        
        [MenuItem("XASSET/Simulation", true, 100)]
        public static bool IsSimulation()
        {
            bool b = Settings.GetDefaultSettings().scriptPlayMode == ScriptPlayMode.Simulation;
            Menu.SetChecked("XASSET/Simulation", b);
            return true;
        }
        
        [MenuItem("XASSET/去除Bundle8字节前缀", false, 500)]
        public static void RemoveBundlePrefix()
        {
            string path =  UnityEditor.EditorUtility.OpenFolderPanel("选择AssetBundle目录", "", "");
            if (path.IsNullOrEmpty())
            {
                return;
            }
            
            string[] files = Directory.GetFiles(path, "*.bundle");

            string key_UnityRaw = "UnityRaw";
            byte[] keybyte = System.Text.Encoding.UTF8.GetBytes(key_UnityRaw);
            
            foreach (string file in files)
            {
                if (!file.EndsWith(".bundle"))
                    continue;
                
                //Debug.Log($"--> {filepath}");
                byte[] bytedata = File.ReadAllBytes(file);

                string s = System.Text.Encoding.UTF8.GetString(bytedata, 0, 8);
                if (s != "UnityRaw")
                {
                    continue;
                }

                FileStream sw = File.OpenWrite(file);
                sw.Write(bytedata, 8, bytedata.Length - 8);
                sw.Close();
            }
            
            Debug.LogFormat("RemoveBundlePrefix - {0}", path);
        }

        [MenuItem("XASSET/去除Bundle MD5文件名", false, 500)]
        public static void RemoveBundleMd5()
        {
            string path =  UnityEditor.EditorUtility.OpenFolderPanel("选择AssetBundle目录", "", "");
            if (path.IsNullOrEmpty())
            {
                return;
            }
            
            string[] files = Directory.GetFiles(path, "*.bundle");
            StringBuilder sb = new StringBuilder();
            
            foreach (string file in files)
            {
                int pos1 = file.LastIndexOf('_');
                int pos2 = file.LastIndexOf('.');

                string s = file;
                if (pos1>= 0 && pos1 < pos2)
                {
                    s = file.Remove(pos1, pos2 - pos1);
                    File.Move(file, s);
                }

                long length = new FileInfo(s).Length;
                int pos3 = s.IndexOf("assets/");
                if (pos3 >= 0)
                {
                    s = s.Substring(pos3);
                }

                sb.AppendFormat("{0}\t{1}\n", s, length);
            }
            
            File.WriteAllText(path + "/statistics.txt", sb.ToString());
            Debug.LogFormat("RemoveBundleMd5 - {0}", path);
        }
    }
}
#endif



