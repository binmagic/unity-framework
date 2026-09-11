using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

// ④ 小怪波次模板库：分两个子Tab——离散波次模板 / 持续范围刷怪区域（移植自 ParkourBattle，来源未核实见架构文档第零节）
// 主从结构：左侧 ListView 选模板，右侧详情编辑区
public class WaveTemplatePanel : IStgPanel
{
    public string TabTitle => "④ 小怪波次模板库";
    public VisualElement Root { get; }

    static readonly string[] FormationTypes = { "single", "line_horizontal", "line_vertical", "v_shape", "circle", "arrow", "random" };
    static readonly string[] EntryPathTypes = { "from_top_straight", "from_left_curve", "from_right_curve", "from_top_sine", "teleport" };
    static readonly string[] BehaviorTypes = { "straight_down", "sine_move", "track_player", "circle_strafe", "kamikaze", "stationary" };
    static readonly string[] SpawnAreaTypes = { "fix_point", "range", "round" };

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_SubTabBar;
    readonly VisualElement m_ContentHost;
    int m_SubTabIndex = 0;

    public WaveTemplatePanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        Root.style.flexDirection = FlexDirection.Column;
        Root.style.flexGrow = 1;

        m_SubTabBar = new VisualElement();
        m_SubTabBar.style.flexDirection = FlexDirection.Row;
        Root.Add(m_SubTabBar);

        m_ContentHost = new VisualElement();
        m_ContentHost.style.flexGrow = 1;
        Root.Add(m_ContentHost);

        BuildSubTabs();
        ShowSubTab(0);
    }

    void BuildSubTabs()
    {
        m_SubTabBar.Clear();
        var titles = new[] { "离散波次模板 (enemyWaveTemplates)", "持续/范围刷怪区域 (spawnAreaConfigs)" };
        for (int i = 0; i < titles.Length; i++)
        {
            int index = i;
            var button = new Button(() => ShowSubTab(index)) { text = titles[i] };
            m_SubTabBar.Add(button);
        }
    }

    void ShowSubTab(int index)
    {
        m_SubTabIndex = index;
        m_ContentHost.Clear();
        m_ContentHost.Add(index == 0 ? BuildWaveTemplateSubPanel() : BuildSpawnAreaSubPanel());
    }

    // ---------- 离散波次模板 ----------

    VisualElement BuildWaveTemplateSubPanel()
    {
        var list = m_Context.Model.enemyWaveTemplates;
        var split = new VisualElement();
        split.style.flexDirection = FlexDirection.Row;
        split.style.flexGrow = 1;

        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, MakeMasterRow, (el, i) => BindMasterRow(el, list[i].templateName, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 220;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgWaveTemplate { templateId = $"wave_{System.Guid.NewGuid().ToString("N").Substring(0, 8)}", templateName = "新模板" };
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
                if (obj is StgWaveTemplate t)
                {
                    detailHost.Add(BuildWaveTemplateDetail(t, listView));
                }
                break;
            }
        };

        split.Add(listView);
        split.Add(detailHost);
        return split;
    }

    VisualElement MakeMasterRow()
    {
        var label = new Label { name = "title" };
        label.style.paddingLeft = 4;
        return label;
    }

    void BindMasterRow(VisualElement el, string title, object dataItem)
    {
        ((Label)el).text = string.IsNullOrEmpty(title) ? "(未命名)" : title;
        el.userData = dataItem;
    }

    VisualElement BuildWaveTemplateDetail(StgWaveTemplate t, ListView ownerListView)
    {
        var box = new VisualElement();

        var templateId = new TextField("模板ID") { value = t.templateId };
        templateId.RegisterValueChangedCallback(evt => { t.templateId = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); });
        box.Add(templateId);

        var templateName = new TextField("模板名称") { value = t.templateName };
        templateName.RegisterValueChangedCallback(evt => { t.templateName = evt.newValue; m_Context.MarkDirty(); ownerListView.Rebuild(); });
        box.Add(templateName);

        var enemyType = new TextField("敌人预制件路径 enemyType") { value = t.enemyType };
        enemyType.RegisterValueChangedCallback(evt => { t.enemyType = evt.newValue; m_Context.MarkDirty(); });
        box.Add(enemyType);

        var count = new IntegerField("数量 count") { value = t.count };
        count.RegisterValueChangedCallback(evt => { t.count = evt.newValue; m_Context.MarkDirty(); });
        box.Add(count);

        box.Add(SectionLabel("编队配置 (formation)"));
        var formationType = new PopupField<string>("类型", new List<string>(FormationTypes), System.Array.IndexOf(FormationTypes, t.formationType) is int fi && fi >= 0 ? fi : 0);
        formationType.RegisterValueChangedCallback(evt => { t.formationType = evt.newValue; m_Context.MarkDirty(); });
        box.Add(formationType);
        var spacing = new FloatField("间距 spacing") { value = t.formationSpacing };
        spacing.RegisterValueChangedCallback(evt => { t.formationSpacing = evt.newValue; m_Context.MarkDirty(); });
        box.Add(spacing);
        var rowDelay = new FloatField("行延迟 rowDelay") { value = t.formationRowDelay };
        rowDelay.RegisterValueChangedCallback(evt => { t.formationRowDelay = evt.newValue; m_Context.MarkDirty(); });
        box.Add(rowDelay);

        box.Add(SectionLabel("入场路径 (entryPath)"));
        var entryPathType = new PopupField<string>("类型", new List<string>(EntryPathTypes), System.Array.IndexOf(EntryPathTypes, t.entryPathType) is int epi && epi >= 0 ? epi : 0);
        entryPathType.RegisterValueChangedCallback(evt => { t.entryPathType = evt.newValue; m_Context.MarkDirty(); });
        box.Add(entryPathType);
        var entrySpeed = new FloatField("速度 speed") { value = t.entryPathSpeed };
        entrySpeed.RegisterValueChangedCallback(evt => { t.entryPathSpeed = evt.newValue; m_Context.MarkDirty(); });
        box.Add(entrySpeed);
        var entryAmplitude = new FloatField("振幅 amplitude") { value = t.entryPathAmplitude };
        entryAmplitude.RegisterValueChangedCallback(evt => { t.entryPathAmplitude = evt.newValue; m_Context.MarkDirty(); });
        box.Add(entryAmplitude);

        box.Add(SectionLabel("行为模式 (behavior)"));
        var behaviorType = new PopupField<string>("类型", new List<string>(BehaviorTypes), System.Array.IndexOf(BehaviorTypes, t.behaviorType) is int bi && bi >= 0 ? bi : 0);
        behaviorType.RegisterValueChangedCallback(evt => { t.behaviorType = evt.newValue; m_Context.MarkDirty(); });
        box.Add(behaviorType);
        var fireInterval = new FloatField("射击间隔 fireInterval") { value = t.behaviorFireInterval };
        fireInterval.RegisterValueChangedCallback(evt => { t.behaviorFireInterval = evt.newValue; m_Context.MarkDirty(); });
        box.Add(fireInterval);
        var bulletType = new TextField("子弹类型 bulletType") { value = t.behaviorBulletType };
        bulletType.RegisterValueChangedCallback(evt => { t.behaviorBulletType = evt.newValue; m_Context.MarkDirty(); });
        box.Add(bulletType);

        box.Add(SectionLabel("数值"));
        var hp = new IntegerField("血量 hp") { value = t.hp };
        hp.RegisterValueChangedCallback(evt => { t.hp = evt.newValue; m_Context.MarkDirty(); });
        box.Add(hp);
        var score = new IntegerField("得分 score") { value = t.score };
        score.RegisterValueChangedCallback(evt => { t.score = evt.newValue; m_Context.MarkDirty(); });
        box.Add(score);

        var dropTableIds = m_Context.GetDropTableIds();
        dropTableIds.Insert(0, "(无)");
        int dropIndex = dropTableIds.IndexOf(t.dropTableId);
        if (dropIndex < 0) dropIndex = 0;
        var dropTableId = new PopupField<string>("掉落表 dropTableId", dropTableIds, dropIndex);
        dropTableId.RegisterValueChangedCallback(evt => { t.dropTableId = evt.newValue == "(无)" ? "" : evt.newValue; m_Context.MarkDirty(); });
        box.Add(dropTableId);

        return box;
    }

    // ---------- 持续/范围刷怪区域 ----------

    VisualElement BuildSpawnAreaSubPanel()
    {
        var list = m_Context.Model.spawnAreaConfigs;
        var split = new VisualElement();
        split.style.flexDirection = FlexDirection.Row;
        split.style.flexGrow = 1;

        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, MakeMasterRow, (el, i) => BindMasterRow(el, list[i].spawnAreaId, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 220;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgSpawnAreaConfig { spawnAreaId = $"spawn_area_{System.Guid.NewGuid().ToString("N").Substring(0, 6)}" };
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
                if (obj is StgSpawnAreaConfig s)
                {
                    detailHost.Add(BuildSpawnAreaDetail(s, listView));
                }
                break;
            }
        };

        split.Add(listView);
        split.Add(detailHost);
        return split;
    }

    VisualElement BuildSpawnAreaDetail(StgSpawnAreaConfig s, ListView ownerListView)
    {
        var box = new VisualElement();

        var spawnAreaId = new TextField("区域ID") { value = s.spawnAreaId };
        spawnAreaId.RegisterValueChangedCallback(evt => { s.spawnAreaId = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); ownerListView.Rebuild(); });
        box.Add(spawnAreaId);

        var typeIndex = System.Array.IndexOf(SpawnAreaTypes, s.type);
        if (typeIndex < 0) typeIndex = 0;
        var typeField = new PopupField<string>("类型 type", new List<string>(SpawnAreaTypes), typeIndex);
        box.Add(typeField);

        var dynamicFields = new VisualElement();
        box.Add(dynamicFields);

        void RebuildDynamicFields()
        {
            dynamicFields.Clear();

            var centerRow = new VisualElement();
            centerRow.style.flexDirection = FlexDirection.Row;
            var centerX = new FloatField("中心X") { value = s.centerX };
            centerX.style.flexGrow = 1;
            centerX.RegisterValueChangedCallback(evt => { s.centerX = evt.newValue; m_Context.MarkDirty(); });
            var centerY = new FloatField("中心Y") { value = s.centerY };
            centerY.style.flexGrow = 1;
            centerY.RegisterValueChangedCallback(evt => { s.centerY = evt.newValue; m_Context.MarkDirty(); });
            centerRow.Add(centerX);
            centerRow.Add(centerY);
            dynamicFields.Add(centerRow);

            switch (s.type)
            {
                case "fix_point":
                    var intervalMin = new FloatField("间隔最小 intervalMin") { value = s.intervalMin };
                    intervalMin.RegisterValueChangedCallback(evt => { s.intervalMin = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(intervalMin);
                    var intervalMax = new FloatField("间隔最大 intervalMax") { value = s.intervalMax };
                    intervalMax.RegisterValueChangedCallback(evt => { s.intervalMax = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(intervalMax);
                    break;
                case "range":
                    var interval1 = new FloatField("间隔 interval") { value = s.interval };
                    interval1.RegisterValueChangedCallback(evt => { s.interval = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(interval1);
                    var radiusOuter1 = new FloatField("外半径 radiusOuter") { value = s.radiusOuter };
                    radiusOuter1.RegisterValueChangedCallback(evt => { s.radiusOuter = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(radiusOuter1);
                    var radiusInner = new FloatField("内半径 radiusInner") { value = s.radiusInner };
                    radiusInner.RegisterValueChangedCallback(evt => { s.radiusInner = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(radiusInner);
                    var centerOffsetY = new FloatField("中心Y偏移 centerOffsetY") { value = s.centerOffsetY };
                    centerOffsetY.RegisterValueChangedCallback(evt => { s.centerOffsetY = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(centerOffsetY);
                    break;
                case "round":
                    var interval2 = new FloatField("间隔 interval") { value = s.interval };
                    interval2.RegisterValueChangedCallback(evt => { s.interval = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(interval2);
                    var radiusOuter2 = new FloatField("半径 radiusOuter") { value = s.radiusOuter };
                    radiusOuter2.RegisterValueChangedCallback(evt => { s.radiusOuter = evt.newValue; m_Context.MarkDirty(); });
                    dynamicFields.Add(radiusOuter2);
                    break;
            }

            var previewHint = new Label(s.type == "range" || s.type == "round"
                ? "预览：内切7小圆分布（大圈切1中心+6周边小圆，逐圆轮转采样，避免同批怪挤在圆心）——本版暂未绘制图形预览，占位提示。"
                : "");
            previewHint.style.color = new Color(0.55f, 0.55f, 0.55f);
            previewHint.style.whiteSpace = WhiteSpace.Normal;
            previewHint.style.fontSize = 11;
            dynamicFields.Add(previewHint);
        }

        typeField.RegisterValueChangedCallback(evt =>
        {
            s.type = evt.newValue;
            m_Context.MarkDirty();
            RebuildDynamicFields();
        });
        RebuildDynamicFields();

        box.Add(SectionLabel("怪物权重表 monsterWeights"));
        var weightsField = new TextField("敌人id|权重,敌人id|权重,...") { value = s.monsterWeights, multiline = true };
        weightsField.style.height = 40;
        weightsField.RegisterValueChangedCallback(evt => { s.monsterWeights = evt.newValue; m_Context.MarkDirty(); RefreshWeightHint(box, s); });
        box.Add(weightsField);
        var weightHint = new Label { name = "monsterWeightHint" };
        weightHint.style.color = new Color(0.6f, 0.6f, 0.6f);
        weightHint.style.fontSize = 11;
        box.Add(weightHint);
        RefreshWeightHint(box, s);

        var limit = new IntegerField("刷怪上限 limit") { value = s.limit };
        limit.RegisterValueChangedCallback(evt => { s.limit = evt.newValue; m_Context.MarkDirty(); RefreshDurationHint(box, s); });
        box.Add(limit);
        var durationHint = new Label { name = "durationHint" };
        durationHint.style.color = new Color(0.6f, 0.6f, 0.6f);
        durationHint.style.fontSize = 11;
        box.Add(durationHint);
        RefreshDurationHint(box, s);

        return box;
    }

    void RefreshWeightHint(VisualElement box, StgSpawnAreaConfig s)
    {
        var hint = box.Q<Label>("monsterWeightHint");
        if (hint == null) return;

        float total = 0f;
        var pairs = s.monsterWeights.Split(',');
        int validCount = 0;
        foreach (var pair in pairs)
        {
            var kv = pair.Split('|');
            if (kv.Length == 2 && float.TryParse(kv[1], out float w))
            {
                total += Mathf.Max(0f, w);
                validCount++;
            }
        }
        hint.text = total > 0f
            ? $"解析到 {validCount} 条权重，加权和 {total:F1}（>0，可正常刷怪）"
            : "警告：权重加权和为0或表为空，运行时刷怪权重随机会永远落不到任何怪物上";
        hint.style.color = total > 0f ? new Color(0.5f, 0.75f, 0.5f) : new Color(0.85f, 0.4f, 0.4f);
    }

    void RefreshDurationHint(VisualElement box, StgSpawnAreaConfig s)
    {
        var hint = box.Q<Label>("durationHint");
        if (hint == null) return;
        float avgInterval = s.type == "fix_point" ? (s.intervalMin + s.intervalMax) / 2f : s.interval;
        hint.text = $"预计持续时长 ≈ {s.limit} × {avgInterval:F2}s = {s.limit * avgInterval:F1}s";
    }

    VisualElement SectionLabel(string text)
    {
        var label = new Label(text);
        label.style.unityFontStyleAndWeight = FontStyle.Bold;
        label.style.marginTop = 8;
        label.style.marginBottom = 2;
        return label;
    }

    public void Rebuild()
    {
        ShowSubTab(m_SubTabIndex);
    }
}
