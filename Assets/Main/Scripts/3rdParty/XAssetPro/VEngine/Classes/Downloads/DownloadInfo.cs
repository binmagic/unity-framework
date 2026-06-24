using System;

namespace VEngine
{
    [Serializable]
    public class DownloadInfo
    {
        public uint crc;
        public string savePath;
        public ulong size;
        public string url;
        public int resMode; //下载方式
    }
}





