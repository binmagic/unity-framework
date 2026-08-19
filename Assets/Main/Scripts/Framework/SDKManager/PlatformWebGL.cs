#if UNITY_WEBGL
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using LitJson;
using UnityEngine;

/// <summary>
/// 微信小游戏 WebGL 平台实现
/// 通过 JsBridge 调用微信小游戏 SDK (wx.* API)
/// </summary>
public class PlatformWebGL : IPlatformNative
{
    public bool HasSignedIn { get; set; }
    public string UID { get; set; }
    public GamePlatform ID => GamePlatform.Tecent;
    public PaymentChannel PaymentChannel => PaymentChannel.Default;
    public LoginPlatform LoginPlatform { get; set; }

    // JsBridge 外部声明 — 对应 WebGL JsLib 中注册的方法
    [DllImport("__Internal")]
    private static extern void wx_Login(string callbackObj, string callbackMethod);

    [DllImport("__Internal")]
    private static extern void wx_Pay(string data, string callbackObj, string callbackMethod);

    [DllImport("__Internal")]
    private static extern string wx_GetSystemInfo(string key);

    [DllImport("__Internal")]
    private static extern void wx_SendDataToNative(string funcName, string data);

    [DllImport("__Internal")]
    private static extern string wx_GetDataFromNative(string funcName, string data);

    public void InitPlatform(string proxyName)
    {
        Debug.Log("[PlatformWebGL] InitPlatform");
    }

    public void SignIn(string json)
    {
        Debug.Log("[PlatformWebGL] SignIn: " + json);
        // 微信小游戏登录流程: wx.login → code → 服务端换 openid/session_key
        wx_Login("SDKManager", "OnWxLoginCallback");
    }

    public void SignOut()
    {
        Debug.Log("[PlatformWebGL] SignOut");
        HasSignedIn = false;
        UID = "";
        // 通知 SDKManager 登出结果
        JsonData result = new JsonData();
        result["code"] = "1";
        GameEntry.Sdk.SendDataToGame("onSignOutCallback", result.ToJson());
    }

    public void Pay(int channelId, string json)
    {
        Debug.Log("[PlatformWebGL] Pay: " + json);
        wx_Pay(json, "SDKManager", "OnWxPayCallback");
    }

    public void QueryPurchaseOrder()
    {
        // 微信小游戏支付无查询接口，由服务端处理
    }

    public void ConsumeProduct(string orderId, int status)
    {
        // 微信小游戏支付为消耗型，服务端确认
    }

    public void SendDataToNative(string funcName, string data)
    {
        wx_SendDataToNative(funcName, data);
    }

    public string GetDataFromNative(string funcName, string data)
    {
        return wx_GetDataFromNative(funcName, data);
    }

    public string GetPermissionByType(string data)
    {
        // 微信小游戏权限模型不同于原生，返回已授权
        return "1";
    }
}
#endif
