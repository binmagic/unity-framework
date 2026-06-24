using System;
using System.Collections.Generic;
using Object = UnityEngine.Object;

namespace VEngine
{
    /// <summary>
    ///     资源管理器，提供 预加载 和 队列加载机制，目前组合在 SceneObject 使用，可以更方便管理资源内存。
    /// </summary>
    public class Assets
    {
        private readonly List<Asset> preload = new List<Asset>();
        private readonly Dictionary<string, Asset> cache = new Dictionary<string, Asset>();
        private readonly Queue<Asset> queue = new Queue<Asset>();
        private int queueSize = 10;

        public void SetQueueSize(int size, bool autoMaxSize = true)
        {
            queueSize = autoMaxSize ? Math.Max(queueSize, size) : size;
        }

        public Asset Enqueue(string path, Type type, Action<Asset> completed = null)
        {
            if (queue.Count >= queueSize)
            {
                var first = queue.Dequeue();
                first.Release();
            }

            var asset = Asset.LoadAsync(path, type, completed);
            queue.Enqueue(asset);
            return asset;
        }

        public Asset Preload(string path, Type type, Action<Asset> completed = null)
        {
            if (cache.TryGetValue(path, out var value))
            {
                return value;
            }

            value = Asset.LoadAsync(path, type, completed);
            cache.Add(path, value);
            preload.Add(value);
            return value;
        }

        public T GetAsset<T>(string path) where T : Object
        {
            if (cache.TryGetValue(path, out var value))
            {
                return value.Get<T>();
            }

            return null;
        }

        public float GetProgress()
        {
            var loaded = 0;
            foreach (var asset in preload)
            {
                if (asset.isDone)
                {
                    loaded++;
                }
            }

            return loaded * 1f / preload.Count;
        }

        public void Clear()
        {
            foreach (var asset in queue)
            {
                asset.Release();
            }

            queue.Clear();

            foreach (var item in preload)
            {
                if (string.IsNullOrEmpty(item.error))
                {
                    item.Release();
                }
            }

            preload.Clear();
            cache.Clear();
        }
    }
}





