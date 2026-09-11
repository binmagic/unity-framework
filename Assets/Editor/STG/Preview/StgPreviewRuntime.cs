using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 预览会话主控：Start/Stop/Tick，持有当前预览时间和已生成对象。详见关卡编辑器设计文档第四节。
/// 纯 Editor 态实现，不进入 Play Mode，用 EditorApplication.update 驱动（详见 4.1 节边界说明）。
///
/// 已知简化（相对设计文档的降级点，供后续迭代，风格对齐 TimelineEditorPanel 的"已知简化"注释）：
/// - 手动跳转时间点（4.6 节"手动定位"）：向前跳转正确补触发漏掉的事件；向后跳转简化为清空全部对象+
///   重置已触发事件集合+重新扫描触发，不做"倒放"式的运动状态还原，跳转后对象位置从各自的初始生成状态重新演出
/// - Boss 假血量下降速率固定写死在 StgPreviewMoveDrivers（30 秒打完），未在 Overlay 提供可调滑条
/// - 掉落表演出简化为"生成后按 lifetime 固定比例触发一次掉落"，不是真实死亡判定触发（详见设计文档 4.4 节表格最后一行）
/// </summary>
public static class StgPreviewRuntime
{
    // ---------- 画幅常量（竖版卷轴取景范围，供 Spawner/MoveDrivers/SceneView 共用） ----------
    public const float ScreenTopY = 6f;
    public const float ScreenBottomY = -6f;
    public const float ScreenHalfWidth = 4f;
    public const float BossStationY = 4f;

    /// <summary>
    /// 预览会话是否存活（已生成对象、视口已就绪）。注意它不等于"时间在推进"——
    /// 拖动播放头擦洗时会话存活但 IsPaused=true，时间由 SeekTo 显式指定而非自动前进。
    /// 所有清理逻辑（窗口关闭/模型替换/Scene 浮层停止）判断的都是会话存活，语义不变。
    /// </summary>
    public static bool IsPlaying { get; private set; }

    /// <summary>
    /// 会话存活但时间停止推进（拖动播放头擦洗、或手动暂停）。
    /// 与 IsPlaying 分离的理由：擦洗时需要"有画面但时间不自己走"，这是 IsPlaying 单独表达不了的状态。
    /// </summary>
    public static bool IsPaused { get; private set; }

    public static float PreviewTime { get; private set; }

    static StgLevelEditorContext s_Context;
    static GameObject s_Root;
    static Transform s_BulletParent;
    static double s_LastEditorTime;
    static int s_LoopCount;
    static int s_PlaceholderFallbackCount;

    static readonly List<StgPreviewObjectHandle> s_Handles = new List<StgPreviewObjectHandle>();
    static readonly HashSet<StgTimelineEvent> s_TriggeredEvents = new HashSet<StgTimelineEvent>();
    static readonly List<ActiveSpawnArea> s_ActiveSpawnAreas = new List<ActiveSpawnArea>();

    static float s_ScrollSpeedOverride = -1f; // change_scroll_speed 事件覆盖值，-1 表示未覆盖，按 basicScroll 配置走
    static readonly Dictionary<string, float> s_LayerScatterTimers = new Dictionary<string, float>(); // key: layerId
    static bool s_EnemySpawnPaused;

    class ActiveSpawnArea
    {
        public StgSpawnAreaConfig Area;
        public float EndTime;
        public float SpawnTimer;
        public int SampleIndex;
    }

    // ---------- 生命周期 ----------

    // startPaused=true 用于"拖动播放头时按需起会话"：只生成画面、不自动推进时间，
    // 时间完全由随后的 SeekTo 指定（见 TimelineEditorPanel 的播放头拖拽）
    //
    // skipValidationPrompt=true 时校验问题只记日志、不弹模态框。给"拖动播放头"这类轻量手势用：
    // 擦洗是连续的鼠标交互，中途弹出模态对话框会打断拖拽、并阻塞编辑器主线程等待点击，
    // 手感上不可接受。显式点"播放预览"仍然保留弹框询问——那是一次明确的动作，值得提示。
    public static void Start(StgLevelEditorContext context, float startTime = 0f, bool startPaused = false, bool skipValidationPrompt = false)
    {
        if (IsPlaying) Stop();

        var issues = ValidationPanel.RunValidation(context.Model);
        int errorCount = issues.Count(i => i.Severity == ValidationPanel.Severity.Error);
        if (errorCount > 0)
        {
            if (skipValidationPrompt)
            {
                Debug.LogWarning($"[STG预览] 关卡存在 {errorCount} 个错误级别的校验问题（详情见⑧校验与统计面板），擦洗预览可能出现生成异常或引用缺失。");
            }
            else
            {
                bool proceed = EditorUtility.DisplayDialog(
                    "预览前校验发现问题",
                    $"发现 {errorCount} 个错误级别的问题（详情见⑧校验与统计面板），继续预览可能出现生成异常或引用缺失。是否仍要预览？",
                    "仍然预览", "取消");
                if (!proceed) return;
            }
        }

        s_Context = context;
        PreviewTime = Mathf.Max(0f, startTime);
        s_LoopCount = 0;
        s_PlaceholderFallbackCount = 0;
        s_ScrollSpeedOverride = -1f;
        s_LayerScatterTimers.Clear();
        s_EnemySpawnPaused = false;
        s_TriggeredEvents.Clear();
        s_ActiveSpawnAreas.Clear();
        ClearAllHandles();

        s_Root = new GameObject("__StgPreviewRoot__");
        s_Root.hideFlags = HideFlags.DontSave;
        var bulletParentGo = new GameObject("Bullets");
        bulletParentGo.hideFlags = HideFlags.DontSave;
        bulletParentGo.transform.SetParent(s_Root.transform, false);
        s_BulletParent = bulletParentGo.transform;

        StgPreviewSceneView.EnterPreviewView();
        // ③时间轴面板内嵌的模拟画面：离屏相机 + RenderTexture，和 Scene 视图共用同一批预览对象
        StgPreviewViewport.Create(s_Root.transform);

        // 铺满 useTileLoop 层的循环贴图带（多张图按顺序首尾相接，见 StgPreviewTileStrip）
        StgPreviewTileStrip.BuildStrips(s_Context.Model, s_Root.transform);

        // 从 0 快进到 startTime：补触发所有 time <= startTime 的一次性事件、激活覆盖 startTime 的持续区间
        if (PreviewTime > 0f)
        {
            FastForwardEvents(PreviewTime);
        }

        s_LastEditorTime = EditorApplication.timeSinceStartup;
        IsPlaying = true;
        IsPaused = startPaused;
        EditorApplication.update += OnEditorUpdate;

        // 先渲一帧，让内嵌视口立刻有画面，不用等到第一次 Tick
        StgPreviewViewport.Render();
        OnFrameRendered?.Invoke();
    }

    public static void Stop()
    {
        if (!IsPlaying) return;

        EditorApplication.update -= OnEditorUpdate;
        IsPlaying = false;
        IsPaused = false;

        ClearAllHandles();
        StgPreviewTileStrip.Clear();
        // 视口相机是 s_Root 的子节点，必须在销毁 s_Root 之前先解绑并释放 RenderTexture，
        // 否则 RT 会失去引用变成泄漏的 GPU 资源
        StgPreviewViewport.Release();
        if (s_Root != null)
        {
            UnityEngine.Object.DestroyImmediate(s_Root);
            s_Root = null;
        }
        s_BulletParent = null;

        StgPreviewSceneView.ExitPreviewView();
    }

    // 手动跳转时间点（详见 4.6 节，向后跳转按类头部注释的简化策略处理）
    // 暂停态（IsPaused）下同样可调用——拖动播放头擦洗就走这条路径；只要求会话存活（对象/视口已就绪）
    public static void SeekTo(float newTime)
    {
        if (!IsPlaying) return;

        newTime = Mathf.Max(0f, newTime);
        bool backward = newTime < PreviewTime;

        if (backward)
        {
            ClearAllHandles();
            s_TriggeredEvents.Clear();
            s_ActiveSpawnAreas.Clear();
            s_ScrollSpeedOverride = -1f;
            PreviewTime = 0f;
            // 贴图带同样重铺（向后跳转不做"倒放"式还原，从初始铺满状态重新演出）
            StgPreviewTileStrip.BuildStrips(s_Context.Model, s_Root.transform);
            FastForwardEvents(newTime);
        }
        else
        {
            FastForwardEvents(newTime);
        }
        PreviewTime = newTime;

        // 跳转后立刻重渲，让内嵌视口跟着播放头同步刷新，而不是等下一次 Tick
        StgPreviewViewport.Render();
        OnFrameRendered?.Invoke();
    }

    public static void ReportPlaceholderFallback()
    {
        s_PlaceholderFallbackCount++;
    }

    // 补触发 [0, targetTime] 区间内所有尚未触发的一次性事件，并激活覆盖 targetTime 的持续区间；不做逐帧运动模拟
    static void FastForwardEvents(float targetTime)
    {
        var events = s_Context.Model.timeline.events;
        foreach (var e in events)
        {
            if (e.time > targetTime) continue;
            if (e.type == "spawn_area_start" || e.type == "spawn_area_stop") continue; // 区间事件单独处理
            if (s_TriggeredEvents.Contains(e)) continue;
            DispatchEvent(e);
            s_TriggeredEvents.Add(e);
        }

        // 找出 startTime<=targetTime 且（没有对应 stop 事件，或 stop 事件时间 > targetTime）的区间，直接激活
        foreach (var e in events.Where(e => e.type == "spawn_area_start" && e.startTime <= targetTime))
        {
            float endTime = e.endTime;
            var stopEvent = events.FirstOrDefault(s => s.type == "spawn_area_stop" && s.spawnAreaId == e.spawnAreaId && s.time > e.startTime && s.time <= targetTime);
            if (stopEvent != null) continue; // 已经被提前结束，不激活
            if (endTime <= targetTime && endTime > 0f) continue; // 区间已自然结束

            var area = StgPreviewSpawner.FindSpawnArea(s_Context.Model, e.spawnAreaId);
            if (area != null && !s_ActiveSpawnAreas.Any(a => a.Area == area))
            {
                s_ActiveSpawnAreas.Add(new ActiveSpawnArea { Area = area, EndTime = endTime > 0f ? endTime : float.MaxValue });
            }
            s_TriggeredEvents.Add(e);
        }
    }

    static void ClearAllHandles()
    {
        foreach (var h in s_Handles)
        {
            if (h.GameObject != null) UnityEngine.Object.DestroyImmediate(h.GameObject);
        }
        s_Handles.Clear();
    }

    // ---------- 逐帧驱动 ----------

    static void OnEditorUpdate()
    {
        double now = EditorApplication.timeSinceStartup;
        float deltaTime = (float)(now - s_LastEditorTime);
        // 即使暂停也要推进基准时间戳，否则恢复播放的瞬间会拿到"整段暂停时长"作为 deltaTime
        s_LastEditorTime = now;
        if (IsPaused) return; // 暂停中：会话存活、画面保留，但时间不自动前进（时间由 SeekTo 指定）
        if (deltaTime <= 0f || deltaTime > 0.5f) return; // 跳过异常大的 deltaTime（如窗口失焦恢复瞬间）

        Tick(deltaTime);
    }

    /// <summary>暂停/恢复时间推进（会话保持存活）。拖动播放头开始时暂停，松手后按调用方意图决定是否恢复。</summary>
    public static void SetPaused(bool paused)
    {
        if (!IsPlaying) return;
        IsPaused = paused;
        // 恢复播放时重置时间基准，避免把暂停期间累积的墙钟时间当成一帧的 deltaTime 灌进去
        if (!paused) s_LastEditorTime = EditorApplication.timeSinceStartup;
    }

    static void Tick(float deltaTime)
    {
        PreviewTime += deltaTime;
        var model = s_Context.Model;

        if (PreviewTime > model.timeline.duration)
        {
            PreviewTime = 0f;
            s_LoopCount++;
            s_TriggeredEvents.Clear();
            s_ActiveSpawnAreas.Clear();
            ClearAllHandles();
            // 贴图带也要重铺，否则接续顺序会和重置后的时间轴脱节
            StgPreviewTileStrip.BuildStrips(model, s_Root.transform);
        }

        TickScroll(model, deltaTime);
        TickBackgroundSpawn(model, deltaTime);
        TickTimelineEvents(model);
        TickActiveSpawnAreas(deltaTime);
        TickAllHandles(deltaTime, s_ScrollDeltaAccum);
        RecycleHandles();

        StgPreviewSceneView.UpdateOverlayText(PreviewTime, model.timeline.duration, s_LoopCount, s_PlaceholderFallbackCount);
        SceneView.RepaintAll();

        // 内嵌视口按预览时间同步渲一帧；OnFrameRendered 让③面板拿到时机去刷新 UI（Image 元素重绘 + HUD 文字）
        StgPreviewViewport.Render();
        OnFrameRendered?.Invoke();
    }

    /// <summary>
    /// 每帧预览推进并渲完内嵌视口后触发，供③时间轴面板刷新内嵌画面与状态文字。
    /// 订阅方负责在自己销毁/停止时取消订阅（见 TimelineEditorPanel.TogglePlay）。
    /// </summary>
    public static event Action OnFrameRendered;

    /// <summary>供 UI 侧读取用于 HUD 展示的运行统计，避免把内部静态字段整体暴露出去</summary>
    public static int LoopCount => s_LoopCount;
    public static int PlaceholderFallbackCount => s_PlaceholderFallbackCount;

    // ---------- 背景滚动 ----------

    static float s_ScrollDeltaAccum;

    static void TickScroll(StgLevelEditorModel model, float deltaTime)
    {
        var scroll = model.basicScroll;
        float baseSpeed;
        if (s_ScrollSpeedOverride >= 0f)
        {
            baseSpeed = s_ScrollSpeedOverride;
        }
        else if (scroll.rampUpTime > 0f && PreviewTime < scroll.rampUpTime)
        {
            baseSpeed = Mathf.Lerp(scroll.baseSpeed, scroll.rampUpTargetSpeed, PreviewTime / scroll.rampUpTime);
        }
        else
        {
            baseSpeed = scroll.rampUpTime > 0f ? scroll.rampUpTargetSpeed : scroll.baseSpeed;
        }

        float scrollDelta = baseSpeed * scroll.speedMultiplier * 0.01f * deltaTime;
        s_ScrollDeltaAccum = scrollDelta;

        foreach (var h in s_Handles)
        {
            if (h.Category == "background_layer")
            {
                StgPreviewMoveDrivers.TickBackground(h, scrollDelta);
            }
        }

        // 循环贴图带自己维护 tile 的滚动与顺序接续，不走 s_Handles 那套生成/回收管线
        StgPreviewTileStrip.Tick(scrollDelta, s_Root.transform);
    }

    static void TickBackgroundSpawn(StgLevelEditorModel model, float deltaTime)
    {
        foreach (var layer in model.backgroundLayers)
        {
            if (layer.enableScatterSpawn) TickLayerScatterSpawn(layer, deltaTime);
        }
    }

    static readonly System.Random s_BgRandom = new System.Random();

    static void TickLayerScatterSpawn(StgBackgroundLayer layer, float deltaTime)
    {
        if (layer.scatterRules.Count == 0) return;

        int activeCount = s_Handles.Count(h => h.ConfigRef == layer);
        if (activeCount >= layer.scatterMaxActive) return;

        if (!s_LayerScatterTimers.TryGetValue(layer.layerId, out float timer)) timer = 0f;
        timer -= deltaTime;
        if (timer > 0f)
        {
            s_LayerScatterTimers[layer.layerId] = timer;
            return;
        }

        timer = Mathf.Lerp(layer.scatterIntervalMin, layer.scatterIntervalMax, (float)s_BgRandom.NextDouble());
        s_LayerScatterTimers[layer.layerId] = timer;

        var rule = PickWeightedRule(layer.scatterRules);
        if (rule == null) return;

        float x = ((float)s_BgRandom.NextDouble() * 2f - 1f) * ScreenHalfWidth;
        float y = ScreenTopY + layer.scatterSpawnYOffset * 0.05f;
        float scale = Mathf.Lerp(rule.sizeRangeMin, rule.sizeRangeMax, (float)s_BgRandom.NextDouble());
        scale = Mathf.Max(0.2f, scale);

        var handle = StgPreviewSpawner.SpawnBackgroundElement(layer, rule, x, y, scale, s_Root.transform, PreviewTime);
        s_Handles.Add(handle);
    }

    static StgSpawnRule PickWeightedRule(List<StgSpawnRule> rules)
    {
        float total = rules.Sum(r => Mathf.Max(0f, r.weight));
        if (total <= 0f) return rules.Count > 0 ? rules[0] : null;

        float roll = (float)s_BgRandom.NextDouble() * total;
        float acc = 0f;
        foreach (var r in rules)
        {
            acc += Mathf.Max(0f, r.weight);
            if (roll <= acc) return r;
        }
        return rules[rules.Count - 1];
    }

    // ---------- 时间轴事件分发 ----------

    static void TickTimelineEvents(StgLevelEditorModel model)
    {
        foreach (var e in model.timeline.events)
        {
            if (e.time > PreviewTime) continue;
            if (s_TriggeredEvents.Contains(e)) continue;

            if (e.type == "spawn_area_start")
            {
                var area = StgPreviewSpawner.FindSpawnArea(model, e.spawnAreaId);
                if (area != null)
                {
                    s_ActiveSpawnAreas.Add(new ActiveSpawnArea { Area = area, EndTime = e.endTime > 0f ? e.endTime : float.MaxValue });
                }
                s_TriggeredEvents.Add(e);
                continue;
            }
            if (e.type == "spawn_area_stop")
            {
                s_ActiveSpawnAreas.RemoveAll(a => a.Area.spawnAreaId == e.spawnAreaId);
                s_TriggeredEvents.Add(e);
                continue;
            }

            DispatchEvent(e);
            s_TriggeredEvents.Add(e);
        }
    }

    static void DispatchEvent(StgTimelineEvent e)
    {
        var model = s_Context.Model;
        switch (e.type)
        {
            case "spawn_enemy_wave":
                if (s_EnemySpawnPaused) break;
                var template = StgPreviewSpawner.FindWaveTemplate(model, e.templateId);
                if (template != null)
                {
                    s_Handles.AddRange(StgPreviewSpawner.SpawnEnemyWave(template, e.offsetX, PreviewTime, s_Root.transform));
                }
                break;

            case "spawn_boss":
                var boss = StgPreviewSpawner.FindBoss(model, e.bossId);
                if (boss != null)
                {
                    s_Handles.Add(StgPreviewSpawner.SpawnBoss(boss, PreviewTime, s_Root.transform));
                }
                break;

            case "spawn_trap":
                var trap = StgPreviewSpawner.FindTrap(model, e.trapId);
                if (trap != null)
                {
                    Vector2? pos = (e.positionX != 0f || e.positionY != 0f) ? new Vector2(e.positionX, e.positionY) : (Vector2?)null;
                    s_Handles.Add(StgPreviewSpawner.SpawnTrap(trap, pos, PreviewTime, s_Root.transform));
                }
                break;

            case "drop_digital_gate":
                DispatchDropDigitalGate(e);
                break;

            case "spawn_item":
                var item = StgPreviewSpawner.FindItem(model, e.itemId);
                if (item != null)
                {
                    var positions = StgPreviewSpawner.ComputeItemDropPositions(e.pattern, new Vector2(e.positionX, e.positionY), e.count, e.spacing);
                    foreach (var p in positions)
                    {
                        s_Handles.Add(StgPreviewSpawner.SpawnItem(item, p, PreviewTime, s_Root.transform));
                    }
                }
                break;

            case "change_scroll_speed":
                s_ScrollSpeedOverride = e.speed;
                break;

            case "pause_enemy_spawn":
                s_EnemySpawnPaused = true;
                break;

            case "resume_enemy_spawn":
                s_EnemySpawnPaused = false;
                break;

            case "show_banner":
            case "play_bgm":
            case "trigger_cutscene":
            case "level_complete":
            case "game_over":
                // 预览态不做实际 UI/音频/过场演出，仅作为时间轴事件被消费掉（避免下一轮循环重复触发日志）
                Debug.Log($"[STG预览] {PreviewTime:F1}s 触发事件 {e.type}" + (e.type == "show_banner" ? $"：{e.text}" : ""));
                break;
        }
    }

    static void DispatchDropDigitalGate(StgTimelineEvent e)
    {
        var model = s_Context.Model;
        // 抛撒的门参数取自⑥面板标记为"可复用模板"的同 gateType 数字门配置（详见设计文档 4.4/4.6 节）
        var templateTrap = model.trapConfigs.FirstOrDefault(t => t.type == "digital_gate" && t.isReusableGateTemplate && t.gateType == e.gateType);

        int count = Mathf.Max(1, e.count);
        for (int i = 0; i < count; i++)
        {
            float delay = i * Mathf.Max(0.02f, e.dropIntervalSec);
            float offsetX = Mathf.Lerp(e.offsetXMin, e.offsetXMax, count == 1 ? 0.5f : i / (float)(count - 1));
            float offsetY = Mathf.Lerp(e.offsetYMin, e.offsetYMax, (float)s_BgRandom.NextDouble());
            Vector2 landPos = new Vector2(e.positionX + offsetX, e.positionY + offsetY);

            if (templateTrap != null)
            {
                var handle = StgPreviewSpawner.SpawnTrap(templateTrap, landPos, PreviewTime + delay, s_Root.transform);
                handle.SpawnTime = PreviewTime + delay; // 抛撒的门延迟落地，用 SpawnTime 错开显示时机
                handle.GameObject.SetActive(false);
                s_Handles.Add(handle);
            }
        }
    }

    // ---------- 持续/范围刷怪区域 ----------

    static void TickActiveSpawnAreas(float deltaTime)
    {
        for (int i = s_ActiveSpawnAreas.Count - 1; i >= 0; i--)
        {
            var active = s_ActiveSpawnAreas[i];
            if (PreviewTime >= active.EndTime)
            {
                s_ActiveSpawnAreas.RemoveAt(i);
                continue;
            }

            var area = active.Area;
            active.SpawnTimer -= deltaTime;
            if (active.SpawnTimer > 0f) continue;

            float interval = area.type == "fix_point"
                ? Mathf.Lerp(area.intervalMin, area.intervalMax, (float)s_BgRandom.NextDouble())
                : Mathf.Max(0.05f, area.interval);
            active.SpawnTimer = interval;

            int currentCountFromArea = s_Handles.Count(h => h.ConfigRef == area);
            if (currentCountFromArea >= area.limit) continue;

            Vector2 pos = StgPreviewSpawner.SampleSpawnAreaPosition(area, active.SampleIndex);
            active.SampleIndex++;
            s_Handles.Add(StgPreviewSpawner.SpawnAreaMonster(area, pos, PreviewTime, s_Root.transform));
        }
    }

    // ---------- 所有对象逐帧驱动 ----------

    static readonly List<StgPreviewObjectHandle> s_PendingBullets = new List<StgPreviewObjectHandle>();

    static void TickAllHandles(float deltaTime, float scrollDelta)
    {
        s_PendingBullets.Clear();

        foreach (var h in s_Handles)
        {
            if (h.GameObject == null) { h.MarkedForRecycle = true; continue; }

            switch (h.Category)
            {
                case "enemy":
                    StgPreviewMoveDrivers.TickEnemy(h, PreviewTime, deltaTime, scrollDelta, s_PendingBullets, s_BulletParent);
                    break;
                case "boss":
                    StgPreviewMoveDrivers.TickBoss(h, deltaTime, s_PendingBullets, s_BulletParent);
                    break;
                case "trap":
                    if (PreviewTime >= h.SpawnTime && !h.GameObject.activeSelf) h.GameObject.SetActive(true);
                    if (h.GameObject.activeSelf) StgPreviewMoveDrivers.TickTrap(h, PreviewTime, deltaTime, scrollDelta, s_PendingBullets, s_BulletParent);
                    break;
                case "item":
                    StgPreviewMoveDrivers.TickItem(h, deltaTime);
                    break;
                case "bullet_fx":
                    StgPreviewMoveDrivers.TickBulletFx(h, deltaTime);
                    break;
                // background_layer 已在 TickScroll 里驱动，这里不重复处理
            }
        }

        s_Handles.AddRange(s_PendingBullets);
    }

    static void RecycleHandles()
    {
        for (int i = s_Handles.Count - 1; i >= 0; i--)
        {
            var h = s_Handles[i];
            bool expired = h.Lifetime > 0f && (PreviewTime - h.SpawnTime) > h.Lifetime;
            bool outOfBounds = h.Position.y < ScreenBottomY - 3f || h.Position.y > ScreenTopY + 3f || Mathf.Abs(h.Position.x) > ScreenHalfWidth + 3f;

            if (h.MarkedForRecycle || expired || (h.Lifetime <= 0f && outOfBounds && h.Category != "trap"))
            {
                if (h.GameObject != null) UnityEngine.Object.DestroyImmediate(h.GameObject);
                s_Handles.RemoveAt(i);
            }
        }
    }
}
