//  ***
//  * Created by zhangliheng.
//  * DateTime: 2025/02/18 5:04 PM
//  * Description: 动态模糊
//  ***/

#if UNITY_EDITOR
using Sirenix.OdinInspector;
#endif
using System;
using System.Collections;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;
public class AnimateBlur : MonoBehaviour
{
    [SerializeField] private RawImage rawImage;
    [SerializeField] private Material material;
    [SerializeField] private float duration = 2;
    [SerializeField] private float wait = 0.5f;
    [SerializeField] private float MaxRadius = 3;
    [SerializeField] private float MaxIterations = 4;
    
    
    private static readonly int BlurRadius = Shader.PropertyToID("_BlurRadius");
    private static readonly int Iterations = Shader.PropertyToID("_Iterations");

    private void OnEnable()
    {
        ToggleRendererFeature(true);
        
        rawImage.material = material;
        rawImage.enabled = false;
        material.SetFloat(BlurRadius, 0);
        material.SetFloat(Iterations, 0);
        
        float minScale = 0f; 
        float maxScale = 2f;
        StartCoroutine(DoFade(duration));
    }

    private void OnDisable()
    {
        ToggleRendererFeature(false);
    }

    private IEnumerator DoFade(float duration)
    {
        yield return null;
        rawImage.enabled = true;
        
        var halfDuration = duration / 2f;
        var elapsed = 0f;

        while (elapsed < halfDuration)
        {
            elapsed += Time.deltaTime;
            var t = elapsed / halfDuration;
            
            var radius = Mathf.Lerp(0, MaxRadius, t);
            material.SetFloat(BlurRadius, radius);
            var iterations = Mathf.Lerp(0, MaxIterations, t);
            material.SetFloat(Iterations, iterations);

            yield return null;
        }

        yield return new WaitForSeconds(wait);

        elapsed = 0f;
        while (elapsed < halfDuration)
        {
            elapsed += Time.deltaTime;
            var t = elapsed / halfDuration;
            var radius = Mathf.Lerp(MaxRadius, 0, t);
            material.SetFloat(BlurRadius, radius);
            var iterations = Mathf.Lerp(MaxIterations, 0, t);
            material.SetFloat(Iterations, iterations);
            yield return null;
        }

        rawImage.enabled = false;
        gameObject.SetActive(false);
    }
    
    private void ToggleRendererFeature(bool enable)
    {
        var pipeline = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        if (pipeline != null)
        {
            FieldInfo propertyInfo = pipeline.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
            var scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline))?[0];
            if (scriptableRendererData != null)
            {
                foreach (var feature in scriptableRendererData.rendererFeatures)
                {
                    if (feature.name == "GrabRenderPassFeature")
                    {
                        feature.SetActive(enable);
                    }
                }

                scriptableRendererData.SetDirty();
            }
        }
        
    }
}
