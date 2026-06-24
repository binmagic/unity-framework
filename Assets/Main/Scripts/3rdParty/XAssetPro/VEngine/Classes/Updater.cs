using System;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     更新器，运行时所有需要分帧的 Update 操作通过此类集中处理，并尽可能将单帧的 Update 操作
    ///     控制在 maxUpdateTimeSlice 以内，从而让程序的流畅度得到控制。
    /// </summary>
    public sealed class Updater : MonoBehaviour
    {
        /// <summary>
        ///     单帧最大处理的时间片（毫秒）
        /// </summary>
        public static float maxUpdateTimeSlice = 25;

        /// <summary>
        ///     当前帧的初始时间，单位毫秒。
        /// </summary>
        public static double time { get; private set; }

        /// <summary>
        ///     判断当前更新器是否处于超时状态，如果超时表示当前帧已经满负荷了，余下的操作应该放到下一帧处理。
        /// </summary>
        public static bool busy => DateTime.Now.TimeOfDay.TotalMilliseconds - time >= maxUpdateTimeSlice;

        public static Action onUpdate { get; set; }


        private void Awake()
        {
            AddUpdateCallback(Download.UpdateDownloads);
            AddUpdateCallback(Loadable.UpdateLoadables);
            AddUpdateCallback(Operation.UpdateOperations);
        }

        private void Update()
        {
            time = DateTime.Now.TimeOfDay.TotalMilliseconds;
            if (onUpdate != null)
            {
                onUpdate();
            }
        }

        [RuntimeInitializeOnLoadMethod]
        private static void InitializeOnLoad()
        {
            var updater = FindObjectOfType<Updater>();
            if (updater == null)
            {
                updater = new GameObject("[XAsset Updater]").AddComponent<Updater>();
                DontDestroyOnLoad(updater);
            }
        }

        public static void AddUpdateCallback(Action callback)
        {
            onUpdate += callback;
        }

        public static void RemoveUpdateCallback(Action callback)
        {
            onUpdate -= callback;
        }
    }
}





