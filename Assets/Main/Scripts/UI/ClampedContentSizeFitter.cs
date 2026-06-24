using UnityEngine;
using UnityEngine.UI;

namespace Main.Scripts.UI
{
    public class ClampedContentSizeFitter : ContentSizeFitter
    {
#pragma warning disable IDE1006 // 命名样式
        [SerializeField] private float m_MaxWidth = -1;
        public float maxWdith { get => m_MaxWidth; set { m_MaxWidth = value; SetDirty(); } }
 
        [SerializeField] private float m_MaxHeight = -1;
        public float maxHeight { get => m_MaxHeight; set { m_MaxHeight = value; SetDirty(); } }
 
        [System.NonSerialized] private RectTransform m_Rect;
        private RectTransform rectTransform
        {
            get
            {
                if (m_Rect == null)
                    m_Rect = GetComponent<RectTransform>();
                return m_Rect;
            }
        }
#pragma warning restore IDE1006 // 命名样式
 
        private DrivenRectTransformTracker m_Tracker;
 
        protected ClampedContentSizeFitter()
        { }
 
        protected override void OnDisable()
        {
            m_Tracker.Clear();
            LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
        }
 
        private void HandleSelfFittingAlongAxis(int axis)
        {
            FitMode fitting = (axis == 0 ? horizontalFit : verticalFit);
            if (fitting == FitMode.Unconstrained)
            {
                m_Tracker.Add(this, rectTransform, DrivenTransformProperties.None);
                return;
            }
 
            m_Tracker.Add(this, rectTransform, (axis == 0 ? DrivenTransformProperties.SizeDeltaX : DrivenTransformProperties.SizeDeltaY));
 
            var maxValue = axis == 0 ? m_MaxWidth : m_MaxHeight;
            if (fitting == FitMode.MinSize)
                rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)axis, maxValue >= 0 ? Mathf.Min(LayoutUtility.GetMinSize(m_Rect, axis), maxValue) : LayoutUtility.GetMinSize(m_Rect, axis));
            else
                rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)axis, maxValue >= 0 ? Mathf.Min(LayoutUtility.GetPreferredSize(m_Rect, axis), maxValue) : LayoutUtility.GetPreferredSize(m_Rect, axis));
        }
 
        public override void SetLayoutHorizontal()
        {
            m_Tracker.Clear();
            HandleSelfFittingAlongAxis(0);
        }
 
        public override void SetLayoutVertical()
        {
            HandleSelfFittingAlongAxis(1);
        }
    }
}





