using System;
using System.Diagnostics;
using Debug = UnityEngine.Debug;

namespace VEngine
{
    /// <summary>
    ///     日志工具
    /// </summary>
    public static class Logger
    {
        /// <summary>
        ///     是否开启调试日志打印
        /// </summary>
        public static bool Loggable = false;
        
        /// <summary>
        ///     按输入的 name 输出执行 action 的毫秒时间
        /// </summary>
        /// <param name="action"></param>
        /// <param name="name"></param>
#if UNITY_EDITOR
        public static void T(Action action, string name)
        {
            var watch = new Stopwatch();
            watch.Start();
            action.Invoke();
            watch.Stop();
            Debug.LogFormat("Log.T -> {0} with {1:f4}s.", name, watch.ElapsedMilliseconds / 1024);
        }
#endif

        /// <summary>
        ///     打印错误
        /// </summary>
        /// <param name="format"></param>
        /// <param name="args"></param>
        public static void E(string format, params object[] args)
        {
            /*if (!Loggable)
            {
                return;
            }*/

            Debug.LogErrorFormat(format, args);
        }

        /// <summary>
        ///     打印警告
        /// </summary>
        /// <param name="format"></param>
        /// <param name="args"></param>
        public static void W(string format, params object[] args)
        {
            if (!Loggable)
            {
                return;
            }

            Debug.LogWarningFormat(format, args);
        }

        /// <summary>
        ///     打印信息
        /// </summary>
        /// <param name="format"></param>
        /// <param name="args"></param>
        public static void I(string format, params object[] args)
        {
            if (!Loggable)
            {
                return;
            }

            Debug.LogFormat(format, args);
        }
    }
}





