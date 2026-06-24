using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using GameFramework;
using GameKit.Base;
using UnityEngine;


public class ApplicationLaunch : MonoBehaviour
{
    private static ApplicationLaunch _instance;
    public static ApplicationLaunch Instance => _instance;

    //这里缓存了lua appStartLoading中的uiLoading的request，之所以在这里缓存是因为热更Reload时，不想对uiLoading立即Destroy(立即Destroy会闪一下黑屏)
    //而是等新的uiLoading加载后再Destroy旧的loading,但这个时候lua因为做了Shutdown，丢失了对oldLoading的request引用。因此将loading的request放到这里。
    public static InstanceRequest uiLoadingRequest;

    private int m_ScreenWidth;
    private int m_ScreenHeight;
    private bool m_toRotate = false;
    private bool m_forceToInit = false;
    
    private bool _isReloadGame;
    private bool _isQuitGame = false; // 是否退出了游戏
    public bool IsNeedCheckResVer // 是否需要检测ResVer；标识是否需要执行CheckResVersion这个状态
    {
        get;
        set;
    } = true;

    public Dictionary<string, Shader> m_kvNameToShader = new Dictionary<string, Shader>(128);
    
    // 配置的zip处理
    public ZipDataTable _zipDataTable;
    
    /*public ObjectCulling GetObjectCull()
    {
        return GetComponent<ObjectCulling>();
    }*/

    

    private string deepLinkUrl = "";
    private bool isInitDone = false;
    void Awake()
    {
#if !UNITY_EDITOR
        // 普通 LOG 输出不输出整个栈了
        Application.SetStackTraceLogType(LogType.Error, StackTraceLogType.ScriptOnly);
        Application.SetStackTraceLogType(LogType.Exception, StackTraceLogType.ScriptOnly);
        Application.SetStackTraceLogType(LogType.Assert, StackTraceLogType.ScriptOnly);
        Application.SetStackTraceLogType(LogType.Log, StackTraceLogType.None);
        Application.SetStackTraceLogType(LogType.Warning, StackTraceLogType.None);
#endif

        m_ScreenWidth = Screen.width;
        m_ScreenHeight = Screen.height;
        
        // 添加深度链接激活事件的监听
        Application.deepLinkActivated += OnDeepLinkActivated;
        // 检查应用是否通过深度链接启动
        if (!string.IsNullOrEmpty(Application.absoluteURL))
        {
            OnDeepLinkActivated(Application.absoluteURL);
        }
        
        _instance = this;
        DontDestroyOnLoad(gameObject);
        Debug.Log("ROTATION: 1");
        // 在最初的时候进行朝向的调整
        try
        {
            LayoutHelper.CheckCurLayout();
            if (LayoutHelper.CurLayout == LayoutHelper.Layout.Landscape)
            {
                m_toRotate = true;
                if (Screen.orientation != ScreenOrientation.Portrait)
                {
                    m_forceToInit = true;
                }
            }
            LayoutHelper.SetRotation();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
        if (m_toRotate == false)
        {
            RotateDoneToAwake();
        }
#if UNITY_EDITOR //编辑器下不会自动旋转屏幕,所以直接触发
        if (m_toRotate == true)
        {
            RotateDoneToAwake();
            m_toRotate = false;
        }
#endif
    }

    public void RotateDoneToAwake()
    {
        float realtimeSinceStartup = Time.realtimeSinceStartup;
        Log.Info("Application Awake! {0}", realtimeSinceStartup);
        
        GameEntry.Init();
        Application.lowMemory += OnLowMemory;

        // 打点的时候带上一点细节参数
        string param = string.Format("{0}|{1:N2}", SystemInfo.deviceModel, realtimeSinceStartup);
        PostEventLog.Record(PostEventLog.Defines.LAUNCH, param);
        
        // 资源加载的LOG
        VEngine.Logger.Loggable = GameEntry.Setting.GetPublicBool(GameDefines.SettingKeys.RESOURCE_LOGGER, false);
        // Firebase
        //GameEntry.Sdk.CrashlyticsSetCustomValue("VEngineLoggable", VEngine.Logger.Loggable ? "true" :  "false");
        GameEntry.Sdk.CrashlyticsAddLog("ApplicationAwake");
        
        CreateZipDataTable();

        Log.Info("Resource.Initialize.");
        GameEntry.Resource.Initialize(OnResourcesInitialized);
        XLua.LuaDLL.Lua.RegisterUnityLogger();
        CFuncUtils.InitUnityProfile_xLuaDll();


#if !FINAL_RELEASE
        gameObject.AddComponent<ShowFPS>();
#endif
        isInitDone = true;
    }

    private void OnDeepLinkActivated(string url)
    {
        Log.Info("Deep Link Activated: " + url);
        // 在这里解析你的 URL，并根据需要执行相关逻辑
        // 例如，假设 URL 是 "darkwarapp://page?param=msj"
        SetDeepLinkUrl(url);
    }

    public string GetDeepLinkUrl()
    {
        return deepLinkUrl;
    }

    public void SetDeepLinkUrl(string url)
    {
        deepLinkUrl = url;
    }
    
    private void Start()
    {
        Debug.Log("#zlh# #audioSettings# register listener!");
        AudioSettings.OnAudioConfigurationChanged += OnAudioConfigurationChanged;
    }

    private static void OnAudioConfigurationChanged(bool t)
    {
        Debug.Log($"#zlh# #audioSettings# step in OnAudioConfigurationChanged t:{t}!");
        var audioSources = FindObjectsOfType<AudioSource>();
        Debug.Log($"#zlh# #audioSettings# audioSources count is :{audioSources.Length}!");
        foreach (var audioSource in audioSources)
        {
            if (audioSource != null)
            {
                audioSource.Play();
            }
        }
    }
    
    private void OnDestroy()
    {
        if (isInitDone == false)
            return;
        // 添加深度链接激活事件的监听
        Application.deepLinkActivated -= OnDeepLinkActivated;
        Debug.Log("#zlh# #audioSettings# unregister listener!");
        AudioSettings.OnAudioConfigurationChanged -= OnAudioConfigurationChanged;
        
        if (_isQuitGame && GameEntry.Lua != null)
        {
            GameEntry.Lua.Shutdown();
        }
    }

    private void OnApplicationQuit()
    {
        if (isInitDone == false)
            return;
        _isQuitGame = true;
        Debug.Log("app quit real begin");
        try
        {
            PostEventLog.Record(PostEventLog.Defines.APP_QUIT);
            
            GameObjectPool.Instance.ClearPool();
            GameEntry.Shutdown(true, false);
            PostEventLog.stop();
        }
        catch (Exception e)
        {
            Log.Error("quit error: {0}", e.StackTrace);
        }
    }
    
    private void LateUpdate()
    {
        if (m_forceToInit)
        {
            this.m_ScreenHeight = Screen.height;
            this.m_ScreenWidth = Screen.width;
            RotateDoneToAwake();
            m_toRotate = false;
            m_forceToInit = false;
            LayoutHelper.SetCanvas(); //这个地方调用的意义是,如果已经在游戏中,点击旋转。这个时候需要再次触发一下
            return;
        }else if(this.m_ScreenWidth!=Screen.width||this.m_ScreenHeight!=Screen.height)
        {
            this.m_ScreenHeight = Screen.height;
            this.m_ScreenWidth = Screen.width;
            if (m_toRotate == true)
            {
                RotateDoneToAwake();
                m_toRotate = false;
            }
            LayoutHelper.SetCanvas(); //这个地方调用的意义是,如果已经在游戏中,点击旋转。这个时候需要再次触发一下
        }
        
    }

    private void Update()
    {
        if (isInitDone == false)
            return;
        try
        {
            // 等待bundle加载完毕，同时等待logo显示完毕
            if (isResourceInitOk)
            {
                bool ret = GameEntry.Sdk.IsShowLogoOk();
                if (ret == true)
                {
                    InitGame();
                    isResourceInitOk = false;
                }
            }
            
            // 是否重新加载游戏；主要是热更新
            if (_isReloadGame)
            {
                ReloadGameImpl();
                _isReloadGame = false; 
            }

            GameEntry.Update(Time.deltaTime);
        }
        catch (Exception e)
        {
#if UNITY_EDITOR
            Log.Error("APP_ERROR: {0}_{1}",e.Message, e.StackTrace);
#else
            var str = string.Format("APP_ERROR: {0}\n{1}", e.Message, e.StackTrace);
            PostEventLog.LogToFeishu(str, 1);
#endif
        }
    }
    
    // 游戏初始化
    // 把之前在Loading中的一些函数提到这里
    private void InitGame()
    {
        Log.Info("InitGame begin! {0} ", Time.realtimeSinceStartup);
        PostEventLog.Record("InitGame");
        
        GameEntry.Localization.Initialize(GameEntry.Setting.UserLanguage);

        // 初始化xlua引擎
        XLuaManager.loadUsePtr = GameEntry.GameBase.UsePtrForLua;
        Log.Info($"usePtrForLua: {XLuaManager.loadUsePtr}");
        GameEntry.Lua.Initialize();
        GameEntry.Lua.StartGame();
        Log.Info("XLua Initialized: {0} ", Time.realtimeSinceStartup);
        
        // 这个代码要放到LUA初始化之后，因为lua会去设置多语言的的支持列表！
        GameEntry.Localization.LoadDictionary("Dialog");
        
        //LoadingInit();
        Log.Info("InitGame ok!");
        GameEntry.Sdk.CrashlyticsAddLog("InitLua");

    }

    private bool isResourceInitOk = false;
    /// <summary>
    /// AssetBundle资源管理器初始化回调
    /// </summary>
    /// <param name="key">Key.</param>
    /// <param name="obj">Object.</param>
    /// <param name="err">Error.</param>
    private void OnResourcesInitialized(bool succ)
    {
        Log.Info("OnResourcesInitialized {0}.", succ);
        PostEventLog.Record(PostEventLog.Defines.RES_OK);
        
        isResourceInitOk = true;
        GameEntry.Sdk.CrashlyticsAddLog("ResourcesInitialized");
        InitFrameworkEnv();
    }

    private void InitFrameworkEnv()
    {
        InstanceObj("Assets/Main/Prefabs/UnityGameFramework/GameFramework.prefab");
        
        GameEntry.InitUIContainer();
        
        // 关闭URP的调试界面
#if !UNITY_EDITOR
        UnityEngine.Rendering.DebugManager.instance.enableRuntimeUI = false;
#endif
        
    }

    private bool initEnvSky = false;
    private int loadCnt = 0;

    public bool LoadDone()
    {
        if (loadCnt > 0)
            return true;
        return false;
    }

    public void InitUSky()
    {
        if (initEnvSky)
            return;
        
        //Log.Debug(">>>zzz InitUSky");
        //InstanceObj("Assets/Main/Framework_USky/Surviva_PVE_Light.prefab");
        //InstanceObj("Assets/Main/Framework_USky/uSkyPro.prefab");
        initEnvSky = true;
    }

    private string GetRealName(string path)
    {
        int lastSlashPos = path.LastIndexOf('/');
        if (lastSlashPos == 0)
            return path;
        string _realName = path.Substring(lastSlashPos+1);
        _realName = _realName.Replace(".prefab", "");
        return _realName;
    }

    private void InstanceObj(string path)
    {
        string _realName = GetRealName(path);
        var req = GameEntry.Resource.LoadAsset(path, typeof(GameObject));
        if (req != null)
        {
            GameObject obj = req.asset as GameObject;
            if (obj != null)
            {
                var obj1 = Instantiate(obj);
                obj1.name = _realName;
                if (_realName.Contains("uSkyPro"))
                {
                    loadCnt++;
                }
            }
        }
    }

    public void Quit()
    {
        Debug.Log("app quit begin");
        
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#elif UNITY_ANDROID && !UNITY_2018_4_OR_NEWER // Application.Quit() crash has been fixed after 2018.4
        AndroidUtils.Quit();
#else
        Application.Quit();
#endif
    }
    public void ReloadGame()
    {
        Debug.Log("ReloadGame!");
        _isReloadGame = true;
    }

    private Action _resetCanvasAction = null;
    public void WaitToResetCanvas( Action callback )
    {
        Debug.Log("WaitToResetCanvas");
        _resetCanvasAction = callback;
        StartCoroutine(ToResetCanvas());
    }

    IEnumerator ToResetCanvas()
    {
        yield return new WaitForSeconds(0.5f);
        _resetCanvasAction?.Invoke();
    }

    private void ReloadGameImpl()
    {
        try
        {
            GameEntry.Shutdown();
            GameObjectPool.Instance.ClearPool();
        } 
        catch (Exception e)
        {
            Log.Error("ReloadGameImpl error: {0}", e.StackTrace);
        }

        Log.Info("ReloadGameImpl finish");

        // 每次重新init一下game
        InitGame();
    }

    public void OnApplicationPause(bool pause)
    {
        if (isInitDone == false)
            return;
        if (GameEntry.GlobalData != null)
        {
            GameEntry.GlobalData.isInBackGround = pause;
        }

        if (GameEntry.Lua != null)
        {
            GameEntry.Lua.OnApplicationPause(pause);
        }
        else
        {
            if (pause)
            {
                PostEventLog.Record(PostEventLog.Defines.APP_PAUSE);
            }
            else
            {
                PostEventLog.Record(PostEventLog.Defines.APP_RESUME);
            }
        }
    }

    public void OnApplicationFocus(bool hasFocus)
    {
        if (isInitDone == false)
            return;
        if (GameEntry.Lua != null)
        {
            GameEntry.Lua.OnApplicationFocus(hasFocus);
        }
    }

    // 输出已经加载的Lua Asset，临时先放到这里。到时候整理一下
    public static void DumpLoadingLuaScripts()
    {
        if (GameEntry.Lua != null)
        {
            GameEntry.Lua.DumpLoadingLuaScripts();
        }
    }
    
    private void OnLowMemory()
    {
        StringBuilder builder = new StringBuilder(256);
        
        builder.AppendFormat("DM={0}", SystemInfo.deviceModel);
        builder.AppendFormat("|MEM={0}", SystemInfo.systemMemorySize);

        int luaMem = 0;
        if (GameEntry.Lua != null && GameEntry.Lua.Env != null)
        {
            luaMem = GameEntry.Lua.Env.Memroy / 1024;
        }
        builder.AppendFormat("|Mono={0:N2}/{0:N2}", UnityEngine.Profiling.Profiler.GetMonoUsedSizeLong()/1024/1024, UnityEngine.Profiling.Profiler.GetMonoHeapSizeLong()/1024/1024);
        builder.AppendFormat("|TotalReservedMemory={0:N2}", UnityEngine.Profiling.Profiler.GetTotalReservedMemoryLong()/1024/1024);
        builder.AppendFormat("|LUAMem={0:N2}", luaMem);

        string memstr = builder.ToString();
        PostEventLog.Record(PostEventLog.Defines.LOW_MEMORY, memstr);
        
        Log.Info(memstr);
        
        Resources.UnloadUnusedAssets();
    }
    
    private InstanceRequest _gfxConsoleRequest;
    public void ShowConsole()
    {
        if (_gfxConsoleRequest == null)
        {
            _gfxConsoleRequest = GameEntry.Resource.InstantiateAsync(GameDefines.UIAssets.GFXConsole);
            _gfxConsoleRequest.completed += delegate { Log.Debug("创建GFXConsole成功"); };
        }
        else
        {
            _gfxConsoleRequest.Destroy();
            _gfxConsoleRequest = null;
        }
    }

    // 防止LUA代码有问题，导致登录卡死，无法自动更新
    public void ClearUserCache()
    {
        Debug.LogError("GameMain.Start exception! remove all cache!");
        var deviceID = GameEntry.Setting.GetString(GameDefines.SettingKeys.DEVICE_ID, "");
        var postEventID = GameEntry.Setting.GetString("POSTEVENTID", "");
        PlayerPrefs.DeleteAll();
        GameEntry.Setting.SetString(GameDefines.SettingKeys.DEVICE_ID, deviceID);
        GameEntry.Setting.SetString("POSTEVENTID", postEventID);
        PlayerPrefs.Save();

        var persistentPath = Application.persistentDataPath;

        FileUtils.DeleteDirectoryIfExists(Application.temporaryCachePath, true);
        FileUtils.DeleteDirectoryIfExists(GameEntry.Resource.GetDownloadDataRootPath(), true);
        FileUtils.DeleteFileIfExists(Path.Combine(persistentPath, "CheckVersion.txt"));
        FileUtils.DeleteFileIfExists(Path.Combine(persistentPath, "config.db"));
        FileUtils.DeleteFileIfExists(Path.Combine(persistentPath, "data_config.txt"));
    }
    
    public void CreateZipDataTable()
    {
        _zipDataTable = new ZipDataTable();
    }

    public ZipDataTable GetZipDataTable()
    {
        return _zipDataTable;
    }

    public static string appDataPath = "";
    public string GetAppDataPath()
    {
        if (appDataPath.IsNullOrEmpty())
        {
            // 这个每次访问都有GC，所以在这里缓存一下吧
            appDataPath = Application.dataPath;
        }


        
        return appDataPath;
    }


    public void CallAllGarbageCodes()
    {
#if UNITY_IOS
        try
        {
            BarrelGarbageCode.CallAllCodeManager.CallAllGarbageCode();
            //BarrelGarbageCode.CallAllAppendCodeManager.CallAllAppendGarbageCode();
        }
        catch (Exception e)
        {
        }
#endif
    }
}





