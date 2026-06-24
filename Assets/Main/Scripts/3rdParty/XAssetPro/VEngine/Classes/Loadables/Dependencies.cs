using System;
using System.Collections.Generic;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     资源的依赖，管理资源依赖的 Bundles 的加载和回收。
    /// </summary>
    public class Dependencies : Loadable
    {
        /// <summary>
        ///     资源所有依赖的 bundle
        /// </summary>
        internal readonly List<Bundle> bundles = new List<Bundle>();

#if UNITY_EDITOR
        private static bool ShowLog = true;
        private static string[] whiteList =
        {
            // "atlas__uiloadingatlas",
            // "atlas__countryflag",
            // "atlas__guide",
            // "atlas__itemicons",
            // "atlas__ui_common",
            // "atlas__ui_commonbg",
            // "atlas__ui_uimain",
            // "atlas__ui_uibuildbubble",  // 场景气泡。一般来讲都会使用，而且特效使用的很多
        };
#endif

        /// <summary>
        ///     资源所在的 bundle
        /// </summary>
        internal Bundle bundle;

        internal AssetBundle assetBundle => bundle?.assetBundle;

        protected override void OnLoad()
        {
            if (!Versions.GetDependencies(pathOrURL, out var info, out var infos))
            {
                Finish("Dependencies.OnLoad, Dependencies not found");
                return;
            }

            if (info == null)
            {
                Finish("Dependencies.OnLoad, info == null");
                return;
            }

            // 如果bundle找不到，这里输出一些错误信息，就不直接抛异常了，异常会导致整体逻辑坏掉
            bundle = Bundle.LoadInternal(info, mustCompleteOnNextFrame);
            if (bundle == null)
            {
                Finish("Dependencies.OnLoad, LoadInternal == null");
                return;    
            }
            bundles.Add(bundle);
            
            if (infos != null && infos.Length > 0)
            {
                foreach (var item in infos)
                {
#if UNITY_EDITOR
                    if (ShowLog && item.name.StartsWith("main_atlas_"))
                    {
                        bool inWhite = false;
                        foreach (var atlas in whiteList)
                        {
                            if (item.name.StartsWith(atlas))
                            {
                                inWhite = true;
                            }
                        }

                        if (!inWhite)
                        {
                            Debug.Log($"***NotInWhite: prefab:{pathOrURL}  loadBundle: {info.name}  dep:{item.name}");
                        }
                    }
#endif

                    var b = Bundle.LoadInternal(item, mustCompleteOnNextFrame);
                    if (b != null)
                    {
                        bundles.Add(b);
                    }
                    else
                    {
                        CommonUtils.LogErrorWithPost($"Bundle.LoadInternal {item.name} error!!");
                    }
                }
            }

        }

        public override void LoadImmediate()
        {
            if (isDone)
            {
                return;
            }

            foreach (var request in bundles)
            {
                request.LoadImmediate();
            }
        }
        
        public override void KeepAliveOnLoad(bool keepAlive = true)
        {
            // FIXME: 作者这里的引用计数机制做的非常不好
            // 理论来讲，如果this没有Release，那么所有this依赖的项都不能被Release
            // 然而作者目前的做法不是如此
    
            foreach (var item in bundles)
            {
                if (string.IsNullOrEmpty(item.error))
                {
                    item.KeepAliveOnLoad(keepAlive);
                }
            }
        }

        protected override void OnUnload()
        {
            if (bundles.Count > 0)
            {
                foreach (var item in bundles)
                {
                    if (string.IsNullOrEmpty(item.error))
                    {
                        item.Release();
                    }
                }

                bundles.Clear();
            }

            bundle = null;
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.Loading:
                    var totalProgress = 0f;
                    var allDone = true;
                    foreach (var child in bundles)
                    {
                        totalProgress += child.progress;
                        if (!string.IsNullOrEmpty(child.error))
                        {
                            status = LoadableStatus.FailedToLoad;
                            error = child.error;
                            progress = 1;
                            return;
                        }

                        if (child.isDone)
                        {
                            continue;
                        }

                        allDone = false;
                        break;
                    }

                    progress = totalProgress / bundles.Count * 0.5f;
                    if (allDone)
                    {
                        if (assetBundle == null)
                        {
                            Finish("Dependencies.OnLoad, assetBundle == null");
                            return;
                        }

                        Finish();
                    }

                    break;
            }
        }
        
        public override void SetPriority(int priority)
        {
            foreach (var request in bundles)
            {
                request.SetPriority(priority);
            }
        }
        
    }
}





