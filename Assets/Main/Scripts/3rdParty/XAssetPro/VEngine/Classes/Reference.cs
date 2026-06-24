namespace VEngine
{
    /// <summary>
    /// 引用类，提了基于 MRC 的引用计数机制，对比 C# 的 WeakReference，这种相对原始的引用计数在 跨语言的环境中，例如，采用 Lua 写业务的项目，具备更好的兼容性和稳定性。
    /// </summary>
    public class Reference
    {
        /// <summary>
        /// 引用次数
        /// </summary>
        public int count { get; private set; }

        /// <summary>
        /// 是否被引用
        /// </summary>
        public bool unused
        {
            get { return count <= 0; }
        }

        /// <summary>
        /// 增加引用次数
        /// </summary>
        public void Retain()
        {
            count++;
        }

        /// <summary>
        /// 释放引用次数
        /// </summary>
        public void Release()
        {
            count--;
        }
    }
}





