/**
 * [INPUT]: 依赖 UnityEngine.Timeline 的 TimelineAsset 与 UnityEngine.Playables 的 PlayableDirector，引入 GameFramework 命名空间
 * [OUTPUT]: 对外提供 PlayTimeLine 组件，启动时把指定 TimelineAsset 绑到 Director 并从固定时间点播放
 * [POS]: Common/Component 的 Timeline 播放挂件，作为 Playable 时间轴动画的最小启动器，预留了播放结束回调钩子
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

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





