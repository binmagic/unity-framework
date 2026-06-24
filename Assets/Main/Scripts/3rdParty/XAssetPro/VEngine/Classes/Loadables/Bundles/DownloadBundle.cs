using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     从服务器下载的 Bundle，下载完成后会自动加载，并更新下载地址到 bundleToURLs 的缓存。
    /// </summary>
    internal class DownloadBundle : Bundle
    {
        private Download download;
        private AssetBundleCreateRequest request;

        public override void LoadImmediate()
        {
            if (isDone)
            {
                return;
            }
            while (!download.isDone)
            {
                Download.UpdateDownloads();
            }

            if (string.IsNullOrEmpty(download.error))
            {
                assetBundle = request == null ? AssetBundle.LoadFromFile(download.info.savePath) : request.assetBundle;
                Versions.SetBundlePathOrURl(info.name, download.info.savePath);
            }
            
            Finish(assetBundle == null ? "DownloadBundle.LoadImmediate, assetBundle == null" : null);
            request = null;
        }

        protected override void OnLoad()
        {
            download = Download.DownloadAsync(pathOrURL, Versions.GetDownloadDataPath(info.name), null, info.size, info.crc, info.resMode);
            download.completed += OnDownloaded;
        }

        private void OnDownloaded(Download obj)
        {
            if (download.status == DownloadStatus.Failed)
            {
                Finish(download.error);
                return;
            }
            if (assetBundle != null)
            {
                return;
            }
            request = AssetBundle.LoadFromFileAsync(obj.info.savePath, 0, BundleEncodeOffset);
            Versions.SetBundlePathOrURl(info.name, obj.info.savePath);
            status = LoadableStatus.Loading;
        }

        protected override void OnUpdate()
        {
            if (status != LoadableStatus.Loading)
            {
                return;
            }

            if (download != null && !download.isDone)
            {
                progress = download.downloadedBytes * 1f / download.info.size * 0.5f;
                if (!string.IsNullOrEmpty(download.error))
                {
                    Finish(download.error);
                    return;
                }
            }

            if (request == null)
            {
                return;
            }

            progress = 0.5f + request.progress;
            if (!request.isDone)
            {
                return;
            }

            assetBundle = request.assetBundle;
            Finish(assetBundle == null ? "DownloadBundle.OnUpdate, assetBundle == null" : null);
            request = null;
        }
        
        protected override void ForceStop()
        {
            if (!download.isDone)
            {
                download.Cancel();
            }

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





