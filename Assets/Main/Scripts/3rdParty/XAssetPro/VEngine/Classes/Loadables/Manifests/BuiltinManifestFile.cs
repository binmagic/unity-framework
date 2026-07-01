using System.IO;
using GameFramework;
using UnityEngine;
using UnityEngine.Networking;

namespace VEngine
{
    /// <summary>
    ///     包体内的 manifest 文件，使用 UnityWebRequest copy 到包外
    /// </summary>
    public class BuiltinManifestFile : ManifestFile
    {
        private UnityWebRequest request;

        private void DownloadAsync(string url, string savePath)
        {
#if UNITY_WEBGL
            // WebGL: 不使用 DownloadHandlerFile（WebGL 不支持文件系统写入）
            // 直接通过 UnityWebRequest 下载，数据保存在内存中
            Log.Debug("[WebGL] Download {0}", url);
            request = UnityWebRequest.Get(url);
            request.SendWebRequest();
#else
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }
            Log.Debug("Download {0} and save to {1}", url, savePath);
            request = UnityWebRequest.Get(url);
            request.downloadHandler = new DownloadHandlerFile(savePath);
            request.SendWebRequest();
#endif
        }

        private static string GetTemporaryPath(string filename)
        {
            return Versions.GetTemporaryPath(string.Format("Builtin/{0}", filename));
        }

        public override void Override()
        {
            if (versionFile == null)
            {
                return;
            }
            Versions.Override(target);

#if UNITY_WEBGL
            // WebGL: 直接从 StreamingAssets 加载 manifest，不做本地缓存检查
            var path = GetTemporaryPath(name);
            target.Load(path);
            Log.Debug($"[WebGL] Load manifest {path} {target.version}");
#else
            var path = Versions.GetDownloadDataPath(Manifest.GetVersionFile(target.name));
            var file = ManifestVersionFile.Load(path);
            if (file.version > versionFile.version)
            {
                path = Versions.GetDownloadDataPath(target.name);
                if (File.Exists(path))
                {
                    using (var stream = File.OpenRead(path))
                    {
                        if (Utility.ComputeCRC32(stream) == file.crc)
                        {
                            target.Load(path);
                            Log.Debug($"Load manifest {path} {target.version}");
                            return;
                        }
                    }
                }
                else
                {
                    Debug.LogFormat("{0} target.name file not found!", target.name);
                }
            }
            path = GetTemporaryPath(name);
            target.Load(path);
            Log.Debug($"Load manifest {path} {target.version}");
#endif
        }

        protected override void OnLoad()
        {
            base.OnLoad();
            pathOrURL = Versions.GetPlayerDataURL(name);
            var file = Manifest.GetVersionFile(name);
            var url = Versions.GetPlayerDataURL(file);
            DownloadAsync(url, GetTemporaryPath(file));
            status = LoadableStatus.CheckVersion;
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
                    Finish();
                    break;
            }
        }

        private void UpdateDownloading()
        {
            if (request == null)
            {
                Finish("request == nul with " + status);
                return;
            }

            progress = 0.2f + request.downloadProgress;
            if (!request.isDone)
            {
                return;
            }

            if (!string.IsNullOrEmpty(request.error))
            {
                Finish(request.error);
                return;
            }

            request.Dispose();
            request = null;

            status = LoadableStatus.Loading;
        }

        private void UpdateVersion()
        {
            if (request == null)
            {
                Finish("request == null with " + status);
                return;
            }

            progress = 0.2f * request.downloadProgress;
            if (!request.isDone)
            {
                return;
            }

            if (!string.IsNullOrEmpty(request.error))
            {
                Finish(request.error);
                return;
            }

#if UNITY_WEBGL
            // WebGL: 直接从 UnityWebRequest 响应中解析版本信息
            // 不使用文件系统操作
            var versionText = request.downloadHandler.text;
            versionFile = ManifestVersionFile.LoadFromText(versionText);
            if (versionFile == null)
            {
                Finish("version parse failed.");
                return;
            }
            Log.Debug("[WebGL] Read {0} with version {1} crc {2}", name, versionFile.version, versionFile.crc);
            request.Dispose();
            request = null;

            // WebGL: 总是下载 manifest（不做本地缓存检查）
            DownloadAsync(pathOrURL, null);
            status = LoadableStatus.Downloading;
#else
            var file = Manifest.GetVersionFile(name);
            var savePath = GetTemporaryPath(file);
            if (!File.Exists(savePath))
            {
                Finish("version not exist.");
                return;
            }

            versionFile = ManifestVersionFile.Load(savePath);
            Log.Debug("Read {0} with version {1} crc {2}", name, versionFile.version, versionFile.crc);
            request.Dispose();
            request = null;

            var path = GetTemporaryPath(name);
            if (File.Exists(path))
            {
                using (var stream = File.OpenRead(path))
                {
                    if (Utility.ComputeCRC32(stream) == versionFile.crc)
                    {
                        Log.Debug("[BuildInManifest] Skip to download {0}, because nothing to update.", name);
                        status = LoadableStatus.Loading;
                        return;
                    }
                }
            }
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            DownloadAsync(pathOrURL, path);
            status = LoadableStatus.Downloading;
#endif
        }
    }
}





