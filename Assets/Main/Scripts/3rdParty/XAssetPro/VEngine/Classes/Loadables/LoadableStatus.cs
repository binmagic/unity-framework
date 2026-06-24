namespace VEngine
{
    /// <summary>
    ///     加载状态
    /// </summary>
    public enum LoadableStatus
    {
        /// <summary>
        ///     等待加载
        /// </summary>
        Wait,

        /// <summary>
        ///     加载中
        /// </summary>
        Loading,

        /// <summary>
        ///     依赖加载中
        /// </summary>
        DependentLoading,

        /// <summary>
        ///     加载成功
        /// </summary>
        SuccessToLoad,

        /// <summary>
        ///     加载失败
        /// </summary>
        FailedToLoad,

        /// <summary>
        ///     已经卸载
        /// </summary>
        Unloaded,

        /// <summary>
        ///     检查版本
        /// </summary>
        CheckVersion,

        /// <summary>
        ///     下载中
        /// </summary>
        Downloading
    }
}





