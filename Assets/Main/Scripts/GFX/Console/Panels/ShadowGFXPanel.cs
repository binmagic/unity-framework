/**
 * [INPUT]: 依赖 UnityEngine 的 Light/主光(实现整体注释停用中)
 * [OUTPUT]: 曾对外提供 ShadowGFXPanel,用于运行时调节主光与阴影参数;当前整体注释未启用
 * [POS]: GFX/Console/Panels 的阴影调试页,已在 GFXConsole 装配中禁用,保留为后续恢复的占位
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





