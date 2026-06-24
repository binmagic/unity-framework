using System.IO;
using System.Reflection;
using Sfs2X.Entities.Data;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;
[ExecuteAlways]
public class QualityLimit : MonoBehaviour
{
    [SerializeField]
    public bool hideLow = true;
    [SerializeField]  
    GameObject obj;
    
    private void OnEnable()
    {
        QualityChangeRegistry.Instance?.Register(this);
        OnGrabToggle(true);
    }

    private void OnDisable()
    {
        QualityChangeRegistry.Instance?.Unregister(this);
        OnGrabToggle(false);
    }
    void OnGrabToggle(bool isToggle)
    {
        if (gameObject.layer != LayerMask.NameToLayer("Grab"))
        {
            return;
        }
        var pipeline = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        if (pipeline != null)
        {

            // pipeline.supportsMainLightShadows = false;
            FieldInfo propertyInfo = pipeline.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
            int counts = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline)).Length;
            for (int i = 0; i < counts; i++)
            {
                var _scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline))?[i];
                foreach (var feature in _scriptableRendererData.rendererFeatures)
                {
                    if (feature.name == "GrabRenderPassFeature")
                    {
                        if (feature.isActive != isToggle)
                        {
                            feature.SetActive(isToggle);

                        }
                    }

                }

            }



        }

    }
    public void Refresh(int graphicLv)
    {
        if (obj == null)
        {
            return;
        }
        
        if (hideLow)
        {
            obj.SetActive(graphicLv != GameDefines.QualityLevel_Low);
        }
        else
        {
            obj.SetActive(graphicLv == GameDefines.QualityLevel_Low);
        }
    }
}





