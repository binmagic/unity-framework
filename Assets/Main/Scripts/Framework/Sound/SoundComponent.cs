//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using System;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;
using VEngine;
using Object = UnityEngine.Object;


/// <summary>
/// 声音组件。
/// </summary>
public sealed partial class SoundComponent
{
    private AudioListener m_AudioListener = null;
    private Transform m_AudioListenerTrans = null;
    private Transform m_InstanceRoot = null;

    private readonly Dictionary<string, ISoundGroup> m_SoundGroupDic = new Dictionary<string, ISoundGroup>();
    
    // Effect Name -> path 缓存工具
    private Dictionary<string, string> m_nameToPath = new Dictionary<string, string>();

    private int m_Serial;
    private readonly Dictionary<int, Asset> m_SoundsBeingLoaded = new();
    private readonly HashSet<int> m_SoundsToReleaseOnLoad = new HashSet<int>();

    // 背景音乐组
    private static string MusicGroup = "Music";
    private int _bgMusicId;
    private string _bgMusicName;

    // 音乐是否暂停
    private bool m_soundIsPause;
    // 是否静音
    private bool m_soundIsMute;
    
    /// <summary>
    /// 获取声音组数量。
    /// </summary>
    public int SoundGroupCount
    {
        get
        {
            return m_SoundGroupDic.Count;
        }
    }

    public SoundComponent()
    {
        m_Serial = 1;

        var sound = new GameObject("SoundComponent");
        m_InstanceRoot = sound.transform;

        // 初始默认添加一个AudioListener
        m_AudioListener = GameObject.FindObjectOfType<AudioListener>();
        if (m_AudioListener == null)
        {
            m_AudioListener = m_InstanceRoot.gameObject.AddComponent<AudioListener>();
        }

        m_AudioListenerTrans = m_AudioListener.gameObject.transform;

        // 一上来就初始化这个3D group，特殊处理的
        var soundGroupNew = new Sound3DGroup("3DSound");
        m_SoundGroupDic.Add("3DSound", soundGroupNew);

    }

    public void ShutDown()
    {
        StopAllSounds();
    }
    

    
    // 设置AudioListener的位置；3D声音要用
    public void SetAudioListenerPosition(float x, float y, float z)
    {
        if (m_AudioListenerTrans == null)
        {
            return;
        }
        
        m_AudioListenerTrans.position = new Vector3(x, y, z);
    }
    
    // 直接在gameObject上播放一个3D声音
    // 3D声音直接绑定到物件上，这样可以随物件的运动而运动，同时方便管理
    public int Play3DSoundAtGO(GameObject go, string name)
    {
        if (name.IsNullOrEmpty())
        {
            Log.Error("Play 3D Effect no name!!");
            return -1;
        }
        
        string soundAssetName;
        if (!m_nameToPath.TryGetValue(name, out soundAssetName))
        {
            soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
            m_nameToPath[name] = soundAssetName;
        }
        
        var soundAsset = GameEntry.Resource.LoadAssetAsync(soundAssetName, typeof(AudioClip));
        if (soundAsset != null)
        {
            int serialId = GetSerial();
            m_SoundsBeingLoaded.Add(serialId, soundAsset);
            soundAsset.completed += delegate
            {
                if (!soundAsset.isError)
                {
                    // 声音没有在释放列表 
                    if (!m_SoundsToReleaseOnLoad.Contains(serialId))
                    {
                        var soundGroup = GetSoundGroup("3DSound") as Sound3DGroup;
                        soundGroup.PlaySound(serialId, go, soundAsset);
                        if (m_soundIsMute)
                        {
                            soundGroup.MuteSound(true);
                        }
                        return;
                    }
                }
                
                // 声音释放掉
                m_SoundsBeingLoaded.Remove(serialId);
                m_SoundsToReleaseOnLoad.Remove(serialId);
                soundAsset.Release();
            };
            
            return serialId;
        }

        return -1;
    }

    public int Stop3DSoundAtGO(GameObject go)
    {
        var soundGroup = GetSoundGroup("3DSound") as Sound3DGroup;
        bool ret = soundGroup.Stop(go);
        return ret ? 1 : 0;
    }

    public void Remove3DSoundAll()
    {
        var soundGroup = GetSoundGroup("3DSound") as Sound3DGroup;
        soundGroup.RemoveAll();
    }

    /// <summary>
    /// 是否存在指定声音组。
    /// </summary>
    /// <param name="soundGroupName">声音组名称。</param>
    /// <returns>指定声音组是否存在。</returns>
    public bool HasSoundGroup(string soundGroupName)
    {
        return m_SoundGroupDic.ContainsKey(soundGroupName);
    }

    /// <summary>
    /// 设置声音组的静音。
    /// </summary>
    public void SetSoundGroupMute(string soundGroupName, bool mute)
    {
        SoundGroup soundGroup = GetSoundGroup(soundGroupName) as SoundGroup;
        soundGroup.Mute = mute;
    }

    /// <summary>
    /// 播放声音。
    /// </summary>
    /// <param name="soundAssetName">声音资源名称。</param>
    /// <param name="soundGroupName">声音组名称。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlaySound(string soundAssetName, string soundGroupName, Action<bool, int> action = null, bool loop = false, float volume = 1.0f)
    {
        PlaySoundParams playSoundParams = null;
        if (loop == true || volume <= 0.99999)
        {
            playSoundParams = new PlaySoundParams() { Loop = loop, VolumeInSoundGroup = volume };
        }
        return PlaySound(soundAssetName, soundGroupName, playSoundParams, action);
    }

    /// <summary>
    /// 播放音乐。
    /// </summary>
    /// <param name="assetPath">声音资源名称。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlayMusic(string name, bool loop = true, float volume = 1.0f)
    {
        var assetPath = string.Format("Assets/Main/Sound/Music/{0}.ogg", name);
        return PlaySound(assetPath, MusicGroup, new PlaySoundParams() { Loop = loop, VolumeInSoundGroup = volume }, null);
    }

    public float GetSoundLength(int serialId)
    {
        foreach (var group in m_SoundGroupDic)
        {
            var s = group.Value as SoundGroup;
            if (s != null)
            {
                if (s.SerialId == serialId)
                {
                    return s.Length;
                }
            }
        }

        return -1;
    }

    /// <summary>
    /// 播放音效。
    /// </summary>
    /// <param name="assetPath">声音资源名称。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlayEffect(string name, bool loop = false, float volume = 1.0f, string specifiedGroup = null)
    {
        if (name.IsNullOrEmpty())
        {
#if !FINAL_RELEASE
            //GameEntry.Lua.LuaTraceback();
            Log.Error("Play Effect no name!!");
#endif
            return -1;
        }
        
        string soundAssetName;
        if (!m_nameToPath.TryGetValue(name, out soundAssetName))
        {
            soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
            m_nameToPath[name] = soundAssetName;
        }

        // 他这个有问题，每次只能播放一个loop声音，这里暂时先特殊处理一下
        // 以后有时间还是得修改一下这个烂东西。。。
        if (loop == true)
        {
            return PlaySound(soundAssetName, "LoopEffect", new PlaySoundParams() { Loop = true, VolumeInSoundGroup = volume}, null);
        }
        
        //var soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
        var soundAsset = GameEntry.Resource.LoadAssetAsync(soundAssetName, typeof(Object));
        if (soundAsset != null)
        {
            int serialId = GetSerial();
            m_SoundsBeingLoaded.Add(serialId, soundAsset);
            soundAsset.completed += delegate
            {
                if (!soundAsset.isError)
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    if (m_SoundsToReleaseOnLoad.Contains(serialId))
                    {
                        m_SoundsToReleaseOnLoad.Remove(serialId);
                        soundAsset.Release();
                    }
                    else
                    {
                        // 如果目前声音系统禁用中，那么即将播放的音效也禁用一下。
                        var groupName = string.IsNullOrEmpty(specifiedGroup) ? "Effect" : specifiedGroup;
                        var soundGroup = GetSoundGroup(groupName) as SoundGroup;
                        //soundGroup.PlayOneShot(serialId, soundAsset, new PlaySoundParams() {VolumeInSoundGroup = 1.0f});
                        if (m_soundIsMute)
                        {
                            soundGroup.Mute = true;
                        }
                        soundGroup.PlayOneShot(serialId, soundAsset, false, volume);
                    }
                }
                else
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    m_SoundsToReleaseOnLoad.Remove(serialId);
                    soundAsset.Release();
                }
            };
            
            return serialId;
        }

        return -1;
    }

    // 播放一个3D音效
    public int Play3DEffect(string name, Vector3 pos, float volume = 1.0f)
    {
        if (name.IsNullOrEmpty())
        {
            Log.Error("Play Effect no name!!");
            return -1;
        }
        
        string soundAssetName;
        if (!m_nameToPath.TryGetValue(name, out soundAssetName))
        {
            soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
            m_nameToPath[name] = soundAssetName;
        }
        
        //var soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
        var soundAsset = GameEntry.Resource.LoadAssetAsync(soundAssetName, typeof(Object));
        if (soundAsset != null)
        {
            int serialId = GetSerial();
            m_SoundsBeingLoaded.Add(serialId, soundAsset);
            soundAsset.completed += delegate
            {
                if (!soundAsset.isError)
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    if (m_SoundsToReleaseOnLoad.Contains(serialId))
                    {
                        m_SoundsToReleaseOnLoad.Remove(serialId);
                        soundAsset.Release();
                    }
                    else
                    {
                        var soundGroup = GetSoundGroup("Effect") as SoundGroup;
                        //soundGroup.PlayOneShot(serialId, soundAsset, new PlaySoundParams() {VolumeInSoundGroup = 1.0f});
                        soundGroup.PlayClipAtPoint(serialId, soundAsset, volume, pos);
                    }
                }
                else
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    m_SoundsToReleaseOnLoad.Remove(serialId);
                    soundAsset.Release();
                }
            };
            
            return serialId;
        }

        return -1;
    }
        
    public int PlayDub(int nameId, Action<bool, int> action = null)
    {
        string name = nameId.ToString();
        return PlayDub(name, action);
    }
    
    /// <summary>
    /// 播放配音
    /// </summary>
    /// <param name="assetPath">声音资源名称。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlayDub(string name, Action<bool, int> action = null)
    {
        if (name.IsNullOrEmpty())
        {
            Debug.Log("playdub invalid name!");
            return -1;
        }
        
        string lang = GameEntry.Localization.GetLanguageName();
        var assetPath = string.Format("Assets/Main/Sound/Dub/{1}/{0}.ogg", name, lang);

        if (!GameEntry.Resource.HasAsset(assetPath))
        {
            assetPath = string.Format("Assets/Main/Sound/Dub/en/{0}.ogg", name);
        }

        return PlaySound(assetPath, "Dub", null, null, action);
    }

    public int PlayBGMusicByName(string nameStr, float volume = 1.0f, bool isLoop = true)
    {
        if(_bgMusicId > 0)
        {
            StopSound(_bgMusicId);
        }
        _bgMusicId = PlayMusic(nameStr, isLoop, volume);
        _bgMusicName = nameStr;
        return _bgMusicId;
    }

    /// <summary>
    ///     世界场景播放音效, volume由Group决定。
    /// </summary>
    /// <param name="assetPath">声音资源名称。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlayWorldScopeEffect(string name, bool loop = false)
    {
        if (name.IsNullOrEmpty())
        {
#if !FINAL_RELEASE
            //GameEntry.Lua.LuaTraceback();
            Log.Error("Play Effect no name!!");
#endif
            return -1;
        }

        string soundAssetName;
        if (!m_nameToPath.TryGetValue(name, out soundAssetName))
        {
            soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
            m_nameToPath[name] = soundAssetName;
        }

        //暂时这个函数没有Loop的需求，先不实现
        // if (loop)
        // {
        // return PlaySound(soundAssetName, "LoopEffect",
        //     new PlaySoundParams { Loop = true, VolumeInSoundGroup = volume }, null);
        // }

        //var soundAssetName = string.Format("Assets/Main/Sound/Effect/{0}.ogg", name);
        var soundAsset = GameEntry.Resource.LoadAssetAsync(soundAssetName, typeof(Object));
        if (soundAsset != null)
        {
            var serialId = GetSerial();
            m_SoundsBeingLoaded.Add(serialId, soundAsset);
            soundAsset.completed += delegate
            {
                if (!soundAsset.isError)
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    if (m_SoundsToReleaseOnLoad.Contains(serialId))
                    {
                        m_SoundsToReleaseOnLoad.Remove(serialId);
                        soundAsset.Release();
                    }
                    else
                    {
                        // 如果目前声音系统禁用中，那么即将播放的音效也禁用一下。
                        // var groupName = string.IsNullOrEmpty(specifiedGroup) ? "Effect" : specifiedGroup;
                        var soundGroup = GetSoundGroup("WorldScope") as SoundGroup;
                        //soundGroup.PlayOneShot(serialId, soundAsset, new PlaySoundParams() {VolumeInSoundGroup = 1.0f});
                        if (m_soundIsMute)
                        {
                            soundGroup.Mute = true;
                        }

                        soundGroup.PlayOneShot(serialId, soundAsset, false, soundGroup.Volume);
                    }
                }
                else
                {
                    m_SoundsBeingLoaded.Remove(serialId);
                    m_SoundsToReleaseOnLoad.Remove(serialId);
                    soundAsset.Release();
                }
            };

            return serialId;
        }

        return -1;
    }
    
    // 获取当前播放的音乐名字，防止要播放一个音乐A时，但此时正在播放音乐A，就会导致先停止再重新播放A，非常诡异。
    // FIXME:这个音乐系统写的比较烂，但是目前先这样吧。
    public string GetCurPlayMusicName()
    {
        SoundGroup soundGroup = GetSoundGroup(MusicGroup) as SoundGroup;
        if (soundGroup == null)
        {
            return "";
        }

        if (soundGroup.SerialId > 0)
        {
            return _bgMusicName;
        }

        return "";
    }
  
    public void OnUpdate(float elapseSeconds)
    {
        foreach (var i in m_SoundGroupDic)
        {
            i.Value.OnUpate();
        }
    }


    /// <summary>
    /// 停止播放声音。
    /// </summary>
    /// <param name="serialId">要停止播放声音的序列编号。</param>
    /// <returns>是否停止播放声音成功。</returns>
    public bool StopSound(int serialId)
    {
        //增在load的需要关闭的就添加到列表
        if (m_SoundsBeingLoaded.ContainsKey(serialId))
        {
            m_SoundsToReleaseOnLoad.Add(serialId);
            return true;
        }

        foreach (var group in m_SoundGroupDic)
        {
            var s = group.Value as SoundGroup;
            if (s != null)
            {
                if (s.SerialId == serialId)
                {
                    s.StopSound();
                    return true;
                }
            }
        }
    
        return false;
    }

    // 停止某一个组内的声音
    public void StopGroupSound(string soundGroupName)
    {
        SoundGroup soundGroup = GetSoundGroup(soundGroupName) as SoundGroup;
        if (soundGroup != null)
        {
            soundGroup.StopSound();
        }
        else
        {
            var t = GetSoundGroup(soundGroupName) as Sound3DGroup;
            if (t != null)
            {
                t.RemoveAll();
            }
        }
    }

    /// <summary>
    /// 停止所有已加载的声音。
    /// </summary>
    public void StopAllSounds()
    {
        foreach (var group in m_SoundGroupDic)
        {
            var s = group.Value as SoundGroup;
            if (s != null)
            {
                s.StopSound();
            }
            else
            {
                var t = group.Value as Sound3DGroup;
                if (t != null)
                {
                    t.RemoveAll();
                }
            }
        }

        foreach (var i in m_SoundsBeingLoaded)
        {
            m_SoundsToReleaseOnLoad.Add(i.Key);
        }

        _bgMusicId = 0;
        _bgMusicName = null;
        m_soundIsPause = false;
        m_soundIsMute = false;
    }



    /// <summary>
    /// 暂停播放声音。
    /// </summary>
    /// <param name="serialId">要暂停播放声音的序列编号。</param>
    public void PauseSound(int serialId)
    {
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as SoundGroup;
            if (s != null)
            {
                if (s.SerialId == serialId)
                {
                    s.PauseSound();
                }
            }
        }
    }

    /// <summary>
    /// 恢复播放声音。
    /// </summary>
    /// <param name="serialId">要恢复播放声音的序列编号。</param>
    public void ResumeSound(int serialId)
    {
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as SoundGroup;
            if (s != null)
            {
                if (s.SerialId == serialId)
                {
                    s.ResumeSound();
                }
            }
        }
    }

    public bool IsAllSoundPause()
    {
        return m_soundIsPause;
    }
    
    public void PauseAllSound()
    {
        m_soundIsPause = true;
        
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as ISoundGroup;
            if (s != null)
            {
                s.PauseSound();
            }
        }
    }
    
    public void ResumeAllSound()
    {
        m_soundIsPause = false;
        
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as ISoundGroup;
            if (s != null)
            {
                s.ResumeSound();
            }
        }
    }
    
    public void MuteAllSounds(bool mute)
    {
        m_soundIsMute = mute;
        
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as ISoundGroup;
            if (s != null)
            {
                s.MuteSound(mute);
            }
        }
    }
    
    public bool IsAllSoundMute()
    {
        return m_soundIsMute;
    }

    private int GetSerial()
    {
        if (++m_Serial == int.MaxValue)
        {
            m_Serial = 1;
        }
        return m_Serial;
    }

    /// <summary>
    /// 播放声音。
    /// </summary>
    /// <param name="soundAssetName">声音资源名称。</param>
    /// <param name="soundGroupName">声音组名称。</param>
    /// <param name="priority">加载声音资源的优先级。</param>
    /// <param name="playSoundParams">播放声音参数。</param>
    /// <param name="userData">用户自定义数据。</param>
    /// <returns>声音的序列编号。</returns>
    public int PlaySound(string soundAssetName, string soundGroupName, PlaySoundParams playSoundParams, object userData, Action<bool, int> action = null)
    {
        // if (playSoundParams == null)
        // {
        //     playSoundParams = new PlaySoundParams();
        // }

        int serialId = GetSerial();

        PlaySoundErrorCode? errorCode = null;
        string errorMessage = null;
        SoundGroup soundGroup = GetSoundGroup(soundGroupName) as SoundGroup;

        if (soundGroup == null)
        {
            Log.Error("Sound group '{0}' is not exist.", soundGroupName);
            errorCode = PlaySoundErrorCode.SoundGroupNotExist;
            errorMessage = string.Format("Sound group '{0}' is not exist.", soundGroupName);
            return -1;
        }

        if (errorCode.HasValue)
        {
            throw new GameFrameworkException(errorMessage);
        }

        var req = GameEntry.Resource.LoadAssetAsync(soundAssetName, typeof(Object));
        if (req != null)
        {
            m_SoundsBeingLoaded.Add(serialId, req);

            req.completed += delegate
            {
                if (!req.isError)
                {
                    LoadSoundSuccess(soundAssetName, req, action,
                        new PlaySoundInfo(serialId, soundGroup, playSoundParams, userData));
                }
                else
                {
                    LoadSoundFailure(soundAssetName, req,
                        new PlaySoundInfo(serialId, soundGroup, playSoundParams, userData));
                }
            };
        }
 
        return serialId;
    }

    /// <summary>
    /// 获得声音组。
    /// </summary>
    private ISoundGroup GetSoundGroup(string soundGroupName, bool soundGroupMute = false, float volume = 1)
    {
        ISoundGroup soundGroup = null;
        if (m_SoundGroupDic.TryGetValue(soundGroupName, out soundGroup))
        {
            return soundGroup;
        }

        var soundGroupNew = new SoundGroup(soundGroupName) { Mute = soundGroupMute, Volume = volume };

        soundGroupNew.AudioSourceTransform.SetParent(m_InstanceRoot);
        m_SoundGroupDic.Add(soundGroupName, soundGroupNew);

        return soundGroupNew;
    }

    private bool LoadSoundSuccess(string soundAssetName, Asset soundAsset, Action<bool, int> action, object userData)
    {
        int soundId = -1;
        PlaySoundInfo playSoundInfo = (PlaySoundInfo)userData;
        if (playSoundInfo != null)
        {
            soundId = playSoundInfo.SerialId;
            m_SoundsBeingLoaded.Remove(playSoundInfo.SerialId);

            if (!m_SoundsToReleaseOnLoad.Contains(playSoundInfo.SerialId))
            {
                if (playSoundInfo.SoundGroup != null)
                {
                    bool loop = false;
                    float volume = 1f;
                    var playSoundParams = playSoundInfo.PlaySoundParams;
                    if (playSoundParams != null)
                    {
                        loop = playSoundParams.Loop;
                        volume = playSoundParams.VolumeInSoundGroup;
                    }
                    
                    playSoundInfo.SoundGroup.PlaySound(playSoundInfo.SerialId, soundAsset, loop, volume);

                    // 如果目前声音系统禁用中，那么即将播放的音效也禁用一下。
                    if (m_soundIsMute)
                    {
                        playSoundInfo.SoundGroup.Mute = true;
                    }

                    if (m_soundIsPause)
                    {
                        playSoundInfo.SoundGroup.PauseSound();
                    }

                    if (action != null)
                    {
                        action(true, soundId);
                    }

                    return true;
                }
                else
                {
                    soundAsset.Release();
                    Log.Error("Sound Group Can not Find!");
                }
            }
            else
            {
                Log.Debug("Release sound '{0}' on loading success.", soundAssetName);
                m_SoundsToReleaseOnLoad.Remove(playSoundInfo.SerialId);
                soundAsset.Release();
            }
        }
        else
        {
            Debug.LogError("Play sound info is invalid.");
        }

        if (action != null)
        {
            action(false, soundId);
        }
        return false;
    }

    private void LoadSoundFailure(string soundAssetName, Asset soundAsset, object userData)
    {
        PlaySoundInfo playSoundInfo = (PlaySoundInfo)userData;
        if (playSoundInfo == null)
        {
            Log.Error("Play sound info is invalid.");
        }

        m_SoundsBeingLoaded.Remove(playSoundInfo.SerialId);
        m_SoundsToReleaseOnLoad.Remove(playSoundInfo.SerialId);
        string appendErrorMessage = string.Format("Load sound failure, asset name '{0}', status '{1}', error message '{2}'.", soundAssetName, soundAsset.error);
        Log.Error(appendErrorMessage);
        soundAsset.Release();
    }
    
    /// <summary>
    /// 改变声音大小。
    /// </summary>
    public void ChangeVolume(string soundGroupName, float toVolume, float time)
    {
        var group = GetSoundGroup(soundGroupName) as SoundGroup;
        if( group != null)
        {
            group.ChangeVolume(toVolume, time);
        }
    }
    
    // 改变声音大小，除去某个分组
    public void ChangeVolumeExclude(string soundGroupName, float time, float toVolume = -1)
    {
        foreach (var g in m_SoundGroupDic)
        {
            if (soundGroupName == g.Key)
            {
                g.Value.ChangeVolume(toVolume, time);
            }
        }
    }

    // 获取某个声音的长度
    public float GetClipLength(int serialId)
    {
        foreach (var soundGroup in m_SoundGroupDic)
        {
            var s = soundGroup.Value as SoundGroup;
            if (s != null)
            {
                if (s.SerialId == serialId)
                {
                    return s.m_curLength;
                }
            }
        }

        return 0;
    }
}





