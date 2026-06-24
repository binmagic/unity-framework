using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace GameKit.Base
{
    public class SingletonParent : SingletonBehaviour<SingletonParent>
    {
        void OnApplicationQuit()
        {
            transform.BroadcastMessage("Release", SendMessageOptions.DontRequireReceiver);
        }
    }

    /// <summary>
    /// Be aware this will not prevent a non singleton constructor
    ///   such as `T myT = new T();`
    /// To prevent that, add `protected T () {}` to your singleton class.
    /// 
    /// As a note, this is made as MonoBehaviour because we need Coroutines.
    /// </summary>
    public class SingletonBehaviour<T> : MonoBehaviour where T : MonoBehaviour
    {
        private static T _instance;

        public static T Instance
        {
            get
            {
                if (applicationIsQuitting)
                {
                    Debug.LogWarning("[Singleton] Instance '" + typeof(T) +
                        "' already destroyed on application quit." +
                        " Won't create again - returning null.");
                    return null;
                }

                if (_instance == null)
                {
                    var objs = FindObjectsOfType<T>();
                    if (objs.Length > 1)
                    {
                        Debug.LogError("[Singleton] Something went really wrong " +
                                       " - there should never be more than 1 singleton!" +
                                       " Reopenning the scene might fix it.");
                        _instance = objs[0];
                    }
                    else if (objs.Length > 0)
                    {
                        _instance = objs[0];
                    }

                    if (_instance == null)
                    {
                        GameObject singleton = new GameObject("(Singleton) " + typeof(T));
                        _instance = singleton.AddComponent<T>();

                        DontDestroyOnLoad(singleton);

                        singleton.transform.SetParent(SingletonParent.Instance.transform);

                        // Debug.Log("[Singleton] An instance of " + typeof(T) +
                        //           " is needed in the scene, so '" + singleton +
                        //           "' was created with DontDestroyOnLoad.");
                    }
                    else
                    {
                        Debug.Log("[Singleton] Using instance already created: " +
                                  _instance.gameObject.name);
                    }
                }

                return _instance;
            }
        }

        private static bool applicationIsQuitting = false;

        public static void DestroyInstance()
        {
            if (Instance != null)
            {
                applicationIsQuitting = true;
                Destroy(_instance.gameObject);
                _instance = null;
            }
        }

        /// <summary>
        /// When Unity quits, it destroys objects in a random order.
        /// In principle, a Singleton is only destroyed when application quits.
        /// If any script calls Instance after it have been destroyed, 
        /// it will create a buggy ghost object that will stay on the Editor scene
        /// even after stopping playing the Application. Really bad!
        /// So, this was made to be sure we're not creating that buggy ghost object.
        /// </summary>
        private void OnDestroy()
        {
            applicationIsQuitting = true;
            _instance = null;
        }

        public enum UpdateMode { FIXED_UPDATE, UPDATE, LATE_UPDATE }
        public UpdateMode updateMode = UpdateMode.UPDATE;
        private void Update()
        {
            if (updateMode == UpdateMode.UPDATE) OnUpdate(Time.deltaTime);
        }

        private void FixedUpdate()
        {
            if (updateMode == UpdateMode.FIXED_UPDATE) OnUpdate(Time.fixedDeltaTime);
        }

        private void LateUpdate()
        {
            if (updateMode == UpdateMode.LATE_UPDATE) OnUpdate(Time.deltaTime);
        }

        protected virtual void OnUpdate(float delta)
        {

        }

        public virtual void Release()
        {
            Debug.Log("[Release] " + gameObject.name);
        }
    }

    public static class ComponentExtensions
    {
        public static T GetOrAddComponent<T>(this Component comp, bool set_enable = false) where T : Component
        {
            T result = comp.GetComponent<T>();
            if (result == null)
                result = comp.gameObject.AddComponent<T>();

            var bcomp = result as Behaviour;
            if (set_enable && bcomp != null)
                bcomp.enabled = set_enable;

            return result;
        }

        public static T GetOrAddComponent<T>(this GameObject go, bool set_enable = false) where T : Component
        {
            T result = go.GetComponent<T>();
            if (result == null)
                result = go.AddComponent<T>();

            var bcomp = result as Behaviour;
            if (set_enable && bcomp != null)
                bcomp.enabled = set_enable;

            return result;
        }

        public static Component GetOrAddComponent(this Component comp, Type type, bool set_enable = false)
        {
            Component result = comp.GetComponent(type);
            if (result == null)
                result = comp.gameObject.AddComponent(type);

            var bcomp = result as Behaviour;
            if (set_enable && bcomp != null)
                bcomp.enabled = set_enable;

            return result;
        }

        public static Component GetOrAddComponent(this GameObject go, Type type, bool set_enable = false)
        {
            Component result = go.GetComponent(type);
            if (result == null)
                result = go.AddComponent(type);

            var bcomp = result as Behaviour;
            if (set_enable && bcomp != null)
                bcomp.enabled = set_enable;

            return result;
        }

        public static void ScrollRect_EndDrag(this ScrollRect scrollRect)
        {
            if (scrollRect == null)
                return;
            PointerEventData eventData = new PointerEventData(null);
            eventData.button = PointerEventData.InputButton.Left;
            scrollRect.OnEndDrag(eventData);
        }

        public static void ScrollView_EndDrag(this ScrollView scrollView)
        {
            if (scrollView == null)
                return;
            PointerEventData eventData = new PointerEventData(null);
            eventData.button = PointerEventData.InputButton.Left;
            scrollView.OnEndDrag(eventData);
        }
    }

    public static class TransformExtentions
    {
        public static Transform GetOrAddTransform(this Transform parent, string childName, Vector3 position, Vector3 roll)
        {
            Transform t = GetOrAddTransform(parent, childName);
            if (t != null)
            {
                t.localPosition = position;
                t.localRotation = Quaternion.Euler(roll);
            }

            return t;
        }

        public static Transform GetOrAddTransform(this Transform parent, string childName, Vector3 position, Quaternion rotation)
        {
            Transform t = GetOrAddTransform(parent, childName);
            if (t != null)
            {
                t.localPosition = position;
                t.localRotation = rotation;
            }

            return t;
        }

        public static Transform GetOrAddTransform(this Transform parent, string childName)
        {
            Transform t = parent.Find(childName);
            if (t == null)
            {
                t = new GameObject(childName).transform;
                t.SetParent(parent, false);
            }

            return t;
        }
    }
}





