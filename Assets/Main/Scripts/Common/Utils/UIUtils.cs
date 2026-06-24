using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public static class UIUtils
{

    /// <summary>
    /// 获取异形屏一边的宽度
    /// </summary>
    /// <returns></returns>
    public static float tmpWidth = -100.0f;
    public static float GetSpecialScreenWidth()
    {
        if (tmpWidth < -99.0)
        {
            int width = Screen.width;
            float newWidth = ScreenSafeArea.GetSafeArea().width;
            tmpWidth = (width - newWidth) / 2.0f;
        }

        return tmpWidth;
    }

    public static bool IsPhone()
    {
        bool isPhone = true;
#if UNITY_IPHONE && !UNITY_EDITOR
			string deviceInfo = SystemInfo.deviceModel.ToString();
			isPhone = deviceInfo.Contains("iPhone");
#else
        float physicscreen = 1.0f * Screen.width / Screen.height;
        isPhone = physicscreen > 1.5f; //(the ratio 4:3 = 1.33; 16:9 = 1.777;)
#endif
        return isPhone;
    }

    public static bool CheckGuiRaycastObjects()
    {
        if (EventSystem.current == null)
        {
            return false;
        }

        PointerEventData eventData = new PointerEventData(EventSystem.current);
#if UNITY_EDITOR
        eventData.pressPosition = Input.mousePosition;
        eventData.position = Input.mousePosition;
#endif
#if UNITY_ANDROID || UNITY_IPHONE
        if (Input.touchCount > 0)
        {
            eventData.pressPosition = Input.GetTouch(0).position;
            eventData.position = Input.GetTouch(0).position;
        }
#endif
        List<RaycastResult> list = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventData, list);
        return list.Count > 0;
    }

    public static void ShowMessage(string message, int buttonCount = 1, string confirmText = GameDialogDefine.CONFIRM,
        string cancelText = GameDialogDefine.CANCEL, Action confirmAction = null, Action cancelAction = null, bool isChangeImg = false)
    {
        GameEntry.Lua.ShowMessage(message,buttonCount,confirmText,cancelText,confirmAction,cancelAction,cancelAction,"",isChangeImg);
        //UITipMessage.Instance.Show(message, buttonCount, confirmText, cancelText, confirmAction, cancelAction, isLocal);
    }
    
    public static void ShowMessages(string message, int buttonCount, string cancelText,
        string confirmText, Action confirmAction = null, Action cancelAction = null, bool isChangeImg = true)
    {
        GameEntry.Lua.ShowMessage(message,buttonCount,cancelText, confirmText,cancelAction,confirmAction,cancelAction,"",isChangeImg);
        //UITipMessage.Instance.Show(message, buttonCount, confirmText, cancelText, confirmAction, cancelAction, isLocal);
    }

    public static void ShowMessage(string message, Action confirmAction, Action cancelAction = null, bool isChangeImg = false)
    {
        GameEntry.Lua.ShowMessage(message,cancelAction == null ? 1 : 2,GameDialogDefine.CONFIRM,GameDialogDefine.CANCEL,confirmAction,cancelAction,cancelAction,"",isChangeImg);
    }
    //这个方法和上一个的区别是默认显示关闭按钮
    public static void NewShowMessage(string message, Action confirmAction, Action cancelAction = null, bool isChangeImg = false)
    {
        GameEntry.Lua.ShowMessage(message,cancelAction == null ? 2 : 3,GameDialogDefine.CONFIRM,GameDialogDefine.CANCEL,confirmAction,cancelAction,cancelAction,"",isChangeImg);
    }


    public static void ShowReloadMessage(string message,Action confirmAction, Action cancelAction,string rTxt = "",float countTime = 0)
    {
        //ShowMessage(message, 1, " 120952", GameDialogDefine.CANCEL, 
        //    delegate { ApplicationLaunch.Instance.ReloadGame(); },
        //    delegate { ApplicationLaunch.Instance.Quit();});

        //var para = new UINetError.Param { errMsg = message, onConfirm = confirmAction , cancelConfirm = cancelAction , time = countTime , rightTxt = rTxt };
        //GameEntry.UI.OpenUIForm(GameDefines.UIAssets.UINetError, GameDefines.UILayer.Dialog, para);
        GameEntry.Lua.ShowMessage(message, 2, GameDialogDefine.CONFIRM, rTxt, confirmAction, cancelAction, cancelAction, "",false);
    }
    
    // 这个方法传进来的msgKey 是 本地化的id,直接用uitips内部方法解析id
    public static void ShowTips(string msgKey, float closeTime = 3f, params object[] args)
    {
        GameEntry.Lua.ShowTips(GameEntry.Localization.GetString(msgKey, args), "", "");
        // UITips.Param p = new UITips.Param()
        // {
        //     AutoCloseTime = closeTime,
        //     TextKey = msgKey,
        //     FormatParams = args,
        // };
        // GameEntry.UI.OpenUIForm(GameDefines.UIAssets.Tips, GameDefines.UILayer.Dialog, p);
    }
    
    /// <summary>
    /// 屏幕坐标转UGUI坐标
    /// </summary>
    /// <param name="transform"></param>
    /// <param name="screenPos"></param>
    /// <returns></returns>
    public static Vector2 ScreenPointToLocalPointInRectangle(Transform transform, Vector2 screenPos)
    {
        Vector2 localPos;
        RectTransform rectT = transform.GetComponent<RectTransform>();
        if (rectT == null)
            return Vector2.zero;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(rectT, screenPos, null, out localPos);
        return localPos;
    }

    public static Transform GetFirstChild(Transform parent, string name)
    {
        if (parent == null)
        {
            return null;
        }

        Transform[] allChild = parent.GetComponentsInChildren<Transform>(true);

        for (int i = 0; i < allChild.Length; i++)
        {
            if (allChild[i].gameObject.name == name)
            {
                return allChild[i];
            }

        }

        return null;

    }

    public static float PlayAnimationReturnTime(SimpleAnimation anim, string animName)
    {
        var aniState = anim.GetState(animName);
        if (aniState != null)
        {
            anim.Stop();
            anim.Play(animName);
            return aniState.length;
        }

        return -1;
    }

    public static float PlayAnimationReturnTime(Animator anim, string animName)
    {
        var clips = anim.runtimeAnimatorController.animationClips;
        for (int i = 0; i < clips.Length; ++i)
        {
            if (clips[i].name.EndsWith(animName))
            {
                anim.Play(animName,0,0);
                return clips[i].length;
            }
        }

        return -1;
    }

    public static float PlayAnimationReturnTime(GPUSkinningAnimator anim, string animName)
    {
        anim.Play(animName);
        return anim.GetClipLength(animName);
    }

    /*public static Vector2Int GetCurScreenMaxRadiusSize()
    {
        var posWorld = SceneManager.World.WorldToTile(SceneManager.World.ScreenPointToWorld(Vector3.zero));
        var cur = SceneManager.World.CurTilePos;
        return cur - posWorld;
    }*/
}





