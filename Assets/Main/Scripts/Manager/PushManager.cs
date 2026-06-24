using GameFramework;
using System;

public class PushManager
{
    private bool connected;
    private string platform;        //平台  apns fcm xg
    private string userId;          //普通的token
    private string channelId;       //目前没用
    private string parseId;         //apns的token
    private bool openGiftPage = false;
    private bool initFlag = true;
    public string firebaseAppId = ""; 

    #region 单例
    private static PushManager _instance;
    public static PushManager Instance
    {
        get
        {
            if (null == _instance)
            {
                _instance = new PushManager();
            }

            return _instance;
        }
    }

    public static void Purge()
    {
        _instance = null;

    }

    #endregion

    private PushManager()
    {
        //GameFramework.Log.Debug("初始化PushManager ~");

//#if UNITY_ANDROID
//        var c = new AndroidNotificationChannel()
//        {
//            Id = "channel_id",
//            Name = "Default Channel",
//            Importance = Importance.High,
//            Description = "Generic notifications",
//        };
//        AndroidNotificationCenter.RegisterNotificationChannel(c);
//        AndroidNotificationCenter.OnNotificationReceived += AndroidNotificationCenter_OnNotificationReceived;
//#elif UNITY_IOS
//#endif
    }


    public void reqFcmTokenMessage(string regParseId)
    {
        if ((regParseId.IsNullOrEmpty() || regParseId.Equals("|") || regParseId.Equals("|fcm")) && firebaseAppId.IsNullOrEmpty())
            return;

        FcmTokenMessage.Instance.Send(new FcmTokenMessage.Request()
        {
            token = regParseId, 
            fireabaseAppId = firebaseAppId
        });
    }

    public void registerdAccount(string strPlatform, string strUserId, string strChannelId)
    {
        Log.Debug(string.Format("platform:{0}, userId:{1}, channelId:{2}", platform, userId, channelId));

        platform = strPlatform;
        userId = strUserId;
        channelId = strChannelId;

        asyncAccount();
    }

    public void registerdParseAccount(string strParseId, string strPlatform)
    {
        parseId = strParseId;
        platform = strPlatform;
        asyncAccount();
    }

    public void SetFireBaseId(string firebaseId)
    {
        firebaseAppId = firebaseId;
        asyncAccount();
    }

    public void onLoginComplete()
    {
        connected = true;
        asyncAccount();
    }


    private void asyncAccount()
    {
        string tempStr = "";
        if (connected == false)
            return;

        if (string.IsNullOrEmpty(userId) && !string.IsNullOrEmpty(parseId))
        {
            tempStr = parseId + "|" + platform;
            
            Log.Debug("asyncAccount1 str == {0}", tempStr);

            reqFcmTokenMessage(tempStr);
        }
        else if (userId != "")
        {
            tempStr = userId + "|" + platform;

            Log.Debug("asyncAccount2 str == {0}", tempStr);
            reqFcmTokenMessage(tempStr);
        }

    }

    //消息推送跳转
    public void pushFirMessaging()
    {
        string gotoType = GameEntry.Setting.GetPublicString("GOTO_TYPE", "");
//        GameEntry.Setting.SetPublicString("GOTO_TYPE", "");
    }



    //推送消息 - cancel
    public void CancelNotice(int type)
    {

    }


    //推送消息 - 记录
    public void recordPushData()
    {
        string pushClick = GameEntry.Setting.GetPublicString("CATCH_PUSH_CLICK_DATA", "");
        if (!string.IsNullOrEmpty(pushClick))
        {
            PushRecordMessage.Instance.Send(new PushRecordMessage.Request()
            {
                record = "",
                click = pushClick,
            });
        }
    }

    //推送消息 - 清空
    public void clearPushCache()
    {
        GameEntry.Setting.SetPublicString("CATCH_PUSH_RECORD", "");
        GameEntry.Setting.SetPublicString("CATCH_PUSH_CLICK_DATA", "");
    }

    public long GetCurrentTimeUnix()
    {
        TimeSpan cha = (DateTime.Now - TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)));
        long t = (long)cha.TotalSeconds;
        return t;
    }

    public void pushDataToHttpServer()
    {
        /*string pushTag = SDKManager.Instance.getClickPushTag();
        if (pushTag.IsNullOrEmpty())
        {
            return;
        }
        GameEntry.GlobalData.push_Tag = pushTag;
        string project = "lastfortress";
        string _gameUid = GameEntry.Setting.GetPublicString(GameDefines.SettingKeys.GAME_UID, "");
        
        string playerMark = GameEntry.Setting.GetPublicInt("PUSHMARK").ToString();
        long time = GetCurrentTimeUnix();
        JsonData data = new JsonData();
        data["project"] = project;
        data["uid"] = _gameUid;
        data["pushtag"] = pushTag;
        data["playermark"] = playerMark;
        data["ispushget"] = true;
        data["ispushopen"] = true;
        data["type"] = "click";
        data["time"] = time*1000;
        string jsonStr = data.ToJson();
        string strUrl = "http://apiaz.lf.im30app.com/push/lf_postback.php?param=";
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
        SDKManager.Instance.ClearAllPushData();*/
    }

}





