using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

// TMP 打字机效果
// 为了兼容TextMeshProUGUI 和 TextMeshPro

public class TMPTeletypeComponent : MonoBehaviour
{
    private TMP_Text _textMeshPro;
    
    /* 做打字机效果 */
    private int m_codeCurTextIdx;
    private int m_codeTotalCnt;
    private float m_codeDeltaT;
    private bool m_isStartCodingEffect = false;
    private Action m_codeCallback;
    private float m_tmpDeltaT = 0.0f;

    public void Awake()
    {
        _textMeshPro = GetComponent<TMP_Text>();
    }

    /// <summary>
    /// 采用文字-打字机效果
    /// </summary>
    /// <param name="str"></param>
    /// <param name="startIndex"></param>
    /// <param name="callback"></param>
    public void SetCodeEffectText(string str, Action callback, int startIndex=0, float speed = 0.1f)
    {
        if (_textMeshPro == null)
        {
            callback?.Invoke();
            return;
        }
        
        _textMeshPro.text = str;
        m_codeCallback = callback;
        m_codeDeltaT = speed;
        _textMeshPro.ForceMeshUpdate();
        m_codeCurTextIdx = startIndex;
        m_codeTotalCnt = _textMeshPro.textInfo.characterCount;
        _textMeshPro.maxVisibleCharacters = m_codeCurTextIdx;
        m_isStartCodingEffect = false;
        if (string.IsNullOrEmpty(str) || m_codeCurTextIdx >= m_codeTotalCnt)
        {
            m_codeCallback?.Invoke();
            return;
        }
        m_isStartCodingEffect = true;
    }

    public void SetCodeSpeed(float delta)
    {
        m_codeDeltaT = delta;
    }

    /// <summary>
    /// 在播放打字特效的时候，瞬间显示所有的文字
    /// </summary>
    public void ShowCodeTextEffDirect()
    {
        //只有正在正常播放的时候才生效
        if (m_isStartCodingEffect)
        {
            if (_textMeshPro != null)
            {
                _textMeshPro.maxVisibleCharacters = m_codeTotalCnt;
            }

            m_isStartCodingEffect = false;
            m_codeCallback?.Invoke();
        }
    }

    private void Update()
    {
        // 如果_textMeshPro为null，这个标志就不会为true，所以这里不用判断_textMeshPro!=null
        if (m_isStartCodingEffect == false)
            return;
        m_tmpDeltaT += Time.deltaTime;
        if (m_tmpDeltaT < m_codeDeltaT)
            return;
        m_tmpDeltaT = 0.0f;
        m_codeCurTextIdx++;
        _textMeshPro.maxVisibleCharacters = m_codeCurTextIdx;
        if (m_codeCurTextIdx >= m_codeTotalCnt)
        {
            m_isStartCodingEffect = false;
            m_codeCallback?.Invoke();
        }
    }
}





