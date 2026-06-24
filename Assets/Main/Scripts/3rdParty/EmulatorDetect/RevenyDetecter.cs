#if UNITY_ANDROID && !UNITY_EDITOR
using System;
// ReSharper disable once CheckNamespace
using UnityEngine;
#endif
namespace EmulatorDetect
{
    /// <summary>
    ///     From com.reveny.emulatordetector
    ///     Edit by liudi
    /// </summary>
    public static class RevenyDetecter
    {
        private static bool _hasDetected;
        private static string _emluatorStr = "";
        private const string ClassName = "com.reveny.emulatordetector.plugin.EmulatorDetection";

        private static void _innerDetect()
        {
            _emluatorStr = "";
#if UNITY_ANDROID && !UNITY_EDITOR
            try
            {
                using (AndroidJavaObject obj = new AndroidJavaObject(ClassName))
                {
                    var detected = obj.Call<bool>("isDetected");
                    _emluatorStr = obj.Call<string>("getResult");
                    var time = obj.Call<long>("getDetectCost");
                    Debug.Log($"RD Detected: {detected} CostTime: {time}");
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
#endif
            _hasDetected = true;
        }

        public static string GetEmulatorStr(bool forceCheck = false)
        {
            if (_hasDetected && !forceCheck)
                return _emluatorStr;
            _innerDetect();
            return _emluatorStr;
        }
    }
}