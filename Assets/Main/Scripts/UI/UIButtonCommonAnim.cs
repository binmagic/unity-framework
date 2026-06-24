using DG.Tweening;
using UnityEngine;

namespace Main.Scripts.UI
{
    public class UIButtonCommonAnim : MonoBehaviour
    {
        private Vector3 preScale = Vector3.one;
        
        private bool GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction func)
        {
            otherScale = Vector3.one;
			
            // 如果button 有自己的曲线，那么就使用自己的曲线；否则使用公共默认的曲线
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
        
        private bool GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func)
        {
            if (DefaultNewButtonCurve.defaultButtonCurve == null)
            {
                pressedScale = Vector3.one;
                pressedTime = 1;
                func = null;
                return false;
            }
				
            pressedScale = DefaultNewButtonCurve.defaultButtonCurve.m_PressedScale;
            pressedTime = DefaultNewButtonCurve.defaultButtonCurve.m_DoPressedTime;
            func = DefaultNewButtonCurve.defaultPressedEase;

            return true;
        }

        public void TriggerAnimation_Pressed()
        {
            Sequence seq;
            DOTween.Kill(gameObject);
            seq = DOTween.Sequence();
					
            if (GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func))
            {
                preScale = gameObject.transform.localScale;
                Vector3 needScale = Vector3.Scale(preScale, pressedScale);
                seq.Append(this.gameObject.transform.DOScale(needScale, pressedTime)
                    .SetEase(func));
            }
        }

        public void TriggerAnimation_Other()
        {
            Sequence seq;
            DOTween.Kill(gameObject);
            seq = DOTween.Sequence();
            if (GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction otherFunc))
            {
                seq.Append(this.gameObject.transform.DOScale(preScale, otherTime)
                    .SetEase(otherFunc));
            }
        }
    }
}





