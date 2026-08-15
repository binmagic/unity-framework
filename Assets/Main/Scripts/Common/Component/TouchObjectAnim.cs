/**
 * [INPUT]: 依赖 DG.Tweening 做缩放缓动，依赖 DefaultNewButtonCurve 提供全局按压曲线（缩放/时长/缓动函数）
 * [OUTPUT]: 对外提供 TouchObjectAnim 组件与 ShowClickPressAnim/HideClickPressAnim 两个按压反馈接口
 * [POS]: GEgineRunTime 命名空间下 Common/Component 的点击按压动画器，把全局按钮曲线配置应用到任意可点击对象，通常由 TouchObjectEventTrigger 的点击事件驱动
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using DG.Tweening;
using UnityEngine;

namespace GEgineRunTime
{
    public class TouchObjectAnim : MonoBehaviour
    {
        public bool    useRecordScale;
        public Vector3 useScale;
        
        private bool GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func)
        {
            if (DefaultNewButtonCurve.defaultButtonCurve == null)
            {
                pressedScale = Vector3.one;
                pressedTime = 1;
                func = null;
                return false;
            }

            if (useRecordScale)
            {
                pressedScale = Vector3.Scale( DefaultNewButtonCurve.defaultButtonCurve.m_PressedScale, transform.localScale);

            }
            else
            {
                pressedScale = DefaultNewButtonCurve.defaultButtonCurve.m_PressedScale;
            }
            pressedTime = DefaultNewButtonCurve.defaultButtonCurve.m_DoPressedTime;
            func = DefaultNewButtonCurve.defaultPressedEase;

            return true;
        }
        
        private bool GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction func)
        {
            if (useRecordScale)
            {
                otherScale = useScale;

            }
            else
            {
                otherScale = Vector3.one;
            }
			
            if (DefaultNewButtonCurve.defaultButtonCurve == null)
            {
                otherTime = 1;
                func = null;
                return false;
            }

            otherTime = DefaultNewButtonCurve.defaultButtonCurve.m_DoOtherTime;
            func = DefaultNewButtonCurve.defaultOtherEase;

            return true;
        }
        
        public void ShowClickPressAnim()
        {
            Sequence seq;
            DOTween.Kill(gameObject);
            seq = DOTween.Sequence();
					
            if (GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func))
            {
                seq.Append(this.gameObject.transform.DOScale(pressedScale, pressedTime)
                    .SetEase(func));
            }
        }

        public void HideClickPressAnim()
        {
            Sequence seq;
            DOTween.Kill(gameObject);
            seq = DOTween.Sequence();
            if (GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction otherFunc))
            {
                seq.Append(this.gameObject.transform.DOScale(otherScale, otherTime)
                    .SetEase(otherFunc));
            }
        }
    }
}





