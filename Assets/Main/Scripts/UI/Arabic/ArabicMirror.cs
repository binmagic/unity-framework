using System.Collections;
using System.Collections.Generic;
using GameFramework.Localization;
// using LS.UnityEngine.UI;
using SuperScrollView;
using TMPro;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class MirrorPositionData
{
    public Vector2 anchoredPosition;
    public Vector2 anchorMin;
    public Vector2 anchorMax;
    public Vector2 pivot;
    public Quaternion localRotation;
    public Vector3 localScale;

    public MirrorPositionData(GameObject gameObject)
    {
        if (gameObject.transform is RectTransform rect)
        {
            anchoredPosition = rect.anchoredPosition;
            anchorMin = rect.anchorMin;
            anchorMax = rect.anchorMax;
            pivot = rect.pivot;
            localRotation = rect.localRotation;
            localScale = rect.localScale;
        }
    }
}

public class AutoMirrorPositionData
{
    public int uid;
    public float width;
    public float height;
    public Vector3 localPosition;
    public Vector3 position;
    public Vector2 pivot;
    public Quaternion localRotation;
    public string name;
    public Vector3 lossyScale;
    public Rect rect;
    public RectTransform parent;

    public AutoMirrorPositionData(GameObject gameObject)
    {
        if (gameObject.transform is RectTransform rect)
        {
            uid = rect.gameObject.GetInstanceID();
            width = rect.rect.width;
            height = rect.rect.height;
            localPosition = rect.localPosition;
            position = rect.position;
            pivot = rect.pivot;
            name = rect.name;
            localRotation = rect.localRotation;
            lossyScale = rect.lossyScale;
            this.rect = rect.rect;
            parent = rect.parent as RectTransform;
        }
    }
}

public class Counter
{
    public int count = 0;
}

[System.Serializable]
public class SingleMirrorObjectData
{
    public MirrorPositionData mirrorData; // 镜像数据
    public MirrorPositionData originalData; // 原始数据
    public bool isUsingMirrorData = false;//此刻是否在应用镜像
}

public struct HorizontalData
{
    private RectOffset padding;
    private float spacing;
    private TextAnchor childAlignment;
    private bool childControlWidth;
    private bool childControlHeight;
    private bool childForceExpandWidth;
    private bool childForceExpandHeight;
    public HorizontalData(HorizontalLayoutGroup group)
    {
        padding = group.padding;
        spacing = group.spacing;
        childAlignment = group.childAlignment;
        childControlWidth = group.childControlWidth;
        childControlHeight = group.childControlHeight;
        childForceExpandWidth = group.childForceExpandWidth;
        childForceExpandHeight = group.childForceExpandHeight;
    }    
    
    public void CopyToArabicRTLHorLayout(BidirectionalHorizontalLayoutGroup group)
    {
        group.padding = padding;
        group.spacing = spacing;
        group.childAlignment = childAlignment;
        group.childControlWidth = childControlWidth;
        group.childControlHeight = childControlHeight;
        group.childForceExpandWidth = childForceExpandWidth;
        group.childForceExpandHeight = childForceExpandHeight;
    }
}

public static class MirrorVersionConfig
{
    private static bool _isAutoMirrorVersionOpen = false;
    static MirrorVersionConfig()
    {
        RefreshOpenFlag();
    }

    public static void RefreshOpenFlag()
    {
        _isAutoMirrorVersionOpen = GameEntry.Lua?.CallWithReturn<bool>("CSharpCallLuaInterface.IsArabicAutoMirrorOpen") ?? false;
        if (_isAutoMirrorVersionOpen)
        {
            AutoReverseImageNameList.Init();
        }
    }
    public static bool IsMirrorVersionOpen => _isAutoMirrorVersionOpen;
}

public class ArabicMirror : MonoBehaviour
{
    [HideInInspector]
    public  List<GameObject> mirrorObjects = new List<GameObject>();
    [SerializeField,HideInInspector] 
    private List<SingleMirrorObjectData> mirrorObjectDatas = new List<SingleMirrorObjectData>(); // 单个数据
    
    public bool IsApplyAutoMirror = true;
    public bool IsNoLuaControl = false;
    [Tooltip("以自身中心而不是以屏幕中心做镜像")]
    public bool IsInnerMirror = false;
    [SerializeField]  
    private  List<GameObject> _autoMirrorCullObjects = new List<GameObject>();

    private void EnsureDataListSize(int index)
    {
        if (index < 0)
            return;
        if (index >= mirrorObjectDatas.Count)
        {
            var count = mirrorObjectDatas.Count;
            for (int i = count-1; i < index; i++)
            {
                mirrorObjectDatas.Add(null);
            }
        }
    }

    public void WriteData(int index, GameObject gameObject)
    {
        EnsureDataListSize(index);
        
        mirrorObjectDatas[index] = mirrorObjectDatas[index] ?? new SingleMirrorObjectData();
        mirrorObjectDatas[index].mirrorData = new MirrorPositionData(gameObject);
        mirrorObjectDatas[index].isUsingMirrorData = true;
    }    
    
    public void RecordOriginalData(int index, GameObject gameObject)
    {
        EnsureDataListSize(index);
        
        mirrorObjectDatas[index] = mirrorObjectDatas[index] ?? new SingleMirrorObjectData();
        mirrorObjectDatas[index].originalData = new MirrorPositionData(gameObject);
        mirrorObjectDatas[index].isUsingMirrorData = false;
    }  
    
    public bool SwitchData(int index, GameObject gameObject)
    {
        if (index < 0 || index >= mirrorObjectDatas.Count)
            return false;
        var singleData = mirrorObjectDatas[index];
        if (singleData.isUsingMirrorData)
        {
            if (singleData.originalData != null)
            {
                ApplyDataToGameObject(gameObject, singleData.originalData);
                singleData.isUsingMirrorData = false;
                return true;
            }
        }
        else
        {
            if (singleData.mirrorData != null)
            {
                singleData.originalData = new MirrorPositionData(gameObject);
                ApplyDataToGameObject(gameObject, singleData.mirrorData);
                singleData.isUsingMirrorData = true;
                return true;
            }
        }

        return false;
    }

    public void ClearData(int index)
    {
        if (index > 0 && index < mirrorObjects.Count)
        {
            mirrorObjects[index] = null;
            mirrorObjectDatas[index] = null;
        }
    }

    private static void ApplyDataToGameObject(GameObject gameObject, MirrorPositionData data)
    {
        if (gameObject != null && data != null)
        {
            if (gameObject.transform is RectTransform rect)
            {
                rect.anchoredPosition = data.anchoredPosition;
                rect.anchorMin = data.anchorMin;
                rect.anchorMax = data.anchorMax;
                rect.pivot = data.pivot;
                rect.localRotation = data.localRotation;
                rect.localScale = data.localScale;
            }
        }
    }

    // public static void MirrorEntry(bool isInnerMirror, bool isProcessRootAnchorAndPivot, GameObject go)
    // {
    //     //prefab挂了脚本，且标明不使用自动镜像，则不处理（view 和 item 均适用）
    //     if (go.TryGetComponent<ArabicMirror>(out var arabicMirrorCom) && !arabicMirrorCom.IsApplyAutoMirror) 
    //     {
    //         return;
    //     }
    //
    //     var isNoLuaControl = arabicMirrorCom?.IsNoLuaControl ?? false;
    //     if (UIRunTimeConfig.IsArabic && (isNoLuaControl || MirrorVersionConfig.IsMirrorVersionOpen))
    //     {
    //         if (go.transform is RectTransform rect)
    //         {
    //             if (rect.localScale.x == 0 || rect.localScale.y == 0)
    //             {
    //                 return;
    //             }
    //
    //             var cullingObjects = new List<GameObject>();
    //             if (go.TryGetComponent<ArabicMirror>(out var arabicMirror))
    //             {
    //                 cullingObjects = arabicMirror._autoMirrorCullObjects;
    //             }
    //
    //             var dataList = new List<AutoMirrorPositionData>();
    //             RecordAutoOriginalData(rect, dataList, cullingObjects);
    //             var counter = new Counter { count = 0 };
    //             Mirror(rect, rect, dataList, cullingObjects, counter, isInnerMirror, isProcessRootAnchorAndPivot,
    //                 true);
    //         }
    //     }
    // }
    
    public void Awake()
    {
        // if (IsNoLuaControl && IsApplyAutoMirror)
        // {
        //     MirrorEntry( false, true, gameObject);
        // }
    }

    static void RecordAutoOriginalData(RectTransform rect, List<AutoMirrorPositionData> preOrderDataList,
        List<GameObject> cullingObjects)
    {
        if (rect == null) return;
        if (!IsProcessSelf(rect,cullingObjects) || rect.localScale.x == 0 || rect.localScale.y == 0) //rect位于剔除列表内，则不处理
        {
            return;
        }

        PreProcessInRecord(rect, cullingObjects);
        preOrderDataList.Add(new AutoMirrorPositionData(rect.gameObject));

        foreach (Transform child in rect)
        {
            if (child is RectTransform childRect)
            {
                // 递归处理子节点
                RecordAutoOriginalData(childRect, preOrderDataList, cullingObjects);
            }
        }
        
    }

    static void PreProcessInRecord(RectTransform rect,  List<GameObject> cullingObjects)
    {
        if (rect != null)
        {
            if (rect.TryGetComponent<Slider>(out var slider))
            {
                if (slider.fillRect)
                {
                    var mirror = slider.fillRect.gameObject.AddComponent<ArabicImageMirror>();
                    mirror.mirrorType = ArabicImageMirror.MirrorType.Horizontal;
                    cullingObjects.Add(slider.fillRect.gameObject);
                }                
                if (slider.handleRect)
                {
                    var mirror = slider.handleRect.gameObject.AddComponent<ArabicImageMirror>();
                    mirror.mirrorType = ArabicImageMirror.MirrorType.Horizontal;
                    cullingObjects.Add(slider.handleRect.gameObject);
                }
            }
        }
    }

    // static void Mirror(RectTransform rect, RectTransform rootRect,  List<AutoMirrorPositionData> preOrderDataList,List<GameObject> cullingObjects,
    //     Counter counter,bool isInnerMirror, bool isProcessRootAnchorAndPivot, bool isProcessSelfPos, AutoMirrorPositionData rootRectData = null)
    // {
    //     if (rect != null)
    //     {
    //         var autoMirrorCullObjects = cullingObjects ?? new List<GameObject>();
    //         if (!IsProcessSelf(rect,autoMirrorCullObjects) || rect.localScale.x == 0 || rect.localScale.y == 0) //rect位于剔除列表内，则不处理
    //         {
    //             return;
    //         }
    //
    //         var isSelfRoot = rect == rootRect;
    //         var processRootAnchorAndPivotFilter = isProcessRootAnchorAndPivot || !isSelfRoot; // 根节点是否处理锚点和pivot
    //         var data = preOrderDataList[counter.count++];
    //         rootRectData = isSelfRoot ? data:  rootRectData;
    //         if(isProcessSelfPos)
    //         {
    //             Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2);
    //             Vector3 center = GameEntry.UICamera.ScreenToWorldPoint(new Vector3(screenCenter.x, screenCenter.y, 0));
    //
    //             if (isInnerMirror) // item 内部镜像
    //             {
    //                 var midPos = rootRectData?.position ?? rootRect.position;
    //                 midPos.x += (0.5f - rootRect.pivot.x) * rootRect.rect.width * rootRect.lossyScale.x;
    //                 midPos.y += (0.5f - rootRect.pivot.y) * rootRect.rect.height * rootRect.lossyScale.y;
    //                 center = new Vector3(midPos.x, midPos.y, 0);
    //             }
    //
    //             Vector3 posDiff = data.position - center;
    //             Vector3 mirrorPos = new Vector3(center.x - posDiff.x, data.position.y, data.position.z);
    //             if (processRootAnchorAndPivotFilter) // 更改锚点
    //             {
    //                 var oldAnchorMinX = rect.anchorMin.x;
    //                 var oldAnchorMaxX = rect.anchorMax.x;
    //                 rect.anchorMin = new Vector2(1 - oldAnchorMaxX, rect.anchorMin.y);
    //                 rect.anchorMax = new Vector2(1 - oldAnchorMinX, rect.anchorMax.y);
    //             }
    //
    //             // 应用镜像位置
    //             rect.position = mirrorPos;
    //             // 根据pivot调整
    //             var localPos = rect.localPosition;
    //             var scaleX = counter.count == 1 && rootRect.parent == null ? rootRect.lossyScale.x : rect.localScale.x;
    //             localPos.x += 2 * (data.pivot.x - 0.5f) * data.width * scaleX;
    //             rect.localPosition = localPos;
    //             // 旋转
    //             var euler = data.localRotation.eulerAngles;
    //             euler.z = -euler.z;
    //             rect.localRotation = Quaternion.Euler(euler);
    //
    //             if (processRootAnchorAndPivotFilter)
    //             {
    //                 ChangePivot(rect, 1 - data.pivot.x); // 镜像pivot 
    //             }
    //         }
    //         
    //         ProcessImageOrRawImage(rect);
    //         ProcessSlider(rect);
    //         ProcessTextAlign(rect);
    //         ProcessLayout(rect);
    //
    //         var isProcessChildPos = IsProcessChildPos(rect);
    //         foreach (Transform child in rect)
    //         {
    //             // 递归处理子节点
    //             if (child is RectTransform childRect)
    //             {
    //                 var isIgnoreLayoutElement = child.TryGetComponent<LayoutElement>(out var layoutElement) &&
    //                                             layoutElement.ignoreLayout; //layout下的ignore element
    //                 
    //                 if(isProcessChildPos || isIgnoreLayoutElement)
    //                 {
    //                     Mirror(childRect, rootRect, preOrderDataList, autoMirrorCullObjects, counter,
    //                         isInnerMirror, isProcessRootAnchorAndPivot, true);
    //                 }
    //                 else // layout下
    //                 {
    //                     Mirror(childRect, childRect, preOrderDataList, autoMirrorCullObjects, counter,
    //                         true, false, true);
    //                 }
    //             }
    //         }
    //         
    //     }
    // }
    
    static void ChangePivot(RectTransform rect, float pivotX)
    {
        Vector2 oldPivot = rect.pivot;
        Vector2 oldOffsetMin = rect.offsetMin;
        Vector2 oldOffsetMax = rect.offsetMax;
        Vector2 oldAnchoredPosition = rect.anchoredPosition;
        // 设置新的pivot
        rect.pivot = new Vector2(pivotX, rect.pivot.y);
        if (Mathf.Abs(rect.anchorMin.x - rect.anchorMax.x) < 0.01) // 水平锚点集中在一点
        {
            // 计算新的anchoredPosition，以保持UI元素在屏幕上的位置不变
            Vector2 deltaPivot = rect.pivot - oldPivot;
            Vector2 newSizeDelta = new Vector2(rect.rect.width * deltaPivot.x, 0);
            Vector2 newAnchoredPosition = oldAnchoredPosition + 
                                          newSizeDelta * rect.localScale.x;
            // 设置新的anchoredPosition
            rect.anchoredPosition = newAnchoredPosition;
        }
        else
        {
            // 设置新的offsetMin和offsetMax
            rect.offsetMin = oldOffsetMin;
            rect.offsetMax = oldOffsetMax;
        }
    }

    static void ProcessImageOrRawImage(RectTransform rect)
    {
        var imageName = string.Empty;
        bool hasForceArabicImage = rect.TryGetComponent<ForceArabicImage>(out var forceArabicImage);
        bool hasImage = rect.TryGetComponent<Image>(out var image);
        bool hasRawImage = rect.TryGetComponent<RawImage>(out var rawImage);
        bool hasPolygonImage = false;
        
        var imageReverseFlag = (hasImage || hasPolygonImage) && hasForceArabicImage && forceArabicImage.IsReverseImage; // Image默认不翻转
        var forceImageDontReverseFlag = (hasImage || hasPolygonImage) && hasForceArabicImage && !forceArabicImage.IsReverseImage;
        if (hasImage && image.sprite != null)
        {
            imageName = image.sprite.name; 
        }
        
        
        var rawImageReverseFlag =  hasRawImage &&
                                   (!hasForceArabicImage || forceArabicImage.IsReverseImage); // rawImage默认翻转
        if (hasRawImage && rawImage.texture != null)
        {
            imageName = rawImage.texture.name;
        }

        var isAutoImage = !string.IsNullOrEmpty(imageName) &&
                          AutoReverseImageNameList.IsAutoReverseImage(imageName);        
        
        var isDontAutoRawImage = !string.IsNullOrEmpty(imageName) &&
                          AutoReverseImageNameList.IsDontAutoReverseRawImage(imageName);
        
        if (imageReverseFlag || (rawImageReverseFlag && !isDontAutoRawImage) || (isAutoImage && !forceImageDontReverseFlag))
        {
            var mirror = rect.gameObject.AddComponent<ArabicImageMirror>();
            mirror.mirrorType = ArabicImageMirror.MirrorType.Horizontal;
        }
    }

    static void ProcessSlider(RectTransform rect)
    {
        if (rect == null)
        {
            return;
        }
        
        if (rect.TryGetComponent<Slider>(out var slider))
        {
            if (slider.direction == Slider.Direction.LeftToRight)
            {
                slider.direction = Slider.Direction.RightToLeft;
            }
            else if (slider.direction == Slider.Direction.RightToLeft)
            {
                slider.direction = Slider.Direction.LeftToRight;
            }
        }
        
    }    
    
    static void ProcessTextAlign(RectTransform rect)
    {
        if (rect == null)
        {
            return;
        }
        
        if (rect.TryGetComponent<Text>(out var text))
        {
            var alignment = text.alignment;
            switch (text.alignment)
            {
                case TextAnchor.LowerLeft:
                    alignment = TextAnchor.LowerRight;
                    break;
                case TextAnchor.MiddleLeft:
                    alignment = TextAnchor.MiddleRight;
                    break;
                case TextAnchor.UpperLeft:
                    alignment = TextAnchor.UpperRight;
                    break;     
                
                case TextAnchor.LowerRight:
                    alignment = TextAnchor.LowerLeft;
                    break;
                case TextAnchor.MiddleRight:
                    alignment = TextAnchor.MiddleLeft;
                    break;
                case TextAnchor.UpperRight:
                    alignment = TextAnchor.UpperLeft;
                    break;
            }
            text.alignment = alignment;
        }        
        else if (rect.TryGetComponent<NewTMPText>(out var tmpro))
        {
            var alignment = tmpro.alignment;
            if (((uint)alignment & (uint)NewTMPText.HorizontalAlignmentOptions.Left) != 0)
            {
                alignment = (TextAlignmentOptions)((uint)alignment & ~(uint)NewTMPText.HorizontalAlignmentOptions.Left);
                alignment = (TextAlignmentOptions) ((uint)alignment | (uint)NewTMPText.HorizontalAlignmentOptions.Right);
            }
            else if (((uint)alignment & (uint)NewTMPText.HorizontalAlignmentOptions.Right) != 0)
            {
                alignment = (TextAlignmentOptions)((uint)alignment & ~(uint)NewTMPText.HorizontalAlignmentOptions.Right);
                alignment = (TextAlignmentOptions) ((uint)alignment | (uint)NewTMPText.HorizontalAlignmentOptions.Left);
            }
            tmpro.alignment = alignment;
            var oldMarginX = tmpro.margin.x;
            var oldMarginZ = tmpro.margin.z;
            tmpro.margin = new Vector4(oldMarginZ, tmpro.margin.y, oldMarginX, tmpro.margin.w);
        }
        
    }    
    
    static void ProcessLayout(RectTransform rect)
    {
        if (rect == null)
        {
            return;
        }
        
        if (rect.TryGetComponent<VerticalLayoutGroup>(out var verticalLayoutGroup) && verticalLayoutGroup.enabled)
        {
            var alignment = verticalLayoutGroup.childAlignment;
            switch (alignment)
            {
                case TextAnchor.LowerLeft:
                    verticalLayoutGroup.childAlignment = TextAnchor.LowerRight;
                    break;                
                case TextAnchor.LowerRight:
                    verticalLayoutGroup.childAlignment = TextAnchor.LowerLeft;
                    break;                
                case TextAnchor.MiddleLeft:
                    verticalLayoutGroup.childAlignment = TextAnchor.MiddleRight;
                    break;                
                case TextAnchor.MiddleRight:
                    verticalLayoutGroup.childAlignment = TextAnchor.MiddleLeft;
                    break;                
                case TextAnchor.UpperLeft:
                    verticalLayoutGroup.childAlignment = TextAnchor.UpperRight;
                    break;                
                case TextAnchor.UpperRight:
                    verticalLayoutGroup.childAlignment = TextAnchor.UpperLeft;
                    break;
            }
            var leftPadding = verticalLayoutGroup.padding.left;
            var rightPadding = verticalLayoutGroup.padding.right;
            verticalLayoutGroup.padding.left = rightPadding;
            verticalLayoutGroup.padding.right = leftPadding;
        }    
        else if (rect.TryGetComponent<GridLayoutGroup>(out var gridLayoutGroup) && gridLayoutGroup.enabled)
        {
            var corner = gridLayoutGroup.startCorner;
            switch (corner)
            {
                case GridLayoutGroup.Corner.LowerLeft:
                    gridLayoutGroup.startCorner = GridLayoutGroup.Corner.LowerRight;
                    break;                
                case GridLayoutGroup.Corner.LowerRight:
                    gridLayoutGroup.startCorner = GridLayoutGroup.Corner.LowerLeft;
                    break;                
                case GridLayoutGroup.Corner.UpperLeft:
                    gridLayoutGroup.startCorner = GridLayoutGroup.Corner.UpperRight;
                    break;                
                case GridLayoutGroup.Corner.UpperRight:
                    gridLayoutGroup.startCorner = GridLayoutGroup.Corner.UpperLeft;
                    break;
            }            
            
            var childAlignment = gridLayoutGroup.childAlignment;
            switch (childAlignment)
            {
                case TextAnchor.LowerLeft:
                    gridLayoutGroup.childAlignment = TextAnchor.LowerRight;
                    break;                  
                case TextAnchor.LowerRight:
                    gridLayoutGroup.childAlignment = TextAnchor.LowerLeft;
                    break;                     
                case TextAnchor.MiddleLeft:
                    gridLayoutGroup.childAlignment = TextAnchor.MiddleRight;
                    break;                  
                case TextAnchor.MiddleRight:
                    gridLayoutGroup.childAlignment = TextAnchor.MiddleLeft;
                    break;                   
                case TextAnchor.UpperLeft:
                    gridLayoutGroup.childAlignment = TextAnchor.UpperRight;
                    break;                  
                case TextAnchor.UpperRight:
                    gridLayoutGroup.childAlignment = TextAnchor.UpperLeft;
                    break;                

            }
            var leftPadding = gridLayoutGroup.padding.left;
            var rightPadding = gridLayoutGroup.padding.right;
            gridLayoutGroup.padding.left = rightPadding;
            gridLayoutGroup.padding.right = leftPadding;
        }        
        else if (rect.TryGetComponent<GridInfinityScrollView>(out var gridInfinityScrollView) && gridInfinityScrollView.enabled)
        {
            //LSZ暂时注释
            //gridInfinityScrollView.isRTLInArabic = true;
        }
        else if (rect.TryGetComponent<BidirectionalHorizontalLayoutGroup>(out var bidirectionalHorizontalLayoutGroup) && bidirectionalHorizontalLayoutGroup.enabled)
        {
            var hasForceArabicBiHorizontalLayout = rect.TryGetComponent<ForceArabicBiHorizontalLayout>(out var forceArabicBiHorizontalLayout);
            
            bidirectionalHorizontalLayoutGroup.IsReverse = !hasForceArabicBiHorizontalLayout || 
                                                           forceArabicBiHorizontalLayout.IsReverseHorizontalLayout;
            var leftPadding = bidirectionalHorizontalLayoutGroup.padding.left;
            var rightPadding = bidirectionalHorizontalLayoutGroup.padding.right;
            bidirectionalHorizontalLayoutGroup.padding.left = rightPadding;
            bidirectionalHorizontalLayoutGroup.padding.right = leftPadding;
        }
        else if (rect.TryGetComponent<HorizontalLayoutGroup>(out var horizontalLayoutGroup)&& horizontalLayoutGroup.enabled)
        { 
            var alignment = horizontalLayoutGroup.childAlignment;
            switch (alignment)
            {
                case TextAnchor.LowerLeft:
                    horizontalLayoutGroup.childAlignment = TextAnchor.LowerRight;
                    break;                
                case TextAnchor.LowerRight:
                    horizontalLayoutGroup.childAlignment = TextAnchor.LowerLeft;
                    break;                
                case TextAnchor.MiddleLeft:
                    horizontalLayoutGroup.childAlignment = TextAnchor.MiddleRight;
                    break;                
                case TextAnchor.MiddleRight:
                    horizontalLayoutGroup.childAlignment = TextAnchor.MiddleLeft;
                    break;                
                case TextAnchor.UpperLeft:
                    horizontalLayoutGroup.childAlignment = TextAnchor.UpperRight;
                    break;                
                case TextAnchor.UpperRight:
                    horizontalLayoutGroup.childAlignment = TextAnchor.UpperLeft;
                    break;
            }
            var leftPadding = horizontalLayoutGroup.padding.left;
            var rightPadding = horizontalLayoutGroup.padding.right;
            horizontalLayoutGroup.padding.left = rightPadding;
            horizontalLayoutGroup.padding.right = leftPadding;
        }        
        // else if (rect.TryGetComponent<LoopListView2>(out var loopListView2)&& loopListView2.enabled)
        // {
        //     if (loopListView2.ArrangeType == ListItemArrangeType.LeftToRight)
        //     {
        //         loopListView2.ArrangeType = ListItemArrangeType.RightToLeft;
        //     }
        //     else if(loopListView2.ArrangeType == ListItemArrangeType.RightToLeft)
        //     {
        //         loopListView2.ArrangeType = ListItemArrangeType.LeftToRight;
        //     }
        //
        //     loopListView2.InitArabicItemPrefabData();
        // }
    }
    
    static bool IsProcessChildPos(RectTransform rect)
    {
        if (rect == null)
        {
            return false;
        }
        bool hasHorizonLayout = rect.gameObject.TryGetComponent<HorizontalLayoutGroup>(out var horizonLayout);
        bool hasBiDirectionHorizonLayout = rect.gameObject.TryGetComponent<BidirectionalHorizontalLayoutGroup>(out var bidirectionalHorizontalLayoutGroup);
        bool hasGridLayout = rect.gameObject.TryGetComponent<GridLayoutGroup>(out var gridLayout);
        //bool hasGridInfinityScroll = rect.gameObject.TryGetComponent<GridInfinityScrollView>(out var gridInfinityScrollView);

        return (!hasHorizonLayout || !horizonLayout.enabled) &&
               (!hasBiDirectionHorizonLayout || !bidirectionalHorizontalLayoutGroup.enabled) &&
               (!hasGridLayout || !gridLayout.enabled);
        //(!hasGridInfinityScroll || !gridInfinityScrollView.enabled);
    }

    static bool IsProcessSelf(RectTransform rect, List<GameObject> cullingObjects)
    {
        if (rect == null || cullingObjects.Contains(rect.gameObject))
        {
            return false;
        }

        return true;
    }

    private static void ProcessAllGameObject(List<GameObject> objects, List<SingleMirrorObjectData> objectDatas)
    {
        if (objects == null || objectDatas == null)
        {
            return;
        }
        for (int i = 0; i < objects.Count; i++)
        {
            var gameobject = objects[i];
            if (i < objectDatas.Count)
            {
                var data = objectDatas[i];
                if (gameobject != null && data != null)
                {
                    ApplyDataToGameObject(gameobject, data.mirrorData);
                }
            }
        }
    }
}





