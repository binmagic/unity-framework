#define BUILTIN_BUILD
#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using GameFramework;
using UnityEditor;
using UnityEngine;

namespace VEngine.Editor
{
    public class Manifest : ScriptableObject
    {
        /// <summary>
        ///     版本中的所有自定义分组
        /// </summary>
        [Tooltip("所有自定分组")] public List<Group> groups = new List<Group>();

        public ulong size;
        public Settings settings;
        public BuildAssetBundleOptions buildAssetBundleOptions = BuildAssetBundleOptions.ChunkBasedCompression;
        private readonly List<Group> rawGroups = new List<Group>();
        private const string AtlasPath = "Assets/Main/Atlas";

        // 此函数给编辑用，譬如显示Groups窗口之类的。
        public Dictionary<string, Asset> GetAssets()
        {
            var assets = new Dictionary<string, Asset>();
            foreach (var group in groups)
            foreach (var asset in group.assets)
            {
                if (!assets.TryGetValue(asset.path, out var value))
                {
                    if (asset.parentGroup == null)
                    {
                        asset.parentGroup = group;
                    }
                    assets[asset.path] = asset;
                }
                else
                {
                    Logger.W("can't add {0} with {1} already exist in {2}", asset.path, @group.name,
                        value.parentGroup.name);
                }
            }
            return assets;
        }

        /// <summary>
        ///     移除分组
        /// </summary>
        /// <param name="group"></param>
        /// <returns></returns>
        public void RemoveGroup(Group group)
        {
            group.assets.Clear();
            groups.Remove(group);
            var path = AssetDatabase.GetAssetPath(group);
            AssetDatabase.DeleteAsset(path);
        }

        public Group GetOrCreateGroup(string groupName)
        {
            var assetGroup = groups.Find(group => group.name == groupName);
            if (assetGroup == null)
            {
                assetGroup = AddGroup(groupName, false, false);
            }
            return assetGroup;
        }

        /// <summary>
        ///     添加分组
        /// </summary>
        /// <param name="groupType"></param>
        /// <param name="raw"></param>
        /// <param name="autoNewPath"></param>
        /// <returns></returns>
        public Group AddGroup(string groupType, bool raw = false, bool autoNewPath = true)
        {
            var dir = Settings.GetGroupsDataPath(name);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
            var path = Settings.GetGroupsDataPath($"{name}/{groupType}.asset");
            if (autoNewPath && File.Exists(path))
            {
                var findAssets = AssetDatabase.FindAssets($"t:Group {groupType}", new[]
                {
                    dir
                });
                path = Settings.GetGroupsDataPath($"{name}/{groupType}{findAssets.Length}.asset");
            }

            var assetGroup = EditorUtility.GetOrCreateAsset<Group>(path);
            assetGroup.manifest = this;
            assetGroup.bundleMode = raw ? BundleMode.PackByRaw : BundleMode.PackByEntry;
            groups.Add(assetGroup);
            return assetGroup;
        }

        /// <summary>
        ///     添加一个要打包的 entry 到设置中
        /// </summary>
        /// <param name="file"></param>
        /// <param name="group"></param>
        /// <param name="label"></param>
        /// ///
        /// <returns></returns>
        public Asset AddAsset(string file, Group group, string label = null)
        {
            var asset = Asset.Create(file, group, label);
            group.assets.Add(asset);
            return asset;
        }

        /// <summary>
        ///     从设置中移除
        /// </summary>
        /// <param name="asset"></param>
        public void RemoveAsset(Asset asset)
        {
            asset.parentGroup.assets.Remove(asset);
        }

        public Build GetCurrentBuild()
        {
            //var build = CreateInstance<Build>();
            var manifestPath = $"{EditorUtility.PlatformBuildPath}/{name}.json";
            return GetBuild(manifestPath);
            // if (!File.Exists(manifestPath))
            // {
            //     return build;
            // }
            // var json = File.ReadAllText(manifestPath);
            // EditorJsonUtility.FromJsonOverwrite(json, build);
            // return build;
        }

        static public Build GetBuild(string path)
        {
            var build = CreateInstance<Build>();
            if (!File.Exists(path))
            {
                Log.Error("GetBuild - file not found. {0}", path);
                return build;
            }
            
            Debug.LogFormat("Manifest - GetBuild : {0}", path);
            var json = File.ReadAllText(path);
            EditorJsonUtility.FromJsonOverwrite(json, build);
            return build;
        }

        public static bool CreateBundles(Dictionary<string, Asset> assets, List<BundleBuild> bundleBuilds, Dictionary<string, string> spriteBundle)
        {
            var nameWithBundles = new Dictionary<string, BundleBuild>();
            var assetWithBundles = new Dictionary<string, string>();
            
            // 变体的Asset
            List<Asset> variantAsset = new List<Asset>();
            
            Log.Debug("assets count: {0}", assets.Count);
            foreach (var item in assets)
            {
                var asset = item.Value;
                if (asset.isFolder)
                {
                    Log.Debug("assets folder: {0}", asset.path);
                    continue;
                }
                
                // sprite 打包到 altas 的bundle中
                if (spriteBundle.TryGetValue(asset.path, out var packBundle))
                {
                    asset.bundle = packBundle;
                }
                else
                {
                    // 计算每个asset的Bundle名字
                    string newBundle = asset.PackWithBundleMode();
                    if (newBundle != asset.bundle)
                    {
                        newBundle = asset.PackWithBundleMode();
                        Log.Info("bundle changed: {0} -> {1},,,{2}: {3}", asset.bundle, newBundle, asset.index, asset.path);
                        asset.bundle = newBundle;
                    }
                    
                    // 如果是变体和源要打到一起的情况
                    if (asset.GetBundleMode() == BundleMode.PackBySourcePrefabOrFile ||
                        asset.GetBundleMode() == BundleMode.PackBySourcePrefabOrDirectory)
                    {
                        variantAsset.Add(asset);
                    }
                }

                // // 组织新的bundle
                // if (!assetWithBundles.TryGetValue(asset.path, out var bundleName))
                // {
                //     assetWithBundles[asset.path] = asset.bundle;
                //     if (!nameWithBundles.TryGetValue(asset.bundle, out var bundle))
                //     {
                //         bundle = new BundleBuild
                //         {
                //             name = asset.bundle
                //         };
                //         bundleBuilds.Add(bundle);
                //         nameWithBundles.Add(bundle.name, bundle);
                //     }
                //
                //     bundle.assets.Add(new AssetBuild
                //     {
                //         path = asset.path,
                //         metaPath = asset.metaPath,
                //         dependencies = asset.dependencies,
                //         bundle = asset.bundle
                //     });
                //     
                //     // 通过asset找到所属的group。然后将bundles记录到group里
                //     string bundlename = asset.bundle;
                //
                //     if (!asset.parentGroup.allBundleNames.Contains(bundlename))
                //     {
                //         asset.parentGroup.allBundleNames.Add(bundlename);
                //     }
                //
                //     bundle.resMode = asset.parentGroup.resMode;
                // }
                // else
                // {
                //     Logger.W("Asset {0} already exist with bundle {1} with newGroup {2}.", asset.path,
                //         bundleName, asset.parentGroup.name);
                // }
            }

            //
            // 如果有变体和源要打到一起的情况
            if (variantAsset.Count > 0)
            {
                var builder = new StringBuilder();
                // 如果有变体和源要打到一起的情况；先获取源
                foreach (var item in variantAsset)
                {
                    var asset = item;
                    string prefab = GetPrefabSourcePath(asset.path);
                    if (prefab != null)
                    {
                        Asset srcAsset;
                        if (assets.TryGetValue(prefab, out srcAsset))
                        {
                            builder.AppendLine($"{asset.path} : \n    {asset.bundle} -> {srcAsset.bundle}\n");

                            // 直接把当前的prefab的ab设置成源prefab的ab
                            asset.bundle = srcAsset.bundle;
                            continue;
                        }
                    }
                    
                    builder.AppendLine($"{asset.path} : \n    {asset.bundle}  **** not move!!\n");
                }

                File.WriteAllText(Settings.GetBuildPath($"variant_prefab.txt"), builder.ToString());
            }
            
            //
            // 最后组织Unity BUNDLE
            //
            foreach (var item in assets)
            {
                var asset = item.Value;
                if (asset.isFolder)
                {
                    Log.Debug("assets folder: {0}", asset.path);
                    continue;
                }

                // 组织新的bundle
                if (!assetWithBundles.TryGetValue(asset.path, out var bundleName))
                {
                    assetWithBundles[asset.path] = asset.bundle;
                    if (!nameWithBundles.TryGetValue(asset.bundle, out var bundle))
                    {
                        bundle = new BundleBuild
                        {
                            name = asset.bundle
                        };
                        bundleBuilds.Add(bundle);
                        nameWithBundles.Add(bundle.name, bundle);
                    }

                    bundle.assets.Add(new AssetBuild
                    {
                        path = asset.path,
                        metaPath = asset.metaPath,
                        dependencies = asset.dependencies,
                        bundle = asset.bundle
                    });
                    
                    // 通过asset找到所属的group。然后将bundles记录到group里
                    string bundlename = asset.bundle;

                    if (!asset.parentGroup.allBundleNames.Contains(bundlename))
                    {
                        asset.parentGroup.allBundleNames.Add(bundlename);
                    }

                    bundle.resMode = asset.parentGroup.resMode;
                }
                else
                {
                    Logger.W("Asset {0} already exist with bundle {1} with newGroup {2}.", asset.path,
                        bundleName, asset.parentGroup.name);
                }
            }
            
            // 通过自定义构建脚本，确保文件顺序一致，并使用特定的构建选项，你可以尽量减少每次构建AssetBundle时MD5值的变化。
            foreach (var item in bundleBuilds)
            {
                // 使用Sort方法和Lambda表达式进行排序
                item.assets.Sort((a, b) => string.Compare(a.path, b.path, StringComparison.Ordinal));
            }

            Logger.I("CreateBundles {0}", bundleBuilds.Count);
            return true;
        }

        // 生成json，version等文件用的
        public void AfterBuild(List<BundleBuild> bundles)
        {
            // 我们每次都是重新Build一个完整的打包，所以这里不存在增量的情况，所以这里也就无法读取到上一次的打包配置
            // 这个地方理论上就是新建一个Build，表示每次构建的数据
            // FIMXE: 这里会获取到数据吗？
            var build = GetCurrentBuild();
            build.name = name.ToLower();
            var buildBundles = build.GetBundles();
            
            Log.Info("AfterBuild - version = {0}", build.version);

            size = 0UL;
            var newFiles = new List<string>();
            var newSize = 0UL;
            foreach (var bundle in bundles)
            {
                size += bundle.size;
                if (!buildBundles.TryGetValue(bundle.name, out var value) ||
                    value.nameWithAppendHash != bundle.nameWithAppendHash)
                {
                    newFiles.Add(bundle.nameWithAppendHash);
                    newSize += bundle.size;
                }
            }

            var delFiles = new List<string>();
            var currBundles = bundles.ToDictionary(b => b.name);
            foreach (var bundle in buildBundles.Values)
            {
                if (!currBundles.TryGetValue(bundle.name, out var value))
                    delFiles.Add(bundle.nameWithAppendHash);
            }

            if (newFiles.Count > 0 || delFiles.Count > 0)
            {
                build.version++;
                Log.Info("AfterBuild had changed - version++ = {0}", build.version);
            }
            
            var pathWithAssets = new Dictionary<string, AssetBuild>();
            for (var index = 0; index < bundles.Count; index++)
            {
                var bundle = bundles[index];
                if (string.IsNullOrEmpty(bundle.nameWithAppendHash))
                {
                    Logger.W("Invalid bundle： {0} with assets: {1}", bundle.name,
                        string.Join("\n", bundle.assets.ConvertAll(o => o.path).ToArray()));
                    bundles.RemoveAt(index);
                    index--;
                    continue;
                }

                bundle.AfterBuild();
                foreach (var asset in bundle.assets)
                {
                    asset.bundles = bundle.deps;
                    pathWithAssets[asset.path] = asset;
                }
            }
            build.groups = groups.ConvertAll(ConverterGroup(pathWithAssets));
            build.bundles = bundles;
            build.newFiles = newFiles;
            build.size = EditorUtility.FormatBytes(newSize);
            
            var target = build.CreateManifest();
            Logger.I("Build Bundles with {0}({1}) files with version {2}.", newFiles.Count, build.size, build.version);

            string json = "";
            try
            {
                json = EditorJsonUtility.ToJson(build, false);
            }
            catch (Exception e)
            {
                Logger.I("SaveJsonError: {0}", e.Message);
            }
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}.json", json);
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_v{build.version}.json", json);
            
            // 同时写一个极简版本的文件，方便查看；json用来详细调试
            var sampletxt = build.ToSimpleReadableString();
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}.txt", sampletxt);
            
            // 压缩Manifst
            var manifestSmall = build.name.ToLower() + ManifestFile.CompressPosfix;
            var manifestSmallSavePath = Settings.GetBuildPath(manifestSmall);
            if (File.Exists(manifestSmallSavePath))
                File.Delete(manifestSmallSavePath);
            
            // using (var zip = ZipFile.Create(manifestSmallSavePath))
            // {
            //     zip.BeginUpdate();
            //     zip.Add(Settings.GetBuildPath(build.name.ToLower()), build.name.ToLower());
            //     zip.CommitUpdate();
            // }
            
            // 使用 C# 自带的Compression!!将清单文件压缩一下，使用C#压缩的文件会大15KB左右
            using (ZipArchive zipArchive = System.IO.Compression.ZipFile.Open(manifestSmallSavePath, ZipArchiveMode.Create))
            {
                // 3 = SmallestSize
                zipArchive.CreateEntryFromFile(Settings.GetBuildPath(build.name.ToLower()), build.name.ToLower(), System.IO.Compression.CompressionLevel.Optimal);
            }
            
            if (File.Exists(manifestSmallSavePath + $"_v{build.version}"))
                File.Delete(manifestSmallSavePath + $"_v{build.version}");
            File.Copy(manifestSmallSavePath, manifestSmallSavePath + $"_v{build.version}", true);
        }

        private static Converter<Group, GroupBuild> ConverterGroup(Dictionary<string, AssetBuild> pathWithAssets)
        {
            return input =>
            {
                var group = new GroupBuild();
                group.name = input.name;
                var set = new HashSet<string>();
                foreach (var asset in input.assets)
                {
                    if (asset.isFolder)
                    {
                        foreach (var child in asset.GetChildren())
                        {
                            GetBundles(pathWithAssets, child, set);
                        }
                        continue;
                    }

                    GetBundles(pathWithAssets, asset.path, set);
                }

                group.bundles = set.ToArray();
                return group;
            };
        }

        private static void GetBundles(Dictionary<string, AssetBuild> pathWithAssets, string asset, HashSet<string> set)
        {
            if (pathWithAssets.TryGetValue(asset, out var value))
            {
                set.Add(value.bundle);
                foreach (var bundle in value.bundles)
                {
                    set.Add(bundle);
                }
            }
        }

        public void Save(bool clear = false)
        {
            for (var index = 0; index < groups.Count; index++)
            {
                var group = groups[index];
                if (group == null)
                {
                    groups.RemoveAt(index);
                    index--;
                    continue;
                }

                UnityEditor.EditorUtility.SetDirty(group);
            }

            if (clear)
            {
                size = 0;
                var build = GetCurrentBuild();
                build.Clear();
            }

            EditorUtility.SaveAsset(this);
        }

        /// <summary>
        ///     处理依赖。
        /// </summary>
        public Dictionary<string, List<Asset>> AnalysisDependencies(Dictionary<string, Asset> pathWithAssets)
        {
            var dependencyWithAssets = new Dictionary<string, List<Asset>>();
            UnityEditor.EditorUtility.DisplayProgressBar("", "Analysis dependencies begin...", 0);
            // for (var i = 0; i < pathWithAssets.Count; i++)
            // {
            //     var asset = assets[i];
            
            foreach (var item in pathWithAssets)
            {
                var asset = item.Value;
                var dependencies = asset.GetDependencies();
#if UNITY_EDITOR
                //EditorUtility.DisplayProgressBar("Analysis dependencies...", asset.path, i, assets.Count);
#endif
                foreach (var dependency in dependencies)
                    // 子节点以外的没有主动打包的依赖
                {
                    if (!pathWithAssets.ContainsKey(dependency))
                    {
                        if (!dependencyWithAssets.TryGetValue(dependency, out var value))
                        {
                            value = new List<Asset>();
                            dependencyWithAssets.Add(dependency, value);
                        }

                        value.Add(asset);
                    }
                }
            }
            
            UnityEditor.EditorUtility.DisplayProgressBar("", "Analysis dependencies end...", 0);
            
            // 清理进度条
            EditorUtility.ClearProgressBar();
            return dependencyWithAssets;
        }

        // 单一节点的暂时也不处理了，使用Strip机制挺好
        public void ProcessSingleDependencies(Dictionary<string, List<Asset>> dependencyWithAssets)
        {
            var savePath = Settings.GetBuildPath(name + "_depends_asset.txt");
            
            using (var writer = new StreamWriter(File.OpenWrite(savePath)))
            {
                writer.WriteLine("++++ Single DependencyWithAssets");
                List<string> keys = new List<string>();
                foreach (var value in dependencyWithAssets)
                {
                    // 如果只是单一依赖的话，那就不用特意处理这个Asset，当其不存在即可，
                    // Unity在打包的时候，会自动把这个依赖打入到其依赖的Bundle内
                    if (value.Value.Count == 1)
                    {
                        writer.WriteLine("    {0}", value.Key);
                        writer.WriteLine("     |- {0}", value.Value[0].path);
                    }
                }

                writer.WriteLine("++++ DependencyWithAssets");
                foreach (var value in dependencyWithAssets)
                {
                    writer.WriteLine("    {0}", value.Key);
                    for (int i = 0; i < value.Value.Count; ++i)
                    {
                        writer.WriteLine("      |- [{0}]: {1}", i, value.Value[i].path);
                    }
                }
            }

#if false
            Debug.LogFormat("++++ DependencyWithAssets");
            List<string> keys = new List<string>();
            foreach (var value in dependencyWithAssets)
            {
                Debug.LogFormat("    {0}", value.Key);
                for (int i = 0; i < value.Value.Count; ++i)
                {
                    Debug.LogFormat("      {0}: {1}", i, value.Value[i].path);
                }

                if (value.Value.Count == 0)
                {
                    keys.Add(value.Key);
                }

                // 如果只是单一依赖的话，那就不用特意处理这个Asset，当其不存在即可，
                // Unity在打包的时候，会自动把这个依赖打入到其依赖的Bundle内
                if (value.Value.Count == 1)
                {
                    Asset dep = value.Value[0];
                    string path = value.Key;
                    keys.Add(path);
                    
                    // // 添加一个Asset
                    // if (!pathWithAssets.TryGetValue(path, out var a))
                    // {
                    //     a = Asset.Create(path, dep.parentGroup, dep.label, dep.rootPath);
                    //     a.bundle = dep.bundle;
                    //     
                    //     pathWithAssets.Add(path, a);
                    // }
                    //
                    // a.readOnly = true;
                    // assets.Add(a);
                }
            }

            Debug.LogFormat("++++ Remove DependencyWithAssets");
            foreach (var k in keys)
            {
                Debug.LogFormat("    {0}", k);
                dependencyWithAssets.Remove(k);
            }
#endif
        }
            
        // 从变体prefab获取到源prefab
        static string GetPrefabSourcePath(string variantPrefab)
        {
            // 加载Prefab变体
            GameObject prefabVariant = AssetDatabase.LoadAssetAtPath<GameObject>(variantPrefab);
            if (prefabVariant != null)
            {
                // 如果该Prefab资产是一个变体
                if (!PrefabUtility.IsPartOfVariantPrefab(prefabVariant))
                {
                    return null;
                }
                    
                // 获取Prefab变体的源Prefab
                GameObject sourcePrefab = PrefabUtility.GetCorrespondingObjectFromSource(prefabVariant);
                if (sourcePrefab != null)
                {
                    // 获取源Prefab的路径
                    string sourcePrefabPath = AssetDatabase.GetAssetPath(sourcePrefab);
                    return sourcePrefabPath;
                }
            }

            return null;
        }
        
        // // 处理技术的prefab；有些目录的变体prefab要打包到源prefab的ab内
        // // 否则文件会多
        // private void AnalysisTechPrefab(Dictionary<string, Asset> pathWithAssets)
        // {
        //     var builder = new StringBuilder();
        //     var spriteBundle = new Dictionary<string, string>();
        //     
        //     // 这里注意，我们把spriteatlas找出来，然后把spriteatlas包含的所有sprite都打到atlas所在的bundle中
        //     // 然后sprite对应的纹理图片注意不要打包，
        //     // 这样的处理是就是避免出现图片包含两次的情况（大图和小图有两份）
        //     foreach (var item in pathWithAssets)
        //     {
        //         var asset = item.Value;
        //         if (asset.path.Contains("Assets/Main/Prefabs/PVELevel") ||
        //             asset.path.Contains("Assets/Main/Prefabs/Building"))
        //         {
        //             //PrefabUtility.GetPrefabAssetType()
        //             builder.AppendLine($"VariantPrefab {asset.path} - [{asset.bundle}]");
        //
        //             string prefab = GetPrefabSourcePath(asset.path);
        //             if (prefab != null)
        //             {
        //                 Asset srcAsset;
        //                 if (pathWithAssets.TryGetValue(prefab, out srcAsset))
        //                 {
        //                     builder.AppendLine($"  {srcAsset.path}  -  {srcAsset.bundle}");
        //                     // 直接把当前的prefab的ab设置成源prefab的ab
        //                     asset.bundle = srcAsset.bundle;
        //                     continue;
        //                 }
        //             }
        //             
        //             builder.AppendLine($"  *** no source prefab!");
        //         }
        //     }
        //     
        //     File.WriteAllText(Settings.GetBuildPath($"{name}_techprefab.txt"), builder.ToString());
        //     return;
        // }

        private Dictionary<string, string> AnalysisSprites(Dictionary<string, Asset> pathWithAssets)
        {
            var builder = new StringBuilder();
            var spriteBundle = new Dictionary<string, string>();
            
            // 这里注意，我们把spriteatlas找出来，然后把spriteatlas包含的所有sprite都打到atlas所在的bundle中
            // 然后sprite对应的纹理图片注意不要打包，
            // 这样的处理是就是避免出现图片包含两次的情况（大图和小图有两份）
            foreach (var item in pathWithAssets)
            {
                var asset = item.Value;
                if (asset.path.EndsWith(".spriteatlas", StringComparison.OrdinalIgnoreCase))
                {
                    builder.AppendLine($"Atlas {asset.path} - [{asset.bundle}]");
                    
                    foreach (var j in asset.dependencies)
                    {
                        if (pathWithAssets.TryGetValue(j, out var dep))
                        {
                            builder.AppendLine($"  Sprite {dep.path}  -  {asset.bundle}");
                            
                            if (!spriteBundle.ContainsKey(dep.path))
                            {
                                spriteBundle.Add(dep.path, asset.bundle);
                            }
                        }
                    }
                }
            }
            
            File.WriteAllText(Settings.GetBuildPath($"{name}_group_spriteatlas.txt"), builder.ToString());
            return spriteBundle;
        }

        /// <summary>
        ///     对公共依赖进行自动分组
        /// </summary>
        public void AutoGrouping(Dictionary<string, Asset> pathWithAssets,
            Dictionary<string, List<Asset>> dependencyWithAssets)
        {
            if (dependencyWithAssets.Count > 0)
            {
                var auto = GetOrCreateGroup("Auto");
                auto.bundleMode = BundleMode.PackByDirectory;
                auto.manifest = this;
                
                var dependencies = new List<string>(dependencyWithAssets.Keys);
                dependencies.Sort();
                var builder = new StringBuilder();
                
                UnityEditor.EditorUtility.DisplayProgressBar("", "Analysis grouping begin...", 0);
                for (int index = 0, max = dependencies.Count; index < max; index++)
                {
                    var path = dependencies[index];
#if UNITY_EDITOR
                    //EditorUtility.DisplayProgressBar("Auto grouping...", path, index, max);
#endif
                    if (dependencyWithAssets.TryGetValue(path, out var value))
                    {
                        // ---- 资源的交叉引用 ----
                        if (value.Count > 1)
                        {
                            var set = new List<string>();
                            foreach (var item in value)
                            {
                                if (!set.Contains(item.bundle))
                                {
                                    set.Add(item.bundle);
                                }
                            }

                            set.Sort();
                            builder.AppendLine(path);
                            foreach (var bundle in set)
                            {
                                builder.AppendLine($" - {bundle}");
                            }
                        }

                        // ---- 
                        if (!pathWithAssets.TryGetValue(path, out var asset))
                        {
                            //Log.Debug("Auto Asset Create - {0}", path);
                            
                            asset = AddAsset(path, auto);
                            pathWithAssets[path] = asset;
                        }
                    }
                    else
                    {
                        Logger.I("Dependency not found {0}", path);
                    }
                }

                UnityEditor.EditorUtility.DisplayProgressBar("", "Analysis grouping end...", 0);
                
                var file = $"{EditorUtility.PlatformBuildPath}/auto_assets_dependencies_for_{name.ToLower()}.txt";
                File.WriteAllText(file, builder.ToString());
                
                UnityEditor.EditorUtility.DisplayProgressBar("asset_dependencies,,,", file, 0);
                EditorUtility.ClearProgressBar();
            }
        }

        /// <summary>
        ///     采集规则中的所有资源
        /// </summary>
        public bool CollectAssets(Dictionary<string, Asset> pathWithAssets)
        {
            rawGroups.Clear();
            
            // 采集分组中的资源 
            // 根据分组的类型：譬如文件夹分组，单文件分组
            for (var groupIndex = 0; groupIndex < groups.Count; groupIndex++)
            {
                var group = groups[groupIndex];
                if (group == null)
                {
                    groups.RemoveAt(groupIndex);
                    groupIndex--;
                    continue;
                }
                
                // 每次重新打包的时候都清除掉上一次的bundles
                group.allBundleNames.Clear();

                if (group.bundleMode == BundleMode.PackByRaw)
                {
                    rawGroups.Add(group);
                    continue;
                }

                if (group.name.Contains("Auto"))
                {
                    group.assets.Clear();
                    continue;
                }

                // 自动整理的组会在计算完dependency之后处理
                if (group.autoStrip)
                {
                    continue;
                }
                
                group.manifest = this;

                EditorUtility.DisplayProgressBar("Collect assets...", group.name, groupIndex, groups.Count);
                for (var assetIndex = 0; assetIndex < group.assets.Count; assetIndex++)
                {
                    // 跳过自动分组
                    var asset = group.assets[assetIndex];
                    // 跳过不存在的资源
                    if (!File.Exists(asset.path) && !Directory.Exists(asset.path))
                    {
                        group.assets.RemoveAt(assetIndex);
                        assetIndex--;
                        continue;
                    }

                    // 文件夹不用打包，只采集子文件
                    CollectAsset(asset, group, pathWithAssets);
                }
            }

            // 清理进度条
            EditorUtility.ClearProgressBar();
            return true;
        }

        public void CollectAutoAssets(Dictionary<string, Asset> pathWithAssets, Dictionary<string, List<Asset>> dependencyWithAssets)
        {
            // 采集分组中的资源 
            for (var groupIndex = 0; groupIndex < groups.Count; groupIndex++)
            {
                var group = groups[groupIndex];
                
                // 自动整理的组会在计算完dependency之后处理
                if (group.autoStrip == false)
                {
                    continue;
                }

                group.manifest = this;

                EditorUtility.DisplayProgressBar("Collect Auto assets...", group.name, groupIndex, groups.Count);
                for (var assetIndex = 0; assetIndex < group.assets.Count; assetIndex++)
                {
                    // 跳过自动分组
                    var asset = group.assets[assetIndex];
                    // 跳过不存在的资源
                    if (!File.Exists(asset.path) && !Directory.Exists(asset.path))
                    {
                        group.assets.RemoveAt(assetIndex);
                        assetIndex--;
                        continue;
                    }
                    
                    // 文件夹不用打包，只采集子文件
                    CollectAutoAsset(asset, group, pathWithAssets, dependencyWithAssets);
                }
            }

            // 清理进度条
            EditorUtility.ClearProgressBar();
            
            
            /////////////////////////////////////////////////////////////////
            var savePath = Settings.GetBuildPath(name + "_depends_asset.txt");
            using (var writer = new StreamWriter(File.Open(savePath, FileMode.Append)))
            {
                writer.WriteLine("\n\n\n++++ Final DependencyWithAssets");
                foreach (var value in dependencyWithAssets)
                {
                    writer.WriteLine("    {0}", value.Key);
                    for (int i = 0; i < value.Value.Count; ++i)
                    {
                        writer.WriteLine("      |- {0}", value.Value[i].path);
                    }
                }
            }
            
            // Debug.LogFormat("++++ Final DependencyWithAssets");
            // foreach (var value in dependencyWithAssets)
            // {
            //     Debug.LogFormat("    {0}", value.Key);
            //     for (int i = 0; i < value.Value.Count; ++i)
            //     {
            //         Debug.LogFormat("      |- {0}", value.Value[i].path);
            //     }
            // }

            return;
        }

        // 核心函数，这个函数里统计了bundle，并且返回bundle的列表
        // pathWithAssets，所有的asset列表
        public bool BuildGroups(
            Dictionary<string, Asset> pathWithAssets,
            List<BundleBuild> bundleBuilds)
        {
            Asset.count = 0;

            // 某个asset依赖其他asset的列表
            Dictionary<string, List<Asset>> dependencyWithAssets = new Dictionary<string, List<Asset>>();
            
            // 收集所有必须打包到bundle中的asset（用户设置的DefaultSetting里面的项，同时没有勾选autostrip）
            // 这个一般是prefab目录，是肯定要打入到Bundle中的
            CollectAssets(pathWithAssets);

            // 把assets里面的每个asset的依赖找出来，通过结果返回，保存在dependencyWithAssets中
            dependencyWithAssets = AnalysisDependencies(pathWithAssets);
            
            // 把单一依赖的文件，进行整合，特定目录
            ProcessSingleDependencies(dependencyWithAssets);
            
            // 进行自动整理资源的处理（设置为autostrip）
            // 设置autostrip的选项，就是扫描分组，但是只把用到的文件放到分组的bundle中
            // 譬如：设定了A文件夹打一个bundle，未设置分组的时候，是把A文件夹里所有的文件打个bundle
            //       但是设置了分组的autostrip之后，他会把A文件夹里真正使用的文件打进这个bundle
            //       如何判断是否被使用了呢？就是上面的AnalysisDependencies，凡是被依赖的文件，就是被使用的
            // 简单来讲，就是反向扫描一下，如果这个分组被设置为autostrip了，那么就要扫描这个分组内每一个文件，如果这个文件没有被任何人使用，那么就strip掉！
            //
            // 但是，prefab文件夹不要使用autostrip，因为prefab是最终根源。
            // 有可能是在代码中引用的，也不要设置autostrip，否则这里也扫不到了
            //
            // 这个函数是：把设置为autostrip的项建立到合适的bundle中，然后减少dependencyWithAssets的数量。
            // 因为dependencyWithAssets这个列表中的最终的项会被打包到auto中。。。而auto是不可控的
            CollectAutoAssets(pathWithAssets, dependencyWithAssets);
            
            // 所有未被设置bundle的文件，自动打入到auto中；即剩余的dependencyWithAssets
            AutoGrouping(pathWithAssets, dependencyWithAssets);

            // 把sprite和atlas打到一个bundle里。
            var spriteBundle = AnalysisSprites(pathWithAssets);

            // 通过所有的asset信息，建立起最终要打包的bundle信息
            CreateBundles(pathWithAssets, bundleBuilds, spriteBundle);
            
            // 不打包的文件，我们没有用到！
            //rawBundleBuilds = BuildRaws(assets, bundleBuilds);

            return true;
        }

        private void CollectAsset(Asset asset, Group parentGroup, Dictionary<string, Asset> pathWithAssets)
        {
            if (asset.isFolder)
            {
                List<string> assets = asset.GetChildren();
                foreach (var child in assets)
                {
                    if (!pathWithAssets.TryGetValue(child, out var value))
                    {
                        value = Asset.Create(child, parentGroup, asset.label, asset.path, asset.bundleMode);
                        pathWithAssets.Add(value.path, value);
                        //collectAssets.Add(value);
                    }
                    else
                    {
                        Log.Debug("Asset Already Exist d- {0},,{1}", child, value.bundle);   
                    }
                }
            }
            else
            {
                if (!pathWithAssets.TryGetValue(asset.path, out var value))
                {
                    // 缓存中没有
                    value = Asset.Create(asset.path, parentGroup, asset.label, null, asset.bundleMode);
                    pathWithAssets.Add(value.path, value);
                    
//                    collectAssets.Add(value);
                }
                else
                {
                    Log.Debug("Asset Already Exist - {0}, {1}", asset.path, value.bundle);   
                }
                
            }
        }


        // auto asset也要加value.GetDependencies();否则auto的asset的依赖项会丢失
        private void CollectAutoAsset(Asset asset, Group parentGroup,
            IDictionary<string, Asset> pathWithAssets, Dictionary<string, List<Asset>> dependencyWithAssets)
        {
            if (asset.isFolder)
            {
                var childs = asset.GetChildren();
                foreach (var child in childs)
                {
                    // 如果依赖中没有的项，就放弃
                    if (!dependencyWithAssets.ContainsKey(child))
                    {
                        continue;
                    }
                    dependencyWithAssets.Remove(child);
                    
                    if (!pathWithAssets.TryGetValue(child, out var value))
                    {
                        value = Asset.Create(child, parentGroup, asset.label, asset.path, asset.bundleMode);
                        value.GetDependencies();
                        pathWithAssets.Add(value.path, value);
                        // collectAssets.Add(value);
                    }
                    else
                    {
                        Log.Debug("Asset Already Exist 2 - {0}", child);   
                    }

                }
            }
            else
            {
                // 如果依赖中没有的项，就放弃
                if (!dependencyWithAssets.ContainsKey(asset.path))
                {
                    return;
                }

                dependencyWithAssets.Remove(asset.path);
                
                if (!pathWithAssets.TryGetValue(asset.path, out var value))
                {
                    // 缓存中没有
                    value = Asset.Create(asset.path, parentGroup, asset.label, null, asset.bundleMode);
                    value.GetDependencies();
                    pathWithAssets.Add(value.path, value);
                    // collectAssets.Add(value);
                }
                else
                {
                    Log.Debug("Asset Already Exist 2 - {0}", asset.path);   
                }

                
            }
        }
        
        /// <summary>
        ///     创建 bundle 名字到 hash 名字之间的映射
        /// </summary>
        /// <param name="assetBundleManifest"></param>
        /// <param name="bundleBuilds"></param>
#if BUILTIN_BUILD
        public void CreateVersions(AssetBundleManifest assetBundleManifest, List<BundleBuild> bundleBuilds)
#else
        public void CreateVersions(CompatibilityAssetBundleManifest assetBundleManifest, List<BundleBuild> bundleBuilds)
#endif
        {
            BuildProcessInfo buildProcessInfo = new BuildProcessInfo();
            
            var nameWithBundles = new Dictionary<string, BundleBuild>();
            foreach (var bundleBuild in bundleBuilds)
            {
                nameWithBundles[bundleBuild.name] = bundleBuild;
            }
            if (assetBundleManifest != null)
            {
                StringBuilder sb = new StringBuilder();
                sb.AppendFormat("+++++++++++++ {0} +++++++++++++\n", assetBundleManifest.name);
                
                // 反向依赖（谁依赖我）
                Dictionary<string, HashSet<string>> res_depends = new Dictionary<string, HashSet<string>>();
                
                var assetBundles = assetBundleManifest.GetAllAssetBundles();
                foreach (var assetBundle in assetBundles)
                {
                    var originBundle = GetOriginBundle(assetBundle);
                    var fullPath2 = Path.Combine(VEngine.Editor.EditorUtility.PlatformBuildPath, originBundle);
                    if (originBundle.StartsWith("videos__"))
                    {
                        var re = AssetBundle.RecompressAssetBundleAsync(fullPath2, fullPath2, BuildCompression.Uncompressed);
                        while (!re.isDone)
                        {
                            int a = 1;
                        }

                        if (!re.success)
                        {
                            Logger.E($"video -> {originBundle} decompress error");
                        }
                    }

                    BuildScript.BundleEncode(assetBundle);
                    //Logger.I("CreateVersions Bundle : {0}", assetBundle);
                    sb.AppendFormat("[{0}]\n", assetBundle);
                    var deps = assetBundleManifest.GetAllDependencies(assetBundle);
                    if (deps.Length > 0)
                    {
                        foreach (var dep in deps)
                        {
                            HashSet<string> list;
                            if (!res_depends.TryGetValue(dep, out list))
                            {
                                list = new HashSet<string>();
                                res_depends.Add(dep, list);
                            }

                            list.Add(assetBundle);
                            sb.AppendFormat("  + {0}\n", dep);
                        }
                    }

                    if (nameWithBundles.TryGetValue(originBundle, out var bundle))
                    {
                        string nameWithAppendHash;
                        var md5 = System.Security.Cryptography.MD5.Create().ComputeHash(File.ReadAllBytes(Settings.GetBuildPath(assetBundle))).Aggregate("", (s, b) => s + b.ToString("x2"));
                        if (string.IsNullOrEmpty(settings.bundleExtension))
                        {
                            nameWithAppendHash = $"{assetBundle}_{md5}";
                        }
                        else
                        {
                            var extIndex = assetBundle.LastIndexOf(settings.bundleExtension);
                            nameWithAppendHash = $"{assetBundle.Substring(0, extIndex)}_{md5}{settings.bundleExtension}";
                        }

                        if (File.Exists(Settings.GetBuildPath(nameWithAppendHash)))
                        {
                            File.Delete(Settings.GetBuildPath(nameWithAppendHash));
                        }
                        File.Move(Settings.GetBuildPath(assetBundle), Settings.GetBuildPath(nameWithAppendHash));
                        bundle.nameWithAppendHash = nameWithAppendHash;
                        bundle.AfterBuild();

                        // 如果是不在包体的文件，需要记录一下
                        if (bundle.resMode != ResMode.Normal)
                        {
                            buildProcessInfo.downloadBundles.Add(nameWithAppendHash);
                            buildProcessInfo.downloadSize.Add(bundle.size);
                            Debug.LogFormat("++ {0}", nameWithAppendHash);
                        }
                        
                        bundle.deps = deps;
                    }
                    else
                    {
                        Logger.E("Bundle not exist: {0}", originBundle);
                        sb.AppendFormat("!!![ERROR] Bundle not exist: {0}\n", originBundle);
                    }
                }
                
                File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_depends.txt", sb.ToString());
                
                // 先把系统生成的文件Android.manifest复制保存一会，防止被覆盖
                File.Copy($"{EditorUtility.PlatformBuildPath}/{EditorUtility.GetPlatformName()}.manifest",
                    $"{EditorUtility.PlatformBuildPath}/{name}.manifest", true);

                // 输出反向依赖数据
                sb.Clear();
                foreach (var t in res_depends)
                {
                    sb.AppendFormat("[{0}]\n", t.Key);

                    HashSet<string> v = t.Value;
                    foreach (var t2 in v)
                    {
                        sb.AppendFormat("  # {0}\n", t2);
                    }
                }
                File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_reverse_depends.txt", sb.ToString());
                
                // 需要下载的bundle列表先保存到文件里
                Debug.LogFormat("ReadDownloadBundles - downloadBundles count : {0}", buildProcessInfo.downloadBundles.Count);
                if (buildProcessInfo.downloadBundles.Count > 0)
                {
                    string str = $"{EditorUtility.PlatformBuildPath}/{name}_buildInfo.txt";
                    string downloadJson = JsonUtility.ToJson(buildProcessInfo);
                    File.WriteAllText(str,downloadJson.ToString());
                    
                    Debug.LogFormat("ReadDownloadBundles - save : {0} -- {1}", str, downloadJson);
                }
            }

            try
            {
                AfterBuild(bundleBuilds);
                Save();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        private string GetOriginBundle(string assetBundle)
        {
            /*
            var pos = assetBundle.LastIndexOf("_", StringComparison.Ordinal) + 1;
            var hash = assetBundle.Substring(pos);
            if (!string.IsNullOrEmpty(settings.bundleExtension))
            {
                hash = hash.Replace(settings.bundleExtension, "");
            }

            var originBundle = $"{assetBundle.Replace("_" + hash, "")}";
            return originBundle;
            */
            return assetBundle;
        }

        private void BuildRaw(List<Asset> assets, List<BundleBuild> bundles, string path, Asset asset,
            Dictionary<string, BundleBuild> nameWithBundles,
            Dictionary<string, Asset> pathWithAssets)
        {
            using (var stream = File.OpenRead(path))
            {
                var crc = Utility.ComputeCRC32(stream);
                if (!nameWithBundles.TryGetValue(path, out var bundle))
                {
                    bundle = new BundleBuild
                    {
                        name = path
                    };
                    bundles.Add(bundle);
                    nameWithBundles.Add(path, bundle);
                    pathWithAssets.Add(asset.path, asset);
                    assets.Add(asset);
                }

                bundle.size = (ulong) stream.Length;
                bundle.assets.Add(new AssetBuild
                {
                    path = asset.path,
                    metaPath = asset.metaPath,
                    bundle = asset.bundle
                });
                bundle.nameWithAppendHash = $"{name}_raw_{crc}{settings.bundleExtension}".ToLower();
            }
        }


        public List<BundleBuild> BuildRaws(List<Asset> assets, List<BundleBuild> bundles)
        {
            var nameWithBundles = new Dictionary<string, BundleBuild>();
            foreach (var bundle in bundles)
            {
                nameWithBundles[bundle.name] = bundle;
            }
            var pathWithAssets = new Dictionary<string, Asset>();
            foreach (var asset in assets)
            {
                pathWithAssets[asset.path] = asset;
            }
            var count = bundles.Count;
            var buildRaws = new List<BundleBuild>();

            for (var index = 0; index < rawGroups.Count; index++)
            {
                var group = rawGroups[index];
                EditorUtility.DisplayProgressBar("Collect assets...", group.name, index, groups.Count);
                foreach (var asset in group.assets)
                {
                    if (!asset.isFolder)
                    {
                        if (File.Exists(asset.path))
                        {
                            var path = asset.path;
                            BuildRaw(assets, bundles, path, asset, nameWithBundles, pathWithAssets);
                        }
                    }
                    else
                    {
                        var children = asset.GetChildren();
                        foreach (var child in children)
                        {
                            if (File.Exists(child))
                            {
                                BuildRaw(assets, bundles, child, Asset.Create(child, @group), nameWithBundles,
                                    pathWithAssets);
                            }
                        }
                    }
                }
            }

            for (var i = count; i < bundles.Count; i++)
            {
                var bundle = bundles[i];
                var path = Settings.GetBuildPath(bundle.nameWithAppendHash);
                if (File.Exists(path))
                {
                    continue;
                }
                File.Copy(bundle.name, path, true);
                bundle.AfterBuild();
                buildRaws.Add(bundle);
            }

            EditorUtility.ClearProgressBar();
            return buildRaws;
        }
    }
}
#endif



