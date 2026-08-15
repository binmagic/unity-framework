//  ***
//  * Created by zhangliheng.
//  * DateTime: 2025/05/06 11:04 AM
//  ***/

/**
 * [INPUT]: 依赖 UnityEngine.Networking 的 CertificateHandler 基类
 * [OUTPUT]: 对外提供 BypassCertificate，一律放行 HTTPS 证书校验（供 UnityWebRequest 挂载）
 * [POS]: Network 模块的 HTTP 传输辅助类，服务于 BestHTTP/UnityWebRequest 场景，与消息定义类无继承关系，仅解决自签名/测试环境证书问题
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine.Networking;

[UnityEngine.Scripting.Preserve]
public class BypassCertificate : CertificateHandler
{
    protected override bool ValidateCertificate(byte[] certificateData)
    {
        return true;
    }
}
