/**
 * [INPUT]: 依赖 UnityEngine 的 RectTransform 尺寸信息与 BoxCollider2D 组件
 * [OUTPUT]: 对外提供 UIBoxColliderSize 组件,将 2D 碰撞器同步为 RectTransform 的实际大小与中心
 * [POS]: UIExtension 的运行时几何同步工具,解决 UI 元素需要 2D 物理碰撞检测时碰撞器尺寸对齐问题
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





