using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public static class LayoutHelper
{
    public enum Layout
    {
        Landscape = 0,
        Portrait
    }

    private static Layout m_layout = Layout.Landscape;

    public static Layout CurLayout
    {
        get
        {
            return m_layout;
        }
    }
    private static string CACHE_KEY_CurLayout = "CurLayoutNew";
    /// <summary>
    /// 检测当前应该使用什么样的布局
    /// 目前使用的检测方法是如果缓存中有"CurOri" 使用这个的设置,如果没有的话,看是否有gameuid的缓存,如果有使用横版,否则使用竖版
    /// </summary>
    public static void CheckCurLayout()
    {
        Debug.Log("ROTATION: 2");
        var _oriSet = (int)Layout.Portrait; //测试竖版PlayerPrefs.GetInt(CACHE_KEY_CurLayout, -1);
        if (_oriSet == 0 || _oriSet == 1)
        {
            m_layout = (Layout) _oriSet;
        }
        else
        {
            //editor下默认是横版
#if UNITY_EDITOR
            PlayerPrefs.SetInt(CACHE_KEY_CurLayout, (int)Layout.Landscape);
            m_layout = Layout.Landscape;
            return;
#elif UNITY_IOS
            PlayerPrefs.SetInt(CACHE_KEY_CurLayout, (int)Layout.Portrait);
            m_layout = Layout.Portrait;
            return;
#endif
            var _gameUid = PlayerPrefs.GetString(GameDefines.SettingKeys.GAME_UID);
            if (string.IsNullOrEmpty(_gameUid))
            {
                //默认设置为竖版
                PlayerPrefs.SetInt(CACHE_KEY_CurLayout, (int)Layout.Portrait);
                m_layout = Layout.Portrait;
            }
            else
            {
                PlayerPrefs.SetInt(CACHE_KEY_CurLayout, (int)Layout.Landscape);
                m_layout = Layout.Landscape;
            }
        }
    }

    public static void SetLayoutInt(int ivalue)
    {
        Layout _layout = (Layout) ivalue;
        if (_layout == CurLayout)
            return;
        m_layout = _layout;
        
       
       //编辑器下自动切换下GameViewRes
       #if UNITY_EDITOR
           if(_layout == Layout.Landscape)
           {
               GameViewResHelper.ChangeToLandScape(); 
           }else
           {
               GameViewResHelper.ChangeToPortrait(); 
           }
       #endif
       
               
        PlayerPrefs.SetInt(CACHE_KEY_CurLayout, (int)_layout);
        SetRotation();
        ApplicationLaunch.Instance.WaitToResetCanvas(() =>
        {
#if UNITY_ANDROID
            GameEntry.Sdk.SetAndroidScreenNotch();
#endif
            ApplicationLaunch.Instance.ReloadGame();
            if (LayoutHelper.CurLayout == LayoutHelper.Layout.Landscape)
            {
                Screen.orientation = ScreenOrientation.AutoRotation; //因为setrotation里的协成会被这个顶掉,重设一遍
            }
        });
    }

    public static void SetRotation()
    {
        Debug.Log("ROTATION: 3");
        if (LayoutHelper.CurLayout == LayoutHelper.Layout.Landscape)
        {
            Debug.Log("ROTATION: 4");
            if (Screen.orientation == ScreenOrientation.Portrait)
            {
                Debug.Log("ROTATION: 5");
                Screen.orientation = ScreenOrientation.LandscapeLeft;
            }
            Screen.autorotateToPortrait = false;
            Screen.autorotateToPortraitUpsideDown = false;
            Screen.autorotateToLandscapeLeft = true;
            Screen.autorotateToLandscapeRight = true;
            ApplicationLaunch.Instance.WaitToResetCanvas(() =>
            {
                Debug.Log("ROTATION: 9");
                Screen.orientation = ScreenOrientation.AutoRotation;
            });
        }
        else
        {
            Debug.Log("ROTATION: 6");
            if (Screen.orientation == ScreenOrientation.LandscapeLeft ||
                Screen.orientation == ScreenOrientation.LandscapeRight)
            {
                Debug.Log("ROTATION: 7");
                Screen.orientation = ScreenOrientation.Portrait;
            }
            Debug.Log("ROTATION: 8");
            Screen.autorotateToPortrait = true;
            Screen.autorotateToPortraitUpsideDown = false;
            Screen.autorotateToLandscapeLeft = false;
            Screen.autorotateToLandscapeRight = false;
        }
    }

    public static void SetCanvas()
    {
        if (LayoutHelper.CurLayout == LayoutHelper.Layout.Landscape)
        {
            SetDesignSize(new Vector2(1334, 750));
        }
        else
        {
            SetDesignSize(new Vector2(750, 1625));
        }

        SetUICamera();
    }
    
    //修正UI Design Size
    public static void SetDesignSize(Vector2 size)
    {
        var _uiContainer = GameObject.Find(FrameworkEnv.UIContainerPath);
        if (_uiContainer == null)
            return;
        var _canvasScale = _uiContainer.GetComponent<CanvasScaler>();
        if (_canvasScale != null)
        {
            _canvasScale.referenceResolution = size;
        }
    }
    
    private static void SetUICamera()
    {
        var _rootObj = GameObject.Find("GameFramework");
        if (_rootObj == null)
            return;
        var blurCameraObj = _rootObj.transform.Find("UI/BlurCamera");
        var uiCameraObj = _rootObj.transform.Find("UI/UICamera");
        // var uiContainer = transform.Find("UI/UIContainer");
        AdjustCamera(blurCameraObj);
        AdjustCamera(uiCameraObj);
    }
    private static void AdjustCamera(Transform camera)
    {
        if (camera!=null)
        {
            var uiCamera = camera.GetComponent<Camera>();
            camera.transform.position = new Vector3(Screen.width/2, Screen.height/2, 10);
            uiCamera.orthographicSize = Screen.height / 2;
        }
    }

}