---
--- STG 运行时常量
--- 字段枚举与 Assets/Editor/STG/Data/StgLevelEditorModel.cs 保持一致
--- 编辑器改枚举时同步本文件，详见 Docs/STG/STG导出格式_运行时字段对照表.md
---@class StgConst
local Const = {}

--- 数字门类型（StgTrapConfig.gateType）
Const.GateType = {
    Step    = "gate_step",     -- 打门累计伤害升级（对齐 barrel UpgradeableGate）
    Counter = "gate_counter",  -- 计数区间门（对齐 barrel UpgradeableGate2）
    Duet    = "gate_duet",     -- 双生门（对齐 barrel UpgradeableDuetGate）
}

--- 机关类型（StgTrapConfig.type）
Const.TrapType = {
    StaticObstacle  = "static_obstacle",
    Turret          = "turret",
    LaserGate       = "laser_gate",
    Destructible    = "destructible",
    MovingObstacle  = "moving_obstacle",
    SlowField       = "slow_field",
    DigitalGate     = "digital_gate",
}

--- 时间轴事件类型（StgTimelineEvent.type）
Const.TimelineEventType = {
    SpawnEnemyWave     = "spawn_enemy_wave",
    SpawnBoss          = "spawn_boss",
    SpawnTrap          = "spawn_trap",
    SpawnAreaStart     = "spawn_area_start",
    SpawnAreaStop      = "spawn_area_stop",
    DropDigitalGate    = "drop_digital_gate",
    SpawnItem          = "spawn_item",
    ChangeScrollSpeed  = "change_scroll_speed",
    ShowBanner         = "show_banner",
    PlayBgm            = "play_bgm",
    PauseEnemySpawn    = "pause_enemy_spawn",
    ResumeEnemySpawn   = "resume_enemy_spawn",
    LevelComplete      = "level_complete",
    GameOver           = "game_over",
    TriggerCutscene    = "trigger_cutscene",
}

--- 触发效果类型（门/机关命中后执行，对齐 barrel TriggerEnum 思路）
--- 首期只实现飞机玩法实际用到的，后续按编辑器 effectTableRef 扩展
Const.TriggerType = {
    AddWingman     = 10,  -- para = 数量
    RemoveWingman  = 20,  -- para = 数量
    AddGold        = 30,  -- para = 数量
    MultiplyWingman= 40,  -- para = 倍率
}

--- 战斗阶段
Const.BattleStage = {
    None    = 0,
    Init    = 1,
    Load    = 2,
    Play    = 3,   -- 主玩法（时间轴驱动）
    Result  = 4,
}

--- 战斗结果
Const.BattleResult = {
    None  = 0,
    Win   = 1,
    Lose  = 2,
}

--- 资源路径约定
Const.LEVEL_JSON_DIR = "STG/Levels/"  -- Resources 下相对路径，文件名 = levelId .. ".json"

return Const
