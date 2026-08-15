# GFX/
> L2 | 父级: ../../../CLAUDE.md

图形调试控制台：真机可用的 IMGUI 调试台，运行时观察与调节渲染参数。全部集中在 Console 子目录，独立于运行时画质策略（Scene/SceneQualitySetting）。

## 成员清单
Console/GFXConsole.cs: 具体控制台，装配各调试面板并借触控摄像机屏蔽点击，是调试台对外入口
Console/ProfilerGraph.cs: 第三方 Graphy 性能图表的按需实例化与显隐切换（独立于 IMGUI 台）
Console/Base/BaseGFXConsole.cs: 控制台骨架 MonoBehaviour，管理面板列表/分页/IMGUI 窗口绘制
Console/Base/BaseGFXPanel.cs: 面板基类，定义面板名与 Init/DrawGUI 生命周期，是各页签的插件契约
Console/Base/ShowFPS.cs: 独立帧率显示组件，可脱离控制台单挂
Console/Panels/PostProcessGFXPanel.cs: 后处理调试页，开关/调节 URP Volume 效果
Console/Panels/ScreenGFXPanel.cs: 屏幕分辨率调试页，调节 URP renderScale
Console/Panels/ShaderGFXPanel.cs: Shader 调试页，调节全局 ShaderLOD 与 keyword
Console/Panels/QualitySettingGFXPanel.cs: 画质档位调试页，调档位与渲染分辨率上限
Console/Panels/CameraGFXPanel.cs: 摄像机调试页，展示/调节各场景 zoom 与旋转参数
Console/Panels/SceneViewerGFXPanel.cs: 场景查看页，真机浏览对象层级并定位节点
Console/Panels/ShadowGFXPanel.cs: 阴影调试页（整体注释停用，保留占位）

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
