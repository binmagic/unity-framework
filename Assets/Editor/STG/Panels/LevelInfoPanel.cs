using UnityEngine;
using UnityEngine.UIElements;

// ① 关卡元信息面板：levelId/levelName/description/seed/duration(只读)
public class LevelInfoPanel : IStgPanel
{
    public string TabTitle => "① 关卡元信息";
    public VisualElement Root { get; }

    readonly StgLevelEditorContext m_Context;
    TextField m_LevelIdField;
    TextField m_LevelNameField;
    TextField m_DescriptionField;
    IntegerField m_SeedField;
    FloatField m_DurationField;

    public LevelInfoPanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        Root.style.paddingLeft = 8;
        Root.style.paddingRight = 8;
        Root.style.paddingTop = 8;

        BuildUI();
    }

    void BuildUI()
    {
        Root.Clear();

        m_LevelIdField = new TextField("关卡ID");
        m_LevelIdField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.levelId = evt.newValue;
            m_Context.MarkDirty();
        });
        Root.Add(m_LevelIdField);

        m_LevelNameField = new TextField("关卡名称");
        m_LevelNameField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.levelName = evt.newValue;
            m_Context.MarkDirty();
        });
        Root.Add(m_LevelNameField);

        m_DescriptionField = new TextField("描述");
        m_DescriptionField.multiline = true;
        m_DescriptionField.style.height = 60;
        m_DescriptionField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.description = evt.newValue;
            m_Context.MarkDirty();
        });
        Root.Add(m_DescriptionField);

        var seedRow = new VisualElement();
        seedRow.style.flexDirection = FlexDirection.Row;
        m_SeedField = new IntegerField("随机种子 (seed)");
        m_SeedField.style.flexGrow = 1;
        m_SeedField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.seed = evt.newValue;
            m_Context.MarkDirty();
        });
        var randomButton = new Button(() =>
        {
            int rand = new System.Random().Next(0, int.MaxValue);
            m_SeedField.value = rand;
        }) { text = "随机生成" };
        seedRow.Add(m_SeedField);
        seedRow.Add(randomButton);
        Root.Add(seedRow);

        m_DurationField = new FloatField("关卡时长 (秒，只读)");
        m_DurationField.SetEnabled(false);
        Root.Add(m_DurationField);

        var hint = new Label("时长由③时间轴编辑器里最后一个事件的时间反算，避免与手填数值不一致。");
        hint.style.color = new Color(0.6f, 0.6f, 0.6f);
        hint.style.whiteSpace = WhiteSpace.Normal;
        Root.Add(hint);

        RefreshFromModel();
    }

    void RefreshFromModel()
    {
        var m = m_Context.Model;
        m_LevelIdField.SetValueWithoutNotify(m.levelId);
        m_LevelNameField.SetValueWithoutNotify(m.levelName);
        m_DescriptionField.SetValueWithoutNotify(m.description);
        m_SeedField.SetValueWithoutNotify(m.seed);
        m_DurationField.SetValueWithoutNotify(m.timeline.duration);
    }

    public void Rebuild()
    {
        RefreshFromModel();
    }
}
