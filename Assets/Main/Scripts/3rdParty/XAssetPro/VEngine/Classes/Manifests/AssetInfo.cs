using System;
using System.Linq;

namespace VEngine
{
    /// <summary>
    ///     Asset 的运行时信息
    /// </summary>
    /// 这个地方的优化略有牵强，不过还是处理一下吧
    /// 具体参考：http://clarkkromenaker.com/post/csharp-structs/
    public struct AssetInfo
    {
        /// <summary>
        ///     资源索引，对应Manifest的 allAssetPaths下标
        /// </summary>
        public int id;
        
        /// <summary>
        ///     资源名字 对应的 bundle（id）
        /// </summary>
        public int bundle;
    }
}





