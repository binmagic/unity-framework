using System.Collections;
using System.Collections.Generic;

using Sfs2X.Entities.Data;
using UnityEngine;
using UnityEngine.UI;
using UnityGameFramework.Runtime;
using XLua;

[Hotfix]
/// <summary>
/// 滚动字体
/// </summary>
public class ScrollTxtNode : MonoBehaviour
{
    [SerializeField] private RectTransform txtRect;
    public float target = -178f;

    /// <summary>
    /// 滚动间隔 没多久滚动一次
    /// </summary>
    public float scrollInterval = 45;

    public float speed = 50f;
    public bool canMove;
    private float scrollTimer;
    private Vector2 originPos;
    public bool run;
    private void Start()
    {
        scrollTimer = scrollInterval;
        originPos = txtRect.anchoredPosition;
    }

    public void Move()
    {
        if (!canMove)
        {
            canMove = true;
        }
    }

    private void Update()
    {
        if (run)
        {
            if (!canMove && scrollTimer > 0)
            {
                scrollTimer -= Time.deltaTime;
                if (scrollTimer <= 0)
                {
                    canMove = true;
                }
            }
            else
            {
                if (canMove)
                {
                    Vector2 v2 = txtRect.anchoredPosition;
                    v2.x -= speed * Time.deltaTime;
                    txtRect.anchoredPosition = v2;
                    if (v2.x <= target)
                    {
                        canMove = false;
                        scrollTimer = scrollInterval;
                        txtRect.anchoredPosition = originPos;
                    }
                }
            }
        }
    }
}





