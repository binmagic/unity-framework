using System;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     在 Bundle 中的资源，持有 Dependencies 可以自动管理依赖
    /// </summary>
    public class BundledAsset : Asset
    {
        private Dependencies dependencies;
        private AssetBundleRequest request;
        private int priority_;

        internal static BundledAsset Create(string path, Type type)
        {
            return new BundledAsset
            {
                pathOrURL = path,
                type = type
            };
        }
        
        internal static bool IsAssetDownloaded(string path)
        {
            if (!Versions.GetDependencies(path, out var bundle, out var deps))
            {
                return false;
            }  

            if (!Versions.IsDownloaded(bundle))
            {
                return false;
            }

            foreach (var d in deps)
            {
                if (!Versions.IsDownloaded(d))
                {
                    return false;
                }
            }

            return true;
        }

        protected override void OnLoad()
        {
            dependencies = new Dependencies
            {
                pathOrURL = pathOrURL
            };
            dependencies.Load();
            status = LoadableStatus.DependentLoading;
        }

        protected override void OnUnload()
        {
            if (dependencies != null)
            {
                dependencies.Unload();
                dependencies = null;
            }

            request = null;
            asset = null;
        }

        public override void LoadImmediate()
        {
            if (isDone)
            {
                return;
            }
            
            if (dependencies == null)
            {
                Finish("BundledAsset.LoadImmediate, dependencies == null");
                return;
            }

            if (!dependencies.isDone)
            {
                dependencies.LoadImmediate();
            }

            if (dependencies.assetBundle == null)
            {
                Finish("BundledAsset.LoadImmediate, dependencies.assetBundle == null");
                return;
            }

            try
            {
                // LoadAsset底层会抛出异常，这里处理一下，因为有地方显示这里会导致崩溃；具体什么原因未知。。。
                asset = dependencies.assetBundle.LoadAsset(pathOrURL, type);
                if (asset == null)
                {
                    Finish("BundledAsset.LoadImmediate, asset == null");
                    return;
                }
            }
            catch (Exception exp)
            {
                Finish("BundledAsset.LoadImmediate, exception!");
                Debug.LogErrorFormat("BundledAsset.LoadImmediate-exception:{0}", exp.Message);
                return;
            }

            Finish();
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.Loading:
                    UpdateLoading();
                    break;

                case LoadableStatus.DependentLoading:
                    UpdateDependencies();
                    break;
            }
        }

        private void UpdateLoading()
        {
            if (request == null)
            {
                Finish("BundledAsset.UpdateLoading, request == null");
                return;
            }
            progress = 0.5f + request.progress * 0.5f;
            if (!request.isDone)
            {
                return;
            }
            asset = request.asset;
            if (asset == null)
            {
                Finish("BundledAsset.UpdateLoading, asset == null");
                return;
            }
            
            // 这里处理一下编辑器的shader更新
#if UNITY_EDITOR
            ResetObjectShader(asset as GameObject);
#endif

            Finish();
        }

        private void UpdateDependencies()
        {
            if (dependencies == null)
            {
                Finish("BundledAsset.UpdateDependencies, dependencies == null");
                return;
            }

            progress = 0.5f * dependencies.progress;
            if (!dependencies.isDone)
            {
                return;
            }

            var assetBundle = dependencies.assetBundle;
            if (assetBundle == null)
            {
                Finish("BundledAsset.UpdateDependencies, assetBundle == null");
                return;
            }

            request = assetBundle.LoadAssetAsync(pathOrURL, type);
            if (priority_ != 0)
            {
                request.priority = priority_;
            }
            
            status = LoadableStatus.Loading;
        }

        // 获取到这个Asset所属的Bundle
        public override Bundle GetOwnerBundle()
        {
            if (dependencies != null)
            {
                return dependencies.bundle;
            }

            return null;
        }
        
        public override void SetPriority(int priority)
        {
            priority_ = priority;
            if (dependencies != null)
            {
                dependencies.SetPriority(priority);
            }
        }

        
#if UNITY_EDITOR
        private static List<Renderer> results = new List<Renderer>(64);
        
        // 对某一个GameObject对象下进行材质的替换
        private void ResetObjectShader(GameObject go)
        {
            if (go == null)
            {
                return;
            }

            // 把所有的renderer遍历出来，每个材质的shader重新定位一下。
            results.Clear();
            go.GetComponentsInChildren<Renderer>(true, results);
            if (results.Count > 0)
            {
                for (int ii = 0; ii < results.Count; ii++)
                {
                    for (int k = 0; k < results[ii].sharedMaterials.Length; ++k)
                    {
                        var m = results[ii].sharedMaterials[k];
                        if (m != null && m.shader != null)
                        {
                            var shaderName = m.shader.name;
                            var newShader = Shader.Find(shaderName);
                            if (newShader != null)
                                //if (newShader != m.shader)
                            {
                                m.shader = newShader;
                            }
                            else
                            {
                                Debug.LogWarning("unable to refresh shader: " + shaderName + " in material " + m.name);
                            }
                        }
                    }
                }
            }

            return;
        }
#endif
    }

}





