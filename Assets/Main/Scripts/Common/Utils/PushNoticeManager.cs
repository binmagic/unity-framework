using System;
using System.Collections;
using System.Collections.Generic;
using GameFramework;
using GameKit.Base;
using LitJson;
using UnityEngine;
using UnityEngine.Networking;
using VEngine;

public class PushNoticeManager
{
    public static void PushNotice(string noticeJson)
    {
        if (noticeJson.IsNullOrEmpty())
            return;
        GameEntry.Sdk.SendDataToNative("PUSH_PushNotice", noticeJson);
    }

    public static void CancelNotice(string typeJson)
    {
        if (typeJson.IsNullOrEmpty())
            return;
        GameEntry.Sdk.SendDataToNative("PUSH_CancleNotice", typeJson);
    }

    public static int GetPushCountById(string pushId)
    {
        int ret = 0;
        try
        {
            JsonData jsonData = new JsonData();
            jsonData["pushId"] = pushId;
            string result = GameEntry.Sdk.GetDataFromNative("PUSH_getPushCountById", jsonData.ToJson());
            ret = result.ToInt();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return 0;
        }

        return ret;
    }

    public static int GetPushSecondTimeById(string pushId)
    {
        int ret = 0;
        try
        {
            JsonData jsonData = new JsonData();
            jsonData["pushId"] = pushId;
            
            Log.Info("PUSH_PushNotice");
            string result = GameEntry.Sdk.GetDataFromNative("PUSH_getPushTimeById", jsonData.ToJson());
            ret = result.ToInt();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return 60;
        }

        return ret;
    }
    
    public static bool GetIsNotifyOpen()
    {
        string result = "";
        try
        {
            result = GameEntry.Sdk.GetDataFromNative("PUSH_isNotifyOpen", "");
            
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return false;
        }

        return result.Equals("true");
    }
    
    
    public static long GetCurrentTimeUnix()
    {
        TimeSpan cha = (DateTime.Now - TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)));
        long t = (long)cha.TotalSeconds;
        return t;
    }
    
    public static void pushDataToHttpServer()
    {
        string pushTag = GameEntry.Sdk.getClickPushTag();
        string pushId = GameEntry.Sdk.getClickPushId();
        if (pushTag.IsNullOrEmpty() || pushId.IsNullOrEmpty())
        {
            return;
        }
        string project = "aps";
        string _gameUid = GameEntry.Setting.GetPublicString(GameDefines.SettingKeys.GAME_UID, "");
        
        string playerMark = GameEntry.Setting.GetPublicInt("PUSHMARK").ToString();
        long time = GetCurrentTimeUnix();
        JsonData data = new JsonData();
        data["project"] = project;
        data["uid"] = _gameUid;
        data["pushtag"] = pushTag;
        data["playermark"] = playerMark;
        data["pushId"] = pushId;
        data["ispushget"] = true;
        data["ispushopen"] = true;
        data["type"] = "click";
        data["versionCode"] = GameEntry.Sdk.VersionCode;
        data["time"] = time*1000;
        string jsonStr = data.ToJson();
        string strUrl = "http://analyse-aps.metapoint.club/postback.php?param=";
        string Url = string.Format("{0}{1}", strUrl, jsonStr);
        WebRequestManager.Instance.Get(Url, (UnityWebRequest request, bool hasErr, object userdata) =>
        {
            DownloadInfo info = (DownloadInfo)userdata;
            if (!hasErr)
            {
                if (request.isDone)
                {
                    return;
                }
            }
        });
        GameEntry.Sdk.ClearAllPushData();
    }
}





