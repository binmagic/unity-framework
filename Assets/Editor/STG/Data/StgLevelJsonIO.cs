using System.Collections.Generic;
using System.IO;
using JsonData = StgJsonValue;

// StgLevelEditorModel <-> JSON 读写，字段结构对齐 Docs/STG 关卡生成工具设计.md 第四节完整 JSON 示例
// 手动构造/解析 JsonData 树。JSON 底层实现见 StgJson.cs（StgJsonValue），不使用 LitJson——
// Assembly-CSharp-Editor 同时能看到源码版和微信小游戏插件版两份 LitJson.JsonType，引用会产生
// CS0433 歧义，详见 StgJson.cs 文件头注释。这是对《STG 关卡编辑器设计.md》原定"C# 侧沿用 LitJson"
// 的一处偏离，该文档已同步补充说明。
public static class StgLevelJsonIO
{
    public static StgLevelEditorModel LoadFromFile(string path)
    {
        string text = File.ReadAllText(path);
        JsonData root = StgJsonValue.Parse(text);
        return FromJson(root);
    }

    public static void SaveToFile(StgLevelEditorModel model, string path)
    {
        JsonData root = ToJson(model);
        File.WriteAllText(path, root.ToJsonString());
    }

    // ---------- Model -> JsonData ----------

    public static JsonData ToJson(StgLevelEditorModel model)
    {
        var root = new JsonData();
        root["version"] = model.version;
        root["levelId"] = model.levelId;
        root["levelName"] = model.levelName;
        root["description"] = model.description;
        root["seed"] = model.seed;

        root["basicScroll"] = BasicScrollToJson(model.basicScroll);
        root["backgroundLayers"] = ListToJson(model.backgroundLayers, BackgroundLayerToJson);
        root["objectPool"] = ObjectPoolToJson(model.objectPool);

        root["itemConfigs"] = ListToJson(model.itemConfigs, ItemConfigToJson);
        root["globalDropTables"] = ListToJson(model.globalDropTables, DropTableToJson);

        root["spawnAreaConfigs"] = ListToJson(model.spawnAreaConfigs, SpawnAreaToJson);
        root["enemyWaveTemplates"] = ListToJson(model.enemyWaveTemplates, WaveTemplateToJson);
        root["bossConfigs"] = ListToJson(model.bossConfigs, BossConfigToJson);
        root["trapConfigs"] = ListToJson(model.trapConfigs, TrapConfigToJson);

        root["timeline"] = TimelineToJson(model.timeline);
        return root;
    }

    static JsonData ListToJson<T>(List<T> list, System.Func<T, JsonData> converter)
    {
        var arr = StgJsonValue.NewArray();
        foreach (var item in list)
        {
            arr.Add(converter(item));
        }
        return arr;
    }

    static JsonData BasicScrollToJson(StgBasicScroll s)
    {
        var j = new JsonData();
        j["baseSpeed"] = s.baseSpeed;
        j["speedMultiplier"] = s.speedMultiplier;
        j["rampUpTime"] = s.rampUpTime;
        j["rampUpTargetSpeed"] = s.rampUpTargetSpeed;
        return j;
    }

    // 统一背景层：不管 enableScatterSpawn 是否开启，都写完整字段（哪怕散布字段用不到），
    // 保持结构稳定简单，避免"字段有没有出现"这种隐式状态增加读取分支
    static JsonData BackgroundLayerToJson(StgBackgroundLayer l)
    {
        var j = new JsonData();
        j["layerId"] = l.layerId;
        j["layerName"] = l.layerName;
        j["layerType"] = l.layerType;
        j["orderInLayer"] = l.orderInLayer;

        j["speedCoefficient"] = l.speedCoefficient;
        j["useTileLoop"] = l.useTileLoop;
        // 循环贴图带：数组顺序即拼接顺序，滚完最后一张接回第一张
        var tilePaths = StgJsonValue.NewArray();
        foreach (var path in l.tileSpritePaths) tilePaths.Add(path);
        j["tileSpritePaths"] = tilePaths;
        j["tileWorldHeight"] = l.tileWorldHeight;

        j["enableScatterSpawn"] = l.enableScatterSpawn;
        if (l.enableScatterSpawn)
        {
            var interval = StgJsonValue.NewArray();
            interval.Add((double)l.scatterIntervalMin);
            interval.Add((double)l.scatterIntervalMax);
            j["scatterInterval"] = interval;
            j["scatterMaxActive"] = l.scatterMaxActive;
            j["scatterOverlapCheckRadius"] = l.scatterOverlapCheckRadius;
            j["scatterSpawnYOffset"] = l.scatterSpawnYOffset;
            j["scatterRules"] = ListToJson(l.scatterRules, SpawnRuleToJson);
        }
        return j;
    }

    static JsonData SpawnRuleToJson(StgSpawnRule r)
    {
        var j = new JsonData();
        j["ruleName"] = r.ruleName;
        j["prefabPath"] = r.prefabPath;
        j["weight"] = r.weight;
        var sizeRange = StgJsonValue.NewArray();
        sizeRange.Add((double)r.sizeRangeMin);
        sizeRange.Add((double)r.sizeRangeMax);
        j["sizeRange"] = sizeRange;
        j["allowPartialOffscreen"] = r.allowPartialOffscreen;
        return j;
    }

    static JsonData ObjectPoolToJson(StgObjectPoolConfig p)
    {
        var j = new JsonData();
        j["backgroundLayerPoolSize"] = p.backgroundLayerPoolSize;
        j["enemyPoolSize"] = p.enemyPoolSize;
        j["bossPoolSize"] = p.bossPoolSize;
        j["bulletPoolSize"] = p.bulletPoolSize;
        j["itemPoolSize"] = p.itemPoolSize;
        j["trapPoolSize"] = p.trapPoolSize;
        j["preloadOnStart"] = p.preloadOnStart;
        return j;
    }

    static JsonData ItemConfigToJson(StgItemConfig i)
    {
        var j = new JsonData();
        j["itemId"] = i.itemId;
        j["itemName"] = i.itemName;
        j["prefabPath"] = i.prefabPath;
        j["type"] = i.type;
        j["value"] = i.value;
        j["moveMode"] = i.moveMode;
        j["attractToPlayer"] = i.attractToPlayer;
        j["attractRadius"] = i.attractRadius;
        j["lifetime"] = i.lifetime;
        return j;
    }

    static JsonData DropTableToJson(StgDropTable d)
    {
        var j = new JsonData();
        j["dropTableId"] = d.dropTableId;
        j["entries"] = ListToJson(d.entries, DropEntryToJson);
        return j;
    }

    static JsonData DropEntryToJson(StgDropEntry e)
    {
        var j = new JsonData();
        j["itemId"] = e.itemId;
        j["probability"] = e.probability;
        var countRange = StgJsonValue.NewArray();
        countRange.Add(e.countMin);
        countRange.Add(e.countMax);
        j["countRange"] = countRange;
        return j;
    }

    static JsonData SpawnAreaToJson(StgSpawnAreaConfig s)
    {
        var j = new JsonData();
        j["spawnAreaId"] = s.spawnAreaId;
        j["type"] = s.type;
        var center = new JsonData();
        center["x"] = s.centerX;
        center["y"] = s.centerY;
        j["centerCoord"] = center;
        j["monsterWeights"] = s.monsterWeights;
        j["limit"] = s.limit;
        j["intervalMin"] = s.intervalMin;
        j["intervalMax"] = s.intervalMax;
        j["interval"] = s.interval;
        j["radiusOuter"] = s.radiusOuter;
        j["radiusInner"] = s.radiusInner;
        j["centerOffsetY"] = s.centerOffsetY;
        return j;
    }

    static JsonData WaveTemplateToJson(StgWaveTemplate t)
    {
        var j = new JsonData();
        j["templateId"] = t.templateId;
        j["templateName"] = t.templateName;
        j["enemyType"] = t.enemyType;
        j["count"] = t.count;

        var formation = new JsonData();
        formation["type"] = t.formationType;
        formation["spacing"] = t.formationSpacing;
        formation["rowDelay"] = t.formationRowDelay;
        j["formation"] = formation;

        var entryPath = new JsonData();
        entryPath["type"] = t.entryPathType;
        entryPath["speed"] = t.entryPathSpeed;
        entryPath["amplitude"] = t.entryPathAmplitude;
        j["entryPath"] = entryPath;

        var behavior = new JsonData();
        behavior["type"] = t.behaviorType;
        behavior["fireInterval"] = t.behaviorFireInterval;
        behavior["bulletType"] = t.behaviorBulletType;
        j["behavior"] = behavior;

        j["hp"] = t.hp;
        j["score"] = t.score;
        j["dropTableId"] = t.dropTableId;
        return j;
    }

    static JsonData BossConfigToJson(StgBossConfig b)
    {
        var j = new JsonData();
        j["bossId"] = b.bossId;
        j["bossName"] = b.bossName;
        j["prefabPath"] = b.prefabPath;
        j["entryAnimation"] = b.entryAnimation;
        j["totalHp"] = b.totalHp;
        j["score"] = b.score;
        j["phases"] = ListToJson(b.phases, BossPhaseToJson);
        j["dropOnDeath"] = ListToJson(b.dropOnDeath, DropFixedEntryToJson);
        j["onDefeatEvent"] = b.onDefeatEvent;
        return j;
    }

    static JsonData BossPhaseToJson(StgBossPhase p)
    {
        var j = new JsonData();
        j["phaseId"] = p.phaseId;
        j["hpThreshold"] = p.hpThreshold;
        j["movePattern"] = p.movePattern;
        j["skills"] = ListToJson(p.skills, BossSkillToJson);
        return j;
    }

    static JsonData BossSkillToJson(StgBossSkill s)
    {
        var j = new JsonData();
        j["skillId"] = s.skillId;
        j["interval"] = s.interval;
        j["bulletCount"] = s.bulletCount;
        j["spreadAngle"] = s.spreadAngle;
        j["duration"] = s.duration;
        j["width"] = s.width;
        j["rings"] = s.rings;
        j["waveTemplateId"] = s.waveTemplateId;
        j["count"] = s.count;
        j["speed"] = s.speed;
        j["damageReduction"] = s.damageReduction;
        return j;
    }

    static JsonData DropFixedEntryToJson(StgDropFixedEntry e)
    {
        var j = new JsonData();
        j["itemId"] = e.itemId;
        j["count"] = e.count;
        return j;
    }

    static JsonData TrapConfigToJson(StgTrapConfig t)
    {
        var j = new JsonData();
        j["trapId"] = t.trapId;
        j["trapName"] = t.trapName;
        j["type"] = t.type;
        j["prefabPath"] = t.prefabPath;
        var pos = new JsonData();
        pos["x"] = t.positionX;
        pos["y"] = t.positionY;
        j["position"] = pos;

        var p = new JsonData();
        switch (t.type)
        {
            case "static_obstacle":
                p["damage"] = t.paramDamage;
                p["destroyOnContact"] = t.paramDestroyOnContact;
                p["count"] = t.paramCount;
                p["spreadRadius"] = t.paramSpreadRadius;
                break;
            case "turret":
                p["fireInterval"] = t.paramFireInterval;
                p["bulletType"] = t.paramBulletType;
                p["damage"] = t.paramDamage;
                p["rotateSpeed"] = t.paramRotateSpeed;
                break;
            case "laser_gate":
                p["onDuration"] = t.paramOnDuration;
                p["offDuration"] = t.paramOffDuration;
                p["initialState"] = t.paramInitialState;
                p["damage"] = t.paramDamage;
                p["width"] = t.paramWidth;
                break;
            case "destructible":
                // hp/dropTableId 走通用字段
                break;
            case "moving_obstacle":
                p["pathType"] = t.paramPathType;
                p["speed"] = t.paramSpeed;
                p["damage"] = t.paramDamage;
                break;
            case "slow_field":
                p["slowFactor"] = t.paramSlowFactor;
                p["radius"] = t.paramRadius;
                p["duration"] = t.paramDuration;
                break;
            case "digital_gate":
                p["gateType"] = t.gateType;
                p["paraTable"] = t.paraTable;
                if (t.gateType == "gate_duet")
                {
                    p["paraTableRight"] = t.paraTableRight;
                }
                p["initialValue"] = t.initialValue;
                p["effectTableRef"] = t.effectTableRef;
                break;
        }
        j["params"] = p;

        j["hp"] = t.hp;
        j["destroyable"] = t.destroyable;
        j["dropTableId"] = t.dropTableId;
        if (t.type == "digital_gate")
        {
            j["isReusableGateTemplate"] = t.isReusableGateTemplate;
        }
        return j;
    }

    static JsonData TimelineToJson(StgTimeline tl)
    {
        var j = new JsonData();
        j["duration"] = tl.duration;
        j["events"] = ListToJson(tl.events, TimelineEventToJson);
        return j;
    }

    static JsonData TimelineEventToJson(StgTimelineEvent e)
    {
        var j = new JsonData();
        j["time"] = e.time;
        j["type"] = e.type;

        switch (e.type)
        {
            case "spawn_enemy_wave":
                j["templateId"] = e.templateId;
                j["offsetX"] = e.offsetX;
                break;
            case "spawn_boss":
                j["bossId"] = e.bossId;
                break;
            case "spawn_trap":
                j["trapId"] = e.trapId;
                if (e.positionX != 0f || e.positionY != 0f)
                {
                    var pos = new JsonData();
                    pos["x"] = e.positionX;
                    pos["y"] = e.positionY;
                    j["position"] = pos;
                }
                break;
            case "spawn_area_start":
                j["spawnAreaId"] = e.spawnAreaId;
                j["startTime"] = e.startTime;
                j["endTime"] = e.endTime;
                break;
            case "spawn_area_stop":
                j["spawnAreaId"] = e.spawnAreaId;
                break;
            case "drop_digital_gate":
                j["gateType"] = e.gateType;
                j["count"] = e.count;
                j["interval"] = e.dropIntervalSec;
                var offsetRange = new JsonData();
                offsetRange["xMin"] = e.offsetXMin;
                offsetRange["xMax"] = e.offsetXMax;
                offsetRange["yMin"] = e.offsetYMin;
                offsetRange["yMax"] = e.offsetYMax;
                j["offsetRange"] = offsetRange;
                j["dropAniDuration"] = e.dropAniDuration;
                var gatePos = new JsonData();
                gatePos["x"] = e.positionX;
                gatePos["y"] = e.positionY;
                j["position"] = gatePos;
                break;
            case "spawn_item":
                j["itemId"] = e.itemId;
                j["pattern"] = e.pattern;
                j["count"] = e.count;
                j["spacing"] = e.spacing;
                var itemPos = new JsonData();
                itemPos["x"] = e.positionX;
                itemPos["y"] = e.positionY;
                j["position"] = itemPos;
                break;
            case "change_scroll_speed":
                j["speed"] = e.speed;
                break;
            case "show_banner":
                j["text"] = e.text;
                j["duration"] = e.duration;
                break;
            case "play_bgm":
                j["bgmId"] = e.bgmId;
                j["fadeDuration"] = e.fadeDuration;
                break;
            case "pause_enemy_spawn":
                j["duration"] = e.duration;
                break;
            case "resume_enemy_spawn":
            case "level_complete":
            case "game_over":
                break;
            case "trigger_cutscene":
                j["cutsceneId"] = e.cutsceneId;
                break;
        }
        return j;
    }

    // ---------- JsonData -> Model ----------

    public static StgLevelEditorModel FromJson(JsonData root)
    {
        var model = new StgLevelEditorModel();
        model.version = GetString(root, "version", "1.0");
        model.levelId = GetString(root, "levelId", "");
        model.levelName = GetString(root, "levelName", "");
        model.description = GetString(root, "description", "");
        model.seed = GetInt(root, "seed", 0);

        if (root.ContainsKey("basicScroll")) model.basicScroll = BasicScrollFromJson(root["basicScroll"]);
        if (root.ContainsKey("backgroundLayers")) model.backgroundLayers = FromArray(root["backgroundLayers"], BackgroundLayerFromJson);
        if (root.ContainsKey("objectPool")) model.objectPool = ObjectPoolFromJson(root["objectPool"]);

        if (root.ContainsKey("itemConfigs")) model.itemConfigs = FromArray(root["itemConfigs"], ItemConfigFromJson);
        if (root.ContainsKey("globalDropTables")) model.globalDropTables = FromArray(root["globalDropTables"], DropTableFromJson);

        if (root.ContainsKey("spawnAreaConfigs")) model.spawnAreaConfigs = FromArray(root["spawnAreaConfigs"], SpawnAreaFromJson);
        if (root.ContainsKey("enemyWaveTemplates")) model.enemyWaveTemplates = FromArray(root["enemyWaveTemplates"], WaveTemplateFromJson);
        if (root.ContainsKey("bossConfigs")) model.bossConfigs = FromArray(root["bossConfigs"], BossConfigFromJson);
        if (root.ContainsKey("trapConfigs")) model.trapConfigs = FromArray(root["trapConfigs"], TrapConfigFromJson);

        if (root.ContainsKey("timeline")) model.timeline = TimelineFromJson(root["timeline"]);
        return model;
    }

    static List<T> FromArray<T>(JsonData arr, System.Func<JsonData, T> converter)
    {
        var list = new List<T>();
        if (arr == null || !arr.IsArray) return list;
        for (int i = 0; i < arr.Count; i++)
        {
            list.Add(converter(arr[i]));
        }
        return list;
    }

    static string GetString(JsonData j, string key, string def)
    {
        if (j == null || !j.ContainsKey(key) || j[key] == null) return def;
        return (string)j[key];
    }

    static int GetInt(JsonData j, string key, int def)
    {
        if (j == null || !j.ContainsKey(key) || j[key] == null) return def;
        var v = j[key];
        if (v.IsInt) return (int)v;
        if (v.IsDouble) return (int)(double)v;
        return def;
    }

    static float GetFloat(JsonData j, string key, float def)
    {
        if (j == null || !j.ContainsKey(key) || j[key] == null) return def;
        var v = j[key];
        if (v.IsDouble) return (float)(double)v;
        if (v.IsInt) return (int)v;
        return def;
    }

    static bool GetBool(JsonData j, string key, bool def)
    {
        if (j == null || !j.ContainsKey(key) || j[key] == null) return def;
        return (bool)j[key];
    }

    static StgBasicScroll BasicScrollFromJson(JsonData j)
    {
        var s = new StgBasicScroll();
        s.baseSpeed = GetFloat(j, "baseSpeed", 300f);
        s.speedMultiplier = GetFloat(j, "speedMultiplier", 1.0f);
        s.rampUpTime = GetFloat(j, "rampUpTime", 0f);
        s.rampUpTargetSpeed = GetFloat(j, "rampUpTargetSpeed", 300f);
        return s;
    }

    static StgBackgroundLayer BackgroundLayerFromJson(JsonData j)
    {
        var l = new StgBackgroundLayer();
        l.layerId = GetString(j, "layerId", "");
        l.layerName = GetString(j, "layerName", "");
        l.layerType = GetString(j, "layerType", "parallax");
        l.orderInLayer = GetInt(j, "orderInLayer", 0);

        l.speedCoefficient = GetFloat(j, "speedCoefficient", 1.0f);
        l.useTileLoop = GetBool(j, "useTileLoop", false);
        l.tileSpritePaths = new List<string>();
        if (j.ContainsKey("tileSpritePaths") && j["tileSpritePaths"].IsArray)
        {
            var arr = j["tileSpritePaths"];
            for (int i = 0; i < arr.Count; i++) l.tileSpritePaths.Add((string)arr[i]);
        }
        l.tileWorldHeight = GetFloat(j, "tileWorldHeight", 0f);

        l.enableScatterSpawn = GetBool(j, "enableScatterSpawn", false);
        if (j.ContainsKey("scatterInterval") && j["scatterInterval"].IsArray && j["scatterInterval"].Count >= 2)
        {
            l.scatterIntervalMin = (float)(double)j["scatterInterval"][0];
            l.scatterIntervalMax = (float)(double)j["scatterInterval"][1];
        }
        l.scatterMaxActive = GetInt(j, "scatterMaxActive", 6);
        l.scatterOverlapCheckRadius = GetFloat(j, "scatterOverlapCheckRadius", 150f);
        l.scatterSpawnYOffset = GetFloat(j, "scatterSpawnYOffset", 100f);
        if (j.ContainsKey("scatterRules")) l.scatterRules = FromArray(j["scatterRules"], SpawnRuleFromJson);
        return l;
    }

    static StgSpawnRule SpawnRuleFromJson(JsonData j)
    {
        var r = new StgSpawnRule();
        r.ruleName = GetString(j, "ruleName", "");
        r.prefabPath = GetString(j, "prefabPath", "");
        r.weight = GetFloat(j, "weight", 1f);
        if (j.ContainsKey("sizeRange") && j["sizeRange"].IsArray && j["sizeRange"].Count >= 2)
        {
            r.sizeRangeMin = (float)(double)j["sizeRange"][0];
            r.sizeRangeMax = (float)(double)j["sizeRange"][1];
        }
        r.allowPartialOffscreen = GetBool(j, "allowPartialOffscreen", true);
        return r;
    }

    static StgObjectPoolConfig ObjectPoolFromJson(JsonData j)
    {
        var p = new StgObjectPoolConfig();
        p.backgroundLayerPoolSize = GetInt(j, "backgroundLayerPoolSize", 20);
        p.enemyPoolSize = GetInt(j, "enemyPoolSize", 30);
        p.bossPoolSize = GetInt(j, "bossPoolSize", 2);
        p.bulletPoolSize = GetInt(j, "bulletPoolSize", 100);
        p.itemPoolSize = GetInt(j, "itemPoolSize", 50);
        p.trapPoolSize = GetInt(j, "trapPoolSize", 15);
        p.preloadOnStart = GetBool(j, "preloadOnStart", true);
        return p;
    }

    static StgItemConfig ItemConfigFromJson(JsonData j)
    {
        var i = new StgItemConfig();
        i.itemId = GetString(j, "itemId", "");
        i.itemName = GetString(j, "itemName", "");
        i.prefabPath = GetString(j, "prefabPath", "");
        i.type = GetString(j, "type", "currency");
        i.value = GetInt(j, "value", 0);
        i.moveMode = GetString(j, "moveMode", "fall_down");
        i.attractToPlayer = GetBool(j, "attractToPlayer", true);
        i.attractRadius = GetFloat(j, "attractRadius", 100f);
        i.lifetime = GetFloat(j, "lifetime", 10f);
        return i;
    }

    static StgDropTable DropTableFromJson(JsonData j)
    {
        var d = new StgDropTable();
        d.dropTableId = GetString(j, "dropTableId", "");
        if (j.ContainsKey("entries")) d.entries = FromArray(j["entries"], DropEntryFromJson);
        return d;
    }

    static StgDropEntry DropEntryFromJson(JsonData j)
    {
        var e = new StgDropEntry();
        e.itemId = GetString(j, "itemId", "");
        e.probability = GetFloat(j, "probability", 0f);
        if (j.ContainsKey("countRange") && j["countRange"].IsArray && j["countRange"].Count >= 2)
        {
            e.countMin = GetIntFromArrayElement(j["countRange"][0]);
            e.countMax = GetIntFromArrayElement(j["countRange"][1]);
        }
        return e;
    }

    static int GetIntFromArrayElement(JsonData v)
    {
        if (v.IsInt) return (int)v;
        if (v.IsDouble) return (int)(double)v;
        return 0;
    }

    static StgSpawnAreaConfig SpawnAreaFromJson(JsonData j)
    {
        var s = new StgSpawnAreaConfig();
        s.spawnAreaId = GetString(j, "spawnAreaId", "");
        s.type = GetString(j, "type", "fix_point");
        if (j.ContainsKey("centerCoord"))
        {
            s.centerX = GetFloat(j["centerCoord"], "x", 0f);
            s.centerY = GetFloat(j["centerCoord"], "y", 0f);
        }
        s.monsterWeights = GetString(j, "monsterWeights", "");
        s.limit = GetInt(j, "limit", 10);
        s.intervalMin = GetFloat(j, "intervalMin", 1f);
        s.intervalMax = GetFloat(j, "intervalMax", 2f);
        s.interval = GetFloat(j, "interval", 1f);
        s.radiusOuter = GetFloat(j, "radiusOuter", 200f);
        s.radiusInner = GetFloat(j, "radiusInner", 0f);
        s.centerOffsetY = GetFloat(j, "centerOffsetY", 0f);
        return s;
    }

    static StgWaveTemplate WaveTemplateFromJson(JsonData j)
    {
        var t = new StgWaveTemplate();
        t.templateId = GetString(j, "templateId", "");
        t.templateName = GetString(j, "templateName", "");
        t.enemyType = GetString(j, "enemyType", "");
        t.count = GetInt(j, "count", 1);

        if (j.ContainsKey("formation"))
        {
            t.formationType = GetString(j["formation"], "type", "single");
            t.formationSpacing = GetFloat(j["formation"], "spacing", 0f);
            t.formationRowDelay = GetFloat(j["formation"], "rowDelay", 0f);
        }
        if (j.ContainsKey("entryPath"))
        {
            t.entryPathType = GetString(j["entryPath"], "type", "from_top_straight");
            t.entryPathSpeed = GetFloat(j["entryPath"], "speed", 200f);
            t.entryPathAmplitude = GetFloat(j["entryPath"], "amplitude", 0f);
        }
        if (j.ContainsKey("behavior"))
        {
            t.behaviorType = GetString(j["behavior"], "type", "straight_down");
            t.behaviorFireInterval = GetFloat(j["behavior"], "fireInterval", 2.0f);
            t.behaviorBulletType = GetString(j["behavior"], "bulletType", "");
        }

        t.hp = GetInt(j, "hp", 100);
        t.score = GetInt(j, "score", 100);
        t.dropTableId = GetString(j, "dropTableId", "");
        return t;
    }

    static StgBossConfig BossConfigFromJson(JsonData j)
    {
        var b = new StgBossConfig();
        b.bossId = GetString(j, "bossId", "");
        b.bossName = GetString(j, "bossName", "");
        b.prefabPath = GetString(j, "prefabPath", "");
        b.entryAnimation = GetString(j, "entryAnimation", "fly_in_from_top");
        b.totalHp = GetInt(j, "totalHp", 5000);
        b.score = GetInt(j, "score", 5000);
        if (j.ContainsKey("phases")) b.phases = FromArray(j["phases"], BossPhaseFromJson);
        if (j.ContainsKey("dropOnDeath")) b.dropOnDeath = FromArray(j["dropOnDeath"], DropFixedEntryFromJson);
        b.onDefeatEvent = GetString(j, "onDefeatEvent", "");
        return b;
    }

    static StgBossPhase BossPhaseFromJson(JsonData j)
    {
        var p = new StgBossPhase();
        p.phaseId = GetInt(j, "phaseId", 1);
        p.hpThreshold = GetFloat(j, "hpThreshold", 1.0f);
        p.movePattern = GetString(j, "movePattern", "horizontal_patrol");
        if (j.ContainsKey("skills")) p.skills = FromArray(j["skills"], BossSkillFromJson);
        return p;
    }

    static StgBossSkill BossSkillFromJson(JsonData j)
    {
        var s = new StgBossSkill();
        s.skillId = GetString(j, "skillId", "spread_shot");
        s.interval = GetFloat(j, "interval", 2.0f);
        s.bulletCount = GetInt(j, "bulletCount", 5);
        s.spreadAngle = GetFloat(j, "spreadAngle", 60f);
        s.duration = GetFloat(j, "duration", 0f);
        s.width = GetFloat(j, "width", 0f);
        s.rings = GetInt(j, "rings", 0);
        s.waveTemplateId = GetString(j, "waveTemplateId", "");
        s.count = GetInt(j, "count", 0);
        s.speed = GetFloat(j, "speed", 0f);
        s.damageReduction = GetFloat(j, "damageReduction", 0f);
        return s;
    }

    static StgDropFixedEntry DropFixedEntryFromJson(JsonData j)
    {
        var e = new StgDropFixedEntry();
        e.itemId = GetString(j, "itemId", "");
        e.count = GetInt(j, "count", 1);
        return e;
    }

    static StgTrapConfig TrapConfigFromJson(JsonData j)
    {
        var t = new StgTrapConfig();
        t.trapId = GetString(j, "trapId", "");
        t.trapName = GetString(j, "trapName", "");
        t.type = GetString(j, "type", "static_obstacle");
        t.prefabPath = GetString(j, "prefabPath", "");
        if (j.ContainsKey("position"))
        {
            t.positionX = GetFloat(j["position"], "x", 0f);
            t.positionY = GetFloat(j["position"], "y", 0f);
        }

        if (j.ContainsKey("params"))
        {
            var p = j["params"];
            t.paramDamage = GetFloat(p, "damage", 0f);
            t.paramDestroyOnContact = GetBool(p, "destroyOnContact", false);
            t.paramCount = GetInt(p, "count", 0);
            t.paramSpreadRadius = GetFloat(p, "spreadRadius", 0f);
            t.paramFireInterval = GetFloat(p, "fireInterval", 0f);
            t.paramBulletType = GetString(p, "bulletType", "");
            t.paramRotateSpeed = GetFloat(p, "rotateSpeed", 0f);
            t.paramOnDuration = GetFloat(p, "onDuration", 0f);
            t.paramOffDuration = GetFloat(p, "offDuration", 0f);
            t.paramInitialState = GetString(p, "initialState", "on");
            t.paramWidth = GetFloat(p, "width", 0f);
            t.paramPathType = GetString(p, "pathType", "");
            t.paramSpeed = GetFloat(p, "speed", 0f);
            t.paramSlowFactor = GetFloat(p, "slowFactor", 0f);
            t.paramRadius = GetFloat(p, "radius", 0f);
            t.paramDuration = GetFloat(p, "duration", 0f);

            t.gateType = GetString(p, "gateType", "gate_step");
            t.paraTable = GetString(p, "paraTable", "");
            t.paraTableRight = GetString(p, "paraTableRight", "");
            t.initialValue = GetInt(p, "initialValue", 0);
            t.effectTableRef = GetString(p, "effectTableRef", "");
        }

        t.hp = GetInt(j, "hp", 9999);
        t.destroyable = GetBool(j, "destroyable", false);
        t.dropTableId = GetString(j, "dropTableId", "");
        t.isReusableGateTemplate = GetBool(j, "isReusableGateTemplate", false);
        return t;
    }

    static StgTimeline TimelineFromJson(JsonData j)
    {
        var tl = new StgTimeline();
        tl.duration = GetFloat(j, "duration", 60f);
        if (j.ContainsKey("events")) tl.events = FromArray(j["events"], TimelineEventFromJson);
        return tl;
    }

    static StgTimelineEvent TimelineEventFromJson(JsonData j)
    {
        var e = new StgTimelineEvent();
        e.time = GetFloat(j, "time", 0f);
        e.type = GetString(j, "type", "spawn_enemy_wave");

        e.templateId = GetString(j, "templateId", "");
        e.offsetX = GetFloat(j, "offsetX", 0f);
        e.bossId = GetString(j, "bossId", "");
        e.trapId = GetString(j, "trapId", "");
        e.spawnAreaId = GetString(j, "spawnAreaId", "");
        e.startTime = GetFloat(j, "startTime", 0f);
        e.endTime = GetFloat(j, "endTime", 0f);
        e.itemId = GetString(j, "itemId", "");
        e.pattern = GetString(j, "pattern", "single");
        e.count = GetInt(j, "count", 1);
        e.spacing = GetFloat(j, "spacing", 0f);
        e.speed = GetFloat(j, "speed", 0f);
        e.text = GetString(j, "text", "");
        e.duration = GetFloat(j, "duration", 0f);
        e.bgmId = GetString(j, "bgmId", "");
        e.fadeDuration = GetFloat(j, "fadeDuration", 0f);
        e.cutsceneId = GetString(j, "cutsceneId", "");

        if (j.ContainsKey("position"))
        {
            e.positionX = GetFloat(j["position"], "x", 0f);
            e.positionY = GetFloat(j["position"], "y", 0f);
        }

        if (e.type == "drop_digital_gate")
        {
            e.gateType = GetString(j, "gateType", "");
            e.dropIntervalSec = GetFloat(j, "interval", 0.1f);
            e.dropAniDuration = GetFloat(j, "dropAniDuration", 0.5f);
            if (j.ContainsKey("offsetRange"))
            {
                var r = j["offsetRange"];
                e.offsetXMin = GetFloat(r, "xMin", 0f);
                e.offsetXMax = GetFloat(r, "xMax", 0f);
                e.offsetYMin = GetFloat(r, "yMin", 0f);
                e.offsetYMax = GetFloat(r, "yMax", 0f);
            }
        }

        return e;
    }
}
