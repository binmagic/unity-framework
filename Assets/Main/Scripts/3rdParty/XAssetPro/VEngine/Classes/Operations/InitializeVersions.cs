using System.Collections.Generic;
using System.IO;

namespace VEngine
{
    /// <summary>
    ///     版本初始化操作
    /// </summary>
    public sealed class InitializeVersions : Operation
    {
        private readonly List<ManifestFile> assets = new List<ManifestFile>();
        private readonly List<string> errors = new List<string>();
        public string[] manifests;
        public string bkgroundManifest;
        public string packageResManifest;

        public override void Start()
        {
            base.Start();
            // 需要优先加载包内的版本文件，后下载服务器的版本文件。
            foreach (var info in manifests)
            {
                assets.Add(ManifestFile.LoadAsync(info, true));
            }
        }

        protected override void Update()
        {
            switch (status)
            {
                case OperationStatus.Processing:
                    foreach (var asset in assets)
                    {
                        if (!asset.isDone)
                        {
                            return;
                        }
                    }

                    foreach (var asset in assets)
                    {
                        // fixed issues:Version.UpdateAsync状态错误 #2
                        if (asset.status != LoadableStatus.Unloaded)
                        {
                            asset.Override();
                            asset.Release();
                        }
                        else
                        {
                            errors.Add($"Failed to load {asset.pathOrURL} with {asset.error}");
                        }
                    }

                    assets.Clear();
                    Finish(errors.Count == 0 ? null : string.Join("\n", errors.ToArray()));
                    break;
            }
        }
    }
}





