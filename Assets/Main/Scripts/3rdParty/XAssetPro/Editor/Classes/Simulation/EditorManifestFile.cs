#if UNITY_EDITOR
using VEngine.Editor;

namespace VEngine
{
    public class EditorManifestFile : ManifestFile
    {
        private int assetIndex;

        private int groupIndex;
        private Editor.Manifest manifest;

        protected override void OnLoad()
        {
            base.OnLoad();
            groupIndex = 0;
            assetIndex = 0;
            pathOrURL = name;
            var settings = Settings.GetDefaultSettings();
            foreach (var item in settings.manifests)
            {
                var manifestName = $"{item.name}".ToLower();
                if (name != manifestName)
                {
                    continue;
                }

                manifest = item;
                return;
            }

            Finish("File not found.");
        }

        public override void Override()
        {
            Versions.Override(target);
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.Loading:
                    while (groupIndex < manifest.groups.Count)
                    {
                        var group = manifest.groups[groupIndex];
                        while (assetIndex < group.assets.Count)
                        {
                            var asset = group.assets[assetIndex];
                            if (!asset.isFolder)
                            {
                                target.AddAsset(asset.path);
                            }
                            else
                            {
                                foreach (var child in asset.GetChildren())
                                {
                                    target.AddAsset(child);
                                }
                            }

                            assetIndex++;
                        }

                        assetIndex = 0;
                        groupIndex++;
                    }
                    Finish();
                    break;
            }
        }

        public static EditorManifestFile Create(string name, bool builtin)
        {
            var asset = new EditorManifestFile
            {
                name = name
            };
            return asset;
        }
    }
}
#endif



