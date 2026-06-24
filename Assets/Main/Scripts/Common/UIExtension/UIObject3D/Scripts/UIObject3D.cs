using System;
using UnityEngine;
using Object = UnityEngine.Object;


[RequireComponent(typeof(RectTransform)), DisallowMultipleComponent, ExecuteInEditMode]
[AddComponentMenu("UI/UIObject3D/UIObject3D")]
public class UIObject3D : MonoBehaviour
{
    [Header("Target"), SerializeField] private GameObject _target;

    public GameObject Target
    {
        get { return _target; }
        set
        {
            _target = value;
            HardUpdateDisplay();
        }
    }

    [SerializeField] private Transform _targetContainer;
    [SerializeField] private Vector3 _targetRotation = Vector3.zero;
    [SerializeField, Range(-10, 10)] private float _targetOffsetX = 0f;
    [SerializeField, Range(-10, 10)] private float _targetOffsetY = 0f;

    [Header("Camera Settings"), SerializeField]
    private Camera _targetCamera;

    [SerializeField, Range(20, 100)] private float _cameraFOV = 35f;
    [SerializeField, Range(-10, -1)] private float _cameraDistance = -3.5f;

    [SerializeField] private Vector2 _textureSize = default(Vector2);

    private Vector2 TextureSize
    {
        get
        {
            if (_textureSize != default(Vector2))
                return _textureSize;

            if (_target != null)
            {
                Vector2 size = new Vector2(Mathf.Abs(Mathf.Floor(rectTransform.rect.width)),
                    Mathf.Abs(Mathf.Floor(rectTransform.rect.height)));

                if (size.x == 0 || size.y == 0)
                    size = new Vector2(256, 256);

                _textureSize = size;

                return size;
            }

            return Vector2.one;
        }
    }

    [NonSerialized] private bool renderQueued = false;

    void DestroyResources()
    {
        if (_targetCamera != null)
        {
            _targetCamera.targetTexture = null;
        }

        if (_renderTexture != null)
        {
            _Destroy(_renderTexture);
            _renderTexture = null;
            _textureSize = default;
        }
    }

    /// <summary>
    /// Clear all textures/etc. destroy the current target objects, and then start from scratch.
    /// Necessary, if, for example, the RectTransform size has changed.
    /// Fairly performance-intensive - only call this if strictly necessary.
    /// </summary>
    public void HardUpdateDisplay()
    {
        DestroyResources();

        Transform parent = _targetContainer;
        if (parent == null)
        {
            parent = transform;
        }

        _target.transform.SetParent(parent, false);
        SetLayerRecursively(_target.transform, objectLayer);


        UpdateDisplay(true);
    }

    private void _Destroy(Object o)
    {
        if (Application.isPlaying)
            Destroy(o);
        else
            DestroyImmediate(o);
    }

    public void UpdateDisplay(bool instantRender = false)
    {
        if (imageComponent.texture != renderTexture)
        {
            imageComponent.texture = renderTexture;
        }

        UpdateTargetPositioningAndScale();
        UpdateTargetCameraPositioningEtc();

        Render(instantRender);
    }

    private void OnEnable()
    {
        UpdateDisplay(true);
    }

    private void Render(bool instant = false)
    {
        if (Application.isPlaying && !instant)
        {
            renderQueued = true;
            return;
        }

        if (_targetCamera == null || _target == null)
        {
            return;
        }

        if (_targetCamera.targetTexture != this.renderTexture)
        {
            _targetCamera.targetTexture = this.renderTexture;
        }

        _targetCamera.Render();

        renderQueued = false;
    }

    /*
     * As of Unity 2017.2, there seems to be a bug which calls this method
     * repeatedly when UIObject3D is nested within a layout group, which causes all sorts of problems.
     * As such, I have decided to remove this method for now; the primary downside is that
     * resizing a UIObject3D instance will no longer resize the texture. In most scenarios,
     * this will not be noticeable. Leaving the method out increases performance markedly,
     * as resizing the texture/etc. is very expensive.
    void OnRectTransformDimensionsChange()
    {
    }
    */

    /// <summary>
    /// Unity's Update() method. Called every frame.
    /// </summary>
    void Update()
    {
        if (!Application.isPlaying)
            return;

        Render(true);
    }

    private RectTransform _rectTransform;

    private RectTransform rectTransform
    {
        get
        {
            if (_rectTransform == null)
                _rectTransform = this.GetComponent<RectTransform>();
            return _rectTransform;
        }
    }

    [SerializeField, HideInInspector] private UIObject3DRawImage _imageComponent;

    public UIObject3DRawImage imageComponent
    {
        get
        {
            if (_imageComponent == null)
            {
                _imageComponent = this.GetComponent<UIObject3DRawImage>();
            }

            if (_imageComponent == null)
            {
                _imageComponent = this.gameObject.AddComponent<UIObject3DRawImage>();
            }

            return _imageComponent;
        }
    }

    private RenderTexture _renderTexture;

    private RenderTexture renderTexture
    {
        get
        {
            if (_renderTexture == null)
            {
                _renderTexture = new RenderTexture((int) TextureSize.x, (int) TextureSize.y, 16,
                    RenderTextureFormat.ARGB32);
                _renderTexture.filterMode = FilterMode.Bilinear;
                _renderTexture.useMipMap = false;
            }

            return _renderTexture;
        }
    }

    private void UpdateTargetPositioningAndScale()
    {
        if (_targetContainer == null)
            return;

        _targetContainer.transform.localPosition = new Vector3(_targetOffsetX, _targetOffsetY, 0);
        _targetContainer.transform.localEulerAngles = _targetRotation;
    }

    private void SetLayerRecursively(Transform transform, int layer)
    {
        transform.gameObject.layer = layer;

        foreach (Transform t in transform)
        {
            SetLayerRecursively(t, layer);
        }
    }

    private void UpdateTargetCameraPositioningEtc()
    {
        if (_targetCamera == null)
            return;

        _targetCamera.transform.localPosition = Vector3.zero + new Vector3(0, 0, _cameraDistance);
        _targetCamera.transform.rotation = Quaternion.identity;
        _targetCamera.targetTexture = this.renderTexture;
        _targetCamera.fieldOfView = _cameraFOV;
        _targetCamera.gameObject.layer = objectLayer;
        _targetCamera.cullingMask = LayerMask.GetMask(LayerMask.LayerToName(objectLayer));
        _targetCamera.backgroundColor = Color.clear;
    }

    private static int _objectLayer = -1;

    private static int objectLayer
    {
        get
        {
            if (_objectLayer == -1)
            {
                _objectLayer = LayerMask.NameToLayer("UIObject3D");
            }

            return _objectLayer;
        }
    }

}





