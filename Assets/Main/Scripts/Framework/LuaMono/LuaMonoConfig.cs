using GameFramework;
using UnityEngine;

// 绑定LUA脚本用
// 因为我们大部分代码都在LUA中，所以这里的Mono相当于只做一个配置
public class LuaMonoConfig : LuaMonoBase
{
    // 一些缓存的函数ref变量
    // 不要用数组存，会有额外GC。。。
    // 添加更多函数时记得需要在 UnRefAll 里加释放代码
    private int _Awake = 0;
    private int _Start = 0;
    private int _OnDestroy = 0;
    private int _OnEnable = 0;
    private int _OnDisable = 0;
    private int _OnCollisionEnter = 0;
    private int _OnCollisionExit = 0;
    private int _OnTriggerEnterAction = 0;
    private int _OnTriggerExitAction = 0;
    private int _OnAnimationAction = 0;
    private int _OnApplicationFocus = 0;
    private int _OnApplicationPause = 0;
    protected int _Update = 0;
    private bool m_isApplicationQuit = false;
#if UNITY_EDITOR
    private int _OnGUI = 0;
#endif

    protected void Awake()
    {
        Init();

        // 调用Lua的Awake
        CallLuaFunc("Awake", ref _Awake);
        CallLuaFunc("Start", ref _Start);
    }

    // 这个消息也等同OnDestroy()
    // 因为Component释放是异步的，否则退出游戏的时候释放不及时，会导致Mono的OnDestroy调用较晚，导致LUA已经释放
    private void OnApplicationQuit()
    {
        OnDestroy();
        m_isApplicationQuit = true;
    }

    private void OnDestroy()
    {
        if (m_isApplicationQuit)
        {
            return;
        }
        
        if (GameEntry.Lua == null || GameEntry.Lua.Env == null)
        {
            Log.Info("lua not ready!");
            return;
        }

        if (_OnDestroy != LUA_REFNIL)
        {
            CallLuaFunc("OnDestroy", ref _OnDestroy);
        }

        // 反注册所有的变量
        UnRefAll();
        
        // 卸载lua table相关
        Uninit();
    }
    
    private void OnEnable()
    {
        CallLuaFunc("OnEnable", ref _OnEnable);
    }

    private void OnDisable()
    {
        if (m_isApplicationQuit)
        {
            return;
        }
        
        CallLuaFunc("OnDisable", ref _OnDisable);
    }
    
    private void OnCollisionEnter(Collision other)
    {
        CallLuaFunc("OnCollisionEnter", _OnCollisionEnter, other);
    }

    private void OnCollisionExit(Collision other)
    {
        CallLuaFunc("OnCollisionExit", _OnCollisionExit, other);
    }

    private void OnTriggerEnter(Collider other)
    {
        CallLuaFunc("OnTriggerEnter", _OnTriggerEnterAction, other);
    }

    private void OnTriggerExit(Collider other)
    {
        CallLuaFunc("OnTriggerExit", _OnTriggerExitAction, other);
    }

    private void OnAnimationAction(string name)
    {
        CallLuaFunc("OnAnimationAction", _OnAnimationAction, name);
    }
    
    void OnApplicationFocus(bool hasFocus)
    {
        CallLuaFunc("OnApplicationFocus", _OnApplicationFocus, hasFocus);
    }

    void OnApplicationPause(bool pauseStatus)
    {
        CallLuaFunc("OnApplicationPause", _OnApplicationPause, pauseStatus);
    }
    
    #if UNITY_EDITOR
    private void OnGUI()
    {
        CallLuaFunc("OnGUI", ref _OnGUI);
    }
    #endif

    // 从注册表注销所有相关的引用
    protected void UnRefAll()
    {
        UnRef(ref _Awake);
        UnRef(ref _Start);
        UnRef(ref _OnDestroy);
        UnRef(ref _OnEnable);
        UnRef(ref _OnDisable);
        UnRef(ref _OnCollisionEnter);
        UnRef(ref _OnCollisionExit);
        UnRef(ref _OnTriggerEnterAction);
        UnRef(ref _OnTriggerExitAction);
        UnRef(ref _OnAnimationAction);
        UnRef(ref _OnApplicationFocus);
        UnRef(ref _OnApplicationPause);
        UnRef(ref _Update);
#if UNITY_EDITOR
        UnRef(ref _OnGUI);
#endif
    }
}





