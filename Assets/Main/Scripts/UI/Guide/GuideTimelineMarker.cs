/**
 * [INPUT]: 依赖 UnityEngine.Timeline/Playables 的信号通知机制,依赖 GameEntry.Event 广播 EventId.GuideTimelineMarker
 * [OUTPUT]: 对外提供 GuideTimelineMarker 组件(接收 Timeline 信号并转成引导事件、支持标记回退)与 IsContinue 拦截回调
 * [POS]: Guide 模块中 Timeline 与引导逻辑的桥接件,把演出时间轴上的信号点转换为业务可订阅的引导事件,控制引导过场的暂停/回放
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using GameFramework;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class GuideTimelineMarker : MonoBehaviour, INotificationReceiver
{
    public Func<bool> IsContinue;
    private double _markerTime = 0;

    enum ShowMarkType
    {
        Zero = 0,
        One = 1,
        Start = 998,
        End = 999,
    }

    private void Awake()
    {
        _markerTime = 0;
    }

    public void OnNotify(Playable origin, INotification notification, object context)
    {
        SignalEmitter emitter = (SignalEmitter) notification;
        string signalName = emitter.asset.name;
        if (signalName.Equals("GuideMarkerEnd"))
        {
            GameEntry.Event?.Fire(EventId.GuideTimelineMarker, (int)ShowMarkType.End);
        }else if (signalName.Equals("GuideMarkerStart"))
        {
            GameEntry.Event?.Fire(EventId.GuideTimelineMarker, (int)ShowMarkType.Start);
        }
        else if (signalName.Contains("GuideMarker"))
        {
            var markIndex = signalName.Replace("GuideMarker", "").ToInt();
            GameEntry.Event?.Fire(EventId.GuideTimelineMarker, markIndex);
        }

        if (IsContinue != null)
        {
            if (IsContinue())
            {
                return;
            }
        }

        Log.Debug("[Guide] OnNotify " + signalName);
        PlayableDirector director = (PlayableDirector) origin.GetGraph().GetResolver();
        if (signalName.Equals("GuideRewindSignal"))
        {
            TimelineAsset ta = emitter.parent.timelineAsset;
            if (ta != null)
            {
                director.Pause();
                director.time = _markerTime;
                director.Play();
            }
        }
        else if (signalName.Equals("GuideRewindMarker"))
        {
            _markerTime = director.time;
        }
    }
}





