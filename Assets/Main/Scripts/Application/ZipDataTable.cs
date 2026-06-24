using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using GameFramework;
using Main.Scripts.Application.LoadingState;
using UnityEngine;
using UnityEngine.Networking;
using Logger = VEngine.Logger;

public enum ConfigStatus
{
    Init = 0, 
    BeginDownload = 1,
    FinishDownload = 2,
    BeginUnzip = 3,
    FinishUnzip = 4,
    NotUseLocal = 5,
}

// 内网配置打包处理
public class ZipDataTable
{
    private HttpRequest _zipDownloadRequest;
    // public bool downloadFinish = false;
    // public bool isZipModeFinish = false;
    public ConfigStatus _ConfigStatus = ConfigStatus.Init;
    private static readonly string LuaDataTableRootPath = "/ZipDocument/getnewlua/";
    
    public void StartZipDownLoad(Action callBack1,Action callBack2)
    {
        Debug.Log("lszconfig - StartZipDownLoad");
        if (GameEntry.Resource.SkipUpdate)
        {
            _ConfigStatus = ConfigStatus.NotUseLocal;
            return;
        }

        string branch_name = GameEntry.Sdk.GetDataFromNative("PF_BranchName", "");
        string url = "http://10.7.88.22:886/lm/getnewlua.zip";
        if (!string.IsNullOrEmpty(branch_name) && !branch_name.Equals("barrel_new2"))
        {
            url = string.Format("http://10.7.88.22:886/lm/{0}_getnewlua.zip", branch_name);
        }
        Debug.Log($"lszconfig - 开始下载配置文件 {url}");
        _zipDownloadRequest = new HttpRequest(url);
        _zipDownloadRequest.onFailed += delegate(string error)
        {
             callBack1?.Invoke();
            //_startupLoading.SetState(LoadingState.LoadingError, LoginErrorCode.ERROR_DOWNLOAD_ZIP_ERROR);
        };
        _zipDownloadRequest.onSuccess += delegate(DownloadHandler downloadHandler)
        {

        };
        _zipDownloadRequest.onTimeOut += delegate
        {
            callBack2?.Invoke();
            //_startupLoading.SetState(LoadingState.LoadingError, LoginErrorCode.ERROR_DOWNLOAD_ZIP_TIMEOUT);
        };
        _zipDownloadRequest.Timeout = 30;
        _zipDownloadRequest.SendRequest();

    }


    public void UnzipDatabase(byte[] data)
    {
        var dirName = Application.persistentDataPath + "/ZipDocument/";
        if (!string.IsNullOrEmpty(dirName) && !Directory.Exists(dirName))
        {
            Directory.CreateDirectory(dirName);
        }

        var zipPath = dirName+"getnewlua.zip";
        FileStream writeStream; // 写入本地文件流对象
        writeStream = new FileStream(zipPath, FileMode.Create);
        writeStream.Write(data, 0, data.Length);
        writeStream.Dispose();
        var folderPath = dirName+"getnewlua/";
        if (Directory.Exists(folderPath))
        {
            Directory.Delete(folderPath,true);
        }
        if (!string.IsNullOrEmpty(folderPath) && !Directory.Exists(folderPath))
        {
            Directory.CreateDirectory(folderPath);
        }
        using (ZipArchive archive = ZipFile.OpenRead(zipPath))
        {
            foreach (ZipArchiveEntry entry in archive.Entries)
            {
                string destinationPath = Path.Combine(folderPath, entry.FullName);
                if (entry.FullName.EndsWith("/"))
                {
                    if (!string.IsNullOrEmpty(destinationPath) && !Directory.Exists(destinationPath))
                    {
                        Directory.CreateDirectory(destinationPath);
                    }
                }
                else if (entry.FullName.EndsWith(".txt", StringComparison.OrdinalIgnoreCase) || entry.FullName.EndsWith(".lua", StringComparison.OrdinalIgnoreCase))
                {

                    if (destinationPath.StartsWith(folderPath, StringComparison.Ordinal))
                    {
                        entry.ExtractToFile(destinationPath, true);
                    }
                }
            }
        }
        _ConfigStatus = ConfigStatus.FinishUnzip;
        Debug.Log("lszconfig - download Zip finish");
    }

    public void DisposeZipDownloadRequest()
    {
        if (_zipDownloadRequest != null)
        {
            _zipDownloadRequest.Dispose();
            _zipDownloadRequest = null;
        }
    }
    
    /// <summary>
    /// 1. 待解压,需要拦截  2.解压完成  3.不做处理
    /// </summary>
    /// <param name="callBack"></param>
    /// <returns></returns>
    public int ExecuteUnzipDatabase(Action callBack)
    {
        if (_zipDownloadRequest != null)
        {
            _zipDownloadRequest.OnUpdate();
            if (_zipDownloadRequest == null)
            {
                return 1;
            }
            if (!_zipDownloadRequest.isDone)
            {
                return 1;
            }
            if (!string.IsNullOrEmpty(_zipDownloadRequest.error))
            {
                 callBack?.Invoke();
                return 1;
            }
            UnzipDatabase(_zipDownloadRequest.data);
            _zipDownloadRequest.Dispose();
            _zipDownloadRequest = null;
             return 2;
        }

          return 3;
    }

    // 加载zip文件
    public byte[] LoadZipFile(string filepath)
    {
        if (_ConfigStatus == ConfigStatus.NotUseLocal)
            return null;
        if (filepath.Contains("LuaDatatable"))
        {
            var str = filepath.Split('.');
            if (str.Length != 2)
            {
                str = filepath.Split('/');
            }

            if (str.Length == 2)
            {
                var name = str[str.Length - 1];
                var luafile = Application.persistentDataPath +LuaDataTableRootPath + name+ ".lua";
                if (File.Exists(luafile))
                {
                    //Debug.Log($"lszconfig - : load file:{luafile}");
                    return File.ReadAllBytes(luafile);
                }
            }

        }

        return null;
    }
}





