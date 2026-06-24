//------------------------------------------------------------
// Game Framework
// Copyright © 2013-2021 Jiang Yin. All rights reserved.
// Homepage: https://gameframework.cn/
// Feedback: mailto:ellan@gameframework.cn
//------------------------------------------------------------


using System.Diagnostics;
using UnityEngine;

namespace GameFramework
{
    /// <summary>
    /// 日志类。
    /// </summary>
    public class Log
    {
        private static int WriteLogLevel = 1;

        static Log()
        {
            // 先读一下LOG标志；0不写LOG，1写所有LOG，2只写错误LOG
            // 理论上应该是log分级，0不写，1只写错误，2写所有；但是这里用0，1表示，写或不写，相对兼容
            WriteLogLevel = PlayerPrefs.GetInt("WriteLogLevel", 1);
        }

        public static int GetWriteLogLevel()
        {
            return WriteLogLevel;
        }

        public static void SetWriteLogLevel(int value)
        {
            if (WriteLogLevel != value)
            {
                WriteLogLevel = value;
                PlayerPrefs.SetInt("WriteLogLevel", WriteLogLevel);
            }
        }
        

        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="message">日志内容。</param>
        [Conditional("DEBUG")]
        public static void Debug(string message)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, message);
        }
        
        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="message">日志内容。</param>
        [Conditional("DEBUG")]
        public static void Debug(object message)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, message);
        }

        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        [Conditional("DEBUG")]
        public static void Debug(string format, object arg0)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, string.Format(format, arg0));
        }

        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        [Conditional("DEBUG")]
        public static void Debug(string format, object arg0, object arg1)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, string.Format(format, arg0, arg1));
        }

        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        /// <param name="arg2">日志参数 2。</param>
        [Conditional("DEBUG")]
        public static void Debug(string format, object arg0, object arg1, object arg2)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, string.Format(format, arg0, arg1, arg2));
        }

        /// <summary>
        /// 记录调试级别日志，仅在带有 DEBUG 预编译选项时产生。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="args">日志参数。</param>
        [Conditional("DEBUG")]
        public static void Debug(string format, params object[] args)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Debug, string.Format(format, args));
        }

        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Info(string message)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, message);
        }
        
        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Info(object message)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, message);
        }

        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        public static void Info(string format, object arg0)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, string.Format(format, arg0));
        }

        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        public static void Info(string format, object arg0, object arg1)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, string.Format(format, arg0, arg1));
        }

        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        /// <param name="arg2">日志参数 2。</param>
        public static void Info(string format, object arg0, object arg1, object arg2)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, string.Format(format, arg0, arg1, arg2));
        }

        /// <summary>
        /// 打印信息级别日志，用于记录程序正常运行日志信息。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="args">日志参数。</param>
        public static void Info(string format, params object[] args)
        {
            if (WriteLogLevel != 1) return;
            LogHelper(LogLevel.Info, string.Format(format, args));
        }
        
        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="message">日志内容。</param>
        public static void Error(string message)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, message);
        }
        
        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="message">日志内容。</param>
        public static void Error(object message)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, message);
        }
        
        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        public static void Error(string format, object arg0)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, string.Format(format, arg0));
        }

        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        public static void Error(string format, object arg0, object arg1)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, string.Format(format, arg0, arg1));
        }

        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="arg0">日志参数 0。</param>
        /// <param name="arg1">日志参数 1。</param>
        /// <param name="arg2">日志参数 2。</param>
        public static void Error(string format, object arg0, object arg1, object arg2)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, string.Format(format, arg0, arg1, arg2));
        }

        /// <summary>
        /// 打印错误级别日志，建议在发生功能逻辑错误，但尚不会导致游戏崩溃或异常时使用。
        /// </summary>
        /// <param name="format">日志格式。</param>
        /// <param name="args">日志参数。</param>
        public static void Error(string format, params object[] args)
        {
            if (WriteLogLevel == 0) return;
            LogHelper(LogLevel.Error, string.Format(format, args));
        }

        private static void LogHelper(LogLevel level, object message)
        {
            LogHelper(level, message.ToString());
        }
        
        private static void LogHelper(LogLevel level, string message)
        {
            switch (level)
            {
                case LogLevel.Debug:
                    UnityEngine.Debug.Log(message);
                    break;
                case LogLevel.Info:
                    UnityEngine.Debug.Log(message);
                    break;
                case LogLevel.Warning:
                    UnityEngine.Debug.LogWarning(message);
                    break;
                case LogLevel.Error:
#if !UNITY_EDITOR
                    PostEventLog.LogToFeishu(message);               
#endif
                    UnityEngine.Debug.LogError(message);
                    break;
                default:
#if UNITY_EDITOR
                    UnityEngine.Debug.LogError(message); 
#endif
                    break;
            }
        }

    }
}





