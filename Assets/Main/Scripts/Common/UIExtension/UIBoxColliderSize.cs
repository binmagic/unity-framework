using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>动态修改ui碰撞器大小</summary>
public class UIBoxColliderSize : MonoBehaviour
{
    [SerializeField]
    private RectTransform rectTransform = null;

    [SerializeField]
    private BoxCollider2D boxCollider2D = null;
    [SerializeField]
    private bool isUpdateSize = true;

    private void LateUpdate()
    {
        if (isUpdateSize)
        {
            if (rectTransform == null || boxCollider2D == null)
            { return; }

            boxCollider2D.offset = rectTransform.rect.center;
            boxCollider2D.size = new Vector2(rectTransform.rect.width, rectTransform.rect.height);
            isUpdateSize = false;
        }
    }
}





