//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

/**
 * [INPUT]: 依赖 Unity MonoBehaviour 与 GameEntry.RegisterComponent
 * [OUTPUT]: 对外提供 GameFrameworkComponent 抽象基类，在 Awake 时向 GameEntry 自注册
 * [POS]: Framework 层所有场景挂载型框架组件的抽象基类，兄弟类 BaseComponent 继承之，打通 MonoBehaviour 与全局静态入口 GameEntry 的注册桥
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

namespace UnityGameFramework.Runtime
{
    /// <summary>
    /// 游戏框架组件抽象类。
    /// </summary>
    public abstract class GameFrameworkComponent : MonoBehaviour
    {
        /// <summary>
        /// 游戏框架组件初始化。
        /// </summary>
        protected virtual void Awake()
        {
            GameEntry.RegisterComponent(this);
        }
    }
}





