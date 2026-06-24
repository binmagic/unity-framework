using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     批量下载操作
    /// </summary>
    public sealed class DownloadVersions : Operation
    {
        /// <summary>
        ///     所有下载类
        /// </summary>
        private List<Download> downloads = new List<Download>();

        /// <summary>
        ///     批量下载的分组信息
        /// </summary>
        public DownloadInfo[] groups;

        /// <summary>
        ///     下载的总大小
        /// </summary>
        public ulong totalSize { get; private set; }

        /// <summary>
        ///     已经下载的大小
        /// </summary>
        public ulong downloadedBytes { get; private set; }

        /// <summary>
        /// 是否最高优先级下载
        /// </summary>
        public bool highestPriority = false;
        
        public override void Start()
        {
            base.Start();
            if (highestPriority)
            {
                foreach (var info in groups)
                {
                    totalSize += info.size;
                }
                
                var list = Download.DownloadGroupWithHighestPriority(groups);
                downloads = list;
            }
            else
            {
                foreach (var info in groups)
                {
                    downloads.Add(Download.DownloadAsync(info));
                    totalSize += info.size;
                }
            }

            downloadedBytes = 0;
        }

        public void Stop()
        {
            foreach (var download in downloads)
            {
                download.Cancel();
            }

            downloads.Clear();
            totalSize = 0;
            downloadedBytes = 0;
        }
        
        protected override void Update()
        {
            switch (status)
            {
                case OperationStatus.Processing:
                    ulong temDownloadedBytes = 0;
                    var allDown = true;
                    foreach (var download in downloads)
                    {
                        temDownloadedBytes += download.downloadedBytes;
                        if (!download.isDone)
                        {
                            allDown = false;
                        }
                    }

                    downloadedBytes = temDownloadedBytes;
                    progress = (float) temDownloadedBytes / totalSize;
                    if (allDown)
                    {
                        var err = new StringBuilder();
                        foreach (var download in downloads)
                        {
                            if (!string.IsNullOrEmpty(download.error))
                                err.AppendLine(download.error);
                        }
                        Finish(err.ToString());
                    }

                    break;
            }
        }
    }
}





