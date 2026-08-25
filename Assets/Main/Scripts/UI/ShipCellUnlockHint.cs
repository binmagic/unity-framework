using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 船舱格子"可解锁"提示的呼吸动画。
///
/// 挂在 ShipRoomCell.prefab 的 UnlockHint 节点上。该节点默认 SetActive(false)，
/// 由 UIShipCabinView 在"未解锁且解锁条件已满足"时开启 —— 所以动画只需跟随
/// OnEnable/OnDisable，不用自己判断业务状态。
///
/// 效果：中央开锁图标缩放脉动 + 金色边框透明度呼吸，两者同周期反向，
/// 视觉上是一次"亮起-收回"。
/// </summary>
public class ShipCellUnlockHint : MonoBehaviour
{
    [Header("脉动的开锁图标")]
    public RectTransform iconRT;

    [Header("呼吸的边框高光")]
    public Image glowFrame;

    [Header("参数")]
    public float cycleDuration = 1.1f;   // 单程时长，Yoyo 往返即一次呼吸
    public float iconScaleFrom = 1.0f;
    public float iconScaleTo   = 1.14f;
    public float glowAlphaFrom = 0.18f;
    public float glowAlphaTo   = 0.55f;

    private Sequence _seq;
    private Vector3  _iconBaseScale = Vector3.one;
    private bool     _cached;

    void Awake()
    {
        CacheRefs();
    }

    /// <summary>
    /// 节点是代码建出来的，Inspector 里没连引用，这里按名字兜底找一次。
    /// </summary>
    void CacheRefs()
    {
        if (_cached) return;
        _cached = true;

        if (iconRT == null)
        {
            var t = transform.Find("ImgUnlockIcon");
            if (t != null) iconRT = t as RectTransform;
        }
        if (glowFrame == null)
        {
            var t = transform.Find("ImgGlowFrame");
            if (t != null) glowFrame = t.GetComponent<Image>();
        }
        if (iconRT != null) _iconBaseScale = iconRT.localScale;
    }

    void OnEnable()
    {
        CacheRefs();
        Play();
    }

    void OnDisable()
    {
        Stop();
    }

    void OnDestroy()
    {
        Stop();
    }

    void Play()
    {
        Stop();

        // 用 Sequence.Join 让两条动画并行，Insert 到同一时间轴起点
        _seq = DOTween.Sequence();
        _seq.SetLink(gameObject);   // 节点销毁时自动 Kill，避免野 tween 报空引用

        if (iconRT != null)
        {
            iconRT.localScale = _iconBaseScale * iconScaleFrom;
            _seq.Join(iconRT.DOScale(_iconBaseScale * iconScaleTo, cycleDuration)
                            .SetEase(Ease.InOutSine)
                            .SetLoops(-1, LoopType.Yoyo));
        }

        if (glowFrame != null)
        {
            var c = glowFrame.color;
            glowFrame.color = new Color(c.r, c.g, c.b, glowAlphaFrom);
            _seq.Join(glowFrame.DOFade(glowAlphaTo, cycleDuration)
                               .SetEase(Ease.InOutSine)
                               .SetLoops(-1, LoopType.Yoyo));
        }
    }

    void Stop()
    {
        if (_seq != null)
        {
            _seq.Kill();
            _seq = null;
        }
        // 还原到基准值，避免下次启用时从中间态开始
        if (iconRT != null) iconRT.localScale = _iconBaseScale;
        if (glowFrame != null)
        {
            var c = glowFrame.color;
            glowFrame.color = new Color(c.r, c.g, c.b, glowAlphaFrom);
        }
    }
}
