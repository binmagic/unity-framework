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
        _gfxBg = GameObject.Find(FrameworkEnv.GfxProfilerBgPath);
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





