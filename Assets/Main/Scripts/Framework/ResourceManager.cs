using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using GameFramework;
using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.UI;
using VEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

//
// 资源管理
//
public class ResourceManager
{
    private string debugDownloadURL_ = "http://10.7.88.21:84/gameservice/get3dfile.php?file=";
    private string onlineDownloadURL_ = "https://cdn-lm.readygo.tech/hotupdate/";
    //
    // public readonly string GameResManifestName = "gameres";
    // public readonly string DataTableManifestName = "datatable";
    // public readonly string LuaManifestName = "lua";

    private string[] manifests;
    private string bkgroundManifest;
    private string packageResManifest;
    private float lastTimePerSecondUpdate;
    private DownloadUpdateBkground _updateBkground;

    //这个是为了缓存pvelevel和pvelevel_download交换目录导致的新路径的
    private Dictionary<string, string> swapPrefabPathCache = new Dictionary<string, string>();
    

    public string DownloadURL {
        set
        {
            if (CommonUtils.IsDebug())
            {
                debugDownloadURL_ = value;
            }
            else
            {
                onlineDownloadURL_ = value;
            }
        }
        get{
            if (CommonUtils.IsDebug())
            {
                return debugDownloadURL_;
            }
            else
            {
                return onlineDownloadURL_;
            }
        }
    }

    public enum PreloadType { Cache, KeepAlive }

    public class PreloadCache
    {
        public VEngine.Asset asset;
        public float expiredTime;
    }

    private const float CacheTime = 300.0f;
    private Dictionary<string, PreloadCache> preloadCache = new Dictionary<string, PreloadCache>();
    private List<string> keysRemove = new List<string>();

    public bool Loggable
    {
        get { return VEngine.Logger.Loggable;}
        set { VEngine.Logger.Loggable = value; }
    }
    
    // 设置AB加载缓存大小；直接用LUA调用了，不用这里了
    // https://blog.unity.com/engine-platform/unity-asset-bundles-tips-pitfalls
    public static void SetABBudget(uint kb)
    {
        AssetBundle.memoryBudgetKB = kb;
    }

    public static uint GetABBudget()
    {
        return AssetBundle.memoryBudgetKB;
    }
    
    // 清除整个xAsset底层的引用数据
    public static void ClearVersions()
    {
        Loadable.ForceUnloadLoading();
        Asset.Cache?.Clear();
        Bundle.Cache?.Clear();
    }

    public void Initialize(Action<bool> onComplete)
    {
        swapPrefabPathCache.Clear();
        var operation = VEngine.Versions.InitializeAsync();
        operation.completed += delegate
        {
            if (operation.status == VEngine.OperationStatus.Failed)
            {
                CommonUtils.LogErrorWithPost($"#ResourceManager# operation.error:{operation.error}");
            }

            onComplete?.Invoke(operation.status == VEngine.OperationStatus.Success);
        };
        
        manifests = operation.manifests.ToArray();
        bkgroundManifest = operation.bkgroundManifest;
        packageResManifest = operation.packageResManifest;
        
#if SKIP_UPDATE
        VEngine.Versions.SkipUpdate = true;
#endif
        Log.Info(">>>SkipUpdate {0}", VEngine.Versions.SkipUpdate);
        VEngine.Versions.DownloadURL = DownloadURL;
        VEngine.Versions.getDownloadURL = GetDownloadURL;
        
        SpriteAtlasManager.atlasRegistered += OnAtlasRegistered;
        SpriteAtlasManager.atlasRequested += OnAtlasRequested;
    }

    private string GetDownloadURL(string filename)
    {
        var platformPath = VEngine.Versions.PlatformName;
        string package_name = GameEntry.Sdk.GetGPPackageName();
        return $"{DownloadURL}{package_name}/{platformPath}/{filename}";
    }

    public string[] GetManifestNames()
    {
        return manifests;
    }

    public string GetBkgroundManifestName()
    {
        return bkgroundManifest;
    }

    public string GetPackageResManifestName()
    {
        return packageResManifest;
    }

    public string GetTempDownloadPath(string file)
    {
        var ret = $"{Application.temporaryCachePath}/Download/{file}";
        var dir = Path.GetDirectoryName(ret);
        if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        return ret;
    }
    public string GetDownloadDataRootPath()
    {
        return VEngine.Versions.DownloadDataPath;
    }
    
    
    public void OverrideManifest(VEngine.Manifest manifest)
    {
        if (VEngine.Versions.SkipUpdate)
            return;
        
        var from = GetTempDownloadPath(manifest.name);
        var dest = VEngine.Versions.GetDownloadDataPath(manifest.name);
        if (File.Exists(from))
        {
            Log.Debug("Copy {0} to {1}.", from, dest);
            File.Copy(from, dest, true);
        }
        var versionName = VEngine.Manifest.GetVersionFile(manifest.name);
        from = GetTempDownloadPath(versionName);
        if (File.Exists(from))
        {
            var path = VEngine.Versions.GetDownloadDataPath(versionName);
            Log.Debug("Copy {0} to {1}.", from, path);
            File.Copy(from, path, true);
        }
        if (!VEngine.Versions.IsChanged(manifest.name))
        {
            Log.Debug("OverrideManifest no changed! {0}", manifest.name);
            return;
        }
        manifest.Load(dest);
        Log.Debug($"Load manifest {dest} {manifest.version}");
        VEngine.Versions.Override(manifest);
    }
    
    //
    // 更新所有 Manifest
    //
    // public VEngine.UpdateVersions UpdateManifests()
    // {
    //     return VEngine.Versions.UpdateAsync(manifests);
    // }

    //
    // 获取更新文件总大小
    //
    public ulong GetDownloadSize(DownloadType downloadType, List<VEngine.Manifest> manifests, List<VEngine.DownloadInfo> downloadInfos)
    {
        if (VEngine.Versions.SkipUpdate || manifests == null || manifests.Count == 0)
            return 0;
        var debugStr = string.Join(",", manifests.Select(x => x.name.ToString()).ToArray());
        Debug.Log("#bundle# GetDownloadSize manifests:" + debugStr);
        ulong totalSize = 0;
        downloadInfos.Clear();
        var bundles = VEngine.Versions.GetBundlesWithGroups(manifests.ToArray(), null);
        foreach (var bundle in bundles)
        {
            //过滤非本下载类型的资源
            if (downloadType == DownloadType.Normal)
            {
                if (bundle.resMode == (int) ResMode.Download || bundle.resMode == (int) ResMode.RequestDownload)
                    continue;
            }else if (downloadType == DownloadType.BackGround)
                if (bundle.resMode == (int) ResMode.Normal || bundle.resMode == (int) ResMode.LoadingDownload)
                    continue;

            var savePath = VEngine.Versions.GetDownloadDataPath(bundle.name);
            
            if (!VEngine.Versions.IsDownloaded(bundle))
            {
                if (!downloadInfos.Exists(downloadInfo => downloadInfo.savePath == savePath))
                {
                    totalSize += bundle.size;
                    downloadInfos.Add(new VEngine.DownloadInfo
                    {
                        crc = bundle.crc,
                        url = VEngine.Versions.GetDownloadURL(bundle.name),
                        size = bundle.size,
                        savePath = savePath,
                        resMode = bundle.resMode,
                    });
                    Debug.Log($"#bundle# GetDownloadSize add to downloadInfos! bundle.name:{bundle.name}, size:{bundle.size/1024}K");
                }
                else
                {
                    Debug.Log($"#bundle# GetDownloadSize already exist in downloadInfos! bundle.name:{bundle.name}");
                }
            }
            else
            {
                Debug.Log($"#bundle# GetDownloadSize [2] already in GetDownloadDataPath! bundle.name:{bundle.name}");
            }
        }
        
        return totalSize;
    }

    /// <summary>
    /// 获取资源对应的bundle相关信息
    /// </summary>
    /// <param name="assetPath">资源路径</param>
    /// <param name="needDownloadBundleInfos">需要下载的bundle</param>
    /// <param name="totalSize">资源及依赖总大小</param>
    /// <param name="needDownloadSize">剩余需要下载的大小</param>
    /// <returns>资源是否存在</returns>
    public bool GetBundleInfosOfAsset(string assetPath, List<BundleInfo>needDownloadBundleInfos, out ulong totalSize, out ulong needDownloadSize)
    {
        totalSize = 0;
        needDownloadSize = 0;
        
        if (!Versions.GetDependencies(assetPath, out var curBundle, out var deps))
        {
            return false;
        }

        var totalBundleInfos = deps.ToList();
        totalBundleInfos.Insert(0, curBundle);

        foreach (var bundle in totalBundleInfos)
        {
            var savePath = Versions.GetDownloadDataPath(bundle.name);
            totalSize += bundle.size;
            if (!Versions.IsDownloaded(bundle))
            {
                needDownloadBundleInfos.Add(bundle);
                needDownloadSize += bundle.size;
            }
        }
        
        return true;
    }

    
    /// <summary>
    /// 检查资源是否下载完成 并返回剩余需要下载的大小
    /// </summary>
    /// <param name="assetPath">资源路径</param>
    /// <param name="size">剩余需要下载的大小</param>
    /// <returns>资源是否存在</returns>
    public bool GetNeedDownloadSize(string assetPath, out ulong size)
    {
        size = 0;
        //如果资源及其依赖已经下载完 直接返回
        if (IsAssetDownloaded(assetPath))
        {
            return true;
        }
        
        if (!Versions.GetDependencies(assetPath, out var curBundle, out var deps))
        {
            return false;
        }

        if (!Versions.IsDownloaded(curBundle))
        {
            size += curBundle.size;
        }
        
        foreach (var bundle in deps)
        {
            if (!Versions.IsDownloaded(bundle))
            {
                size += bundle.size;
            }
        }

        return true;
    }

    /// <summary>
    /// 以最高优先级进行下载
    /// </summary>
    /// <param name="downloadBundleList"></param>
    /// <returns></returns>
    public DownloadVersions StartHighestPriorityDownload(List<BundleInfo> downloadBundleList)
    {
        var downloadGroups = new Dictionary<string, DownloadInfo>(downloadBundleList.Count);
        foreach (var bundle in downloadBundleList)
        {
            var savePath = Versions.GetDownloadDataPath(bundle.name);
            if (downloadGroups.ContainsKey(savePath))
            {
                continue;
            }
            
            if(Versions.IsDownloaded(bundle))
                continue;

            var downloadInfo = new DownloadInfo
            {
                crc = bundle.crc,
                url = Versions.GetDownloadURL(bundle.name),
                size = bundle.size,
                savePath = savePath,
                resMode = bundle.resMode,
            };
            
            downloadGroups.Add(savePath, downloadInfo);
        }

        var downloadVersion = Versions.DownloadAsync(downloadGroups.Values.ToArray(), true);
        return downloadVersion;
    }

    
    
    //
    // 下载所有更新
    //
    public VEngine.DownloadVersions DownloadUpdates(List<VEngine.DownloadInfo> downloadInfos)
    {
        var debugStr = string.Join(",", downloadInfos.Select(x => x.savePath.ToString()).ToArray());
        Debug.Log("#bundle# DownloadUpdates downloadInfos:" + debugStr);
        return VEngine.Versions.DownloadAsync(downloadInfos.ToArray());
    }

    public void StartBkgroundDownload_Lua()
    {
        List<string> tmp = new List<string> { "gameres" };
        StartBkgroundDownload(tmp);
    }

    //设置后台最大下载数
    public void SetBkgroundDownloadThread(uint thread_count)
    {
        Download.MaxDownloads = thread_count;
    }

    public void StartBkgroundDownload(List<string> manifestNames)
    {
        var manifests = new List<VEngine.Manifest>();
        foreach (var n in manifestNames)
        {
            var m = VEngine.Versions.GetManifest(n);
            manifests.Add(m);
        }
        var downloadInfos = new List<VEngine.DownloadInfo>();
        var totalSize = GetDownloadSize(DownloadType.BackGround, manifests, downloadInfos);
        if (totalSize > 0)
        {
            _updateBkground = new DownloadUpdateBkground {manifests = new List<VEngine.Manifest>(manifests)};
            _updateBkground.Start(downloadInfos);
            Debug.LogFormat("start bkground download {0}", totalSize);
        }
        else
        {
            Debug.Log("start bkground download but no data!");
        }
    }
    
    public void BeginWhiteListCheck()
    {
        VEngine.Versions.CheckWhiteList = true;
    }

    public bool EndWhiteListCheck()
    {
        VEngine.Versions.CheckWhiteList = false;
        if (VEngine.Versions.WhiteListFailed.Count > 0)
        {
            foreach (var i in VEngine.Versions.WhiteListFailed)
            {
                Log.Info("whitelist failed: {0}", i);
            }
        }
        return VEngine.Versions.WhiteListFailed.Count == 0;
    }
    
    // now表示是否立即停止，一般在结束游戏的时候用
    public void Clear(bool now = false)
    {
        Log.Debug("ResourceManager:Clear");
        
        foreach (var i in preloadCache)
        {
            i.Value.asset.Release();
        }
        preloadCache.Clear();

        ClearInstance();
        
        objectPoolMgr.ClearAllPool(now);
        
        VEngine.Loadable.ClearAll();
        UnloadUnusedAssets(now);
      
        // 结束的时候输出一下资源的日志
#if !FINAL_RELEASE
        objectPoolMgr.DebugOutput();
        InstanceRequest.PrintAllRequests();
#endif
    }

    //
    // 加载资源
    //
    public VEngine.Asset LoadAsset(string path, Type type)
    {
        return VEngine.Asset.Load(path, type);
    }

    public VEngine.Asset LoadAssetAsync(string path, Type type)
    {
        return VEngine.Asset.LoadAsync(path, type);
    }
    
    public VEngine.Asset LoadAllAssetsAsync(string bundle_path, Action<VEngine.Asset> completed = null)
    {
        return VEngine.Asset.LoadAllAssetsAsync(bundle_path, completed);
    }

    public void PreloadAsset(string path, Type type, PreloadType preloadType = PreloadType.Cache)
    {
        var expiredTime = preloadType == PreloadType.Cache ? Time.realtimeSinceStartup + CacheTime : float.MaxValue;
        if (preloadCache.TryGetValue(path, out var cache))
        {
            cache.expiredTime = expiredTime;
        }
        else
        {
            var asset = VEngine.Asset.LoadAsync(path, type);
            preloadCache.Add(path, new PreloadCache {asset = asset, expiredTime = expiredTime});
        }
    }

    //
    // 卸载资源
    //
    public void UnloadAsset(VEngine.Asset asset)
    {
        if (asset != null)
        {
            asset.Release();
        }
    }

    // 资源清单中是否有该资源
    public bool HasAsset(string path)
    {
        var tempPath = path;
        VEngine.AssetInfo asset;
        return VEngine.Versions.GetAsset(ref tempPath, out asset);
        //return VEngine.Versions.GetAsset(ref tempPath) != null;
    }
    
    

    /*
     * 资源是否已下载
     * 这个地方我们做这个处理,如果判定不存在,我们再尝试,pvelevel/pvelevel_download
     */
    public bool IsAssetDownloaded(string path)
    {
        return VEngine.Versions.IsAssetDownloaded(path);
        //每次进来从dic筛选下吧.相比较而言比checkres要好些
        if (swapPrefabPathCache.TryGetValue(path, out string swapPath))
        {
            return true; //如果在这个里面表示之前已经筛选过,而且是已经存在的情况
        }
        else
        {
            var result = VEngine.Versions.IsAssetDownloaded(path);
            if (result == false)
            {
                string newPath = "";
                if (path.Contains(PVEPrefab))
                {
                    newPath = path.Replace(PVEPrefab, PVELevel_Download);
                    result = VEngine.Versions.IsAssetDownloaded(newPath);
                }else if (path.Contains(PVELevel_Download))
                {
                    newPath = path.Replace(PVEPrefab, PVELevel_Download);
                    result = VEngine.Versions.IsAssetDownloaded(newPath);
                }

                if (result == true)
                {
                    swapPrefabPathCache.Add(path, newPath);
                }
            }
            return result;
        }

        

        
    }

    public void UnloadUnusedAssets(bool now = false)
    {
        objectPoolMgr.ClearUnusedPool(now);
        VEngine.Asset.UnloadUnusedAssets();
        VEngine.Bundle.DebugOutputCache();
    }

    public ObjectPoolMgr GetPoolManager()
    {
        return objectPoolMgr;
    }
    
    public void ClearObjectPool()
    {
        objectPoolMgr.ClearUnusedPool();
    }
    
    // 输出所有当前Bundle的细节，为了自动更新使用
    public void DumpBundleDetail()
    {
        Log.Info("====================== DumpBundleDetail ======================");
        
        Dictionary<int, List<string>> d = new Dictionary<int, List<string>>();
        foreach (var VARIABLE in VEngine.Asset.Cache)
        {
            string path = VARIABLE.Value.pathOrURL;
            VEngine.AssetInfo asset;
            var a = VEngine.Versions.GetAsset(ref path, out asset);
            int bundle_id = -1;
            if (a != false)
            {
                bundle_id = asset.bundle;
            }

            List<string> li;
            if (d.TryGetValue(bundle_id, out li))
            {
                li.Append(path);
            }
            else
            {
                li = new List<string>();
                li.Add(path);
                d.Add(bundle_id, li);
            }
        }
         
        Log.Info("++ Using Bundle and Asset");
        foreach (var VARIABLE in VEngine.Bundle.Cache)
        {
            Log.Info("  [BUNDLE] {0}", VARIABLE.Key);
            VEngine.Bundle b = VARIABLE.Value;
            
            List<string> li;
            if (d.TryGetValue(b.GetInfo().id, out li))
            {
                foreach (var v in li)
                {
                    Log.Info("   {0}", v);
                }
            }
        }
        
        Log.Info("++ Loading Bundles");
        foreach (var VARIABLE in VEngine.Loadable.Loading)
        {
            Log.Info("  [BUNDLE] {0}", VARIABLE.pathOrURL);
        }

        Log.Info("++ Unused Bundles");
        foreach (var VARIABLE in VEngine.Bundle.Unused)
        {
            Log.Info("  [BUNDLE] {0}", VARIABLE.pathOrURL);
            
            List<string> li;
            if (d.TryGetValue(VARIABLE.GetInfo().id, out li))
            {
                foreach (var v in li)
                {
                    Log.Info("   {0}", v);
                }
            }
        }

        
        objectPoolMgr.DebugOutput();
        
        return;
    }


    public void CollectGarbage()
    {
        // 输出日志
        Log.Info("CollectGarbage begin");
        objectPoolMgr.DebugOutput();
        VEngine.Asset.DebutOutputCache();
        VEngine.Bundle.DebugOutputCache();
        
        objectPoolMgr.ClearUnusedPool();
        VEngine.Asset.UnloadUnusedAssets();
        
        Log.Info("CollectGarbage end");
        objectPoolMgr.DebugOutput();
        VEngine.Asset.DebutOutputCache();
        VEngine.Bundle.DebugOutputCache();
    }

    public void DebugOutput()
    {
        objectPoolMgr.DebugOutput();
        VEngine.Asset.DebutOutputCache();
        VEngine.Bundle.DebugOutputCache();
    }

    public void DebugLoadCount()
    {
        VEngine.Asset.DebugLoadCount();
    }

    public void RemoveCachedUnusedAssets()
    {
        VEngine.Asset.RemoveCachedUnusedAssets();
    }

    public string GetResVersion()
    {
        return VEngine.Versions.ManifestsVersion;
    }

    public bool IsSimulation
    {
        get { return VEngine.Versions.IsSimulation; }
    }

    public bool SkipUpdate
    {
        get { return VEngine.Versions.SkipUpdate; }
        set { VEngine.Versions.SkipUpdate = value; }
    }

    public bool SplitApk
    {
        get
        {
#if UNITY_EDITOR
            return false;
#endif
#if SPLIT_APK
            return true;
#endif
            return false;
        }
    }

    public void Update()
    {
        UpdateInstance();

        if (Time.realtimeSinceStartup - lastTimePerSecondUpdate >= 3)
        {
            lastTimePerSecondUpdate = Time.realtimeSinceStartup;
            
            UnityUIExtension.Update();
            UpdatePoolClean();
            UpdatePreloadRelease();
        }
        
        _updateBkground?.Update();
    }

    private void UpdatePoolClean()
    {
        objectPoolMgr.TryCleanPool();
    }

    private void UpdatePreloadRelease()
    {
        foreach (var i in preloadCache)
        {
            if (i.Value.expiredTime < Time.realtimeSinceStartup)
            {
                i.Value.asset.Release();
                keysRemove.Add(i.Key);
            }
        }

        if (keysRemove.Count > 0)
        {
            foreach (var key in keysRemove)
            {
                preloadCache.Remove(key);
            }
            keysRemove.Clear();
        }
    }
    
    //========================================================================
    // Sprite late binding
    //========================================================================
    #region SpriteAtlas
    
    private const string AtlasRootPath = "Assets/Main/Atlas/{0}.spriteatlas";
    
    private void OnAtlasRegistered(SpriteAtlas sa)
    {
        Log.Debug("OnAtlasRegistered: {0},{1}", sa.name, Time.frameCount);
    }
    
    private void OnAtlasRequested(string atlasName, System.Action<SpriteAtlas> callback)
    {
        Log.Info("OnAtlasRequested: {0},{1}", atlasName, Time.frameCount);

        var atlasPath = string.Format(AtlasRootPath, atlasName);
        var req = VEngine.Asset.Load(atlasPath, typeof(SpriteAtlas));
        if (!req.isError)
        {
            Log.Info("OnAtlasRequested ok: {0}  in  {1}", atlasName, req.pathOrURL);
            callback(req.asset as SpriteAtlas);
        }
        else
        {
            Log.Info("OnAtlasRequested not found: {0}");
            callback(null);
        }
    }
    
    #endregion
    
    //========================================================================
    // GameObject Instantiate & Destroy
    //========================================================================
    #region Instantiate & Destroy
    
    private static readonly int MAX_INSTANCE_PERFRAME = 60;
    private static readonly float MAX_INSTANCE_TIME = 120.0f;
    private ObjectPoolMgr objectPoolMgr = new ObjectPoolMgr();
    private List<InstanceRequest> toInstanceList = new List<InstanceRequest>();
    private List<InstanceRequest> instancingList = new List<InstanceRequest>();
    //private Dictionary<GameObject, InstanceRequest> gameObject2Request = new Dictionary<GameObject, InstanceRequest>();

    // 在这里做了每帧限制Instance 实例化的数量限制
    private void UpdateInstance()
    {
        int max = MAX_INSTANCE_PERFRAME;
        if (toInstanceList.Count > 0 && instancingList.Count < max)
        {
            int count = Math.Min(max - instancingList.Count, toInstanceList.Count);
            for (var i = 0; i < count; ++i)
            {
                var item = toInstanceList[i];
                if (item.state == InstanceRequest.State.Destroy)
                    continue;

                item.Instantiate();
                instancingList.Add(item);
            }

            toInstanceList.RemoveRange(0, count);
        }

        //var time = DateTime.Now.TimeOfDay.TotalMilliseconds;
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        int insCount = 0;
        for (var i = 0; i < instancingList.Count; i++)
        {
            var item = instancingList[i];
            if (item.Update())
                continue;
           

            instancingList.RemoveAt(i);
            --i;
            ++insCount;

            
#if true
            //double diff = DateTime.Now.TimeOfDay.TotalMilliseconds - time; 
            //if (diff > MAX_INSTANCE_TIME)
            var diff = stopwatch.ElapsedMilliseconds;
            if(stopwatch.ElapsedMilliseconds > MAX_INSTANCE_TIME)
            {
                Log.Debug("resource frame time limit: {0}, instanceCount: {1}, remain: {2}, in queue: {3}", 
                    diff, insCount, instancingList.Count, toInstanceList.Count);
                break;
            }
#endif
        }

        // if (insCount > 0)
        // {
        //     Log.Debug("resource log instance count: {0} use time: {1}", insCount,
        //         DateTime.Now.TimeOfDay.TotalMilliseconds - time);
        // }
    }


    private void ClearInstance()
    {
        foreach (var i in toInstanceList)
        {
            i.Destroy(); 
        }

        foreach (var i in instancingList)
        {
            i.Destroy();
        }
    }

    public ObjectPool GetObjectPool(string prefabPath)
    {
        return objectPoolMgr.GetPool(prefabPath, this);
    }

    public static string PVEPrefab = "Assets/Main/Prefabs/PVELevel/";
    public static string PVELevel_Download = "Assets/Main/Prefabs/PVELevel_Download/";

    private bool m_isMainLevel = true;
    private int m_levelId = 0;

    public void SetMainLevel(bool isMainLevel, int levelid)
    {
        m_isMainLevel = isMainLevel;
        m_levelId = levelid;
    }

    private string GetRealPath_Native(string prefabPath)
    {
#if UNITY_EDITOR
        if (prefabPath.StartsWith(PVEPrefab))
        {
            if (m_isMainLevel) //优先pveprefab,然后再pvedownload
            {
                // if (String.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(prefabPath)))
                if (!File.Exists(prefabPath))
                {
                    Debug.Log($">>>资源不存在: 关卡id: {m_levelId} 资源名称: {prefabPath}");
                    string newstr = prefabPath.Replace(PVEPrefab, PVELevel_Download);
                    swapPrefabPathCache.Add(prefabPath, newstr);
                    prefabPath = newstr;
                }
            }
            else
            {
                string newstr = prefabPath.Replace(PVEPrefab, PVELevel_Download);
                /*
                 *  这个地方不使用AssetPathToGUID,测试发现即使文件被移动了,还是可以取到值.[但是之前测试可以正常返回""的啊。诡异!]这个地方可能需要reimport,但是通过
                 *  unity操作应该可以刷新文件缓存了啊。这个需要查一查
                 */
                // if (!String.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(newstr)))
                if (File.Exists(newstr))
                {
                    swapPrefabPathCache.Add(prefabPath, newstr);
                    prefabPath = newstr;
                }
                else
                {
                    Debug.Log($">>>资源不存在: 关卡id: {m_levelId} 资源名称: {prefabPath}");
                }
            }
        }
#endif
        return prefabPath;
    }

    private string GetRealPath_AB(string prefabPath)
    {
        if (prefabPath.StartsWith(PVEPrefab))
        {
            if (m_isMainLevel) //优先pveprefab,然后再pvedownload
            {
                if (!IsAssetDownloaded(prefabPath))
                {
                    Debug.Log($">>>资源不存在: 关卡id: {m_levelId} 资源名称: {prefabPath}");
                    var newstr = prefabPath.Replace(PVEPrefab, PVELevel_Download);
                    swapPrefabPathCache.Add(prefabPath, newstr);
                }
            }
            else
            {
                string newstr = prefabPath.Replace(PVEPrefab, PVELevel_Download);
                if (IsAssetDownloaded(newstr))
                {
                    swapPrefabPathCache.Add(prefabPath, newstr);
                    prefabPath = newstr;
                }
                else
                {
                    Debug.Log($">>>资源不存在: 关卡id: {m_levelId} 资源名称: {prefabPath}");
                }
            }
        }

        return prefabPath;
    }

    public string GetRealPath(string prefabPath)
    {
        if (swapPrefabPathCache.TryGetValue(prefabPath, out string newPath))
        {
            prefabPath = newPath;
        }
        else
        {
#if UNITY_EDITOR
            if (Versions.IsSimulation)
                return GetRealPath_Native(prefabPath);
            else
            {
                return GetRealPath_AB(prefabPath);
            }
#else
            return GetRealPath_AB(prefabPath);
#endif
        }

        return prefabPath;
    }

    public InstanceRequest InstantiateAsync(string prefabPath, Transform parent = null)
    {
        /*只在这个地方做替换路径,目前涉及到的是基本上都是通过InstantiateAsyncId 这个来做的,所以只在这个地方加
            不然太浪费了
         */
        prefabPath = GetRealPath(prefabPath); 
        var req = new InstanceRequest(prefabPath, parent);
        toInstanceList.Add(req);
        return req;
    }

    #endregion
}

public class InstanceRequest
{
    private string prefabPath;
    private ObjectPool pool;
    private int req_index;
    private int req_priority;
    private bool alwaysHold = false;

#if !FINAL_RELEASE
    private static int request_count = 1;
    private static Dictionary<int, InstanceRequest> all_request = new Dictionary<int, InstanceRequest>();
#endif

    public void SetAlwaysHold(bool hold)
    {
        alwaysHold = hold;
    }

    public enum State
    {
        Init, Loading, Instanced, Destroy
    }

    public string PrefabPath
    {
        get { return prefabPath; }
    }

    public bool isDone { get; private set; }
    // 加这个标记是为了LUA端兼容，代码判断的是req.isError。其实InstantiateAsync的返回是不存在的这个属性的。
    public bool isError; 

    public State state;
    public GameObject gameObject;
    public event Action<InstanceRequest> completed;
    public Transform presetParent;
    
    public InstanceRequest(string prefabPath, Transform parent = null)
    {
        this.prefabPath = prefabPath;
        presetParent = parent;
        state = State.Init;
    }
    
    public void Instantiate()
    {
        pool = GameEntry.Resource.GetObjectPool(prefabPath);
        if (pool != null)
        {
            if (req_priority > 0)
            {
                pool.SetPriority(req_priority);
            }
            
            if (alwaysHold)
            {
                pool.AlwaysHold = alwaysHold;
            }
            
            pool.AddInstanceRecord(this);
        }

        state = State.Loading;
        
#if !FINAL_RELEASE
        req_index = ++request_count;
        all_request[req_index] = this;
#endif
    }

    public void Destroy(bool backToPool = true)
    {
        if (state == State.Destroy)
        {
#if !FINAL_RELEASE
                Log.Error("#ResourceManager# request is already in destroy!!! {0}", PrefabPath);
#endif
        }

        pool?.RemoveInstanceRecord(this);

        if (state == State.Instanced)
        {
            if (gameObject != null)
            {
                pool?.DeSpawn(gameObject, backToPool);
                gameObject = null;
                pool = null;
            }
            else
            {
#if !FINAL_RELEASE
                Log.Error("#ResourceManager# destroy but gameObject is null! PrefabPath: {0}", PrefabPath);
#endif
            }
        }
        else
        {
            if (gameObject != null)
            {
                Log.Error("#ResourceManager# not instanced but has gameObject! PrefabPath: {0}", PrefabPath);
            }
        }
        
        state = State.Destroy;
        completed = null;
        
#if !FINAL_RELEASE
        all_request.Remove(req_index);
#endif

    }

    public bool Update()
    {
        if (state == State.Destroy)
            return false;
        if (!pool.IsAssetLoaded)
            return true;
        if (prefabPath.Equals("Assets/Main/Prefabs/Monsters/Zombie01.prefab"))
        {
            var a = 1;
        }

        try
        {
            if (gameObject == null)
            {
                gameObject = pool.Spawn(presetParent);
            }
            else
            {
                CommonUtils.LogErrorWithPost($"#ResourceManager# gameObject already exist! why ??? prefabPath : {prefabPath}");
            }
            
            state = State.Instanced;
        }
        catch (Exception ex)
        {
            CommonUtils.LogErrorWithPost($"#ResourceManager# Spawn Exception prefabPath : {prefabPath}, error : {ex.Message}");
        }

        isDone = true;
        if (gameObject == null)
        {
            CommonUtils.LogErrorWithPost($"#ResourceManager# Error gameObject is null! prefabPath : {prefabPath}");
            isError = true;
        }
        
        try
        {
            completed?.Invoke(this);
        }
        catch (Exception ex)
        {
            CommonUtils.LogErrorWithPost($"#ResourceManager# callback is error! prefabPath :{prefabPath} error: {ex.Message}");
        }
        finally
        {
            completed = null;
        }
        
        return false;
    }

    public void SetPriority(int priority)
    {
        req_priority = priority;
    }

    public static void PrintAllRequests()
    {
#if !FINAL_RELEASE
        Debug.LogErrorFormat("remain Requests: {0}", all_request.Count);
        foreach (var r in all_request)
        {
            Debug.LogErrorFormat("++ prefab : {0}", r.Value.PrefabPath);
        }
#endif
    }
}

//
// UI扩展
//
public static class UnityUIExtension
{
    static List<UnityEngine.Object> keyToRemove = new List<UnityEngine.Object>(100);
    static readonly Dictionary<UnityEngine.Object, VEngine.Asset> AllRefs = new Dictionary<UnityEngine.Object, VEngine.Asset>();
    
    public static void LoadSprite(this Image image, string spritePath, string defaultSprite = null)
    {
        if (AllRefs.TryGetValue(image, out var asset))
        {
            asset.Release();
            AllRefs.Remove(image);
        }
        asset = LoadSprite(spritePath, defaultSprite);
        
#if UNITY_EDITOR
        if (asset == null)
        {
            Debug.LogWarningFormat("LoadSprite not found: {0}", spritePath);
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.LuaTraceback();
            }   
        }
#endif
        
        if (asset != null && !asset.isError)
        {
            AllRefs.Add(image, asset);
            image.sprite = asset.asset as Sprite;
        }
    }
    
    public static void LoadSprite(this CircleImage image, string spritePath, string defaultSprite = null)
    {
        if (AllRefs.TryGetValue(image, out var asset))
        {
            asset.Release();
            AllRefs.Remove(image);
        }
        asset = LoadSprite(spritePath, defaultSprite);
        if (asset != null && !asset.isError)
        {
            AllRefs.Add(image, asset);
            image.sprite = asset.asset as Sprite;
        }
    }
    
    public static void LoadSprite(this SpriteRenderer spriteRenderer, string spritePath, string defaultSprite = null)
    {
        if (AllRefs.TryGetValue(spriteRenderer, out var asset))
        {
            asset.Release();
            AllRefs.Remove(spriteRenderer);
        }
        asset = LoadSprite(spritePath, defaultSprite);
        if (asset != null && !asset.isError)
        {
            AllRefs.Add(spriteRenderer, asset);
            spriteRenderer.sprite = asset.asset as Sprite;
        }
    }
    
    public static void LoadSprite(this SpriteMask spriteMask, string spritePath, string defaultSprite = null)
    {
        if (AllRefs.TryGetValue(spriteMask, out var asset))
        {
            asset.Release();
            AllRefs.Remove(spriteMask);
        }
        asset = LoadSprite(spritePath, defaultSprite);
        if (asset != null && !asset.isError)
        {
            AllRefs.Add(spriteMask, asset);
            spriteMask.sprite = asset.asset as Sprite;
        }
    }
    
    public static void LoadSprite(this SpriteMeshRenderer meshRenderer, string spritePath, string defaultSprite = null)
    {
        if (AllRefs.TryGetValue(meshRenderer, out var asset))
        {
            asset.Release();
            AllRefs.Remove(meshRenderer);

#if UNITY_EDITOR
            // 这个表示当前和要加载的图片一样。。。。
            if (asset.pathOrURL.Contains(spritePath))
            {
                Debug.LogWarningFormat("LoadSprite same!!! {0}", spritePath);
                
                // if (GameEntry.Lua != null)
                // {
                //     GameEntry.Lua.LuaTraceback();
                // }
            }
#endif
        }
        asset = LoadSprite(spritePath, defaultSprite);
        
#if UNITY_EDITOR
        if (asset == null)
        {
            Debug.LogWarningFormat("LoadSprite not found: {0}", spritePath);
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.LuaTraceback();
            }   
        }
#endif
        
        if (asset != null && !asset.isError)
        {
            AllRefs.Add(meshRenderer, asset);
            meshRenderer.sprite = asset.asset as Sprite;
        }
    }

    public static void Update()
    {
        foreach (var kv in AllRefs)
        {
            var obj = kv.Key;
            if (obj == null)
            {
                kv.Value.Release();
                keyToRemove.Add(obj);
            }
        }

        if (keyToRemove.Count > 0)
        {
            foreach (var k in keyToRemove)
            {
                AllRefs.Remove(k);
            }
            keyToRemove.Clear();
        }
    }
    
    private static VEngine.Asset LoadSprite(string spritePath, string defaultSprite)
    {
#if UNITY_EDITOR
        if (spritePath.IsNullOrEmpty())
        {
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.LuaTraceback();
            }
        }
#endif
        
        if (!spritePath.EndsWith(".png"))
        {
            // 需要在LUA内就把png补齐，不要传递到这里再产生一次无意义的GC了。
#if UNITY_EDITOR
            Debug.LogWarningFormat("LoadSprite no png ext!! {0}", spritePath);
#endif
            spritePath += ".png";
        }
        
        var req = VEngine.Asset.Load(spritePath, typeof(Sprite));
        if (req == null || req.isError)
        {
            // 加载失败：打印完整 path，便于定位资源/寻址问题
            Debug.LogErrorFormat("LoadSprite failed, full path: {0}", spritePath);
        }
        if ((req == null || req.isError) && !string.IsNullOrEmpty(defaultSprite))
        {
            if (!defaultSprite.EndsWith(".png"))
            {
                defaultSprite += ".png";
            }
            req = VEngine.Asset.Load(defaultSprite, typeof(Sprite));
        }

        return req;
    }
    
    
    
#region ScrollRect
    public static void SetHorizontalNormalizedPosition(this ScrollRect scrollRect, float ratio)
    {
        scrollRect.horizontalNormalizedPosition = ratio;
    }

    public static float GetHorizontalNormalizedPosition(this ScrollRect scrollRect)
    {
        return scrollRect.horizontalNormalizedPosition;
    }

    #endregion
    
}


//
// 后台下载更新
//
class DownloadUpdateBkground
{
    public List<VEngine.Manifest> manifests;

    private VEngine.DownloadVersions _downloadVersions;
    
    public void Start(List<VEngine.DownloadInfo> downloadInfos)
    {
        _downloadVersions = VEngine.Versions.DownloadAsync(downloadInfos.ToArray());
    }

    public void Update()
    {
        if (_downloadVersions != null && _downloadVersions.isDone)
        {
            if (_downloadVersions.isError)
            {
                var downloadInfos = new List<VEngine.DownloadInfo>();
                var totalSize = GameEntry.Resource.GetDownloadSize(DownloadType.Normal, manifests, downloadInfos);
                if (totalSize > 0)
                {
                    Log.Debug("restart bkground download {0}", totalSize);
                    Start(downloadInfos);
                }
                else
                {
                    _downloadVersions = null;
                    Log.Debug("finish bkground download 1");
                }
            }
            else
            {
                _downloadVersions = null;
                Log.Debug("finish bkground download 2");
            }
        }
    }
}





