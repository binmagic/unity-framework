#define BUILTIN_BUILD
#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using GameFramework;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using BuildCompression = UnityEngine.BuildCompression;

namespace VEngine.Editor
{
    /// <summary>
    ///     BuildScript 类，实现了具体的打包逻辑
    /// </summary>
    public static class BuildScript
    {
        [MenuItem("GameObject/Opt/获取所有image节点对应的图片资源")]
        public static void GetAllImageSpritePath()
        {
            Transform transform = Selection.activeGameObject.transform;
            Image[] allImage = transform.GetComponentsInChildren<Image>(true);
            for (int i = 0; i < allImage.Length; ++i)
            {
                Sprite _sprite = allImage[i].sprite;
                if (_sprite == null)
                    continue;
                string x = AssetDatabase.GetAssetPath(_sprite);
                string path = GetRootPath(allImage[i].transform);
                Debug.Log($"{path} -> {x}");
            }

        }
        
        
        public static Action<Manifest> preprocessBuildBundles { get; set; }
        public static Action<Manifest> postprocessBuildBundles { get; set; }

        /// <summary>
        ///     构建资源
        /// </summary>
        public static void BuildBundles()
        {
            var settings = Settings.GetDefaultSettings();
            var manifests = new List<string>();
            foreach (var manifest in settings.manifests)
            {
                manifests.Add(AssetDatabase.GetAssetPath(manifest));
            }
            foreach (var manifest in manifests)
            {
                BuildBundle(manifest);
            }
            
        }
        
        static Dictionary<string, Asset> pathWithAssets1 = new Dictionary<string, Asset>();
        // 所有的bundle列表
        static List<BundleBuild> bundleBuilds1 = new List<BundleBuild>();
        [MenuItem("GameObject/Opt/GetAllSpritePath")]
        public static void GetAllSpritePath()
        {
            StringBuilder _sb = new StringBuilder(8196);
            Dictionary<string, string> pathList = new Dictionary<string, string>(8096);
            Transform transform = Selection.activeGameObject.transform;
            Image[] allImage = transform.GetComponentsInChildren<Image>(true);
            for (int i = 0; i < allImage.Length; ++i)
            {
                Sprite _sprite = allImage[i].sprite;
                if (_sprite == null)
                    continue;
                string x = AssetDatabase.GetAssetPath(_sprite);
                string path = GetRootPath(allImage[i].transform);
                pathList[path] = x;
            }

            if (pathWithAssets1.Count == 0 && bundleBuilds1.Count == 0)
            {
                string manifest = "Assets/Editor/VEngine/Data/GameRes.asset";
                var asset = EditorUtility.GetOrCreateAsset<Manifest>(manifest);
                asset.BuildGroups(pathWithAssets1, bundleBuilds1);
            }

            Asset getbundle( string imagePath )
            {
                foreach (var item in pathWithAssets1)
                {
                    if (item.Key.Equals(imagePath))
                    {
                        return item.Value;
                    }
                }

                return null;
            }

            string cachePath = Path.Combine(Application.persistentDataPath, "findImageBundle.txt");
            File.Delete(cachePath);
            StreamWriter sw = new StreamWriter(cachePath, true);
            Dictionary<string, List<string>> KV = new Dictionary<string, List<string>>(256);
            foreach (var item in pathList)
            {
                Asset asset = getbundle(item.Value);
                if (asset == null)
                    continue;
                if (KV.TryGetValue(asset.bundle, out _) == false)
                {
                    KV[asset.bundle] = new List<string>(32);
                }

                foreach (var bundle in bundleBuilds1)
                {
                    if (bundle.name.Equals(asset.bundle))
                    {
                        KV[asset.bundle].Add(item.Value);
                        // sw.Write($"\nspriteName: {item.Value}\n    {asset.bundle}");
                        // for (int i = 0; i < bundle.deps.Length; ++i)
                        // {
                        //     sw.Write($"\n        {bundle.deps[i]}");
                        // }
                    }
                }
            }

            foreach (var item in KV)
            {
                sw.Write($"{item.Key}\n");
                foreach (var sprite in item.Value)
                {
                    sw.Write($"        {sprite}\n");
                }
            }
            
            
            sw.Flush();
            sw.Close();
        }
        
        public static string GetRootPath(Transform t)
        {
            string _path = "";
            while (t != null)
            {
                _path = $"{t.name}|{_path}";
                t = t.parent;
            }

            return _path;
        }
        
        
        
        
        
        // useCache表示是否增量打包
        public static void BuildBundles(List<string> manifestNames, string lastBuildPath, bool useCache = false)
        {
            // 先关闭useCache，毕竟打包机现在效率高一些
            Debug.LogFormat("=== BuildBundles begin!!! {0}", useCache);

            var settings = Settings.GetDefaultSettings();
            var manifests = new List<string>();
            foreach (var manifest in settings.manifests)
            {
                if (manifestNames.Contains(manifest.name))
                {
                    manifests.Add(AssetDatabase.GetAssetPath(manifest));
                }
            }

            string manifestName = "";
            foreach (var manifest in manifests)
            {
                Debug.Log($"[Publish] Build manifest {manifest}");
                
                var asset = EditorUtility.GetOrCreateAsset<Manifest>(manifest);
                if (asset != null)
                {
                    Build lastBuild = null;
                    // 先读取一下上一次的gameres.json
                    if (!lastBuildPath.IsNullOrEmpty())
                    {
                        // 目录的结构为：PatchMCDebug\com.readygo.lm.debug\Android\20230314_002\GameRes\GameRes.json
                        // 其中：LastBuildPath = PatchMCDebug\com.readygo.lm.debug\Android\20230314_002
                        string fullJson = lastBuildPath + asset.name + "/" + asset.name + ".json";
                        lastBuild = Manifest.GetBuild(fullJson);
                    }

                    manifestName = asset.name;
                    BuildBundles_Internal(asset, lastBuild, useCache);
                    //输出需要更新下载的资源
                    try
                    {
                        string logtxt = $"{EditorUtility.PlatformBuildPath}/{manifestName}_buildInfo.txt";
                        if (File.Exists(logtxt))
                        {
                            Debug.Log($"******** 需要在登录下载的资源列表 *******");
                            string jsonstr = File.ReadAllText(logtxt);
                            var buildInfo = JsonUtility.FromJson<BuildProcessInfo>(jsonstr);
                            if (buildInfo != null)
                            {
                                var bundlelist = buildInfo.downloadBundles;
                                var bundlesize = buildInfo.downloadSize;
                                if (bundlelist.Count == bundlesize.Count)
                                {
                                    for (int i = 0; i < bundlelist.Count; ++i)
                                    {
                                        Debug.Log($"bundlename: {bundlelist[i]} size: {GetBundleSize(bundlesize[i])}");
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e);
                    }
                }
            }
            
            Debug.Log("=== BuildBundles end!!!");
        }
        
        public static string GetBundleSize(ulong bundlesize)
        {
            if (bundlesize > 1000000)
                return string.Format("{0:F}M", bundlesize / 1000000.0f);
            else
                return string.Format("{0:F}KB", bundlesize / 1000.0f);
        }

        public static void SaveManifestVersion()
        {
            var settings = Settings.GetDefaultSettings();
            var manifests = settings.manifests.ConvertAll(AssetDatabase.GetAssetPath);
            
            // 合并manifest.version
            var builder = new StringBuilder();
            foreach (var manifest in manifests)
            {
                var m = EditorUtility.GetOrCreateAsset<Manifest>(manifest);
                var versionPath = Settings.GetBuildPath($"{m.name.ToLower()}.version");
                if (File.Exists(versionPath))
                {
                    builder.AppendLine($"{m.name},{File.ReadAllText(versionPath).Trim()}");
                }
                else
                {
                    Debug.LogFormat("SaveManifestVersion file not exist! {0}", versionPath);
                }
            }

            var bundleVersion = GetBundleVersion();
            Debug.LogFormat("SaveManifestVersion bundleVersion - {0}!", bundleVersion);
            Debug.LogFormat("SaveManifestVersion builder - {0}!", builder.ToString());
            
            string manifestVersionPath = Settings.GetBuildPath(ManifestFile.GetManifestVersion(bundleVersion, ""));
            File.WriteAllText(manifestVersionPath, builder.ToString());
            string manifestVersionPathTest = Settings.GetBuildPath(ManifestFile.GetManifestVersion(bundleVersion, "_test"));
            File.WriteAllText(manifestVersionPathTest, builder.ToString());
            string manifestVersionPathGM = Settings.GetBuildPath(ManifestFile.GetManifestVersion(bundleVersion, "_gm"));
            File.WriteAllText(manifestVersionPathGM, builder.ToString());
        }
        
        public static void BuildBundle(Manifest manifest)
        {
            BuildBundles_Internal(manifest);
        }
        
        public static void BuildBundle(string manifestPath)
        {
            var asset = EditorUtility.GetOrCreateAsset<Manifest>(manifestPath);
            BuildBundles_Internal(asset);
            // SaveManifestVersion();
        }

        public static void DumpGroupAssetPath()
        {
            var settings = Settings.GetDefaultSettings();
            string filepath = Path.Combine(Application.temporaryCachePath, "bundlepath.txt");
            if (File.Exists(filepath))
                File.Delete(filepath);
            StreamWriter sw = new StreamWriter(filepath, true);
            foreach (var manifest in settings.manifests)
            {
                string manifestPath = AssetDatabase.GetAssetPath(manifest);
                var asset = EditorUtility.GetOrCreateAsset<Manifest>(manifestPath);
                sw.WriteLine("***********" + manifestPath);
                var assetlist = asset.GetAssets();
                foreach (var item in assetlist)
                {
                    sw.WriteLine(item.Value.parentGroup.name + " - " +  item.Value.path);
                }
               
            }
            sw.Flush();
            sw.Close();
            UnityEditor.EditorUtility.RevealInFinder(Application.temporaryCachePath);
        }
        
        // 增量打包检测，检测这个是否发生了变动
        public static bool IsBundleChanged(BundleBuild bundleBuild, Build lastBuild, BuildChanged bc)
        {
            // 这里就没什么好处理得了
            if (lastBuild == null)
            {
                return false;
            }
            
            // 这里做改动，新增，和删除判断
            BundleChanged bundleChanged = null;

            // 把上个版本的文件信息读进来，逐一做一下比对，如果整个bundle里的每一条asset的文件大小和时间都匹配的话（包括meta）
            // 则从当前打包的信息中删除
            bool bundlefound = false;
            for (int i = 0; i < lastBuild.bundles.Count; ++i)
            {
                BundleBuild oldBundle = lastBuild.bundles[i]; 
                if (oldBundle.name == bundleBuild.name)
                {
                    bundlefound = true;
                    
                    // 第一遍，用来处理改动和新增
                    // 在new中获取每一项，然后和old匹配上之后；对于path相同的，比对时间是否一致

                    for (int m = 0; m < bundleBuild.assets.Count; ++m)
                    {
                        AssetBuild a0 = bundleBuild.assets[m];
                        
                        bool filefound = false;
                        
                        for (int n = 0; n < oldBundle.assets.Count; ++n)
                        {
                            AssetBuild a1 = oldBundle.assets[n];
                            
                            if (a1.path == a0.path && a1.metaPath == a0.metaPath)
                            {
                                //if (a1.time != a0.time || a1.metaTime != a0.metaTime)
                                if (a1.crc != a0.crc || a1.metacrc != a0.metacrc)
                                {
                                    if (bundleChanged == null)
                                    {
                                        bundleChanged = new BundleChanged();
                                    }

                                    bundleChanged.ChangedAssets(a0);
                                }

                                filefound = true;
                                break;
                            }
                        }

                        if (filefound == false)
                        {
                            if (bundleChanged == null)
                            {
                                bundleChanged = new BundleChanged();
                            }

                            bundleChanged.AddAssets(a0);
                        }
                    }
                    
                   // 第二遍，用来处理删除
                   // 把旧的每一个asset放到新的列表中去查找
                   for (int m = 0; m < oldBundle.assets.Count; ++m)
                   {
                       AssetBuild a1 = oldBundle.assets[m];
                       
                       bool filefound = false;
                       for (int n = 0; n < bundleBuild.assets.Count; ++n)
                       {
                           AssetBuild a0 = bundleBuild.assets[n];
                            
                           if (a1.path == a0.path && a1.metaPath == a0.metaPath)
                           {
                               filefound = true;
                               break;
                           }
                       }

                       // 此时表示在old的bundle中有个asset，但是在新的bundle中没有这个asset
                       if (filefound == false)
                       {
                           if (bundleChanged == null)
                           {
                               bundleChanged = new BundleChanged();
                           }

                           bundleChanged.DelAssets(a1);
                       }
                   }

                   if (bundleChanged != null)
                   {
                       bundleChanged.bb = bundleBuild;
                   }

                   // 找到同名文件后，处理一下就跳出去
                   break;
                }
            }
            
            // 表示这是一个新增的bundle
            if (bundlefound == false)
            {
                Logger.I("**** Bundle Add - {0}", bundleBuild.name);
                bc.newBundles.Add(bundleBuild);
                return true;
            }
            

            if (bundleChanged != null)
            {
                Logger.I("**** Bundle Changed - {0}", bundleBuild.name);
                bc.changedBundles.Add(bundleChanged);
                return true;
            }
            
            return false;
        }

        // 把我们自己组织的Bundle List 组织成Unity打包用的AssetBundleBuild
        // 给Unity打包的时候，只需要把我们最终打的Bundle和其中的Asset组织好传给Build结构即可。
        public static AssetBundleBuild[] ListBundleTo_UnityAssetBundleBuild(List<BundleBuild> bundleBuilds, Build lastBuild, string name)
        {
            bool isIncrementBuildBundle = lastBuild ? true : false;
            BuildChanged bc = new BuildChanged();
            
            // 在这里检测一下重复
            var builds = new Dictionary<string, AssetBundleBuild>();
            foreach (var bundle in bundleBuilds)
            {
                if (!builds.ContainsKey(bundle.name))
                {
                    if (isIncrementBuildBundle)
                    {
                        // 需要计算一个每一个asset的时间戳，用来和上一次的变动做一个比较
                        foreach (var asset in bundle.assets)
                        {
                            asset.AfterBuild();
                        }

                        // 增量更新，Unity有个问题，打包时如果A依赖B，打包时你没有提交B，只提交A
                        // 他会把B的资源直接给打到A里面
                        IsBundleChanged(bundle, lastBuild, bc);
                        if (true)
                        {
                            builds.Add(bundle.name, bundle.GetBuild());
                        }
                        else
                        {
                            Log.Info("Increment Bundle not changed : {0}", bundle.name);
                        }
                    }
                    else
                    {
                        builds.Add(bundle.name, bundle.GetBuild());
                    }
                }
                else
                {
                    Logger.E("??? Bundle {0} already exist.", bundle.name);
                }
            }
            
            // 查看是否有bundle删除项
            if (lastBuild != null)
            {
                for (int i = 0; i < lastBuild.bundles.Count; ++i)
                {
                    BundleBuild oldBundle = lastBuild.bundles[i];
                    if (!builds.ContainsKey(oldBundle.name))
                    {
                        Logger.I("**** Bundle Delete - {0}", oldBundle.name);
                        bc.delBundles.Add(oldBundle);
                    }
                }
            }

            bc.thisBundleCount = builds.Count;
            bc.lastBundleCount = lastBuild ? lastBuild.bundles.Count : 0;
            
            // 每次改变的数据
            var sampletxt = bc.ToReadableString();
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_changed.txt", sampletxt);

            return builds.Values.ToArray();
        }
        
        // 打印bundle的log
        private static void WriteBundlesLog(AssetBundleBuild[] builds, string name)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("+++++++++++++ {0} +++++++++++++\n", name);
            
            for (int i = 0; i < builds.Length; ++i)
            {
                sb.AppendFormat(" BUNDLE [{0}]\n", builds[i].assetBundleName);
                for (int j = 0; j < builds[i].assetNames.Length; ++j)
                {
                    sb.AppendFormat("   |- {0}\n", builds[i].assetNames[j]);    
                }
            }
            
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_bundles.txt", sb.ToString());
            return;
        }

        // 尽量保证我们的输入和输出的依赖是一样的
        public static void WriteBundleDepends(List<BundleBuild> bundleBuilds, Dictionary<string, Asset> pathWithAssets, string name)
        {
            // sb 保存 bundle依赖，sb2 保存 Bundle-Asset依赖（详细依赖）
            StringBuilder sb = new StringBuilder();
            StringBuilder sb2 = new StringBuilder();

            // 这个字典用来统计每一个bundle中的每一个Asset依赖其他bundle的其他asset的详细信息！懂吗？详细信息！
            Dictionary<string, HashSet<string> > detail_list = new Dictionary<string, HashSet<string>>();
            HashSet<string> bundle_list = new HashSet<string>();
            
            foreach (var assetBundle in bundleBuilds)
            {
                sb.AppendFormat("[{0}]\n", assetBundle.name);
                sb2.AppendFormat("[{0}]\n", assetBundle.name);
                
                bundle_list.Clear();
                
                // 遍历这个Bundle中每一个Asset，输出每一个Asset的依赖项。
                for (int i = 0; i < assetBundle.assets.Count; ++i)
                {
                    detail_list.Clear();
                    
                    var srcAsset = assetBundle.assets[i];
                    // if (srcAsset.path.Contains("UIGuideHeadTalk"))
                    // {
                    //     int a = 0;
                    // }
                    //
                    for (int j = 0; j < srcAsset.dependencies.Length; ++j)
                    {
                        var asset = srcAsset.dependencies[j];
                        //var asset2 = AssetDatabase.GetDependencies(assetBundle.assets[i].path, true); 
                        
                        // 找到asset对应的结构，从而取出asset.bundle
                        if (pathWithAssets.TryGetValue(asset, out Asset a))
                        {
                            // 如果源资源是包体或者下载资源，就要注意不能依赖Download资源
                            if (assetBundle.resMode == ResMode.Normal ||
                                assetBundle.resMode == ResMode.LoadingDownload)
                            {
                                if (a.parentGroup.resMode == ResMode.Download ||
                                    a.parentGroup.resMode == ResMode.RequestDownload)
                                {
                                    Debug.LogErrorFormat("*************************************************ERR*************************************************: {0} depends download res: {1} ", 
                                        assetBundle.assets[i].path, asset);    
                                }
                            }

                            // ************************************** 关键行
                            // 把assetBundle 依赖的其他 bundle 加到列表中
                            // 记录Bundle-Asset依赖数据和Bundle依赖数据
                            bundle_list.Add(a.bundle);
                            
                            // 把当前Asset依赖的其他Asset，进行按照Bundle分组！
                            HashSet<string> value;
                            if (!detail_list.TryGetValue(a.bundle, out value))
                            {
                                value = new HashSet<string>();
                                detail_list.Add(a.bundle, value);
                            }
                            
                            value.Add(asset);
                        }
                        else
                        {
                            Debug.LogErrorFormat("not found asset! {0}", asset);
                        }
                    }

                    // Bundle-Asset依赖
                    detail_list.Remove(assetBundle.name);
                    
                    // 把一些常用项去除吧，要不然看起来也很累
                    detail_list.Remove("shader_all.bundle");
                    detail_list.Remove("packages_com_unity_render-pipelines_universal__all.bundle");

                    detail_list.Remove("fontsmaterial_all.bundle");
                    detail_list.Remove("fonts__notosanssc-bold_sdf.bundle");
                    detail_list.Remove("fonts__notosanssc-bold.bundle");
                    detail_list.Remove("fonts__notosanssc-medium_sdf.bundle");
                    detail_list.Remove("fonts__notosanssc-medium.bundle");
                    detail_list.Remove("fonts__oswald-semibold_sdf.bundle");
                    detail_list.Remove("fonts__oswald-semibold.bundle");
                    
                    // 先把这些干扰排序掉，测起来方便
                    detail_list.Remove("art_lastday_effect_all.bundle");
                    detail_list.Remove("art_barrel_effect_all.bundle");
                    detail_list.Remove("art_barrel_artassets_all.bundle");
                    detail_list.Remove("art_lastday_effect_texture_aps.bundle");
                    detail_list.Remove("art_lastday_effect_texture_blood.bundle");
                    detail_list.Remove("art_lastday_effect_texture_decal.bundle");
                    detail_list.Remove("art_lastday_effect_texture_duobiqiu.bundle");
                    detail_list.Remove("art_lastday_effect_texture_fire.bundle");
                    detail_list.Remove("art_lastday_effect_texture_flash.bundle");
                    detail_list.Remove("art_lastday_effect_texture_glow.bundle");
                    detail_list.Remove("art_lastday_effect_texture_light.bundle");
                    detail_list.Remove("art_lastday_effect_texture_lizi.bundle");
                    detail_list.Remove("art_lastday_effect_texture_mask.bundle");
                    detail_list.Remove("art_lastday_effect_texture_noise.bundle");
                    detail_list.Remove("art_lastday_effect_texture_object.bundle");
                    detail_list.Remove("art_lastday_effect_texture_other.bundle");
                    detail_list.Remove("art_lastday_effect_texture_path.bundle");
                    detail_list.Remove("art_lastday_effect_texture_ring.bundle");
                    detail_list.Remove("art_lastday_effect_texture_smoke.bundle");
                    detail_list.Remove("art_lastday_effect_texture_trail.bundle");
                    detail_list.Remove("art_lastday_effect_texture_ui.bundle");
                    detail_list.Remove("art_lastday_effect_texture_uifirstpay.bundle");
                    detail_list.Remove("art_lastday_effect_texture_uimainquest_head.bundle");
                    detail_list.Remove("art_lastday_effect_texture_water.bundle");
                    detail_list.Remove("art_lastday_effect_texture_wind.bundle");
                    detail_list.Remove("art_lastday_effect_texture_xulie.bundle");
                    
                    detail_list.Remove("main_texturert_all.bundle");
                    detail_list.Remove("art_lastday_misc_all.bundle");
                    
                    


                    if (detail_list.Count > 0)
                    {
                        sb2.AppendFormat("++{0}\n", srcAsset.path);
                        
                        foreach (var v in detail_list)
                        {
                            foreach (var v2 in v.Value)
                            {
                                sb2.AppendFormat("      {0}\n", v2);
                            }
                            
                            sb2.AppendFormat("      == OWNER BUNDLE: {0} ==\n\n", v.Key);
                        }
                    }
                }

                // bundle依赖，把依赖自己排除掉
                bundle_list.Remove(assetBundle.name);
                var keys = bundle_list.ToList();
                keys.Sort();
                assetBundle.deps = keys.ToArray();
                
                if (keys.Count > 0)
                {
                    foreach (var v in keys)
                    {
                        sb.AppendFormat("  + {0}\n", v);
                    }
                }

                if (assetBundle.deps.Length > 15)
                {
                    Debug.LogFormat("*** DEPENDS *** Bundle {0} deps too many bundles! {1}", assetBundle.name, assetBundle.deps.Length);
                }
            }
            
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_input_depends.txt", sb.ToString());
            File.WriteAllText($"{EditorUtility.PlatformBuildPath}/{name}_input_depends_detail.txt", sb2.ToString());
            return;
        }
     
        // 这里用来标记到底是是使用内置打包流程还是使用Scriptable Build Pipeline (SBP)
        // SBP打包速度会更快一些
        // https://zhuanlan.zhihu.com/p/369264807
#if BUILTIN_BUILD
        public static AssetBundleManifest BuildAssetBundles(string outputPath,
            AssetBundleBuild[] builds,
            BuildAssetBundleOptions assetBundleOptions,
            BuildTarget targetPlatform)
        {
            return BuildPipeline.BuildAssetBundles(outputPath, builds, assetBundleOptions, targetPlatform);
        }
#else
        
        // 自定义的构造参数
        class CustomBuildParameters : BundleBuildParameters
        {
            public CustomBuildParameters(BuildTarget target, BuildTargetGroup group, string outputFolder) : base(target, group, outputFolder)
            {
            }

            // Override the GetCompressionForIdentifier method with new logic
            public override BuildCompression GetCompressionForIdentifier(string identifier)
            {
                // gameres_luascript_
                // datatable_config_luatxt_
                // 视频不压缩，多语言使用lzma极限压缩
                if (identifier.StartsWith("videos_"))
                {
                    Debug.LogFormat("GetCompressionForIdentifier - {0} Uncompressed!", identifier);
                    return BuildCompression.Uncompressed;
                }
                
                if (identifier.StartsWith("datatable_config_"))
                {
                    Debug.LogFormat("GetCompressionForIdentifier - {0} LZMA!", identifier);
                    return BuildCompression.LZMA;
                }
                
                return BundleCompression;
            }
        }
        
        public static CompatibilityAssetBundleManifest BuildAssetBundles(string outputPath,
            AssetBundleBuild[] builds,
            BuildAssetBundleOptions options,
            BuildTarget targetPlatform)
        {
            if (!Directory.Exists(outputPath))
            {
                Directory.CreateDirectory(outputPath);
            }

            // 构建内容
            var content = new BundleBuildContent(builds);
            
            // 构建参数
            var group = BuildPipeline.GetBuildTargetGroup(targetPlatform);
            var parameters = new CustomBuildParameters(targetPlatform, group, outputPath);
            if ((options & BuildAssetBundleOptions.ForceRebuildAssetBundle) != 0)
            {
                parameters.UseCache = false;
            }
            else
            {
                // Set build parameters for connecting to the Cache Server
                parameters.UseCache = true;
                parameters.CacheServerHost = "10.7.89.8";
                parameters.CacheServerPort = 8126; // 8126 是老版本的cache server,  10080 是新版本的cache server
                Debug.Log("BuildAssetBundles - UseCache - 10.7.89.8:10080");
            }

            if ((options & BuildAssetBundleOptions.AppendHashToAssetBundleName) != 0)
                parameters.AppendHash = true;
            
            if ((options & BuildAssetBundleOptions.ChunkBasedCompression) != 0)
                parameters.BundleCompression = BuildCompression.LZ4;
            else if ((options & BuildAssetBundleOptions.UncompressedAssetBundle) != 0)
                parameters.BundleCompression = BuildCompression.Uncompressed;
            else
                parameters.BundleCompression = BuildCompression.LZMA;

            if ((options & BuildAssetBundleOptions.DisableWriteTypeTree) != 0)
                parameters.ContentBuildFlags |= ContentBuildFlags.DisableWriteTypeTree;

            IBundleBuildResults results;
            ReturnCode exitCode = ContentPipeline.BuildAssetBundles(parameters, content, out results);
            if (exitCode < ReturnCode.Success)
            {
                Log.Error("BuildAssetBundles Error: {0}", exitCode.ToString());
                return null;
            }

            var manifest = ScriptableObject.CreateInstance<CompatibilityAssetBundleManifest>();
            manifest.SetResults(results.BundleInfos);
            File.WriteAllText(parameters.GetOutputFilePathForIdentifier(Path.GetFileName(outputPath) + ".manifest"), manifest.ToString());
            return manifest;
        }
#endif

        // 最终内部处理bundle的接口
        private static void BuildBundles_Internal(Manifest manifest, Build lastBuild = null, bool useCache = false)
        {
            if (manifest == null)
            {
                return;
            }

            // 打包时强制打开LOG
            Logger.Loggable = true;

            // 所有的asset列表
            Dictionary<string, Asset> pathWithAssets = new Dictionary<string, Asset>();
            // 所有的bundle列表
            List<BundleBuild> bundleBuilds = new List<BundleBuild>();

            Logger.T(() =>
            {
                if (preprocessBuildBundles != null)
                {
                    preprocessBuildBundles.Invoke(manifest);
                }
                
                Logger.I("+++++++++++++ BuildGroups +++++++++++++");
                // 将所有的bundle信息从xasset设置的配置中整理好；通过bundleBuilds返回
                manifest.BuildGroups(pathWithAssets, bundleBuilds);
                UnityEditor.EditorUtility.SetDirty(manifest);
                
                if (bundleBuilds.Count > 0)
                {
                    var assetPath = AssetDatabase.GetAssetPath(manifest);
                    var platform = EditorUserBuildSettings.activeBuildTarget;
                    var outputFolder = EditorUtility.PlatformBuildPath;
                    
                    Logger.I("+++++++++++++ AssetBundleBuild {0}.", manifest.name);
                    
                    // 将xasset组织好的ab，返回成Untiy最终打包的数据结构
                    var builds = ListBundleTo_UnityAssetBundleBuild(bundleBuilds, lastBuild, manifest.name);
                    WriteBundlesLog(builds, manifest.name);
                    WriteBundleDepends(bundleBuilds, pathWithAssets, manifest.name);
                    
                    Logger.I("+++++++++++++ Begin to build for {0}.", manifest.name);

                    // 打包的时候需要增加这几个选项
                    // BuildAssetBundleOptions.DisableLoadAssetByFileName 不让用名字加载
                    // BuildAssetBundleOptions.DisableLoadAssetByFileNameWithExtension 不让用名字+后缀加载
                    // BuildAssetBundleOptions.AssetBundleStripUnityVersion 不加Unity版本号
                    // Unable to use flags DisableWriteTypeTree and StripUnityVersion together
                    // BuildAssetBundleOptions bundleOptions = manifest.buildAssetBundleOptions |
                    //                                         BuildAssetBundleOptions.DeterministicAssetBundle |
                    //                                         BuildAssetBundleOptions.DisableLoadAssetByFileName |
                    //                                         BuildAssetBundleOptions.DisableLoadAssetByFileNameWithExtension |
                    //                                         BuildAssetBundleOptions.StrictMode;

                    BuildAssetBundleOptions bundleOptions = manifest.buildAssetBundleOptions;
                    if (manifest.name.Contains("DataTable"))
                    {
                        bundleOptions = BuildAssetBundleOptions.None;
                    }
                    bundleOptions |= BuildAssetBundleOptions.DeterministicAssetBundle |
                        BuildAssetBundleOptions.DisableLoadAssetByFileName |
                        BuildAssetBundleOptions.DisableLoadAssetByFileNameWithExtension |
                        BuildAssetBundleOptions.AssetBundleStripUnityVersion |
                        BuildAssetBundleOptions.StrictMode;
                    
                    // 如果没有定义使用缓存就全量打包
                    if (useCache == false)
                    {
                        bundleOptions |= BuildAssetBundleOptions.ForceRebuildAssetBundle;
                    }
                    
                    // 这个是为了防止bundle模式在Editor下运行崩溃。。。
                    // 原因是：TMP的m_SourceFontFile_EditorRef
                    // https://answer.uwa4d.com/question/616a8e668f8c834241dfd78b
#if FINAL_RELEASE
                    bundleOptions |= BuildAssetBundleOptions.IgnoreTypeTreeChanges;
#else
                    bundleOptions |= BuildAssetBundleOptions.IgnoreTypeTreeChanges;
#endif

#if BUILTIN_BUILD
                    AssetBundleManifest assetBundleManifest = null;
#else
                    CompatibilityAssetBundleManifest assetBundleManifest = null;
#endif
                    try
                    {
                        assetBundleManifest = BuildAssetBundles(outputFolder, builds, bundleOptions, platform);
                    }
                    catch (Exception e)
                    {
                        Logger.E("BuildAssetBundles exception {0}.", e.Message);
                    }

                    manifest = EditorUtility.GetOrCreateAsset<Manifest>(assetPath);

                    // 禁止写太多无意义的堆栈
                    Application.SetStackTraceLogType(LogType.Error, StackTraceLogType.None);
                    Application.SetStackTraceLogType(LogType.Exception, StackTraceLogType.None);
                    Application.SetStackTraceLogType(LogType.Assert, StackTraceLogType.None);
                    Application.SetStackTraceLogType(LogType.Log, StackTraceLogType.None);
                    Application.SetStackTraceLogType(LogType.Warning, StackTraceLogType.None);

                    Debug.LogFormat("OKOKOK!");
                    
                    // 重新获取之前的版本文件，因为打包后，之前的内存数据会被 Unity 清空
                    Logger.Loggable = true;
                    Logger.I("+++++++++++++ Build [{0}] ok.", manifest.name);

                    if (assetBundleManifest == null)
                    {
                        var msg = "Failed to build {0} with bundles, because assetBundleManifest == null.";
                        Logger.E(msg, manifest.name);
                        throw new Exception(msg);
                        return;
                    }

                    manifest.CreateVersions(assetBundleManifest, bundleBuilds);
                }
                else
                {
                    var msg = "Nothing to build for " + manifest.name;
                    Debug.LogErrorFormat("Nothing to build for {0}.", manifest.name);
                    throw new Exception(msg);
                    return;
                    // if (rawBundleBuilds.Count <= 0 && manifest.GetCurrentBuild().GetBundles().Count == bundleBuilds.Count)
                    // {
                    //     Debug.LogFormat("Nothing to build for {0}.", manifest.name);
                    // }
                    // manifest.CreateVersions(null, bundleBuilds);
                }
                if (postprocessBuildBundles != null)
                {
                    postprocessBuildBundles.Invoke(manifest);
                }
            }, $"Build Bundles for {manifest.name}");

            // if (!CheckAssetsReference(manifest, assets, dependencyWithAssets, out _))
            // {
            //     Log.Error("Manifest 资源存在相互引用??");
            //     //throw new Exception("Manifest 资源存在相互引用");
            // }
        }

        /// <summary>
        ///     检测Manifest资源引用错误
        /// </summary>
        public static void CheckManifestRefs()
        {
            var settings = Settings.GetDefaultSettings();
            foreach (var manifest in settings.manifests)
            {
                List<Asset> assets = null;
                Dictionary<string, List<Asset>> dependencyWithAssets = null;
                
                // 暂时不知道意义
               // Logger.T(() => manifest.BuildGroups(out _, out _, out assets, out dependencyWithAssets), $"检测资源引用 {manifest.name}");

                CheckAssetsReference(manifest, assets, dependencyWithAssets, out var logFile);
                if (!string.IsNullOrEmpty(logFile))
                {
                    UnityEditor.EditorUtility.OpenWithDefaultApp(logFile);
                }
            }
        }

        private static string GetTimeForNow()
        {
            return DateTime.Now.ToString("yyyyMMdd-HHmmss");
        }
        
        public static string GetBundleVersion()
        {
            return UnityEditor.PlayerSettings.bundleVersion;
        }

        /// <summary>
        ///     获取打包播放器的目标名字
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public static string GetBuildTargetName(BuildTarget target)
        {
            var productName = "xc" + "-v" + UnityEditor.PlayerSettings.bundleVersion + ".";
            var targetName = $"/{productName}-{GetTimeForNow()}";
            switch (target)
            {
                case BuildTarget.Android:
                    return targetName + ".apk";
                case BuildTarget.StandaloneWindows:
                case BuildTarget.StandaloneWindows64:
                    return targetName + ".exe";
                case BuildTarget.StandaloneOSX:
                    return targetName + ".app";
                default:
                    return targetName;
            }
        }

        /// <summary>
        ///     打包播放器
        /// </summary>
        public static void BuildPlayer()
        {
            var path = Path.Combine(Environment.CurrentDirectory, "Build");
            if (path.Length == 0)
            {
                return;
            }

            var levels = new List<string>();
            foreach (var scene in EditorBuildSettings.scenes)
            {
                if (scene.enabled)
                {
                    levels.Add(scene.path);
                }
            }

            if (levels.Count == 0)
            {
                Logger.I("Nothing to build.");
                return;
            }

            var buildTarget = EditorUserBuildSettings.activeBuildTarget;
            var buildTargetName = GetBuildTargetName(buildTarget);
            if (buildTargetName == null)
            {
                return;
            }

            var buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = levels.ToArray(),
                locationPathName = path + buildTargetName,
                target = buildTarget,
                options = EditorUserBuildSettings.development
                    ? BuildOptions.Development
                    : BuildOptions.None
            };
            BuildPipeline.BuildPlayer(buildPlayerOptions);
        }

        public static void Clear()
        {
            Settings.GetDefaultSettings().Clear();
        }

        public static void CopyToStreamingAssets()
        {
            Settings.GetDefaultSettings().CopyToStreamingAssets();
        }
        
        public static string key_UnityRaw = "UnityRaw";
        public static void BundleEncode(string filepath)
        {
            // Logger.T(() =>
            // {
            //     Debug.Log("**************************************************************");
            //     Debug.Log("对bundle进行加密");
            //     Debug.Log("**************************************************************\n\n");
                byte[] keybyte = System.Text.Encoding.UTF8.GetBytes(key_UnityRaw);
                filepath = Path.Combine(EditorUtility.PlatformBuildPath, filepath);
                if (!File.Exists(filepath))
                    return;
                
                if (filepath.EndsWith(".bundle"))
                {
                    //Debug.Log($"--> {filepath}");
                    byte[] bytedata = File.ReadAllBytes(filepath);

                    // byte[] bdatas = new byte[1024];
                    // var fs = new FileStream(filepath, FileMode.Open);
                    // var br = new BinaryReader(fs);
                    // long read_count = fs.Length / 1024 + (fs.Length % 1024) != 0 ? 1 : 0;
                    // for (int i = 0; i < read_count; ++i)
                    // {
                    //     int c = br.Read(bdatas, i * 1024, 1024);
                    // }


                    // byte[] tmpbyte = new byte[bytedata.Length + keybyte.Length];
                    // Array.Copy(keybyte, tmpbyte, keybyte.Length);
                    // Array.Copy(bytedata, 0, tmpbyte, keybyte.Length, bytedata.Length);
                    FileStream sw = File.OpenWrite(filepath);
//                    sw.Write(tmpbyte, 0, tmpbyte.Length);
                    sw.Write(keybyte, 0, keybyte.Length); // 这里必须要保证keybyte.Length == 8
                    sw.Write(bytedata, 0, bytedata.Length);
                    sw.Close();
                }
            // }, "BundleEncode");
        }

        public static void ClearHistory()
        {
            var settings = Settings.GetDefaultSettings();
            var usedFiles = new List<string>
            {
                EditorUtility.GetPlatformName(),
                EditorUtility.GetPlatformName() + ".manifest"
            };
            foreach (var manifest in settings.manifests)
            {
                var build = manifest.GetCurrentBuild();
                usedFiles.Add(manifest.name + ".json");
                usedFiles.Add(manifest.name.ToLower());
                usedFiles.Add(VEngine.Manifest.GetVersionFile(manifest.name.ToLower()));
                foreach (var bundle in build.bundles)
                {
                    usedFiles.Add(bundle.nameWithAppendHash);
                    usedFiles.Add(bundle.name + ".manifest");
                }
            }

            var files = Directory.GetFiles(EditorUtility.PlatformBuildPath);
            foreach (var file in files)
            {
                var name = Path.GetFileName(file);
                if (usedFiles.Contains(name))
                {
                    continue;
                }
                File.Delete(file);
                Logger.I("Delete {0}", file);
            }
        }


        private static bool CheckAssetsReference(Manifest manifest, List<Asset> assets, Dictionary<string, List<Asset>> dependencyWithAssets, out string logFile)
        {
            logFile = null;
            if (manifest == null || assets == null || dependencyWithAssets == null)
                return true;
            
            bool succ = true;
            
            if (manifest.name == "GameRes")
            {
                int index = 0;
                var builder = new StringBuilder();
                
                builder.AppendLine(manifest.name);
                
                foreach (var i in assets)
                {
                    if (i.path.StartsWith("Assets/Download") || i.path.StartsWith("Assets/PackageRes"))
                    {
                        index++;
                        succ = false;
                        builder.AppendLine($"[{index}] {i.path}@{i.bundle}");
                        if (dependencyWithAssets.TryGetValue(i.path, out var refs))
                        {
                            for (var j = 0; j < refs.Count; j++)
                            {
                                var r = refs[j];
                                builder.AppendLine($"  - {j} {r.path}@{r.bundle}");
                            }
                        }
                    }
                }

                logFile = $"{EditorUtility.PlatformBuildPath}/RefErr_{manifest.name}.txt";
                File.WriteAllText(logFile, builder.ToString());
                return succ;
            }
            else if (manifest.name == "Download" || manifest.name == "PackageRes")
            {
                int index = 0;
                var builder = new StringBuilder();
                
                builder.AppendLine(manifest.name);
                
                foreach (var i in assets)
                {
                    if (!i.path.StartsWith($"Assets/{manifest.name}") && !i.path.StartsWith("Packages"))
                    {
                        index++;
                        succ = false;
                        builder.AppendLine($"[{index}] {i.path}@{i.bundle}");
                        if (dependencyWithAssets.TryGetValue(i.path, out var refs))
                        {
                            for (var j = 0; j < refs.Count; j++)
                            {
                                var r = refs[j];
                                builder.AppendLine($"  - {j} {r.path}@{r.bundle}");
                            }
                        }
                    }
                }
                logFile = $"{EditorUtility.PlatformBuildPath}/RefErr_{manifest.name}.txt";
                File.WriteAllText(logFile, builder.ToString());
                return succ;
            }

            return true;
        }
        
        /// <summary>
        /// 检测资源重复打包到多个bundle
        /// </summary>
        public static void CheckAssetDuplicate()
        {
            var assetNameToBundles = new Dictionary<string, List<string>>();
            var settings = Settings.GetDefaultSettings();
            foreach (var manifest in settings.manifests)
            {
                var build = manifest.GetCurrentBuild();
                foreach (var bundle in build.bundles)
                {
                    var b = AssetBundle.LoadFromFile(Settings.GetBuildPath(bundle.nameWithAppendHash));
                    if (b == null)
                    {
                        continue;
                    }
                    
                    var allAssetNames = b.GetAllAssetNames();
                    foreach (var a in allAssetNames)
                    {
                        if (assetNameToBundles.TryGetValue(a, out var list))
                        {
                            list.Add(bundle.nameWithAppendHash);
                        }
                        else
                        {
                            assetNameToBundles.Add(a, new List<string>{bundle.nameWithAppendHash});
                        }
                    }
                
                    b.Unload(true);
                }
            }

            var builder = new StringBuilder();
            foreach (var i in assetNameToBundles)
            {
                if (i.Value.Count > 1)
                {
                    builder.AppendLine(i.Key);
                    builder.Append("\t").AppendLine(string.Join("\n\t", i.Value));
                }
            }
            File.WriteAllText(Path.Combine(EditorUtility.PlatformBuildPath, "asset_duplicate.txt"), builder.ToString());
        }
    }
}
#endif



