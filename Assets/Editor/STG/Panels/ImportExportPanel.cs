using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

// ⑨ 导入导出面板：打开/另存为/新建 + 从其他关卡导入模板 + 批量替换字符串；版本对比按设计文档优先级最低，本版本暂不支持
public class ImportExportPanel : IStgPanel
{
    public string TabTitle => "⑨ 导入导出";
    public VisualElement Root { get; }

    readonly StgLevelEditorContext m_Context;
    readonly System.Action m_OnModelReloaded;
    Label m_PathLabel;
    Label m_DirtyLabel;

    public ImportExportPanel(StgLevelEditorContext context, System.Action onModelReloaded)
    {
        m_Context = context;
        m_OnModelReloaded = onModelReloaded;
        Root = new VisualElement();
        Root.style.paddingLeft = 8;
        Root.style.paddingRight = 8;
        Root.style.paddingTop = 8;

        BuildUI();
    }

    void BuildUI()
    {
        Root.Clear();

        var fileRow = new VisualElement();
        fileRow.style.flexDirection = FlexDirection.Row;
        fileRow.style.marginBottom = 4;

        var newButton = new Button(OnNewLevel) { text = "新建关卡" };
        var openButton = new Button(OnOpen) { text = "打开关卡 JSON..." };
        var saveButton = new Button(OnSave) { text = "保存" };
        var saveAsButton = new Button(OnSaveAs) { text = "另存为..." };

        fileRow.Add(newButton);
        fileRow.Add(openButton);
        fileRow.Add(saveButton);
        fileRow.Add(saveAsButton);
        Root.Add(fileRow);

        m_PathLabel = new Label();
        m_PathLabel.style.whiteSpace = WhiteSpace.Normal;
        Root.Add(m_PathLabel);

        m_DirtyLabel = new Label();
        Root.Add(m_DirtyLabel);

        var separator = new VisualElement();
        separator.style.height = 1;
        separator.style.marginTop = 8;
        separator.style.marginBottom = 8;
        separator.style.backgroundColor = new Color(0.3f, 0.3f, 0.3f);
        Root.Add(separator);

        Root.Add(BuildTemplateImportSection());

        var separator2 = new VisualElement();
        separator2.style.height = 1;
        separator2.style.marginTop = 8;
        separator2.style.marginBottom = 8;
        separator2.style.backgroundColor = new Color(0.3f, 0.3f, 0.3f);
        Root.Add(separator2);

        Root.Add(BuildBatchReplaceSection());

        var separator3 = new VisualElement();
        separator3.style.height = 1;
        separator3.style.marginTop = 8;
        separator3.style.marginBottom = 8;
        separator3.style.backgroundColor = new Color(0.3f, 0.3f, 0.3f);
        Root.Add(separator3);

        var comingSoon = new Label("版本对比：优先级最低，本版本暂不支持（详见关卡编辑器设计文档⑨节）。");
        comingSoon.style.color = new Color(0.6f, 0.6f, 0.6f);
        comingSoon.style.whiteSpace = WhiteSpace.Normal;
        Root.Add(comingSoon);

        RefreshStatus();
    }

    // ---------- 从其他关卡导入模板 ----------

    VisualElement BuildTemplateImportSection()
    {
        var box = StgUiUtil.SectionBox("从其他关卡导入模板");

        var hint = StgUiUtil.HintLabel("只导入选中的部分并合并进当前关卡（同ID条目会被跳过，避免覆盖当前正在编辑的数据）。");
        box.Add(hint);

        var importWaveTemplates = new Toggle("小怪波次模板 (enemyWaveTemplates)") { value = true };
        var importBossConfigs = new Toggle("Boss配置 (bossConfigs)") { value = true };
        var importTrapConfigs = new Toggle("机关配置 (trapConfigs)") { value = true };
        var importItemConfigs = new Toggle("物品定义 (itemConfigs)") { value = false };
        var importDropTables = new Toggle("掉落表 (globalDropTables)") { value = false };
        var importSpawnAreas = new Toggle("持续/范围刷怪区域 (spawnAreaConfigs)") { value = false };

        box.Add(importWaveTemplates);
        box.Add(importBossConfigs);
        box.Add(importTrapConfigs);
        box.Add(importItemConfigs);
        box.Add(importDropTables);
        box.Add(importSpawnAreas);

        var resultLabel = StgUiUtil.HintLabel("");
        box.Add(resultLabel);

        var importButton = new Button(() =>
        {
            string path = EditorUtility.OpenFilePanel("选择要导入模板的关卡 JSON", Application.dataPath, "json");
            if (string.IsNullOrEmpty(path)) return;

            StgLevelEditorModel source;
            try
            {
                source = StgLevelJsonIO.LoadFromFile(path);
            }
            catch (System.Exception e)
            {
                EditorUtility.DisplayDialog("导入失败", $"解析 JSON 失败：{e.Message}", "确定");
                return;
            }

            int added = 0, skipped = 0;
            var target = m_Context.Model;

            if (importWaveTemplates.value)
                MergeById(source.enemyWaveTemplates, target.enemyWaveTemplates, t => t.templateId, ref added, ref skipped);
            if (importBossConfigs.value)
                MergeById(source.bossConfigs, target.bossConfigs, b => b.bossId, ref added, ref skipped);
            if (importTrapConfigs.value)
                MergeById(source.trapConfigs, target.trapConfigs, t => t.trapId, ref added, ref skipped);
            if (importItemConfigs.value)
                MergeById(source.itemConfigs, target.itemConfigs, i => i.itemId, ref added, ref skipped);
            if (importDropTables.value)
                MergeById(source.globalDropTables, target.globalDropTables, d => d.dropTableId, ref added, ref skipped);
            if (importSpawnAreas.value)
                MergeById(source.spawnAreaConfigs, target.spawnAreaConfigs, s => s.spawnAreaId, ref added, ref skipped);

            resultLabel.text = $"导入完成：新增 {added} 条，跳过 {skipped} 条（ID 已存在）。";
            if (added > 0)
            {
                m_Context.MarkDirty();
                m_Context.NotifyCrossReferencesChanged();
                m_OnModelReloaded?.Invoke();
            }
        })
        { text = "选择关卡 JSON 并导入..." };
        box.Add(importButton);

        return box;
    }

    // 按 ID 合并：source 中 ID 在 target 里不存在的条目追加进 target，已存在的跳过（不覆盖当前正在编辑的数据）
    static void MergeById<T>(List<T> source, List<T> target, System.Func<T, string> idGetter, ref int added, ref int skipped)
    {
        var existingIds = new System.Collections.Generic.HashSet<string>();
        foreach (var item in target) existingIds.Add(idGetter(item));

        foreach (var item in source)
        {
            string id = idGetter(item);
            if (string.IsNullOrEmpty(id) || existingIds.Contains(id))
            {
                skipped++;
                continue;
            }
            target.Add(item);
            existingIds.Add(id);
            added++;
        }
    }

    // ---------- 批量替换 ----------

    VisualElement BuildBatchReplaceSection()
    {
        var box = StgUiUtil.SectionBox("批量替换（字符串级）");

        var hint = StgUiUtil.HintLabel("对关卡内所有预制件路径类字段做字符串替换，用于批量更换美术资源。仅替换完全匹配 oldValue 的字段值。");
        box.Add(hint);

        var oldValueField = new TextField("旧路径 (oldValue)");
        var newValueField = new TextField("新路径 (newValue)");
        box.Add(oldValueField);
        box.Add(newValueField);

        var resultLabel = StgUiUtil.HintLabel("");
        box.Add(resultLabel);

        var replaceButton = new Button(() =>
        {
            string oldValue = oldValueField.value;
            string newValue = newValueField.value;
            if (string.IsNullOrEmpty(oldValue))
            {
                resultLabel.text = "旧路径不能为空。";
                return;
            }

            int count = 0;
            var m = m_Context.Model;

            foreach (var l in m.backgroundLayers)
            {
                // tileSpritePaths 是 List<string>，string 不可变，只能按索引写回
                for (int i = 0; i < l.tileSpritePaths.Count; i++)
                {
                    if (l.tileSpritePaths[i] == oldValue)
                    {
                        l.tileSpritePaths[i] = newValue;
                        count++;
                    }
                }
                foreach (var r in l.scatterRules) count += ReplaceField(ref r.prefabPath, oldValue, newValue);
            }
            foreach (var i in m.itemConfigs) count += ReplaceField(ref i.prefabPath, oldValue, newValue);
            foreach (var t in m.enemyWaveTemplates) count += ReplaceField(ref t.enemyType, oldValue, newValue);
            foreach (var b in m.bossConfigs) count += ReplaceField(ref b.prefabPath, oldValue, newValue);
            foreach (var t in m.trapConfigs) count += ReplaceField(ref t.prefabPath, oldValue, newValue);

            resultLabel.text = $"替换完成：共修改 {count} 处字段。";
            if (count > 0)
            {
                m_Context.MarkDirty();
                m_OnModelReloaded?.Invoke();
            }
        })
        { text = "执行替换" };
        box.Add(replaceButton);

        return box;
    }

    static int ReplaceField(ref string field, string oldValue, string newValue)
    {
        if (field == oldValue)
        {
            field = newValue;
            return 1;
        }
        return 0;
    }

    void OnNewLevel()
    {
        if (m_Context.IsDirty && !EditorUtility.DisplayDialog("新建关卡", "当前关卡有未保存的修改，确定要新建吗？", "新建", "取消"))
        {
            return;
        }
        m_Context.NewLevel();
        m_OnModelReloaded?.Invoke();
        RefreshStatus();
    }

    void OnOpen()
    {
        string path = EditorUtility.OpenFilePanel("打开关卡 JSON", Application.dataPath, "json");
        if (string.IsNullOrEmpty(path)) return;

        try
        {
            m_Context.LoadFromFile(path);
            m_OnModelReloaded?.Invoke();
            RefreshStatus();
        }
        catch (System.Exception e)
        {
            EditorUtility.DisplayDialog("打开失败", $"解析 JSON 失败：{e.Message}", "确定");
        }
    }

    void OnSave()
    {
        if (string.IsNullOrEmpty(m_Context.CurrentFilePath))
        {
            OnSaveAs();
            return;
        }
        if (!ConfirmSaveAfterValidation()) return;
        m_Context.SaveToFile(m_Context.CurrentFilePath);
        RefreshStatus();
    }

    void OnSaveAs()
    {
        if (!ConfirmSaveAfterValidation()) return;

        string defaultName = string.IsNullOrEmpty(m_Context.Model.levelId) ? "level_new" : m_Context.Model.levelId;
        string path = EditorUtility.SaveFilePanel("另存为关卡 JSON", Application.dataPath, defaultName, "json");
        if (string.IsNullOrEmpty(path)) return;

        m_Context.SaveToFile(path);
        RefreshStatus();
    }

    // 保存前自动校验（详见关卡编辑器设计文档 5.2 节）：存在错误级别问题时弹窗提示，可选择强制忽略继续保存
    bool ConfirmSaveAfterValidation()
    {
        var issues = ValidationPanel.RunValidation(m_Context.Model);
        int errorCount = 0;
        foreach (var issue in issues)
        {
            if (issue.Severity == ValidationPanel.Severity.Error) errorCount++;
        }
        if (errorCount == 0) return true;

        return EditorUtility.DisplayDialog(
            "保存前校验发现问题",
            $"发现 {errorCount} 个错误级别的问题（详情见⑧校验与统计面板），继续保存可能导致运行时解析出错。是否仍然保存？",
            "仍然保存", "取消");
    }

    void RefreshStatus()
    {
        m_PathLabel.text = string.IsNullOrEmpty(m_Context.CurrentFilePath)
            ? "当前未关联文件（新关卡）"
            : $"当前文件：{m_Context.CurrentFilePath}";
        m_DirtyLabel.text = m_Context.IsDirty ? "有未保存的修改" : "已保存";
        m_DirtyLabel.style.color = m_Context.IsDirty ? new Color(0.9f, 0.6f, 0.1f) : new Color(0.5f, 0.8f, 0.5f);
    }

    public void Rebuild()
    {
        RefreshStatus();
    }
}
