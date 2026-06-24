using System.Collections.Generic;
using UnityEngine;

public static class GameDefines
{
    public const string DefaultDialog = "Assets/Main/DataTable/Localization/English/Dictionaries/Dialog.txt";
    
    public const int QualityLevel_Off = 0;
    public const int QualityLevel_Low = 1;
    public const int QualityLevel_Middle = 2;
    public const int QualityLevel_High = 3;
    
    public const string GrayMaterialName = "SpriteGray";
    public const float LookAtFocusTime =  0.4f;
    
    // public static List<BuildConnectRoadDirection> BuildConnectList = new List<BuildConnectRoadDirection>()
    // {
    //     BuildConnectRoadDirection.Down,
    //     BuildConnectRoadDirection.Left,
    //     BuildConnectRoadDirection.Right,
    //     BuildConnectRoadDirection.Top,
    // };
    // public static List<DirectionType> ConnectDirList = new List<DirectionType>()
    // {
    //     DirectionType.Down,
    //     DirectionType.Left,
    //     DirectionType.Right,
    //     DirectionType.Top,
    // };
    public const int Int32Bit = 32;
    public const int ByteSize = 8;

    public class EntityAssets
    {
        public const string Building = "Assets/Main/Prefabs/Building/{0}.prefab";
        public const string AllianceBuilding = "Assets/Main/Prefabs/AllianceBuilding/{0}.prefab";
        public const string WorldRoadRobot = "Assets/Main/Prefabs/World/WorldRoadRobot.prefab";
        public const string WorldBuildingRobot = "Assets/Main/Prefabs/World/WorldBuildingRobot.prefab";
        public const string TouchTerrainEffect = "Assets/Main/Prefabs/World/TouchTerrainEffect.prefab";
        public const string HexTouchEffect = "Assets/Main/Prefabs/World/HexTouchEffect.prefab";
        public const string WorldCityGrass = "Assets/Main/Prefabs/World/WorldCityGrass.prefab";
        public const string BatteryAttackRange = "Assets/_Art/Effect/prefab/scene/Build/V_paota_fanwei.prefab"; //炮台攻击范围特效
        public const string QuanEffectRange = "Assets/Main/Prefabs/BuildEffect/V_zdbx_quan.prefab"; //炮台攻击范围特效
        public const string LandLock = "Assets/_Art/Models/Environment/Interactive/Massif/prefab/{0}"; // 解锁地块

        //世界
        public const string World = "Assets/Main/Prefabs/World/Scene_World.prefab";
        public const string City = "Assets/Main/Prefabs/World/Scene_City.prefab";
        // public const string Wasteland_City = "Assets/Main/Prefabs/World/Scene_City2.prefab";
        // public const string Wasteland_City_Dig = "Assets/Main/Prefabs/World/Scene_City_Dig.prefab";
        public const string WorldSceneDesc = "Assets/Main/Scenes/WorldSceneDesc.bytes";
        public const string WorldSceneAllianceCityDesc = "Assets/Main/Scenes/WorldSceneAllianceCityDesc.bytes";
        public const string LandLockDesc = "Assets/Main/Scenes/LandLockDesc.bytes";
        public const string WorldMapZone = "Assets/Main/Scenes/Zone/zone.bytes";
        // public const string WorldEdenMapZone = "Assets/Main/Scenes/EdenZone/zone.bytes";
        // public const string WorldEdenMapArea = "Assets/Main/Scenes/EdenZone/area.bytes";
        public static readonly Dictionary<int, string> WorldEdenMapArea = new Dictionary<int, string>()
        {
            {(int)SeasonPlayType.Eden1, "Assets/Main/Scenes/SeasonEdenZone/S5/area.bytes"},
            {(int)SeasonPlayType.Eden2, "Assets/Main/Scenes/SeasonEdenZone/S7/area.bytes"},
        };
        public static readonly Dictionary<int, string> WorldEdenMapZone = new Dictionary<int, string>()
        {
            {(int)SeasonPlayType.Eden1, "Assets/Main/Scenes/SeasonEdenZone/S5/zone.bytes"},
            {(int)SeasonPlayType.Eden2, "Assets/Main/Scenes/SeasonEdenZone/S7/zone.bytes"},
        };
        public static readonly Dictionary<int, string> WorldEdenSceneDesc = new Dictionary<int, string>()
        {
            {(int)SeasonPlayType.Eden1, "Assets/Main/Scenes/MapData/WorldEdenSceneDescS5.bytes"},
            {(int)SeasonPlayType.Eden2, "Assets/Main/Scenes/MapData/WorldEdenSceneDescS7.bytes"},
        };
        public const string Terrain_World0_Low = "Assets/Main/Prefabs/World/Terrain_0.prefab";
        public const string Terrain_World0_High = "Assets/Main/Prefabs/World/Terrain_0_High.prefab";
        // public const string TerrainSetting_Low = "Assets/Main/Prefabs/World/TerrainSetting_Low.asset";
        // public const string TerrainSetting_High = "Assets/Main/Prefabs/World/TerrainSetting_High.asset";
        // public const string Terrain_City_Low = "Assets/Main/Prefabs/World/Terrain_City.prefab";
        // public const string Terrain_City_High = "Assets/Main/Prefabs/World/Terrain_City_High.prefab";
        // public const string TerrainSetting_City_Low = "Assets/Main/Prefabs/World/TerrainSetting_City_Low.asset";
        // public const string TerrainSetting_City_High = "Assets/Main/Prefabs/World/TerrainSetting_City_High.asset";
        public const string TroopLine = "Assets/Main/Prefabs/March/TroopLine.prefab";
        public const string TroopDestinationSignal = "Assets/Main/Prefabs/March/TroopDestinationSignal.prefab";
        public const string TroopLineDrag = "Assets/Main/Prefabs/March/TroopLineDrag.prefab";
        public const string WorldTroop = "Assets/Main/Prefabs/March/WorldTroop.prefab";
        public const string MonsterActBoss = "Assets/Main/Prefabs/Monsters/MonsterActBoss.prefab";
        public const string WorldTroopAlliance = "Assets/Main/Prefabs/March/WorldTroopAlliance.prefab";
        public const string WorldTroopOther = "Assets/Main/Prefabs/March/WorldTroopOther.prefab";
        public const string WorldVirtualTroop = "Assets/Main/Prefabs/March/WorldVirtualTroop.prefab";
        public const string ScoutTroop = "Assets/Main/Prefabs/March/WorldRallyTroop.prefab";
        public const string ResTransTroop = "Assets/Main/Prefabs/March/WorldTroop.prefab";
        public const string GolloesExploreTroop = "Assets/Main/Prefabs/March/GolloesExploreTroop.prefab";
        public const string GolloesTradeTroop = "Assets/Main/Prefabs/March/WorldTroopScout.prefab";
        public const string WorldRallyTroop = "Assets/Main/Prefabs/March/WorldTroop.prefab";
        public const string FieldMonster = "Assets/Main/Prefabs/Monsters/FieldMonster.prefab";
        public const string FieldBoss = "Assets/Main/Prefabs/Monsters/FieldBoss.prefab";
        public const string ConstructMaterial = "Assets/Main/Material/building_construct.mat";

        public const string MonsterPath = "Assets/Main/Prefabs/Monsters/{0}.prefab";
        public const string BuildBlock = "Assets/Main/Prefabs/Building/BuildBlock.prefab";
        public const string WorldTroopSoldier = "Assets/Main/Prefabs/March/WorldTroopSoldier.prefab";
        public const string WorldTroopTank = "Assets/Main/Prefabs/March/WorldTroopTank.prefab";
        public const string WorldTroopPlane = "Assets/Main/Prefabs/March/WorldTroopPlane.prefab";
        public const string WorldTroopJunkman = "Assets/Main/Prefabs/March/WorldTroopJunkman.prefab";
        public const string CollectAnimalModel = "Assets/Main/Prefabs/CollectResource/CollectAnimalModel.prefab";
        public const string CollectArmyAnimalModel = "Assets/Main/Prefabs/CollectResource/CollectArmyAnimalModel.prefab";
        public const string CollectArmyAnimalModelAlliance = "Assets/Main/Prefabs/CollectResource/CollectArmyAnimalModelAlliance.prefab";
        public const string CollectArmyAnimalModelEnemy = "Assets/Main/Prefabs/CollectResource/CollectArmyAnimalModelEnemy.prefab";
        public const string BuildMetalFew = "Assets/Main/Prefabs/Building/BuildMetalFew.prefab";
        public const string BuildMetalMiddle = "Assets/Main/Prefabs/Building/BuildMetalMiddle.prefab";
        public const string BuildMetalMax = "Assets/Main/Prefabs/Building/BuildMetalMax.prefab";
        public const string BuildWoodFew = "Assets/Main/Prefabs/Building/BuildWoodFew.prefab";
        public const string BuildWoodMiddle = "Assets/Main/Prefabs/Building/BuildWoodMiddle.prefab";
        public const string BuildWoodMax = "Assets/Main/Prefabs/Building/BuildWoodMax.prefab";
        public const string DetectEventUI = "Assets/Main/Prefabs/March/WorldDetectInfo.prefab";
        public const string CityGarbagePath = "Assets/Main/Prefabs/Garbage/{0}.prefab";
        public const string CityTroop = "Assets/Main/Prefabs/March/CityTroop.prefab";
        public const string CollectGarbageUI = "Assets/Main/Prefabs/March/CollectGarbageUI.prefab";
        public const string CityWorkMan = "Assets/Main/Prefabs/CityScene/CityWorkMan.prefab";
        public const string FogPath = "Assets/Main/Prefabs/FogOfWar/{0}.prefab";
        public const string CityCameraSand = "Assets/Main/Prefabs/CityScene/CityCameraSand.prefab";
        public const string WorldCityTreeHigh = "Assets/Main/Prefabs/World/WorldCityTreeHigh{0}.prefab";
        public const string WorldCityTree = "Assets/Main/Prefabs/World/WorldCityTree{0}.prefab";
        public const string FocusCurve = "Assets/Main/Prefabs/CityScene/FocusCurve{0}.prefab";

        public const string LandLockFadeOut = "Assets/Main/Prefabs/World/LandLockFadeOut.prefab";
        public const string AllianceBossModel = "Assets/Main/Prefabs/Monsters/AllianceBoss.prefab";
        
        public const string normalWordPath = "Assets/Main/Prefabs/UI/BattleWord/BattleNormalBloodTip.prefab";
    }

    public class UIAssets
    {
        public const string ProfileGraphy = "Assets/Main/Prefabs/Debug_Graphy/Graphy.prefab";
        public const string GFXConsole = "Assets/Main/Prefabs/Debug_Graphy/GFXConsole.prefab";
    }

    public class SettingKeys
    {
        public const string LAST_SERVER_KEY = "DEBUG_LAST_SERVERID";

        /// 系统相关
        public const string GAME_UID = "Setting.GAME_UID";                                      // 用户id（使用这个）
        public const string GM_FLAG = "Setting.GM_FLAG";
        public const string UUID = "Setting.UUID";                                              // 用户uuid
        public const string DEVICE_ID = "DEVICE_ID";                                            // 设备保存ID，真机测试用
        public const string SERVER_IP = "SERVER_IP";
        public const string SERVER_PORT = "SERVER_PORT";
        public const string SERVER_ZONE = "SERVER_ZONE";
        
        public const string USER_LANGUAGE = "Setting.USER_LANGUAGE";                           //用户自定义语言
        public const string RESOURCE_LOGGER = "Setting.Resource.Logger";
        public const string SCENE_GRAPHIC_LEVEL = "SCENE_GRAPHIC_LEVEL";
        public const string CITY_TROOP_POSITION = "CITY_TROOP_POSITION";

    }

    // public class SoundAssets
    // {
    //     public const string Music_Effect_Message = "effect_message"; //战斗胜利
    //     public const string Music_Effect_Attack = "effect_attack"; //攻击
    //     public const string Music_Effect_Skill_Attack = "effect_skill";//技能攻击
    // }

    public class BuildingTypes
    {
        public const int FUN_BUILD_MAIN = 400000; // 基地 总部大楼 (限制其他建筑的等级上限，本身受玩家殖民等级限制，兵力上限)
        public const int FUN_BUILD_BUSINESS_CENTER = 401000; // 商业中心 (提供居民订单列表入口、钻石商店、同盟援助商队)
        public const int FUN_BUILD_STABLE = 402000; // 联合太空中心 (援助盟友，链接侦察卫星（科技解锁相关数值）)
        public const int FUN_BUILD_SCIENE = 403000; // 科研中心 (研究科技)
        public const int FUN_BUILD_SMITHY = 407000; // 联合指挥中心 (集结兵力)
        public const int FUN_BUILD_CONDOMINIUM = 409000; // 公寓 (提供工人数量、居民（工人）订单气泡)
        public const int FUN_BUILD_HOSPITAL = 411000; // 维修站 (维修武器)
        public const int FUN_BUILD_STONE = 412000; // 采矿场 (采集面板资源矿)
        public const int FUN_BUILD_OIL = 413000; // 油井 (采集面板资源原油)
        public const int FUN_BUILD_ARROW_TOWER = 418000; // 炮台 (防御物)
        public const int FUN_BUILD_CAR_BARRACK = 423000;//车辆制造厂 (生产车辆类的武器) 
        public const int FUN_BUILD_INFANTRY_BARRACK = 424000;//轻武器工厂 (生产步兵类的武器) 
        public const int FUN_BUILD_AIRCRAFT_BARRACK = 425000;//飞机制造厂 (生产飞行类的武器) 
        public const int FUN_BUILD_TRAINFIELD_1 = 427000; //兵营1
        public const int FUN_BUILD_TRAINFIELD_2 = 793000; //兵营2
        public const int FUN_BUILD_TRAINFIELD_3 = 794000; //兵营3
        public const int FUN_BUILD_TRAINFIELD_4 = 795000; //兵营4
        public const int FUN_BUILD_WATER = 432000;//抽水站 (采集面板资源水)
        public const int FUN_BUILD_MARKET = 435000;//火箭发射场 交易中心 (火箭发射点，贸易，更换火箭皮肤)
        public const int FUN_BUILD_ROAD = 436000;//路 (由于火星地面土质较松、需要一种特殊的路)
        public const int FUN_BUILD_ELECTRICITY_STORAGE = 437000;//蓄电站 (储存电，通过科技解锁生产高能电池)
        public const int FUN_BUILD_WATER_STORAGE = 438000;//蓄水罐 (存放水)
        public const int FUN_BUILD_OIL_STORAGE = 439000;//储油罐 (储存原油)
        public const int FUN_BUILD_IRON_STORAGE = 441000;//矿石仓库 (储存矿石)
        public const int FUN_BUILD_WIND_TURBINE = 444000;//风力电站 (全天工作，初级电站，风沙时产量提升)
        public const int FUN_BUILD_SOLAR_POWER_STATION = 447000; // 太阳能发电站 (在白天工作，初级电站)
        public const int FUN_BUILD_DRONE = 477000; // 无人机平台 (提供建造队列)
        
        public const int FUN_BUILD_VILLA = 700000; // 别墅 (提升工程师数量，提升居民订单所需物品数量)
        public const int APS_BUILD_FARM = 701000;//火星农场 (消耗水种植各种植物给居民订单，通过科技解锁植物种类)
        public const int APS_BUILD_FARM_FIELD = 702000;//火星农场的农田 (消耗水种植各种植物给居民订单，通过科技解锁植物种类)
        public const int APS_BUILD_PASTURE = 703000; // 火星牧场 (消耗作物养殖各种动物，通过科技解锁动物种类)
        public const int APS_BUILD_PASTURE_FIELD = 704000; // 火星牧场的牧场 (消耗作物养殖各种动物，通过科技解锁动物种类)
        public const int FUN_BUILD_OXYGEN = 705000; // 制氧站 (消耗水生产氧气供给居民订单)
        public const int FUN_BUILD_METALLURGY = 706000; // 冶金厂 (消耗矿石生产各种金属，通过科技解锁多种矿类产品)
        public const int FUN_BUILD_FOOD = 707000; // 食品厂 (消耗动植物加工二级产品，科技解锁高级配方)
        public const int FUN_BUILD_OIL_REFINERY = 708000; // 炼油厂 (分馏原油获得各种油，通过科技解锁多种化工产品)
        public const int FUN_BUILD_INTEGRATED_FACTORY = 709000; // 综合工厂 (生产工业类二级产品，通过科技解锁产物种类)
        public const int FUN_BUILD_TRADING_CENTER = 710000; // 贸易中心 (地球火箭停靠点，提供地球订单、黑市商人)
        public const int FUN_BUILD_FOODSHOP = 711000; // 餐厅 (生产食品类的三级产物，提供居民订单)
        public const int FUN_BUILD_PRINT_FACTORY = 712000; // 3D打印厂 (生产工业类的三级产物，提供地球订单和贸易)
        public const int FUN_BUILD_INFORMATION_CENTER = 713000; // 信息中心 (新闻玩法、服务器大事、纪念碑)
        public const int FUN_BUILD_COLD_STORAGE = 714000; // 冷库 (冷库、用来放置水果果蔬等需要保鲜的产品)
        public const int FUN_BUILD_COMPREHENSIVE_STORAGE = 715000; // 综合仓库 (大型物流仓库可以放置各种商品)
        public const int FUN_BUILD_DEFENCE_CENTER = 716000; // 备战中心
        public const int FUN_BUILD_DOME= 449000; // 苍穹
            
        
        public const int FUN_BUILD_FORGE = 429000; //装备制造//配件工厂
        public const int FUN_BUILD_ELECTRICITY = 431000; //发电厂
        public const int FUN_BUILD_RECHARGE_GARAGE = 445000; // 充值获得的车库
        public const int FUN_BUILD_HONOR_HALL = 446000;// 荣誉大厅
        public const int FUN_BUILD_BUILDING_CENTER = 448000; // 建造中心
        public const int FUN_BUILD_OFFICER = 483000;// 英雄大厅
       
        public const int APS_BUILD_PASTURE_OSTRICH = 719000;//鸵鸟农场
        public const int APS_BUILD_PASTURE_CATTLE = 720000;//奶牛农场
        public const int APS_BUILD_PASTURE_SANDWORM = 721000;//沙虫农场

        public const int APS_BUILD_WORMHOLE_MAIN = 791000;//虫洞-主
        public const int APS_BUILD_WORMHOLE_SUB = 792000;//虫洞-副
        public const int WORM_HOLE_CROSS = 735000; //跨服虫洞
        public const int FUN_BUILD_RADAR_CENTER = 417000; // 雷达
        public const int FUN_BUILD_TEMP_WIND_POWER_PLANT = 796000;//新手引导风力电站
        public const int FUN_BUILD_OUT_WOOD = 736000;//伐木场(生产资源道具)
        public const int FUN_BUILD_OUT_STONE = 737000;//(生产资源道具)


        public const int EDEN_WORM_HOLE_1 = 757000;//--伊甸园虫洞1 
        public const int EDEN_WORM_HOLE_2 = 758000;//--伊甸园虫洞2 
        public const int EDEN_WORM_HOLE_3 = 759000; //--伊甸园虫洞3
        
    }

    // 表名称
    public class TableName
    {
        public const string APSMonster = "APS_monster";     // 野战怪物
        public const string APSHeros = "aps_new_heroes";
        public const string GuideTab = "guide";                 // 引导配置表
        public const string PlotTab = "plot";                   // 剧情配置表
        public const string FieldMonster = "field_monster";     // 野战怪物
        public const string HeroTab = "new_heroes";             // 英雄
        public const string GoodsTab = "goods";                 // 物品
        public const string SkillTab = "skill";                 // 技能
        public const string BattleAnimation = "battle_animation";             // 战斗性效果
        public const string StatusTab = "status";
        public const string EquipRandomEffect = "equip_random_effect";        // 装备效果
        public const string AllianceGift = "alliance_gift";     // 联盟礼包
        public const string AllianceGiftGroup = "alliance_gift_group";
        public const string AllianceItemWarehouse = "alliance_item_warehouse"; // 联盟中心原材料
        public const string Territory = "territory";            // 联盟领地
        public const string TerritoryEffect = "territory_effect";            // 联盟领地
        public const string GoldrushBuilding = "goldrush_building";
        public const string ServerPos = "serverpos";//服务器世界联通
        public const string SiegeNPC = "siegeNPC";//NPC
        public const string Diary = "diary";//diary Diary_Xml 末日笔记
        public const string ActivityShow = "activity_show";//activity_show 活动数据
        public const string RightsEffectLevel = "rights_effect_level";//特权权益等级
        public const string RightsEffect = "rights_effect";//特权权益
        public const string VipStoreUnlock = "vip_store_unlock";//vip商店解锁
        public const string VipDetails = "vipdetails";//vip详情
        public const string WorldSeason = "world_season";  // 末日争霸-英雄预览
        public const string WorldBuilding = "building_world"; // 世界建筑
        public const string DesertTalent = "DesertTalent_DesertTalent";    // 专精
        public const string TalentShading = "DesertTalent_Shading";  // 专精
        public const string TalentHome = "talentHome";        // 专精类型
        public const string DesertGoldmineWar = "DesertGoldmineWar";
        public const string DesertTalentStats = "DesertTalentStats";    // 专精统计
        public const string Decompose = "decompose";                    // 加工厂原材料
        public const string Missile = "missile";//activity_panel 活动面板数据
        public const string LoadingTips = "loadingTips";//loading时的文字描述
        public const string Mail_ChannelID = "Mail_ChannelID"; //邮件列表排序
        public const string PlayerCareerXml = "player_career";//职业的配置表
        public const string QuestXml = "quest";//任务队列表
        public const string DesertSkillXml = "desertSkill";
        public const string GuideStep = "guide_step_GuideStep";
        public const string GuideStepContentInfo = "guide_step_ContentInfo";
        public const string Office = "office";
        public const string DoomsDayNote = "doomsdaynote_doomsdaynote";
        public const string DD_Season_Group = "DD_season_group";
        public const string Building = "building";//建筑信息
        public const string Chapter = "chapter_1";//章节任务信息
        public const string EffectName = "APS_effect_name";//作用号表
        public const string Global = "APS_global";//全局表（替代现有item）
        public const string Talent = "APS_talent";//天赋表
        public const string ResourceItem = "aps_resource_item";//资源道具表
        public const string Farming = "aps_farming";//农场配方表
        public const string BaseExpansion = "aps_base_expansion";//苍穹连接点表
        public const string GatherResource = "aps_gather_resource";//时间资源点
        public const string WorldCity = "worldcity"; //世界城市表
        public const string CityJunk = "aps_singlemap_junk"; //主城垃圾
        public const string LandLock = "aps_landlock"; //地块解锁表
        public const string Item = "item";
        public const string Decoration = "decoration";
        public const string Desert = "desert";
    }

    public static class SpritePath
    {
        public const string HeroIconSmall = "Assets/Main/Sprites/HeroIconsSmall/";
        public const string UITitleTag = "Assets/Main/Sprites/UI/UITitleTag/";
    }

    public static class QualitySetting
    {
        public const string PostProcess_Bloom = "QualitySetting.PostProcess.Bloom";
        public const string PostProcess_ColorAdjustments = "QualitySetting.PostProcess.ColorAdjustments";
        public const string PostProcess_Vignette = "QualitySetting.PostProcess.Vignette";
        public const string PostProcess_Tonemapping = "QualitySetting.PostProcess.Tonemapping";
        public const string PostProcess_LiftGammaGain = "QualitySetting.PostProcess.LiftGammaGain";
        public const string PostProcess_DepthOfField = "QualitySetting.PostProcess.DepthOfField";
        public const string Resolution = "QualitySetting.Resolution";
        public const string FPS = "QualitySetting.FPS";
        public const string Terrain = "QualitySetting.Terrain";
    }

    //引导类型
    public static class GuideType
    {
    //     public const int None = 0;
    //     public const int ClickButton = 1;//点击按钮
    //     public const int ShowTalk = 2;//人物对话
    //     public const int ClickBuild = 3;//点击建筑
         public const int BuildPlace = 4;//建筑建造
    //     public const int BuildRoad = 5;//造路
    //     public const int PlantFarm = 6;//农场种植
    //     public const int GetFarm = 7;//农场收获
    //     public const int QueueBuild = 8;//跳转队列所在建筑
    //     public const int PlantAnimal = 9;//牧场饲养鸵鸟
    //     public const int Factory = 10;//加工厂加工
    //     public const int Bubble = 11;//气泡
    //     public const int CityGarbage = 12;//主城内垃圾点
    //     public const int GotoMoveBubble = 13;//点击垃圾点和迷雾弹出确认前往的气泡
    //     public const int OpenFog = 14;//迷雾
    //     public const int CityGarbageResultShow = 15;//捡垃圾结果展示引导
    //     public const int DragCityTroop = 16;//拖拽城市行军
    //     public const int PlayMovie = 17;//播放timeline剧情
    //     public const int WaitMovieComplete = 18;//等待timeline剧情播放结束
    //     public const int ClickQuest = 19;//点击任务
    //     public const int WaitPlaceBuilding = 20;//等待建筑放置
    //     public const int WaitTroopArrive = 21;//等待行军到达目标点
    //     public const int WaitGarbageTroopMoveLeft = 22;//等待行军到达目标点剩余距离
    //     public const int WaitCloseUI = 23;//等待UI关闭
    //     public const int ClickBuildFinishBox = 24;//点击建筑完成的箱子
    }

    // public static class CityLabelTextColor
    // {
    //     public static Color32 Green = new Color32(181,248,49,255);
    //     public static Color32 Blue = new Color32(84,196,242,255);
    //     public static Color32 White = new Color32(228,228,228,255);
    //     public static Color32 Yellow = new Color32(255,133,39,255);
    //     public static Color32 Red = new Color32(252,81,77,255);
    //     public static Color32 Purple = new Color32(167,108,240,255);
    // }
}

// public enum LodType
// {
//     None = 0,
//     Custom = 1,
//     MainSelf = 1001,
//     MainAlly = 1002,
//     MainOther = 1003,
//     WormHoleSelf = 1004,
//     WormHoleAlly = 1005,
//     WormHoleOther = 1006,
//     Monster = 2001,
//     Resource = 2002,
//     Explore = 2003,
//     Sample = 2004,
//     Garbage = 2005,
//     MonsterReward = 2006,
//     RadarPve = 2007,
//     WorldBoss = 2008,
//     TroopSelf = 3001,
//     TroopAlly = 3002,
//     TroopOther = 3003,
//     Ground = 4001,
//     Zone = 4002,
//     CityLabel = 5001,
//     WorldCity = 5002,
//     Desert = 5003,
//     WorldAllianceBuild = 5004,
//     WorldAllianceFlag = 5005,
//     NPCCity = 5006,
//     MainEnemy = 5007,
//     WormHoleEnemy = 5008,
//     
//     NpcCity = 5009,
// }

// public enum SkinType
// {
//     BASE_SKIN = 1, //基地皮肤
//     HEAD_SKIN = 2, //头像框
//     TITLE_NAME = 3, //称号
// }





