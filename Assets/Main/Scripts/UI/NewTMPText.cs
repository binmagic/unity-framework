using System;
using System.Text;
using GameFramework.Localization;
using GameKit.Base;
using RTLTMPro;
using TMPro;
using UnityEngine.EventSystems;
using UnityEngine;

public class NewTMPText : TextMeshProUGUI, IPointerClickHandler
{
/// <summary>
    /// Internal horizontal text alignment options.
    /// </summary>
    public enum HorizontalAlignmentOptions
    {
        Left = 0x1, Center = 0x2, Right = 0x4, Justified = 0x8, Flush = 0x10, Geometry = 0x20
    }
 
    /// <summary>
    /// Internal vertical text alignment options.
    /// </summary>
    public enum VerticalAlignmentOptions
    {
        Top = 0x100, Middle = 0x200, Bottom = 0x400, Baseline = 0x800, Geometry = 0x1000, Capline = 0x2000,
    }

    private bool arabicFontSizeProcessFlag;

    public Action<PointerEventData> onPointerClick;
    public void OnPointerClick(PointerEventData eventData)
    {
        onPointerClick?.Invoke(eventData);
    }

    // 阿拉伯语是否自动右对齐，这个处理不同于lastwar
    // 因为lastwar是整个UI都做了布局处理了，而我们没有刻意去处理，全部都右对齐，会导致显示很奇怪，所以这里做一个特定的标志
    public bool ArabicAutoRight = false;
    public int ArabicFontSize = 0;

    public override string text
    {
        get { return base.text; }
        set
        {
       
            string val = value;
            //val = "ر \"<color=#099b4a> ﺑﺸﺮﺍﺀ</color>\"";
            if(Application.isPlaying) 
            {
                // 非阿语语言，是不会遇到阿语的（除了玩家名字和聊天，聊天用的还不是TMPro）
                // 而且即使遇到阿语了，他们也不知道正确还是错误。所以不需要支持。
                var ret = HasArabic(val, out var arabicCount);
                if (ret) // 含阿语字符
                {
                    if (GameEntry.Localization?.Language != Language.Arabic) // 非阿语看阿语单词
                    {
                        isRightToLeftText = false;
                        base.text = val;
                    }
                    else // 阿语环境
                    {
                        isRightToLeftText = true;
                        base.text = GetFixedText(val);

                        if (ArabicAutoRight)
                        {
                            SetRtlAlign(TextAlignmentOptions.Right, true);
                        }
                        
                        // 阿拉伯文字太小，自动放大一下+2
                        // 但是如果手动设置了大小，就使用手动设置的大小
                        if (ArabicFontSize > 0)
                        {
                            fontSize = ArabicFontSize;
                        }
                        else
                        {
                            if (!arabicFontSizeProcessFlag)
                            {
                                if (enableAutoSizing)
                                {
                                    fontSizeMax = fontSizeMax + 4;
                                }
                                else
                                {
                                    if (fontSize <= 14)
                                    {
                                        fontSize = fontSize + 4;
                                    }
                                    else
                                    {
                                        fontSize = fontSize + 2;
                                    }
                                }

                                arabicFontSizeProcessFlag = true;
                            }
                        }
                    }
                }
                else // 无阿语字符
                {
                    isRightToLeftText = false;
                    base.text = val;
                }
            }
            else
            {
                base.text = val;
            }
        }
    }

    public static TextAlignmentOptions ConvertAlignFormat(TextAnchor anchor, bool alignByGeometry)
        {
        
            HorizontalAlignmentOptions horizontalAlignment;
            VerticalAlignmentOptions verticalAlignment;
    
            // 水平对齐
            switch (anchor)
            {
                case TextAnchor.UpperLeft:
                case TextAnchor.MiddleLeft:
                case TextAnchor.LowerLeft:
                    horizontalAlignment = HorizontalAlignmentOptions.Left;
                    break;
                case TextAnchor.UpperCenter:
                case TextAnchor.MiddleCenter:
                case TextAnchor.LowerCenter:
                    horizontalAlignment = HorizontalAlignmentOptions.Center;
                    break;
                case TextAnchor.UpperRight:
                case TextAnchor.MiddleRight:
                case TextAnchor.LowerRight:
                    horizontalAlignment = HorizontalAlignmentOptions.Right;
                    break;
                default:
                    horizontalAlignment = HorizontalAlignmentOptions.Center;
                    break;
            }
    
            // 垂直对齐
            switch (anchor)
            {
                case TextAnchor.UpperLeft:
                case TextAnchor.UpperCenter:
                case TextAnchor.UpperRight:
                    verticalAlignment = alignByGeometry ? VerticalAlignmentOptions.Geometry : VerticalAlignmentOptions.Top;
                    break;
                case TextAnchor.MiddleLeft:
                case TextAnchor.MiddleCenter:
                case TextAnchor.MiddleRight:
                    verticalAlignment = alignByGeometry ? VerticalAlignmentOptions.Geometry : VerticalAlignmentOptions.Middle;
                    break;
                case TextAnchor.LowerLeft:
                case TextAnchor.LowerCenter:
                case TextAnchor.LowerRight:
                    verticalAlignment = alignByGeometry ? VerticalAlignmentOptions.Geometry : VerticalAlignmentOptions.Bottom;
                    break;
                default:
                    verticalAlignment = VerticalAlignmentOptions.Middle;
                    break;
            }
    
            return (TextAlignmentOptions)((uint)horizontalAlignment | (uint)verticalAlignment);
        }
        public bool HasArabic(string str, out int arabicCount)
        {
            arabicCount = 0;
            if (string.IsNullOrEmpty(str))
                return false;
            
            var isArabicLang = GameEntry.Localization?.Language == Language.Arabic;
            if (!isArabicLang)
            {
                return false;
            }
            
            var ret =  CheckArabicByChar(str, out arabicCount);
            return ret;
        }
    
        public static bool CheckArabicByChar(string str, out int arabicCount)
        {
            arabicCount = 0;
            int strLength = str.Length;
            for (var i = 0; i < strLength; i++)
            {
                char c = str[i];
                if (isArabic(c))
                {
                    arabicCount++;
                    break;
                }
            }
            
            return arabicCount > 0;
        }
        
        
        private void SetRtlAlign(TextAlignmentOptions targetAlign, bool auto)
        {
            // if (MirrorVersionConfig.IsMirrorVersionOpen) // 镜像版本上线后自动控制对齐
            // {
            //     return;
            // }
            
            if (!auto)
            {
                alignment = targetAlign;
            }
            else
            {
                var oldAlign = alignment;
                switch (oldAlign){
                    case TextAlignmentOptions.BottomLeft:
                        alignment = TextAlignmentOptions.BottomRight;
                        break;                        
                    case TextAlignmentOptions.MidlineLeft:
                        alignment = TextAlignmentOptions.MidlineRight;
                        break;                        
                    case TextAlignmentOptions.TopLeft:
                        alignment = TextAlignmentOptions.TopRight;
                        break;                
                    case TextAlignmentOptions.BaselineLeft:
                        alignment = TextAlignmentOptions.BaselineRight;
                        break;                
                    case TextAlignmentOptions.CaplineLeft:
                        alignment = TextAlignmentOptions.CaplineRight;
                        break;                
                    case TextAlignmentOptions.Left:
                        alignment = TextAlignmentOptions.Right;
                        break;
                }
            }
        }
        
    
        public static bool isArabic(char c)
        {
            if (c >= 0x600 && c <= 0x6ff) return true;
            if (c >= 0x750 && c <= 0x77f) return true;
            if (c >= 0xfb50 && c <= 0xfc3f) return true;
            if (c >= 0xfe70 && c <= 0xfefc) return true;
            return false;
        }
    
    private FastStringBuilder RTLFixedText = new FastStringBuilder(RTLSupport.DefaultBufferSize);
    
    private string GetFixedText(string input, bool isReverse = true)
        {
            if (string.IsNullOrEmpty(input))
                return input;
        
            RTLFixedText.Clear();
            RTLSupport.FixRTL(input, RTLFixedText, false, richText, true);
            if (isReverse)
            {
                RTLFixedText.Reverse();
            }
            return RTLFixedText.ToString();
        }
    public void SetColorMode(ColorMode mode)
    {
        m_colorMode = mode;
    }

    /// <summary>
    /// 打字机效果
    /// </summary>
    private int startIndex;
    private int endIndex;
    private int length;

    // 打字效果
    private TMPTeletypeComponent m_teletypeCom;
    
    public TMPTeletypeComponent Teletype
    {
        get
        {
            if (m_teletypeCom == null)
                m_teletypeCom = this.GetOrAddComponent<TMPTeletypeComponent>();

            return m_teletypeCom;
        }
    }
    
    /// <summary>
    /// 采用文字-打字机效果
    /// </summary>
    /// <param name="str"></param>
    /// <param name="startIndex"></param>
    /// <param name="callback"></param>
    public void SetCodeEffectText(string str, Action callback, int startIndex=0, float speed = 0.1f)
    {
        if (Teletype != null)
        {
            Teletype.SetCodeEffectText(str, callback, startIndex, speed);
        }
    }

    public void SetCodeSpeed(float delta)
    {
        if (Teletype != null)
        {
            Teletype.SetCodeSpeed(delta);
        }
    }

    /// <summary>
    /// 在播放打字特效的时候，瞬间显示所有的文字
    /// </summary>
    public void ShowCodeTextEffDirect()
    {
        if (Teletype != null)
        {
            Teletype.ShowCodeTextEffDirect();
        }
    }
    
}





