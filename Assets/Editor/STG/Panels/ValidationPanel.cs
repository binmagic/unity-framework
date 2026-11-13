using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UIElements;

// ⑧ 校验与统计面板：引用完整性检查 + 数值范围检查 + 关卡统计
public class ValidationPanel : IStgPanel
{
    public string TabTitle => "⑧ 校验与统计";
    public VisualElement Root { get; }

    public enum Severity { Error, Warning }

    public struct Issue
    {
        public Severity Severity;
        public string Message;
    }

    readonly StgLevelEditorContext m_Context;
    readonly VisualElement m_Content;

    public ValidationPanel(StgLevelEditorContext context)
    {
        m_Context = context;
        Root = new VisualElement();
        Root.style.paddingLeft = 8;
        Root.style.paddingTop = 8;

        m_Content = new VisualElement();
        Root.Add(m_Content);

        BuildUI();
    }

    void BuildUI()
    {
        m_Content.Clear();

        var refreshButton = new Button(BuildUI) { text = "刷新校验与统计" };
        m_Content.Add(refreshButton);

        var issues = RunValidation(m_Context.Model);
        m_Content.Add(BuildIssuesSection(issues));
        m_Content.Add(BuildStatsSection(m_Context.Model));
    }

    VisualElement BuildIssuesSection(List<Issue> issues)
    {
        var box = StgUiUtil.SectionBox("校验结果");

        int errorCount = issues.Count(i => i.Severity == Severity.Error);
        int warningCount = issues.Count(i => i.Severity == Severity.Warning);

        var summary = new Label(issues.Count == 0
            ? "未发现问题"
            : $"{errorCount} 个错误，{warningCount} 个警告");
        summary.style.unityFontStyleAndWeight = FontStyle.Bold;
        summary.style.color = errorCount > 0 ? new Color(0.85f, 0.4f, 0.4f) : (warningCount > 0 ? new Color(0.9f, 0.7f, 0.2f) : new Color(0.5f, 0.8f, 0.5f));
        box.Add(summary);

        foreach (var issue in issues)
        {
            var label = new Label((issue.Severity == Severity.Error ? "[错误] " : "[警告] ") + issue.Message);
            label.style.whiteSpace = WhiteSpace.Normal;
            label.style.fontSize = 11;
            label.style.color = issue.Severity == Severity.Error ? new Color(0.85f, 0.4f, 0.4f) : new Color(0.9f, 0.7f, 0.2f);
            box.Add(label);
        }

        return box;
    }

    VisualElement BuildStatsSection(StgLevelEditorModel model)
    {
        var box = StgUiUtil.SectionBox("统计");

        int totalEnemyCount = 0;
        foreach (var ev in model.timeline.events.Where(e => e.type == "spawn_enemy_wave"))
        {
            var template = model.enemyWaveTemplates.FirstOrDefault(t => t.templateId == ev.templateId);
            if (template != null) totalEnemyCount += template.count;
        }

        int bossSpawnCount = model.timeline.events.Count(e => e.type == "spawn_boss");
        int trapSpawnCount = model.timeline.events.Count(e => e.type == "spawn_trap");
        int itemDropEventCount = model.timeline.events.Count(e => e.type == "spawn_item");

        box.Add(new Label($"本关小怪总数（时间轴引用波次的 count 求和）：{totalEnemyCount}"));
        box.Add(new Label($"Boss 出场次数：{bossSpawnCount}"));
        box.Add(new Label($"机关生成次数：{trapSpawnCount}"));
        box.Add(new Label($"物品投放事件次数：{itemDropEventCount}"));
        box.Add(new Label($"关卡时长：{model.timeline.duration:F1}s"));
        box.Add(new Label($"波次模板数：{model.enemyWaveTemplates.Count}　持续刷怪区域数：{model.spawnAreaConfigs.Count}　Boss配置数：{model.bossConfigs.Count}　机关配置数：{model.trapConfigs.Count}"));
        box.Add(new Label($"物品定义数：{model.itemConfigs.Count}　掉落表数：{model.globalDropTables.Count}"));

        return box;
    }

    // 供保存前自动校验调用（详见关卡编辑器设计文档 5.2 节）；错误级别问题应阻止保存，警告级别只提示
    public static List<Issue> RunValidation(StgLevelEditorModel m)
    {
        var issues = new List<Issue>();

        var waveTemplateIds = new HashSet<string>(m.enemyWaveTemplates.Select(t => t.templateId));
        var bossIds = new HashSet<string>(m.bossConfigs.Select(b => b.bossId));
        var trapIds = new HashSet<string>(m.trapConfigs.Select(t => t.trapId));
        var spawnAreaIds = new HashSet<string>(m.spawnAreaConfigs.Select(s => s.spawnAreaId));
        var itemIds = new HashSet<string>(m.itemConfigs.Select(i => i.itemId));
        var dropTableIds = new HashSet<string>(m.globalDropTables.Select(d => d.dropTableId));

        // 必填字段
        if (string.IsNullOrEmpty(m.levelId)) issues.Add(new Issue { Severity = Severity.Error, Message = "levelId 未填写" });
        if (m.timeline == null || m.timeline.duration <= 0f || float.IsNaN(m.timeline.duration) || float.IsInfinity(m.timeline.duration))
            issues.Add(new Issue { Severity = Severity.Error, Message = "关卡时长必须是有限的正数" });

        // 运行时按 ID 建立字典；重复 ID 会导致后一个定义静默覆盖前一个。
        AddDuplicateIdIssues(m.enemyWaveTemplates.Select(x => x.templateId), "波次模板");
        AddDuplicateIdIssues(m.bossConfigs.Select(x => x.bossId), "Boss");
        AddDuplicateIdIssues(m.trapConfigs.Select(x => x.trapId), "机关");
        AddDuplicateIdIssues(m.spawnAreaConfigs.Select(x => x.spawnAreaId), "刷怪区域");
        AddDuplicateIdIssues(m.itemConfigs.Select(x => x.itemId), "物品");
        AddDuplicateIdIssues(m.globalDropTables.Select(x => x.dropTableId), "掉落表");

        var playerRules = m.playerRules ?? new StgPlayerBattleRules();
        if (!playerRules.useLegacyInitialWingman && playerRules.initialWingman < 0)
            issues.Add(new Issue { Severity = Severity.Error, Message = $"战机规则 initialWingman={playerRules.initialWingman} 不能小于0" });
        if (!playerRules.useLegacyInitialWingman && playerRules.initialWingman > 24)
            issues.Add(new Issue { Severity = Severity.Warning, Message = "初始普通僚机超过逻辑上限24，运行时会截断（含指挥英雄增援）" });
        if (float.IsNaN(playerRules.heroArmorMultiplier) || float.IsInfinity(playerRules.heroArmorMultiplier) || playerRules.heroArmorMultiplier <= 0f)
            issues.Add(new Issue { Severity = Severity.Error, Message = $"英雄装甲倍率必须大于0，当前为 {playerRules.heroArmorMultiplier}" });
        if (float.IsNaN(playerRules.heroSkillCooldownMultiplier) || float.IsInfinity(playerRules.heroSkillCooldownMultiplier) || playerRules.heroSkillCooldownMultiplier <= 0f)
            issues.Add(new Issue { Severity = Severity.Error, Message = $"英雄技能冷却倍率必须大于0，当前为 {playerRules.heroSkillCooldownMultiplier}" });

        // 波次模板引用
        foreach (var t in m.enemyWaveTemplates)
        {
            if (!string.IsNullOrEmpty(t.dropTableId) && !dropTableIds.Contains(t.dropTableId))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"波次模板「{t.templateId}」引用了不存在的掉落表 dropTableId「{t.dropTableId}」" });
            if (t.behaviorRole != "standard" && t.behaviorRole != "swarm" && t.behaviorRole != "armored" && t.behaviorRole != "charger")
                issues.Add(new Issue { Severity = Severity.Error, Message = $"波次「{t.templateId}」未知敌机分工 {t.behaviorRole}" });
            void CheckBehavior(float value, float min, float max, string field)
            {
                if (float.IsNaN(value) || float.IsInfinity(value) || value < min || value > max)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"波次「{t.templateId}」{field} 必须在 [{min},{max}] 内" });
            }
            CheckBehavior(t.behaviorFireInterval, 0, 60, "射击间隔");
            CheckBehavior(t.behaviorShotCount, 1, 7, "弹数");
            CheckBehavior(t.behaviorSpreadAngle, 0, 90, "散射角");
            CheckBehavior(t.behaviorWarningDuration, .3f, 2, "预警时长");
            CheckBehavior(t.behaviorChargeTriggerRatio, .35f, .8f, "冲锋高度比例");
            CheckBehavior(t.behaviorChargeSpeedMultiplier, 1, 4, "冲锋速度倍率");
            if (t.hp <= 0) issues.Add(new Issue { Severity = Severity.Warning, Message = $"波次模板「{t.templateId}」血量 hp 为 {t.hp}，非正数" });
        }

        // Boss 引用与阈值
        foreach (var b in m.bossConfigs)
        {
            foreach (var entry in b.dropOnDeath)
            {
                if (!string.IsNullOrEmpty(entry.itemId) && !itemIds.Contains(entry.itemId))
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"Boss「{b.bossId}」固定掉落引用了不存在的物品「{entry.itemId}」" });
            }
            foreach (var phase in b.phases)
            {
                if (phase.hpThreshold < 0f || phase.hpThreshold > 1f)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"Boss「{b.bossId}」阶段{phase.phaseId} 的 hpThreshold={phase.hpThreshold} 不在 [0,1] 范围内" });
                foreach (var skill in phase.skills)
                {
                    if (skill.skillId == "summon_minions" && !string.IsNullOrEmpty(skill.waveTemplateId) && !waveTemplateIds.Contains(skill.waveTemplateId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"Boss「{b.bossId}」阶段{phase.phaseId} 的召唤技能引用了不存在的波次模板「{skill.waveTemplateId}」" });
                }
            }
        }

        // 机关掉落表引用
        foreach (var t in m.trapConfigs)
        {
            if (!string.IsNullOrEmpty(t.dropTableId) && !dropTableIds.Contains(t.dropTableId))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"机关「{t.trapId}」引用了不存在的掉落表 dropTableId「{t.dropTableId}」" });
        }

        // 掉落表条目
        foreach (var d in m.globalDropTables)
        {
            foreach (var entry in d.entries)
            {
                if (!string.IsNullOrEmpty(entry.itemId) && !itemIds.Contains(entry.itemId))
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"掉落表「{d.dropTableId}」条目引用了不存在的物品「{entry.itemId}」" });
                if (entry.probability < 0f || entry.probability > 1f)
                    issues.Add(new Issue { Severity = Severity.Warning, Message = $"掉落表「{d.dropTableId}」条目概率 probability={entry.probability} 不在 [0,1] 范围内" });
            }
        }

        // 时间轴事件引用
        foreach (var e in m.timeline.events)
        {
            if (e.time < 0f) issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件「{e.type}」的 time={e.time} 为负数" });
            if (e.time > m.timeline.duration) issues.Add(new Issue { Severity = Severity.Warning, Message = $"时间轴事件「{e.type}」的 time={e.time} 超出关卡时长 {m.timeline.duration}" });

            if (!string.IsNullOrEmpty(e.routeChoice) && e.routeChoice != "balanced" && e.routeChoice != "mass"
                && e.routeChoice != "pierce" && e.routeChoice != "homing")
                issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件@{e.time}s 路线条件「{e.routeChoice}」无效" });
            switch (e.type)
            {
                case "spawn_enemy_wave":
                    if (string.IsNullOrEmpty(e.templateId) || !waveTemplateIds.Contains(e.templateId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件 spawn_enemy_wave@{e.time}s 引用了不存在的模板「{e.templateId}」" });
                    break;
                case "spawn_boss":
                    if (string.IsNullOrEmpty(e.bossId) || !bossIds.Contains(e.bossId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件 spawn_boss@{e.time}s 引用了不存在的 Boss「{e.bossId}」" });
                    break;
                case "spawn_trap":
                    if (string.IsNullOrEmpty(e.trapId) || !trapIds.Contains(e.trapId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件 spawn_trap@{e.time}s 引用了不存在的机关「{e.trapId}」" });
                    break;
                case "spawn_area_start":
                case "spawn_area_stop":
                    if (string.IsNullOrEmpty(e.spawnAreaId) || !spawnAreaIds.Contains(e.spawnAreaId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件 {e.type}@{e.time}s 引用了不存在的刷怪区域「{e.spawnAreaId}」" });
                    break;
                case "spawn_item":
                    if (string.IsNullOrEmpty(e.itemId) || !itemIds.Contains(e.itemId))
                        issues.Add(new Issue { Severity = Severity.Error, Message = $"时间轴事件 spawn_item@{e.time}s 引用了不存在的物品「{e.itemId}」" });
                    break;
            }
        }

        // 持续/范围刷怪区域
        foreach (var s in m.spawnAreaConfigs)
        {
            float total = 0f;
            foreach (var pair in s.monsterWeights.Split(','))
            {
                var kv = pair.Split('|');
                if (kv.Length == 2 && float.TryParse(kv[1], out float w)) total += Mathf.Max(0f, w);
            }
            if (total <= 0f)
                issues.Add(new Issue { Severity = Severity.Error, Message = $"刷怪区域「{s.spawnAreaId}」的怪物权重表加权和为0，永远不会刷出任何怪物" });
        }

        // 数字门区间表连续性
        foreach (var t in m.trapConfigs.Where(t => t.type == "digital_gate"))
        {
            if (float.IsNaN(t.hitCooldown) || float.IsInfinity(t.hitCooldown) || t.hitCooldown < 0f)
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」有效命中间隔必须是有限非负数" });
            if (t.unlockMode != "none" && t.unlockMode != "enemy_count" && t.unlockMode != "bucket_damage")
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」解锁方式必须是 none、enemy_count 或 bucket_damage" });
            if (t.unlockMode != "none" && (float.IsNaN(t.unlockRequired) || float.IsInfinity(t.unlockRequired) || t.unlockRequired <= 0f))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」解锁阈值必须大于 0" });
            if (t.unlockMode == "bucket_damage" && string.IsNullOrWhiteSpace(t.unlockTargetId))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」的油桶伤害解锁必须填写目标ID" });
            if (t.unlockMode == "enemy_count" && t.unlockRequired != Mathf.Floor(t.unlockRequired))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」击破数量必须是整数" });
            if (t.unlockMode == "enemy_count" && !string.IsNullOrEmpty(t.unlockTargetId)
                && !m.enemyWaveTemplates.Any(w => w.templateId == t.unlockTargetId))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」引用的敌机波次「{t.unlockTargetId}」不存在" });
            if (t.unlockMode == "bucket_damage" && !m.trapConfigs.Any(b => b.trapId == t.unlockTargetId && b.type == "destructible"))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」引用的可破坏目标「{t.unlockTargetId}」不存在或不是 destructible" });
            if (t.heroChargeSlot < 0 || t.heroChargeSlot > 5)
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」英雄出战位置须为 0～5" });
            if (float.IsNaN(t.heroChargePercent) || float.IsInfinity(t.heroChargePercent) || t.heroChargePercent < 0f || t.heroChargePercent > 100f)
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」英雄充能百分比须为 0～100 的有限数" });
            if (t.heroChargePercent > 0f && t.gateType == "gate_duet")
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」英雄充能请使用单门，避免双侧奖励含义不明确" });
            if (t.choiceMode != "none" && t.choiceMode != "three")
                issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」奖励模式必须是 none 或 three" });
            if (t.choiceMode == "three")
            {
                var choices = (t.choicePool ?? "").Split(',').Select(x => x.Trim()).Where(x => !string.IsNullOrEmpty(x)).ToList();
                if (choices.Count != 3 || choices.Distinct().Count() != 3)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」三选一必须配置恰好 3 个不同的 effectId" });
                var supportedEffects = new HashSet<string> {
                    "eff_zero", "eff_plus1", "eff_plus2", "eff_plus5", "eff_double", "eff_weapon", "eff_repair",
                    "eff_minus1", "eff_minus2", "eff_haste", "eff_freeze", "eff_pierce", "eff_homing", "eff_route_mass", "eff_route_pierce", "20001", "20002", "20003", "20004", "20005"
                }; // 与 StgTriggerEnum.EffectTable 同步。
                foreach (var id in choices.Where(id => !supportedEffects.Contains(id)))
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」三选一效果「{id}」不存在" });
                if (t.gateType == "gate_duet" || t.heroChargePercent > 0f)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"数字门「{t.trapId}」三选一请使用普通单门，不能与双生门/英雄充能门叠加" });
            }
            if (t.gateType == "gate_duet")
            {
                bool validMin = !float.IsNaN(t.minSideRatio) && t.minSideRatio >= 0.2f && t.minSideRatio <= 0.5f;
                if (!validMin || float.IsNaN(t.initialLeftRatio) || t.initialLeftRatio < t.minSideRatio || t.initialLeftRatio > 1f - t.minSideRatio)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"双生门「{t.trapId}」最小占比须在 0.2～0.5，初始左侧占比须在最小占比与其互补值之间" });
                if (float.IsNaN(t.ratioChangePerHit) || t.ratioChangePerHit < 0f || t.ratioChangePerHit > 0.2f)
                    issues.Add(new Issue { Severity = Severity.Error, Message = $"双生门「{t.trapId}」每次命中扩大占比须在 0～0.2，0 表示固定宽度" });
            }
            // 英雄充能门通过时只执行技能冷却缩短，不使用数字区间表。
            // 这类门允许 paraTable 为空，避免在编辑器保存时产生误导性的警告。
            if (t.heroChargePercent <= 0f && t.choiceMode != "three" && (t.gateType == "gate_counter" || t.gateType == "gate_duet"))
            {
                var entries = StgGateParaTableUtil.DecodeCounter(t.paraTable);
                var problem = StgGateParaTableUtil.CheckCounterContinuity(entries);
                if (problem != null) issues.Add(new Issue { Severity = Severity.Warning, Message = $"数字门「{t.trapId}」左侧区间表：{problem}" });

                if (t.gateType == "gate_duet")
                {
                    var rightEntries = StgGateParaTableUtil.DecodeCounter(t.paraTableRight);
                    var rightProblem = StgGateParaTableUtil.CheckCounterContinuity(rightEntries);
                    if (rightProblem != null) issues.Add(new Issue { Severity = Severity.Warning, Message = $"数字门「{t.trapId}」右侧区间表：{rightProblem}" });
                }
            }
        }

        return issues;

        void AddDuplicateIdIssues(IEnumerable<string> ids, string label)
        {
            foreach (var group in ids.Where(id => !string.IsNullOrEmpty(id)).GroupBy(id => id).Where(g => g.Count() > 1))
                issues.Add(new Issue { Severity = Severity.Error, Message = $"{label} ID「{group.Key}」重复定义 {group.Count()} 次，运行时索引会覆盖" });
        }
    }

    public void Rebuild()
    {
        BuildUI();
    }
}
