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
    IntegerField m_InitialWingmanField;
    Toggle m_UseLegacyInitialWingmanField;
    FloatField m_HeroArmorMultiplierField;
    FloatField m_HeroSkillCooldownMultiplierField;

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

        var rulesBox = StgUiUtil.SectionBox("战机规则（不固定英雄，玩家仍可自由选择阵容）");
        m_UseLegacyInitialWingmanField = new Toggle("沿用旧表初始僚机");
        m_UseLegacyInitialWingmanField.RegisterValueChangedCallback(evt =>
        {
            m_Context.Model.playerRules.useLegacyInitialWingman = evt.newValue;
            m_InitialWingmanField.SetEnabled(!evt.newValue);
            m_Context.MarkDirty();
        });
        rulesBox.Add(m_UseLegacyInitialWingmanField);
        m_InitialWingmanField = new IntegerField("初始普通僚机");
        m_InitialWingmanField.RegisterValueChangedCallback(evt => { m_Context.Model.playerRules.initialWingman = evt.newValue; m_Context.MarkDirty(); });
        rulesBox.Add(m_InitialWingmanField);
        m_HeroArmorMultiplierField = new FloatField("英雄装甲倍率");
        m_HeroArmorMultiplierField.RegisterValueChangedCallback(evt => { m_Context.Model.playerRules.heroArmorMultiplier = evt.newValue; m_Context.MarkDirty(); });
        rulesBox.Add(m_HeroArmorMultiplierField);
        m_HeroSkillCooldownMultiplierField = new FloatField("英雄技能冷却倍率");
        m_HeroSkillCooldownMultiplierField.RegisterValueChangedCallback(evt => { m_Context.Model.playerRules.heroSkillCooldownMultiplier = evt.newValue; m_Context.MarkDirty(); });
        rulesBox.Add(m_HeroSkillCooldownMultiplierField);
        var rulesHint = new Label("普通僚机不占英雄槽位，指挥英雄的额外增援会叠加，逻辑数量最多24。装甲倍率按四舍五入取整且至少1；冷却倍率小于1时技能更快。仅作用于本局，不改变英雄养成。保存JSON后重新进入关卡生效。");
        rulesHint.style.color = new Color(0.6f, 0.6f, 0.6f);
        rulesHint.style.whiteSpace = WhiteSpace.Normal;
        rulesBox.Add(rulesHint);
        Root.Add(rulesBox);

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
        var rules = m.playerRules ?? (m.playerRules = new StgPlayerBattleRules());
        m_UseLegacyInitialWingmanField.SetValueWithoutNotify(rules.useLegacyInitialWingman);
        m_InitialWingmanField.SetValueWithoutNotify(rules.initialWingman);
        m_InitialWingmanField.SetEnabled(!rules.useLegacyInitialWingman);
        m_HeroArmorMultiplierField.SetValueWithoutNotify(rules.heroArmorMultiplier);
        m_HeroSkillCooldownMultiplierField.SetValueWithoutNotify(rules.heroSkillCooldownMultiplier);
    }

    public void Rebuild()
    {
        RefreshFromModel();
    }
}
