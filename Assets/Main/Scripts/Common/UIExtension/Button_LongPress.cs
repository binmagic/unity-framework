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





