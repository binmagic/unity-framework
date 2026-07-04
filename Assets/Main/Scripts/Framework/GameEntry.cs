//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using System;
using BitBenderGames;
using GameFramework;
using GameKit.Base;
using UnityEngine;
using UnityGameFramework.Runtime;

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
public static class GameEntry
{
    // 基础设置
    public static BaseComponent GameBase { get; private set; }

    // 事件订阅
    public static EventComponent Event { get; private set; }

    public static Transform UIContainer { get; private set; }

    // 资源管理
    public static ResourceManager Resource { get; private set; }

    // 本地化
    public static LocalizationManager Localization { get; private set; }

    // 网络连接
    public static NetworkManager Network { get; private set; }

    // 声效管理
    public static SoundComponent Sound { get; private set; }

    // 客户端设置存储
    public static SettingManager Setting { get; private set; }

    // Lua脚本管理
    public static XLuaManager Lua { get; private set; }
    
    //shader管理器
    public static ShaderManager Shader { get; private set; }

    // 玩家数据
    public static CustomDataManager Data { get; private set; }

    //pb预处理
    public static PBController pb { get; private set; }

    // 定时器
    public static TimerComponent Timer { get; private set; }
    
    // 
    public static GlobalDataManager GlobalData { get; private set; }

    // 原生系统SDK
    public static SDKManager Sdk { get; private set; }

    // 设备信息
    public static DeviceManager Device { get; private set; }
    
    public static BuildAnimatorManager BuildAnimatorManager { get; private set; }

    public static ConfigCache ConfigCache { get; private set; }

    public static void Init()
    {
        Log.Info("GameEntry Init Begin.");
        Event = new EventComponent(UnityGameFramework.Runtime.EventPoolMode.AllowNoHandler | UnityGameFramework.Runtime.EventPoolMode.AllowMultiHandler);
        Localization = new LocalizationManager();
        Network = new NetworkManager();
        Sound = new SoundComponent();
        Setting = new SettingManager();
        Data = new CustomDataManager();
        pb = new PBController();
        Timer = new TimerComponent();
        GlobalData = new GlobalDataManager();
        Resource = new ResourceManager();
        Lua = new XLuaManager();
        Shader = new ShaderManager();
        Sdk = new SDKManager();
        Sdk.Initialize();
        Device = new DeviceManager();
        ConfigCache = new ConfigCache();
        BuildAnimatorManager = new BuildAnimatorManager();

        GameFrameworkLog.SetLogHelper(new GameFrameworkLogHelper());
        Log.Info("GameEntry Init End.");
    }

    public static void InitUIContainer()
    {
        UIContainer = GameObject.Find(FrameworkEnv.UIContainerPath).transform;
        if (UIContainer)
        {
            Debug.Log("container not null.");
        }
    }

    // 目前只是为了注册GameFrameworkComponent
    public static void RegisterComponent(GameFrameworkComponent com)
    {
        if (com.GetType() == typeof(BaseComponent))
        {
            GameBase = com as BaseComponent;
        }
    }

    public static void Shutdown(bool now = false, bool LuaShutdown = true)
    {
        // 退出时要清除一下全局的物件；先清除一下，防止有LUA的引用导致lua释放不干净
        if (Camera.main != null && Camera.main.gameObject != null)
        {
            MobileTouchCamera touchCam = Camera.main.gameObject.GetComponent<MobileTouchCamera>();
            if (touchCam != null)
            {
                //touchCam.Clear();
            }
        }
        
        Lua.ExitGame();
        //Lua.Update();
        Event.Shutdown();
        Network.Shutdown();
        Timer.Shutdown();
        Sdk.Shutdown();
        BuildAnimatorManager.Shutdown();
        Sound.ShutDown();
        Data.Reset();

        //GlobalData.Reset();
        ConfigCache.reset();

        if (LuaShutdown)
        {
            Lua.Shutdown();
        }

        Resource.Clear(now);

        Resource.DumpBundleDetail();

        GameFrameworkEntry.Shutdown();
    }

    /// <summary>
    /// 所有游戏框架模块轮询。
    /// </summary>
    /// <param name="elapseSeconds">逻辑流逝时间，以秒为单位。</param>
    /// <param name="realElapseSeconds">真实流逝时间，以秒为单位。</param>
    private static float lastTimePerSecondUpdate = 0;
    public static void Update(float elapseSeconds)
    {
        GameFrameworkEntry.Update(elapseSeconds, Time.unscaledDeltaTime);
        Network.OnUpdate(elapseSeconds);
        Timer.OnUpdate(elapseSeconds);
        Resource.Update();
        Lua.Update();

        // 这里面有几个放到慢逻辑，每250ms检测一次即可
        if (Time.realtimeSinceStartup - lastTimePerSecondUpdate > 0.25)
        {
            lastTimePerSecondUpdate = Time.realtimeSinceStartup;
            
            Sound.OnUpdate(elapseSeconds);
            Sdk.OnUpdate(elapseSeconds);
            //ChatService.Instance.OnUpdate();
        }
    }

    public static long Test_PbNode_Decode(string bytes, string type)
    {
#if UNITY_IOS
        return 0;
#else
        byte[] data = Convert.FromBase64String(bytes);
        var ret = XLua.LuaDLL.Lua.pbn_decode(data, data.Length, type, type.Length);
        if (ret == IntPtr.Zero)
            return 0;
        return ret.ToInt64();
#endif
    }

    public static int Test_PbNode_UserData_Parse(System.IntPtr ptr)
    {
#if UNITY_IOS
        return 0;
#else
        return XLua.LuaDLL.Lua.pbn_ud_parse(ptr);
#endif
    }
}





