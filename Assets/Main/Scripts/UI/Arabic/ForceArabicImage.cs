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





