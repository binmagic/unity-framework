using System;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     可加载类，自带缓存，并提供了基于引用计数的内存管理机制，目前实现的一级子类主要有 Asset, Bundle。
    ///     此类对象在 Release 的时候，会检查对象是否有使用，如果没有使用就会添加到 Unused 的列表，然后在 Updater 中集中卸载。
    ///     集中卸载时，如果发现对象又被使用了，则只会从 Unused 列表删除对象不会发生真正的卸载操作，否则就会触发真正的卸载了。
    /// </summary>
    public class Loadable
    {
        public static uint BundleEncodeOffset = 8;
        /// <summary>
        ///     加载中的列表，会在 Updater 中集中更新状态
        /// </summary>
        internal static readonly List<Loadable> Loading = new List<Loadable>();

        // 根据当前资源加载的数量，自动设置一下读取线程的优先级
        public static ThreadPriority CurPriority = ThreadPriority.BelowNormal;
        public static double CurSetTime = 0;

        /// <summary>
        ///     引用计数
        /// </summary>
        protected readonly Reference reference = new Reference();

        /// <summary>
        ///     加载对象的状态，对象加载完成后，最好先检查状态判断是否正常加载。
        /// </summary>
        public LoadableStatus status { get; protected set; } = LoadableStatus.Wait;

        /// <summary>
        ///     加载路径
        /// </summary>
        public string pathOrURL { get; set; }

        /// <summary>
        ///     是否是同步加载
        /// </summary>
        protected bool mustCompleteOnNextFrame { get; set; }

        /// <summary>
        ///     如果加载出错可以通过这个属性获取错误信息
        /// </summary>
        public string error { get; internal set; }

        public bool isError
        {
            get { return !string.IsNullOrEmpty(error); }
        }


        /// <summary>
        ///     是否完成了加载
        /// </summary>
        public bool isDone =>
            status == LoadableStatus.SuccessToLoad ||
            status == LoadableStatus.Unloaded ||
            status == LoadableStatus.FailedToLoad;

        protected internal bool keepAliveOnLoad { get; set; }

        /// <summary>
        ///     加载进度
        /// </summary>
        public float progress { get; protected set; }
        
        // 设置异步记载的优先级
        public virtual void SetPriority(int priority)
        {
            
        }

        protected void Finish(string errorCode = null)
        {
            error = errorCode;
            status = string.IsNullOrEmpty(errorCode) ? LoadableStatus.SuccessToLoad : LoadableStatus.FailedToLoad;
            progress = 1;
        }


        public static void UpdateLoadables()
        {
            // 每次最少读3个；因为Complete里面可能会很慢。
            int total = 0;
            // 之前是碰到一个remove一个，但是会有一个问题，他会有O(n^2)次内存copy
            // 这里我直接做成删除连续的空间
            int continuityCount = 0;
            int index = 0;
            for (; index < Loading.Count; index++)
            {
                var item = Loading[index];
                if (total >= 3 && Updater.busy)
                {
                    break;
                }

                ++total;
                
                item.Update();
                if (!item.isDone)
                {
                    if (continuityCount > 0)
                    {
                        if (index - continuityCount < 0)
                        {
                            Log.Error("Loadable Update Error!!!");
                            int a = 0;
                        }
                        Loading.RemoveRange(index - continuityCount, continuityCount);
                    }
                    continuityCount = 0;
                    continue;
                }
                
                // Loading.RemoveAt(index);
                // index--;
                //
                continuityCount++;
                item.Complete();
            }

            if (continuityCount > 0)
            {
                if (index - continuityCount < 0)
                {
                    Log.Error("Loadable Update Error!!!");
                    int a = 0;
                }
                Loading.RemoveRange(index - continuityCount, continuityCount);
            }

            // 当前没有加载项的时候，就降低后台线程的优先级
            if (Loading.Count == 0 && CurPriority != ThreadPriority.BelowNormal)
            {
                if (CurSetTime <= 0.01)
                {
                    CurSetTime = DateTime.Now.TimeOfDay.TotalMilliseconds;
                }
                // 如果2秒后
                else if (DateTime.Now.TimeOfDay.TotalMilliseconds - CurSetTime > 3000.0)
                {
                    Application.backgroundLoadingPriority = ThreadPriority.BelowNormal;
                    CurPriority = ThreadPriority.BelowNormal;

                    //Log.Info("Change thread priority BELOW_NORMAL!!!");
                }
            }

            Asset.UpdateAssets();
            Bundle.UpdateBundles();
            ManifestFile.UpdateFiles();
        }

        // 在引擎结束的时候会调用；因为如果不调用的话，当loading的物件被加载完成的时候，其调用Complete回调函数可能会导致出错
        // 另外Loadable所持的所有Unity对象，这里清除之后，其他地方也不要持有了，这样就等他们自动GC了。
        internal static void ClearAll()
        {
            if (Loading.Count > 0)
            {
                for (var index = 0; index < Loading.Count; index++)
                {
                    var item = Loading[index];
                    if (item!= null)
                    {
                    
                    #if UNITY_EDITOR
                        Debug.LogErrorFormat("!!! ClearAll but item still in loading, pathOrURL:{0}", item.pathOrURL);
                    #endif
                        
                        // 不调用complete函数，否则可能会导致出错
                        //item.Complete();
                    }
                }
            }

            Loading.Clear();
        }
        
        internal static void Add(Loadable loadable)
        {
            // 如果和最后一个一样的话，就不添加了，因为没有意义；增加了重复计算
            for (int i = Loading.Count - 1; i >= 0; --i)
            {
                if (Loading[i] == loadable)
                {
                    return;
                }
            }
            
            Loading.Add(loadable);
            
            // 如果当前队列中数量较多，那么直接提高后台线程的优先级
            if (Loading.Count > 5 && CurPriority != ThreadPriority.High)
            {
                Application.backgroundLoadingPriority = ThreadPriority.High;
                CurPriority = ThreadPriority.High;
                CurSetTime = 0;
                //Log.Info("Change thread priority HIGH!!!");
            }
        }

        internal void Update()
        {
            OnUpdate();
        }

        internal void Complete()
        {
            // if (status == LoadableStatus.FailedToLoad)
            // {
            //     Logger.E("Unable to load {0} {1} with error: {2}", GetType().Name, pathOrURL, error);
            //     Release();
            // }

            OnComplete();
        }

        protected virtual void OnUpdate()
        {
        }

        protected virtual void OnLoad()
        {
        }

        protected virtual void OnUnload()
        {
        }

        protected virtual void OnComplete()
        {
        }

        public virtual void LoadImmediate()
        {
            throw new InvalidOperationException();
        }
        
        // 确定此资源不释放
        public virtual void KeepAliveOnLoad(bool keepAlive = true)
        {
            keepAliveOnLoad = keepAlive;
            
            if (keepAlive == false)
            {
                if (!reference.unused)
                {
                    return;
                }
                
                OnUnused();
            }
        }

        protected internal void Load()
        {
            reference.Retain();
            
            if (status != LoadableStatus.Wait)
            {
                int a = 0;
            }
            Add(this);

            // if (Logger.Loggable)
            // {
            //     Logger.I("Load {0} {1} status:{2} id:{3} {4}.", GetType().Name, reference.count, status, GetHashCode(),
            //         pathOrURL);
            // }

            if (status != LoadableStatus.Wait)
            {
                return;
            }

            status = LoadableStatus.Loading;
            progress = 0;
            OnLoad();

            // if (Logger.Loggable)
            // {
            //     Logger.I("Real Load {0} {1} status:{2} id:{3} {4}.", GetType().Name, reference.count, status,
            //         GetHashCode(), pathOrURL);
            // }
        }

        protected internal bool Unload()
        {
            if (status == LoadableStatus.Unloaded)
            {
                return false;
            }

#if !FINAL_RELEASE && !UNITY_EDITOR
            if (Logger.Loggable)
            {
                Logger.I("Unload {0} status:{1} id:{2} {3}.", GetType().Name, status, GetHashCode(), pathOrURL);
            }
#endif
            
            OnUnload();
            status = LoadableStatus.Unloaded;
            return true;
        }

        public int referenceCount => reference.count;

        public void Release()
        {
            if (reference.count <= 0)
            {
                Logger.W("Release {0} {1} status:{2} id:{3} {4}. reference.count <= 0", GetType().Name, reference.count, status, GetHashCode(), pathOrURL);
                return;
            }
            
            reference.Release();

            // if (Logger.Loggable)
            // {
            //     Logger.I("Release {0} {1} status:{2} id:{3} {4}.", GetType().Name, reference.count, status,
            //         GetHashCode(), pathOrURL);
            // }

            if (!reference.unused)
            {
                return;
            }

            // 这个放到最下面，保持引用计数，只是不释放
            if (keepAliveOnLoad)
            {
                if (Logger.Loggable)
                {
                    Logger.I("Release {0} but keepAliveOnLoad!",pathOrURL);
                }
                return;
            }
            
            OnUnused();
        }

        protected virtual void OnUnused()
        {
        }
        
        protected virtual void ForceStop()
        {
        }
        public static void ForceUnloadLoading()
        {
            for (var index = 0; index < Loading.Count; index++)
            {
                var item = Loading[index];
                item.Update();
                if (item.isDone)
                {
                    item.Complete();
                }
                else
                {
                    item.ForceStop();
                    item.Finish("Force stop");
                }
                Loading.RemoveAt(index);
                index--;
            }
        }
    }
}





