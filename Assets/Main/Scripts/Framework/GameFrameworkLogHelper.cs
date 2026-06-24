using GameFramework;
using UnityEngine;

public class GameFrameworkLogHelper : GameFrameworkLog.ILogHelper
{
    public void Log(GameFrameworkLogLevel level, object message)
    {
        switch (level)
        {
            case GameFrameworkLogLevel.Debug:
                UnityEngine.Debug.Log(message);
                break;
            case GameFrameworkLogLevel.Info:
                UnityEngine.Debug.Log(message);
                break;
            case GameFrameworkLogLevel.Warning:
                UnityEngine.Debug.LogWarning(message);
                break;
            case GameFrameworkLogLevel.Error:
                UnityEngine.Debug.LogError(message);
                break;
            case GameFrameworkLogLevel.Fatal:
                UnityEngine.Debug.LogError($"[FATAL] {message}");
                break;
        }
    }
}
