using System.Collections.Generic;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     实例化对象的操作，对于单个对象是同步，但是多个对象同时实例化的时候，会通过 Updater.maxUpdateTimeSlice 控制单帧最大的实例化对象的个数，从而避免卡顿。
    ///     不需要使用的时候，请通过调用 Destroy 方法销毁，这样效率会比较高，不过只要此类对象的 gameObject 被销毁了，实例化的对象会自动销毁。
    /// </summary>
    public sealed class InstantiateObject : Operation
    {
        /// <summary>
        ///     所有实例化的对象列表，当实例化的对象被销毁时，底层会自动释放列表中的对象。
        /// </summary>
        internal static readonly List<InstantiateObject> AllObjects = new List<InstantiateObject>();

        /// <summary>
        ///     对象的资源
        /// </summary>
        private Asset asset;

        /// <summary>
        ///     对象的资源路径
        /// </summary>
        public string path { get; internal set; }

        /// <summary>
        ///     实例化后的对象
        /// </summary>
        public GameObject result { get; private set; }

        public override void Start()
        {
            base.Start();
            asset = Asset.LoadAsync(path, typeof(GameObject));
            AllObjects.Add(this);
        }


        /// <summary>
        ///     实例化一个 prefab，底层会根据当前帧的空余时间对并行的实例化进行分帧处理，借以让 fps 更平滑，具体参考 Updater 类
        /// </summary>
        /// <param name="assetPath"></param>
        /// <returns><see cref="InstantiateObject" />></returns>
        public static InstantiateObject InstantiateAsync(string assetPath)
        {
            var operation = new InstantiateObject
            {
                path = assetPath
            };
            operation.Start();
            return operation;
        }

        protected override void Update()
        {
            switch (status)
            {
                case OperationStatus.Processing:
                    if (asset == null)
                    {
                        Finish("asset == null");
                        return;
                    }

                    progress = asset.progress;
                    if (!asset.isDone)
                    {
                        return;
                    }

                    if (asset.status == LoadableStatus.FailedToLoad)
                    {
                        Finish("asset.status == LoadableStatus.LoadFailed");
                        return;
                    }

                    if (asset.asset == null)
                    {
                        Finish("asset.asset == null");
                    }

                    result = Object.Instantiate(asset.asset as GameObject);
                    Finish();
                    break;
            }
        }

        /// <summary>
        ///     销毁实例化的对象
        /// </summary>
        public void Destroy()
        {
            if (!isDone)
            {
                Finish("User Cancelled");
                return;
            }

            if (status == OperationStatus.Success)
            {
                if (result != null)
                {
                    Object.DestroyImmediate(result);
                    result = null;
                }
            }

            if (asset != null)
            {
                if (string.IsNullOrEmpty(asset.error))
                {
                    asset.Release();
                }

                asset = null;
            }
        }

        public static void UpdateObjects()
        {
            for (var index = 0; index < AllObjects.Count; index++)
            {
                var item = AllObjects[index];
                if (Updater.busy)
                {
                    return;
                }

                if (!item.isDone || item.result != null)
                {
                    continue;
                }

                AllObjects.RemoveAt(index);
                index--;
                item.Destroy();
            }
        }
    }
}





