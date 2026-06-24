using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class UITextKeyAnimation : MonoBehaviour
{
 
    public static int key = Shader.PropertyToID("_Alpha");
    public float alpha = 1;
    private Material mat;
    private SuperTextMesh textMesh;
    private void Awake()
    {
         textMesh = GetComponent<SuperTextMesh>();

    }
    // Update is called once per frame
    void Update()
    {
        if(textMesh != null)
        {
            alpha = Mathf.Clamp(alpha,0, 1);
            textMesh.OnUpdate(alpha);
        }
    }
}





