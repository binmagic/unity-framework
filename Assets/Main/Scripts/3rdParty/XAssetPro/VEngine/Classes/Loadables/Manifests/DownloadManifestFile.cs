using System;
using System.IO;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    public class DownloadManifestFile : ManifestFile
    {
        private Download download;

        public string versionName { get; set; }

        public bool isRetry
        {
            get { return download != null && download.isRetry; }
        }

        public static string GetTemporaryPath(string filename)
        {
            return Versions.GetTemporaryPath(string.Format("Download/{0}", filename));
        }

        protected override void OnLoad()
        {
            base.OnLoad();

            versionName = Manifest.GetVersionFile(name);

#if UNITY_WEBGL
            // WebGL: 版本文件通过 UnityWebRequest 异步加载，不在 OnLoad 中同步检查
            // 直接进入 CheckVersion 阶段，通过 HTTP 下载版本文件
            pathOrURL = Versions.GetDownloadURL(name);
            status = LoadableStatus.CheckVersion;
#else
            var versionPath = GetTemporaryPath(versionName);
            if (!File.Exists(versionPath))
            {
                Finish("version not exist.");
                return;
            }

            versionFile = ManifestVersionFile.Load(versionPath);
            pathOrURL = Versions.GetDownloadURL($"{name}{CompressPosfix}_v{versionFile.version}");

            status = LoadableStatus.CheckVersion;
#endif
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.CheckVersion:
                    UpdateVersion();
                    break;

                case LoadableStatus.Downloading:
                    UpdateDownloading();
                    break;

                case LoadableStatus.Loading:
                    var path = GetTemporaryPath(name);
                    target.Load(path);
                    Finish();
                    break;
            }
        }

        public override void Override()
        {
            var split = name.Split(new[]
            {
                '_'
            }, StringSplitOptions.RemoveEmptyEntries);
            if (split.Length > 1)
            {
                var newName = split[0];
                target.name = newName;
            }

#if UNITY_WEBGL
            // WebGL: 不使用文件复制，直接从内存加载
            var tempPath = GetTemporaryPath(name);
            target.Load(tempPath);
            Log.Debug($"[WebGL] Load manifest {tempPath} {target.version}");
            Versions.Override(target);
#else
            var from = GetTemporaryPath(name);
            var dest = Versions.GetDownloadDataPath(name).Replace(name, target.name);
            if (File.Exists(from))
            {
                Log.Debug("Copy {0} to {1}.", from, dest);
                File.Copy(from, dest, true);
            }
            from = GetTemporaryPath(versionName);
            if (File.Exists(from))
            {
                var path = Versions.GetDownloadDataPath(versionName).Replace(name, target.name);
                Log.Debug("Copy {0} to {1}.", from, path);
                File.Copy(from, path, true);
            }
            if (!Versions.IsChanged(target.name))
            {
                return;
            }
            target.Load(dest);
            Log.Debug($"Load manifest {dest} {target.version}");
            Versions.Override(target);
#endif
        }

        private void UpdateDownloading()
        {
            if (download == null)
            {
                Finish("request == nul with " + status);
                return;
            }

            progress = download.progress;
            if (!download.isDone)
            {
                return;
            }

            if (!string.IsNullOrEmpty(download.error))
            {
                Finish(download.error);
                return;
            }

#if UNITY_WEBGL
            // WebGL: 下载的数据在内存中，直接进入 Loading 阶段
            download = null;
            status = LoadableStatus.Loading;
#else
            // 解压Manifest
            var savePath = GetTemporaryPath($"{name}{CompressPosfix}");
            var destDir = Path.GetDirectoryName(savePath);
            try
            {
                UnityEngine.Debug.LogFormat("ZipFile.ExtractToDirectory {0} -> {1}", savePath, destDir);
                System.IO.Compression.ZipFile.ExtractToDirectory(savePath, destDir, true);
            }
            catch (Exception exception)
            {
                CommonUtils.LogErrorWithPost($"ExtractToDirectory exception: {exception.Message}");
            }

            download = null;
            status = LoadableStatus.Loading;
#endif
        }

        private void UpdateVersion()
        {
#if UNITY_WEBGL
            // WebGL: 跳过本地版本检查，直接下载最新 manifest
            Log.Debug($"[WebGL] Download manifest {name}");
            var savePath = GetTemporaryPath($"{name}{CompressPosfix}");
            download = Download.DownloadAsync(pathOrURL, savePath);
            status = LoadableStatus.Downloading;
#else
            var path = GetTemporaryPath(name);

            for (int i = 0; i < Versions.Manifests.Count; ++i)
            {
                var manifest = Versions.Manifests[i];
                if (name.Contains(manifest.name))
                {
                    Debug.Log($">>>Version: 包内版本{manifest.version}  服务器版本{versionFile.version}");
                    if (manifest.version >= versionFile.version)
                    {
                        if (File.Exists(path))
                        {
                            File.Delete(path);
                        }
                        Finish();
                        return;
                    }
                }
            }

            Log.Debug("Read {0} with version {1} crc {2}", name, versionFile.version, versionFile.crc);

            if (File.Exists(path))
            {
                using (var stream = File.OpenRead(path))
                {
                    if (Utility.ComputeCRC32(stream) == versionFile.crc)
                    {
                        Log.Debug("[DownloadManifest]2 Skip to download {0}, because nothing to update.", name);
                        status = LoadableStatus.Loading;
                        return;
                    }
                }
            }
            if (File.Exists(path))
            {
                File.Delete(path);
            }

            var savePath = GetTemporaryPath($"{name}{CompressPosfix}");
            Debug.LogFormat("DownloadAsync: {0} -> {1}", pathOrURL, savePath);

            download = Download.DownloadAsync(pathOrURL, savePath);
            status = LoadableStatus.Downloading;
#endif
        }
    }
}





