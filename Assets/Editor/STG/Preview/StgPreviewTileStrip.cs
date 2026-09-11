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

            // 从画幅底部往上铺，直到盖过顶部，保证滚动时上方始终有内容衔接
            int guard = 0;
            while (cursorY < fillTopY && guard++ < 64) // guard 防御 tileHeight 异常导致死循环
            {
                var tile = CreateTile(strip, parent, cursorY);
                if (tile == null) break;
                cursorY += tile.Height;
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

            float tileTopY = tile.GameObject.transform.localPosition.y + tile.Height * 0.5f;
            if (tileTopY < StgPreviewRuntime.ScreenBottomY)
            {
                // 找当前带里最高的 tile 顶边，作为新 tile 的接续位置
                float highestTopY = float.MinValue;
                foreach (var t in strip.Tiles)
                {
                    if (t.GameObject == null) continue;
                    float top = t.GameObject.transform.localPosition.y + t.Height * 0.5f;
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

        int pathIndex = strip.NextPathIndex % paths.Count;
        strip.NextPathIndex = (strip.NextPathIndex + 1) % paths.Count;

        string path = paths[pathIndex];
        var sprite = LoadSprite(path);

        float height = strip.Layer.tileWorldHeight;
        if (height <= 0f)
        {
            // 未配置世界高度：有贴图就按贴图自身尺寸推算，否则按整个画幅高度兜底
            height = sprite != null
                ? sprite.bounds.size.y
                : (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY);
        }
        if (height <= 0.01f) height = StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY;

        var go = new GameObject($"TileStrip_{strip.Layer.layerId}_{pathIndex}");
        go.hideFlags = HideFlags.DontSave;
        go.transform.SetParent(parent, false);
        go.transform.localPosition = new Vector3(0f, bottomY + height * 0.5f, 0f);

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sortingOrder = strip.Layer.orderInLayer;
        if (sprite != null)
        {
            sr.sprite = sprite;
            // 按配置的世界高度缩放贴图；宽度同比拉伸到覆盖画幅宽度
            float spriteHeight = sprite.bounds.size.y;
            float spriteWidth = sprite.bounds.size.x;
            float scaleY = spriteHeight > 0.01f ? height / spriteHeight : 1f;
            float targetWidth = StgPreviewRuntime.ScreenHalfWidth * 2f;
            float scaleX = spriteWidth > 0.01f ? targetWidth / spriteWidth : 1f;
            go.transform.localScale = new Vector3(scaleX, scaleY, 1f);
        }
        else
        {
            // 贴图缺失/加载失败：用占位色块兜底，保证仍能看到滚动节奏（对齐设计文档 4.5 节兜底策略）
            if (!string.IsNullOrEmpty(path)) StgPreviewRuntime.ReportPlaceholderFallback();
            sr.sprite = GetOrCreatePlaceholderSprite(pathIndex);
            go.transform.localScale = new Vector3(StgPreviewRuntime.ScreenHalfWidth * 2f, height, 1f);
        }

        var tile = new Tile { GameObject = go, Height = height, PathIndex = pathIndex };
        strip.Tiles.Add(tile);
        return tile;
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
