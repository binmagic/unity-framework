using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

// ⑦ 物品与掉落表面板：itemConfigs（物品定义）+ globalDropTables（掉落表，每条含多个 entries）
public class ItemDropPanel : IStgPanel
{
    public string TabTitle => "⑦ 物品与掉落表";
    public VisualElement Root { get; }

    static readonly string[] ItemTypes = { "currency", "powerup", "life", "special" };
    static readonly string[] MoveModes = { "fall_down", "float_toward_player", "static_until_collected" };

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_SubTabBar;
    readonly VisualElement m_ContentHost;
    int m_SubTabIndex = 0;

    public ItemDropPanel(StgLevelEditorContext context)
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
        var titles = new[] { "物品定义 (itemConfigs)", "全局掉落表 (globalDropTables)" };
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
        m_ContentHost.Add(index == 0 ? BuildItemConfigSubPanel() : BuildDropTableSubPanel());
    }

    // ---------- 物品定义 ----------

    VisualElement BuildItemConfigSubPanel()
    {
        var list = m_Context.Model.itemConfigs;
        var split = new VisualElement();
        split.style.flexDirection = FlexDirection.Row;
        split.style.flexGrow = 1;

        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, StgUiUtil.MakeMasterRow, (el, i) => StgUiUtil.BindMasterRow(el, list[i].itemName, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 200;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgItemConfig { itemId = $"item_{System.Guid.NewGuid().ToString("N").Substring(0, 6)}", itemName = "新物品" };
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
                if (obj is StgItemConfig i)
                {
                    detailHost.Add(BuildItemConfigDetail(i, listView));
                }
                break;
            }
        };

        split.Add(listView);
        split.Add(detailHost);
        return split;
    }

    VisualElement BuildItemConfigDetail(StgItemConfig i, ListView ownerListView)
    {
        var box = new VisualElement();

        var itemId = new TextField("物品ID") { value = i.itemId };
        itemId.RegisterValueChangedCallback(evt => { i.itemId = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); });
        box.Add(itemId);

        var itemName = new TextField("物品名称") { value = i.itemName };
        itemName.RegisterValueChangedCallback(evt => { i.itemName = evt.newValue; m_Context.MarkDirty(); ownerListView.Rebuild(); });
        box.Add(itemName);

        var prefabPath = new TextField("预制件路径") { value = i.prefabPath };
        prefabPath.RegisterValueChangedCallback(evt => { i.prefabPath = evt.newValue; m_Context.MarkDirty(); });
        box.Add(prefabPath);

        var type = new PopupField<string>("类型 type", new List<string>(ItemTypes), StgUiUtil.SafeIndexOf(ItemTypes, i.type));
        type.RegisterValueChangedCallback(evt => { i.type = evt.newValue; m_Context.MarkDirty(); });
        box.Add(type);

        var value = new IntegerField("数值 value") { value = i.value };
        value.RegisterValueChangedCallback(evt => { i.value = evt.newValue; m_Context.MarkDirty(); });
        box.Add(value);

        var moveMode = new PopupField<string>("移动方式 moveMode", new List<string>(MoveModes), StgUiUtil.SafeIndexOf(MoveModes, i.moveMode));
        moveMode.RegisterValueChangedCallback(evt => { i.moveMode = evt.newValue; m_Context.MarkDirty(); });
        box.Add(moveMode);

        var attractToPlayer = new Toggle("自动吸附玩家") { value = i.attractToPlayer };
        attractToPlayer.RegisterValueChangedCallback(evt => { i.attractToPlayer = evt.newValue; m_Context.MarkDirty(); });
        box.Add(attractToPlayer);

        var attractRadius = new FloatField("吸附半径") { value = i.attractRadius };
        attractRadius.RegisterValueChangedCallback(evt => { i.attractRadius = evt.newValue; m_Context.MarkDirty(); });
        box.Add(attractRadius);

        var lifetime = new FloatField("存活时长 lifetime") { value = i.lifetime };
        lifetime.RegisterValueChangedCallback(evt => { i.lifetime = evt.newValue; m_Context.MarkDirty(); });
        box.Add(lifetime);

        return box;
    }

    // ---------- 全局掉落表 ----------

    VisualElement BuildDropTableSubPanel()
    {
        var list = m_Context.Model.globalDropTables;
        var split = new VisualElement();
        split.style.flexDirection = FlexDirection.Row;
        split.style.flexGrow = 1;

        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, StgUiUtil.MakeMasterRow, (el, i) => StgUiUtil.BindMasterRow(el, list[i].dropTableId, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 200;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgDropTable { dropTableId = $"drop_{System.Guid.NewGuid().ToString("N").Substring(0, 6)}" };
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
                if (obj is StgDropTable d)
                {
                    detailHost.Add(BuildDropTableDetail(d, listView));
                }
                break;
            }
        };

        split.Add(listView);
        split.Add(detailHost);
        return split;
    }

    VisualElement BuildDropTableDetail(StgDropTable d, ListView ownerListView)
    {
        var box = new VisualElement();

        var dropTableId = new TextField("掉落表ID") { value = d.dropTableId };
        dropTableId.RegisterValueChangedCallback(evt =>
        {
            d.dropTableId = evt.newValue;
            m_Context.MarkDirty();
            m_Context.NotifyCrossReferencesChanged();
            ownerListView.Rebuild();
        });
        box.Add(dropTableId);

        box.Add(StgUiUtil.SectionLabel("掉落条目 (entries)"));

        var entriesHost = new VisualElement();
        box.Add(entriesHost);

        var expectHint = new Label { name = "expectHint" };
        box.Add(expectHint);

        var entriesListView = new ListView(d.entries, 22, MakeEntryRow, (el, i) => BindEntryRow(el, d.entries[i]));
        entriesListView.style.height = 160;
        entriesListView.showAddRemoveFooter = true;
        entriesListView.itemsAdded += _ =>
        {
            int lastIndex = d.entries.Count - 1;
            d.entries[lastIndex] = new StgDropEntry { probability = 0f, countMin = 1, countMax = 1 };
            entriesListView.Rebuild();
            m_Context.MarkDirty();
            RefreshExpectHint(expectHint, d.entries, m_Context.Model.itemConfigs);
        };
        entriesListView.itemsRemoved += _ =>
        {
            m_Context.MarkDirty();
            RefreshExpectHint(expectHint, d.entries, m_Context.Model.itemConfigs);
        };
        entriesHost.Add(entriesListView);

        RefreshExpectHint(expectHint, d.entries, m_Context.Model.itemConfigs);

        return box;
    }

    VisualElement MakeEntryRow()
    {
        var row = new VisualElement();
        row.style.flexDirection = FlexDirection.Row;

        var itemId = new TextField { name = "itemId" };
        itemId.style.width = 120;
        var probability = new FloatField { name = "probability" };
        probability.style.width = 70;
        var countMin = new IntegerField { name = "countMin" };
        countMin.style.width = 50;
        var countMax = new IntegerField { name = "countMax" };
        countMax.style.width = 50;

        row.Add(itemId);
        row.Add(probability);
        row.Add(countMin);
        row.Add(countMax);

        itemId.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgDropEntry entry) { entry.itemId = evt.newValue; m_Context.MarkDirty(); }
        });
        probability.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgDropEntry entry) { entry.probability = evt.newValue; m_Context.MarkDirty(); RefreshExpectHintFromRow(row); }
        });
        countMin.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgDropEntry entry) { entry.countMin = evt.newValue; m_Context.MarkDirty(); RefreshExpectHintFromRow(row); }
        });
        countMax.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgDropEntry entry) { entry.countMax = evt.newValue; m_Context.MarkDirty(); RefreshExpectHintFromRow(row); }
        });

        return row;
    }

    void BindEntryRow(VisualElement row, StgDropEntry entry)
    {
        row.userData = entry;
        row.Q<TextField>("itemId").SetValueWithoutNotify(entry.itemId);
        row.Q<FloatField>("probability").SetValueWithoutNotify(entry.probability);
        row.Q<IntegerField>("countMin").SetValueWithoutNotify(entry.countMin);
        row.Q<IntegerField>("countMax").SetValueWithoutNotify(entry.countMax);
    }

    void RefreshExpectHintFromRow(VisualElement row)
    {
        var ancestor = row.parent;
        while (ancestor != null && !(ancestor is ListView)) ancestor = ancestor.parent;
        if (ancestor is ListView listView && listView.itemsSource is List<StgDropEntry> entries)
        {
            var detailBox = listView.parent?.parent;
            var expectHint = detailBox?.Q<Label>("expectHint");
            if (expectHint != null) RefreshExpectHint(expectHint, entries, m_Context.Model.itemConfigs);
        }
    }

    void RefreshExpectHint(Label label, List<StgDropEntry> entries, List<StgItemConfig> itemConfigs)
    {
        float total = 0f;
        foreach (var e in entries)
        {
            float avgCount = (e.countMin + e.countMax) / 2f;
            total += Mathf.Max(0f, e.probability) * avgCount;
        }
        label.text = $"本表期望掉落数量 ≈ {total:F2} 个/次";
        label.style.color = new Color(0.6f, 0.6f, 0.6f);
        label.style.fontSize = 11;
    }

    public void Rebuild()
    {
        ShowSubTab(m_SubTabIndex);
    }
}
