#if UNITY_WEBGL
using System;
using UnityEngine;
using UnityEngine.Networking;

namespace VEngine
{
    /// <summary>
    ///     WebGL (微信小游戏) 平台的 Bundle 加载实现
    ///     使用 UnityWebRequestAssetBundle 替代 AssetBundle.LoadFromFile
    /// </summary>
    internal class WebBundle : Bundle
    {
        private UnityWebRequestAsyncOperation _request;
        private UnityWebRequest _webRequest;

#if !FINAL_RELEASE
        private double startTime;
#endif

        protected override void OnLoad()
        {
#if !FINAL_RELEASE
            Debug.LogFormat("[BUNDLE] - WebBundle.OnLoad - {0}", pathOrURL);
            startTime = DateTime.Now.TimeOfDay.TotalMilliseconds;
#endif
            // WebGL: 使用 UnityWebRequestAssetBundle 加载
            // 支持从 StreamingAssets (http URL) 和 CDN 远程 URL 加载
            string url = pathOrURL;

            // 确保 URL 是完整的 — StreamingAssets 在 WebGL 上需要完整 URL
            if (!url.StartsWith("http://") && !url.StartsWith("https://"))
            {
                // 本地 StreamingAssets 路径 — 拼接完整 URL
                url = $"{Versions.LocalProtocol}{url}";
            }

            _webRequest = UnityWebRequestAssetBundle.GetAssetBundle(url);
            _request = _webRequest.SendWebRequest();
        }

        public override void LoadImmediate()
        {
            if (isDone)
            {
                return;
            }

            // WebGL 不支持真正的同步加载，只能等待异步完成
            // 但 UnityWebRequestAssetBundle 在首包资源中通常很快
            while (_request != null && !_request.isDone)
            {
                // 忙等待 — WebGL 上不推荐但 LoadImmediate 场景有限
            }

            if (_webRequest == null || _webRequest.result != UnityWebRequest.Result.Success)
            {
                Finish($"WebBundle.LoadImmediate failed: {_webRequest?.error}");
                return;
            }

            assetBundle = DownloadHandlerAssetBundle.GetContent(_webRequest);
            _webRequest.Dispose();
            _webRequest = null;

            if (assetBundle == null)
            {
                Finish("WebBundle.LoadImmediate, assetBundle == null");
                return;
            }

            Finish();
        }

        protected override void OnUpdate()
        {
            if (status != LoadableStatus.Loading)
            {
                return;
            }

            if (_request == null)
            {
                return;
            }

            progress = _request.progress;

            if (!_request.isDone)
            {
                return;
            }

            // 加载完成
            if (_webRequest.result != UnityWebRequest.Result.Success)
            {
                Finish($"WebBundle load failed: {_webRequest.error}");
                _webRequest.Dispose();
                _webRequest = null;
                return;
            }

            assetBundle = DownloadHandlerAssetBundle.GetContent(_webRequest);

#if !FINAL_RELEASE
            double cost = DateTime.Now.TimeOfDay.TotalMilliseconds - startTime;
            Debug.LogFormat("[BUNDLE OK] - WebBundle - {0} OK, cost: {1}ms", pathOrURL, cost);
#endif

            _webRequest.Dispose();
            _webRequest = null;

            if (assetBundle == null)
            {
                Finish("WebBundle.OnUpdate, assetBundle == null");
                return;
            }

            Finish();
        }

        protected override void OnUnload()
        {
            if (_webRequest != null)
            {
                _webRequest.Dispose();
                _webRequest = null;
            }
            base.OnUnload();
        }

        protected override void ForceStop()
        {
            if (_webRequest != null)
            {
                _webRequest.Abort();
                _webRequest.Dispose();
                _webRequest = null;
            }
        }
    }
}
#endif
