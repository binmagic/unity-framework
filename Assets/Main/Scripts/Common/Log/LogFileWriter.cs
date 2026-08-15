/**
 * [INPUT]: 依赖 System.IO 与内部 FileWriter 落盘,依赖 Application.persistentDataPath 定位目录
 * [OUTPUT]: 对外提供 GameFramework.LogFile,按时间戳建文件、格式化写入日志行并清理历史日志
 * [POS]: Common/Log 的落盘后端,被 Log 门面驱动,与 LogLevel(分级)/Log(入口)构成完整日志链路
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using System.IO;
using UnityEngine;

namespace GameFramework
{
    public class LogFile
    {
        private FileWriter _fileWriter;
        private const int MaxLogLevelLength = 9;

        public LogFile()
        {
            _fileWriter = new FileWriter(string.Format("{0}/{1:yyyy-MM-dd-HH-mm-ss}_Log.txt", Application.persistentDataPath, DateTime.Now));
        }

        public void Write(LogType logType, string trace, string message)
        {
            var logLevelStr = $"[{logType.ToString()}]".PadRight(MaxLogLevelLength);
            var logLine = string.Format("{0:yyyy/MM/dd/HH:mm:ss:fff} {1}: {2}\n {3}", DateTime.Now, logLevelStr, message, trace);
            _fileWriter.WriteLine(logLine);
        }

        public void ClearOld()
        {
            var now = DateTime.Now;
            var logs = Directory.GetFiles(Application.persistentDataPath, "*_Log.txt");

            foreach (var i in logs)
            {
                var deltaTime = now - File.GetCreationTime(i);
                if (deltaTime.Days > 3)
                {
                    File.Delete(i);
                }
            }
        }
    }

    public class FileWriter
    {
        readonly object _lock = new object();
        readonly string _filePath;

        public FileWriter(string filePath)
        {
            _filePath = filePath;
        }

        public void WriteLine(string message)
        {
            lock (_lock)
            {
                using (StreamWriter writer = new StreamWriter(_filePath, true))
                {
                    writer.WriteLine(message);
                }
            }
        }

        public void ClearFile()
        {
            lock (_lock)
            {
                using (StreamWriter writer = new StreamWriter(_filePath, false))
                {
                    writer.Write(string.Empty);
                }
            }
        }
    }
}





