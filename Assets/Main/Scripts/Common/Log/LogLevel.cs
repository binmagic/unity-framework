//------------------------------------------------------------
// Game Framework
// Copyright © 2013-2021 Jiang Yin. All rights reserved.
// Homepage: https://gameframework.cn/
// Feedback: mailto:ellan@gameframework.cn
//------------------------------------------------------------

/**
 * [INPUT]: 无外部依赖,纯枚举定义
 * [OUTPUT]: 对外提供 GameFramework.LogLevel 枚举,划分 Debug/Info/Warning/Error/Fatal 日志分级
 * [POS]: Common/Log 的日志分级基准,被 Log 门面用于过滤输出,是整个日志系统的严重度词汇表
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
namespace GameFramework
{
    /// <summary>
    /// 日志等级。
    /// </summary>
    public enum LogLevel
    {
        /// <summary>
        /// 调试。
        /// </summary>
        Debug,

        /// <summary>
        /// 信息。
        /// </summary>
        Info,

        /// <summary>
        /// 警告。
        /// </summary>
        Warning,

        /// <summary>
        /// 错误。
        /// </summary>
        Error,

        /// <summary>
        /// 严重错误。
        /// </summary>
        Fatal
    }
}





