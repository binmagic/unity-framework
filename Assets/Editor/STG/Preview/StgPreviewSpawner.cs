using System.Collections.Generic;
using System.Linq;
using UnityEngine;

// 根据关卡配置在预览场景里生成对象，详见关卡编辑器设计文档 4.3/4.4/4.5 节
// 本文件同时承载预览运行时的对象句柄/运行态数据定义（StgPreviewObjectHandle 及各 *RuntimeState），
// 因为这些类型是"生成"动作的直接产物，放在 Spawner 里比单独开一个文件更贴近职责边界
public class StgPreviewObjectHandle
{
    public GameObject GameObject;
    public string Category; // enemy / boss / trap / item / background_layer / bullet_fx / spawn_area_marker
    public float SpawnTime;
    public float Lifetime = -1f; // 秒；<=0 表示不按存活时长自动回收，只按出画幅/手动逻辑回收
    public Vector2 Position;
    public Vector2 Velocity;
    public object ConfigRef;
    public object RuntimeState;
    public bool MarkedForRecycle;
}

public class StgEnemyRuntimeState
{
    public StgWaveTemplate Template;
    public string Phase = "entry"; // entry -> behavior
    public float BehaviorTimer;
    public float FireTimer;
    public float EntryStartX;
    public float PhaseStartTime;
}

public class StgBossRuntimeState
{
    public StgBossConfig Config;
    public int CurrentPhaseIndex = -1;
    public float FakeHpFraction = 1f;
    public List<float> SkillTimers = new List<float>();
    public float PatrolTimer;
}

public class StgTrapRuntimeState
{
    public StgTrapConfig Config;
    public bool GateOn;
    public float StateTimer;
    public float PathTimer;
    public Vector2 PathOrigin; // moving_obstacle 用：生成时的初始位置，circular/sine 路径以此为基准点计算绝对坐标
}

public class StgItemRuntimeState
{
    public StgItemConfig Config;
    public bool Attracting;
}

public static class StgPreviewSpawner
{
    // ---------- 配置查找 ----------

    public static StgWaveTemplate FindWaveTemplate(StgLevelEditorModel m, string id) =>
        m.enemyWaveTemplates.FirstOrDefault(t => t.templateId == id);

    public static StgBossConfig FindBoss(StgLevelEditorModel m, string id) =>
        m.bossConfigs.FirstOrDefault(b => b.bossId == id);

    public static StgTrapConfig FindTrap(StgLevelEditorModel m, string id) =>
        m.trapConfigs.FirstOrDefault(t => t.trapId == id);

    public static StgItemConfig FindItem(StgLevelEditorModel m, string id) =>
        m.itemConfigs.FirstOrDefault(i => i.itemId == id);

    public static StgDropTable FindDropTable(StgLevelEditorModel m, string id) =>
        m.globalDropTables.FirstOrDefault(d => d.dropTableId == id);

    public static StgSpawnAreaConfig FindSpawnArea(StgLevelEditorModel m, string id) =>
        m.spawnAreaConfigs.FirstOrDefault(s => s.spawnAreaId == id);

    // ---------- 背景 ----------

    // Category 统一为 "background_layer"，不再区分具体内容类型；ConfigRef 存 layer 本身，
    // 供 TickScroll 读取该层真实的 speedCoefficient（之前 island/cloud 都硬编码成系数1，这里一并修正）
    public static StgPreviewObjectHandle SpawnBackgroundElement(StgBackgroundLayer layer, StgSpawnRule rule, float x, float y, float scale, Transform parent, float previewTime)
    {
        var go = LoadPrefabOrPlaceholder(rule.prefabPath, StgPreviewPlaceholder.Kind.Background,
            null, StgPreviewPlaceholder.BackgroundColor, scale, parent);
        go.transform.localPosition = new Vector3(x, y, 0f);

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "background_layer",
            SpawnTime = previewTime,
            Lifetime = -1f, // 出画幅回收，不按存活时长
            Position = new Vector2(x, y),
            ConfigRef = layer,
        };
    }

    // ---------- 小怪波次 ----------

    // 返回该波次全部单位的句柄（含尚未真正生成、处于 rowDelay 延迟中的“待生成”占位——由 MoveDrivers 在延迟到期时真正创建 GameObject，
    // 因此这里先只创建第一个单位，其余通过 runtime state 里的 pendingSpawns 队列延后创建，避免一次性生成造成瞬间大量对象）
    public static List<StgPreviewObjectHandle> SpawnEnemyWave(StgWaveTemplate template, float spawnX, float previewTime, Transform parent)
    {
        var handles = new List<StgPreviewObjectHandle>();
        int count = Mathf.Max(1, template.count);
        var offsets = ComputeFormationOffsets(template.formationType, count, Mathf.Max(4f, template.formationSpacing));

        for (int i = 0; i < count; i++)
        {
            float delay = i * Mathf.Max(0f, template.formationRowDelay);
            handles.Add(CreateEnemyUnit(template, spawnX + offsets[i].x, offsets[i].y, previewTime + delay, parent));
        }
        return handles;
    }

    static StgPreviewObjectHandle CreateEnemyUnit(StgWaveTemplate template, float spawnX, float yOffset, float spawnTime, Transform parent)
    {
        var go = LoadPrefabOrPlaceholder(template.enemyType, StgPreviewPlaceholder.Kind.Enemy,
            template.templateName, StgPreviewPlaceholder.EnemyColor, HpToScale(template.hp, 0.6f, 1.4f), parent);

        float startY = StgPreviewRuntime.ScreenTopY + Mathf.Abs(yOffset) * 0.15f; // 编队纵深错开，避免完全重叠
        go.transform.localPosition = new Vector3(spawnX, startY, 0f);
        go.SetActive(false); // 生成时间点未到（rowDelay 延迟）前不显示，由 MoveDrivers 在 SpawnTime 到达时激活

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "enemy",
            SpawnTime = spawnTime,
            Lifetime = -1f,
            Position = new Vector2(spawnX, startY),
            ConfigRef = template,
            RuntimeState = new StgEnemyRuntimeState { Template = template, EntryStartX = spawnX, PhaseStartTime = spawnTime },
        };
    }

    // ---------- 持续/范围刷怪区域 ----------
    // 移植自内部旧版 barrel 项目 ParkourBattle 的刷怪调度算法，尚未逐行核对源码（详见技术架构设计文档第零节）。
    // 预览态实现是对"大圈切7个内切小圆、逐圆轮转采样"这一描述的近似还原，用于验证生成节奏和分布手感，
    // 不代表未来正式 Lua 运行时实现的精确算法结果。

    public static Vector2 SampleSpawnAreaPosition(StgSpawnAreaConfig area, int sampleIndex)
    {
        switch (area.type)
        {
            case "fix_point":
                return new Vector2(area.centerX, area.centerY);
            case "round":
                return SampleOnRing(area.centerX, area.centerY, area.radiusOuter, sampleIndex);
            case "range":
            default:
                return SampleInscribedCircles(area.centerX, area.centerY + area.centerOffsetY, area.radiusOuter, area.radiusInner, sampleIndex);
        }
    }

    static Vector2 SampleOnRing(float cx, float cy, float radius, int index)
    {
        float angle = (index * 47f) % 360f * Mathf.Deg2Rad; // 47° 步进，避免相邻采样落在同一角度
        return new Vector2(cx + Mathf.Cos(angle) * radius, cy + Mathf.Sin(angle) * radius);
    }

    // 大圆内切 7 个小圆（中心 1 个 + 六边形分布 6 个），逐圆轮转、圆内用 sqrt(random) 采样，避免同批次挤在圆心
    static readonly System.Random s_SampleRandom = new System.Random();

    static Vector2 SampleInscribedCircles(float cx, float cy, float outerRadius, float innerRadius, int index)
    {
        float smallRadius = outerRadius / 3f;
        int circleIndex = index % 7;
        float subCx = cx, subCy = cy;
        if (circleIndex > 0)
        {
            float angle = (circleIndex - 1) * 60f * Mathf.Deg2Rad;
            float dist = smallRadius * 2f;
            subCx += Mathf.Cos(angle) * dist;
            subCy += Mathf.Sin(angle) * dist;
        }

        double r = System.Math.Sqrt(s_SampleRandom.NextDouble()) * smallRadius;
        double theta = s_SampleRandom.NextDouble() * System.Math.PI * 2;
        float px = subCx + (float)(r * System.Math.Cos(theta));
        float py = subCy + (float)(r * System.Math.Sin(theta));

        if (innerRadius > 0f)
        {
            float d = Vector2.Distance(new Vector2(px, py), new Vector2(cx, cy));
            if (d < innerRadius)
            {
                float scale = innerRadius / Mathf.Max(0.01f, d);
                px = cx + (px - cx) * scale;
                py = cy + (py - cy) * scale;
            }
        }
        return new Vector2(px, py);
    }

    public static StgPreviewObjectHandle SpawnAreaMonster(StgSpawnAreaConfig area, Vector2 pos, float previewTime, Transform parent)
    {
        // 权重表只决定"生成哪种敌人"，预览态不区分具体外观差异，统一用占位敌人图形展示生成节奏
        var go = StgPreviewPlaceholder.CreatePlaceholder(StgPreviewPlaceholder.Kind.Enemy, null, StgPreviewPlaceholder.EnemyColor, 0.8f, parent);
        go.transform.localPosition = new Vector3(pos.x, pos.y, 0f);

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "enemy",
            SpawnTime = previewTime,
            Lifetime = 6f, // 刷怪区域生成的敌人不挂具体行为，固定存活一段时间后回收，避免无限堆积
            Position = pos,
            ConfigRef = area,
        };
    }

    // ---------- Boss ----------

    public static StgPreviewObjectHandle SpawnBoss(StgBossConfig config, float previewTime, Transform parent)
    {
        var go = LoadPrefabOrPlaceholder(config.prefabPath, StgPreviewPlaceholder.Kind.Boss,
            config.bossName, StgPreviewPlaceholder.BossColor, 2.2f, parent);

        Vector2 entryStart = GetBossEntryStart(config.entryAnimation);
        go.transform.localPosition = new Vector3(entryStart.x, entryStart.y, 0f);

        var state = new StgBossRuntimeState { Config = config };
        if (config.phases.Count > 0)
        {
            state.SkillTimers = config.phases[0].skills.Select(s => 0f).ToList();
        }

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "boss",
            SpawnTime = previewTime,
            Lifetime = -1f,
            Position = entryStart,
            ConfigRef = config,
            RuntimeState = state,
        };
    }

    static Vector2 GetBossEntryStart(string entryAnimation)
    {
        switch (entryAnimation)
        {
            case "fly_in_from_left": return new Vector2(-StgPreviewRuntime.ScreenHalfWidth - 2f, StgPreviewRuntime.BossStationY);
            case "fly_in_from_right": return new Vector2(StgPreviewRuntime.ScreenHalfWidth + 2f, StgPreviewRuntime.BossStationY);
            case "rise_from_bottom": return new Vector2(0f, StgPreviewRuntime.ScreenBottomY - 2f);
            case "teleport_in": return new Vector2(0f, StgPreviewRuntime.BossStationY);
            case "fly_in_from_top":
            default: return new Vector2(0f, StgPreviewRuntime.ScreenTopY + 2f);
        }
    }

    // ---------- 机关 ----------

    public static StgPreviewObjectHandle SpawnTrap(StgTrapConfig config, Vector2? overridePos, float previewTime, Transform parent)
    {
        Vector2 pos = overridePos ?? new Vector2(config.positionX, config.positionY);
        var go = LoadPrefabOrPlaceholder(config.prefabPath, StgPreviewPlaceholder.Kind.Trap,
            config.trapName, StgPreviewPlaceholder.TrapColor, 1f, parent);
        go.transform.localPosition = new Vector3(pos.x, pos.y, 0f);

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "trap",
            SpawnTime = previewTime,
            Lifetime = config.type == "digital_gate" ? 8f : -1f, // 抛撒数字门演出完成后自动回收，摆放类机关常驻
            Position = pos,
            ConfigRef = config,
            RuntimeState = new StgTrapRuntimeState { Config = config, GateOn = config.paramInitialState != "off", PathOrigin = pos },
        };
    }

    // ---------- 物品 ----------

    public static StgPreviewObjectHandle SpawnItem(StgItemConfig config, Vector2 pos, float previewTime, Transform parent)
    {
        var go = LoadPrefabOrPlaceholder(config.prefabPath, StgPreviewPlaceholder.Kind.Item,
            null, StgPreviewPlaceholder.ItemColor(config.type), 0.5f, parent);
        go.transform.localPosition = new Vector3(pos.x, pos.y, 0f);

        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "item",
            SpawnTime = previewTime,
            Lifetime = config.lifetime > 0f ? config.lifetime : 10f,
            Position = pos,
            ConfigRef = config,
            RuntimeState = new StgItemRuntimeState { Config = config },
        };
    }

    // 按 pattern 生成一组物品位置（single/line_horizontal/line_vertical/circle/v_shape/random）
    public static List<Vector2> ComputeItemDropPositions(string pattern, Vector2 origin, int count, float spacing)
    {
        var list = new List<Vector2>();
        count = Mathf.Max(1, count);
        spacing = Mathf.Max(0.3f, spacing);

        switch (pattern)
        {
            case "line_horizontal":
                for (int i = 0; i < count; i++) list.Add(origin + new Vector2((i - (count - 1) / 2f) * spacing, 0f));
                break;
            case "line_vertical":
                for (int i = 0; i < count; i++) list.Add(origin + new Vector2(0f, (i - (count - 1) / 2f) * spacing));
                break;
            case "circle":
                for (int i = 0; i < count; i++)
                {
                    float angle = i * Mathf.PI * 2f / count;
                    list.Add(origin + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * spacing);
                }
                break;
            case "v_shape":
                for (int i = 0; i < count; i++)
                {
                    int side = i % 2 == 0 ? 1 : -1;
                    int depth = i / 2;
                    list.Add(origin + new Vector2(side * depth * spacing, -depth * spacing));
                }
                break;
            case "random":
                for (int i = 0; i < count; i++)
                    list.Add(origin + new Vector2((float)(s_SampleRandom.NextDouble() * 2 - 1), (float)(s_SampleRandom.NextDouble() * 2 - 1)) * spacing * count * 0.3f);
                break;
            case "single":
            default:
                list.Add(origin);
                break;
        }
        return list;
    }

    // ---------- 子弹/技能视觉演出（Boss 技能、机关炮塔、数字门抛撒等共用） ----------

    public static StgPreviewObjectHandle SpawnBulletFx(Vector2 pos, Vector2 velocity, float lifetime, float scale, Transform parent)
    {
        var go = StgPreviewPlaceholder.CreatePlaceholder(StgPreviewPlaceholder.Kind.Enemy, null, new Color(1f, 0.9f, 0.3f, 0.9f), scale, parent);
        go.transform.localPosition = new Vector3(pos.x, pos.y, 0f);
        return new StgPreviewObjectHandle
        {
            GameObject = go,
            Category = "bullet_fx",
            Lifetime = lifetime,
            Position = pos,
            Velocity = velocity,
        };
    }

    // ---------- 编队偏移计算 ----------

    static Vector2[] ComputeFormationOffsets(string formationType, int count, float spacing)
    {
        var offsets = new Vector2[count];
        switch (formationType)
        {
            case "line_horizontal":
                for (int i = 0; i < count; i++) offsets[i] = new Vector2((i - (count - 1) / 2f) * spacing, 0f);
                break;
            case "line_vertical":
                for (int i = 0; i < count; i++) offsets[i] = new Vector2(0f, i * spacing);
                break;
            case "v_shape":
            case "arrow":
                for (int i = 0; i < count; i++)
                {
                    int side = i % 2 == 0 ? 1 : -1;
                    int depth = (i + 1) / 2;
                    offsets[i] = new Vector2(side * depth * spacing, depth * spacing * 0.6f);
                }
                break;
            case "circle":
                for (int i = 0; i < count; i++)
                {
                    float angle = i * Mathf.PI * 2f / count;
                    offsets[i] = new Vector2(Mathf.Cos(angle) * spacing, Mathf.Sin(angle) * spacing * 0.4f);
                }
                break;
            case "random":
                for (int i = 0; i < count; i++)
                    offsets[i] = new Vector2((float)(s_SampleRandom.NextDouble() * 2 - 1) * spacing * count * 0.3f, (float)s_SampleRandom.NextDouble() * spacing);
                break;
            case "single":
            default:
                for (int i = 0; i < count; i++) offsets[i] = Vector2.zero;
                break;
        }
        return offsets;
    }

    static float HpToScale(int hp, float min, float max)
    {
        float t = Mathf.InverseLerp(20f, 2000f, hp);
        return Mathf.Lerp(min, max, Mathf.Clamp01(t));
    }

    // ---------- 预制件加载/占位图形降级 ----------

    static GameObject LoadPrefabOrPlaceholder(string prefabPath, StgPreviewPlaceholder.Kind kind, string label, Color placeholderColor, float scale, Transform parent)
    {
        if (!string.IsNullOrEmpty(prefabPath))
        {
            var prefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if (prefab != null)
            {
                var instance = Object.Instantiate(prefab, parent);
                instance.hideFlags = HideFlags.DontSave;
                instance.transform.localScale = Vector3.one * scale;
                return instance;
            }
            // 路径填了但加载失败：降级为占位图形，由调用方（StgPreviewRuntime）统计告警数量
            StgPreviewRuntime.ReportPlaceholderFallback();
        }
        return StgPreviewPlaceholder.CreatePlaceholder(kind, label, placeholderColor, scale, parent);
    }
}
