using System;
using UnityEngine;

public class ColliderEventHandler : MonoBehaviour
{
    public string action;
    public string param;
    
    //静态全局处理函数 内部按action进行分发
    public static Action<GameObject, GameObject, string, string> OnCollisionEnterGlobal { get; set; }
    public static Action<GameObject, GameObject, string, string> OnCollisionExitGlobal { get; set; }
    public static Action<GameObject, GameObject,  string, string> OnTriggerEnterGlobal { get; set; }
    public static Action<GameObject, GameObject,  string, string> OnTriggerExitGlobal { get; set; }

    //对象自身的处理函数 如果没有设置 就走默认全局处理函数
    public Action<GameObject> OnCollisionEnterAction { get; set; }
    public Action<GameObject> OnCollisionExitAction { get; set; }
    
    public Action<GameObject> OnTriggerEnterAction { get; set; }
    public Action<GameObject> OnTriggerExitAction { get; set; }
    
    private void OnEnable()
    {
        /*if (SceneManager.World != null)
        {
            SceneManager.World.RegisterPhysics(this);
        }*/
    }

    private void OnDisable()
    {
        /*if (SceneManager.World != null)
        {
            SceneManager.World.UnregisterPhysics(this);
        }*/
    }
    
    private void OnCollisionEnter(Collision other)
    {
        if (OnCollisionEnterAction != null)
        {
            OnCollisionEnterAction?.Invoke(other.gameObject);
        }
        else
        {
            OnCollisionEnterGlobal?.Invoke(gameObject, other.gameObject, action, param);
        }
    }

    private void OnCollisionExit(Collision other)
    {
        if (OnCollisionExitAction != null)
        {
            OnCollisionExitAction?.Invoke(other.gameObject);
        }
        else
        {
            OnCollisionExitGlobal?.Invoke(gameObject, other.gameObject, action, param);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (OnTriggerEnterAction != null)
        {
            OnTriggerEnterAction?.Invoke(other.gameObject);
        }
        else
        {
            OnTriggerEnterGlobal?.Invoke(gameObject, other.gameObject, action, param);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (OnTriggerExitAction != null)
        {
            OnTriggerExitAction?.Invoke(other.gameObject);
        }
        else
        {
            OnTriggerExitGlobal?.Invoke(gameObject, other.gameObject, action, param);
        }
    }
}





