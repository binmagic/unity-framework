using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using UiScrollView = UnityEngine.UIElements.ScrollView;

// ③ 时间轴编辑器（路径A：纯 UIElements，不依赖 GraphView，见关卡编辑器设计文档第一节/第五节）
//
// 已实现：轨道分组渲染、事件块按时间定位、拖拽改时间(0.5s吸附)、点击单选(详情编辑)、
// 框选多选(仅用于批量删除)、右键菜单(删除/复制/新增)、滚轮缩放、播放头点击定位、
// 播放预览(接入 StgPreviewRuntime，见设计文档第四节《预览运行时设计》，Scene 视图实际生成/演出关卡内容)。
//
// 已知简化(相对设计文档的降级点，供后续迭代)：
// - 事件块宽度按类型粗略估算(show_banner/pause_enemy_spawn 用 duration 字段，其余固定1秒宽)，不做像素级精确对齐
// - 右键"跳转模板编辑"简化为拷贝ID到剪贴板+提示，未做跨面板自动选中(需要各面板暴露选中API，超出本轮范围)
// - 空格+拖动平移未实现，用滚动条/触控板横向滚动代替(ScrollView 自带)
public class TimelineEditorPanel : IStgPanel
{
    public string TabTitle => "③ 时间轴编辑器";
    public VisualElement Root { get; }

    class TrackDef
    {
        public string Label;
        public Color Color;
        public HashSet<string> EventTypes;
    }

    static readonly TrackDef[] Tracks = new[]
    {
        new TrackDef { Label = "全局事件", Color = new Color(0.55f, 0.55f, 0.55f), EventTypes = new HashSet<string> { "change_scroll_speed", "show_banner", "play_bgm", "pause_enemy_spawn", "resume_enemy_spawn", "level_complete", "game_over", "trigger_cutscene" } },
        new TrackDef { Label = "小怪波次", Color = new Color(0.12f, 0.53f, 0.90f), EventTypes = new HashSet<string> { "spawn_enemy_wave", "spawn_area_start", "spawn_area_stop" } },
        new TrackDef { Label = "Boss", Color = new Color(0.90f, 0.22f, 0.21f), EventTypes = new HashSet<string> { "spawn_boss" } },
        new TrackDef { Label = "机关", Color = new Color(0.98f, 0.55f, 0.0f), EventTypes = new HashSet<string> { "spawn_trap", "drop_digital_gate" } },
        new TrackDef { Label = "物品投放", Color = new Color(0.26f, 0.65f, 0.28f), EventTypes = new HashSet<string> { "spawn_item" } },
    };

    static readonly (string type, string label)[] AddableEventTypes = new[]
    {
        ("spawn_enemy_wave", "生成小怪波次"),
        ("spawn_area_start", "开启持续刷怪区域"),
        ("spawn_area_stop", "关闭持续刷怪区域"),
        ("spawn_boss", "生成 Boss"),
        ("spawn_trap", "生成机关"),
        ("drop_digital_gate", "抛撒数字门"),
        ("spawn_item", "投放物品"),
        ("change_scroll_speed", "改变卷轴速度"),
        ("show_banner", "显示横幅"),
        ("play_bgm", "播放BGM"),
        ("pause_enemy_spawn", "暂停刷怪"),
        ("resume_enemy_spawn", "恢复刷怪"),
        ("trigger_cutscene", "触发过场"),
        ("level_complete", "关卡通关"),
        ("game_over", "关卡失败"),
    };

    const float TrackHeight = 36f;
    const float TrackGap = 4f;
    const float RulerHeight = 22f;
    const float BlockHeight = 24f;
    const float LabelColumnWidth = 90f;
    const float MinPixelsPerSecond = 2f;
    const float MaxPixelsPerSecond = 60f;
    const float SnapSeconds = 0.5f;
    // 内嵌模拟画面：列宽给足边距，画面本体按 2:3 竖版比例（对应 StgPreviewViewport 的 RT 尺寸）
    const float ViewportColumnWidth = 220f;
    const float ViewportFrameWidth = 200f;
    // 播放头：抓手比竖线宽得多，才好按住拖（竖线只有 2px，直接拖极难命中）
    const float PlayheadHandleWidth = 13f;
    const float PlayheadLineWidth = 2f;
    static readonly Color PlayheadColor = new Color(0.92f, 0.26f, 0.21f);
    static readonly Color PlayheadActiveColor = new Color(1f, 0.45f, 0.35f);

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_LabelColumn;
    readonly UiScrollView m_ScrollView;
    readonly VisualElement m_TimelineContent;
    // 播放头三件套：容器(定位) + 顶部抓手(可拖) + 竖线(纯视觉)
    readonly VisualElement m_Playhead;
    readonly VisualElement m_PlayheadHandle;
    readonly VisualElement m_PlayheadLine;
    readonly VisualElement m_SelectionBox;
    readonly VisualElement m_InspectorHost;
    readonly Label m_ZoomLabel;
    readonly Button m_PlayButton;

    // 内嵌模拟画面：m_ViewportImage 的 image 指向 StgPreviewViewport 的 RenderTexture，
    // 每帧靠 MarkDirtyRepaint 重绘（RT 内容变了但元素本身没变，UIElements 不会自动重绘）
    readonly Image m_ViewportImage;
    readonly Label m_ViewportHud;
    readonly VisualElement m_ViewportIdleHint;

    float m_PixelsPerSecond = 10f;
    // 播放头位置改由 StgPreviewRuntime.PreviewTime 驱动（预览运行中）；未播放时 m_PreviewTime 是本地暂存的
    // "手动定位/待播放起点"，与《关卡编辑器设计文档》4.6 节"播放起点默认从当前播放头位置开始"对应
    float m_PreviewTime = 0f;

    readonly List<VisualElement> m_BlockElements = new List<VisualElement>();
    readonly HashSet<StgTimelineEvent> m_MultiSelected = new HashSet<StgTimelineEvent>();
    StgTimelineEvent m_SingleSelected;

    Vector2 m_MarqueeStart;
    bool m_IsMarqueeSelecting;
    // 播放头拖拽前是否处于自动播放：松手后据此决定恢复推进还是保持暂停
    bool m_ScrubResumeAfterDrag;

    public TimelineEditorPanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        Root.style.flexDirection = FlexDirection.Column;
        Root.style.flexGrow = 1;
        Root.focusable = true;

        var toolbar = new VisualElement();
        toolbar.style.flexDirection = FlexDirection.Row;
        toolbar.style.marginBottom = 4;
        Root.Add(toolbar);

        m_PlayButton = new Button(TogglePlay) { text = "▶ 播放预览" };
        toolbar.Add(m_PlayButton);

        // 内嵌视口的三个元素在这里 new 出来，样式与父子关系在 BuildViewportColumn 里统一设置
        m_ViewportImage = new Image();
        m_ViewportHud = new Label();
        m_ViewportIdleHint = new VisualElement();

        var zoomOutButton = new Button(() => SetZoom(m_PixelsPerSecond - 4f)) { text = "－" };
        var zoomInButton = new Button(() => SetZoom(m_PixelsPerSecond + 4f)) { text = "＋" };
        m_ZoomLabel = new Label();
        m_ZoomLabel.style.marginLeft = 8;
        m_ZoomLabel.style.marginRight = 8;
        m_ZoomLabel.style.unityTextAlign = TextAnchor.MiddleCenter;
        toolbar.Add(zoomOutButton);
        toolbar.Add(m_ZoomLabel);
        toolbar.Add(zoomInButton);

        var durationField = new FloatField("关卡时长(秒)");
        durationField.style.marginLeft = 16;
        durationField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.timeline.duration = Mathf.Max(1f, evt.newValue);
            m_Context.MarkDirty();
            RebuildTimeline();
        });
        durationField.name = "durationField";
        toolbar.Add(durationField);

        var autoDurationButton = new Button(() =>
        {
            float maxTime = m_Context.Model.timeline.events.Count > 0 ? m_Context.Model.timeline.events.Max(e => e.time) : 0f;
            m_Context.Model.timeline.duration = Mathf.Max(1f, maxTime + 5f);
            m_Context.MarkDirty();
            RebuildTimeline();
        })
        { text = "按最后事件自动计算时长" };
        toolbar.Add(autoDurationButton);

        // 主体分两列：左列是时间轴+详情检查器（原有内容），右列是内嵌的模拟画面视口
        var bodyRow = new VisualElement();
        bodyRow.style.flexDirection = FlexDirection.Row;
        bodyRow.style.flexGrow = 1;
        Root.Add(bodyRow);

        var editorColumn = new VisualElement();
        editorColumn.style.flexDirection = FlexDirection.Column;
        editorColumn.style.flexGrow = 1;
        bodyRow.Add(editorColumn);

        var splitRow = new VisualElement();
        splitRow.style.flexDirection = FlexDirection.Row;
        splitRow.style.flexGrow = 1;
        editorColumn.Add(splitRow);

        m_LabelColumn = new VisualElement();
        m_LabelColumn.style.width = LabelColumnWidth;
        m_LabelColumn.style.flexShrink = 0;
        splitRow.Add(m_LabelColumn);

        m_ScrollView = new UiScrollView(ScrollViewMode.Horizontal);
        m_ScrollView.style.flexGrow = 1;
        m_ScrollView.style.borderLeftWidth = 1;
        m_ScrollView.style.borderLeftColor = new Color(0.2f, 0.2f, 0.2f);
        splitRow.Add(m_ScrollView);

        m_TimelineContent = new VisualElement();
        m_TimelineContent.style.position = Position.Relative;
        m_ScrollView.Add(m_TimelineContent);

        // 播放头 = 容器(不拦截点击) + 顶部抓手(可拖) + 竖线(不拦截点击)。
        // 容器与竖线必须 PickingMode.Ignore：播放头竖线穿过所有轨道，若整条都可拾取会挡住底下事件块的点击。
        // 抓手只占刻度尺那一段高度，是主要拖拽目标；刻度尺本身也支持按下即拖（见 BuildRuler），两者共用擦洗逻辑。
        m_Playhead = new VisualElement();
        m_Playhead.style.position = Position.Absolute;
        m_Playhead.style.top = 0;
        m_Playhead.style.width = PlayheadHandleWidth;
        m_Playhead.pickingMode = PickingMode.Ignore;
        m_TimelineContent.Add(m_Playhead);

        m_PlayheadHandle = new VisualElement();
        m_PlayheadHandle.style.position = Position.Absolute;
        m_PlayheadHandle.style.left = 0;
        m_PlayheadHandle.style.top = 0;
        m_PlayheadHandle.style.width = PlayheadHandleWidth;
        m_PlayheadHandle.style.height = RulerHeight;
        m_PlayheadHandle.style.backgroundColor = PlayheadColor;
        m_PlayheadHandle.style.borderTopLeftRadius = 3;
        m_PlayheadHandle.style.borderTopRightRadius = 3;
        m_PlayheadHandle.style.borderBottomLeftRadius = 3;
        m_PlayheadHandle.style.borderBottomRightRadius = 3;
        m_PlayheadHandle.style.justifyContent = Justify.Center;
        m_PlayheadHandle.style.alignItems = Align.Center;
        m_PlayheadHandle.tooltip = "拖动以擦洗预览时间";
        // 抓手上画三条竖纹，形成"可抓握"的视觉暗示
        var gripRow = new VisualElement();
        gripRow.style.flexDirection = FlexDirection.Row;
        gripRow.pickingMode = PickingMode.Ignore;
        for (int i = 0; i < 3; i++)
        {
            var grip = new VisualElement();
            grip.style.width = 1;
            grip.style.height = 8;
            grip.style.marginLeft = 1;
            grip.style.marginRight = 1;
            grip.style.backgroundColor = new Color(1f, 1f, 1f, 0.75f);
            grip.pickingMode = PickingMode.Ignore;
            gripRow.Add(grip);
        }
        m_PlayheadHandle.Add(gripRow);
        m_PlayheadHandle.RegisterCallback<PointerDownEvent>(OnPlayheadHandlePointerDown);
        m_Playhead.Add(m_PlayheadHandle);

        m_PlayheadLine = new VisualElement();
        m_PlayheadLine.style.position = Position.Absolute;
        m_PlayheadLine.style.left = (PlayheadHandleWidth - PlayheadLineWidth) * 0.5f;
        m_PlayheadLine.style.top = 0;
        m_PlayheadLine.style.width = PlayheadLineWidth;
        m_PlayheadLine.style.backgroundColor = PlayheadColor;
        m_PlayheadLine.pickingMode = PickingMode.Ignore;
        m_Playhead.Add(m_PlayheadLine);

        m_SelectionBox = new VisualElement();
        m_SelectionBox.style.position = Position.Absolute;
        m_SelectionBox.style.backgroundColor = new Color(0.3f, 0.5f, 0.9f, 0.2f);
        m_SelectionBox.style.borderLeftWidth = 1;
        m_SelectionBox.style.borderLeftColor = new Color(0.4f, 0.6f, 1f);
        m_SelectionBox.style.borderRightWidth = 1;
        m_SelectionBox.style.borderRightColor = new Color(0.4f, 0.6f, 1f);
        m_SelectionBox.style.display = DisplayStyle.None;
        m_SelectionBox.pickingMode = PickingMode.Ignore;
        m_TimelineContent.Add(m_SelectionBox);

        m_InspectorHost = new VisualElement();
        m_InspectorHost.style.minHeight = 160;
        m_InspectorHost.style.borderTopWidth = 1;
        m_InspectorHost.style.borderTopColor = new Color(0.2f, 0.2f, 0.2f);
        m_InspectorHost.style.paddingLeft = 8;
        m_InspectorHost.style.paddingTop = 6;
        editorColumn.Add(m_InspectorHost);

        bodyRow.Add(BuildViewportColumn());

        Root.RegisterCallback<WheelEvent>(OnWheel, TrickleDown.TrickleDown);
        Root.RegisterCallback<KeyDownEvent>(OnKeyDown);

        // 只注册一次：m_TimelineContent 实例不会被重建，RebuildTimeline 只清空/重建其子元素，
        // 若把这两行放进 BuildTracksAndRuler（每次 RebuildTimeline 都会调用），回调会重复叠加
        m_TimelineContent.RegisterCallback<PointerDownEvent>(OnEmptyAreaPointerDown);
        m_TimelineContent.AddManipulator(new ContextualMenuManipulator(BuildEmptyAreaContextMenu));

        RebuildTimeline();
    }

    // ---------- 内嵌模拟画面视口 ----------

    // 右侧固定宽度一列：标题 + 竖版画幅画面 + 状态文字。画面按 StgPreviewViewport 的 RT 宽高比（2:3）留位置，
    // 未播放时显示提示文字占位，播放中换成 RT 画面。
    VisualElement BuildViewportColumn()
    {
        var column = new VisualElement();
        column.style.width = ViewportColumnWidth;
        column.style.flexShrink = 0;
        column.style.borderLeftWidth = 1;
        column.style.borderLeftColor = new Color(0.2f, 0.2f, 0.2f);
        column.style.paddingLeft = 8;
        column.style.paddingRight = 4;

        var title = new Label("模拟画面（跟随播放头）");
        title.style.unityFontStyleAndWeight = FontStyle.Bold;
        title.style.marginBottom = 4;
        column.Add(title);

        // 画面容器：固定 2:3 竖版比例，内部叠放 RT 画面与未播放时的提示，二者互斥显示
        var frame = new VisualElement();
        frame.style.width = ViewportFrameWidth;
        frame.style.height = ViewportFrameWidth * 1.5f;
        frame.style.backgroundColor = new Color(0.08f, 0.09f, 0.11f);
        frame.style.borderTopWidth = 1;
        frame.style.borderBottomWidth = 1;
        frame.style.borderLeftWidth = 1;
        frame.style.borderRightWidth = 1;
        var frameBorder = new Color(0.25f, 0.25f, 0.25f);
        frame.style.borderTopColor = frameBorder;
        frame.style.borderBottomColor = frameBorder;
        frame.style.borderLeftColor = frameBorder;
        frame.style.borderRightColor = frameBorder;
        column.Add(frame);

        m_ViewportImage.style.position = Position.Absolute;
        m_ViewportImage.style.left = 0;
        m_ViewportImage.style.top = 0;
        m_ViewportImage.style.width = ViewportFrameWidth;
        m_ViewportImage.style.height = ViewportFrameWidth * 1.5f;
        m_ViewportImage.scaleMode = ScaleMode.ScaleToFit;
        m_ViewportImage.style.display = DisplayStyle.None;
        frame.Add(m_ViewportImage);

        m_ViewportIdleHint.style.position = Position.Absolute;
        m_ViewportIdleHint.style.left = 0;
        m_ViewportIdleHint.style.top = 0;
        m_ViewportIdleHint.style.width = ViewportFrameWidth;
        m_ViewportIdleHint.style.height = ViewportFrameWidth * 1.5f;
        m_ViewportIdleHint.style.justifyContent = Justify.Center;
        m_ViewportIdleHint.style.alignItems = Align.Center;
        var hintLabel = new Label("点击「▶ 播放预览」\n在此模拟关卡演出");
        hintLabel.style.color = new Color(0.55f, 0.55f, 0.55f);
        hintLabel.style.fontSize = 11;
        hintLabel.style.unityTextAlign = TextAnchor.MiddleCenter;
        m_ViewportIdleHint.Add(hintLabel);
        frame.Add(m_ViewportIdleHint);

        m_ViewportHud.style.marginTop = 4;
        m_ViewportHud.style.fontSize = 10;
        m_ViewportHud.style.color = new Color(0.7f, 0.7f, 0.7f);
        m_ViewportHud.style.whiteSpace = WhiteSpace.Normal;
        column.Add(m_ViewportHud);

        column.Add(StgUiUtil.HintLabel("画幅锁定为竖版取景，与 Scene 视图预览共用同一批对象；点击刻度尺跳转时画面同步刷新。"));

        return column;
    }

    // 每帧由 StgPreviewRuntime.OnFrameRendered 调用：把 RT 绑上去、强制重绘、刷新状态文字
    void OnPreviewFrameRendered()
    {
        if (!StgPreviewViewport.IsReady)
        {
            SetViewportPlaying(false);
            return;
        }

        SetViewportPlaying(true);
        if (m_ViewportImage.image != StgPreviewViewport.Texture)
        {
            m_ViewportImage.image = StgPreviewViewport.Texture;
        }
        // RT 内容每帧都在变，但 Image 元素本身的属性没变，UIElements 不会自动重绘，必须显式标脏
        m_ViewportImage.MarkDirtyRepaint();

        string hud = $"{StgPreviewRuntime.PreviewTime:F1}s / {m_Context.Model.timeline.duration:F1}s";
        if (StgPreviewRuntime.IsPaused) hud += "　⏸ 已暂停";
        if (StgPreviewRuntime.LoopCount > 0) hud += $"　已循环 {StgPreviewRuntime.LoopCount} 次";
        if (StgPreviewRuntime.PlaceholderFallbackCount > 0) hud += $"\n⚠ {StgPreviewRuntime.PlaceholderFallbackCount} 个对象使用占位图形";
        m_ViewportHud.text = hud;
    }

    void SetViewportPlaying(bool playing)
    {
        m_ViewportImage.style.display = playing ? DisplayStyle.Flex : DisplayStyle.None;
        m_ViewportIdleHint.style.display = playing ? DisplayStyle.None : DisplayStyle.Flex;
        if (!playing)
        {
            m_ViewportImage.image = null;
            m_ViewportHud.text = "";
        }
    }

    void OnKeyDown(KeyDownEvent evt)
    {
        if (evt.keyCode == KeyCode.Delete || evt.keyCode == KeyCode.Backspace)
        {
            DeleteSelected();
            evt.StopPropagation();
        }
    }

    void SetZoom(float pixelsPerSecond)
    {
        m_PixelsPerSecond = Mathf.Clamp(pixelsPerSecond, MinPixelsPerSecond, MaxPixelsPerSecond);
        RebuildTimeline();
    }

    void OnWheel(WheelEvent evt)
    {
        if (!m_TimelineContent.worldBound.Contains(evt.mousePosition)) return;
        SetZoom(m_PixelsPerSecond - evt.delta.y * 0.6f);
        evt.StopPropagation();
    }

    // 播放预览：接入编辑器态预览运行时（见关卡编辑器设计文档第四节），点击后在 Scene 视图里实际生成/演出关卡内容，
    // 不再是本类自己驱动一条空转的播放头（原实现见本文件历史版本的 TogglePlay/OnEditorUpdate）
    void TogglePlay()
    {
        if (StgPreviewRuntime.IsPlaying && StgPreviewRuntime.IsPaused)
        {
            // 擦洗后停在某一刻：此时按钮语义是"继续播放"，从当前播放头位置恢复推进，而不是结束会话
            StgPreviewRuntime.SetPaused(false);
        }
        else if (StgPreviewRuntime.IsPlaying)
        {
            StgPreviewRuntime.Stop();
        }
        else
        {
            StgPreviewRuntime.Start(m_Context, m_PreviewTime);
        }
        RefreshPlayButtonText();

        if (StgPreviewRuntime.IsPlaying)
        {
            AttachPreviewCallbacks();
        }
        else
        {
            DetachPreviewCallbacks();
            SetViewportPlaying(false);
        }
    }

    // 会话回调的订阅集中在这两个方法里：TogglePlay 和 BeginScrub 两条起会话的路径都要挂上，
    // 否则会话被面板外部停掉时（Scene 浮层停止按钮/窗口关闭）拿不到收尾时机，视口会残留旧画面
    void AttachPreviewCallbacks()
    {
        // 先退订再订阅，避免重复起会话叠加多次回调（同 m_TimelineContent 那处只注册一次的理由）
        EditorApplication.update -= OnPlayheadFollowUpdate;
        EditorApplication.update += OnPlayheadFollowUpdate;
        StgPreviewRuntime.OnFrameRendered -= OnPreviewFrameRendered;
        StgPreviewRuntime.OnFrameRendered += OnPreviewFrameRendered;
    }

    void DetachPreviewCallbacks()
    {
        EditorApplication.update -= OnPlayheadFollowUpdate;
        StgPreviewRuntime.OnFrameRendered -= OnPreviewFrameRendered;
    }

    // 预览运行中，每帧从 StgPreviewRuntime.PreviewTime 读取当前时间，驱动播放头 UI 位置前进
    // （详见设计文档 4.6 节"播放头与预览时间联动"：previewTime 是同一个变量，UI 侧只做只读展示）
    void OnPlayheadFollowUpdate()
    {
        if (!StgPreviewRuntime.IsPlaying)
        {
            // 预览可能被面板外部停掉（Scene 视图浮层的停止按钮 / 主窗口关闭 / 模型被整体替换），
            // 这里统一收尾：退订帧回调并把内嵌视口切回未播放态
            DetachPreviewCallbacks();
            SetViewportPlaying(false);
            RefreshPlayButtonText();
            return;
        }

        // 暂停中（擦洗态/拖完停住）时间不推进，播放头位置由 ApplyScrubTime 直接控制，
        // 这里不能回读 PreviewTime 覆盖它，否则与鼠标位置抢夺控制权
        if (StgPreviewRuntime.IsPaused) return;

        m_PreviewTime = StgPreviewRuntime.PreviewTime;
        UpdatePlayheadPosition();
    }

    void RefreshPlayButtonText()
    {
        if (!StgPreviewRuntime.IsPlaying)
        {
            m_PlayButton.text = "▶ 播放预览";
        }
        else
        {
            // 暂停态（拖完停在某一刻）给出"继续"语义，避免按钮一直显示"停止"让人以为没在暂停
            m_PlayButton.text = StgPreviewRuntime.IsPaused ? "▶ 继续播放" : "⏸ 停止预览";
        }
    }

    // 容器整体左移半个抓手宽度，让竖线（居中于容器）精确落在时间点对应的像素上，
    // 否则抓手变宽后播放头会整体偏右半个抓手的距离
    void UpdatePlayheadPosition()
    {
        m_Playhead.style.left = m_PreviewTime * m_PixelsPerSecond - PlayheadHandleWidth * 0.5f;
    }

    // ---------- 播放头拖拽擦洗 ----------

    // 拖动播放头：按下即进入擦洗态（暂停时间自动推进），移动实时 SeekTo 让模拟画面停在对应时刻，
    // 松手后恢复到拖动前的播放/暂停状态。
    //
    // 未开预览时按需起一个 startPaused 的会话：否则拖动只能移动一条红线、右侧画面一片空白，
    // 达不到"拖到哪就看到哪一刻"的目的。
    void OnPlayheadHandlePointerDown(PointerDownEvent evt)
    {
        if (evt.button != 0) return;
        evt.StopPropagation();
        BeginScrub(m_PlayheadHandle, evt.pointerId, evt.position.x, m_PreviewTime);
    }

    void BeginScrub(VisualElement target, int pointerId, float startMouseX, float startTime)
    {
        // 记录拖动前是否在自动播放：松手后据此决定要不要恢复推进
        m_ScrubResumeAfterDrag = StgPreviewRuntime.IsPlaying && !StgPreviewRuntime.IsPaused;

        if (!StgPreviewRuntime.IsPlaying)
        {
            // 按需起会话：暂停态启动，时间完全由下面的 SeekTo 驱动。
            // skipValidationPrompt：擦洗途中绝不能弹模态框——它会打断拖拽并阻塞编辑器主线程等待点击
            StgPreviewRuntime.Start(m_Context, startTime, startPaused: true, skipValidationPrompt: true);
            RefreshPlayButtonText();
            // 会话若因故没起来（例如运行时内部提前返回），降级为"只移动红线"，不再尝试擦洗
            if (StgPreviewRuntime.IsPlaying)
            {
                AttachPreviewCallbacks();
            }
        }
        else
        {
            StgPreviewRuntime.SetPaused(true);
        }

        m_PlayheadHandle.style.backgroundColor = PlayheadActiveColor;
        m_PlayheadLine.style.backgroundColor = PlayheadActiveColor;

        target.CapturePointer(pointerId);

        void OnMove(PointerMoveEvent moveEvt)
        {
            float deltaSeconds = (moveEvt.position.x - startMouseX) / m_PixelsPerSecond;
            ApplyScrubTime(startTime + deltaSeconds);
        }

        void OnUp(PointerUpEvent upEvt)
        {
            target.ReleasePointer(upEvt.pointerId);
            target.UnregisterCallback<PointerMoveEvent>(OnMove);
            target.UnregisterCallback<PointerUpEvent>(OnUp);
            EndScrub();
        }

        target.RegisterCallback<PointerMoveEvent>(OnMove);
        target.RegisterCallback<PointerUpEvent>(OnUp);
    }

    // 擦洗不做 0.5s 吸附：事件块拖拽需要吸附以对齐时间点，但擦洗要的是连续平滑地看画面变化
    void ApplyScrubTime(float time)
    {
        float clamped = Mathf.Clamp(time, 0f, Mathf.Max(0.01f, m_Context.Model.timeline.duration));
        m_PreviewTime = clamped;
        UpdatePlayheadPosition();

        if (StgPreviewRuntime.IsPlaying)
        {
            // SeekTo 内部会重渲视口并触发 OnFrameRendered，模拟画面因此同步到该时刻
            StgPreviewRuntime.SeekTo(clamped);
        }
    }

    void EndScrub()
    {
        m_PlayheadHandle.style.backgroundColor = PlayheadColor;
        m_PlayheadLine.style.backgroundColor = PlayheadColor;

        // 拖动前在播放就继续播；拖动前是停止/暂停的，保持暂停停在当前画面，方便逐帧核对构图
        if (StgPreviewRuntime.IsPlaying)
        {
            StgPreviewRuntime.SetPaused(!m_ScrubResumeAfterDrag);
        }
        RefreshPlayButtonText();
    }

    // ---------- 布局重建 ----------

    void RebuildTimeline()
    {
        var durationField = Root.Q<FloatField>("durationField");
        durationField?.SetValueWithoutNotify(m_Context.Model.timeline.duration);
        m_ZoomLabel.text = $"{m_PixelsPerSecond:F0} px/s";

        BuildLabelColumn();
        BuildTracksAndRuler();
        RebuildInspector();
    }

    void BuildLabelColumn()
    {
        m_LabelColumn.Clear();

        var rulerSpacer = new VisualElement();
        rulerSpacer.style.height = RulerHeight;
        m_LabelColumn.Add(rulerSpacer);

        for (int i = 0; i < Tracks.Length; i++)
        {
            var row = new VisualElement();
            row.style.height = TrackHeight;
            row.style.marginBottom = TrackGap;
            row.style.justifyContent = Justify.Center;
            row.style.paddingLeft = 4;
            row.style.backgroundColor = new Color(Tracks[i].Color.r, Tracks[i].Color.g, Tracks[i].Color.b, 0.15f);

            var label = new Label(Tracks[i].Label);
            label.style.fontSize = 11;
            label.style.unityFontStyleAndWeight = FontStyle.Bold;
            row.Add(label);
            m_LabelColumn.Add(row);
        }
    }

    void BuildTracksAndRuler()
    {
        var events = m_Context.Model.timeline.events;
        float maxEventTime = events.Count > 0 ? events.Max(e => e.time) : 0f;
        float duration = Mathf.Max(m_Context.Model.timeline.duration, maxEventTime + 2f);
        float contentWidth = duration * m_PixelsPerSecond + 40f;
        float contentHeight = RulerHeight + Tracks.Length * (TrackHeight + TrackGap);

        m_TimelineContent.style.width = contentWidth;
        m_TimelineContent.style.height = contentHeight;

        // 清空除播放头/框选框外的所有子元素后重建。
        // 保留的是 m_Playhead（播放头容器，抓手与竖线是它的子元素），不是 m_PlayheadLine——
        // 竖线已不再是 m_TimelineContent 的直接子元素，按竖线过滤会把整个播放头连带抓手一起删掉。
        var toRemove = m_TimelineContent.Children().Where(c => c != m_Playhead && c != m_SelectionBox).ToList();
        foreach (var c in toRemove) m_TimelineContent.Remove(c);
        m_BlockElements.Clear();

        BuildRuler(contentWidth, duration);
        BuildTrackBackgrounds(contentWidth);
        BuildEventBlocks(events);

        // 容器与竖线都要撑满内容高度：容器负责定位，竖线负责贯穿所有轨道
        m_Playhead.style.height = contentHeight;
        m_PlayheadLine.style.height = contentHeight;
        // 抓手叠在刻度尺之上，必须让播放头排在最后，否则会被后建的刻度尺/轨道背景盖住而点不到
        m_Playhead.BringToFront();
        UpdatePlayheadPosition();
    }

    void BuildRuler(float contentWidth, float duration)
    {
        var ruler = new VisualElement();
        ruler.style.position = Position.Absolute;
        ruler.style.left = 0;
        ruler.style.top = 0;
        ruler.style.width = contentWidth;
        ruler.style.height = RulerHeight;
        ruler.style.backgroundColor = new Color(0.12f, 0.12f, 0.12f);
        ruler.pickingMode = PickingMode.Position;
        ruler.tooltip = "点击定位、按住拖动可擦洗预览时间";
        // 刻度尺整条都可按下即拖：比 13px 的抓手好命中得多，是"更容易拖动时间轴"的主要入口。
        // 按下先跳到点击位置，再以该位置为基准进入擦洗，手感与 Unity 原生 Timeline 一致。
        ruler.RegisterCallback<PointerDownEvent>(evt =>
        {
            if (evt.button != 0) return;
            evt.StopPropagation();

            var localPos = ruler.WorldToLocal(evt.position);
            float target = Mathf.Max(0f, localPos.x / m_PixelsPerSecond);
            ApplyScrubTime(target);
            BeginScrub(ruler, evt.pointerId, evt.position.x, m_PreviewTime);
        });

        float tickInterval = m_PixelsPerSecond >= 20f ? 1f : (m_PixelsPerSecond >= 8f ? 5f : 10f);
        for (float t = 0; t <= duration; t += tickInterval)
        {
            var tick = new Label($"{t:F0}s");
            tick.style.position = Position.Absolute;
            tick.style.left = t * m_PixelsPerSecond;
            tick.style.top = 2;
            tick.style.fontSize = 9;
            tick.style.color = new Color(0.7f, 0.7f, 0.7f);
            tick.pickingMode = PickingMode.Ignore;
            ruler.Add(tick);
        }

        m_TimelineContent.Insert(0, ruler);
    }

    void BuildTrackBackgrounds(float contentWidth)
    {
        for (int i = 0; i < Tracks.Length; i++)
        {
            var row = new VisualElement();
            row.style.position = Position.Absolute;
            row.style.left = 0;
            row.style.top = RulerHeight + i * (TrackHeight + TrackGap);
            row.style.width = contentWidth;
            row.style.height = TrackHeight;
            row.style.backgroundColor = new Color(Tracks[i].Color.r, Tracks[i].Color.g, Tracks[i].Color.b, 0.06f);
            row.pickingMode = PickingMode.Ignore;
            m_TimelineContent.Add(row);
        }
    }

    int GetTrackIndex(string eventType)
    {
        for (int i = 0; i < Tracks.Length; i++)
        {
            if (Tracks[i].EventTypes.Contains(eventType)) return i;
        }
        return 0;
    }

    float GetBlockDurationSeconds(StgTimelineEvent e)
    {
        switch (e.type)
        {
            case "show_banner":
            case "pause_enemy_spawn":
                return Mathf.Max(0.5f, e.duration);
            default:
                return 1f;
        }
    }

    string GetEventLabel(StgTimelineEvent e)
    {
        switch (e.type)
        {
            case "spawn_enemy_wave": return string.IsNullOrEmpty(e.templateId) ? "波次(未选模板)" : e.templateId;
            case "spawn_boss": return string.IsNullOrEmpty(e.bossId) ? "Boss(未选)" : e.bossId;
            case "spawn_trap": return string.IsNullOrEmpty(e.trapId) ? "机关(未选)" : e.trapId;
            case "drop_digital_gate": return "抛撒数字门";
            case "spawn_area_start": return string.IsNullOrEmpty(e.spawnAreaId) ? "开启刷怪区域" : $"开启:{e.spawnAreaId}";
            case "spawn_area_stop": return string.IsNullOrEmpty(e.spawnAreaId) ? "关闭刷怪区域" : $"关闭:{e.spawnAreaId}";
            case "spawn_item": return string.IsNullOrEmpty(e.itemId) ? "投放物品" : e.itemId;
            case "change_scroll_speed": return $"变速→{e.speed:F0}";
            case "show_banner": return string.IsNullOrEmpty(e.text) ? "横幅" : e.text;
            case "play_bgm": return string.IsNullOrEmpty(e.bgmId) ? "BGM" : e.bgmId;
            case "pause_enemy_spawn": return "暂停刷怪";
            case "resume_enemy_spawn": return "恢复刷怪";
            case "trigger_cutscene": return string.IsNullOrEmpty(e.cutsceneId) ? "过场" : e.cutsceneId;
            case "level_complete": return "通关";
            case "game_over": return "失败";
            default: return e.type;
        }
    }

    void BuildEventBlocks(List<StgTimelineEvent> events)
    {
        foreach (var e in events)
        {
            int trackIndex = GetTrackIndex(e.type);
            float durationSeconds = GetBlockDurationSeconds(e);

            var block = new VisualElement();
            block.userData = e;
            block.style.position = Position.Absolute;
            block.style.left = e.time * m_PixelsPerSecond;
            block.style.top = RulerHeight + trackIndex * (TrackHeight + TrackGap) + (TrackHeight - BlockHeight) / 2f;
            block.style.width = Mathf.Max(24f, durationSeconds * m_PixelsPerSecond);
            block.style.height = BlockHeight;
            block.style.backgroundColor = Tracks[trackIndex].Color;
            block.style.borderTopLeftRadius = 4;
            block.style.borderTopRightRadius = 4;
            block.style.borderBottomLeftRadius = 4;
            block.style.borderBottomRightRadius = 4;
            block.style.overflow = Overflow.Hidden;

            var label = new Label(GetEventLabel(e));
            label.style.fontSize = 9;
            label.style.color = Color.white;
            label.style.unityTextAlign = TextAnchor.MiddleCenter;
            label.pickingMode = PickingMode.Ignore;
            block.Add(label);

            ApplySelectionVisual(block, e);

            block.RegisterCallback<PointerDownEvent>(evt => OnBlockPointerDown(evt, block, e));
            block.AddManipulator(new ContextualMenuManipulator(menuEvt => BuildBlockContextMenu(menuEvt, e)));

            m_TimelineContent.Add(block);
            m_BlockElements.Add(block);
        }
    }

    void ApplySelectionVisual(VisualElement block, StgTimelineEvent e)
    {
        bool selected = e == m_SingleSelected || m_MultiSelected.Contains(e);
        block.style.borderTopWidth = selected ? 2 : 0;
        block.style.borderBottomWidth = selected ? 2 : 0;
        block.style.borderLeftWidth = selected ? 2 : 0;
        block.style.borderRightWidth = selected ? 2 : 0;
        var borderColor = new Color(1f, 1f, 1f, 0.9f);
        block.style.borderTopColor = borderColor;
        block.style.borderBottomColor = borderColor;
        block.style.borderLeftColor = borderColor;
        block.style.borderRightColor = borderColor;
    }

    // ---------- 拖拽移动事件时间 ----------

    void OnBlockPointerDown(PointerDownEvent evt, VisualElement block, StgTimelineEvent e)
    {
        if (evt.button != 0) return;
        evt.StopPropagation();

        if (!evt.shiftKey)
        {
            m_MultiSelected.Clear();
        }
        m_SingleSelected = e;
        RefreshAllBlockSelectionVisuals();
        RebuildInspector();

        block.CapturePointer(evt.pointerId);
        float startMouseX = evt.position.x;
        float startTime = e.time;

        void OnMove(PointerMoveEvent moveEvt)
        {
            float deltaSeconds = (moveEvt.position.x - startMouseX) / m_PixelsPerSecond;
            float newTime = Mathf.Max(0f, startTime + deltaSeconds);
            newTime = Mathf.Round(newTime / SnapSeconds) * SnapSeconds;
            e.time = newTime;
            block.style.left = e.time * m_PixelsPerSecond;
        }

        void OnUp(PointerUpEvent upEvt)
        {
            block.ReleasePointer(upEvt.pointerId);
            block.UnregisterCallback<PointerMoveEvent>(OnMove);
            block.UnregisterCallback<PointerUpEvent>(OnUp);
            m_Context.MarkDirty();
            SortEventsByTime();
            RebuildTimeline();
        }

        block.RegisterCallback<PointerMoveEvent>(OnMove);
        block.RegisterCallback<PointerUpEvent>(OnUp);
    }

    void SortEventsByTime()
    {
        m_Context.Model.timeline.events.Sort((a, b) => a.time.CompareTo(b.time));
    }

    void RefreshAllBlockSelectionVisuals()
    {
        foreach (var block in m_BlockElements)
        {
            if (block.userData is StgTimelineEvent e) ApplySelectionVisual(block, e);
        }
    }

    // ---------- 框选 ----------

    void OnEmptyAreaPointerDown(PointerDownEvent evt)
    {
        if (evt.target != m_TimelineContent) return;
        if (evt.button != 0) return;

        m_IsMarqueeSelecting = true;
        m_MarqueeStart = m_TimelineContent.WorldToLocal(evt.position);
        m_SelectionBox.style.display = DisplayStyle.Flex;
        m_SelectionBox.style.left = m_MarqueeStart.x;
        m_SelectionBox.style.top = m_MarqueeStart.y;
        m_SelectionBox.style.width = 0;
        m_SelectionBox.style.height = 0;

        m_TimelineContent.CapturePointer(evt.pointerId);
        m_TimelineContent.RegisterCallback<PointerMoveEvent>(OnMarqueeMove);
        m_TimelineContent.RegisterCallback<PointerUpEvent>(OnMarqueeUp);

        if (!evt.shiftKey)
        {
            m_MultiSelected.Clear();
            m_SingleSelected = null;
        }
    }

    void OnMarqueeMove(PointerMoveEvent evt)
    {
        if (!m_IsMarqueeSelecting) return;
        var current = m_TimelineContent.WorldToLocal(evt.position);
        float x = Mathf.Min(m_MarqueeStart.x, current.x);
        float y = Mathf.Min(m_MarqueeStart.y, current.y);
        float w = Mathf.Abs(current.x - m_MarqueeStart.x);
        float h = Mathf.Abs(current.y - m_MarqueeStart.y);
        m_SelectionBox.style.left = x;
        m_SelectionBox.style.top = y;
        m_SelectionBox.style.width = w;
        m_SelectionBox.style.height = h;
    }

    void OnMarqueeUp(PointerUpEvent evt)
    {
        m_IsMarqueeSelecting = false;
        m_TimelineContent.ReleasePointer(evt.pointerId);
        m_TimelineContent.UnregisterCallback<PointerMoveEvent>(OnMarqueeMove);
        m_TimelineContent.UnregisterCallback<PointerUpEvent>(OnMarqueeUp);
        m_SelectionBox.style.display = DisplayStyle.None;

        var selectionRect = new Rect(
            m_SelectionBox.style.left.value.value,
            m_SelectionBox.style.top.value.value,
            m_SelectionBox.style.width.value.value,
            m_SelectionBox.style.height.value.value);

        if (selectionRect.width < 2 || selectionRect.height < 2) return;

        foreach (var block in m_BlockElements)
        {
            var blockRect = new Rect(block.style.left.value.value, block.style.top.value.value, block.resolvedStyle.width, block.resolvedStyle.height);
            if (selectionRect.Overlaps(blockRect) && block.userData is StgTimelineEvent e)
            {
                m_MultiSelected.Add(e);
            }
        }
        m_SingleSelected = m_MultiSelected.Count == 1 ? m_MultiSelected.First() : null;
        RefreshAllBlockSelectionVisuals();
        RebuildInspector();
    }

    // ---------- 右键菜单 ----------

    void BuildBlockContextMenu(ContextualMenuPopulateEvent evt, StgTimelineEvent e)
    {
        evt.menu.AppendAction("删除", _ =>
        {
            m_Context.Model.timeline.events.Remove(e);
            m_MultiSelected.Remove(e);
            if (m_SingleSelected == e) m_SingleSelected = null;
            m_Context.MarkDirty();
            RebuildTimeline();
        });
        evt.menu.AppendAction("复制(时间+0.5s)", _ =>
        {
            var copy = CloneEvent(e);
            copy.time += 0.5f;
            m_Context.Model.timeline.events.Add(copy);
            m_Context.MarkDirty();
            SortEventsByTime();
            RebuildTimeline();
        });

        string refId = GetPrimaryReferenceId(e);
        if (!string.IsNullOrEmpty(refId))
        {
            evt.menu.AppendAction($"拷贝引用ID「{refId}」到剪贴板(请前往对应面板手动定位)", _ =>
            {
                EditorGUIUtility.systemCopyBuffer = refId;
            });
        }
    }

    string GetPrimaryReferenceId(StgTimelineEvent e)
    {
        switch (e.type)
        {
            case "spawn_enemy_wave": return e.templateId;
            case "spawn_boss": return e.bossId;
            case "spawn_trap": return e.trapId;
            case "spawn_area_start":
            case "spawn_area_stop": return e.spawnAreaId;
            case "spawn_item": return e.itemId;
            default: return null;
        }
    }

    StgTimelineEvent CloneEvent(StgTimelineEvent e)
    {
        return new StgTimelineEvent
        {
            time = e.time, type = e.type, templateId = e.templateId, offsetX = e.offsetX, bossId = e.bossId,
            trapId = e.trapId, positionX = e.positionX, positionY = e.positionY, spawnAreaId = e.spawnAreaId,
            startTime = e.startTime, endTime = e.endTime, itemId = e.itemId, pattern = e.pattern, count = e.count,
            spacing = e.spacing, speed = e.speed, text = e.text, duration = e.duration, bgmId = e.bgmId,
            fadeDuration = e.fadeDuration, cutsceneId = e.cutsceneId, gateType = e.gateType,
            dropIntervalSec = e.dropIntervalSec, offsetXMin = e.offsetXMin, offsetXMax = e.offsetXMax,
            offsetYMin = e.offsetYMin, offsetYMax = e.offsetYMax, dropAniDuration = e.dropAniDuration,
        };
    }

    void BuildEmptyAreaContextMenu(ContextualMenuPopulateEvent evt)
    {
        var localPos = m_TimelineContent.WorldToLocal(evt.mousePosition);
        float clickTime = Mathf.Max(0f, Mathf.Round(localPos.x / m_PixelsPerSecond / SnapSeconds) * SnapSeconds);

        foreach (var (type, label) in AddableEventTypes)
        {
            evt.menu.AppendAction($"新增事件/{label}", _ =>
            {
                var newEvent = new StgTimelineEvent { time = clickTime, type = type };
                m_Context.Model.timeline.events.Add(newEvent);
                m_Context.MarkDirty();
                SortEventsByTime();
                m_SingleSelected = newEvent;
                RebuildTimeline();
            });
        }

        if (m_MultiSelected.Count > 0)
        {
            evt.menu.AppendSeparator();
            evt.menu.AppendAction($"删除选中的 {m_MultiSelected.Count} 个事件", _ => DeleteSelected());
        }
    }

    void DeleteSelected()
    {
        if (m_MultiSelected.Count == 0 && m_SingleSelected == null) return;

        var toDelete = new HashSet<StgTimelineEvent>(m_MultiSelected);
        if (m_SingleSelected != null) toDelete.Add(m_SingleSelected);

        m_Context.Model.timeline.events.RemoveAll(e => toDelete.Contains(e));
        m_MultiSelected.Clear();
        m_SingleSelected = null;
        m_Context.MarkDirty();
        RebuildTimeline();
    }

    // ---------- 详情检查器 ----------

    void RebuildInspector()
    {
        m_InspectorHost.Clear();

        if (m_MultiSelected.Count > 1)
        {
            m_InspectorHost.Add(StgUiUtil.HintLabel($"已框选 {m_MultiSelected.Count} 个事件，右键可批量删除。单选一个事件可编辑详情。"));
            return;
        }

        if (m_SingleSelected == null)
        {
            m_InspectorHost.Add(StgUiUtil.HintLabel("点击一个事件块以编辑详情；在空白轨道区域右键可新增事件；滚轮缩放，拖拽事件块可改变触发时间(0.5s吸附)。"));
            return;
        }

        var e = m_SingleSelected;
        var box = new VisualElement();
        box.style.flexDirection = FlexDirection.Row;

        var left = new VisualElement();
        left.style.width = 300;

        var typeLabel = new Label($"事件类型：{e.type}");
        typeLabel.style.unityFontStyleAndWeight = FontStyle.Bold;
        left.Add(typeLabel);

        var timeField = new FloatField("触发时间(秒)") { value = e.time };
        timeField.RegisterValueChangedCallback(evt =>
        {
            e.time = Mathf.Max(0f, evt.newValue);
            m_Context.MarkDirty();
            SortEventsByTime();
            RebuildTimeline();
        });
        left.Add(timeField);

        left.Add(BuildEventTypeFields(e));

        box.Add(left);
        m_InspectorHost.Add(box);
    }

    VisualElement BuildEventTypeFields(StgTimelineEvent e)
    {
        var box = new VisualElement();

        switch (e.type)
        {
            case "spawn_enemy_wave":
            {
                var ids = m_Context.GetWaveTemplateIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("波次模板 templateId", ids, Mathf.Max(0, ids.IndexOf(e.templateId)));
                popup.RegisterValueChangedCallback(evt => { e.templateId = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(popup);
                var offsetX = new FloatField("横向偏移 offsetX") { value = e.offsetX };
                offsetX.RegisterValueChangedCallback(evt => { e.offsetX = evt.newValue; m_Context.MarkDirty(); });
                box.Add(offsetX);
                break;
            }
            case "spawn_boss":
            {
                var ids = m_Context.GetBossIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("Boss bossId", ids, Mathf.Max(0, ids.IndexOf(e.bossId)));
                popup.RegisterValueChangedCallback(evt => { e.bossId = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(popup);
                break;
            }
            case "spawn_trap":
            {
                var ids = m_Context.GetTrapIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("机关 trapId", ids, Mathf.Max(0, ids.IndexOf(e.trapId)));
                popup.RegisterValueChangedCallback(evt => { e.trapId = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(popup);
                box.Add(BuildPositionFields(e));
                break;
            }
            case "drop_digital_gate":
            {
                var ids = m_Context.GetReusableGateTrapIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("数字门模板(可复用) trapId(存gateType字段)", ids, 0);
                popup.RegisterValueChangedCallback(evt => { e.gateType = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); });
                box.Add(popup);
                var count = new IntegerField("抛撒数量") { value = e.count };
                count.RegisterValueChangedCallback(evt => { e.count = evt.newValue; m_Context.MarkDirty(); });
                box.Add(count);
                var interval = new FloatField("抛撒间隔(秒)") { value = e.dropIntervalSec };
                interval.RegisterValueChangedCallback(evt => { e.dropIntervalSec = evt.newValue; m_Context.MarkDirty(); });
                box.Add(interval);
                var dropAniDuration = new FloatField("抛撒动画时长") { value = e.dropAniDuration };
                dropAniDuration.RegisterValueChangedCallback(evt => { e.dropAniDuration = evt.newValue; m_Context.MarkDirty(); });
                box.Add(dropAniDuration);
                box.Add(BuildPositionFields(e));
                box.Add(StgUiUtil.HintLabel("参考旧版 barrel DropTriggerGate 的连续抛撒效果，来源未核实，见架构文档第零节。"));
                break;
            }
            case "spawn_area_start":
            case "spawn_area_stop":
            {
                var ids = m_Context.GetSpawnAreaIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("刷怪区域 spawnAreaId", ids, Mathf.Max(0, ids.IndexOf(e.spawnAreaId)));
                popup.RegisterValueChangedCallback(evt => { e.spawnAreaId = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(popup);
                break;
            }
            case "spawn_item":
            {
                var ids = m_Context.GetItemIds();
                ids.Insert(0, "(未选)");
                var popup = new PopupField<string>("物品 itemId", ids, Mathf.Max(0, ids.IndexOf(e.itemId)));
                popup.RegisterValueChangedCallback(evt => { e.itemId = evt.newValue == "(未选)" ? "" : evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(popup);
                var patternOptions = new List<string> { "single", "line_horizontal", "line_vertical", "circle", "v_shape", "random" };
                var pattern = new PopupField<string>("投放形状 pattern", patternOptions, StgUiUtil.SafeIndexOf(patternOptions.ToArray(), e.pattern));
                pattern.RegisterValueChangedCallback(evt => { e.pattern = evt.newValue; m_Context.MarkDirty(); });
                box.Add(pattern);
                var count = new IntegerField("数量") { value = e.count };
                count.RegisterValueChangedCallback(evt => { e.count = evt.newValue; m_Context.MarkDirty(); });
                box.Add(count);
                var spacing = new FloatField("间距") { value = e.spacing };
                spacing.RegisterValueChangedCallback(evt => { e.spacing = evt.newValue; m_Context.MarkDirty(); });
                box.Add(spacing);
                box.Add(BuildPositionFields(e));
                break;
            }
            case "change_scroll_speed":
            {
                var speed = new FloatField("目标速度 speed") { value = e.speed };
                speed.RegisterValueChangedCallback(evt => { e.speed = evt.newValue; m_Context.MarkDirty(); });
                box.Add(speed);
                break;
            }
            case "show_banner":
            {
                var text = new TextField("横幅文本") { value = e.text };
                text.RegisterValueChangedCallback(evt => { e.text = evt.newValue; m_Context.MarkDirty(); });
                box.Add(text);
                var duration = new FloatField("持续时间") { value = e.duration };
                duration.RegisterValueChangedCallback(evt => { e.duration = evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(duration);
                break;
            }
            case "play_bgm":
            {
                var bgmId = new TextField("BGM id") { value = e.bgmId };
                bgmId.RegisterValueChangedCallback(evt => { e.bgmId = evt.newValue; m_Context.MarkDirty(); });
                box.Add(bgmId);
                var fadeDuration = new FloatField("淡入淡出时长") { value = e.fadeDuration };
                fadeDuration.RegisterValueChangedCallback(evt => { e.fadeDuration = evt.newValue; m_Context.MarkDirty(); });
                box.Add(fadeDuration);
                break;
            }
            case "pause_enemy_spawn":
            {
                var duration = new FloatField("暂停时长") { value = e.duration };
                duration.RegisterValueChangedCallback(evt => { e.duration = evt.newValue; m_Context.MarkDirty(); RebuildTimeline(); });
                box.Add(duration);
                break;
            }
            case "trigger_cutscene":
            {
                var cutsceneId = new TextField("过场ID") { value = e.cutsceneId };
                cutsceneId.RegisterValueChangedCallback(evt => { e.cutsceneId = evt.newValue; m_Context.MarkDirty(); });
                box.Add(cutsceneId);
                break;
            }
            case "resume_enemy_spawn":
            case "level_complete":
            case "game_over":
                box.Add(StgUiUtil.HintLabel("此事件无额外参数。"));
                break;
        }

        return box;
    }

    VisualElement BuildPositionFields(StgTimelineEvent e)
    {
        var row = new VisualElement();
        row.style.flexDirection = FlexDirection.Row;
        var x = new FloatField("位置X") { value = e.positionX };
        x.style.flexGrow = 1;
        x.RegisterValueChangedCallback(evt => { e.positionX = evt.newValue; m_Context.MarkDirty(); });
        var y = new FloatField("位置Y") { value = e.positionY };
        y.style.flexGrow = 1;
        y.RegisterValueChangedCallback(evt => { e.positionY = evt.newValue; m_Context.MarkDirty(); });
        row.Add(x);
        row.Add(y);
        return row;
    }

    public void Rebuild()
    {
        m_SingleSelected = null;
        m_MultiSelected.Clear();
        // 模型可能因为新建/打开被整体替换，此时 StgLevelEditorWindow.OnModelReloaded 已经同步调用过
        // StgPreviewRuntime.Stop()——这里立即刷新按钮文字和内嵌视口状态，不等下一次 EditorApplication.update 才更新
        RefreshPlayButtonText();
        if (!StgPreviewRuntime.IsPlaying) SetViewportPlaying(false);
        RebuildTimeline();
    }
}
