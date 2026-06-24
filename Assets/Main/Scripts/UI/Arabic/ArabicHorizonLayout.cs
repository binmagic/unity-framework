using System;
using System.Collections;
using System.Collections.Generic;
using GameFramework.Localization;
using TMPro;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UI;
[DisallowMultipleComponent]
public class ArabicHorizonLayout : MonoBehaviour
{
    /// <summary>
    /// Internal horizontal text alignment options.
    /// </summary>
    private enum _HorizontalAlignmentOptions
    {
        Left = 0x1, Center = 0x2, Right = 0x4, Justified = 0x8, Flush = 0x10, Geometry = 0x20
    }
 
    /// <summary>
    /// Internal vertical text alignment options.
    /// </summary>
    private enum _VerticalAlignmentOptions
    {
        Top = 0x100, Middle = 0x200, Bottom = 0x400, Baseline = 0x800, Geometry = 0x1000, Capline = 0x2000,
    }
    public enum AlignmentType
    {
        NoControl = 1,
        AllLeftAlign,
        AllRightAlign,
        FirstLeftAndLastRight, // 第一个左对齐，最后一个右对齐
        FirstRightAndLastLeft, // 第一个右对齐，最后一个左对齐
    }

    public bool IsReverseImage = false;
    public bool IsControlChildWidth = true;
    public bool IsChildForceExpandWidth = true;
    public AlignmentType TextAlignType = AlignmentType.NoControl;
    public TextAnchor ChildAlignment = TextAnchor.MiddleRight;
    public bool IsDisableChildContentSizeFitter = true;
    [Header("Mirror版本控制")]
    [Tooltip("是否与Mirror版本一起上线")]
    public bool IsControlledByMirror = false;

    // Start is called before the first frame update
    void Start()
    {
        if (IsControlledByMirror && !MirrorVersionConfig.IsMirrorVersionOpen)
            return;
        
        if (GameEntry.Localization.Language == Language.Arabic)
        {
            if (TryGetComponent<BidirectionalHorizontalLayoutGroup>(out var bidirectionalHorizontalLayoutGroup) && MirrorVersionConfig.IsMirrorVersionOpen)
            {
                return;
            }
            
            HorizontalOrVerticalLayoutGroup layoutGroup = GetComponent<BidirectionalHorizontalLayoutGroup>();
            if (layoutGroup == null)
            {
                layoutGroup = GetComponent<HorizontalLayoutGroup>();
            }
            if (layoutGroup == null)
            {
                layoutGroup = gameObject.AddComponent<BidirectionalHorizontalLayoutGroup>();
            }

            layoutGroup.childAlignment = ChildAlignment;
            layoutGroup.childForceExpandWidth = IsChildForceExpandWidth;
            layoutGroup.childControlWidth = IsControlChildWidth;
            // var rectTransform = gameObject.transform as RectTransform;
            // if(rectTransform)
            // {
            //     StartCoroutine(DelayedCall());
            // }

        
            var childCount = transform.childCount;
            for (int i = 0; i < childCount / 2; i++)
            {
                var childRectTrans = transform.GetChild(i);
                var endChildRectTrans = transform.GetChild(childCount - i - 1);
                childRectTrans.SetSiblingIndex(childCount - i - 1);
                endChildRectTrans.SetSiblingIndex(i);
            }

            var firstActiveChildrenIndex = childCount-1;
            var lastActiveChildrenIndex = 0;
            for (int i = 0; i < childCount; i++)
            {
                var childRectTrans = transform.GetChild(i);
                var isHaveText = childRectTrans.gameObject.TryGetComponent<Text>(out var newTextCom);
                var isHaveTMProText = childRectTrans.gameObject.TryGetComponent<NewTMPText>(out var tmproCom);
                if (childRectTrans.gameObject.activeInHierarchy)
                {
                    if (isHaveText || isHaveTMProText)
                    {
                        firstActiveChildrenIndex = Math.Min(firstActiveChildrenIndex, i);
                        lastActiveChildrenIndex = Math.Max(lastActiveChildrenIndex, i);
                    }
                }
                
                if ((childRectTrans.gameObject.TryGetComponent<Image>(out var image) ||
                     childRectTrans.gameObject.TryGetComponent<RawImage>(out var rawImage)))
                {
                    var oldLocalScaleX = childRectTrans.localScale.x;
                    childRectTrans.SetLocalScaleX(IsReverseImage ?-oldLocalScaleX : oldLocalScaleX);                   
                }
                
                if (TextAlignType != AlignmentType.NoControl)
                {
                    if (isHaveText)
                    {
                        var oldAlign = newTextCom.alignment;
                        switch (oldAlign)
                        {
                            case TextAnchor.LowerLeft:
                            case TextAnchor.LowerRight:
                            case TextAnchor.LowerCenter:
                                if (TextAlignType == AlignmentType.AllLeftAlign)
                                {
                                    newTextCom.alignment = TextAnchor.LowerLeft;
                                }
                                else if (TextAlignType == AlignmentType.AllRightAlign)
                                {
                                    newTextCom.alignment = TextAnchor.LowerRight;
                                }
                                else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.LowerLeft
                                        : (i == lastActiveChildrenIndex ? TextAnchor.LowerRight : oldAlign);
                                }                                
                                else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.LowerRight
                                        : (i == lastActiveChildrenIndex ? TextAnchor.LowerLeft : oldAlign);
                                }

                                break;
                            case TextAnchor.MiddleLeft:
                            case TextAnchor.MiddleRight:
                            case TextAnchor.MiddleCenter:
                                if (TextAlignType == AlignmentType.AllLeftAlign)
                                {
                                    newTextCom.alignment = TextAnchor.MiddleLeft;
                                }
                                else if (TextAlignType == AlignmentType.AllRightAlign)
                                {
                                    newTextCom.alignment = TextAnchor.MiddleRight;
                                }
                                else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.MiddleLeft
                                        : (i == lastActiveChildrenIndex ? TextAnchor.MiddleRight : oldAlign);
                                }
                                else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.MiddleRight
                                        : (i == lastActiveChildrenIndex ? TextAnchor.MiddleLeft : oldAlign);
                                }


                                break;
                            case TextAnchor.UpperLeft:
                            case TextAnchor.UpperRight:
                            case TextAnchor.UpperCenter:
                                if (TextAlignType == AlignmentType.AllLeftAlign)
                                {
                                    newTextCom.alignment = TextAnchor.UpperLeft;
                                }
                                else if (TextAlignType == AlignmentType.AllRightAlign)
                                {
                                    newTextCom.alignment = TextAnchor.UpperRight;
                                }
                                else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.UpperLeft
                                        : (i == lastActiveChildrenIndex ? TextAnchor.UpperRight : oldAlign);
                                }
                                else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                                {
                                    newTextCom.alignment = i == firstActiveChildrenIndex
                                        ? TextAnchor.UpperRight
                                        : (i == lastActiveChildrenIndex ? TextAnchor.UpperLeft : oldAlign);
                                }

                                break;
                        }
                    }
                    else if (isHaveTMProText)
                    {
                        var oldAlign = tmproCom.alignment;
                        if (((uint) oldAlign & (uint) _VerticalAlignmentOptions.Bottom) != 0)
                        {
                            if (TextAlignType == AlignmentType.AllLeftAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.BottomLeft;
                            }
                            else if (TextAlignType == AlignmentType.AllRightAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.BottomRight;
                            }
                            else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.BottomLeft
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.BottomRight : oldAlign);
                            }
                            else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.BottomRight
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.BottomLeft : oldAlign);
                            }
                        }
                        else if (((uint) oldAlign & (uint) _VerticalAlignmentOptions.Top) != 0)
                        {
                            if (TextAlignType == AlignmentType.AllLeftAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.TopLeft;
                            }
                            else if (TextAlignType == AlignmentType.AllRightAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.TopRight;
                            }
                            else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.TopLeft
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.TopRight : oldAlign);
                            }
                            else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.TopRight
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.TopLeft : oldAlign);
                            }
                        }
                        else
                        {
                            if (TextAlignType == AlignmentType.AllLeftAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.MidlineLeft;
                            }
                            else if (TextAlignType == AlignmentType.AllRightAlign)
                            {
                                tmproCom.alignment = TextAlignmentOptions.MidlineRight;
                            }
                            else if (TextAlignType == AlignmentType.FirstLeftAndLastRight)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.MidlineLeft
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.MidlineRight : oldAlign);
                            }
                            else if (TextAlignType == AlignmentType.FirstRightAndLastLeft)
                            {
                                tmproCom.alignment = i == firstActiveChildrenIndex
                                    ? TextAlignmentOptions.MidlineRight
                                    : (i == lastActiveChildrenIndex ? TextAlignmentOptions.MidlineLeft : oldAlign);
                            }
                        }
                    }
                }

                if (childRectTrans.gameObject.TryGetComponent<ContentSizeFitter>(out var contentSizeFitter) && IsDisableChildContentSizeFitter)
                {
                    contentSizeFitter.enabled = false;
                }
            }
        }
    }
    
    
    private IEnumerator DelayedCall()
    {
        for (int i = 0; i < 3; i++)
        {
            yield return null;  // 等待一帧
        }

        var rectTransform = gameObject.transform as RectTransform;
        if (rectTransform)
        {
            Vector2 oldLocalPosition = rectTransform.localPosition;
            // 更改 pivot
            Vector2 oldPivot = rectTransform.pivot;
            Vector2 newPivot = new Vector2(1, rectTransform.pivot.y);
            rectTransform.pivot = newPivot;
            Vector2 anchorDelta = newPivot - oldPivot;
        
            rectTransform.localPosition = new Vector2(oldLocalPosition.x + anchorDelta.x * rectTransform.rect.width, oldLocalPosition.y);
        }
    }

    // // Update is called once per frame
    // void Update()
    // {
    //     
    // }
}





