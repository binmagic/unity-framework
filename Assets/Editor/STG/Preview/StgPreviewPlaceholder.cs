using System.Collections.Generic;
using UnityEngine;

// 预制件缺失或加载失败时的占位图形兜底，详见关卡编辑器设计文档 4.5 节
// 占位图形用运行时生成的纯色纹理 Sprite（圆/方/三角/菱形），按 (类型,颜色) 缓存复用，不依赖项目美术资源
public static class StgPreviewPlaceholder
{
    public enum Kind
    {
        Enemy,      // 红色圆形
        Boss,       // 深红色大方块
        Trap,       // 橙色三角形
        Item,       // 绿色菱形（按物品类型变调）
        Background, // 灰色矩形，低透明度
    }

    const int TexSize = 64;

    static readonly Dictionary<string, Sprite> s_SpriteCache = new Dictionary<string, Sprite>();

    // 创建一个占位图形 GameObject，挂在 parent 下。label 非空时额外挂一个 TextMesh 文字标签。
    public static GameObject CreatePlaceholder(Kind kind, string label, Color color, float worldSize, Transform parent)
    {
        var go = new GameObject($"Placeholder_{kind}_{(string.IsNullOrEmpty(label) ? "" : label)}");
        go.hideFlags = HideFlags.DontSave;
        go.transform.SetParent(parent, false);

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = GetOrCreateSprite(kind, color);
        // Sprite 的 pixelsPerUnit 已按 TexSize 设置为 1x1 世界单位，这里用 localScale 直接映射到期望的世界尺寸
        go.transform.localScale = new Vector3(worldSize, worldSize, 1f);

        if (!string.IsNullOrEmpty(label))
        {
            AddLabel(go, label, worldSize);
        }

        return go;
    }

    static Sprite GetOrCreateSprite(Kind kind, Color color)
    {
        string cacheKey = $"{kind}_{ColorUtility.ToHtmlStringRGBA(color)}";
        if (s_SpriteCache.TryGetValue(cacheKey, out var cached) && cached != null)
        {
            return cached;
        }

        var tex = new Texture2D(TexSize, TexSize, TextureFormat.RGBA32, false);
        tex.hideFlags = HideFlags.DontSave;
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Bilinear;

        FillShape(tex, kind, color);
        tex.Apply();

        // pixelsPerUnit = TexSize，使得该 Sprite 在 localScale=1 时正好覆盖 1x1 世界单位，方便按 worldSize 缩放
        var sprite = Sprite.Create(tex, new Rect(0, 0, TexSize, TexSize), new Vector2(0.5f, 0.5f), TexSize);
        sprite.name = cacheKey;
        sprite.hideFlags = HideFlags.DontSave;
        s_SpriteCache[cacheKey] = sprite;
        return sprite;
    }

    static void FillShape(Texture2D tex, Kind kind, Color color)
    {
        int size = tex.width;
        var clear = new Color(0f, 0f, 0f, 0f);
        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                float u = (x + 0.5f) / size;
                float v = (y + 0.5f) / size;
                bool inside;
                switch (kind)
                {
                    case Kind.Enemy:
                        inside = InsideCircle(u, v, 0.42f);
                        break;
                    case Kind.Boss:
                        inside = InsideSquare(u, v, 0.04f);
                        break;
                    case Kind.Trap:
                        inside = InsideTriangle(u, v);
                        break;
                    case Kind.Item:
                        inside = InsideDiamond(u, v);
                        break;
                    case Kind.Background:
                        inside = InsideSquare(u, v, 0.02f);
                        break;
                    default:
                        inside = InsideCircle(u, v, 0.42f);
                        break;
                }
                tex.SetPixel(x, y, inside ? color : clear);
            }
        }
    }

    static bool InsideCircle(float u, float v, float radius)
    {
        float dx = u - 0.5f;
        float dy = v - 0.5f;
        return dx * dx + dy * dy <= radius * radius;
    }

    static bool InsideSquare(float u, float v, float margin)
    {
        return u >= margin && u <= 1f - margin && v >= margin && v <= 1f - margin;
    }

    // 等边三角形，顶点朝上，留白边距 0.1
    static bool InsideTriangle(float u, float v)
    {
        if (v < 0.1f || v > 0.9f) return false;
        float t = (v - 0.1f) / 0.8f; // 0 = 底边，1 = 顶点
        float halfWidthAtV = 0.4f * (1f - t);
        return Mathf.Abs(u - 0.5f) <= halfWidthAtV;
    }

    static bool InsideDiamond(float u, float v)
    {
        float dx = Mathf.Abs(u - 0.5f);
        float dy = Mathf.Abs(v - 0.5f);
        return dx / 0.42f + dy / 0.42f <= 1f;
    }

    static void AddLabel(GameObject go, string text, float worldSize)
    {
        var labelGo = new GameObject("Label");
        labelGo.hideFlags = HideFlags.DontSave;
        labelGo.transform.SetParent(go.transform, false);
        // 父节点已经按 worldSize 缩放，这里用局部坐标反向补偿，保持文字大小不随占位图形尺寸变化
        float safeSize = Mathf.Max(0.01f, worldSize);
        labelGo.transform.localPosition = new Vector3(0f, 0.75f, 0f);
        labelGo.transform.localScale = new Vector3(1f / safeSize, 1f / safeSize, 1f);

        var tm = labelGo.AddComponent<TextMesh>();
        tm.text = text;
        tm.fontSize = 24;
        tm.characterSize = 0.12f;
        tm.anchor = TextAnchor.LowerCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = Color.white;
    }

    // ---------- 按设计文档 4.5 节表格定义的颜色 ----------

    public static Color EnemyColor => new Color(0.85f, 0.2f, 0.2f, 1f);
    public static Color BossColor => new Color(0.5f, 0.05f, 0.05f, 1f);
    public static Color TrapColor => new Color(0.95f, 0.55f, 0.1f, 1f);
    public static Color BackgroundColor => new Color(0.6f, 0.6f, 0.6f, 0.35f);

    public static Color ItemColor(string itemType)
    {
        switch (itemType)
        {
            case "powerup": return new Color(0.2f, 0.85f, 0.65f, 1f);  // 蓝绿
            case "life": return new Color(0.75f, 0.55f, 0.65f, 1f);    // 粉绿
            case "special": return new Color(0.55f, 0.4f, 0.75f, 1f);  // 紫绿
            case "currency":
            default: return new Color(0.7f, 0.85f, 0.2f, 1f);         // 黄绿（默认）
        }
    }
}
