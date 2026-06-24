#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using GameFramework;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace VEngine.Editor
{
    /// <summary>
    ///     参与打包的资源，可以是单个文件，或文件夹
    /// </summary>
    [Serializable]
    public class Asset : IEquatable<Asset>, IComparable<Asset>
    {
        // 注释
        public string comment;
        
        [HideInInspector] private Object _target;
        
        private static readonly string[] EmptyStrings = new string[0];
        
        public static readonly string asset_prefix = "assets";
        
        /// <summary>
        ///     分组的打包模式，决定了分组资源的打包粒度
        /// </summary>
        public BundleMode bundleMode = BundleMode.PackByNone;
        
        /// <summary>
        ///     资源的 label，用来生成 bundle 的名字
        /// </summary>
        public string label;

        /// <summary>
        ///     资源的所有依赖
        /// </summary>
        [HideInInspector] public string[] dependencies = EmptyStrings;

        /// <summary>
        ///     是否是只读的内容，例如 children
        /// </summary>
        [HideInInspector] public bool readOnly;

        /// <summary>
        ///     资源的路径
        /// </summary>
        public string path = string.Empty;

        /// <summary>
        ///     资源排除的目录
        /// </summary>
        public string[] excludePaths = EmptyStrings;

        /// <summary>
        ///     跟节点的路径
        /// </summary>
        [HideInInspector] public string rootPath;

        /// <summary>
        ///     打包的分组
        /// </summary>
        [HideInInspector] public Group parentGroup;

        /// <summary>
        ///     获取 Bundle 的名字
        /// </summary>
        [HideInInspector] public string bundle;

        /// <summary>
        ///     自定义打包器，可以按自己的喜好为资源打包，相同名字的资源会打包到一起。
        /// </summary>
        public static Func<Asset, string> customPacker { get; set; }

        /// <summary>
        ///     包含依赖的大小
        /// </summary>
        public ulong size { get; set; }

        [HideInInspector] public int index = -1;


        /// <summary>
        ///     在 Assets 下的目标对象
        /// </summary>
        public Object target
        {
            get
            {
                if (_target == null) _target = AssetDatabase.LoadAssetAtPath<Object>(path);
                return _target;
            }
        }

        /// <summary>
        ///     是否是文件夹，文件夹需要采集子文件，但本身不参与打包。
        /// </summary>
        public bool isFolder => Directory.Exists(path);

        /// <summary>
        ///     资源是否已经修改
        /// </summary>
        public bool dirty { get; set; }

        public string metaPath => AssetDatabase.GetTextMetaFilePathFromAssetPath(path);

        public int CompareTo(Asset other)
        {
            return string.Compare(path, other.path, StringComparison.Ordinal);
        }

        public bool Equals(Asset other)
        {
            if (ReferenceEquals(null, other)) return false;

            if (ReferenceEquals(this, other)) return true;

            return path == other.path;
        }

        public string PackWithBundleMode()
        {
            BundleMode bm = GetBundleMode();
            if (bm == BundleMode.PackByRaw) return path;
            if (customPacker != null) return $"{customPacker(this)}{Settings.GetDefaultSettings().bundleExtension}";
            return PackWithDefault() + Settings.GetDefaultSettings().bundleExtension;
        }

        public BundleMode GetBundleMode()
        {
            // 有父物体的返回父物体的，否则返回Asset自己设置的
            if (parentGroup.bundleMode != BundleMode.PackByAssetSetting)
            {
                return parentGroup.bundleMode;
            }

            if (bundleMode == BundleMode.PackByNone)
            {
                return BundleMode.PackByFile;
            }
            
            return bundleMode;
        }

        private string PackWithDefault()
        {
            if (parentGroup == null) return "invalid";
            var groupName = $"{parentGroup.manifest.name}_{parentGroup.name}";
            var isScene = path.EndsWith(".unity") || path.EndsWith(".lighting");
            if (isScene)
            {
                var assetName = Path.GetFileNameWithoutExtension(path);
                return $"{groupName}_scenes_{assetName}".ToLower();
            }

            var bundleName = string.Empty;
            
            // 理论上folder没必要掉这个，但是一些工具可能使用
            if (isFolder)
            {
                int a = 0;
                Logger.W("isFolder but PackWithDefault - {0}", path);
                //return bundleName;
            }

            BundleMode bm = GetBundleMode();
            switch (bm)
            {
                case BundleMode.PackTogether:
                    bundleName = PackTogether(groupName);
                    break;
                case BundleMode.PackByEntry:
                    bundleName = PackByEntry(groupName);
                    break;
                case BundleMode.PackByLabel:
                    bundleName = PackByLabel(groupName);
                    break;
                case BundleMode.PackByTopSubDirectoryOnly:
                    bundleName = PackByTopSubDirectoryOnly(groupName);
                    break;
                case BundleMode.PackByTop2SubDirectoryOnly:
                    bundleName = PackByTop2SubDirectoryOnly(groupName);
                    break;
                
                case BundleMode.PackBySourcePrefabOrDirectory:
                case BundleMode.PackByDirectory:
                    bundleName = PackByDirectory(groupName);
                    break;
                case BundleMode.PackBySourcePrefabOrFile:
                    bundleName = PackBySourcePrefabOrFile(groupName);
                    break;
                
                case BundleMode.PackByFile:
                    bundleName = PackByFile(groupName);
                    break;
                case BundleMode.PackByModelPath:
                    bundleName = PackByModelPath(groupName);
                    break;
                
                default:
                    bundleName = $"{groupName}_default";
                    break;
            }

            if (string.IsNullOrEmpty(bundleName)) return "invalid";
            bundleName = bundleName.Replace("\\", "/").Replace("/", "_").Replace(".", "_").Replace(" ", "_");
            bundleName = bundleName.ToLower();
            
            if (bundleName.StartsWith(asset_prefix))
            {
                bundleName = bundleName.Substring(asset_prefix.Length);
            }
            bundleName = bundleName.TrimStart('_', ' ');

            // 有可能是根目录文件，，这里要特殊处理一下
            if (bundleName.IsNullOrEmpty())
            {
                bundleName = asset_prefix;
            }

            if (bundleName == "assets__art_models_environment_build_biesh")
            {
                int a = 0;
            }
            return bundleName;
        }

        /// <summary>
        ///     是否 需要排除 path 对应的文件
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public bool Exclude(string path)
        {
            if (path.EndsWith(".csv"))
            {
                return false;
            }
            
            // 排除相应的路径
            for (int i = 0; i < excludePaths.Length; ++i)
            {
                string s = excludePaths[i];
                s = s.Replace("\\", "/");

                if (path.StartsWith(s, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            // 不包含场景文件
            if (path.EndsWith(".unity") || path.EndsWith(".lighting"))
            {
                if (Settings.GetDefaultSettings().includeScene == false)
                {
                    return true;
                }
            }
            
            // 如果是Editor目录的话，打包时就要忽略掉
            if (path.Contains("/Editor/"))
            {
#if !UNITY_EDITOR
                Debug.LogFormat("xAsset - Exclude Editor path: {0}", path);
#endif
                return true;
            }
            
            return Array.Exists(Settings.GetDefaultSettings().excludeFiles,
                match: path.Contains);
        }
        
        public List<string> GetChildren(string dir)
        {
            if (!Directory.Exists(dir)) 
                return new List<string>();
            
#if true
            var txtFiles = Directory.EnumerateFiles(dir, "*", SearchOption.AllDirectories);
#else
            var txtFiles = Directory.GetFiles(dir, "*", SearchOption.AllDirectories);
#endif
            
            List<string> ret = new List<string>(1024);
            
            foreach (string currentFile in txtFiles)
            {
                string fileName = currentFile;
                
                if (fileName.EndsWith(".cs") || fileName.EndsWith(".meta"))
                {
                    continue;
                }
                
                // 目录直接排除返回,EnumerateFiles会返回目录吗？？？
                // if (Directory.Exists(fileName))
                // {
                //     continue;
                // }
                
                var file = fileName.Replace("\\", "/");
                
                // 被排除的文件，或者是目录就不加入了
                if (Exclude(file))
                {
                    // files.RemoveAt(index);
                    // index--;
                }
                else
                {
                    ret.Add(file);
                }
            }
            
            // 按文件名排序，确保每次输出的文件顺序要基本一样
            ret.Sort();
            return ret;
        }

        private string PackTogether(string groupName)
        {
            var assetName = Path.GetFileName(rootPath);
            // 如果有标签的话，直接使用标签+assetname
            if (!string.IsNullOrEmpty(label))
            {
                return $"{label}_all";
            }
            
            // 否则直接使用目录名字
            if (string.IsNullOrEmpty(rootPath))
            {
                return groupName + "_all";
            }

            return rootPath + "_all";
        }

        private string PackByEntry(string groupName)
        {
            var assetName = readOnly ? rootPath : path;
            if (Directory.Exists(assetName))
            {
                var info = new DirectoryInfo(assetName);
                assetName = info.Name;
            }
            else
            {
                assetName = Path.GetFileNameWithoutExtension(assetName);
            }

            // 如果有标签的话，直接使用标签+文件夹名字
            if (!string.IsNullOrEmpty(label)) return $"{label}_{assetName}";
            return $"{groupName}_{assetName}";
        }

        private string PackByLabel(string groupName)
        {
            if (string.IsNullOrEmpty(label)) return $"{groupName}_default";
            return $"{label}";
        }

        private void TraceBigFiles(string path, string comment)
        {
            long length = new System.IO.FileInfo(path).Length;
            if (length > 4 * 1024 * 1024)
            {
                string ext = Path.GetExtension(path);
                ext = ext.ToLower();
                if (ext == ".png" || ext == ".tga" || ext == ".tif")
                {
                    
                }
                else
                {
                    Debug.LogFormat("****** FILE is too big - {0}, {1}     - {2}", path, length, comment);
                }
            }
        }

        private string PackByDirectory(string groupName)
        {
            // 如果是auto的话，特殊处理一下
            if (groupName.Contains("Auto") || groupName.Contains("auto"))
            {
                int a = 0;
            }

            if (path.Contains("com."))
            {
                int a = 0;
            }

            // 一般是auto分组，此时直接使用完整的目录
            if (rootPath.IsNullOrEmpty())
            {
                if (groupName.Contains("Auto") || groupName.Contains("auto"))
                {

                }
                else
                {
                    Debug.LogFormat("rootpath is null : {0}", path);
                }

                var dName = Path.GetDirectoryName(path);
                dName = dName.ToLower();
                if (dName.StartsWith("assets/"))
                {
                    dName = dName.Substring(new string("assets/").Length);
                }
                return $"{groupName}_{dName}";
            }
            
            var rootPath2 = !rootPath.IsNullOrEmpty() ? rootPath.TrimEnd('/') : "";
            var directoryPath = !string.IsNullOrEmpty(rootPath2) ? path.Substring(rootPath2.Length) : path;
            directoryPath = directoryPath.TrimStart('/');
            
            var directoryName = "";
            
            var list = directoryPath.Split(('/')).ToList();
            if (list.Count > 0)
            {
                // 先去除文件名
                list.RemoveAt(list.Count - 1);
            }
            if (list.Count > 0)
            {
                directoryName = list[0];
            }

            TraceBigFiles(path, "PackByDirectory");
            
            // 如果是目录的文件的话，就用根目录名_files来替代
            if (string.IsNullOrEmpty(directoryName))
            {
                // Debug.LogFormat("pack directory path - {0}", path);
                return $"{rootPath2}_rootfiles";
            }
            
            return $"{rootPath2}_{directoryName}";
        }

        private string PackByTopSubDirectoryOnly(string groupName)
        {
            var rootPath2 = !rootPath.IsNullOrEmpty() ? rootPath.TrimEnd('/') : "";
            
             // 校验根目录是否为空
             if (string.IsNullOrEmpty(rootPath)) 
             {
                 Debug.LogFormat("rootPath is null: {0}", path);
                 return $"{rootPath2}_rootfiles";
             }

             // if (rootPath2.Contains("Assets/Main/Prefabs/UI/ActivityCenter"))
             // {
             //     int a = 0;
             // }
 
             // 确保根路径和文件路径都以标准分隔符表示
             rootPath = rootPath.TrimEnd('/', '\\');
             path = path.TrimStart('/', '\\');
 
             // 去掉 rootPath 前缀，提取相对路径
             var relativePath = path.Substring(rootPath.Length).TrimStart('/', '\\');
 
             // 分割相对路径，获取子目录列表
             var segments = relativePath.Split(new[] { '/', '\\' }, StringSplitOptions.RemoveEmptyEntries);
 
             // 确保至少有一个子目录，如果是1的话，就是文件名了
             if (segments.Length <= 1)
             {
                 return $"{rootPath2}_rootfiles";
             }
 
             // 取第一层和第二层子目录（如果存在）
             var directoryName = string.Join("/", segments.Take(1)); // 第一层目录
             
             // 这个代码表示取两层子目录
             // var directoryName = string.Join("/", segments.Take(2));
             
             // 返回最终结果
             var rootName = Path.GetFileName(rootPath); // 提取根目录名称
             return $"{rootPath2}_{directoryName}";
        }

        // 保留两层目录
        private string PackByTop2SubDirectoryOnly(string groupName)
        {
            var rootPath2 = !rootPath.IsNullOrEmpty() ? rootPath.TrimEnd('/') : "";
            
            // 校验根目录是否为空
            if (string.IsNullOrEmpty(rootPath)) 
            {
                Debug.LogFormat("rootPath is null: {0}", path);
                return $"{rootPath2}_rootfiles";
            }

            // 确保根路径和文件路径都以标准分隔符表示
            rootPath = rootPath.TrimEnd('/', '\\');
            path = path.TrimStart('/', '\\');

            // 去掉 rootPath 前缀，提取相对路径
            var relativePath = path.Substring(rootPath.Length).TrimStart('/', '\\');

            // 分割相对路径，获取子目录列表
            var segments = relativePath.Split(new[] { '/', '\\' }, StringSplitOptions.RemoveEmptyEntries);

            // 确保至少有一个子目录，如果是1的话，就是文件名了
            if (segments.Length <= 1)
            {
                return $"{rootPath2}_rootfiles";
            }

            // 取第一层和第二层子目录（如果存在）
            var directoryName = string.Join("/", segments.Take(2)); // 提取前两层目录

            // 返回最终结果
            var rootName = Path.GetFileName(rootPath); // 提取根目录名称
            return $"{rootPath2}_{directoryName}";
        }
        
        private string PackByFile(string groupName)
        {
            var localPath = path;
            if (string.IsNullOrEmpty(path))
            {
                localPath = rootPath;
            }
            
            // 获取不包含扩展名的完整路径
            string pathWithoutExtension = Path.ChangeExtension(localPath, null);

            // 将路径中的正斜杠 '/' 替换为下划线 '_'
            string result = pathWithoutExtension.Replace('/', '_');

            // 将路径中的反斜杠 '\' (Windows 系统常用) 也替换为下划线 '_'
            result = result.Replace('\\', '_');

            return result;
        }

        private string PackBySourcePrefabOrFile(string groupName)
        {
            var rootPath2 = !rootPath.IsNullOrEmpty() ? rootPath.TrimEnd('/') : "";
            var assetName = Path.GetFileNameWithoutExtension(path);
            
            return $"{rootPath2}_{assetName}";
        }

        private string PackByModelPath(string groupName)
        {
            string lower_path = path.ToLower();
            lower_path = lower_path.Replace("\\", "/");
            
            // 只取目录名字
            lower_path = lower_path.Substring(0,lower_path.LastIndexOf(@"/"));

            string[] flags =
            {
                @"/animation",
                @"/animations",
                @"/animator",
                @"/gpuskin",
                @"/material",
                @"/materials",
                @"/mesh",
                @"/meshs",
                @"/prefab",
                @"/prefabs",
                @"/texture",
                @"/textures",
                @"/tex",
                @"/actions",
                @"/fbx",
                @"/fbxs",
                @"/mat",
                @"/mats",
                @"/lightmap",
            };

            TraceBigFiles(path, "PackByModelPath");
            
            // 有几种归类的情况，例如：
            // A
            // |--texture
            //       |-- a.png      （第一种情况）
            // |--mesh
            //       |-- b.mesh     （第一种情况）
            // |--config  
            //       |-- c.config   （第二种情况：此父目录名字虽然不在flags里，但是也要算）
            // |--other.txt         （第三种情况：此文件的同级目录有flags目录，也要算）
            
            // 第一种情况 A/texture/a.png，此时lower_path = A/texture
            for (int i = 0; i < flags.Length; ++i)
            {
                int idx = lower_path.LastIndexOf(flags[i]);
                if (idx > 0)
                {
                    string s1 = lower_path.Substring(0, idx);
                    //Log.Debug("PackByModelPath ok : {0} -> {1}", path, s1);
                    return s1;
                }
            }
            
            // 先处理第三种情况，如果同级目录有flags归类的目录，就也归类
            for (int i = 0; i < flags.Length; ++i)
            {
                string testPath = lower_path + flags[i];
                if (Directory.Exists(testPath))
                {
                    string s1 = lower_path;
                    //Log.Debug("PackByModelPath ok : {0} -> {1}", path, s1);
                    return s1;
                }
            }
            
            // 第二种情况，上级目录有flags归类的目录，也归类
            string parentPath = lower_path.Substring(0,lower_path.LastIndexOf(@"/"));
            for (int i = 0; i < flags.Length; ++i)
            {
                string testPath = parentPath + flags[i];
                if (Directory.Exists(testPath))
                {
                    string s1 = parentPath;
                    //Log.Debug("PackByModelPath ok : {0} -> {1}", path, s1);
                    return s1;
                }
            }

            // 不符合模型的目录规则，则直接使用目录名字
            string s2 = lower_path;
            if (s2.IsNullOrEmpty())
            {
                s2 = PackByDirectory(groupName);
            }

            Log.Info("PackByModelPath not form : {0} -> {1}", path, s2);
            return s2;
        }
        
        public static int count = 0;

        public static Asset Create(string path, Group group, string label = null,
            string rootPath = null, BundleMode bundleMode = BundleMode.PackByNone)
        {
            var asset = new Asset
            {
                label = label,
                path = path,
                parentGroup = group,
                rootPath = rootPath,
                bundleMode = bundleMode,
            };

            if (rootPath != null)
            {
                asset.readOnly = true;
            }

            asset.index = count;
            if (asset.index == 17690)
            {
                int aa = 0;
            }
            
            asset.bundle = asset.PackWithBundleMode();
            
            // if (group.name == "Auto")
            // {
            //     Log.Debug("Asset Create [AUTO] - {0}: {1} -> {2}", count++, path, asset.bundle);
            // }
            // else
            // {
            //     Log.Debug("Asset Create - {0}: {1} -> {2}", count++, path, asset.bundle);
            // }

            return asset;
        }


        /// <summary>
        ///     获取资源的所有依赖，不包括自己
        /// </summary>
        /// <returns></returns>
        private static string[] GetDependencies_path = new string[1];
        private static List<string> items = new List<string>(20);
        public string[] GetDependencies()
        {
            items.Clear();
            GetDependencies_path[0] = path;
            
            items.AddRange(isFolder
                ? AssetDatabase.GetDependencies(GetChildren().ToArray(), true)
                : AssetDatabase.GetDependencies(GetDependencies_path, true));
            for (var index = 0; index < items.Count; index++)
            {
                var dependency = items[index];
                if (dependency == path
                    || Directory.Exists(dependency)
                    || Exclude(dependency) ||
                    isFolder &&
                    isChild(dependency))
                {
                    items.RemoveAt(index);
                    index--;
                }
            }

            items.Sort();
            dependencies = items.ToArray();
            return dependencies;
        }

        public bool isChild(string file)
        {
            return file.Contains(path);
        }

        /// <summary>
        ///     获取子文件-递归。
        /// </summary>
        /// <returns></returns>
        public List<string> GetChildren()
        {
            return GetChildren(path);
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;

            if (ReferenceEquals(this, obj)) return true;

            return obj.GetType() == GetType() && Equals((Asset) obj);
        }

        public override int GetHashCode()
        {
            return path.GetHashCode();
        }
    }
}
#endif



