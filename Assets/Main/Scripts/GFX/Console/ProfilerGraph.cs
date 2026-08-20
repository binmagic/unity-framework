/**
 * [INPUT]: 依赖 Tayx.Graphy 性能面板与 VEngine 的 InstanceRequest 异步加载
 * [OUTPUT]: 对外提供 ProfilerGraph 单例,按需实例化/切换 Graphy 性能图表的显隐
 * [POS]: GFX/Console 的第三方性能图表包装,独立于 IMGUI 调试台,聚焦帧率/内存/音频的可视化监控
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using Tayx.Graphy;
using UnityEngine;

public class ProfilerGraph
{
    private InstanceRequest _graphRequest;
    private static ProfilerGraph _instance;
    private GameObject _gfxBg;
    public static ProfilerGraph GetInstance()
    {
        return _instance ?? (_instance = new ProfilerGraph());
    }

    #region Profiler图像
    public bool IsGraphVisible()
    {
        return _graphRequest != null;
    }
    
    public void ToggleGraph()
    {
        if (_graphRequest == null)
        {
            _graphRequest = GameEntry.Resource.InstantiateAsync(GameDefines.UIAssets.ProfileGraphy);
            _graphRequest.completed += delegate
            {
                var graphMgr = _graphRequest.gameObject.GetComponent<GraphyManager>();
                graphMgr.SetLuaMemoryGetter(() => GameEntry.Lua.Env.Memroy * 1024);
            };
            
            if (_gfxBg == null)
            {
                _gfxBg = GameObject.Find(FrameworkEnv.GfxProfilerBgPath);
            }
            
            if (_gfxBg)
            {
                _gfxBg.transform.SetAsLastSibling();
                _gfxBg.gameObject.SetActive(true);
            }
        }
        else
        {
            _graphRequest.Destroy();
            _graphRequest = null;
            
            if (_gfxBg)
            {
                _gfxBg.gameObject.SetActive(false);
            }
        }        
    }
    #endregion
    
    
    #region 渲染控制台打开开关

    private InstanceRequest gfxConsoleRequest;

    public bool IsConsoleVisible()
    {
        return gfxConsoleRequest != null;
    }

    public void ToggleConsole()
    {
        if (gfxConsoleRequest == null)
        {
            gfxConsoleRequest = GameEntry.Resource.InstantiateAsync(GameDefines.UIAssets.GFXConsole);
            gfxConsoleRequest.completed += delegate { Debug.Log("创建GFXConsole成功"); };
        }
        else
        {
            gfxConsoleRequest.Destroy();
            gfxConsoleRequest = null;
        }
    }
    #endregion
}





