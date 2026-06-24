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





