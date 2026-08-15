/**
 * [INPUT]: 依赖 IPlatformNative 契约(仅 Unity 基础类型)
 * [OUTPUT]: 对外提供 PlatformEditor，编辑器下的空实现平台(登录/支付多为空操作，仅少量取值桩)
 * [POS]: Framework SDK 子系统在 UNITY_EDITOR 下的平台实现，供 SDKManager 在编辑器运行时注入——让 SDK 流程在无真机环境下可空跑
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformEditor : IPlatformNative
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
#if UNITY_ANDROID
        if (funcName == "PM_getPublishChannel")
        {
            //如果是Android平台则返回谷歌渠道，为了开关正常
            return "market_global";
        }
#endif
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



