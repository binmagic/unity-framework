using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UIElements;
using UiScrollView = UnityEngine.UIElements.ScrollView;

// ⑥ 机关配置面板：trapConfigs，type 驱动 params 专属字段；type == "digital_gate" 时展开数字门专属编辑器
// 数字门相关字段（gateType/paraTable 等）来源提示：参考内部旧版 barrel 项目 ParkourBattle/LWBattle 整理，
// 尚未逐行核对源码，详见 Docs/STG/STG 关卡系统技术架构设计.md 第零节
public class TrapConfigPanel : IStgPanel
{
    public string TabTitle => "⑥ 机关配置";
    public VisualElement Root { get; }

    static readonly string[] TrapTypes = { "static_obstacle", "turret", "laser_gate", "destructible", "moving_obstacle", "slow_field", "digital_gate", "decoration" };
    static readonly string[] GateTypes = { "gate_step", "gate_counter", "gate_duet" };
    static readonly string[] MovingPathTypes = { "linear", "sine", "circular" };
    static readonly string[] GateInitialStates = { "on", "off" };

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_SplitRoot;

    public TrapConfigPanel(StgLevelEditorContext context)
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

        var list = m_Context.Model.trapConfigs;
        var detailHost = new VisualElement();
        detailHost.style.flexGrow = 1;
        detailHost.style.paddingLeft = 10;

        var listView = new ListView(list, 20, StgUiUtil.MakeMasterRow, (el, i) => StgUiUtil.BindMasterRow(el, list[i].trapName, list[i]))
        {
            selectionType = SelectionType.Single,
        };
        listView.style.width = 200;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += indices =>
        {
            foreach (var idx in indices)
            {
                list[idx] = new StgTrapConfig { trapId = $"trap_{System.Guid.NewGuid().ToString("N").Substring(0, 6)}", trapName = "新机关" };
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
                if (obj is StgTrapConfig t) detailHost.Add(BuildTrapDetail(t, listView));
                break;
            }
        };

        m_SplitRoot.Add(listView);

        var scroll = new UiScrollView();
        scroll.style.flexGrow = 1;
        scroll.Add(detailHost);
        m_SplitRoot.Add(scroll);
    }

    VisualElement BuildTrapDetail(StgTrapConfig t, ListView ownerListView)
    {
        var box = new VisualElement();

        var trapId = new TextField("机关ID") { value = t.trapId };
        trapId.RegisterValueChangedCallback(evt => { t.trapId = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); });
        box.Add(trapId);

        var trapName = new TextField("机关名称") { value = t.trapName };
        trapName.RegisterValueChangedCallback(evt => { t.trapName = evt.newValue; m_Context.MarkDirty(); ownerListView.Rebuild(); });
        box.Add(trapName);

        var prefabPath = new TextField("预制件路径") { value = t.prefabPath };
        prefabPath.RegisterValueChangedCallback(evt => { t.prefabPath = evt.newValue; m_Context.MarkDirty(); });
        box.Add(prefabPath);

        var posRow = new VisualElement();
        posRow.style.flexDirection = FlexDirection.Row;
        var posX = new FloatField("位置X") { value = t.positionX };
        posX.style.flexGrow = 1;
        posX.RegisterValueChangedCallback(evt => { t.positionX = evt.newValue; m_Context.MarkDirty(); });
        var posY = new FloatField("位置Y") { value = t.positionY };
        posY.style.flexGrow = 1;
        posY.RegisterValueChangedCallback(evt => { t.positionY = evt.newValue; m_Context.MarkDirty(); });
        posRow.Add(posX);
        posRow.Add(posY);
        box.Add(posRow);

        var hp = new IntegerField("血量 hp") { value = t.hp };
        hp.RegisterValueChangedCallback(evt => { t.hp = evt.newValue; m_Context.MarkDirty(); });
        box.Add(hp);

        var destroyable = new Toggle("可被摧毁 destroyable") { value = t.destroyable };
        destroyable.RegisterValueChangedCallback(evt => { t.destroyable = evt.newValue; m_Context.MarkDirty(); });
        box.Add(destroyable);

        var dropTableIds = m_Context.GetDropTableIds();
        dropTableIds.Insert(0, "(无)");
        int dropIdx = dropTableIds.IndexOf(t.dropTableId);
        if (dropIdx < 0) dropIdx = 0;
        var dropTableId = new PopupField<string>("掉落表 dropTableId", dropTableIds, dropIdx);
        dropTableId.RegisterValueChangedCallback(evt => { t.dropTableId = evt.newValue == "(无)" ? "" : evt.newValue; m_Context.MarkDirty(); });
        box.Add(dropTableId);

        box.Add(StgUiUtil.SectionLabel("类型 (type)"));
        var typeField = new PopupField<string>("机关类型", new List<string>(TrapTypes), StgUiUtil.SafeIndexOf(TrapTypes, t.type));
        box.Add(typeField);

        var dynamicHost = new VisualElement();
        box.Add(dynamicHost);

        void RebuildDynamicFields()
        {
            dynamicHost.Clear();
            dynamicHost.Add(BuildTypeSpecificFields(t));
        }

        typeField.RegisterValueChangedCallback(evt =>
        {
            t.type = evt.newValue;
            m_Context.MarkDirty();
            RebuildDynamicFields();
        });
        RebuildDynamicFields();

        return box;
    }

    VisualElement BuildTypeSpecificFields(StgTrapConfig t)
    {
        var box = StgUiUtil.SectionBox($"专属参数 ({t.type})");

        switch (t.type)
        {
            case "static_obstacle":
                AddFloatField(box, "碰撞伤害 damage", t.paramDamage, v => t.paramDamage = v);
                AddToggleField(box, "接触即销毁 destroyOnContact", t.paramDestroyOnContact, v => t.paramDestroyOnContact = v);
                AddIntField(box, "数量 count", t.paramCount, v => t.paramCount = v);
                AddFloatField(box, "散布半径 spreadRadius", t.paramSpreadRadius, v => t.paramSpreadRadius = v);
                break;
            case "turret":
                AddFloatField(box, "射击间隔 fireInterval", t.paramFireInterval, v => t.paramFireInterval = v);
                AddTextField(box, "子弹类型 bulletType", t.paramBulletType, v => t.paramBulletType = v);
                AddFloatField(box, "伤害 damage", t.paramDamage, v => t.paramDamage = v);
                AddFloatField(box, "旋转速度 rotateSpeed", t.paramRotateSpeed, v => t.paramRotateSpeed = v);
                break;
            case "laser_gate":
                AddFloatField(box, "开启时长 onDuration", t.paramOnDuration, v => t.paramOnDuration = v);
                AddFloatField(box, "关闭时长 offDuration", t.paramOffDuration, v => t.paramOffDuration = v);
                AddPopupField(box, "初始状态 initialState", GateInitialStates, t.paramInitialState, v => t.paramInitialState = v);
                AddFloatField(box, "伤害 damage", t.paramDamage, v => t.paramDamage = v);
                AddFloatField(box, "宽度 width", t.paramWidth, v => t.paramWidth = v);
                break;
            case "destructible":
                var hint = StgUiUtil.HintLabel("可破坏物没有专属 params 字段，血量/掉落表走上方通用字段 hp / dropTableId。");
                box.Add(hint);
                break;
            case "moving_obstacle":
                AddPopupField(box, "路径类型 pathType", MovingPathTypes, t.paramPathType, v => t.paramPathType = v);
                AddFloatField(box, "速度 speed", t.paramSpeed, v => t.paramSpeed = v);
                AddFloatField(box, "伤害 damage", t.paramDamage, v => t.paramDamage = v);
                break;
            case "slow_field":
                AddFloatField(box, "减速系数 slowFactor", t.paramSlowFactor, v => t.paramSlowFactor = v);
                AddFloatField(box, "半径 radius", t.paramRadius, v => t.paramRadius = v);
                AddFloatField(box, "持续时间 duration", t.paramDuration, v => t.paramDuration = v);
                break;
            case "digital_gate":
                box.Add(BuildDigitalGateFields(t));
                break;
            case "decoration":
                var decorationHint = StgUiUtil.HintLabel("纯视觉装饰机关，没有专属 params 字段，也不参与碰撞/伤害判定。用于摆放场景里的静态物件（如坦克站立的土坡），预览时会随全局卷轴一起滚动。");
                box.Add(decorationHint);
                break;
        }

        return box;
    }

    // ---------- 数字门专属编辑器 ----------

    VisualElement BuildDigitalGateFields(StgTrapConfig t)
    {
        var box = new VisualElement();

        var gateTypeField = new PopupField<string>("门类型 gateType", new List<string>(GateTypes), StgUiUtil.SafeIndexOf(GateTypes, t.gateType));
        box.Add(gateTypeField);

        var initialValue = new IntegerField("初始计数值 initialValue") { value = t.initialValue };
        initialValue.RegisterValueChangedCallback(evt => { t.initialValue = evt.newValue; m_Context.MarkDirty(); });
        box.Add(initialValue);

        var effectTableRef = new TextField("效果表引用 effectTableRef（对齐 LW_Trigger_Item 字段结构）") { value = t.effectTableRef };
        effectTableRef.RegisterValueChangedCallback(evt => { t.effectTableRef = evt.newValue; m_Context.MarkDirty(); });
        box.Add(effectTableRef);

        var isReusable = new Toggle("可复用模板（供③时间轴 drop_digital_gate 引用）") { value = t.isReusableGateTemplate };
        isReusable.RegisterValueChangedCallback(evt => { t.isReusableGateTemplate = evt.newValue; m_Context.MarkDirty(); m_Context.NotifyCrossReferencesChanged(); });
        box.Add(isReusable);

        var dynamicHost = new VisualElement();
        box.Add(dynamicHost);

        void RebuildGateTypeFields()
        {
            dynamicHost.Clear();
            switch (t.gateType)
            {
                case "gate_step":
                    dynamicHost.Add(BuildStepTable(t, isRight: false));
                    break;
                case "gate_counter":
                    dynamicHost.Add(BuildCounterTable(t, isRight: false));
                    break;
                case "gate_duet":
                    dynamicHost.Add(StgUiUtil.SectionLabel("左侧区间表 (paraTable)"));
                    dynamicHost.Add(BuildCounterTable(t, isRight: false));
                    dynamicHost.Add(StgUiUtil.SectionLabel("右侧区间表 (paraTableRight)"));
                    dynamicHost.Add(BuildCounterTable(t, isRight: true));
                    dynamicHost.Add(StgUiUtil.HintLabel("门体宽度按左右命中比例实时形变，本编辑器仅编辑区间表数据，形变表现由运行时计算。"));
                    break;
            }
        }

        gateTypeField.RegisterValueChangedCallback(evt =>
        {
            t.gateType = evt.newValue;
            m_Context.MarkDirty();
            RebuildGateTypeFields();
        });
        RebuildGateTypeFields();

        return box;
    }

    VisualElement BuildStepTable(StgTrapConfig t, bool isRight)
    {
        var container = new VisualElement();
        var entries = StgGateParaTableUtil.DecodeStep(t.paraTable);

        void Commit()
        {
            t.paraTable = StgGateParaTableUtil.EncodeStep(entries);
            m_Context.MarkDirty();
        }

        var listView = new ListView(entries, 22, () =>
        {
            var row = new VisualElement();
            row.style.flexDirection = FlexDirection.Row;
            var threshold = new FloatField { name = "threshold" };
            threshold.style.width = 80;
            var effectId = new TextField { name = "effectId" };
            effectId.style.width = 150;
            row.Add(new Label("血量阈值") { style = { width = 60 } });
            row.Add(threshold);
            row.Add(new Label("效果ID") { style = { width = 50 } });
            row.Add(effectId);

            threshold.RegisterValueChangedCallback(evt =>
            {
                if (row.userData is int idx && idx < entries.Count)
                {
                    var e = entries[idx];
                    e.hpThreshold = evt.newValue;
                    entries[idx] = e;
                    Commit();
                }
            });
            effectId.RegisterValueChangedCallback(evt =>
            {
                if (row.userData is int idx && idx < entries.Count)
                {
                    var e = entries[idx];
                    e.effectId = evt.newValue;
                    entries[idx] = e;
                    Commit();
                }
            });

            return row;
        },
        (el, i) =>
        {
            el.userData = i;
            el.Q<FloatField>("threshold").SetValueWithoutNotify(entries[i].hpThreshold);
            el.Q<TextField>("effectId").SetValueWithoutNotify(entries[i].effectId);
        });
        listView.style.height = 140;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += _ =>
        {
            entries[entries.Count - 1] = new StgGateParaTableUtil.StepEntry { hpThreshold = 0f, effectId = "" };
            Commit();
            listView.Rebuild();
        };
        listView.itemsRemoved += _ => Commit();

        container.Add(listView);
        return container;
    }

    VisualElement BuildCounterTable(StgTrapConfig t, bool isRight)
    {
        var container = new VisualElement();
        var entries = isRight ? StgGateParaTableUtil.DecodeCounter(t.paraTableRight) : StgGateParaTableUtil.DecodeCounter(t.paraTable);

        var continuityHint = StgUiUtil.HintLabel("");
        container.Add(continuityHint);

        void RefreshContinuity()
        {
            var problem = StgGateParaTableUtil.CheckCounterContinuity(entries);
            continuityHint.text = problem ?? "区间连续无空洞，覆盖完整";
            continuityHint.style.color = problem != null ? new Color(0.85f, 0.4f, 0.4f) : new Color(0.5f, 0.75f, 0.5f);
        }

        var listView = new ListView(entries, 22, () =>
        {
            var row = new VisualElement();
            row.style.flexDirection = FlexDirection.Row;
            var min = new FloatField { name = "min" };
            min.style.width = 60;
            var max = new FloatField { name = "max" };
            max.style.width = 60;
            var effectId = new TextField { name = "effectId" };
            effectId.style.width = 140;
            row.Add(min);
            row.Add(max);
            row.Add(effectId);

            min.RegisterValueChangedCallback(evt =>
            {
                if (row.userData is int idx && idx < entries.Count)
                {
                    var e = entries[idx];
                    e.min = evt.newValue;
                    entries[idx] = e;
                    CommitCounter(t, entries, isRight);
                    RefreshContinuity();
                }
            });
            max.RegisterValueChangedCallback(evt =>
            {
                if (row.userData is int idx && idx < entries.Count)
                {
                    var e = entries[idx];
                    e.max = evt.newValue;
                    entries[idx] = e;
                    CommitCounter(t, entries, isRight);
                    RefreshContinuity();
                }
            });
            effectId.RegisterValueChangedCallback(evt =>
            {
                if (row.userData is int idx && idx < entries.Count)
                {
                    var e = entries[idx];
                    e.effectId = evt.newValue;
                    entries[idx] = e;
                    CommitCounter(t, entries, isRight);
                }
            });

            return row;
        },
        (el, i) =>
        {
            el.userData = i;
            el.Q<FloatField>("min").SetValueWithoutNotify(entries[i].min);
            el.Q<FloatField>("max").SetValueWithoutNotify(entries[i].max);
            el.Q<TextField>("effectId").SetValueWithoutNotify(entries[i].effectId);
        });
        listView.style.height = 160;
        listView.showAddRemoveFooter = true;
        listView.itemsAdded += _ =>
        {
            entries[entries.Count - 1] = new StgGateParaTableUtil.CounterEntry { min = 0f, max = 0f, effectId = "" };
            CommitCounter(t, entries, isRight);
            listView.Rebuild();
            RefreshContinuity();
        };
        listView.itemsRemoved += _ =>
        {
            CommitCounter(t, entries, isRight);
            RefreshContinuity();
        };

        container.Add(listView);
        RefreshContinuity();
        return container;
    }

    void CommitCounter(StgTrapConfig t, List<StgGateParaTableUtil.CounterEntry> entries, bool isRight)
    {
        string encoded = StgGateParaTableUtil.EncodeCounter(entries);
        if (isRight) t.paraTableRight = encoded;
        else t.paraTable = encoded;
        m_Context.MarkDirty();
    }

    // ---------- 通用字段构造小工具 ----------

    void AddFloatField(VisualElement box, string label, float value, System.Action<float> setter)
    {
        var field = new FloatField(label) { value = value };
        field.RegisterValueChangedCallback(evt => { setter(evt.newValue); m_Context.MarkDirty(); });
        box.Add(field);
    }

    void AddIntField(VisualElement box, string label, int value, System.Action<int> setter)
    {
        var field = new IntegerField(label) { value = value };
        field.RegisterValueChangedCallback(evt => { setter(evt.newValue); m_Context.MarkDirty(); });
        box.Add(field);
    }

    void AddTextField(VisualElement box, string label, string value, System.Action<string> setter)
    {
        var field = new TextField(label) { value = value };
        field.RegisterValueChangedCallback(evt => { setter(evt.newValue); m_Context.MarkDirty(); });
        box.Add(field);
    }

    void AddToggleField(VisualElement box, string label, bool value, System.Action<bool> setter)
    {
        var field = new Toggle(label) { value = value };
        field.RegisterValueChangedCallback(evt => { setter(evt.newValue); m_Context.MarkDirty(); });
        box.Add(field);
    }

    void AddPopupField(VisualElement box, string label, string[] options, string value, System.Action<string> setter)
    {
        var field = new PopupField<string>(label, new List<string>(options), StgUiUtil.SafeIndexOf(options, value));
        field.RegisterValueChangedCallback(evt => { setter(evt.newValue); m_Context.MarkDirty(); });
        box.Add(field);
    }

    public void Rebuild()
    {
        BuildUI();
    }
}
