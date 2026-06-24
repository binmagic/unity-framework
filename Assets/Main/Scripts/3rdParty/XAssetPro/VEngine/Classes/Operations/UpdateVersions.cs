using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace VEngine
{
    /// <summary>
    ///     版本更新操作，更新操作默认只处理服务器的就行
    /// </summary>
    public sealed class UpdateVersions : Operation
    {
        public string[] manifests;
        public readonly List<ManifestFile> assets = new List<ManifestFile>();
        public List<Manifest> Manifests => assets.Select(a => a.target).ToList();

        private Download downloadVersion;
        
        public bool isRetry
        {
            get
            {
                foreach (var asset in assets)
                {
                    if (((DownloadManifestFile) asset).isRetry)
                        return true;
                }

                return false;
            }
        }

        public Manifest GetManifest(string name)
        {
            var asset = assets.Find(a => a.target.name == name);
            return asset?.target;
        }
        
        public override void Start()
        {
            base.Start();
            if (Versions.SkipUpdate)
            {
                Finish();
                return;
            }

            var savePath = DownloadManifestFile.GetTemporaryPath(ManifestFile.ManifestVersion);
            downloadVersion = Download.DownloadAsync(Versions.CheckVersionURL, savePath);
        }

        public void Override()
        {
            if (Versions.SkipUpdate)
            {
                return;
            }
            foreach (var asset in assets)
            {
                asset.Override();
            }
        }

        public void Dispose()
        {
            foreach (var asset in assets)
            {
                if (asset.status != LoadableStatus.Unloaded)
                {
                    asset.Release();
                }
            }
            assets.Clear();
        }

        protected override void Update()
        {
            switch (status)
            {
                case OperationStatus.Processing:
                    if (downloadVersion != null)
                    {
                        if (downloadVersion.isDone)
                        {
                            if (!string.IsNullOrEmpty(downloadVersion.error))
                            {
                                Finish(downloadVersion.error);
                                return;
                            }

                            var versionPath = DownloadManifestFile.GetTemporaryPath(ManifestFile.ManifestVersion);
                            SplitVersionFile(versionPath);
                            downloadVersion = null;
                            //PostEventLog.Record(PostEventLog.Defines.CHECK_VERSION_RESPONSE);
                            
                            // 下载 manifest
                            foreach (var manifest in manifests)
                            {
                                assets.Add(ManifestFile.LoadAsync(manifest));
                            }
                        }
                    }
                    else
                    {
                        foreach (var asset in assets)
                        {
                            if (!asset.isDone)
                            {
                                return;
                            }
                        }

                        var errors = new List<string>();
                        foreach (var asset in assets)
                        {
                            // fixed issues:Version.UpdateAsync状态错误 #2
                            if (asset.status == LoadableStatus.Unloaded)
                            {
                                errors.Add($"Failed to load {Path.GetFileName(asset.pathOrURL)} with {asset.error}");
                            }
                        }
                        Finish(errors.Count == 0 ? null : string.Join("\n", errors.ToArray()));
                    }
                    
                    break;
            }
        }

        private void SplitVersionFile(string versionPath)
        {
            foreach (var line in File.ReadAllLines(versionPath))
            {
                var items = line.Trim().Split(',');
                if (items.Length >= 4)
                {
                    var name = items[0];
                    var version = items[1];
                    var size = items[2];
                    var crc = items[3];
                    var content = $"{version},{size},{crc}";
                    var versionFile = DownloadManifestFile.GetTemporaryPath(Manifest.GetVersionFile(name.ToLower()));
                    File.WriteAllText(versionFile, content);
                }
            }
        }
    }
}





