/**
 * [INPUT]: 依赖 UnityEngine.EventSystems 的指针点击/按下/抬起接口
 * [OUTPUT]: 对外提供 ClickEventListener 组件、静态 Get 挂载入口与单击/双击/按下/抬起事件的委托注册接口
 * [POS]: SuperScrollView 的通用点击事件适配器，把 UGUI 指针事件转成可动态绑定的委托，供列表 item 按需附加交互回调
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace SuperScrollView
{
    public class ClickEventListener : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerUpHandler
    {
        public static ClickEventListener Get(GameObject obj)
        {
            ClickEventListener listener = obj.GetComponent<ClickEventListener>();
            if (listener == null)
            {
                listener = obj.AddComponent<ClickEventListener>();
            }
            return listener;
        }

        System.Action<GameObject> mClickedHandler = null;
        System.Action<GameObject> mDoubleClickedHandler = null;
        System.Action<GameObject> mOnPointerDownHandler = null;
        System.Action<GameObject> mOnPointerUpHandler = null;
        bool mIsPressed = false;

        public bool IsPressd
        {
            get { return mIsPressed; }
        }
        public void OnPointerClick(PointerEventData eventData)
        {
            if (eventData.clickCount == 2)
            {
                if (mDoubleClickedHandler != null)
                {
                    mDoubleClickedHandler(gameObject);
                }
            }
            else
            {
                if (mClickedHandler != null)
                {
                    mClickedHandler(gameObject);
                }
            }

        }
        public void SetClickEventHandler(System.Action<GameObject> handler)
        {
            mClickedHandler = handler;
        }

        public void SetDoubleClickEventHandler(System.Action<GameObject> handler)
        {
            mDoubleClickedHandler = handler;
        }

        public void SetPointerDownHandler(System.Action<GameObject> handler)
        {
            mOnPointerDownHandler = handler;
        }

        public void SetPointerUpHandler(System.Action<GameObject> handler)
        {
            mOnPointerUpHandler = handler;
        }


        public void OnPointerDown(PointerEventData eventData)
        {
            mIsPressed = true;
            if (mOnPointerDownHandler != null)
            {
                mOnPointerDownHandler(gameObject);
            }
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            mIsPressed = false;
            if (mOnPointerUpHandler != null)
            {
                mOnPointerUpHandler(gameObject);
            }
        }

    }

}





