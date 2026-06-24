#if UNITY_IOS

using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using AOT;
using GameFramework;
using UnityEngine;
using UnityGameFramework.Runtime;
using Unity.Notifications.iOS;
using LitJson;
using AppsFlyerSDK;
 
 public class PlatformIOS : IPlatformNative
{
    #region IOS Native Call

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void SendDataToGameHandler(string funcName, string data);

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate string GetDataFromGameHandler(string funcName, string data);

    [MonoPInvokeCallback(typeof(SendDataToGameHandler))]
    static void SendDataToGame(string funcName, string data)
    {
        GameEntry.Sdk.SendDataToGame(funcName, data);
    }

    [MonoPInvokeCallback(typeof(GetDataFromGameHandler))]
    static string GetDataFromGame(string funcName, string data)
    {
        Debug.LogFormat("GetDataFromGame, funcName = {0}, data = {1}", funcName, data);

        string ret = "Test1";

        return ret;
    }

    #endregion

    #region Interface function

    public bool HasSignedIn { get; set; }
    public string UID { get; set; }

    public GamePlatform ID => GamePlatform.AppleStore;

    public PaymentChannel PaymentChannel => PaymentChannel.ApplePay;

    public LoginPlatform LoginPlatform { get; set; }

    public void InitPlatform(string proxyName)
    {
        SendDataToGameHandler h1 = new SendDataToGameHandler(SendDataToGame);
        GetDataFromGameHandler h2 = new GetDataFromGameHandler(GetDataFromGame);

        IntPtr ptr1 = Marshal.GetFunctionPointerForDelegate(h1);
        IntPtr ptr2 = Marshal.GetFunctionPointerForDelegate(h2);

        SDKInitPlatform(proxyName, ptr1, ptr2);
        InitPay();
    }

    public void SignIn(string json)
    {
        if (LoginPlatform == LoginPlatform.FaceBook)
        {
            SendDataToNative("FB_Login", "");
        }
        else
        {
            SDKSignIn(json);
        }
    }

    public void SignOut()
    {
        SDKSignOut();
    }

    public void Pay(int channelId, string data)
    {
        Debug.Log("Pay " + data);
        JsonData json = JsonMapper.ToObject(data);
        string productIdentifier = json["skuId"].ToString();
        int count = 1;
        string serverOrderId = json["selfOrderId"].ToString();
        unity_iap_pay(productIdentifier, count, serverOrderId);
    }

    public void ConsumeProduct(string orderId, int status)
    {
        unity_iap_finish_transaction(orderId);
    }

    private void PushNotice(string data)
    {
        var jsonData = JsonMapper.ToObject(data);
        var type = jsonData["type"].ToString();
        var time = jsonData["time"].ToInt();
        var body = jsonData["body"].ToString();
        /*string soundKey = (string)jsonData["soundKey"];
        string pushType = (string)jsonData["pushType"];
        string playerMark = (string)jsonData["playerMark"];
        string gameUid = (string)jsonData["gameUid"];
        string pushId = (string)jsonData["pushId"];*/
        //time 必须大于0 要不IOS会崩溃
        if (time <= 0)
        {
            return;
        }

        var timeTrigger = new iOSNotificationTimeIntervalTrigger()
        {
            TimeInterval = TimeSpan.FromSeconds(time),
            Repeats = false
        };

        // You can optionally specify a custom Identifier which can later be 
        // used to cancel the notification, if you don't set one, an unique 
        // string will be generated automatically.
        var notification = new iOSNotification()
        {
            Identifier = type,
            Data = type, // 用于玩家点击通知后进入游戏传入的数据
            Title = "",
            Body = body,
            Subtitle = "",
            ShowInForeground = false, // 在前台不显示
            Trigger = timeTrigger,
        };

        iOSNotificationCenter.ScheduleNotification(notification);
    }
    private void CancelNotice(string identifier)
    {
        if (identifier.Equals("-1"))
        {
            iOSNotificationCenter.RemoveAllScheduledNotifications();
        }
        else
        {
            iOSNotificationCenter.RemoveScheduledNotification(identifier);
        }
    }
    public void SendDataToNative(string funcName, string data)
    {
        if (funcName.Equals("PUSH_PushNotice"))
        {
            Log.Info("PUSH_PushNotice");
            PushNotice(data);
        }
        else if (funcName.Equals("PUSH_CancleNotice"))
        {
            Log.Info("PUSH_CancleNotice");
            var jsonData = JsonMapper.ToObject(data);
            if (jsonData.ContainsKey("type"))
            {
                var type = jsonData["type"].ToString();
                CancelNotice(type);
            }
        } 
        else if(funcName.Equals("FireBase_getFCMToken"))
        {
            //这里名字说是获取firebase的tocken,实际上是获取ios的token
            var authorizationRequest = new AuthorizationRequest(
                AuthorizationOption.Sound | AuthorizationOption.Alert | AuthorizationOption.Badge, true);
            authorizationRequest.Dispose();
        }
        // else if (funcName.Equals("PM_InitAppFlyer"))
        // {
        //     AppsFlyer.setCustomerUserId(data);
        //     // AppsFlyer.setIsDebug(true);
        //     AppsFlyer.startSDK();
        // }
        // else if (funcName.Equals("PM_SetAppsFlyerPurchase"))
        // {
        //     var jsonData = JsonMapper.ToObject(data);
        //     string cost = (string)jsonData["cost"];
        //     string itemId = (string)jsonData["itemId"];
        //     var dictData = new Dictionary<string, string>();
        //     dictData.Add(AFInAppEvents.REVENUE,cost);
        //     dictData.Add(AFInAppEvents.CONTENT_ID,itemId);
        //     dictData.Add(AFInAppEvents.CURRENCY,"USD");
        //     AppsFlyer.sendEvent(AFInAppEvents.PURCHASE,dictData);
        // }
        // else if (funcName.Equals("PM_RecordAppsflyer"))
        // {
        //     var jsonData = JsonMapper.ToObject(data);
        //     string uid = (string)jsonData["uid"];
        //     string key = (string)jsonData["key"];
        //     var dictData = new Dictionary<string, string>();
        //     dictData.Add(AFInAppEvents.CUSTOMER_USER_ID,uid);
        //     AppsFlyer.sendEvent(key,dictData);
        // }
        else if (funcName.Equals("Pay_queryPurchase"))
        {
            unity_iap_check();
        }
        else
        {
            SDKSendDataToNative(funcName, data);
        }
    }

    public string GetDataFromNative(string funcName, string data)
    {
        if (funcName.Equals("PUSH_isNotifyOpen"))
        {
            Log.Info("PUSH_isNotifyOpen");
            return iOSNotificationCenter.GetNotificationSettings().AuthorizationStatus == AuthorizationStatus.Denied
                ? "false"
                : "true";
        }
        // else if (funcName.Equals("AF_getAppsFlyerUid"))
        // {
        //     return AppsFlyer.getAppsFlyerId();
        // }

        return SDKGetDataFromNative(funcName, data);
    }
    public string GetPermissionByType(string data)
    {
        return "1";//1授权  2拒绝   3永久拒绝
    }
    #endregion

    [DllImport("__Internal")]
    private static extern void SDKInitPlatform(string objName, IntPtr h1, IntPtr h2);

    [DllImport("__Internal")]
    private static extern void SDKSignIn(string data);

    [DllImport("__Internal")]
    private static extern void SDKSignOut();

    //[DllImport("__Internal")]
    //private static extern void SDKPay(int channelId, string json);
    //[DllImport("__Internal")]
    //private static extern void SDKConsumeProduct(string orderId, int status);
    [DllImport("__Internal")]
    private static extern void SDKSendDataToNative(string funcName, string data);

    [DllImport("__Internal")]
    private static extern string SDKGetDataFromNative(string funcName, string data);

    #region 支付
    [DllImport("__Internal")]
    private static extern void unity_iap_init();
        
    [DllImport("__Internal")]
    private static extern void unity_iap_check();

    [DllImport("__Internal")]
    private static extern void unity_iap_pay(string productIdentifier, int count, string serverOrderId);
        
    [DllImport("__Internal")]
    private static extern void unity_iap_finish_transaction(string transactionIdentifier);
        
    private  void InitPay()
    {
        unity_iap_init();
    }
        
    public void QueryPurchaseOrder()
    {
        unity_iap_check();
    }

    public string GetPayCurrencyCode(string productId)
    {
        string payCurrency = "";
        payCurrency = GameEntry.Setting.GetPublicString ("gp_currency_code", "");
        return payCurrency;
    }

    public string GetPayLocalPrice(string productId)
    {
        string _price     = "";
        string localPrice = "localPrice";
        if (productId.IsNullOrEmpty ())
            return "0";
        localPrice = GameEntry.Setting.GetPublicString (productId);
        return localPrice;
    }
    #endregion
    
}
#endif





