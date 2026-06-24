// using UnityEngine;
//
// public class ShadowGFXPanel:BaseGFXPanel
// {
//     private Light _mainLight;
//     public ShadowGFXPanel() : base("Shadow")
//     {
//         
//     }
//
//     public override void Init()
//     {
//         _mainLight = GameObject.Find("Directional Light").GetComponent<Light>();
//     }
//
//     public override void DrawGUI()
//     {
//         //开关影子
//         if (_mainLight)
//         {
//             GUILayout.Label("主灯影子模式:" + _mainLight.shadows.ToString());
//             GUILayout.BeginHorizontal();
//             if (GUILayout.Button("Hard"))
//             {
//                 _mainLight.shadows = LightShadows.Hard;
//             }
//
//             if (GUILayout.Button("Soft"))
//             {
//                 _mainLight.shadows = LightShadows.Soft;
//             }
//
//             if (GUILayout.Button("None"))
//             {
//                 _mainLight.shadows = LightShadows.None;
//             }
//
//             GUILayout.EndHorizontal();
//         }
//
//
//         //影子分辨率
//         GUILayout.Space(30);
//         GUILayout.Label("影子精度:"+QualitySettings.shadowResolution.ToString());
//         GUILayout.BeginHorizontal();
//         if (GUILayout.Button("超高"))
//         {
//             QualitySettings.shadowResolution = ShadowResolution.VeryHigh;
//         }
//         if (GUILayout.Button("高"))
//         {
//             QualitySettings.shadowResolution = ShadowResolution.High;
//         }
//         if (GUILayout.Button("中"))
//         {
//             QualitySettings.shadowResolution = ShadowResolution.Medium;
//         }
//         if (GUILayout.Button("低"))
//         {
//             QualitySettings.shadowResolution = ShadowResolution.Low;
//         }
//         GUILayout.EndHorizontal();
//         
//         //影子距离
//         GUILayout.Space(30);
//         QualitySettings.shadowDistance = DrawSlider("ShadowDistance", QualitySettings.shadowDistance, 5, 150);
//         
//         //影子防抖
//         GUILayout.Space(30);
//         GUILayout.Label("影子防抖:"+QualitySettings.shadowProjection.ToString());
//         GUILayout.BeginHorizontal();
//         if (GUILayout.Button("StableFit"))
//         {
//             QualitySettings.shadowProjection = ShadowProjection.StableFit;
//         }
//         if (GUILayout.Button("CloseFit"))
//         {
//             QualitySettings.shadowProjection = ShadowProjection.CloseFit;
//         }
//         GUILayout.EndHorizontal();
//     }
// }





