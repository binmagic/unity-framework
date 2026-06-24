using System;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GPUSkinningAnimator : MonoBehaviour
{
    [HideInInspector]
    [SerializeField]
    private GPUSkinningAnimation anim = null;

    [HideInInspector]
    [SerializeField]
    private int defaultPlayingClipIndex = 0;

    public static readonly int PropertyID_TextureSize = Shader.PropertyToID("_GPUSKin_TextureSize");
    public static readonly int PropertyID_ClipParams = Shader.PropertyToID("_GPUSKin_ClipParams");
    public static readonly int PropertyID_Matrix = Shader.PropertyToID("_GPUSKin_Matrix");
    public static readonly int PropertyID_GPUSkin = Shader.PropertyToID("_GPUSkin");
    
    private MeshRenderer[] mrArr = null;
    private float time = 0;
    private int lastPlayingFrameIndex = -1;
    private GPUSkinningClip lastPlayingClip = null;
    private GPUSkinningClip playingClip = null;
    private MaterialPropertyBlock mpb = null;
    private Queue<string> statesQueued = new Queue<string>();
    
    private bool visible = true;
    
    public Action<string> PlayEndCallBack;
    
    public bool Visible
    {
        get { return Application.isPlaying ? visible : true; }
        set { visible = value; }
    }
    
    private bool isPlaying = false;

    public bool IsPlaying
    {
        get { return isPlaying; }
    }
    
    public string PlayingClipName
    {
        get { return playingClip == null ? null : playingClip.name; }
    }

    public Vector3 Position
    {
        get { return transform.position; }
    }

    public Vector3 LocalPosition
    {
        get { return transform.localPosition; }
    }

    public GPUSkinningWrapMode WrapMode
    {
        get { return playingClip == null ? GPUSkinningWrapMode.Once : playingClip.wrapMode; }
    }

    public bool IsTimeAtTheEndOfLoop
    {
        get
        {
            if (playingClip == null)
            {
                return false;
            }
            else
            {
                return GetFrameIndex() == ((int)(playingClip.length * playingClip.fps) - 1);
            }
        }
    }

    public float NormalizedTime
    {
        get
        {
            if (playingClip == null)
            {
                return 0;
            }
            else
            {
                return (float)GetFrameIndex() / (float)((int)(playingClip.length * playingClip.fps) - 1);
            }
        }
        set
        {
            if (playingClip != null)
            {
                float v = Mathf.Clamp01(value);
                this.time = v * playingClip.length;
            }
        }
    }
 
 
    public void Init()
    {
        if (anim != null)
        {
            mrArr = GetComponentsInChildren<MeshRenderer>();
            mpb = new MaterialPropertyBlock();
        
            if (anim.clips != null && anim.clips.Length > 0)
            {
                Play(anim.clips[Mathf.Clamp(defaultPlayingClipIndex, 0, anim.clips.Length)].name);
            }
        }
    }
    
    
    public void Play(string clipName, float normalizedTime = 0.0f)
    {
        GPUSkinningClip[] clips = anim.clips;
        int numClips = clips == null ? 0 : clips.Length;
        for (int i = 0; i < numClips; ++i)
        {
            if (clips[i].name == clipName)
            {
                if (playingClip != clips[i] ||
                    (playingClip != null && playingClip.wrapMode == GPUSkinningWrapMode.Once && IsTimeAtTheEndOfLoop) ||
                    (playingClip != null && !isPlaying))
                {
                    SetNewPlayingClip(clips[i], normalizedTime);
                }

                return;
            }
        }
    }

    public void PlayQueued(string clipName)
    {
        statesQueued.Enqueue(clipName);
    }

    public void Stop()
    {
        isPlaying = false;
    }

    public void Resume()
    {
        if (playingClip != null)
        {
            isPlaying = true;
        }
    }

    public float GetClipLength(string name)
    {
        GPUSkinningClip[] clips = anim.clips;
        int numClips = clips == null ? 0 : clips.Length;
        for (int i = 0; i < numClips; ++i)
        {
            if (clips[i].name == name)
            {
                return clips[i].length;
            }
        }

        return 0;
    }

    public bool HasClip(string name)
    {
        GPUSkinningClip[] clips = anim.clips;
        int numClips = clips == null ? 0 : clips.Length;
        for (int i = 0; i < numClips; ++i)
        {
            if (clips[i].name == name)
            {
                return true;
            }
        }

        return false;
    }

#if UNITY_EDITOR
    public void DeletePlayer()
    {
    }

    public void Update_Editor(float deltaTime)
    {
        if (!Application.isPlaying)
        {
            if (!isPlaying || playingClip == null)
            {
                return;
            }

            // 更新动画播放时间
            time += deltaTime;
            if (playingClip.wrapMode == GPUSkinningWrapMode.Once)
            {
                if (time > playingClip.length)
                {
                    time = playingClip.length;
                }
            }

            // 更新帧索引到材质
            int frameIndex = GetFrameIndex();
            if (lastPlayingClip != playingClip || lastPlayingFrameIndex != frameIndex)
            {
                lastPlayingClip = playingClip;
                lastPlayingFrameIndex = frameIndex;

                mpb.SetVector(PropertyID_ClipParams, new Vector4(playingClip.pixelSegmentation, frameIndex, 0, 0));
                for (int i = 0; i < mrArr.Length; i++)
                {
                    mrArr[i].SetPropertyBlock(mpb);
                }
            }
        }
    }

    private void OnValidate()
    {
        /*
        if (!Application.isPlaying)
        {
            Init();
            Update_Editor(0);
        }
        */
    }
#endif

    private void Update_Game(float deltaTime)
    {
        if (!isPlaying || playingClip == null)
        {
            return;
        }

        // 更新动画播放时间
        time += deltaTime;
        if (playingClip.wrapMode == GPUSkinningWrapMode.Once && time > playingClip.length)
        {
            time = playingClip.length;
            if (PlayEndCallBack != null)
            {
                PlayEndCallBack(PlayingClipName);
            }
        }

        if (statesQueued.Count > 0 && time >= playingClip.length)
        {
            time = 0;
            Play(statesQueued.Dequeue());
        }

        // 更新帧索引到材质
        if (visible)
        {
            int frameIndex = GetFrameIndex();
            if (lastPlayingClip != playingClip || lastPlayingFrameIndex != frameIndex)
            {
                lastPlayingClip = playingClip;
                lastPlayingFrameIndex = frameIndex;
                if (mpb == null)
                {
                    mpb = new MaterialPropertyBlock();

                }
                mpb.SetVector(PropertyID_ClipParams, new Vector4(playingClip.pixelSegmentation, frameIndex, 0, 0));
                for (int i = 0; i < mrArr.Length; i++)
                {
                    mrArr[i].SetPropertyBlock(mpb);
                }
            }
        }
    }
    
    private void SetNewPlayingClip(GPUSkinningClip clip, float normalizedTime)
    {
        isPlaying = true;
        playingClip = clip;
        time = normalizedTime;
    }
    
    private int GetFrameIndex()
    {
        if (playingClip.length == time)
        {
            return (int)(playingClip.length * playingClip.fps) - 1;
        }
        else
        {
            return (int)(time * playingClip.fps) % (int)(playingClip.length * playingClip.fps);
        }
    }

    private void Awake()
    {
        Init();
#if UNITY_EDITOR
        Update_Editor(0); 
#endif
    }

    private void Update()
    {
        
#if UNITY_EDITOR
            if(Application.isPlaying)
            {
                Update_Game(Time.deltaTime);
            }
            else
            {
                Update_Editor(0);
            }
#else
            Update_Game(Time.deltaTime);
#endif
    }

    private void OnDestroy()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            Resources.UnloadUnusedAssets();
            UnityEditor.EditorUtility.UnloadUnusedAssetsImmediate();
        }
#endif
        
        anim = null;
    }
}





