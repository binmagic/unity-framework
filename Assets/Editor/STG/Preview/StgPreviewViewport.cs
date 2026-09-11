using UnityEngine;

// 预览画面的离屏渲染：把 __StgPreviewRoot__ 下的预览内容用一台正交相机渲进 RenderTexture，
// 供③时间轴编辑器面板内嵌的"模拟画面"视口显示——不用切到 Scene 视图就能边拖时间轴边看演出。
//
// 与 StgPreviewSceneView 的分工：那边是"接管 Scene 视图相机取景"，给的是可自由缩放/框选的编辑视角；
// 这里是"固定画幅的旁观窗口"，取景严格锁死在 ScreenTopY/BottomY/HalfWidth 围出的竖版画幅上，
// 所见即玩家将来在手机上看到的构图。两者共用同一批预览对象，不重复生成。
//
// 相机 enabled=false + 手动 Render()：避免这台相机被渲染管线当成场景里的正式相机每帧自动渲，
// 渲染时机完全由 StgPreviewRuntime.Tick 决定，和预览时间推进严格同步。
public static class StgPreviewViewport
{
    // 画幅是 8x12 世界单位（竖版 2:3），RT 按同比例取，够看构图又不至于每帧渲太大分辨率
    const int TextureWidth = 320;
    const int TextureHeight = 480;

    static Camera s_Camera;
    static RenderTexture s_Texture;

    public static RenderTexture Texture => s_Texture;
    public static bool IsReady => s_Camera != null && s_Texture != null;

    public static void Create(Transform previewRoot)
    {
        Release();

        s_Texture = new RenderTexture(TextureWidth, TextureHeight, 24, RenderTextureFormat.Default)
        {
            name = "__StgPreviewViewportRT__",
            hideFlags = HideFlags.DontSave,
            antiAliasing = 1,
        };
        s_Texture.Create();

        var go = new GameObject("__StgPreviewViewportCamera__");
        go.hideFlags = HideFlags.DontSave;
        go.transform.SetParent(previewRoot, false);

        float centerY = (StgPreviewRuntime.ScreenTopY + StgPreviewRuntime.ScreenBottomY) * 0.5f;
        go.transform.localPosition = new Vector3(0f, centerY, -10f);
        go.transform.localRotation = Quaternion.identity;

        s_Camera = go.AddComponent<Camera>();
        s_Camera.orthographic = true;
        // 正交 size 是画幅高度的一半，横向由 RT 宽高比推出来，正好等于 ScreenHalfWidth
        s_Camera.orthographicSize = (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY) * 0.5f;
        s_Camera.nearClipPlane = 0.03f;
        s_Camera.farClipPlane = 100f;
        s_Camera.clearFlags = CameraClearFlags.SolidColor;
        s_Camera.backgroundColor = new Color(0.08f, 0.09f, 0.11f, 1f);
        s_Camera.targetTexture = s_Texture;
        s_Camera.enabled = false;
    }

    public static void Render()
    {
        if (!IsReady) return;
        s_Camera.Render();
    }

    public static void Release()
    {
        if (s_Camera != null)
        {
            s_Camera.targetTexture = null;
            if (s_Camera.gameObject != null) Object.DestroyImmediate(s_Camera.gameObject);
            s_Camera = null;
        }
        if (s_Texture != null)
        {
            s_Texture.Release();
            Object.DestroyImmediate(s_Texture);
            s_Texture = null;
        }
    }
}
