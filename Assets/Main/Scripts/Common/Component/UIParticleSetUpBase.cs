//  ***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description: 添加个基类 这样当美术制作将 UIOrderInLayerSetUp和UISurvivalParticleSetUp互相嵌套时
//      也不需要在lua ResortOrder中通过GetComponentInChildren后手动排序脚本了
//
//  ***/


/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour
 * [OUTPUT]: 对外提供抽象基类 UIParticleSetUpBase 及统一的 Refresh 契约
 * [POS]: Common/Component 的 UI 特效排序基类，让 SpriteMaskSetUp/UIOrderInLayerSetUp/UISurvivalParticleSetUp 互相嵌套时能被 Lua ResortOrder 以同一基类批量取用并排序，无需按具体类型区分
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public abstract class UIParticleSetUpBase : MonoBehaviour
{
    public void Refresh()
    {
    }
}





