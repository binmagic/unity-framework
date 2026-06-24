using System;
using System.Text;
using EmulatorDetect;
using GameFramework;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using UnityEngine;
using UnityEngine.Scripting;

[Preserve]
public class LoginMessage : BaseMessage
{
    public static LoginMessage Instance;

    public Action<ISFSObject> onLoginResponse;
    public Action<object> onLuaLoginResponse;

    public LoginMessage()
    {
        Instance = this;
    }
    public override string GetMsgId()
    {
        return "login";
    }

    protected override IRequest CSSetData(params object[] args)
    {
        DeviceManager device = GameEntry.Device;
        GlobalDataManager globalData = GameEntry.GlobalData;
        SettingManager userDefault = GameEntry.Setting;
        LocalizationManager localization = GameEntry.Localization;

        string userName = (string)args[0];
        string pwd = (string)args[1];
        string zone = (string)args[2];
        SFSObject so = (SFSObject) args[3];

        // 这么做的意义是可以让LUA提交一些可配置的参数过来
        if (so == null)
        {
            so = new SFSObject();
        }
        
        int fuId = GameEntry.Network.getFutureManager().getFutureId();
        so.PutInt("_id", fuId);
        GameEntry.Network.getFutureManager().onSendRequest(fuId, GetMsgId());
        so.PutInt("netType", device.GetNetworkStatus());

        // 分辨率
        so.PutUtfString("phone_screen", string.Format("{0}*{1}", Screen.width, Screen.height));

        // armsXmlVersion?
        SFSObject armsVersion = new SFSObject();
        // armsVersion.PutUtfString(GameDefines.TableName.ArmsTab, userDefault.GetString("armsXmlVersion", "0"));
        so.PutSFSObject("configVersion", armsVersion);

        if (string.IsNullOrEmpty(userName))
        {
            globalData.loginServerInfo = new GlobalDataManager.LoginServerInfo { country = 1 };
            so.PutInt("country", globalData.loginServerInfo.country);
            so.PutBool("suggestCountry", false);

            // 时区？
            var gmtoff = (DateTime.Now - DateTime.UtcNow).TotalSeconds;
            so.PutUtfString("timeoffset", gmtoff.ToString());

#if UNITY_ANDROID
            so.PutUtfString("gcmRegisterId", globalData.gcmRegisterId);
            so.PutUtfString("referrer", globalData.referrer);
#endif
        }

#if UNITY_ANDROID
        so.PutUtfString("AndroidID", device.GetSerialID());
        // android29 以上没法手机IMEI了，再说手机这个意义也不大；目前device_string意义更大一些，见下面
        so.PutUtfString("IMEI", "");
#endif
        // 设备信息
        so.PutUtfString("mt", device.GetHandSetInfo());

        var iIsVerticalCache = GameEntry.Setting.GetPublicInt("Server_isVertical", -1);
        if (iIsVerticalCache != -1)
        {
            so.PutInt("isVertical", iIsVerticalCache);
        }

        // 设备ID；没有的话，需要生成一个新的
        string device_uid = device.GetDeviceUid();
        if (device_uid.IsNullOrEmpty())
        {
            device_uid = device.NewDeviceID();
            Debug.LogFormat("New Device? {0}", device_uid);
        }
        so.PutUtfString("deviceId", device_uid);

        // 增加userName和服务器对齐算法 [2018/11/15 by rj]
        var ct = GameEntry.Timer.GetLocalSeconds();
        var sc = ct.ToString() + "4d1c383ccbedf3d98320d6ea06d8dedc" + userName;
        so.PutUtfString("cmdBaseTime", ct.ToString());
        so.PutUtfString("SecurityCode", StringUtils.GetMD5(sc));

        // 增加外网服务器登录支持：OneCode [2018/11/15 by rj]
        string oneCode = StringUtils.GenerateRandomStr(32);
        string oneCodeMd5 = StringUtils.GetMD5(oneCode);
        char[] oneCodeChars = oneCode.ToCharArray();
        char[] md5Chars = oneCodeMd5.ToCharArray();
        char[] destChars = new char[64];
        for (int i = 0; i < 32; i++)
        {
            destChars[i * 2] = md5Chars[i];
            destChars[i * 2 + 1] = oneCodeChars[i];
        }
        so.PutUtfString("OneCode", new string(destChars));

        // 增加外网服务器登录支持：CoreV [2018/11/15 by rj]
        char[] oneCodeBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(oneCode)).ToCharArray();
        Array.Reverse(oneCodeBase64);
        string oneCode64rMd5 = StringUtils.GetMD5(new string(oneCodeBase64));
        string finalMd5 = StringUtils.GetMD5(oneCode64rMd5 + oneCode);
        for (int i = 0; i < 32; i++)
        {
            destChars[i * 2] = finalMd5[i];
            destChars[i * 2 + 1] = oneCode64rMd5[i];
        }
        so.PutUtfString("CoreV", new string(destChars));

        // OneCodeC?
        //由于跟ls使用同一个服务器，此字段暂时发空的
        so.PutUtfString("googlePlay", GameEntry.Sdk.pf_displayname);
        //so.PutUtfString("googlePlay", device.GetAccountInfo());
        so.PutUtfString("androidDid", device.GetNewAndroidDeviceID());
        so.PutUtfString("googleName", userDefault.GetString("googleName", ""));
        so.PutUtfString("deeplinkParams", globalData.deeplinkParams);
        so.PutUtfString("pfId", globalData.platformUID);
        var dataConfigMd5 =GameEntry.Lua.CallWithReturn<string>("CSharpCallLuaInterface.GetConfigMd5");
        if (!dataConfigMd5.IsNullOrEmpty())
        {
            so.PutUtfString("dataConfigMd5", dataConfigMd5);
        }
        
#if UNITY_ANDROID
        so.PutInt("google_available", GameEntry.Sdk.IsGoogleAvailable ? 1 : 0);
        so.PutUtfString("fromCountry", globalData.fromCountry);
        so.PutUtfString("packageName", GameEntry.Sdk.GetPackageName());
        so.PutUtfString("packageSign", GameEntry.Sdk.GetPackageSign());
        string packageSign = GameEntry.Sdk.GetPackageSign();
        Debug.Log($">>> packageSign: {packageSign}");
        so.PutUtfString("platform", "1");
        so.PutInt("lat", 0);
        //so.PutInt("cpu_features", 0);
        //so.PutInt("cpu_family", 0);
        so.PutUtfString("device_string", device.GetDeviceString());
        so.PutUtfString("pf", GameEntry.Sdk.getChannel());
        so.PutUtfString("fireabaseAppId", PushManager.Instance.firebaseAppId);

#elif UNITY_IOS
        so.PutUtfString("fromCountry", globalData.fromCountry);
        so.PutUtfString("packageName", GameEntry.Sdk.GetPackageName());
        so.PutUtfString("packageSign", GameEntry.Sdk.GetPackageSign());
        so.PutUtfString("platform", "0");
        so.PutInt("lat", 1);
        so.PutUtfString("phone_native_screen", "720*1280");
        so.PutUtfString("device_string", device.GetDeviceString());
        so.PutUtfString("pf", "AppStore");
        string firebaseIdIOS = GameEntry.Sdk.GetDataFromNative("FireBase_GetFireBaseId", "");
        so.PutUtfString("fireabaseAppId", firebaseIdIOS);
#elif UNITY_STANDALONE_WIN
        so.PutUtfString("packageName", GameEntry.Sdk.GetPackageName());
        so.PutUtfString("packageSign", GameEntry.Sdk.GetPackageSign());
        so.PutUtfString("platform", "2");
        so.PutInt("lat", 1);
        so.PutUtfString("phone_native_screen", "720*1280");
        so.PutUtfString("pf", "PC_Win");
#elif UNITY_STANDALONE_OSX
        so.PutUtfString("packageName", GameEntry.Sdk.GetPackageName());
        so.PutUtfString("packageSign", GameEntry.Sdk.GetPackageSign());
        so.PutUtfString("platform", "2");
        so.PutInt("lat", 1);
        so.PutUtfString("phone_native_screen", "720*1280");
        so.PutUtfString("pf", "PC_Mac");
#else
        so.PutUtfString("fromCountry", globalData.fromCountry);
        so.PutUtfString("packageName", GameEntry.Sdk.GetPackageName());
        so.PutUtfString("packageSign", GameEntry.Sdk.GetPackageSign());
        so.PutUtfString("platform", "2");
        so.PutInt("lat", 1);
        so.PutUtfString("phone_native_screen", "720*1280");
        so.PutUtfString("device_string", device.GetDeviceString());
        so.PutUtfString("pf", "Store");
#endif
        
        string afUid = GameEntry.Sdk.GetAppsFlyerUid();
        Log.Info($"LoginMessage afUid [{afUid}]");
        so.PutUtfString("afuid", afUid);
        so.PutUtfString("phone_model", device.GetDeviceModel());
        so.PutInt("configNumber", 0);
        so.PutUtfString("gaid", globalData.gaid);
        so.PutUtfString("osVersion", device.GetOSVersion());
        so.PutUtfString("parseRegisterId", globalData.parseRegisterId);

        so.PutUtfString("gameUid", userName);
        so.PutUtfString("uuid", userDefault.GetString(GameDefines.SettingKeys.UUID, ""));

        // 连接外网版本必须升级版本号 [2018/11/15 by rj]
        so.PutUtfString("appVersion", GameEntry.Sdk.Version);
        so.PutUtfString("resVersion", GameEntry.Resource.GetResVersion());
        so.PutUtfString("versionCode", GameEntry.Sdk.VersionCode);
        so.PutUtfString("lang", localization.GetLanguageName());
        
        so.PutUtfString("serverId", zone.Substring(3));
        so.PutInt("gmLogin", 0);
        so.PutUtfString("KCPMode", "0");
        so.PutInt("forbidden_froce_merge", 1);
        
        so.PutUtfString("simOp", GameEntry.Sdk.GetSimOperator());
        so.PutUtfString("simOpName", GameEntry.Sdk.GetSimOperatorName());

        so.PutUtfString("siDId", SystemInfo.deviceUniqueIdentifier);
        so.PutUtfString("emulatorStr", RevenyDetecter.GetEmulatorStr());
#if __LOG
        if (CommonUtils.IsWriteLog())
        {
            Log.Info("LoginMessage: {0}", so.ToJson());
        }
#endif

        return new LoginRequest(userName, pwd, zone, so);
    }

    protected override void CSHandleResponse(ISFSObject message)
    {
        // 这个地方的处理移动到LUA了
        // 详见：AppStartupLoading:OnLogin
        return;
        
        GlobalDataManager globalData = GameEntry.GlobalData;
        SettingManager userDefault = GameEntry.Setting;
        PostEventLog.Record(PostEventLog.Defines.LOGIN_FINISH);
        if (message.ContainsKey("errorMessage"))
        {
            string errCode = message.GetUtfString("errorMessage");
            Log.Error(errCode);
            onLoginResponse?.Invoke(message);
            if (onLuaLoginResponse != null)
            {
                SFSObject obj = (SFSObject) message;
                onLuaLoginResponse(obj.ToLuaTable(GameEntry.Lua.Env));
            }

            return;
        }

        if (message.ContainsKey("serverInfo"))
        {
            ISFSObject serverInfo = message.GetSFSObject("serverInfo");
            userDefault.SetString(GameDefines.SettingKeys.SERVER_ZONE, serverInfo.GetUtfString("zone"));
            userDefault.SetString(GameDefines.SettingKeys.GAME_UID, serverInfo.GetUtfString("uid"));
            userDefault.SetString(GameDefines.SettingKeys.SERVER_IP, serverInfo.GetUtfString("ip"));
            userDefault.SetInt(GameDefines.SettingKeys.SERVER_PORT, serverInfo.GetInt("port"));
        }

        if (message.ContainsKey("db_timezone_offset"))
        {
            long serverTime = message.GetInt("db_timezone_offset") * 1000L;
            GameEntry.Timer.UpdateServerMilliseconds(serverTime);
            GameEntry.Lua.UpdateUITimeStamp(serverTime);
        }

        //翻译key
        // if (message.ContainsKey("lua"))
        //     customData.Player.translateKey = message.GetUtfString("lua");
        // else
        //     customData.Player.translateKey = "abcdefghigh";

        /*
        globalData.downloadurlcdn = message.GetUtfString("downloadurlcdn");
        if (message.ContainsKey("xmlVersion"))
            globalData.xmlVersion = message.GetUtfString("xmlVersion");
        else
            globalData.xmlVersion = "";
        GameFramework.Log.Info("globalData.xmlVersion = {0}", globalData.xmlVersion);

        if (message.ContainsKey("serverVersion"))
            globalData.serverVersion = message.GetUtfString("serverVersion");
        else
            globalData.serverVersion = "";
        GameFramework.Log.Info("globalData.serverVersion = {0}", globalData.serverVersion);

        if (message.ContainsKey("updateType"))
        {
            int updateType = message.GetInt("updateType");
            globalData.updateType = updateType;
            globalData.downloadurl = message.GetUtfString("downloadurl");
            if (string.IsNullOrEmpty(globalData.downloadurlcdn))
                globalData.downloadurlcdn = globalData.downloadurl;
        
            GameFramework.Log.Info("gameServer UpdateType = {0}, downloadurl = {1}", updateType, globalData.downloadurl);
        }
        if (globalData.updateType == 3){
            globalData.updateType = 0;
        }
        */

        onLoginResponse?.Invoke(message);

        if (onLuaLoginResponse != null)
        {
            SFSObject obj = (SFSObject) message;
            onLuaLoginResponse(obj.ToLuaTable(GameEntry.Lua.Env));
        }
    }
}





