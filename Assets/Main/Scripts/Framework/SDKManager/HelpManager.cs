using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;
using LitJson;
using GameFramework;

namespace UnityGameFramework.SDK
{
    public class HelpManager
    {
        #region 单例
        private static HelpManager _instance;
        public static HelpManager Instance
        {
            get
            {
                if (null == _instance)
                {
                    _instance = new HelpManager();
                }

                return _instance;
            }
        }

        public static void Purge()
        {
            _instance = null;

        }

        #endregion

        #if false
#if OLD_PACK
#if UNITY_ANDROID
        private const string ID = "IM30_platform_cc9cb023-86ca-442c-a60d-235efc8d2f55";
        private const string KEY = "IM30_app_02adbe75f639443ebc1c228a3ac65baa";
        private const string DOMAIN = "IM30@aihelp.net";
#elif UNITY_IOS
        private const string ID = "IM30_platform_d620fec6-6db8-43ae-b2f2-8e32813e65f4";
        private const string KEY = "IM30_app_02adbe75f639443ebc1c228a3ac65baa";
        private const string DOMAIN = "IM30@aihelp.net";
#endif

        private const string GM_URL = "https://{0}/ifadmin/admin/admincp.php?mod=user&act=userinfo&action=view&Gserver=s{1}&useruid={2}";
        private const string BLOG_URL = "https://blog.ls.im30.net/{0}/";
        private const string TRANSLATE_URL = "https://trans.im30.net/translateh5/last-shelter-public/po-mono-gitlab/de/?type=all&offset=3&username={0}&userid={1}";
        private const string GUEST_URL = "http://{0}/ifadmin/admin/admincp.php?mod=user&act=userinfo&action=view&Gserver=s{1}&useruid={2}";
#else
        private const string ID = "IM30_platform_4233d618-febb-485f-bacc-a0d4884fd0c4";
        private const string KEY = "IM30_app_ff947c5183c74167864451b718fb0eff";
        private const string DOMAIN = "IM30@aihelp.net";

        private const string GM_URL = "https://{0}/ifadmin/admin/admincp.php?mod=user&act=userinfo&action=view&Gserver=s{1}&useruid={2}";
        private const string BLOG_URL = "https://blog.ls.im30.net/{0}/";
        private const string TRANSLATE_URL = "https://trans.im30.net/translateh5/last-shelter-public/po-mono-gitlab/de/?type=all&offset=3&username={0}&userid={1}";
        private const string GUEST_URL = "http://{0}/ifadmin/admin/admincp.php?mod=user&act=userinfo&action=view&Gserver=s{1}&useruid={2}";
#endif

        //private const string packageName = "com.im30.lsu3d";
        private const string HS_ENABLE_CONTACT_US = "enableContactUs";
        private const string HS_META_DATA_KEY = "hs-custom-metadata";
        private const string HS_TAGS_KEY = "hs-tags";
        private const string HS_ENABLE_CONTACT_US_AFTER_VIEWING_FAQS = "after_viewing_faqs";

#if UNITY_EDITOR
        //测试服
        private static string SERVERLIST_IP = "10.0.0.16";
        private static string SERVER_IP = "10.0.0.16";
        private static string SERVER_ZONE = "COK2";
        private static int WEBSERVER_CONFIG_PORT = 8081;
#else
   
    private static string SERVER_ZONE = "COK1";
    private static int WEBSERVER_CONFIG_PORT = 80;
#endif
        #endif
        
        public void init()
        {
            // 这里GameFramework.Log还没有初始化，所以用Debug.Log
            // Debug.Log("初始化HelpManager ~");

            // var data = new JsonData();
            // data["id"] = ID;
            // data["key"] = KEY;
            // data["domain"] = DOMAIN;
            //
            // string jsonData = data.ToJson();
            // GameEntry.Sdk.SendDataToNative("InitAIHelp", jsonData);
        }

        public void setUserData()
        {
            // try
            // {
            //     var data = new JsonData();
            //     data["uid"] = GameEntry.Data.Player.Uid;
            //     data["name"] = GameEntry.Data.Player.GetName();
            //     data["serverId"] = GameEntry.Data.Player.GetCurServerId();
            //     data["useLanguage"] = GameEntry.Localization.GetLanguageName();
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_setUserData", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        public void showHelpShiftFAQ()
        {
            // try
            // {
            //     var data = new JsonData();
            //
            //     data["customData"] = GetCustomData(GameEntry.Sdk.VersionCode);
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showFAQs", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        public void showHelpShiftFAQ(string itemId)
        {
            // string key = GameEntry.DataTable.GetString("help_link", itemId, "el_id");
            // if (string.IsNullOrEmpty(key))
            // {
            //     showHelpShiftFAQ();
            //     return;
            // }
            //
            // try
            // {
            //     var data = new JsonData();
            //
            //     data["customData"] = GetCustomData(GameEntry.Sdk.VersionCode);
            //     data["sectionPublishId"] = key;
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showFAQSection", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }


        public void showSingleFAQ(string itemId)
        {
            // string key = GameEntry.DataTable.GetString("help_link", itemId, "el_id");
            // if (string.IsNullOrEmpty(key))
            // {
            //     showHelpShiftFAQ();
            //     return;
            // }
            //
            // try
            // {
            //     var data = new JsonData();
            //
            //     data["customData"] = GetCustomData(GameEntry.Sdk.VersionCode); ;
            //     data["faqId"] = key;
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showSingleFAQ", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }

        }

        public void showQACommunity()
        {
            // if (GameEntry.Data.Player == null)
            // {
            //     return;
            // }
            //
            // GameEntry.GlobalData.isOpenElvaChat = true;
            // //MiddleManager.Instance.isOpenElvaChat = true;
            //
            // try
            // {
            //     var data = new JsonData();
            //     data["playerUid"] = GameEntry.Data.Player.Uid;
            //     data["playerName"] = GameEntry.Data.Player.GetName();
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showQACommunity", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        public void showBlog()
        {
            // string _lang = GameEntry.Localization.GetLanguageName();
            // if (_lang.Equals("zh_CN"))
            // {
            //     _lang = "zh_cn";
            // }
            // else if (_lang.Equals("zh_TW"))
            // {
            //     _lang = "zh_tw";
            // }
            //
            // string url = string.Format(BLOG_URL, _lang);
            //
            // try
            // {
            //     var data = new JsonData();
            //     data["url"] = url;
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showURL", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        public void showTranslateView()
        {
            // string playerName = GameEntry.Data.Player.GetName();
            // string playerUid = GameEntry.Data.Player.Uid;
            // string url = string.Format(TRANSLATE_URL,playerName,playerUid);
            //
            // try
            // {
            //     var data = new JsonData();
            //     data["url"] = url;
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showURL", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        public void goToHelpShift()
        {
//             try
//             {
//                 var data = new JsonData();
//
//                 var config = new JsonData();
//                 var meta = new JsonData();
//                 string _versionCode = GameEntry.Sdk.VersionCode;
//                 meta["VersionCode"] = _versionCode;
//
//                 var tags = new JsonData();
//                 tags.Add("loading");
//
//                 string cokZone = GameEntry.Network.ZoneName;
//                 if (cokZone.Length > 3)
//                 {
//                     tags.Add(string.Format("s{0}",cokZone.Substring(3)));
//                 }
//                 else
//                 {
//                     tags.Add("NoZone");
//                 }
//
//                 string key = "";
// #if UNITY_ANDROID
//                 key = "15448";
//                 string channel = "market_global";//GameEntry.Data.Player.analyticID;
//                 if (channel.Equals("market_global"))
//                 {
//                     channel = "google";
//                 }
//                 tags.Add(channel);
// #elif UNITY_IPHONE
//                 key = "15447";
//                 tags.Add("ios");
// #endif
//                 meta[HS_TAGS_KEY] = tags;
//
//                 string sid = GameEntry.Network.GetServerIdBySharedUser();
//                 string ip = GameEntry.Network.GameServerUrl;
//                 string port = GameEntry.Network.GameServerPort.ToString();
//                 string zoon = GameEntry.Network.ZoneName;
//                 string elog = "";//GameController::getInstance()->getLoginErrorLog().c_str()
//                 string errorLog = string.Format("==sid:{0}, ip:{1}, port:{2}, zoon:{3}, ErrorLog:{4}",sid,ip,port,zoon,elog);
//
//                 string loadingLog = ""; //GameController::getInstance()->getLoadingLogString();
//
//                 string netInfo = errorLog + loadingLog + "==new check net log:";
//                 meta["loadingLog"] = netInfo;
//
//                 config[HS_META_DATA_KEY] = meta;
//
//                 data["customData"] = config;
//                 data["faqId"] = key;
//
//                 string jsonData = data.ToJson();
//                 GameEntry.Sdk.SendDataToNative("AIHelp_showSingleFAQ", jsonData);
//             }
//             catch (System.Exception e)
//             {
//                 Log.Error(e.Message);
//             }
        }

        //不同界面，根据xml配置，显示不同aihelp
        public void showFAQ(string publishId)
        {
            // Log.Debug("Visit showFAQ Id:"+publishId);
            // string key = GameEntry.DataTable.GetString("help_link", publishId, "group");
            // if (key != null && key.Equals("1"))
            // {
            //     showHelpShiftFAQ(publishId);
            // }
            // else
            // {
            //     showSingleFAQ(publishId);
            // }

        }


        //tagkey: kuafu_kill、shamo、libaostore、zhzh、loading、jianyi、abcdefg、abcdefg2
        public void onShowGuest(string tagKey)
        {
            // try
            // {
            //     var data = new JsonData();
            //
            //     string playerUid = GameEntry.Data.Player.Uid;
            //     string serverId = GameEntry.Network.GetServerIdBySharedUser();
            //
            //
            //     string vipFlag = "1";
            //     // if (GameEntry.Data.Player.getPayLevel() < 4)
            //     {
            //         vipFlag = "0";
            //     }
            //     data["playerName"] = GameEntry.Data.Player.GetName();
            //     data["playerUid"] = playerUid;
            //     data["serverId"] = GameEntry.Data.Player.GetCurServerId();
            //     data["playerParseId"] = GameEntry.GlobalData.parseRegisterId; // for ios
            //     data["showConversationFlag"] = vipFlag;
            //     data["customData"] = GetCustomData(tagKey);
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showElva", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }
        }

        //viptalk、wargame、freebuildjianyi、battlefield、zongtong、
        public void showConversation(string tag)
        {
            // try
            // {
            //     var data = new JsonData();
            //
            //     data["uid"] = GameEntry.Data.Player.Uid;
            //     data["serverId"] = GameEntry.Data.Player.GetCurServerId().ToString();
            //     data["customData"] = GetCustomData(tag);
            //
            //     string jsonData = data.ToJson();
            //     GameEntry.Sdk.SendDataToNative("AIHelp_showConversation", jsonData);
            // }
            // catch (System.Exception e)
            // {
            //     Log.Error(e);
            // }


        }

        JsonData GetTags(string tag)
        {
            var tags = new JsonData();

//             if (!string.IsNullOrEmpty(tag))
//                 tags.Add(tag);
//
//             // tags.Add(string.Format("pay{0}", GameEntry.Data.Player.getPayLevel()));
//             //
//             // if (GameEntry.Data.Player.getPayLevelM() > 0)
//             //     tags.Add(string.Format("mp{0}k", GameEntry.Data.Player.getPayLevelM()));
//
//             if (GameEntry.GlobalData.isNewServer)
//                 tags.Add("新服");
//             
//
//             if (tag.IsNullOrEmpty() || tag.Equals("zhzh") || tag.Equals("libaostore"))
//             {
//                 tags.Add(string.Format("s{0}", GameEntry.Data.Player.GetCurServerId()));
//                 // if (GameEntry.Data.Player.CrossFightSrcServerId < 0)
//                 //     tags.Add(string.Format("s{0}", GameEntry.Data.Player.CrossFightSrcServerId));
//             }
//             else
//             {
//
// #if UNITY_ANDROID
//                 if (!GameEntry.GlobalData.analyticID.Equals("market_global"))
//                 {
//                     tags.Add(GameEntry.GlobalData.analyticID);
//                 }
// #elif UNITY_IPHONE
//                 tags.Add("ios");
// #endif
//                 string serverId = GameEntry.Network.GetServerIdBySharedUser();
//                 if (!serverId.IsNullOrEmpty())
//                     tags.Add(string.Format("s{0}", serverId));
//             }

            return tags;
        }

        JsonData GetMetaData(string tag)
        {
            var meta = new JsonData();

            // var tags = GetTags(tag);
            //
            // meta["deviceId"] = GameEntry.Device.GetDeviceUid();
            // meta[HS_TAGS_KEY] = tags;
            //
            // if (!"viptalk".Equals(tag))
            // {
            //     string strUrl;
            //     if (CommonUtils.IsDebug())
            //     {
            //         strUrl = string.Format("{0}:{1}", SERVERLIST_IP, WEBSERVER_CONFIG_PORT);
            //     }
            //     else if (GameEntry.GlobalData.isMiddleEast())
            //     {
            //         // http
            //         strUrl = string.Format(GUEST_URL, "app1.im.medrickgames.com:80", GameEntry.Network.GetServerIdBySharedUser(), GameEntry.Data.Player.Uid);
            //     }
            //     else
            //     {
            //         // https
            //         strUrl = string.Format(GM_URL, SERVERLIST_IP, GameEntry.Network.GetServerIdBySharedUser(), GameEntry.Data.Player.Uid);
            //     }
            //     meta["GM"] = strUrl;
            //
            //     string _versionCode = GameEntry.Sdk.VersionCode;
            //     meta["VersionCode"] = _versionCode;
            // }
            //
            // if (tag.Equals("libaostore") || tag.Equals("zhzh") || tag.Equals("jianyi") || tag.Equals("abcdefg") || tag.Equals("abcdefg2"))
            // {
            //     meta["anotherWelcomeText"] = tag;
            // }
            // else if (tag.Equals("loading"))
            // {
            //     meta["anotherWelcomeText"] = "s-登录";
            // }
            // var dict = CommonUtils.__static_UserSayByInit();
            // if (dict.ContainsValue(tag))
            // {
            //     meta["anotherWelcomeText"] = tag;
            // }

            return meta;
        }

        JsonData GetCustomData(string tag)
        {
            var config = new JsonData();

            // config[HS_META_DATA_KEY] = GetMetaData(tag);

            // if (GameEntry.Data.Player.getPayLevel() <= 0)
            //     config[HS_ENABLE_CONTACT_US] = HS_ENABLE_CONTACT_US_AFTER_VIEWING_FAQS;

            return config;
        }
        

    }
}





