#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace VEngine.Editor
{
    [Serializable]
    public class GroupBuild
    {
        public string[] bundles = new string[0];
        public string name;
    }

    [Serializable]
    public class AssetBuild
    {
        public string path;
        public string bundle;
        public long time;
        public long metaTime;
        public string[] bundles = new string[0];    // 这个bundle其实表示的就是asset所在bundle的依赖项，所有bundle下面的asset是相同的
        public string metaPath;
        public string[] dependencies = new string[0]; // 这里存放的是这个asset的资源依赖项，依赖的是另一个asset
        public int id { get; set; }
        public long crc;  // 还是得用crc判断严谨一些
        public long metacrc;

        public bool dirty => time != Settings.GetLastWriteTime(path) || metaTime != Settings.GetLastWriteTime(metaPath);

        public AssetInfo GetInfo(Dictionary<string, BundleBuild> buildBundles)
        {
            var mainId = -1;
            if (buildBundles.TryGetValue(bundle, out var main))
            {
                mainId = main.id;
            }
            else
            {
                Logger.E("Bundle not found {0} with {1}.", bundle, path);
            }
            var ids = new List<int>();
            foreach (var item in bundles)
            {
                if (!buildBundles.TryGetValue(item, out var dep))
                {
                    Logger.E("Bundle not found {0} with {1}.", item, path);
                    continue;
                }

                ids.Add(dep.id);
            }

            return new AssetInfo
            {
                id = id,
                bundle = mainId,
                // bundles = ids.ToArray()
            };
        }

        public void AfterBuild()
        {
            time = Settings.GetLastWriteTime(path);
            metaTime = Settings.GetLastWriteTime(metaPath);
            crc = Utility.ComputeCRC32(path);
            metacrc = Utility.ComputeCRC32(metaPath);
        }
    }

    [Serializable]
    public class BundleBuild
    {
        public string name;
        public List<AssetBuild> assets = new List<AssetBuild>();
        public ulong size;
        public uint crc;
        public ResMode resMode;
        public string nameWithAppendHash;
        public int id;
        public string[] deps = new string[0];

        public BundleInfo GetInfo(Dictionary<string, BundleBuild> buildBundles)
        {
            var ids = new int[assets.Count];
            for (var index = 0; index < assets.Count; index++)
            {
                var asset = assets[index];
                ids[index] = asset.id;
            }

            var info = new BundleInfo
            {
                id = id,
                assets = ids,
                name = nameWithAppendHash,
                crc = crc,
                resMode = (int)resMode,
                size = size,
                deps = Array.ConvertAll(deps, input =>
                {
                    if (buildBundles.TryGetValue(input, out var dep))
                    {
                        return dep.id;
                    }

                    return -1;
                })
            };
            return info;
        }

        public void AfterBuild()
        {
            var file = Settings.GetBuildPath(nameWithAppendHash);
            if (File.Exists(file))
            {
                using (var stream = File.OpenRead(file))
                {
                    size = (ulong) stream.Length;
                    crc = Utility.ComputeCRC32(stream);
                }
            }

            foreach (var asset in assets)
            {
                asset.AfterBuild();
            }
        }

        public AssetBundleBuild GetBuild()
        {
            var build = new AssetBundleBuild
            {
                assetBundleName = name,
                assetNames = Array.ConvertAll(assets.ToArray(), input => input.path)
            };
            return build;
        }

        public void GetDependencies(Dictionary<string, string> assetWithBundles)
        {
            // Generate bundles for each entry
            foreach (var asset in assets)
            {
                var bundles = new HashSet<string>();
                foreach (var dependency in asset.dependencies)
                {
                    string bundle;
                    if (assetWithBundles.TryGetValue(dependency, out bundle))
                    {
                        bundles.Add(bundle);
                    }
                }

                asset.bundles = bundles.ToArray();
            }
        }
    }

    /// <summary>
    ///     打包后的缓存数据
    /// </summary>
    public class Build : ScriptableObject
    {
        public int version;
        public string size;
        public List<string> newFiles = new List<string>();
        public List<BundleBuild> bundles = new List<BundleBuild>();
        public List<GroupBuild> groups = new List<GroupBuild>();

        public Dictionary<string, BundleBuild> GetBundles()
        {
            var dictionary = new Dictionary<string, BundleBuild>();
            foreach (var bundle in bundles)
            {
                dictionary[bundle.name] = bundle;
            }
            return dictionary;
        }

        public Dictionary<string, AssetBuild> GetAssets()
        {
            var dictionary = new Dictionary<string, AssetBuild>();
            foreach (var bundle in bundles)
            foreach (var asset in bundle.assets)
            {
                dictionary[asset.path] = asset;
            }
            return dictionary;
        }

        public Dictionary<string, GroupBuild> GetGroups()
        {
            var dictionary = new Dictionary<string, GroupBuild>();
            foreach (var group in groups)
            {
                dictionary[group.name] = group;
            }
            return dictionary;
        }

        public void Clear()
        {
            groups.Clear();
            bundles.Clear();
            newFiles.Clear();
            version = 0;
            size = "0B";
        }

        public string CreateManifest()
        {
            var assetNames = new List<string>();
            var manifest = new VEngine.Manifest();
            var filename = $"{name}".ToLower();
            var savePath = Settings.GetBuildPath(filename);
            var buildBundles = new Dictionary<string, BundleBuild>();
            var assetsInBuild = new List<AssetBuild>();
            for (var index = 0; index < bundles.Count; index++)
            {
                var bundle = bundles[index];
                bundle.id = index;
                buildBundles[bundle.name] = bundle;
                foreach (var asset in bundle.assets)
                {
                    asset.id = assetsInBuild.Count;
                    assetsInBuild.Add(asset);
                    assetNames.Add(asset.path);
                }
            }

            //manifest.groups = groups.ConvertAll(ConverterGroup(buildBundles));
            manifest.assets = assetsInBuild.ConvertAll(input => input.GetInfo(buildBundles));
            manifest.bundles = bundles.ConvertAll(input => input.GetInfo(buildBundles));
            manifest.SetAllAssetPaths(assetNames.ToArray());
            switch (EditorUserBuildSettings.activeBuildTarget)
            {
                case BuildTarget.Android:
                    manifest.appVersion = //UnityEditor.PlayerSettings.Android.bundleVersionCode +
                                          UnityEditor.PlayerSettings.bundleVersion;
                    break;
                case BuildTarget.iOS:
                    manifest.appVersion = //UnityEditor.PlayerSettings.iOS.buildNumber +
                                          UnityEditor.PlayerSettings.bundleVersion;
                    break;
                default:
                    manifest.appVersion = UnityEditor.PlayerSettings.bundleVersion;
                    break;
            }
            manifest.version = version;
            manifest.unix_timestamp = DateTimeOffset.Now.ToUnixTimeSeconds();
            return manifest.Save(savePath);
        }

        BundleBuild GetBundleFromName(string name)
        {
            for (int i = 0; i < bundles.Count; ++i)
            {
                if (bundles[i].name == name)
                {
                    return bundles[i];
                }
            }

            return null;
        }
        
        // 整一个简洁版的方便预览的文件
        public string ToSimpleReadableString()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("(build)  ");
            sb.AppendFormat(", version={0}", version);
            sb.AppendFormat(", size={0}", size);
            sb.AppendFormat("\n");
            
            sb.AppendFormat("+(newfiles)\n");
            for (int i = 0; i < newFiles.Count; ++i)
            {
                sb.AppendFormat("  +{0}\n", newFiles[i]);
            }

            
            sb.AppendFormat("+(groups)\n");
            for (int i = 0; i < groups.Count; ++i)
            {
                sb.AppendFormat("  +{0}\n", groups[i].name);

                for (int k = 0; k < groups[i].bundles.Length; ++k)
                {
                    string bname = groups[i].bundles[k];
                    BundleBuild bb = GetBundleFromName(bname);
                    if (bb != null)
                    {
//                        sb.AppendFormat("    +(bundle) \n");
                        sb.AppendFormat("    +[{0}] {1}, size={2}, crc={3}\n", bb.id, bb.name, bb.size, bb.crc);

                        if (bb.deps.Length > 0)
                        {
                            sb.AppendFormat("      +(deps) {0}\n", bb.deps.Length);
                            for (int j = 0; j < bb.deps.Length; ++j)
                            {
                                sb.AppendFormat("        +{0}\n", bb.deps[j]);
                            }
                        }

                        var assets = bb.assets;
                        for (int j = 0; j < assets.Count; ++j)
                        {
                            sb.AppendFormat("      +[{0}] {1}\n", assets[j].id, assets[j].path);

                            var dt1 = new DateTime(assets[j].time);
                            string s1 = dt1.ToString("yyyy-MM-dd HH:mm:ss");
                            
                            var dt2 = new DateTime(assets[j].metaTime);
                            string s2 = dt1.ToString("yyyy-MM-dd HH:mm:ss");
                            
                            sb.AppendFormat("        + {0} ({1}) - {2} ({3}) \n", s1, assets[j].time, s2, assets[j].metaTime);
                            
                            if (assets[j].dependencies.Length > 0)
                            {
                                sb.AppendFormat("        +(dependencies)\n");
                                for (int x = 0; x < assets[j].dependencies.Length; ++x)
                                {
                                    sb.AppendFormat("          +{0}\n", assets[j].dependencies[x]);
                                }
                            }
                        }
                    }
                    else
                    {
                        sb.AppendFormat("  + [ERROR] not found!\n");
                    }
                }
            }
            
            return sb.ToString();
        }

        // private static Converter<GroupBuild, GroupInfo> ConverterGroup(Dictionary<string, BundleBuild> buildBundles)
        // {
        //     return input =>
        //     {
        //         var groupInfo = new GroupInfo
        //         {
        //             name = input.name,
        //             bundles = Array.ConvertAll(input.bundles, s =>
        //             {
        //                 if (buildBundles.TryGetValue(s, out var value))
        //                 {
        //                     return value.id;
        //                 }
        //                 Logger.W("Bundle {0} not find", s);
        //                 return -1;
        //             })
        //         };
        //         return groupInfo;
        //     };
        // }
    }


    // Bundle修改
    public class BundleChanged
    {
        public BundleBuild bb;
        public List<AssetBuild> addAssets;
        public List<AssetBuild> delAddets;
        public List<AssetBuild> changedAssets;

        public void ChangedAssets(AssetBuild a)
        {
            if (changedAssets == null)
            {
                changedAssets = new List<AssetBuild>(8);
            }
            
            changedAssets.Add(a);
        }
        
        public void AddAssets(AssetBuild a)
        {
            if (addAssets == null)
            {
                addAssets = new List<AssetBuild>(8);
            }
            
            addAssets.Add(a);
        }
        
        public void DelAssets(AssetBuild a)
        {
            if (delAddets == null)
            {
                delAddets = new List<AssetBuild>(8);
            }
            
            delAddets.Add(a);
        }
    }
    
    // 打包修改项
    public class BuildChanged
    {
        public int lastBundleCount;
        public int thisBundleCount;
        public List<BundleBuild> newBundles = new List<BundleBuild>(16);        // 新增的bundle
        public List<BundleChanged> changedBundles = new List<BundleChanged>(16);  // 修改的bundle
        public List<BundleBuild> delBundles = new List<BundleBuild>(16);        // 删除的bundle

        public string ToReadableString()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("Bundle Count : {0}\n", thisBundleCount);
            sb.AppendFormat("Last Bundle Count : {0}\n", lastBundleCount);
            
            // 统计一下修改的bundle大小
            ulong totalSize = 0;
            for (int i = 0; i < newBundles.Count; ++i)
            {
                totalSize += newBundles[i].size;
            }

            for (int i = 0; i < changedBundles.Count; ++i)
            {
                totalSize += changedBundles[i].bb.size;
            }

            sb.AppendFormat("Changed Size: {0}\n", totalSize);
            
            sb.AppendFormat("------------------------------------\n");
            sb.AppendFormat("New Bundle Count : {0}\n", newBundles.Count);
            for (int i = 0; i < newBundles.Count; ++i)
            {
                sb.AppendFormat("  + {0}\n", newBundles[i].name);    
            }
            
            sb.AppendFormat("------------------------------------\n");
            sb.AppendFormat("Deleted Bundle Count : {0}\n", delBundles.Count);
            for (int i = 0; i < delBundles.Count; ++i)
            {
                sb.AppendFormat("  - {0}\n", delBundles[i].name);    
            }     
            
            sb.AppendFormat("------------------------------------\n");
            sb.AppendFormat("Changed Bundle Count : {0}\n", changedBundles.Count);
            for (int i = 0; i < changedBundles.Count; ++i)
            {
                BundleChanged changed = changedBundles[i];
                sb.AppendFormat("  [{0}]\n", changed.bb.name);

                if (changed.addAssets != null)
                {
                    for (int j = 0; j < changed.addAssets.Count; ++j)
                    {
                        AssetBuild asset = changed.addAssets[j];
                        sb.AppendFormat("  + {0}\n", asset.path);
                    }
                }

                if (changed.delAddets != null)
                {
                    for (int j = 0; j < changed.delAddets.Count; ++j)
                    {
                        AssetBuild asset = changed.delAddets[j];
                        sb.AppendFormat("  - {0}\n", asset.path);
                    }
                }

                if (changed.changedAssets != null)
                {
                    for (int j = 0; j < changed.changedAssets.Count; ++j)
                    {
                        AssetBuild asset = changed.changedAssets[j];
                        sb.AppendFormat("  * {0}\n", asset.path);
                    }
                }
                
                sb.AppendFormat("\n");
            }    
            
            return sb.ToString();
        }
    }
}
#endif



