using System;
using System.Collections;
using System.Collections.Generic;

namespace VEngine
{
    /// <summary>
    ///     操作基类
    /// </summary>
    public class Operation : IEnumerator
    {
        internal static readonly List<Operation> Processing = new List<Operation>();

        /// <summary>
        ///     操作完成时的回调
        /// </summary>
        public Action<Operation> completed;

        /// <summary>
        ///     操作状态，在完成时，可以用这个来判断操作是成功还是失败
        /// </summary>
        public OperationStatus status { get; protected set; } = OperationStatus.Idle;


        /// <summary>
        ///     操作的进度
        /// </summary>
        public float progress { get; protected set; }

        /// <summary>
        ///     操作是否执行完成，默认操作完成为操作成功或失败时
        /// </summary>
        public bool isDone => status == OperationStatus.Failed || status == OperationStatus.Success;

        /// <summary>
        ///     操作失败时，操作的错误内容
        /// </summary>
        public string error { get; protected set; }
        
        public bool isError
        {
            get { return !string.IsNullOrEmpty(error); }
        }

        public bool MoveNext()
        {
            return !isDone;
        }

        public void Reset()
        {
        }

        public object Current { get; } = null;

        internal static void Process(Operation operation)
        {
            operation.status = OperationStatus.Processing;
            Processing.Add(operation);
        }

        protected virtual void Update()
        {
        }

        public virtual void Start()
        {
            status = OperationStatus.Processing;
            Process(this);
        }

        public void Cancel()
        {
            Finish("User Cancel.");
        }

        protected void Finish(string errorCode = null)
        {
            error = errorCode;
            status = string.IsNullOrEmpty(error) ? OperationStatus.Success : OperationStatus.Failed;
            progress = 1;
        }

        protected void Complete()
        {
            if (completed == null)
            {
                return;
            }

            var saved = completed;
            completed.Invoke(this);
            completed -= saved;
        }

        public static void UpdateOperations()
        {
            for (var index = 0; index < Processing.Count; index++)
            {
                var item = Processing[index];
                if (Updater.busy)
                {
                    return;
                }

                item.Update();
                if (!item.isDone)
                {
                    continue;
                }

                Processing.RemoveAt(index);
                index--;
                if (item.status == OperationStatus.Failed)
                {
                    //Logger.E("Unable to complete {0} with error: {1}", item.GetType().Name, item.error);
                    CommonUtils.LogErrorWithPost($"#XAsset# Unable to complete {item.GetType().Name} with error: {item.error}");
                }

                item.Complete();
            }

            InstantiateObject.UpdateObjects();
        }
    }
}





