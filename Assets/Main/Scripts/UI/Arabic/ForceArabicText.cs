using System.Collections;
using System.Collections.Generic;
using GameFramework.Localization;
using UnityEngine;
using UnityEngine.UI;

public class ForceArabicText : MonoBehaviour
{
    
    public TextAnchor ArabicLangForceAlign = TextAnchor.LowerRight;
    public TextAnchor NonArabicLangForceAlign = TextAnchor.LowerRight;

    public Material ArabicTMProFontMaterial;

    public bool IsArabicDisableBoldFont = false;
    public bool IsReverseImage = false;
    
    // Start is called before the first frame update
    void Start()
    {
        // if (GameEntry.Localization.Language == Language.Arabic)
        // {
        //
        // }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}





