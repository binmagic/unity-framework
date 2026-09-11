using System.Collections.Generic;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;
// 项目全局命名空间下有自定义 uGUI 类 Assets/Main/Scripts/Common/UIExtension/ScrollView.cs，
// 与 UnityEngine.UIElements.ScrollView 同名，别名不能叫 ScrollView（同样会跟全局命名空间里的类撞名），改叫 UiScrollView
using UiScrollView = UnityEngine.UIElements.ScrollView;

// ② 背景生成配置面板：basicScroll（全局滚动） + backgroundLayers（统一的层列表）
//
// 层模型说明：不再区分"岛屿/云朵"这类具体内容，统一成 StgBackgroundLayer——
// layerType 决定层的性质（parallax 纯视差层 / player 玩家所在层，目前只做排序占位），
// enableScatterSpawn 是任意层都可以叠加的可选行为（随机散布生成，原"岛屿/云朵生成"背后的算法）。
//
// 主从结构：左侧 ListView 选层，右侧详情编辑区，写法对齐 WaveTemplatePanel.cs 的模板列表模式。
//
// ListView 绑定约定（本项目 UIElements 首次落地，供后续面板参照）：
// ListView 会虚拟化复用行元素，makeItem 只在创建行时调用一次，bindItem 在滚动/刷新时反复调用。
// 若把 RegisterValueChangedCallback 放进 bindItem，行被复用时旧回调不会自动移除，会在同一个输入框上
// 越叠越多、且闭包捕获的是"注册那一刻"的数据项，导致编辑一行实际写脏另一行。
// 正确做法：回调只在 makeItem 里注册一次，回调体内通过 el.userData 读取"当前绑定"的数据项；
// bindItem 只做 SetValueWithoutNotify + 更新 el.userData，不重复注册回调。
public class BackgroundConfigPanel : IStgPanel
{
    public string TabTitle => "② 背景生成配置";
    public VisualElement Root { get; }

    static readonly string[] LayerTypes = { "parallax", "player" };

    readonly StgLevelEditorContext m_Context;
    readonly UiScrollView m_Scroll;

    public BackgroundConfigPanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        m_Scroll = new UiScrollView();
        Root.Add(m_Scroll);
        BuildUI();
    }

    void BuildUI()
    {
        m_Scroll.Clear();
        var m = m_Context.Model;

        m_Scroll.Add(BuildBasicScrollSection(m.basicScroll));
        m_Scroll.Add(BuildBackgroundLayersSection(m.backgroundLayers));
    }

    VisualElement BuildBasicScrollSection(StgBasicScroll s)
    {
        var box = NewSectionBox("基础滚动 (basicScroll)");

        var baseSpeed = new FloatField("基础速度 baseSpeed") { value = s.baseSpeed };
        baseSpeed.RegisterValueChangedCallback(evt => { s.baseSpeed = evt.newValue; m_Context.MarkDirty(); });
        box.Add(baseSpeed);

        var speedMultiplier = new FloatField("速度倍率 speedMultiplier") { value = s.speedMultiplier };
        speedMultiplier.RegisterValueChangedCallback(evt => { s.speedMultiplier = evt.newValue; m_Context.MarkDirty(); });
        box.Add(speedMultiplier);

        var rampUpTime = new FloatField("加速耗时 rampUpTime") { value = s.rampUpTime };
        rampUpTime.RegisterValueChangedCallback(evt => { s.rampUpTime = evt.newValue; m_Context.MarkDirty(); });
        box.Add(rampUpTime);

        var rampUpTargetSpeed = new FloatField("加速目标速度 rampUpTargetSpeed") { value = s.rampUpTargetSpeed };
        rampUpTargetSpeed.RegisterValueChangedCallback(evt => { s.rampUpTargetSpeed = evt.newValue; m_Context.MarkDirty(); });
        box.Add(rampUpTargetSpeed);

        return box;
    }

    // ---------- 背景层：统一主从列表 ----------

    VisualElement BuildBackgroundLayersSection(List<StgBackgroundLayer> layers)
    {
        var box = NewSectionBox("背景层 (backgroundLayers)");

        var split = new VisualElement();
        split.style.flexDirection = FlexDirection.Row;
        split.style.flexGrow = 1;
        split.style.minHeight = 320;

        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(layers, 20, StgUiUtil.MakeMasterRow, (el, i) => StgUiUtil.BindMasterRow(el, LayerRowTitle(layers[i]), layers[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 220;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                layers[idx] = new StgBackgroundLayer { layerId = $"layer_{System.Guid.NewGuid().ToString("N").Substring(0, 8)}", layerName = "新层" };
            }
            listView.Rebuild();
            m_Context.MarkDirty();
        };
        listView.itemsRemoved += _ =>
        {
            m_Context.MarkDirty();
            detailHost.Clear();
        };
        listView.selectionChanged += items =>
        {
            detailHost.Clear();
            foreach (var obj in items)
            {
                if (obj is StgBackgroundLayer layer)
                {
                    detailHost.Add(BuildLayerDetail(layer, listView));
                }
                break;
            }
        };

        var toolbar = new VisualElement();
        toolbar.style.flexDirection = FlexDirection.Row;
        var addParallaxButton = new Button(() =>
        {
            layers.Add(new StgBackgroundLayer
            {
                layerId = $"layer_{System.Guid.NewGuid().ToString("N").Substring(0, 8)}",
                layerName = "新视差层",
                layerType = "parallax",
            });
            listView.Rebuild();
            m_Context.MarkDirty();
        })
        { text = "新建视差层" };
        var addScatterButton = new Button(() =>
        {
            var layer = new StgBackgroundLayer
            {
                layerId = $"layer_{System.Guid.NewGuid().ToString("N").Substring(0, 8)}",
                layerName = "新随机散布层",
                layerType = "parallax",
                enableScatterSpawn = true,
            };
            layer.scatterRules.Add(new StgSpawnRule { ruleName = "新规则", weight = 1f });
            layers.Add(layer);
            listView.Rebuild();
            m_Context.MarkDirty();
        })
        { text = "新建随机散布层" };
        toolbar.Add(addParallaxButton);
        toolbar.Add(addScatterButton);
        box.Add(toolbar);

        split.Add(listView);
        split.Add(detailHost);
        box.Add(split);

        return box;
    }

    static string LayerRowTitle(StgBackgroundLayer layer)
    {
        string typeLabel = layer.layerType == "player" ? "玩家" : "视差";
        string scatterMark = layer.enableScatterSpawn ? "+散布" : "";
        return $"{layer.layerName} [{typeLabel}{scatterMark}]";
    }

    VisualElement BuildLayerDetail(StgBackgroundLayer layer, ListView ownerListView)
    {
        var box = new VisualElement();

        var layerId = new TextField("层ID") { value = layer.layerId };
        layerId.RegisterValueChangedCallback(evt => { layer.layerId = evt.newValue; m_Context.MarkDirty(); });
        box.Add(layerId);

        var layerName = new TextField("层名称") { value = layer.layerName };
        layerName.RegisterValueChangedCallback(evt => { layer.layerName = evt.newValue; m_Context.MarkDirty(); ownerListView.Rebuild(); });
        box.Add(layerName);

        var layerType = new PopupField<string>("层类型 layerType", new List<string>(LayerTypes), StgUiUtil.SafeIndexOf(LayerTypes, layer.layerType));
        box.Add(layerType);

        var orderInLayer = new IntegerField("渲染层级顺序 orderInLayer") { value = layer.orderInLayer };
        orderInLayer.RegisterValueChangedCallback(evt => { layer.orderInLayer = evt.newValue; m_Context.MarkDirty(); });
        box.Add(orderInLayer);

        var playerHint = StgUiUtil.HintLabel("玩家层目前只做排序占位（确定其他层相对玩家的前后顺序），不含玩家专属数据；预览时玩家锚点仍使用固定坐标，不读取本层配置。");
        box.Add(playerHint);
        playerHint.style.display = layer.layerType == "player" ? DisplayStyle.Flex : DisplayStyle.None;

        var parallaxFields = new VisualElement();
        box.Add(parallaxFields);
        BuildParallaxFields(parallaxFields, layer);

        layerType.RegisterValueChangedCallback(evt =>
        {
            layer.layerType = evt.newValue;
            m_Context.MarkDirty();
            playerHint.style.display = layer.layerType == "player" ? DisplayStyle.Flex : DisplayStyle.None;
            ownerListView.Rebuild();
        });

        box.Add(StgUiUtil.SectionLabel("随机散布 (可选行为，任意层类型都可启用)"));
        var enableScatter = new Toggle("启用随机散布 enableScatterSpawn") { value = layer.enableScatterSpawn };
        box.Add(enableScatter);

        var scatterFields = new VisualElement();
        box.Add(scatterFields);
        scatterFields.style.display = layer.enableScatterSpawn ? DisplayStyle.Flex : DisplayStyle.None;
        BuildScatterFields(scatterFields, layer, ownerListView);

        enableScatter.RegisterValueChangedCallback(evt =>
        {
            layer.enableScatterSpawn = evt.newValue;
            m_Context.MarkDirty();
            scatterFields.style.display = layer.enableScatterSpawn ? DisplayStyle.Flex : DisplayStyle.None;
            ownerListView.Rebuild();
        });

        return box;
    }

    void BuildParallaxFields(VisualElement host, StgBackgroundLayer layer)
    {
        host.Clear();
        host.Add(StgUiUtil.SectionLabel("视差滚动"));

        var speedCoeff = new FloatField("速度系数 speedCoefficient") { value = layer.speedCoefficient };
        speedCoeff.RegisterValueChangedCallback(evt => { layer.speedCoefficient = evt.newValue; m_Context.MarkDirty(); });
        host.Add(speedCoeff);

        var useTileLoop = new Toggle("循环铺贴 useTileLoop") { value = layer.useTileLoop };
        host.Add(useTileLoop);

        var tileFields = new VisualElement();
        host.Add(tileFields);
        tileFields.style.display = layer.useTileLoop ? DisplayStyle.Flex : DisplayStyle.None;
        BuildTileStripFields(tileFields, layer);

        useTileLoop.RegisterValueChangedCallback(evt =>
        {
            layer.useTileLoop = evt.newValue;
            m_Context.MarkDirty();
            tileFields.style.display = layer.useTileLoop ? DisplayStyle.Flex : DisplayStyle.None;
        });
    }

    // 循环贴图带：多张图按列表顺序首尾相接，滚完最后一张接回第一张（顺序循环）
    void BuildTileStripFields(VisualElement host, StgBackgroundLayer layer)
    {
        host.Clear();

        host.Add(StgUiUtil.HintLabel("列表顺序即拼接顺序：多张图首尾相接滚过去，滚完最后一张接回第一张。只放一张时就是单图循环。"));

        var tileWorldHeight = new FloatField("单张贴图世界高度 tileWorldHeight（<=0 时按画幅高度兜底）") { value = layer.tileWorldHeight };
        tileWorldHeight.RegisterValueChangedCallback(evt => { layer.tileWorldHeight = evt.newValue; m_Context.MarkDirty(); });
        host.Add(tileWorldHeight);

        var label = new Label("贴图路径列表 tileSpritePaths（可将 Sprite 拖入格子，或点击圆点从 Project 面板选择）");
        label.style.marginTop = 6;
        host.Add(label);

        var paths = layer.tileSpritePaths;
        var listView = new ListView(paths, 22, MakeTilePathRow, (el, i) => BindTilePathRow(el, paths, i));
        listView.style.height = 120;
        listView.showAddRemoveFooter = true;
        listView.reorderable = true; // 允许拖拽调整顺序，顺序直接决定循环拼接顺序
        listView.itemsAdded += _ =>
        {
            int lastIndex = paths.Count - 1;
            paths[lastIndex] = "";
            listView.Rebuild();
            m_Context.MarkDirty();
        };
        listView.itemsRemoved += _ => { m_Context.MarkDirty(); };
        listView.itemIndexChanged += (_, __) => { m_Context.MarkDirty(); };
        host.Add(listView);
    }

    // List<string> 的行绑定：string 是值类型语义（不可变），回调里不能像引用类型那样改对象字段，
    // 必须通过索引写回列表本身，所以这里用 row.userData 存"当前行索引 + 列表引用"的组合
    class TilePathRowContext
    {
        public List<string> List;
        public int Index;
    }

    VisualElement MakeTilePathRow()
    {
        var row = new VisualElement();
        row.style.flexDirection = FlexDirection.Row;

        var orderLabel = new Label { name = "orderLabel" };
        orderLabel.style.width = 30;
        orderLabel.style.unityTextAlign = TextAnchor.MiddleLeft;
        var spriteField = new ObjectField { name = "sprite", objectType = typeof(Sprite), allowSceneObjects = false };
        spriteField.style.flexGrow = 1;

        row.Add(orderLabel);
        row.Add(spriteField);

        spriteField.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is TilePathRowContext ctx && ctx.Index >= 0 && ctx.Index < ctx.List.Count)
            {
                ctx.List[ctx.Index] = evt.newValue != null ? AssetDatabase.GetAssetPath(evt.newValue) : "";
                m_Context.MarkDirty();
            }
        });

        return row;
    }

    void BindTilePathRow(VisualElement row, List<string> paths, int index)
    {
        row.userData = new TilePathRowContext { List = paths, Index = index };
        row.Q<Label>("orderLabel").text = $"{index + 1}.";
        row.Q<ObjectField>("sprite").SetValueWithoutNotify(AssetDatabase.LoadAssetAtPath<Sprite>(paths[index]));
    }

    void BuildScatterFields(VisualElement host, StgBackgroundLayer layer, ListView ownerListView)
    {
        host.Clear();

        var intervalRow = new VisualElement();
        intervalRow.style.flexDirection = FlexDirection.Row;
        var intervalMin = new FloatField("生成间隔最小") { value = layer.scatterIntervalMin };
        intervalMin.style.flexGrow = 1;
        intervalMin.RegisterValueChangedCallback(evt => { layer.scatterIntervalMin = evt.newValue; m_Context.MarkDirty(); });
        var intervalMax = new FloatField("最大") { value = layer.scatterIntervalMax };
        intervalMax.style.flexGrow = 1;
        intervalMax.RegisterValueChangedCallback(evt => { layer.scatterIntervalMax = evt.newValue; m_Context.MarkDirty(); });
        intervalRow.Add(intervalMin);
        intervalRow.Add(intervalMax);
        host.Add(intervalRow);

        var maxActive = new IntegerField("同屏上限 scatterMaxActive") { value = layer.scatterMaxActive };
        maxActive.RegisterValueChangedCallback(evt => { layer.scatterMaxActive = evt.newValue; m_Context.MarkDirty(); });
        host.Add(maxActive);

        var overlapRadius = new FloatField("重叠检测半径") { value = layer.scatterOverlapCheckRadius };
        overlapRadius.RegisterValueChangedCallback(evt => { layer.scatterOverlapCheckRadius = evt.newValue; m_Context.MarkDirty(); });
        host.Add(overlapRadius);

        var spawnYOffset = new FloatField("生成Y偏移") { value = layer.scatterSpawnYOffset };
        spawnYOffset.RegisterValueChangedCallback(evt => { layer.scatterSpawnYOffset = evt.newValue; m_Context.MarkDirty(); });
        host.Add(spawnYOffset);

        host.Add(BuildRulesList(layer.scatterRules, ownerListView));
    }

    VisualElement BuildRulesList(List<StgSpawnRule> rules, ListView ownerListView)
    {
        var container = new VisualElement();
        var label = new Label("生成规则 (scatterRules)");
        label.style.marginTop = 6;
        container.Add(label);

        var hintContainer = new VisualElement { name = "weightHints" };

        var listView = new ListView(rules, 22, MakeRuleRow, (el, i) => BindRuleRow(el, rules[i]));
        listView.style.height = 150;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += _ =>
        {
            int lastIndex = rules.Count - 1;
            rules[lastIndex] = new StgSpawnRule { ruleName = "新规则", weight = 1f };
            listView.Rebuild();
            RefreshWeightHints(hintContainer, rules);
            m_Context.MarkDirty();
        };
        listView.itemsRemoved += _ =>
        {
            RefreshWeightHints(hintContainer, rules);
            m_Context.MarkDirty();
        };
        container.Add(listView);
        container.Add(hintContainer);
        RefreshWeightHints(hintContainer, rules);

        // 权重字段变化时刷新提示：在行内注册的回调里也要触发一次，通过 container 传递
        listView.userData = hintContainer;

        return container;
    }

    VisualElement MakeRuleRow()
    {
        var row = new VisualElement();
        row.style.flexDirection = FlexDirection.Row;

        var ruleName = new TextField { name = "ruleName" };
        ruleName.style.width = 90;
        var prefabPath = new TextField { name = "prefabPath" };
        prefabPath.style.width = 150;
        var weight = new FloatField { name = "weight" };
        weight.style.width = 60;
        var sizeMin = new FloatField { name = "sizeMin" };
        sizeMin.style.width = 50;
        var sizeMax = new FloatField { name = "sizeMax" };
        sizeMax.style.width = 50;
        var allowOffscreen = new Toggle { name = "allowOffscreen" };

        row.Add(ruleName);
        row.Add(prefabPath);
        row.Add(weight);
        row.Add(sizeMin);
        row.Add(sizeMax);
        row.Add(allowOffscreen);

        ruleName.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule) { rule.ruleName = evt.newValue; m_Context.MarkDirty(); }
        });
        prefabPath.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule) { rule.prefabPath = evt.newValue; m_Context.MarkDirty(); }
        });
        weight.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule)
            {
                rule.weight = evt.newValue;
                m_Context.MarkDirty();
                RefreshWeightHintsFromRow(row);
            }
        });
        sizeMin.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule) { rule.sizeRangeMin = evt.newValue; m_Context.MarkDirty(); }
        });
        sizeMax.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule) { rule.sizeRangeMax = evt.newValue; m_Context.MarkDirty(); }
        });
        allowOffscreen.RegisterValueChangedCallback(evt =>
        {
            if (row.userData is StgSpawnRule rule) { rule.allowPartialOffscreen = evt.newValue; m_Context.MarkDirty(); }
        });

        return row;
    }

    void BindRuleRow(VisualElement row, StgSpawnRule rule)
    {
        row.userData = rule;

        row.Q<TextField>("ruleName").SetValueWithoutNotify(rule.ruleName);
        row.Q<TextField>("prefabPath").SetValueWithoutNotify(rule.prefabPath);
        row.Q<FloatField>("weight").SetValueWithoutNotify(rule.weight);
        row.Q<FloatField>("sizeMin").SetValueWithoutNotify(rule.sizeRangeMin);
        row.Q<FloatField>("sizeMax").SetValueWithoutNotify(rule.sizeRangeMax);
        row.Q<Toggle>("allowOffscreen").SetValueWithoutNotify(rule.allowPartialOffscreen);
    }

    // 权重字段回调里没有直接持有 rules 列表和 hintContainer 的引用，通过向上查找最近的 ListView.userData 拿到
    void RefreshWeightHintsFromRow(VisualElement row)
    {
        var ancestor = row.parent;
        while (ancestor != null && !(ancestor is ListView))
        {
            ancestor = ancestor.parent;
        }
        if (ancestor is ListView listView && listView.itemsSource is List<StgSpawnRule> rules && listView.userData is VisualElement hintContainer)
        {
            RefreshWeightHints(hintContainer, rules);
        }
    }

    void RefreshWeightHints(VisualElement hintContainer, List<StgSpawnRule> rules)
    {
        hintContainer.Clear();

        float total = 0f;
        foreach (var r in rules) total += Mathf.Max(0f, r.weight);
        if (total <= 0f) return;

        foreach (var r in rules)
        {
            float normalized = Mathf.Max(0f, r.weight) / total;
            var label = new Label($"{(string.IsNullOrEmpty(r.ruleName) ? "(未命名)" : r.ruleName)}: 归一化概率 {normalized:P1}");
            label.style.color = new Color(0.6f, 0.6f, 0.6f);
            label.style.fontSize = 11;
            hintContainer.Add(label);
        }
    }

    VisualElement NewSectionBox(string title)
    {
        var box = new VisualElement();
        box.style.marginBottom = 10;
        box.style.paddingLeft = 8;
        box.style.paddingRight = 8;
        box.style.paddingTop = 6;
        box.style.paddingBottom = 6;
        box.style.borderLeftWidth = 1;
        box.style.borderLeftColor = new Color(0.3f, 0.3f, 0.3f);

        var label = new Label(title);
        label.style.unityFontStyleAndWeight = FontStyle.Bold;
        label.style.marginBottom = 4;
        box.Add(label);

        return box;
    }

    public void Rebuild()
    {
        BuildUI();
    }
}
