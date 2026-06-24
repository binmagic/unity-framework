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





