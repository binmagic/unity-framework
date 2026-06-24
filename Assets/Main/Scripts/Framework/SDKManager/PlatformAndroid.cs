#if UNITY_ANDROID
using System;
using System.Collections;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;
using UnityGameFramework.Runtime;

public class PlatformAndroid : AndroidJavaProxy, IPlatformNative
{
    private AndroidJavaObject currentActivity_;
    private AndroidJavaObject currentActivity
    {
        get
        {
            if (currentActivity_ != null)
            {
                return currentActivity_;
            }
            
            try
            {
                AndroidJavaClass unityClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
                currentActivity_ = unityClass.GetStatic<AndroidJavaObject>("currentActivity");
                Debug.LogFormat("CurrentActivity: {0}", currentActivity_.GetRawObject());
                return currentActivity_;
            }
            catch (Exception exception)
            {
                return null;
            }
        }
    }
    
    public const string GOOGLE_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjnC2tvJsZyHzXlAg5RpiBEHso5k3BRcAp42K2PMgNAB0ebz4vt8VPbO+Uuj45jwLVobVusdmEOmCM8N65IrHdkP0/5x9bLy0KpNH3Efik+wjEglj+xwrAotX106emktjT+iXnIMTdPzwT3TnzsRv3R5ny9klJHhr7G/BlLjFCx6a7EJt40UEqMHXUQXBN8FaXGXCpI0UVAEkmBxoG2WYA+jlO5yEpoaUdupl65VElj/LiUtPHdXRa9hKMDvx/ti6EJI8CDQgGgS6O8OcighhBrk8WI39bcnkYtHk3Y1S2HgLwdwALM6ITBQHyDst/ZDMOexR5bGKX/k+eiOE3QDnFQIDAQAB";
    public const string BUGLY_KEY = "f550d68ac8";
    // 使用一个缓存的objects数组
    object[] args_ = new object[2];

    public PlatformAndroid(string listenerClassName) : base(listenerClassName)
    {
        // AndroidJavaClass unityClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        // currentActivity = unityClass.GetStatic<AndroidJavaObject>("currentActivity");
    }

    #region Android Native Call
    /// <summary>
    /// 从Activity中调用非静态方法
    /// </summary>
    /// <param name="funcName">Func name.</param>
    /// <param name="args">Arguments.</param>
    public void Call(string funcName, params object[] args)
    {
        try
        {
            if (currentActivity != null)
            {
                currentActivity.Call(funcName, args);
            }
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }
    }

    public void SaveToCache(string key)
    {
        // string value = PlayerPrefs.GetString("NativeKey", key);
        // value = $"{value}|{key}";
        // PlayerPrefs.SetString("NativeKey", value);
        // PlayerPrefs.Save();
    }

    /// <summary>
    /// 从Activity中调用带返回值的非静态方法
    /// </summary>
    /// <returns>The call.</returns>
    /// <param name="funcName">Func name.</param>
    /// <param name="args">Arguments.</param>
    /// <typeparam name="T">The 1st type parameter.</typeparam>
    public T Call<T>(string funcName, params object[] args)
    {
        T ret = default;
        try
        {
            if (currentActivity != null)
            {
                SaveToCache(funcName);
                ret = currentActivity.Call<T>(funcName, args);
            }
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }

        return ret;
    }

    /// <summary>
    /// 从ActivityClass中调用静态方法
    /// </summary>
    /// <param name="funcName">Func name.</param>
    /// <param name="args">Arguments.</param>
    public void CallStatic(string funcName, params object[] args)
    {
        try
        {
            if (currentActivity != null)
            {
                SaveToCache(funcName);
                currentActivity.CallStatic(funcName, args);
            }
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }
    }

    /// <summary>
    /// 从ActivityClass中调用带返回值的静态方法
    /// </summary>
    /// <returns>The call.</returns>
    /// <param name="funcName">Func name.</param>
    /// <param name="args">Arguments.</param>
    /// <typeparam name="T">The 1st type parameter.</typeparam>
    public T CallStatic<T>(string funcName, params object[] args)
    {
        T ret = default;
        try
        {
            if (currentActivity != null)
            {
                SaveToCache(funcName);
                ret = currentActivity.Call<T>(funcName, args);
            }
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }

        return ret;
    }

    /// <summary>
    /// 从Activity中获取非静态字段
    /// </summary>
    /// <returns>The get.</returns>
    /// <param name="fieldName">Field name.</param>
    /// <typeparam name="T">The 1st type parameter.</typeparam>
    public T Get<T>(string fieldName)
    {
        try
        {
            if (currentActivity != null)
                return currentActivity.Get<T>(fieldName);
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }

        return default;
    }

    /// <summary>
    /// 从Activity中获取静态字段
    /// </summary>
    /// <returns>The static.</returns>
    /// <param name="fieldName">Field name.</param>
    /// <typeparam name="T">The 1st type parameter.</typeparam>
    public T GetStatic<T>(string fieldName)
    {
        try
        {
            if (currentActivity != null)
                return currentActivity.GetStatic<T>(fieldName);
        }
        catch (System.Exception e)
        {
            PostEventLog.Record("Log_Crash", e.StackTrace);
            Debug.LogError(e);
        }

        return default;
    }
    #endregion

    #region Listener from AndroidJavaProxy
    public void SendDataToGame(string funcName, string data)
    {
        Log.Debug("SendDataToGame, funcName = {0}, data = {1}", funcName, data);
        GameEntry.Sdk.SendDataToGame(funcName, data);
    }

    public object GetDataFromGame(string funcName, string data)
    {
        object ret = null;

        try
        {
            switch (funcName)
            {
                case "getPlatform":
                    ret = ID.ToString();
                    break;
                case "getGpk":
                    ret = GOOGLE_PUBLIC_KEY;
                    break;
                case "getBuglyId":
                    ret = BUGLY_KEY;
                    break;
            }
        }
        catch (Exception e)
        {
            Log.Error(e);
        }

        if (ret == null)
            Log.Error("GetDataFromGame: funcName = {0}, data = {1}, ret is null!", funcName, data);
        else
            Log.Info("GetDataFromGame: funcName = {0}, data = {1}, ret = {2}", funcName, data, ret);

        return ret;
    }
    #endregion

    #region Interface function

    public bool HasSignedIn { get; set; }

    public string UID { get; set; }

    public GamePlatform ID => GamePlatform.GooglePlay;

    public PaymentChannel PaymentChannel => PaymentChannel.GooglePay;

    public LoginPlatform LoginPlatform { get; set; }

    public void SendDataToNative(string funcName, string data)
    {
        // args_[0] = funcName ?? "";
        // args_[1] = data ?? "";
        // Call("SendDataToNative", args_);

        if (funcName.IsNullOrEmpty())
        {
            return;
        }
        
        Call("SendDataToNative", funcName, data ?? "");
    }

    public string GetDataFromNative(string funcName, string data)
    {
        if (funcName.IsNullOrEmpty())
        {
            Debug.Log("GetDataFromNative no funcName!");
            return "";
        }
        
        string ret = Call<string>("GetDataFromNative", funcName, data ?? "");
        if (string.IsNullOrEmpty(ret))
            ret = "";

        return ret;
    }
    
    public string GetPermissionByType(string data)
    {
        return GetDataFromNative("PM_GetPermit", data);
    }

    public void InitPlatform(string proxyName)
    {
        Call("InitPlatform", proxyName, this);
    }

    public void SignIn(string json)
    {
        Call("SignIn", json);
    }

    public void SignOut()
    {
        Call("SignOut");
    }

    public void Pay(int channelId, string json)
    {
        Call("Pay", channelId, json);
    }

    public void QueryPurchaseOrder()
    {
        SendDataToNative("Pay_queryPurchase", "");
    }

    public void ConsumeProduct(string orderId, int status)
    {
        Call("ConsumeProduct", orderId, status);
    }
    #endregion
    
}
#endif





