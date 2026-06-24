//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using System;
using System.Collections.Generic;
using GameFramework;
using GameKit.Base;
using UnityEngine;
using VEngine;

public partial class SoundComponent
{
    interface ISoundGroup
    {
        void OnUpate();
        void ChangeVolume(float to, float time);

        void PauseSound();
        void ResumeSound();
        void MuteSound(bool mute);
    }
    
    [Serializable]
    public class SoundGroup : ISoundGroup
    {
        private SoundGroup(){}
        public SoundGroup(string name)
        {
            m_Name = name;
            m_AudioSource = new GameObject("SoundGroup_" + name).AddComponent<AudioSource>();
            m_AudioSource.playOnAwake = false;
            m_AudioSource.rolloffMode = AudioRolloffMode.Custom;
            m_AudioSourceTransform = m_AudioSource.transform;  
        }

        private int m_serialId = 0;
        private string m_Name = null;
        private AudioSource m_AudioSource = null;
        private Transform m_AudioSourceTransform = null;
        private Asset m_SoundAsset;
        public float m_curLength;
        private float m_curVolume;

        //改变音量
        private float _fromVolume = 0;
        private float _toVolume = 0;
        private float _time = 0;
        private float _curTime = 0;
        private bool _changeVolume = false;

        private struct OneShotSound
        {
            public Asset soundAsset;
            public float playTime;
            public float clipLength;
        }

        private List<OneShotSound> m_OneShots = new List<OneShotSound>();
        
        public int SerialId
        {
            get { return m_serialId;}
        }
        
        /// <summary>
        /// 获取声音组名称。
        /// </summary>
        public string Name
        {
            get { return m_Name;}
            set { m_Name = value;}
        }

        public Transform AudioSourceTransform
        {
            get
            {
                return m_AudioSourceTransform;
            }
        }

        /// <summary>
        /// 获取或设置声音组静音。
        /// </summary>
        public bool Mute
        {
            get
            {
                return m_AudioSource.mute;
            }
            set
            {
                m_AudioSource.mute = value;
            }
        }

        /// <summary>
        /// 获取或设置声音组音量。
        /// </summary>
        public float Volume
        {
            get
            {
                return m_AudioSource.volume;
            }
            set
            {
                m_AudioSource.volume = value;
            }
        }

        /// <summary>
        /// 获取或设置是否循环播放。
        /// </summary>
        public bool Loop
        {
            get
            {
                return m_AudioSource.loop;
            }
            set
            {
                m_AudioSource.loop = value;
            }
        }

        public float Length
        {
            get { return m_AudioSource.clip?m_AudioSource.clip.length:0; }
        }   
        
        //打断当前播放音效，根据参数从新播放音效  
        public void PlaySound(int serialId, Asset soundAsset, bool loop = false, float volume = 1f)
        {
            if (this.m_SoundAsset != null)
            {
                this.m_SoundAsset.Release();
            }
            if (m_OneShots.Count > 0)
            {
                foreach (var i in m_OneShots)
                {
                    i.soundAsset.Release();
                }
                m_OneShots.Clear();
            }
            
            this.m_SoundAsset = soundAsset;
            
            var sound = soundAsset.asset as AudioClip;
            if (sound == null)
            {
                Log.Error("Audio Clip is Null");
                return;
            }

            if (m_AudioSource == null)
            {
                Log.Error("Audio Source is Null");
                return;
            }

            m_serialId = serialId;
            Loop = loop;
            Volume = volume;
            m_AudioSource.clip = sound;   
            m_AudioSource.Play();
            m_curLength = m_AudioSource.clip.length;
            m_curVolume = m_AudioSource.volume;
        }

        //播放一个音效，不影响当前播放的音效
        public void PlayOneShot(int serialId, Asset soundAsset, bool loop, float volume)
        {
            var clip = soundAsset.asset as AudioClip;
            if (clip == null)
            {
                Log.Error($"Audio Clip is error: {soundAsset.pathOrURL}");
                return ;
            }
            
#if UNITY_EDITOR
            Log.Debug($"--------PlayOneShot: {m_Name} {soundAsset.pathOrURL}");
#endif
            
            m_OneShots.Add(new OneShotSound(){ soundAsset = soundAsset, clipLength = (clip != null ? clip.length : 0), playTime = 0});
            
            m_serialId = serialId;
            Loop = loop;
            Volume = volume;
            m_AudioSource.PlayOneShot(clip);
            m_curLength = clip.length;
            m_curVolume = volume;
        }
        
        // 在某个点播放一个音效
        public void PlayClipAtPoint(int serialId, Asset soundAsset, float volume, Vector3 pos)
        {
            var clip = soundAsset.asset as AudioClip;
            if (clip == null)
            {
                Log.Error($"找不到这个音乐: {soundAsset.pathOrURL}");
                return ;
            }
            
            m_OneShots.Add(new OneShotSound(){ soundAsset = soundAsset, clipLength = (clip != null ? clip.length : 0), playTime = 0});
            
            m_serialId = serialId;
            Loop = false;
            Volume = volume;
            AudioSource.PlayClipAtPoint(clip, pos, volume);
            m_curLength = clip.length;
            m_curVolume = volume;
        }
        
        //循环播放一个音乐。
        // public void PlaySoundForLoop(int serialId, object soundAsset)
        // {
        //     m_serialId = serialId;
        //     var sound = soundAsset as AudioClip;
        //     if (sound == null)
        //     {
        //         Log.Error("Audio Clip is Null");
        //         return;
        //     }
        //
        //     if (m_AudioSource == null)
        //     {
        //         Log.Error("Audio Source is Null");
        //         return;
        //     }
        //
        //     Loop = true;
        //     m_AudioSource.clip = sound;   
        //     m_AudioSource.Play();
        // }
        
        /// <summary>
        /// 停止播放声音。
        /// <returns>是否停止播放声音成功。</returns>
        public bool StopSound()
        {
            m_serialId = 0;
            m_curLength = 0;
            
            if (m_AudioSource != null)
            {
                m_AudioSource.Stop();
                m_AudioSource.clip = null;
            }

            if (m_SoundAsset != null)
            {
                m_SoundAsset.Release();
                m_SoundAsset = null;
            }

            if (m_OneShots.Count > 0)
            {
                foreach (var i in m_OneShots)
                {
                    i.soundAsset.Release();
                }
                m_OneShots.Clear();
            }
            
            return false;
        }
        
        /// <summary>
        /// 暂停播放声音。
        /// </summary>
        public void PauseSound()
        {
            if (m_AudioSource != null)
            {
                m_AudioSource.Pause();
            }
        }
        /// <summary>
        /// 恢复播放声音。
        /// </summary>
        public void ResumeSound()
        {
            if (m_AudioSource != null)
            {
                m_AudioSource.UnPause();
            } 
        }

        public void MuteSound(bool mute)
        {
            if (m_AudioSource != null)
            {
                m_AudioSource.mute = mute;
            } 
        }

        public void OnUpate()
        {
            for (int i = m_OneShots.Count - 1; i >= 0; i--)
            {
                var o = m_OneShots[i];
                if (o.playTime < o.clipLength)
                {
                    o.playTime += Time.unscaledDeltaTime;
                    m_OneShots[i] = o;
                }
                else
                {
                    o.soundAsset.Release();
                    m_OneShots.RemoveAt(i);
                }
            }

            if (_changeVolume)
            {
                _curTime += Time.unscaledDeltaTime;
                if (_curTime > _time)
                {
                    _changeVolume = false;
                    Volume = _toVolume;
                }
                else
                {
                    Volume = Mathf.Lerp(_fromVolume, _toVolume, _curTime / _time);
                }
            }
        }
        
        public void ChangeVolume(float to, float time)
        {
            if (time > 0)
            {
                _fromVolume = Volume;
                _toVolume = to;
                _time = time;
                _curTime = 0;
                _changeVolume = true;
            }
            else
            {
                Volume = to;
            }
        }
    }

    
    [Serializable]
    public class Sound3DGroup : ISoundGroup
    {
        private struct OneSound
        {
            public float volume;
            public Asset soundAsset;
            public AudioSource source;
        }
        
        //改变音量
        private float _toVolume = 0;
        private float _time = 0;
        private float _curTime = 0;
        private bool _changeVolume = false;
        
        private string m_Name;
        private Dictionary<GameObject, OneSound> m_all3DSource = new Dictionary<GameObject, OneSound>();
        private Sound3DGroup(){}
        public Sound3DGroup(string name)
        {
            m_Name = name;
        }

        public bool PlaySound(int serialId, GameObject go, Asset soundAsset)
        {
            var sound = soundAsset.asset as AudioClip;
            if (sound == null)
            {
                Log.Error("Audio Clip is Null");
                return false;
            }

            if (go.transform == null)
            {
                return false;
            }

            // 已经有了
            if (m_all3DSource.TryGetValue(go, out OneSound oneSound))
            {
                var source = oneSound.source;
                source.Stop();
                oneSound.soundAsset.Release();
                
                source.clip = (AudioClip) soundAsset.asset;
                oneSound.soundAsset = soundAsset;
                source.Play();
                
                m_all3DSource[go] = oneSound;
                return true;
            }

            var audioSource = go.transform.GetOrAddComponent<AudioSource>();
            audioSource.spatialBlend = 1;

            // 线性衰减即可
            audioSource.rolloffMode = AudioRolloffMode.Linear;
            audioSource.minDistance = 1.5f;
            audioSource.maxDistance = 15;
            // 不想有左右环绕
            audioSource.spread = 180;

            audioSource.playOnAwake = false;
            audioSource.clip = (AudioClip) soundAsset.asset;
            audioSource.loop = true;
            audioSource.enabled = true;
            audioSource.Play();
            
            OneSound os = new OneSound();
            os.source = audioSource;
            os.soundAsset = soundAsset;
            os.volume = audioSource.volume;
            m_all3DSource.Add(go, os);
            return true;
        }

        public bool Stop(GameObject go)
        {
            if (m_all3DSource.TryGetValue(go, out OneSound oneSound))
            {
                var source = oneSound.source;
                oneSound.soundAsset.Release();
                source.Stop();
                
                m_all3DSource.Remove(go);
                return true;
            }
            
            return false;
        }

        public void RemoveAll()
        {
            foreach (var v in m_all3DSource)
            {
                if (v.Value.soundAsset != null)
                {
                    v.Value.soundAsset.Release();
                }
            }
            m_all3DSource.Clear();
        }

        public AudioSource GetAudioSource(GameObject go)
        {
            if (m_all3DSource.TryGetValue(go, out OneSound oneSound))
            {
                return oneSound.source;
            }

            return null;
        }
        
        public void OnUpate()
        {
            if (_changeVolume)
            {
                _curTime += Time.unscaledDeltaTime;
                if (_curTime > _time)
                {
                    _changeVolume = false;
                    foreach (var v in m_all3DSource)
                    {
                        v.Value.source.volume = _toVolume;
                    }
                }
                else
                {
                    foreach (var v in m_all3DSource)
                    {
                        v.Value.source.volume = Mathf.Lerp(v.Value.volume, _toVolume, _curTime / _time);
                    }
                }
            }
        }
        
        public void ChangeVolume(float to, float time)
        {
            if (time > 0 && to > 0)
            {
                _toVolume = to;
                _time = time;
                _curTime = 0;
                _changeVolume = true;
            }
            else
            {
                foreach (var v in m_all3DSource)
                {
                    if (to < 0)
                    {
                        v.Value.source.volume = v.Value.volume;
                    }
                    else
                    {
                        v.Value.source.volume = to;
                    }
                }
            }
        }
        
        /// <summary>
        /// 暂停播放声音。
        /// </summary>
        public void PauseSound()
        {
            foreach (var v in m_all3DSource)
            {
                v.Value.source.Pause();
            }
        }
        /// <summary>
        /// 恢复播放声音。
        /// </summary>
        public void ResumeSound()
        {
            foreach (var v in m_all3DSource)
            {
                v.Value.source.UnPause();
            } 
        }

        public void MuteSound(bool mute)
        {
            foreach (var v in m_all3DSource)
            {
                v.Value.source.mute = mute;
            } 
        }
    }
}





