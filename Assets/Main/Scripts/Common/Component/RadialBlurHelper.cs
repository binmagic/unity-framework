using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class RadialBlurHelper : MonoBehaviour
{
    [Range(0, 1)] public float ScreenX = 0.5f;
    [Range(0, 1)] public float ScreenY = 0.5f;
    [Range(1, 8)] public int loop = 5;
    [Range(1, 8)] public float blur = 3;
    [Range(1, 5)] public int downsample = 2;
    [Range(0, 1)] public float instensity = 0.5f;
    public string featureName = "RadialBlur";
    private ScriptableRendererFeature myFeature;
    private MethodInfo updateParamMethod;
    private void OnEnable()
    {
        ToggleBlur(true);

    }
    private void OnDisable()
    {
        ToggleBlur(false);

    }
    void ToggleBlur(bool toggle)
    {
        var pipeline = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        if (pipeline != null)
        {

            // pipeline.supportsMainLightShadows = false;
            FieldInfo propertyInfo = pipeline.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
            int counts = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline)).Length;
            bool isFind = false;
            for (int i = 0; i < counts; i++)
            {
                var _scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline))?[i];
                foreach (var feature in _scriptableRendererData.rendererFeatures)
                {
                    if (feature.name == featureName)
                    {
                        feature.SetActive(toggle);
                        myFeature = feature;
                        updateParamMethod = feature.GetType().GetMethod("UpdateParam",
                            BindingFlags.Instance | BindingFlags.Public);
                        isFind = true;
                        break;
                    }

                }
                if (isFind)
                {
                  //  _scriptableRendererData.SetDirty();

                }
           
            }
           


        }
    }



    // Update is called once per frame
    void Update()
    {
        if (myFeature != null && updateParamMethod != null)
        {
            updateParamMethod.Invoke(myFeature,
                new object[] { ScreenX, ScreenY, loop, blur, downsample, instensity });
        }
    }
}





