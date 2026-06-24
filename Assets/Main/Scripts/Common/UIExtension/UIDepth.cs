using UnityEngine;
using System.Collections;
using UnityEngine.UI;
[ExecuteAlways]
public class UIDepth : MonoBehaviour
{
    public int order;
    public bool isUI = true;

    public bool isUpdate = false;
    void Start()
    {
        if (isUI)
        {
            Canvas canvas = GetComponent<Canvas>();
            if (canvas == null)
            {
                canvas = gameObject.AddComponent<Canvas>();
            }
            canvas.overrideSorting = true;
            canvas.sortingOrder = order;
        }
        else
        {
            Renderer[] renders = GetComponentsInChildren<Renderer>();

            foreach (Renderer render in renders)
            {
                render.sortingOrder = order;
            }
        }
    }

    private void FixedUpdate()
    {
        if (isUpdate)
        {
            Start();
            isUpdate = false;
        }
    }
}





