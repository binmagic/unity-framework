//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using UnityEngine;



    public partial class SoundComponent{
    internal static class Constant
        {
            internal const float DefaultTime = 0f;
            internal const bool DefaultMute = false;
            internal const bool DefaultLoop = false;
            internal const int DefaultPriority = 0;
            internal const float DefaultVolume = 1f;
            internal const float DefaultFadeInSeconds = 0f;
            internal const float DefaultFadeOutSeconds = 0f;
            internal const float DefaultPitch = 1f;
            internal const float DefaultPanStereo = 0f;
            internal const float DefaultSpatialBlend = 0f;
            internal const float DefaultMaxDistance = 100f;
            internal const float DefaultDopplerLevel = 1f;
        }

    
    public sealed class PlaySoundParams
    {
        public int serialId;
        //private float m_Time;
        // private bool m_MuteInSoundGroup;
        private bool m_Loop;
        //private int m_Priority;
        private float m_VolumeInSoundGroup;
        // private float m_FadeInSeconds;
        // private float m_Pitch;
        // private float m_PanStereo;
        // private float m_SpatialBlend;
        // private float m_MaxDistance;
        // private float m_DopplerLevel;

        /// <summary>
        /// 初始化播放声音参数的新实例。
        /// </summary>
        public PlaySoundParams()
        {
            // m_Time = Constant.DefaultTime;
            // m_MuteInSoundGroup = Constant.DefaultMute;
            m_Loop = Constant.DefaultLoop;
            //m_Priority = Constant.DefaultPriority;
            m_VolumeInSoundGroup = Constant.DefaultVolume;
            // m_FadeInSeconds = Constant.DefaultFadeInSeconds;
            // m_Pitch = Constant.DefaultPitch;
            // m_PanStereo = Constant.DefaultPanStereo;
            // m_SpatialBlend = Constant.DefaultSpatialBlend;
            // m_MaxDistance = Constant.DefaultMaxDistance;
            // m_DopplerLevel = Constant.DefaultDopplerLevel;
        }

        /// <summary>
        /// 获取或设置播放位置。
        /// </summary>
        // public float Time
        // {
        //     get
        //     {
        //         return m_Time;
        //     }
        //     set
        //     {
        //         m_Time = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置在声音组内是否静音。
        /// </summary>
        // public bool MuteInSoundGroup
        // {
        //     get
        //     {
        //         return m_MuteInSoundGroup;
        //     }
        //     set
        //     {
        //         m_MuteInSoundGroup = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置是否循环播放。
        /// </summary>
        public bool Loop
        {
            get
            {
                return m_Loop;
            }
            set
            {
                m_Loop = value;
            }
        }

        /// <summary>
        /// 获取或设置声音优先级。
        /// </summary>
        // public int Priority
        // {
        //     get
        //     {
        //         return m_Priority;
        //     }
        //     set
        //     {
        //         m_Priority = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置在声音组内音量大小。
        /// </summary>
        public float VolumeInSoundGroup
        {
            get
            {
                return m_VolumeInSoundGroup;
            }
            set
            {
                m_VolumeInSoundGroup = value;
            }
        }

        /// <summary>
        /// 获取或设置声音淡入时间，以秒为单位。
        /// </summary>
        // public float FadeInSeconds
        // {
        //     get
        //     {
        //         return m_FadeInSeconds;
        //     }
        //     set
        //     {
        //         m_FadeInSeconds = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置声音音调。
        /// </summary>
        // public float Pitch
        // {
        //     get
        //     {
        //         return m_Pitch;
        //     }
        //     set
        //     {
        //         m_Pitch = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置声音立体声声相。
        /// </summary>
        // public float PanStereo
        // {
        //     get
        //     {
        //         return m_PanStereo;
        //     }
        //     set
        //     {
        //         m_PanStereo = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置声音空间混合量。
        /// </summary>
        // public float SpatialBlend
        // {
        //     get
        //     {
        //         return m_SpatialBlend;
        //     }
        //     set
        //     {
        //         m_SpatialBlend = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置声音最大距离。
        /// </summary>
        // public float MaxDistance
        // {
        //     get
        //     {
        //         return m_MaxDistance;
        //     }
        //     set
        //     {
        //         m_MaxDistance = value;
        //     }
        // }

        /// <summary>
        /// 获取或设置声音多普勒等级。
        /// </summary>
        // public float DopplerLevel
        // {
        //     get
        //     {
        //         return m_DopplerLevel;
        //     }
        //     set
        //     {
        //         m_DopplerLevel = value;
        //     }
        // }
    }
    
    internal sealed class PlaySoundInfo
    {
        private readonly Vector3 m_WorldPosition;
        private readonly object m_UserData;
        private readonly int m_SerialId;
        private readonly SoundGroup m_SoundGroup;
        private readonly PlaySoundParams m_PlaySoundParams;

        public PlaySoundInfo(int serialId, SoundGroup soundGroup, PlaySoundParams playSoundParams, object userData)
        {
            m_SerialId = serialId;
            m_SoundGroup = soundGroup;
            m_PlaySoundParams = playSoundParams;
            m_UserData = userData;
        }

        public PlaySoundInfo(Vector3 worldPosition, object userData)
        {
            //m_BindingEntity = bindingEntity;
            m_WorldPosition = worldPosition;
            m_UserData = userData;
        }
        
        public Vector3 WorldPosition
        {
            get
            {
                return m_WorldPosition;
            }
        }

        public object UserData
        {
            get
            {
                return m_UserData;
            }
        }

        public int SerialId
        {
            get
            {
                return m_SerialId;
            }
        }

        public SoundGroup SoundGroup
        {
            get
            {
                return m_SoundGroup;
            }
        }

        public PlaySoundParams PlaySoundParams
        {
            get
            {
                return m_PlaySoundParams;
            }
        }
        
    }
    }





