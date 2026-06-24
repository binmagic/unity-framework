using System;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     从本地加载的Bundle，默认使用 LoadFromFile 这个最高效的接口。
    /// </summary>
    internal class LocalBundle : Bundle
    {
        private AssetBundleCreateRequest request;
        
#if !FINAL_RELEASE
        private double startTime;
#endif
        
        protected override void OnLoad()
        {
            if (!Versions.CheckWhiteList || Versions.IsInWhiteList(GetOriginBundleName(info.name)))
            {
#if !FINAL_RELEASE
                Debug.LogFormat("[BUNDLE] - LoadFromFileAsync - {0}", pathOrURL);
                startTime = DateTime.Now.TimeOfDay.TotalMilliseconds;
#endif
                request = AssetBundle.LoadFromFileAsync(pathOrURL, 0, BundleEncodeOffset);
            }
            else
            {
                Versions.WhiteListFailed.Add(info.name);
                Finish("LocalBundle.OnLoad, not in whitelist");
            }
        }

        private string GetOriginBundleName(string nameWithAppendHash)
        {
            int i = nameWithAppendHash.LastIndexOf('_');
            if (i <= 0)
                return nameWithAppendHash;
            i = nameWithAppendHash.LastIndexOf('_', i - 1);
            if (i <= 0)
                return nameWithAppendHash;
            return nameWithAppendHash.Substring(0, i);
        }

        public override void LoadImmediate()
        {
            if (isDone)
            {
                return;
            }

            assetBundle = request.assetBundle;
            if (assetBundle == null)
            {
                Finish("LocalBundle.LoadImmediate, assetBundle == null");
                return;
            }
            
            ResetAllMaterials(assetBundle);

            Finish();
            request = null;
        }

        private void OnLoaded()
        {
            if (request == null)
            {
                Finish("LocalBundle.OnLoaded, request == null");
                return;
            }

            assetBundle = request.assetBundle;
            request = null;
            if (assetBundle == null)
            {
                Finish("LocalBundle.OnLoaded, assetBundle == null");
                return;
            }

#if !FINAL_RELEASE
            double cost = DateTime.Now.TimeOfDay.TotalMilliseconds - startTime;
            Debug.LogFormat("[BUNDLE OK] - LoadFromFileAsync - {0} OK, cost: {1}ms", pathOrURL, cost);
#endif
            
            ResetAllMaterials(assetBundle);

            Finish();
        }

        protected override void OnUpdate()
        {
            if (status != LoadableStatus.Loading)
            {
                return;
            }

            if (request == null)
            {
                OnLoad();
                return;
            }

            progress = request.progress;
            if (request.isDone)
            {
                OnLoaded();
            }
        }

        // 设置bundle加载的优先级
        public override void SetPriority(int priority)
        {
            if (request != null)
            {
                request.priority = priority;
            }
        }
        
        // 在编辑器模式下，更新一下bundle中所有材质的shader
        // 这样才可以从编辑器模式下测试Bundle
        private void ResetAllMaterials(AssetBundle bundle)
        {
#if UNITY_EDITOR
            var materials = bundle.LoadAllAssets<Material>();
            foreach (Material m in materials)
            {
                var shaderName = m.shader.name;
                var newShader = Shader.Find(shaderName);
                if (newShader != null)
                {
                    m.shader = newShader;
                }
                else
                {
                    Debug.Log("unable to refresh shader: " + shaderName + " in material " + m.name);
                }
            }
#endif
        }

        protected override void ForceStop()
        {
            if (request != null)
            {
                // force load bundle sync
                var bundle = request.assetBundle;
                if (bundle)
                    bundle.Unload(false);
                request = null;
            }
        }
    }
}





