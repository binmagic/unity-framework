/**
 * [INPUT]: 依赖 GameFramework.Localization 的 Language 判定,持有阿语/非阿语强制对齐与字体材质配置
 * [OUTPUT]: 对外提供 ForceArabicText 组件(供策划在 Inspector 标注单个文本的强制 RTL 对齐/字体覆盖意图)
 * [POS]: Arabic 模块的文本适配标记组件,当前逻辑主体被注释、以数据配置形态存在,由镜像流程读取其字段决定文本处理
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





