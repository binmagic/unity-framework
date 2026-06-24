#if UNITY_EDITOR
using System;
using UnityEngine;

namespace VEngine.Editor
{
    /// <summary>
    ///     播放器分组配置
    /// </summary>
    [Serializable]
    public class PlayerGroups
    {
        /// <summary>
        ///     渠道名字
        /// </summary>
        [Tooltip("打包分组名字")] public string name;

        /// <summary>
        ///     分组名字
        /// </summary>
        [Tooltip("包含的分组名字")] public string[] groups;

        /// <summary>
        ///     是否开启分包，不开启会包含完整资源，开启后只复制 groups 中定义的资源
        /// </summary>
        [Tooltip("是否开启分包，不开启会包含完整资源，开启后只复制 groups 中定义的资源")]
        public bool splitBuildWithGroups;
    }
}
#endif



