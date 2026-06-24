using System;
using System.Text;
using UnityEngine;
using Random = UnityEngine.Random;

public class DeviceManager
{
    public int GetNetworkStatus()
    {
        //Unity 0.无网络 1.运营商 2.局域网
        //Cocos 0.无网络 1.WIFI 2.234G
        //和cocos是反的，是否需要换过来？服务器拿这个数据做什么？

        NetworkReachability netType = GetNetworkType();
        return netType == NetworkReachability.ReachableViaCarrierDataNetwork ? 2 : netType == NetworkReachability.ReachableViaLocalAreaNetwork ? 1 : 0;
    }

    public NetworkReachability GetNetworkType()
    {
        return Application.internetReachability;
    }
    
    public string GetNetworkTypeDesc()
    {
        NetworkReachability netType = GetNetworkType();
        string res = "";
        switch (netType)
        {
            case NetworkReachability.NotReachable:
                res = "no net";
                break;
            case NetworkReachability.ReachableViaCarrierDataNetwork:
                res = "4g";
                break;
            case NetworkReachability.ReachableViaLocalAreaNetwork:
                res = "wifi";
                break;
        }

        return res;
    }

    public string GetSerialID()
    {
        return GameEntry.Sdk.GetSerialID();
    }

    public string GetDeviceInfo()
    {
        return GameEntry.Sdk.GetDeviceInfo();
    }

    public string GetHandSetInfo()
    {
        return GameEntry.Sdk.GetHandSetInfo();
    }

    public string GetNewAndroidDeviceID()
    {
        return GameEntry.Sdk.GenerateHighVersionUUID();
    }

    public string GetOSVersion()
    {
        return SystemInfo.operatingSystem;
    }

    public float GetBatteryLevel()
    {
        return SystemInfo.batteryLevel;
    }

    public BatteryStatus GetBatteryStatus()
    {
        return SystemInfo.batteryStatus;
    }

    public string GetProcessorType()
    {
        return SystemInfo.processorType;
    }

    public int GetProcessorCount()
    {
        return SystemInfo.processorCount;
    }

    public string GetProcessorFrequency()
    {
        return string.Format("{0} MHz", SystemInfo.processorFrequency);
    }

    public int GetSystemMemorySize()
    {
        return SystemInfo.systemMemorySize;
    }

    public string GetDeviceModel()
    {
        return SystemInfo.deviceModel;
    }

    public DeviceType GetDeviceType()
    {
        return SystemInfo.deviceType;
    }

    private string GenerateDeviceUniqueId()
    {
        return SystemInfo.deviceUniqueIdentifier + Random.Range(100000, 1000000);
    }

    private string m_strDeviceUid = "";
    public string GetDeviceUid()
    {
//        return "emula_4a4c6e072a48496f850dcd254bb21a09_3d";
        //deviceId做缓存，不要每次都去android里拿
        if (!m_strDeviceUid.IsNullOrEmpty())
        {
            return m_strDeviceUid;
        }

        // debug版本保持和aps一样，不用重新加白名单，只有release使用lm.txt即可
        string devFile = "deviceId.txt";
        if (!CommonUtils.IsDebug())
        {
            devFile = "deviceId_lm.txt";
        }

        string deviceID = GameEntry.Sdk.GetDataFromNative("PM_getDatFromFile", devFile);
        if (deviceID != ""){
            m_strDeviceUid = deviceID;
            return m_strDeviceUid;
        }
        
        deviceID = GameEntry.Setting.GetString(GameDefines.SettingKeys.DEVICE_ID, "");

        //Debug.LogFormat("-dd- : {0}", deviceID);
        return deviceID;
    }

    // 新生成一个deviceId，deviceId标识我们一个游戏的设备，一般是在第一次注册的时候生成的
    // 注册的时候生成，然后将这个uuid保存到本地的一个文件中。以后整个游戏期间就使用这个deviceid
    // 具体参看文章：https://developer.android.com/training/articles/user-data-ids?hl=zh-cn
    public string NewDeviceID()
    {
        // debug版本保持和aps一样，不用重新加白名单，只有release使用lm.txt即可
        string devFile = "deviceId.txt";
        if (!CommonUtils.IsDebug())
        {
            devFile = "deviceId_lm.txt";
        }

        string deviceID = "";
        
#if UNITY_IOS || UNITY_ANDROID
        deviceID = GameEntry.Sdk.GetDeviceUDID();
        if (string.IsNullOrEmpty(deviceID))
        {
            Debug.LogError("原生层获取设备ID为空,请及时排查~");
        }
        else
        {
            deviceID = deviceID.Trim();
        }
#endif

        if (deviceID.IsNullOrEmpty())
        {
            deviceID = GenerateDeviceUniqueId();
            //后缀在java层做了处理了
            if (CommonUtils.IsDebug())
            {
                deviceID += "_3d";
            }
            else
            {
                deviceID += "_BA88";
            }
        }
        
        GameEntry.Setting.SetString(GameDefines.SettingKeys.DEVICE_ID, deviceID);
        
        GameEntry.Sdk.saveDataToSdcard(deviceID, devFile);
        m_strDeviceUid = deviceID;

        Debug.LogFormat("+dd+ : {0}", deviceID);
        return deviceID;
    }

    private string m_zoneId;
    public string GetTimeZoneId()
    {
        if (!string.IsNullOrEmpty(m_zoneId))
            return m_zoneId;
        m_zoneId = GameEntry.Sdk.GetZoneIdFromNative();
        return m_zoneId;
    }

    // 获取设备整体信息
    public string GetDeviceString()
    {
        StringBuilder sb = new StringBuilder();

        sb.AppendFormat("Model={0}|", SystemInfo.deviceModel);
        sb.AppendFormat("Memory={0}|", SystemInfo.systemMemorySize);
        sb.AppendFormat("Vendor={0}|", SystemInfo.graphicsDeviceVendor);
        sb.AppendFormat("Processor={0}|", SystemInfo.processorFrequency);
        sb.AppendFormat("Graphics={0}|", SystemInfo.graphicsDeviceName);
        sb.AppendFormat("DeviceType={0}|", getGraphicsDeviceType());
        sb.AppendFormat("ZoneId={0}|", GetTimeZoneId());
        sb.AppendFormat("deviceLang={0}|", GameEntry.Localization.GetDeviceLang());
        
        return sb.ToString();
    }

    public int GetOpenGL()
    {
        int version = 0;
#if (UNITY_ANDROID && !UNITY_EDITOR)
    
        try
        {
            using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            {
                using (AndroidJavaObject currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    using (AndroidJavaObject curApplication = currentActivity.Call<AndroidJavaObject>("getApplication"))
                    {
                        using (AndroidJavaObject curSystemService = curApplication.Call<AndroidJavaObject>("getSystemService", "activity"))
                        {
                            using (AndroidJavaObject curConfigurationInfo = curSystemService.Call<AndroidJavaObject>("getDeviceConfigurationInfo"))
                            {
                                int reqGlEsVersion = curConfigurationInfo.Get<int>("reqGlEsVersion");
                                return reqGlEsVersion;
                            }
                        }
                    }
                } 
            }
        }
        catch (Exception e)
        {
        }
        
#elif (UNITY_IOS && !UNITY_EDITOR)
        version = 0;
#endif
        return version;
    }
    
    public string getGraphicsDeviceType()
    {
        try
        {
#if UNITY_EDITOR
            var szGLVersion = SystemInfo.graphicsDeviceVersion;
#elif UNITY_IOS
            var szGLVersion = SystemInfo.graphicsDeviceVersion;
#else
            var dGLVersion = GetOpenGL();
            int bigVersion = dGLVersion >> 16;
            int smallVersion = dGLVersion & 0xffff;
            var szGLVersion = $"OpenGL{bigVersion}.{smallVersion}";
#endif
            bool isSupportDXT = isSupportDxt();
            bool isSupportAstc = IsSupportASTC();
            bool isSupportEtc2 = IsSupportEtc2();
            StringBuilder sBuilder = new StringBuilder();
            sBuilder.Append(szGLVersion);
            if (isSupportAstc)
                sBuilder.Append("-ASTC");
            if (isSupportEtc2)
                sBuilder.Append("-ETC2");
            if (isSupportDXT)
                sBuilder.Append("-DXT");
            if (SystemInfo.SupportsTextureFormat(TextureFormat.ASTC_4x4))
                sBuilder.Append("-ASTC_4x4");
            if (SystemInfo.SupportsTextureFormat(TextureFormat.ASTC_6x6))
                sBuilder.Append("-ASTC_6x6");
            return sBuilder.ToString();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }

        return "";
    }

    public bool isSupportDxt()
    {
        bool isSupport = false;
#if UNITY_ANDROID
        isSupport = SystemInfo.SupportsTextureFormat(TextureFormat.DXT1) ||
                    SystemInfo.SupportsTextureFormat(TextureFormat.DXT5) ||
                    SystemInfo.SupportsTextureFormat(TextureFormat.DXT1Crunched) ||
                    SystemInfo.SupportsTextureFormat(TextureFormat.DXT5Crunched);
#endif
        
        return isSupport;
    }

    public bool IsSupportASTC()
    {
        bool isSupport = false;
 
        for (TextureFormat i = TextureFormat.ASTC_4x4; i <= TextureFormat.ASTC_12x12; i++)
        {
            isSupport = SystemInfo.SupportsTextureFormat(i);
            if (!isSupport)
                return isSupport;
        }
        return isSupport;
    }

    public bool IsSupportEtc2()
    {
        bool isSupport = false;
 
        for (TextureFormat i = TextureFormat.ETC2_RGB; i <= TextureFormat.ETC2_RGBA8; i++)
        {
            isSupport = SystemInfo.SupportsTextureFormat(i);
            if (!isSupport)
                return isSupport;
        }
        return isSupport;
    }

}





