using System;
using System.Collections.Generic;
using UnityEngine;

namespace VEngine
{
    // 读取All Asset的依赖的方法要特殊处理一下
    public class AllBundledDependencies : Dependencies
    {
        protected override void OnLoad()
        {
            if (!Versions.GetBundleFromName(pathOrURL, out var info, out var infos))
            {
                Finish("Dependencies.OnLoad, Dependencies not found");
                return;
            }

            if (info == null)
            {
                Finish("Dependencies.OnLoad, info == null");
                return;
            }

            bundle = Bundle.LoadInternal(info, mustCompleteOnNextFrame);
            bundles.Add(bundle);
            if (infos != null && infos.Length > 0)
            {
                foreach (var item in infos)
                {
                    if (item != null)
                    {
                        bundles.Add(Bundle.LoadInternal(item, mustCompleteOnNextFrame));
                    }
                    else
                    {
                        Debug.LogError($"#bundle# AllBundledDependencies:OnLoad infos has empty item! pathOrURL:{pathOrURL}");
                    }
                }
            }
        }
    }

    /// <summary>
    ///     这个类用来加载一个bundle下所有的Assets
    /// 使用方法：
    ///  先通过遍历获取到bundle的名称，然后再去加载这个Bundle
    ///  因为我们的bundle名称后面有个md5值，所以没法准确匹配，只能通过部分匹配的方法来确定一个bundle
    /// 
    /// string shader_bundle = "";
    // VEngine.Versions.VisitBundles(delegate(string s)
    // {
    // if (s.Contains("shader_shader"))
    // {
    //     shader_bundle = s;
    // }
    // Log.Info(s);
    // return true;
    // });
    //
    // var a = VEngine.Asset.LoadAllAssetsAsync(shader_bundle, delegate(Asset asset)
    // {
    // int aaaa = 0;
    // });
    /// </summary>
    public class AllBundledAsset : Asset
    {
        private AllBundledDependencies dependencies;
        private AssetBundleRequest request;
        public UnityEngine.Object[] assets { get; protected set; }
        
        internal static AllBundledAsset Create(string bundle_path)
        {
            return new AllBundledAsset
            {
                pathOrURL = bundle_path,
            };
        }

        protected override void OnLoad()
        {
            dependencies = new AllBundledDependencies
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
            assets = null;
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

            assets = dependencies.assetBundle.LoadAllAssets();
            if (assets == null)
            {
                Finish("BundledAsset.LoadImmediate, asset == null");
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

            assets = request.allAssets;
            if (assets == null)
            {
                Finish("BundledAsset.UpdateLoading, asset == null");
                return;
            }

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

            request = assetBundle.LoadAllAssetsAsync();
            status = LoadableStatus.Loading;
        }
        
        // protected override void OnComplete()
        // {
        //     // Log.Debug("debug load {0} finish", pathOrURL);
        //     if (completed == null)
        //     {
        //         return;
        //     }
        //
        //     var saved = completed;
        //     if (completed != null)
        //     {
        //         completed(this);
        //     }
        //
        //     completed -= saved;
        // }
    }

}





