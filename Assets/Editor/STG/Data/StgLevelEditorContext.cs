using System;
using System.Collections.Generic;
using System.Linq;

// 持有当前编辑中的关卡数据、文件路径、脏标记，并提供跨面板引用查询（模板ID/掉落表ID/BossID等）
// 面板不直接互相引用，统一通过本 Context 查询，避免耦合（详见关卡编辑器设计文档 4.3 节）
public class StgLevelEditorContext
{
    public StgLevelEditorModel Model { get; private set; }
    public string CurrentFilePath { get; private set; }
    public bool IsDirty { get; private set; }

    // 模型整体被替换（New/Open）时触发，面板据此重建自身视图
    public event Action OnModelReloaded;
    // 某个面板新增/删除/改名了一个可被跨面板引用的 ID（模板/掉落表/Boss/机关等）时触发，供下拉选项刷新
    public event Action OnCrossReferencesChanged;

    public StgLevelEditorContext()
    {
        Model = new StgLevelEditorModel();
    }

    public void NewLevel()
    {
        Model = new StgLevelEditorModel();
        CurrentFilePath = null;
        IsDirty = false;
        OnModelReloaded?.Invoke();
    }

    public void LoadFromFile(string path)
    {
        Model = StgLevelJsonIO.LoadFromFile(path);
        CurrentFilePath = path;
        IsDirty = false;
        OnModelReloaded?.Invoke();
    }

    public void SaveToFile(string path)
    {
        StgLevelJsonIO.SaveToFile(Model, path);
        CurrentFilePath = path;
        IsDirty = false;
    }

    public void MarkDirty()
    {
        IsDirty = true;
    }

    public void NotifyCrossReferencesChanged()
    {
        OnCrossReferencesChanged?.Invoke();
    }

    // ---------- 跨面板引用查询 ----------

    public List<string> GetWaveTemplateIds()
    {
        return Model.enemyWaveTemplates.Select(t => t.templateId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    public List<string> GetDropTableIds()
    {
        return Model.globalDropTables.Select(d => d.dropTableId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    public List<string> GetBossIds()
    {
        return Model.bossConfigs.Select(b => b.bossId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    public List<string> GetTrapIds()
    {
        return Model.trapConfigs.Select(t => t.trapId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    public List<string> GetSpawnAreaIds()
    {
        return Model.spawnAreaConfigs.Select(s => s.spawnAreaId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    public List<string> GetItemIds()
    {
        return Model.itemConfigs.Select(i => i.itemId).Where(id => !string.IsNullOrEmpty(id)).ToList();
    }

    // 供③时间轴 drop_digital_gate 事件下拉引用：仅列出标记为"可复用模板"的数字门配置
    public List<string> GetReusableGateTrapIds()
    {
        return Model.trapConfigs
            .Where(t => t.type == "digital_gate" && t.isReusableGateTemplate)
            .Select(t => t.trapId)
            .Where(id => !string.IsNullOrEmpty(id))
            .ToList();
    }
}
