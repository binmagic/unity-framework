using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using GameFramework;
using System;

public class PlayTimeLine : MonoBehaviour
{
    [SerializeField]
    public TimelineAsset timelineAsset;
    [SerializeField]
    public PlayableDirector playeAble;

    //Start is called before the first frame update
    void Start()
    {
        playeAble.playableAsset = timelineAsset;
        playeAble.time = 5.283333f;
        playeAble.Play();

     
    }
    void PlayTimelineStopHandle(PlayableDirector director)
    {
  
    }

    //// Update is called once per frame
    //void Update()
    //{

    //}
}





