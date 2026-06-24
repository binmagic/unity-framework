using System;
using System.Collections;
using Sfs2X.Core;

namespace Sfs2X.Logging
{
  public class Logger
  {
    private bool enableConsoleTrace = true;
    private bool enableEventDispatching = true;
    private SmartFox smartFox;
    private LogLevel loggingLevel;

    public Logger(SmartFox smartFox)
    {
      this.smartFox = smartFox;
      loggingLevel = LogLevel.INFO;
    }

    public bool IsDebug => this.smartFox.Debug;
    
    public bool EnableConsoleTrace
    {
      get => enableConsoleTrace;
      set => enableConsoleTrace = value;
    }

    public bool EnableEventDispatching
    {
      get => enableEventDispatching;
      set => enableEventDispatching = value;
    }

    public LogLevel LoggingLevel
    {
      get => loggingLevel;
      set => loggingLevel = value;
    }

    public void Debug(params string[] messages)
    {
      Log(LogLevel.DEBUG, string.Join(" ", messages));
    }

    public void Info(params string[] messages)
    {
      Log(LogLevel.INFO, string.Join(" ", messages));
    }

    public void Warn(params string[] messages)
    {
      Log(LogLevel.WARN, string.Join(" ", messages));
    }

    public void Error(params string[] messages)
    {
      Log(LogLevel.ERROR, string.Join(" ", messages));
    }

    private void Log(LogLevel level, string message)
    {
      if (level < loggingLevel)
        return;
      if (enableConsoleTrace)
        Console.WriteLine("[SFS - " + level + "] " + message);
      if (!enableEventDispatching || smartFox == null)
        return;
      smartFox.DispatchEvent(new LoggerEvent(level, new Hashtable
      {
        {
          nameof (message),
          message
        }
      }));
    }

    public void AddEventListener(LogLevel level, EventListenerDelegate listener)
    {
      smartFox?.AddEventListener(LoggerEvent.LogEventType(level), listener);
    }

    public void RemoveEventListener(LogLevel logLevel, EventListenerDelegate listener)
    {
      smartFox?.RemoveEventListener(LoggerEvent.LogEventType(logLevel), listener);
    }
  }
}





