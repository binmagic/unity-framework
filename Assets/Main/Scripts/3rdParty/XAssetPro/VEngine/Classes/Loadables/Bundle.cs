using System;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     Bundle 类，将 Unity 的 AssetBundle 的进行了封装，加载的时候，底层会自动根据 Bundle 的版本状态进行寻址。
    /// </summary>
    public class Bundle : Loadable
    {
        /// <summary>
        ///     按 key 缓存的所有加载类对象
        /// </summary>
        public static readonly Dictionary<string, Bundle> Cache = new Dictionary<string, Bundle>();
        public static readonly List<Bundle> Unused = new List<Bundle>();

        protected BundleInfo info;
        protected internal AssetBundle assetBundle { get; set; }

        public BundleInfo GetInfo()
        {
            return info;
        }

        protected override void OnUnused()
        {
            Unused.Add(this);
        }

        internal static Bundle LoadInternal(BundleInfo info, bool mustCompleteOnNextFrame)
        {
            if (info == null)
            {
                CommonUtils.LogErrorWithPost("#bundle# Bundle LoadInternal info is nil!");
                //throw new NullReferenceException();
                return null;
            }

            if (!Cache.TryGetValue(info.name, out var item))
            {
                var url = Versions.GetBundlePathOrURL(info);
                if (string.IsNullOrEmpty(url))
                {
                    CommonUtils.LogErrorWithPost($"Exception! not found in any path! name:{info.name}");
                    return null;
                }

                // if (Application.platform == RuntimePlatform.WebGLPlayer)
                // {
                //     // item = new WebBundle
                //     // {
                //     //     pathOrURL = url,
                //     //     info = info
                //     // };
                // }
                // else
                {
                    if (!string.IsNullOrEmpty(Versions.DownloadURL) && url.StartsWith(Versions.DownloadURL))
                    {
                        item = new DownloadBundle
                        {
                            pathOrURL = url,
                            info = info
                        };
                    }
                    else
                    {
                        item = new LocalBundle
                        {
                            pathOrURL = url,
                            info = info
                        };
                    }
                }

                Cache.Add(info.name, item);
                
                if (Logger.Loggable)
                {
                    Logger.I($"Cache.Add {info.name} - {mustCompleteOnNextFrame} - {item.GetHashCode()}");
                }
            }

            item.mustCompleteOnNextFrame = mustCompleteOnNextFrame;
            item.Load();
            if (mustCompleteOnNextFrame)
            {
                item.LoadImmediate();
            }

            return item;
        }

        internal static void UpdateBundles()
        {
            for (var index = 0; index < Unused.Count; index++)
            {
                var item = Unused[index];
                if (Updater.busy)
                {
                    return;
                }

                if (!item.isDone)
                {
                    continue;
                }

                Unused.RemoveAt(index);
                index--;
                if (!item.reference.unused)
                {
                    continue;
                }

                if (item.Unload())
                {
                    Cache.Remove(item.info.name);

                    if (Logger.Loggable)
                    {
                        Logger.I($"Cache.Remove UpdateBundles {item.info.name} {item.GetHashCode()}");
                    }
                }
            }
        }

        public static void UnloadUnusedBundles()
        {
            while (Unused.Count > 0)
            {
                for (var index = 0; index < Unused.Count; index++)
                {
                    var item = Unused[index];

                    Unused.RemoveAt(index);
                    index--;
                    if (item.reference.unused)
                    {
                        if (item.Unload())
                        {
                            Cache.Remove(item.info.name);

                            if (Logger.Loggable)
                            {
                                Logger.I($"Cache.Remove UnloadUnusedBundles {item.info.name} {item.GetHashCode()}");
                            }
                        }
                        else
                        {
                            if (Logger.Loggable)
                            {
                                Logger.I($"Cache.Remove UnloadUnusedBundles Unload false {item.info.name} {item.GetHashCode()}");
                            }
                        }
                    }
                    else
                    {
                        if (Logger.Loggable)
                        {
                            Logger.I($"Cache.Remove UnloadUnusedBundles Failed {item.info.name} {item.GetHashCode()} {item.reference.unused}");
                        }
                    }
                }
            }
        }

        public static void DebugOutputCache()
        {
#if !FINAL_RELEASE
            Log.Debug("=== DebugOutputCache begin ===");
            foreach (var i in Cache)
            {
                Log.Debug("Bundle Cache {0} {1}", i.Key, i.Value.reference.count);
            }
#endif
        }

        protected override void OnUnload()
        {
            if (assetBundle == null)
            {
                Logger.I("OnUnload assetBundle == null {0} {1}", info.name, GetHashCode());
                return;
            }

            // if (Logger.Loggable)
            // {
            //     Logger.I("OnUnload assetBundle.Unload {0} {1}", info.name, GetHashCode());
            // }

            assetBundle.Unload(true);
            assetBundle = null;
        }
    }
}





