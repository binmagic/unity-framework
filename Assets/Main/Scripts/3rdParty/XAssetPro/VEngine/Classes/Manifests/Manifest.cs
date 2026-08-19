using System;
using System.Buffers;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     资源清单，记录了所有要加载的资源的寻址信息和依赖关系。
    /// </summary>
    public partial class Manifest
    {
        private const string key_version = "[Version]";
        private const string key_app_version = "[AppVersion]";
        private const string key_groups = "[Groups]";
        private const string key_paths = "[Paths]";
        private const string key_directories = "[Directories]";
        private const string key_bundles = "[Bundles]";
        private const string key_assets = "[Assets]";
        private const string key_dependencies = "[Dependencies]";
        private const string key_count = "#Count=";

        private static readonly HashSet<string> all_keys = new HashSet<string>
        {
            key_version,
            key_app_version,
            key_groups,
            key_paths,
            key_directories,
            key_bundles,
            key_assets,
            key_dependencies,
        };

        public Action<string> onReadAsset;

        /// <summary>
        ///     所有资源路径
        /// </summary>
        internal readonly List<string> allAssetPaths = new List<string>();

        /// <summary>
        ///     所有资源的目录
        /// </summary>
        private List<string> directories = new List<string>();

        /// <summary>
        ///     按 bundle 名字关联运行时信息
        /// </summary>
        private readonly Dictionary<string, BundleInfo> nameWithBundles = new Dictionary<string, BundleInfo>(500);

        /// <summary>
        ///     按 asset 名字关联运行时信息；这个字典中第二个值表示在assets数组中的下标
        /// </summary>
        internal readonly Dictionary<string, int> pathWithAssets = new Dictionary<string, int>(2000);

        /// <summary>
        ///     所有 asset 的运行时信息
        /// </summary>
        public List<AssetInfo> assets = new List<AssetInfo>();

        /// <summary>
        ///     所有 bundle 的运行时信息
        /// </summary>
        public List<BundleInfo> bundles = new List<BundleInfo>();
        
        /// <summary>
        ///     所有 Asset 依赖的Bundles信息
        /// </summary>
        public List<int[]> dep_bundles = new List<int[]>();
    
        /// <summary>
        ///     所有 Asset 依赖的Bundles信息
        /// </summary>
        //public List<BundleInfo[]> dep_bundles_list = new List<BundleInfo[]>(256);

        /// <summary>
        ///     版本号
        /// </summary>
        public int version;
        // 时间戳
        public long unix_timestamp;
        // 打包时的版本号
        public string appVersion;

        public string name { get; set; }

        public int id { get; set; }
        
        // 这里做一个全局sb！
        private StringBuilder sb = null;

        public void LoadEx(string name1)
        {
            name = name1;
            name1 = Path.Combine(Application.persistentDataPath, name1);
            Load(name1);
        }

        public void Load(string path)
        {
            //Debug.Log($">>>lsz parse Manifest: {path}");
            pathWithAssets.Clear();
            nameWithBundles.Clear();
            //nameWithGroups.Clear();
            allAssetPaths.Clear();
            assets.Clear();
            bundles.Clear();
            //groups.Clear();
            directories.Clear();

#if UNITY_WEBGL
            // WebGL: 如果 path 是 URL，通过 UnityWebRequest 加载
            // 如果是本地路径，尝试从 StreamingAssets 加载
            if (path.StartsWith("http://") || path.StartsWith("https://"))
            {
                LoadFromURL(path);
                return;
            }
#endif

            if (!File.Exists(path))
            {
                return;
            }

            ParseManifest(path);

            // 这东西读完就可以直接释放了，以后也不用了
            //C项目耻辱柱：这个内存俩份的问题 仨人累计工作量小一周才定位，结果是一个极小的问题！！！ 太菜了懂吗？！！！！
            //后续可能reload 为了尽可能容错这里重新赋值下 这样之前大的内存才能被GC掉 --zlh
            directories = new List<string>();
            return;
        }

#if UNITY_WEBGL
        /// <summary>
        /// WebGL: 从文本内容加载 manifest（不依赖文件系统）
        /// </summary>
        public void LoadFromText(string text)
        {
            pathWithAssets.Clear();
            nameWithBundles.Clear();
            allAssetPaths.Clear();
            assets.Clear();
            bundles.Clear();
            directories.Clear();

            if (string.IsNullOrEmpty(text))
            {
                return;
            }

            ParseManifestFromText(text);
            directories = new List<string>();
        }

        /// <summary>
        /// WebGL: 从 URL 加载 manifest
        /// </summary>
        private void LoadFromURL(string url)
        {
            // 注意: 这是同步加载，WebGL 上可能有问题
            // 实际应该在 ManifestFile 的异步流程中处理
            Log.Warning($"[WebGL] Manifest.LoadFromURL called synchronously for: {url}");
        }

        private void ParseManifestFromText(string text)
        {
            Log.Info("[VER] ParseManifestFromText");
            var parseType = string.Empty;
            sb = new StringBuilder(512);

            var reader = new StringReader(text);
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                ParseManifestLine(line.AsSpan(), ref parseType);
            }
            reader.Dispose();

            sb = null;
        }
#endif
        
           // 解析；快速且不产生GC
        private void ParseManifest(string path)
        {
            Log.Info("[VER]ParseManifest {0}", path);
            var parseType = string.Empty;
            sb = new StringBuilder(512);
            
            using (StreamReader sr = File.OpenText(path))
            {
                // https://adamsitnik.com/Array-Pool/
                var samePool = ArrayPool<char>.Shared;
                char[] fileBuffer = samePool.Rent(8192*4);

                try
                {
                    foreach (ReadOnlySpan<char> line in sr.SplitLines(fileBuffer))
                    {
                        //we're just testing read speeds
                        ParseManifestLine(line, ref parseType);
                    }
                }
                finally
                {
                    samePool.Return(fileBuffer);   
                }
            }
            
            sb = null;
            
            // #if UNITY_EDITOR
            // Log.Error("read ok!!!!");
            // #endif
            return;
        }

        // 根据#Count=来设置容器的容量，这个值可以没有
        // Unity2019带的C#版本还不支持Dictionary的Capacity设置
        private void SetContainerCapacity(ReadOnlySpan<char> line, string parseType)
        {
            if (!line.StartsWith(key_count.AsSpan()))
            {
                return;
            }

            ReadOnlySpan<char> fields_0;
            ReadOnlySpan<char> fields_1;
            if (line.Split_to_spanspan('=', out fields_0, out fields_1) == false)
            {
                return;
            }
            
            int c = fields_1.ToInt();
            // 这里需要try..catch一下，因为设置Capacity的时候有可能抛出异常
            try
            {
                switch (parseType)
                {
                    case key_bundles:
                        bundles.Capacity = c;
                       //Log.Info("{0} - Set {1} Capacity - {2}", name, parseType, c);
                        break;
                    case key_assets:
                        assets.Capacity = c;
                        allAssetPaths.Capacity = c;
                        //Log.Info("{0} - Set {1} Capacity - {2}", name, parseType, c);
                        break;
                    case key_directories:
                        directories.Capacity = c;
                        //Log.Info("{0} - Set {1} Capacity - {2}", name, parseType, c);
                        break;
                    case key_dependencies:
                        dep_bundles.Capacity = c;
                        //Log.Info("{0} - Set {1} Capacity - {2}", name, parseType, c);
                        break;
                }
            }
            catch
            {
                Log.Error("{0} - Set {1} Capacity Error - {2}", name, parseType, c);
            }
        }

        private void ParseManifestLine(ReadOnlySpan<char> line, ref string parseType)
        {
            try
            {
                if (line.IsEmpty)
                {
                    return;
                }

                // 表面是注释，其实是一些隐式信息，暂时只有Count
                if (line[0] == '#')
                {
                    SetContainerCapacity(line, parseType);
                    return;
                }

                if (line.Length >= 2 && line[0] == '/' && line[1] == '/')
                {
                    return;
                }

                // 文件中是没有多余空格的，他之前的判断也是原始字符串直接判断的
                if (line[0] == '[')
                {
                    ReadOnlySpan<char> ok_line = line.Trim();

                    bool found = false;
                    foreach (var k in all_keys)
                    {
                        // 注意readonlyspan和字符串比较，不能直接使用==；必须使用如下形式
                        if (k.AsSpan().SequenceEqual(ok_line))
                        {
                            parseType = k;
                            found = true;
                            break;
                        }
                    }

                    if (found)
                    {
                        return;
                    }

                    // 什么情况能走到这里？
#if UNITY_EDITOR
                    Log.Error("what a happened for run here?!");
#endif
                }

                switch (parseType)
                {
                    case key_version:
                        ReadVersion(line);
                        break;
                    case key_bundles:
                        ReadBundle(line);
                        break;
                    case key_assets:
                        ReadAsset(line);
                        break;
                    case key_directories:
                        ReadDirectory(line);
                        break;
                    case key_dependencies:
                        ReadDependencies(line);
                        break;
                }
            }
            catch (Exception exception)
            {
                Log.Error("parser error!!!!");
            }

            return;
        }
        
        private void ReadVersion(ReadOnlySpan<char> line)
        {
            ReadOnlySpan<char> fields_0;
            ReadOnlySpan<char> fields_1;
            line.Split_to_spanspan(',', out fields_0, out fields_1);
            version = fields_0.ToInt();
            unix_timestamp = fields_1.ToInt();
            
            Log.Info("[VER]ReadVersion {0},{1}", version, unix_timestamp);
        }
        
        private void ReadDirectory(ReadOnlySpan<char> line)
        {
            ReadOnlySpan<char> fields_0;
            ReadOnlySpan<char> fields_1;
            line.Split_to_spanspan('=', out fields_0, out fields_1);
            
            sb.Clear();
            if (!fields_1.StartsWith("Assets/"))
            {
                sb.Append("Assets/");
            }

            sb.Append(fields_1);
            
            directories.Add(sb.ToString());
            //directories.Add(fields_1.ToString());
        }
        
        // 读取所有依赖项
        private void ReadDependencies(ReadOnlySpan<char> line)
        {
            ReadOnlySpan<char> fields_0;
            ReadOnlySpan<char> fields_1;
            line.Split_to_spanspan('=', out fields_0, out fields_1);

            //int[] bundles = fields_1.Split_to_IntArray('|');
            int[] bundles = fields_1.Split_to_IntArrayEx('|');
            dep_bundles.Add(bundles);
        }
        
        private void ReadBundle(ReadOnlySpan<char> line)
        {
            var bundle = new BundleInfo();
            //bundle.Deserialize(line);
            
            ReadOnlySpan<char> fields_0;
            ReadOnlySpan<char> fields_1;
            ReadOnlySpan<char> fields_2;
            ReadOnlySpan<char> fields_3;
            ReadOnlySpan<char> fields_4;
            ReadOnlySpan<char> fields_5;
            ReadOnlySpan<char> fields_6;
            line.Split_to_spans(',', out fields_0, out fields_1, out fields_2, out fields_3, out fields_4, out fields_5, out fields_6);

            bundle.id = fields_0.ToInt();
            bundle.name = fields_1.ToString();
            bundle.crc = (uint)fields_2.ToULong();
            bundle.size = fields_3.ToULong();
            if (fields_4.IsEmpty)
            {
                bundle.assets = Utility.IntArrayEmpty;
            }
            else
            {
                bundle.assets = fields_4.Split_to_IntArrayEx('|');
            }

            
            int dep_id = fields_5.ToInt();
            if (dep_id >= 0 && dep_id < dep_bundles.Count)
            {
                bundle.deps = dep_bundles[dep_id];
            }
            else
            {
                Logger.I("read bundles error!");
                bundle.deps = Utility.IntArrayEmpty;
            }

            int resMode = fields_6.ToInt();
            bundle.resMode = resMode;
            
            nameWithBundles[bundle.name] = bundle;
            bundles.Add(bundle);
        }

        private void ReadPath(int dir, ReadOnlySpan<char> asset_name)
        {
            if (dir >= 0 && dir < directories.Count)
            {
                sb.Clear();
                sb.Append(directories[dir]);
                sb.Append("/");
                // 因为目前Unity版本的C#不支持加入readonlyspan（官方已支持）；所以暂时如此
                // for (int i = 0; i < asset_name.Length; ++i)
                // {
                //     sb.Append(asset_name[i]);
                // }
                sb.Append(asset_name);
                allAssetPaths.Add(sb.ToString());
            }
            else
            {
                var file = asset_name.ToString();
                allAssetPaths.Add(file);
            }
        }
        
        private void ReadAsset(ReadOnlySpan<char> line)
        {
            // 0,0/BingoWar-UI-Default.shader,0,1
            var asset = new AssetInfo();

            ReadOnlySpan<char> fields_0; // asset id
            ReadOnlySpan<char> fields_1; // asset path
            ReadOnlySpan<char> fields_2; // asset 所属的bundle id
            ReadOnlySpan<char> fields_3; // bundles 的依赖

            // 这里组合一下Asset的path。asset path里面分两段：dir目录id + asset name            
            ReadOnlySpan<char> fields_1_0;    
            ReadOnlySpan<char> fields_1_1;
            var fields = line.Split_to_spans(',', out fields_0, out fields_1, out fields_2, out fields_3);

            if (fields_1.Split_to_spanspan('/', out fields_1_0, out fields_1_1))
            {
                ReadPath(fields_1_0.ToInt(), fields_1_1);
            }
            else
            {
                Logger.I("read path error!");
            }
            
            asset.id = fields_0.ToInt();
            asset.bundle = fields_2.ToInt();
            
            // int bundles_id = fields_3.ToInt();
            // if (bundles_id >= 0 && bundles_id < dep_bundles.Count)
            // {
            //     asset.bundles = dep_bundles[bundles_id];
            // }
            // else
            // {
            //     Logger.I("read bundles error!");
            //     asset.bundles = Utility.IntArrayEmpty;
            // }
            
            assets.Add(asset);
            var assetPath = allAssetPaths[asset.id];
            pathWithAssets[assetPath] = assets.Count() - 1;//asset;
            
            if (onReadAsset != null)
            {
                onReadAsset(assetPath);
            }
        }

        public static string GetVersionFile(string name)
        {
            return $"{name}.version";
        }

        public BundleInfo GetBundle(string assetBundleName)
        {
            nameWithBundles.TryGetValue(assetBundleName, out var bundle);
            return bundle;
        }

        public string GetBundleNameAppendHash(string nameWithoutHash)
        {
            var info = bundles.Find(b => b.name.StartsWith(nameWithoutHash));
            if (info != null)
                return info.name;
            return string.Empty;
        }

        public bool ContainsBundle(string assetBundleName)
        {
            return nameWithBundles.ContainsKey(assetBundleName);
        }
        
        public BundleInfo GetBundle(int bundleId)
        {
            if (bundleId >= 0 && bundleId < bundles.Count)
            {
                return bundles[bundleId];
            }

            return null;
        }

        public bool GetAsset(string path, out AssetInfo asset)
        {
            int index = -1;
            if (pathWithAssets.TryGetValue(path, out index))
            {
                if (index >= 0 && index < assets.Count)
                {
                    asset = assets[index];
                    return true;
                }
                else
                {
                    Log.Error("GetAsset error!! out of range!!! {0}/{1}", index, assets.Count);
                }
            }

            asset.id = -1;
            asset.bundle = -1;
            return false;
        }

        public void SetAllAssetPaths(IEnumerable<string> assetPaths)
        {
            allAssetPaths.Clear();
            allAssetPaths.AddRange(assetPaths);
        }

        // public BundleInfo[] GetBundles(AssetInfo info)
        // {
        //     return Array.ConvertAll(info.bundles, GetBundle);
        // }

        public BundleInfo[] GetDependencies(BundleInfo info)
        {
            return Array.ConvertAll(info.deps, GetBundle);
        }

        public int GetAllBundlsSize()
        {
            ulong size = 0;
            foreach (var b in bundles)
            {
                size += b.size;
            }

            return (int)size;
        }
    }
}





