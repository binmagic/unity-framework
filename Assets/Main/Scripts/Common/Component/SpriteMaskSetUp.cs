//  ***
//  * Created by zhangliheng.
//  * DateTime: 2023/06/16 5:04 PM
//  * Description: 针对ui特效相关的SpriteMask的range设置

//  ***/


/**
 * [INPUT]: 依赖 UnityEngine 的 SpriteMask/Canvas/SortingLayer，依赖 GetComponentInParentExt 扩展取父级 Canvas，编辑器下依赖 Sirenix.OdinInspector 绘制面板
 * [OUTPUT]: 对外提供 SpriteMaskSetUp 组件，Refresh 校准 SpriteMask 的自定义排序区间，AutoMatchByTarget 按目标 RectTransform 缩放遮罩
 * [POS]: Common/Component 的 UI 特效遮罩配置器，继承 UIParticleSetUpBase，把 SpriteMask 的 order 区间锚定到父 Canvas 排序，与 UIOrderInLayerSetUp/UISurvivalParticleSetUp 同族解决特效层级
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;
using UnityEngine;
#if UNITY_EDITOR
using Sirenix.OdinInspector;
#endif

[RequireComponent(typeof(SpriteMask))]
public class SpriteMaskSetUp : UIParticleSetUpBase
{
#if UNITY_EDITOR
    [Title("尺寸多分辨率自适应：开启并设置目标RectTransform后，SpriteMask会始终保持和目标显示尺寸一致")]
#endif 
    [SerializeField] public bool AutoMatch = false;
#if UNITY_EDITOR
    [SerializeField] [ShowIf("@AutoMatch == true"), Space(10), LabelText("目标RectTransform")]
#endif
    public RectTransform targetRectTransform;
    
    
#if UNITY_EDITOR
    [Space]
    [Space]
    [Title("父节点orderInLayer为：")]
    [ReadOnly]
#endif
    public int parentSortingOrder = 0;
    
    private Canvas _parentCanvas;
#if UNITY_EDITOR
    [Space]
    [Title("Local代表是在父节点的基础上追加")]
#endif
    public bool Local = true;
    public Vector2Int Range = new Vector2Int(0, 99);

    private SpriteMask _spriteMask;
    private void Awake()
    {
        _spriteMask = GetComponent<SpriteMask>();
    }

    private void OnEnable()
    {
        if (AutoMatch)
        {
            Invoke(nameof(AutoMatchByTarget), 0.1f);
        }
    }

#if UNITY_EDITOR
    [Button("设置")]
#endif
    public void Refresh()
    {
        if (_spriteMask == null)
        {
            _spriteMask = GetComponent<SpriteMask>();
            if (_spriteMask == null)
            {
                return;
            }
        }
        
        _parentCanvas = transform.GetComponentInParentExt<Canvas>(false);
        if (Local && _parentCanvas == null)
        {
            Debug.LogWarning("parentCanvas not found!");
            return;
        }
        
        parentSortingOrder = Local ? _parentCanvas.sortingOrder : 0;
        var sortingLayerId = Local ? _parentCanvas.sortingLayerID : SortingLayer.NameToID("Default");
        var finalRange = new Vector2Int(parentSortingOrder + Range.x, parentSortingOrder + Range.y);
        _spriteMask.isCustomRangeActive = true;
        _spriteMask.backSortingLayerID =sortingLayerId;
        _spriteMask.frontSortingLayerID = sortingLayerId;
        _spriteMask.backSortingOrder = finalRange.x;
        _spriteMask.frontSortingOrder = finalRange.y;
    }
    
    
    public void AutoMatchByTarget()
    {
        if (targetRectTransform == null)
        {
            return;
        }

        var worldSize = targetRectTransform.rect.size;
        if (worldSize.x <= 0 || worldSize.y <= 0)
        {
            return;
        }
        
        var worldScale = targetRectTransform.lossyScale;
        var finalScaleX = worldScale.x;
        var finalScaleY = worldScale.y;
        var maskSize = new Vector2(worldSize.x * finalScaleX, worldSize.y * finalScaleY);

        var sprite = _spriteMask.sprite;
        var newScale = new Vector3(maskSize.x / sprite.bounds.size.x, maskSize.y / sprite.bounds.size.y, 1);

        if (transform.parent != null)
        {
            var lossyScale = transform.parent.lossyScale;
            var parentLossyScaleX = lossyScale.x;
            var parentLossyScaleY = lossyScale.y;
            newScale.x /= parentLossyScaleX;
            newScale.y /= parentLossyScaleY;
        }
        
        _spriteMask.transform.localScale = newScale;
    }
}





