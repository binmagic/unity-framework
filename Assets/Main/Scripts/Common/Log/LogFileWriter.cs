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





