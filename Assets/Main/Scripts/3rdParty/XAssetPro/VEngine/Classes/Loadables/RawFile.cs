using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine.Networking;

namespace VEngine
{
    /// <summary>
    ///     原始资源，不管在网络还是在本地，都通过资源名字加载，自带版本管理机制，可以自动更新，包体内的资源会自动按需 copy 到包外。
    /// </summary>
    public sealed class RawFile : Loadable
    {
        private static readonly Dictionary<string, RawFile> Cache = new Dictionary<string, RawFile>();
        private static readonly List<RawFile> Unused = new List<RawFile>();
        public Action<RawFile> completed;
        private BundleInfo info;
        public string name;
        private UnityWebRequest request;
        public string savePath { get; private set; }

        public byte[] bytes { get; private set; }

        protected override void OnLoad()
        {
            if (!Versions.GetDependencies(name, out info, out _))
            {
                Finish("File not found.");
                return;
            }

            pathOrURL = Versions.GetBundlePathOrURL(info);
            savePath = Versions.GetDownloadDataPath(info.name);
            var dir = Path.GetDirectoryName(savePath);
            if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            status = LoadableStatus.CheckVersion;
        }

        protected override void OnUnload()
        {
            if (request != null)
            {
                request.Dispose();
                request = null;
            }
            if (bytes != null)
            {
                bytes = null;
            }
        }

        protected override void OnComplete()
        {
            if (completed == null)
            {
                return;
            }

            var saved = completed;
            if (completed != null)
            {
                completed(this);
            }

            completed -= saved;
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.CheckVersion:
                    UpdateChecking();
                    break;
                case LoadableStatus.Loading:
                    UpdateLoading();
                    break;
            }
        }

        protected override void OnUnused()
        {
            // 不需要使用的时候，加载完成不回调。
            completed = null;
            Unused.Add(this);
        }

        private void UpdateLoading()
        {
            if (request == null)
            {
                Finish("request == null");
                return;
            }

            if (!request.isDone)
            {
                return;
            }

            if (!string.IsNullOrEmpty(request.error))
            {
                Finish(request.error);
                return;
            }

            if (File.Exists(savePath))
            {
                bytes = File.ReadAllBytes(savePath);
            }

            Finish();
        }

        private void UpdateChecking()
        {
            if (File.Exists(savePath))
            {
                using (var stream = File.OpenRead(savePath))
                {
                    if (info.size == (ulong) stream.Length && Utility.ComputeCRC32(stream) == info.crc)
                    {
                        Finish();
                        return;
                    }
                }

                File.Delete(savePath);
            }

            request = UnityWebRequest.Get(pathOrURL);
            request.downloadHandler = new DownloadHandlerFile(savePath);
            request.SendWebRequest();
            status = LoadableStatus.Loading;
        }


        public static void UpdateFiles()
        {
            for (var index = 0; index < Unused.Count; index++)
            {
                var item = Unused[index];
                if (Updater.busy)
                {
                    break;
                }

                if (!item.isDone)
                {
                    continue;
                }

                Unused.RemoveAt(index);
                Cache.Remove(item.name);
                index--;
                item.Unload();
            }
        }

        public static RawFile LoadAsync(string filename)
        {
            if (!Cache.TryGetValue(filename, out var asset))
            {
                asset = new RawFile
                {
                    name = filename
                };
                Cache.Add(filename, asset);
            }

            asset.Load();
            return asset;
        }
    }
}





