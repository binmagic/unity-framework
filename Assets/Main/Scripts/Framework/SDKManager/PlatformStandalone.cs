/**
 * [INPUT]: 依赖 IPlatformNative 契约(仅 Unity 基础类型)
 * [OUTPUT]: 对外提供 PlatformStandalone，PC 单机平台的空实现(无登录支付渠道)
 * [POS]: Framework SDK 子系统在 UNITY_STANDALONE 下的平台实现，供 SDKManager 注入——PC 端无第三方 SDK 时的占位实现
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





