/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour/SpriteRenderer，依赖 DG.Tweening 的 DOTweenAnimation 组件
 * [OUTPUT]: 对外提供 DotweenFinish 组件的 OnComplete 回调，供 DOTween 动画结束时调用以复位缩放/颜色并隐藏对象
 * [POS]: Common/Component 的 DOTween 收尾组件，作为动画完成事件的挂载目标，保证一次性动画播完后干净还原初始状态
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class DotweenFinish : MonoBehaviour
{
    private Vector3 localScale = Vector3.one;
    private DOTweenAnimation[] animations = null;
    private SpriteRenderer sp;
    private void Awake()
    {
        animations = GetComponents<DOTweenAnimation>();

        sp = GetComponent<SpriteRenderer>();
  
    }
    private void Start()
    {
        localScale = transform.localScale;
    }
    public void OnComplete()
    {
        for(int i=0;i<animations.Length;i++)
        {
            animations[i].DOPause();
        }
        transform.localScale = localScale;
        sp.color = new Color(1, 1, 1, 1);
        gameObject.SetActive(false);
    }
}





