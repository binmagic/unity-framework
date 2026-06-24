using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostProcessGFXPanel : BaseGFXPanel
{
    private Camera _mainCamera;
    private Volume _ppVolume;

    public PostProcessGFXPanel() : base("后期") { }

    public override void Init()
    {
        _mainCamera = GameObject.FindWithTag("MainCamera").GetComponent<Camera>();
        _ppVolume = GameObject.FindObjectOfType(typeof(Volume)) as Volume;
    }

    public override void DrawGUI()
    {
        if (_mainCamera == null || _ppVolume == null)
        {
            GUILayout.Label("MainCamera或者Volum为null，请检查");
            return;
        }

        //后期
        GUILayout.Space(30);

        if (GUILayout.Button("开关后期:" + _ppVolume.enabled))
        {
            _ppVolume.enabled = !_ppVolume.enabled;
            _mainCamera.GetComponent<UniversalAdditionalCameraData>().renderPostProcessing = _ppVolume.enabled;
        }

        GUILayout.Space(30);
        if (_ppVolume.enabled)
        {
            var pp = _ppVolume.profile;
            var list = new List<VolumeComponent>();
            pp.TryGetAllSubclassOf(typeof(VolumeComponent), list);
            foreach (var com in list)
            {
                DoDrawPostProcessingModle(com);
            }
        }
    }

    private void DoDrawPostProcessingModle(VolumeComponent com)
    {
        if (GUILayout.Button(com.GetType().Name + " 开关:" + com.active))
        {
            com.active = !com.active;
        }
    }
}





