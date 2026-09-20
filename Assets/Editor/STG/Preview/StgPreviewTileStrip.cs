using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

// 背景层的"循环贴图带"预览渲染：多张图按 tileSpritePaths 列表顺序首尾相接铺成一条无限带，
// 随卷轴向下滚动，滚出画幅底部的贴图回收并按顺序接到带尾（滚完最后一张接回第一张）。
//
// 与 scatterRules（随机散布单个物体）的区别：这里铺的是连续无缝的整张背景，不是散落的独立对象，
// 所以不走 StgPreviewObjectHandle 那套生成/回收管线，由本类自己维护每层的一条贴图带。
//
// 每层一条带（key: layerId），带内每个 tile 是一个挂 SpriteRenderer 的 GameObject。
public static class StgPreviewTileStrip
{
    class Tile
    {
        public GameObject GameObject;
        public float Height;
        public int PathIndex; // 该 tile 用的是 tileSpritePaths 里第几张，决定带尾接下一张时取哪个索引
        // localPosition.y = 逻辑中心 - VisualCenterOffsetY（见 CreateTile），
        // 换算回逻辑中心/边界时必须加回这个偏移，否则 Pivot 非居中的贴图会算错顶边/底边
        public float VisualCenterOffsetY;
    }

    class Strip
    {
        public StgBackgroundLayer Layer;
        public readonly List<Tile> Tiles = new List<Tile>();
        public int NextPathIndex; // 下一次接到带尾时该取的 path 索引（顺序循环）
    }

    static readonly Dictionary<string, Strip> s_Strips = new Dictionary<string, Strip>();
    static readonly Dictionary<string, Sprite> s_SpriteCache = new Dictionary<string, Sprite>();

    public static void Clear()
    {
        foreach (var strip in s_Strips.Values)
        {
            foreach (var tile in strip.Tiles)
            {
                if (tile.GameObject != null) Object.DestroyImmediate(tile.GameObject);
            }
        }
        s_Strips.Clear();
    }

    // 预览开始时为每个 useTileLoop 的层铺满画幅（从底部往上铺到超出顶部一张的高度）
    public static void BuildStrips(StgLevelEditorModel model, Transform parent)
    {
        Clear();

        foreach (var layer in model.backgroundLayers)
        {
            if (!layer.useTileLoop || layer.tileSpritePaths.Count == 0) continue;

            var strip = new Strip { Layer = layer };
            s_Strips[layer.layerId] = strip;

            float fillTopY = StgPreviewRuntime.ScreenTopY;
            float cursorY = StgPreviewRuntime.ScreenBottomY;

            // 从画幅底部往上铺：不能一"盖过顶部"就停——若单张贴图高度超过画幅高度（不缩放时很常见，
            // 比如原生高度 25.6 远大于画幅高度 12），铺第一张就已经盖过顶部，循环立刻结束，导致带里
            // 只有一张图。此时要等这张图完全滚出画幅（RecycleAndAppend 的回收条件）才追加下一张，
            // 中间会空出一整段没有任何 tile 覆盖的区间，长度接近一张画幅——这正是"两图间隔一整屏黑块"的成因。
            // 修正：盖过顶部之后，强制至少再铺一张预备图，保证画幅上方随时有内容等着接续，滚动时严密无缝
            int guard = 0;
            while (guard++ < 64) // guard 防御 tileHeight 异常导致死循环
            {
                var tile = CreateTile(strip, parent, cursorY);
                if (tile == null) break;
                cursorY += tile.Height;
                if (cursorY >= fillTopY && strip.Tiles.Count >= 2) break;
            }
        }
    }

    // 每帧随卷轴下移，出画幅的 tile 回收并按顺序接到带尾
    public static void Tick(float scrollDelta, Transform parent)
    {
        foreach (var strip in s_Strips.Values)
        {
            float coeff = strip.Layer.speedCoefficient;
            float delta = scrollDelta * coeff;

            foreach (var tile in strip.Tiles)
            {
                if (tile.GameObject == null) continue;
                var p = tile.GameObject.transform.localPosition;
                p.y -= delta;
                tile.GameObject.transform.localPosition = p;
            }

            RecycleAndAppend(strip, parent);
        }
    }

    // 把滚到画幅下方（整张都看不见了）的 tile 移到带顶，并换成顺序里的下一张图
    static void RecycleAndAppend(Strip strip, Transform parent)
    {
        for (int i = strip.Tiles.Count - 1; i >= 0; i--)
        {
            var tile = strip.Tiles[i];
            if (tile.GameObject == null)
            {
                strip.Tiles.RemoveAt(i);
                continue;
            }

            // localPosition.y 已被 CreateTile 减去了 VisualCenterOffsetY，换算回逻辑中心要加回来，
            // 否则 Pivot 非居中的贴图会算出错误的顶边，导致下一张接续位置偏移（即本次要修的黑块 bug 本身）
            float tileTopY = tile.GameObject.transform.localPosition.y + tile.VisualCenterOffsetY + tile.Height * 0.5f;
            if (tileTopY < StgPreviewRuntime.ScreenBottomY)
            {
                // 找当前带里最高的 tile 顶边，作为新 tile 的接续位置
                float highestTopY = float.MinValue;
                foreach (var t in strip.Tiles)
                {
                    if (t.GameObject == null) continue;
                    float top = t.GameObject.transform.localPosition.y + t.VisualCenterOffsetY + t.Height * 0.5f;
                    if (top > highestTopY) highestTopY = top;
                }

                Object.DestroyImmediate(tile.GameObject);
                strip.Tiles.RemoveAt(i);

                if (highestTopY > float.MinValue)
                {
                    CreateTile(strip, parent, highestTopY);
                }
            }
        }
    }

    // bottomY 是新 tile 的底边位置；返回 null 表示这一层没有可用贴图路径
    static Tile CreateTile(Strip strip, Transform parent, float bottomY)
    {
        var paths = strip.Layer.tileSpritePaths;
        if (paths.Count == 0) return null;

        // 空字符串槄位（列表里刚加的、还没拖贴图进去的行）不参与拼接：跳过它去找下一个非空路径，
        // 就像这个位置在数组里不存在一样——不能让"未配置"生成一个整屏高度的占位块插进无缝带里，
        // 那是真正贴图缺失（路径写了但资源加载失败）才该有的兜底行为，两者性质不同
        int pathIndex = -1;
        string path = null;
        for (int attempt = 0; attempt < paths.Count; attempt++)
        {
            int candidate = strip.NextPathIndex % paths.Count;
            strip.NextPathIndex = (strip.NextPathIndex + 1) % paths.Count;
            if (!string.IsNullOrEmpty(paths[candidate]))
            {
                pathIndex = candidate;
                path = paths[candidate];
                break;
            }
        }
        if (pathIndex < 0)
        {
            // 整条列表都是空槄位：不生成任何 tile（层保持空白，而不是塞一个整屏高度的占位块），
            // 但这仍值得提醒——用户大概率是漏了拖贴图，不报警告的话会一直不知道这层为什么不显示
            Debug.LogWarning($"[STG预览] 层[{strip.Layer.layerName}] 的 tileSpritePaths 列表里所有槄位都未配置贴图，该层不会显示任何内容");
            return null;
        }

        var sprite = LoadSprite(path);

        // 不缩放贴图资源：高度直接用贴图原生高度做接带定位，保证视觉高度与逻辑接带高度一致（无缝）；
        // 贴图缺失时才退化为画幅高度兜底，让占位块仍有合理尺寸
        float height = sprite != null
            ? sprite.bounds.size.y
            : (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY);
        if (height <= 0.01f)
        {
            if (sprite != null) Debug.LogWarning($"[STG预览] 贴图高度异常（<=0.01，已按画幅高度兜底），检查该贴图的导入设置: {path}");
            height = StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY;
        }

        var go = new GameObject($"TileStrip_{strip.Layer.layerId}_{pathIndex}");
        go.hideFlags = HideFlags.DontSave;
        go.transform.SetParent(parent, false);

        // Sprite.bounds 是相对 Pivot 计算的：Pivot 不在正中心（0.5, 0.5）时 bounds.center.y 不为 0，
        // 必须用这个偏移把"贴图视觉内容的中心"对齐到接带位置，否则不同 Pivot 的贴图之间会露缝或重叠——
        // 不依赖"所有贴图 Pivot 都居中"这个隐式假设，任意 Pivot 设置下接带都严密无缝
        float visualCenterOffsetY = sprite != null ? sprite.bounds.center.y : 0f;
        go.transform.localPosition = new Vector3(0f, bottomY + height * 0.5f - visualCenterOffsetY, 0f);

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sortingOrder = strip.Layer.orderInLayer;
        if (sprite != null)
        {
            sr.sprite = sprite;
            // 纵向不缩放（贴图按原生高度/比例显示）；仅横向拉伸铺满画幅宽度，避免两侧露出空隙。
            // 用 Sliced 绘制模式（而非默认 Simple）：Simple 模式直接用贴图导入设置里的 Mesh Type 生成的网格渲染——
            // 若贴图 Mesh Type 是 Tight（沿 Alpha 边缘描边的多边形），描边网格可能比贴图矩形边界略小一点，
            // 拼接时就会在贴图之间露出比清屏色更深的缝隙。Sliced/Tiled 模式忽略该网格，永远用完整矩形渲染贴图内容，
            // 不依赖美术把每张贴图的导入设置改成 Full Rect，从渲染层面保证拼接严密无缝
            float spriteWidth = sprite.bounds.size.x;
            float targetWidth = StgPreviewRuntime.ScreenHalfWidth * 2f;
            sr.drawMode = SpriteDrawMode.Sliced;
            sr.size = new Vector2(spriteWidth, height);
            float scaleX = spriteWidth > 0.01f ? targetWidth / spriteWidth : 1f;
            go.transform.localScale = new Vector3(scaleX, 1f, 1f);
        }
        else
        {
            // 走到这里 path 必定非空（空槄位已在上面跳过），说明是路径写了但资源加载失败——
            // 真正的资源异常，用占位色块兜底，保证仍能看到滚动节奏（对齐设计文档 4.5 节兜底策略）
            StgPreviewRuntime.ReportPlaceholderFallback();
            Debug.LogWarning($"[STG预览] 贴图加载失败，已用占位色块代替，检查路径是否有效: {path}");
            sr.sprite = GetOrCreatePlaceholderSprite(pathIndex);
            go.transform.localScale = new Vector3(StgPreviewRuntime.ScreenHalfWidth * 2f, height, 1f);
        }

        var tile = new Tile { GameObject = go, Height = height, PathIndex = pathIndex, VisualCenterOffsetY = visualCenterOffsetY };
        strip.Tiles.Add(tile);
        return tile;
    }

    // 诊断用：逐层检查相邻 tile 之间是否有几何缝隙（不含浮点误差容差），用于在预览 HUD 上直接报出
    // 具体间隙数值和涉及的贴图路径，比让人肉眼估算画面里的黑块更精确——不改动任何 Tick/回收逻辑，纯只读查询
    const float GapTolerance = 0.001f;

    public static string GetGapReport()
    {
        System.Text.StringBuilder sb = null;

        foreach (var strip in s_Strips.Values)
        {
            if (strip.Tiles.Count < 2) continue;

            // 按顶边/底边算出的世界 Y 排序，而不是假设 Tiles 列表本身有序（回收会把顺序打乱）
            var sorted = new List<Tile>(strip.Tiles);
            sorted.Sort((a, b) => TileBottomY(a).CompareTo(TileBottomY(b)));

            for (int i = 0; i < sorted.Count - 1; i++)
            {
                float topOfCurrent = TileTopY(sorted[i]);
                float bottomOfNext = TileBottomY(sorted[i + 1]);
                float gap = bottomOfNext - topOfCurrent;
                if (gap > GapTolerance)
                {
                    sb ??= new System.Text.StringBuilder();
                    sb.Append($"\n⚠ 层[{strip.Layer.layerName}] tile#{sorted[i].PathIndex}→#{sorted[i + 1].PathIndex} 间隙 {gap:F3} 世界单位");
                }
            }
        }

        return sb?.ToString() ?? "";
    }

    static float TileTopY(Tile tile)
    {
        return tile.GameObject.transform.localPosition.y + tile.VisualCenterOffsetY + tile.Height * 0.5f;
    }

    static float TileBottomY(Tile tile)
    {
        return tile.GameObject.transform.localPosition.y + tile.VisualCenterOffsetY - tile.Height * 0.5f;
    }

    static Sprite LoadSprite(string path)
    {
        if (string.IsNullOrEmpty(path)) return null;
        if (s_SpriteCache.TryGetValue(path, out var cached)) return cached;

        var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(path);
        s_SpriteCache[path] = sprite; // 允许缓存 null，避免每帧重复尝试加载不存在的资源
        return sprite;
    }

    // 占位色块：相邻序号用略微不同的灰度，让"接到下一张"的时机在预览里肉眼可辨
    static readonly Dictionary<int, Sprite> s_PlaceholderCache = new Dictionary<int, Sprite>();

    static Sprite GetOrCreatePlaceholderSprite(int pathIndex)
    {
        int shade = pathIndex % 3;
        if (s_PlaceholderCache.TryGetValue(shade, out var cached) && cached != null) return cached;

        float gray = 0.45f + shade * 0.08f;
        var tex = new Texture2D(4, 4, TextureFormat.RGBA32, false);
        tex.hideFlags = HideFlags.DontSave;
        var color = new Color(gray, gray, gray, 0.35f);
        for (int y = 0; y < 4; y++)
        {
            for (int x = 0; x < 4; x++) tex.SetPixel(x, y, color);
        }
        tex.Apply();

        var sprite = Sprite.Create(tex, new Rect(0, 0, 4, 4), new Vector2(0.5f, 0.5f), 4);
        sprite.name = $"TileStripPlaceholder_{shade}";
        sprite.hideFlags = HideFlags.DontSave;
        s_PlaceholderCache[shade] = sprite;
        return sprite;
    }
}
