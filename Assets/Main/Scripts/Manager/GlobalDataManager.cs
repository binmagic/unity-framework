using System.Collections.Generic;
using System.Linq;
using Sfs2X.Entities.Data;
using UnityEngine;
using UnityGameFramework.Runtime;

#if true
public class GlobalDataManager
{
    public GlobalDataManager()
    {
        version = Application.version;
    }
    
    public struct LoginServerInfo
    {
        public int country;
        public int recommandCountry;
    }
    
    public bool isCN = false;
    public LoginServerInfo loginServerInfo;
    public string gcmRegisterId = "";//GCM注册ID
    public string referrer = "";//广告来源数据
    public string deeplinkParams = "";//deep link params
    
    public string analyticID = "";//mycard 发布平台 91 google 360.
    /// 谷歌服务是否可用 是否支持谷歌支付
    public bool s_isGooglePlayAvailable;
    public string platformUID = "";//平台UID
    public string parseRegisterId = "";//Parse注册ID
    public string fromCountry = "US";//国家
    public string gaid = "";//adjust 发奖依据

    public string version;//前台版本号
    public string uuid;// uuid
    public string gaidCache;//android读取到gaid以后缓存起来
    public bool isUploadPic;//是否在上传照片
    public int serverType;
    public int serverMax;
    public int curSeasonPlayType = 0; //当前所查看服玩法
    
    public bool pushOffWithQuitGame = false;//是否被踢标识
    
    public bool isInBackGround = false; //游戏是否在后台
    
    public void Init(ISFSObject dict)
    {
        if (dict.ContainsKey("gaid"))
        {
            gaid = dict.GetUtfString("gaid");
        }
    }

    public void SetAnalyticID()
    {
        analyticID = GameEntry.Sdk.GetPublishRegion();
    }
    
    public void recordGaid()
    {
        if (gaid.IsNullOrEmpty())
        {
            if (!gaidCache.IsNullOrEmpty() && !gaidCache.Equals("missed"))
            {
                gaid = gaidCache;
                UserBindGaidMessage.Instance.Send(new UserBindGaidMessage.Request(){gaid = gaid});
            }
            else
            {
                gaidCache = "missed";
            }
        }
    }

    // google
    public bool isGoogle()
    {
        if (analyticID == "market_global"/* && s_isGooglePlayAvailable*/)
            return true;
        return false;
    }
    // 检查是否是google包
    public bool isGoogleOnlyCheckAnalyticID()
    {
        return false;
    }
    // 中国包
    public bool isChina()
    {
        return isCN;
    }
    // 中东
    public bool isMiddleEast()
    {
        return false;
    }
    // 应用宝
    public bool isTencent()
    {
        return false;
    }
    // amazon
    public bool isAmazon()
    {
        return false;
    }
    // mol
    public bool isMol()
    {
        return false;
    }
    // mycard
    public bool isMycard()
    {
        return false;
    }
    // onestore
    public bool isOnestore()
    {
        return false;
    }
}

#endif





