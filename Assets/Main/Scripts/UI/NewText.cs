using System;
using System.Collections.Generic;
using System.Text;
using GameFramework.Localization;
using UnityEngine;
using UnityEngine.UI;

public class NewText : Text
{
    [SerializeField] private bool _useTextWithEllipsis= true;
    [SerializeField] private bool _useTextBestFit= false;
    [SerializeField] private bool _useNoLineSpace= false;
    
    // 这几个定义成static，这几个都是临时对象，且没有多线程
    
    //Unity对TextGenerator的定义: Caches vertices, character info, and line info for memory friendlyness.
    //这个改为static可能是负优化，同个界面多个Text在Update中调用SetText(str) 即使同个Text的str和上次内容没变，static的_generator缓存也极有可能失效，会再次调用native层重新计算Verts 失去了TextGenerator缓存的意义
    //static TextGenerator _generator = new TextGenerator(); 

    
    private const string no_breaking_space = "\u00A0";
    public override string text
    {
        get => m_Text;
        set
        {
            if (String.IsNullOrEmpty(value))
            {
                if (String.IsNullOrEmpty(m_Text))
                    return;
                m_Text = "";
                SetVerticesDirty();
            }
            else
            {
                if (_useNoLineSpace)
                {
                    if (value.Contains(" "))
                    {
                        value = value.Replace(" ", no_breaking_space);
                    }
                }
                
                // 如果很短的话，没必要去做处理了。否则全显示成...了
                if (_useTextWithEllipsis && value.Length > 4)
                {
                    value = GetTextWithEllipsis(value);
                }
// #if UNITY_ANDROID || UNITY_EDITOR
                if (IsRtl(value))
                {
                    value = ArabicSupport.ArabicFixer.Fix(value);
                }
// #endif

                if (m_Text != value)
                {
                    var tempFont =  GameEntry.Localization.GetFontByLanguage();
                    if (tempFont != null)
                    {
                        font = tempFont;
                    }
                    m_Text = value;
                    SetVerticesDirty();
                    SetLayoutDirty();
                }
            }
        }
    }
    
    StringBuilder _stringBuilder = new StringBuilder(50);
    private bool _lock = false;
    private string _compareValue = "";
    private bool _needNewString = false;
    
    private string GetTextWithEllipsis(string value)
    {
        _stringBuilder.Clear();
        _needNewString = false;
        _compareValue = "";
        for (int i = 0; i < value.Length; ++i)
        {
            if (value[i] == '<')
            {
                _lock = true;
                _needNewString = true;
                continue;
            }
            if (value[i] == '>')
            {
                _lock = false;
                continue;
            }

            if (!_lock)
                _stringBuilder.Append(value[i]);
        }

        if (_needNewString)
        {
            _compareValue = _stringBuilder.ToString();
        }
        else
        {
            _compareValue = value;
        }

        var settings = GetGenerationSettings(rectTransform.rect.size);
        var _generator = cachedTextGenerator;
        _generator.Populate(_compareValue, settings);
        var characterCountVisible = _generator.characterCountVisible;
        var updatedText = value;
        if (characterCountVisible>0 && _compareValue.Length > characterCountVisible)
        {
            _lock = false;
            _stringBuilder.Clear();
            int valueLength = value.Length;
            int visibleCharactorIndex = 0;
            int needRichTextNum = 0;
            for (int i = 0; i < valueLength; ++i)
            {
                if (value[i] == '<')
                {
                    _lock = true;
                    if (i < valueLength-1 && value[i + 1] == '/')
                    {
                        --needRichTextNum;
                    }
                    else
                    {
                        ++needRichTextNum;
                    }
                }
                else if (value[i] == '>')
                {
                    _lock = false;
                    if (needRichTextNum <= 0 && visibleCharactorIndex > characterCountVisible)
                    {
                        _stringBuilder.Append(value[i]);
                        break;
                    }
                }

                if (!_lock)
                {
                    ++visibleCharactorIndex;
                    if (visibleCharactorIndex > characterCountVisible)
                    {
                        if (needRichTextNum <= 0)
                        {
                            break;
                        }
                    }
                    else
                    {
                        _stringBuilder.Append(value[i]);
                        if (visibleCharactorIndex == characterCountVisible)
                        {
                            _stringBuilder.Append("...");
                        }
                    }
                }
                else
                {
                    _stringBuilder.Append(value[i]);
                }
            }
            updatedText = _stringBuilder.ToString();
        }
        return updatedText;
    }
    
        /// <summary>
    /// 当前可见的文字行数
    /// </summary>
    public int VisibleLines { get; private set; }
        
    private readonly UIVertex[] _tmpVerts = new UIVertex[4];

    private void _UseFitSettings()
    {
        TextGenerationSettings settings = GetGenerationSettings(rectTransform.rect.size);
        settings.resizeTextForBestFit = false;

        if (!resizeTextForBestFit)
        {
            cachedTextGenerator.PopulateWithErrors(text, settings, gameObject);
            return;
        }

        int minSize = resizeTextMinSize;
        int txtLen = text.Length;
        for (int i = resizeTextMaxSize; i >= minSize; --i)
        {
            settings.fontSize = i;
            cachedTextGenerator.PopulateWithErrors(text, settings, gameObject);
            if (cachedTextGenerator.characterCountVisible == txtLen)
            {
                break;
            }
        }
    }

    protected override void OnPopulateMesh(VertexHelper toFill)
    {
        if (null == font) return;

        m_DisableFontTextureRebuiltCallback = true;
        if (_useTextBestFit == false)
        {
            
            base.OnPopulateMesh(toFill);
            return;
        }
        _UseFitSettings();

        // Apply the offset to the vertices
        IList<UIVertex> verts = cachedTextGenerator.verts;
        float unitsPerPixel = 1 / pixelsPerUnit;
        int vertCount = verts.Count;

        // We have no verts to process just return (case 1037923)
        if (vertCount <= 0)
        {
            toFill.Clear();
            return;
        }

        Vector2 roundingOffset = new Vector2(verts[0].position.x, verts[0].position.y) * unitsPerPixel;
        roundingOffset = PixelAdjustPoint(roundingOffset) - roundingOffset;
        toFill.Clear();
        if (roundingOffset != Vector2.zero)
        {
            for (int i = 0; i < vertCount; ++i)
            {
                int tempVertsIndex = i & 3;
                _tmpVerts[tempVertsIndex] = verts[i];
                _tmpVerts[tempVertsIndex].position *= unitsPerPixel;
                _tmpVerts[tempVertsIndex].position.x += roundingOffset.x;
                _tmpVerts[tempVertsIndex].position.y += roundingOffset.y;
                if (tempVertsIndex == 3)
                    toFill.AddUIVertexQuad(_tmpVerts);
            }
        }
        else
        {
            for (int i = 0; i < vertCount; ++i)
            {
                int tempVertsIndex = i & 3;
                _tmpVerts[tempVertsIndex] = verts[i];
                _tmpVerts[tempVertsIndex].position *= unitsPerPixel;
                if (tempVertsIndex == 3)
                    toFill.AddUIVertexQuad(_tmpVerts);
            }
        }

        m_DisableFontTextureRebuiltCallback = false;
        VisibleLines = cachedTextGenerator.lineCount;
    }

    private bool IsRtl(string str)
    {
        var isRtl = false;
        if (GameEntry.Localization?.Language == Language.Arabic)
        {
            foreach (var _char in str)
            {
                if ((_char >= 1536 && _char <= 1791) || (_char >= 65136 && _char <= 65279))
                {
                    isRtl = true;
                    break;
                }
            }
        }
        return isRtl;
    }
}





