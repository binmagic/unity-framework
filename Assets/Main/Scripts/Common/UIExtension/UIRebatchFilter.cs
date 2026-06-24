using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine.UI;
 
public class UIRebatchFilter : MonoBehaviour
{
#if UNITY_EDITOR
    public bool m_IsStart = false;
    IList<ICanvasElement> m_LayoutRebuildQueue;
    IList<ICanvasElement> m_GraphicRebuildQueue;
 
    private void Start()
    {
        System.Type type = typeof(CanvasUpdateRegistry);
        FieldInfo field = type.GetField("m_LayoutRebuildQueue", BindingFlags.NonPublic | BindingFlags.Instance);
        m_LayoutRebuildQueue = (IList<ICanvasElement>)field.GetValue(CanvasUpdateRegistry.instance);
        field = type.GetField("m_GraphicRebuildQueue", BindingFlags.NonPublic | BindingFlags.Instance);
        m_GraphicRebuildQueue = (IList<ICanvasElement>)field.GetValue(CanvasUpdateRegistry.instance);
    }

    private string GetAbsolutePath(Transform transform)
    {
        string _path = "";
        while (transform != null)
        {
            _path = string.Format("{0}/{1}", transform.name, _path);
            transform = transform.parent;
        }

        return _path;
    }

    private void LateUpdate()
    {
        if (m_IsStart == false)
            return;
        for (int j = 0; j < m_LayoutRebuildQueue.Count; j++)
        {
            var rebuild = m_LayoutRebuildQueue[j];
            if (ObjectValidForUpdate(rebuild))
            {
                Debug.LogFormat(">>>Rebuild {0} 引起 {1} 网格重建 Type: {2}", GetAbsolutePath(rebuild.transform), rebuild.transform.GetComponent<Graphic>().canvas.name, rebuild.GetType().ToString());
            }
        }
 
        for (int j = 0; j < m_GraphicRebuildQueue.Count; j++)
        {
            var element = m_GraphicRebuildQueue[j];
            if (ObjectValidForUpdate(element))
            {
                Debug.LogFormat(">>>Rebuild {0} 引起 {1} 网格重建 Type: {2}", GetAbsolutePath(element.transform), element.transform.GetComponent<Graphic>().canvas.name, element.GetType().ToString());
            }
        }
    }
    private bool ObjectValidForUpdate(ICanvasElement element)
    {
        var valid = element != null;
 
        var isUnityObject = element is Object;
        if (isUnityObject)
            valid = (element as Object) != null; //Here we make use of the overloaded UnityEngine.Object == null, that checks if the native object is alive.
 
        return valid;
    }
#endif
}





