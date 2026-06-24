#if UNITY_STANDALONE
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformStandalone : IPlatformNative
{
    public bool HasSignedIn { get; set; }
    public string UID { get; set; }

    public GamePlatform ID => GamePlatform.Default;

    public PaymentChannel PaymentChannel => PaymentChannel.Default;

    public LoginPlatform LoginPlatform { get; set; }

    public void ConsumeProduct(string orderId, int status)
    {
        //throw new System.NotImplementedException();
    }

    public string GetDataFromNative(string funcName, string data)
    {
        return "";
    }

    public void InitPlatform(string proxyName)
    {

    }

    public string GetPermissionByType(string data)
    {
        return "1";//1授权  2拒绝   3永久拒绝
    }
    

    public void Pay(int channelId, string json)
    {
        throw new System.NotImplementedException();
    }

    public void QueryPurchaseOrder()
    {
        
    }

    public void SendDataToNative(string funcName, string data)
    {

    }

    public void SignIn(string json)
    {
        
    }

    public void SignOut()
    {
        throw new System.NotImplementedException();
    }
}
#endif





