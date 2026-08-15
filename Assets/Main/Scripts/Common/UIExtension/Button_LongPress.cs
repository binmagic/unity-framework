/**
 * [INPUT]: 依赖 UnityEngine.EventSystems 的指针事件接口，依赖 GameEntry.Event 派发 EventId.Btn_LongPress，操作子物体的 Image 做按压变灰
 * [OUTPUT]: 对外提供 Button_LongPress 组件及 SetLongPressAction/SetClickAction/SetTouchBgGray 注入回调的接口
 * [POS]: UIExtension 的按钮交互扩展，在原生点击之上叠加长按识别，区分短按点击与长按触发两种回调
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System;
using UnityEngine.EventSystems;

namespace UnityEngine.UI
{
    public class Button_LongPress : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler
    {
        private Color32 gray = new Color32(235, 235, 235, 255);
        
        public float pressDurationTime = 2;
        public bool onceLongPress = false;

        private Action longPressAction;
        private Action clickAction;
        private Image[] bgImage;
        private bool _touchGray = false;

        public void SetTouchBgGray(bool gray)
        {
            _touchGray = gray;
        }

        public void SetLongPressAction(Action _action)
        {
            longPressAction = _action;
        }

        public void SetClickAction(Action action)
        {
            clickAction = action;
        }

        private void Start()
        {
            bgImage = GetComponentsInChildren<Image>();
        }

        private bool isDown = false;
        private float downTime = 0;
        private bool donelongPressAction = false;

        private void Update()
        {
            if (!isDown)
                return;
            downTime += Time.deltaTime;
            if (downTime > pressDurationTime)
            {
                if (onceLongPress)
                {
                    isDown = false;
                }

                donelongPressAction = true;
                downTime = 0;
                longPressAction?.Invoke();
            }
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            isDown = true;
            downTime = 0.0f;
            donelongPressAction = false;
            if (bgImage != null && _touchGray)
            {
                for (int i = 0; i < bgImage.Length; ++i)
                    bgImage[i].color = gray;
            }
            GameEntry.Event.Fire(EventId.Btn_LongPress,true);
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (bgImage != null && _touchGray)
            {
                for (int i = 0; i < bgImage.Length; ++i)
                    bgImage[i].color = Color.white;
            }
            isDown = false;
            
            GameEntry.Event.Fire(EventId.Btn_LongPress,false);
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (donelongPressAction == false && downTime < pressDurationTime)
            {
                clickAction?.Invoke();
            }
        }
    }
}





