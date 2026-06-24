//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using System;
using GameFramework;
using UnityEngine;

namespace UnityGameFramework.Runtime
{
    /// <summary>
    /// 基础组件。
    /// </summary>
    [DisallowMultipleComponent]
    public sealed class BaseComponent : GameFrameworkComponent
    {
        private float m_GameSpeedBeforePause = 1f;

        [SerializeField]
        private int m_FrameRate = 50;

        [SerializeField]
        private float m_GameSpeed = 1f;

        [SerializeField]
        private bool m_RunInBackground = true;

        [SerializeField]
        private bool m_NeverSleep = true;

        [SerializeField]
        private bool m_UsePtrForLua = false;

        
        private int m_ScreenWidth;

        private int m_ScreenHeight;
        /// <summary>
        /// 获取或设置游戏帧率。
        /// </summary>
        public int FrameRate
        {
            get
            {
                return m_FrameRate;
            }
            set
            {
                Application.targetFrameRate = m_FrameRate = value;
            }
        }

        /// <summary>
        /// 获取或设置游戏速度。
        /// </summary>
        public float GameSpeed
        {
            get
            {
                return m_GameSpeed;
            }
            set
            {
                Time.timeScale = m_GameSpeed = (value >= 0f ? value : 0f);
            }
        }

        /// <summary>
        /// 获取游戏是否暂停。
        /// </summary>
        public bool IsGamePaused
        {
            get
            {
                return m_GameSpeed <= 0f;
            }
        }

        /// <summary>
        /// 获取是否正常游戏速度。
        /// </summary>
        public bool IsNormalGameSpeed
        {
            get
            {
                return m_GameSpeed == 1f;
            }
        }

        /// <summary>
        /// 获取或设置是否允许后台运行。
        /// </summary>
        public bool RunInBackground
        {
            get
            {
                return m_RunInBackground;
            }
            set
            {
                Application.runInBackground = m_RunInBackground = value;
            }
        }

        /// <summary>
        /// 获取或设置是否禁止休眠。
        /// </summary>
        public bool NeverSleep
        {
            get
            {
                return m_NeverSleep;
            }
            set
            {
                m_NeverSleep = value;
                Screen.sleepTimeout = value ? SleepTimeout.NeverSleep : SleepTimeout.SystemSetting;
            }
        }

        //是否使用ptr方式load lua
        public bool UsePtrForLua
        {
            get => m_UsePtrForLua;
            set => m_UsePtrForLua = value;
        }
    
        
        private void OnApplicationPause(bool pause)
        {
            //Screen.SetResolution(Screen.width, Screen.height, true);
            LayoutHelper.SetCanvas();
        }

        /// <summary>
        /// 游戏框架组件初始化。
        /// </summary>
        protected override void Awake()
        {   
            base.Awake();
            
            Application.targetFrameRate = m_FrameRate;
            Time.timeScale = m_GameSpeed;
            Application.runInBackground = m_RunInBackground;
            Screen.sleepTimeout = m_NeverSleep ? SleepTimeout.NeverSleep : SleepTimeout.SystemSetting;
            this.m_ScreenHeight = Screen.height;
            this.m_ScreenWidth = Screen.width;
        }

        private void Start()
        {
            LayoutHelper.SetCanvas();
        }

        

        
        /// <summary>
        /// 暂停游戏。
        /// </summary>
        public void PauseGame()
        {
            if (IsGamePaused)
            {
                return;
            }

            m_GameSpeedBeforePause = GameSpeed;
            GameSpeed = 0f;
        }

        /// <summary>
        /// 恢复游戏。
        /// </summary>
        public void ResumeGame()
        {
            if (!IsGamePaused)
            {
                return;
            }

            GameSpeed = m_GameSpeedBeforePause;
        }

        /// <summary>
        /// 重置为正常游戏速度。
        /// </summary>
        public void ResetNormalGameSpeed()
        {
            if (IsNormalGameSpeed)
            {
                return;
            }

            GameSpeed = 1f;
        }
#if UNITY_EDITOR
        private void LateUpdate()
        {
            if(this.m_ScreenWidth!=Screen.width||this.m_ScreenHeight!=Screen.height)
            {
                this.m_ScreenHeight = Screen.height;
                this.m_ScreenWidth = Screen.width;
                // LayoutHelper.SetCanvas();
            }
            
        }
#endif
    }
}





