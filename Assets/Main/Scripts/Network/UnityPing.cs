/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour/Coroutine/Ping，依赖 System.Net.Dns 域名解析
 * [OUTPUT]: 对外提供 UnityPing 组件，CreatePing 以协程对指定 IP 发起 ICMP 探测并回调耗时（含超时保护）
 * [POS]: Network 模块的链路测速工具，独立于 BaseMessage 消息体系，服务于选服/网络质量检测；与 FutureManager 的应用层 RTT 统计互补，此处为底层网络延迟
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using System.Net;
using UnityEngine;

public class UnityPing : MonoBehaviour
{

    private string s_ip = "";
    private System.Action<int> s_callback = null;
    private int s_timeout = 2;
    private Coroutine curCoroutine;
    public void CreatePing(string ip, System.Action<int> callback)
    {
        if (string.IsNullOrEmpty(ip)) return;
        if (callback == null) return;
        s_ip = ip;
        s_callback = callback;
        if (curCoroutine != null)
        {
            StopCoroutine(this.curCoroutine);
        }
        
        curCoroutine = StartCoroutine(this.PingConnect());
    }

    private void OnDestroy()
    {
        if (curCoroutine != null)
        {
            StopCoroutine(this.curCoroutine);
        }
        s_ip = "";
        s_timeout = 2;
        s_callback = null;
    }
    
    IEnumerator PingConnect()
    {
        // Ping网站
        var ip = Dns.GetHostAddresses(s_ip);
        if (ip.Length <= 0)
        {
            yield return null;
        }

        var ip0 = ip[0].ToString();
        Ping ping = new Ping(ip0);
        int addTime = 0;
        int requestCount = s_timeout * 10; 
        // 等待请求返回
        while (!ping.isDone)
        {
            yield return new WaitForSeconds(0.1f);
            // ping = new Ping(s_ip);
            // 链接失败
            if (addTime > requestCount)
            {
                if (s_callback != null)
                {
                    s_callback(ping.time);
                }
                yield break;
            }
            addTime++;
        }
        // 链接成功
        if (ping.isDone)
        {
            if (s_callback != null)
            {
                s_callback(ping.time);
            }
            yield return null;
        }
    }
}





