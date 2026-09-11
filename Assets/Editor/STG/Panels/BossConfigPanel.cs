using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
// 项目全局命名空间下有自定义 uGUI 类 Assets/Main/Scripts/Common/UIExtension/ScrollView.cs，
// 与 UnityEngine.UIElements.ScrollView 同名，别名不能叫 ScrollView（同样会跟全局命名空间里的类撞名），改叫 UiScrollView
using UiScrollView = UnityEngine.UIElements.ScrollView;

// ⑤ Boss配置面板：bossConfigs -> phases -> skills，九个面板里嵌套层级最深的一个
// 技能字段按 skillId 动态显示，用映射表驱动，避免为每种技能写一份重复表单
public class BossConfigPanel : IStgPanel
{
    public string TabTitle => "⑤ Boss配置";
    public VisualElement Root { get; }

    static readonly string[] EntryAnimations = { "fly_in_from_top", "fly_in_from_left", "fly_in_from_right", "rise_from_bottom", "teleport_in" };
    static readonly string[] MovePatterns = { "horizontal_patrol", "vertical_patrol", "figure_eight", "stationary_center", "chase_player" };
    static readonly string[] SkillIds = { "spread_shot", "aimed_shot", "laser_beam", "bullet_hell", "summon_minions", "missile_volley", "shield_up" };

    // 技能类型 -> 该类型专属需要显示的字段名（对齐设计文档 3.2 节技能类型枚举表）
    static readonly Dictionary<string, string[]> SkillFieldMap = new Dictionary<string, string[]>
    {
        { "spread_shot", new[] { "bulletCount", "spreadAngle" } },
        { "aimed_shot", new[] { "bulletCount" } },
        { "laser_beam", new[] { "duration", "width" } },
        { "bullet_hell", new[] { "bulletCount", "rings" } },
        { "summon_minions", new[] { "waveTemplateId", "count" } },
        { "missile_volley", new[] { "bulletCount", "speed" } },
        { "shield_up", new[] { "duration", "damageReduction" } },
    };

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_SplitRoot;

    public BossConfigPanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        m_SplitRoot = new VisualElement();
        Root.Add(m_SplitRoot);
        BuildUI();
    }

    void BuildUI()
    {
        m_SplitRoot.Clear();
        m_SplitRoot.style.flexDirection = FlexDirection.Row;
        m_SplitRoot.style.flexGrow = 1;

        var list = m_Context.Model.bossConfigs;
        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, StgUiUtil.MakeMasterRow, (el, i) => StgUiUtil.BindMasterRow(el, list[i].bossName, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 200;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgBossConfig { bossId = $"boss_{System.Guid.NewGuid().ToString("N").Substring(0, 6)}", bossName = "新Boss" };
            }
            listView.Rebuild();
            m_Context.MarkDirty();
            m_Context.NotifyCrossReferencesChanged();
        };
        listView.itemsRemoved += _ =>
        {
            m_Context.MarkDirty();
            m_Context.NotifyCrossReferencesChanged();
            detailHost.Clear();
        };
        listView.selectionChanged += items =>
        {
            detailHost.Clear();
            foreach (var obj in items)
            {
                if (obj is StgBossConfig b) detailHost.Add(BuildBossDetail(b, listView));
                break;
            }
        };

        m_SplitRoot.Add(listView);

        var scroll = new UiScrollView();
        scroll.style.flexGrow = 1;
        scroll.Add(detailHost);
        m_SplitRoot.Add(scroll);
    }

    VisualElement BuildBossDetail(StgBossConfig b, ListView ownerListView)
    {
        var box = new VisualElement();

        var bossId = new TextField("Boss ID") { value = b.bossId };
        bossId.RegisterValueChangedCallback(evt => { b.bossId = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); });
        box.Add(bossId);

        var bossName = new TextField("Boss 名称") { value = b.bossName };
        bossName.RegisterValueChangedCallback(evt => { b.bossName = evt.newValue; m_Context.MarkDirty(); ownerListView.Rebuild(); });
        box.Add(bossName);

        var prefabPath = new TextField("预制件路径") { value = b.prefabPath };
        prefabPath.RegisterValueChangedCallback(evt => { b.prefabPath = evt.newValue; m_Context.MarkDirty(); });
        box.Add(prefabPath);

        var entryAnimation = new PopupField<string>("入场动画", new List<string>(EntryAnimations), StgUiUtil.SafeIndexOf(EntryAnimations, b.entryAnimation));
        entryAnimation.RegisterValueChangedCallback(evt => { b.entryAnimation = evt.newValue; m_Context.MarkDirty(); });
        box.Add(entryAnimation);

        var totalHp = new IntegerField("总血量 totalHp") { value = b.totalHp };
        totalHp.RegisterValueChangedCallback(evt => { b.totalHp = evt.newValue; m_Context.MarkDirty(); });
        box.Add(totalHp);

        var score = new IntegerField("得分 score") { value = b.score };
        score.RegisterValueChangedCallback(evt => { b.score = evt.newValue; m_Context.MarkDirty(); });
        box.Add(score);

        var onDefeatEvent = new TextField("击败后触发事件 onDefeatEvent") { value = b.onDefeatEvent };
        onDefeatEvent.RegisterValueChangedCallback(evt => { b.onDefeatEvent = evt.newValue; m_Context.MarkDirty(); });
        box.Add(onDefeatEvent);

        box.Add(StgUiUtil.SectionLabel("固定掉落 (dropOnDeath)"));
        box.Add(BuildDropOnDeathList(b.dropOnDeath));

        box.Add(StgUiUtil.SectionLabel("阶段 (phases)"));
        var phasesHost = new VisualElement();
        box.Add(phasesHost);
        RebuildPhasesList(phasesHost, b);

        var addPhaseButton = new Button(() =>
        {
            b.phases.Add(new StgBossPhase { phaseId = b.phases.Count + 1, hpThreshold = 1.0f });
            m_Context.MarkDirty();
            RebuildPhasesList(phasesHost, b);
        })
        { text = "+ 新增阶段" };
        box.Add(addPhaseButton);

        return box;
    }

    VisualElement BuildDropOnDeathList(List<StgDropFixedEntry> drops)
    {
        var listView = new ListView(drops, 20, () =>
        {
            var row = new VisualElement();
            row.style.flexDirection = FlexDirection.Row;
            var itemId = new TextField { name = "itemId" };
            itemId.style.width = 150;
            var count = new IntegerField { name = "count" };
            count.style.width = 60;
            row.Add(itemId);
            row.Add(count);

            itemId.RegisterValueChangedCallback(evt => { if (row.userData is StgDropFixedEntry e) { e.itemId = evt.newValue; m_Context.MarkDirty(); } });
            count.RegisterValueChangedCallback(evt => { if (row.userData is StgDropFixedEntry e) { e.count = evt.newValue; m_Context.MarkDirty(); } });
            return row;
        },
        (el, i) =>
        {
            el.userData = drops[i];
            el.Q<TextField>("itemId").SetValueWithoutNotify(drops[i].itemId);
            el.Q<IntegerField>("count").SetValueWithoutNotify(drops[i].count);
        });
        listView.style.height = 100;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += _ =>
        {
            drops[drops.Count - 1] = new StgDropFixedEntry { count = 1 };
            listView.Rebuild();
            m_Context.MarkDirty();
        };
        listView.itemsRemoved += _ => { m_Context.MarkDirty(); };
        return listView;
    }

    void RebuildPhasesList(VisualElement host, StgBossConfig b)
    {
        host.Clear();
        for (int i = 0; i < b.phases.Count; i++)
        {
            var phase = b.phases[i];
            var foldout = new Foldout { text = $"阶段 {phase.phaseId}", value = true };
            foldout.Add(BuildPhaseDetail(phase, b, host));
            host.Add(foldout);
        }
    }

    VisualElement BuildPhaseDetail(StgBossPhase phase, StgBossConfig owner, VisualElement phasesHost)
    {
        var box = new VisualElement();

        var phaseId = new IntegerField("阶段序号 phaseId") { value = phase.phaseId };
        phaseId.RegisterValueChangedCallback(evt => { phase.phaseId = evt.newValue; m_Context.MarkDirty(); });
        box.Add(phaseId);

        var hpThreshold = new Slider("血量阈值 hpThreshold", 0f, 1f) { value = phase.hpThreshold, showInputField = true };
        hpThreshold.RegisterValueChangedCallback(evt => { phase.hpThreshold = evt.newValue; m_Context.MarkDirty(); });
        box.Add(hpThreshold);

        var movePattern = new PopupField<string>("移动模式", new List<string>(MovePatterns), StgUiUtil.SafeIndexOf(MovePatterns, phase.movePattern));
        movePattern.RegisterValueChangedCallback(evt => { phase.movePattern = evt.newValue; m_Context.MarkDirty(); });
        box.Add(movePattern);

        var removePhaseButton = new Button(() =>
        {
            owner.phases.Remove(phase);
            m_Context.MarkDirty();
            RebuildPhasesList(phasesHost, owner);
        })
        { text = "删除本阶段" };
        box.Add(removePhaseButton);

        box.Add(StgUiUtil.SectionLabel("技能 (skills)"));
        var skillsHost = new VisualElement();
        box.Add(skillsHost);
        RebuildSkillsList(skillsHost, phase);

        var addSkillButton = new Button(() =>
        {
            phase.skills.Add(new StgBossSkill());
            m_Context.MarkDirty();
            RebuildSkillsList(skillsHost, phase);
        })
        { text = "+ 新增技能" };
        box.Add(addSkillButton);

        return box;
    }

    void RebuildSkillsList(VisualElement host, StgBossPhase phase)
    {
        host.Clear();
        for (int i = 0; i < phase.skills.Count; i++)
        {
            var skill = phase.skills[i];
            var skillBox = StgUiUtil.SectionBox($"技能 {i + 1}");
            skillBox.Add(BuildSkillDetail(skill, phase, host));
            host.Add(skillBox);
        }
    }

    VisualElement BuildSkillDetail(StgBossSkill skill, StgBossPhase owner, VisualElement skillsHost)
    {
        var box = new VisualElement();

        var skillId = new PopupField<string>("技能类型 skillId", new List<string>(SkillIds), StgUiUtil.SafeIndexOf(SkillIds, skill.skillId));
        box.Add(skillId);

        var interval = new FloatField("触发间隔 interval") { value = skill.interval };
        interval.RegisterValueChangedCallback(evt => { skill.interval = evt.newValue; m_Context.MarkDirty(); });
        box.Add(interval);

        var dynamicFields = new VisualElement();
        box.Add(dynamicFields);

        void RebuildDynamicFields()
        {
            dynamicFields.Clear();
            if (!SkillFieldMap.TryGetValue(skill.skillId, out var fieldNames)) return;

            foreach (var fieldName in fieldNames)
            {
                dynamicFields.Add(BuildSkillField(skill, fieldName));
            }
        }

        skillId.RegisterValueChangedCallback(evt =>
        {
            skill.skillId = evt.newValue;
            m_Context.MarkDirty();
            RebuildDynamicFields();
        });
        RebuildDynamicFields();

        var removeButton = new Button(() =>
        {
            owner.skills.Remove(skill);
            m_Context.MarkDirty();
            RebuildSkillsList(skillsHost, owner);
        })
        { text = "删除本技能" };
        box.Add(removeButton);

        return box;
    }

    VisualElement BuildSkillField(StgBossSkill skill, string fieldName)
    {
        switch (fieldName)
        {
            case "bulletCount":
                var bulletCount = new IntegerField("子弹数 bulletCount") { value = skill.bulletCount };
                bulletCount.RegisterValueChangedCallback(evt => { skill.bulletCount = evt.newValue; m_Context.MarkDirty(); });
                return bulletCount;
            case "spreadAngle":
                var spreadAngle = new FloatField("扇形角度 spreadAngle") { value = skill.spreadAngle };
                spreadAngle.RegisterValueChangedCallback(evt => { skill.spreadAngle = evt.newValue; m_Context.MarkDirty(); });
                return spreadAngle;
            case "duration":
                var duration = new FloatField("持续时间 duration") { value = skill.duration };
                duration.RegisterValueChangedCallback(evt => { skill.duration = evt.newValue; m_Context.MarkDirty(); });
                return duration;
            case "width":
                var width = new FloatField("宽度 width") { value = skill.width };
                width.RegisterValueChangedCallback(evt => { skill.width = evt.newValue; m_Context.MarkDirty(); });
                return width;
            case "rings":
                var rings = new IntegerField("环数 rings") { value = skill.rings };
                rings.RegisterValueChangedCallback(evt => { skill.rings = evt.newValue; m_Context.MarkDirty(); });
                return rings;
            case "waveTemplateId":
                var templateIds = m_Context.GetWaveTemplateIds();
                templateIds.Insert(0, "(无)");
                int idx = templateIds.IndexOf(skill.waveTemplateId);
                if (idx < 0) idx = 0;
                var waveTemplateId = new PopupField<string>("召唤波次模板 waveTemplateId", templateIds, idx);
                waveTemplateId.RegisterValueChangedCallback(evt => { skill.waveTemplateId = evt.newValue == "(无)" ? "" : evt.newValue; m_Context.MarkDirty(); });
                return waveTemplateId;
            case "count":
                var count = new IntegerField("数量 count") { value = skill.count };
                count.RegisterValueChangedCallback(evt => { skill.count = evt.newValue; m_Context.MarkDirty(); });
                return count;
            case "speed":
                var speed = new FloatField("速度 speed") { value = skill.speed };
                speed.RegisterValueChangedCallback(evt => { skill.speed = evt.newValue; m_Context.MarkDirty(); });
                return speed;
            case "damageReduction":
                var damageReduction = new FloatField("减伤比例 damageReduction") { value = skill.damageReduction };
                damageReduction.RegisterValueChangedCallback(evt => { skill.damageReduction = evt.newValue; m_Context.MarkDirty(); });
                return damageReduction;
            default:
                return new VisualElement();
        }
    }

    public void Rebuild()
    {
        BuildUI();
    }
}
