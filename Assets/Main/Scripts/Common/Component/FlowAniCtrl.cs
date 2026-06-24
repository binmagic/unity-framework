using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
[ExecuteAlways]
public class FlowAniCtrl : MonoBehaviour
{
    public float _Tick;
    public float _Power;
    private static int _TickId = Shader.PropertyToID("_Tick");
    private static int _PowerId = Shader.PropertyToID("_Power");
    private Material mat;
    private void Awake()
    {
        var image = GetComponent<Image>();
        if(image!=null)
        {
            mat = image.material;
        }
  
    }
    void Update()
    {
        if(mat==null)
        {
            return;
        }
        mat.SetFloat(_TickId, _Tick);
        mat.SetFloat(_PowerId, _Power);
   
    }
    private void OnDestroy()
    {
    
    }
}





