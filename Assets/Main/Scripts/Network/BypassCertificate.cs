//  ***
//  * Created by zhangliheng.
//  * DateTime: 2025/05/06 11:04 AM
//  ***/


using UnityEngine.Networking;

[UnityEngine.Scripting.Preserve]
public class BypassCertificate : CertificateHandler
{
    protected override bool ValidateCertificate(byte[] certificateData)
    {
        return true;
    }
}
