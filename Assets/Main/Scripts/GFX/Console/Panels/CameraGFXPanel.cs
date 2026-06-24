using System.Collections.Generic;
using BitBenderGames;
using UnityEngine;

public class CameraGFXPanel:BaseGFXPanel
{
    private Camera _mainCamera;
    private string camZoomInit;
    private string camZoomMin;
    private string camZoomMax;
    private string camZoom;
    private string camZoomBuild;
    private string camZoomFocusRotation;
    private string camZoomFarmPlant;
    private string camZoomFarmPlantRotation;
    private string camZoomFormation;
    private string camZoomFormationRotation;
    private List<MobileTouchCamera.ZoomParam> zoomParams;

    private bool camToggle;
    
    public CameraGFXPanel() : base("摄像机")
    {
        
    }

    public override void Init()
    {
        _mainCamera = GameObject.FindWithTag("MainCamera").GetComponent<Camera>();
        camToggle = false;
        
        var mobileTouchCamera = _mainCamera.GetComponent<MobileTouchCamera>();
        camZoomInit = mobileTouchCamera.CamZoomInit.ToString();
        camZoomMin = mobileTouchCamera.CamZoomMin.ToString();
        camZoomMax = mobileTouchCamera.CamZoomMax.ToString();
        zoomParams = mobileTouchCamera.GetZoomParams();
        camZoomBuild = mobileTouchCamera.CamZoomBuild.ToString();
        camZoomFocusRotation = mobileTouchCamera.CamZoomFocusRotation.ToString();
        camZoomFarmPlant = mobileTouchCamera.CamZoomFarmPlant.ToString();
        camZoomFarmPlantRotation = mobileTouchCamera.CamZoomFarmPlantRotation.ToString();
        camZoomFormation = mobileTouchCamera.CamZoomFormation.ToString();
        camZoomFormationRotation = mobileTouchCamera.CamZoomFocusFormationRotation.ToString();
    }

    public override void DrawGUI()
    {
        if (_mainCamera == null)
        {
            GUILayout.Label("MainCamera为null，请检查");
            return;
        }
        
        camToggle = GUILayout.Toggle(camToggle, "视锥体");
        if (camToggle)
        {
            _mainCamera.farClipPlane = DrawSlider("FarClip", _mainCamera.farClipPlane, 2, 600);
            _mainCamera.nearClipPlane = DrawSlider("NearClip", _mainCamera.nearClipPlane, 0, 30);
            _mainCamera.fieldOfView = DrawSlider("FOV", _mainCamera.fieldOfView, 30, 80);
        }
        
        GUILayout.Space(30);
        DrawZoomParams();
    }

    private void DrawZoomParams()
    {
        var mobileTouchCamera = _mainCamera.GetComponent<MobileTouchCamera>();
        
        GUILayout.Label("镜头Zoom参数：");
        
        var eulerX = mobileTouchCamera.transform.eulerAngles.x;
        GUILayout.BeginHorizontal();
        GUILayout.Label("当前高：" + mobileTouchCamera.CamZoom);
        // GUILayout.Label("向后偏移：" + (mobileTouchCamera.GetWorldPoint() - mobileTouchCamera.transform.position).z);
        GUILayout.Label("俯仰角：" + eulerX);
        GUILayout.EndHorizontal();
        
        GUILayout.BeginHorizontal();
        camZoomInit = DrawInputField("初始高：", camZoomInit);
        camZoomMin = DrawInputField("最小高: ", camZoomMin);
        camZoomMax = DrawInputField("最大高: ", camZoomMax);
        GUILayout.EndHorizontal();
        
        GUILayout.BeginHorizontal();
        camZoomBuild = DrawInputField("建筑-高", camZoomBuild);
        camZoomFocusRotation = DrawInputField("建筑-俯仰角", camZoomFocusRotation);
        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal();
        camZoomFarmPlant = DrawInputField("农场-高", camZoomFarmPlant);
        camZoomFarmPlantRotation = DrawInputField("农场-俯仰角", camZoomFarmPlantRotation);
        camZoomFormation = DrawInputField("出征-高", camZoomFormation);
        camZoomFormationRotation = DrawInputField("出征-俯仰角", camZoomFormationRotation);
        GUILayout.EndHorizontal();
        
        GUILayout.BeginVertical();
        for (int i = 0; i < zoomParams.Count; i++)
        {
            var p = zoomParams[i];
            GUILayout.BeginHorizontal();
            p.posY = float.Parse(DrawInputField(string.Format("[{0}] 高：", i + 1), p.posY.ToString()));
            p.offsetZ = float.Parse(DrawInputField("向后偏移：", p.offsetZ.ToString()));
            p.sensitivity = float.Parse(DrawInputField("灵敏度：", p.sensitivity.ToString()));
            GUILayout.EndHorizontal();
        }
        
        GUILayout.EndVertical();
        if (GUILayout.Button("确定"))
        {
            mobileTouchCamera.CamZoomInit = float.Parse(camZoomInit);
            mobileTouchCamera.CamZoomMin = float.Parse(camZoomMin);
            mobileTouchCamera.CamZoomMax = float.Parse(camZoomMax);
            mobileTouchCamera.SetZoomParams(zoomParams);
            mobileTouchCamera.CamZoom = float.Parse(camZoomInit);
            mobileTouchCamera.CamZoomBuild = float.Parse(camZoomBuild);
            mobileTouchCamera.CamZoomFocusRotation = float.Parse(camZoomFocusRotation);
            mobileTouchCamera.CamZoomFarmPlant = float.Parse(camZoomFarmPlant);
            mobileTouchCamera.CamZoomFarmPlantRotation = float.Parse(camZoomFarmPlantRotation);
            mobileTouchCamera.CamZoomFormation = float.Parse(camZoomFormation);
            mobileTouchCamera.CamZoomFocusFormationRotation = float.Parse(camZoomFormationRotation);
        }
    }

}





