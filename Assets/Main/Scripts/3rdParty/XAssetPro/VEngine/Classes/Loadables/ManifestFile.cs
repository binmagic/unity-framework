using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace VEngine
{
    public class ManifestVersionFile
    {
        public uint crc;
        public int version;

        public static ManifestVersionFile Load(string path)
        {
            var file = new ManifestVersionFile();
            if (File.Exists(path))
            {
                var content = File.ReadAllText(path);
                var fields = content.Split(',');
                if (fields.Length > 2)
                {
                    file.version = fields[0].IntValue();
                    file.crc = fields[2].UIntValue();
                }
            }
            return file;
        }
    }

    /// <summary>
    ///     清单资源
    /// </summary>
    public class ManifestFile : Loadable
    {
        public const string ManifestVersion = "manifest.version";
        public const string CompressPosfix = "_small";
        
        /// <summary>
        ///     未使用的列表
        /// </summary>
        private static readonly List<ManifestFile> Unused = new List<ManifestFile>();

        public Manifest target { get; set; }
        protected ManifestVersionFile versionFile;

        protected string name { get; set; }


        protected override void OnLoad()
        {
            target = new Manifest
            {
                name = name,
                onReadAsset = Versions.OnReadAsset
            };
        }

        protected override void OnUnused()
        {
            Unused.Add(this);
        }

        public virtual void Override()
        {
        }

        public static ManifestFile LoadAsync(string name, bool builtin = false)
        {
            var asset = Versions.CreateManifest(name, builtin);
            asset.Load();
            return asset;
        }

        internal static ManifestFile Create(string name, bool builtin)
        {
            Debug.Log($">>>lszManifest: {name}");
            if (builtin)
            {
                return new BuiltinManifestFile
                {
                    name = name
                };
            }

            return new DownloadManifestFile
            {
                name = name
            };
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
                index--;
                item.Unload();
            }
        }

        public static string GetManifestVersion(string appVersion, string gm)
        {
            return $"manifest_v{appVersion}{gm}.version";
        }
    }
}





