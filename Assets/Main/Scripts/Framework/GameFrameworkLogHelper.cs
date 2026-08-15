/**
 * [INPUT]: 依赖 GameFramework 日志接口 GameFrameworkLog.ILogHelper 与 UnityEngine.Debug
 * [OUTPUT]: 对外提供 GameFrameworkLogHelper，将框架日志等级桥接到 Unity 控制台输出
 * [POS]: Framework 层的日志适配器，在 GameEntry.Init 中经 GameFrameworkLog.SetLogHelper 注入,统一框架内部日志的落地方式
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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
