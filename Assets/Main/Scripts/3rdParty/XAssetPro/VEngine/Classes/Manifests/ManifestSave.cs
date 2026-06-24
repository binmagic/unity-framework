using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace VEngine
{
    /// <summary>
    /// 这部分是保存文件信息，所以这里只有编辑器有即可，运行时不存在
    /// 所以这里使用单独的文件去处理
    /// </summary>
    public partial class Manifest
    {
#if UNITY_EDITOR
        public void AddAsset(string path)
        {
            var asset = new AssetInfo
            {
                id = assets.Count
            };
            assets.Add(asset);
            allAssetPaths.Add(path);
            pathWithAssets[path] = assets.Count - 1;//asset;
            if (onReadAsset != null)
            {
                onReadAsset(path);
            }
        }
        
        /// <summary>
        ///     所有版本内的资源路径
        /// </summary>
        public string[] AllAssetPaths => allAssetPaths.ToArray();
        
        public string Save(string path)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }

            using (var writer = new StreamWriter(File.OpenWrite(path)))
            {
                writer.WriteLine($"#{appVersion}");
                
                WriteVersion(writer);
                
                WriteDirectories(writer);
                WriteAssets(writer);
                
                WriteDependencies(writer);
                WriteBundles(writer);
            }

            return SaveVersion(path);
        }
        
        private void WriteVersion(StreamWriter writer)
        {
            writer.WriteLine(key_version);
            writer.WriteLine($"{version},0");
            writer.WriteLine();
        }

        private void WriteDirectories(StreamWriter writer)
        {
            writer.WriteLine(key_directories);
            
            directories.Clear();
            var directoryWithIDs = new Dictionary<string, int>();
            
            for (var index = 0; index < allAssetPaths.Count; index++)
            {
                var assetPath = allAssetPaths[index];
                var directoryName = Path.GetDirectoryName(assetPath);
                var file = Path.GetFileName(assetPath);
                var dir = -1;
                if (string.IsNullOrEmpty(directoryName))
                {
                    allAssetPaths[index] = $"{dir}/{file}";
                    continue;
                }

                directoryName = directoryName.Replace('\\', '/');
                if (!directoryWithIDs.TryGetValue(directoryName, out dir))
                {
                    dir = directories.Count;
                    directoryWithIDs.Add(directoryName, dir);
                    directories.Add(directoryName);
                    //writer.WriteLine($"{dir}={directoryName}");
                }

                allAssetPaths[index] = $"{dir}/{file}";
            }
            
            string str = string.Format("{0}{1}", key_count, directories.Count);
            writer.WriteLine(str);

            string prefix = "assets/";
            for (int i = 0; i < directories.Count; ++i)
            {
                string s = directories[i];
                if (s.StartsWith(prefix))
                {
                    s = s.Remove(0, prefix.Length);
                }
                writer.WriteLine($"{i}={s}");
            }

            writer.WriteLine();
        }

        private void WriteDependencies(StreamWriter writer)
        {
            writer.WriteLine(key_dependencies);

            dep_bundles.Clear();
            dep_bundles.Add(new int[0]);
            
            // 先扫描一遍，把所有的dep项组合起来
            foreach (var bundle in bundles)
            {
                if (bundle.deps.Length > 0)
                {
                    Array.Sort(bundle.deps);
                    
                    int dep_index = -1;
                    for (int i = 0; i < dep_bundles.Count; ++i)
                    {
                        int[] a = dep_bundles[i];
                        if (Enumerable.SequenceEqual(a, bundle.deps))
                        {
                            dep_index = i;
                            break;
                        }
                    }
            
                    if (dep_index == -1)
                    {
                        dep_index = dep_bundles.Count;
                        dep_bundles.Add(bundle.deps);
                    }
                }
            }
            
            string str = string.Format("{0}{1}", key_count, dep_bundles.Count);
            writer.WriteLine(str);
            for (int i=0;i<dep_bundles.Count;++i)
            {
                //string s = StringExtensions.Join("|", dep_bundles[i]);
                string s = StringExtensions.IntArrayToString(dep_bundles[i]);
                writer.WriteLine($"{i}={s}");
            }

            writer.WriteLine();
        }

        private void WriteAssets(StreamWriter writer)
        {
            writer.WriteLine(key_assets);
            
            string str = string.Format("{0}{1}", key_count, assets.Count);
            writer.WriteLine(str);

            foreach (var asset in assets)
            {
                string p = allAssetPaths[asset.id];
                string line = $"{asset.id},{p},{asset.bundle}";
                writer.WriteLine(line);
            }

            writer.WriteLine();
        }
        
        private void WriteBundles(StreamWriter writer)
        {
            writer.WriteLine(key_bundles);
            
            string str = string.Format("{0}{1}", key_count, bundles.Count);
            writer.WriteLine(str);
            
            foreach (var bundle in bundles)
            {
                string str_assets = StringExtensions.IntArrayToString(bundle.assets);

                int dep_index = 0;
                if (bundle.deps.Length > 0)
                {
                    for (int i = 0; i < dep_bundles.Count; ++i)
                    {
                        int[] a = dep_bundles[i];
                        if (Enumerable.SequenceEqual(a, bundle.deps))
                        {
                            dep_index = i;
                            break;
                        }
                    }
            
                    if (dep_index == 0)
                    {
                        Logger.E("Version not changed.");
                    }
                }
                
                string line = $"{bundle.id},{bundle.name},{bundle.crc},{bundle.size},{str_assets},{dep_index},{bundle.resMode}";
                writer.WriteLine(line);
            }

            writer.WriteLine();
        }

        private string SaveVersion(string path)
        {
            var file = Path.GetFileName(path);
            var outputFolder = Path.GetDirectoryName(path);
            string newName;
            using (var stream = File.OpenRead(path))
            {
                var crc = Utility.ComputeCRC32(stream);
                var versionFile = $"{outputFolder}/{GetVersionFile(file)}";
                if (File.Exists(versionFile))
                {
                    var text = File.ReadAllText(versionFile);
                    var fields = text.Split(',');
                    var lastCRC = fields[2].UIntValue();
                    if (lastCRC.Equals(crc))
                    {
                        Logger.I("Version not changed.");
                    }
                    File.Delete(versionFile);
                }
                newName = $"{file}_v{version}";
                var content = $"{version},{stream.Length},{crc}";
                File.WriteAllText(versionFile, content);
                File.Copy(versionFile, versionFile.Replace(file, newName), true);
                File.Copy(path, path.Replace(file, newName), true);
            }
            return newName;
        }
#endif
    
    }
}





