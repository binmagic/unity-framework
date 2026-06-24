using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Threading;
using GameFramework;
using UnityEngine;

namespace VEngine
{
    public class Download : CustomYieldInstruction
    {
        public static uint MaxDownloads = 10;
        public static ulong MaxBandwidth = 0;
        public static int MaxRetryTimes = 5;
        public static uint ReadBufferSize = 1024 * 4;
        public static readonly List<Download> Prepared = new List<Download>();
        public static readonly List<Download> Progressing = new List<Download>();
        public static readonly Dictionary<string, Download> Cache = new Dictionary<string, Download>();
        private static float lastSampleTime;
        private static ulong lastTotalDownloadedBytes;


        private readonly byte[] _readBuffer = new byte[ReadBufferSize];
        private ulong _bandWidth;

        private Thread _thread;

        private int retryTimes;
        private FileStream writer;
        
        
        private Download()
        {
            status = DownloadStatus.Wait;
            downloadedBytes = 0;
            createTime = Time.realtimeSinceStartup;
        }

        public DownloadInfo info { get; private set; }


        public DownloadStatus status { get; private set; }

        public string error { get; private set; }
        public Action<Download> completed { get; set; }

        public bool isDone
        {
            get { return status == DownloadStatus.Failed || status == DownloadStatus.Success; }
        }

        public bool isRetry
        {
            get { return retryTimes > 0; }
        }

        public float createTime { get; set; }

        public float progress
        {
            get { return downloadedBytes * 1f / info.size; }
        }

        public ulong downloadedBytes { get; private set; }

        public override bool keepWaiting
        {
            get { return !isDone; }
        }
        

        public static ulong TotalDownloadedBytes
        {
            get
            {
                var value = 0UL;
                foreach (var item in Cache) value += item.Value.downloadedBytes;

                return value;
            }
        }
        

        public static ulong TotalBandwidth { get; private set; }

        public static void ClearAllDownloads()
        {
            foreach (var download in Progressing) download.Cancel();
            Prepared.Clear();
            Progressing.Clear();
            Cache.Clear();
        }

        public static Download DownloadAsync(string url, string savePath, Action<Download> completed = null,
            ulong size = 0, uint crc = 0, int resMode = 0)
        {
            return DownloadAsync(new DownloadInfo
            {
                url = url,
                savePath = savePath,
                crc = crc,
                size = size,
                resMode = resMode
            }, completed);
        }

        public static Download DownloadAsync(DownloadInfo info, Action<Download> completed = null, bool highPriority = false)
        {
            if (!Cache.TryGetValue(info.url, out var download))
            {
                download = new Download
                {
                    info = info
                };

                if (highPriority)
                    Prepared.Insert(0, download);
                else
                    Prepared.Add(download);
                
                Cache.Add(info.url, download);
            }
            else
            {
                Logger.W("Download url {0} already exist.", info.url);
            }

            if (completed != null) download.completed += completed;

            return download;
        }

        /// <summary>
        /// 以最高优先级下载一组任务
        /// </summary>
        /// <param name="downloadInfos"></param>
        /// <returns></returns>
        public static List<Download> DownloadGroupWithHighestPriority(DownloadInfo[] downloadInfos)
        {
            //1st. 将Progressing中正在下载的Cancel掉 并放回到Prepare列表中
            Debug.Log($"#zlh# DownloadGroupWithHighestPriority 当前Progress数量: {Progressing.Count}");
            if (Progressing.Count > 0)
            {
                Prepared.AddRange(Progressing);
                foreach (var download in Progressing)
                {
                    Debug.Log($"#zlh# DownloadGroupWithHighestPriority 取消后台下载 [url]:{download.info.url}");
                    download.Cancel();
                }
                
                Progressing.Clear();
            }

            var downloadList = new List<Download>(downloadInfos.Length);
            Debug.Log($"#zlh# DownloadGroupWithHighestPriority 此次任务数量: {downloadInfos.Length}");

            //2nd. 检查当前任务列表 如果已在Prepare中提到最前 否则插入一条到Prepare最前端
            foreach (var info in downloadInfos)
            {
                var index = Prepared.FindIndex(d => d?.info?.url == info.url);
                if (index >= 0)
                {
                    Debug.Log($"#zlh# DownloadGroupWithHighestPriority 已有下载实例,提高优先级 [url]:{info.url}");
                    
                    if(index == 0) continue;
                    var download = Prepared[index];
                    Prepared.RemoveAt(index);
                    Prepared.Insert(0, download);
                    
                    downloadList.Add(download);
                }
                else
                {
                    Debug.Log($"#zlh# DownloadGroupWithHighestPriority 以最高优先级添加下载实例 [url]:{info.url}");

                    var download = DownloadAsync(info, null, true);
                    downloadList.Add(download);
                }
            }

            return downloadList;
        }

        public static void UpdateDownloads()
        {
            if (Prepared.Count > 0)
                for (var index = 0; index < Mathf.Min(Prepared.Count, MaxDownloads - Progressing.Count); index++)
                {
                    var download = Prepared[index];
                    Prepared.RemoveAt(index);
                    index--;
                    Progressing.Add(download);
                    download.Start();
                }

            if (Progressing.Count > 0)
            {
                for (var index = 0; index < Progressing.Count; index++)
                {
                    var download = Progressing[index];
                    if (CommonUtils.IsDebug())
                    {
                        float useTime = Time.realtimeSinceStartup - download.createTime;
                        if (useTime > 1)
                        {
                            Log.Debug("{0} download has use time {1}", download.info.url, useTime);
                            download.createTime = Time.realtimeSinceStartup;
                        }
                    }

                    if (download.status == DownloadStatus.Failed || download.status == DownloadStatus.DownloadFinish)
                    {
                        if (download.status == DownloadStatus.Failed)
                        {
                            if (download.error != "User Cancel")
                            {
                                Log.Error("Unable to download {0} with error {1}", download.info.url, download.error);
                            }
                        }
                        else
                        {
                            Log.Debug("Success to download {0} from {1}", download.info.savePath, download.info.url);
                        }

                        Progressing.RemoveAt(index);
                        index--;
                        download.Complete();
                    }
                }

                if (Time.realtimeSinceStartup - lastSampleTime >= 1)
                {
                    TotalBandwidth = TotalDownloadedBytes - lastTotalDownloadedBytes;
                    lastTotalDownloadedBytes = TotalDownloadedBytes;
                    lastSampleTime = Time.realtimeSinceStartup;
                }
            }
            else
            {
                if (Cache.Count <= 0) return;

                Cache.Clear();
                lastTotalDownloadedBytes = 0;
                lastSampleTime = Time.realtimeSinceStartup;
            }
        }

        /// <summary>
        ///     重试下载
        /// </summary>
        public void Retry()
        {
            status = DownloadStatus.Wait;
            Start();
        }

        public void UnPause()
        {
            Retry();
        }
        
        public void Pause()
        {
            status = DownloadStatus.Wait;
        }

        public void Cancel()
        {
            error = "User Cancel.";
            status = DownloadStatus.Failed;
        }

        private void Complete()
        {
            CheckStatus();
            
            if (completed != null)
            {
                completed.Invoke(this);
                completed = null;
            }
        }

        private void Run()
        {
            try
            {
                Downloading();
                if (writer != null)
                {
                    writer.Flush();
                    writer.Close();
                    writer = null;
                }
            }
            catch (Exception e)
            {
                if (writer != null)
                {
                    writer.Flush();
                    writer.Close();
                    writer = null;
                }

                error = $"{info.url} {e.Message}";
                // 出现异常 3s 后重试
                if (retryTimes < MaxRetryTimes)
                {
                    Thread.Sleep(1000);
                    Retry();
                    retryTimes++;
                }
                else
                {
                    status = DownloadStatus.Failed;
                }
            }
        }

        private void CheckStatus()
        {
            if (status != DownloadStatus.DownloadFinish) return;
            Debug.Log($">>>> bundle下载完成开始检测: {info.url}");
            // 下载完成，进行校验
            if (downloadedBytes != info.size)
            {
                error = $"{info.url} 长度 {downloadedBytes} 不符合期望 {info.size}";
                status = DownloadStatus.Failed;
                return;
            }

            if (info.crc != 0)
            {
                var crc = Utility.ComputeCRC32(info.savePath + ".bak");
                if (info.crc != crc)
                {
                    error = $"{info.url} crc {crc} 不符合期望 {info.crc}";
                    status = DownloadStatus.Failed;
                    return;
                }
            }

            if (File.Exists(info.savePath))
            {
                File.Delete(info.savePath);
            }
            File.Move(info.savePath + ".bak", info.savePath);
            status = DownloadStatus.Success;
        }

        private static bool CheckValidationResult(object sender, X509Certificate certificate, X509Chain chain,
            SslPolicyErrors spe)
        {
            return true;
        }

        private void Downloading()
        {
            var request = CreateWebRequest();
            Log.Debug("begin download {0}", info.url);
            using (var response = request.GetResponse())
            {
                if (response.ContentLength > 0)
                {
                    if (info.size == 0) info.size = (ulong) response.ContentLength + downloadedBytes;
                    using (var reader = response.GetResponseStream())
                    {
                        if (downloadedBytes < info.size)
                        {
                            var startTime = DateTime.Now;
                            while (status == DownloadStatus.Progressing)
                            {
                                if (ReadToEnd(reader)) break;
                                UpdateBandwidth(ref startTime);
                            }
                        }

                        if (writer != null)
                        {
                            writer.Flush();
                            writer.Close();
                            writer = null;
                        }
                        
                        status = DownloadStatus.DownloadFinish;
                    }
                }
                else
                {
                    if (writer != null)
                    {
                        writer.Flush();
                        writer.Close();
                        writer = null;
                    }
                    status = DownloadStatus.DownloadFinish;
                }
            }
        }

        private void UpdateBandwidth(ref DateTime startTime)
        {
            var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
            while (MaxBandwidth > 0 &&
                   status == DownloadStatus.Progressing &&
                   _bandWidth >= MaxBandwidth / (ulong) Progressing.Count &&
                   elapsed < 1000)
            {
                var wait = Mathf.Clamp((int) (1000 - elapsed), 1, 33);
                Thread.Sleep(wait);
                elapsed = (DateTime.Now - startTime).TotalMilliseconds;
            }

            if (!(elapsed >= 1000)) return;
            startTime = DateTime.Now;
            TotalBandwidth = _bandWidth;
            _bandWidth = 0L;
        }

        private WebRequest CreateWebRequest()
        {
            WebRequest request;
            if (info.url.StartsWith("https", StringComparison.OrdinalIgnoreCase))
            {
                ServicePointManager.ServerCertificateValidationCallback = CheckValidationResult;
                request = GetHttpWebRequest();
            }
            else
            {
                request = GetHttpWebRequest();
            }

            return request;
        }

        private WebRequest GetHttpWebRequest()
        {
            var httpWebRequest = (HttpWebRequest) WebRequest.Create(info.url);
            httpWebRequest.ProtocolVersion = HttpVersion.Version10;
            if (downloadedBytes > 0) httpWebRequest.AddRange((int) downloadedBytes);
            return httpWebRequest;
        }

        private bool ReadToEnd(Stream reader)
        {
            if (reader != null)
            {
                var len = reader.Read(_readBuffer, 0, _readBuffer.Length);
                if (len > 0)
                {
                    writer.Write(_readBuffer, 0, len);
                    downloadedBytes += (ulong) len;
                    _bandWidth += (ulong) len;
                }
                else
                {
                    return true;
                }
            }
            else
            {
                error = "reader == null";
                status = DownloadStatus.Failed;
                return true;
            }

            return false;
        }

        private void Start()
        {
            if (status != DownloadStatus.Wait) return;
            status = DownloadStatus.Progressing;
            var file = new FileInfo(info.savePath);
            if (file.Exists && file.Length > 0)
            {
                if (info.size > 0 && file.Length == (long) info.size)
                {
                    status = DownloadStatus.Success;
                    return;
                }

                // writer = File.OpenWrite(info.savePath);
                // downloadedBytes = (ulong) writer.Length - 1;
                // if (downloadedBytes > 0) writer.Seek(-1, SeekOrigin.End);
                writer = File.Create(info.savePath + ".bak");
                downloadedBytes = 0;
            }
            else
            {
                writer = File.Create(info.savePath + ".bak");
                downloadedBytes = 0;
            }
            _thread = new Thread(Run)
            {
                IsBackground = true
            };
            _thread.SetThreadName("DownloadThread");
            _thread.Start();
        }
    }
}





