/**
 * [INPUT]: 继承 BaseGFXConsole,依赖 BitBenderGames 的 MobileTouchCamera 屏蔽点击,聚合各 GFXPanel
 * [OUTPUT]: 对外提供 GFXConsole,组装后期/屏幕/Shader/画质/摄像机/场景查看等调试面板为一个控制台
 * [POS]: GFX/Console 的具体控制台实现与装配点,决定启用哪些 Panel,是调试台的对外入口
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using BitBenderGames;
using UnityEngine;

public class GFXConsole:BaseGFXConsole
{
    //主要用来控制显示console的时候，游戏不要再响应点击
    private GameObject _uiContainerGO;
    private GameObject _gfxBg;
    private MobileTouchCamera _touchCamera;
    
    protected override  void Initialize()
    {
        this.AddPanel(new PostProcessGFXPanel());
        this.AddPanel(new ScreenGFXPanel());
        this.AddPanel(new ShaderGFXPanel());
        //this.AddPanel(new ShadowGFXPanel());
        this.AddPanel(new QualitySettingGFXPanel());
        this.AddPanel(new CameraGFXPanel());
        this.AddPanel(new SceneViewerGFXPanel());
        //this.AddPanel(new ProfilerGFXPanel());


        _uiContainerGO = GameObject.Find("UIContainer");
        _touchCamera = GameObject.Find("Main Camera").GetComponent<MobileTouchCamera>();
        _gfxBg = GameObject.Find("GameFramework/UI/UIContainer/GfxProfilerBg");
        if (_gfxBg)
        {
            _gfxBg.transform.SetAsLastSibling();
        }
    }

    protected override void OnShowConsole()
    {
        //_uiContainerGO.SetActive(false);
        //SceneManager.World.SetTouchInputControllerEnable(false);
        _gfxBg.gameObject.SetActive(true);
    }

    protected override void OnHideConsole()
    {
        //_uiContainerGO.SetActive(true);
        //SceneManager.World.SetTouchInputControllerEnable(true);
        _gfxBg.gameObject.SetActive(false);
    }
}





