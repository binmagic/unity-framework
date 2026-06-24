using System;
using System.Collections.Generic;
using UnityEngine;

//
// 定时器
//
public interface ITimer
{
    bool isCompleted { get; }
    bool isCancelled { get; }
    bool isDone { get; }
}

//
// 定时器管理，时间管理，时间类工具函数
//
public class TimerComponent : IGameController
{
    private long m_ServerDeltaTime;
    private int m_TimeZone;
    private int m_FrameCount;
    private bool m_IsNight;
    private bool _2Hours = true;
    private int _serverOffset = 0;

    public TimerComponent()
    {
    }
    
    /// <summary>
    /// 基准时间
    /// </summary>
    private DateTime _orignTime = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    
    public long Tomorrow
    {
        get;
        set;
    }

    public void Shutdown()
    {
        CancelAllTimers();
    }

    public void OnUpdate(float elapseSeconds)
    {
        UpdateAllTimers();
    }
    
    // 将时间调整到相对UTC的0点时区
    public long ChangeTime(long t)
    {
        //开关关闭的话，由前端去计算-2时区，一般情况下不会打开
        return t - _serverOffset;
    }

    public void UpdateServerMilliseconds(long ms)
    {
        m_ServerDeltaTime = ms - GetLocalMilliseconds();
    }

    public long GetLocalMilliseconds()
    {
        return (long)(DateTime.UtcNow.Subtract(_orignTime)).TotalMilliseconds;
    }

    public long GetLocalSeconds()
    {
        return (long)(DateTime.UtcNow.Subtract(_orignTime)).TotalSeconds;
    }

    public long GetServerTime()
    {
        return m_ServerDeltaTime + GetLocalMilliseconds();
    }

    public int GetServerTimeSeconds()
    {
        return (int)(GetServerTime() / 1000);
    }
    
    // copy from aow to "00:00:00"
    public string MillisecondToSecondString(long mstime, string separator)
    {
        mstime /= 1000;
        return SecondsToSecondString(mstime, separator);
    }

    public string SecondsToSecondString(long second, string separator)
    {
        long tmpTime = second < 0 ? 0 : second;
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        
        long hours = tmpTime / 3600;
        if (hours < 10)
        {
            sb.Append("0");
        }
        sb.Append(hours);
        sb.Append(separator);

        long tmp = tmpTime % 3600;
        long minutes = tmp / 60;
        if (minutes < 10)
        {
            sb.Append("0");
        }
        sb.Append(minutes);
        sb.Append(separator);
        
        long seconds = tmp % 60;
        if (seconds < 10)
        {
            sb.Append("0");
        }
        sb.Append(seconds);
        
        return sb.ToString();
    }

    /// <summary>
    /// 把毫秒秒数转成1d 00:00:00格式
    /// </summary>
    /// <returns>The sectoa.</returns>
    /// <param name="milliSecond">milliSecond</param>
    public string MilliSecondToFmtString(long milliSecond)
    {
        int secs = (int)(milliSecond / 1000);
        return SecondToFmtString(secs);
    }

    /// <summary>
    /// 把秒数转成1d 00:00:00格式
    /// </summary>
    /// <returns>The sectoa.</returns>
    /// <param name="secs">Secs.</param>
    public string SecondToFmtString(long secs)
    {
        string temp;
        if (secs > 24 * 3600)
        {
            temp = string.Format("{0}d {1:00}:{2:00}:{3:00}", secs / (24 * 3600), secs / 3600 % 24, secs / 60 % 60, secs % 60);
            return temp;
        }
        temp = string.Format("{0:00}:{1:00}:{2:00}", secs / 3600, secs / 60 % 60, secs % 60);
        return temp;
    }

    // 获取时间修正，这个函数相当于没有用，因为目前m_TimeZone ==0
    public long RefixTimebyZone(long time)
    {
        if (time <= 0) return 0;
        return time + m_TimeZone * 3600;
    }
    // 经过多长时间
    public string PassTimeSecondString(long passTime, bool isMstime = true)
    {
        if (isMstime)
        {
            passTime = passTime / 1000;
        }
        if (passTime > 3600 * 24)
        {
            int day = (int)(passTime / (3600 * 24));
            return GameEntry.Localization.GetString("390506", day);
        }
        if (passTime > 3600)
        {
            int hour = (int)(passTime / 3600);
            return GameEntry.Localization.GetString("390505", hour);
        }
        if (passTime > 60)
        {
            int min = (int)(passTime / 60);
            return GameEntry.Localization.GetString("390504", min);
        }
        return GameEntry.Localization.GetString("100355");
    }

    
    public DateTime GetDateTime(long timeStamp)
    {
        DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc);
        //这个地方*10000 是要变成ticks
        long lTime = ((long)timeStamp * 10000L);
        TimeSpan toNow = new TimeSpan(lTime);
        //把时区减下去
        DateTime targetDt = dtDateTime.Add(toNow);
        return targetDt;
    }
    //时间戳转时间（简化）
    public string TimeStampToTimeSimple(long timestamp, string format = "T")
    {
        DateTime dt = GetDateTime(timestamp);
        return dt.ToString(format);
    }
    //时间戳转时间（日期）
    public string TimeStampToTimeDate(long timestamp, string format = "yyyy-MM-dd")
    {
        DateTime dt = GetDateTime(timestamp);
        return dt.ToString(format);
    }

    //时间戳转月日
    public string TimeStampToTimeDateMd(long timestamp, string format = "MM-dd")
    {
        DateTime dt = GetDateTime(timestamp);
        return dt.ToString(format);
    }

    // 时间戳转时间
    public string TimeStampToTime(long timestamp, string format = "yyyy-MM-dd HH:mm:ss")
    {
        DateTime dt = GetDateTime(timestamp);
        return dt.ToString(format);
    }
    
    /// <summary>
    /// UTC 本地时间，这个是用时间戳
    /// </summary>
    public string GetUniversalTime(long timeStamp, string format = "yyyy-MM-dd HH:mm:ss")
    {
        timeStamp = ChangeTime(timeStamp);
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        //这个地方*10000 是要变成ticks
        long lTime = ((long)timeStamp * 10000L);
        TimeSpan toNow = new TimeSpan(lTime); ;
        DateTime targetDt = dtStart.Add(toNow);
        return targetDt.ToString(format);
    }

    /// <summary>
    /// UTC 本地时间，这个是用聊天专用时间戳
    /// 聊天红包界面不能用这个
    /// 邮件聊天也不用这个，邮件聊天算邮件
    /// </summary>
    public string GetUniversalChatTime(long timeStamp, string format = "yyyy-MM-dd HH:mm:ss")
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        //这个地方*10000 是要变成ticks
        long lTime = ((long)timeStamp * 10000L);
        TimeSpan toNow = new TimeSpan(lTime); ;
        DateTime targetDt = dtStart.Add(toNow);
        return targetDt.ToString(format);
    }


    // 返回当前服务器时间是周几
    // [1-7]
    public int GetServerWeekDay()
    {
        long timeTmp = GetServerTime();
        DateTime time = GetDateTime(timeTmp);
        return WeekDay(time);
    }

    public int WeekDay(DateTime time)
    {
        // 系统周几是0-6，这里我们做一个转换即可。
        // 我们是1-7
        int wd = (int)time.DayOfWeek;
        if (wd == 0)
        {
            wd = 7;
        }
        return wd;
    }

    // 返回当前时间是周几
    // [1-7]
    public int GetWeekDay(long milliSecond)
    {
        DateTime time = new DateTime(milliSecond);
        return WeekDay(time);
    }
    
    //获取到第二日凌晨的剩余时间 返回秒数
    public int GetResSecondsTo24()
    {
        return 86400 - GetServerTimeSeconds() % 86400;
    }

    
    
    
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    #region 定时器实现

    private List<Timer> timers = new List<Timer>(64);
    private List<Timer> timersToAdd = new List<Timer>(64);

    class Timer : ITimer
    {
        public bool isCompleted { get; private set; }
        public bool isCancelled { get; private set; }

        public bool isDone
        {
            get { return isCompleted || isCancelled; }
        }

        // 取消定时器，此时OnComplete回调不会执行
        public void Cancel()
        {
            if (isDone)
            {
                return;
            }

            isCancelled = true;
        }

        private readonly Action _onComplete;
        private float repeatSec;
        private float finishTime;

        public Timer(float delaySec, float repeatSec, Action onComplete)
        {
            _onComplete = onComplete;
            this.repeatSec = repeatSec;
            finishTime = GetNowTime() + delaySec;
        }

        private float GetNowTime()
        {
            return Time.time;
        }

        public void Update()
        {
            if (isDone)
            {
                return;
            }

            if (GetNowTime() >= finishTime)
            {
                if (_onComplete != null)
                {
                    _onComplete();
                }

                if (repeatSec >= 0)
                {
                    finishTime = GetNowTime() + repeatSec;
                }
                else
                {
                    isCompleted = true;
                }
            }
        }
    }

    public ITimer RegisterTimer(float delaySec, Action onComplete)
    {
        var timer = new Timer(delaySec, -1, onComplete);
        timersToAdd.Add(timer);
        return timer;
    }

    public ITimer RegisterTimerRepeat(float delaySec, float repeatSec, Action onComplete)
    {
        var timer = new Timer(delaySec, repeatSec, onComplete);
        timersToAdd.Add(timer);
        return timer;
    }

    public void CancelTimer(ITimer timer)
    {
        if (timer != null)
        {
            ((Timer)timer).Cancel();
        }
    }

    public void CancelAllTimers()
    {
        foreach (Timer timer in timers)
        {
            timer.Cancel();
        }

        timers.Clear();
        timersToAdd.Clear();
    }

    private void UpdateAllTimers()
    {
        if (timersToAdd.Count > 0)
        {
            timers.AddRange(timersToAdd);
            timersToAdd.Clear();
        }

        foreach (Timer timer in timers)
        {
            timer.Update();
        }

        //timers.RemoveAll(t => t.isDone);
        for (int i = timers.Count - 1; i >= 0; --i)
        {
            if (timers[i].isDone)
            {
                timers.RemoveAt(i);
            }
        }
    }

    #endregion
}





