//  ***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description: 添加个基类 这样当美术制作将 UIOrderInLayerSetUp和UISurvivalParticleSetUp互相嵌套时
//      也不需要在lua ResortOrder中通过GetComponentInChildren后手动排序脚本了
//
//  ***/


using UnityEngine;

public abstract class UIParticleSetUpBase : MonoBehaviour
{
    public void Refresh()
    {
    }
}





