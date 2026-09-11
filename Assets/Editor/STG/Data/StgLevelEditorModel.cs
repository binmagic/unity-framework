using System.Collections.Generic;

// 对应 Lua 运行时: Game/STG/DataCenter/StgLevelConfig.lua 等一组 *Config/*Template 类
// 字段结构对齐 Docs/STG/STG 关卡生成工具设计.md 第四节完整 JSON 示例
// 修改本文件字段时，务必同步修改 StgLevelJsonIO.cs 的读写逻辑，以及运行时对应的 Lua 数据类

public class StgLevelEditorModel
{
    public string version = "1.0";
    public string levelId = "";
    public string levelName = "";
    public string description = "";
    public int seed = 0;

    public StgBasicScroll basicScroll = new StgBasicScroll();
    public List<StgBackgroundLayer> backgroundLayers = new List<StgBackgroundLayer>();
    public StgObjectPoolConfig objectPool = new StgObjectPoolConfig();

    public List<StgItemConfig> itemConfigs = new List<StgItemConfig>();
    public List<StgDropTable> globalDropTables = new List<StgDropTable>();

    public List<StgSpawnAreaConfig> spawnAreaConfigs = new List<StgSpawnAreaConfig>();
    public List<StgWaveTemplate> enemyWaveTemplates = new List<StgWaveTemplate>();
    public List<StgBossConfig> bossConfigs = new List<StgBossConfig>();
    public List<StgTrapConfig> trapConfigs = new List<StgTrapConfig>();

    public StgTimeline timeline = new StgTimeline();
}

public class StgBasicScroll
{
    public float baseSpeed = 300f;
    public float speedMultiplier = 1.0f;
    public float rampUpTime = 0f;
    public float rampUpTargetSpeed = 300f;
}

// 统一的背景层模型，替代原来的 StgParallaxLayer + StgBackgroundSpawn(islandSpawn/cloudSpawn)。
// 任意层都可以是纯视差滚动，也可以额外开启"随机散布"行为（enableScatterSpawn），
// 不再为"岛屿""云朵"这类具体内容单独开一套字段——它们现在只是散布层的一种配置结果。
// layerType: "parallax"（视差层，默认）/ "player"（玩家所在层，目前只做排序占位，不含玩家专属数据，
// 预览锚点仍用 StgPreviewMoveDrivers.PlayerAnchor 常量，不读取本字段）
public class StgBackgroundLayer
{
    public string layerId = "";
    public string layerName = "";
    public string layerType = "parallax";
    public int orderInLayer = 0;

    // ---- 视差滚动 ----
    public float speedCoefficient = 1.0f;
    // 循环贴图带：多张图按列表顺序首尾相接拼成无限带，滚完最后一张接回第一张
    // （单张图的情况就是列表里只放一条，效果等价于原来的 tileSpritePath）
    public List<string> tileSpritePaths = new List<string>();
    public bool useTileLoop = false;
    // 单张贴图在世界坐标下的高度；决定何时该在带尾接下一张。<=0 时运行时按画幅高度兜底
    public float tileWorldHeight = 0f;

    // ---- 随机散布（可选，任意 layerType 都可以启用）----
    public bool enableScatterSpawn = false;
    public float scatterIntervalMin = 1.0f;
    public float scatterIntervalMax = 2.0f;
    public int scatterMaxActive = 6;
    public float scatterOverlapCheckRadius = 150f;
    public float scatterSpawnYOffset = 100f;
    public List<StgSpawnRule> scatterRules = new List<StgSpawnRule>();
}

public class StgSpawnRule
{
    public string ruleName = "";
    public string prefabPath = "";
    public float weight = 1f;
    public float sizeRangeMin = 1f;
    public float sizeRangeMax = 1f;
    public bool allowPartialOffscreen = true;
}

public class StgObjectPoolConfig
{
    public int backgroundLayerPoolSize = 20; // 替代原 islandPoolSize(12) + cloudPoolSize(10)
    public int enemyPoolSize = 30;
    public int bossPoolSize = 2;
    public int bulletPoolSize = 100;
    public int itemPoolSize = 50;
    public int trapPoolSize = 15;
    public bool preloadOnStart = true;
}

public class StgItemConfig
{
    public string itemId = "";
    public string itemName = "";
    public string prefabPath = "";
    public string type = "currency";
    public int value = 0;
    public string moveMode = "fall_down";
    public bool attractToPlayer = true;
    public float attractRadius = 100f;
    public float lifetime = 10f;
}

public class StgDropTable
{
    public string dropTableId = "";
    public List<StgDropEntry> entries = new List<StgDropEntry>();
}

public class StgDropEntry
{
    public string itemId = "";
    public float probability = 0f;
    public int countMin = 1;
    public int countMax = 1;
}

// 移植自内部旧版 barrel 项目 ParkourBattle/GenMonsterTaskBase.lua，尚未逐行核对源码，详见技术架构设计文档第零节
public class StgSpawnAreaConfig
{
    public string spawnAreaId = "";
    public string type = "fix_point"; // fix_point / range / round
    public float centerX = 0f;
    public float centerY = 0f;
    public string monsterWeights = ""; // "敌人id|阈值,敌人id|阈值,..."
    public int limit = 10;
    public float intervalMin = 1f;
    public float intervalMax = 2f;
    public float interval = 1f;
    public float radiusOuter = 200f;
    public float radiusInner = 0f;
    public float centerOffsetY = 0f;
}

public class StgWaveTemplate
{
    public string templateId = "";
    public string templateName = "";
    public string enemyType = "";
    public int count = 1;

    public string formationType = "single";
    public float formationSpacing = 0f;
    public float formationRowDelay = 0f;

    public string entryPathType = "from_top_straight";
    public float entryPathSpeed = 200f;
    public float entryPathAmplitude = 0f;

    public string behaviorType = "straight_down";
    public float behaviorFireInterval = 2.0f;
    public string behaviorBulletType = "";

    public int hp = 100;
    public int score = 100;
    public string dropTableId = "";
}

public class StgBossConfig
{
    public string bossId = "";
    public string bossName = "";
    public string prefabPath = "";
    public string entryAnimation = "fly_in_from_top";
    public int totalHp = 5000;
    public int score = 5000;
    public List<StgBossPhase> phases = new List<StgBossPhase>();
    public List<StgDropFixedEntry> dropOnDeath = new List<StgDropFixedEntry>();
    public string onDefeatEvent = "";
}

public class StgBossPhase
{
    public int phaseId = 1;
    public float hpThreshold = 1.0f;
    public string movePattern = "horizontal_patrol";
    public List<StgBossSkill> skills = new List<StgBossSkill>();
}

// skillId 决定哪些扩展字段生效，参照 Docs/STG 关卡生成工具设计.md 3.2 节技能类型枚举表
public class StgBossSkill
{
    public string skillId = "spread_shot";
    public float interval = 2.0f;
    public int bulletCount = 5;
    public float spreadAngle = 60f;
    public float duration = 0f;
    public float width = 0f;
    public int rings = 0;
    public string waveTemplateId = "";
    public int count = 0;
    public float speed = 0f;
    public float damageReduction = 0f;
}

public class StgDropFixedEntry
{
    public string itemId = "";
    public int count = 1;
}

// type == "digital_gate" 时使用 gateType/paraTable 等字段，移植自内部旧版 barrel 项目，尚未逐行核对源码
public class StgTrapConfig
{
    public string trapId = "";
    public string trapName = "";
    public string type = "static_obstacle";
    public string prefabPath = "";
    public float positionX = 0f;
    public float positionY = 0f;
    public int hp = 9999;
    public bool destroyable = false;
    public string dropTableId = "";

    // params 专属字段，按 type 动态取用（见 TrapConfigPanel 的类型->字段映射表）
    public float paramDamage = 0f;
    public bool paramDestroyOnContact = false;
    public int paramCount = 0;
    public float paramSpreadRadius = 0f;
    public float paramFireInterval = 0f;
    public string paramBulletType = "";
    public float paramRotateSpeed = 0f;
    public float paramOnDuration = 0f;
    public float paramOffDuration = 0f;
    public string paramInitialState = "on";
    public float paramWidth = 0f;
    public string paramPathType = "";
    public float paramSpeed = 0f;
    public float paramSlowFactor = 0f;
    public float paramRadius = 0f;
    public float paramDuration = 0f;

    // digital_gate 专属
    public string gateType = "gate_step"; // gate_step / gate_counter / gate_duet
    public string paraTable = "";
    public string paraTableRight = "";
    public int initialValue = 0;
    public string effectTableRef = "";
    public bool isReusableGateTemplate = false; // 供③时间轴 drop_digital_gate 事件引用
}

public class StgTimeline
{
    public float duration = 60f;
    public List<StgTimelineEvent> events = new List<StgTimelineEvent>();
}

// 不同 type 使用不同字段子集，具体映射见 TimelineEditorPanel
public class StgTimelineEvent
{
    public float time = 0f;
    public string type = "spawn_enemy_wave";

    public string templateId = "";
    public float offsetX = 0f;

    public string bossId = "";

    public string trapId = "";
    public float positionX = 0f;
    public float positionY = 0f;

    public string spawnAreaId = "";
    public float startTime = 0f;
    public float endTime = 0f;

    public string itemId = "";
    public string pattern = "single";
    public int count = 1;
    public float spacing = 0f;

    public float speed = 0f;

    public string text = "";
    public float duration = 0f;

    public string bgmId = "";
    public float fadeDuration = 0f;

    public string cutsceneId = "";

    // drop_digital_gate 专属
    public string gateType = "";
    public float dropIntervalSec = 0.1f;
    public float offsetXMin = 0f;
    public float offsetXMax = 0f;
    public float offsetYMin = 0f;
    public float offsetYMax = 0f;
    public float dropAniDuration = 0.5f;
}
