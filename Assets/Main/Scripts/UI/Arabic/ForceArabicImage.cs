/**
 * [INPUT]: 依赖 GameFramework.Localization 的 Language 判定阿语环境,依赖 Image/RawImage/Text 组件识别
 * [OUTPUT]: 对外提供 ForceArabicImage 标记组件(IsReverseImage 意图开关)
 * [POS]: Arabic 模块的图片翻转覆盖标记,ArabicMirror 结合 AutoReverseImageNameList 名单时读取它,以强制指定单张图片在 RTL 下是否镜像
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using GameFramework.Localization;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ForceArabicImage : MonoBehaviour
{
    public bool IsReverseImage = true;
    void Start()
    {
        if (GameEntry.Localization.Language == Language.Arabic)
        {
            // if (IsReverseImage)
            // {
            //     var originLocalScale = this.gameObject.transform.localScale;
            //     if (TryGetComponent<Image>(out var image) || TryGetComponent<RawImage>(out var rawImage))
            //     {
            //         this.gameObject.transform.localScale =
            //             new Vector3(-originLocalScale.x, originLocalScale.y, originLocalScale.z);
            //         ProcessText(transform as RectTransform, 1);
            //     }
            // }
        }
    }

    void ProcessText(RectTransform rect,int depth)
    {
        if (depth > 1 && rect.TryGetComponent<ForceArabicImage>(out var forceArabicImage))
        {
            return;
        }
        if (rect.TryGetComponent<Text>(out var text) || rect.TryGetComponent<TextMeshProUGUI>(out var tmpro))
        {
            if ((depth & 1) == 1)
            {
                var originLocalScale = rect.localScale;
                rect.localScale =
                    new Vector3(-originLocalScale.x, originLocalScale.y, originLocalScale.z);
                depth++;
            }
            
        }
        foreach (RectTransform child in rect)
        {
            ProcessText(child, depth);
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}





