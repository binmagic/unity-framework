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
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }
            Log.Debug("Download {0} and save to {1}", url, savePath);
            request = UnityWebRequest.Get(url);
            request.downloadHandler = new DownloadHandlerFile(savePath);
            request.SendWebRequest();
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
            var path = Versions.GetDownloadDataPath(Manifest.GetVersionFile(target.name));
            var file = ManifestVersionFile.Load(path);
            // 服务器版本比包内版本高，装载服务器版本
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
            
            //Log.Debug($"Load manifest begin");
            target.Load(path);
            Log.Debug($"Load manifest {path} {target.version}");
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
        }
    }
}





