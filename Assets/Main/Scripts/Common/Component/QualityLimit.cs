/**
 * [INPUT]: 依赖 QualityChangeRegistry 的画质变更订阅，依赖 UnityEngine.Rendering.Universal 的 URP 渲染管线资产，通过反射读取 m_RendererDataList 以开关 RenderFeature，依赖 GameDefines 的画质档位常量
 * [OUTPUT]: 对外提供 QualityLimit 组件，Refresh(graphicLv) 按画质档位显隐挂载对象
 * [POS]: Common/Component 的画质自适应节点，注册到 QualityChangeRegistry 被全局画质切换驱动，专管 Grab 层的抓取渲染 Feature 与低配隐藏
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





