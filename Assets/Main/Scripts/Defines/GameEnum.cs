using System;

public enum BuildingState
{
    None,//
    FindingPathState,//寻找路
    PrepareBuild,//准备阶段
    Building,//建设中--没用
    Upgrading,//升级中
    Idle,//等待状态
    Moving,//移动状态
    Producting,//生产
    WaitCollecting,//未用到
    //Healing,//医院治疗中
}

//这个资源类型和下面的类型对不上，10以后的会有问题，所以我写了一个映射，用来之间转换  by shimin 2019.3.21
public enum ResourceType
{
    None = -1,//默认值，只前端要用
    // 0 燃油
    //Oil=0,
    // 1 金属
    //Metal=1,
    // // 2 核燃料
    // Nuclear,
    // // 3 粮食
    // Food,
    // // 4 氧气
    // Oxygen,
    // // 5 贸易压力
    // Trade,
    // // 6 住房压力
    // House,
    // // 7 医疗压力
    // Hospital,
    // // 8 科技压力
    // Science,
    // // 9 建设压力
    // Build,
    // // 10 环境值
    // Environment,
    // 11 水
    Water =11,
    // 12 电
    Electricity =12,
    // // 13 人口
    // People,
    // 14 钞票
    Money=14,
    // 15钻石
    GOLD =15,
    // // 16受伤人口
    // WoundedPeople,
}

public enum ResourceItem 
{
    Wood = 10000,
    Stone = 10001,
}

//新队列状态
public enum NewQueueState
{
    Free,//空闲
    Prepare,//准备
    Work,//工作
    Finish//完成（状态为客户端倒计时结束但未向服务器发送队列消息的状态）
}

public enum GlobalShaderLod
{
    LOW =0,
    MIDDLE =1,
    HIGH =2
}

//世界行军目的类型
public enum MarchTargetType
{
    STATE,//驻守
    ATTACK_MONSTER,//攻击
    COLLECT,//采集
    BACK_HOME,//回城
    ATTACK_BUILDING, // 4 攻击玩家建筑
    ATTACK_ARMY, // 5 攻击玩家编队
    JOIN_RALLY, //6 参加集结
    RALLY_FOR_BOSS, //7 集结打怪
    RALLY_FOR_BUILDING, //8 集结打建筑
    RANDOM_MOVE, //9 野怪状态，随便走走
    ATTACK_ARMY_COLLECT, //10 打采集编队，打完了采集
    ATTACK_CITY, //11 攻击大本
    RALLY_FOR_CITY, //12 集结大本
    ASSISTANCE_BUILD, //13 援助建筑
    ASSISTANCE_CITY, //14 援助大本
    ATTACK_ROAD, //15 拆路
    GO_WORM_HOLE, // 16 进虫洞
    SCOUT_CITY,// 17 侦察城市
    SCOUT_BUILDING,// 18 侦察建筑
    SCOUT_ARMY_COLLECT,// 19 侦查部队
    EXPLORE,   //20小队探测
    SAMPLE,//21采样
    SCOUT_TROOP = 22,//侦查部队
    PICK_GARBAGE = 23,//捡垃圾
    RESOURCE_HELP = 24,//资源援助
    ATTACK_ALLIANCE_CITY,// 25 攻击联盟城市
    ASSISTANCE_ALLIANCE_CITY,// 26 防御联盟城市
    RALLY_FOR_ALLIANCE_CITY,// 27 集结攻打联盟城市
    SCOUT_ALLIANCE_CITY,//侦察建筑
    GOLLOES_EXPLORE,//29咕噜探索
    GOLLOES_TRADE,//30咕噜商队
    BUILD_WORM_HOLE, //31 建设虫洞
    TRANSPORT_ACT_BOSS, //32 传送活动boss
    DIRECT_ATTACK_ACT_BOSS,//33 直接攻击活动boss
    BUILD_ALLIANCE_BUILDING, // 34 建造联盟建筑
    COLLECT_ALLIANCE_BUILD_RESOURCE, // 35 采集联盟建筑资源
    CROSS_SERVER_WORM, // 36 跨服
    ATTACK_DESERT, //37 攻击地块
    ASSISTANCE_DESERT,//38 驻守地块
    SCOUT_DESERT,//39 侦察地块
    TRAIN_DESERT,//40 地块训练  Target
    DIRECT_ATTACK_CITY,//41奇袭大本
    ATTACK_ALLIANCE_BUILDING, // 42 攻击联盟建筑
    RALLY_ALLIANCE_BUILDING, // 43 集结联盟建筑
    SCOUT_ALLIANCE_BUILDING, // 44 侦察联盟建筑
    ASSISTANCE_ALLIANCE_BUILDING, // 45 援助联盟建筑
    DIRECT_ATTACK_NPC_CITY, //46 奇袭NPC城市
    ATTACK_NPC_CITY, // 47 攻击NPC城市
    RALLY_NPC_CITY, // 48 集结NPC城市
    SCOUT_NPC_CITY, // 49 侦察NPC城市
    RALLY_THRONE, // 50 集结王座
    RALLY_ASSISTANCE_THRONE, // 51 集结援助王座
    SCOUT_THRONE,// 52 侦察王座
    ATTACK_ALLIANCE_BOSS, //53 攻击联盟boss
    ATTACK_ACT_ALLIANCE_MINE,//54 攻击活动联盟矿
    RALLY_FOR_ACT_ALLIANCE_MINE,//55 集结攻击联盟活动矿F
    ASSISTANCE_COLLECT_ACT_ALLIANCE_MINE,//56 采集联盟活动矿
    SCOUT_ACT_ALLIANCE_MINE,//57 侦察联盟活动矿
    
    ATTACK_DRAGON_BUILDING, // 58 攻击战场建筑
    RALLY_DRAGON_BUILDING, // 59 集结战场建筑
    SCOUT_DRAGON_BUILDING, // 60 侦察战场建筑
    ASSISTANCE_DRAGON_BUILDING, // 61 援助战场建筑
    TAKE_SECRET_KEY, //62 获取战场密钥
    PICK_SECRET_KEY, //63 拾取战场密钥
    TRANSPORT_SECRET_KEY, //64 运送战场密钥
    TRIGGER_DRAGON_BUILDING,//65 攻击/援助战场建筑
    TRIGGER_CROSS_THRONE_BUILDING, // 66 攻击/援助王座建筑
    RALLY_CROSS_THRONE_BUILDING, // 67 集结王座建筑
    SCOUT_CROSS_THRONE_BUILDING, // 68 侦察王座建筑
    ASSISTANCE_CROSS_THRONE_BUILDING, // 69 援助王座建筑
}

public enum MarchStatus
{
    DEFAULT =-1,//初始状态
    STATION, // 0 驻军
    MOVING, // 1 行军中
    ATTACKING, // 2 攻击中
    COLLECTING, // 3 采集中
    BACK_HOME, // 4 到家
    CHASING, //5 追逐
    WAIT_RALLY, //6 等待集结中
    IN_TEAM, //7 在集结中
    ASSISTANCE, //8 在援助单位中
    IN_WORM_HOLE, //9 在虫洞中    
    SAMPLING,//10采样中
    PICKING,//11捡垃圾
    GOLLOES_EXPLORING,//12咕噜探索中//DEATH,//12 死亡
    BUILD_WORM_HOLE, //13 建设虫洞中
    DESTROY_WAIT, //14 等待拆除耐久
    BUILD_ALLIANCE_BUILDING, //15 建造联盟建筑中
    TRANSPORT_BACK_HOME, // 16 传送回家
    CROSS_SERVER, // 17 跨服虫洞中
    WAIT_THRONE, // 18 王座排队中
    COLLECTING_ASSISTANCE,//19 活动联盟矿专用，采集并在援助中
    WAIT_DRAGON_BUILD, // 20 等待巨龙建筑中
    WAIT_CROSS_THRONE, // 21 等待跨服王座建筑中
}
 
public enum NewMarchType
{
    DEFAULT =-1,//初始状态
    NORMAL, // 0 普通出征
    ASSEMBLY_MARCH, // 1 联盟出征
    MONSTER, // 2 怪物
    BOSS, // 3 BOSS
    SCOUT,//4 侦查
    EXPLORE,//5 探索
    RESOURCE_HELP,//6资源援助
    GOLLOES_EXPLORE,//7咕噜探索
    GOLLOES_TRADE,//8咕噜商队
    ACT_BOSS, //9 活动BOSS
    PUZZLE_BOSS, //10 拼图BOSS
    DIRECT_MOVE_MARCH, //11 非自由行军，不可操作
    CHALLENGE_BOSS,//12 挑战BOSS
    MONSTER_SIEGE,//13 黑骑士攻城
    ALLIANCE_BOSS, //14 联盟boss
}

public enum DamageType
{
    /**
        * 0 默认
        */
    DEFAULT,
    /**
     * 1 普通攻击
     */
    ATTACK,
    /**
     * 2 反击
     */
    COUNTER_ATTACK,
    /**
     * 3 护盾攻击
     */
    SHIELD_ATTACK,
    /**
     * 4 护盾
     */
    SHIELD,
    /**
     * 5 恢复伤兵
     */
    RECOVER_DAMAGE,
    /**
     * 6 添加Buff
     */
    ADD_EFFECT,
    /**
     * 7 使用技能
     */
    USE_SKILL,
    /**
     * 8 怒气
     */
    ADD_ANGER,
    /**
 * 9 根据攻击目标个数增加怒气
 */
    ADD_ANGER_BY_TARGET_NUM,
    /**
 * 10 反击到护盾攻击
 */
    SHIELD_COUNTER_ATTACK,

}
public enum CombatUnitType
{
    /**
     * 0 默认
     */
    DEFAULT,
    /**
     * 1 编队
     */
    ARMY,
    /**
     * 2 普通建筑
     */
    BUILDING,
    /**
     * 3 箭塔
     */
    TOWER,
    /**
     * 4 怪物
     */
    MONSTER,
    /**
     * 5 集结编队
     */
    RALLY_TEAM,
    /**
     * 6 BOSS
     */
    BOSS,
    /**
     * 7 大本
     */
    CITY,
    /**
     * 8 路
     */
    ROAD,
    /**
     * 9 探索点
     */
    EXPLORE_POINT,
    /**
     * 10 联盟中立城
     */
    ALLIANCE_NEUTRAL_CITY,
    /**
     * 11 联盟占领城
     */
    ALLIANCE_OCCUPIED_CITY,
    /**
     * 12 冠军对决
     */
    ELITE,
    /**
     * 13 PVE玩家编队
     */
    PVE_MARCH,
    /**
     * 14 PVE怪物
     */
    PVE_MONSTER,
    /**
     * 15 活动boss
     */
    ACT_BOSS,
    /**
     * 16 活动boss
     */
    PUZZLE_BOSS,
    /**
    * 17  挑战BOSS
    */
    CHALLENGE_BOSS,
    /**
    * 18  地块
    */
    Desert,
    /**
 * 19 训练地块
 */
    TRAIN_DESERT,
    /**
 * 20 联盟建筑
 */
    ALLIANCE_BUILDING,
    /**
 * 21 NPC城
 */
    NPC_CITY,
    /**
    * 22 联盟城守备军
    */
    ALLIANCE_CITY_GUARD,
    /**
 * 23 玩家大本守备军
 */
    CITY_GUARD,
    /**
 * 24 联盟建筑守备军
 */
    ALLIANCE_BUILD_GUARD,
    /**
 * 25 NPC城市守备军
 */
    NPC_CITY_GUARD,
    
    // 26 黑骑士
    MONSTER_SIEGE,
    //27 王座军队
    THRONE_ARMY,
    // 28 跨服虫洞
    CROSS_WORM,

    // 30 联盟boss
    ALLIANCE_BOSS = 30,
    /**
     * 31 陷阱
     */
    CITY_TRAP,
    /**
     * 32 活动联盟矿
     */
    ACT_ALLIANCE_MINE,
    
    DRAGON_BUILDING, // 33 巨龙建筑
    
    CROSS_THRONE,//34 跨服王座建筑
    CROSS_THRONE_MONSTER,//35 跨服王座怪物
}

public enum APSSpecialUnitType
{
    // 0 无
    NONE,

    // 1 联盟城NPC怪物
    ALLIANCE_CITY_NPC,

    // 2 建筑守军
    BUILDING_STATION,

    // 3 城市守军
    CITY_STATION,

    // 4 集结队长
    TEAM_LEADER,

    // 5 集结成员
    TEAM_MEMBER,

    // 6 PVE行军
    PVE_MARCH,

    // 7 PVE怪物
    PVE_MONSTER,

    // 8 活动BOSS
    ACT_BOSS,

    // 9 竞技场NPC
    ARENA_NPC,

    // 10 拼图BOSS
    PUZZLE_BOSS,

    // 11 挑战BOSS
    CHALLENGE_BOSS,

    // 12 地块NPC
    DESERT_NPC,

    // 13 联盟城警备队
    ALLIANCE_CITY_POLICE_NPC,
    // 14 联盟建筑警备队
    ALLIANCE_BUILD_POLICE_NPC,
// 15 大本守军
    CITY_POLICE_NPC,
    // 16 跨服虫洞守军
    CROSS_WORM_STATION,
    // 17 黑骑士
    MONSTER_SIEGE,
    // 18 炮塔
    TOWER,
    // 19 联盟Boss
    ALLIANCE_BOSS,
    // 20 陷阱
    TRAP,
    // 21 活动联盟矿守军
    ACT_ALLIANCE_MINE_GUARD,

}

public enum HeroSkillType
{
    //0 默认
    DEFAULT = 0,

    //1 全局生效技能
    GLOBAL_SKILL = 1,

    //2 编队中生效技能
    FORMATION_SKILL = 2,

    //3 机器人生效技能
    ROBOT_SKILL = 3,

    //10 普通攻击
    NORMAL_SKILL = 10,

    //11 怒气攻击(主动技能)
    RAGE_SKILL = 11,

    //12 进入战斗释放技能
    START_BATTLE_SKILL = 12,

    //13 特定英雄加成技能
    SPECIAL_HERO_ADD_SKILL = 13,

    //14 子技能
    SUB_SKILL = 14,
}

public enum APSDamageEffectType {
    //0 默认
    DEFAULT = 0,
    //1 暴击
    CRIT= 1,
    //2 闪避
    MISS =2,
}

public enum ArmyBattleStatus
{
    NONE,//无状态
    START_BATTLE,//开始战斗
    BATTLEING,//战斗中
    END_BATTLE//结束战斗
}

public enum LookAtFocusState
{
    None = 0,//无聚焦
    FarmPlant = 1,//聚焦农场
    PlaceBuild = 2,//聚焦放置普通建筑
    EarthOrder = 3,//聚焦地球订单
    Dome = 4,//聚焦苍穹
    MoveCity = 5,//聚焦迁城
    Formation = 6,//聚焦出征
    BuildRoad = 7,//聚焦修路
}

public enum RewardType
{
    OIL = 0,//0
    METAL,//1
    NUCLEAR,//2
    FOOD,//3
    OXYGEN,//4
    TRADE,//5
    EXP,//6
    GOODS,//7
    GENERAL,//8
    POWER,//9
    HONOR,//10
    ALLIANCE_POINT,//11
    HOUSE,//12
    HOSPITAL,//13
    EQUIP,//14
    MATERIAL,//15
    PART,//16
    ITEM_EFFECT,//17
    BATTLE_HONOR,//18
    WATER,//19
    MONEY,//20
    ELECTRICITY,//21
    PEOPLE,//22
    ARM,//23
    MANOR,//24
    HERO,//25
    PTGOLD,//26
    RESOURCE_ITEM,//27
    PVE_POINT,//28
    DETECT_EVENT,//29
    FORMATION_STAMINA,//30
    WOOD,//31
    PVE_STAMINA,//32
    PVE_MONUMENT_TIME,//33
}

public enum WorldTileType
{
    OriginTile = 0 //0
    , CityTile//世界城市
    , CampTile//2 扎营地
    , ResourceTile// 3 资源
    , KingTile//// 4 遗迹
    , BattleTile// 5 塔
    , MonsterTile// 6 地宫
    , MonsterRange
    , CityRange// 8 玩家周边
    , FieldMonster // 9 野怪
    , Throne //王座
    , ThroneRange //王座周边
    , Trebuchet //投石机
    , TrebuchetRange //投石机周边
    , Tile_allianceArea //联盟主堡 14
    , ActBossTile// 15 活动怪物boss
    , Tile_allianceRange//领地周边16
    , ActBossTileRange
    , tile_superMine//18
    , tile_superMineRange//19
    , TERRITORY_BUILDING //20
    , title_Armory//21军械库
    , title_Prison//22监狱
    , title_Laboratory//23实验室
    , title_SuperMarket//24超市
    , tile_banner//联盟国旗25
    , tile_resBuilding//26
    , tile_disScout//27挖
    , tile_disOccupy//28
    , tile_siege//29征服岛建筑
    , tile_siegeRange//30征服岛周边
    , tile_Npc = 31//31
    , tile_NpcRange = 32//32
    , Tile_allianceSolder = 33 //联盟兵营
    , tile_wheelfight_building = 34 //34 车轮战建筑
    , tile_wheelfight_range = 35 // 车轮战建筑周边
    , Tile_kingdomMedal = 36 //大王座雕像
    , tile_desert_throne //沙漠里的王座
    , tile_desert_pyramid//
    , tile_build_city //副堡
    , tile_desert_goldrush = 41//淘金者营地
    , tile_desert_goldrush_range = 42//淘金者营地周边
    , tile_desert_gold_resource = 43/**43 沙漠金币矿*/
    , tile_desert_alliance_fight_space = 44/**44 沙漠争夺中的 地块标记*/
    , tile_build_corps = 45 //边境战基地
    , tile_build_corps_range = 46 //边境战基地周边
    , tile_NOT_COVERED_DOMAIN = 47 // 不可压的地块儿
    , tile_FIGHT_FOR_DOMAIN_MARK = 48 // 此地块儿被兵占着
    , tile_USER_WORLD_BUILDING = 49 // 玩家的世界建筑
    , tile_TERRITORY_ASSEMBLE = 53 // 联盟跨服集结点
    , tile_TERRITORY_ASSEMBLE_RANGE = 54 // 联盟跨服集结点周边
    , tile_city_ruins = 55 // 55 城市飞之后的废墟
    , tile_USER_WORLD_PRISON = 56 //56 世界监狱
    , tile_USER_WORLD_PRISON_RANGE = 57 //57 世界监狱周边
    , tile_ALLIANCE_WAR_FORTRESS = 61 //61驻军基地
    , tile_ALLIANCE_WAR_FORTRESS_RANGE = 62 //62驻军基地周边
    , tile_ALLIANCE_TEMPORARY_LAND = 63 //63临时地皮
    , tile_FBCareer_1 = 64 //职业
    , tile_FBCareer_2 = 65 //职业
    , tile_FBCareer_3 = 66 //职业
    , tile_FBCareer_4 = 67 //职业
    , tile_FBCareer_5 = 68 //职业
    , tile_FBCareer_6 = 69 //职业
    , tile_FBCareer_7 = 70 //职业
    , tile_FBCareer_8 = 71 //职业
    , tile_DOMAIN_CITY = 80 //中立城市
    , tile_DOMAIN_CITY_WALL = 81 //中立城市围墙
    , tile_MOVE_PLAY_CITY_MACHINE = 82 //迁城中的地表类型
        , tile_SnowMan = 105 //雪人BOSS
}
public enum PlayerType
{
    PlayerNone = -1, // 无
    PlayerSelf = 0, // 自己
    PlayerAlliance = 1, // 盟友
    PlayerOther = 2, // 敌人
    PlayerAllianceLeader = 3, // 盟主
};

public enum MainBuildOrder
{
    Other = 21, // 其他
    Enemy = 22, // 敌人
    Ally = 23, // 盟主
    Leader = 24, // 盟友
    Self = 25, // 自己
}

//detect_event和物品颜色的对应关系不一样
public enum DetectEventColor
{
    DETECT_EVENT_WHITE = 1,
    DETECT_EVENT_GREEN = 2,
    DETECT_EVENT_BLUE = 3 ,
    DETECT_EVENT_PURPLE = 4,
    DETECT_EVENT_ORANGE = 5,
    DETECT_EVENT_GOLDEN = 6,
}

// 服务器类型
public enum ServerType
{
    /**
 * 0:普通服
 */
    NORMAL,
    /**
 * 1:外网测试服
 */
    TEST,
    /**
 * 2:合服活动服务器
 */
    MERGE,
    /**
 * 3:大王座
 */
    KINGDOM,
    /**
 * 4:攻城略地服务器
 */
    SIEGESERVER,
    /**
 * 5:竞技场服务器
 */
    BATTLEFIELD,
    /**
 * 6:精英对决服务器
 */
    ELITE,
    /**
 * 7;地块赛季服
 */
    WORLD_SEASON,
    /**8;极地战役服*/
    DRAGON_BATTLE_FIGHT_SERVER,
    /**9;伊甸园*/
    EDEN_SERVER,
    /**
     * 10;跨服王座
     */
    CROSS_THRONE,
}
//大本罩子尺寸
public enum DomeSize
{
    Small = 1,
    Middle = 2,
    Large = 3,
}

public enum GameEffect{
    //燃油每秒产量
    OIL_SPEED = 30000,
    //金属每秒产量
    METAL_SPEED = 30001,
    //核燃料每秒产量
    NUCLEAR_SPEED = 30002,
    //粮食每秒产量
    FOOD_SPEED = 30003,
    //水每秒产量
    WATER_SPEED = 30004,
    //氧气每秒产量
    OXYGEN_SPEED = 30005,
    //自然电每秒产量
    ELECTRICITY_SPEED = 30006,
    //油电每秒产量
    OIL_ELECTRICITY_SPEED = 30008,
    //核电每秒产量
    NUCLEAR_ELECTRICITY_SPEED = 30010,
    //人口上限增加
    PEOPLE_MAX = 30007,
    //医疗上限增加
    HOS_MAX = 30009,
    //贸易度上限增加(值)
    TRAD_MAX = 30011,
    //研发值增加(值)
    RD_ADD = 30013,
    //研发值增加(值)
    OPERA_ADD = 30014,
    //维护度上限(值)
    MAINTAIN_MAX_ADD = 30016,
    //建造值增加(值)
    BUILD_ADD = 30017,
    //环境值指数、每分钟对环境值进行加减值
    ENVIR_SPEED = 30020,
    //人口每分钟增长值(数值)
    PEOPLE_SPEED = 30021,
    //人口增长加成(千分比)1000=1
    PEOPLE_SPEED_PER = 30022,
    //资金每秒增长(值)
    MONEY_SPEED = 30023,
    //资金增长加成(千分比)
    MONEY_SPEED_PER = 30024,
    //燃油上限
    OIL_MAX_LIMIT = 30030,
    //金属上限
    METAL_MAX_LIMIT = 30031,
    //核燃料上限
    NUCLEAR_MAX_LIMIT = 30032,
    //粮食上限
    FOOD_MAX_LIMIT = 30033,
    //水上限
    WATER_MAX_LIMIT = 30034,
    //氧气上限
    OXYGEN_MAX_LIMIT = 30035,
    //电上限
    ELECTRICITY_MAX_LIMIT = 30036,
    //电消耗
    ELECTRICITY_DEC = 30037,
    //核燃料消耗
    NUCLEAR_DEC = 30038,
    //燃油消耗
    OIL_DEC = 30039,
    //受伤人口恢复速度（分钟）
    PEOPLE_REC_SPEED = 30040,
    //冷库存储上线
    FREEZER_STORAGE_MAX_LIMIT = 30044,
    //综合仓库存储上线
    WAREHOUSE_STORAGE_MAX_LIMIT = 30045,
    //冷库保护上线  已经去掉
    //FREEZER_PROTECT_MAX_LIMIT = 30046,
    // 地球订单额外加成提升百分比
    EARTH_ORDER_EXTRA_MONEY_ADD_PERCENT = 30046,
    // 地球订单额外加成值百分比
    EARTH_ORDER_EXTRA_MONEY_ADD_VALUE = 30093,
    //综合仓库保护上线
    WAREHOUSE_PROTECT_MAX_LIMIT = 30047,
    
    WATER_CAPACITY_ADD = 30064,//30064	抽水站储量提升	储量=建筑para2*(1+【30064】/100)
    METAL_CAPACITY_ADD = 30065,//30065	水晶采集场储量提升	储量=建筑para2*(1+【30065】/100)
    GAS_CAPACITY_ADD = 30066,//30066	瓦斯收集器储量提升	储量=建筑para2*(1+【30066】/100)
    METALLURGY_FACTORY_OUT_SPEED_ADD = 30067,// 30067	冶金厂生产速度提升	生产时间=aps_factory.xml  time/（1+【30067】/100）
    CHEMISTRY_FACTORY_OUT_SPEED_ADD = 30068,// 30068	化学实验室生产速度提升	生产时间=aps_factory.xml  time/（1+【30068】/100）
    PRINT_FACTORY_OUT_SPEED_ADD = 30069,// 30069	3d打印厂生产速度提升	生产时间=aps_factory.xml  time/（1+【30069】/100）
    BUILD_SPEED_ADD = 30070,//30070	建造建筑速度	建筑建造时间=building.xml time/(1+【30070】/ 100)
    SCIENCE_SPEED_ADD = 30071,// 30071	科研速度	科研时间=science.xml time/(1+【30071】/ 100)
    WIND_ELECTRICITY_SPEED_ADD = 30072,// 风力发电站速度提升	速度=建筑para1*(1+【30072】/100)
    WIND_ELECTRICITY_CAPACITY_ADD = 30073,// 风力发电站储量提升	储量=建筑para2*(1+【30073】/100)
    HOTEL_MONEY_SPEED_ADD = 30074,// 公寓钞票产出速度提升	速度=建筑para1*(1+【30074】/100)
    HOUSE_MONEY_SPEED_ADD = 30075,// 别墅钞票产出速度提升	速度=建筑para1*(1+【30075】/100)
    METAL_SPEED_ADD = 30076,//水晶采集场速度提升	  速度=建筑para1*(1+【30076】/100)	
    SOLAR_ELECTRICITY_SPEED_ADD = 30077,//太阳能发电站速度提升	速度=建筑para1*(1+【30077】/100)
    RESOURCE_PROTECT_CAPACITY_ADD = 30078,//资源仓库保护上限提升	保护上限=基础值*(1+【30078】/100)
    BUILD_ROAD_NUM_ADD = 30079,//建造道路的数量提升		数量=基础值+【30079】
    FREEZER_STORAGE_ADD = 30080,//冷库上限提升	容量=【30044】+【30080】
    MONEY_SPEED_ADD = 30081,//钞票产出速度提升
    SOLAR_ELECTRICITY_CAPACITY_ADD = 30082,//太阳能发电站储量提升	储量=建筑para2*(1+【30082】/100)
    FIRE_ELECTRICITY_CAPACITY_ADD = 30083,//火力发电站储量提升	储量=建筑para2*(1+【30083】/100)
    FIRE_ELECTRICITY_SPEED_ADD = 30084,//火力发电站速度提升	速度=建筑para1*(1+【30084】/100)
    HOTEL_MONEY_CAPACITY_ADD = 30085,//公寓钞票储量提升	储量=建筑para2*(1+【30085】/100)
    HOUSE_MONEY_CAPACITY_ADD = 30086,//别墅钞票储量提升	储量=建筑para2*(1+【30086】/100)
    MONEY_CAPACITY_ADD = 30087,//钞票储量提升		公寓储量=建筑para2*(1+【30086】/100+【30084】/100)  别墅储量=建筑para2*(1+【30086】/100+【30085】/100)	
    GAS_BUILD_COLLECT_SPEED_ADD = 30091,//瓦斯收集器速度提升		百分比	速度=建筑para1*(1+【30091	】/100)	
    WATER_BUILD_COLLECT_SPEED_ADD = 30092,//抽水站速度提升		百分比	速度=建筑para1*(1+【30092	】/100)
    UNLOCK_WATER_GET= 30088,//解锁部队采集水
    UNLOCK_GAS_GET= 30089,//解锁部队采集瓦斯
    UNLOCK_METAL_GET= 30090,//解锁部队采集水晶
    
    ADD_FIELD_NUM = 30094, // 702000可建造农田数量加成
    ADD_CAN_BUILD_NUM = 30095, // 可建造建筑范围
    ADD_WATER_BUILD_NUM = 30096, // 432000可建造净水罐数量加成
    ADD_HOTEL_NUM = 30097, // 409000可建造公寓数量加成
    ADD_METAL_COLLECT_NUM = 30098, // 412000可建造水晶采集场数量加成
    TANK_TRAIN_SPEED_ADD = 31000,//31000	坦克训练速度提升	训练士兵时间=arms.xml time/（1+【31000】/100）
    ROBOT_TRAIN_SPEED_ADD = 31001,//31001	轻武器训练速度提升	训练士兵时间=arms.xml time/（1+【31001】/100）
    PLANE_TRAIN_SPEED_ADD = 31002,//31002	飞机训练速度提升	训练士兵时间=arms.xml time/（1+【31002】/100）
    TANK_TRAIN_NUM_ADD = 31003,//31003	坦克训练量提升	训练量=arms.xml max_train +【31003】
    ROBOT_TRAIN_NUM_ADD = 31004,//31004	轻武器训练量提升	训练量=arms.xml max_train +【31004】
    PLANE_TRAIN_NUM_ADD = 31005,//31005	飞机训练量提升	训练量=arms.xml max_train +【31005】
    DETECT_ARMY_SPEED = 31006,//侦察行军速度 行军速度=基础值*(1+【31006】/100)
    REPAIR_SPEED_ADD = 31007,//维修速度提升		维修速度=arms.xml treat_time/（1+【31007】/100）
    ARMY_TRAIN_SPEED_ADD = 31008,//部队训练速度提升	训练士兵时间=arms.xml time/（1+【31008】/100）
    ARMY_TRAIN_MAX_ADD = 31009,//部队训练上限提升	坦克训练量=arms.xml max_train +【31003】 +【31009】 轻武器训练量=arms.xml max_train +【31004】 +【31009】 飞机训练量=arms.xml max_train +【31005】 +【31009】）
    ATTACK_ADD_BASE_ALL_ARMY = 35000,//全体兵种基础攻击加成
    ATTACK_ADD_BASE_ARM_1= 35001,//兵种1基础攻击加成
    ATTACK_ADD_BASE_ARM_2= 35002,//兵种2基础攻击加成
    ATTACK_ADD_BASE_ARM_3= 35003,//兵种3基础攻击加成
    ATTACK_ADD_BUILD_ALL_ARMY = 35048,//驻守建筑前台兵种总攻击加成
    ATTACK_ADD_BUILD_ARM_1 = 35049,//驻守建筑前台兵种1攻击加成
    ATTACK_ADD_BUILD_ARM_2 = 35050,//驻守建筑前台兵种2攻击加成
    ATTACK_ADD_BUILD_ARM_3 = 35051,//驻守建筑前台兵种3攻击加成
    
    DEFENCE_ADD_BASE_ALL_ARMY = 35004,//全体兵种基础防守加成
    DEFENCE_ADD_BASE_ARM_1 = 35005,//兵种1基础防守加成
    DEFENCE_ADD_BASE_ARM_2= 35006,//兵种2基础防守加成
    DEFENCE_ADD_BASE_ARM_3= 35007,//兵种3基础防守加成
    DEFENCE_ADD_BUILD_ALL_ARMY = 35052,//驻守建筑前台兵种总防守加成
    DEFENCE_ADD_BUILD_ARM_1 = 35053,//驻守建筑前台兵种1防守加成
    DEFENCE_ADD_BUILD_ARM_2 = 35054,//驻守建筑前台兵种2防守加成
    DEFENCE_ADD_BUILD_ARM_3 = 35055,//驻守建筑前台兵种3防守加成
    ATTACK_MONSTER = 35056,//打怪攻击力
    DEFENCE_MONSTER = 35057,//打怪防御力
    GAS_COLLECT_SPEED = 30058,//瓦斯采集速度
    WATER_COLLECT_SPEED = 30059,//水源采集速度
    CRYSTAL_COLLECT_SPEED = 30060,//水晶采集速度
    WAR_ATTACK = 35064,//战斗伤害加成
    WAR_DEFENCE = 35065,//战斗防御加成
    
    APS_FORMATION_SIZE = 40001,
    APS_FORMATION_SIZE_ENHANCE = 40002,
    
    APS_DEFENCE_FORMATION_SIZE = 40003,//守城编队数量
    APS_DEFENCE_FORMATION_FIRST_HERO_COUNT = 40004,//守城第一编队可上阵英雄数量
    APS_DEFENCE_FORMATION_SECOND_HERO_COUNT = 40005,//守城第二编队可上阵英雄数量
    APS_DEFENCE_FORMATION_THIRD_HERO_COUNT = 40006,//守城第三编队可上阵英雄数量
    APS_DEFENCE_DOME_NUM = 40007,//防护罩耐久
    APS_DEFENCE_DOME_SPEED = 40008,//防护罩耐久回复速度
    ARMY_CARRY_WEIGHT_ADD_PERCENT = 40010, // 负重上线百分比
    SIEGE_DAMAGE_ADD_PERCENT = 40011, // 单兵攻城值增加百分比
    APS_ALLIANCE_TEAM_MAX_ARMY = 40014,// 最大集结上限
    

    APS_FORMATION_FIRST_HERO_COUNT = 40016,//第一编队可上阵英雄数量
    APS_FORMATION_SECOND_HERO_COUNT = 40017,//第二编队可上阵英雄数量
    APS_FORMATION_THIRD_HERO_COUNT = 40018,//第三编队可上阵英雄数量
    APS_FORMATION_FORTH_HERO_COUNT = 40019,//第四编队可上阵英雄数量
    ARMY_SPEED_ADD = 40020,//部队行军速度提升	行军速度=基础值*(1+【40020】/100)
    APS_SCOUT_FORMATION_SIZE = 40022,//侦查队列最大数量
    APS_NORMAL_FORMATION_1_ATK =40036, // 普通编队1攻击力提升
    APS_NORMAL_FORMATION_2_ATK = 40037, // 普通编队2攻击力提升
    APS_NORMAL_FORMATION_3_ATK = 40038, // 普通编队3攻击力提升
    APS_NORMAL_FORMATION_4_ATK = 40039, // 普通编队4攻击力提升
    APS_NORMAL_FORMATION_1_DEF = 40040, // 普通编队1防御力提升
    APS_NORMAL_FORMATION_2_DEF = 40041, // 普通编队2防御力提升
    APS_NORMAL_FORMATION_3_DEF = 40042, // 普通编队3防御力提升
    APS_NORMAL_FORMATION_4_DEF = 40043, // 普通编队4防御力提升
    APS_NORMAL_FORMATION_1_FORMATION_COUNT = 40044, // 普通编队1编队出征数量增加
    APS_NORMAL_FORMATION_2_FORMATION_COUNT = 40045, // 普通编队2编队出征数量增加
    APS_NORMAL_FORMATION_3_FORMATION_COUNT = 40046, // 普通编队3编队出征数量增加
    APS_NORMAL_FORMATION_4_FORMATION_COUNT = 40047, // 普通编队4编队出征数量增加
}

//放置建筑界面打开类型
public enum PlaceBuildType
{
    None = 0,
    Build = 1,
    Move = 2,
    Replace = 3,
    MoveCity = 4,
}
//点击世界类型
public enum ClickWorldType
{
    Ground = 0,
    Collider = 1,
}

public enum BoardState 
{
    NORMAL = 0, //0 正常状态
    Updating,   //1 升级状态
}
public enum PutState
{
    None,
    Ok,//可以放置
    Collect,//矿根
    CollectRange,//矿根周边
    OtherCollectRange,//其他矿根周边
    NoCollectRange,//没有矿根周边
    OutMyRange,//超出自己限制范围
    InOtherBaseRange,//在他人大本范围内
    StaticPoint,//静态点
    Building,//建筑
    Board,//基板
    OutUnlockRange,//不在已经锁范围内,解锁范围:({0},{1}) - ({2},{3})
    UnConnectBoard,//没有与自己基板相连
    WorldBoss,//世界Boss
    WorldMonster,//世界野怪
    CollectTimeOver,//矿跟正在销毁中
    OutMyInside,//不在苍穹内
    InMyInside,//不在苍穹外
    OutMainSubRange,//超出主建筑范围
    OnBaseExpansion,//在苍穹上
    OnWorldResource,//世界资源点
    OnlyBuildRoad,//该点只能铺设道路
    ReachBuildMax,//达到建造最大值
    OnExplore,//小队探索点
    OnSample,//小队采样点
    OnGarbage,//垃圾点
    GuideBuildRoad,//引导造路
    MONSTER_REWARD
}

public enum BuildingStateType
{
    /*普通*/
    Normal = 0,

    /*升级中*/
    Upgrading,

    /*收起*/
    FoldUp,
}

public enum BuildType
{
    Normal = 0, //一般建筑
    Main = 1,//主建筑
    Second = 2,//辅建筑
    Third = 3,//次建筑
}

public enum BuildTilesType
{
    One = 1,//1格
    Two = 2,//2格
    Three = 3,//3格
}

//建筑扫描动画
public enum BuildScanAnim
{

    No = 0,//没有飞行时间，不播放建筑扫描动画
    Play = 1,//有飞行时间，播放建筑扫描动画
    NoFly = 2,//没有飞行时间，播放建筑扫描动画
}

public enum CityPointType  
{
    Other = 0, // 空地
    Garbage = 1, // 垃圾
    Monster = 2, // 野怪
    MonsterReward = 3, // 野怪奖励箱子
    GarbageReward = 4, // 垃圾奖励箱子
    LandLockReward = 5, // 解锁地块奖励箱子

    Building = 100, // 建筑
    Road = 101, // 路
    Fog = 102, // 迷雾
    LandLock = 103, // 解锁地块
    Collect = 104, // 矿根
    CollectRange = 105, // 矿根周边
}

//运兵车预制体的类型
public enum MarchPrefabType
{
    Self = 1,//自己（绿色）
    Alliance = 2,//盟友（蓝色）
    Camp = 3,//同阵营（黄色）
    Other = 4,//敌人（红色）
}

public enum SeasonPlayType
{
    Default,    //联盟城赛季
    Desert,     //地块赛季
    Eden1,      //伊甸园赛季 二阵营版本
    Eden2,      //伊甸园赛季 四阵营版本
}





