/**
 * [INPUT]: 依赖 Screen.safeArea,依赖 GameEntry.Sdk.AndroidScreenNotch 取安卓刘海参数,依赖 LayoutHelper 判定横竖屏
 * [OUTPUT]: 对外提供 ScreenSafeArea 组件与静态 GetSafeArea(按平台计算安全区)
 * [POS]: UI 层的刘海/安全区适配器,把面板锚点收进安全区并随分辨率变化刷新,统一处理 iOS/Android 异形屏
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using GameFramework;

public class ScreenSafeArea:MonoBehaviour
{  
    
    public Rect phoneDelta = new Rect(50f, 0f, -100f, 0);//ios 官方给定的偏移量  
    [SerializeField]  
    private RectTransform Panel;  
    private Rect LastSafeArea = new Rect(0, 0, 0, 0);
    private float ScreenWidth, ScreenHeight;
    private void Awake()  
    {  
        Panel = GetComponent<RectTransform>();  
        Refresh();
        ScreenHeight = Screen.height;
        ScreenWidth = Screen.width;
    }  
  
    private void Update()
    {
        CheckSize();
    }

    private void CheckSize()
    {
        if (ScreenHeight != Screen.height || ScreenWidth != Screen.width)
        {
            Refresh();
            ScreenHeight = Screen.height;
            ScreenWidth = Screen.width;
        }
    }
    private void Refresh()  
    {  
        Rect safeArea = GetSafeArea();  
  
        if (safeArea != LastSafeArea)  
            SetSafeArea(safeArea);  
    }  
  
    public static Rect GetSafeArea()  
    {  
        var tempArea = Screen.safeArea;
#if UNITY_ANDROID && !UNITY_EDITOR
        var delta = GameEntry.Sdk.AndroidScreenNotch;
        if (!delta.IsNullOrEmpty())
        {
            var vec = delta.Split(';');
            if (vec.Length > 3)
            {
                var delta1 = vec[0].ToFloat();//Left
                var delta2 = vec[1].ToFloat();//Right
                var delta3 = vec[2].ToFloat();//Top
                var delta4 = vec[3].ToFloat();//Bottom
                if (LayoutHelper.CurLayout == LayoutHelper.Layout.Portrait)
                {
                    tempArea = new Rect(0,0,Screen.width, Screen.height - delta3);
                }
                else
                {
                    var deltaX = Mathf.Max(delta1, delta2, delta3, delta4);
                    tempArea = new Rect(deltaX,0,Screen.width- (deltaX*2), Screen.height);
                }
            }
        }
#endif
        if (LayoutHelper.CurLayout == LayoutHelper.Layout.Portrait)
        {
            var deltaWidthY = Screen.height - tempArea.yMax;

#if UNITY_IOS || UNITY_EDITOR
            if (deltaWidthY > 0)
            { 
                deltaWidthY = Mathf.Max(0,deltaWidthY - 40);
            }
#endif 
        
            var safeArea = new Rect(0, 0, Screen.width, Screen.height - deltaWidthY);
        
            return safeArea;  
        }
        else
        {
            var deltaWidthX = tempArea.x;
            var safeArea = new Rect((deltaWidthX/2), 0, Screen.width-(deltaWidthX), Screen.height);
            return safeArea;  
        }
    } 
  
    private void SetSafeArea(Rect r)  
    {  
        LastSafeArea = r;  
        Vector2 anchorMin = r.position;  
        Vector2 anchorMax = r.position + r.size;  
        anchorMin.x /= Screen.width;  
        anchorMin.y /= Screen.height;  
        anchorMax.x /= Screen.width;  
        anchorMax.y /= Screen.height;  
        Panel.anchorMin = anchorMin;  
        Panel.anchorMax = anchorMax;  
  
        Log.Debug("New safe area {0}: x={1}, y={2}, w={3}, h={4} screenSize w={5}, h={6}",  
            name, r.x, r.y, r.width, r.height, Screen.width, Screen.height);  
    }  
}





