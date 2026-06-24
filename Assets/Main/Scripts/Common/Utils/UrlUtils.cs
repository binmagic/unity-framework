using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityGameFramework.Runtime;

public static class UrlUtils
{
    private const string HEAD_URL_MID = "http://app1.im.medrickgames.com:8086/ds/img/";
    private const string HEAD_URL = "https://im30-i.akamaized.net/ds/img/";

    //判断是否是自定义头像
    public static bool IsUseCustomPic(int picVer)
    {
        if (picVer > 0 && picVer < 1000000)
        {
            return true;
        }
        return false;
    }

    public static bool GenCustomPicUrl(string uid, int picVer, out string url, out string key)
    {
        url = "";
        key = "";
        string md5Str = uid + string.Format("_{0}", picVer);
        string md5 = AESHelper.GetMd5Hash(md5Str);

        // 取uid末尾6位
        string tempStr = uid;
        if (tempStr.Length > 6)
        {
            tempStr = tempStr.Substring(tempStr.Length - 6);
        }

        key = tempStr + "/" + md5 + ".jpg";
        string cachePath = Path.Combine(Application.persistentDataPath, "Images", "heads", key);
        if (File.Exists(cachePath))
        {
            url = "file://" + cachePath;
        }
        else
        {
            if (GameEntry.GlobalData.isMiddleEast())
            {
                url = HEAD_URL_MID + key;
            }
            else
            {
                url = HEAD_URL + key;
            }
        }

        return true;
    }

    // public static string GetAudioUrl()
    // {
    //     return CommonUtils.IsDebug() ? "http://10.7.88.22:8800" : "https://chat.im30app.com";
    // }
    //
    // public static bool GenCustomVoiceMsgUrl(string audioName, out string url, out string key)
    // {
    //     url = "";
    //     key = "";
    //     if (string.IsNullOrEmpty(audioName))
    //     {
    //         return false;
    //     }
    //
    //     key = "recordings/" + audioName;
    //     string cachePath = Path.Combine(Application.persistentDataPath, "Audio", "recordings", audioName);
    //     if (File.Exists(cachePath))
    //     {
    //         url = "file://" + cachePath;
    //     }
    //     else
    //     {
    //         url = string.Format("{0}/{1}/{2}/{3}",
    //                         GetAudioUrl(),
    //                         ChatService.DOWNLOAD_AUDIO_URL,
    //                         ChatService.APP_ID,
    //                         audioName);
    //     }
    //
    //     return true;
    // }

    //public static bool GenAssetBundleUrlOnCdn(DownloadInfo info, out string url, out string key)
    //{
    //    url = "";
    //    key = "";
    //    if (info == null)
    //    {
    //        return false;
    //    }

    //    string remotePath = Path.Combine(Application.identifier, info.name, AssetBundles.Utility.GetPlatformName(), info.version, string.IsNullOrEmpty(info.md5) ? info.assetbundle : info.md5);

    //    key = info.assetbundle;
    //    url = GetCdnUrl() + remotePath;

    //    return true;
    //}
}





