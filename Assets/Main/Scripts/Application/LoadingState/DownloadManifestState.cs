using System;
using System.IO;
using System.IO.Compression;
using GameFramework;
using Main.Scripts.Application.LoadingState;
using UnityEngine;
using UnityEngine.Networking;


//
// 下载Manifest
//

#region Download Manifest

[UnityEngine.Scripting.Preserve]
public class DownloadManifest
{
    private VEngine.Manifest _manifest;
    private VEngine.ManifestVersionFile _versionFile;
    private string _versionName;
    private string _pathOrURL;
    private Status _status;
    private HttpRequest _httpRequest;
    private string _error;

    private enum Status
    {
        Loading, CheckVersion, Downloading, Success, Failed
    }
    
    public bool isDone => _status == Status.Success || _status == Status.Failed;

    public string error => _error;
    
    public VEngine.Manifest manifest => _manifest;
    
    public DownloadManifest(string name)
    {
        _manifest = new VEngine.Manifest
        {
            name = name.ToLower(),
            onReadAsset = VEngine.Versions.OnReadAsset
        };
    }

    ~DownloadManifest()
    {
        Debug.Log(">>> DownloadManifest~ Destroy!");
    }

    public void Dispose()
    {
        if (_httpRequest != null)
        {
            _httpRequest.Dispose();
            _httpRequest = null;
        }
        Debug.Log(">>> DownloadManifest~ Dispose!");
    }
    
    public static DownloadManifest LoadAsync(string name)
    {
        var download = new DownloadManifest(name);
        download.Load();
        return download;
    }

    private void Load()
    {
        _versionName = VEngine.Manifest.GetVersionFile(_manifest.name);
        var versionPath = GameEntry.Resource.GetTempDownloadPath(_versionName);
        if (!File.Exists(versionPath))
        {
            Finish("version not exist.");
            return;
        }

        _versionFile = VEngine.ManifestVersionFile.Load(versionPath);
        _pathOrURL = VEngine.Versions.GetDownloadURL($"{_manifest.name}{VEngine.ManifestFile.CompressPosfix}_v{_versionFile.version}");

        _status = Status.CheckVersion;
    }

    public void OnUpdate()
    {
        switch (_status)
        {
            case Status.CheckVersion:
                UpdateVersion();
                break;

            case Status.Downloading:
                UpdateDownloading();
                break;

            case Status.Loading:
                var path = GameEntry.Resource.GetTempDownloadPath(_manifest.name);
                path += ".temp";
                _manifest.Load(path);
                Finish();
                break;
        }
    }

    private void UpdateVersion()
    {
        var path = GameEntry.Resource.GetTempDownloadPath(_manifest.name);
#if FINAL_RELEASE
        var _manifestList = VEngine.Versions.Manifests;
        for (int i = 0; i < _manifestList.Count; ++i)
        {
            var m = _manifestList[i];
            if (_manifest.name.Contains(m.name))
            {
                Debug.Log($">>>Version: Package: {m.version}  Remote: {_versionFile.version}");
                if (m.version >= _versionFile.version)
                {
                    Log.Info("[DownloadManifestState]1 Skip to download {0}, local version == remote version", _manifest.name);
                    if (File.Exists(path))
                    {
                        File.Delete(path);
                    }

                    _manifest = m;
                    Finish();
                    return;
                }
            }
            // if (m.version == _versionFile.version && _manifest.name.Contains(m.name))
            // {
            //     Log.Info("[DownloadManifestState]1 Skip to download {0}, local version == remote version", _manifest.name);
            //     if (File.Exists(path))
            //     {
            //         File.Delete(path);
            //     }
            //
            //     _manifest = m;
            //     Finish();
            //     return;
            // }
        }
#endif

        if (File.Exists(path))
        {
            using (var stream = File.OpenRead(path))
            {
                if (VEngine.Utility.ComputeCRC32(stream) == _versionFile.crc)
                {
                    Log.Info("[DownloadManifestState]2 Skip to download {0}, remote manifest exist (same crc)", _manifest.name);
                    _status = Status.Loading;
                    return;
                }
                else
                {
                    Debug.Log("crc not match!!");
                }
            }
        }
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        
        Log.Info("begin to download manifest: {0}", _pathOrURL);
        _httpRequest = new HttpRequest(_pathOrURL);
        _httpRequest.Timeout = 10;
        
        _httpRequest.onFailed += delegate(string error)
        {
            PostEventLog.Record(PostEventLog.Defines.DOWNLOAD_MANIFEST_FAILED, $"{_manifest.name} {error}");
        };
        _httpRequest.onTimeOut += delegate()
        {
            PostEventLog.Record(PostEventLog.Defines.DOWNLOAD_MANIFEST_TIMEOUT, _manifest.name);
        };
        _httpRequest.onSuccess += delegate(DownloadHandler downloadHandler)
        {
            PostEventLog.Record(PostEventLog.Defines.DOWNLOAD_MANIFEST_SUCCESS, _manifest.name);
        };
        _httpRequest.SendRequest();
        _status = Status.Downloading;
        PostEventLog.Record(PostEventLog.Defines.DOWNLOAD_MANIFEST_START, _manifest.name);
    }
    
    private void UpdateDownloading()
    {
        _httpRequest.OnUpdate();
        
        if (!_httpRequest.isDone)
        {
            return;
        }

        if (!string.IsNullOrEmpty(_httpRequest.error))
        {
            Finish(_httpRequest.error);
            return;
        }
        
        Log.Info("download manifest finish: {0}", _manifest.name);
        try
        {
            var path = GameEntry.Resource.GetTempDownloadPath(_manifest.name);
            path += ".temp";
            UnzipToFile(_httpRequest.data, path);
        }
        catch (Exception e)
        {
            int len = _httpRequest.data != null ? _httpRequest.data.Length : 0;
            var exception = e.Message + "\n" + e.StackTrace;
            PostEventLog.Record(PostEventLog.Defines.DOWNLOAD_MANIFEST_FAILED, $"{_manifest.name} len: {len}, exception: {exception}");
            Finish(exception);
            return;
        }

        _httpRequest = null;
        _status = Status.Loading;
    }

    private void Finish(string error = null)
    {
        _error = error;
        _status = string.IsNullOrEmpty(_error) ? Status.Success : Status.Failed;
    }

    private void Unzip(byte[] data, string path)
    {
        using (var stream = new MemoryStream(data))
        using (var zip = new ZipArchive(stream))
        {
            string dirName = Path.GetDirectoryName(path);
        
            foreach (ZipArchiveEntry entry in zip.Entries)
            {
                string fullPath = Path.Combine(dirName, entry.FullName);
                Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
                using (Stream destination = File.Open(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    using (Stream entryStream = entry.Open())
                        entryStream.CopyTo(destination);
                }
            }
        }
    }

    private void UnzipToFile(byte[] data, string filename)
    {
        using (var stream = new MemoryStream(data))
        using (var zip = new ZipArchive(stream))
        {
            foreach (ZipArchiveEntry entry in zip.Entries)
            {
                Directory.CreateDirectory(Path.GetDirectoryName(filename));
                using (Stream destination = File.Open(filename, FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    using (Stream entryStream = entry.Open())
                        entryStream.CopyTo(destination);
                }
            }
        }
    }

}

#endregion





