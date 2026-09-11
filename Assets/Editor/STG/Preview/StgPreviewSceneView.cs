using UnityEditor;
using UnityEngine;

// 预览专用 Scene 视图接管与状态浮层，详见关卡编辑器设计文档 4.2 节
// 复用 Unity 原生 Scene 视图渲染 GameObject/Sprite，不额外写 RenderTexture 手工渲染管线
//
// 实现说明：状态浮层原计划用 UnityEditor.Overlays.Overlay（Unity 2021+ 的 Scene 视图工具栏系统），
// 但项目内检索不到 SceneView 按类型查找/挂载 Overlay 的确切方法签名可供核对（只找到按字符串 ID 查找
// 已注册 Overlay 的 TryGetOverlay 用法，没有"新建并挂载一个 Overlay 实例"的确切调用方式），为避免
// 凭记忆写出编译不过的 API 调用，改用自 Unity 早期版本起就稳定存在的 SceneView.duringSceneGui +
// IMGUI 手绘浮层，效果等价（左上角文字状态 + 停止按钮），且不依赖未经核实的 API。
public static class StgPreviewSceneView
{
    class SavedCameraState
    {
        public Vector3 pivot;
        public Quaternion rotation;
        public float size;
        public bool orthographic;
        public bool in2DMode;
    }

    static SceneView s_TargetSceneView;
    static SavedCameraState s_SavedState;
    static string s_StatusText = "";

    // 关卡画幅取景：竖版卷轴，size 取上下边界跨度的 0.7 倍，留出边距
    public static void EnterPreviewView()
    {
        var sceneView = SceneView.lastActiveSceneView ?? EditorWindow.GetWindow<SceneView>();
        s_TargetSceneView = sceneView;

        s_SavedState = new SavedCameraState
        {
            pivot = sceneView.pivot,
            rotation = sceneView.rotation,
            size = sceneView.size,
            orthographic = sceneView.orthographic,
            in2DMode = sceneView.in2DMode,
        };

        sceneView.in2DMode = true;
        sceneView.orthographic = true;
        sceneView.rotation = Quaternion.identity;
        sceneView.pivot = new Vector3(0f, (StgPreviewRuntime.ScreenTopY + StgPreviewRuntime.ScreenBottomY) * 0.5f, 0f);
        sceneView.size = (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY) * 0.7f;
        sceneView.Repaint();

        s_StatusText = "STG 预览中 · 0.0s / 0.0s";
        SceneView.duringSceneGui += OnDuringSceneGui;
    }

    public static void ExitPreviewView()
    {
        SceneView.duringSceneGui -= OnDuringSceneGui;

        if (s_TargetSceneView != null && s_SavedState != null)
        {
            s_TargetSceneView.in2DMode = s_SavedState.in2DMode;
            s_TargetSceneView.orthographic = s_SavedState.orthographic;
            s_TargetSceneView.rotation = s_SavedState.rotation;
            s_TargetSceneView.pivot = s_SavedState.pivot;
            s_TargetSceneView.size = s_SavedState.size;
            s_TargetSceneView.Repaint();
        }

        s_TargetSceneView = null;
        s_SavedState = null;
    }

    public static void UpdateOverlayText(float previewTime, float duration, int loopCount, int placeholderFallbackCount)
    {
        string text = $"STG 预览中 · 当前时间 {previewTime:F1}s / {duration:F1}s";
        if (loopCount > 0) text += $"　已循环 {loopCount} 次";
        if (placeholderFallbackCount > 0) text += $"\n⚠ {placeholderFallbackCount} 个对象使用占位图形（资源缺失或加载失败）";
        s_StatusText = text;
    }

    static void OnDuringSceneGui(SceneView sceneView)
    {
        Handles.BeginGUI();

        var rect = new Rect(8, 8, 260, 54);
        GUI.Box(rect, GUIContent.none);

        var labelRect = new Rect(rect.x + 6, rect.y + 4, rect.width - 12, 32);
        GUI.Label(labelRect, s_StatusText);

        var buttonRect = new Rect(rect.x + 6, rect.y + rect.height - 22, rect.width - 12, 18);
        if (GUI.Button(buttonRect, "停止预览"))
        {
            StgPreviewRuntime.Stop();
        }

        Handles.EndGUI();
    }
}
