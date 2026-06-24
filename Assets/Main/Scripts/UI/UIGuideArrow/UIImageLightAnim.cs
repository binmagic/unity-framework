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





