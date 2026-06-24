namespace VEngine
{
    /// <summary>
    ///     操作状态
    /// </summary>
    public enum OperationStatus
    {
        /// <summary>
        ///     闲置的
        /// </summary>
        Idle,

        /// <summary>
        ///     执行中，会进行 Update
        /// </summary>
        Processing,

        /// <summary>
        ///     成功
        /// </summary>
        Success,

        /// <summary>
        ///     失败
        /// </summary>
        Failed
    }
}





