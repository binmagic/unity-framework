#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEngine;

namespace VEngine.Editor
{
    /// <summary>
    ///     打包模式
    /// </summary>
    public enum BundleMode
    {
        /// <summary>
        ///     分组中的除了场景外的所有资源按分组的名字一起打包，每个场景会按 分组名字 + 场景名字 进行打包。
        /// </summary>
        PackTogether,

        /// <summary>
        ///     资源按分组名字 + 资源一级节点名字打包
        /// </summary>
        PackByEntry,

        /// <summary>
        ///     资源按目录打包。
        /// </summary>
        PackByDirectory,

        /// <summary>
        ///     同一个分组相同 label 的资源会打包到一个 AssetBundle
        /// </summary>
        PackByLabel,

        /// <summary>
        ///     按原始格式分组
        /// </summary>
        PackByRaw,

        /// <summary>
        ///     资源按文件。
        /// </summary>
        PackByFile,

        /// <summary>
        ///     资源按顶级目录及其一级子目录归集 。
        /// </summary>
        PackByTopSubDirectoryOnly,
        
        // 根据Asset的设置进行归集
        PackByAssetSetting,
        
        // 设置打包为None,主要是为了默认值
        PackByNone,
        
        // 设置打包为Model目录, Model目录的特性是拥有
        // material, mesh, prefab, texture, animation, animator 这类目录的
        PackByModelPath,
        
        // 保留二级目录
        PackByTop2SubDirectoryOnly,
        
        // 打包到源prefab或者文件
        PackBySourcePrefabOrFile,
        
        // 打包到源prefab或者目录
        PackBySourcePrefabOrDirectory,
    }

    

    /// <summary>
    ///     打包资源的自定义分组
    /// </summary>
    public class Group : ScriptableObject
    {
        // 注释
        public string comment;
        
        /// <summary>
        ///     分组的打包模式，决定了分组资源的打包粒度
        /// </summary>
        public BundleMode bundleMode = BundleMode.PackTogether;

        /// <summary>
        ///     分组所在的清单
        /// </summary>
        public Manifest manifest;

        /// <summary>
        ///     分组中的所有资源
        /// </summary>
        [Tooltip("所有打包的资源，可以是文件加或文件")] public List<Asset> assets = new List<Asset>();

        /// <summary>
        ///     是否只读，自动分组默认会开启这个选项
        /// </summary>
        [Tooltip("分组是否只读，自动分组默认会开启这个选项")] public bool readOnly = true;

        /// <summary>
        ///     是否为auto整理模式，此模式不事先扫描asset，而是依靠依赖
        /// </summary>
        public bool autoStrip = false;

        /// <summary>
        ///     分组资源打包后包含依赖的字节大小
        /// </summary>
        public ulong size { get; set; }
        
        // 资源类型
        public ResMode resMode = ResMode.Normal;

        // group下所有的bundle name
        public List<string> allBundleNames = new List<string>();
    }
}
#endif



