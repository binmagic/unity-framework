/**
 * [INPUT]: 继承 BaseGFXPanel,依赖 URP 的 Volume 后处理栈与主摄像机
 * [OUTPUT]: 对外提供 PostProcessGFXPanel,运行时开关/调节后处理 Volume 各效果
 * [POS]: GFX/Console/Panels 的后处理调试页,现场对比 Bloom/色调等效果开销与观感
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





