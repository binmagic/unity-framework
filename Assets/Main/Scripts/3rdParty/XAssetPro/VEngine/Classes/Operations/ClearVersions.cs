using System.Collections.Generic;
using System.IO;

namespace VEngine
{
    /// <summary>
    ///     清理不在版本中的文件。
    /// </summary>
    public sealed class ClearVersions : Operation
    {
        private readonly List<string> usedFiles = new List<string>();
        private string[] allFiles;
        private int index;

        public override void Start()
        {
            base.Start();
            allFiles = Directory.GetFiles(Versions.DownloadDataPath);
            index = 0;
            foreach (var manifest in Versions.Manifests)
            {
                usedFiles.Add(Versions.GetDownloadDataSystemPath(manifest.name));
                usedFiles.Add(Versions.GetDownloadDataSystemPath(Manifest.GetVersionFile(manifest.name)));
                foreach (var bundle in manifest.bundles)
                {
                    if (string.IsNullOrEmpty(bundle.name))
                    {
                        continue;
                    }

                    usedFiles.Add(Versions.GetDownloadDataSystemPath(bundle.name));
                }
            }
        }

        protected override void Update()
        {
            switch (status)
            {
                case OperationStatus.Processing:
                    if (allFiles == null)
                    {
                        Finish();
                    }
                    else
                    {
                        var count = allFiles.Length;
                        if (index >= count)
                        {
                            Finish();
                        }
                        else
                        {
                            while (index < count)
                            {
                                progress = (count - (index + 1)) / (float) count;
                                var file = allFiles[index];
                                if (!usedFiles.Contains(file))
                                {
                                    if (File.Exists(file))
                                    {
                                        File.Delete(file);
                                    }
                                }

                                index++;
                                if (Updater.busy)
                                {
                                    break;
                                }
                            }

                            if (index >= count)
                            {
                                Finish();
                            }
                        }
                    }

                    break;
            }
        }
    }
}





