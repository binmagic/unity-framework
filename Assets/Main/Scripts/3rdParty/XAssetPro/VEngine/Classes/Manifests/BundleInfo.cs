using System;
using System.Linq;

namespace VEngine
{
    /// <summary>
    ///     Bundle 的运行时信息
    /// </summary>
    public class BundleInfo
    {
        /// <summary>
        ///     bundle 的 id
        /// </summary>
        public int id;

        /// <summary>
        ///     bundle 名字，就是在AssetBundles中的文件名
        /// 完整的路径根据 GetBundlePathOrURL 函数获取，同时缓存到BundleWithPathOrUrLs中
        /// 这块代码参考Version.cs！
        /// </summary>
        public string name;
        
        /// <summary>
        ///     crc 用作版本校验
        /// </summary>
        public uint crc;
        
        /// <summary>
        ///     字节大小
        /// </summary>
        public ulong size;

        /// <summary>
        ///     Bundle下载方式
        /// </summary>
        public int resMode;
        
        /// <summary>
        ///     包含的所有 assets（id）
        /// </summary>
        public int[] assets = Utility.IntArrayEmpty;
        
        /// <summary>
        ///     依赖列表，这里保存的是Bundle的索引列表，其实是指向Manifest里面的dep_bundles
        /// </summary>
        public int[] deps = Utility.IntArrayEmpty;
        
    }
}





