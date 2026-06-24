using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IPlatformNative
{
    bool HasSignedIn
    {
        get;
        set;
    }

    string UID
    {
        get;
        set;
    }

    GamePlatform ID
    {
        get;
    }

    PaymentChannel PaymentChannel
    {
        get;
    }

    LoginPlatform LoginPlatform
    {
        get;
        set;
    }

    void InitPlatform(string proxyName);
    void SignIn(string json);
    void SignOut();
    void Pay(int channelId, string json);
    void QueryPurchaseOrder();
    void ConsumeProduct(string orderId, int status);
    void SendDataToNative(string funcName, string data);
    string GetDataFromNative(string funcName, string data);
    string GetPermissionByType(string data);
}

public enum GamePlatform
{
    Default = 0,
    GooglePlay,
    AppleStore,
    Tecent,
}

public enum LoginPlatform
{
    GameCenter = 0,
    GooglePlay,
    FaceBook,
    WeChat,
}

public enum PaymentChannel
{
    Default = 0,
    GooglePay,
    ApplePay,
}

[System.Serializable]
public class PlatformResult
{
    public string code;
}





