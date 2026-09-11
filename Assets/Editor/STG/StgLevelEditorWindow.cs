using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

/// <summary>
/// STG 关卡编辑器主窗口，菜单: Window/STG/关卡编辑器
/// 左侧 Tab 切换九个面板，右侧显示当前面板内容。
/// 设计依据: Docs/STG/STG 关卡编辑器设计.md 第二节
/// </summary>
public class StgLevelEditorWindow : EditorWindow
{
    StgLevelEditorContext m_Context;
    readonly List<IStgPanel> m_Panels = new List<IStgPanel>();
    VisualElement m_ContentRoot;
    readonly List<Button> m_TabButtons = new List<Button>();
    int m_SelectedIndex = 0;

    [MenuItem("Window/STG/关卡编辑器")]
    public static void ShowWindow()
    {
        var window = GetWindow<StgLevelEditorWindow>("STG 关卡编辑器");
        window.minSize = new Vector2(960, 640);
        window.Show();
    }

    void OnEnable()
    {
        m_Context = new StgLevelEditorContext();
        BuildPanels();
        BuildLayout();
    }

    // 关闭窗口时必须停止预览：否则 EditorApplication.update 挂接和 __StgPreviewRoot__ 预览对象会常驻，
    // 详见关卡编辑器设计文档 4.3 节"点击停止预览或关闭主窗口"
    void OnDisable()
    {
        if (StgPreviewRuntime.IsPlaying)
        {
            StgPreviewRuntime.Stop();
        }
    }

    void BuildPanels()
    {
        m_Panels.Clear();

        var importExportPanel = new ImportExportPanel(m_Context, OnModelReloaded);
        var levelInfoPanel = new LevelInfoPanel(m_Context);
        var backgroundPanel = new BackgroundConfigPanel(m_Context);
        var timelinePanel = new TimelineEditorPanel(m_Context);
        var wavePanel = new WaveTemplatePanel(m_Context);
        var bossPanel = new BossConfigPanel(m_Context);
        var trapPanel = new TrapConfigPanel(m_Context);
        var itemDropPanel = new ItemDropPanel(m_Context);
        var validationPanel = new ValidationPanel(m_Context);

        m_Panels.Add(levelInfoPanel);
        m_Panels.Add(backgroundPanel);
        m_Panels.Add(timelinePanel);
        m_Panels.Add(wavePanel);
        m_Panels.Add(bossPanel);
        m_Panels.Add(trapPanel);
        m_Panels.Add(itemDropPanel);
        m_Panels.Add(validationPanel);
        m_Panels.Add(importExportPanel);

        // 跨面板引用变化（新增/删除模板ID等）时，让所有面板刷新下拉选项
        m_Context.OnCrossReferencesChanged += () =>
        {
            foreach (var p in m_Panels) p.Rebuild();
        };
    }

    void OnModelReloaded()
    {
        // 模型即将被整体替换（新建/打开）：预览运行时持有的是旧 Model 里的对象引用（ConfigRef 等），
        // 模型换掉后这些引用会失效，必须先停止预览，避免下一帧 Tick 时访问到脏数据
        if (StgPreviewRuntime.IsPlaying)
        {
            StgPreviewRuntime.Stop();
        }

        foreach (var p in m_Panels) p.Rebuild();
        m_Context.NotifyCrossReferencesChanged();
    }

    void BuildLayout()
    {
        rootVisualElement.Clear();

        var mainRow = new VisualElement();
        mainRow.style.flexDirection = FlexDirection.Row;
        mainRow.style.flexGrow = 1;
        rootVisualElement.Add(mainRow);

        var tabColumn = new VisualElement();
        tabColumn.style.width = 160;
        tabColumn.style.borderRightWidth = 1;
        tabColumn.style.borderRightColor = new Color(0.15f, 0.15f, 0.15f);
        tabColumn.style.flexShrink = 0;
        mainRow.Add(tabColumn);

        m_ContentRoot = new VisualElement();
        m_ContentRoot.style.flexGrow = 1;
        m_ContentRoot.style.paddingTop = 4;
        mainRow.Add(m_ContentRoot);

        m_TabButtons.Clear();
        for (int i = 0; i < m_Panels.Count; i++)
        {
            int index = i;
            var button = new Button(() => SelectTab(index)) { text = m_Panels[i].TabTitle };
            button.style.unityTextAlign = TextAnchor.MiddleLeft;
            button.style.marginLeft = 0;
            button.style.marginRight = 0;
            button.style.borderTopLeftRadius = 0;
            button.style.borderTopRightRadius = 0;
            button.style.borderBottomLeftRadius = 0;
            button.style.borderBottomRightRadius = 0;
            tabColumn.Add(button);
            m_TabButtons.Add(button);
        }

        SelectTab(0);
    }

    void SelectTab(int index)
    {
        m_SelectedIndex = index;
        m_ContentRoot.Clear();

        var panel = m_Panels[index];
        panel.Rebuild();

        // 时间轴编辑器（③）默认展开更大的高度，参照设计文档 2.1 节布局说明
        if (panel is TimelineEditorPanel)
        {
            panel.Root.style.minHeight = 420;
        }

        m_ContentRoot.Add(panel.Root);

        for (int i = 0; i < m_TabButtons.Count; i++)
        {
            m_TabButtons[i].style.backgroundColor = i == index
                ? new Color(0.24f, 0.37f, 0.58f)
                : new StyleColor(StyleKeyword.Null);
        }
    }
}
