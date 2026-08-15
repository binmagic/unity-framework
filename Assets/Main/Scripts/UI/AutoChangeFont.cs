/**
 * [INPUT]: 依赖 GameEntry.Localization 的 GetFontByLanguage 取当前语言字体,依赖同节点 UGUI Text 组件
 * [OUTPUT]: 对外提供 AutoChangeFont 组件(Awake 时按当前语言替换 Text 字体)
 * [POS]: UI 层的本地化字体自动切换器,服务原生 Text;与 NewText 内建的按语言换字体逻辑同源,用于未继承 NewText 的普通文本
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.Mime;
using UnityEngine;
using UnityEngine.UI;

public class AutoChangeFont : MonoBehaviour
{
    private Text _text;

    private void Awake()
    {
        _text = this.GetComponent<Text>();
        if (_text != null)
        {
            var font =  GameEntry.Localization.GetFontByLanguage();
            if (font != null)
            {
                _text.font = font;
            }
         
        }
    }
}





