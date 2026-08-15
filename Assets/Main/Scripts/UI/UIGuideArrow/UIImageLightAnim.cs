/**
 * [INPUT]: 依赖同节点 Image 的材质,按时间轴切换材质 _Color_time 参数
 * [OUTPUT]: 对外提供 UIImageLightAnim 组件(周期性触发图片高光/流光表现)
 * [POS]: UIGuideArrow 模块的辅助高亮特效,独立于箭头移动状态机,给引导目标图片加节律性光效以吸引注意
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
using UnityEngine.UI;

public class UIImageLightAnim : MonoBehaviour
{
    private float _animAllTime = 0;
    private float _showAnimTime = 0;
    private float _hideAnimTime = 0;
    private float _time;
    private bool _isDoAnim;
    private Material _material;
    private const string PlayAnimName = "_Color_time";
    private void Awake()
    {
        _isDoAnim = false;
        _animAllTime = 0;
    }

    private void Start()
    {
        var img = this.GetComponent<Image>();
        if (img != null)
        {
            _material = img.material;
        }
        SetAnim(false);
    }

    public void Init(float allTime, float startTime, float endTime)
    {
        var img = this.GetComponent<Image>();
        if (img != null)
        {
            _material = img.material;
        }
        _animAllTime = allTime;
        _showAnimTime = startTime;
        _hideAnimTime = endTime;
    }

    private void Update()
    {
        if (_animAllTime > 0)
        {
            _time += Time.deltaTime;
            if (_time >= _animAllTime)
            {
                _time -= _animAllTime;
            }

            if (_time > _showAnimTime && !_isDoAnim)
            {
                SetAnim(true);
            }

            if (_time > _hideAnimTime && _isDoAnim)
            {
                SetAnim(false);
            }
        }
    }

    private void SetAnim(bool isShow)
    {
        _isDoAnim = isShow;
        if (_material != null)
        {
            float val = isShow ? 1.0f : 0.0f;
            _material.SetFloat(PlayAnimName, val);
        }
    }
}





