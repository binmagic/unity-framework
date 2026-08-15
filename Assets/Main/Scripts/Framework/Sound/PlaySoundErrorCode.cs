//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

/**
 * [INPUT]: 无外部依赖
 * [OUTPUT]: 对外提供 PlaySoundErrorCode 枚举，标识播放声音的各类失败原因
 * [POS]: Framework 声音子系统的错误码定义，被 SoundComponent 播放流程用于错误分类，与 PlaySoundInfo 同为声音子系统的辅助数据类型
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

    /// <summary>
    /// 播放声音错误码。
    /// </summary>
    public enum PlaySoundErrorCode
    {
        /// <summary>
        /// 声音组不存在。
        /// </summary>
        SoundGroupNotExist,

        /// <summary>
        /// 声音组没有声音代理。
        /// </summary>
        SoundGroupHasNoAgent,

        /// <summary>
        /// 加载资源失败。
        /// </summary>
        LoadAssetFailure,

        /// <summary>
        /// 播放声音因优先级低被忽略。
        /// </summary>
        IgnoredDueToLowPriority,

        /// <summary>
        /// 设置声音资源失败。
        /// </summary>
        SetSoundAssetFailure,
    }





