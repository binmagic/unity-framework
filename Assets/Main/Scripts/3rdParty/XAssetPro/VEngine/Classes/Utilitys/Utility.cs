using System.IO;
using UnityEngine;

namespace VEngine
{
    /// <summary>
    ///     工具类
    /// </summary>
    public static class Utility
    {
        /// <summary>
        ///     打包输出的目录
        /// </summary>
        public const string buildPath = "AssetBundles";

        public const string unsupportedPlatform = "Unsupported";
        
        public static int[] IntArrayEmpty = new int[0];

        private static readonly double[] byteUnits =
        {
            1073741824.0, 1048576.0, 1024.0, 1
        };

        private static readonly string[] byteUnitsNames =
        {
            "GB", "MB", "KB", "B"
        };

        public static string GetPlatformName()
        {
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    return "Android";
                case RuntimePlatform.WindowsPlayer:
                    return "Windows";
                case RuntimePlatform.IPhonePlayer:
                    return "iOS";
                case RuntimePlatform.WebGLPlayer:
                    return "WebGL";
                default:
                    return unsupportedPlatform;
            }
        }

        /// <summary>
        ///     将字节大小自动转换成 B，GB，MB，KB 等单位输出
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public static string FormatBytes(ulong bytes)
        {
            var size = "0 B";
            if (bytes == 0)
            {
                return size;
            }

            for (var index = 0; index < byteUnits.Length; index++)
            {
                var unit = byteUnits[index];
                if (bytes >= unit)
                {
                    size = $"{bytes / unit:##.##} {byteUnitsNames[index]}";
                    break;
                }
            }

            return size;
        }

        public static uint ComputeCRC32(Stream stream)
        {
            var crc32 = new CRC32();
            return crc32.Compute(stream);
        }

        private static readonly CRC32 _crc32 = new CRC32();

        public static uint ComputeCRC32(string filename)
        {
#if UNITY_WEBGL
            // WebGL: 包已由微信平台校验完整性，跳过客户端 CRC 校验
            return 0;
#else
            if (!File.Exists(filename))
            {
                return 0;
            }
            _crc32.ClearCrc();
            using (var stream = File.OpenRead(filename))
            {
                return _crc32.Compute(stream);
            }
#endif
        }
    }
}





