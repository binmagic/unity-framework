using System.Collections.Generic;
using System.IO;
using System.Xml;
using UnityEditor;
using UnityEngine;

/// <summary>
/// Plist Atlas Viewer - 可视化查看 TexturePacker 生成的 .plist 图集
/// 菜单: Window/Load Plist
/// </summary>
public class PlistAtlasViewer : EditorWindow
{
    #region 数据结构

    private struct SpriteInfo
    {
        public string name;
        public Rect frame;          // 在图集中的位置和尺寸 (像素)
        public Vector2 offset;      // 偏移量
        public bool rotated;        // 是否旋转
        public Rect sourceColorRect;// 源矩形
        public Vector2 sourceSize;  // 原始尺寸
    }

    #endregion

    #region 状态变量

    private string m_PlistPath;
    private Texture2D m_AtlasTexture;
    private List<SpriteInfo> m_Sprites = new List<SpriteInfo>();
    private int m_SelectedIndex = -1;
    private Vector2 m_SpriteListScrollPos;
    private Vector2 m_PreviewScrollPos;
    private float m_Zoom = 1f;
    private Vector2 m_PanOffset;
    private string m_SearchText = "";
    private Vector2 m_AtlasSize;
    private string m_TextureFileName;

    // 样式
    private GUIStyle m_HeaderStyle;
    private GUIStyle m_BoxStyle;
    private bool m_StylesInitialized;

    // 颜色
    private static readonly Color k_SpriteBorderColor = new Color(0f, 1f, 0f, 0.8f);
    private static readonly Color k_RotatedBorderColor = new Color(1f, 1f, 0f, 0.8f); // 黄色 = 旋转
    private static readonly Color k_SelectedBorderColor = new Color(1f, 0f, 0f, 1f);
    private static readonly Color k_SelectedFillColor = new Color(1f, 0f, 0f, 0.15f);
    private static readonly Color k_GridColor = new Color(1f, 1f, 1f, 0.1f);

    #endregion

    #region 菜单入口

    [MenuItem("Window/Load Plist")]
    public static void ShowWindow()
    {
        var path = EditorUtility.OpenFilePanel("选择 Plist 文件", Application.dataPath, "plist");
        if (string.IsNullOrEmpty(path)) return;

        var window = GetWindow<PlistAtlasViewer>("Plist Atlas Viewer");
        window.minSize = new Vector2(900, 600);
        window.LoadPlist(path);
        window.Show();
    }

    #endregion

    #region 初始化样式

    private void InitStyles()
    {
        if (m_StylesInitialized) return;
        m_StylesInitialized = true;

        m_HeaderStyle = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 13,
            margin = new RectOffset(0, 0, 4, 4)
        };

        m_BoxStyle = new GUIStyle("box")
        {
            padding = new RectOffset(8, 8, 8, 8)
        };
    }

    #endregion

    #region Plist 解析

    private void LoadPlist(string plistPath)
    {
        m_PlistPath = plistPath;
        m_Sprites.Clear();
        m_SelectedIndex = -1;
        m_Zoom = 1f;
        m_PanOffset = Vector2.zero;
        m_AtlasTexture = null;
        m_TextureFileName = null;

        // 解析 plist XML
        try
        {
            var doc = new XmlDocument();
            doc.Load(plistPath);

            var rootDict = GetFirstChildDict(doc.DocumentElement);
            if (rootDict == null)
            {
                Debug.LogError("[PlistAtlasViewer] 无法解析 plist 根节点");
                return;
            }

            // 解析 metadata
            var metadataDict = GetDictByKey(rootDict, "metadata");
            if (metadataDict != null)
            {
                m_TextureFileName = GetStringByKey(metadataDict, "realTextureFileName");
                var sizeStr = GetStringByKey(metadataDict, "size");
                if (!string.IsNullOrEmpty(sizeStr))
                {
                    m_AtlasSize = ParseVector2(sizeStr);
                }
            }

            // 解析 frames
            var framesDict = GetDictByKey(rootDict, "frames");
            if (framesDict != null)
            {
                ParseFrames(framesDict);
            }

            // 加载纹理
            LoadAtlasTexture(plistPath);
        }
        catch (System.Exception e)
        {
            Debug.LogError($"[PlistAtlasViewer] 解析 plist 失败: {e.Message}");
        }
    }

    private void ParseFrames(XmlElement framesDict)
    {
        var children = framesDict.ChildNodes;
        string currentKey = null;

        for (int i = 0; i < children.Count; i++)
        {
            var node = children[i];
            if (node is XmlElement elem)
            {
                if (elem.Name == "key")
                {
                    currentKey = elem.InnerText;
                }
                else if (elem.Name == "dict" && currentKey != null)
                {
                    var sprite = ParseSpriteDict(elem, currentKey);
                    m_Sprites.Add(sprite);
                    currentKey = null;
                }
            }
        }
    }

    private SpriteInfo ParseSpriteDict(XmlElement dict, string name)
    {
        var sprite = new SpriteInfo { name = name };

        var children = dict.ChildNodes;
        string currentKey = null;

        for (int i = 0; i < children.Count; i++)
        {
            var node = children[i];
            if (node is XmlElement elem)
            {
                if (elem.Name == "key")
                {
                    currentKey = elem.InnerText;
                }
                else if (currentKey != null)
                {
                    switch (currentKey)
                    {
                        case "frame":
                            sprite.frame = RectFromString(elem.InnerText);
                            break;
                        case "offset":
                            sprite.offset = ParseVector2(elem.InnerText);
                            break;
                        case "rotated":
                            sprite.rotated = elem.Name == "true";
                            break;
                        case "sourceColorRect":
                            sprite.sourceColorRect = RectFromString(elem.InnerText);
                            break;
                        case "sourceSize":
                            sprite.sourceSize = ParseVector2(elem.InnerText);
                            break;
                    }
                    currentKey = null;
                }
            }
        }

        return sprite;
    }

    private void LoadAtlasTexture(string plistPath)
    {
        var dir = Path.GetDirectoryName(plistPath);
        var texName = !string.IsNullOrEmpty(m_TextureFileName) ? m_TextureFileName : Path.GetFileNameWithoutExtension(plistPath) + ".png";
        var texPath = Path.Combine(dir, texName);

        if (!File.Exists(texPath))
        {
            // 尝试 .png
            texPath = Path.Combine(dir, Path.GetFileNameWithoutExtension(plistPath) + ".png");
        }

        if (!File.Exists(texPath))
        {
            Debug.LogWarning($"[PlistAtlasViewer] 找不到对应的纹理文件: {texPath}");
            return;
        }

        // 转为 Unity 相对路径
        var relativePath = "Assets" + texPath.Replace(Application.dataPath, "").Replace("\\", "/");
        m_AtlasTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(relativePath);

        if (m_AtlasTexture == null)
        {
            // 尝试直接加载
            var bytes = File.ReadAllBytes(texPath);
            m_AtlasTexture = new Texture2D(2, 2);
            m_AtlasTexture.LoadImage(bytes);
            m_AtlasTexture.name = Path.GetFileNameWithoutExtension(texPath);
        }
    }

    #endregion

    #region XML 解析辅助

    private static XmlElement GetFirstChildDict(XmlElement parent)
    {
        foreach (XmlNode child in parent.ChildNodes)
        {
            if (child is XmlElement elem && elem.Name == "dict")
                return elem;
        }
        return null;
    }

    private static XmlElement GetDictByKey(XmlElement parent, string targetKey)
    {
        var children = parent.ChildNodes;
        for (int i = 0; i < children.Count; i++)
        {
            if (children[i] is XmlElement elem && elem.Name == "key" && elem.InnerText == targetKey)
            {
                // 找到 key，返回下一个 dict
                for (int j = i + 1; j < children.Count; j++)
                {
                    if (children[j] is XmlElement next && next.Name == "dict")
                        return next;
                }
            }
        }
        return null;
    }

    private static string GetStringByKey(XmlElement parent, string targetKey)
    {
        var children = parent.ChildNodes;
        for (int i = 0; i < children.Count; i++)
        {
            if (children[i] is XmlElement elem && elem.Name == "key" && elem.InnerText == targetKey)
            {
                for (int j = i + 1; j < children.Count; j++)
                {
                    if (children[j] is XmlElement next && next.Name == "string")
                        return next.InnerText;
                }
            }
        }
        return null;
    }

    /// <summary>
    /// 解析 "{w,h}" 格式的向量
    /// </summary>
    private static Vector2 ParseVector2(string str)
    {
        str = str.Trim('{', '}', ' ');
        var parts = str.Split(',');
        if (parts.Length >= 2 &&
            float.TryParse(parts[0].Trim(), out var x) &&
            float.TryParse(parts[1].Trim(), out var y))
        {
            return new Vector2(x, y);
        }
        return Vector2.zero;
    }

    /// <summary>
    /// 解析 "{{x,y},{w,h}}" 格式的矩形
    /// </summary>
    private static Rect RectFromString(string str)
    {
        // 格式: {{x,y},{w,h}}
        str = str.Replace("},{", "|").Trim('{', '}');
        var parts = str.Split('|');
        if (parts.Length >= 2)
        {
            var pos = ParseVector2(parts[0]);
            var size = ParseVector2(parts[1]);
            return new Rect(pos.x, pos.y, size.x, size.y);
        }
        return Rect.zero;
    }

    #endregion

    #region GUI 绘制

    private void OnGUI()
    {
        InitStyles();

        // 工具栏
        DrawToolbar();

        if (m_Sprites.Count == 0)
        {
            EditorGUILayout.HelpBox("请通过 Window → Load Plist 打开一个 .plist 文件", MessageType.Info);
            return;
        }

        // 主内容区域：左预览 + 右信息
        EditorGUILayout.BeginHorizontal();
        {
            // 左侧：图集预览（占 2/3）
            DrawPreviewArea();

            // 右侧：信息面板（占 1/3）
            EditorGUILayout.BeginVertical(GUILayout.Width(280));
            {
                DrawInfoPanel();
                GUILayout.Space(4);
                DrawSpriteList();
            }
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawToolbar()
    {
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        {
            if (!string.IsNullOrEmpty(m_PlistPath))
            {
                GUILayout.Label($"文件: {Path.GetFileName(m_PlistPath)}", EditorStyles.miniLabel);
                GUILayout.Label($"精灵数: {m_Sprites.Count}", EditorStyles.miniLabel);
                if (m_AtlasTexture != null)
                    GUILayout.Label($"图集: {m_AtlasTexture.width}x{m_AtlasTexture.height}", EditorStyles.miniLabel);
            }

            GUILayout.FlexibleSpace();

            // 缩放控制
            GUILayout.Label("缩放:", EditorStyles.miniLabel, GUILayout.Width(32));
            m_Zoom = GUILayout.HorizontalSlider(m_Zoom, 0.1f, 5f, GUILayout.Width(100));
            GUILayout.Label($"{m_Zoom:F1}x", EditorStyles.miniLabel, GUILayout.Width(32));

            if (GUILayout.Button("适应", EditorStyles.toolbarButton, GUILayout.Width(40)))
                ResetView();

            if (GUILayout.Button("重载", EditorStyles.toolbarButton, GUILayout.Width(40)))
            {
                if (!string.IsNullOrEmpty(m_PlistPath))
                    LoadPlist(m_PlistPath);
            }
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawPreviewArea()
    {
        // 预览区域
        var previewRect = EditorGUILayout.BeginVertical(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
        {
            if (m_AtlasTexture == null)
            {
                EditorGUILayout.HelpBox("无法加载图集纹理", MessageType.Warning);
                EditorGUILayout.EndVertical();
                return;
            }

            // 处理鼠标事件
            HandleMouseEvents(previewRect);

            // 计算绘制区域
            var texWidth = m_AtlasTexture.width * m_Zoom;
            var texHeight = m_AtlasTexture.height * m_Zoom;

            // 滚动视图
            m_PreviewScrollPos = EditorGUILayout.BeginScrollView(m_PreviewScrollPos);
            {
                var contentRect = new Rect(m_PanOffset.x, m_PanOffset.y, texWidth, texHeight);
                GUILayout.Space(contentRect.yMax + 10);

                // 绘制纹理
                var texRect = new Rect(contentRect.x, contentRect.y, texWidth, texHeight);
                GUI.DrawTexture(texRect, m_AtlasTexture, ScaleMode.ScaleToFit, true);

                // 绘制所有精灵边框
                for (int i = 0; i < m_Sprites.Count; i++)
                {
                    var sprite = m_Sprites[i];
                    var spriteRect = GetSpriteScreenRect(sprite);

                    bool isSelected = i == m_SelectedIndex;

                    if (isSelected)
                    {
                        EditorGUI.DrawRect(spriteRect, k_SelectedFillColor);
                        DrawRectOutline(spriteRect, k_SelectedBorderColor, 2f);
                    }
                    else
                    {
                        // 旋转精灵用黄色边框，非旋转用绿色
                        var color = sprite.rotated ? k_RotatedBorderColor : k_SpriteBorderColor;
                        DrawRectOutline(spriteRect, color, 1f);
                    }

                    // 旋转标记: 精灵名称旁显示 [R]
                    if (sprite.rotated)
                    {
                        var labelStyle = EditorStyles.miniLabel;
                        var labelText = "[R]";
                        var labelContent = new GUIContent(labelText);
                        var labelSize = labelStyle.CalcSize(labelContent);
                        var labelRect = new Rect(
                            spriteRect.x + 2,
                            spriteRect.y + 1,
                            labelSize.x,
                            labelSize.y
                        );
                        EditorGUI.DrawRect(labelRect, new Color(0, 0, 0, 0.5f));
                        GUI.Label(labelRect, labelContent, labelStyle);
                    }
                }
            }
            EditorGUILayout.EndScrollView();
        }
        EditorGUILayout.EndVertical();
    }

    private void DrawInfoPanel()
    {
        EditorGUILayout.LabelField("精灵信息", m_HeaderStyle);

        if (m_SelectedIndex < 0 || m_SelectedIndex >= m_Sprites.Count)
        {
            EditorGUILayout.HelpBox("点击图集中的精灵或右侧列表查看信息", MessageType.Info);
            return;
        }

        var sprite = m_Sprites[m_SelectedIndex];

        EditorGUILayout.BeginVertical(m_BoxStyle);
        {
            DrawInfoRow("名称", sprite.name);
            GUILayout.Space(2);

            EditorGUILayout.LabelField("Frame (图集坐标)", EditorStyles.miniBoldLabel);
            EditorGUI.indentLevel++;
            DrawInfoRow("X", sprite.frame.x.ToString("F0"));
            DrawInfoRow("Y", sprite.frame.y.ToString("F0"));
            DrawInfoRow("宽", sprite.frame.width.ToString("F0"));
            DrawInfoRow("高", sprite.frame.height.ToString("F0"));
            EditorGUI.indentLevel--;

            GUILayout.Space(4);
            EditorGUILayout.LabelField("属性", EditorStyles.miniBoldLabel);
            EditorGUI.indentLevel++;
            DrawInfoRow("旋转", sprite.rotated ? "是" : "否");
            DrawInfoRow("偏移", $"({sprite.offset.x}, {sprite.offset.y})");
            DrawInfoRow("原始尺寸", $"{sprite.sourceSize.x} x {sprite.sourceSize.y}");
            EditorGUI.indentLevel--;

            if (sprite.sourceColorRect != Rect.zero)
            {
                GUILayout.Space(4);
                EditorGUILayout.LabelField("Source Color Rect", EditorStyles.miniBoldLabel);
                EditorGUI.indentLevel++;
                DrawInfoRow("X", sprite.sourceColorRect.x.ToString("F0"));
                DrawInfoRow("Y", sprite.sourceColorRect.y.ToString("F0"));
                DrawInfoRow("宽", sprite.sourceColorRect.width.ToString("F0"));
                DrawInfoRow("高", sprite.sourceColorRect.height.ToString("F0"));
                EditorGUI.indentLevel--;
            }
        }
        EditorGUILayout.EndVertical();
    }

    private void DrawSpriteList()
    {
        EditorGUILayout.LabelField($"精灵列表 ({m_Sprites.Count})", m_HeaderStyle);

        // 搜索框
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Label("搜索:", GUILayout.Width(36));
            m_SearchText = EditorGUILayout.TextField(m_SearchText);
            if (GUILayout.Button("X", GUILayout.Width(20)))
                m_SearchText = "";
        }
        EditorGUILayout.EndHorizontal();

        // 列表
        m_SpriteListScrollPos = EditorGUILayout.BeginScrollView(m_SpriteListScrollPos, GUILayout.ExpandHeight(true));
        {
            for (int i = 0; i < m_Sprites.Count; i++)
            {
                var sprite = m_Sprites[i];

                // 搜索过滤
                if (!string.IsNullOrEmpty(m_SearchText) &&
                    !sprite.name.ToLower().Contains(m_SearchText.ToLower()))
                    continue;

                bool isSelected = i == m_SelectedIndex;
                var style = isSelected ? EditorStyles.selectionRect : GUI.skin.button;

                if (GUILayout.Button(sprite.name, style))
                {
                    m_SelectedIndex = i;
                    CenterOnSprite(sprite);
                    Repaint();
                }
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void DrawInfoRow(string label, string value)
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Label(label, GUILayout.Width(60));
            EditorGUILayout.SelectableLabel(value, GUILayout.Height(16));
        }
        EditorGUILayout.EndHorizontal();
    }

    #endregion

    #region 鼠标交互

    private void HandleMouseEvents(Rect previewRect)
    {
        var e = Event.current;

        // 鼠标滚轮缩放
        if (e.type == EventType.ScrollWheel && previewRect.Contains(e.mousePosition))
        {
            var delta = -e.delta.y * 0.05f;
            m_Zoom = Mathf.Clamp(m_Zoom + delta, 0.1f, 5f);
            e.Use();
            Repaint();
        }

        // 鼠标拖拽平移
        if (e.type == EventType.MouseDrag && e.button == 2) // 中键
        {
            m_PanOffset += e.delta;
            e.Use();
            Repaint();
        }

        // 鼠标点击选中精灵
        if (e.type == EventType.MouseDown && e.button == 0 && previewRect.Contains(e.mousePosition))
        {
            // 将鼠标位置转换为图集像素坐标（左上角原点，Y 向下）
            var localPos = e.mousePosition - previewRect.position + m_PreviewScrollPos;
            var atlasX = (localPos.x - m_PanOffset.x) / m_Zoom;
            var atlasY = (localPos.y - m_PanOffset.y) / m_Zoom;
            var clicked = new Vector2(atlasX, atlasY);

            // 查找点击的精灵（从后往前，后面的覆盖前面的）
            int found = -1;
            for (int i = m_Sprites.Count - 1; i >= 0; i--)
            {
                var r = GetSpriteRect(m_Sprites[i]);
                if (clicked.x >= r.x && clicked.x <= r.x + r.width &&
                    clicked.y >= r.y && clicked.y <= r.y + r.height)
                {
                    found = i;
                    break;
                }
            }

            if (found >= 0)
            {
                m_SelectedIndex = found;
                e.Use();
                Repaint();
            }
        }
    }

    #endregion

    #region 辅助方法

    /// <summary>
    /// 将图集像素坐标转换为屏幕绘制坐标
    /// plist 和 GUI.DrawTexture 都是左上角原点、Y 向下，坐标系一致，无需翻转
    /// </summary>
    private Rect GetScreenRect(Rect frame)
    {
        return new Rect(
            m_PanOffset.x + frame.x * m_Zoom,
            m_PanOffset.y + frame.y * m_Zoom,
            frame.width * m_Zoom,
            frame.height * m_Zoom
        );
    }

    /// <summary>
    /// 获取精灵在图集中的实际显示矩形
    /// 旋转精灵的 frame 存的是旋转后尺寸（宽高互换），只交换宽高，位置不变
    /// </summary>
    private static Rect GetSpriteRect(SpriteInfo sprite)
    {
        var f = sprite.frame;
        if (!sprite.rotated)
            return f;

        // 旋转精灵: 只交换宽高，x/y 保持不变
        return new Rect(f.x, f.y, f.height, f.width);
    }

    /// <summary>
    /// 获取精灵的屏幕绘制矩形（含缩放和偏移）
    /// </summary>
    private Rect GetSpriteScreenRect(SpriteInfo sprite)
    {
        var r = GetSpriteRect(sprite);
        return new Rect(
            m_PanOffset.x + r.x * m_Zoom,
            m_PanOffset.y + r.y * m_Zoom,
            r.width * m_Zoom,
            r.height * m_Zoom
        );
    }

    /// <summary>
    /// 绘制矩形边框
    /// </summary>
    private static void DrawRectOutline(Rect rect, Color color, float width)
    {
        // 上
        EditorGUI.DrawRect(new Rect(rect.x, rect.y, rect.width, width), color);
        // 下
        EditorGUI.DrawRect(new Rect(rect.x, rect.yMax - width, rect.width, width), color);
        // 左
        EditorGUI.DrawRect(new Rect(rect.x, rect.y, width, rect.height), color);
        // 右
        EditorGUI.DrawRect(new Rect(rect.xMax - width, rect.y, width, rect.height), color);
    }

    /// <summary>
    /// 将预览视图居中到指定精灵
    /// </summary>
    private void CenterOnSprite(SpriteInfo sprite)
    {
        var r = GetSpriteRect(sprite);
        var previewWidth = position.width - 300;
        var previewHeight = position.height - 40;

        m_PanOffset = new Vector2(
            previewWidth / 2f - (r.x + r.width / 2f) * m_Zoom,
            previewHeight / 2f - (r.y + r.height / 2f) * m_Zoom
        );
    }

    /// <summary>
    /// 重置视图（适应窗口大小）
    /// </summary>
    private void ResetView()
    {
        if (m_AtlasTexture == null) return;

        var previewWidth = position.width - 300;
        var previewHeight = position.height - 60;

        var scaleX = previewWidth / m_AtlasTexture.width;
        var scaleY = previewHeight / m_AtlasTexture.height;
        m_Zoom = Mathf.Min(scaleX, scaleY) * 0.9f;
        m_Zoom = Mathf.Clamp(m_Zoom, 0.1f, 5f);

        m_PanOffset = new Vector2(
            (previewWidth - m_AtlasTexture.width * m_Zoom) / 2f,
            10f
        );
    }

    #endregion
}
