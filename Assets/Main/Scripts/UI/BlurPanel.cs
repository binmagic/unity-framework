using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Tayx.Graphy.Utils.NumString;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BlurMgr
{
    private int index = 0;
    private bool m_isToggle = false;
    private GameObject m_blurCamera;
    private Canvas m_rootCanvas;
    private Camera m_uiCamera;
    private BlurMgr()
    {
        m_blurCamera = GameObject.Find(FrameworkEnv.BlurCameraPath);
        m_rootCanvas = GameObject.Find(FrameworkEnv.UIContainerPath).GetComponent<Canvas>();
        m_uiCamera = GameObject.Find(FrameworkEnv.UICameraPath).GetComponent<Camera>();
    }

    private static BlurMgr _inst;

    public static BlurMgr Inst()
    {
        if (_inst == null)
            _inst = new BlurMgr();
        return _inst;
    }

    public void Register()
    {
        index++;
        CheckStatus();
    }

    public void UnRegister()
    {
        index--;
        CheckStatus();
    }

    void CheckStatus()
    {
        bool visible = false;
        if (index > 0)
            visible = true;
        
        ToggleRenderFeature(visible);
        m_blurCamera.SetActive(visible);
        if (visible == false)
        {
            m_rootCanvas.worldCamera = m_uiCamera;
        }
    }

    public void ToggleRenderFeature(bool isToggle)
    {
        if (isToggle == m_isToggle)
            return;
        m_isToggle = isToggle;
        m_blurCamera.SetActive(isToggle);
        var pipeline = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        if (pipeline != null)
        {
            FieldInfo propertyInfo = pipeline.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
            var _scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline))?[0];
            foreach (var feature in _scriptableRendererData.rendererFeatures)
            {
                if (feature != null && feature.name.StartsWith("BlurURP"))
                {
                    feature.SetActive(isToggle);
                }
            }
            _scriptableRendererData.SetDirty();
        }
    }
}

/// <summary>
/// 这个需要替换canvas的camera为blurcamera,同时父节点的节点设置为blurroot的节点下
/// </summary>
public class BlurPanel : MonoBehaviour
{
    private Transform m_transParent;

    private Transform m_objBlur;
    // Start is called before the first frame update
    void OnEnable()
    {
        m_transParent = transform.parent;
        m_objBlur = transform.Find("Blur");
        m_objBlur.gameObject.SetActive(false);
        StartCoroutine(ChangeCanvas());
        BlurMgr.Inst().Register();
    }
    
    IEnumerator ChangeCanvas()
    {
        yield return new WaitForSeconds(0);
        var canvas = m_transParent.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceCamera;
        var blurCamera = GameObject.Find(FrameworkEnv.BlurCameraPath).GetComponent<Camera>();
        canvas.worldCamera = blurCamera;
        m_objBlur.gameObject.SetActive(true);
    }

    private void OnDisable()
    {
        BlurMgr.Inst().UnRegister();
    }
}





