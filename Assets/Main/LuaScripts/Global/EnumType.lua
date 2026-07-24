
--[[
-- 枚举类
--]]
UIWindowNames = require "UI.Config.UIWindowNames"
--为方便在全局都能调用UI或是Data中枚举值，把枚举都写到EnumType中


ProxyList =
{
    --"aps-r1-aga.apprelay.metapoint.club",
    --"aps-r1-cf.apprelay.metapoint.club",
    --"aps-r1-source.apprelay.metapoint.club"
	"s1.game.lm-app.readygo.tech"
};

ProxyName =
{
    --"aws",
    --"cloudfare",
    "direct"
};

-- 翻译地址
TRANS_URL = "http://translate-lm.metapoint.club/client.php"
TRANS_CHANNEL = "lastman"

LoginErrorMessage =
{
    --ERROR_UPDATE_MANIFEST = "ManifestDownError", -- 更新Manifest失败 (被下面覆盖)
    --ERROR_CHECK_VERSION_FAILED = "CheckRes_NetError",  -- 访问res文件失败 (被下面覆盖)
    --ERROR_CHECK_VERSION_TIMEOUT = "CheckRes_NetTimeout", -- 超时 (被下面覆盖)

    ERROR_CONN_LOST = "ErrorConnectLost", -- 连接丢失
    ERROR_LOGOUT = "ErrorLogout", -- 登出
    ERROR_NO_NET = "ErrorNoNet", -- 没有网络
    ERROR_CONNECT = "ErrorConnectError",   -- 连接错误

    ERROR_BANID = "ERROR_BANID",              -- 封号
    ERROR_IPBLACK = "ERROR_IPBLACK",           -- ip黑名单
    ERROR_DEVICEBLACK = "ERROR_DEVICEBLACK",       -- device黑名单

    ERROR_SUCCESS = "ERROR_SUCCESS", -- 成功
    ERROR_ACCOUNT_ERR = "ERROR_ACCOUNT_ERR", -- 服务器没有账号
    ERROR_NETWORK = "ERROR_NETWORK", -- 网络错误
    ERROR_HTTP = "ERROR_HTTP", -- Http错误
    ERROR_JSON = "ERROR_JSON", -- Json格式错误
    ERROR_DATA = "ERROR_DATA", -- 数据错误
    ERROR_UNREACHABLE = "ERROR_UNREACHABLE", -- 网络不可达
    ERROR_INIT = "ERROR_INIT", -- PushInit 错误
    ERROR_INIT_TIMEOUT = "ERROR_INIT_TIMEOUT", -- PushInit 超时
    ERROR_TIMEOUT = "ERROR_TIMEOUT", -- 网络超时
    ERROR_MAINTENANCE = "ERROR_MAINTENANCE", -- 服务器维护
    ERROR_SERVER_STATE = "ERROR_SERVER_STATE",
    ERROR_LOAD_DATATABLE = "ERROR_LOAD_DATATABLE", -- 加载配置表错误
    ERROR_LOAD_DATATABLE_TIMEOUT = "ERROR_LOAD_DATATABLE_TIMEOUT", -- 加载配置表超时
    ERROR_LOGIN_TIMEOUT = "ERROR_LOGIN_TIMEOUT", -- login超时
    ERROR_UPDATE_MANIFEST = "ERROR_UPDATE_MANIFEST", -- 下载Manifest错误
    ERROR_DOWNLOAD_UPDATE = "ERROR_DOWNLOAD_UPDATE", -- 下载更新错误
    ERROR_SERVER_LIST = "ERROR_SERVER_LIST", -- gsl返回错误码
    ERROR_LOGIN_ERROR = "ERROR_LOGIN_ERROR", -- 登陆错误
    ERROR_CHECK_VERSION_TIMEOUT = "ERROR_CHECK_VERSION_TIMEOUT", -- 检查版本超时
    ERROR_CHECK_VERSION_FAILED = "ERROR_CHECK_VERSION_FAILED", -- 检查版本失败
    ERROR_SERVER_LIST_EMPTY = "ERROR_SERVER_LIST_EMPTY", -- 没有返回server list
    ERROR_LOAD_SCENE_ERR = "ERROR_LOAD_SCENE_ERR", -- 加载场景报错
}

-- 网络出错列表
LoginErrorCode =
{
    ERROR_CONN_LOST = "error connect lost", -- 连接丢失
    ERROR_LOGOUT = "error logout", -- 登出
    ERROR_NO_NET = "error no net", -- 没有网络
    ERROR_CONNECT = "error connect error",   -- 连接错误

    ERROR_BANID = "4",              -- 封号
    ERROR_IPBLACK = "43",           -- ip黑名单
    ERROR_DEVICEBLACK = "44",       -- device黑名单

    ERROR_SUCCESS = "E000",    -- 成功
    ERROR_NETWORK = "E101",    -- 网络错误
    ERROR_HTTP = "E102",        -- Http错误
    ERROR_JSON = "E103",        -- Json格式错误
    ERROR_DATA = "E104",        -- 数据错误
    ERROR_UNREACHABLE = "E105", -- 网络不可达
    ERROR_INIT = "E106",        -- PushInit 错误
    ERROR_INIT_TIMEOUT = "E107",-- PushInit 超时
    ERROR_TIMEOUT = "E108",     -- 网络超时
    ERROR_MAINTENANCE = "E109", -- 服务器维护
    ERROR_SERVER_STATE = "E110",
    ERROR_LOAD_DATATABLE = "E111", -- 加载配置表错误
    ERROR_LOAD_DATATABLE_TIMEOUT = "E112", -- 加载配置表超时
    ERROR_LOGIN_TIMEOUT = "E113", -- login超时
    ERROR_UPDATE_MANIFEST = "E114", -- 下载Manifest错误
    ERROR_DOWNLOAD_UPDATE = "E115", -- 下载更新错误
    ERROR_SERVER_LIST = "E116", -- 没有返回server list
    ERROR_LOGIN_ERROR = "E117", -- 登陆错误
}

--[[
ResourceType =
{
    None = -1,--默认值，只前端要用
    Oil = 0, -- 0 黑曜石
    Metal = 1, -- 1 (之前是石头，现在变成躲避球变成食物了)
    Wood = 2, -- 2 木头
    PVE_STAMINA = 3, -- 3 pve体力
    People = 4, --4 人口
    Water = 11, -- 11 水
    Electricity = 12, -- 12 电
    FLINT = 13,--13 火晶石
    Money = 14, -- 14 钞票
    Gold = 15, -- 15 钻石
    PvePoint = 17,-- 17 PVE Point
    MedalOfWisdom = 18,--智慧勋章,GreenCrystal这个已经被废除了
    FarmBox = 19,--农业补给箱
    DETECT_EVENT = 20,--
    FORMATION_STAMINA = 21,--体力
    BattlePass = 22,--战令经验
    LM_food = 30, -- 食物
    LM_metal = 31, -- 金属
    Max = 100, --资源区间预留
    BlackKnight = 9001, --黑骑士积分(战报专用)
    MasteryPoint = 9002, -- 专精点数
    ResourceItem = 10000, --收取的资源道具
    Item = 10001, --Survival道具
    Survival_People = 10002,--Survival人口
    HeroExp = 200394, -- 经验
    Steel = 230104, --铜锭，装备材料
    SeasonRadiate = 200000, --赛季抗性
    SeasonGroundNum = 200001, --赛季地块数量
}
]]

--ResourceCanNotChangeByDiamond = {
--    [ResourceType.Oil] = 1,
--    [ResourceType.FLINT] = 1,
--}

GlobalShaderLod =
{
    LOW =0,
    MIDDLE =1,
    HIGH =2
}

--HeroBountyRarity =
--{
--    White = 1,
--    Green =2,
--    Blue = 3,
--    Purple = 4,
--    Orange = 5,
--    Red = 6
--}
--HeroBountyRarityColor =
--{
--    [HeroBountyRarity.White] = Color.New(254/255, 240/255, 217/255,1),
--    [HeroBountyRarity.Green] = Color.New(148/255, 225/255, 56/255,1),
--    [HeroBountyRarity.Blue] = Color.New(95/255, 163/255, 237/255,1),
--    [HeroBountyRarity.Purple] = Color.New(201/255, 108/255, 240/255,1),
--    [HeroBountyRarity.Orange] = Color.New(250/255, 136/255, 67/255,1),
--    [HeroBountyRarity.Red] = Color.New(242/255, 106/255, 103/255,1),
--
--}

--[[
---@class RewardType
RewardType =
{
    OIL = 0,--0 --燃油/瓦斯
    METAL = 1,--1 -- 金属/水晶
    LM_food = 3,--3 食物
    GOLD = 5,--5 钻石
    EXP = 6,--6
    GOODS = 7,--7 -- 道具
    SURVIVAL_GOODS = 100,--100 --RPG道具
    GENERAL = 8,--8
    POWER = 9,--9
    HONOR = 10,--10
    ALLIANCE_POINT = 11, --11 联盟积分
    HOUSE = 12,--12
    HOSPITAL = 13,--13
    EQUIP = 14,--14
    MATERIAL = 15,--15
    PART = 16,--16
    ITEM_EFFECT = 17,--17
    BATTLE_HONOR = 18,--18
    WATER = 19,--19 --水
    MONEY = 20,--20 --钱
    ELECTRICITY = 21,--21--电
    PEOPLE = 22,--22--人口
    ARM = 23,--23
    MANOR = 24,--24
    HERO = 25,--25
    PTGOLD = 26,--26
    RESOURCE_ITEM = 27,--27 资源道具
    PVE_POINT = 28,--pve积分
    DETECT_EVENT = 29,--雷达事件
    FORMATION_STAMINA = 30,--体力
    WOOD = 31,--木头
    PVE_STAMINA = 32,--pve体力
    PVE_MONUMENT_TIME = 33,--英雄丰碑次数
    PVE_ACT_SCORE = 34,--pve活动积分
    MuseumArtifact = 35,--博物馆宝物
    FLINT = 36,--火晶石
    CAR_EQUIP = 37,--装备
    LM_metal = 38,--金属
    VISITOR = 39, -- 小人
    HERO_EQUIP = 40,--英雄装备
    GARAGE_COMPON = 41,--改装车组件
    ---1000以后为客户端使用
    SEVENDAY_SCORE = 1001,--七日积分
    Golloes = 1002,--咕噜
    SAPPHIRE = 1003,--蓝宝石（联盟资源）
    ALLIANCE_DONATE = 1004, -- 联盟贡献
    ALLIANCE_SCIENCE_TECH_POINT = 1005, -- 捐献进度
    UnlockModule = 1007,--解锁功能（暂时联盟任务用）
    HERO_EXP = 1008,--英雄经验
    BATTLE_PASS = 1009,--战令积分
    TALENT = 1010,--天赋
    BUILD = 1011,--建筑
    ActGiftBox = 240010,--礼盒活动
    MASTERY_POINT = 1013,--专精点数
    SUB_BUILD_UP_01 = 1011,--子建筑升级
    SUB_BUILD_UP_02 = 1012,--子建筑升级
    FlyGoods_HeroTrial = 1015, -- 英雄试炼
    FlyGoods_MedalGet = 1016, -- BattlePass成就勋章获得
    PERSON_POINT = 1017, -- 战备奖章
    FlyGoods_FirstKill = 1018, -- 首杀奖励
    FlyGoods_UnlockMine = 1019,
    FlyGoods_Science = 1020, -- 科技
    ActFakeItem = 1021, --活动积分 道具之类的纯前端展示
    PLATFORM_TOKEN = 1025, --平台代币
    FAKE = 9999, --假奖励(比如：解锁了什么建筑，纯展示下)
}
]]
--奖励对应资源
--RewardToResType =
--{
--    --0=》0
--    [RewardType.OIL] = ResourceType.Oil,
--    --1=》1
--    [RewardType.METAL] = ResourceType.Metal,
--    --19=》11
--    [RewardType.WATER] = ResourceType.Water,
--    --21=》12
--    [RewardType.ELECTRICITY] = ResourceType.Electricity,
--    --20=》14
--    [RewardType.MONEY] = ResourceType.Money,
--    --5=》15
--    [RewardType.GOLD] = ResourceType.Gold,
--    --33=》17
--    [RewardType.FLINT] = ResourceType.FLINT,
--    [RewardType.PVE_POINT] = ResourceType.PvePoint,
--    [RewardType.DETECT_EVENT] = ResourceType.DETECT_EVENT,
--    [RewardType.FORMATION_STAMINA] = ResourceType.FORMATION_STAMINA,
--    [RewardType.WOOD] = ResourceType.Wood,
--    [RewardType.PVE_STAMINA] = ResourceType.PVE_STAMINA,
--    [RewardType.PEOPLE] = ResourceType.People,
--    [RewardType.LM_food] = ResourceType.LM_food,
--    [RewardType.LM_metal] = ResourceType.LM_metal,
--}

--资源对应奖励
--ResTypeToReward =
--{
--    [ResourceType.Oil] = RewardType.OIL,
--    [ResourceType.Metal] = RewardType.METAL,
--    [ResourceType.Water] = RewardType.WATER,
--    [ResourceType.Electricity] = RewardType.ELECTRICITY,
--    [ResourceType.Money] = RewardType.MONEY,
--    [ResourceType.Gold] = RewardType.GOLD,
--    [ResourceType.PvePoint] = RewardType.PVE_POINT,
--    [ResourceType.DETECT_EVENT] = RewardType.DETECT_EVENT,
--    [ResourceType.FORMATION_STAMINA] = RewardType.FORMATION_STAMINA,
--    [ResourceType.Wood] = RewardType.WOOD,
--    [ResourceType.PVE_STAMINA] = RewardType.PVE_STAMINA,
--    [ResourceType.People] = RewardType.PEOPLE,
--    [ResourceType.FLINT] = RewardType.FLINT,
--    [ResourceType.LM_food] = RewardType.LM_food,
--    [ResourceType.LM_metal] = RewardType.LM_metal,
--    [ResourceType.HeroExp] = RewardType.EXP,
--}

--[[
GOODS_TYPE =
{
    GOODS_TYPE_0 = 0,
    GOODS_TYPE_1 = 1,
    GOODS_TYPE_2 = 2,   --加速道具
    GOODS_TYPE_3 = 3,   --资源道具  20英雄经验
    GOODS_TYPE_4 = 4,   --buff道具
    GOODS_TYPE_5 = 5,   --宝箱
    GOODS_TYPE_6 = 6,
    GOODS_TYPE_7 = 7,   --装备材料
    GOODS_TYPE_8 = 8,   --随机给1000兵
    GOODS_TYPE_9 = 9,   --装备配件
    GOODS_TYPE_13 = 13, --道具合成
    GOODS_TYPE_15 = 15, -- 红包道具
    GOODS_TYPE_16 = 22, --道具合成+最强要塞积分buffer,16 occupy ，manager change it to 22
    GOODS_TYPE_23 = 23, --军队扩充道具
    GOODS_TYPE_35 = 35, --导弹
    GOODS_TYPE_39 = 39, --
    GOODS_TYPE_41 = 41, --
    GOODS_TYPE_45 = 45, --礼品赠送
    GOODS_TYPE_46 = 46, --可以产生多个reward的道具
    GOODS_TYPE_48 = 48,
    GOODS_TYPE_50 = 50, --沙漠积分
    GOODS_TYPE_57 = 57, --能力强化经验道具
    GOODS_TYPE_59 = 59, --可以产生多个reward的道具
    GOODS_TYPE_62 = 62, --勋章
    GOODS_TYPE_63 = 63, -- 技能书，用来学习技能用，在道具列表中不显示
    GOODS_TYPE_66 = 66, --治疗沙漠淘金者伤兵的道具
    GOODS_TYPE_70 = 70, --英雄碎片
    GOODS_TYPE_79 = 79, --vip赠送礼物
    GOODS_TYPE_90 = 90, --天赋重置卷
    GOODS_TYPE_91 = 91, --英雄经验书
    GOODS_TYPE_93 = 93, --英雄勋章
    GOODS_TYPE_98 = 98, --英雄碎片
    GOODS_TYPE_99 = 99, --特定英雄碎片
    GOODS_TYPE_102 = 102,--英雄组合选择箱
    GOODS_TYPE_106 = 106,--
    GOODS_TYPE_107 = 107,--资源道具选择箱子
    GOODS_TYPE_108 = 108,--晶体箱
    GOODS_TYPE_109 = 109,--编队buff
    GOODS_TYPE_110 = 110,--装扮道具
    GOODS_TYPE_112 = 112,--赛季经验道具
    FILL_UP_EVENT_NUM =113,      --113补满雷达事件
    UNLOCK_FACTORY_SLOT = 115, --115解锁工厂生产区
    SPEED_WORLD_MARCH = 116, -- 116 行军加速道具
    MIGRATE_ITEM = 117, -- 移民道具
    LANDMINE = 118, -- 地雷
    BUILD_BAUBLE = 120,      --120装饰建筑
    GOODS_TYPE_122 = 122,--士兵自选箱子
    GOODS_TYPE_123 = 123,--雇佣兵自选箱子
    Password = 124,--密码道具
    CALL_BOSS_OR_REWARD = 126,--呼叫boss或者获得奖励
    GOODS_TYPE_127 = 127,--赠送皮肤的道具类型
    GOODS_TYPE_128 = 128,--圣器经验
    GOODS_TYPE_204 = 204,--自适应资源箱子的道具类型
    GOODS_TYPE_206 = 206,--联盟积分兑换道具类型
    GOODS_TYPE_207 = 207,--英雄装备自选道具
    GOODS_TYPE_210 = 210,--类似于类型5 但是有保底
    GOODS_TYPE_212 = 212,--改装车组件自选箱子
    GOODS_TYPE_503 = 503,--道具激活皮肤
    GOODS_TYPE_504 = 504,--道具解锁专武
}
]]

--SurvivalItemType =
--{
--    Sundries = 80, --杂物
--    Material = 81, --材料
--    Equip = 82, --武器、装备、背包、工具
--    Feed = 83,  --食物
--}

--GOODS_TYPE2 =
--{
--    ResourceItem = 1, --ResourceItem类物品
--    PVEEnergy = 3,--pve体力
--    HeroExp = 20,-- type == 3为英雄经验 
--    StaminaItem = 21, --good_type == 3运兵车燃料
--    MarchSpeedItem = 22,--good_type == 116行军加速道具
--}

-- 作用状态
--EffectStateDefine =
--{
--    LORD_SKILL_PROTECTED = 501051,         -- 资源保护
--    PLAYER_PROTECTED_TIME1 = 500000,       -- 鸡蛋壳
--    PLAYER_PROTECTED_TIME2 = 500001,
--    PLAYER_PROTECTED_TIME3 = 500002,
--    PLAYER_PROTECTED_TIME4 = 500003,
--    PLAYER_PROTECTED_TIME5 = 500004,
--    NEW_PLAYER_PROTECTED = 500009,         -- 新手鸡蛋壳
--    CHINESE_WIND_SKIN = 500526,            -- 中国风皮肤（1天）表格里的说明
--
--}

--PushType =
--{
--    PUSH_GM = 0,
--    PUSH_QUEUE = 1,         --队列
--    PUSH_WORLD = 2,         --世界地图,拆分被攻击和被侦查
--    PUSH_MAIL = 3,          --联盟
--    PUSH_STATUS = 4,        --状态
--    PUSH_ALLIANCE = 5,      --社交（聊天） 去掉联盟邮件
--    PUSH_ACTIVITY = 6,      --活动 5的联盟邮件加进来
--    PUSH_RESOURCE = 7,      --7资源满仓
--    PUSH_CHAT = 8,          --8聊天
--    PUSH_REWARD = 9,        --9礼包...音乐杀僵尸、食堂开餐等
--    PUSH_WEB_ONLINE = 10,   --web在线?
--    PUSH_ATTACK = 11,       --从2拆分出来,被攻击
--    PUSH_SCOUT = 12,        --从2拆分出来,被侦察
--    NOT_CHECK = 99,  --不用检查
--}

--ViewMode =
--{
--    RPG = 0,
--    SLG = 1
--}

--SLGCameraPosType =
--{
--    FollowPlayer = 1, -- 跟随主角
--    ConfigPos = 2 -- 读配置
--}

--缺少道具 补充显示排序  354
--ResLackResTypeOrder =
--{
--	Normal = 1, --常规资源补充
--	Custom = 2, --自选宝箱
--	Adapt = 3, --自适应宝箱
--}

--SurvivalEquipType =
--{
--    Hat = "hat",
--    Cloth = "cloth",
--    Trousers = "trousers",
--    Shoe = "shoe",
--    Weapon = "weapon",
--    Bag = "bag",
--}

--EquipSlotReq =
--{
--    [0] = SurvivalEquipType.Hat,
--    [1] = SurvivalEquipType.Cloth,
--    [2] = SurvivalEquipType.Trousers,
--    [3] = SurvivalEquipType.Shoe,
--    [4] = SurvivalEquipType.Weapon,
--    [5] = SurvivalEquipType.Bag
--}


--GirlCollectBubbleType = 
--{
--    Progress = 1,
--    Confirm = 2,
--    FreeToFinish = 3,
--}

--SurvivalTipsColor =
--{
--    White = Color.New(255/255, 255/255, 255/255,1),
--    AddHP_Green = Color.New(147/255, 248/255, 65/255,1),
--    ReduceHP_Red = Color.New(249/255, 81/255, 55/255,1),
--    ReduceHP_Zombie_Orange = Color.New(242/255, 210/255, 61/255,1),
--    LevelUp_Cyan = Color.New(57/255, 222/255, 208/255,1),
--    BagFull_Orange = Color.New(216/255, 161/255, 42/255,1),
--    BuildBeAttack = Color.New(218/255, 99/255, 75/255,1),
--}

--QualityTrainBgPath={
--    [1]="Assets/Main/UITexture/UILWRailway/lrb_chengjimaoyi_huocheN_bg.png",
--    [2]="Assets/Main/UITexture/UILWRailway/lrb_chengjimaoyi_huocheR_bg.png",
--    [3]="Assets/Main/UITexture/UILWRailway/lrb_chengjimaoyi_huocheSR_bg.png",
--    [4]="Assets/Main/UITexture/UILWRailwayRailwayUtil/lrb_chengjimaoyi_huocheSSR_bg.png",
--    [5]="Assets/Main/UITexture/UILWRailway/lrb_chengjimaoyi_huocheUR_bg.png",
--    [10]="Assets/Main/UITexture/UILWRailway/lrb_chengjimaoyi_huocheUR_bg.png",
--}

--[[
AtlasAssets =
{
    ItemAtlas = "ItemIcons",
    ItemAtlas1 = "ItemIcons1",
    ResourceAtlas = "Resource",
    SoldierIcons = "SoldierIcons",
    MonsterBodyAtlas = "MonsterBody",
    UIAllianceFlag = "AllianceFlags",
    UIAllianceWar = "AllianceWar",
    UIWorldCity = "Scene_WorldCity",
    CountryFlag = "CountryFlag",
    SceneMiniMap = "Scene_MiniMap",
    UIBuildBtns = "UI_UIBuildBtns",
    SceneRoad = "Scene_road",
    UICommon = "UI_Common",
    UICommonBG = "UI_CommonBG",
    WorldResource = "Scene_WorldResource",
    UIMail = "UI_UIMail",
    UIFormation = "UI_UIFormation",
    UIActivityPreView = "UI_UIActivityPreView",
    EquipAtlas = "Equip",
    SceneWorld = "Scene_World",
    ServerMap = "Scene_ServerMap",
    TalentIcon = "UI_TalentIcon",
    CommonDefault = "UI_CommonDefault",
    UIBattle = "UI_Battle_BattleUI",
    WorldBuild = "WorldBuild",
    UI_DoomsdayBattleGuide = "UI_DoomsdayBattleGuide",
    UI_WelfareCenter = "UI_WelfareCenter",
    UI_KingdomFace = "UI_KingdomFace",
    UI_NoteBook = "UI_UINoteBook",
    UI_BuildMenu = "UI_BuildMenu",
    UI_UIMissile = "UI_UIMissile",
    UI_Decoration = "UI_Decoration",
    DynamicAtlas = "DynamicAtlas0",
    UI_UITilepop = "UI_UITilepop",
    UI_UIResourceProduction = "UI_UIResourceProduction",
    HUP = "HUP",
    UI_UIMain = "UI_UIMain",
    UI_GiftPackage = "UI_GIftPackage_GiftCommon",
    Science = "UI_UIScience",
    ScienceIcons = "ScienceIcons",
    UI_UIHeroInfo = "UI_UIHeroInfo",
    UITask = "UI_UITask",
    UISet = "UI_UISet",
    UI_UIHeroTalent = "UI_UIHeroTalent",
}
]]

SkinType = {
    BASE_SKIN = 1, --基地皮肤
    HEAD_SKIN = 2, --头像框
    TITLE_NAME = 3, --称号
}
--DeclareState =
--{
--    None = 0,--未开启
--    Prepare = 1,--战前准备
--    SelectPlayer = 2,--未挑选对手
--    SelectPlayerDone = 3,--挑选对手后
--    BattleWaitStart = 4,--宣战日，有对手等待战斗开启
--    BattleNoPlayer = 5,--宣战日，没有对手
--    Battle = 6,--宣战日，战斗阶段
--    BattleAdvanceEnd = 7,--宣战日，战斗阶段提前结束倒计时
--    End = 8,--宣战日，战斗结束
--}

--CrossHitBlockType =
--{
--    MatchingPhaseOne = 1, --第一次战斗的匹配阶段
--    PremonitoryPhaseOne = 2 ,--第一次预热阶段
--    BattlePhaseOne = 3, -- 战斗阶段
--    BattlePhaseTwo = 4, -- 战斗阶段 
--    MatchingPhaseTwo = 5, --第二次战斗的匹配阶段
--    PremonitoryPhaseTwo = 6 ,--第二次预热阶段
--    WaitEnd = 7 ,--等待结束
--}


UIAssets =
{
}

VFXAssets =
{
--    UIMainTaskHead = 'Assets/_Art_LastDay/Effect/Prefab/UI/Common/%s.prefab',
--    UIMainTaskNormalCompHead = 'Assets/_Art_LastDay/Effect/Prefab/UI/UIPVEMain/Eff_UI_PVEMain_renwutishi_05_Head.prefab',
}



SettingKeys =
{
    Server_isVertical = "Server_isVertical", -- 服务器记录的横竖版状态
    CACHE_KEY_CurLayout = "CurLayoutNew",
	LAST_SERVER_KEY = "DEBUG_LAST_SERVERID",
    LAST_DRAGON_BATTLE_TIME = "LAST_DRAGON_BATTLE_TIME",
    CATCH_ITEM_ID = "Setting.CATCH_ITEM_ID",

	--GP_USERID = "Setting.GooglePlayID",  -- 重复定义，使用下面的
	GP_USERNAME = "Setting.GooglePlayName",
    PURCHASE_SUCCESSED_KEY = "Setting.PURCHASE_SUCCESSED_KEY",   --已成功订单号存放的key
    PURCHASE_KEY = "Setting.PURCHASE_KEY",                      --订单信息存放的key

    EFFECT_MUSIC_ON = "isEffectMusicOn",                                --音效
    BG_MUSIC_ON = "isBGMusicOn",                                        --音乐
    VIBRATE = "Setting.Vibrate",                                        --震动
    TOUCH_SP_FUN = "touch_sp_fun",                                      --问题反馈
    TASK_TIPS_ON = "isTaskTipsOn",                                      --任务提示
    COORDINATE_ON_SHOW = "COORDINATE_ON_SHOW",                          --坐标提示
    SETTING_ACCOUNT = "Setting.ACCOUNT",                              	--账号，本地缓存
    ACCOUNT_STATUS = "Setting.ACCOUNT_STATUS",                          --账号，验证状态
    GP_USERID = "Setting.GooglePlayID",                                 --谷歌账号
    FB_USERID = "Setting.FB_USERID",                                    --Facebook账号
    WX_APPID_CACHE = "Setting.WX_APPID_CACHE",                          --微信账号
    FB_USERNAME = "Setting.FB_USERNAME",                                --Facebook账号名字
    UUID = "Setting.UUID",                                              --用户uuid
    GAME_UID = "Setting.GAME_UID",                                      --用户id（使用这个）
    New_GAME_UID = "New_GAME_UID",                                      --指定服新建账号时用来缓存老账号
    GAME_UID_FOR_ERR_SEARCH = "GAME_UID_FOR_ERR_SEARCH",                --发生E002后GetServerList附带给服务器，用于检索账号
    GM_FLAG = "Setting.GM_FLAG",
    SERVER_IP = "SERVER_IP",
    SERVER_PORT = "SERVER_PORT",
    SERVER_ZONE = "SERVER_ZONE",
    CROSS_SERVER_TYPE = "CROSS_SERVER_TYPE",                            --跨服类型
    FUN_BUILD_MAIN_LEVEL = "FUN_BUILD_MAIN_LEVEL",
    CUSTOM_UID = "Setting.CUSTOM_UID",                                  --邮件
	EMAIL_CONFIRM = "Setting.EMAIL_CONFIRM", --邮件确认
    AZ_ACCOUNT = "Setting.AZ_ACCOUNT",
    AZ_ACCOUNTSTATUS = "Setting.AZ_ACCOUNTSTATUS",
    DEVICE_UID = "Setting.DEVICE_UID",                                  --设备ID
    ACCOUNT_LIST = "Setting.ACCOUNT_LIST",                              --登录过的账号列表
    ACCOUNT_PWD = "Setting.ACCOUNT_PWD",                                --密码，本地缓存
    --ACCOUNT_PWD = "Setting.ACCOUNT_PWD",                                --密码，本地缓存
    DEVICE_ID = "DEVICE_ID",
    ACCOUNT_SENDMIL_AGAINTIME = "Setting.ACCOUNT_SENDMIL_AGAINTIME",    --记录验证邮件发送时间
    HERO_LIST_SORT_TYPE = "HERO_LIST_SORT_TYPE",                        --英雄界面排序设置
    CHAT_SHOW_ROOM_LIST = "CHAT_SHOW_ROOM_LIST",                        --聊天界面是否显示左边房间列表
    POST_PROCESSING = "POST_PROCESSING",                                --后处理
    HEIGHT_FOG = "HEIGHT_FOG",                                          --高度雾
    SCENE_PARTICLES = "SCENE_PARTICLES",                                --场景粒子
    SCENE_SURFACE = "SCENE_SURFACE",                                    --地表
    SCENE_BUILD = "SCENE_BUILD",                                        --建筑
    SCENE_DECORATIONS = "SCENE_DECORATIONS",                            --装饰物
    SCENE_MONSTER = "SCENE_MONSTER",                                    --野怪
    SCIENCE_TAB_UNLOCK = "SCIENCE_TAB_UNLOCK",                          --科技Tab已解锁
    SEARCH_MONSTER_LEVEL = "Setting.SEARCH_MONSTER_LEVEL",              --上次搜怪等级
    GAME_ACCOUNT = "GAME_ACCOUNT",
    GAME_PWD = "GAME_PWD",
    ACCOUNT_LIST_DEBUG = "ACCOUNT_LIST_DEBUG",							-- 内网测试账号列表
    ALLOW_TRACKING_CLICK = "ALLOW_TRACKING_CLICK",                      -- 点击“允许跟踪”
    LAST_ALLOW_TRACKING = "LAST_ALLOW_TRACKING",

    MAIL_COLLECT_LAST_OPEN = "MAIL_COLLECT_LAST_OPEN",                  -- 采集邮件上次打开的时间
    MAIL_MONSTER_REWARD_LAST_OPEN = "MAIL_MONSTER_REWARD_LAST_OPEN",    -- 怪物奖励邮件上次打开的时间
    USER_ALREADY_FARM = "USER_ALREADY_FARM",                                 -- 玩家首次播种
    USER_ALREADY_FEED = "USER_ALREADY_FEED",                                 -- 玩家首次喂动物
    SHOW_DEBUG_CHOOSE_SERVER = "SHOW_DEBUG_CHOOSE_SERVER",               -- 是否有选服界面
    CANCEL_MARCH_ALERT_UUIDS = "CANCEL_MARCH_ALERT_UUIDS",              --取消的行军警报
    MAIL_LAST_OPEN_TIME_BY_GROUP = "MAIL_LAST_OPEN_TIME_BY_GROUP_",     --上次打开邮件时间
    SHOW_USE_DIAMOND_ALERT = "SHOW_USE_DIAMOND_ALERT",                  --是否有使用钻石提示
    SHOW_LIKE_TIPS = "SHOW_LIKE_TIPS",                  --是否提示被点赞
    SHOW_FORCE_CHANGE_TARGET = "SHOW_FORCE_CHANGE_TARGET",                  --在自由行军中强制修改目的地
    CITY_TROOP_POSITION ="CITY_TROOP_POSITION",
    GOTO_POSITION_X = "GOTO_POSITION_X",--跳转的x坐标
    GOTO_POSITION_Y = "GOTO_POSITION_Y",--跳转的y坐标
    ALLIANCE_WAR_OLD_DATA = "ALLIANCE_WAR_OLD_DATA",--已查看过的联盟战争id
    SCENE_GRAPHIC_LEVEL = "SCENE_GRAPHIC_LEVEL",
    SCENE_FPS_LEVEL = "SCENE_FPS_LEVEL",
    BUILD_NO_SHOW_UNLOCK = "BUILD_NO_SHOW_UNLOCK", -- 已查看过的建筑解锁动画
    ACTIVITY_VISITED_END_TIME = "ACTIVITY_VISITED_END_TIME", -- 上次访问活动界面的endTime
    WORLDARROW_TYPE_FARM_NUM = "WORLD_ARROW_TYPE_FARM_NUM",--农田arrow出现的次数
    WORLDARROW_TYPE_BUILD_NUM = "WORLD_ARROW_TYPE_BUILD_NUM",--建筑arrow出现的次数
    FIRST_INCITY_CHAT_SHOW = "FIRST_INCITY_CHAT_SHOW",--第一次显示任务
    ALLIANCE_ORDER_WELCOME = "ALLIANCE_ORDER_WELCOME", --首次进入联盟农场活动，显示过场
    WORLDARROW_TYPE_NUM = "WORLDARROW_TYPE_NUM_",--arrow出现的次数
    ShowAlCompeteTime = "ShowAlCompeteTime", --联盟对决每周一展示的红点记录
    LOGIN_SECOND_DAYS = "LOGIN_SECOND_DAYS", -- 第二天登录游戏
    HERO_STATION_VIEWED = "HERO_STATION_VIEWED", -- 玩家已经看过的英雄驻扎面板, StationId
    HERO_STATION_VAL_CACHE = "HERO_STATION_VAL_CACHE", -- 英雄驻扎面板保存值
    REGISTER_TIME_REACH = "REGISTER_TIME_REACH",--第一次登陆游戏记录
    FIRST_PAY_BUY_CLICK = "FIRST_PAY_BUY_CLICK",--首冲按钮点击
    CAMP_RECRUIT_BUBBLE_TIP = "CAMP_RECRUIT_BUBBLE_TIP", --阵营招募建筑气泡提示
    DigCameraHeightSnap = "DigCameraHeightSnap",
    LOGIN_POP_K = "LOGIN_POP_K", --登录弹出轮到第几个了
    LOGIN_POP_LAST_TIME = "LOGIN_POP_LAST_TIME", --登录弹出上次记录时间
    ActivityNoticeTipShowTime = "ActivityNoticeTipShowTime",
    TimeCompePop_Times = "TimeCompePop_Times", --每天限时竞赛活动PopUI已经弹出次数
    PlayActBossAni_Time = "PlayActBossAni_Time",
    PlayBarterShopNotice2Ani_Time = "PlayBarterShopNotice2Ani_Time",
    Combat_Times = "Combat_Times", -- 战力活动
    ArenaPop_Times = "ArenaPop_Times", --每天竞技场弹板次数
    WorldBossPop_Times = "WorldBossPop_Times",  --每天世界boss弹板次数
    StrongCommander_Times = "StrongCommander_Times", --每天最强指挥官弹板次数
    ChampionBattle_Times = "ChampionBattle_Times",
    ChampionBattleInvivation_Times = "ChampionBattle_Times_Special",
    CHAT_CONNECT_SERVER_INDEX = "CHAT_CONNECT_SERVER_INDEX",
    AllianceCompete_Times = "AllianceCompete_Times", --每天联盟对决弹板次数
    AllianceCompete_PopDay = "AllianceCompete_PopDay", --记录联盟对决弹板弹到第几天了
    KONBINI_BUY_DONT_SHOW = "KONBINI_BUY_DONT_SHOW", -- 小卖部花钻石不再提示
    NEWBIE_FARM_BTN_CLICK = "NEWBIE_FARM_BTN_CLICK", -- 开荒种植按钮点击记录
    AlCompeteShowAnim_Time = "AlCompeteShowAnim_Time", --上次联盟对决对抗动效播放时间
    FIRST_PAY_SHOWN = "FIRST_PAY_SHOWN", -- 首充是否显示过
    FIRST_ACCOUNTBIND_SHOW = "FIRST_ACCOUNTBIND_SHOW",--首次绑定账号是否显示过
    CAREER_CHANGE_CHECK_TIME = "CAREER_CHANGE_CHECK_TIME",
    UNLOCK_FACTORY_PRELEVEL = "UNLOCK_FACTORY_PRELEVEL",
    LastArenaFightTime = "LastArenaFightTime", --最后一次用竞技场战斗的时间
    PVE_EXP_HEROES = "PVE_EXP_HEROES", -- PVE经验关上阵英雄
    PVE_HEROES = "PVE_HEROES", -- PVE上阵英雄
    PVE_HEROES_ADVENTURE = "PVE_HEROES_ADVENTURE", -- PVE上阵英雄，星珲探索活动
    TRUCK_ROB_HEROES = "TRUCK_ROB_HEROES", -- 卡车抢夺队列英雄列表
    PVE_SPEED_OFFSET = "PVE_SPEED_OFFSET",   -- PVE战报速度
    ActLuckyRollJumpAnim = "Act_LuckyRoll_JumpAnim",
    ACT_GOLLOESCARD_JUMP_ANIM = "Act_GolloesCard_JumpAnim",
    DayRechargeMonthCardPackageIndex = "DayRechargeMonthCardPackageIndex",
    FREE_SOLDIER_HIDE_WHEN_MAX = "FREE_SOLDIER_HIDE_WHEN_MAX", -- 兵营满时，免费收兵隐藏
    PVE_HERO_POWER_CONFIG_CACHE = "PVE_HERO_POWER_CONFIG_CACHE",
    PVE_HERO_POWER_CACHE = "PVE_HERO_POWER_CACHE",
    PVE_SPEED_SHOW_RED_DOT = "PVE_SPEED_SHOW_RED_DOT",
    CHAPTER_FIRST_SHOW = "CHAPTER_FIRST_SHOW",
    PVE_SPEED_SHOW_EFFECT  = "PVE_SPEED_SHOW_EFFECT",
    KONBINI_TIP_TIME = "KONBINI_TIP_TIME",
    MineCaveSwitchCross_Time = "MineCaveSwitchCross_Time",--矿洞切换点击切换时间
    MineCaveShowCrossTip_Time = "MineCaveShowCrossTip_Time",--矿洞切换点击时弹出tip的时间
    MineCaveAttackTip_Time = "MineCaveAttackTip_Time", --矿洞跨服攻击弹出确认tip的时间
    PVE_LV_POINT = "PVE_LV_POINT",
    NEWBIE_FARM_SHOW_HEAD = "NEWBIE_FARM_SHOW_HEAD", -- 开荒种植头像显示
    LEVEL_EXPLORE_SWEEP_HEROES = "LEVEL_EXPLORE_SWEEP_HEROES",
    LAST_WORLD_TREDN = "LAST_WORLD_TREDN" ,
    PVE_AUTO_PLAY = "PVE_AUTO_PLAY_V1" ,
    KEEP_PAY_VISIT_TIME = "KEEP_PAY_VISIT_TIME",
    CHAIN_PAY_VISIT_TIME = "CHAIN_PAY_VISIT_TIME",
    ActGiftBoxJumpAnim = "Act_GiftBox_JumpAnim",
    ShopRedTime = "ShopRedTime", --公共商店红点显示时间
    DEAD_ARMY_READ_TIME = "DEAD_ARMY_READ_TIME", --士兵死亡记录阅读时间
    GROWTH_PLAN_VISITED = "GROWTH_PLAN_VISITED",
    SEASON_FORCE_REWARD = "SEASON_FORCE_REWARD",
    CHAT_GROUP_SHIELD = "CHAT_GROUP_SHIELD",--聊天屏蔽红点
    NPC_CITY_DATA = "NPC_CITY_DATA_V1_",
    MAIL_MAIN_FIRST = "MAIL_MAIN_FIRST",
    BLACK_KNIGHT_CANCEL_WARNING = "BLACK_KNIGHT_CANCEL_WARNING",--黑骑士关闭预警
    BLACK_KNIGHT_RED_NEW = "BLACK_KNIGHT_RED_NEW",--黑骑士红点
    THRONE_ACT_TIME = "THRONE_ACT_TIME",
    CROSS_WORM_ADD_ARMY_NO_TIP = "CROSS_WORM_ADD_ARMY_NO_TIP",
    DONATE_SOLDIER_ACTIVITY_RED_NEW = "DONATE_SOLDIER_ACTIVITY_RED_NEW",--捐兵活动new红点
    DONATE_SOLDIER_ACTIVITY_NEW_TASK_RED = "DONATE_SOLDIER_ACTIVITY_NEW_TASK_RED",--捐兵活动新任务红点
    DONATE_SOLDIER_ALVS_ACTIVITY_RED_NEW = "DONATE_SOLDIER_ALVS_ACTIVITY_RED_NEW",
    ALLIANCE_BOSS_ACTIVITY_RED_NEW = "ALLIANCE_BOSS_ACTIVITY_RED_NEW",-- 联盟boss活动new红点
    LastClickDayRechargeMonthDay = "LastClickDayRechargeMonthDay", --上次点击每日充值月卡手册的时间
    LastClickCompensateMonthMonthDay = "LastClickCompensateMonthMonthDay", --上次点击每日充值月卡手册的时间
    LastClickCandyRoom_Time = "LastClickCandyRoom_Time", --上次点击糖果屋的时间
    LastCandyRoomBubbleGuide_Time = "", --上次糖果屋气泡引导时间

    Barrel_GM_DebugInfo = "Barrel_GM_DebugInfo",
    Barrel_GM_LastLevelId = "Barrel_GM_LastLevelId",
    Barrel_HaveFailed = "Barrel_HaveFailed",

    NewUnlockBluePrintIds = "NewUnlockBluePrintIds", -- 新解锁的蓝图
    PlayerCauseOfDeath = "PlayerCauseOfDeath", -- 角色死亡原因
    GirlAutoEventTalk = "GirlAutoEventTalk", -- 自动播放美女对话(美女界面的事件对话)
    GuideAutoTalk = "GuideAutoTalk", -- 自动播放美女对话(引导的对话)
    PlayGirlStoryPv = "PlayGirlStoryPv", -- 播放美女故事视频
    PlayGirlStoryUnlock = "PlayGirlStoryUnlock", -- 美女故事解锁
    LastServerTime = "LastServerTime", --记录上次记录服务器的时间
    UITaskPromptTips = "UITaskPromptTips",--任务弹框
    AutoStory = "AutoStory",--自动推关
    ActNotice_History = "ActNotice_History",--记录今日已经弹出过的气泡
    BarterNoticeRed = "BarterNoticeRed", --记录危机四伏是否点过自动集结的按钮红点

    ActDigJumpAnim = "Act_Dig_JumpAnim", --是否跳过挖掘动画
    LLHangUpGoToBtnShow = "LLHangUpGoToBtnShow", --挂机奖励推图提示按钮是否显示过
    TalkTaskObjWeakGuideArrows = "TalkTaskObjWeakGuideArrows", --对话小人是否显示过弱引导
    ArenaBubbleShow = "ArenaBubbleShow", -- 竞技场气泡一天就显示一次显示
    AUTO_ENTER_NEXT_LEVEL = "AUTO_ENTER_NEXT_LEVEL",--
    HasOpenNewFirstPay = 'HasOpenNewFirstPay',

    BuildPoliceInsigniaBubbleShow = "BuildPoliceInsigniaBubbleShow", --警徽气泡初始是否显示过动画
    ChangeNamePicNew = "ChangeNamePicNew", --改名活动
    ChangeNameGender = "ChangeNameGender", 
    
    ItemRedUuidList = "ItemRedUuidList", -- 道具红点列表
    FightPreview_Times = "FightPreview_Times", --杀戮活动弹板次数
    
    FormationPanelUpgradeTip = "FormationPanelUpgradeTip", --barrel布阵面板升级提示
    Barrel_Tutorial2HasDisplayed = "Barrel_Tutorial2HasDisplayed", --前冲关boss指引是否显示过
    
    Throne_Times = "Throne_Times",
    Presidenton_Times = "Presidenton_Times",
    
    Act_Throne_Presidenton = "Act_Throne_Presidenton",
    Act_Throne_Preview = "Act_Throne_Preview",
    Act_Throne_Battle = "Act_Throne_Battle",
    Act_Throne_Score_Rule = "Act_Throne_Score_Rule",
    
    Cross_Wonder_Begin = "Cross_Wonder_Begin_",--跨服王座开始战斗红点
    Cross_Wonder_WinCount_Red_Shown = "Cross_Wonder_WinCount_Red_Shown_", --跨服王座连胜奖励红点是否已经展示过（玩家积分未达到领奖限制50000时，点击按钮之后红点消失，且按钮置灰）

    NoticeShow_Time = "NoticeShow_Time", --通知面板显示的时间
    
    RESERVATION_TIPS = "RESERVATION_TIPS_", --预约宣战主UI提醒
    RESERVATION_SHOWN = "RESERVATION_SHOWN_", --活动红点，点击之后消失
    
    LAST_TRAIN_SOLDIER_INDEX = "LAST_TRAIN_SOLDIER_INDEX",--上一次选中的士兵
    
    HERO_BATTLE_FIELD_SHOP = "HERO_BATTLE_FIELD_SHOP",--英雄战场商店红点
    CAMP_TARGET_CHAPTER_NEW_FLAG = "CAMP_TARGET_CHAPTER_NEW_FLAG", -- 英雄战场，打通新的一关之后，赠送关卡标识
    CAMP_TARGET_CHAPTER = "CAMP_TARGET_CHAPTER", -- 当前选中章节

    SEASON_BUFF_VISITED_TIME = "SEASON_BUFF_VISITED_TIME", --赛季buff界面访问时间
    
    Act_Dragon_Sign_Show_State = "Act_Dragon_Sign_Show_State_", --峡谷争夺战报名之后红点显示状态
    Act_Dragon_BattleStart_Main = "Act_Dragon_BattleStart_Main_", --主力参战红点
    Act_Dragon_BattleStart_Sub = "Act_Dragon_BattleStart_Sub_", --替补参战红点
    
    GLORY_DECLARE_ACTIVITY = "GLORY_DECLARE_ACTIVITY_",--联盟宣战活动首次开始红点.
    GLORY_DECLARE_SET_TRUCE = "GLORY_DECLARE_SET_TRUCE_",--联盟宣战设置免战时间
    GLORY_DECLARE_GOTO_BATTLE = "GLORY_DECLARE_GOTO_BATTLE_",--联盟宣战前往战斗
    GLORY_DECLARE_SHOW_TIPS = "GLORY_DECLARE_SHOW_TIPS_",--联盟宣战，主界面左下角开战按钮tips
    
    ACT_WORLD_RESOURCE_NEW = "ACT_WORLD_RESOURCE_NEW",
    ACT_CROSS_WORLD_RESOURCE_NEW = "ACT_CROSS_WORLD_RESOURCE_NEW",
    ALREADY_SHOW_PLAYER_PRIVACY = "ALREADY_SHOW_PLAYER_PRIVACY", --是否已显示过
    NEED_RECORD_PLAYER_PRIVACY = "NEED_RECORD_PLAYER_PRIVACY", --是否需要向服务器发送

    GLORY_DECLARE_WAR_TIMES = "GLORY_DECLARE_WAR_TIMES",--荣耀宣战次数

    UICompensateMonthCardLetter_TIMES = "UICompensateMonthCardLetter_TIMES",  --补偿月卡信件
    UICompensateMonthCardPop_Times = "UICompensateMonthCardPop_Times",
    UIHeroBattlePassPop_Times = "UIHeroBattlePassPop_Times",

    GLORY_DECLARE_WAR_POPED = "GLORY_DECLARE_WAR_POPED",--联盟宣战登录弹窗
    
    --竖版：赛季
    SEASON_INTRO_HAS_READ = "SEASON_INTRO_HAS_READ",
    
    HospitalCostTimeRecord = "HospitalCostTimeRecord",--医院治疗士兵花费时间
    RandomHotServerList = "RandomHotServerList",--hot服务器随机一个时总共的服务器数量

    RobotWarsMain_LastOpenTime = "RobotWarsMain_LastOpenTime",--领地争夺战主界面最后打开时间
    SmallPeopleRecruitSkipAnim = "SmallPeopleRecruitSkipAnim", --小人招募跳过动画
    MineCrossServerFilter = "MineCrossServerFilter",--矿区跨服过滤
    UILuckyRollHeroPop_Times = "UILuckyRollHeroPop_Times",--英雄幸运转盘弹窗次数
    UIMainNotice_Time_Type = "UIMainNotice_Time_Type",--公告时间类型,世界时间或者末世时间
    UILuckyRollHeroShow = "UILuckyRollHeroShow",--英雄幸运转盘英雄显示
    UIVerticalInviteRulesPoped= "UIVerticalInviteRulesPoped",
    DailyPackageListRecordStr = "DailyPackageListRecordStr",
}

--SoundGround =
--{
--    Music = "Music",
--    Effect = "Effect",
--    LoopEffect = "LoopEffect",
--    LoopSound = "LoopSound",
--    Dub = "Dub",
--    Hero = "Hero",
--    Gatling = "Gatling",
--    Barrel = "Barrel",  --不受mixer控制
--    LevelWeatherGroup = "LevelWeatherGroup",
--    WorldScope = "WorldScope", --功能上定义为世界场景内的活动行为音效, 战斗,迁城等
--    TerritoryTriumph_Cooper = "TerritoryTriumph_Cooper", --领地争夺战
--    TerritoryTriumph_Burning = "TerritoryTriumph_Burning", --领地争夺战
--}

SoundAssets =
{
    SU_OpenBuildList = "building/sounds_builder_open_plan",
    SU_BuildUpgrade = "building/sounds_builder_upgrade",

    Music_Effect_Open ="effect_open"	,--打开界面
    Music_Effect_Close ="effect_close"	,--关闭界面
    Music_Effect_Ground ="effect_ground"	,--选中地块
    Music_Effect_Building ="effect_building"	,--选中建筑
    
    Music_Effect_Electric ="effect_electric"	,--收取电力
    Music_Effect_Crystal = "effect_crystal"	,--收取水晶
    Music_Effect_Stamina = "effect_stamina"	,--收取体力--MK_缺音效
    Music_Effect_Water ="effect_water"	,--收取净水
    Music_Effect_Gas = "effect_gas",--收取瓦斯
    Music_Effect_Coin ="effect_coin"	,--收取金币
    Music_Effect_Product1 ="effect_product1"	,--收取农田作物
    Music_Effect_Trained ="city/TrainTroops"	,--收取士兵
    
    Music_Effect_Bill ="effect_bill"	,--交付订单

    Music_Effect_Button ="btn/StereoButtons"	,--点击按钮
	Music_Effect_FlatButton ="btn/FlatButton"	,--图标按钮
	Music_Effect_WarFrenzyTip ="ui/ui_WarFrenzyTip"	,--战争狂热音效	
	
	
    Music_Effect_Gulu_Order_Button ="Effect_Gulu_Order_Button"	,--点击咕噜订单按钮
    Music_Effect_Gulu_Get_Reward ="Effect_Gulu_Get_Reward"	,--点击咕噜订单获得奖励
	
	Music_Effect_MailItem = "ui/dairy_check_book", -- 点击邮件
    
    Music_Effect_Finish ="effect_finished"	,--建造/升级完成
    Music_Effect_Radar ="effect_radar"	,--雷达扫描
    Music_Effect_Alliance ="Effect_Bubble1"	,--联盟帮助(寻求帮助的气泡)
    Music_Effect_Alliance2 ="Effect_Bubble2"	,--联盟帮助(主ui联盟按钮上帮助别人的气泡)
    Music_Effect_Collect_Crystal = "Effect_Collect_Crystal",--收取水晶的音效
    Music_Effect_Train_Soldiers = "Effect_Train_Soldiers",--点击收取士兵部队时播放
    Music_Effect_Train_Tank = "Effect_Train_Tank",--点击收取坦克部队时播放
    Music_Effect_Train_Aircraft = "Effect_Train_Aircraft",--点击收取飞机部队时播放
    Music_Effect_Train_Start1 = "Effect_Train_Start1",--士兵、坦克、飞机开始训练
    Music_Effect_Hero_Upgrade1 = "Effect_Hero_Upgrade1",--英雄进阶时播放
    Music_Effect_Hero_Upgrade2 = "Effect_Hero_Upgrade2",--英雄升级
    Music_Effect_Hero_Upgrade3 = "Effect_Hero_Upgrade3",--英雄突破
    Music_Effect_Science_Finish = "city/ResearchComp",--屏幕顶部弹出 研究完成 的提示时播放
    Music_Effect_Ue_Unclock ="Effect_Ue_Unclock",--弹出解锁某个功能时的窗口时播放
    Music_Effect_Science_Start = "Effect_Science_Start",--点击研究按钮时播放,此时开始研究科技
    Music_Effect_Click_CattleFarm = "Effect_Click_CattleFarm",--点击养牛场时音效
    Music_Effect_Click_OstrichFarm = "Effect_Click_OstrichFarm",--点击鸵鸟场时音效
    Music_Effect_Click_PigFarm = "Effect_Click_PigFarm",--点击猪场时音效
    Music_Effect_Click_Add_Cattle= "Effect_Click_Add_Cattle",--创建牛
    Music_Effect_Click_Add_Ostrich= "Effect_Click_Add_Ostrich",--创建鸵鸟
    Music_Effect_Click_Apartment = "Effect_Click_Apartment",--点击公寓
    Music_Effect_Click_Factory = "Effect_Click_Factory",--点击加工厂的通用音效
    Music_Effect_Click_Army1 = "Effect_Click_Army1",--点击坦克的音效
    Music_Effect_Click_Enemy1 = "Effect_Click_Enemy1",--点击野怪的音效

    Music_Effect_Click_GroundGoods = "Effect_Click_GroundGoods",--点击野外物品的音效
    Music_Effect_Ue_OneGood = "Effect_Ue_OneGood",--在获得奖励界面中，物品单个获得弹出的音效
    Music_Effect_Ue_GetPayReward = "Effect_Ue_GetPayReward",--弹出支付成功界面时的音效
    Music_Effect_Common_GetReward = "Effect_Common_GetReward",--点击任务交付按钮时播放
    Music_Effect_Build_Unclock = "ui/BuildUnlockInterfaceOpen",--播放解锁建筑的特效同时播放
    Music_Effect_Ue_CombatPowerUp = "Effect_Ue_CombatPowerUp",--播放获得星星的动画同时播放
    Music_Effect_Build_SelectCard = "Effect_Build_SelectCard",--点击建筑卡片时播放
    Music_Effect_Common_SelectGoods = "Effect_Common_SelectGoods",--点击仓库内物品时播放
    Music_Effect_Common_ChangeNum = "Effect_Common_ChangeNum",--点击按钮导致数量变化时播放
    Music_Effect_Ue_GetReward = "Effect_Ue_GetReward",--弹出获得奖励窗口时播放
    Music_Effect_Common_SelectTab = "Effect_Common_SelectTab",--点击左侧页签时播放
    Music_Effect_Start_March = "Effect_Start_March",--点击行军出征
    Music_Effect_Start_March_Random = "world/effect_APC_move_",--行军时随机音效
    Music_Effect_APC_Rally_Random = "world/effect_APC_rally_",--行军时随机音效
    Music_Effect_APC_Attack_Random = "world/effect_APC_attack_",--行军时随机音效
    
    Effect_Recruit_Card_Befall = "ui/Effect_fall_card",--"Effect_GetHero_card", --卡牌掉落音效
    Effect_Recruit_Card_Flip1 = "Effect_GetHero_card2", --橙色卡牌翻转音效
    Effect_Recruit_Card_Flip2 = "Effect_GetHero_card1", --紫色卡牌翻转音效
    Effect_Recruit_Card_Flip3 = "Effect_GetHero_card", --普通卡牌翻转音效
    Effect_Recruit_Card_Click = "Effect_GetHero_cardclick", --卡牌点击音效
    Music_Effect_Click_Building = "Effect_Click_Building",--点击建筑
    Music_Effect_Common_FailClick = "Effect_Common_FailClick",--订单非提交点击
    Music_Effect_Speed_Button ="Effect_SpeedUp_goods",--点击加速按钮(未直接完成)
    Music_Effect_Speed_Button2 ="Effect_SpeedUp_goods2",--点击加速按钮(直接完成)

    Music_Effect_Click_FoodFactory = "Effect_Click_FoodFactory",--点击建筑时播放 - 食品工厂 
    Music_Effect_Click_Bakery = "Effect_Click_Bakery",--点击建筑时播放 - 面包店
    Music_Effect_Click_TuckerStore = "Effect_Click_TuckerStore",--点击建筑时播放 - 塔可店
    Music_Effect_Click_Bar = "Effect_Click_Bar",--点击建筑时播放 - 酒吧
    Music_Effect_Click_JewelryStore = "Effect_Click_JewelryStore",--点击建筑时播放 - 珠宝店
    Music_Effect_Put_Formula = "Effect_Put_Formula",--加工厂内确认产物的音效：
    Music_Effect_Click_Ground2 = "Effect_Click_Ground2",--点击农田，如果有农作物时，使用音效
    Music_Effect_Click_Radar = "Effect_Click_Radar",--点击雷达建筑
    Music_Effect_Click_Main_City = "Effect_Click_Main_City",--点击大本
    Music_Effect_Click_Hero_Build = "Effect_Click_Hero_Build",--点击抽卡星门
    Music_Effect_Click_INFANTRY_BARRACK = "Effect_Click_INFANTRY_BARRACK",--点击建筑-机械兵营
    Music_Effect_Click_AIRCRAFT_BARRACK= "Effect_Click_AIRCRAFT_BARRACK",--点击建筑--空港
    Music_Effect_Click_BARRACKS = "Effect_Click_BARRACKS",--点击建筑-军营
    Music_Effect_Click_DRONE = "Effect_Click_DRONE",--点击建筑-无人机平台
    Music_Effect_Click_LIBRARY = "Effect_Click_LIBRARY",--点击建筑--图书馆
    Music_Effect_Click_KONBINI = "Effect_Click_KONBINI",--点击建筑杂货店
    Music_Effect_Click_ALLIANCE_CENTER ="Effect_Click_ALLIANCE_CENTER",--点击建筑-联盟大厅
    Music_Effect_Click_POLICE_STATION = "Effect_Click_POLICE_STATION",--点击建筑-太空警署
    Music_Effect_Click_CAR_BARRACK = "Effect_Click_CAR_BARRACK",--点击建筑-重工厂
    Music_Effect_Click_TRAINFIELD = "Effect_Click_TRAINFIELD",--点击车库
    Music_Effect_Click_COLD_STORAGE= "Effect_Click_COLD_STORAGE",--点击资源仓库
    Music_Effect_Click_SCIENE = "Effect_Click_SCIENE",--点击科研中心
    Music_Effect_Repair = "Effect_Repair",--点击维修
    Music_Effect_Hero_Skill = "Effect_Hero_Skill",--点击主建筑获取金币
    Music_Effect_Enter_Earth_Order = "Effect_Enter_Earth_Order",--点击进入地球订单
    Effect_Exp_FarmSystem = "Effect_Exp_FarmSystem", --玩家获得经验
    Music_Effect_player_bag = "Effect_player_bag",--资源进入背包

    Music_Effect_Golloes_Trader = "Effect_Golloes_trader",
    Music_Effect_Golloes_Warrior = "Effect_Golloes_warrior",
    Music_Effect_Golloes_Explorer = "Effect_Golloes_explorer",
    Music_Effect_Golloes_Worker = "Effect_Golloes_worker",
    Music_Effect_Golloes_Build = "Effect_Golloes_build",
    
    Music_Effect_Npc_Talk_Pop = "city/NPC_talk_pop",

    Herobattlefeild_Rush_comp = "ui/Herobattlefeild_Rush_comp",
    Herobattlefeild_Rush_Flash = "ui/Herobattlefeild_Rush_Flash",
    Herobattlefeild_Rush_Win = "ui/Herobattlefeild_Rush_Win",

    --新手节点音效
    Music_Effect_PlantFlag = "Effect_PlantFlag",--插旗音效
    Music_Effect_Dome_Scan = "Effect_Dome_Scan",--苍穹扫描
    Music_Effect_show_to_plant = "show_to_plant",--播种
    Music_Effect_show_to_water = "show_to_plant",--浇水
    Music_Effect_guide_plane_arrive = "Effect_guide_plane_arrive",--引导飞机第一次落地
    Music_Effect_guide_air_drop = "Effect_guide_air_drop",--引导空投
    Music_Effect_guide_robot = "Effect_guide_robot",--引导机器人
    Music_Effect_guide_migrate = "Effect_guide_migrate",--引导移民
    Music_Effect_guide_ostrich = "Effect_guide_ostrich",--引导出现鸵鸟
    Music_Effect_guide_cattle = "Effect_guide_cattle",--引导出现牛
    Music_Effect_guide_pick_weapon = "Effect_guide_pick_weapon",--引导捡起斧头
    Music_Effect_enter_pve = "Effect_enter_pve",--点击pve按钮入口
    Music_Effect_pve_finish = "Effect_pve_finish",--pve完成
    Music_Effect_Attack = "effect_attack",--行军攻击
    Music_Effect_self_attack_low = "Effect_self_attack_low",
    
    Music_Effect_pve_debuff = "Effect_pve_debuff",--pve debuff
    Music_Effect_pve_buff = "Effect_pve_debuff",--pve buff
    Music_Effect_pve_gunAttack = "Effect_pve_gunAttack",--开枪
    Music_Effect_pve_skill = "Effect_pve_skill",--技能
    Music_Effect_pve_hero_weak = "Effect_pve_hero_weak",--英雄虚弱
    Music_Effect_pve_lost = "Effect_pve_lost",--pve失败
    Music_Effect_pve_call_reward = "Effect_pve_call_reward",--呼叫空投
    Music_Effect_pve_reward_land_lock = "Effect_pve_reward_land_lock",--降落伞
    Music_Effect_hero_box_open = "Effect_hero_box_open",--英雄抽卡宝箱
    Music_Effect_Task_Show = "Effect_Task_Show",--任务弹板出现
    Music_Effect_Guide_Get_New_Hero = "Effect_Guide_Get_New_Hero",--引导获取新英雄
    
    Music_Effect_Golloes_Sort_Card = "Effect_Golloes_Sort_Card",--咕噜翻卡洗牌
    Music_Effect_Golloes_Show_All_Card = "Effect_Golloes_Show_All_Card",--咕噜一键翻卡
    Music_Effect_Golloes_Show_One_Card = "Effect_Golloes_Show_One_Card",--咕噜单张翻卡
    Music_Effect_Golloes_Refresh_Card = "Effect_Golloes_Refresh_Card",--咕噜刷新

    Music_Effect_Building_Get_Exp = "effect_exp",--建筑获取经验
    Music_Effect_Building_Get_Steel = "effect_steel",--建筑获取装备材料
    Music_Effect_APC_Slide = "world/effect_APC_slide",--拖运兵车
    Music_Effect_APC_ATK = "world/effect_APC_ATK",--运兵车攻击特效
    Music_Effect_APC_Skill = "world/effect_APC_Skill",--运兵车技能
    Music_Effect_PickUp_Gift = "effect_pickup_gift",--拾取地面礼包音效
    
    Music_Effect_Lucky_Roll_Click = "Effect_Lucky_Roll_Click",--点击转盘
    Music_Effect_Lucky_Select = "Effect_Lucky_Select",--转盘轮换
    Music_Effect_Hero_Up = "Effect_Hero_Up",--上英雄音效
    Music_Effect_Hero_Down = "Effect_Hero_Down",--下英雄音效

    Music_Effect_pve_trigger_1 = "Effect_pve_trigger_1",--与气泡Trigger交互
    --装备音效
    Music_Effect_Click_Equipment_Upgrade = "Effect_Click_Equipment_Upgrade",--点击“升级”音效
    Music_Effect_Click_Equipment_Take_Off = "Effect_Click_Equipment_Take_Off",--点击“卸下”音效
    Music_Effect_Click_Equipment_Put_On = "Effect_Click_Equipment_Put_On",--点击“装备”音效
    Music_Effect_Click_Open_Equipment_Factory = "Effect_Click_Open_Equipment_Factory",--点击建筑上的图标打开“部件”界面-02
    Music_Effect_Click_Equipment_InUpgrade = "Effect_Click_Equipment_InUpgrade",--升级过程音效
    Music_Effect_Click_Equipment_Quality_Up = "Effect_Click_Equipment_Quality_Up",--提升品质音
    
    --大富翁音效
    City_Chest_Opening = "city/ChestOpening", --打开箱子
    City_Monster_Battle_Preparation = "city/MonsterBattlePreparation",--怪物交战准备音效
    
    --建造列表音效
    City_Click_Build = "city/ClickBuild", --点击建造音效
    City_Build_List_Switching = "city/BuildListSwitching", --建造列表切换音效
    --爱情通讯
    LoveNewsletter_Click = "ui/cell_photo_click", --点击
    LoveNewsletter_Pop = "ui/text_pop_1", --消息气泡弹出
    LoveNewsletter_Pic_Clicked = "ui/photo_click_1", --查看图片
    Build_Put = "building/build_put",

    --挖掘活动
    Music_Effect_dig_blocksDropDown = "ui/Effect_dig_blocksDropDown",
    Music_Effect_dig_digOneBlock1 = "ui/Effect_dig_digOneBlock1",
    Music_Effect_dig_digOneBlock2 = "ui/Effect_dig_digOneBlock2",
    Music_Effect_dig_doorOpenClose = "ui/Effect_dig_doorOpenClose",
    Music_Effect_dig_getFinalReward = "ui/Effect_dig_getFinalReward",

    --丧尸暴君
    TyrantOp = "ui/ui_tyrant_op",

    --联盟
    Musci_Effect_First_Alliance = "ui/first_alliance",
    Music_Effect_GetAllianceReward = "ui/Effect_GetAllianceReward",	--领取联盟小礼物
    UI_Arena_VS = "ui/alliance_donate_crit",

    --礼包
    PackageClick = "ui/ui_packet_small_op",
    PackagePop = "ui/packge_op",

    --改装车
    Car_Upgrade = "ui/car_upgrade",
    Car_Get = "ui/car_get",
    Car_Refit = "ui/car_refit",

    --累充转盘
    Roulette_bingo = "ui/ui_roulette_bingo",
    Roulette_hush = "ui/ui_roulette_hush",
    Roulette_move = "ui/ui_roulette_move",
    Roulette_start = "ui/ui_roulette_start",

    -- 点击建筑
    Click_ALLIANCE_CENTER = "building/build_choose_alliance", --联盟中心
    Click_INFANTRY_BARRACK = "building/build_choose_assaultcamp", --突击训练营
    Click_PUB = "building/build_choose_bar", --酒吧
    Click_KONBINI = "building/build_choose_blackmarket", --黑市
    Click_WareHouse = "building/build_choose_cage", --仓库
    Click_GROCERY_STORE = "building/build_choose_camp", --流浪者营地
    Click_PASTURE_FIELD = "building/build_choose_caravan", --房车
    Click_HERO_DISPATCH_CENTER = "building/build_choose_commission", --派遣任务中心
    Click_MARS_CAMP = "building/build_choose_dining", --餐厅
    Click_HERO_MONUMENT = "building/build_choose_EXP", --英雄丰碑
    Click_FACTION = "building/build_choose_faction", -- 阵营建筑
    Click_STONE = "building/build_choose_farm", --农场
    Click_TRAINFIELD = "building/build_choose_garage", --车库
    Click_EQUIP_FACTORY = "building/build_choose_gear", --装备工厂
    Click_HOSPITAL = "building/build_choose_hospital", --维修站
    Click_Blank = "world/effect_click_blank", -- 点击空白地块
    Click_Steel = "effect_steel", -- 点击钻石矿

    --英雄战场
    Herobattlefeild_guardian_choose = "ui/Herobattlefeild_guardian_choose",--点击秩序卫队大门，未打开
    Herobattlefeild_rose_choose = "ui/Herobattlefeild_rose_choose", --血蔷薇大门，未打开
    Herobattlefeild_wing_choose = "ui/Herobattlefeild_wing_choose", --自由之翼大门，未打开
    Herobattlefeild_open_gate = "ui/Herobattlefeild_open_gate", --首次点击，打开大门时播放
    Herobattlefeild_opened_burning = "ui/Herobattlefeild_opened_burning", -- 点击大门时，如果已经打开过，则在选中时持续播放燃烧循环音效
    Herobattlefeild_opened_choose = "ui/Herobattlefeild_opened_choose", --非首次点击，打开大门时播放


    Click_Butcher = "world/effect_click_butcher", -- 点击电锯屠夫
    Click_Container = "world/effect_click_container", --点击集装箱
    Click_Monster_Female = "world/effect_click_femalezombie_", --点击男小怪
    Click_Monster_Male = "world/effect_click_malezombie_", --点击女小怪
    Click_Gaint = "world/effect_click_gaint", --点击集结怪
    Click_OtherPlayerApc = "world/effect_click_otherplayer_apc", --点击其他玩家的运兵车
    Click_OtherPlayerCity = "world/effect_click_otherplayer_city", --点击其他玩家的城市
    
    Click_Ruin = "world/effect_click_ruin", --点击废墟
    Click_Truck = "world/effect_click_trunk", --点击卡车
    Click_Turret = "world/effect_click_turret", --点击炮台
    Click_Worldboss = "world/effect_click_worldboss", --点击世界boss
    Click_Throne = "world/effect_click_worldcapital", -- 点击王座
    Click_WorldCity = "world/effect_click_worldcity", -- 点击中立城

    Scout_Done = "world/scout_done", -- 侦查完毕,指刚到侦查目标的时候
    Scout_Back = "world/scout_back", -- 侦查返回大本
    
    
    
    --巨龙音效
    UI_canyonclash_op = "ui/ui_canyonclash_op",  --巨龙打开UI
    UI_canyonclash_loop = "Assets/Main/Sound/Effect/ui/ui_canyonclash_loop.ogg",  --巨龙循环
    
    --生存试炼
    UI_MonsterTower_OP = "ui/ui_survivalsaga_op",
    
    
    Click_CONDOMINIUM = "building/build_choose_house", --银行
    Click_BOOK = "building/build_choose_library", --图书馆
    Click_OIL = "building/build_choose_logging", --油井(伐木场)
    Click_Intelligence = "building/build_choose_masion", --情报站(美女别墅)
    Click_EQUIP_SMELTING_FACTORY = "building/build_choose_materialfactory", --熔炼厂
    Click_BARRACKS = "building/build_choose_militarily", --军营
    Click_AIRCRAFT_BARRACK = "building/build_choose_motocamp", --摩托训练营
    Click_SMITHY = "building/build_choose_rally", --联合指挥中心(集结兵力)
    Click_RADAR_CENTER = "building/build_choose_redar", --雷达
    Click_SCIENE = "building/build_choose_research", --科研中心
    Click_CAR_BARRACK = "building/build_choose_shootcamp", --射手训练营
    Click_smelter = "building/build_choose_smelter", --铸造厂
    Click_VILLA = "building/build_choose_tower", --暸望塔
    Click_TRADING_CENTER = "building/build_choose_trade", --贸易中心
    Click_WIND_TURBINE = "building/build_choose_windmill", --风力发电站
    -- 放置建筑
    Put_ALLIANCE_CENTER = "building/build_put_alliance", --联盟中心
    Put_INFANTRY_BARRACK = "building/build_put_assaultcamp", --突击训练营
    Put_PUB = "building/build_put_bar", --酒吧
    Put_KONBINI = "building/build_put_blackmarket", --黑市
    Put_WareHouse = "building/build_put_cage", --仓库
    Put_GROCERY_STORE = "building/build_put_camp", --流浪者营地
    Put_PASTURE_FIELD = "building/build_put_caravan", --房车
    Put_HERO_DISPATCH_CENTER = "building/build_put_commission", --派遣任务中心
    Put_MARS_CAMP = "building/build_put_dining", --餐厅
    Put_HERO_MONUMENT = "building/build_put_EXP", --英雄丰碑
    Put_FACTION = "building/build_put_faction", -- 阵营建筑
    Put_STONE = "building/build_put_farm", --农场
    Put_TRAINFIELD = "building/build_put_garage", --车库
    Put_EQUIP_FACTORY = "building/build_put_gear", --装备工厂
    Put_HOSPITAL = "building/build_put_hospital", --维修站
    Put_CONDOMINIUM = "building/build_put_house", --银行
    Put_BOOK = "building/build_put_library", --图书馆
    Put_OIL = "building/build_put_logging", --油井(伐木场)
    Put_Intelligence = "building/build_put_masion", --情报站(美女别墅)
    Put_EQUIP_SMELTING_FACTORY = "building/build_put_materialfactory", --熔炼厂
    Put_BARRACKS = "building/build_put_militarily", --军营
    Put_AIRCRAFT_BARRACK = "building/build_put_motocamp", --摩托训练营
    Put_SMITHY = "building/build_put_rally", --联合指挥中心(集结兵力)
    Put_RADAR_CENTER = "building/build_put_redar", --雷达
    Put_SCIENE = "building/build_put_research", --科研中心
    Put_CAR_BARRACK = "building/build_put_shootcamp", --射手训练营
    Put_smelter = "building/build_put_smelter", --铸造厂
    Put_VILLA = "building/build_put_tower", --暸望塔
    Put_TRADING_CENTER = "building/build_put_trade", --贸易中心
    Put_WIND_TURBINE = "building/build_put_windmill", --风力发电站

    --危机四伏
    AutorallyOp = "effect_event_autorally_op",
    UIBartershopNoiceOp = "ui/ui_dangerlurks_op",
    UIBartershopNoiceLoop = "Assets/Main/Sound/Effect/ui/ui_dangerlurks_loop.ogg",

    --狂暴首领
    ActWorldBossOP = "ui/ui_furylord_op",

    -- 关卡结算分数-数字跳动
    Music_Effect_level_num_dance = "ui/level_num_dance_couple",
    -- 战力提升
    Music_Effect_PowerUp = "city/PowerUp",
    --建造联盟建筑
    Music_Effect_AllianceBuilding = "building/build_put_logging",
    Effect_Start_Heal = "effect_start_heal",--开始治疗
    
    UI_FireWork = "ui/ui_firework",--烟花
    List_Change = "ui/ui_photo_slap",--滑动列表

    Effect_MoveCityBuildSelect = "world/Effect_city_move_btn", --迁城按钮
    Effect_MoveCityBuildRemove = "world/Effect_city_move_start", --迁城开始
    Effect_MoveCityBuildPutDown = "world/Effect_city_move_trans", --迁城结束
    
    GiftBox_Roll = "ui/effect_color_roll",--娃娃机抽奖

    UI_TerritoryTriumph_OP = "ui/ui_territorytriumph_op", -- 领地争夺战 入场
    UI_TerritoryTriumph_Cooper_Loop = "Assets/Main/Sound/Effect/ui/ui_territorytriumph_cooper_loop.ogg", 
    UI_TerritoryTriumph_Burning_Loop = "Assets/Main/Sound/Effect/ui/ui_territorytriumph_burning_loop.ogg", 
    UI_TerritoryTriumph_APC_ATK = "Assets/Main/Sound/Effect/ui/ui_territorytriumph_apc_atk.ogg", -- 领地争夺战 运兵车攻击
    UI_TerritoryTriumph_Cooper_ATK = "Assets/Main/Sound/Effect/ui/ui_territorytriumph_cooper_atk.ogg", -- 领地争夺战 联盟攻击

    UI_Select = "btn/ui_select", -- 转骰子动画增加效果音
    UI_MonopolyActivityHeroFoot = "sounds_character_footsteps2",

    Effect_LevelClick = "barrel_new/effect_levelclick",
}

--HideCountryFlag =
--{
--    "TW","HK","MO","CN"
--}

--资源缺失打开补充界面的类型
--ResourceLackOpenWinType =
--{
--    HeroLevelup = 1, --英雄升级
--    FurnitureLevelup = 2, --家具升级
--    ModifyCarItemAdd = 3, --改装车主动点击右上角增加道具
--    HeroEquip = 4,
--    SeasonLack = 5,--赛季lack
--    SeasonWorldCost = 6,--赛季外城点击资源
--}

-- datatable 表名
TableName =
{
    -- 连连看
    Theme = "Theme_Config",     -- 主题/元素配置
    C_Sound = "c_sound",        -- 声音配置
}

--EnumDestinationSignalType =
--{
--    None = 0,
--    EmptyGround =1,
--    My =2,
--    Alliance =3,
--    EnemyBuild =4,
--    Other =5,
--    UnReachAble =6,
--    EnemyMarch =7,
--}


--NewQueueType =
--{
--    Default = 0,
--    FootSoldier = 8,--突击队列
--    Hospital = 3,--急救帐篷
--    Science = 6,--科技
--    CarSoldier = 1,--射手队列
--    BowSoldier = 9,--摩托队列
--    ProductEquip = 11, --英雄装备
--    ArmyUpgrade = 34,--士兵升级
--    DomainHospital = 35,--地块医院
--    EquipMaterial = 36,--配件中心材料
--    Field = 39,--农田
--    Barn = 40,--牧场
--    OstrichBarn = 41,
--    CattleBarn = 42,
--    SandWormBarn = 43,
--    TransportRes = 104,--资源运输
--    Equip = 107,--配件中心装备
--    BlastMissile = 111,--爆破飞弹
--    GasMissile = 112,--毒气飞弹
--    FreezingMissile = 113,--急冻飞弹
--    CombustionMissile = 114,--燃烧飞弹
--    IlluminationMissile = 115,--照明飞弹
--
--}

EntityAssets = {
	TroopLineDrag = "Assets/Main/Prefabs/March/TroopLineDrag.prefab",
	CollectGarbageUI = "Assets/Main/Prefabs/March/CollectGarbageUI.prefab",
}

--QueueProductState = {
--    DEFAULT = 0,
--    PASTURE_MATURE = 1,--成熟
--    PASTURE_BY_PRODUCT = 2,--副产品
--}


--ResourceItemType=
--{
--    Farming = 0,--农业
--    Industry = 1,--工业
--}

--TroopIconShowState =
--{
--    Hide = 0,
--    Idle = 1,
--    Broken = 2,
--    Wait = 3,
--
--}

---@class ItemSpdMenu
--ItemSpdMenu =
--{
--    ItemSpdMenu_ALL = 1, --——城建，造兵，科技，造陷阱，治疗
--    ItemSpdMenu_Troop = 2,  --——行军
--    ItemSpdMenu_Soldier = 3, --——造兵
--    ItemSpdMenu_Heal = 4, -- 治疗
--    ItemSpdMenu_Trap = 5, -- 造陷阱
--    ItemSpdMenu_Science = 6, -- 科技
--    ItemSpdMenu_City = 7, -- 城建
--    ItemSpdMenu_DuanZao = 8, --锻造
--    ItemSpdMenu_Helicopter = 9, --直升机
--    ItemSpdMenu_Missile = 10, --导弹
--    ItemSpdMenu_RemoveCity = 11, -- 拆除建筑
--    ItemSpdMenu_Siege_Heal = 20, -- 征服岛治疗
--    ItemSpdMenu_Desert_Heal = 21,--沙漠中治疗
--    ItemSpdMenu_Fix_Ruins =22,--修复废墟
--    ItemSpdMenu_HeroEquip = 23,-- 英雄装备
--    ItemSpdMenu_GirlCollect = 24, --宝箱拾取
--}

--新队列状态
NewQueueState =
{
    Free = 0,--空闲
    Prepare = 1,--准备
    Work = 2,--工作
    Finish = 3,--完成（状态为客户端倒计时结束但未向服务器发送队列消息的状态）
}

--FarmStateType=
--{
    --None = -1,
    --Plant= 0,--种植
    --Harvest =1,--收割
    --Feed =2,--喂养
    --HarvestSecond =3,--获取副产品 
    --Irrigate = 4,--灌溉
--}
BuildType=
{
    Normal = 0, --一般建筑
    Main = 1,--主建筑
    Second = 2,--辅建筑
    Third = 3,--次建筑
}
BuildingStateType =
{
    Normal = 0, --普通
    Upgrading = 1, --升级中
    FoldUp = 2,     --收起
    PAUSE_Upgrading = 3 ,--暂停升级
}

--信用值是否限制玩家登录
---@class CreditStateTypel
--CreditStateType =
--{
--    Normal = 0,
--    Restrict = 1
--}

--EffectLocalType =
--{
--    Num = 1,              --数字
--    Time = 2,             --时间
--    Percent = 3,          --百分比
--    Dialog = 4,           --多语言
--    PositiveNum = 5,      --正数
--    NegativeNum = 6,      --负数
--    PositiveTime = 7,     --正时间
--    NegativeTime = 8,     --负时间
--    PositivePercent = 9,  --正百分比
--    NegativePercent = 10, --负百分比
--}

--EffectLocalTypeInEffectDesc = {
--    Num = 0,--数值
--    Percent = 1,--百分比
--    Thousandth = 2,--千分比
--    NegativePercent = 4,--负百分比
--}

--UIMainLeftButtonType = {
--    None = 0,
--    March = 1,      --行军
--}

--UIMainLeftButtonTypeSortList = {
--    UIMainLeftButtonType.March,
--}

--UIMainTopResourceChangeType = {
--    Normal = 0,           --正常状态，被Normal层页面压住
--    ChangeLevel = 1,      --高层级状态，可以压住Normal层页面
--}

--UIGiftTypeButtonType = {
--    Hot = "Hot",           --热销礼包
--    Diamond = "Diamond",       --钻石
--}

--BattleType =
--{
--    None =0,
--    Formation =1,--编队攻击  PVP
--    Building =2,--建筑攻击
--    Turret =3,--箭塔攻击
--    Monster =4, -- 野怪
--    RallyFormation=5,--集结编队攻击
--    Boss =6,--集结怪
--    City = 7,--大本  打玩家城  PVP
--    Road = 8, -- 路
--    Explore = 9, -- 探索点攻击
--    ALLIANCE_NEUTRAL_CITY = 10, -- 联盟中立城  打中立城
--    ALLIANCE_OCCUPIED_CITY = 11, -- 联盟占领城
--    ELITE_FIGHT_MAIL = 12,--冠军对决
--    PVE_MARCH = 13, -- PVE玩家编队
--    PVE_MONSTER = 14, -- PVE怪物
--    ACT_BOSS =15, -- 活动boss  世界BOSS  PVE
--    PUZZLE_BOSS = 16,
--    CHALLENGE_BOSS = 17,--挑战BOSS
--    Desert = 18,--地块
--    TRAIN_DESERT = 19,--19 训练地块
--    ALLIANCE_BUILDING = 20,--20 联盟建筑
--    NpcCity = 21,--NPC大本
--    ALLIANCE_CITY_GUARD = 22, --22 联盟城守备军
--    CITY_GUARD = 23, --23 玩家大本守备军
--    ALLIANCE_BUILD_GUARD = 24, --24 联盟建筑守备军
--    NPC_CITY_GUARD = 25, --25 NPC城市守备军
--    BLACK_KNIGHT = 26, --26 黑骑士活动战报
--    THRONE_ARMY = 27, --//27 王座军队
--    CROSS_WORM = 28, -- 跨服虫洞
--    AllianceBoss = 30, -- 联盟boss
--    DRAGON_BUILDING = 33,-- 巨龙建筑
--    Train_March = 36,--劫镖
--    ALLIANCE_THRONE_TOWER = 37, --炮台
--    DRAGON_BOSS = 38, --巨龙Boss
--    ACT_RESOURCE = 39,
--}

--PlayerDesertAttr =
--{
--    SelfCount = 1,
--    OtherCount = 2,
--    Buff = 3,
--    ResSpeedGas = 4,
--    ResNum  = 5,
--    ResSpeedFlint = 6,
--    Force = 7,
--    ForceRank = 8,
--    Ground = 9,
--}

--UIBagBtnType =
--{
--    Hot = 0,
--    War = 1,
--    Buff = 2,
--    Resource = 3,
--    Other = 4,
--}

--GoToType =
--{
--    None = -1,
--    GotoBuilding = 0,
--    GotoUI = 1
--
--}

--UIMainFunctionInfo =
--{
--    None = 0,
--    Report = 1,--报表
--    Goods = 2,--物品
--    Store = 3,--商城
--    Info = 4,--个人信息
--    --Alliance =5,--联盟
--    Search =6,--查找
--    Task = 7,--任务
--    Activity =8,--活动中心
--    Hero = 9, --英雄
--    Mail =10, --邮件
--    Chat = 11, --聊天
--    Build = 12, --建筑
--    Science =13, --科技
--    Trade =14, --交易中心
--    Position =15, --收藏坐标
--    radarAlarm =16, --雷达警报
--    FastBuild = 17, --快捷建造
--    Warning = 18,--New新警报
--    ChapterTask = 19,
--    AllianceTaskShare = 20,
--}

--ScienceTab =
--{
--    Resource = 1,
--    Fight = 2,
--    --联盟
--    AllianceDevelop = 101,
--    AllianceFight = 102,
--    AllianceDefense = 103,
--    AllianceBuild = 104,
--
--}

--资源部队采集对应科技
--ResourceTypeScience =
--{
--    [ResourceType.Metal] = 731000,
--    [ResourceType.Oil] = 751000,
--    [ResourceType.Water] = 732000,
--}

--ResourceTypeTxt =
--{
--    [RewardType.METAL] = 722034,
--    [RewardType.OIL] = 100014,
--    [RewardType.WATER] = 100546,
--    [RewardType.ELECTRICITY] = 100002,
--    [RewardType.FLINT] = 110353,
--    [RewardType.MONEY] = 100000,
--    [RewardType.GOLD] = 100183,
--    [RewardType.SAPPHIRE] = 390967,
--    [RewardType.PVE_POINT] = 400011,
--    [RewardType.DETECT_EVENT] = 140073,
--    [RewardType.FORMATION_STAMINA] = 100510,
--    [RewardType.WOOD] = 180265,
--    [RewardType.PVE_STAMINA] = 100510,
--    [RewardType.PVE_STAMINA] = 100510,
--    [ResourceType.Gold] = 100183,
--    [RewardType.EXP] = 100180,
--}

--UIScienceSortList =
--{
--    ScienceTab.Resource,
--    ScienceTab.Fight,
--}

--ScienceResearchUseGold =
--{
--    NoUseGold = 0,--不使用钻石升级
--    UseGold = 1,--使用钻石秒时间升级
--    Free = 2,--免费升级(英雄加持)
--    Speed = 3, --资源足够，免费时间+道具覆盖所需时间
--}

--IsGold =
--{
--    NoUseGold = 0,--不使用钻石
--    UseGold = 1,--使用钻石
--}

---@class AllianceButtonType
--AllianceButtonType =
--{
--    None =0,
--    AllianceBattle = 1,-- 盟友情报
--    AllianceBuilding=2,
--    AllianceHelp =3,--联盟帮助
--    AllianceGift =4,--联盟礼物
--    AllianceSalary = 5,
--    AllianceScience =6,--联盟科技
--    AllianceShop =7,--联盟商店
--    AllianceSetting =8,
--    AllianceList =9,
--    AllianceRank =10,
--    AllianceCheck =11,
--    AllianceInvite =12,
--    AllianceQuit =13,
--    AllianceMail =14,
--    AllianceAnnounce= 15,
--    AllianceMember = 16,
--    EverydayTask = 17,
--    AllianceCity = 18,--联盟建筑
--    BecomeLeader = 19,--成为盟主
--    AlLeaderElect = 20,--选举
--    AllianceTask = 21,--里程碑
--    AllianceMoveInvite = 22, --移动邀请
--    AllianceMerge = 23,
--    AllianceLeaderReward = 24, --管理福利
--    AllianceRally = 25, --集结
--    AllianceVote = 26,
--    AllianceLog = 27,
--    AllianceFortress = 28,
--}

--PLayerInfoButtonType =
--{
--    None =0,
--    MoreMessage =1,
--    RankList =2,
--    Setting =3,
--    ActivityCenter = 4,
--    Account = 5,
--    Faq = 6,
--    Talk=7,--聊天
--    Alliance = 8,--联盟
--    Citybuff = 9,
--    PhotoWall = 10,
--}

--SoldierType =
--{
--    FootSoldier = 1,--机器人兵
--    BowSoldier = 2,--飞机兵
--    CarSoldier = 3,--坦克兵
--}

---@class BuildingTypes
BuildingTypes =
{
    FUN_BUILD_MAIN = 400000; -- 基地 总部大楼 (限制其他建筑的等级上限，本身受玩家殖民等级限制，兵力上限)
    FUN_BUILD_BUSINESS_CENTER = 401000; -- 商业中心 (提供居民订单列表入口、钻石商店、同盟援助商队)
    FUN_BUILD_SCIENE = 403000; -- 科研中心 (研究科技)
    FUN_BUILD_SMITHY = 407000; -- 联合指挥中心 (集结兵力)
    FUN_BUILD_CONDOMINIUM = 409000; -- 银行 (提供工人数量、居民（工人）订单气泡)
    FUN_BUILD_HOSPITAL = 411000; -- 维修站 (维修武器)
    FUN_BUILD_STONE = 412000; -- 采矿场 (采集面板资源矿)
    FUN_BUILD_OIL = 413000; -- 油井 (采集面板资源原油)
    FUN_BUILD_RADAR_CENTER = 417000; --雷达中心
    FUN_BUILD_ARROW_TOWER = 418000; -- 炮台 (防御物)
    FUN_BUILD_MASTERY_ARROW_TOWER = 419000; -- 专精炮台 (防御物)
    
    FUN_BUILD_CAR_BARRACK = 423000;--坦克制造厂 (生产车辆类的武器) 射手训练营
    FUN_BUILD_INFANTRY_BARRACK = 424000;--机器人工厂 (生产步兵类的武器) 突击训练营
    FUN_BUILD_AIRCRAFT_BARRACK = 425000;--飞机制造厂 (生产飞行类的武器) 摩托训练营
    
    FUN_BUILD_TRAINFIELD_1 = 427000; --兵营1
    FUN_BUILD_TRAINFIELD_2 = 793000; --兵营2
    FUN_BUILD_TRAINFIELD_3 = 794000; --兵营3
    FUN_BUILD_TRAINFIELD_4 = 795000; --兵营4
    FUN_BUILD_WATER = 432000;--抽水站 (采集面板资源水)
    FUN_BUILD_MARKET = 435000;--火箭发射场 交易中心 (火箭发射点，贸易，更换火箭皮肤)
    FUN_BUILD_ROAD = 436000;--路 (由于火星地面土质较松、需要一种特殊的路)
    FUN_BUILD_ELECTRICITY_STORAGE = 437000;--蓄电站 (储存电，通过科技解锁生产高能电池)  ##废弃建筑
    FUN_BUILD_WATER_STORAGE = 438000;--蓄水罐 (存放水)
    FUN_BUILD_OIL_STORAGE = 439000;--储油罐 (储存原油)
    FUN_BUILD_IRON_STORAGE = 441000;--矿石仓库 (储存矿石)
    FUN_BUILD_WIND_TURBINE = 444000;--风力电站 (全天工作，初级电站，风沙时产量提升)
    FUN_BUILD_SOLAR_POWER_STATION = 447000; -- 太阳能发电站 (在白天工作，初级电站)
    FUN_BUILD_DRONE = 477000; -- 无人机平台 (提供建造队列)
    FUN_BUILD_RECYCLE_BIN = 300000,-- 回收站(现在押镖活动入口占用)
    FUN_BUILD_VILLA = 700000; -- 别墅 (提升工程师数量，提升居民订单所需物品数量)
    APS_BUILD_FARM = 701000;--火星农场 (消耗水种植各种植物给居民订单，通过科技解锁植物种类)
    APS_BUILD_FARM_FIELD = 702000;--火星农场的农田 (消耗水种植各种植物给居民订单，通过科技解锁植物种类)
    APS_BUILD_PASTURE = 703000; -- 火星牧场 (消耗作物养殖各种动物，通过科技解锁动物种类)
    APS_BUILD_PASTURE_FIELD = 704000; -- 火星牧场的牧场 (消耗作物养殖各种动物，通过科技解锁动物种类)
    FUN_BUILD_FACTORY_STONE = 705000; -- 石头加工厂
    FUN_BUILD_METALLURGY = 706000; -- 冶金厂 (消耗矿石生产各种金属，通过科技解锁多种矿类产品)
    FUN_BUILD_FOOD = 707000; -- 食品厂 (消耗动植物加工二级产品，科技解锁高级配方)  ##甜品店
    FUN_BUILD_OIL_REFINERY = 708000; -- 炼油厂 (分馏原油获得各种油，通过科技解锁多种化工产品)
    FUN_BUILD_INTEGRATED_FACTORY = 709000; -- 综合工厂 (生产工业类二级产品，通过科技解锁产物种类)  ##废弃建筑，弃用
    FUN_BUILD_ORE_FACTORY_1 = 709000; -- 晶石工厂1
    FUN_BUILD_ORE_FACTORY_2 = 705000; -- 晶石工厂2
    FUN_BUILD_TRADING_CENTER = 710000; -- 贸易中心 (地球火箭停靠点，提供地球订单、黑市商人)
    FUN_BUILD_FOODSHOP = 711000; -- 餐厅 (生产食品类的三级产物，提供居民订单)  ##面包店
    FUN_BUILD_PRINT_FACTORY = 712000; -- 3D打印厂 (生产工业类的三级产物，提供地球订单和贸易)
    FUN_BUILD_INFORMATION_CENTER = 713000; -- 信息中心 (新闻玩法、服务器大事、纪念碑)
    FUN_BUILD_COLD_STORAGE = 714000; -- 冷库 (冷库、用来放置水果果蔬等需要保鲜的产品)
    FUN_BUILD_COMPREHENSIVE_STORAGE = 715000; -- 综合仓库 (大型物流仓库可以放置各种商品)
    FUN_BUILD_DEFENCE_CENTER =716000;--备战中心
    FUN_BUILD_FOOD_1 = 717000;--食品厂1 ##快餐店
    FUN_BUILD_FOOD_2 = 718000;--食品厂2 ##小吃店
    APS_BUILD_PASTURE_OSTRICH = 719000;---鸵鸟农场
    APS_BUILD_PASTURE_CATTLE = 720000;---奶牛农场
    APS_BUILD_PASTURE_SANDWORM = 721000;---沙虫农场
    APS_BUILD_PUB = 722000; --星际酒馆
    FUN_BUILD_FORGE = 429000; --装备制造--配件工厂
    FUN_BUILD_ELECTRICITY = 431000; --火力发电厂
    FUN_BUILD_HONOR_HALL = 446000;-- 荣誉大厅
    FUN_BUILD_BUILDING_CENTER = 448000; -- 建造中心
    FUN_BUILD_OFFICER = 483000;-- 英雄大厅
    FUN_BUILD_RECHARGE_GARAGE = 445000; -- 充值获得的车库
    FUN_BUILD_DOME = 449000;--苍穹
    FUND_BUILD_ALLIANCE_CENTER = 402000;--联盟太空中心
    APS_BUILD_WORMHOLE_MAIN = 791000;--虫洞（主
    APS_BUILD_WORMHOLE_SUB = 792000;--虫洞（副
    APS_BUILD_WORMHOLE_EXPORT = 792001, --虫洞出口
    FUN_BUILD_TEMP_WIND_POWER_PLANT = 796000, --新手引导风车
    FUN_BUILD_PVE_FACTORY = 723000, --怪物资源加工厂 ##蛋糕店
    FUN_BUILD_GROCERY_STORE = 724000, --咕噜营地
    FUN_BUILD_SCIENCE_PART = 725000,--第二科研中心
    FUN_BUILD_BARRACKS = 797000,--军营
    FUN_BUILD_POLICE_STATION = 726000,--警察局

    FUN_BUILD_MARS_CAMP = 727000,-- 餐厅
    FUN_BUILD_LIBRARY= 728000,--公寓
    FUN_BUILD_KONBINI = 729000,--小卖部
    FUN_BUILD_GREEN_CRYSTAL = 730000,--小生产绿水晶建筑
    FUN_BUILD_HERO_MONUMENT = 731000,--英雄丰碑
    FUN_BUILD_HERO_BOUNTY = 732000,--英雄赏金工会
    FUN_BUILD_HERO_OFFICE = 733000,--英雄议会
    FUN_BUILD_HERO_BAR = 734000,--英雄酒吧
    WORM_HOLE_CROSS =735000, --跨服虫洞
    FUN_BUILD_OUT_WOOD =736000, --伐木场(生产资源道具)
    FUN_BUILD_OUT_STONE =737000, --采石场(生产资源道具)
    
    FUN_BUILD_BOOK = 738000,--真正的图书馆

    --世界上的建筑
    SEASON_DESERT_RESISTANCE_1 = 741000,--抗性建筑1
    SEASON_DESERT_MAX_DESERT_1 = 742000,--地块上限建筑1
    SEASON_DESERT_MAX_FORMATION_SIZE_1 = 743000,--出征上限建筑1
    SEASON_DESERT_ARMY_ATTACK_1 = 744000,--部队攻击建筑1
    SEASON_DESERT_ARMY_DEFEND_1 = 745000,--部队防御建筑1
    SEASON_DESERT_RESISTANCE_2 = 746000,--抗性建筑2
    SEASON_DESERT_RESISTANCE_3 = 747000,--抗性建筑3
    SEASON_DESERT_RESISTANCE_4 = 748000,--抗性建筑4
    SEASON_DESERT_MAX_DESERT_2 = 749000,--地块上限建筑2
    SEASON_DESERT_MAX_FORMATION_SIZE_2 = 750000,--出征上限建筑2
    SEASON_DESERT_ARMY_ATTACK_2 = 751000,--部队攻击建筑2
    SEASON_DESERT_ARMY_DEFEND_2 = 752000,--部队防御建筑2
    SEASON_DESERT_BUILD_DRONE_1 = 753000,--世界工作台1
    SEASON_DESERT_BUILD_DRONE_2 = 754000,--世界工作台2
    
    ALLIANCE_MARK_13_FAKE = 308000, --联盟集结FakeModel

    --联盟矿
    ALLIANCE_RES_1 = 10000,
    ALLIANCE_RES_2 = 11000,
    ALLIANCE_RES_3 = 12000,
    ALLIANCE_RES_4 = 20000,
    ALLIANCE_RES_5 = 21000,
    ALLIANCE_RES_6 = 22000,
    ALLIANCE_RES_7 = 30000,
    ALLIANCE_RES_8 = 31000,
    ALLIANCE_RES_9 = 32000,
    --联盟建筑
    ALLIANCE_FLAG_BUILD = 40000,--联盟旗帜
    ALLIANCE_CENTER_1 = 41000,--联盟中心1
    ALLIANCE_CENTER_2 = 42000,--联盟中心2
    ALLIANCE_CENTER_3 = 43000,--联盟中心3
    ALLIANCE_CENTER_4 = 44000,--联盟中心4
    ALLIANCE_CENTER_2_1 = 42001,--联盟中心2另一个ID。。。
    ALLIANCE_CENTER_3_1 = 43002,--联盟中心3另一个ID。。。
    ALLIANCE_CENTER_4_1 = 44003,--联盟中心4另一个ID。。。

    ALLIANCE_FRONT_BUILD_1 = 45000,--前线阵地1
    ALLIANCE_FRONT_BUILD_2 = 46000,--前线阵地2
    ALLIANCE_FRONT_BUILD_3 = 47000,--前线阵地3

    FUN_BUILD_Reserve = 739000,--预备兵营
    FUN_BUILD_BAUBLE = 740000, -- 装饰公司
    
    --Survival--
    Survival_ShabbyTruck = 100000, -- 破旧的卡车
    Survival_Cabinet = 101000, --储物柜
    Survival_Cabinet_Newbie = 147000, --新手期储物柜
    Survival_Hearth = 102000, --灶台
    Survival_AirDryRack = 103000, --风干架
    Survival_WaterCollector = 104000, --集水器
    Survival_WoodTable = 105000, --木工台
    Survival_VegetableFarm = 106000, --菜园
    Survival_LeatherRack = 107000, --制皮架
    Survival_MasonryTable = 108000, --石工台
    Survival_ClothTable = 109000, --布工台
    Survival_MeltingPot = 110000, --熔炉
    Survival_ArrowTower  = 120000, -- 箭塔
    Survival_Fence1  = 121000 , -- 栅栏
    Survival_Fence2  = 123000 , -- 栅栏
    Survival_Fence3  = 124000 , -- 栅栏
    Survival_Fence4  = 125000 , -- 栅栏
    Survival_Fence5  = 128000 , -- 栅栏
    Survival_Fence6  = 129000 , -- 栅栏
    
    Survival_WatchTower  = 122000 , -- 瞭望塔
    Survival_Radio  = 131000 , -- 无线电
    Survival_Bed = 134000, -- 床
    Survival_WeaponFactory = 135000, -- 武器工坊
    Survival_EquipFactory = 136000, -- 装备工坊
    Survival_Mail = 137000, -- 邮箱
    Survival_Home = 138000, -- 家
    Survival_Bar = 139000, -- 酒吧
    Survival_Bathe = 140000, --洗澡
    Survival_WareHouse = 438000, --SLG仓库 
    Survival_Restaurant = 301000, --餐厅 
    Survival_Home_Floor = 139000, --家的地板 
    Survival_Home_Wall = 148000, --家的墙
    Survival_Intelligence = 302000, --情报站
    FUN_BUILD_DOOR = 779000, --大门
    SUB_BUILD_BED = 155000, -- 大本中的床
    LW_BUILD_SOFA = 184000, --沙发
    SUB_BUILD_WEAPON = 183000, -- 大本中的武器库
	
	LW_BUILD_TRUCK_STATION_1 = 427000, --卡车站1
	LW_BUILD_TRUCK_STATION_2 = 793000, --卡车站2
	LW_BUILD_TRUCK_STATION_3 = 794000, --卡车站3
	LW_BUILD_TRUCK_STATION_4 = 795000, --卡车站4

    DS_EQUIP_FACTORY = 811000, -- 装备工厂
    DS_EQUIP_SMELTING_FACTORY = 812000, -- 熔炼厂
    DS_EQUIP_MATERIAL_FACTORY = 813000, -- 材料加工厂
    DS_EQUIP_SMELTING_FACTORY_2 = 814000, -- 熔炼厂

    HERO_DISPATCH_CENTER = 303000, -- 派遣任务中心
    BUILD_FACTION_1 = 304000, -- 黎明塔(破晓之翼)
    BUILD_FACTION_2 = 305000, -- 钢铁工厂(秩序卫队)
    BUILD_FACTION_3 = 306000, -- 毒雾花园(血蔷薇)
    GARAGEREFIT_DRONE = 307000, -- 无人机，之前的车库，现在是四合一
    HEROSMALL_TALENT_CENTER = 310000, -- 人才中心(英雄小人总管理建筑)
}

--FakeBuildingTypes = {
--    NOTICE_BUILD = 1,--公告
--}

--BuildingSpecialGroupType =  {
--    WORM_HOLE_B = 1000,--虫洞B口
--    WORM_HOLE_CROSS = 1001,--虫洞C口
--    EDEN_WORM_HOLE_B_1 = 1002,--伊甸园虫洞B口1
--    EDEN_WORM_HOLE_B_2 = 1003,--伊甸园虫洞B口2
--    EDEN_WORM_HOLE_B_3 = 1004,--伊甸园虫洞B口3
--}

--BuildingSpecialGroupList =  {
--    [BuildingSpecialGroupType.WORM_HOLE_B] = {BuildingTypes.APS_BUILD_WORMHOLE_SUB},
--    [BuildingSpecialGroupType.WORM_HOLE_CROSS] = {BuildingTypes.WORM_HOLE_CROSS},
--    [BuildingSpecialGroupType.EDEN_WORM_HOLE_B_1] = {BuildingTypes.EDEN_WORM_HOLE_1,BuildingTypes.EDEN_WORM_HOLE_SENIOR_1},
--    [BuildingSpecialGroupType.EDEN_WORM_HOLE_B_2] = {BuildingTypes.EDEN_WORM_HOLE_2,BuildingTypes.EDEN_WORM_HOLE_SENIOR_2},
--    [BuildingSpecialGroupType.EDEN_WORM_HOLE_B_3] = {BuildingTypes.EDEN_WORM_HOLE_3,BuildingTypes.EDEN_WORM_HOLE_SENIOR_3},
--}

--高级虫洞组
--BuildingSeniorEdenWormHoleGroup =  {
--    BuildingTypes.EDEN_WORM_HOLE_SENIOR_1,
--    BuildingTypes.EDEN_WORM_HOLE_SENIOR_2,
--    BuildingTypes.EDEN_WORM_HOLE_SENIOR_3,
--}

---巨龙建筑类型
---@class DragonBuildingTypes
--DragonBuildingTypes =
--{
--    DragonEmptyBuild = 10000,  --医疗站
--    DragonWarBuild = 10010,  --军事基地
--    DragonCenterBuild = 10020,  --能源站
--    DragonAllianceFlagSelf = 10030,  --联盟信标
--    DragonAllianceFlagOther = 10040, --联盟信标
--    DragonHospitalBuild = 10050,  --净水厂
--    DragonBoss = 10060,  --巨龙boss
--}

---巨龙Boss状态
---@class DragonBossState
--DragonBossState =
--{
--    Hide = 0, --隐藏
--    Born = 2, --出生
--    Dead = 3, --死亡
--}

--DragonPlayerState = --0未指派 1主力 2替补
--{
--    None = 0,
--    Main = 1,
--    Sub =2,
--}

ServerType =
{
    NORMAL = 0,
    DRAGON_BATTLE_FIGHT_SERVER = 8,
    EDEN_SERVER = 9,
    CROSS_THRONE = 10,
}

--EdenCamp =
--{
--    DEFAULT = 0,
--    NORTH = 1, --北方阵营
--    SOUTH = 2, --南方阵营
--}

--EdenAreaType =
--{
--    DEFAULT = 0,
--    FIGHT_AREA = 1, -- 1 战斗区域
--    NORTH_BORN_AREA = 2, --2 北方出生区域
--    SOUTH_BORN_AREA = 3, --3 南方出生区域
--}

--PassType =
--{
--    DEFAULT = 0,
--    NONE_CITY_PASS = 1,
--    ALLIANCE_CITY_PASS = 2,
--}

--WorldCityType =
--{
--    AllianceCity = 0,--联盟城
--    AlliancePass = 1,--关卡
--    StrongHold = 2,--据点
--}

--赛季建筑 在世界上的建筑 
--WorldSeasonBuild = 
--{
--    --世界上的建筑
--    [BuildingTypes.SEASON_DESERT_RESISTANCE_1] = 1,
--    [BuildingTypes.SEASON_DESERT_MAX_DESERT_1] = 2,
--    [BuildingTypes.SEASON_DESERT_MAX_FORMATION_SIZE_1] = 3,
--    [BuildingTypes.SEASON_DESERT_ARMY_ATTACK_1] = 4,
--    [BuildingTypes.SEASON_DESERT_ARMY_DEFEND_1] = 5,
--    [BuildingTypes.SEASON_DESERT_RESISTANCE_2] = 6,
--    [BuildingTypes.SEASON_DESERT_RESISTANCE_3] = 7,
--    [BuildingTypes.SEASON_DESERT_RESISTANCE_4] = 8,
--    [BuildingTypes.SEASON_DESERT_MAX_DESERT_2] = 9,
--    [BuildingTypes.SEASON_DESERT_MAX_FORMATION_SIZE_2] = 10,
--    [BuildingTypes.SEASON_DESERT_ARMY_ATTACK_2] = 11,
--    [BuildingTypes.SEASON_DESERT_ARMY_DEFEND_2] = 12,
--    [BuildingTypes.SEASON_DESERT_BUILD_DRONE_1] = 13,
--    [BuildingTypes.SEASON_DESERT_BUILD_DRONE_2] = 14,
--}

--HeroCamp =
--{
--    All = -1,
--    NEW_HUMAN = 0,
--    MAFIA = 1,--血蔷薇
--    UNION=2,--破晓之翼
--    ZELOT = 3,--秩序卫队
--}
--HeroCampBuildToCamp =
--{
--    [BuildingTypes.BUILD_FACTION_1] = HeroCamp.UNION,
--    [BuildingTypes.BUILD_FACTION_2] = HeroCamp.ZELOT,
--    [BuildingTypes.BUILD_FACTION_3] = HeroCamp.MAFIA,
--}
--HeroCampCampToBuild =
--{
--    [HeroCamp.UNION] = BuildingTypes.BUILD_FACTION_1,
--    [HeroCamp.ZELOT] = BuildingTypes.BUILD_FACTION_2,
--    [HeroCamp.MAFIA] = BuildingTypes.BUILD_FACTION_3,
--}

--CampImage = {
--    [HeroCamp.NEW_HUMAN] = "Assets/Main/Sprites/UI/Common/ui_camp_0.png",
--    [HeroCamp.MAFIA]     = "Assets/Main/Sprites/UI/UIHeroBattlefield/UIHeroscape_icon_camp01.png",
--    [HeroCamp.UNION]     = "Assets/Main/Sprites/UI/UIHeroBattlefield/UIHeroscape_icon_camp02.png",
--    [HeroCamp.ZELOT]     = "Assets/Main/Sprites/UI/UIHeroBattlefield/UIHeroscape_icon_camp03.png",
--}

--HeroCampName = {
--    [HeroCamp.MAFIA]     = 158002,
--    [HeroCamp.UNION]     = 158003,
--    [HeroCamp.ZELOT]     = 158005
--}

--加工厂类建筑
--FactoryBuild =
--{
--    BuildingTypes.FUN_BUILD_FOODSHOP,
--    BuildingTypes.FUN_BUILD_METALLURGY,
--    BuildingTypes.FUN_BUILD_FOOD,
--    BuildingTypes.FUN_BUILD_OIL_REFINERY,
--    BuildingTypes.FUN_BUILD_ORE_FACTORY_1,
--    BuildingTypes.FUN_BUILD_ORE_FACTORY_2,
--    BuildingTypes.FUN_BUILD_FOOD_1,
--    BuildingTypes.FUN_BUILD_FOOD_2,
--    BuildingTypes.FUN_BUILD_PVE_FACTORY,
--    --BuildingTypes.APS_BUILD_FARM,
--
--    BuildingTypes.Survival_Hearth,
--    BuildingTypes.Survival_AirDryRack,
--    BuildingTypes.Survival_VegetableFarm,
--    BuildingTypes.Survival_WaterCollector,
--    BuildingTypes.Survival_WoodTable,
--    BuildingTypes.Survival_VegetableFarm,
--    BuildingTypes.Survival_LeatherRack,
--    BuildingTypes.Survival_MasonryTable,
--    BuildingTypes.Survival_ClothTable,
--    BuildingTypes.Survival_MeltingPot,
--    BuildingTypes.FUN_BUILD_FACTORY_STONE,
--    --BuildingTypes.APS_BUILD_FARM,
--    BuildingTypes.Survival_Restaurant, --餐厅
--    BuildingTypes.FUN_BUILD_RECYCLE_BIN, --回收站
--}

--SurvivalFenceBuild = 
--{
--    BuildingTypes.Survival_Fence1,
--    BuildingTypes.Survival_Fence2,
--    BuildingTypes.Survival_Fence3,
--    BuildingTypes.Survival_Fence4,
--    BuildingTypes.Survival_Fence5,
--    BuildingTypes.Survival_Fence6,
--}

--ItemProductBuild = 
--{
--    BuildingTypes.FUN_BUILD_OUT_WOOD,  -- Survival 伐木场
--    BuildingTypes.FUN_BUILD_OUT_STONE, -- Survival 采石场
--    BuildingTypes.FUN_BUILD_HERO_MONUMENT, -- 英雄丰碑
--    BuildingTypes.FUN_BUILD_LIBRARY,   -- Survival 民居(公寓)
--    BuildingTypes.FUN_BUILD_WATER,     -- Survival 农田(抽水站)
--    BuildingTypes.DS_EQUIP_MATERIAL_FACTORY,     -- 
--    BuildingTypes.DS_EQUIP_SMELTING_FACTORY,     --
--    BuildingTypes.DS_EQUIP_SMELTING_FACTORY2,    -- 
--}


--兵营类建筑
--BarracksBuild =
--{
--    BuildingTypes.FUN_BUILD_CAR_BARRACK,
--    BuildingTypes.FUN_BUILD_INFANTRY_BARRACK,
--    BuildingTypes.FUN_BUILD_AIRCRAFT_BARRACK,
--}

--QualityTrainBigBgPath={
--    [1]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_hui.png",
--    [2]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_lv.png",
--    [3]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_lan.png",
--    [4]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_zi.png",
--    [5]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_cheng.png",
--    [6]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_cheng.png",
--    [10]="Assets/Main/UITexture/UILWRailway/zyf_cjmy_cheng.png",
--}
--QualityImagePath = {
--    [1] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_01.png",
--    [2] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_02.png",
--    [3] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_03.png",
--    [4] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_04.png",
--    [5] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_05.png",
--    [6] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_05.png",
--    [10] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitExplore/c_explore_truck_quality_05.png",
--}

--TruckMailReportBG = {
--    [1] = "Assets/Main/UITexture/UITextureExplore/c_texture_explore_truck_report_bg_01.png",
--    [2] = "Assets/Main/UITexture/UITextureExplore/c_texture_explore_truck_report_bg_02.png",
--    [3] = "Assets/Main/UITexture/UITextureExplore/c_texture_explore_truck_report_bg_03.png",
--    [4] = "Assets/Main/UITexture/UITextureExplore/c_texture_explore_truck_report_bg_04.png",
--    [5] = "Assets/Main/UITexture/UITextureExplore/c_texture_explore_truck_report_bg_05.png",
--}

--采集类建筑
--CollectBuild =
--{
--    --BuildingTypes.FUN_BUILD_CONDOMINIUM,
--    --BuildingTypes.FUN_BUILD_STONE,
--    --BuildingTypes.FUN_BUILD_OIL,
--    --BuildingTypes.FUN_BUILD_WATER,
--    --BuildingTypes.FUN_BUILD_ELECTRICITY_STORAGE,
--    --BuildingTypes.FUN_BUILD_WIND_TURBINE,
--    --BuildingTypes.FUN_BUILD_SOLAR_POWER_STATION,
--    --BuildingTypes.FUN_BUILD_ELECTRICITY,
--    --BuildingTypes.FUN_BUILD_GROCERY_STORE,
--    --BuildingTypes.FUN_BUILD_GREEN_CRYSTAL,
--}

--AllianceTeamType =
--{
--    ATTACK_BOSS=0,--集结怪物 pve
--    ATTACK_BUILDING=1,--集结建筑  pvp
--    ATTACK_CITY = 2,--集结大本   pvp
--    ATTACK_AL_CITY = 3,--集结联盟城  pvp
--    ATTACK_AL_BUILD = 4,--集结联盟建筑  pvp
--    ATTACK_NPC_CITY = 5,--集结NPC大本  pvp
--    ATTACK_THRONE = 6,--集结王座  pvp
--    ASSISTANCE_THRONE = 7,--援助王座  pvp
--    ATTACK_DRAGON_BUILDING= 8,--集结战场建筑  pvp
--    ATTACK_ALLIANCE_BOSS = 10,--集结联盟boss pve
--    ATTACK_ACT_RESOURCE = 11,--集结金矿掠夺
--    ATTACK_ALLIANCE_BOSS_BEAR = 12, --集结联盟boss熊
--    ATTACK_TOWER = 13,--集结炮塔
--}

MarchStatus=
{
    DEFAULT =-1,--初始状态
    STATION=0, --驻军
    MOVING=1, --行军中
    ATTACKING=2, --攻击中
    COLLECTING=3, --采集中
    BACK_HOME=4, --到家
    CHASING=5, --追逐
    WAIT_RALLY=6, --等待集结中
    IN_TEAM=7, --在集结中
    ASSISTANCE =8, --在援助单位中
    IN_WORM_HOLE = 9, -- 在虫洞中
    SAMPLING = 10,--采样中
    PICKING = 11,--捡垃圾
    GOLLOES_EXPLORING = 12,--咕噜探索中
    BUILD_WORM_HOLE = 13,-- 建设虫洞中
    DESTROY_WAIT = 14, --等待拆除耐久
    BUILD_ALLIANCE_BUILDING = 15, --建造联盟建筑中
    TRANSPORT_BACK_HOME = 16, --传送回家
    CROSS_SERVER = 17, --跨服虫洞中
    WAIT_THRONE =18, --18 王座排队中
    DIG_TREASURE = 24,-- 挖掘宝藏中

    RALLY_FORTRESS = 74,--74 集结堡垒 --D的代码 我们暂时好像没用到
}

--GotoType =
--{
--    Build = 1,
--    Science = 2,
--    Package = 3,
--    Activity = 4,
--}

MarchTargetType =
{
    STATE =0,--驻守
    ATTACK_MONSTER=1,--攻击
    COLLECT=2,--采集
    BACK_HOME=3,--回城
    ATTACK_BUILDING=4,--攻击玩家建筑
    ATTACK_ARMY=5, --攻击玩家编队
    JOIN_RALLY=6, --参加集结
    RALLY_FOR_BOSS=7, --集结打怪
    RALLY_FOR_BUILDING=8, --集结打建筑
    RANDOM_MOVE = 9, --野怪状态，随便走走
    ATTACK_ARMY_COLLECT=10 ,--打采集编队，打完了采集
    ATTACK_CITY = 11, --攻击大本
    RALLY_FOR_CITY=12, --集结大本
    ASSISTANCE_BUILD=13, --援助建筑
    ASSISTANCE_CITY=14, --援助大本
    ATTACK_ROAD = 15, --拆路
    GO_WORM_HOLE = 16, -- 进虫洞
    SCOUT_CITY = 17,-- 17 侦察城市
    SCOUT_BUILDING = 18,-- 18 侦察建筑
    SCOUT_ARMY_COLLECT = 19,-- 19 侦查部队
    EXPLORE = 20,   --20小队探测
    SAMPLE = 21,--21采样
    SCOUT_TROOP = 22,--侦查部队
    PICK_GARBAGE = 23,--捡垃圾
    RESOURCE_HELP = 24,--资源援助
    ATTACK_ALLIANCE_CITY =25,-- 25 攻击联盟城市
    ASSISTANCE_ALLIANCE_CITY =26,-- 26 防御联盟城市
    RALLY_FOR_ALLIANCE_CITY =27,-- 27 集结攻打联盟城市
    SCOUT_ALLIANCE_CITY = 28,--侦察建筑
    GOLLOES_EXPLORE = 29,--咕噜探索
    GOLLOES_TRADE = 30,--咕噜商队
    BUILD_WORM_HOLE = 31,-- 建设虫洞
    TRANSPORT_ACT_BOSS = 32, --传送活动boss
    DIRECT_ATTACK_ACT_BOSS = 33, --直接攻击活动boss
    BUILD_ALLIANCE_BUILDING = 34, --建造联盟建筑
    COLLECT_ALLIANCE_BUILD_RESOURCE = 35, --采集联盟建筑资源
    CROSS_SERVER_WORM = 36, --跨服
    ATTACK_DESERT = 37, -- 攻击地块
    ASSISTANCE_DESERT = 38, --驻守地块
    SCOUT_DESERT = 39, --侦察地块
    TRAIN_DESERT = 40, --地块训练  Target
    DIRECT_ATTACK_CITY = 41, --奇袭
    ATTACK_ALLIANCE_BUILDING = 42, --攻击联盟建筑
    RALLY_ALLIANCE_BUILDING = 43, --集结联盟建筑
    SCOUT_ALLIANCE_BUILDING = 44, --侦察联盟建筑
    ASSISTANCE_ALLIANCE_BUILDING = 45, --援助联盟建筑
    DIRECT_ATTACK_NPC_CITY = 46, --奇袭NPC城市
    ATTACK_NPC_CITY = 47, --攻击NPC城市
    RALLY_NPC_CITY = 48, --集结NPC城市
    SCOUT_NPC_CITY = 49, --侦察NPC城市
    RALLY_THRONE = 50,-- 集结王座
    RALLY_ASSISTANCE_THRONE = 51, --集结援助王座
    SCOUT_THRONE = 52, --侦察王座
    ATTACK_ALLIANCE_BOSS = 53, -- 攻击联盟boss
    ATTACK_DRAGON_BUILDING = 58,-- 攻击战场建筑
    RALLY_DRAGON_BUILDING = 59, -- 集结战场建筑
    SCOUT_DRAGON_BUILDING = 60, -- 侦察战场建筑
    ASSISTANCE_DRAGON_BUILDING = 61, -- 援助战场建筑
    TAKE_SECRET_KEY = 62, --获取战场密钥
    PICK_SECRET_KEY = 63, --拾取战场密钥
    TRANSPORT_SECRET_KEY = 64, --运送战场密钥
    TRIGGER_DRAGON_BUILDING = 65, --攻击/援助战场建筑
    TRIGGER_THRONE = 72, --单队援助王座（中间状态）
    ASSISTANCE_THRONE = 76, --援助王座
    RALLY_FOR_ALLIANCE_BOSS = 74, --集合打联盟boss
    Garage_March = 75, --车库编队
    ATTACK_THRONE = 77, -- 77 单人攻击王座
    GodzillaGift = 78, -- 试炼boss奖励
    DIG_TREASURE = 79,

    ATTACK_DRAGON_BOSS = 88, --巨龙建筑BOSS
    ATTACK_ACT_WORLD_RESOURCE = 86, --掠夺活动资源
    COLLECT_ACT_WORLD_RESOURCE = 87, --采集世界活动资源
    SCOUT_ACT_WORLD_RESOURCE = 89, --侦察活动资源
    RALLY_FOR_ACT_WORLD_RESOURCE = 90, --集结世界活动资源
    --客户端用
    PUZZLE_BOSS = 101,--puzzle monster
    DISPATCH_TASK = 105, --派遣任务
    NORMAL_FAKE_MARCH = 106, -- 通用假行军队列，只有移动逻辑
    -- 卡车
    Truck_March = 107, -- 保存卡车的队列信息
    Champion_Formation = 108, -- 冠军对决
}

--MarchTargetSubType =
--{
--    FakeRescue = 1, --营救
--}

--FortAtkState = {
--    Wait = 1,
--    Atk = 2,
--    Done = 3
--}

--HospitalPanelStateType =
--{
--    NoSoldier = 0,
--    Treating = 1,--正在治疗
--    Select = 2,--选择
--}

--作用号值
--EffectDefine =
--{
--    TREAT_NUM_MAX_EFFECT_ADD = 73, --医院伤兵上限数量
--    TREAT_NUM_MAX_EFFECT = 57, --医院伤兵上限增加百分比
--    CURE_RESOURCE_REDUCE = 108,--治疗消耗减少百分比
--    CHAT_ROOM_MAX = 310, -- 可创建聊天室数量
--    TRADE_TEX_DECREASE_938 = 938, --交易税率
--    BUILD_QUEUE_NUM = 30050, --建造队列数量
--
--    --燃油每小时产量
--    OIL_SPEED = 30000,
--    --水晶每小时产量
--    METAL_SPEED = 30001,
--    --风力发电站每小时产量
--    NUCLEAR_SPEED = 30002,
--    --火力发电站每小时产量
--    FOOD_SPEED = 30003,
--    --水每小时产量
--    WATER_SPEED = 30004,
--    --氧气每秒产量
--    HERO_ONE_KEY_OPEN = 30005,--一键进阶开关
--    --OXYGEN_SPEED = 30005,
--    --太阳能电每小时产量
--    ELECTRICITY_SPEED = 30006,
--    --油电每秒产量
--    OIL_ELECTRICITY_SPEED = 30008,
--    --核电每秒产量
--    NUCLEAR_ELECTRICITY_SPEED = 30010,
--    --人口上限增加
--    PEOPLE_MAX = 30007,
--    --医疗上限增加
--    HOS_MAX = 30009,
--    --贸易度上限增加(值)
--    TRAD_MAX = 30011,
--    --研发值增加(值)
--    RD_ADD = 30013,
--    --研发值增加(值)
--    OPERA_ADD = 30014,
--    --维护度上限(值)
--    MAINTAIN_MAX_ADD = 30016,
--    --建造值增加(值)
--    BUILD_ADD = 30017,
--    --环境值指数、每分钟对环境值进行加减值
--    ENVIR_SPEED = 30020,
--    --人口每分钟增长值(数值)
--    PEOPLE_SPEED = 30021,
--    --人口增长加成(千分比)1000=1
--    PEOPLE_SPEED_PER = 30022,
--    --资金每秒增长(值)
--    MONEY_SPEED = 30023,
--    --资金增长加成(千分比)
--    MONEY_SPEED_PER = 30024,
--    --燃油上限
--    OIL_MAX_LIMIT = 30030,
--    --金属上限
--    METAL_MAX_LIMIT = 30031,
--    --核燃料上限
--    NUCLEAR_MAX_LIMIT = 30032,
--    --粮食上限
--    FOOD_MAX_LIMIT = 30033,
--    --水上限
--    WATER_MAX_LIMIT = 30034,
--    --氧气上限
--    OXYGEN_MAX_LIMIT = 30035,
--    --电上限
--    ELECTRICITY_MAX_LIMIT = 30036,
--    --电消耗
--    ELECTRICITY_DEC = 30037,
--    --核燃料消耗
--    NUCLEAR_DEC = 30038,
--    --燃油消耗
--    OIL_DEC = 30039,
--    --PVE入场券上限
--    PVE_POINT_MAX_LIMIT = 30019,
--    --受伤人口恢复速度（分钟）
--    PEOPLE_REC_SPEED = 30040,
--    --科技带兵数量
--    SCIENCE_ADD_SOLDIER = 30441,
--    --冷库存储上线
--    FREEZER_STORAGE_MAX_LIMIT = 30044,
--    --综合仓库存储上线
--    WAREHOUSE_STORAGE_MAX_LIMIT = 30045,
--    --[[    --冷库保护上线
--        FREEZER_PROTECT_MAX_LIMIT = 30046,]]
--
--    -- 地球订单额外加成提升百分比
--    EARTH_ORDER_EXTRA_MONEY_ADD_PERCENT = 30046,
--    -- 地球订单额外加成值百分比
--    EARTH_ORDER_EXTRA_MONEY_ADD_VALUE = 30093,
--    --综合仓库保护上线
--    WAREHOUSE_PROTECT_MAX_LIMIT = 30047,
--
--
--
--    WATER_CAPACITY_ADD = 30064, --30064	抽水站储量提升	储量=建筑para2*(1+【30064】/100)
--    METAL_CAPACITY_ADD = 30065, --30065	水晶采集场储量提升	储量=建筑para2*(1+【30065】/100)
--    GAS_CAPACITY_ADD = 30066, --30066	瓦斯收集器储量提升	储量=建筑para2*(1+【30066】/100)
--    METALLURGY_FACTORY_OUT_SPEED_ADD = 30067, -- 30067	冶金厂生产速度提升	生产时间=aps_factory.xml  time/（1+【30067】/100）
--    CHEMISTRY_FACTORY_OUT_SPEED_ADD = 30068, -- 30068	化学实验室生产速度提升	生产时间=aps_factory.xml  time/（1+【30068】/100）
--    ORE_FACTORY_OUT_SPEED_ADD = 30264, -- 晶石工厂生产速度提升
--    PRINT_FACTORY_OUT_SPEED_ADD = 30069, -- 30069	3d打印厂生产速度提升	生产时间=aps_factory.xml  time/（1+【30069】/100）
--    BUILD_SPEED_ADD = 30070, --30070	建造建筑速度	建筑建造时间=building.xml time/(1+【30070】/ 100)
--    SCIENCE_SPEED_ADD = 30071, -- 30071	科研速度	科研时间=science.xml time/(1+【30071】/ 100)
--    WIND_ELECTRICITY_SPEED_ADD = 30072, -- 风力发电站速度提升	速度=建筑para1*(1+【30072】/100)
--    WIND_ELECTRICITY_CAPACITY_ADD = 30073, -- 风力发电站储量提升	储量=建筑para2*(1+【30073】/100)
--    HOTEL_MONEY_SPEED_ADD = 30074, -- 公寓钞票产出速度提升	速度=建筑para1*(1+【30074】/100)
--    HOUSE_MONEY_SPEED_ADD = 30075, -- 别墅钞票产出速度提升	速度=建筑para1*(1+【30075】/100)
--    METAL_SPEED_ADD = 30076, --水晶采集场速度提升	  速度=建筑para1*(1+【30076】/100)
--    SOLAR_ELECTRICITY_SPEED_ADD = 30077, --太阳能发电站速度提升	速度=建筑para1*(1+【30077】/100)
--    RESOURCE_PROTECT_CAPACITY_ADD = 30078, --资源仓库保护上限提升	保护上限=基础值*(1+【30078】/100)
--    BUILD_ROAD_NUM_ADD = 30079, --建造道路的数量提升		数量=基础值+【30079】
--    FREEZER_STORAGE_ADD = 30080, --冷库上限提升	容量=【30044】+【30080】
--    MONEY_SPEED_ADD = 30081, --钞票产出速度提升
--    SOLAR_ELECTRICITY_CAPACITY_ADD = 30082, --太阳能发电站储量提升	储量=建筑para2*(1+【30082】/100)
--    FIRE_ELECTRICITY_CAPACITY_ADD = 30083, --火力发电站储量提升	储量=建筑para2*(1+【30083】/100)
--    FIRE_ELECTRICITY_SPEED_ADD = 30084, --火力发电站速度提升	速度=建筑para1*(1+【30084】/100)
--    HOTEL_MONEY_CAPACITY_ADD = 30085, --公寓钞票储量提升	储量=建筑para2*(1+【30085】/100)
--    HOUSE_MONEY_CAPACITY_ADD = 30086, --别墅钞票储量提升	储量=建筑para2*(1+【30086】/100)
--    MONEY_CAPACITY_ADD = 30087, --钞票储量提升		公寓储量=建筑para2*(1+【30086】/100+【30084】/100)  别墅储量=建筑para2*(1+【30086】/100+【30085】/100)
--
--    UNLOCK_WATER_GET = 30088, --解锁部队采集水
--    UNLOCK_GAS_GET = 30089, --解锁部队采集瓦斯
--    UNLOCK_METAL_GET = 30090, --解锁部队采集水晶
--    GAS_BUILD_COLLECT_SPEED_ADD = 30091, --瓦斯收集器速度提升		百分比	速度=建筑para1*(1+【30091	】/100)
--    WATER_BUILD_COLLECT_SPEED_ADD = 30092, --抽水站速度提升		百分比	速度=建筑para1*(1+【30092	】/100)
--
--    ADD_OSTRICH_NUM = 30052, -- 719000鸵鸟数量
--    ADD_COW_NUM = 30053, -- 720000奶牛数量
--    ADD_PIG_NUM = 30054, -- 721000猪数量
--
--    STORAGE_SHOP_REFRESH_TIME_REDUCE = 30026,--交易行刷新减少时间
--
--    ADD_FIELD_NUM = 30094, -- 702000可建造农田数量加成
--    ADD_CAN_BUILD_NUM = 30095, -- 可建造建筑范围
--    ADD_WATER_BUILD_NUM = 30096, -- 432000可建造净水罐数量加成
--    ADD_HOTEL_NUM = 30097, -- 409000可建造公寓数量加成
--    ADD_METAL_COLLECT_NUM = 30098, -- 412000可建造水晶采集场数量加成
--
--    BUILD_TIME_REDUCE = 30099,--建筑时间减少
--    RESEARCH_TIME_REDUCE = 30100,--科技时间减少
--    SEASON_BUILD_TIME_REDUCE = 30270,--赛季建筑时间减少
--
--    AlContributeMonthCard = 30266,--功勋积分双倍
--
--    ROBOT_IN_FARM = 30101, --机器人可以到农庄工作
--    ROBOT_IN_FACTORY = 30102, --机器人可以到食品加工厂工作
--    ROBOT_IN_PASTURE = 30103,--机器人可以到食品加工厂工作
--    ADD_SCIENCE_QUEUE = 30104,	--可建造科研部件数量增加
--    ADD_FARM_SPEED = 30105,	--农场作物成熟速度
--    ADD_PASTURE_SPEED = 30106,	--牧场动物成熟速度
--    ADD_FACTORY_SPEED = 30107,	--加工厂加工速度
--    EARTH_ORDER_VIP = 30108,--贸易中心火箭发射时间可控
--    EFFECT_ONE_MORE_TIMES = 30132,--再来一份
--    GLOBAL_MONEY_EXTRA_PERCENT = 30109, -- 全局金币收益加成 百分比
--    EARTH_ORDER_UNLOCK = 30110, -- 解锁火箭订单功能（1: 解锁 0: 未解锁）
--    GLOBAL_HERO_EXP_EXTRA_PERCENT = 30111, -- 全局英雄经验获得加成 百分比
--    TROOP_LIMIT_EXTRA = 30018, -- 带兵上限
--    STORAGE_MAX_EXTRA = 30112, -- 仓库上限
--    CAREER_ATTACK_CITY_COLLECT_ADD_PERCENT = 30137,--30137 攻城时编队负重 百分比 攻城时生效
--    CAREER_COLLECT_ADD_PERCENT = 30138, --30138 采集时负重 百分比 采集时生效
--    CAREER_JOIN_TEAM_SPEED_ADD_PERCENT = 30139, --30139 参与组队时的行军速度 百分比 前往参加组队时的行军速度
--    MONEY_ROB = 30140, --特权掠夺z币
--    MONEY_ROB_LIMIT = 30399, --特权掠夺z币每日上限
--    Effect_30470 = 30470, --派遣特权
--    Effect_30473 = 30473, --经验产出 百分比
--    Effect_30474 = 30474, --合金产出 百分比
--    
--    STORAGE_SHOP_ADD_MAX_NUM = 30191,--交易行最大上架数量增加值
--    HAS_UNCLAIMED_FREE_GOLLOES = 30192,--当日有免费咕噜没领取
--    MINE_CAVE_CAN_PREVIEW = 30203,--矿洞是否可刷出（是否需要预览）
--    TANK_TRAIN_SPEED_ADD = 31000, --31000	坦克训练速度提升	训练士兵时间=arms.xml time/（1+【31000】/100）
--    ROBOT_TRAIN_SPEED_ADD = 31001, --31001	轻武器训练速度提升	训练士兵时间=arms.xml time/（1+【31001】/100）
--    PLANE_TRAIN_SPEED_ADD = 31002, --31002	飞机训练速度提升	训练士兵时间=arms.xml time/（1+【31002】/100）
--    TANK_TRAIN_NUM_ADD = 31003, --31003	坦克训练量提升	训练量=arms.xml max_train +【31003】
--    ROBOT_TRAIN_NUM_ADD = 31004, --31004	轻武器训练量提升	训练量=arms.xml max_train +【31004】
--    PLANE_TRAIN_NUM_ADD = 31005, --31005	飞机训练量提升	训练量=arms.xml max_train +【31005】
--    DETECT_ARMY_SPEED = 31006,--侦察行军速度 行军速度=基础值*(1+【31006】/100)
--    REPAIR_SPEED_ADD = 31007, --维修速度提升		维修速度=arms.xml treat_time/（1+【31007】/100）
--    ARMY_TRAIN_SPEED_ADD = 31008, --部队训练速度提升	训练士兵时间=arms.xml time/（1+【31008】/100）
--    ARMY_TRAIN_MAX_ADD = 31009, --部队训练上限提升	坦克训练量=arms.xml max_train +【31003】 +【31009】 轻武器训练量=arms.xml max_train +【31004】 +【31009】 飞机训练量=arms.xml max_train +【31005】 +【31009】）
--
--    INFANTRY_UPGRADE_SWITCH = 31010, --步兵可晋升
--    TANK_UPGRADE_SWITCH = 31011,--坦克可晋升
--    PLANE_UPGRADE_SWITCH = 31012,--飞机可晋升
--
--    ATTACK_ADD_BASE_ALL_ARMY = 35000, --全体兵种基础攻击加成
--    ATTACK_ADD_BASE_ARM_1 = 35001, --兵种1基础攻击加成
--    ATTACK_ADD_BASE_ARM_2 = 35002, --兵种2基础攻击加成
--    ATTACK_ADD_BASE_ARM_3 = 35003, --兵种3基础攻击加成
--    HEALTH_ADD_BASE_ALL_ARMY = 35012,--全局生命加成
--    ATTACK_ADD_BUILD_ALL_ARMY = 35048, --驻守建筑前台兵种总攻击加成
--    ATTACK_ADD_BUILD_ARM_1 = 35049, --驻守建筑前台兵种1攻击加成
--    ATTACK_ADD_BUILD_ARM_2 = 35050, --驻守建筑前台兵种2攻击加成
--    ATTACK_ADD_BUILD_ARM_3 = 35051, --驻守建筑前台兵种3攻击加成
--
--    DEFENCE_ADD_BASE_ALL_ARMY = 35004, --全体兵种基础防守加成
--    DEFENCE_ADD_BASE_ARM_1 = 35005, --兵种1基础防守加成
--    DEFENCE_ADD_BASE_ARM_2 = 35006, --兵种2基础防守加成
--    DEFENCE_ADD_BASE_ARM_3 = 35007, --兵种3基础防守加成
--    DEFENCE_ADD_BUILD_ALL_ARMY = 35052, --驻守建筑前台兵种总防守加成
--    DEFENCE_ADD_BUILD_ARM_1 = 35053, --驻守建筑前台兵种1防守加成
--    DEFENCE_ADD_BUILD_ARM_2 = 35054, --驻守建筑前台兵种2防守加成
--    DEFENCE_ADD_BUILD_ARM_3 = 35055, --驻守建筑前台兵种3防守加成
--    ATTACK_MONSTER = 35056, --打怪攻击力
--    DEFENCE_MONSTER = 35057, --打怪防御力
--    GAS_COLLECT_SPEED = 30058, --瓦斯采集速度
--    WATER_COLLECT_SPEED = 30059, --水源采集速度
--    CRYSTAL_COLLECT_SPEED = 30060, --水晶采集速度
--    OIL_COLLECT_SPEED_PERCENT = 30061, --瓦斯采集速度增加百分比
--    WATER_COLLECT_SPEED_PERCENT = 30062, --水源采集速度增加百分比
--    CRYSTAL_COLLECT_SPEED_PERCENT = 30063, --水晶采集速度增加百分比
--    ELECTRICITY_COLLECT_SPEED_PERCENT = 30239,--电采集速度增加百分比
--    MONEY_COLLECT_SPEED_PERCENT = 35109,--金币采集速度增加百分比
--    PURPLE_CRYSTAL_COLLECT_SPEED_PERCENT = 30245,--紫水晶采集速度增加百分比
--    
--    HERO_CAMP_SOLDIER_PERCENT_1 = 30451,--同时上阵5个黑手党英雄，编队容量增加	编队生效	百分比
--    HERO_CAMP_SOLDIER_PERCENT_2 = 30452,--同时上阵5个联邦卫队英雄，编队容量增加	编队生效	百分比
--    HERO_CAMP_SOLDIER_PERCENT_3 = 30453,--同时上阵5个狂热者英雄，编队容量增加	编队生效	百分比
--        
--    HERO_SKILL_SOLDIER_COUNT = 30460,--英雄带兵量	只对本英雄自身生效	数值
--    HERO_SKILL_SOLDIER_PERCENT = 30461,--英雄带兵量	只对本英雄自身生效	百分比
--    HERO_SKILL_30469 = 30469,--中立城削减体力消耗
--    
--    WAR_ATTACK = 35064, --战斗伤害加成
--    WAR_DEFENCE = 35065, --战斗防御加成
--    APS_BATTLE_HERO_TOTAL_ATK_PERCENT_INCR = 35067,--英雄攻击力加成
--    APS_BATTLE_HERO_TOTAL_DEF_PERCENT_INCR = 35068,--英雄防御力加成
--    APS_BATTLE_TROOP_TOTAL_ATK_INCR_PERCENT = 35073,--全体兵种攻击
--    APS_BATTLE_TROOP_TOTAL_DEF_INCR_PERCENT = 35074,--全体兵种防御
--    STAMINA_COST_DEC = 35111,--行军体力消耗减少
--    STAMINA_MAX_LIMIT = 35117,--车库燃料上限
--    TOWER_RANGE_ADD = 35122,--炮台攻击范围
--    TOWER_ATTACK_ADD = 35123,--炮台攻击力提升
--    APS_FORMATION_SIZE = 40001,
--    APS_FORMATION_SIZE_ENHANCE = 40002,
--    STAMINA_COST_DEC_LITE = 35331,--行军体力消耗减少 小怪
--    STAMINA_COST_DEC_BIG = 35332,--行军体力消耗减少 集结怪
--    
--    APS_DEFENCE_FORMATION_SIZE = 40003, --守城编队数量
--    APS_DEFENCE_FORMATION_FIRST_HERO_COUNT = 40004, --守城第一编队可上阵英雄数量
--    APS_DEFENCE_FORMATION_SECOND_HERO_COUNT = 40005, --守城第二编队可上阵英雄数量
--    APS_DEFENCE_FORMATION_THIRD_HERO_COUNT = 40006, --守城第三编队可上阵英雄数量
--    APS_DEFENCE_DOME_NUM = 40007, --防护罩耐久
--    APS_DEFENCE_DOME_SPEED = 40008, --防护罩耐久回复速度
--    ARMY_CARRY_WEIGHT_ADD_PERCENT = 40010, -- 负重上线百分比
--    SIEGE_DAMAGE_ADD_PERCENT = 40011, -- 单兵攻城值增加百分比
--    APS_ALLIANCE_TEAM_MAX_ARMY = 40014, -- 最大集结上限
--
--
--    APS_FORMATION_FIRST_HERO_COUNT = 40016, --第一编队可上阵英雄数量
--    APS_FORMATION_SECOND_HERO_COUNT = 40017, --第二编队可上阵英雄数量
--    APS_FORMATION_THIRD_HERO_COUNT = 40018, --第三编队可上阵英雄数量
--    APS_FORMATION_FORTH_HERO_COUNT = 40019, --第四编队可上阵英雄数量
--    ARMY_SPEED_ADD = 40020, --部队行军速度提升	行军速度=基础值*(1+【40020】/100)
--    APS_WORM_SPEED_ADD_PERCENT = 40021, --行军虫洞速度增加百分比
--    APS_SCOUT_FORMATION_SIZE = 40022, --侦查队列最大数量
--    APS_NORMAL_FORMATION_1_ATK =40036, -- 普通编队1攻击力提升
--    APS_NORMAL_FORMATION_2_ATK = 40037, -- 普通编队2攻击力提升
--    APS_NORMAL_FORMATION_3_ATK = 40038, -- 普通编队3攻击力提升
--    APS_NORMAL_FORMATION_4_ATK = 40039, -- 普通编队4攻击力提升
--    APS_NORMAL_FORMATION_1_DEF = 40040, -- 普通编队1防御力提升
--    APS_NORMAL_FORMATION_2_DEF = 40041, -- 普通编队2防御力提升
--    APS_NORMAL_FORMATION_3_DEF = 40042, -- 普通编队3防御力提升
--    APS_NORMAL_FORMATION_4_DEF = 40043, -- 普通编队4防御力提升
--    APS_NORMAL_FORMATION_1_FORMATION_COUNT = 40044, -- 普通编队1编队出征数量增加
--    APS_NORMAL_FORMATION_2_FORMATION_COUNT = 40045, -- 普通编队2编队出征数量增加
--    APS_NORMAL_FORMATION_3_FORMATION_COUNT = 40046, -- 普通编队3编队出征数量增加
--    APS_NORMAL_FORMATION_4_FORMATION_COUNT = 40047, -- 普通编队4编队出征数量增加
--    STAMINA_RECOVER_SPEED_ADD = 40050,--行军体力回复速度提升
--    APS_NORMAL_FORMATION_1_CARRY_WEIGHT_ADD_PERCENT = 40083,--普通编队1负重增加百分比
--    APS_NORMAL_FORMATION_2_CARRY_WEIGHT_ADD_PERCENT = 40084, --普通编队2负重增加百分比
--    APS_NORMAL_FORMATION_3_CARRY_WEIGHT_ADD_PERCENT = 40085, --普通编队3负重增加百分比
--    APS_NORMAL_FORMATION_4_CARRY_WEIGHT_ADD_PERCENT = 40086, --普通编队4负重增加百分比
--    APS_NORMAL_FORMATION_1_MARCH_SPEED_ADD_PERCENT = 40087,--普通编队1行军速度增加百分比
--    APS_NORMAL_FORMATION_2_MARCH_SPEED_ADD_PERCENT = 40088, --普通编队2行军速度增加百分比
--    APS_NORMAL_FORMATION_3_MARCH_SPEED_ADD_PERCENT = 40089, --普通编队3行军速度增加百分比
--    APS_NORMAL_FORMATION_4_MARCH_SPEED_ADD_PERCENT = 40090, --普通编队4行军速度增加百分比
--    APS_NORMAL_FORMATION_1_CARRY_WEIGHT_ADD_NUM = 40091,--普通编队1负重增加值
--    APS_NORMAL_FORMATION_2_CARRY_WEIGHT_ADD_NUM = 40092, --普通编队2负重增加值
--    APS_NORMAL_FORMATION_3_CARRY_WEIGHT_ADD_NUM = 40093, --普通编队3负重增加值
--    APS_NORMAL_FORMATION_4_CARRY_WEIGHT_ADD_PNUM = 40094, --普通编队4负重增加值
--    APS_SEASON_DESERT_NUM_ADD = 41000, -- 赛季地块额外上限
--    APS_SEASON_DESERT_RESISTANCE = 41001, --赛季地块抗性
--    APS_ALLIANCE_ARMS_USE_NUM = 220,--联盟军备活动
--    APS_ARMY_NUM_MAX = 40049, -- 士兵数量上限
--    APS_ALCOMPETE_ACT_UNLOCK_BOX_2 = 30121,
--    APS_ALCOMPETE_ACT_UNLOCK_BOX_3 = 30123,
--
--    GREEN_CTRSTAL_SPEED_ADD = 30118,--绿水晶生产速度增加  百分比	速度=建筑para1*(1+【30118】/100)
--
--    FARMER_IRRIGATE_FRAM = 30147,--农民可灌溉农田
--    FARMER_IRRIGATE_PASTURE = 30148,--农民可灌溉农田
--    TRADER_EXTRA_FARM_BOX = 30151,--商人技能-农业补给箱
--
--    ALLIANCE_STORAGE_MAX = 30143,--联盟仓库上限
--    SAPPHIRE_PRODUCT_SPEED_PERCENT = 30144,--蓝宝石增长百分比
--    SAPPHIRE_PRODUCT_SPEED_NUM = 30145,--蓝宝石增长数值
--
--    KONBINI_EXTRA_FREE_COUNT = 30025, -- 小卖部额外免费次数
--    KONBINI_EXTRA_GREEN_STONE = 30149, -- 小卖部额外绿水晶
--    STORAGESHOP_EXTRA_SLOT = 30029, -- 交易行额外格子
--    EFFECT_ROCKET_NUM = 30027,--火箭次数加成
--
--    ALLIANCE_SCIENCE_RESEARCH_CONSUME = 30159,
--    ALLIANCE_CITY_MAX_NUM = 30160,
--    ASSIST_SPEED_ADD = 30158,
--    PLUNDER_REST_COUNT = 30152, -- 剩余掠夺次数
--    GROCERY_STORE_COIN_ADD_PERCENT = 30155, -- 咕噜订单价格增加
--    EFFECT_PRODUCT_QUEUE_ADD_711000 = 30113,
--    EFFECT_PRODUCT_QUEUE_ADD_707000 = 30114,
--    EFFECT_PRODUCT_QUEUE_ADD_717000 = 30115,
--    EFFECT_PRODUCT_QUEUE_ADD_718000 = 30116,
--    EFFECT_PRODUCT_QUEUE_ADD_708000 = 30117,
--    EFFECT_PRODUCT_QUEUE_ADD_709000 = 30119,
--    ADD_BUILD_ARROW_TOWER_NUM = 31013,	--炮台数量增加
--    DEC_UPGRADE_BUILD_ARROW_TOWER_ITEM = 30162,	--当此作用号生效，升级炮台时，消耗的道具读取418000的para2，格式与item字段一致
--    EFFECT_GULU_STORE_OPEN = 30041,--咕噜商店开放
--
--    FARM_EXP_ADD = 30119, --  种植获得玩家经验加成
--
--    GARAGE_REFIT_FREE_EXTRA = 30176, -- 改装车免费次数增加
--    GARAGE_REFIT_X2_PROB_EXTRA = 30177, -- 改造2倍概率增加
--    GARAGE_REFIT_X3_PROB_EXTRA = 30178, -- 改造3倍概率增加
--    GARAGE_REFIT_X5_PROB_EXTRA = 30179, -- 改造5倍概率增加
--    GARAGE_REFIT_X10_PROB_EXTRA = 30181, -- 改造10倍概率增加
--
--    ATTACK_DESERT_STAMINA_DECREASE = 30281, -- 玩家打地时体力消耗减少
--    --火车
--    MAX_DAILY_COUNT_ADD = 90103, -- 每日火车贸易次数附加值
--    TRADE_CD_REDUCE_RATE = 90104, -- 贸易CD减少百分比
--    -- 每日免费
--    DAILY_FREE_INFANTRY = 30167, -- 每日免费步兵
--    DAILY_FREE_TANK = 30168, -- 每日免费坦克
--    DAILY_FREE_PLANE = 30169, -- 每日免费飞机
--    DAILY_FREE_MAIN_PAPER = 30170, -- 每日免费总部图纸
--    DAILY_FREE_MONUMENT_PAPER = 30171, -- 每日免费英雄丰碑图纸
--    DAILY_FREE_TRADE_PAPER = 30172, -- 每日免费贸易中心图纸
--    DAILY_FREE_BARRACKS_PAPER = 30173, -- 每日免费军事中心图纸
--    DAILY_FREE_GARAGE_REFIT_ITEM = 30174, -- 每日免费车库改装齿轮
--    DAILY_FREE_TREAT = 30175, -- 每日免费恢复伤兵
--    SEASON_BUILDING_MAXLV_1 = 30243,--赛季建筑等级上限
--    SEASON_BUILDING_MAXLV_2 = 30244,--赛季建筑等级上限
--    PVE_MONUMENT_SWEEP = 30247,--英雄丰碑是否可以扫荡
--
--    -- 2023/1/13 New
--    DAILY_FREE_ENERGY = 30301, -- 每日免费体力
--    DAILY_FREE_MERCENARY_INFANTRY = 30402, -- 每日免费雇佣兵步兵
--    DAILY_FREE_MERCENARY_TANK = 30403, -- 每日免费雇佣兵坦克
--    DAILY_FREE_MERCENARY_PLANE = 30404, -- 每日免费雇佣兵飞机
--    DECREASE_ENERGY_COST = 35113, -- 体力消耗减少
--    DECREASE_GEAR_COST = 30304, -- 车库改装齿轮消耗减少
--    SEASON_WEEK_CARD_FLINT_ADD_PERCENT = 30305,--地块黑曜石产量增加
--    SEASON_WEEK_CARD_DESERT_SWEEP_FIELD = 30308,--地块可以进行连续扫荡 开关 1开0关
--    DECREASE_TRAIN_COIN_COST = 30401, -- 训练消耗金币减少
--    PVE_EXP_LEVEL_MORE_HERO = 30302, -- 经验关额外上阵英雄
--    PVE_EXP_LEVEL_MORE_ENTER = 30303, -- 经验关额外进入次数
--
--    -- 2023/3/15 New
--    WOOD_PRODUCT_ADD = 30226, -- 伐木场木头产量增加
--    STONE_PRODUCT_ADD = 30228, -- 采石场石头产量增加
--    UPGRADE_BUILD_EXP_ADD = 30257, -- 升建筑获得专精经验增加
--    ATTACK_DESERT_EXP_ADD = 30258, -- 打地获得专精经验增加
--    MONUMENT_REWARD_ADD = 30278, -- 英雄丰碑奖励增加
--    WOOD_BUILD_COUNT_ADD = 30279, -- 伐木场数量增加
--    STONE_BUILD_COUNT_ADD = 30280, -- 采石场数量增加
--
--    EFFECT_BUSINESS_CENTER_DELETE = 30187,--订单界面订单删除
--    ALLOW_FORCE_END_PVE = 30180,--天赋允许强制结束pve
--    ALLOW_DRAG_MARCH = 30186,--天赋允许拖拽行军
--    ALLOW_ATTACK_SAME_MONSTER = 30193, --天赋允许同时打同一个野怪
--    FACTORY_CANCEL_EFFECT_ID = 30190,--工厂取消功能
--    AUTO_RALLY_REWARD_NUM_ADD = 30195, -- 自动集结攻击沙虫额外奖励次数
--    REFRESH_MINE_CAVE_REFRESH_TIME_ADD = 30198,--矿洞活动界面额外攻击次数
--    UNLOCK_PUZZLE_BOSS_2 = 30199,--解锁拼图活动id=2的boss  1开0关
--    UNLOCK_PUZZLE_BOSS_3 = 30200,--解锁拼图活动id=3的boss  1开0关
--    TALENT_REFRESH_TIME = 30209,-- 重新随机可选天赋的次数
--    UNLOCK_ARM_ACT_BUILD = 30210,--解锁个人军备替换城市建筑 1开0关
--    UNLOCK_ARM_ACT_SCIENCE = 30211,--解锁个人军备替换科技研发 1开0关
--    UNLOCK_ARM_ACT_HERO = 30212,--解锁个人军备替换英雄试炼 1开0关
--    INDIVIDUAL_ORDER_REFRESH_TIME = 30214, -- 商业大亨刷新次数
--    DETECT_EVENT_FUNCTION_OPEN = 30215,--雷达事件功能解锁
--    PVE_STAMINA_MAX = 30216,--关卡体力上限 数值    体力上限=原上限+作用号
--    PVE_ATTACK_WOOD_OUT_NUM = 30217,--砍树获得木头        数值    砍一个树获得木头=原产出+作用号
--    PVE_ATTACK_STONE_OUT_NUM = 30218,--采矿获得石头        数值    砍一个石头获得石头=原产出+作用号    
--    PVE_START_ATTACK_SKILL = 30221,--开启旋风斩	开关	1开0关
--    GAME_EFFECT_30224 = 30224, --连续打怪体力消耗减少	百分比	连续打怪时体力消耗=原消耗*（1-作用号/100）刘文
--    GAME_EFFECT_30241 = 30241,-- 势力值金币奖励百分比增加
--    GAME_EFFECT_30242 = 30242,--势力值资源道具箱奖励百分比增加
--    APS_MONEY_WEIGHT_PERCENT = 35112,--金币资源重量减重百分比
--    APS_HERO_CAMP_COUNTER_INCR_PERCENT = 35115,--克制百分比加成
--    APS_HERO_CAMP_COUNTER_BY_INTENSIFY = 35272,--克制百分比加成（阵营加成）
--    ADD_FORMATION_ATTACK_BY_CAMP_35320 = 35320,--全阵营加成/部队攻击
--
--    ADD_FORMATION_ATTACK_BY_CAMP_35160 = 35160,--同时上阵2个黑手党英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35161 = 35161,--同时上阵3个黑手党英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35162 = 35162,--同时上阵4个黑手党英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35163 = 35163,--同时上阵5个黑手党英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35164 = 35164,--同时上阵2个联邦卫队英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35165 = 35165,--同时上阵3个联邦卫队英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35166 = 35166,--同时上阵4个联邦卫队英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35167 = 35167,--同时上阵5个联邦卫队英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35168 = 35168,--同时上阵2个狂热者英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35169 = 35169,--同时上阵3个狂热者英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35170 = 35170,--同时上阵4个狂热者英雄，部队攻击增加
--    ADD_FORMATION_ATTACK_BY_CAMP_35171 = 35171,--同时上阵5个狂热者英雄，部队攻击增加
--
--    ADD_FORMATION_DAMAGE_BY_CAMP_35200 = 35200,--同时上阵2个联邦卫队英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35201 = 35201,--同时上阵3个联邦卫队英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35202 = 35202,--同时上阵4个联邦卫队英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35203 = 35203,--同时上阵5个联邦卫队英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35204 = 35204,--同时上阵2个狂热者英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35205 = 35205,--同时上阵3个狂热者英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35206 = 35206,--同时上阵4个狂热者英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35207 = 35207,--同时上阵5个狂热者英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35208 = 35208,--同时上阵2个黑手党英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35209 = 35209,--同时上阵3个黑手党英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35210 = 35210,--同时上阵4个黑手党英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35211 = 35211,--同时上阵5个黑手党英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35212 = 35212,--同时上阵2个新人类英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35213 = 35213,--同时上阵3个新人类英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35214 = 35214,--同时上阵4个新人类英雄，伤害增加
--    ADD_FORMATION_DAMAGE_BY_CAMP_35215 = 35215,--同时上阵5个新人类英雄，伤害增加
--
--    ADD_FORMATION_DEF_BY_CAMP_35321 = 35321,--全阵营加成/部队防御
--    APS_MAFIA_TWO_FORMATION_DEF_INCR = 35176, --同时上阵2个黑手党英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_MAFIA_THREE_FORMATION_DEF_INCR = 35177,--同时上阵3个黑手党英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_MAFIA_FOUR_FORMATION_DEF_INCR = 35178, --同时上阵4个黑手党英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_MAFIA_FIVE_FORMATION_DEF_INCR = 35179,--同时上阵5个黑手党英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_UNION_TWO_FORMATION_DEF_INCR = 35180, --同时上阵2个联邦卫队英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_UNION_THREE_FORMATION_DEF_INCR = 35181,--同时上阵3个联邦卫队英雄，部队防御增加	百分比	效果同【35004】，全兵种部队防御增加
--    APS_UNION_FOUR_FORMATION_DEF_INCR = 35182,--同时上阵4个联邦卫队英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_UNION_FIVE_FORMATION_DEF_INCR = 35183,--同时上阵5个联邦卫队英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_ZELOT_TWO_FORMATION_DEF_INCR = 35184,--同时上阵2个狂热者英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_ZELOT_THREE_FORMATION_DEF_INCR = 35185,--同时上阵3个狂热者英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_ZELOT_FOUR_FORMATION_DEF_INCR = 35186,--同时上阵4个狂热者英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_ZELOT_FIVE_FORMATION_DEF_INCR = 35187,--同时上阵5个狂热者英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_NEW_HUMAN_TWO_FORMATION_DEF_INCR = 35188, --同时上阵2个新人类英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_NEW_HUMAN_THREE_FORMATION_DEF_INCR = 35189,--同时上阵3个新人类英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_NEW_HUMAN_FOUR_FORMATION_DEF_INCR = 35190,--同时上阵4个新人类英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--    APS_NEW_HUMAN_FIVE_FORMATION_DEF_INCR = 35191,--同时上阵5个新人类英雄，部队防御增加		百分比	效果同【35004】，全兵种部队防御增加
--
--    
--    ADD_UNION_HERO_ATK = 35216,--联邦英雄攻击力增加
--    ADD_UNION_HERO_DEF = 35217,--联邦英雄防御力增加
--    ADD_UNION_HERO_TRP = 35218,--联邦英雄带兵量增加
--    ADD_ZEALOT_HERO_ATK = 35219,--狂热者英雄攻击力增加
--    ADD_ZEALOT_HERO_DEF = 35220,--狂热者英雄防御力增加
--    ADD_ZEALOT_HERO_TRP = 35221,--狂热者英雄带兵量增加
--    ADD_MAFIA_HERO_ATK = 35222,--黑手党英雄攻击力增加
--    ADD_MAFIA_HERO_DEF = 35223,--黑手党英雄防御力增加
--    ADD_MAFIA_HERO_TRP = 35224,--黑手党英雄带兵量增加
--    ADD_NEW_HUMAN_HERO_ATK = 35225,--新人类英雄攻击力增加
--    ADD_NEW_HUMAN_HERO_DEF = 35226,--新人类英雄防御力增加
--    ADD_NEW_HUMAN_HERO_TRP = 35227,--新人类英雄带兵量增加
--    
--    ADD_MAFIA_HERO_TRP_PERCENT = 40131,--血蔷薇英雄带兵百分比
--    ADD_UNION_HERO_TRP_PERCENT = 40132,--破晓之翼英雄带兵百分比
--    ADD_ZEALOT_HERO_TRP_PERCENT = 40133,--秩序卫队英雄带兵百分比
--
--    APS_HERO_MAFIA_ATK_ADD_PERCENT = 40100, --黑手党英雄攻击力增加
--    APS_HERO_MAFIA_DEF_ADD_PERCENT = 40101, --黑手党英雄防御力增加
--    APS_HERO_UNION_ATK_ADD_PERCENT = 40102, --联邦英雄攻击力增加
--    APS_HERO_UNION_DEF_ADD_PERCENT = 40103, --联邦英雄防御力增加
--    APS_HERO_ZELOT_ATK_ADD_PERCENT = 40104, --狂热者英雄攻击力增加
--    APS_HERO_ZELOT_DEF_ADD_PERCENT = 40105, --狂热者英雄防御力增加
--    APS_HERO_NEW_HUMAN_ATK_ADD_PERCENT = 40106, --新人类英雄攻击力增加
--    APS_HERO_NEW_HUMAN_DEF_ADD_PERCENT = 40107, --新人类英雄防御力增加
--
--    ADD_CAMP_RESTRAINT_35228 = 35228,--联邦卫队 对  黑手党 阵营额外造成 伤害
--    ADD_CAMP_RESTRAINT_35229 = 35229,--黑手党 对  狂热者  阵营额外造成 伤害
--    ADD_CAMP_RESTRAINT_35230 = 35230,--狂热者   对  机器人 阵营额外造成 伤害
--    ADD_CAMP_RESTRAINT_35231 = 35231,--机器人 对 联邦卫队  阵营额外造成 伤害
--
--    EXTRA_WOOD = 30219,--额外木头
--    EXTRA_STONE = 30220,--额外石头
--
--    MONSTER_EXTRA_REWARD = 30204,
--    BOSS_EXTRA_REWARD = 30205,
--    UPGRADE_ADD_RES_CONDOMINIUM = 30182,--公寓升级之后会增加资源
--    UPGRADE_ADD_RES_WIND = 30184,--电力升级之后会增加资源
--    PVE_PLAYER_HP = 200001,     --PVE主角生命增加作用号
--    PVE_PLAYER_DEFENCE = 200002, --PVE主角防御力作用号
--    PVE_PLAYER_ATTACK = 200003, --PVE主角攻击作用号
--    PVE_PLAYER_MOVE_SPEED = 200004, --PVE主角移动速度作用号
--    PVE_PLAYER_FOOD_HP = 200005, --PVE食物恢复血量增加作用号
--    SURVIVAL_AUTO_PLANT = 200006, --解锁美女自动种植
--    SU_ITEM_STACK_ADD = 200010, --道具堆叠上限加成
--    FLINT_PROTECT_BASE = 30230,--火晶石保护基础值
--    FLINT_PROTECT_PERCENT = 30231, --火晶石保护百分比
--    FLINT_GATHER_ADD_PERCENT = 30232, --火晶石收取额外加成百分比
--    FLINT_MAX_LIMIT = 30234,--火晶石数量上限
--    FLINT_MAX_LIMIT_ADD_PERCENT = 30235, --火晶石数量上限增加百分比
--    OIL_MAX_LIMIT_ADD_PERCENT = 30236, --燃油上限增加百分比
--    PVE_AUTO_PLAY = 30233,
--
--    SK_SURPRISE_ATTACK = 30237, -- 技能：奇袭
--    APS_ELECTRICITY_WEIGHT_PERCENT = 30240,--电资源重量减重百分比
--
--    SEASON_FORCE_REWARD_MONEY = 30241, --势力值金币奖励增加百分比
--    SEASON_FORCE_REWARD_BOX = 30242, --势力值资源道具箱奖励增加百分比
--
--    HERO_CAMP_ADD_ARMY_UNION_2 = 35256, -- 同时上阵2个联邦卫队英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_UNION_3 = 35257, -- 同时上阵3个联邦卫队英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_UNION_4 = 35258, -- 同时上阵4个联邦卫队英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_UNION_5 = 35259, -- 同时上阵5个联邦卫队英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_ZEALOT_2 = 35260, -- 同时上阵2个狂热者英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_ZEALOT_3 = 35261, -- 同时上阵3个狂热者英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_ZEALOT_4 = 35262, -- 同时上阵4个狂热者英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_ZEALOT_5 = 35263, -- 同时上阵5个狂热者英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_MAFIA_2 = 35264, -- 同时上阵2个黑手党英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_MAFIA_3 = 35265, -- 同时上阵3个黑手党英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_MAFIA_4 = 35266, -- 同时上阵4个黑手党英雄，带兵量增加
--    HERO_CAMP_ADD_ARMY_MAFIA_5 = 35267, -- 同时上阵5个黑手党英雄，带兵量增加
--
--    SEASON_BUILDING_FLINT_DEC = 30259, -- 赛季建筑火晶石消耗降低
--    SEASON_BUILDING_OBSIDIAN_DEC = 30260, -- 赛季建筑黑曜石消耗降低
--    SEASON_BUILDING_BUILD_SPEED_INC = 30261, -- 赛季建筑速度增加
--    SEASON_BUILDING_HP_INC = 30262, -- 赛季建筑耐久上限增加
--    HEAL_MONEY_DEC = 30263, -- 医院消耗金币减少
--    TO_DESERT_ATK_INC = 30268, -- 对地块守军的攻击提升
--    TO_DESERT_DEF_INC = 30269, -- 对地块守军的防御提升
--    GAIN_HEAL_ITEM_WHEN_SEASON_BUILDING_LV_UP = 30281, -- 升级赛季建筑，获得伤兵加速道具
--    ADD_SEASON_DESERT_ARMY_ATTACK_2 = 30288, --751000 建造上限
--    ADD_SEASON_DESERT_ARMY_DEFEND_2 = 30289, --752000 建造上限
--    ADD_SEASON_DESERT_BUILD_DRONE_1 = 30290, --753000 建造上限
--    ADD_SEASON_DESERT_BUILD_DRONE_2 = 30291, --754000 建造上限
--    MAX_LV_SEASON_DESERT_MAX_FORMATION_SIZE_1 = 30285, --743000 等级上限
--    PROTECT_PLUNDER = 30294, -- 全资源不被掠夺
--    THRONE_EFFECT_30252 = 30252, --资源产量增速
--    THRONE_EFFECT_35121 = 35121, --资源产量减速
--    THRONE_EFFECT_35127 = 35127, --采集速度增加
--    THRONE_EFFECT_35301 = 35301, --建筑速度降低
--    THRONE_EFFECT_35311 = 35311, --科研速度降低
--    THRONE_EFFECT_30309 = 30309, --仓库保护降低
--
--    CAMP_BONUS_ADD = 35322,--全阵营加成效果/部队攻击
--    CAMP_BONUS_ADD_35306 = 35306,--黑手党阵营加成效果增加/部队攻击
--    CAMP_BONUS_ADD_35307 = 35307,--联盟卫队阵营加成效果增加/部队攻击
--    CAMP_BONUS_ADD_35308 = 35308,--狂热者阵营加成效果增加/部队攻击
--    CAMP_BONUS_ADD_35309 = 35309,--新人类阵营加成效果增加/部队攻击
--
--    CAMP_RESTRAINT_ADD = 35325,--全阵营加成效果/部队攻击
--    CAMP_RESTRAINT_ADD_35288 = 35288,--黑手党阵营加成效果增加/部队攻击
--    CAMP_RESTRAINT_ADD_35289 = 35289,--联盟卫队阵营加成效果增加/部队攻击
--    CAMP_RESTRAINT_ADD_35290 = 35290,--狂热者阵营加成效果增加/部队攻击
--    CAMP_RESTRAINT_ADD_BASE = 35284,--阵营克制/部队防御增加
--
--    HOS_MAX_ADD = 30298,  --每当城内维修站达到上限时，维修厂容量增加
--    
--    UNLOCK_MORE_EXPLOIT_REWARDS = 30299,    --功勋解锁更多奖励
--    EASY_GOLLOES_SEND = 30365, -- 一键派遣咕噜
--    Effect_Reserve_Max = 30313,--预备兵上限
--    Hero_Officer_Free_Time = 200012,--免费招募冷却时间
--    Get_Hero_Exp_Item_Effect_10 = 200013,--获得英雄10经验道具n个
--    Get_Hero_Exp_Item_Effect_100 = 200014,--获得英雄100经验道具n个
--    Get_Hero_Exp_Item_Effect_500 = 200015,--获得英雄500经验道具n个
--    Get_Hero_Exp_Item_Effect_1000 = 200016,--获得英雄1000经验道具n个
--
--    Survival_Farmland_Auto = 200018, --农田自动生产开关
--    LW_DISPATCH_TASK_FASTJOIN_FUNCTION_OPEN = 30319,--一键派遣上阵
--    NORMAL_DAMAGE_RATE = 35103, -- 普攻系数提升
--    COUNTER_DAMAGE_RATE = 35105, -- 反击系数提升
--    Daily_Get_Build_Add_Speed = 30419; --每天可领取x个5分钟建筑加速
--    Daily_Get_Research_Add_Speed = 30420; --每天可领取x个5分钟建筑加速
--    Build_LevelUp_Cost_Decrease = 30421; --建筑资源消耗降低
--    Extra_Soldier_Get = 30422; --每训练100士兵额外获得x个同等级雇佣兵
--    GAME_EFFECT_30424 = 30424,--每天可领取x个雷达任务
--    GAME_EFFECT_30426 = 30426,--雷达任务经验奖励增加 百分比
--    GAME_EFFECT_50001 = 50001, -- VIP 一键批量完成雷达事件
--    HERO_EQUIP_ATK = 30333, -- 英雄装备攻击力
--    HERO_EQUIP_DEF = 30334, -- 英雄装备防御力
--    Plunder_Today_Limit = 30440, --掠夺今日上限
--
--    DroneMaterialDrawingDecrease = 30444, --改装车消耗图纸减少
--    DAILY_FREE_REFITPAPER = 30445, --英雄技能每日免费改装图纸
--    Hero_Atk = 30331, -- 英雄攻击，无人机改装车增加的
--    Hero_Def = 30332, -- 英雄防御，无人机改装车增加的
--    Social_Pic = 30446, -- 查看别人头像
--    Social_Edit = 30447, -- 编辑个人签名
--
--    APS_BATTLE_PER_HERO_ATK_ADD = 30442, -- 增加所有英雄的攻击力
--    APS_BATTLE_PER_HERO_DEF_ADD = 30443, -- 增加所有英雄的防御力
--    
--    CarLevelUpReducedConsumption = 43001, -- 改装车升级消耗降低
--    CarTalentUpReducedConsumption = 43002, -- 改装车改装消耗降低
--    CarLevelUpExpSub = 43003, -- 改装车升级经验增加
--
--    TRAIN_FINISH_TANK = 35330,-- 坦克30329：每次训练时，有【35330】的概率立即完成（不消耗资源和加速）
--    TRAIN_FINISH_INFANTRY = 35329,-- 步兵30328：每次训练时，有【35329】的概率立即完成（不消耗资源和加速）
--    TRAIN_FINISH_PLANE = 30330,-- 飞机30330：每次训练时，有【35331】的概率立即完成（不消耗资源和加速）
--
--    Chat_Block_Count = 30448,  --聊天黑名单增加
--    GAME_EFFECT_50005 = 50005, --士兵训练量增加
--    GAME_EFFECT_51001 = 51001, --货车刷新
--    GAME_EFFECT_30437 = 30437,--科研基础资源消耗降低 百分比
--    
--    RALLY_SPEED_ADD = 40149, -- 集结行军速度增加10%
--
--    SEASON_FORMATION_ATK_ADD = 40150, -- 赛季加成：部队攻击
--    SEASON_FORMATION_DEF_ADD = 40151, -- 赛季加成：部队防御
--    SEASON_FORMATION_DAMAGE_ADD = 40152, -- 赛季加成：部队伤害
--}

--HeroCampAddArmyEffects =
--{
--    [HeroCamp.MAFIA] =
--    {
--        [2] = EffectDefine.HERO_CAMP_ADD_ARMY_MAFIA_2,
--        [3] = EffectDefine.HERO_CAMP_ADD_ARMY_MAFIA_3,
--        [4] = EffectDefine.HERO_CAMP_ADD_ARMY_MAFIA_4,
--        [5] = EffectDefine.HERO_CAMP_ADD_ARMY_MAFIA_5,
--    },
--    [HeroCamp.ZELOT] =
--    {
--        [2] = EffectDefine.HERO_CAMP_ADD_ARMY_ZEALOT_2,
--        [3] = EffectDefine.HERO_CAMP_ADD_ARMY_ZEALOT_3,
--        [4] = EffectDefine.HERO_CAMP_ADD_ARMY_ZEALOT_4,
--        [5] = EffectDefine.HERO_CAMP_ADD_ARMY_ZEALOT_5,
--    },
--    [HeroCamp.UNION] =
--    {
--        [2] = EffectDefine.HERO_CAMP_ADD_ARMY_UNION_2,
--        [3] = EffectDefine.HERO_CAMP_ADD_ARMY_UNION_3,
--        [4] = EffectDefine.HERO_CAMP_ADD_ARMY_UNION_4,
--        [5] = EffectDefine.HERO_CAMP_ADD_ARMY_UNION_5,
--    },
--}

--CheckHeroRestraintEffectList =
--{
--    EffectDefine.CAMP_RESTRAINT_ADD,
--    EffectDefine.CAMP_RESTRAINT_ADD_35288,
--    EffectDefine.CAMP_RESTRAINT_ADD_35289,
--    EffectDefine.CAMP_RESTRAINT_ADD_35290,
--    EffectDefine.CAMP_RESTRAINT_ADD_BASE,
--}

--CheckHeroCampAddEffectList =
--{
--    EffectDefine.CAMP_BONUS_ADD_35306,
--    EffectDefine.CAMP_BONUS_ADD_35307,
--    EffectDefine.CAMP_BONUS_ADD_35308,
--    EffectDefine.CAMP_BONUS_ADD_35309,
--    EffectDefine.CAMP_BONUS_ADD,
--}
--PlayBackEndJumpType =
--{
--    Mail=1,
--    Chat =2,
--    Arena=3,
--    MineCave = 4,
--}
--ExchangeDefine =
--{
--    MONTH_CARD_ID = "9007",--月卡ID
--    SUB_MONTH_CARD_ID = "9012",--订阅ID
--}

--ItemColor =
--{
--    WHITE = 0,
--    GREEN = 1,
--    BLUE = 2 ,
--    PURPLE = 3,
--    ORANGE = 4,
--    GOLDEN = 5,
--    SSS = 6,
--}

--HeroColor =
--{
--    ORANGE = 1,
--    PURPLE = 2,
--    BLUE = 3,
--    GREEN = 4,
--}

--detect_event和物品颜色的对应关系不一样
DetectEventColor =
{
    DETECT_EVENT_WHITE = 1,
    DETECT_EVENT_GREEN = 2,
    DETECT_EVENT_BLUE = 3 ,
    DETECT_EVENT_PURPLE = 4,
    DETECT_EVENT_ORANGE = 5,
    DETECT_EVENT_GOLDEN = 6,
}

--CheckNameType ={
--    None =0, --通过
--    MinNameChar =1,--少于最小字符数量
--    MaxNameChar = 2,--大于最大字符数量
--    IllegalChar = 3,--非法字符
--    SensitiveWords =4,---敏感词汇
--    Exist =5,--已存在
--    Unchanged = 6,--无变化
--}

--RankType = {
--    None = 0,
--    AllianceKill = 1, --联盟杀敌排行榜
--    AlliancePower = 2, --联盟战力排行榜
--    CommanderKill = 3, --杀敌排行榜
--    CommanderPower = 4, --战斗力排行榜
--    CommanderBase = 5, --指挥官基地排行榜
--    AllianceOrder = 6, --联盟农场排行榜
--    SeasonForce = 13,--赛季势力排行榜
--    SeasonDesert = 14,--赛季地块排行榜
--    AllianceSeasonForce = 15,--赛季联盟积分排行榜
--    MONSTER_SIEGE_USER = 17,--黑骑士个人杀怪排行榜
--    MONSTER_SIEGE_ALLIANCE = 18,--黑骑士联盟杀怪排行榜
--    OtherServerAlliancePower = 19,--其他服务器联盟战力排行榜
--    LandLockRank = 101, --解锁地块排行榜
--    ActLeadingQuestAllianceRank = 26,-- 任务活动联盟占领城市排行榜
--    HeroPluginRank = 31,-- 插件排行榜
--	RankLOCamp = 41,
--    HeroPower = 45,--英雄战力榜
--    StrongestHero = 49,--最强英雄
--    CrossWonderBattleRank = 50,--跨服王座开战时的积分排行
--}

--联盟贡献排行榜
--AllianceDonateRankType = {
--    None = 0,
--    RankDay = 1, --每日排行榜
--    RankWeek = 2, --每周排行榜
--    RankHistory = 3, --总排行榜
--}

--建筑时间进度条类型
--BuildTimeType =
--{
--    BuildTime_Upgrading = 0,--建筑升级
--    BuildTime_FootSoldier = 1,--机器人兵
--    BuildTime_CarSoldier = 2,--坦克兵
--    BuildTime_BowSoldier = 3,--飞机兵
--    BuildTime_Injuries = 4,--伤兵恢复
--    BuildTime_Science = 5,--科研中心研究
--    BuildTime_Farm = 6,--农场时间条
--    BuildTime_pasture = 7,--牧场时间条
--    BuildTime_tradingCenter = 8, -- 火箭订单倒计时
--    BuildTime_Fixing = 9,--废墟重建
--    BuildTime_HeroEquip = 10,--英雄装备制造
--
--    SU_Product = 100, --survival生产建筑
--}

--建筑气泡类型(小的在前)
--BuildBubbleType =
--{
--	--火车站
--	TrainFirstReward = 301, --火车首次领奖
--	TrainCanRob = 302, --火车可抢
--
--    BuildFixFinishEnd = 0,--建筑废墟修复完成
--    NeedConnect = 1,--需要连接道路
--    DetectEventFinished = 2,--探测事件完成（雷达黄底气泡）
--    StorageShopFirstOpen = 3,--交易行首次打开
--    HeroStationAvailable = 4,--英雄驻扎可用
--    UpgradeAllianceHelp = 5,--升级联盟帮助
--    ScienceAllianceHelp = 6,--科技研究联盟帮助
--    HospitalAllianceHelp = 7,--治疗伤兵联盟帮助
--    FootSoldierFree = 8,--机器人可以造兵
--    FootSoldierEnd = 9,--突击收兵
--    CarSoldierFree = 10,--坦克可以造兵
--    CarSoldierEnd = 11,--射手收兵
--    BowSoldierFree = 12,--飞机可以造兵
--    BowSoldierEnd = 13,--摩托收兵
--    HospitalFree = 14,--医院可以救治
--    HospitalEnd = 15,--医院收兵
--    ScienceFree = 16,--可以研究科技
--    ScienceEnd = 17,--收取科技
--    ResidentOrder = 18,--商业中心气泡
--    EarthOrder = 19,--地球订单气泡
--    ExtendDome = 20,--苍穹扩建
--    PastureProduct = 21,--收取动物副产物
--    GetItem = 22,--收取道具
--    GetResource = 23,--收取资源
--    NoGetResource = 24,--资源点枯竭
--    NeedTransport = 25,--火力发电站中资源为空
--    AllianceHelp = 26,--联盟帮助
--    GetFoodProduct = 27,--收取食品加工厂产物
--    DetectEvent = 28,--探测事件（雷达白底气泡）
--    HeroAdvance = 29,--英雄进阶
--    HeroRecruit = 30,--英雄招募
--    BuildZeroUp = 31,--主城建筑0级需要升级的材料
--    AllianceBattle = 32,--联盟战争
--    AllianceTask = 33,--联盟任务
--    AllianceGift = 34,--联盟礼物
--    GolloesGift = 35,--咕噜营地奖励
--    GolloesMonthCard = 36,--购买咕噜月卡
--    GroceryStore = 37,--杂货店订单
--    NoAlliance = 38,--无联盟
--    HeroStationSkill = 39,--英雄驻扎技能
--    Assistance = 40,--援助
--    StorageShopMoney = 41,--交易行收金币
--    StorageShopGolloes = 42,--交易行系统回收
--    FixBuildingAllianceHelp = 43,--废墟恢复联盟帮助
--    KonbiniFree = 44,--小卖部免费次数
--    HeroFreeScienceAddTime = 45,--英雄科技加速时间
--    HeroFreeBuildAddTime = 46,--英雄建筑加速时间
--    --WorldTrendStateRefresh = 47,--天下大势刷新，可领奖
--    AllianceCareer = 48,--联盟职业有空位可以任命
--    AllianceApply = 49,--加入联盟申请
--    GarageRefitFree = 50,--车库改装免费次数
--    InactivePlayer = 51,--有非活跃玩家
--    WormHoleSub = 52,--有虫洞出口  有部队在虫洞中
--    WormHoleSubZero = 53,--虫洞出口还未建造 0级
--    PveMonument = 54,--英雄丰碑
--    BuildingLv0Ruins = 55,--0级废墟建筑
--    BuildCanUpgrade = 56,
--    AllianceCityDeclareWar = 57,--联盟宣战
--    BuildUpgradeReward = 58,--建筑升级领奖
--    CanUseHeroEffectSkill = 59,
--    HeroRecruitOther = 60,--除了普通招募的英雄招募
--    CommonShopFree = 61,--通用道具商店免费红点
--    Talent = 62,--天赋
--    HeroBountyFree = 63,--英雄悬赏开始
--    HeroBountyFinish = 64,--英雄悬赏结束
--    HeroOfficialEmpty = 65,--英雄议会有空位
--    FootSoldierUnlock = 66,--新步兵解锁
--    CarSoldierUnlock = 67,--新坦克解锁
--    BowSoldierUnlock = 68,--新飞机解锁
--    LevelExploreEnergyEnough = 69,--探险飞船体力充足
--    EnergyOrder = 70,
--    CrossWormHoleSub = 71,--跨服虫洞有行军
--    RemoveRoad = 72,--删除路
--    EnergyTreasure = 73,--体力宝物
--    PubFreeItem = 74,--酒馆有免费道具
--    HeroIntensifyAvailable = 75,--英雄议会 阵营强化
--    EquipmentCanUpgrade = 76,--装备的部件可以升级时候
--    EquipmentSlotCanPutOn = 77,--有可穿的部件
--    HeroMedalShop = 78,--英雄勋章商店
--    Reserve = 79,--预备兵
--    RocketBomb = 86,--火箭炸弹气泡
--    HeroEquip = 87,--英雄装备
--    HeroFreeEnergy = 88,--英雄技能每日免费体力
--    HeroFreeGear = 89,--英雄技能每日免费齿轮
--    MonthCard = 90, --车库月卡
--    MonthCard2 = 91, --车库月卡
--    SU_ProductGather = 200, --
--    SU_RepairBuild = 202, --修复建筑
--    SU_Level0 = 203,   -- 废墟
--    SU_BuildComplete = 204,   --建筑待收取
--    SU_ItemProduct = 205,  -- 资源生成
--    SU_BuildUse = 206,  --
--    SU_NewMail = 207,  -- 有新邮件
--    HeroExpEffectItem = 208,--每天可通过建筑气泡领取一次道具奖励
--    GiftBubble = 209,--女二礼包气泡
--    CookBubble = 210,--烹饪气泡
--    IntelligenceBubble = 211,--情报气泡
--    StationBubble = 212,--派遣气泡
--    EnergyBubble = 213, --体力气泡
--    PoliceInsigniaBubble = 214, --建筑警徽气泡
--    LadyBubble = 215, -- 播放美女视频气泡
--    Arena = 216, -- 竞技场
--    Barrel_Pve = 217, -- 通过车库进入的爬塔
--    TalkTaskEventBubble = 218, -- 建筑对话事件气泡
--    NpcTalkTaskEventBubble = 219, -- npc对话事件气泡
--    GirlGetReward = 220, -- 美女领奖
--    CardGetReward = 221, -- 周卡月卡领奖
--    HeroDispatch = 222, -- 英雄派遣气泡
--    TruckBubble = 223, -- 卡车气泡
--    ChatLoveBubble = 224, -- 爱情通讯气泡
--    GarageBubble = 225, --无人机(车库)气泡
--    HeroStationBubble = 226, -- 小人驻扎气泡
--    HeroSmallTalentCenter = 227, -- 人才中心(英雄小人总管理建筑)
--    HeroFreeRefitPaper = 228,--英雄技能每日免费无人机图纸
--    Hospital_Treating = 229,--医院治疗中
--    NewDecorate = 230, -- 新装扮
--    UpgradeFinish = 231, --升级完成
--    SkinShop = 232, --皮肤商店
--}

--BuildBubbleTypeOrder =
--{
--    [BuildBubbleType.BuildFixFinishEnd] = 0,--建筑废墟修复完成
--    [BuildBubbleType.NeedConnect] = 1,--需要连接道路
--    [BuildBubbleType.TalkTaskEventBubble] = 1.10, -- 建筑对话事件气泡
--    [BuildBubbleType.PoliceInsigniaBubble] = 1.15, -- 警徽气泡
--    [BuildBubbleType.HeroStationBubble] = 1.16, -- 建筑驻扎小人气泡
--    [BuildBubbleType.BuildingLv0Ruins] = 1.1,--需要升级0级废墟建筑至1级
--    [BuildBubbleType.LadyBubble] = 1.2, -- 播放美女视频气泡
--    [BuildBubbleType.CanUseHeroEffectSkill] = 1.5,
--    [BuildBubbleType.CrossWormHoleSub] = 1.6,
--    [BuildBubbleType.DetectEventFinished] = 2,--探测事件完成（雷达黄底气泡）
--    [BuildBubbleType.StorageShopFirstOpen] = 3,--交易行首次打开
--    [BuildBubbleType.HeroStationAvailable] = 4,--英雄驻扎可用
--    [BuildBubbleType.HeroFreeScienceAddTime] = 4.5,--英雄科技加速时间
--    [BuildBubbleType.HeroFreeBuildAddTime] = 0.5,--英雄建筑加速时间
--    [BuildBubbleType.UpgradeAllianceHelp] = 1.31,--升级联盟帮助
--    [BuildBubbleType.ScienceAllianceHelp] = 1.32,--科技研究联盟帮助
--    [BuildBubbleType.HospitalAllianceHelp] = 1.33,--治疗伤兵联盟帮助
--    [BuildBubbleType.FootSoldierUnlock] = 8,--新步兵解锁
--    [BuildBubbleType.FootSoldierFree] = 9,--机器人可以造兵
--    [BuildBubbleType.FootSoldierEnd] = 7.9,--机器人收兵
--    [BuildBubbleType.CarSoldierUnlock] = 10,--新坦克解锁
--    [BuildBubbleType.CarSoldierFree] = 11,--坦克可以造兵
--    [BuildBubbleType.CarSoldierEnd] = 9.9,--坦克收兵
--    [BuildBubbleType.BowSoldierUnlock] = 12,--新飞机解锁
--    [BuildBubbleType.BowSoldierFree] = 13,--飞机可以造兵
--    [BuildBubbleType.BowSoldierEnd] = 11.9,--飞机收兵
--    [BuildBubbleType.NewDecorate] = 13,--飞机收兵
--    
--    [BuildBubbleType.HospitalFree] = 14,--医院可以救治
--    [BuildBubbleType.HospitalEnd] = 15,--医院收兵
--    [BuildBubbleType.ScienceFree] = 16,--可以研究科技
--    [BuildBubbleType.ScienceEnd] = 17,--收取科技
--    [BuildBubbleType.ResidentOrder] = 18,--商业中心气泡
--    --[BuildBubbleType.RocketBomb] = 18.1,
--    [BuildBubbleType.EarthOrder] = 19,--地球订单气泡
--    [BuildBubbleType.Talent] = 19.9,--天赋
--    [BuildBubbleType.ExtendDome] = 20,--苍穹扩建
--    [BuildBubbleType.PastureProduct] = 21,--收取动物副产物
--    [BuildBubbleType.GetItem] = 22,--收取道具
--    [BuildBubbleType.GolloesGift] = 22.6,--咕噜营地奖励
--    [BuildBubbleType.GroceryStore] = 22.7,--杂货店订单
--    [BuildBubbleType.CommonShopFree] = 22.8,--联盟宣战
--    [BuildBubbleType.GolloesMonthCard] = 22.9,--购买咕噜月卡
--    [BuildBubbleType.GetResource] = 23,--收取资源
--    [BuildBubbleType.NoGetResource] = 24,--资源点枯竭
--    [BuildBubbleType.NeedTransport] = 25,--火力发电站中资源为空
--    [BuildBubbleType.AllianceHelp] = 26,--联盟帮助
--    [BuildBubbleType.GetFoodProduct] = 27,--收取食品加工厂产物
--    [BuildBubbleType.DetectEvent] = 28,--探测事件（雷达白底气泡）
--    [BuildBubbleType.HeroExpEffectItem] = 28.4,
--    [BuildBubbleType.PubFreeItem] = 28.5,--酒馆有免费道具
--    [BuildBubbleType.HeroRecruitOther] = 29,--英雄招募
--    [BuildBubbleType.HeroAdvance] = 29.2,--英雄进阶
--    [BuildBubbleType.HeroMedalShop] = 28.75,--英雄勋章商店
--    [BuildBubbleType.HeroRecruit] = 29.1,--英雄招募
--    [BuildBubbleType.BuildZeroUp] = 31,--主城建筑0级需要升级的材料
--    [BuildBubbleType.AllianceBattle] = 32,--联盟战争
--    [BuildBubbleType.AllianceGift] = 33,--联盟礼物
--    [BuildBubbleType.AllianceApply] = 34,--联盟申请
--    [BuildBubbleType.NoAlliance] = 38,--无联盟
--    [BuildBubbleType.HeroStationSkill] = 39,--英雄驻扎技能
--    [BuildBubbleType.Assistance] = 40,--援助
--    [BuildBubbleType.StorageShopMoney] = 41,--交易行收金币
--    [BuildBubbleType.StorageShopGolloes] = 42,--交易行系统回收
--    [BuildBubbleType.FixBuildingAllianceHelp] = 43,--废墟恢复联盟帮助
--    [BuildBubbleType.EnergyTreasure] = 43.3,--体力宝物
--    [BuildBubbleType.PveMonument] = 43.4,--英雄丰碑
--    [BuildBubbleType.BuildUpgradeReward] = 43.5,--建筑升级领奖
--    [BuildBubbleType.BuildCanUpgrade] = 43.6,--建筑升级气泡
--    [BuildBubbleType.KonbiniFree] = 44,--小卖部免费次数
--    --[BuildBubbleType.HeroFreeScienceAddTime] = 45,--英雄科技加速时间
--    --[BuildBubbleType.HeroFreeBuildAddTime] = 46,--英雄建筑加速时间
--    --[BuildBubbleType.WorldTrendStateRefresh] = 47,--天下大势刷新，可领奖
--    [BuildBubbleType.AllianceTask] = 48,--联盟任务
--    [BuildBubbleType.InactivePlayer] = 48.1,--有非活跃玩家
--    [BuildBubbleType.AllianceCareer] = 49,--联盟职业有空位可以任命
--    [BuildBubbleType.GarageRefitFree] = 50,--车库改装免费次数
--    [BuildBubbleType.WormHoleSub] = 51,--有虫洞出口
--    [BuildBubbleType.WormHoleSubZero] = 52,--虫洞出口还未建造 0级
--    [BuildBubbleType.AllianceCityDeclareWar] = 56,--联盟宣战
--    [BuildBubbleType.HeroBountyFinish] = 58,--英雄悬赏结束
--    [BuildBubbleType.HeroBountyFree] = 59,--英雄悬赏开始
--    [BuildBubbleType.HeroOfficialEmpty] = 60,--英雄议会有空位
--    [BuildBubbleType.HeroIntensifyAvailable] = 60.5,--英雄议会 阵营强化
--    [BuildBubbleType.LevelExploreEnergyEnough] = 61,--探险飞船体力充足
--    [BuildBubbleType.EnergyOrder] = 64,--体力订单
--    [BuildBubbleType.EquipmentCanUpgrade] = 65,--
--    [BuildBubbleType.EquipmentSlotCanPutOn] = 66,--
--    [BuildBubbleType.Reserve] = 67,--
--    [BuildBubbleType.SU_ProductGather] = 201,
--    [BuildBubbleType.SU_RepairBuild] = 202,
--    [BuildBubbleType.SU_Level0] = 203,
--    [BuildBubbleType.SU_BuildComplete] = 204,
--    [BuildBubbleType.SU_ItemProduct] = 205,
--    [BuildBubbleType.SU_BuildUse] = 206,
--    [BuildBubbleType.SU_NewMail] = 207,
--    [BuildBubbleType.GiftBubble] = 209,
--    [BuildBubbleType.CookBubble] = 210,
--    [BuildBubbleType.IntelligenceBubble] = 211,
--    [BuildBubbleType.StationBubble] = 212,
--    [BuildBubbleType.EnergyBubble] = 213,
--    [BuildBubbleType.Arena] = 214,
--    [BuildBubbleType.Barrel_Pve] = 217,
--    [BuildBubbleType.HeroEquip] = 72,
--    [BuildBubbleType.GirlGetReward] = 218,
--    [BuildBubbleType.CardGetReward] = 10,
--    [BuildBubbleType.HeroFreeEnergy] = 1.7,
--    [BuildBubbleType.HeroFreeGear] = 1.8,
--    [BuildBubbleType.MonthCard] = 1.8,
--    [BuildBubbleType.MonthCard2] = 1.1,
--    [BuildBubbleType.HeroDispatch] = 1.8,
--    [BuildBubbleType.TruckBubble] = 1.8,
--    [BuildBubbleType.ChatLoveBubble] = 219,
--    [BuildBubbleType.GarageBubble] = 220,
--    [BuildBubbleType.HeroSmallTalentCenter] = 221,
--    [BuildBubbleType.HeroFreeRefitPaper] = 1.8,
--    [BuildBubbleType.Hospital_Treating] = 222,
--    [BuildBubbleType.UpgradeFinish] = 1.2,
--    [BuildBubbleType.SkinShop] = 1.2,
--}

--建筑气泡类型
--BuildBubbleIconName =
--{
--    BuildFixFinishEnd = "bubble_icon_build_repair",
--    EarthOrder = "bubble_icon_earth",
--    EarthOrderRecall = "bubble_icon_earth_rocketrecall",
--    DomeExtend ="bubble_icon_dome",
--    BuildUpgrade ="bubble_bg_build_upgrade1",
--    ScienceAllianceHelp = "bubble_icon_alliance_help_me",
--    HospitalAllianceHelp = "bubble_icon_alliance_help_me",
--    UpgradeAllianceHelp = "bubble_icon_alliance_help_me",
--    ScienceFree = "bubble_icon_science_free",
--    HospitalFree = "icon_bandage",
--    Business = "bubble_icon_business_free",
--    NoGetResource = "bubble_icon_warning",
--    AllianceHelpOthers = "bubble_icon_alliance_help_others",
--    AllianceTask = "bubble_icon_alliance_task",
--    AllianceGift = "bubble_icon_alliance_award",
--    CommonShopFree = "bubble_icon_alliance_award",
--    StorageShopMoney = "bubble_icon_trading_bank",
--    BgCircle = "bubble_bg_circle",
--    BgUnSelect = "bubble_bg_unselect",
--    BgSelect = "bubble_bg_select",
--    BgUnSelect1 = "bubble_bg_unselect1",
--    BgSelect1 = "bubble_bg_select1",
--    GetItem = "bubble_icon_alliance_gift",
--    NeedConnect = "uibuild_road_warning",
--    EarthOrderClock  = "Common_icon_time",
--    HeroAdvance  = "bubble_icon_hero_advance",
--    HeroRecruit  = "bubble_icon_hero_recruit",
--    DetectEvent = "bubble_icon_detect_event",
--    DetectEventComplete = "bubble_icon_detect_complete",
--    AllianceBattle = "bubble_icon_alliance_battle",
--    GolloesGift = "bubble_icon_golloes_gift",
--    AnimalBg = "bubble_bg_animal",
--    AnimalBgYellow = "bubble_bg_animal_yellow",
--    NoAlliance = "bubble_icon_no_alliance",
--    AllianceApply = "bubble_icon_alliance_apply",
--    HeroStationAvailable = "bubble_icon_hero_station_available",
--    HeroStationSkill = "bubble_icon_hero_station_skill",
--    StorageShopFirstOpen = "bubble_icon_trading_bank2",
--    StorageShopGolloes = "bubble_icon_trading_bank3",
--    KonbiniFree = "bubble_icon_konbini_free",
--    WorldTrendStateRefresh = "bubble_icon_Mars",
--    Mars = "bubble_icon_plane",
--    GolloesMc = "bubble_icon_golloes_mc",
--    AllianceCareer = "bubble_icon_alliance_career",
--    InactivePlayer = "bubble_icon_alliance_inactive",
--    GarageRefitFree = "bubble_icon_garagerefit",
--    PveMonument = "bubble_icon_level_explore_energy_enough",
--    BuildingLv0RuinsWhite = "bubble_bg_landlock_white",
--    BuildingLv0RuinsYellow = "bubble_bg_landlock_yellow",
--    AllianceCityDeclareWar = "bubble_icon_declare",
--    BuildUpgradeReward = "bubble_icon_alliance_award",
--    Talent = "bubble_icon_talent",
--    HeroBounty = "bubble_icon_reward",
--    HeroOfficialEmpty = "bubble_icon_hero_official_empty",
--    HeroIntensifyAvailable = "bubble_icon_hero_intensity",
--    LevelExploreEnergyEnough = "bubble_icon_level_explore_energy_enough",
--    ClaimTreasureEnergy = "bubble_icon_museum",
--    EnergyOrder = "bubble_icon_energy_order",
--    RemoveRoad = "bubble_icon_warning",
--    EquipmentCanUpgrade = "bubble_icon_tank",--
--    EquipmentSlotCanPutOn = "bubble_icon_tank",--
--    HeroMedalShop = "bubble_icon_exchange",
--    Reserve = "bubble_icon_exchange",
--    Aircraft = "bubble_icon_aircraft",
--    Tank = "bubble_icon_tank",
--    Infantry = "bubble_icon_infantry",
--    BuildUseBg = "bubble_build_use_bg",
--    BuildUseSlider = "bubble_build_use_slider",
--    BuildUseBed = "bubble_build_use_bed",
--    Money = "bubble_icon_money",
--    SU_RepairBuild = "UImain_icon_repair",--修复
--    SU_Level0 = "qipao18",--0级修建废墟
--    CookBubble = "qipao19",--烹饪气泡
--    UImain_btn_bubble_green = "UImain_btn_bubble_green",
--    UImain_btn_bubble_red = "UImain_btn_bubble_red",
--    UImain_btn_bubble_white = "UImain_btn_bubble_white",
--    UImain_btn_bubble_yellow = "UImain_btn_bubble_yellow",
--    StoryBubble = "qipao21",--推关气泡
--    StationBubble = "qipao22",--派遣气泡
--    --RocketBomb = "bubble_icon_rocket_bomb",
--    UImain_icon_bubble_event = "UImain_icon_bubble_event", 
--    HeroEquip = "uibuild_btn_Equipment",
--    GirlsRewardBack = "UINpcGirl_bubble_01",
--    GirlsReward = "UINpcGirl_bubble_heart1",
--    BarrackCar = "bubble_icon_barrackCar",
--    BarrackCar1 = "bubble_icon_barrackCar1",
--    BarrackFoot = "bubble_icon_barrackFoot",
--    BarrackFoot1 = "bubble_icon_barrackFoot1",
--    BarrackBow = "bubble_icon_barrackBow",
--    BarrackBow1 = "bubble_icon_barrackBow1",
--    HeroSkillEnergy = "bubble_icon_barrackCar",
--    HeroFreeGear = "bubble_icon_barrackCar",
--    HeroFreeBuildAddTime = "bubble_icon_barrackCar",
--    HeroFreeScienceAddTime = "bubble_icon_barrackCar",
--    Bubble_Barrel_Pve = "bubble_icon_special",
--    Bubble_Barrel_Pve_1 = "bubble_icon_special_1",
--    TruckBubble = "bubble_icon_Escort",
--    BlackMarket = "bubble_icon_blackmarket",
--    ChatLove = "bubble_icon_aiqing_tongxun",
--    GarageBubble = "bubble_icon_Modified",
--    UIlevlehang_toukui = "UIlevlehang_toukui_jiahao",
--    HospitalTreating = "UImain_fasttreatment_icon_treating",
--    MainHospitalBg = "UImain_fasttreatment_bg", --其他
--    MainHospitalBg1 = "UImain_fasttreatment_bg1",--待治疗
--    MainHospitalBg2 = "UImain_fasttreatment_bg2",--治疗中
--    MainHospitalAllianceHelp = "UImain_fasttreatment_icon_help",
--    SkinShop = "bubble_fashion",
--}

--奔跑气泡类型
--RunBubbleType =
--{
--    Collect = 1,
--    Build = 2,
--}

--PickResEffectLevel=
--{
--    Low=1,
--    Middle=2,
--    High=3
--
--}

--DawnTaskState =
--{
--    NoComplete = 0, --未完成
--    Received = 1,--已经领取
--    CanReceive = 2, --已经完成但是未领取
--    Lock = 3,--未解锁
--}

TaskState =
{
    NoComplete = 0, --未完成
    CanReceive = 1, --已经完成但是未领取
    Received = 2--已经领取
}

--TaskStateOrder =
--{
--    [TaskState.CanReceive] = 1,
--    [TaskState.NoComplete] = 2,
--    [TaskState.Received] = 3,
--}

--AllianceHelpType =
--{
--    None =-1,
--    Building =0,
--    Queue = 1,
--    FIX_BUILDING =2,
--}

--DailyBoxActive =
--{
--    30,70,120,180,260
--}

--任务跳转类型
--GoType =
--{
--    None= 0,--空
--    Go = 2,--跳转到指定建筑
--    BuildList = 5,--跳转到建筑列表
--    Science = 8,--跳转任务科技所在界面
--    Hero = 13,--英雄升级 跳转英雄背包主界面
--    Farm =40,--代表收取农作物
--    BuildRoad = 43,--跳转修路
--    Searching = 44,--跳转到搜索界面
--    CollectResource = 45, --跳转到对应矿根
--
--    --50-59 每日任务
--    DailyBuildUp = 51,--每日任务建筑升级
--    DailyBarn = 52, --每日任务牧场收获
--    DailyFoodFactory = 53, --每日任务加工厂生产
--
--
--}

--当GoType=2时
--TaskGoBuild =
--{
--    None = 0,--空
--    Upgrade = 1,--表示建筑升级
--    Train = 2,--表示练兵
--    Treat = 3,--表表示治疗伤兵
--    Plant = 4,--表示种植
--    FoodFactory = 5,--表示加工厂加工
--    BuyAnimal = 10,--表示购买动物
--    FeedAnimal = 11,--表示喂养动物
--    GetAnimal = 12,--表示收获动物产品
--    HeroGet = 13,--表示招募
--    HeroUpStar = 14,--表示英雄升阶
--    ResidentOrder = 15,--表示居民订单
--    EarthOrder = 16,--表示贸易火箭
--    GetResource = 17,--表示收取某种资源(固定)
--    GetResourceRandom = 18,--表示收取某种资源(随机)
--
--}

--任务跳转类型
--QuestGoType =
--{
--    None = 0,
--    BuildBtn = 1,--跳到建筑并打开建筑按钮
--    Farm = 2,--跳转到农田种植
--    FarmGet = 3,--跳转到农田收获
--    Pasture = 4,--跳转购买动物
--    GetResource = 5,--跳转收取某种资源(固定)
--    GetResourceRandom = 6,--跳转收取某种资源(随机)
--    BuildList = 7,--跳转去建造列表
--    Science = 8,--跳转去科技
--    HeroUpgrade = 9,--跳转英雄升级
--    BuildRoad = 10,--跳转修路
--    Searching = 11,--跳转搜索界面
--    CollectResource = 12,--跳转到对应矿根
--    DailyBuildUp = 13,--跳转每日任务建筑升级
--    DailyBarn = 14,--跳转每日任务牧场收获
--    DailyFoodFactory = 15,--跳转每日任务加工厂生产
--    AttackMonster = 16,--跳转每日任务集结怪
--    AllianceHelp = 17,--跳转联盟帮助
--    RadarProbe = 18,--每日任务雷达探测
--    ChangePlayerName = 19,--玩家改名
--    GoBusinessCenterWindow = 20,--商业中心
--    CollectGarbage = 21,--大本附近垃圾
--    FactoryWork = 22,--加工厂生产(跳转建筑分离出来)
--    GoRobot = 23,--跳转机器人
--    GoBarracks = 24,--跳转训练营
--    GoBindAccount = 25,--绑定账号
--    GoConnectBuild = 26,--连接建筑道路
--    MonsterReward = 27,--拾取野怪奖励箱子
--    GoHeroStation = 28,--英雄驻守
--    GoGiftMall = 29,--礼包商城
--    GoBagPackUseItem = 30,--跳转到背包使用道具
--    GoSearchEnemy = 31,--寻找附近敌人
--    GoGarageUpgrade = 32,--跳转车库升级改装
--    GoHeroStationScores = 33,--跳转驻守目标增益
--    GoHospital = 34,--跳转医院救治
--    GoPveLevel = 35,--pve跳转关卡
--    GoTile = 36,--跳转地块
--    GoUnlockedTile = 37,--跳转可解锁地块
--    GoLockMonster = 38,--击败地块怪物
--    GoHeroTrust = 39, --英雄委托
--    FactoryWorkNew = 40, --加工厂生产新
--    GoTriggerPve = 41,--pve任务专用 指定trigger
--    GoLandPve = 42,--pve专用 指定地块坐标
--    GoEnergy = 43,--体力订单
--    GoFelledTree = 44,--砍树
--    GoPveAutoTo = 45,
--    GoActUI = 46,--跳转活动界面
--    GoCityCollect = 47,--跳转城内矿
--    GoFormation = 48,--指向快捷编队
--    GoTaskToBuild = 49,--任务跳转建筑
--    GoCheckBuild = 50,--可建造优先建造，不可建造最低等级
--    GoHeroBag = 51,--英雄碎片兑换智慧勋章
--    GoHeroSkill = 52,--英雄碎片兑换智慧勋章
--    GoBuildOpenUpgrade = 53,--跳转到某个建筑打开升级界面
--    GoWorldToSearch = 54,--跳转到世界指引搜索
--    HeroStar = 55,--跳转英雄升星
--    GoWorldCity = 56,--跳转遗迹城点
--    GoFlint = 57,--前往火晶石
--    GoWorldBuildList = 58,--跳转赛季建筑
--    GoDailyUI = 59,--跳转到每日活动
--    GoSeasonDesertMaxLv = 60,--赛季最高等级地块
--    GoSelfDesert = 61,--赛季自己最低等级地块
--    GoSeasonManager = 62,--前往地块管理
--    GoActWindowByType = 63,--根据活动类型跳转
--    GOGiftPackageView = 64,--根据礼包id跳转到礼包
--    GoGuidEventToWorld = 65,--引导用 事件id跳转到世界海盗船
--    GoHeroBagRankUp = 66,--英雄升阶
--    PrologueBridge = 68,--序章造桥气泡
--    SU_GoTile = 69, --跳转最近的地块怪物
--    SU_CollectedGarbage = 70, -- 采集垃圾
--    SU_GoGirl = 71, -- 跳转美女
--    Go_AllianceScience = 72, --联盟科技
--    Go_PoliceInsignia = 73, --跳转警徽建筑
--    GO_LandLock = 74,--跳到指定地块位置
--    GoListBuildOpenUpgrade = 75,--跳转到列表中最高等级建筑打开升级界面
--    GO_UIAllianceCompete = 76,--跳到联盟对决
--    Go_UpdatePoliceInsignia = 77, -- 点击升级警徽建筑，没有子建筑的
--    GoWorld = 78, --跳转世界
--    GoSeasonFactionRewards = 79, --赛季势力奖励
--}

--任务描述类型
--QuestDescType =
--{
--    Normal = 1,
--    Build = 2, --和建筑交互
--    Train = 3, --士兵名字
--    Farm = 4, --farming表的名字
--    Factory = 5, --factory表的名字
--    ResourceItem = 6, --资源道具表名字
--    HeroUpStar = 7, --英雄星级
--    Resource = 8, --资源表
--    Science = 9, --科技表名字
--    Monster = 10, --怪物表名字
--    Robot = 11, --机器人名字
--    LandLockMonster = 12, --aps_monsterlock,xml的名字
--    HeroQuality = 13, --英雄稀有度颜色
--    Trigger = 14, --找指定的Trigger
--    HeroSkill = 15,
--    Season = 16, 
--    ChangeLevel = 17, --切换关卡
--    Blueprint = 18, -- 蓝图制造
--    Destroy_ = 19, -- 破坏东西（砍树/挖石头什么的）
--    Building = 20, -- 建造建筑
--    Position = 21, -- 坐标
--    TalkNPC_G = 22, -- 执行线性引导，有任务完成的callback。完成条件: 执行到最后一步，即nextId == -1
--    DoGuide = 23, -- 执行线性引导，没有其他操作
--    
--    --启动条件：PVETrigger配了GuideId
--    --执行非线性引导，有任务完成的callback。
--    --完成条件: 会传入多个结束Id，根据当前条件执行不同的分支，只要当前guideId == 任一结束Id，就算完成。
--    --无论完成与否，都会执行到当前分支的最后一步
--    TalkNPC_T = 24,
--    
--    ZombieWave = 25, -- 丧尸攻城
--    Self_Talk = 26, -- 我自己脑袋顶上说话。gopara填多语言id
--    GotoBuild = 27, -- 移动到建筑按钮
--    OpenHeroRecruit = 28,--直接打开招募界面
--    SearchMonster = 29,--搜怪
--    PlayerBehavior = 30,--玩家行为(洗澡，大小便什么的)
--    SPEquipStarTask = 31, --专武升星任务,星级参数,填写在para3
--}

--任务执行类型
--QuestDoType =
--{
--    NPC = 1,
--    Collect = 2,
--    Monster = 3,
--    Build = 4,
--    Position = 5,
--}

--PlayerBehavior = 
--{
--    Bathe = 1,
--    Stool = 2,
--    Pee = 3,
--}

--当GoType=44时
--TaskGoBuild44Type =
--{
--    Monster =  1,--代表搜怪
--    Gas =  2,--代表搜瓦斯
--    Metal =  3,--代表搜水晶
--    Water =  4,--代表搜水源
--}

--当GoType=45时
--TaskResourceType =
--{
--    [1] = ResourceType.Oil,
--    [2] = ResourceType.Metal,
--    [3] = ResourceType.Water,
--    [4] = ResourceType.Electricity
--}

--界面中任务类型排序 ，并非表中任务type
--TaskType =
--{
--    Chapter = 1,--章节任务
--    Main = 2,--主线任务
--    Daily = 3,--日常任务
--}

--TaskTypeSort =
--{
--    TaskType.Chapter,
--    --TaskType.Main,
--    --TaskType.Daily,
--}

--SettingType =
--{
--    Notice = 1,--消息通知
--    Setting = 2,--通用设置
--    --Account = 3,--账号
--    Description = 4,--说明
--    Language = 5,--语言
--    --RedemptionCode = 6, --兑换码
--    Ban = 7, --屏蔽用户
--    --Flag = 8,--国旗
--    --GM = 9,--gm
--    --Service = 10,--服务条款
--    NewGame = 11,--开始新游戏
--    --GM_Talk = 14, --GM聊天
--    --Vip = 15
--    ChangeId = 16,--切号
--    PVE = 17, -- 进入pve
--    PVEFreeCamera = 18,  -- PVE相机自由移动
--    AllowTracking = 19, -- iOS授权允许跟踪
--    PlayerNation = 20,--玩家国家
--    Roles = 21,
--    Ping = 22,
--    ChangeScene = 23,
--    GameNotice = 24,
--    ChangeView = 25,
--    WareHouse = 26,
--    AddItem = 27,
--    Home_World = 28,
--    NpcTest = 29,
--    HeroTest = 30,
--    TriggerTest = 31,
--    RunnerTest = 32,
--    ShowBtn = 33,
--    FixStuck = 34,
--    Science = 35,
--	Radar = 36,
--    PicGuide = 37,
--    TestTimeLine = 38,
--    OutputLog = 39,
--    GameSpeed = 40,
--    AutoAttack = 41,
--    Activity = 42,
--    ApsPVE = 43,
--    Console = 44,
--    MoreSetting = 45,
--    ArtTest = 46,
--	DeleteAccount = 47,
--    DebugReward = 48,
--    GMNewGame = 49,
--    CustomService = 50, -- 客诉
--    HelpCenter = 51, -- 客服中心
--    Tos = 52,
--    Privacy = 53,
--    TestTikTokEvent = 54, --tiktok打点测试功能
--    GMTestFunc = 55, --Gm功能测试(修改函数测试各种功能)
--    Copy = 56, --复制账号
--    LayoutChange = 57, -- 横竖屏切换
--}

--SettingShowTypes = {
--    SettingType.Notice,
--    SettingType.Setting,
--    SettingType.Language,
--    SettingType.NewGame,
--}

--SettingTypeSort =
--{
--    --SettingType.Notice,
--    SettingType.Setting,
--    --SettingType.Account,
--    --SettingType.Description,
--    SettingType.Language,
--    --SettingType.RedemptionCode,
--    SettingType.Ban,
--    --SettingType.Flag,
--    --SettingType.Service,
--    SettingType.NewGame,
--    --SettingType.Vip,
--    --SettingType.GM_Talk,
--    SettingType.ChangeId,
--    SettingType.PVE,
--    SettingType.Copy,
--    --SettingType.PVEFreeCamera,
--    SettingType.AllowTracking,
--    SettingType.PlayerNation,
--    --SettingType.Ping,
--    --SettingType.ChangeScene,
--    --    SettingType.Roles,
--    --    SettingType.Roles,
--    --SettingType.ApsPVE,
--    --SettingType.FixStuck,
--    --SettingType.WareHouse,
--    SettingType.AddItem,
--    --    SettingType.Roles,
--    SettingType.GameNotice,
--    SettingType.Home_World,
--    --SettingType.NpcTest,
--    --SettingType.HeroTest,
--    --SettingType.TriggerTest,
--    --SettingType.RunnerTest,
--    SettingType.ShowBtn,
--    --SettingType.Science,
--    --SettingType.Radar,
--    --SettingType.PicGuide,
--    SettingType.TestTimeLine,
--    SettingType.OutputLog,
--    SettingType.GameSpeed,
--    --SettingType.AutoAttack,
--    --SettingType.Activity,
--    SettingType.Console,
--    SettingType.DeleteAccount,
--    SettingType.ArtTest,
--    SettingType.DebugReward,
--    SettingType.GMNewGame,
--    SettingType.CustomService,
--    SettingType.HelpCenter,
--    SettingType.Tos,
--    SettingType.Privacy,
--    SettingType.MoreSetting,
--    SettingType.TestTikTokEvent,
--    SettingType.GMTestFunc,
--    SettingType.LayoutChange,
--}

--AllianceMemberManageType = {
--    MemberData = 1,
--    MemberRankChange = 2,
--    LeaderTrans = 3,
--    LeaderReplace = 4,
--    MemberQuit = 5,
--    Mail = 6,
--    ResSupport = 7,
--    GolloesTrade = 8,
--    OfficalCancel = 9,
--}
--消息推送
--SettingNoticeType =
--{
--    PUSH_GM = 0,
--    PUSH_QUEUE = 1,         --队列
--    PUSH_WORLD = 2,         --世界地图,拆分被攻击和被侦查
--    PUSH_MAIL = 3,          --联盟
--    PUSH_STATUS = 4,        --状态
--    PUSH_ALLIANCE = 5,      --社交（聊天） 去掉联盟邮件
--    PUSH_ACTIVITY = 6,      --活动 5的联盟邮件加进来
--    PUSH_RESOURCE = 7,      --7资源满仓
--    PUSH_CHAT = 8,          --8聊天
--    PUSH_REWARD = 9,        --9礼包...音乐杀僵尸、食堂开餐等
--    PUSH_WEB_ONLINE = 10,   --web在线?
--    PUSH_ATTACK = 11,       --从2拆分出来,被攻击
--    PUSH_SCOUT = 12,        --从2拆分出来,被侦察
--    NOT_CHECK = 99,         --不用检查
--}

--SettingNoticeTypeSort =
--{
--    SettingNoticeType.PUSH_WORLD,
--    SettingNoticeType.PUSH_MAIL,
--    SettingNoticeType.PUSH_ALLIANCE,
--    SettingNoticeType.PUSH_ACTIVITY,
--    SettingNoticeType.PUSH_RESOURCE,
--    SettingNoticeType.PUSH_CHAT,
--    SettingNoticeType.PUSH_REWARD,
--    SettingNoticeType.PUSH_ATTACK,
--    SettingNoticeType.PUSH_SCOUT,
--}

--SettingNoticeStatus =
--{
--    Off = 0,    --关闭状态
--    On = 1,   --开启状态
--}

--SettingNoticeUnlock =
--{
--    Lock = 0,       --锁住
--    UnLock = 1,     --解锁
--}

Language =
{
    Unspecified = 0,                -- 未指定。
    Afrikaans = 1,                  -- 南非荷兰语。
    Albanian = 2,                   -- 阿尔巴尼亚语。
    Arabic = 3,                     -- 阿拉伯语。
    Basque = 4,                     -- 巴斯克语。
    Belarusian = 5,                 -- 白俄罗斯语。
    Bulgarian = 6,                  -- 保加利亚语。
    Catalan = 7,                    -- 加泰罗尼亚语。
    ChineseSimplified = 8,          -- 简体中文。
    ChineseTraditional = 9,         -- 繁体中文。
    Croatian = 10,                  -- 克罗地亚语。
    Czech = 11,                     -- 捷克语。
    Danish = 12,                    -- 丹麦语。
    Dutch = 13,                     -- 荷兰语。
    English = 14,                   -- 英语。
    Estonian = 15,                  -- 爱沙尼亚语。
    Faroese = 16,                   -- 法罗语。
    Finnish = 17,                   -- 芬兰语。
    French = 18,                    -- 法语。
    Georgian = 19,                  -- 格鲁吉亚语。
    German = 20,                    -- 德语。
    Greek = 21,                     -- 希腊语。
    Hebrew = 22,                    -- 希伯来语。
    Hungarian = 23,                 -- 匈牙利语。
    Icelandic = 24,                 -- 冰岛语。
    Indonesian = 25,                -- 印尼语。
    Italian = 26,                   -- 意大利语。
    Japanese = 27,                  -- 日语。
    Korean = 28,                    -- 韩语。
    Latvian = 29,                   -- 拉脱维亚语。
    Lithuanian = 30,                -- 立陶宛语。
    Macedonian = 31,                -- 马其顿语。
    Malayalam = 32,                 -- 马拉雅拉姆语。
    Norwegian = 33,                 -- 挪威语。
    Persian = 34,                   -- 波斯语。
    Polish = 35,                    -- 波兰语。
    PortugueseBrazil = 36,          -- 巴西葡萄牙语。
    PortuguesePortugal = 37,        -- 葡萄牙语。
    Romanian = 38,                  -- 罗马尼亚语。
    Russian = 39,                   -- 俄语。
    SerboCroatian = 40,             -- 塞尔维亚克罗地亚语。
    SerbianCyrillic = 41,           -- 塞尔维亚西里尔语。
    SerbianLatin = 42,              -- 塞尔维亚拉丁语。
    Slovak = 43,                    -- 斯洛伐克语。
    Slovenian = 44,                 -- 斯洛文尼亚语。
    Spanish = 45,                   -- 西班牙语。
    Swedish = 46,                   -- 瑞典语。
    Thai = 47,                      -- 泰语。
    Turkish = 48,                   -- 土耳其语。
    Ukrainian = 49,                 -- 乌克兰语。
    Vietnamese = 50,                -- 越南语。
}

--CountryCodeToLanguage =
--{
--    ["AE"] = Language.Arabic,
--    ["AF"] = Language.Arabic,
--    ["AR"] = Language.Spanish,
--    ["BR"] = Language.PortuguesePortugal,
--    ["CN"] = Language.ChineseSimplified,
--    ["DE"] = Language.German,
--    ["ENG"] = Language.English,
--    ["ES"] = Language.Spanish,
--    ["FR"] = Language.French,
--    ["GB"] = Language.English,
--    ["HK"] = Language.ChineseTraditional,
--    ["IN"] = Language.English,
--    ["IT"] = Language.Italian,
--    ["JP"] = Language.Japanese,
--    ["KR"] = Language.Korean,
--    ["PH"] = Language.English,
--    ["PT"] = Language.PortuguesePortugal,
--    ["QA"] = Language.Arabic,
--    ["RU"] = Language.Russian,
--    ["TH"] = Language.Thai,
--    ["TR"] = Language.Turkish,
--    ["TW"] = Language.ChineseTraditional,
--    ["US"] = Language.English,
--}

--LanguageToIndex =
--{
--    ["zh-Hant"] = Language.ChineseSimplified,
--    ["pt"] = Language.PortuguesePortugal,
--    ["ar"] = Language.Arabic,
--    ["de"] = Language.German,
--    ["fr"] = Language.French,
--    ["th"] = Language.Thai,
--    ["tr"] = Language.Turkish,
--    ["ja"] = Language.Japanese,
--    ["ko"] = Language.Korean,
--    ["es"] = Language.Spanish,
--    ["it"] = Language.Italian,
--    ["ru"] = Language.Russian,
--    ["en"] = Language.English,
--}

--SteamLanguageToPay = {
--    ["arabic"] = "ar",
--    ["bulgarian"] = "bg",
--    ["schinese"] = "zh-CN",
--    ["tchinese"] = "zh-TW",
--    ["czech"] = "cs",
--    ["danish"] = "da",
--    ["dutch"] = "nl",
--    ["english"] = "en",
--    ["finnish"] = "fi",
--    ["french"] = "fr",
--    ["german"] = "de",
--    ["greek"] = "el",
--    ["hungarian"] = "hu",
--    ["italian"] = "it",
--    ["japanese"] = "ja",
--    ["koreana"] = "ko",
--    ["norwegian"] = "no",
--    ["polish"] = "pl",
--    ["portuguese"] = "pt",
--    ["brazilian"] = "pt-BR",
--    ["romanian"] = "ro",
--    ["russian"] = "ru",
--    ["spanish"] = "es",
--    ["latam"] = "es-419",
--    ["swedish"] = "sv",
--    ["thai"] = "th",
--    ["turkish"] = "tr",
--    ["ukrainian"] = "uk",
--    ["vietnamese"] = "vn",
--}

--LanguageName =
--{
--    [Language.Afrikaans] = "Afrikaans",
--    [Language.Albanian] = "Albanian",
--    [Language.Arabic] = "Arabic",
--    [Language.Basque] = "Basque",
--    [Language.Belarusian] = "Belarusian",
--    [Language.Bulgarian] = "Bulgarian",
--    [Language.Catalan] = "Catalan",
--    [Language.ChineseSimplified] = "ChineseSimplified",
--    [Language.ChineseTraditional] = "ChineseTraditional",
--    [Language.Croatian] = "Croatian",
--    [Language.Czech] = "Czech",
--    [Language.Danish] = "Danish",
--    [Language.Dutch] = "Dutch",
--    [Language.English] = "English",
--    [Language.Estonian] = "Estonian",
--    [Language.Faroese] = "Faroese",
--    [Language.Finnish] = "Finnish",
--    [Language.French] = "French",
--    [Language.Georgian] = "Georgian",
--    [Language.German] = "German",
--    [Language.Greek] = "Greek",
--    [Language.Hebrew] = "Hebrew",
--    [Language.Hungarian] = "Hungarian",
--    [Language.Icelandic] = "Icelandic",
--    [Language.Indonesian] = "Indonesian",
--    [Language.Italian] = "Italian",
--    [Language.Japanese] = "Japanese",
--    [Language.Korean] = "Korean",
--    [Language.Latvian] = "Latvian",
--    [Language.Lithuanian] = "Lithuanian",
--    [Language.Macedonian] = "Macedonian",
--    [Language.Malayalam] = "Malayalam",
--    [Language.Norwegian] = "Norwegian",
--    [Language.Persian] = "Persian",
--    [Language.Polish] = "Polish",
--    [Language.PortugueseBrazil] = "PortugueseBrazil",
--    [Language.PortuguesePortugal] = "PortuguesePortugal",
--    [Language.Romanian] = "Romanian",
--    [Language.Russian] = "Russian",
--    [Language.SerboCroatian] = "SerboCroatian",
--    [Language.SerbianCyrillic] = "SerbianCyrillic",
--    [Language.SerbianLatin] = "SerbianLatin",
--    [Language.Slovak] = "Slovak",
--    [Language.Slovenian] = "Slovenian",
--    [Language.Spanish] = "Spanish",
--    [Language.Swedish] = "Swedish",
--    [Language.Thai] = "Thai",
--    [Language.Turkish] = "Turkish",
--    [Language.Ukrainian] = "Ukrainian",
--    [Language.Vietnamese] = "Vietnamese",
--}

SuportedLanguages = {
    Language.English,
    Language.French,
    Language.German,
    --Language.Russian,
    Language.Korean,
    Language.Thai,
    Language.Japanese,
    Language.PortuguesePortugal,
    Language.Spanish,
    Language.Turkish,
    --Language.Indonesian,
    Language.ChineseTraditional,
    Language.ChineseSimplified,
    Language.Italian,
    --Language.Polish,
    --Language.Dutch,
    Language.Arabic,
    Language.Vietnamese,
}

--OnlineSuportedLanguages =
--{
--    Language.English,
--    Language.ChineseSimplified,
--}

--SuportedLanguagesName = {}
--SuportedLanguagesName[Language.English] = "English"
--SuportedLanguagesName[Language.French] = "Français"
--SuportedLanguagesName[Language.German] = "Deutsch"
--SuportedLanguagesName[Language.Russian] = "Pусский"
--SuportedLanguagesName[Language.Korean] = "한국어"
--SuportedLanguagesName[Language.Thai] = "ไทย"
--SuportedLanguagesName[Language.Japanese] = "日本語"
--SuportedLanguagesName[Language.PortuguesePortugal] = "Português"
--SuportedLanguagesName[Language.Spanish] = "Español"
--SuportedLanguagesName[Language.Turkish] = "Türkçe"
--SuportedLanguagesName[Language.Indonesian] = "Indonesia"
--SuportedLanguagesName[Language.ChineseTraditional] = "繁體中文"
--SuportedLanguagesName[Language.ChineseSimplified] = "简体中文"
--SuportedLanguagesName[Language.Italian] = "Italiano"
--SuportedLanguagesName[Language.Polish] = "Polski"
--SuportedLanguagesName[Language.Dutch] = "Nederlands"
--SuportedLanguagesName[Language.Arabic] = "العربية"
--SuportedLanguagesName[Language.Vietnamese] = "Tiếng Việt"

--SuportedLanguagesLocalName = {}
--SuportedLanguagesLocalName[Language.English] = "390752"
--SuportedLanguagesLocalName[Language.French] = "390754"
--SuportedLanguagesLocalName[Language.German] = "390756"
--SuportedLanguagesLocalName[Language.Russian] = "390757"
--SuportedLanguagesLocalName[Language.Korean] = "390758"
--SuportedLanguagesLocalName[Language.Thai] = "390780"
--SuportedLanguagesLocalName[Language.Japanese] = "390766"
--SuportedLanguagesLocalName[Language.PortuguesePortugal] = "390755"
--SuportedLanguagesLocalName[Language.Spanish] = "390753"
--SuportedLanguagesLocalName[Language.Turkish] = "390773"
--SuportedLanguagesLocalName[Language.Indonesian] = "115625"
--SuportedLanguagesLocalName[Language.ChineseTraditional] = "391083"
--SuportedLanguagesLocalName[Language.ChineseSimplified] = "390759"
--SuportedLanguagesLocalName[Language.Italian] = "390760"
--SuportedLanguagesLocalName[Language.Polish] = "390769"
--SuportedLanguagesLocalName[Language.Dutch] = "390768"
--SuportedLanguagesLocalName[Language.Arabic] = "390782"
--SuportedLanguagesLocalName[Language.Vietnamese] = "390781"

--SettingSetType =
--{
--    Effect = 0,--音效
--    Sound = 1,--声音
--    Message = 2,--消息
--    Game = 3,--游戏
--    Task = 4,--任务
--    Question = 5,--反馈
--    Position = 6,--位置
--    DebugChooseServer = 7,--Loading是否显示选服界面
--    SceneParticles = 9,--场景粒子
--    Resolution = 10,--场景相机分辨率
--    FPS = 11,--帧率
--    Surface = 12,--地表
--    Build = 13,--建筑
--    Decorations = 14,--装饰物
--    Monster = 15,--野怪
--    SkyBox = 16,--天空盒
--    ShaderLod = 17,--设置shader LOD级别
--    Diamond = 18,--使用钻石提示
--    ShowAnimal = 19,--显示动物
--    ShowFarm = 20,--显示农作物
--    Vibrate = 21,
--    SendNotice = 22,--发推送
--    PveResetPos = 23,--PVE 脱离卡死
--    ShowTroopName = 24,--显示行军名称
--    ShowTroopHead = 25,--显示行军头像
--    ShowTroopDestroyIcon = 26,--显示行军拆耐久进度
--    ShowTroopBloodNum = 27,--显示掉血
--    ShowTroopAttackEffect = 28,--显示攻击效果
--    ShowTroopGunAttackEffect = 29,--显示炮口效果
--    ShowTroopDamageAttackEffect = 30,--显示爆炸效果
--    FullScreen = 31,--全屏显示
--    ScreenResolution = 32,--设置窗口分辨率
--    GraphicAPI = 33,
--    ProfilerGraph = 25,
--    GraphicSetting = 26,
--    ChatShowVip = 39,
--    LikeShowTips = 40,
--    ClearDevice = 43,
--    DeleteMail = 44,
--}

--GMSettings = 
--{
--    SettingSetType.DebugChooseServer,
--    SettingSetType.SendNotice,
--    SettingSetType.GraphicAPI,
--    SettingSetType.ProfilerGraph,
--    SettingSetType.GraphicSetting,
--}

--SettingSetSoundTypeSort =
--{
--    SettingSetType.Effect,
--    SettingSetType.Sound,
--    SettingSetType.Vibrate,
--}


--SettingSetClearTypeSort =
--{
--    --SettingSetType.Message,
--    SettingSetType.Game,
--    SettingSetType.DeleteMail,
--    SettingSetType.ClearDevice,
--}

--SettingSetPrivilegeTypeSort =
--{
--    SettingSetType.ChatShowVip,
--}

--SettingSetPromptTypeSort =
--{
--    SettingSetType.Diamond,
--    --SettingSetType.Task,
--    --SettingSetType.Question,
--    --SettingSetType.Position,
--    SettingSetType.LikeShowTips,
--}
HeroSkillType = {
    --0 默认
    DEFAULT = 0,

    --1 全局生效技能
    GLOBAL_SKILL = 1,

    --2 编队中生效技能
    FORMATION_SKILL = 2,

    --3 机器人生效技能
    ROBOT_SKILL = 3,

    --10 普通攻击
    NORMAL_SKILL = 10,

    --11 怒气攻击(主动技能)
    RAGE_SKILL = 11,

    --12 进入战斗释放技能
    START_BATTLE_SKILL = 12,

    --13 特定英雄加成技能
    SPECIAL_HERO_ADD_SKILL = 13,

    --14 子技能
    SUB_SKILL = 14,
}

--TrainFreeType =
--{
--    Bauble = 1,--来自装饰建筑
--}

--SettingSetPerformanceTypeSort =
--{
--    SettingSetType.ShaderLod,
--    --SettingSetType.PveResetPos,
--    SettingSetType.DebugChooseServer,
--    SettingSetType.GraphicSetting,
--    SettingSetType.ProfilerGraph,
--    SettingSetType.GraphicAPI,
--    
--    --SettingSetType.ShaderLod,
--    --SettingSetType.PveResetPos,
--    --SettingSetType.DebugChooseServer,
--    --SettingSetType.SceneParticles,
--    --SettingSetType.Surface,
--    --SettingSetType.Build,
--    --SettingSetType.Decorations,
--    --SettingSetType.Monster,
--    --SettingSetType.ShowAnimal,
--    --SettingSetType.ShowFarm,
--    --SettingSetType.SendNotice,
--    --SettingSetType.ShowTroopName,
--    --SettingSetType.ShowTroopHead,
--    --SettingSetType.ShowTroopDestroyIcon,
--    --SettingSetType.ShowTroopBloodNum,
--    --SettingSetType.ShowTroopAttackEffect,
--    --SettingSetType.ShowTroopGunAttackEffect,
--    --SettingSetType.ShowTroopDamageAttackEffect,
--    --SettingSetType.SkyBox,
--}


--SettingSetResolutionTypeSort =
--{
--    SettingSetType.Resolution,
--    SettingSetType.FPS,
--}

--SettingScreenResolutionTypeSort =
--{
--    SettingSetType.FullScreen,
--    SettingSetType.ScreenResolution,
--}

--CountryCode =
--{
--    "AE", "AL", "AM", "AO", "AR", "AT", "AU", "AZ", "AW",
--    "BD", "BE", "BG", "BH", "BR", "BY", "BL", "BIH",
--    "CA", "CH", "CL", "CN", "CP", "CZ", "CU", "CY", "CR",
--    "DE", "DK", "DZ", "DO",
--    "EC", "EE", "EG", "ES", "ENG",
--    "FI", "FR",
--    "GB", "GR", "GE", "GH",
--    "HK", "HR", "HU", "HN",
--    "ID", "IE", "IL", "IN", "IR", "IT", "IQ",
--    "JP", "JO", "JM",
--    "KH", "KR", "KW", "KZ", "KE",
--    "LA", "LB", "LI", "LT", "LU", "LV", "LK", "LY",
--    "MK", "MM", "MX", "MY", "MN", "MA", "ME", "MD",
--    "NG", "NL", "NO", "NZ", "NP",
--    "OM",
--    "PA", "PE", "PH", "PK", "PL", "PT", "PR",
--    "QA",
--    "RO", "RS", "RU",
--    "SA", "SE", "SG", "SI", "SK", "SY", "SCO", "SV",
--    "TH", "TN", "TR", "TW",
--    "UA", "UN", "US", "UZ", "UKL",
--    "VE", "VN",
--    "YE", "YU",
--    "ZA"
--}

--DmaCountry = {
--    "AT",  --奥地利
--    "BE",  --比利时
--    "BG",  --保加利亚
--    "CY",  --塞浦路斯
--    "CZ",  --捷克
--    "DE",  --德国
--    "DK",  --丹麦
--    "EE",  --爱沙尼亚
--    "ES",  --西班牙
--    "FI",  --芬兰
--    "FR",  --法国
--    "GR",  --希腊
--    "HR",  --克罗地亚
--    "HU",  --匈牙利
--    "IE",  --爱尔兰
--    "IT",  --意大利
--    "LT",  --立陶宛
--    "LU",  --卢森堡
--    "LV",  --拉脱维亚
--    "MT",  --马耳他
--    "NL",  --荷兰
--    "PL",  --波兰
--    "PT",  --葡萄牙
--    "RO",  --罗马尼亚
--    "SE",  --瑞典
--    "SI",  --斯洛文尼亚
--    "SK",  --斯洛伐克
--    "UK",  --英国（已脱欧，但仍包括在此列表中）
--    "LI",  --列支敦士登
--    "NO",  --挪威
--    "IS",  --冰岛
--}

--账号绑定状态
--AccountBandState =
--{
--    UnBand = 0,                 --未绑定账号
--    UnCheck = 1,                --未验证
--    Band = 2,                   --已验证、即已绑定
--}

--账号验证状态
--AccountCheckState =
--{
--    UnCheck = 0,                 --未验证
--    Check = 1,                   --已验证
--}

--打开绑定账号页面类型
--AccountBindType =
--{
--    Bind = 1,                     --绑定账户
--    Change = 2,                   --改变账户
--}

--平台
RuntimePlatform =
{
    OSXEditor = 0,
    OSXPlayer = 1,
    WindowsPlayer = 2,
    WindowsEditor = 7,
    IPhonePlayer = 8,
    Android = 11,
    LinuxPlayer = 13,
    LinuxEditor = 16,
    WebGLPlayer = 17,
    WSAPlayerX86 = 18,
    WSAPlayerX64 = 19,
    WSAPlayerARM = 20,
    PS4 = 25,
    XboxOne = 27,
    tvOS = 31,
    Switch = 32,
    Lumin = 33,
}

--BIND_TYPE =
--{
--    DEVICE = 0,
--    FACEBOOK = 1,
--    GOOGLEPLAY = 2,
--    CUSTOM = 3,
--    APPSTORE = 4,
--    OICQ = 6,
--    WEIBO = 7,
--    WX = 8,
--}

--PinPwdStatus =
--{
--    NoHave = 0,
--    Have = 1,
--}

--AccountCreateType =
--{
--    Register = 0,
--    ChangePassword = 1,
--}

--UIPinInputType =
--{
--    Enter = 0,      --进入游戏
--    Set = 1,        --设置PIN码
--    Change = 2,     --修改PIN码
--}

--UIPinOpenState =
--{
--    Open = 0,        --开启Pin码
--    Close = 2,      --关闭PIN码
--}

--BindSuccessType =
--{
--    BindAccount = 0,        --绑定账号成功
--    ChangePassword = 1,     --修改密码成功
--}

--BuildState =
--{
--    BUILD_LIST_RECEIVED = 1,      --收起的建筑可以放置
--    BUILD_LIST_STATE_OK = 2,      --满足建造条件
--    BUILD_LIST_LACK_PEOPLE = 3,   --缺少人口
--    BUILD_LIST_LACK_RESOURCE = 4,   --缺少资源
--    BUILD_LIST_STATE_NEED_RESOURCE_ITEM = 5,  --缺少资源道具,
--    BUILD_LIST_STATE_NEED_BUY_ITEM = 6,  --缺少物品,
--    BUILD_LIST_STATE_NEED_ITEM_FORM_GIFT = 7,  --缺少物品,物品来自于礼包（目前用于机器人建筑）
--    BUILD_LIST_STATE_BREAK = 8,      --建筑破损
--    BUILD_LIST_SCIENCE = 9,   --缺少科技但有科技前置建筑
--    BUILD_LIST_SCIENCE_BUILD = 10,   --缺少科技和前置建筑
--    BUILD_LIST_STATE_NEED_LEVEL = 11, --玩家等级不够
--    BUILD_LIST_STATE_VIP_LEVEL = 12,--vip等级不够
--    BUILD_LIST_NEED_GUIDE = 13,      --建造需要完成引导
--    BUILD_LIST_REACH_CUR_MAX = 14,      --建造达到当前可解锁最大
--    BUILD_LIST_PREBUILD = 15,--前置建筑
--    BUILD_LIST_STATE_NEED_BUY = 16,  --需要礼包购买
--    BUILD_LIST_STATE_NEED_BUY_MONTH = 17,  --缺少月卡,
--    BUILD_LIST_REACH_MAX = 18,      --建造达到最大
--    BUILD_LIST_NEED_PARA3_SCIENCE = 19,      --建造需要para3科技
--    BUILD_LIST_NEED_UNLOCK_TILE = 20,      --建造需要解锁地块
--    BUILD_LIST_NEED_UNLOCK_TALENT = 21,      --建造需要解锁地块
--    BUILD_LIST_NEED_QUEST = 22,      --建造需要完成任务
--    BUILD_LIST_NEED_CHAPTER = 23,      --建造需要完成章节
--    BUILD_LIST_NEED_ALLIANCE_CITY_BUILD = 24,      --建造需要赛季城
--    BUILD_LIST_NEED_ALLIANCE_CENTER_FOR_REPLACE = 25, --重放赛季建筑需要联盟中心前置条件
--    BUILD_LIST_NEED_ALLIANCE_CENTER_FOR_BUILD = 26, --建造赛季建筑需要联盟中心前置条件
--    BUILD_LIST_NEED_MASTERY = 27, --建造需要学习专精
--    BUILD_LIST_NEED_AREA = 28, --建造需要解锁区域
--}


--HeroListSortType =
--{
--    Quality = 0,   --品质  --dropdown 从0开始
--    Level = 1,     --等级排序
--    Power = 2,     --战力排序
--}

--HeroListSortTypeSort =
--{
--    HeroListSortType.Quality,
--    HeroListSortType.Level,
--    HeroListSortType.Power,
--}

--HeroState =
--{
--    Free = 0,           --空闲中
--    FormationMarch = 1,   --跟随编队出征中
--    StationBuilding = 7,    --驻扎在建筑上
--    FormationInCity = 8,    --在城内的编队里  没有出征
--}

--SlotState =
--{
--    Lock = 0,           --锁住
--    UnLock = 1,         --已解锁
--}

--ShowHeroListType =
--{
--    OwnTitle = 1,
--    Own = 2,
--    UnOwnTitle = 3,
--    UnOwn = 4,
--}

--HeroXmlState =
--{
--    HeroXMLState_Normal = 1, -- 正常显示
--    HeroXMLState_Prepare = 2, -- 准备中
--    HeroXMLState_Hide = 3, --不对玩家开放
--    HeroXMLState_NeverGet = 4, --玩家永远不会获得的英雄 英雄是存在的 英雄列表里没有
--    HeroXMLState_Max = 5,
--}

--HeroSkillState =
--{
--    Unlock = 0,             --已解锁
--    Lock = 1,               --未解锁
--    CanLock = 2,            --可解锁
--}

--HeroStarUseType =
--{
--    UseSelf = 1,                            --使用自己的英雄碎片
--    SameCampAndSameColor = 2,               --表示使用碎片对应英雄同阵营同品质碎片
--    OnlySameColor = 3,                      --表示使用碎片对应英雄同品质碎片
--}

--HeroStarUseCommon =
--{
--    No = 0,                             --不可以使用通用碎片
--    Yes = 1,                            --可以使用通用碎片
--}

--FrameType =
--{
--    HeroFrame = 0,                              --英雄碎片
--    Common = 1,                                 --通用碎片
--}

--英雄列表状态
--UIHeroListState =
--{
--    HeroList = 0,                               --英雄列表状态
--    Star = 1,                                   --升星状态
--}

--升星界面星星状态
--UIHeroListUpStarStarState =
--{
--    Yes = 0,                                  --已达成
--    No = 1,                                   --未达成
--}

--ActivityEventType =
--{
--    NULL =0, --0
--    PERSONAL=1, --1个人军备
--    ALLIANCE=2, --2联盟军备
--    KINGDOM_PERSONAL=3, --3 最强要塞个人
--    KINGDOM_ALLIANCE =4, --4 最强要塞联盟
--    MERGE_PERSONAL =5, --5 沙漠个人
--    MERGE_ALLIANCE =6, --6 沙漠联盟
--    BF_PERSONAL =7,--7 竞技场日常奖励
--    LS_WORLD_PERSONAL =8, --8 LS世界活动赛季积分 个人
--    LS_WORLD_ALLIANCE =9,--9 LS世界活动赛季积分 联盟
--    LS_WORLD_ALLIANCE_TO_ALLIANCE =10, --10 世界地块 联盟对联盟
--    PERSONAL_LIMITTIME =11,    --11 个人限时活动
--    KINGDOM_WARMUP_PERSONAL =12, --12 最强要塞热身赛赛个人
--    KINGDOM_WARMUP_ALLIANCE =13, --13 最强要塞热身赛联盟
--    ALLIANCE_ORDER = 16, --16 联盟农场
--    INDIVIDUAL_ORDER = 19, --19 个人农场
--}

--EnumActivity = {
--    AllianceCompete = {
--        Type = 14,
--        ActId = "55000",
--        EventType = 15,
--    },
--    LeadingQuest = {
--        Type = 18,
--    },
--    BarterShop = {
--        Type = 20,
--        ActId = "90017"
--    },
--    BarterShopNotice = {--属于活动中心
--        Type = 21,
--    },
--    RallyBossAct = {--属于日常活动
--        Type = 21,
--        ActId = "40005",
--    },
--    MineCave = {
--        Type = 25,
--        ActId = "20001",
--    },
--    Arena = {
--        Type = 26,
--        ActId = "30000"
--    },
--    Adventure =
--    {
--        Type = 28,
--        ActId = "40006",
--    },
--    ActivitySummary = {
--        Type = 30,
--    },
--    JigsawPuzzle = {
--        Type = 31,
--    },
--    PveAct =
--    {
--        Type = 32,
--    },
--    DigActivity =
--    {
--        Type = 35,
--    },
--    RobotWars = {
--        ActId = "40086",
--        Type = 38,
--    },
--    ThemeChristmas = {
--        Type = 39,
--    },
--    ChristmasCelebrate = {
--        Type = 40,
--    },
--    PaidLottery = {
--        Type = 42,
--    },
--    ChainPay = {
--        Type = 43,
--    },
--    SeasonPass = {
--        Type = 45,
--    },
--    AllianceSeasonForce = {
--        Type = 50,
--        ActId = "40014"
--    },
--    AlContribute = {
--        Type = 53,
--        EventType = 16,
--    },
--    Throne = {
--        Type = 54,
--        ActId = "111001",
--    },
--    ActDragon = {
--        Type = 71,
--        ActId = "40038",
--    },
--    DragonNotice = {
--        Type = 76,
--    },
--    ThroneScore = {
--        Type = 152,
--        ActId = "50102",
--    },
--    CrossWonder = {
--        Type = 153,
--        ActId = "50201",
--    },
--    HeroGrowth = {
--        Type = 998,
--    },
--    DispatchTask = {
--        Type = 201, -- 派遣任务
--    },
--    FightPreview = {
--        Type = 106,
--        ActId = "55100",
--    },
--    SpecialAction = {
--        type = 151,
--        ActId = "40131"
--    },
--    AllianceCumulativeRecharge = {
--        ActId = "59004"
--    },
--    LandingOperations = {
--        type = 101,
--        ActId = "40130"
--    },
--    SeasonMain = {
--        Type = 154,
--        ActId = "40008"
--    },
--    SeasonPanning = {
--        Type = 21, --赛季淘金活动
--        ActId = "40011",
--    },
--    GloryDeclare = {
--        Type = 155,
--        ActId = "40061",
--    },
--    ActWorldResource = {
--        Type = 156,--世界活动矿(本服采集)
--        ActId = "500001",
--    },
--    ActCrossWorldResource = {
--        Type = 157,--世界活动矿(跨服掠夺)
--        ActId = "500002",
--    },
--}

-- 活动中心-相关枚举
--ActivityEnum =
--{
--    ActivitySubType = {
--        ActivitySubType_1 = 1,--活动类型 type=18 任务活动. 当sub_type=1时表示任务进度不累计，不可领奖。 活动类型 type=20 兑换活动当 sub_type=1时表示不可兑换。
--        ActivitySubType_2 = 2,--活动类型 type=18 任务活动. 当sub_type=2时表示任务可跳转，显示前往
--        DrakeBoss = 3,--活动类型 type=18 任务活动. 当sub_type=3时表示德雷克活动
--    },
--    --活动类型
--    ActivityType ={
--        None = 0,
--        BlackKnight = 3,--黑骑士活动
--        ----开服-战力活动
--        --NewServer = 8,
--        --开服-平民活动
--        Farmer = 9,
--        --转盘活动
--        TurntableActivity = 10,
--        --英雄活动
--        HeroActivity = 11,
--        --个人军备活动
--        Arms = 12,
--        --联盟军备
--        AllianceArmRaceAct = 14,
--        --联盟农场
--        AllianceOrder = 16,
--        --怪物活动
--        MonsterActivity = 100,
--        --世界 Boss 活动
--        WorldBoss = 23,
--        --伊甸园
--        EdenWar = 13,
--		--雷达集结
--		RadarRally = 17,
--		--个人农场
--		IndividualOrder = 19,
--        
--        --
--        BarterShop = 20,
--        
--        Puzzle = 22,--拼图活动
--        --幸运转盘
--        LuckyRoll = 24,
--        --战令
--        BattlePass = 27,
--        -- 星珲探险活动
--        Adventure = 28,
--        --咕噜翻牌
--        GolloesCards = 29,
--        PveAct = 32,
--        MonsterTower = 33,--怪物爬塔
--        ActSevenDay = 34,--活动七日 ps:有两个七日 一个是属于活动的，一个是不属于的
--        GiftBox = 36,
--        SeasonActGuide = 37, --赛季活动指引
--        AllianceCityRecord2 = 38,--玩家打城记录
--        ActSevenLogin = 41,--七日登陆
--        LuckyShop = 44,--幸运商店
--        SeasonWeekCard = 46,--赛季周卡
--        SeasonRank = 48,--赛季打地块排行榜
--        DecorationGiftPackage = 49,--皮肤礼包活动
--        AllianceSeasonForce = 50,--赛季联盟积分排行榜
--        WorldTrend = 51,--天下大势，移到活动中了
--        Throne = 54,--王座
--        GloryPreview = 55,--S3星球大战预告
--        DonateSoldierActivity = 56,--捐兵活动
--        HeroEvolve = 57,--英雄特训
--        AllianceSeasonWeekRank = 58,--赛季积分榜周榜
--        PersonSeasonRank = 59,--个人势力排行榜
--        PresidentAuthority = 60,--总统特权
--        ALVSDonateSoldier = 61,
--        AllianceBoss = 62,--捐兵活动
--        DoubleSeasonScore = 63,--双倍赛季积分活动
--        ActNoOne = 68,--假活动    只需活动时间的活动
--        ActDragon = 71,--巨龙活动
--        GolloBox = 73,--咕噜专精
--        SeasonShop = 74,--赛季商店
--        AllianceCityRecord = 88,--玩家打城记录
--		ChangeNameAndPic = 89,--改名/换头像活动
--		MysteriousNew = 98,--数字寻宝
--        StrongCommander = 100,--最强指挥官
--		LandingOperations = 101, --登陆作战
--        GeneralPreview = 104, --通用活动预告
--        DawnTask = 112,--黎明
--		Train = 150, --押镖
--        SpecialAction = 151, --特别行动
--        ThroneScore = 152,--王座积分
--        GloryDeclare = 155,--联盟宣战
--        DigPuzzle = 202, --(挖掘版)拼图活动
--        --七日 ps:七日不算活动，在这为手动添加活动ID
--        SevenDay = 999,
--        FightPreview = 106, --杀戮活动
--        WeeklyMsgCard = 108, --周卡
--        MonthMsgCard = 109, --月卡
--        ThroneScore = 152,--王座积分
--        CrossWonder = 153, -- 跨服王座
--        SeasonMain = 154,--赛季主界面
--        ActWorldResource = 156,
--        ActCrossWorldResource = 157,
--        PersonalArmsRankReward = 158, -- 全面战备排行榜奖励
--        CumulativeRecharge = 1000, --礼包累充
--        DailyCumulativeRecharge = 1001, --每日礼包累充
--        RedPacket = 1002,--红包
--        DrakeBoss2 = 1004,--洛哈试炼（或薇薇安试炼）
--        DayRechargeMonthCard = 1005, --每日充值月卡
--        CompensateMonthCard = 1006, --补偿月卡
--        AllianceCumulativeRecharge = 1100, --联盟礼包累充
--        MonopolyActivity = 1110,
--        ICDCandyRoom = 1111,
--        DroppedTreasureActivity = 1112,
--        FlipFun = 116,  -- 对对碰
--        Exchange = 117, -- 交换活动
--        VerticalInvite = 1010, --个人邀请领奖
--        AllianceVerticalInvite = 1012, --联盟邀请领奖
--    };
--}

--ActivityDailyType = {
--    Default = 0, --默认(活动中心)
--    Season = 4, -- 赛季
--}

--个人军备活动类型
--PersonalEventType =
--{
--    Daily = 1,  --日常军备
--    Kill = 2,   --杀敌活动
--    Permanent = 3,--常驻军备(持续一天)
--}

--冠军对决活动不同阶段状态
--Activity_ChampionBattle_Stage_State =
--{
--    None = 0,
--    SingUp = 1, --报名阶段
--    Auditions = 2, --海选阶段
--    Strongest_64 = 3,--巅峰对决64强赛
--    Strongest = 4,--巅峰对决8强赛
--    Settlement = 5, -- 结算
--};

--冠军对决-海洗赛阶段各宝箱状态
--AuditionsBoxState =
--{
--    Fail = -1,      --海选单局失败
--    NotStart = 0,   --海选此局未开始
--    CanReceive = 1, --海选胜利未领奖
--    HasReceived = 2, --海选已领奖
--};

--冠军对决海报类型(冠军对决争霸赛阶段状态，1，2，3服务器同步状态，4为客户根据结果补充状态)
--ChampionBattlePosterType =
--{
--    None = 0,
--    Strongest_Eight = 1, --8强
--    Strongest_Four = 2,  --4强
--    Strongest_Two = 3,   --2强
--    Strongest_King = 4,  --冠军
--};

--SeasonStage = {
--    None = 0,
--    Preview = 1,
--    Open = 2,
--    toSettle = 3,
--    ToFinish = 4,
--    Finished = 5,
--}

--GetRewardTitleType = {
--    Common = 1,
--    BattleFail = 2,
--}

--DragonSignState = {
--    HasSign = 1,--已报名
--    NotR4R5 = 2,--不是R4或者R5
--    NO_ALLIANCE = 3,--无联盟
--    RankLimit = 4, --当前联盟战力排名不在前{0}名内，无法参与报名
--    ServerCreateTimeLimit = 5, --当前联盟创建时间不足{0}天，无法参与报名
--    ToSign = 6,--可报名
--    Expire = 7,--过期
--    MemberNotEnough = 8,--成员不足
--    Vote = 9,--投票
--}

---巨龙活动阶段
---@class DragonActStage
--DragonActStage = {
--    None = 0,
--    Vote = 1,--投票
--    Sign = 2,--报名
--    Matching = 3, --匹配
--    Battle = 4, --战斗
--}

--EnumActivityStatus = {
--    Preview = 1,
--    Open = 2,
--    Close = 3,
--}

--HeroGrowthTaskStatus = {
--    LackHero = 1,--没有英雄
--    LackSkill = 2,--技能未解锁
--    SkillLvUnfit = 3,--技能等级不足
--    Complete = 4,--完成未领奖
--    Rewarded = 5,--已领奖
--}

--EnumActivityNoticeInfo = {
--    EnumActivityNoticeInfo_Hero = "hero",
--}

--SeasonPassRewardType = {
--    NormalReward = 0,--普通奖励
--    SpecialReward = 1,--付费奖励
--}

--HeroTalentColor =
--{
--    Red = 1,
--    Orange = 2,
--    Blue = 3,
--}

--HeroTalentCellIconType =
--{
--    Big = 1,
--    Small = 2,
--}


--HeroTalentCellState =
--{
--    NoPre = 0,--等级0 不满足前置要求
--    Pre = 1, --等级0 满足前置要求
--    Yes = 2,--等级大于1
--}

--HeroTalentLineCellState =
--{
--    Gray = 0,--暗
--    Light = 1, --亮
--}

--HeroTalentUseType =
--{
--    Reset = 1,
--    Change = 2,
--}

--TeamDialogType = {
--    Win = 1, 
--    GotoBattle = 2,
--    Idle = 3,
--    Lose = 4
--}

--加载路径
LoadPath =
{
    SoundEffect = "Assets/Main/Sound/Effect/%s.ogg",
    UIChapterTask = "Assets/Main/Sprites/UI/UIChapterTask/%s",
    HeroIconsSmallPath = "Assets/Main/Sprites/HeroIconsSmall/",
    HeroIconsSmallPath2 = "Assets/Main/Sprites/UI/UITroopsNew/",
    HeroIconsSmallPath3 = "Assets/Main/Sprites/HeroIconsSmall/%s.png",
    HeroIconsBigPath = "Assets/Main/Sprites/HeroIconsBig/",
    HeroDevHeroPath = "Assets/Main/Sprites/DevHeroIconsBig/",
    HeroBodyIconPath = "Assets/Main/Sprites/HeroBodyTroops/%s.png",
    HeroListPath = "Assets/Main/Sprites/UI/UIHeroList/%s.png",
    HeroAppear = "Assets/Main/Sprites/UI/UINewHeroAppear/%s.png",
    HeroDetailPath = "Assets/Main/Sprites/UI/UIHeroDetail/%s.png",
    HeroAdvancePath = "Assets/Main/Sprites/UI/UIHeroAdvance/%s.png",
    HeroRecruitPath = "Assets/Main/Sprites/UI/UIHeroRecruit/%s.png",
    HeroBodyPath = "Assets/Main/UITexture/HeroBody/%s.png",
    HeroSprinePath = "Assets/Main/Prefabs/Heros/%s.prefab",
    HeroBodyTroopsPath = "Assets/Main/Sprites/HeroBodyTroops/%s.png",
    HeroTrialPath = "Assets/Main/UITexture/HeroBodyAct/%s_UItrial.png",
    SkillIconsPath = "Assets/Main/Sprites/SkillIcons/",
    SkillBigIconsPath = "Assets/Main/Sprites/UI/UIPveHeroAppear/",
    UIFirstCharge = "Assets/Main/Sprites/UI/UIFirstCharge/%s.png",
    --GarbageIconsPath = "Assets/Main/Sprites/UI/UIGarbage/",

    UIGetRewardTips= "Assets/Main/UITexture/UIGetRewardTips/%s.png",
    GolloesCampPath = "Assets/Main/Sprites/UI/UIGolloesCamp/%s.png",
    ActivityIconPath = "Assets/Main/Sprites/ActivityIcons/%s.png",
    HeroIconPath = "Assets/Main/Sprites/HeroIcons/%s.png",
    TalentPath = "Assets/Main/Sprites/HeroTalent/%s.png",
    UIHeroInfoPath = "Assets/Main/Sprites/UI/UIHeroInfo/%s.png",
    CommonApsNewPath = "Assets/Main/Sprites/UI/UIRank/%s.png",
    ItemPath = "Assets/Main/Sprites/ItemIcons/%s.png",
    UIChatChat = "Assets/Main/Sprites/UI/UIChat/Chat/%s.png",
    BuildIconInCity = "Assets/Main/Sprites/BuildIconInCity/%s.png",
    BuildIconOutCity = "Assets/Main/UITexture/BuildIconOutCity/%s.png",
    SeasonDesert = "Assets/Main/Sprites/SeasonDesert/%s",
    DailyActivityUnlock = "Assets/Main/Sprites/DailyActivityUnlock/%s.png",
    ResLackIcons = "Assets/Main/Sprites/ResLackIcons/%s.png",
    ResourceIcons = "Assets/Main/Sprites/Resource/%s.png",
    UIBuildBtns = "Assets/Main/Sprites/UI/UIBuildBtns/%s.png",
    UIBuildBubble = "Assets/Main/Sprites/UI/UIBuildBubble/%s.png",
    UILandLock = "Assets/Main/Sprites/UI/UILandLock/%s.png",
    UINPCPath = "Assets/Main/Sprites/UI/UINPC/%s.png",
    CommonPath = "Assets/Main/Sprites/UI/Common/%s.png",
    UIBuild = "Assets/Main/Sprites/UI/UIBuild/%s.png",
    ScienceIcons = "Assets/Main/Sprites/ScienceIcons/%s.png",
    SoldierIcons = "Assets/Main/Sprites/SoldierIcons/%s.png",
    SoldierIcons2 = "Assets/Main/Sprites/SoldierIcons/%s",
    SoldierIconsNew = "Assets/Main/Sprites/UI/UISoildierNew/%s.png",
    SoldierTexture = "Assets/Main/UITexture/UISoildierNew/%s.png",
    UIScience = "Assets/Main/Sprites/UI/UIScience/%s.png",
    UIScience_Slg = "Assets/Main/Sprites/Slg/UI/UIScience/%s.png",
    UIResidentOrder = "Assets/Main/Sprites/UI/UIResidentOrder/%s.png",
    UISciencePrefab = "Assets/Main/Prefabs/UI/UIScience/%s.png",
    Soldier = "Assets/Main/Sprites/Soldier/%s.png",
    UISoldier = "Assets/Main/Sprites/UI/UISoildier/%s.png",
    AvatorFolder = "Assets/Main/Sprites/UI/UIChatNew/%s.png",
    ChatFolder = "Assets/Main/Sprites/UI/UIChatNew2/%s.png",
    UIRedenvelopePath = "Assets/Main/Sprites/UI/UIRedenvelope/%s.png",
    CommonNewPath = "Assets/Main/Sprites/UI/Common/New/%s.png",
    PortraitCommonPath = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/%s.png",
    SLGCommonNewPath = "Assets/Main/Sprites/Slg/UI/Common/New/%s.png",
    UIFormationDefencePath = "Assets/Main/Sprites/UI/UIFormationDefence/%s.png",
    UIChatNew1 = "Assets/Main/Sprites/UI/UIChatNew1/%s.png",
    UIMainNew = "Assets/Main/Sprites/UI/UIMain/UIMainNew/%s.png",
    UIMainNew2 = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/%s.png",
    UIMainNew2_0 = "Assets/Main/Sprites/UI/UIMain2.0/%s.png",
    UIMainPortrait = "Assets/Main/Sprites/UI/UIMain2.0/UIMainPortrait/%s.png",
    UILandLockTips = "Assets/Main/Sprites/UI/UI_LandLockTips/%s.png",
    UIPopupPackage = "Assets/Main/Sprites/UI/UIMain/UIPopupPackage/%s.png",
    RadarCenterPath = "Assets/Main/Sprites/UI/UIRadarCenter2/%s.png",
	RadarBannerPath = "Assets/Main/Sprites/UI/UIRadarCenterBanner/%s.png",

    CommonBGPath = "Assets/Main/Sprites/UI/CommonBG/%s.png",
    UITroops = "Assets/Main/Sprites/UI/UITroops/%s.png",
    UITroopsNew = "Assets/Main/Sprites/UI/UITroopsNew/%s.png",
    Guide = "Assets/Main/Sprites/Guide/%s.png",
    UITask = "Assets/Main/Sprites/UI/UITask/%s.png",
    UIPlayerIcon ="Assets/Main/Sprites/UI/UIHeadIcon/%s.png",
    UserHeadPath = "Assets/Main/Sprites/UI/UIHeadIcon/%s.png",
    UIActivity = "Assets/Main/Sprites/UI/UIActivity/%s.png",
    UIPersonalArms = "Assets/Main/Sprites/UI/UIPersonalArms/%s.png",
    UIAllianceArmament = "Assets/Main/Sprites/UI/UIAllianceArmament/%s.png",
    UISevenDay = "Assets/Main/Sprites/UI/UISevenDay/%s.png",
    UISevenLogin = "Assets/Main/Sprites/UI/UISevenLogin/%s.png",
    UIAlliance = "Assets/Main/Sprites/UI/UIAlliance/%s.png",
    UIAlliance_Slg = "Assets/Main/Sprites/Slg/UI/UIAlliance/%s.png",
    UIAllianceRank = "Assets/Main/Sprites/UI/UIAlliance/rank/%s.png",
    UIAllianceGift = "Assets/Main/Sprites/UI/UIAllianceGift/%s.png",
    NPCModel = "Assets/Main/Guide/Prefabs/NPCModel/%s.prefab",
    UIMail = "Assets/Main/Sprites/Slg/UI/UIMail/%s.png",
    --UIMailNormal = "Assets/Main/Sprites/Slg/UI/UIMail/UIMail_Normal/%s.png",
    UIMailNormal = "Assets/Main/UITexture/UIMail/%s.png",
    AllianceMark = "Assets/Main/Sprites/UI/UIAllianceMark/%s.png",
    GuideTipSpine = "Assets/Main/Prefabs/Guide/%s.prefab",
    UIPlayerLevel = "Assets/Main/Sprites/UI/UIPlayerLevel/%s.png",
    UIPlayerCareer = "Assets/Main/Sprites/UI/UICareer/%s.png",
    DecorationTreePath = "Assets/Main/Prefabs/World/WorldCityTree%s.prefab",
    UILevelUpItem = "Assets/Main/Prefabs/UI/UILevelUp/UILevelUpItem.prefab",
    UIVipPath = "Assets/Main/Sprites/UI/UIVip/%s.png",
    UIHeroMonthCard = "Assets/Main/Sprites/UI/UIHeroMonthCard/%s.png",
    UIHeroMonthCard_Slg = "Assets/Main/Sprites/Slg/UI/UIHeroMonthCard/%s.png",
    GoldPay = "Assets/Main/Sprites/UI/UIGoldPay/%s.png",

    SULevelPic = "Assets/Main/UITexture/SULevelPic/%s.png",

--    SULevelList = "Assets/Main/Sprites/UI/UILevelList/%s",

    WarDetail = "Assets/Main/Sprites/UI/UIAlliance/WarDetail/%s.png",
    WarDetail_Slg = "Assets/Main/Sprites/Slg/UI/UIAllianceWarDetail/%s.png",
    UIRobotPack = "Assets/Main/UITexture/UIRobotEx/UIRobot_Beauty_%s.png",
    UIHeroStation = "Assets/Main/Sprites/UI/UIHeroStation/%s.png",
    UIChampionBattle = "Assets/Main/Sprites/UI/UIChampion/%s.png",
    UIMainQuest = "Assets/Main/Sprites/UI/UITask/%s.png",
    UILuckyRoll = "Assets/Main/Sprites/UI/UILuckyRoll/%s.png",
    UIGolloesCards = "Assets/Main/Sprites/UI/UIGolloesCards/%s.png",
    UIChronicle = "Assets/Main/Sprites/UI/UIChronicle/%s.png",
    UIWorldTrend = "Assets/Main/Sprites/UI/UIWorldTrend/%s.png",
    UIMonsterTower = "Assets/Main/Sprites/UI/UIMonsterTower/%s.png",
    UIMonsterTowerNew = "Assets/Main/Sprites/UI/UIMonsterTower/New/%s.png",
    LodIcon = "Assets/Main/Sprites/LodIcon/%s.png",
    
    UIPveLoading = "Assets/Main/Sprites/UI/UIPveLoading/%s.png",
    UImystery = "Assets/Main/Sprites/UI/UImystery/%s.png",
    UIHeroIntensify = "Assets/Main/Sprites/UI/UIHeroHall/%s.png",

    -- 砍伐相关
    CityScene = "Assets/Main/Prefabs/CityScene/%s.prefab",
    Building = "Assets/Main/Prefabs/Building/%s.prefab",
    DyHero = "Assets/Main/Prefabs/PVE/DyHeroes/%s.prefab",
    UICommonPackageBig = "Assets/Main/Sprites/UI/UICommonPackageBig/CommonPackageBig_img_%s.png",
    UIKonbiniRes = "Assets/Main/Sprites/UI/UIKonbini/UIKonbini_icon_res_%s.png",
    UIKonbiniResItem = "Assets/Main/Sprites/UI/UIKonbini/UIKonbini_icon_res_item_%s.png",
    UIGarageRefit = "Assets/Main/Sprites/UI/UIGarageRefit/UIRetrofit_%s.png",
    UIChapter = "Assets/Main/Sprites/UI/UIChapter/%s.png",
    PVEScene = "Assets/Main/Sprites/pve/%s.png",
    UIPveBattleBuff = "Assets/Main/Sprites/UI/UIPveBattleBuff/%s.png",
    UITreasurePuzzle = "Assets/Main/Sprites/UI/UITreasurePuzzle/%s.png",
    PVELevel = "Assets/Main/Prefabs/PVELevel/%s.prefab",
    PVELevel_Active = "Assets/Main/Prefabs/PVELevel/%s_active.prefab",
    PVELevel_Reward = "Assets/Main/Prefabs/PVELevel/%s_reward.prefab",
    PVETriggerIcons = "Assets/Main/Sprites/PVETriggerIcons/%s.png",
    UIPveAct = "Assets/Main/Sprites/UI/UIPveAct/%s.png",
    CollectResource = "Assets/Main/Prefabs/CollectResource/%s.prefab",
    UIBuildUpgrade = "Assets/Main/Sprites/UI/UIBuildUpgrade/%s.png",
    UIDecoration = "Assets/Main/Sprites/UI/UIDecoration2/%s.png",
    UIDecorationBG = "Assets/Main/UITexture/UIActivityPortrait/%s.png",
    UILuckyShop = "Assets/Main/Sprites/UI/UIGroceryStore/%s.png",
    UISeasonIntro = "Assets/Main/Sprites/UI/UISeasonIntro/%s.png",
    UISeasonHint = "Assets/Main/Sprites/UI/UISeasonHint/%s.png",
    UISeasonWeek = "Assets/Main/Sprites/UI/UISeasonWeek/%s.png",
    UITextureExActivity = "Assets/Main/UITexture/UIActivity/%s.png",
    UIEquipmentIcons = "Assets/Main/Sprites/EquipmentIcons/%s.png",
    UIGlory = "Assets/Main/Sprites/UI/UIGloryLeague/%s.png",
    UISeasonWeekBuff = "Assets/Main/Sprites/UI/UISeasonGround/%s.png",
    UIMastery = "Assets/Main/Sprites/UI/UIMastery/",
    UIGovernment = "Assets/Main/Sprites/UI/UIGovernment/%s.png",
    UIGovernmentBig = "Assets/Main/UITexture/UIGovernment/%s.png",
    UIHeroEvolve = "Assets/Main/UITexture/UIHeroEvolve/%s.png",
    UIWorldTrendBg = "Assets/Main/UITexture/UIWorldTrend/%s.png",
    UIActivityBg =  "Assets/Main/UITexture/UIActivityBG/%s.png",
    UIActivityBgPortrait =  "Assets/Main/UITexture/UIActivityBGPortrait/%s.png",
    UIActivityBgPortrait2 =  "Assets/Main/UITexture/UIActivityBGPortrait2/%s.png",
    UIActivityBg2 =  "Assets/Main/UITexture/UIActivityBG2/%s.png",
    UINewSeason = "Assets/Main/Sprites/UI/UINewSeason/%s.png",
    UINewSeasonBlock = "Assets/Main/Sprites/UI/UINewSeason/Block/%s.png",
    UINewSeasonBig = "Assets/Main/UITexture/UINewSeason/%s.png",
    
    UITitleIcon = "Assets/Main/Sprites/UI/UITitleTag/%s.png",
    UIMasteryEx = "Assets/Main/UITexture/UIMastery/UIMastery_%s.png",

--    UITalent = "Assets/Main/Sprites/UI/UITalent/%s.png",
    UIJoyStick = "Assets/Main/Sprites/UI/UIJoystick/%s.png",
    PlayerPrefabPath = "Assets/_Art_LastDay/Models/Soldier/LastDayActor/prefab/%s.prefab",
    WeaponPrefabPath = "Assets/_Art_LastDay/Models/Soldier/%s.prefab",
    NvlieshouPrefabPath = "Assets/_Art_LastDay/Models/Soldier/Nvlieshou_low/prefab/%s.prefab",
    UIHero2D = "Assets/Main/UITexture/UIHeroList2.0/%s.png",
    UIGuidePic = "Assets/Main/UITexture/UI_PicGuide/%s.png",
    ZombiePartPrefabPath = "Assets/_Art_LastDay/Models/Monster/Zombie01/prefab/%s.prefab",
	
	UISearch = "Assets/Main/Sprites/UI/UISearch/%s.png",

    UIGiftPackageNew = "Assets/Main/Sprites/UI/UIGiftPackageNew/%s.png",
    UIGiftPackageEx = "Assets/Main/UITexture/UIGiftPackage/%s",
    UIGiftPackageIcon = "Assets/Main/Sprites/Slg/GiftPackageIcon/%s",
    RobotTablePath = "Assets/Main/Sprites/UI/UIGiftPackageNew/UIRobot_Tab_%s.png",
    RobotMainPath = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIMain_icon_%s.png",
    GirlIconsSmall = "Assets/Main/Sprites/GirlIconsSmall/%s.png",
--    UIRecycle = "Assets/Main/Sprites/UI/UIRecycle/UIRecycle_%s",
    UIFirstPay = "Assets/Main/Sprites/UI/UIFirstPay/%s.png",
    UIFirstPayEx = "Assets/Main/UITexture/UIFirstPay/%s.png",
    UIWeekPackage = "Assets/Main/Sprites/UI/UIWeekCard/UIWeekPackage_%s.png",
	UIStory = "Assets/Main/Sprites/UI/UIStory/%s.png",
    SU_Sidebar = "Assets/Main/Sprites/UI/SU_Sidebar/%s.png",
    UIFirstChargeEx = "Assets/Main/TextureEx/UIFirstCharge/UIfirstcharge_bg_%s.png",
    UIHeroEquipIcons = "Assets/Main/Sprites/HeroEquipIcons/%s.png",
    UIHeroEquipPath = "Assets/Main/Sprites/UI/UIHeroEquip/%s.png",

	UILandingOperations = "Assets/Main/Sprites/UI/UILandingOperations/%s.png",
	UIInterstellarMigration = "Assets/Main/Sprites/UI/UIInterstellarMigration/%s",
	
    GreenWarnIcon = "Assets/Main/Sprites/UI/UITroopsNew/UITroops_btn_combat01.png",
    YellowWarnIcon = "Assets/Main/Sprites/UI/UITroopsNew/UITroops_btn_combat02.png",
    RedWarnIcon = "Assets/Main/Sprites/UI/UITroopsNew/UITroops_btn_combat03.png",
    
    UIJeepAdventure = "Assets/Main/Sprites/UI/UIJeepAdventure/%s.png",
    ShopIcon = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitShop/%s.png",

    SmileyNpcHeadIcon = "Assets/Main/Sprites/UI/UISmileyFaceNpcDialog/%s.png",

    FreeTypeHeroBg = "Assets/Main/Sprites/UI/Common/UImain_btn_bubble_completely.png",
    TurntableEx = "Assets/Main/Sprites/UI/UILuckyRoll/%s.png",
    TMPMaterialPath = "Assets/Main/Fonts/material/%s.mat",
    NewsletterPath = "Assets/Main/UILovemessage%s.png",
    NewsletterPath2 = "Assets/Main/UILovemessage%s.png",
    UIWorldBattle = "Assets/Main/Sprites/UI/UIWorldBattle/%s",
    
    --小人路径
    SmallPeopleIcon = "Assets/Main/Sprites/UI/UISmallPeople/%s.png",
    SmallPeopleTexture = "Assets/Main/UITexture/UISmallPeopleTexture/%s.png",
    --小人路径End
    HeroSkinIcon = "Assets/Main/Sprites/HeroSkinIcons/%s.png",
	
	SPINE_UI_Task = 'Assets/_Art_LastDay/Spine/UIMainChapterTask/%s.prefab',
    SPINE_UI_Laola7day = 'Assets/_Art_LastDay/Spine/UILaola7day_Chapter/%s.prefab',

    UIcapitalwar_imgBg_Self = "Assets/Main/Sprites/UI/UICrossWonderAct/UIcapitalwar_img_004_blue.png",
    UIcapitalwar_imgBg_Other = "Assets/Main/Sprites/UI/UICrossWonderAct/UIcapitalwar_img_004_red.png",
    
    CrossWonder_Attack_Img = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitActivity/c_activity_cross_wrold_atk_icon.png",
    CrossWonder_Defend_Img = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitActivity/c_activity_cross_wrold_def_icon.png",
    GiftBoxPath = "Assets/Main/Sprites/UI/UImystery/%s.png",
    
    UIDragon = "Assets/Main/Sprites/UI/UIDragon/%s.png",
    
    LandingOperationNewPath = "Assets/Main/Sprites/UI/UIHeroBattlefield/%s.png",

    BaubleIconPath = "Assets/Main/Sprites/BaubleIcon/%s",
    UIBaublePath = "Assets/Main/Sprites/UI/UIBauble/%s",
    BaubleModelPath = "Assets/_Art_LastDay/Models/Environment/Decorate/%s.prefab",
    UIRedenvelopeExPath = "Assets/Main/UITexture/UIRedenvelope/%s",

    UISeasonGroundPath = "Assets/Main/Sprites/UI/UISeasonGround/%s.png",
    SLGUISeasonGroundPath = "Assets/Main/Sprites/Slg/UI/UISeasonGround/%s.png",

    UIChampionBattleNew = "Assets/Main/Sprites/Slg/UI/UIChampionBattle/%s",
    
    UIChampionBattleIcon = 'Assets/Main/Sprites/UI/UIPortrait/UIPortraitActivity/%s',

    CrossWonderBadgeQualityBg = "Assets/Main/UITexture/UIActivityCrossServer/c_texture_activity_cross_world_card_0%s.png",
}

--资源图片名字 (已废弃，无调用)
--ResourceTypeIconName = {}

--	聊天频道的类型
--ChatChannelType = {
--    CHAT_CHANNEL_COUNTRY  = 0, -- 国家
--    CHAT_CHANNEL_ALLIANCE = 1, -- 联盟
--    CHAT_CHANNEL_USER 	  = 2, -- 个人（邮件）
--    CHAT_CHANNEL_ROOM     = 3, -- 新建聊天室
--}
--	红包类型
--ChatMessageType = {
--    COMMON		    = 0,   	-- 普通
--    SYSTEM 	   		= 1, 	-- 系统消息
--    FESTIVAL	    = 2, 	-- 系统节日
--}

--分享到聊天的频道类型
--ChatShareChannel = {
--    TO_COUNTRY  = 0,  -- 国家
--    TO_ALLIANCE = 1,  -- 联盟
--    TO_PERSON   = 2,  -- 私聊
--}

----发送聊天的类型
--PostType = {
--    Text_Normal 			= 0,   		-- 普通聊天消息
--    Text_AllianceCreated 	= 1, 	-- 联盟创建消息 
--    Text_AllianceAdded		   = 2, 	-- 加入联盟系统邮件
--    Text_AllianceInvite    	= 3,  -- 联盟邀请的系统邮件
--    Text_FightReport 		= 4,  --战报分享 
--    Text_InvestigateReport  = 5,  --侦查战报分享
--    Text_Loudspeaker 		= 6,  -- 喇叭消息
--    Text_EquipShare 		= 7,  -- 装备分享
--    Text_SayHello 			= 8,  -- 打招呼
--    Text_AllianceRally   = 9,  -- 联盟集结
--    Text_TurntableShare     = 10, -- 轮盘分享
--    Text_AllianceTask 		= 11, --联盟任务
--    RedPackge      			= 12, -- 红包
--    Text_PointShare			= 13, -- 坐标分享
--    Text_AllianceTaskHelper = 14, -- 联盟宝藏求助
--    Text_Media 				= 15, -- 语音消息 这个C++层也没定义 不知道有没有用了
--    Text_Alliance_MonthCardBox = 18, -- 月卡随机宝箱分享
--    Text_SevenDayShare  	= 19, -- 七日分享
--    Text_MissileShare       = 20, --导弹分享
--    Text_AllianceGroupBuyShare = 21, -- 联盟团购分享
--    Text_Create_EquipShare  = 22, --打造装备分享
--    Text_Create_New_EquipShare = 23,--新打造装备分享
--    Text_Use_Item_Share  		= 24, --使用道具分享
--    Text_Gift_Mail_Share 		= 25, -- 赠送礼品邮件分享
--    Text_Favour_Point_Share     = 26, -- 收藏坐标点
--    Text_GoTo_Wounded_Share 	= 27, -- 治疗伤病分享
--    Text_GoTo_Medal_Share		= 28, -- 装备勋章分享
--    Text_Shamo_Inhesion_Share   = 29, -- 沙漠天赋分享
--    Text_Formation_Fight_Share  = 30, -- 新的地块战斗战报分享
--    Text_FBScoutReport_Share    = 31, -- 新的侦查邮件分享
--    Text_FBActivityhero_Share   = 32, -- 自由城建积分兑换英雄的分享
--    Text_FBFormation_Share		= 33, -- 自由城建编队分享
--
--
--    Text_ScienceMaxShare 		= 34, -- 科技MAX分享
--    Text_AllianceCommonShare 	= 35, -- 新联盟转盘分享
--    Text_SevenDayNewShare 		= 36, -- 新末日投资分享
--    Text_AllianceAttackMonsterShare = 37, --  联盟集结BOSS
--    Text_AllianceArmsRaceShare  = 38, -- 联盟军备竞赛活动分享
--    Text_EnemyPutDownPointShare = 39, -- 敌方在本方放下集结点分享
--    Text_FBAllianceGift_Share   = 40, -- 自由城建联盟礼物分享
--    Text_FBAlliance_missile_share = 41,--分享联盟导弹攻击信息
--
--    Text_Dommsday_Missile_Share = 42,  --末日导弹
--    Text_Audio_Message 			= 43,  -- 语音消息
--    Text_Visit_Base_Message 	= 44,  --参观基地建设
--    Text_Send_Flower 			= 45,  --送花界面
--
--    Text_ChatRoomSystemMsg 		= 100, -- 聊天室系统消息
--    Text_ChatWarnningSysMsg 	= 110, --世界频道i政治敏感信息警告系统消息
--    Text_AD_Msg 				= 150, --个人信息邮件广告友情提示
--    Text_AreaMsg  				= 180, --竞技场伪造的消息
--    Text_ModMsg 				= 200, --mod邮件
--    Text_Alliance_ALL_Msg       = 250,
--
--    NotCanParse 				= 300,
--
--
--}

--聊天限制玩家类型
--RestrictType = {
--    BLOCK 	= 1,  -- 屏蔽
--    BAN 	= 2,  -- 禁言
--}

--发送状态的类型
--SendStateType = {
--    OK 		= 0,
--    PENDING = 1,
--    FAILED  = 2,
--
--}

--ScreenType =
--{
--    Portrait = 0,--竖屏
--    Landscape = 1,--横屏
--}

--语音保存结果
--RecordResultState =
--{
--    RECORD_SAVE_ERROR = -4,
--    RECORD_USER_CANCELED = -3,
--    RECORD_TOO_SHORT = -2,
--    MICROPHONE_UNAVAILABLE = -1,
--    OK = 0,
--}

--编队状态
--ArmyFormationState =
--{
--    Free = 0,--空闲中
--    March = 1,--出征中
--}

--编队出征状态
--MarchArmsType =
--{
--    Free = 0,--普通出征
--    Cross = 1,--跨服出征
--    CROSS_DRAGON = 2,--跨服战场(峡谷争夺战 or 巨龙战场)
--}

--建筑占格子大小
--BuildTilesSize =
--{
--    One = 1,
--    Two = 2,
--    Three = 3,
--    Four = 4,
--    Five = 5,
--    Seven = 7,
--}

--BuildNeedMonth =
--{
--    No = 0,--不需要
--    Yes = 1,--需要
--}

--建筑放置条件
--BuildInside =
--{
--    In = 0,--苍穹内建筑
--    Out = 1,--苍穹外建筑
--    All = 2,--所有都可以放置
--}

--ResidentOrderState =
--{
--    No = 0,--不可交付
--    Yes = 1,--可交付
--    CanBuy = 2,--可以通过购买道具交付
--}

--建造列表界面类型枚举
--UIBuildListTabType =
--{
--    Road = 0,--修路/产路
--    InBuild = 1,--苍穹内建筑
--    OutBuild = 2,--苍穹外
--    Military = 3,--军事
--    SeasonBuild = 4,--赛季建筑
--    WallOrFloor = 5,
--    Robot = 10,--机器人
--    SeasonRobot = 11,--赛季机器人
--}
--建造列表界面类型枚举排序
--UIBuildListTabTypeSort =
--{
--    UIBuildListTabType.Robot,
--    UIBuildListTabType.InBuild,
--    UIBuildListTabType.OutBuild,
--    UIBuildListTabType.Military,
--    UIBuildListTabType.Road,
--}

--UIBuildListBuildType =
--{
--    BuildRoad = 1,--修路
--    RemoveRoad = 2,--铲路
--    Build = 3,--建筑
--    Robot = 4,--无人机
--}

--主界面动画类型
UIMainAnimType =
{
    AllHide = "OutWithResource",--:主界面上下左右全部隐藏
    LeftRightBottomHide = "OutWithoutResource",--:主界面上部保留（资源条和头像），下左右全部隐藏
    AllShow = "EnterWithResource",--:主界面上下左右全部隐藏
    LeftRightBottomShow = "EnterWithoutResource",--:主界面上部保留（资源条和头像），下左右全部隐藏
    ChangeAllShow = "ChangeAllShow",--:无论什么状态，变成全部显示状态
}

--ResourceTabSelectImage = {}
--ResourceTabSelectImage[ResourceType.Oil] = "Assets/Main/Sprites/Resource/Oil_select"
--ResourceTabSelectImage[ResourceType.Metal] = "Assets/Main/Sprites/UI/UIDecoration2/btn_tab_shiwu2"
--ResourceTabSelectImage[ResourceType.Water] = "Assets/Main/Sprites/Resource/Water_select"
--ResourceTabSelectImage[ResourceType.Electricity] = "Assets/Main/Sprites/Resource/Electricity_select"
--ResourceTabSelectImage[ResourceType.Money] = "Assets/Main/Sprites/Resource/Money_select"
--ResourceTabSelectImage[ResourceType.Wood] = "Assets/Main/Sprites/Resource/Wood_select"
--ResourceTabSelectImage[ResourceType.LM_food] = "Assets/Main/Sprites/UI/UIDecoration2/btn_tab_shiwu2"
--ResourceTabSelectImage[ResourceType.LM_metal] = "Assets/Main/Sprites/UI/UIBagView3.0/btn_tab_metal2"

--ResourceTabUnSelectImage = {}
--ResourceTabUnSelectImage[ResourceType.Oil] = "Assets/Main/Sprites/Resource/Oil_unSelect"
--ResourceTabUnSelectImage[ResourceType.Metal] = "Assets/Main/Sprites/UI/UIDecoration2/btn_tab_shiwu"
--ResourceTabUnSelectImage[ResourceType.Water] = "Assets/Main/Sprites/Resource/Water_unSelect"
--ResourceTabUnSelectImage[ResourceType.Electricity] = "Assets/Main/Sprites/Resource/Electricity_unSelect"
--ResourceTabUnSelectImage[ResourceType.Money] = "Assets/Main/Sprites/Resource/Money_unSelect"
--ResourceTabUnSelectImage[ResourceType.Wood] = "Assets/Main/Sprites/Resource/Wood_unSelect"
--ResourceTabUnSelectImage[ResourceType.LM_food] = "Assets/Main/Sprites/UI/UIDecoration2/btn_tab_shiwu"
--ResourceTabUnSelectImage[ResourceType.LM_metal] = "Assets/Main/Sprites/UI/UIBagView3.0/btn_tab_metal"

--ResourceTabSelectImage1 = {}
--ResourceTabSelectImage1[ResourceType.Metal] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_03"
--ResourceTabSelectImage1[ResourceType.Electricity] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_04"
--ResourceTabSelectImage1[ResourceType.Money] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_01"
--ResourceTabSelectImage1[ResourceType.Wood] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_02"

--ResourceTabUnSelectImage1 = {}
--ResourceTabUnSelectImage1[ResourceType.Metal] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_03"
--ResourceTabUnSelectImage1[ResourceType.Electricity] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_04"
--ResourceTabUnSelectImage1[ResourceType.Money] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_01"
--ResourceTabUnSelectImage1[ResourceType.Wood] = "Assets/Main/Sprites/UI/UIGiftPackageNew/G_ziyuanbuzu_02"

--ResourceTabName = {}
--ResourceTabName[ResourceType.Oil] = 100020
--ResourceTabName[ResourceType.Metal] = 722034
--ResourceTabName[ResourceType.Water] = 100546
--ResourceTabName[ResourceType.Electricity] = 100002
--ResourceTabName[ResourceType.Money] = 100000
--ResourceTabName[ResourceType.Wood] = 104283
--ResourceTabName[ResourceType.LM_food] = 722034
--ResourceTabName[ResourceType.LM_metal] = 710060
--ResourceTabName[ResourceType.FLINT] = 110353
--ResourceTabName[ResourceType.Oil] = 110352

--UICapacityTableTab=
--{
--    Farming = 4,    --战争  --跟Item合在一起
--    Industry = 2,   --加速
--    Resource = 3,   --资源
--    Item = 4,       --道具  --跟Farming合在一起
--    HeroEquip = 5,  --装备
--    Hero = 6,       --英雄
--}

--UIWorldTileTopBtnType =
--{
--    Share = 1,  --分享
--    Book = 2,   --收藏
--    Emoji = 3,  --表情
--    PackUp = 4, --收起
--}

--UIWorldTileTopBtnSort =
--{
--    UIWorldTileTopBtnType.Share,
--    UIWorldTileTopBtnType.Book,
--    -- UIWorldTileTopBtnType.Emoji,
--    --UIWorldTileTopBtnType.PackUp,
--}

--UIWorldTileTopBtnImage = {}
--UIWorldTileTopBtnImage[UIWorldTileTopBtnType.Share] = "Assets/Main/Sprites/UI/Common/New/Common_btn_share_position.png"
--UIWorldTileTopBtnImage[UIWorldTileTopBtnType.Book] = "Assets/Main/Sprites/UI/UISearch/UISearch_btn_collect.png"
--UIWorldTileTopBtnImage[UIWorldTileTopBtnType.Emoji] = "Assets/Main/Sprites/UI/Common/New/Common_btn_meme.png"
--UIWorldTileTopBtnImage[UIWorldTileTopBtnType.PackUp] = "Assets/Main/Sprites/UI/Common/New/Common_btn_recycle.png"

--排序规则 大的在右边
WorldTileBtnType = {
    City_Repair = 1, --- 维修
    City_Robot_Set = 2,--设置机器人
    AssistanceSeasonBuild = 3,--援助赛季建筑
    City_Details = 4, -- 建筑详情
    City_Assistance = 5, --援助
    City_Upgrade = 6, -- 城市升级
    City_MyProfile = 7, -- 我的详情
    City_Attack = 8, -- 攻击
    City_EarthOrder = 9, --地球订单
    --City_Product = 9, --加工厂加工
    City_Science = 10, --科研
    City_Call = 11, --呼叫直升机
    City_QiFei = 12, --起飞
    City_SpeedUp = 13, --加速建造
    March_ViewTroop = 14, --查看行军部队
    March_SpeedUp = 15, --行军加速
    March_Callback = 16, --行军召回
    March_Rally = 17, --集结
    March_Attack = 18, --攻击
    City_PickUp = 19, --收起建筑
    City_Recovery = 20, --治疗伤兵
    City_BusinessCenter = 21, --商业中心
    City_ColdCapacity = 22, --冷库
    City_IntegratedWarehouse = 23, --综合仓库
    City_ResourceTransport = 24, --资源运输
    City_SpeedUpTrain = 25, --加速训练
    City_SpeedUpScience = 26, --加速科技
    City_SpeedUpHospital = 27, --加速治疗
    City_TrainingAircraft = 28, --训练飞机
    City_TrainingInfantry = 29, --训练机器人
    City_TrainingTank = 30, --训练坦克
    City_Defence = 31, --防守编队
    Hero_Advance = 33, --英雄进阶
    --Hero_Bag = 33, --英雄背包
    City_BatteryrAttack = 34, --炮台攻击
    City_Garrison = 35, --炮台驻扎
    WormHole_Enter = 36, --进入虫洞
    RadarCenter_Alert = 37, --雷达中心预警
    RadarCenter_Detective = 38, --雷达中心探测
    AllianceResSupport = 39, --资源援助
    AllianceEntrance = 40,--联盟入口
    AllianceBattle = 41,--联盟战争
    ARMY = 44,--部队
    WormHole_Create = 45, --虫洞创造
    WormHole_Dismantle = 46, --虫洞拆除
    GolloesCamp = 47,--咕噜营地
    City_GROCERY_STORE = 48,--杂货店订单
    Hero_Station = 49,--英雄驻扎
    City_SpeedUpRuins = 50, --加速建造废墟
    Konbini = 51, --小卖部
    StorageShop = 52,--交易行
    --GarageRefit = 53, --车库改造
    PoliceStation=54,--警察局入口
    --WorldTrend = 55,--天下大势
    WormHoleToB = 56,--虫洞前往B口
    WormHoleToC = 57,--虫洞前往C口
    CommonShop = 59, --通用商店
    HeroResetShop = 60,--海报商店
    WorldNews = 61,--世界新闻
    Talent = 62,--天赋
    HeroBounty = 63,--英雄悬赏
    HeroOfficial = 64,--英雄官职
    LevelExplore = 65,
    PveMonument = 66,--进入英雄经验关卡
    CrossWormHoleEnter= 67,--进入跨服虫洞
    EnergyOrder = 68,--体力订单
    Museum = 69,--博物馆
    Hero_Bag = 70, --英雄背包

    SU_Warehouse = 72, --仓库
    SU_Factory = 73, --加工厂
    SU_Repair = 74, --修复
    SU_Blueprint_Weapon = 75, --武器蓝图
    SU_Blueprint_Equip = 76, --装备蓝图
    SU_Bed = 77, --床
    SU_Mail = 78,
    SU_Bar = 79,
    SU_Recycle = 80,--回收站
    --RocketBomb = 93, --火箭炸弹

    Hero_Recruit = 170, --英雄招募
    Poster_Exchange = 171, --英雄海报兑换勋章
    Decoration = 172, --皮肤
    SeasonBuildPickUp = 173,--收起城内建筑

    GarageEquipment = 175, --装备
    GarageRefit = 716, --车库改造
    GarageRefitDrone = 717, -- 无人机，四合一车库
    GarageFormation = 718, --车库编队

    EquipmentBag = 177, --装备仓库
    City_Product = 178, --加工厂加工
    CrossWormHero = 179, --跨服虫洞进驻英雄
    DesertOperate = 180,
    HeroMedalShop = 181, --英雄勋章商店
    bathe = 182,--洗澡
    Food = 183,--食材
    Cook = 184,--烹饪
    PoliceInsignia = 185, -- 警徽
    Barrel_Pve = 186, -- 房车PVE
    PoliceInsigniaOut = 186, -- 警徽建筑上的气泡
    HeroEquip = 187, --英雄装备
    ActivityTrain = 188, --押镖入口
    LoveNewsletter = 189, --英雄爱情通讯

    Notice = 190,--公告
    HeroDispatch = 191,--英雄派遣
    HeroIntensify = 192,--荣耀殿堂
    PhotoWall = 193, --照片墙

    BaubleUpgrade = 1000, --装饰建筑升级
    BaubleDetail = 1001, --装饰建筑详情
    BaubleChangePos = 1002, --装饰建筑改变位置
    SkinShop = 1003, --皮肤商店
}

WorldTileBtnTypeImage = {}

WorldTileBtnTypeImage[WorldTileBtnType.SU_Warehouse] = "uibuild_btn_Warehouse"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Factory] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Repair] = "UImain_icon_repair"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Blueprint_Weapon] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Blueprint_Equip] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Bed] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Mail] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Bar] = "uibuild_btn_working"
WorldTileBtnTypeImage[WorldTileBtnType.SU_Recycle] = "uibuild_btn_working"

WorldTileBtnTypeImage[WorldTileBtnType.City_Repair] = "uibuild_btn_repair"
WorldTileBtnTypeImage[WorldTileBtnType.City_SpeedUpRuins] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_MyProfile] = "uibuild_btn_info_des"
WorldTileBtnTypeImage[WorldTileBtnType.City_Attack] = "uibuild_btn_infantry"
WorldTileBtnTypeImage[WorldTileBtnType.City_Upgrade] = "uibuild_btn_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_Science] = "uibuild_btn_science"
WorldTileBtnTypeImage[WorldTileBtnType.City_Call] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_QiFei] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_SpeedUp] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_Recovery] = "uibuild_btn_recovery"
WorldTileBtnTypeImage[WorldTileBtnType.March_ViewTroop] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.March_SpeedUp] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.March_Callback] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.March_Rally] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.March_Attack] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_PickUp] = "uibuild_btn_pickup"
WorldTileBtnTypeImage[WorldTileBtnType.City_Details] = "uibuild_btn_info_des"
WorldTileBtnTypeImage[WorldTileBtnType.City_EarthOrder] = "uibuild_btn_rocket"
WorldTileBtnTypeImage[WorldTileBtnType.City_Product] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_BusinessCenter] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_ColdCapacity] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.Hero_Advance] = "UIreset_icon_degree"
WorldTileBtnTypeImage[WorldTileBtnType.Hero_Recruit] = "UIreset_icon_recruit"
WorldTileBtnTypeImage[WorldTileBtnType.City_IntegratedWarehouse] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.Barrel_Pve] = "uibuild_btn_attack"
WorldTileBtnTypeImage[WorldTileBtnType.City_ResourceTransport] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_SpeedUpTrain] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_SpeedUpScience] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_SpeedUpHospital] = "uibuild_btn_speed_up"
WorldTileBtnTypeImage[WorldTileBtnType.City_TrainingAircraft] = "uibuild_btn_aircraft"
WorldTileBtnTypeImage[WorldTileBtnType.City_TrainingInfantry] = "uibuild_btn_infantry"
WorldTileBtnTypeImage[WorldTileBtnType.City_TrainingTank] = "uibuild_btn_tank"
WorldTileBtnTypeImage[WorldTileBtnType.City_Defence] = "uibuild_btn_defences"
WorldTileBtnTypeImage[WorldTileBtnType.City_BatteryrAttack] = "uibuild_btn_infantry"
WorldTileBtnTypeImage[WorldTileBtnType.City_Garrison] = "uibuild_btn_tank"
WorldTileBtnTypeImage[WorldTileBtnType.WormHole_Enter] = "uibuild_btn_transmit"
WorldTileBtnTypeImage[WorldTileBtnType.City_Assistance] = "uibuild_btn_defences"
WorldTileBtnTypeImage[WorldTileBtnType.RadarCenter_Alert] = "uibuild_btn_defences"
WorldTileBtnTypeImage[WorldTileBtnType.RadarCenter_Detective] = "uibuild_btn_detect_event"
WorldTileBtnTypeImage[WorldTileBtnType.AllianceResSupport] = "uibuild_btn_al_help"
WorldTileBtnTypeImage[WorldTileBtnType.AllianceEntrance] = "uibuild_btn_al_entrance"
WorldTileBtnTypeImage[WorldTileBtnType.AllianceBattle] = "uibuild_btn_al_battle"
WorldTileBtnTypeImage[WorldTileBtnType.City_GROCERY_STORE] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.City_Robot_Set] = "uibuild_btn_robot"
WorldTileBtnTypeImage[WorldTileBtnType.ARMY] = "uibuild_btn_al_troop"
WorldTileBtnTypeImage[WorldTileBtnType.WorldNews] = "uibuild_btn_worldNews"
WorldTileBtnTypeImage[WorldTileBtnType.Notice] = "uibuild_btn_worldNews"
WorldTileBtnTypeImage[WorldTileBtnType.WormHole_Create] = "uibuild_btn_xiujian"
WorldTileBtnTypeImage[WorldTileBtnType.WormHole_Dismantle] = "uibuild_btn_chaichu"
WorldTileBtnTypeImage[WorldTileBtnType.WormHoleToB] = "uibuild_btn_shachong_b"
WorldTileBtnTypeImage[WorldTileBtnType.WormHoleToC] = "uibuild_btn_shachong_c"
WorldTileBtnTypeImage[WorldTileBtnType.GolloesCamp] = "uibuild_btn_golloesCamp"
WorldTileBtnTypeImage[WorldTileBtnType.Hero_Station] = "uibuild_btn_hero_station"
WorldTileBtnTypeImage[WorldTileBtnType.StorageShop] = "uibuild_btn_storageShop"
WorldTileBtnTypeImage[WorldTileBtnType.CommonShop] = "uibuild_btn_commonShop"
WorldTileBtnTypeImage[WorldTileBtnType.GarageFormation] = "uibuild_btn_garagerefit"  --车库改造
WorldTileBtnTypeImage[WorldTileBtnType.Konbini] = "uibuild_btn_konbini"
WorldTileBtnTypeImage[WorldTileBtnType.GarageRefit] = "uibuild_btn_garagerefit"
WorldTileBtnTypeImage[WorldTileBtnType.GarageRefitDrone] = "uibuild_btn_garagerefit"
WorldTileBtnTypeImage[WorldTileBtnType.PoliceStation] = "uibuild_btn_police_station"
--WorldTileBtnTypeImage[WorldTileBtnType.WorldTrend] = "uibuild_btn_mars"
WorldTileBtnTypeImage[WorldTileBtnType.PveMonument] = "uibuild_btn_heroMounment"
WorldTileBtnTypeImage[WorldTileBtnType.Talent] = "uibuild_btn_Talent"
WorldTileBtnTypeImage[WorldTileBtnType.HeroResetShop] = "uibuild_btn_heroShop"
WorldTileBtnTypeImage[WorldTileBtnType.HeroBounty] = "uibuild_btn_reward"
WorldTileBtnTypeImage[WorldTileBtnType.HeroOfficial] = "uibuild_btn_hero_official"
WorldTileBtnTypeImage[WorldTileBtnType.LevelExplore] = "uibuild_btn_level_explore"
WorldTileBtnTypeImage[WorldTileBtnType.CrossWormHoleEnter] = "uibuild_btn_cross"
WorldTileBtnTypeImage[WorldTileBtnType.CrossWormHero] = "uibuild_btn_defences"
WorldTileBtnTypeImage[WorldTileBtnType.Museum] = "uibuild_btn_museum"
--WorldTileBtnTypeImage[WorldTileBtnType.Hero_Bag] = "uibuild_btn_heroShop"
WorldTileBtnTypeImage[WorldTileBtnType.Decoration] = "uibuild_btn_skin"
--WorldTileBtnTypeImage[WorldTileBtnType.Hero_Bag] = "uibuild_btn_heroShop"
--WorldTileBtnTypeImage[WorldTileBtnType.EnergyOrder] = "uibuild_btn_energy_order"
WorldTileBtnTypeImage[WorldTileBtnType.Poster_Exchange] = "uibuild_btn_badge"
WorldTileBtnTypeImage[WorldTileBtnType.SeasonBuildPickUp] = "uibuild_btn_pickup"
WorldTileBtnTypeImage[WorldTileBtnType.AssistanceSeasonBuild] = "uibuild_btn_reinforce"
WorldTileBtnTypeImage[WorldTileBtnType.DesertOperate] = "uibuild_btn_operate"
WorldTileBtnTypeImage[WorldTileBtnType.GarageEquipment] = "common_btn_formation"
WorldTileBtnTypeImage[WorldTileBtnType.EquipmentBag] = "common_btn_formation"
WorldTileBtnTypeImage[WorldTileBtnType.HeroMedalShop] = "common_btn_exchange"
WorldTileBtnTypeImage[WorldTileBtnType.bathe] = "xizao"
WorldTileBtnTypeImage[WorldTileBtnType.Food] = "uibuild_btn_ingredients"
WorldTileBtnTypeImage[WorldTileBtnType.Cook] = "uibuild_btn_cooking"
--WorldTileBtnTypeImage[WorldTileBtnType.RocketBomb] = "uibuild_btn_rocket_bomb"
WorldTileBtnTypeImage[WorldTileBtnType.HeroEquip] = "uibuild_btn_Equipment"
WorldTileBtnTypeImage[WorldTileBtnType.ActivityTrain] = "uibuild_btn_build"
WorldTileBtnTypeImage[WorldTileBtnType.LoveNewsletter] = "uibuild_btn_aiqing_tongxun"
WorldTileBtnTypeImage[WorldTileBtnType.HeroDispatch] = "common_btn_dispatch"
WorldTileBtnTypeImage[WorldTileBtnType.LoveNewsletter] = "uibuild_btn_aiqing_tongxun"
WorldTileBtnTypeImage[WorldTileBtnType.HeroIntensify] = "common_btn_rongyaodiantang"
WorldTileBtnTypeImage[WorldTileBtnType.PhotoWall] = "common_btn_photo"
WorldTileBtnTypeImage[WorldTileBtnType.BaubleDetail] = "uibuild_btn_info_des"
WorldTileBtnTypeImage[WorldTileBtnType.BaubleUpgrade] = "uibuild_btn_up"
WorldTileBtnTypeImage[WorldTileBtnType.BaubleChangePos] = "uibuild_btn_refresh"
WorldTileBtnTypeImage[WorldTileBtnType.SkinShop] = "uibuild_btn_fashion"

--WorldTileBtnTypName = {}
--WorldTileBtnTypName[WorldTileBtnType.SU_Warehouse] = 860100
--WorldTileBtnTypName[WorldTileBtnType.SU_Factory] = 860101
--WorldTileBtnTypName[WorldTileBtnType.SU_Repair] = 860102
--WorldTileBtnTypName[WorldTileBtnType.SU_Blueprint_Weapon] = 860101
--WorldTileBtnTypName[WorldTileBtnType.SU_Blueprint_Equip] = 860101
--WorldTileBtnTypName[WorldTileBtnType.SU_Bed] = 860103
--WorldTileBtnTypName[WorldTileBtnType.SU_Mail] = 860104
--WorldTileBtnTypName[WorldTileBtnType.SU_Bar] = 860105
--WorldTileBtnTypName[WorldTileBtnType.SU_Recycle] = 860106
--WorldTileBtnTypName[WorldTileBtnType.City_Repair] = 860102
--WorldTileBtnTypName[WorldTileBtnType.City_SpeedUpRuins] = 860107
--WorldTileBtnTypName[WorldTileBtnType.City_MyProfile] = 860108
--WorldTileBtnTypName[WorldTileBtnType.City_Attack] = 860117
--WorldTileBtnTypName[WorldTileBtnType.City_Upgrade] = 100091
--WorldTileBtnTypName[WorldTileBtnType.City_Science] = 860110
--WorldTileBtnTypName[WorldTileBtnType.City_Call] = 860111
--WorldTileBtnTypName[WorldTileBtnType.City_QiFei] = 860112
--WorldTileBtnTypName[WorldTileBtnType.City_SpeedUp] = 100159
--WorldTileBtnTypName[WorldTileBtnType.City_Recovery] = 860113
--WorldTileBtnTypName[WorldTileBtnType.March_ViewTroop] = 860114
--WorldTileBtnTypName[WorldTileBtnType.March_SpeedUp] = 860107
--WorldTileBtnTypName[WorldTileBtnType.March_Callback] = 860115
--WorldTileBtnTypName[WorldTileBtnType.March_Rally] = 860116
--WorldTileBtnTypName[WorldTileBtnType.March_Attack] = 860117
--WorldTileBtnTypName[WorldTileBtnType.City_PickUp] = 860118
--WorldTileBtnTypName[WorldTileBtnType.Barrel_Pve] = 724021
--WorldTileBtnTypName[WorldTileBtnType.City_Details] = 100092
--WorldTileBtnTypName[WorldTileBtnType.Hero_Advance] = 860119
--WorldTileBtnTypName[WorldTileBtnType.Hero_Recruit] = 860120
--WorldTileBtnTypName[WorldTileBtnType.City_ResourceTransport] = 860121
--WorldTileBtnTypName[WorldTileBtnType.City_SpeedUpTrain] = 860107
--WorldTileBtnTypName[WorldTileBtnType.City_SpeedUpScience] = 860107
--WorldTileBtnTypName[WorldTileBtnType.City_SpeedUpHospital] = 860107
--WorldTileBtnTypName[WorldTileBtnType.City_TrainingAircraft] = 860109
--WorldTileBtnTypName[WorldTileBtnType.City_TrainingInfantry] = 860109
--WorldTileBtnTypName[WorldTileBtnType.City_TrainingTank] = 860109
--WorldTileBtnTypName[WorldTileBtnType.City_Defence] = 860122
--WorldTileBtnTypName[WorldTileBtnType.City_BatteryrAttack] = 860117
--WorldTileBtnTypName[WorldTileBtnType.GarageFormation] = 302254 -- old Id: 860134 车库改造
--WorldTileBtnTypName[WorldTileBtnType.City_Garrison] = 860109
--WorldTileBtnTypName[WorldTileBtnType.WormHole_Enter] = 104318
--WorldTileBtnTypName[WorldTileBtnType.City_Assistance] = 860123
--WorldTileBtnTypName[WorldTileBtnType.RadarCenter_Alert] = 860124
--WorldTileBtnTypName[WorldTileBtnType.RadarCenter_Detective] = 860125
--WorldTileBtnTypName[WorldTileBtnType.AllianceResSupport] = 860123
--WorldTileBtnTypName[WorldTileBtnType.AllianceEntrance] = 860126
--WorldTileBtnTypName[WorldTileBtnType.AllianceBattle] = 860116
--WorldTileBtnTypName[WorldTileBtnType.ARMY] = 860127
--WorldTileBtnTypName[WorldTileBtnType.WorldNews] = 860128
--WorldTileBtnTypName[WorldTileBtnType.Notice] = 450158
--WorldTileBtnTypName[WorldTileBtnType.WormHole_Create] = 104317
--WorldTileBtnTypName[WorldTileBtnType.WormHole_Dismantle] = 130242
--WorldTileBtnTypName[WorldTileBtnType.GolloesCamp] = 860129
--WorldTileBtnTypName[WorldTileBtnType.Hero_Station] = 896735
--WorldTileBtnTypName[WorldTileBtnType.StorageShop] = 860131
--WorldTileBtnTypName[WorldTileBtnType.CommonShop] = 860132
--WorldTileBtnTypName[WorldTileBtnType.Konbini] = 860133
--WorldTileBtnTypName[WorldTileBtnType.GarageRefit] = 860134
--WorldTileBtnTypName[WorldTileBtnType.GarageRefitDrone] = 860134
--WorldTileBtnTypName[WorldTileBtnType.PveMonument] = 860136
--WorldTileBtnTypName[WorldTileBtnType.HeroResetShop] = 860132
--WorldTileBtnTypName[WorldTileBtnType.HeroBounty] = 860137
--WorldTileBtnTypName[WorldTileBtnType.HeroOfficial] = 860138
--WorldTileBtnTypName[WorldTileBtnType.CrossWormHoleEnter] = 143584
--WorldTileBtnTypName[WorldTileBtnType.CrossWormHero] = 143655
--WorldTileBtnTypName[WorldTileBtnType.Decoration] = 860139
--WorldTileBtnTypName[WorldTileBtnType.SeasonBuildPickUp] = 104319
--WorldTileBtnTypName[WorldTileBtnType.AssistanceSeasonBuild] = 300516
--WorldTileBtnTypName[WorldTileBtnType.DesertOperate] = 110728
--WorldTileBtnTypName[WorldTileBtnType.GarageEquipment] = 860140
--WorldTileBtnTypName[WorldTileBtnType.EquipmentBag] = 860135
--WorldTileBtnTypName[WorldTileBtnType.HeroMedalShop] = 860132
--WorldTileBtnTypName[WorldTileBtnType.bathe] = 820720
--WorldTileBtnTypName[WorldTileBtnType.Food] = 722042
--WorldTileBtnTypName[WorldTileBtnType.Cook] = 722041
--WorldTileBtnTypName[WorldTileBtnType.City_ColdCapacity] = 860135
--WorldTileBtnTypName[WorldTileBtnType.HeroEquip] = 100348
--WorldTileBtnTypName[WorldTileBtnType.ActivityTrain] = 458657
--WorldTileBtnTypName[WorldTileBtnType.LoveNewsletter] = 855002
--WorldTileBtnTypName[WorldTileBtnType.HeroDispatch] = 390146
--WorldTileBtnTypName[WorldTileBtnType.LoveNewsletter] = 855002
--WorldTileBtnTypName[WorldTileBtnType.HeroIntensify] = 483305
--WorldTileBtnTypName[WorldTileBtnType.PhotoWall] = 821055
--WorldTileBtnTypName[WorldTileBtnType.BaubleDetail] = 100092
--WorldTileBtnTypName[WorldTileBtnType.BaubleUpgrade] = 100091
--WorldTileBtnTypName[WorldTileBtnType.BaubleChangePos] = 110126
--WorldTileBtnTypName[WorldTileBtnType.SkinShop] = 821076

--怪物类型 用与区分模型以及音效
--MonsterType =
--{
--    Normal = 1,     --普通僵尸
--    RedZombie = 2,  --红色僵尸
--    WorldBoss = 3,  --世界Boss
--    Dog = 4,        --狗
--    Bucket = 5,     --铁桶僵尸
--}

WorldPointBtnType =
{
    Outfire = -4,  --灭火
    PlayerInfo = -3,
    Decoration = -2,
    Detail = -1,
    None =0,
    AttackMonster = 1,
    AttackActChallenge = 1.5,
    RallyBoss = 2,
    AttackCity = 3,
    AttackBuild =4,
    AttackRoad = 5,
    DeclareWar = 5.1,
    ReservationDeclareWar = 5.2, -- 预约宣战
    CReservationDeclareWar = 5.3, -- 修改预约宣战
    RallyCity = 6,
    RallyBuild = 7,
    AssistanceCity = 8,

    BuildUpgrade = 8.2,
    BuildSpeed = 8.3,
    BuildDetail = 8.4,
    AssistanceBuild = 9,
    ScoutCity = 10,
    ScoutBuild = 11,

    ResourceHelp = 13,
    Collect = 14,
    CallBack = 15,
    AttackArmyCollect = 16,
    ScoutArmyCollect = 16.1,
    Search = 17,
    Explore = 18,
    GetReward =19,
    Sample = 20,
    PickGarbage = 21,
    SingleMapGarbage = 22,
    StorageShop = 23,
    AllianceCollect = 25,
    TransPos = 26,
    AttackActBoss = 27,
    CheckActBossRank = 28,
    BlackKnight = 29,--黑骑士活动
    MonsterLockAttack = 30,
    AttackPuzzleBoss = 31,
    CheckPuzzleBossRank = 32,
    ChallengeHelp = 33,
    AssistanceDesert = 36,
    AttackDesert = 37, --赛季攻击
    ScoutDesert = 38,  --赛季侦查
    DesertBuildList = 39,  --赛季建造
    GiveUpDesert = 40,
    CancelGiveUpDesert = 41,
    CheckDesert = 42,
    AllianceMine_Construct = 43,
    AllianceMine_Collect = 44,
    AllianceMineDetail = 45,
    AllianceMineCallback = 44.5,
    AllianceMineFoldUp = 44.6,
    TrainDesert = 47,
    GuideEventMonster = 48,--引导世界事件怪
    AttackAllianceBuild = 49,
    ScoutAllianceBuild = 50,
    AssistanceAllianceBuild  =51,
    RallyAllianceBuild = 52,
    ReBuildAllianceRuin = 53,
    BuildAllianceCenter = 54,  --联盟中心
    City_Defence = 55, --防守编队
    GoBackToCity = 55.1,
    FoldUpAllianceBuild = 56,
    RallyThrone = 58,
    RallyAssistanceThrone = 59,
    ScoutThrone = 60,
    AppointPosition = 60.1, --总统
    DonateSoldier = 61,--捐兵活动
    DesertOperate = 62,
    ALVSDonateSoldier = 63,--新捐兵活动
    Missile = 64,--导弹
    AttackAllianceBoss = 65,
    AllianceBossRank = 66,
    AttackCityReward = 70, --打城奖励
    GetSecretKey = 75,
    Emotion = 76,
    AllianceCityRank = 81,
    DispatchTask = 83,-- 派遣任务
    DispatchTaskHelp = 84,  -- 派遣任务帮助
    DispatchTaskSteal = 85, -- 派遣任务偷取
    HelperDetect = 7.9,-- 帮助雷达事件
    RecuseDetect = 87,-- 救援雷达事件
    AttackNpcCity = 88,-- 虚拟玩家
    MoveCity = 89,
    March = 90,
    DetectEventNewCollect = 91, --对应雷达类型21
    RallyAllianceBoss = 92, --集结联盟boss
    AllianceBossReward = 93,--联盟boss奖励
    AttackTrain = 94, -- 攻击卡车
    AllianceBossViewOpen = 95,--联盟boss 预约开启
    ScoutNpcCity = 96,--侦查虚拟玩家
    AttackDragonBuild = 97,
    ScoutDragonBuild = 98,
    AssistanceDragonBuild  =99,
    GetSecretKey = 100,
    AttackCrossThroneBuild = 101,
    ScoutCrossThroneBuild = 102,
    AssistanceCrossThroneBuild  = 103,
    RallyCrossThroneBuild  = 104,
    DigTreasure = 105,
    DigTreasureBack = 106,
    AllianceBuildInfo = 107,
    MinePlunder_Collect = 108,--金矿掠夺矿点：采集
    MinePlunder = 109,--金矿掠夺矿点：掠夺
    MinePlunder_Back = 110,--返回
    MinePlunder_Rally = 111,
    MinePlunder_Scout = 112,
    MinePlunder_Detail = 113,

    ThroneBattleRecord = 114, --首都争夺记录
    TowerBattleRecord = 115,  --炮台争夺记录
}

--按钮顺序以后放在这里,号段间隔预留位置
WorldPointBtnSortType = {}
WorldPointBtnSortType[WorldPointBtnType.Emotion] = -4
WorldPointBtnSortType[WorldPointBtnType.PlayerInfo] = -3
WorldPointBtnSortType[WorldPointBtnType.Decoration] = -2
WorldPointBtnSortType[WorldPointBtnType.Detail] = -1
WorldPointBtnSortType[WorldPointBtnType.None] = 0
WorldPointBtnSortType[WorldPointBtnType.AttackMonster] = 10

WorldPointBtnSortType[WorldPointBtnType.RallyBoss] = 20
WorldPointBtnSortType[WorldPointBtnType.AttackCity] = 30
WorldPointBtnSortType[WorldPointBtnType.AttackBuild] = 40
WorldPointBtnSortType[WorldPointBtnType.AttackRoad] = 50
WorldPointBtnSortType[WorldPointBtnType.RallyCity] = 60
WorldPointBtnSortType[WorldPointBtnType.RallyBuild] = 70
WorldPointBtnSortType[WorldPointBtnType.AssistanceCity] = 80

WorldPointBtnSortType[WorldPointBtnType.AttackNpcCity] = 81
WorldPointBtnSortType[WorldPointBtnType.ScoutNpcCity] = 82

WorldPointBtnSortType[WorldPointBtnType.AssistanceBuild] = 90
WorldPointBtnSortType[WorldPointBtnType.BuildDetail] = 121
WorldPointBtnSortType[WorldPointBtnType.BuildUpgrade] = 122
WorldPointBtnSortType[WorldPointBtnType.BuildSpeed] = 123


WorldPointBtnSortType[WorldPointBtnType.ScoutCity] = 100  
WorldPointBtnSortType[WorldPointBtnType.AttackCityReward] = 200  --打城奖励
WorldPointBtnSortType[WorldPointBtnType.ScoutBuild] = 110
WorldPointBtnSortType[WorldPointBtnType.ScoutArmyCollect] = 120



WorldPointBtnSortType[WorldPointBtnType.ResourceHelp] = 130
WorldPointBtnSortType[WorldPointBtnType.Collect] = 140
WorldPointBtnSortType[WorldPointBtnType.CallBack] = 150
WorldPointBtnSortType[WorldPointBtnType.AttackArmyCollect] = 160
WorldPointBtnSortType[WorldPointBtnType.Search] = 170
WorldPointBtnSortType[WorldPointBtnType.Explore] = 180
WorldPointBtnSortType[WorldPointBtnType.GetReward] = 190
WorldPointBtnSortType[WorldPointBtnType.Sample] = 200
WorldPointBtnSortType[WorldPointBtnType.PickGarbage] = 210
WorldPointBtnSortType[WorldPointBtnType.SingleMapGarbage] = 220
WorldPointBtnSortType[WorldPointBtnType.StorageShop] = 230
WorldPointBtnSortType[WorldPointBtnType.BlackKnight] = 240
WorldPointBtnSortType[WorldPointBtnType.AllianceCollect] = 250
WorldPointBtnSortType[WorldPointBtnType.TransPos] = 260
WorldPointBtnSortType[WorldPointBtnType.AttackActBoss] = 270
WorldPointBtnSortType[WorldPointBtnType.CheckActBossRank] = 280
WorldPointBtnSortType[WorldPointBtnType.DeclareWar] = 290
WorldPointBtnSortType[WorldPointBtnType.MonsterLockAttack] = 300
WorldPointBtnSortType[WorldPointBtnType.AttackPuzzleBoss] = 310
WorldPointBtnSortType[WorldPointBtnType.CheckPuzzleBossRank] = 320
WorldPointBtnSortType[WorldPointBtnType.ChallengeHelp] = 330
WorldPointBtnSortType[WorldPointBtnType.AttackActChallenge] = 340
WorldPointBtnSortType[WorldPointBtnType.GoBackToCity] = 350
WorldPointBtnSortType[WorldPointBtnType.AssistanceDesert] = 360
WorldPointBtnSortType[WorldPointBtnType.TrainDesert] = 370
WorldPointBtnSortType[WorldPointBtnType.DesertBuildList] = 380
WorldPointBtnSortType[WorldPointBtnType.AttackDesert] = 390
WorldPointBtnSortType[WorldPointBtnType.ScoutDesert] = 400
WorldPointBtnSortType[WorldPointBtnType.GiveUpDesert] = 410
WorldPointBtnSortType[WorldPointBtnType.CancelGiveUpDesert] = 420
WorldPointBtnSortType[WorldPointBtnType.CheckDesert] = 430
WorldPointBtnSortType[WorldPointBtnType.AllianceMine_Construct] = 440
WorldPointBtnSortType[WorldPointBtnType.AllianceMine_Collect] = 450
WorldPointBtnSortType[WorldPointBtnType.AllianceMineCallback] = 460
WorldPointBtnSortType[WorldPointBtnType.AllianceMineFoldUp] = 465
WorldPointBtnSortType[WorldPointBtnType.AllianceMineDetail] = 470
WorldPointBtnSortType[WorldPointBtnType.GuideEventMonster] = 480
WorldPointBtnSortType[WorldPointBtnType.AttackAllianceBuild] = 490
WorldPointBtnSortType[WorldPointBtnType.ScoutAllianceBuild] = 500
WorldPointBtnSortType[WorldPointBtnType.AssistanceAllianceBuild] = 510
WorldPointBtnSortType[WorldPointBtnType.AllianceBuildInfo] = 511
WorldPointBtnSortType[WorldPointBtnType.RallyAllianceBuild] = 520
WorldPointBtnSortType[WorldPointBtnType.ReBuildAllianceRuin] = 530
WorldPointBtnSortType[WorldPointBtnType.BuildAllianceCenter] = 540
WorldPointBtnSortType[WorldPointBtnType.City_Defence] = 550
WorldPointBtnSortType[WorldPointBtnType.FoldUpAllianceBuild] = 560
WorldPointBtnSortType[WorldPointBtnType.AppointPosition] = 570
WorldPointBtnSortType[WorldPointBtnType.RallyThrone] = 580
WorldPointBtnSortType[WorldPointBtnType.RallyAssistanceThrone] = 590
WorldPointBtnSortType[WorldPointBtnType.ScoutThrone] = 600
WorldPointBtnSortType[WorldPointBtnType.DonateSoldier] = 610
WorldPointBtnSortType[WorldPointBtnType.DesertOperate] = 620
WorldPointBtnSortType[WorldPointBtnType.Missile] = 630
WorldPointBtnSortType[WorldPointBtnType.AttackAllianceBoss] = 640
WorldPointBtnSortType[WorldPointBtnType.AllianceBossRank] = 650
WorldPointBtnSortType[WorldPointBtnType.AssistanceDragonBuild] = 750
WorldPointBtnSortType[WorldPointBtnType.AttackDragonBuild] = 760
WorldPointBtnSortType[WorldPointBtnType.ScoutDragonBuild] = 770
WorldPointBtnSortType[WorldPointBtnType.GetSecretKey] = 780
WorldPointBtnSortType[WorldPointBtnType.AssistanceCrossThroneBuild] = 790
WorldPointBtnSortType[WorldPointBtnType.AttackCrossThroneBuild] = 800
WorldPointBtnSortType[WorldPointBtnType.RallyCrossThroneBuild] = 810
WorldPointBtnSortType[WorldPointBtnType.ScoutCrossThroneBuild] = 820
WorldPointBtnSortType[WorldPointBtnType.DispatchTask] = 830
WorldPointBtnSortType[WorldPointBtnType.DispatchTaskHelp] = 840
WorldPointBtnSortType[WorldPointBtnType.DispatchTaskSteal] = 850
WorldPointBtnSortType[WorldPointBtnType.HelperDetect] = 860
WorldPointBtnSortType[WorldPointBtnType.RecuseDetect] = 870
WorldPointBtnSortType[WorldPointBtnType.DetectEventNewCollect] = 880
WorldPointBtnSortType[WorldPointBtnType.RallyAllianceBoss] = 900
WorldPointBtnSortType[WorldPointBtnType.AllianceBossViewOpen] = 901
WorldPointBtnSortType[WorldPointBtnType.AllianceBossReward] = 910
WorldPointBtnSortType[WorldPointBtnType.DigTreasure] = 920
WorldPointBtnSortType[WorldPointBtnType.DigTreasureBack] = 921

WorldPointBtnSortType[WorldPointBtnType.MinePlunder_Collect] = 930
WorldPointBtnSortType[WorldPointBtnType.MinePlunder] = 931
WorldPointBtnSortType[WorldPointBtnType.MinePlunder_Back] = 932
WorldPointBtnSortType[WorldPointBtnType.MinePlunder_Rally] = 933
WorldPointBtnSortType[WorldPointBtnType.MinePlunder_Scout] = 934
WorldPointBtnSortType[WorldPointBtnType.MinePlunder_Detail] = 935
WorldPointBtnSortType[WorldPointBtnType.Outfire] = 936

WorldPointBtnTypeImage = {}
WorldPointBtnTypeImage[WorldPointBtnType.AttackMonster] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackCity] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackBuild] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackRoad] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackDesert] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackAllianceBuild] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.TrainDesert] = "uibuild_btn_saodang"
WorldPointBtnTypeImage[WorldPointBtnType.AttackArmyCollect] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.RallyBoss] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceBuildInfo] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.AttackDragonBuild] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.RallyAllianceBoss] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutDragonBuild] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceDragonBuild] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.AttackCrossThroneBuild] ="uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutCrossThroneBuild] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceCrossThroneBuild] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.RallyCrossThroneBuild] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceBossReward] = "uibuild_btn_golloesCamp"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceBossViewOpen] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.RallyCity] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.RallyBuild] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.RallyAllianceBuild] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceCity] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceBuild] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceDesert] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.AssistanceAllianceBuild] = "uibuild_btn_reinforce"
WorldPointBtnTypeImage[WorldPointBtnType.FoldUpAllianceBuild] = "uibuild_btn_pickup"
WorldPointBtnTypeImage[WorldPointBtnType.DesertOperate] = "uibuild_btn_operate"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutCity] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.AttackCityReward] = "uibuild_btn_golloesCamp"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutNpcCity] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutBuild] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutArmyCollect] = "uibuild_btn_scout"


WorldPointBtnTypeImage[WorldPointBtnType.BuildDetail] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.BuildUpgrade] = "uibuild_btn_up"
WorldPointBtnTypeImage[WorldPointBtnType.BuildSpeed] = "uibuild_btn_speed_up"




WorldPointBtnTypeImage[WorldPointBtnType.ScoutDesert] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutAllianceBuild] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.ResourceHelp] = "uibuild_btn_help"
WorldPointBtnTypeImage[WorldPointBtnType.Collect] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceCollect] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.CallBack] = "uibuild_btn_return"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMine_Construct] = "uibuild_btn_build2"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMine_Collect] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMineDetail] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.Search] = "uibuild_btn_search"
WorldPointBtnTypeImage[WorldPointBtnType.Explore] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.GetReward] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.Sample] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.PickGarbage] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.SingleMapGarbage] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.StorageShop] = "uibuild_btn_storageShop"
WorldPointBtnTypeImage[WorldPointBtnType.Detail] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.TransPos] = "uibuild_btn_aircraft"
WorldPointBtnTypeImage[WorldPointBtnType.AttackActBoss] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.CheckActBossRank] = "uibuild_btn_bossRank"
WorldPointBtnTypeImage[WorldPointBtnType.DeclareWar] = "uibuild_btn_declare"
WorldPointBtnTypeImage[WorldPointBtnType.ReservationDeclareWar] = "uibuild_btn_reservation"
WorldPointBtnTypeImage[WorldPointBtnType.CReservationDeclareWar] = "uibuild_btn_reservation"
WorldPointBtnTypeImage[WorldPointBtnType.MonsterLockAttack] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.AttackPuzzleBoss] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.CheckPuzzleBossRank] = "uibuild_btn_bossreward"
WorldPointBtnTypeImage[WorldPointBtnType.AttackActChallenge] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.ChallengeHelp] = "uibuild_btn_alliancehelp"
WorldPointBtnTypeImage[WorldPointBtnType.GoBackToCity] = "uibuild_btn_maincity"
WorldPointBtnTypeImage[WorldPointBtnType.GiveUpDesert] = "uibuild_btn_dismantle"
WorldPointBtnTypeImage[WorldPointBtnType.CancelGiveUpDesert] = "uibuild_btn_canceldismantle"
WorldPointBtnTypeImage[WorldPointBtnType.CheckDesert] = "uibuild_btn_level_explore"
WorldPointBtnTypeImage[WorldPointBtnType.Decoration] = "uibuild_btn_skin"
WorldPointBtnTypeImage[WorldPointBtnType.PlayerInfo] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.DesertBuildList] = "uibuild_btn_collect2"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMine_Collect] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMineCallback] = "uibuild_btn_return"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceMineFoldUp] = "uibuild_btn_remove"
WorldPointBtnTypeImage[WorldPointBtnType.GuideEventMonster] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.ReBuildAllianceRuin] = "UImain_icon_repair"
WorldPointBtnTypeImage[WorldPointBtnType.BuildAllianceCenter] = "common_btn_seasonbuild"
WorldPointBtnTypeImage[WorldPointBtnType.City_Defence] = "uibuild_btn_defences"
WorldPointBtnTypeImage[WorldPointBtnType.BlackKnight] = "uibuild_btn_jump"
WorldPointBtnTypeImage[WorldPointBtnType.DonateSoldier] = "uibuild_btn_jump"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceCityRank] = "uibuild_btn_bossRank"
WorldPointBtnTypeImage[WorldPointBtnType.ThroneBattleRecord] = "uibuild_btn_bossRank"
WorldPointBtnTypeImage[WorldPointBtnType.TowerBattleRecord] = "uibuild_btn_bossRank"

WorldPointBtnTypeImage[WorldPointBtnType.AppointPosition] = "uibuild_btn_jump"
WorldPointBtnTypeImage[WorldPointBtnType.RallyThrone] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.RallyAssistanceThrone] = "uibuild_btn_defences"
WorldPointBtnTypeImage[WorldPointBtnType.ScoutThrone] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.Missile] = "uibuild_btn_daodan_purple"
WorldPointBtnTypeImage[WorldPointBtnType.AllianceBossRank] = "uibuild_btn_bossRank"
WorldPointBtnTypeImage[WorldPointBtnType.AttackAllianceBoss] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.DispatchTask] = "common_btn_formation"
WorldPointBtnTypeImage[WorldPointBtnType.DispatchTaskHelp] = "uibuild_btn_assist"
WorldPointBtnTypeImage[WorldPointBtnType.BuildAllianceCenter] = "common_btn_seasonbuild"
WorldPointBtnTypeImage[WorldPointBtnType.DispatchTaskSteal] = "uibuild_btn_plunder"
WorldPointBtnTypeImage[WorldPointBtnType.AttackTrain] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.HelperDetect] = "uibuild_btn_assist"
WorldPointBtnTypeImage[WorldPointBtnType.RecuseDetect] = "uibuild_btn_assist"
WorldPointBtnTypeImage[WorldPointBtnType.AttackNpcCity] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.DetectEventNewCollect] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.Emotion] = "icon_emote"
WorldPointBtnTypeImage[WorldPointBtnType.GetSecretKey] = "uibuild_btn_shiqu"
WorldPointBtnTypeImage[WorldPointBtnType.DigTreasure] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.DigTreasureBack] = "uibuild_btn_return"
WorldPointBtnTypeImage[WorldPointBtnType.MoveCity] = "G_dashijie_qiancheng02"
WorldPointBtnTypeImage[WorldPointBtnType.March] = "G_dashijie_qiancheng02"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder_Collect] = "uibuild_btn_collect"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder_Detail] = "uibuild_btn_info_des"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder_Back] = "uibuild_btn_return"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder] = "uibuild_btn_attack"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder_Rally] = "uibuild_btn_rally"
WorldPointBtnTypeImage[WorldPointBtnType.MinePlunder_Scout] = "uibuild_btn_scout"
WorldPointBtnTypeImage[WorldPointBtnType.Outfire] = "uibuild_btn_outfire"

WorldPointBtnName = {}
WorldPointBtnName[WorldPointBtnType.AllianceBuildInfo] = 510135 -- 规则介绍
WorldPointBtnName[WorldPointBtnType.AssistanceDragonBuild] = 300516
WorldPointBtnName[WorldPointBtnType.AttackCrossThroneBuild] = 100150
WorldPointBtnName[WorldPointBtnType.ScoutCrossThroneBuild] = 300037
WorldPointBtnName[WorldPointBtnType.AssistanceCrossThroneBuild] = 300516
WorldPointBtnName[WorldPointBtnType.RallyCrossThroneBuild] = 300038
WorldPointBtnName[WorldPointBtnType.AttackMonster] = 100150
WorldPointBtnName[WorldPointBtnType.AttackCity] = 100150
WorldPointBtnName[WorldPointBtnType.AttackBuild] = 100150
WorldPointBtnName[WorldPointBtnType.AttackRoad] = 100150
WorldPointBtnName[WorldPointBtnType.AttackDesert] = 100150
WorldPointBtnName[WorldPointBtnType.AttackTrain] = 457527
WorldPointBtnName[WorldPointBtnType.AttackDragonBuild] = 100150
WorldPointBtnName[WorldPointBtnType.AttackAllianceBuild] = 100150
WorldPointBtnName[WorldPointBtnType.TrainDesert] = 302253
WorldPointBtnName[WorldPointBtnType.AttackArmyCollect] = 100150
WorldPointBtnName[WorldPointBtnType.RallyBoss] = 300038
WorldPointBtnName[WorldPointBtnType.ScoutDragonBuild] = 300037
WorldPointBtnName[WorldPointBtnType.RallyAllianceBoss] = 300038
WorldPointBtnName[WorldPointBtnType.AllianceBossReward] = 450084
WorldPointBtnName[WorldPointBtnType.BuildAllianceCenter] = 302741
WorldPointBtnName[WorldPointBtnType.AllianceBossViewOpen] = 372711
WorldPointBtnName[WorldPointBtnType.RallyCity] = 300038
WorldPointBtnName[WorldPointBtnType.RallyBuild] = 300038
WorldPointBtnName[WorldPointBtnType.RallyAllianceBuild] = 300038
WorldPointBtnName[WorldPointBtnType.AssistanceCity] = 300516
WorldPointBtnName[WorldPointBtnType.AssistanceBuild] = 300516
WorldPointBtnName[WorldPointBtnType.AssistanceDesert] = 300516
WorldPointBtnName[WorldPointBtnType.AssistanceAllianceBuild] = 300516
WorldPointBtnName[WorldPointBtnType.FoldUpAllianceBuild] = 104319
WorldPointBtnName[WorldPointBtnType.DesertOperate] = 110728
WorldPointBtnName[WorldPointBtnType.ScoutCity] = 300037
WorldPointBtnName[WorldPointBtnType.AttackCityReward] = 111255
WorldPointBtnName[WorldPointBtnType.ScoutNpcCity] = 300037
WorldPointBtnName[WorldPointBtnType.ScoutBuild] = 300037
WorldPointBtnName[WorldPointBtnType.ScoutArmyCollect] = 300037


WorldPointBtnName[WorldPointBtnType.BuildDetail] = 458544
WorldPointBtnName[WorldPointBtnType.BuildUpgrade] = 896861
WorldPointBtnName[WorldPointBtnType.BuildSpeed] = 100159


WorldPointBtnName[WorldPointBtnType.ScoutDesert] = 300037
WorldPointBtnName[WorldPointBtnType.ScoutAllianceBuild] = 300037
--WorldPointBtnName[WorldPointBtnType.ResourceHelp] = "uibuild_btn_help"
WorldPointBtnName[WorldPointBtnType.Collect] = 128012
WorldPointBtnName[WorldPointBtnType.AllianceCollect] = 128012
WorldPointBtnName[WorldPointBtnType.CallBack] = 300520
WorldPointBtnName[WorldPointBtnType.AllianceMine_Construct] = 110015
WorldPointBtnName[WorldPointBtnType.AllianceMine_Collect] = 128012
WorldPointBtnName[WorldPointBtnType.AllianceMineDetail] = 100092
WorldPointBtnName[WorldPointBtnType.AllianceMineFoldUp] = 898544
WorldPointBtnName[WorldPointBtnType.Search] = 100192
WorldPointBtnName[WorldPointBtnType.Explore] = 100150
WorldPointBtnName[WorldPointBtnType.GetReward] = 128012
WorldPointBtnName[WorldPointBtnType.Sample] = 128012
WorldPointBtnName[WorldPointBtnType.PickGarbage] = 128012
WorldPointBtnName[WorldPointBtnType.SingleMapGarbage] = 128012
--WorldPointBtnName[WorldPointBtnType.StorageShop] = "uibuild_btn_storageShop"
WorldPointBtnName[WorldPointBtnType.Detail] = 100092
--WorldPointBtnName[WorldPointBtnType.TransPos] = "uibuild_btn_aircraft"
WorldPointBtnName[WorldPointBtnType.AttackActBoss] = 100150
WorldPointBtnName[WorldPointBtnType.CheckActBossRank] = 390040
WorldPointBtnName[WorldPointBtnType.DeclareWar] = 302812
WorldPointBtnName[WorldPointBtnType.MonsterLockAttack] = 100150
WorldPointBtnName[WorldPointBtnType.AttackPuzzleBoss] = 100150
WorldPointBtnName[WorldPointBtnType.CheckPuzzleBossRank] = 130065
WorldPointBtnName[WorldPointBtnType.AttackActChallenge] = 100150
--WorldPointBtnName[WorldPointBtnType.ChallengeHelp] = "uibuild_btn_alliancehelp"
WorldPointBtnName[WorldPointBtnType.GoBackToCity] = 104315
WorldPointBtnName[WorldPointBtnType.GiveUpDesert] = 130242
WorldPointBtnName[WorldPointBtnType.CancelGiveUpDesert] = 110106
--WorldPointBtnName[WorldPointBtnType.CheckDesert] = "uibuild_btn_level_explore"
WorldPointBtnName[WorldPointBtnType.Decoration] = 320557
WorldPointBtnName[WorldPointBtnType.PlayerInfo] = 100092
WorldPointBtnName[WorldPointBtnType.DesertBuildList] = 110015
WorldPointBtnName[WorldPointBtnType.AllianceMine_Collect] = 128012
WorldPointBtnName[WorldPointBtnType.AllianceMineCallback] = 300520
WorldPointBtnName[WorldPointBtnType.GuideEventMonster] = 100150
WorldPointBtnName[WorldPointBtnType.BlackKnight] = 372700
WorldPointBtnName[WorldPointBtnType.DonateSoldier] = 372700
WorldPointBtnName[WorldPointBtnType.ReBuildAllianceRuin] = 723003
--WorldPointBtnName[WorldPointBtnType.BuildAllianceCenter] = "uibuild_btn_tacticalbuilding_r4"
WorldPointBtnName[WorldPointBtnType.City_Defence] = 104321
WorldPointBtnName[WorldPointBtnType.AppointPosition] = 250005
WorldPointBtnName[WorldPointBtnType.RallyThrone] = 300038
WorldPointBtnName[WorldPointBtnType.RallyAssistanceThrone] = 300516
WorldPointBtnName[WorldPointBtnType.ScoutThrone] = 300037
WorldPointBtnName[WorldPointBtnType.Missile] = 300037
WorldPointBtnName[WorldPointBtnType.AllianceBossRank] = 390040
WorldPointBtnName[WorldPointBtnType.AttackAllianceBoss] = 100150
WorldPointBtnName[WorldPointBtnType.HelperDetect] = 100389
WorldPointBtnName[WorldPointBtnType.AttackNpcCity] = 100150
WorldPointBtnName[WorldPointBtnType.DetectEventNewCollect] = 100150
WorldPointBtnName[WorldPointBtnType.Emotion] = 493013
WorldPointBtnName[WorldPointBtnType.GetSecretKey] = 100547
WorldPointBtnName[WorldPointBtnType.DigTreasure] = 897960
WorldPointBtnName[WorldPointBtnType.DigTreasureBack] = 300520

WorldPointBtnName[WorldPointBtnType.MoveCity] = 300035
WorldPointBtnName[WorldPointBtnType.March] = 150122
WorldPointBtnName[WorldPointBtnType.MinePlunder_Collect] = 128012
WorldPointBtnName[WorldPointBtnType.MinePlunder_Detail] = 100092
WorldPointBtnName[WorldPointBtnType.MinePlunder_Back] = 300520
WorldPointBtnName[WorldPointBtnType.MinePlunder] = 457527
WorldPointBtnName[WorldPointBtnType.MinePlunder_Rally] = 300038
WorldPointBtnName[WorldPointBtnType.MinePlunder_Scout] = 300037
WorldPointBtnName[WorldPointBtnType.Outfire] = 900162

WorldPointUIType =
{
    None=0,
    Monster=1,
    Boss=2,
    City=3,
    Build=4,
    CollectPoint=5,
    CollectArmy=6,
    Road=7,
    Explore = 8,
    MonsterReward = 9,
    Sample = 10,
    PickGarbage = 11,
    SingleMapGarbage = 12,
    AllianceCollectPoint = 14,
    ActBoss = 15,
    MonsterLock = 16,
    PuzzleBoss = 17,
    ChallengeBoss = 18,
    CityResPoint = 19,
    Desert =20,
    AllianceMine = 21,
    GuideEventMonster = 22,
    AllianceBuild = 23,
    Ruin = 24,
    AllianceBoss = 25,
    DispatchTask = 26,
    NpcCity = 27,
    Train = 28,
    Truck = 28,
    DragonBuild = 29,
    DragonSecretKey = 30,
    GodzillaGift = 31,
    DigTreasure = 32,
    Empty = 33,
    DragonBoss = 34,
    ActResource = 35,
}

--WorldBuildTopBubbleType = {
--    None = 0,
--    HelperDetect = 1,
--    NpcCity = 2,
--}

--TruckQualityName =
--{
--    [1] = "469004",
--    [2] = "469005",
--    [3] = "469006",
--    [4] = "469007",
--    [5] = "469008",
--}

--TruckIndexName =
--{
--    [1] = "469000",
--    [2] = "469001",
--    [3] = "469002",
--    [4] = "469003",
--}

--HeroCellSmallStyle =
--{
--    Normal = 0,--通用
--    Weapon = 1,--武器
--}

--WorldBuildTopBubbleTypeData = {
--    [WorldBuildTopBubbleType.HelperDetect] = {
--        assert = "Assets/Main/Prefabs/March/WorldHelperDetectInfo.prefab",
--        script = "Scene.BuildTopBubble.HelperDetectWorldBuildBubble",
--    },
--    [WorldBuildTopBubbleType.NpcCity] = {
--        assert = "Assets/Main/Prefabs/March/WorldHelperDetectInfo.prefab",
--        script = "Scene.BuildTopBubble.NpcCityWorldBuildBubble",
--    }
--}

--WorldMarchTileBtnType =
--{
--    None = 0,
--    March_ViewTroop = 1,    -- 查看行军部队
--    March_Stop = 2,      -- 暂停
--    March_Emotion = 3, -- 表情
--    March_Callback =4,     -- 召回
--    March_Rally = 5,      -- 集结
--    March_Attack = 6,       -- 攻击
--    March_Scout = 7,        --侦查
--    March_Speed = 8,        --行军加速
--    March_Operate = 9,--行军专精操作
--	
--	March_AssistTrain = 11,    -- 援助火车
--	March_ScoutTrain = 12,    -- 援助火车
--	March_AttackTrain = 13,    -- 援助火车
--	March_ViewTrain = 14,    -- 查看火车详情
--	March_ReinforceTrain = 15,   -- 火车补兵
--}

--WorldMarchBtnTypeImage = {}
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_ViewTroop] = "uibuild_btn_info_des"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Stop] = "uibuild_btn_station"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Callback] = "uibuild_btn_return"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Rally] = "uibuild_btn_rally"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Attack] = "uibuild_btn_attack"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Scout] = "uibuild_btn_scout"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Speed] = "uibuild_btn_speed_purple"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Operate] = "uibuild_btn_operate"
--WorldMarchBtnTypeImage[WorldMarchTileBtnType.March_Emotion] = "icon_emote"
--WorldMarchBtnTypeName = {}
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_ViewTroop] = 100092
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Stop] = 400069
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Callback] = 300520
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Rally] = 300038
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Attack] = 100150
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Scout] = 300037
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Speed] = 100159
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Operate] = 110728
--WorldMarchBtnTypeName[WorldMarchTileBtnType.March_Emotion] = 493013

--按钮宽度
--BtnWidth =
--{
--    380,320
--}

--点击世界需要关闭的世界上UI
ClickWorldNeedCloseWorldUI =
{
}

--点击UI需要关闭的额外的世界上UI
ClickUINeedCloseExtraWorldUI =
{
}

--点击UI需要关闭的额外的世界上UI
DragWorldNeedCloseExtraWorldUI =
{
}

--兵营类建筑对应训练按钮
--BarracksBuildToBtnType =
--{
--    [BuildingTypes.FUN_BUILD_CAR_BARRACK] = WorldTileBtnType.City_TrainingTank,
--    [BuildingTypes.FUN_BUILD_INFANTRY_BARRACK] = WorldTileBtnType.City_TrainingInfantry,
--    [BuildingTypes.FUN_BUILD_AIRCRAFT_BARRACK] = WorldTileBtnType.City_TrainingAircraft,
--}


--订单是否全部完成
--OrderAllFinished =
--{
--    No = 0,--没有全部完成
--    Yes = 1,--全部完成
--}

--OrderType =
--{
--    Resident = 0,--居民订单
--    Earth = 1,--地球订单
--    GROCERY_ORDER = 2,--杂货店订单
--}

--MessageBarType = {
--    Get =0,
--    Cost = 1,
--    Lack = 2
--}


--BuildUpgradeUseGoldType =
--{
--    No = 0,--直接升级
--    Yes = 2,--使用钻石升级
--    Free = 3,--免费升级
--    Speed = 4, --资源足够，免费时间+道具覆盖所需时间
--}

--OrderPriorShowType =
--{
--    Normal = 0,--不优先
--    Prior = 1,--优先
--}

--FactoryWorkState =
--{
--    Free =0,
--    Work =1,
--    Full =2,
--    NotOpen = 3,
--}

--WarningType =
--{
--    Meteorite = 1,--陨石来临
--    Attack = 2 ,--攻击
--    Scout = 3,--侦查
--    Assistance = 4 ,--援助
--    ResourceAssistance = 5,--资源援助
--    AllianceAttack = 6,--集结
--}
--WarningTypeIcon = {}
--WarningTypeIcon[WarningType.Meteorite] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIMain_warning_btn_meteorite"

--UIScienceTopBtnType =
--{
--    Electricity = 1,--资源电
--    Money = 2,--资源钱
--    Gold = 3,--钻石
--}


--ScienceType =
--{
--    Build = 1,
--    Alliance = 2,
--}

--ScienceTabState =
--{
--    Lock = 0,           --锁住
--    UnLock = 1,         --已解锁
--    CanUnlock = 2,      --可解锁
--    LockShow = 3,--锁定但显示
--}


--ScienceTabUnlockType =
--{
--    PreScienceTreePro = 1,       -- 前置科技树进度
--    PreScienceLevel   = 2,       -- 前置科技等级
--    PreBuildingLevel  = 3,       -- 前置建筑等级
--    RequireActivityId = 4,       -- 前置活动id
--}

--AllianceOfficialPos = {
--    Pos1 = 1,
--    Pos2 = 2,
--    Pos3 = 3,
--    Pos4 = 4,
--}

--AllianceOfficialPosConf = {
--    [AllianceOfficialPos.Pos1] = {
--        name = 391063,
--        icon = "icon_zhanshen",
--        tip = 391067,
--    },
--    [AllianceOfficialPos.Pos2] = {
--        name = 391064,
--        icon = "icon_zhihuiguan",
--        tip = 391068,
--    },
--    [AllianceOfficialPos.Pos3] = {
--        name = 391065,
--        icon = "icon_nvshen",
--        tip = 391069,
--    },
--    [AllianceOfficialPos.Pos4] = {
--        name = 391066,
--        icon = "icon_guanjia",
--        tip = 391070,
--    },
--}

--MessageBallType = {
--    None = 0,
--    BuildingUpgrade =1,
--    JoinRoad = 2,
--    EmptyFarm = 3,
--    CanGatherFarm = 4,
--    EmptyPasture = 5,
--    CanGatherPasture = 6,
--    FactoryFree = 7,
--    FactoryCanGather = 8,
--
--    MoneyFull = 11,--金币建筑满
--    WaterFull = 12,--水满
--    OilFull = 13,--水晶满
--    MetalFull = 14,--瓦斯满
--    ElectricityFull=15,--电满
--
--    BuildingComplete = 16,--建筑完成，待点击
--    SoldierTrainComplete = 17,--士兵训练完成，待点击
--    ScienceSearchComplete = 18,--科技完成
--
--    ArmyQueueFree = 19,--兵营队列空闲
--    --ScienceQueueFree = 20,--科研队列空闲
--
--    HeroStationWarning = 21,--英雄驻扎效果值增加
--    FactoryFreeNew = 22,
--    BagMax = 23,
--    SeasonQueue = 24,--赛季队列空闲
--}

--UIWorldBuildStateOrder =
--{
--    CanPut = 1,
--    Resource = 2,--资源不足
--    Pre = 3,--需要前置
--    Max = 4,--已建造
--}

--BusinessBubbleState =
--{
--    No = 0,--不显示
--    NoSubmit = 1,--没有可交付订单
--    Yes = 2,--有可以交付订单
--}

--资源道具产出类型
--ResourceItemOutType =
--{
--    Farm = 0,--农场
--    Pasture = 1,--牧场
--    Food = 2,--食品厂
--}

--BuildRedDotType =
--{
--    No = 0,--不显示
--    AllShow = 1,--一直显示
--    Once = 2,--只显示一次
--}

--建筑升级解锁显示类型
--BuildLevelUpShowType =
--{
--    New = 1,--新品
--    Unlock = 2,--解锁
--    AddNum = 3,--数量增加
--}

--建筑升级解锁类型
--BuildLevelUpUnlockType =
--{
--    Build = 1,--解锁建筑
--    ResourceItem = 2,--解锁资源道具
--}

--ScienceShowTag =
--{
--    No = 0,
--    Recommend = 1,--推荐科技
--}

--热销道具类型
--ItemHotPage =
--{
--    No = 0,--不是热销道具
--    Yes = 1,--热销道具
--}

--BagTabSelectImage ={}
--BagTabSelectImage[UIBagBtnType.Hot] = "Assets/Main/Sprites/UI/Common/Common_img_freeze_select"
--BagTabSelectImage[UIBagBtnType.War] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_select"
--BagTabSelectImage[UIBagBtnType.Buff] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_select"
--BagTabSelectImage[UIBagBtnType.Resource] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_select"
--BagTabSelectImage[UIBagBtnType.Other] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_select"

--BagTabUnSelectImage ={}
--BagTabUnSelectImage[UIBagBtnType.Hot] = "Assets/Main/Sprites/UI/Common/Common_img_freeze_unselect"
--BagTabUnSelectImage[UIBagBtnType.War] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_unselect"
--BagTabUnSelectImage[UIBagBtnType.Buff] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_unselect"
--BagTabUnSelectImage[UIBagBtnType.Resource] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_unselect"
--BagTabUnSelectImage[UIBagBtnType.Other] = "Assets/Main/Sprites/UI/Common/Common_img_warehouse_unselect"

--BuildingConnectState =
--{
--    UnConnect = 0, --没有联通
--    Connect = 1,--联通
--}

--UIBuildQueueState =
--{
--    None = 0,
--    Free = 1,
--    Work = 2,
--}

--BuildNoQueue =
--{
--    No = 0,--占用
--    Yes = 1,--不占用建造队列
--}
--UICapacityTableResourceType=
--{
--    ResourceType.Water,
--    ResourceType.Electricity,
--}

--UIBuildQueueUnlockType =
--{
--    Upgrade = 0,--建筑升级
--    Buy = 1,--购买
--}

--UIBuildQueueImageTypeScale =
--{
--    Unlock = Vector3.New(1,1,1),--正常大小
--    Build = Vector3.New(0.3265766,0.3265766,0.3265766),--建筑缩放
--}

--UIFarmViewResourceItemPositions =
--{
--    {Vector3.New(15,-10,0)},
--    {Vector3.New(66,28,0), Vector3.New(-30,-78,0)},
--    {Vector3.New(137,60,0), Vector3.New(10,-20,0), Vector3.New(-45,-156,0)},
--    {Vector3.New(66,28,0), Vector3.New(-30,-78,0), Vector3.New(35,154,0), Vector3.New(-88,67,0)},
--    {Vector3.New(66,28,0), Vector3.New(-30,-78,0), Vector3.New(35,154,0), Vector3.New(-88,67,0), Vector3.New(-166,-63,0)},
--}

--UIBuildQueueEnterType =
--{
--    None = 0,--无
--    Build = 1,--建造
--    Upgrade = 2,--升级
--    Science = 3,--科技
--}

--UIMainBuildQueueAnimState =
--{
--    Empty = 0,--静止
--    Free = 1,--空闲
--}

--UIMainBuildQueueAnimName = {}
--UIMainBuildQueueAnimName[UIMainBuildQueueAnimState.Empty] = "BuildQueueEmpty"
--UIMainBuildQueueAnimName[UIMainBuildQueueAnimState.Free] = "BuildQueueFree"

--BuildQueueTalkShowType =
--{
--    Free = 1,--有空闲时触发
--    StartQueue = 2,--开始队列时触发
--    EndQueue = 3,--结束队列时触发
--}

--UITrainState =
--{
--    Select = 1,--选择状态
--    Training = 2,--正在训练状态
--    NoReason = 3,--锁住状态
--}
--UITrainDetailType =
--{
--    Attack = 1,
--    Defense = 2,
--    Blood = 3,
--    Speed = 4,
--    Load = 5,
--    Power = 6,
--}
--UITrainDetailTypeList =
--{
--    UITrainDetailType.Power,
--    UITrainDetailType.Attack,
--    UITrainDetailType.Defense,
--    UITrainDetailType.Blood,
--    UITrainDetailType.Speed,
--    UITrainDetailType.Load,    
--}
--UITrainDetailTypeIcon = {}
--UITrainDetailTypeIcon[UITrainDetailType.Attack] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_gongjili.png"
--UITrainDetailTypeIcon[UITrainDetailType.Defense] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_fangyu.png"
--UITrainDetailTypeIcon[UITrainDetailType.Blood] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_shengmingzhi.png"
--UITrainDetailTypeIcon[UITrainDetailType.Speed] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_xingjunsudu.png"
--UITrainDetailTypeIcon[UITrainDetailType.Load] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_fuzai.png"
--UITrainDetailTypeIcon[UITrainDetailType.Power] = "Assets/Main/Sprites/UI/Common/Soldier/SoldierIcons_icon_zhanli.png"

--UISearchType =
--{
--    Monster = 1,
--    Boss = 2,
--    Food = 3,
--    Wood = 4,
--    Electricity = 5,
--    Metal = 6,
--    Money = 7,
--    SeasonRes1 = 8,
--    SeasonRes2 = 9,
--    SeasonRes3 = 10,
--    SeasonRes4 = 11,
--}

--AnimalAnimationState =
--{
--    None = 0,
--    Free =1,
--    Feed =2,
--    Walk = 3,
--    Finish =4,
--    Fly = 5,
--    GuideShow = 6,--引导出现动画
--}

--WarningBallState =
--{
--    Free = 0,
--    Cold = 1,--冷却
--    Wait = 2,--等待
--    Show = 3,--显示
--    ShowOnce = 4, -- 只显示一次
--}

--EffectCoupleType =
--{
--    BASE_ATTACK = 100001,
--    BASE_DEFEND = 100002,
--    BASE_HEALTH =100003,
--    BASE_HEALTH_PERCENT = 100004,
--    COLLECT_ATTACK =100101,
--    COLLECT_DEFEND =100102,
--    OUTSIDE_ATTACK = 100201,
--    OUTSIDE_DEFEND = 100202,
--    TEAM_ATTACK = 100301,
--    TEAM_DEFEND = 100302,
--    ATTACK_BUILD_ATTACK = 100401,
--    ATTACK_BUILD_DEFEND = 100402,
--    STATE_BUILD_ATTACK = 100501,
--    STATE_BUILD_DEFEND = 100502,
--    ATTACK_MONSTER_ATTACK = 100601,
--    ATTACK_MONSTER_DEFEND = 100602,
--    ATTACK_ALLIANCE_NEUTRAL_CITY_ATTACK = 100701,
--    ATTACK_ALLIANCE_NEUTRAL_CITY_DEFEND = 100702,
--    
--    DAMAGE_INCREASE_PERCENTAGE = 200001,--增伤加成
--    DAMAGE_REDUCTION_PERCENTAGE = 200002,--减伤加成
--}
--[[
UIMainResourceSort = {}
UIMainResourceSort[ResourceType.Wood] = 1
UIMainResourceSort[ResourceType.Metal] = 2
UIMainResourceSort[ResourceType.Water] = 3
UIMainResourceSort[ResourceType.LM_metal] = 4
UIMainResourceSort[ResourceType.Money] = 5
]]

--罗马数字
RomeNum =
{
    "I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX","XXI","XXII","XXIX"
}

--产出资源气泡图片名字
--OutResourceTypeIconName = {}
--OutResourceTypeIconName[ResourceType.Electricity] = "Assets/Main/Sprites/UI/UIBuildBubble/bubble_icon_electricity.png"
--OutResourceTypeIconName[ResourceType.Metal] = "Assets/Main/Sprites/UI/UIBuildBubble/bubble_icon_metal.png"
--OutResourceTypeIconName[ResourceType.Oil] = "Assets/Main/Sprites/UI/UIBuildBubble/bubble_icon_oil.png"
--OutResourceTypeIconName[ResourceType.Water] = "Assets/Main/Sprites/UI/UIBuildBubble/bubble_icon_water.png"
--OutResourceTypeIconName[ResourceType.Money] = "Assets/Main/Sprites/UI/Common/Common_icon_money.png"

--时间条切换显示的类型
--UIBuildTimeTextShowType =
--{
--    Time = 1,--时间
--    Des = 2,--描述
--}

--UIResourceCostState =
--{
--    Normal = 1,--正常状态
--    Animation = 2,--做动画
--}

--CrossHitBlockFightType =
--{
--    None = 0, --未开始
--    WaitFight = 1, --等待战斗
--    Fight = 2 ,--战斗中
--}

WorldPointType =
{
    Other = 0,                     -- 空地
    WorldCollectResource = 1,           -- 世界矿根（玩家资源站建筑用）
    PlayerRoad = 2,                     -- 玩家道路
    PlayerBoard = 3,                    --基板
    WorldMonster = 4,              --世界怪物
    WorldBoss = 5,                 -- 世界Boss
    PlayerBuilding = 6,            -- 玩家建筑
    WorldResource = 7,             -- 世界资源
    EXPLORE_POINT = 8,             --小队探测点
    SAMPLE_POINT = 9,              --采样点
    GARBAGE = 10,                   --垃圾点
    WORLD_ALLIANCE_CITY =11,      --联盟城市
    MONSTER_REWARD  =12,         --野怪箱子
    SAMPLE_POINT_NEW = 13,      --新采样点
    DETECT_EVENT_PVE = 14,      --雷达pve
    WORLD_ALLIANCE_BUILD = 15,  --联盟建筑
    NPC_CITY = 16,              --npc城市
    WorldRuinPoint = 17,        --17废墟
    DRAGON_BUILDING = 18, --巨龙中立建筑
    SECRET_KEY = 19, --密钥
    WORLD_TALK_TASK = 21,  --雷达大世界对话任务
    HERO_DISPATCH = 22, --英雄派遣
    GodzillaGift = 23, --大boss奖励
    ACT_RESOURCE = 25,
    DRAGON_BOSS = 27, --巨龙Boss
}

--UIResourceBagBtnType =
--{
--    Use = 1,--使用道具
--    Buy = 2,--购买并使用
--    PickUp = 3,--收取道具
--    Build = 4,--去建造
--    Go = 5,--跳转
--    LackResMode = 6, -- 资源不足情况下跳转
--
--}

--特殊道具id
--SpecialItemId =
--{
--    ITEM_MOVE_RANDOM = "200001",--随机迁城
--    ITEM_MOVE_CITY = "200002",--高级迁城
--    --ITEM_FREE_MOVE_CITY = 200005,--免费迁城
--    ITEM_ALLIANCE_CITY_MOVE = "200005",--联盟迁城
--    ITEM_BLACK_DESERT_CITY_MOVE ="200003",--黑土地迁城
--}

--EnumItemId = {
--    Heart = 301042,--爱心
--}

--MoveCityUseItemIds =
--{
--    --SpecialItemId.ITEM_FREE_MOVE_CITY,
--    SpecialItemId.ITEM_MOVE_CITY,
--}

--兵种类型
---@class ArmType
--ArmType =
--{
--    Tank = 1,--坦克兵种
--    Robot = 2,--机器人兵种
--    Plane = 3,--飞机兵种
--    Type4 = 4,
--    Type5= 5,
--}

--收资源建筑气泡状态
--BuildGetResourceState =
--{
--    No = 1,--不显示
--    Add = 2,--正在增长
--    Full = 3,--满了
--}

--QuestType =
--{
--    Main = 1,--主线任务
--    Chapter = 2,--章节任务
--    Daily = 3,--日常任务
--    PVE = 9,--关卡任务
--    PveAct = 11,--关卡活动任务
--    RalyyBoss = 202,--进击的巨人
--    JeepAdventure = 203,--pve悬赏任务
--    SeasonChapter = 99,
--}

--UIMainLeftBottomState =
--{
--    WarningBall = 1,--显示消息求
--    RewardQuest = 2,--显示可以领奖的任务
--    ChatAndQuest = 3,--任务和聊天切换
--    OnlyChat = 4,--只显示聊天
--    radarAlarm = 5, --显示警报
--    ChapterReward = 6,--章节礼包领奖
--    AllianceWar = 7,--联盟战争
--    Quest = 8,--任务
--    --HeroStation = 9,--英雄驻扎
--    RedPacket = 10,--红包
--    AllianceTaskShare = 11,--联盟任务分享
--    BubbleQuest = 12,
--}

--UIMainShowTextType =
--{
--    Quest = 1,
--    Chat = 2,
--    radarAlarm = 3,
--    RedPacket = 4,
--}

--UIMainLeftBottomType =
--{
--    WarningBall = 1,--消息求
--    Quest = 2,--任务
--    Chat = 3,--任务
--    radarAlarm = 4, --雷达警报
--    AllianceWar = 5,--联盟战争
--    HeroStation = 6,--英雄驻扎
--}

---@class CityManageBuffType
--CityManageBuffType =
--{
--    CityFever = 100001, -- 城市狂热
--    WarGuard = 100002, -- 战争守护
--    GolloesFever = 100003,--咕噜狂热
--    GolloesGuard = 100004,--咕噜守护
--    DirectAttackCity = 100005, -- 奇袭
--    AlCompeteScoreAdd1 = 100006,--联盟军备积分加成1
--    AlCompeteScoreAdd2 = 100007,--联盟军备积分加成2
--}
--CityWarFeverStatu = -- 城市狂热等级 staus表中配置，配置更改这里也要更改
--{
--    CityWarFeverMin = 500172,
--    CityWarFeverMax = 500192,
--}

--DetectNpcCityEvenColorImage = {
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_grey02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_green02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_blue02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_purple02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_gold02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_orange02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_orange02.png",
--}

--DetectHelpEventColorImage = {
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_grey03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_green03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_blue03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_purple03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_orange03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red03.png",
--}

--DetectEvenColorImage = {
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_grey.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_green.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_blue.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_purple.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_orange.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red.png",
--}
--DetectEvenColorSpecialImage = {
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_grey04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_green04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_blue04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_purple04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_orange04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red04.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_red04.png",
--}

--DetectEventCompleteImage = {
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_light01s.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_light01.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_light02.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_light03.png",
--    "Assets/Main/Sprites/UI/UIRadarCenter2/Detect_event_light04.png",
--}

--DetectEventState = {
--    DETECT_EVENT_STATE_NOT_FINISH = 0, --未完成
--    DETECT_EVENT_STATE_FINISHED = 1, --已完成未领奖励
--    DETECT_EVENT_STATE_REWARDED = 2, --已领奖
--}

--ScoutReportVisibleState = {
--    DEFAULT = 0,
--    ENABLE = 1,
--    DISABLE = 2,
--    NOT_MATCH = 3,
--}

--建造队列获取方式
--BuildQueueUnlockType =
--{
--    Unknown = 0, --未知
--    Build = 1, --建筑解锁
--    Gift = 2, --礼包购买
--    Talent = 3, --天赋解锁
--    Mastery = 4, --专精解锁
--    Favorability = 5, --美女好感度
--}

--AnimalQIdToAreaId = {}
--AnimalQIdToAreaId[1] = 5
--AnimalQIdToAreaId[2] = 1
--AnimalQIdToAreaId[3] = 3
--AnimalQIdToAreaId[4] = 7
--AnimalQIdToAreaId[5] = 9

--坐标类型
PositionType =
{
    World = 1,--世界坐标
    Screen = 2,--屏幕坐标
    PointId = 3,--坐标id
}

--ArrowType =
--{
--    Normal = 0,
--    Monster = 1,--指示野怪
--    Capacity = 2,--指示仓库里面的cell
--    Building =3, -- 指示建筑
--    Guide_Garbage = 4, --新手期间垃圾
--    BuildBox = 5,--建筑升级盒子
--    Farm = 6,--农田
--    Factory = 7,--工厂新队列
--    Chapter = 8,--章节任务
--    PlayerLevel = 9,--玩家等级
--    LackResource = 10,--升级界面缺少资源
--    ChapterGetReward = 11, --章节任务领奖触发
--    WaitTimeChapter = 12, --等待时间过长提示章节
--    WaitTimeChapterNew = 13,--等待时间过长提示任务
--    LandLock = 14,--解锁地块
--    CollectMoney = 15,--指向金矿
--    PveMonsterArrow = 16, -- PVE Monster
--    BuildBubble = 17, -- 建筑气泡
--    BuildBtn = 18, -- 建筑按钮
--    MonsterToLevel = 19, -- 大富翁地块
--    DetectTalkWorld = 20, --雷达城外对话建筑
--    PoliceInsigniaOutUpFinish = 21, -- 警徽建筑跳转，建筑礼盒状态
--    MonsterToLevel_Dog = 22, -- 大富翁地块(美女任务触发，不显示手指，光圈闪烁一次就消失)
--    SmallHero = 23, -- 小人头顶气泡
--}

--DetectEventType = {
--    DetectEventTypeSpecial = 1,
--    DetectEventTypeNormal = 2,
--    DetectEventRadarRally = 5, -- 雷达集结活动
--    DetectEventPickGarbage = 6, -- 纯前台行军表现的捡垃圾
--    DetectEventPVE = 7,
--    DetectEventTypeBoss = 8,
--    HeroTrial = 9,--英雄试炼时间
--    SPECIAL_OPS = 10,--10 特别行动
--    SWEEP_FIELD = 11,--11 扫荡地块
--    OCCUPY_FIELD = 12,--12 占领地块
--    GUIDE_PVE_LEVEL = 13,--引导关卡船
--    GUIDE_MONSTER = 14,--引导大野怪（胡蒂尔)
--    DetectTalkCity = 16, --内城雷达任务
--    DetectTalkWorld = 17, --外城雷达任务
--    PLOT = 18, --剧情对话
--    HELP = 19, --帮助
--    RESCUE = 20, --救援
--    COLLECT = 21, --采集
--    NPC_CITY = 22, --虚拟玩家
--    ALLIANCE_TREASURE = 23, --联盟宝箱
--    DetectEvent_SevenDay = 24, -- 七日活动
--}

--DetectEventQualityImage = {
--    [DetectEventType.SPECIAL_OPS]          = DetectEvenColorSpecialImage,
--    [DetectEventType.HELP]                 = DetectHelpEventColorImage,
--    [DetectEventType.NPC_CITY]             = DetectNpcCityEvenColorImage,
--    [DetectEventType.DetectEvent_SevenDay] = DetectEvenColorSpecialImage,
--    [-1]                                   = DetectEvenColorImage,
--}

--引导触发方式
--GuideTriggerType =
--{
--    None = 0,--无
--    Quest = 1,--任务领奖触发
--    UIPanel = 2 ,--打开界面时触发
--    Plot = 3,--剧情触发
--    Queue = 4,--队列完成触发
--    OwnQueue = 5,--第一次获得队列时触发
--    CityGarbage = 6,--捡完垃圾触发
--    OpenFog = 7,--解锁迷雾触发
--    BuildUpgrade = 8,--升级完建筑触发 建筑id，等级；第几个（大于等于等级）
--    QuestGoto = 9,--任务跳转触发
--    ChapterQuestCanReward = 10,--可领章节任务奖触发
--    QuestTriggerBuild = 11,--任务引导建筑建造（无限次触发，下线上线不引导）
--    FirstJoinAlliance = 12,--第一次加入联盟引导
--    TaskFinish = 13,--任务完成触发
--    NoFreeQueue = 14,--没有空闲队列
--    ChapterQuestAfterReward = 15,--章节任务领奖触发
--    OpenSpecialPanel = 16,--用于加工厂，不同建筑打开同意界面的情况
--    ResourceItemFull = 17,--资源仓库已满
--    MonsterGetReward = 18,--领取怪物奖励
--    PickUpGarbageItem = 19,--捡垃圾获得物品触发
--    QuestFarmUpgrade = 20,--任务农场种植农庄等级不够去升级触发
--    AllianceAutoMoveCity = 21,--加入联盟自动迁城触发
--    MoveToWorldJoinAlliance = 22,--主城迁到世界自动加盟引导
--    CityTroopFightMonsterTip = 23,--主城内没有车库时拖动到怪物升上出现提示对话
--    SubmitGolloesOrder = 24,--交付咕噜营地的订单
--    FactoryProductStart = 25,--开始加工产品触发
--    FarmPlantStart = 26,--农田开始种植农作物触发
--    BuildUpgradeStart = 27,--开始升级建筑触发
--    BusinessNoSubmit = 28,--超市界面，没有订单可以交付时触发
--    NeedConnect = 29,--需要连路触发引导
--    PlayerLevel = 30,--玩家等级达到后触发
--    Science = 31,--成功收取科技
--    FactoryCanUnlock = 32,--打开加工厂界面产品已解锁触发
--    ClickBubble = 33,--点击气泡触发
--    UseHeroExp = 34,--使用英雄道具引导
--    MarchHeroQuality = 35,--上阵高品质英雄引导
--    GetNewAnim = 36,--获得新动物触发
--    TreatSoldier = 37,--有伤兵触发
--    ShowNewQuest = 38,--出现新任务触发
--    ClearAllianceMember = 40,--清理不活跃玩家触发引导触发
--    FinishBattleLevel = 41,--完成关卡回到主城/世界 触发引导
--    ClickLandLock = 42,--点击地块/地块气泡时触发
--    PveEnterBattle = 43,--pve进入战斗触发
--    PveShopBuyItem = 44,--pve商店成功购买一次道具触发
--    LandLockRewardSoldier = 45,--地块解锁获得士兵
--    BackCityAfterRecruit = 46,--招募英雄后，返回到主城内，触发引导
--    ClickRocketLaunch = 47,--完成火箭订单后，点击提交按钮后，触发引导
--    PveOwnRes = 48,--pve拥有资源大于等于配置数量后触发
--    LandLockReceiveReward = 49,--地块解锁获得奖励弹出触发
--    StartScience = 50,--开始研究科技触发
--    ClickRadarMonster = 51,--点击雷达怪触发
--    ClickHeroRecruit = 52,--点击招募按钮触发
--    HeroEntrustComplete = 53,--英雄委托点击最后一次提交按钮
--    PrologueStartMove = 54,--序章开始移动3秒后触发
--    PveEndBattle = 55,--pve战斗结束触发
--    ResourceLackShowGoto = 56,--资源不足，显示关卡跳转时触发
--    ClickMonster = 60,--点击野怪触发
--    ClickPveBackBtn = 61,--点击Pve返回按钮触发引导
--    UIBuildUpgradeLackResource = 62,--升级界面，升级条件不满足，则触发引导
--    EnterPve = 63,--进入pve触发
--    OpenBuyBuffShop = 64,--打开购买buff商店界面
--    PveEnterSubmitResource = 65,--pve踩到交资源白块触发
--    PveStaminaZero = 66,--pve当体力为0时触发
--    OpenActivityPanel = 67,--打开活动页面触发
--    BuildWarmHoleCross = 68,--造虫洞触发
--    DefendWall = 69,--被攻击触发
--    OpenBuildUpgrade = 70,--打开升级界面触发引导
--    BagFullInPve = 71,--在pve中背包满了
--    UIPlaceBuild = 72,--在预放置建筑界面内，准备放下某建筑时触发
--    PrologueOwnNum = 73,--序章背的资源大于等于配置数量时触发
--    PlaceBuild = 74,--放建筑触发
--    ClickWorldCollectPoint = 75,--点击世界上资源点触发
--    ClickResItemUse = 76,--点击资源道具使用没有所需时触发(每次都触发)
--    FightLevelLackPanel = 77,--打怪条件不足触发
--    UIBuildUpgradeEveryLackResource = 78,--升级界面，升级条件不满足，每一个不满足都触发引导
--    PveBattleShowResult = 79,--pve战斗结束弹出结果面板触发
--    ClickBagFullBtn = 80,--点击仓库已满tips按钮触发
--    LandLockReward = 81,--地块解锁获得奖励触发
--    TaskToUpgradeView = 82,--任务跳转升级界面触发
--    AfterCityDomeExpend = 83,--大本扩苍穹表现播放完触发引导
--    OpenUIPVEMonument = 84,--打开矿洞探险页面触发引导
--    SeasonLogin = 85,--赛季登录触发引导
--    ClickAttackDesert = 86,--赛季点击占领按钮触发
--    ClickNoConnectAttackDesert = 87,--赛季点击与自己或盟友不相邻的空地占领按钮触发
--    ClickOutValueDesertTile = 88,--赛季点击辐射值大于抗性值地块触发
--    OwnDesert = 89,--占领配置个配置等级地块后触发
--    ClickDesertCity = 90,--点击遗迹城触发：我方/敌方/无主
--    ClickMarchNeedChangeHero = 91,--点击行军弹出替换英雄提示触发
--    OpenHeroListPanel = 92,--打开英雄界面特殊触发
--    BuildAllianceFlag = 93,--造联盟旗帜触发
--    ClickAttackGuideMonster = 94,--点击攻击引导雷达怪触发
--    GotoBuildAllianceCenter = 95,--造联盟中心
--    WaitRallyTeamMarch = 96,--点击排队中飞碟
--    ClickProtectThrone = 97,--点击保护中的王座
--    ClickWarThrone = 98,--点击争夺中的王座
--    
--    PrologueCityUnlock = 100,--序章交完材料触发引导
--    PrologueErrorGuide = 110,--序章出现错误导致卡死，触发
--    EnterBridge = 111,--进入修桥关触发
--    ExitBridge = 112,--退出修桥关触发
--    BridgeClickStart = 113,--修桥玩家点击开始
--    BridgeStageMoveEnd = 114,--切换小关卡 镜头移动结束
--    BridgeFinishInScene = 115,--造桥关卡通关（还在造桥关，如果触发引导不退出造桥）
--    RocketBombCanClickReward = 120,--拆弹界面可以领取奖励触发
--
--    SeasonPrologueFinish = 162,--赛季开场表演结束
--    SeasonDesertFull = 163,--赛季占领地块满了触发 参数是赛季id
--    SeasonPrologueToWorld = 164,--赛季开场表演到世界
--    ClickSeasonDesertLevel = 165,--（特殊触发）点击大于等于配置等级的矿点触发
--    OwnDesertType = 166,--占领配置个配置等级配置类型的地块后触发
--    ClickAttackDesertFullGetMore = 167,--点击攻击按钮，地块满了，弹出获得更多触发
--    
--    Login = 200,--登录触发检测是否保存引导id
--    BuildModel = 201,--进入建筑建筑模式时候触发
--    Trigger = 202, -- RPG模式进入与某个trigger交互时触发
--    Debug = 203, -- RPG模式出现负面状态气泡时触发
--    Talent = 204, -- 解锁某个天赋时触发
--    NewItem = 205, -- 获得某个道具时触发
--    LMPlayerLevel = 206, -- 玩家角色升级至x级时触发
--    LMPlayerBlood = 207, -- 主角血量小于等于X时触发
--    LMZombieDead = 208, -- ZombieDead
--    UnlockNewFunction = 209, -- 解锁新功能
--    ZombiesProgress = 210, -- 消灭丧尸进度达到X触发
--    QuestShow = 211, -- 任务在主UI左边展示
--    PveBattleShowWin = 212,--pve战斗弹胜利界面触发
--    PveBattleWinExit = 213,--pve战斗胜利界面点退出后触发
--    DetectNpcOK = 215,--雷达对话完成
--    NpcGirNewViewClose = 216, --美女对话
--    FenceUnlockFinish = 217, --某个地块解锁（围栏动画结束）
--    NpcGirNewViewPicClose = 218, --美女照片界面关闭
--    GoRallyBossAct = 219, --危机四伏->前往发起组队
--    FastCombat = 220, --快速战斗(跳过)
--    OnHeroDieInBattle = 221, --某关卡内死亡一个英雄时触发，triggerpara=关卡id
--    ReceiveLandReward = 222, -- 大富翁关卡奖励回调触发
--    BuildChangeToBox = 223, -- 建筑转为箱子状态
--    TimeCompeGetReward = 224, --限时比赛排行榜获得奖励
--    TimeCompeBtnShow = 226, --限时比赛按钮出现
--    GarbageTriggerFinished = 227,--宝箱领取完毕后触发
--    ClickRadarEvent = 228, -- 点击前往打开雷事件的达按钮,打开页面时
--    SelectActivityListItem = 229, -- 选中活动中心ListItem
--    NewHero = 231, -- 获得某个英雄时触发
--    DetectEventFinish = 233, -- 领取某个类型的雷达奖励触发
--    OnClickWorldAllianceCity = 234, -- 点击联盟城市
--    
--    BuyGift = 235, -- 购买某个礼包
--    ExitFromArena = 236,--从竞技场退出
--    ReplaceTrialHero = 237,--替换橙色试用英雄
--    
--    HeroEquippedGet = 238, -- 获得英雄装备
--
--    UIAircraftMainPreviewClose = 239, --改装车改装完成后的动画界面关闭
--    BarrelCarEnter = 240, --改装车出场
--    
--    MineCaveEnter = 241, -- 进入矿洞
--    DetectEventBarrelPveExit = 242, -- 雷达pve退出
--}

--引导跳转类型
--GuideGoType =
--{
--    None = 0,--无
--    Build = 1,--建筑
--}

--引导类型(强/软)
--GuideForceType =
--{
--    Soft = 0,--软引导
--    Force = 1,--强引导
--}

--引导对话NPC位置
--GuideNpcPosition =
--{
--    Left = 1,--左侧
--    Right = 2,--右侧
--}

--Runtime_Mode = {
--    Editor = 1,
--    RunTime = 2,
--}

--引导类型
GuideType =
{
    None = 0,--无
    ClickButton = 1,--点击按钮
    ShowTalk = 2,--对话
    ClickBuild = 3,--点击建筑(按照：建筑->npc->trigger的顺序查找)
    BuildPlace = 4,--建筑建造
    BuildRoad = 5,--造路
    PlantFarm = 6,--农场种植
    GetFarm = 7,--农场收获
    QueueBuild = 8,--跳转队列所在建筑
    PlantAnimal = 9,--牧场饲养鸵鸟
    Factory = 10,--加工厂加工
    Bubble = 11,--气泡
    CityGarbage = 12,--空投垃圾点
    GotoMoveBubble = 13,--点击垃圾点和迷雾弹出确认前往的气泡
    OpenFog = 14,--迷雾
    CityGarbageResultShow = 15,--捡垃圾结果展示引导
    DragCityTroop = 16,--拖拽城市行军
    PlayMovie = 17,--播放timeline剧情
    WaitMovieComplete = 18,--等待timeline剧情播放结束
    ClickQuest = 19,--点击任务
    WaitPlaceBuilding = 20,--等待建筑放置
    WaitTroopArrive = 21,--等待行军到达目标点
    WaitGarbageTroopMoveLeft = 22,--等待行军到达目标点剩余距离ClickBuildFinishBox
    WaitCloseUI = 23,--等待UI关闭
    ClickBuildFinishBox = 24,--点击建筑完成的箱子
    WaitMessageFinish = 25,--等待服务器消息回来
    ShowBlackUI = 26,--显示黑屏文本
    MoveCamera = 27,--镜头移动
    ClickTime = 28,--点击时间条加速按钮
    CloseAllUI = 29,--关闭所有UI
    ShowUIGuideGrow = 30,--打开播放动画界面（种土豆）
    SetRecommendShow = 31,--设置指向土豆建筑的参数
    UnlockBtn = 32,--解锁按钮
    ShowTroopTalk = 33,--显示右下角人物对话
    ShowGuideTip = 34,--显示引导tip说明
    PlayEffectSound = 35,--播放音效
    ShowChapterAnim = 36,--显示章节动画页面
    ClickQuickBuildBtn = 37,--点击主UI快速建造按钮
    StopAllEffectSound = 38,--停止所有引导加载的音效
    ClickMonster = 39,--点击野怪
    ClickTimeLineBubble = 40,--点击气泡后开始timeline
    ClickCityPointType = 41,--点击垃圾奖励的气泡
    ShowBuildRoadAnim = 42,--显示修路动画
    ClickGolloesCanSubmitOrder = 43,--点击咕噜订单中可交付的订单
    DoUIMainAnim = 44,--做uimain动画
    ClickRadarBubble = 45,--指向雷达特殊气泡
    ClickUISpecialBtn = 46,--指向UI上有button组件，但是有选择条件的按钮
    ShowAllianceCityEffect = 47,--显示周围盟友的特效
    WaitQuestionEnd = 48,--等待答题结束
    WaitTime = 49,--等待时间然后做下一步
    FakeQuest = 50,--添加一个任务提示
    ShowCommunicationTalk = 51,--通讯界面
    ClickLandLockBubble = 52,--指向地块解锁的气泡
    ClickCollectResource = 53,--点击矿根
    CollectUISpecialGuide = 54,--采集出征界面特殊引导
    ClickLandLockRewardBox = 55,--点击地块解锁后箱子奖励
    SetLandLockBubbleVisible = 56,--设置地块气泡显示/隐藏
    PveShowYellowArrow = 57,--pve中显示黄色箭头
    PveShowBattleSpeedBtn = 58,--pve显示战斗加速按钮
    PveShowBattleFinishBtn = 59,--pve显示战斗直接完成按钮
    PveShowBattlePowerLight = 60,--pve显示战斗兵力高亮引导
    ShowUIBlackChangeMask = 61,--显示过渡动画
    PveShowBattleBloodLight = 62,--pve显示血条高亮引导
    PveHideYellowArrow = 63,--隐藏所有黄色箭头
    WaitMarchFightEnd = 64,--等待行军战斗结束，期间镜头一直锁定在行军车上
    ClickRadarMonster = 65,--点击雷达怪
    OpenSelectQuestionPanel = 66,--弹出选择成为盟主答题界面
    NoNpcTalk = 67,--弹出旁白界面
    ShowFakeHero = 68,--展示假英雄
    ClickMonsterReward = 69,--点击任意一个野怪箱子
    SetAttackSpecialStateFlag = 70,--引导设置出征特殊状态
    WaitPanelOpen = 71,--等待界面打开（加载完）
    LandLockChangeModel = 72,--设置地块的显示模型显示
    SetBubbleShow = 73,--设置所有气泡显示/隐藏
    AlliancePanelGuide = 74,--联盟界面特殊引导  
    DoQuestJump = 75,--任务跳转  
    CheckBecomeAllianceLeader = 76,--检测是否能成为盟主
    ShowLoadMask = 77,--出世界/联盟迁城遮罩
    SetShowLandLock = 78,--设置指定地块隐藏/显示
    ChangeBgm = 79,--改变Bgm
    ChangeBgmVolume = 80,--修改Bgm音量
    WaitGolloesArrived = 81,--等待咕噜探索到达，期间镜头一直锁定在咕噜行军
    SetRadarMonsterVisible = 82,--隐藏/显示世界雷达怪
    SetCityPeopleAndCarVisible = 83,--隐藏/显示城内车和行人
    WaitBackCity = 84,--等待从pve返回到主场景
    PveSkillVisible = 85,--旋风斩按钮显示/隐藏
    PveShowStaminaLight = 86,--pve显示血条高亮引导
    SetPveStaminaNpcVisible = 87,--控制买体力小人显示/隐藏
    FullPveSkill = 88,--一键加满旋风斩能量
    ClickPveTriggerBubble = 89,--引导手指指向pve触发点气泡
    WaitPveEnterComplete = 90,--等待pve进入loading结束
    SetPveBuyBuffShopEffectActive = 91,--pve购买buff商店页面黑色遮罩显示/隐藏
    SetPveStopRefreshStamina = 92,--pve设置停止刷新体力
    SetPveNoClickStamina = 93,--pve设置不能点击体力条
    OpenHeadTalkPanel = 94,--打开头像对话页面
    CloseHeadTalkPanel = 95,--关闭头像对话页面
    SetPveBagGuide = 96,--pve背包引导
    HeroAdvanceGuide = 97,--英雄晋级引导
    SetHeroAdvanceGuideHeroVisible = 98,--英雄晋级引导晋级英雄置黑
    SetHeroAdvanceGuideSubHeroVisible = 99,--英雄晋级引导海报英雄置黑
    SetAllVisible = 100,--隐藏所有UI（界面ui，女npc的每日任务，格鲁的修理气泡，建筑气泡，问答小人气泡）
    -- 砍伐相关
    PrologueShowBuild = 101,--引导序章显示建筑，1坐标，2名称，3动画，4idle动画
    PrologueShowTrigger = 102,--引导序章显示流程点
    PrologueUnlockFog = 103,--引导序章解锁迷雾
    PrologueShowNpc = 104,--引导序章显示NPC
    PrologueShowNoMovePoint = 105,--引导序章显示阻挡的格子
    PrologueShowSetManPosition = 106,--在pve控制主角 在序章控制小人 para1 调位置  para2填 旋转  都可以不填
    Wastelan_Guide = 107, -- 开荒
    Prologure_CarryingFlag = 108, -- 人物扛旗
    Prologure_PlantFlag = 109, -- 人物插旗
    Wastelan_ResetManState = 110,  -- 还原小人状态
    ShowUIWindow = 111,  -- 显示UI界面
    Wastelan_ShowFarm = 112, -- 显示农田

    Wastelan_ShowNpcTalk = 113,  --显示Npc对话
    Wastelan_HideNpcTalk = 114,  --关闭Npc对话
    Wastelan_GuideNpcTalk = 115,  --引导中Npc对话 需点击屏幕任意位置关闭
    Wastelan_ShowYellowArrow = 116,  --场景内出现黄色箭头
    Wastelan_CheckFarmArrow = 117,  --开启农田箭头条件检查 <----> 农田状态改变时关闭检查

    Wasteland_ShowTank = 118, --控制坦克显示和移动
    Wasteland_ShowMonster = 119, -- 控制怪物显示
    Wasteland_AttackDone = 120, -- 发射炮弹.同时干掉怪物
    Prologure_ManJump = 121,  -- 小人播放跳跃动画
    PrologueHideNpc = 122,--引导序章删除NPC
    PrologueManRotation = 123,--引导序章太空人旋转
    PrologueAddOneSpaceMan = 124,--引导序章增加一个太空人
    PVEFinishOneTrigger = 125,--引导关卡完成一个触发点
    PrologueSubmitTrigger = 126,--序章上交所有材料
    PVESetTriggerVisible = 127,--pve隐藏/显示触发点
    ShakeCamera = 128,--晃动相机
    SetWoundedBubbleVisible = 129,--隐藏/显示格鲁的修理气泡
    ClickWoundedCompensateBubble = 130,--引导手指指向pve伤兵爆仓气泡
    SetGuideQuestVisible = 131,--引导期间任务气泡弹出/不弹出
    ShowCurtain = 132,--引导期间任务气泡弹出/不弹出
    UIBuildListSpecial = 133,--建造列表特殊的引导
    BackBuildCollectTime = 134,--特殊处理让银行获得金币
    SetHeroAdvanceMaskVisible = 135,--隐藏/显示英雄升星遮罩
    SetPveOutBagGuide = 136,--pve爆仓引导黑色遮罩
    SetQuestCanShowInGuide = 137,--主界面任务可以在引导中显示
    OpenPanel = 138,--打开页面
    UIScrollToSomeWhere = 139,--当前打开界面滑动到指定位置
    ShowJumpBtn = 140,--timeline显示跳过按钮
    BlackHoleMask = 141,--通用黑色扣洞遮罩
    UIPathArrow = 142,--通用ui上黄色箭头
    BuildCanDoAnim = 143,--建筑做动画
    ShowNewHero = 144,--展示一个新英雄
    SetWorldArrowVisible = 145,--控制世界上箭头显示
    ShowWorldArrow = 146,--显示黄色箭头
    
    ShowRocketBombTime = 159,--炸弹倒计时

    DoEndGuideCallBack = 196,--如果有需要再引导结束才弹出的页面就立刻弹出（目前用在在引导中间弹出奖励）

    FormationAutoAddHero = 225,--给一个车库自动上英雄
    
    ShowOverheadDialog = 501, --头顶对话
    ClickBagItem = 502, --点击背包内的道具
    MistressTalk = 503, --美女养成对话
    ShowSUMainDialog = 504, --主界面提示对话
    -- 505 
    -- 模式一：弹出全屏带背景的界面,上面为一个dialog,逐字弹出
    -- para1:dialog，para2:背景
    -- 模式二：弹出全屏带背景的过渡界面
    -- para1:空(如果不为空，那就默认变为模式一)，para2:背景，para3:自动next，para4:延迟skip按钮显示
    -- 过渡界面就是为了防止穿帮，所有必要时会延迟关闭
    ShowFullScreenDialog = 505, 
    MoviePrologue = 506, -- 电影序幕式的全屏语言对话
    Movie = 507, -- 电影
    MovieCurtain = 508, -- 电影幕布
    FullBlackBG = 509, -- 全屏黑幕
    GroundHint = 510, --地面文字指示

    IntroBubble = 511,--介绍气泡
    MoveBagViewItem = 512,--界面移动
    IntroBubble1 = 513,--介绍气泡
    SkyTime = 514,--1：进入黎明；2：进入白天；3：进入黄昏；4：进入黑夜。5：进入正常循环
    ShowSLGArea = 515,--SLG模式箭头
    PicGuide = 516,--配图引导，c_guide_pic
    ShowUIByPath = 520, -- 通过UI路径，隐藏/显示某个UI
    ShowPlantarArrow = 521, -- 控制任务指引的动态箭头显隐
    SetHungerOrThirsty = 522, -- 设置饥饿度or饥渴度
    WalkieTalkie = 523,-- 对讲机
    PlayRoleAnim = 524,-- 角色播放动作
    ShowTalk2 = 525,--对话
    ShowOverheadDialog1 = 526, --头顶对话(点击屏幕doNext)
    GuideSetPlayerMoveState = 528,--para1：人物状态，1=佝偻走 para2：1设置变为该状态，2取消该状态
    SU_MovePlayerToRelativePos = 529, -- 移动角色到相对坐标
    SU_WearCloth = 530, -- 穿指定衣服
    Blueprint = 531, -- 打开蓝图制作指定道具
    PlayerIdle = 532, --玩家闲置/触碰空气墙
    NewInformation = 534, -- 获取到新信息后的弹板(新道具，建筑升级什么的)
    ClickButtonNew = 535, -- 点击按钮(新的手指光圈特效)
    SU_ActiveMainUI = 536, -- 显示隐藏主UI
    ActiveNpc = 537, -- 显示隐藏Npc
    LensBlackEdge = 538, -- 电影镜头黑边
    ChangeViewMode = 539, -- 切换镜头
    SU_AddEvent = 540, -- 添加Event
    WalkieTalkie1 = 541,-- 对讲机(不带左边对讲机动画)
    CameraLerpSet = 542, --插值设置相机参数

    
    ShowFadeBlack = 545, --渐变显示黑幕
    SU_ChangeLevel = 546, -- 跳转到指定关卡
    SU_ShowNewHero = 547, -- 展示获取新英雄
    SU_UnlockNewFunction = 548, -- 解锁新功能
    ClickRecycleItem = 549, --点击回收站的道具
    PveMonsterArrow = 550, --PveMonster显示箭头
    AttackPveMonster = 551, --直接进入PVE战斗
    BA_UpgradeBuild = 552, -- 升级指定建筑
    
    SimpleMoveCameraToPos = 556,--镜头移动
    BA_StopZombieWave = 557, -- 结束丧尸来袭
    BA_ZombieKickDoor = 558, --丧尸拍门
    OpenGiftPack = 559, -- 打开礼包
    MoveCameraAndShowTalkBubble = 560, -- 移动镜头并显示带头像的聊天气泡
    ShowBoxBubble = 561, -- 引导中的一些辅助气泡，比如附加在警徽上，或者单独存在显示缺少子弹什么的
    MoveRolePartnerMove = 562, -- 让主角编队中指定的角色移动
    
    FenceChangeToIntact = 563, -- 内城围栏从破损状态变为完整状态
    MapObjectPveRoutePlayAnim = 564, -- 大富翁警局门口播放动画
    MapObjectLLFirstPayReward = 565, -- 首充英雄引导汽车动画
    PoliceInsigniaShowOrHide = 566, -- 警徽气泡显示或者隐藏
    PoliceInsigniaPointer = 567, -- 指引警徽气泡点击
    PoliceInsigniaSubPointer = 568, -- 指引警徽气泡子建筑点击
    MapObjBuildFromRuinsToNormal = 569, -- 栅栏从破损状态切换至正常状态
    GoToMainCityArea = 570, -- 解锁地块
    DroneTimeline = 571, -- 无人机解锁动画
    LLHangUpBubble = 572, -- 挂机奖励气泡，比较特殊，不是通用的气泡
    TriggerOrNpcEventBubble = 573, --Trigger或NPC的气泡
    PlayLadyBubble = 574, -- 特指NPC头顶的播放视频气泡
    OpenBuildList = 575, -- 打开建造列表
    HangUpTimeline = 578, -- 播放挂机奖励小车Timeline
    HangUpTimelinePauseOrResume = 579, -- 挂机奖励小车Timeline暂停或者恢复
    HangUpBubbleShow = 580, -- 挂机奖励气泡显示
    PlaySound = 581, -- 播放声音
    TalkTaskObjBubble = 582, -- 对话任务类型，气泡
    TalkTaskBubbleShowOrHide = 583, -- 隐藏建筑上的对话事件气泡  1 隐藏 2显示
    SetLadyBubbleShow = 584,--设置美女气泡显示/隐藏
    TalkTaskNpcBubbleClick = 585, --点击npc头顶的对话气泡
    WaitFenceFinish = 586, -- 等待围栏落下结束
    OpenActivityCenter = 587, -- 活动中心内点击活动的页签
    GamePause = 588, --暂停关卡  para1=  1-暂停 2-继续
    AddHeroTrialHero = 589, --试用英雄加入队伍
    ShowTalk3 = 590,--索菲亚对话
    UnlockGirl = 591,--美女解锁
    
    ClickGarbageTrigger = 593, --点击盒子（使用队列）
    
    WaitPoliceInsigniaPanelReady = 594, -- 等待警徽升级子建筑界面准备完成
    
    PlayerTeamPlayAnimation = 595,--小队播放动作

    MainBuildGuide2 = 597, -- 大本播放引导第三步，播放第二段timeline
    ReconnectedMainBuildTimeLine = 598, -- 断线重连大本的Timeline 
    FakeMainBuildUpdate = 599, --假的建筑升级条
    WaitToClickBuildFence = 600, --等待点击修建围栏的下一步
    ResumeCurTimelinePlay = 601, -- 恢复Timeline播放
    BattleFrontGate = 602, -- 警局门前战斗
    ShowTalk4 = 603, --猫女对话
    SetPlayerTeamActive = 604, -- 隐藏或者显示主角队伍
    ShowGetPoliceView = 605, -- 展示建造大本到1级时的弹框
    ShowBossRunAway = 606, -- 展示Boss逃跑的UI
    ShowCameraBlackScreen = 607, -- 屏幕从黑到亮，或者从亮到黑，主相机
    ShowDogItem = 608, -- 展示猫女道具
    ClickTrigger = 609, -- 点击场景中的Trigger
    StopTimeLineLoop = 610, -- 停止timeline某一时间段内的循环播放
    SetAreaActive = 611, -- 设置区域解锁的气泡和地块解锁特效的显示隐藏
    ShowLandLockView = 612, -- 显示隐藏UILandLockTipsView1
    ShowUIGetPolicewoman = 613, -- 展示女警UI
    ShowUIGuideGurtain = 614, -- 拉窗帘动画
    HideShowHud3d = 615, -- 显示隐藏hud3d层级
    LoveNewsletter_hero = 616,
    LoveNewsletter_heroStory = 617,
    CloseAllWindowAndGotoWorld = 618,--关闭所有UI，并去往大世界
    GotoWorldCityAndOpenUI = 619,--镜头移动至城市，展示信息面板
    LLFirstPayRewardBubble = 620, -- 指引点击首充英雄气泡
    Barrel_PauseOrResumeUnitAni = 621, --暂停、继续关卡内角色动画
    
    RadarScanningEffect = 622, -- 雷达扫描特效
    RadarCloudEffect = 623, --雷达云雾切换场景效果
    HideUIPVEScene = 624, --隐藏关卡内布阵界面
    ShowUISmallPeopleBook = 625, -- 展示小人获得的页面
    BonFireBoyResetToStart = 626, -- 重置小人到初始位置
    BonFireBoyPlayEnterAnim = 627, -- 小人开始跑
    OpenMailWithSpecialTab = 628, --打开邮件并选定页签类型
    AircraftMainToggleClick = 629, --改装车厂切换左边页签
    ClickHero = 630, --点击英雄
    LLVIPPayRewardBubble = 631, -- vip英雄气泡
    HideMainQuest = 632, -- 隐藏主ui任务栏
    LLFirstPayRewardBubbleShowState = 633, --隐藏或者显示主程首充气泡
    OpenActivityCenterTable = 634, -- 打开限时活动中心到对应的页签
    MoveWorldCameraToPosByDetectEvent = 635, -- 移动世界相机到雷达任务位置
    ShowSevenDayNewGuide = 636, -- 劳拉七日活动过场
    SaveReconnectionGuideId = 637, -- 保存断线重连guideId
    BossShowingTimeline = 638, -- boss登场timeline
    NetUnConnect = 1000,--测试类型，断线重连
}

--引导对话NPC位置
--GuideArrowStyle =
--{
--    Finger = 0,--手指
--    Yellow = 1,--黄色箭头
--    Green = 2,--绿色箭头
--    ClickCallAirDrop = 3,--快速点击召唤空投按钮
--    NOArrow = 4,--没有引导箭头
--}

--GuideArrowPositionStyle =
--{
--    Position_Down = 0,--箭头向下
--    Position_Up = 1,--箭头向上
--    Position_Right = 2,--箭头向右
--    Position_Left = 3,--箭头向左
--}

--GuideFingerPositionStyle =
--{
--    Position_Down = 0,  --手指在下
--    Position_Up = 1,    --手指在上
--    Position_Right = 2, --手指在右
--    Position_Left = 3,  --手指在左
--}

--SceneType =
--{
--    None = 0,
--    City = 1,
--    World = 2,
--    PVE = 3,
--}

CloseUIType =
{
    ClickWorld = 1,
    ClickUI = 2,
    DragWorld = 3,
}

CityPointType =
{
    Other = 0, --0 空地
    Garbage = 1,   --1 垃圾
    Monster = 2,   --2 野怪
    MonsterReward = 3, -- 野怪奖励箱子
    GarbageReward = 4, -- 垃圾奖励箱子
    LandLockReward = 5, -- 解锁地块奖励箱子

    Building = 100,--建筑
    Road = 101,--路
    Fog = 102,--迷雾
    LandLock = 103, -- 解锁地块
    Collect = 104, -- 矿根
    CollectRange = 105, -- 矿根周边
}

--OrderItemType = {
--    ORDER_ITEM_TYPE_RESOURCE_ITEM = 0,
--    ORDER_ITEM_TYPE_GOODS = 1,
--    ORDER_ITEM_TYPE_RESOURCE = 2,
--    ORDER_ITEM_TYPE_MONSTER = 3,
--    ORDER_ITEM_TYPE_SPECIAL_MONSTER = 4,
--}

--TroopActionType = {
--    TROOP_ACTION_TYPE_NULL = 0,
--    TROOP_ACTION_TYPE_ATTACK = 1,--有编队出征（打怪/打人/集结）
--    TROOP_ACTION_TYPE_GATHER_RESOURCE = 2,--有编队去采集
--    TROOP_ACTION_TYPE_FIGHTING = 3,--编队战斗（个人/集结）
--    TROOP_ACTION_TYPE_GET_REWARD = 4,--战斗结束/捡垃圾/采集获得奖励
--    TROOP_ACTION_TYPE_FIGHT_FAIL = 5,--战斗失败
--    TROOP_ACTION_TYPE_MARCH_RETURN = 6,--编队返回
--    TROOP_ACTION_TYPE_ALL_FREE = 7,--都在车库中
--    TROOP_ACTION_TYPE_UNSET_FORMATION = 8,--有未设置的行军队列
--
--    CITY_TROOP_ACTION_GROCERY_STORE_HINT = 20,--咕噜营地打怪提示
--    TROOP_ACTION_TYPE_RADAR_CENTER = 21,--雷达事件事件点击
--
--    CITY_TROOP_ACTION_CLICK_ON_HEAD = 201,--点击大聪明头像
--    CITY_TROOP_ACTION_COLLECT_GARBAGE = 202,--编队采完一次垃圾触发
--}

local EnumType = {

}

--设置中部队详情中tab
--TroopType =
--{
--    Total = 1,
--    Inside = 2 ,
--    Outside = 3 ,
--    Turret = 4 ,
--    Redif = 5,
--}

--PurchaseOrderType = {
--    PURCHASE_ORDER = 0,-- 商业订单 0
--    GROCERY_ORDER = 1,--杂货店订单 1
--    ENERGY_ORDER = 2,
--}

--商业订单状态
--PurchaseOrderState =
--{
--    NORMAL = 0, --0 正常状态
--    LOCKED = 1, --1 锁定状态
--    DELETE= 2, --2 删除状态
--    FINISH = 3,--完成状态
--}
--商业订单更新类型
--BusinessRereshType =
--{
--    InitOrderFinish = 0, --初始化订单
--    DeleteOrderFinish = 1, --删除订单
--    PurchaseOrderFinish = 2, -- 提交订单
--    ImmediateRefresh = 3, --钻石秒订单
--
--}

--连接方向（双向）
--ConnectDirection =
--{
--    TopToLeft = 1,
--    TopToDown = 2,
--    TopToRight = 3,
--    LeftToDown = 4,
--    LeftToRight = 5,
--    LeftToTop = 6,
--    DownToLeft = 7,
--    DownToTop = 8,
--    DownToRight = 9,
--    RightToTop = 10,
--    RightToLeft = 11,
--    RightToDown = 12,
--    Left = 13,
--    Right = 14,
--    Top = 15,
--    Down = 16,
--}
--城内攻击结果
CityFightResult =
{
    Success = 1,--成功
    Fail = 2,--失败
}


--城内捡垃圾结果
CityGarbageResult =
{
    None = 0,--没有奖励
    Reward = 1,--有
}

--VipPayGoodState =
--{
--    Lock = 1,
--    CanBuy = 2,
--    CanGet = 3,
--    HasGet = 4,
--}

--城内捡垃圾结果
--CityGarbageResultShowType =
--{
--    People = 1,--获得人
--    UseItem = 2,--带有使用按钮的物品
--    NoUseItem = 3,--没带有使用按钮的物品
--}


--GuidePlayMovieType =
--{
--    Farm = 1,--种土豆剧情
--    SavePeople = 2,--拔小人
--    Radar = 3,--获得雷达开迷雾
--    Wind = 4,--风车维修后运转
--    FightGetPeople = 5,--打沙虫获得第二个小人
--    GameStartRocketFall = 6, --火箭落地后，宇航小人儿先出舱；第一个小人跳起
--    WorkManJump = 7,--小人儿跳一圈
--    BuildBuilding = 8,--机器人飞出来，把箱子放到地上；摄像机右移1/3屏幕，机器人在火箭右边扫描出0级大本和道路和风车；
--    RocketFly = 9,--火箭起飞，卷起气浪，吹飞一个宇航小人儿和箱子，其他小人儿抱头蹲地上
--    ShowSandMonster = 10,--出现沙虫
--    BaseZeroUpgrade = 11,--大本0升1
--    ShowOstrichAnim = 12,--展示鸵鸟动画
--    MoveToWorld = 13,--主城去世界
--    ShowGarbage = 14,--空投
--    FarmWithoutTimeLine = 15,--不带timeline的种土豆
--    BusinessPlaneArrive = 16,--商业订单飞机降落
--    ShowBusinessBubble = 17,--显示商业订单气泡
--    --ShowMigrateScene = 18,--显示移民timeline
--    RadarShowAnim = 19,--雷达界面显示动画
--    ShowCowAnim = 20,--展示奶牛动画
--    ShowRobotScene = 21,--展示无人机出场动画
--    ShowBaseLight = 22,--亮灯动画
--    ShowChangeFarm = 23,--农田变换动画
--    FromMjBuildMainBuild = 24,--从民居出来修建大本
----    MainZeroUpgradeScene = 25,--大本新的0升1
--    --SecondMigrateScene = 26,--显示第二段移民timeline
--    --TilePlaneRuin = 27,--地块飞机坠毁
--    --SaveBobScene = 28,--解救Bob
--    --PirateFightBobScene = 29,--海盗船和Bob打架
--    --PirateComeScene = 30,--海盗船到来
--    --PirateAwayScene = 31,--海盗船离开
--    --PirateShowScene = 32,--海盗出现
--    RadarScanScene = 33,--雷达扫描动画
--    ShowFakePlayerFlag = 34,--查看假的敌人标志
--    ShowRadarBubble = 35,--显示雷达气泡
--    ShowWorldCollectPoint = 36,--显示/隐藏世界垃圾点
--    RadarWorldScanScene = 37,--世界雷达扫描动画
--    --PickUpWeaponScene = 38,--序章小人捡斧子
--    TankScene = 39,--坦克场景
--    FactoryShowFreeBtn = 40,--加工厂加速按钮显示成免费
--    PvePirateBoomScene = 41,--pve显示海盗船爆炸
--    ShowRadarMonsterScene = 42,--播放雷打怪出现动画
--    PveThreeBombs = 43,--pve降落3颗炸弹
--    PveDestroyHdc1 = 44,--pve摧毁海盗船1
--    PveDestroyHdc2 = 45,--pve摧毁海盗船2
--    PveDestroyHdc3 = 46,--pve摧毁海盗船3
--    PveMissileAttackMain = 47,--pve大本受到炮击
--    PveHdc1Attack = 48,--pve海盗船1开火
--    PveHdc2Attack = 49,--pve海盗船2开火
--    PveTurretTurn = 50,--pve炮台转向
--    PveDestroyMountain = 51,--pve摧毁山石
--    PveHdc3Attack = 52,--pve海盗船3开火
--    PveMissileInSky = 53,--pve空中飞炮弹
--    --GuluOutFromBaseScene = 54,--世界上咕噜从营地走出
--    --GuideTimeline2Scene = 55,--GuideTimeline2Scene
--    PveMorganAttack = 56,--摩根挥警棍
--    PveHdcEscape = 57,--pve海盗船逃跑
----    DefendWallScene = 58,--伤兵爆仓出现火焰
--    ShowEnemyAllianceCityEffect = 59,--显示敌对盟的特效
--    GuideTimeline3Scene = 60,--GuideTimeline3Scene
--    PveHdcEscape31014 = 61,-- 31014 海盗船逃跑
----    ConnectElectricityScene = 62,-- 通电动画
--    Chapter2CameraMoveScene = 63,-- 第二章播完章节图，镜头移动
--    HugLadyTimeline = 64,
--    SU_StartBorfire = 65, -- 篝火
--    ThreeBodyQTEInHomeTimeline = 66, --三人室内qte和timeline
--    FightOnBoardQTETimeline1 = 67,  --船上qte的timeline 第一种动画
--    FightOnBoardQTETimeline2 = 68,  --船上qte的timeline 第二种动画
--    HugLadyTimeline2 = 69, --第二种抱女士动画
--    SU_PlayerOutoffCar = 70, --角色下车
--    SU_ZombieChasePlayer = 71, -- 丧尸追赶角色
--    SU_PlayerDriveCar = 72, --角色进入车内准备开车
--    SU_ZombieMoveIntoCar = 73, --丧尸攻入车内
--    SU_PlayerOutOffDriveSeat = 74, -- 角色从驾驶座起来
--    SU_PlayerOpenCarDoor = 75, --角色打开车门
--    SU_OpenCarDoorInMainLevel = 76, --主城内开启房车车门
--    SU_ZombieChaseNew = 77, -- 新版丧尸追及
--    SU_PlayerPickUpCloth = 78, -- 捡衣服
--    SU_PlayerPickUpPapper = 79, -- 捡报纸
--    SU_PlayerPutdownAlbum = 80, -- 放相册
--    SU_NpcToBuild = 81, -- npc建造
--    
--    SU_NpcGetGunTimeline = 85, --大本完成子建筑升级后，小人进入大本拿枪
--    SU_BuildFence = 86, -- 小人建造栅栏
--    Su_BattleFrontGate = 87, -- 警局门口的战斗
--    SU_FenceZombieWave = 88, -- 栅栏的尸潮
--    SU_GoToTowerTimeline = 89, -- 出兵上塔Timeline
--    SU_BarrelBattlePolicewoman = 90, -- 女警在关卡中的
--    SU_BarrelReceptTrailHero = 100,
--    SU_BarrelBattlePolicewoman_1 = 105, -- 女警在关卡中的
--}

--标记(个人，联盟）
---@class MarkType
--MarkType = {
--    Special = 0,
--    Friend = 1,
--    Enemy = 2,
--    Alliance_Attack = 3,
--    Alliance_Sun = 4,
--    Alliance_LuckyClover = 5,
--    Alliance_6 = 6,
--    Alliance_7 = 7,
--    Alliance_8 = 8,
--    Alliance_9 = 9,
--    Alliance_10 = 10,
--    Alliance_11 = 11,
--    Alliance_12 = 12,
--    Alliance_Rally = 13, --集结
--    Alliance_Build = 14, --建筑, 暂时不要用,这个还没做
--    
--    Dragon_Attack = 20, --巨龙战场标记进攻
--    Dragon_Attack2 = 21, --巨龙战场标记进攻
--    Dragon_Attack3 = 22, --巨龙战场标记进攻
--    Dragon_Attack4 = 23, --巨龙战场标记进攻
--    Dragon_Attack5 = 24, --巨龙战场标记进攻
--    Dragon_Attack6 = 25, --巨龙战场标记进攻
--    Dragon_Attack7 = 26, --巨龙战场标记进攻
--    Dragon_Attack8 = 27, --巨龙战场标记进攻
--    Dragon_Attack9 = 28, --巨龙战场标记进攻
--    Dragon_Attack10 = 29, --巨龙战场标记进攻
--    
--    Dragon_Defend = 30, --巨龙战场标记防御
--    Dragon_Defend2 = 31, --巨龙战场标记防御
--    Dragon_Defend3 = 32, --巨龙战场标记防御
--    Dragon_Defend4 = 33, --巨龙战场标记防御
--    Dragon_Defend5 = 34, --巨龙战场标记防御
--    Dragon_Defend6 = 35, --巨龙战场标记防御
--    Dragon_Defend7 = 36, --巨龙战场标记防御
--    Dragon_Defend8 = 37, --巨龙战场标记防御
--    Dragon_Defend9 = 38, --巨龙战场标记防御
--    Dragon_Defend10 = 39, --巨龙战场标记防御
--    
--    Dragon_Retreat = 40, --巨龙战场标记撤退
--    Dragon_Retreat2 = 41, --巨龙战场标记撤退
--    Dragon_Retreat3 = 42, --巨龙战场标记撤退
--    Dragon_Retreat4 = 43, --巨龙战场标记撤退
--    Dragon_Retreat5 = 44, --巨龙战场标记撤退
--    Dragon_Retreat6 = 45, --巨龙战场标记撤退
--    Dragon_Retreat7 = 46, --巨龙战场标记撤退
--    Dragon_Retreat8 = 47, --巨龙战场标记撤退
--    Dragon_Retreat9 = 48, --巨龙战场标记撤退
--    Dragon_Retreat10 = 49, --巨龙战场标记撤退
--    
--    Dragon_Rally = 50, --巨龙战场标记集结
--    Dragon_Rally2 = 51, --巨龙战场标记集结
--    Dragon_Rally3 = 52, --巨龙战场标记集结
--    Dragon_Rally4 = 53, --巨龙战场标记集结
--    Dragon_Rally5 = 54, --巨龙战场标记集结
--    Dragon_Rally6 = 55, --巨龙战场标记集结
--    Dragon_Rally7 = 56, --巨龙战场标记集结
--    Dragon_Rally8 = 57, --巨龙战场标记集结
--    Dragon_Rally9 = 58, --巨龙战场标记集结
--    Dragon_Rally10 = 59, --巨龙战场标记集结
--}


--AllianceMarkName = {
--    [MarkType.Alliance_Attack] = "100150",
--    [MarkType.Alliance_Sun] = "391106",
--    [MarkType.Alliance_LuckyClover] = "391107",
--    [MarkType.Alliance_6] = "391108",
--    [MarkType.Alliance_7] = "391109",
--    [MarkType.Alliance_8] = "130066",
--    [MarkType.Alliance_9] = "390817",
--    [MarkType.Alliance_10] = "391110",
--    [MarkType.Alliance_11] = "391111",
--    [MarkType.Alliance_12] = "391112",
--    [MarkType.Alliance_Rally] = "391112",
--    [MarkType.Alliance_Build] = "391112",
--    
--    [MarkType.Dragon_Attack] = "722006",
--    [MarkType.Dragon_Defend] = "372281",
--    [MarkType.Dragon_Retreat] = "395201",
--    [MarkType.Dragon_Rally] = "860116",
--    
--    [MarkType.Dragon_Attack2] = "722006",
--    [MarkType.Dragon_Defend2] = "372281",
--    [MarkType.Dragon_Retreat2] = "395201",
--    [MarkType.Dragon_Rally2] = "860116",
--
--    [MarkType.Dragon_Attack3] = "722006",
--    [MarkType.Dragon_Defend3] = "372281",
--    [MarkType.Dragon_Retreat3] = "395201",
--    [MarkType.Dragon_Rally3] = "860116",
--
--    [MarkType.Dragon_Attack4] = "722006",
--    [MarkType.Dragon_Defend4] = "372281",
--    [MarkType.Dragon_Retreat4] = "395201",
--    [MarkType.Dragon_Rally4] = "860116",
--
--    [MarkType.Dragon_Attack5] = "722006",
--    [MarkType.Dragon_Defend5] = "372281",
--    [MarkType.Dragon_Retreat5] = "395201",
--    [MarkType.Dragon_Rally5] = "860116",
--
--    [MarkType.Dragon_Attack6] = "722006",
--    [MarkType.Dragon_Defend6] = "372281",
--    [MarkType.Dragon_Retreat6] = "395201",
--    [MarkType.Dragon_Rally6] = "860116",
--
--    [MarkType.Dragon_Attack7] = "722006",
--    [MarkType.Dragon_Defend7] = "372281",
--    [MarkType.Dragon_Retreat7] = "395201",
--    [MarkType.Dragon_Rally7] = "860116",
--
--    [MarkType.Dragon_Attack8] = "722006",
--    [MarkType.Dragon_Defend8] = "372281",
--    [MarkType.Dragon_Retreat8] = "395201",
--    [MarkType.Dragon_Rally8] = "860116",
--
--    [MarkType.Dragon_Attack9] = "722006",
--    [MarkType.Dragon_Defend9] = "372281",
--    [MarkType.Dragon_Retreat9] = "395201",
--    [MarkType.Dragon_Rally9] = "860116",
--
--    [MarkType.Dragon_Attack10] = "722006",
--    [MarkType.Dragon_Defend10] = "372281",
--    [MarkType.Dragon_Retreat10] = "395201",
--    [MarkType.Dragon_Rally10] = "860116",
--}

--LoadPath.AllianceMark
--AllianceMarkIconName = {
--    [MarkType.Alliance_Attack] = "UIAlliance_mark_03",
--    [MarkType.Alliance_Sun] = "UIAlliance_mark_04",
--    [MarkType.Alliance_LuckyClover] = "UIAlliance_mark_05",
--    [MarkType.Alliance_6] = "UIAlliance_mark_06",
--    [MarkType.Alliance_7] = "UIAlliance_mark_07",
--    [MarkType.Alliance_8] = "UIAlliance_mark_08",
--    [MarkType.Alliance_9] = "UIAlliance_mark_09",
--    [MarkType.Alliance_10] = "UIAlliance_mark_10",
--    [MarkType.Alliance_11] = "UIAlliance_mark_11",
--    [MarkType.Alliance_12] = "UIAlliance_mark_12",
--    [MarkType.Alliance_Rally] = "UIAlliance_mark_13",
--    [MarkType.Alliance_Build] = "UIAlliance_mark_06",
--    
--    [MarkType.Dragon_Attack] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack2] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend2] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat2] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally2] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack3] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend3] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat3] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally3] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack4] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend4] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat4] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally4] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack5] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend5] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat5] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally5] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack6] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend6] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat6] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally6] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack7] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend7] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat7] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally7] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack8] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend8] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat8] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally8] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack9] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend9] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat9] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally9] = "UIAlliance_mark_13",
--
--    [MarkType.Dragon_Attack10] = "UIAlliance_mark_03",
--    [MarkType.Dragon_Defend10] = "UIAlliance_mark_08",
--    [MarkType.Dragon_Retreat10] = "UIAlliance_mark_07",
--    [MarkType.Dragon_Rally10] = "UIAlliance_mark_13",
--}

--AllianceMarkPrefabPath = {
--    [MarkType.Alliance_Attack] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Alliance_Sun] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_4.prefab",
--    [MarkType.Alliance_LuckyClover] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_5.prefab",
--    [MarkType.Alliance_6] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_6.prefab",
--    [MarkType.Alliance_7] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Alliance_8] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Alliance_9] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_9.prefab",
--    [MarkType.Alliance_10] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_10.prefab",
--    [MarkType.Alliance_11] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_11.prefab",
--    [MarkType.Alliance_12] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_12.prefab",
--    [MarkType.Alliance_Rally] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--    [MarkType.Alliance_Build] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_6.prefab",
--    
--    [MarkType.Dragon_Attack] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack2] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend2] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat2] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally2] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack3] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend3] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat3] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally3] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack4] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend4] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat4] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally4] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack5] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend5] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat5] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally5] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack6] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend6] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat6] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally6] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack7] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend7] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat7] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally7] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack8] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend8] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat8] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally8] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack9] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend9] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat9] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally9] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--
--    [MarkType.Dragon_Attack10] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_3.prefab",
--    [MarkType.Dragon_Defend10] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_8.prefab",
--    [MarkType.Dragon_Retreat10] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_7.prefab",
--    [MarkType.Dragon_Rally10] = "Assets/Main/Prefabs/UI/AllianceWorldMark/AllianceWorldMark_13.prefab",
--}


--GuideArrowDirection =
--{
--    RightDown = 0,--右下
--    LeftDown = 1,--左下
--}

--GuideMoveArrowPlayAnimName =
--{
--    Down = 1,--按下
--    Up = 2,--抬起
--}

--GuideAnimObjectType =
--{
--    Scene = 1,--场景
--    SavePeople = 2,--救小人
--    ExploreMonster = 3,--探洞穴
--    ShowOstrichAnim = 4,--出现鸵鸟特效
--    ShowOstrichEgg = 5,--出现鸵鸟蛋
--    --ShowMigrateScene = 6,--出现移民
--    --ShowBusinessPlaneArriveScene = 7,--出现货运公司飞机
--    --ShowCowScene = 8,--出现奶牛
--    ShowRobotScene = 9,--出现机器人
----    ShowFromMjBuildMainBuildScene = 10,--出现工人从民居出来修建大本timeline
----    MainZeroUpgradeScene = 11,--大本0升1 
--    --SecondMigrateScene = 12,--第二次出现移民
--    --TilePlaneRuin = 13,--飞机坠毁
--    --SaveBobScene = 14,--拯救Bob
--    --PirateFightBobScene = 15,--海盗船和Bob打架
--    --PirateComeScene = 16,--海盗船到来
--    --PirateAwayScene = 17,--海盗船离开
--    --PirateShowScene = 18,--海盗出现
--    RadarScanScene = 19,--雷达扫描动画
--    --ShowFakePlayerFlagScene = 20,--显示假玩家标志
--    RadarWorldScanScene = 21,--世界雷达扫描动画
--    --PickUpWeaponScene = 22,--序章捡武器
--    ShowTankScene = 23,--显示假坦克
--    PvePirateBoomScene = 24,--pve海盗船爆炸
--    ShowRadarMonsterScene = 25,--播放雷打怪出现动画
--    PveThreeBombs = 26,--pve降落3颗炸弹
--    PveDestroyHdc1 = 27,--pve摧毁海盗船1
--    PveDestroyHdc2 = 28,--pve摧毁海盗船2
--    PveDestroyHdc3 = 29,--pve摧毁海盗船3
--    PveMissileInSky = 30,--pve摧毁海盗船3
--    PveDestroyMountain = 31,--pve摧毁山石
--    GuluOutFromBaseScene = 32,--timeline_1
--    GuideTimeline2Scene = 33,--GuideTimeline2Scene   不删除
--    PveHdcEscape = 34,--pve海盗船逃跑
----    DefendWallScene = 35,--
--    GuideTimeline3Scene = 36,--GuideTimeline3Scene
--    PveHdcEscape31014 = 37,--pve海盗船逃跑
--    SecondExpandDomeScene = 38,--第二次扩苍穹
----    ConnectElectricityScene = 39,--连电动画
--    Chapter2CameraMoveScene = 40,-- 第二章播完章节图，镜头移动
--    FirstExpandDomeScene = 41,--第一次扩苍穹
--    --SmallDomeMigrateScene = 42,--小苍穹移民timeline
--    WorldDesertCityEffectScene = 43,--赛季世界城特效
--    WorldAttackPlayerScene = 44,--世界上出现海盗船袭击大本
--    EndPrologueBridgeScene = 45,--结束序章填坑
--    StartPrologueBridgeScene = 46,--开始序章填坑
--    FromCarBuildMainBuildScene = 47,--从车里出来建造大本
--    HugLadyTimeline = 48,
--    SU_BorFireTimeline = 49,
--    ThreeBodyQTEInHomeTimeline = 50, --三人室内拉扯Timeline和qte
--    FightOnBoardQTETimeline1 = 51,  --船上qte 1
--    FightOnBoardQTETimeline2 = 52,
--    HugLadyTimeline2 = 53,
--    SU_PlayerOutoffCar = 70, --角色下车
--    SU_ZombieChasePlayer = 71, -- 丧尸追赶角色
--    SU_PlayerDriveCar = 72, --角色进入车内准备开车
--    SU_ZombieMoveIntoCar = 73, --丧尸攻入车内
--    SU_PlayerOutOffDriveSeat = 74, -- 角色从驾驶座起来
--    SU_PlayerOpenCarDoor = 75, --角色打开车门
--    SU_PlayerPutdownAlbum = 80, -- 放相册
--    SU_DroneTimeline = 81, -- 无人机雾气解锁
--    SU_HangUpTimeline = 82, -- 挂机奖励的车\
--    SU_NpcToBuild = 83, -- npc建造
--    SU_ShowZombieComing = 84, -- 展示丧尸来袭
--    SU_NpcGetGunTimeline = 85, -- 小人警局拿枪
--    SU_BuildFence = 86, -- 小人建造栅栏
--    Su_BattleFrontGate = 87, -- 警局门口的战斗
--    SU_FenceZombieWave = 88, -- 栅栏的尸潮
--    SU_GoToTowerTimeline = 89, -- 出兵上塔Timeline
--    SU_BarrelBattlePolicewoman = 90, -- 女警在关卡中的
--    SU_HeroKickDoor = 91, -- 英雄踹开城门
--    SU_HeroRescueGirl = 92, -- 营救护士
--    SU_BuildHousesTimeline = 93, -- 民居timeline
--    SU_SoldierBuildsTimeline = 94, -- 士兵建造建筑timeline
--    SU_RestaurantTimeline = 95, -- 餐厅吃饭timeline
--    SU_BossRunAwayTimeline = 96, -- 警局门口boss逃跑的timeline
--    SU_ArenaShowTimeline = 97, -- 竞技场出现的timeline
--    SU_SoldierRunToDaben = 98, -- 士兵拿着国旗进城
--    SU_SoldierRaiseFlag = 99, -- 升旗
--    SU_BarrelReceptTrailHero = 100,
--    SU_BloodyHandBrothers = 101, --末日帮timeline
--    SU_BloodyHandBrothers2 = 102, --末日帮timeline2
--    SU_TrainingGroundTimeline = 103, --校场timeline
--    Su_BuildTimeOfChange = 104, -- 时代变迁
--    SU_BarrelBattlePolicewoman_1 = 105, -- 女警在关卡中的
--    SU_BossShowingTimeline = 106, -- 前期boss入场
--}

--UIAssetTimeLine = {
--    [GuideAnimObjectType["SU_SoldierRaiseFlag"]] = "Assets/_Art_LastDay/Timeline/ShouchongshengqiB_Timeline/prefab/ShouchongshengqiB_3_Timeline.prefab",
--    [GuideAnimObjectType["SU_SoldierRunToDaben"]] = "Assets/_Art_LastDay/Timeline/ShouchongshengqiB_Timeline/prefab/ShouchongshengqiB_1_Timeline.prefab",
--    [GuideAnimObjectType["SU_NpcToBuild"]] = "Assets/_Art_LastDay/Timeline/Xunlianyingjianzao_B_Timeline/prefab/Xunlianyingjianzao_B_Timeline.prefab",
--    [GuideAnimObjectType["SU_ShowZombieComing"]] = "Assets/_Art_LastDay/Timeline/Timeline_maincity_new_citizen/prefab/Timeline_maincity_new_citizen.prefab", -- 放相册
--    [GuideAnimObjectType["SU_NpcGetGunTimeline"]] = "Assets/_Art_LastDay/Timeline/Chongjianjiju_Timeline/prefab/Chongjianjiju_Timeline.prefab",
--    [GuideAnimObjectType["SU_BuildFence"]] = "Assets/_Art_LastDay/Timeline/Chongjianjiju_Timeline/prefab/Chongjianjiju_Timeline_02.prefab",
--    [GuideAnimObjectType["Su_BattleFrontGate"]] = "Assets/_Art_LastDay/Timeline/Jingjudazhanqian_Timeline/prefab/Jingjudazhanqian_Timeline.prefab",
--    [GuideAnimObjectType["SU_FenceZombieWave"]] = "Assets/_Art_LastDay/Timeline/shichaolaixi_Timeline/prefab/shichaolaixi_Timeline.prefab",
--    [GuideAnimObjectType["SU_GoToTowerTimeline"]] = "Assets/_Art_LastDay/Timeline/shibingchuji_Timeline/prefab/shibingchuji_Timeline.prefab",
--    [GuideAnimObjectType["SU_BarrelBattlePolicewoman"]] = "Assets/_Art_LastDay/Timeline/nvjingdengchang/prefab/Nvjingchadengchang_Timeline.prefab",
--    [GuideAnimObjectType["SU_BarrelReceptTrailHero"]] = "Assets/_Art_LastDay/Timeline/ShouchongshengqiA_Timeline/prefab/ShouchongshengqiA_Timeline.prefab",
--
--    [GuideAnimObjectType["SU_HeroKickDoor"]] = "Assets/_Art_LastDay/Timeline/Nanzhuchuaimen_Timeline/prefab/Nanzhuchuaimen_Timeline.prefab",
--    [GuideAnimObjectType["SU_HeroRescueGirl"]] = "Assets/_Art_LastDay/Timeline/hushidengchang_Timeline/prefab/hushidengchang_Timeline_02.prefab",
--    
--    [GuideAnimObjectType["SU_BuildHousesTimeline"]] = "Assets/_Art_LastDay/Timeline/dianjiminju/prefab/Dianjijumin_Timeline.prefab",
--    [GuideAnimObjectType["SU_SoldierBuildsTimeline"]] = "Assets/_Art_LastDay/Timeline/Xunlianyingjianzao_Timeline/prefab/Xunlianyingjianzao_Timeline.prefab",
--    [GuideAnimObjectType["SU_RestaurantTimeline"]] = "Assets/_Art_LastDay/Timeline/Yidunbaofan_Timeline/prefab/Yidunbaofan_Timeline.prefab",
--    [GuideAnimObjectType["SU_BossRunAwayTimeline"]] = "Assets/_Art_LastDay/Timeline/Bosstaopao_Timeline/prefab/Bosstaopao_Timeline.prefab",
--    [GuideAnimObjectType["SU_ArenaShowTimeline"]] = "Assets/_Art_LastDay/Timeline/Jingjichangzhanshi_Timeline/prefab/Jingjichangzhanshi_Timeline.prefab",
--    
--    [GuideAnimObjectType["SU_BloodyHandBrothers"]] = "Assets/_Art_LastDay/Timeline/Xueshoulaixi_A2_Timeline/prefab/Xueshoulaixi_A2_Timeline.prefab",
--    [GuideAnimObjectType["SU_BloodyHandBrothers2"]] = "Assets/_Art_LastDay/Timeline/Xueshoulaixi_B_Timeline/prefab/Xueshoulaixi_B_Timeline.prefab",
--    [GuideAnimObjectType["SU_TrainingGroundTimeline"]] = "Assets/_Art_LastDay/Timeline/jiaochangjianzao_Timeline/prefab/jiaochangjianzao_Timeline.prefab",
--    [GuideAnimObjectType["SU_DroneTimeline"]] = "Assets/_Art_LastDay/Timeline/Miwujiesuo_timelineA/prefab/Miwujiesuo_timeline.prefab",
--    [GuideAnimObjectType["SU_BarrelBattlePolicewoman_1"]] = "Assets/_Art_LastDay/Timeline/nvjingdengchang/prefab/NvjingchadengchangB_Timeline.prefab",
--    [GuideAnimObjectType["SU_BossShowingTimeline"]] = "Assets/_Art_LastDay/Timeline/Bossdengchang_Timeline/prefab/BOSSdengchang_timeline.prefab",
--
--    OpeningAnimation = "Assets/_Art_LastDay/Timeline/KCdonghua/prefab/KCdonghua_Timeline.prefab",
--}

--UIAssetTimeLineB = {
--    [GuideAnimObjectType["SU_DroneTimeline"]] = "Assets/_Art_Barrel/Timeline/Miwujiesuo_timelineB/prefab/Miwujiesuo_timeline.prefab",
--    [GuideAnimObjectType["SU_BloodyHandBrothers"]] = "Assets/_Art_Barrel/Timeline/Xueshoulaixi_A_Timeline/prefab/Xueshoulaixi_A_Timeline.prefab",
--    [GuideAnimObjectType["SU_BloodyHandBrothers2"]] = "Assets/_Art_Barrel/Timeline/Xueshoulaixi_B_TimelineB/prefab/Xueshoulaixi_B_Timeline.prefab",
--}

--引导TimeLine信号类型
--GuideTimeLineShowMarkerType =
--{
--    Zero = 0,
--    One = 1,
--    Two = 2,
--    Three = 3,
--    Four = 4,
--    Five = 5,
--    Start = 998, --timeline刚开始
--    End = 999,
--}

--CanUnlockFogSmallDirection =
--{
--    LeftDown = 1,--左下
--    RightDown = 2,--右下
--    RightTop = 3,--右上
--    LeftTop = 4,--左上
--}

--FogCanUnlockEffectAnimName =
--{
--    CanLockToUnlock = "CanLockToUnlock",
--    CanUnlockIdle = "CanUnlockIdle",
--    LockIdle = "LockIdle",
--    LockToCanUnlock = "LockToCanUnlock",
--}

--CanUnlockFogSmallState =
--{
--    DeepColor = 1,
--    WeakColor = 2,
--}

--解锁迷雾影响的位置
--UnlockFogDirection =
--{
--    Own = 1,--自己
--    Left = 2,--左边
--    Right = 3,--右边
--    Top = 4,--上边
--    Down = 5,--下边
--}

--判断能不能做动画 小的不能做大的
--FogCanUnlockEffectAnimSort =
--{
--    [FogCanUnlockEffectAnimName.CanLockToUnlock] = 1,
--    [FogCanUnlockEffectAnimName.CanUnlockIdle] = 2,
--    [FogCanUnlockEffectAnimName.LockToCanUnlock] = 3,
--    [FogCanUnlockEffectAnimName.LockIdle] = 4,
--
--}

--ShowCircleType =
--{
--    Show = 0,--显示引导圆圈
--    No = 1,--不显示引导圆圈
--}

--建筑扫描动画
BuildScanAnim =
{
    No = 0,--没有飞行时间，不播放建筑扫描动画
    Play = 1,--有飞行时间，播放建筑扫描动画
    NoFly = 2,--没有飞行时间，播放建筑扫描动画
}

--第一次键入联盟标志
--FirstJoinAllianceType =
--{
--    No = 0,
--    Yes = 1,
--}

--解锁弹窗类型
--UnlockWindowType =
--{
--    None = 0,
--    Product = 1,
--    Building = 2,
--    GuideBtn = 3,--引导按钮
--    Activity = 4,--解锁新日常活动
--}

--引导是否可以做的状态
--GuideCanDoType =
--{
--    Yes = 1,--可以正常进行
--    No = 2,--缺少条件不能做，如果做会卡住
--}

--farming表材料是否足够类型标志
--FarmingEnoughType =
--{
--    Plant = 1,--种
--    Feed = 2,--喂
--}

--WaitMessageFinishType =
--{
--    PlantAnim = 1,--等待喂鸵鸟
--    PlantFarm = 2,--等待收土豆
--    GetAnim = 3,--等待收鸵鸟蛋
--    FeedAnim = 4,--等待喂完鸵鸟
--    AllianceMember = 5,--等待联盟成员信息返回
--    PurchaseOrderFinish = 6,--等待订单提交返回
--    FirstJoinAlliance = 7,--等待答题成为盟主返回
--    MoveCityToWorld = 8,--去世界消息返回
--    LevelExploreGetInfo = 9,--等待扫荡消息返回
--    TaskRewardGet = 10,--等待领奖消息返回
--    TrainSoldier = 11,--等待训练士兵消息返回
--    UIMergeMainRefresh = 12,--等待合成界面刷新
--    UIMainChapterTaskRefresh = 13,--等待章节任务界面刷新
--    LotteryHeroCard = 14,--等待英雄抽奖消息返回
--    UIDetectEvent = 15,--等待雷达界面事件加载完
--    BackSceneFinish = 16,--等待回到主城/回到世界
--    DetectEventRewardReceive = 27,--等待雷达领奖消息返回
--    
--    FindDesertPoint = 36,--等待找赛季地块消息返回
--}

--放置建筑界面打开类型
---@class PlaceBuildType
PlaceBuildType =
{
    None = 0,
    Build = 1,
    Move = 2,
    Replace = 3,
    MoveCity = 4,--迁城，根据情况选择道具
    MoveCity_Al = 5,--联盟迁城
    MoveCity_Cmn = 6,--高级迁城
    MoveCity_Cross = 7,--跨服迁城
    MoveCity_CrossWonder = 8,--跨服王座迁城
    Rally = 9, --集结
    MoveCity_Declare = 10,--宣战主动迁城
    MoveCity_CrossDragon = 11, --巨龙迁城
    MoveCity_PlunderMine = 12, --迁城掠夺金矿
}
--AllianceCityState = {
--    NEUTRAL = 0,--中立
--    OCCUPIED =1,--占领
--    InProgress = 2,--王座积分增长中
--}

--迁城类型
--MoveCrossServerType =
--{
--    Declare = 5,--宣战迁城
--    MinePlunder = 6,--金矿掠夺迁城
--}

---@class BuildPutState
--BuildPutState =
--{
--    None = 0,
--    Ok = 1,--可以放置
--    Collect = 2,--矿根
--    CollectRange = 3,--矿根周边
--    OtherCollectRange = 4,--其他矿根周边
--    NoCollectRange = 5,--没有矿根周边
--    OutMyRange = 6,--超出自己限制范围
--    InOtherBaseRange = 7,--在他人大本范围内
--    StaticPoint = 8,--静态点
--    Building = 9,--建筑
--    Board = 10,--基板
--    OutUnlockRange = 11,--不在已经锁范围内,解锁范围:({0},{1}) - ({2},{3})
--    UnConnectBoard = 12,--没有与自己基板相连
--    WorldBoss = 13,--世界Boss
--    WorldMonster = 14,--世界野怪
--    CollectTimeOver = 15,--矿跟正在销毁中
--    OutMyInside = 16,--不在苍穹内
--    InMyInside = 17,--不在苍穹外
--    OutMainSubRange = 18,--超出主建筑范围
--    OnBaseExpansion = 19,--在苍穹上
--    OnWorldResource = 20,--世界资源点
--    OnlyBuildRoad = 21,--该点只能铺设道路
--    ReachBuildMax = 22,--达到建造最大值
--    OnExplore = 23,--小队探索点
--    OnSample = 24,--小队采样点
--    OnGarbage = 25,--垃圾点
--    GuideBuildRoad = 26,--引导造路
--    MONSTER_REWARD = 27,--野怪奖励
--    NoBuildInMyInside = 28,--苍穹内不能建造道路
--    NoRemoveInMyInside = 29,--苍穹内的道路不可拆除
--    OnLandLock = 30,--地块未解锁
--    PveMonster = 31,--pve怪物点
--    OutBuildZone = 32,--不在建筑可建造区域内
--    ItemLack = 33,--道具不足
--    NotInAlArea = 34,--不可联盟迁城
--    NotNearAlRuin = 35,--不在联盟遗迹附近
--    AlResNotEnough = 36,--联盟资源不足
--    AlCityBuilding = 37,--在联盟城附近
--    NoInAllianceCenterRange = 38,--超出联盟中心范围
--    NotConnectDesert = 39,--地块未相连
--    InBlackLandRange = 40,--在黑土地范围
--    OnMonsterLock = 41,--在monsterlock上
--    OnRoad = 42, -- 在公路上
--    DragonCoolDown = 43, --巨龙迁城冷却
--    DragonSafeArea = 44, --巨龙安全区域
--    OutAllianceRallyPointRange = 45, --超出联盟集结点
--    OutAllianceLeaderPointRange = 46, --超出盟主范围
--}

--ResourceItemMonsterJumpType = {
--    MonsterJumpType_Monster = 1,
--    MonsterJumpType_Boss = 2,
--}

--修路界面状态
--PlaceRoadState =
--{
--    Build = 1,--修路
--    Remove = 2,--铲路
--}

--修路界面旗帜状态
--PlaceRoadFlagState =
--{
--    None = 0,
--    Start = 1,--开始
--    End = 2,--结束
--}

--AllianceCityShowTimeState = {
--    None = 0,
--    Lock = 1,--未开启
--    UnAttack =2,--休战
--    Recover = 3,--恢复
--    ThroneProtect = 4,
--    ThroneAttack = 5,
--    ThroneNotOpen = 6,
--}

--PackageImgPath = {
--    PackageBg = "Assets/Main/UITexture/UIPopupPackage/UIPopupPackage_%s",
--    PackageTitle = "Assets/Main/Prefabs/UI/UIPopupPackage/UIPopupPackage_Name_%s.prefab",
--    CommonBg = "Assets/Main/UITexture/UICommonPackageBig/CommonPackageBig_img_%s",
--    ScrollPack = "Assets/Main/UITexture/UIScrollPack/UIScrollPack_Bg_%s",
--    ScrollPackShort = "Assets/Main/UITexture/UIScrollPack/%s",
--}

--推送类型
--NoticeType = {
--    RecruitHero = 1,    -- 招募英雄
--    FirstKill = 2,      -- 首次击杀怪物
--    FirstOccupyCity = 3,     -- 首次占领城市
--    ChangeOccupyCity = 4,    --抢夺城市
--    HeroCard_Use = 5,   --紫将使用
--    OccupyEmptyCity = 6, --占领空城
--    NewServer_Act_Reward = 7, --开服活动领奖公告
--    RadarRally = 8, -- 雷达集结活动 首次击杀沙虫暴君
--    AcquireHero = 9,--英雄品质升阶
--    AlElectResult = 10,--联盟盟主选举
--    ActBossOpen = 11,--活动boss出现
--    ActBossClose = 12,--活动boss消失
--    CrossServer = 13,--有人跨服
--    AllianceCityBegin =14,--七级城解锁
--    DecorationItemGet = 15,--获取装扮物品
--    DecorationSend = 16,--赠送装扮物品
--    OccupyThrone = 17,--占领王座
--    KingSetPosition = 18,--授予官职
--    KingRefreshDesert = 19,--国王刷矿
--    OccupyDragonBuild =20,--占领巨龙建筑
--    GetSecretKey = 21,--获取圣物
--    SecretAppear = 22,--圣物出现
--    DragonTime = 23,--巨龙倒计时
--    SecretAppearAdv = 24,--圣物出现预告
--    CapitalOccupied   = 30,--首都正在被占领
--    CapitalBattleBegin = 31,--首都站已开启
--    PresidentialAppointment = 32,--总统任命
--    GetLuckyRollReward = 33, --幸运转盘获得奖励
--    ContinueWin = 35, -- 连杀
--    CrossThroneWin = 36, -- 跨服王座被占领
--    Dragon_Boss_Refresh = 37, --巨龙Boss刷新
--    Kill_Dragon_Boss = 38, --巨龙Boss被击杀
--    Dragon_Boss_Run_Away = 39, --巨龙Boss逃跑
--
--
--    LoginNotice =  20151020, --用于登陆之后设置时间，长时间不登录进行提示
--    FreeHero =  4100109,--免费抽英雄
--}

--GiftPackageTab =
--{
--    MonthCard = 1,
--
--}

ClickWorldType =
{
    Ground = 0,
    Collider = 1,
}

--RobotState =
--{
--    -- 0 空闲
--    FREE=0,
--    -- 1 升级/建造中
--    BUILD=1,
--    -- 2 科技研究中
--    SCIENCE=2,
--    -- 3 农场
--    FARM=3,
--    -- 4 加工厂
--    FACTORY=4,
--    -- 5 牧场
--    PASTURE = 5,
--    -- 6 捡垃圾
--    SU_Collect = 6,
--}

--RobotSkillType =
--{
--    -- 0 默认
--    DEFAULT=0,
--    -- 1 建造
--    BUILD=1,
--    -- 2 科技
--    SCIENCE=2,
--    -- 3 农牧
--    FARM=3,
--    -- 4 加工厂
--    FACTORY=4,
--}

--UIGuideGrowType =
--{
--    PlantFarm = 1,--种土豆
--}

--RecommendShowState =
--{
--    ShowBuild = 1,--显示建筑上的箭头
--    ShowPanel = 2--显示页面中的箭头
--}

--RecommendShowType =
--{
--    FarmPlant = 1,--农场种植
--    FarmGet = 2,--农场收获
--    FeedOstrich = 3,--喂鸵鸟
--}

--咕噜月卡,value1-4不可变
--GolloesType = {
--    Worker = 1,
--    Explorer = 2,
--    Trader = 3,
--    Warrior = 4,
--}

--GolloesSound = {
--    [GolloesType.Worker] = SoundAssets.Music_Effect_Golloes_Worker,
--    [GolloesType.Explorer] = SoundAssets.Music_Effect_Golloes_Explorer,
--    [GolloesType.Trader] = SoundAssets.Music_Effect_Golloes_Trader,
--    [GolloesType.Warrior] = SoundAssets.Music_Effect_Golloes_Warrior,
--}

--GolloesTypeOrderList =
--{
--    --GolloesType.Worker,
--    --GolloesType.Explorer,
--    GolloesType.Trader,
--    --GolloesType.Warrior
--}

--aps_shop.shop_id
--CommonShopType = {
--    Goods = 1,
--    Vip = 2,
--    LimitTime = 3,
--    HeroReset = 4,
--    Adventure = 5,
--    GolloesShop = 6,
--    DiscountShop = 7,--折扣商店？
--    AlContribute = 8,
--    SeasonShop = 10,--赛季商店
--    Honor = 14, --功勋商店
--    LO = 16, --登录作战商店
--}

--ShopType2PanelTab = {
--    [CommonShopType.LimitTime] = 1,
--    [CommonShopType.Vip] = 2,
--    [CommonShopType.Goods] = 3,
--    [CommonShopType.Honor] = 4,
--    [CommonShopType.LO] = 5,
--}

--CommonShopCurrencyId = {
--    HonorBadge = 254000,--荣誉徽章
--}

--AllianceMemberOpenType = {
--    AllianceMember = 1,
--    ResSupport = 2,
--    GolloesTrande = 3,
--    OtherAlMember = 4,
--}

--GolloesShow = {
--    [GolloesType.Worker] = {
--        name = "320246",
--        nameBg = "UI_dispatch_namebg_blue",
--        desc = "320216",
--        icon = "UI_dispatch_blue",
--        bg = "UI_dispatch_bg_blue",
--        costBg = "UI_dispatch_consumebg_blue",
--        costIcon = "UI_dispatch_consumeIcon_blue",
--        claimBg = "UI_dispatch_receive_blue",
--        color = Color.New(0.1, 0.9, 1,1),
--        tipOffsetX = 50,
--        rewardIcon = "UI_dispatch_icon_01",
--    },
--    [GolloesType.Explorer] = {
--        name = "320247",
--        nameBg = "UI_dispatch_namebg_red",
--        desc = "320217",
--        icon = "UI_dispatch_red",
--        bg = "UI_dispatch_bg_red",
--        costBg = "UI_dispatch_consumebg_red",
--        costIcon = "UI_dispatch_consumeIcon_red",
--        claimBg = "UI_dispatch_receive_red",
--        color = Color.New(1, 0.51, 0.51,1),
--        tipOffsetX = 0,
--        rewardIcon = "UI_dispatch_icon_02",
--    },
--    [GolloesType.Trader] = {
--        name = "320248",
--        nameBg = "UI_dispatch_namebg_yellow",
--        desc = "320218",
--        icon = "UI_dispatch_yellow",
--        bg = "UI_dispatch_bg_yellow",
--        costBg = "UI_dispatch_consumebg_yellow",
--        costIcon = "UI_dispatch_consumeIcon_yellow",
--        claimBg = "UI_dispatch_receive_yellow",
--        color = Color.New(1, 0.91, 0.45,1),
--        tipOffsetX = 0,
--        rewardIcon = "UI_dispatch_icon_03",
--    },
--    [GolloesType.Warrior] = {
--        name = "320249",
--        nameBg = "UI_dispatch_namebg_purple",
--        desc = "320219",
--        icon = "UI_dispatch_purple",
--        bg = "UI_dispatch_bg_purple",
--        costBg = "UI_dispatch_consumebg_purple",
--        costIcon = "UI_dispatch_consumeIcon_purple",
--        claimBg = "UI_dispatch_receive_purple",
--        color = Color.New(1, 0.52, 0.95,1),
--        tipOffsetX = -50,
--        rewardIcon = "UI_dispatch_icon_04",
--    },
--}

--RecommendShowAnimType = {
--    Default = 1,
--    Show = 2,
--}

--RecommendShowAnimName = {
--    [RecommendShowAnimType.Default] = "UIRecommendDefault",
--    [RecommendShowAnimType.Show] = "UIRecommendShow",
--}

--RecommendShowImgAnimName = {
--    [RecommendShowAnimType.Default] = "UIRecommendLightDefault",
--    [RecommendShowAnimType.Show] = "UIRecommendLightShow",
--}


--AssistanceType =
--{
--    Build = 0,
--    MainCity = 1,
--    AllianceCity = 2,
--    Desert = 3,
--    AllianceBuild = 4,
--    Throne =5,
--	Train = 6, -- 守火车
--    DragonBuilding = 7,
--    ThroneSingle = 9, -- 单队守王座
--}

--引导tip位置
--GuideTipPosition =
--{
--    LeftUp = 1,--左上
--    RightUp = 2,--右上
--    LeftDown = 3,--左下
--    RightDown = 4,--右下
--}

--引导移动镜头类型
--GuideMoveCameraType =
--{
--    Point = 1,--移动到固定点
--    Build = 2,--移动到建筑
--    CityTroop = 3,--移动到城市行军
--    AllianceChief = 4,--移动到盟主
--    AllianceMember = 5,--移动到周围8个点中任意盟友位置
--    NewbieSpaceMan = 6,--镜头重新跟随小人
--    Npc = 7,--镜头移动到NPC
--    FollowNpc = 8,--跟随NPC
--    CollectResource = 9,--矿根
--    Garbage = 10,--世界空投垃圾点
--    MonsterReward = 11,--野怪箱子
--    RadarMonster = 12,--移动到雷达
--    WorldCity = 13,--移动世界大本
--    BattleLevelArea = 30,--区域id
--}

--头顶对话类型
--GuideOverheadDialogType =
--{
--    Trigger = 1, --trigger目标
--    Player = 6, --主角团
--}

--解锁类型
--TemplateUnlockType =
--{
--    Build = 0,--建筑解锁
--    Science = 1,--科技解锁
--    MonthCard = 2,--(农场产物月卡解锁) 
--    Career = 2,--(工厂产物的职业解锁)
--    Talent = 4,--(天赋解锁)
--    Mastery = 5,--专精解锁
--}

--解锁按钮类型
--UnlockBtnType =
--{
--    Quest = 1,--任务按钮
--    Build = 2,--建造按钮
--    CityTroop = 3,--城市行军
--    Resource = 4,--全部资源条
--    FastBuild = 5,--快速建造按钮
--    Search = 6,--搜索按钮
--    Building = 7,--建筑
--    World = 13,--世界
--    Tool_Goods = 100,--道具
--    Tool_Resource = 101,--资源
--    Tool_ResourceItem = 102,--农作物
--}

--UnlockBtnIconPath = {
--    [UnlockBtnType.Quest] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIMain_icon_task",
--    [UnlockBtnType.Build] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIMain_btn_robot",
--    [UnlockBtnType.CityTroop] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIGuide_queue",
--    [UnlockBtnType.Resource] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIMain_btn_Technology",
--    [UnlockBtnType.FastBuild] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIGuide_queue",
--    [UnlockBtnType.Search] = "Assets/Main/Sprites/UI/UIMain/UIMainNew/UIGuide_queue",
--}
--UserSayCodeMap = {}
--UserSayCodeMap["en"] = "Account Banned"
--UserSayCodeMap["ru"] = "Аккаунт под баном"
--UserSayCodeMap["ja"] = "アカウント凍結"
--UserSayCodeMap["cn"] = "账号被封停___*禁言*___*封号*"
--UserSayCodeMap["tw"] = "帳號被封停"
--UserSayCodeMap["ar"] = "تم حظر الحساب"
--UserSayCodeMap["de"] = "Konto verbannt"
--UserSayCodeMap["fr"] = "Compte bloqué"
--UserSayCodeMap["ko"] = "계정이 차단됨"
--UserSayCodeMap["pt"] = "Conta foi congelada"
--UserSayCodeMap["th"] = "บัญชีโดนแบน"
--UserSayCodeMap["tr"] = "Hesap donduruldu"
--UserSayCodeMap["id"] = "Akun Diblokir"
--UserSayCodeMap["es"] = "Cuenta bloqueada"
--UserSayCodeMap["it"] = "Account bloccato"

--主UI需要保存的位置，用于飞图标，主界面隐藏的情况
--UIMainSavePosType =
--{
--    Quest = 1,--任务按钮
--    Build = 2,--建造按钮
--    CityTroop = 3,--城市行军
--    FastBuild = 4,--快速建造按钮
--    Goods = 5,--物品
--    PlayerLevel = 6,--玩家等级
--    Search = 7,--搜索按钮
--    StorageLimit = 9,--仓库上限
--    Power = 10,--战力
--    Gold = 11,--钻石
--    Stamina = 12,--体力
--    LM_food = 13,--食物
--    People = 14,--Survival人口
--    AllianceCompete = 15,--联盟对决
--    Activity = 16,--活动中心
--    WelfareCenter = 17,--福利中心
--}

--活动提示入口类型   7087
--ActivityTipEntranceType =
--{
--    activityEntrance = 1, --日常活动入口
--    welfareCenterEntrance = 2, -- 福利中心入口
--    expose = 3, -- 曝光入口
--    strongCommander = 4, -- 最强指挥官
--    allianceCompete = 5, -- 联盟对决
--    sevenDay = 7, -- 7日活动
--    Another = 100, --未知
--}
--ActivityTipConditionType =
--{
--    FirstActivityId = 0,  --活动id首次
--    FirstActivityType =1, --活动类型首次
--    LoginInEveryDay = 2, --每日登录
--    EveryTime = 3,  --每次
--    CycleActivityEveryTime = 4,--周期活动每次开启
--    Monday = 113, --周一
--    TuesdayToFriday = 114, --周二到周五
--    Saturday = 115, --周六
--    MondayToSaturday = 116, --周一至周六
--}

--移动到世界自动加联盟类型
--MoveToWorldJoinAllianceType =
--{
--    Join = "1",--加入
--    No = "2",--未加入
--}

--建筑联通道路方向，越大优先级越高
BuildConnectRoadDirection =
{
    None = 0,
    Top = 1,
    Right = 2,
    Left = 3,
    Down = 4,
}
--方向
DirectionType =
{
    Top = 1,
    Right = 2,
    Left = 3,
    Down = 4,
}


--EnumQualitySetting =
--{
--    PostProcess_Bloom = "QualitySetting.PostProcess.Bloom",
--    PostProcess_ColorAdjustments = "QualitySetting.PostProcess.ColorAdjustments",
--    PostProcess_Vignette = "QualitySetting.PostProcess.Vignette",
--    PostProcess_Tonemapping = "QualitySetting.PostProcess.Tonemapping",
--    PostProcess_LiftGammaGain = "QualitySetting.PostProcess.LiftGammaGain",
--    PostProcess_DepthOfField = "QualitySetting.PostProcess.DepthOfField",
--    Resolution = "QualitySetting.Resolution",
--    FPS = "QualitySetting.FPS",
--    Terrain = "QualitySetting.Terrain"
--}

EnumQualityLevel =
{
    Off = 0,
    Low = 1,
    Middle = 2,
    High = 3,
}
BuildTilesType =
{
    One = 1, --1格
    Two = 2, --2格
    Three = 3, --3格
}

---改装车品质对应颜色
---@class CarQualityType
--CarQualityType = {
--    Write = 1, --白
--    Green = 2, --绿
--    Blue = 3, --蓝
--    Purple = 4, --紫
--    Orange = 5, --橙
--}

--StatTTType =
--{
--    Guide_Jump = "noviceboot_jump",
--    Guide = "noviceboot",
--    Quest = "quest",
--    Special = "special",
--    JumpGuideId = "jump",
--    FinishTrigger = "finishTrigger",
--    FinishLevel = "finishLevel",
--    CreateLevelStart = "createLevelStart",
--    CreateLevelComplete = "createLevelComplete",
--    EngeryNotEnough = "engery_not_enough",
--    PveBattleStart = "pveBattleStart",
--    PveBattlePowerLack = "pveBattlePowerLack",
--    PveBattleFail = "pveBattleFail",
--    FiveStarJump = "fiveStarJump",
--    FiveStarReceive = "fiveStarReceive",
--    BridgeStageFinish = "bridgeStageFinish",
--    BridgeStageFail = "bridgeStageFail",
--    BridgeStageReset = "bridgeStageReset",
--    BridgeLevelFinish = "bridgeLevelFinish",
--    GuideType505 = "GuideType505",
--    GuideFullScreenDialogClick = "GuideFullScreenDialogClick",
--    BeginShowVideo = "beginvideo",
--    Mistresschat = "noviceboot_mistresschat",
--}
--引导镜头移动显示主UI类型
--GuideCameraShowUIMainType =
--{
--    None = 0,
--    Hide = 1,
--    Show = 2,
--}
--BaseExpansionType =
--{
--    None = 0,
--    Road = 1,
--    Tree = 2,
--}

--场景数据标志
--NewUserWorld =
--{
--    Skip = 0, --跳过新手世界
--    Ing= 1,-- 正在新手世界中
--    Pass= 2 ,--经历过新手世界
--}
--建筑联盟帮助类型
--AllianceHelpState =
--{
--    No = 0,
--    UpgradeHelped = 1,
--    RuinsHelped = 2,
--    UpgradeAndRuinsHelped = 3,
--}


--引导需要判断满足条件
--GuideJumpType =
--{
--    BuildPlace = 1,--建筑建造
--    QueueBuild = 2,--跳转队列所在建筑
--    PlantAnimal = 3,--饲养鸵鸟
--    WaitMessageFinish = 4,--等服务器消息回来
--    ClickTime = 5,--点击时间条加速
--    Factory = 6,--加工厂加工
--    ClickBuild = 7,--点击建筑
--    FactorySpeed = 8,--加工厂加速
--    TimelineJump = 9,--timeline对话等待时，需要播放下一个对话时跳转
--    WaitCloseUI = 10,--等待UI关闭
--    BuildLevel = 11,--要求建筑等级
--    QueueState = 12,--当前队列是否是这个状态
--    AllianceMember = 13,--周围8个点是否有盟友
--    DoneGuide = 14,--如果该引导id做过就跳过
--    CityPointType = 15,--坐标点是否为城市点类型
--    BuildRoad = 16,--坐标点能不能建路
--    HasBuild = 17,--这个位置是否有该建筑（不判断联通）
--    HasGroceryStoreOrder = 18,--是否有该状态的咕噜订单
--    ClickRadarBubble = 19,--是否有配置类型配置状态的雷达事件,没有走跳过
--    IsHaveCanShopItem = 20,--是否有可以上架的物品
--    UIStorageShopMainViewTab = 21,--是否为配置的页签
--    PlayerCareer = 22,--是否有职业
--    AllianceLeader = 23,--是否是盟主
--    TreatSoldier = 24,--是否有伤兵
--    BuildState = 25,--建筑状态
--    LandLockState = 26,--地块是否是该状态
--    LandLockHasChest = 27,--地块是否有獎勵
--    LandLockPowerEnough = 28,--地块兵力是否充足
--    PveHasUseBattleHero = 29,--pve是否有可上阵英雄
--    PveBattleMinHeroRarity = 30,--pve上阵中等级最低的英雄是否低于或等于该稀有度
--    HasCanAdvanceHero = 31,--当前是否有可突破的英雄,没有走跳过
--    HasOutRangeLevelHero = 32,--当前是否有超过该等级的英雄,有走跳过
--    FactoryFreeSpeed = 33,--加工厂不能免费加速跳过
--    LockLandBubbleState = 34,--地块气泡不是配置状态走跳过
--    HaveAlliance = 35,--不满足配置（1:有联盟 2：没有联盟）时,，走跳过
--    IsFormationUnset = 36,--配置index未设置编队走跳过
--    IsSuccessMarch = 37,--没有正常出征走跳过
--    HaveMonsterReward = 38,--没有打怪的宝箱走跳过
--    GetMonsterRewardBagFull = 39,--领取打怪宝箱背包满了走跳过
--    Bubble = 40,--是否正在显示该气泡，没有走跳过
--    AttackLevelMonster = 41,--配置等级野怪不能打走跳过
--    FinishChapter = 42,--是否完成这个章节（该章节已领奖）
--    HaveLeaderInAlliance = 43,--没有联盟或联盟中没有盟主走跳过
--    PveLevelExploreState = 44,--关卡扫荡不是配置状态走跳过
--    FactoryState = 45,--加工厂不满足配置状态走跳过
--    OwnResourceItemNum = 46,--拥有的资源道具数量小于配置数量走跳过
--    UIResourceLackHaveLackTips = 47,--缺资源界面没有配置tips则走跳过
--    OwnResourceNum = 48,--拥有的资源数量小于配置数量走跳过
--    PveTaskNotUnCompleteState = 49,--pve任务不是未完成状态走跳过
--    HaveUpgradeHero = 50,--没有可晋级的英雄走跳过
--    PveMonumentRestEnterTime = 51,--丰碑剩余进入次数小于配置数量走跳过
--    HistoryUpgradeHero = 52,--晋升过走跳过
--    BuildBubble = 53,--建筑没有该气泡走跳过
--    SceneType = 54,--不在配置的场景内走跳过（主城/世界/pve）
--    HasStarUpHero  = 55,--升过星走跳过
--    HasCanStarUpHero    = 56,--没有可以升星的英雄走跳过
--    PveBattleResult    = 57,--关卡战斗不是配置结果走跳过
--    OwnItemNum = 58,--拥有的道具数量小于配置数量走跳过
--    ShowQuestId = 59,--主UI左侧没有配置任务id的任务球显示走跳过
--    WorldCollectPoint = 60,--该类型采集点不能采集走
--    UIPVEPowerLack = 61,--pve战斗不能攻击面板，没有配置条件类型走跳过
--    StoryReward = 72,--探险阶段宝箱不能领取奖励走跳过
--    PlayerLevel = 73,--玩家等级
--    SeasonGetResource = 101,--赛季不能收取资源走跳过
--    SeasonResistanceValue = 102,--赛季抗性值大于等于配置值走跳过
--    SU_CheckQuestId = 201, -- 任务完成
--    SU_TriggerDone = 202, -- trigger完成
--    SU_RapidPocket = 203, -- 检测快捷栏是否有东西
--    SU_CheckPocketItem = 204, -- 配置道具id，判断快捷栏是否有该道具。有的话跳过
--    SU_CheckGuide = 205, -- 配置引导id，如果没有完成参数里的引导的话，则跳过本步引导
--    LM_CheckBagItem = 206, -- 当背包中没有该道具时，跳过该引导
--    SU_CheckScientificFinish = 207, -- 检测某个科研界面的进度是否满了，满的话则跳过
--    HasWindow = 208, -- UI存在，没有关闭
--    HasBuyGift = 209, -- 已经购买过该礼包
--    HasActivity = 210, -- 活动是否开启
--    HasSevenDay = 211, -- 七日活动是否开启
--    HasHero = 212, -- 拥有英雄跳过
--    LandLockFinish = 213, -- landLock关卡是否完成，关卡如果没通关，则走跳过
--    HeroEquippedWithEquipment = 214, -- 是否有英雄装备了装备
--}

--不可点击类型
--UINoInputType =
--{
--    ShowNoScene = 1,
--    ShowNoUI = 2,
--    Close = 3,
--}
--UIMovingType =
--{
--    Open = 1,
--    Close = 2,
--}

--UIMigrateType =
--{
--    Open = 1,
--    Close = 2,
--}

--UISetEdenType =
--{
--    Open = 1,
--    Close = 2,
--}

--建造坐标点类型
--PositionUnitType =
--{
--    DefaultRoad = 1,--默认路
--    InCityCanBuildPoint = 5,--城内的可建造点
--    NoBuildPoint = 6,--不可建造点
--}

--SpecialGuideLogType =
--{
--    RocketLandingClickJump = 1103,--cs播放时，点击跳过按钮
--    RecommendPlantFarmFirstClickFarm = 1104,--第一次种土豆路箭头出现，点击农田
--    DragPlantFarm = 1105,--拖拽土豆
--    PlantFarmPosLeftTop = 1106,--种田	左上
--    PlantFarmPosRightTop = 1107,--种田	右上
--    PlantFarmPosLeftDown = 1108,--种田	左下
--    PlantFarmPosLeftRight = 1109,--种田	右下
--    ShowFoodBoxFinger = 1110,--面包店，放下后变成盒子，出现手指时打点
--    ShowBusinessBoxFinger = 1111,--货运站，放下后变成盒子，出现手指时打点
--    PlaneRuinTimelineJump = 1112,--火箭坠毁timeline点击跳过
--    PlaneRuinTimelineShow = 1200,--火箭坠毁timeline刚开始播放
--    PlaneRuinTimelineHello = 1201,--火箭坠毁timeline舰长打招呼
--    PlaneRuinTimelineRuin = 1202,--火箭坠毁timeline坠落
--}

--PlantPosLogIndex = {SpecialGuideLogType.PlantFarmPosLeftTop,SpecialGuideLogType.PlantFarmPosRightTop
--,SpecialGuideLogType.PlantFarmPosLeftDown,SpecialGuideLogType.PlantFarmPosLeftRight}

--ABTestType =
--{
--    A = "0",
--    B = "1",
--}
--DestroyBuildType =
--{
--    Self = 0,
--    Other = 1,
--}
--DestroyRankType =
--{
--    Blood = 0,--伤害排行
--    Stamina = 1,--耐久排行
--}
--与StorageShopSlotData.state一致
--StorageShopSlotState = {
--    Empty = 0,
--    OnSell = 1,
--    Cleaning = 2,
--    SoldOut = 3,
--}

--StorageShopListType = {
--    World = 0,
--    Alliance = 1,
--}

-- 英雄驻扎状态
--HeroStationState =
--{
--    Current = 1, --已驻扎在当前建筑
--    Idle = 2, -- 闲置
--    Other = 3, -- 已驻扎在其他建筑
--    Namesake = 4, -- 已有同名英雄驻扎
--    Disabled = 5, -- 不可用
--}

--OtherBuildBubbleType = {
--    StorageShop = 1,
--
--}

--OtherBuildBubbleIcon = {
--    CommonBg = "bubble_bg_unselect",
--    StorageShop = "bubble_icon_trading_bank2",
--}

--ArrowPrefabName =
--{
--    [GuideArrowStyle.Finger] = UIAssets.WorldYellowArrow,
--    [GuideArrowStyle.Green] = UIAssets.WorldArrow,
--    [GuideArrowStyle.Yellow] = UIAssets.WorldYellowArrow,
--}
--HeroStationEffectType =
--{
--    Normal = 0, -- 普通作用号
--
--    -- 策划给了的
--    GlobalMoney = 1, -- 全局金币产量
--    StorageLimit = 2, -- 仓库上限
--    HeroExp = 3, -- 英雄经验
--    TroopLimit = 4, -- 带兵上限
--
--    -- 策划没给的
--    TradeCenterMoney = 10001, -- 火箭额外金币
--}

--HeroStationSkillEffectType =
--{
--    [1000] = HeroStationEffectType.GlobalMoney,
--    [1001] = HeroStationEffectType.StorageLimit,
--    [1002] = HeroStationEffectType.TroopLimit,
--    [1003] = HeroStationEffectType.HeroExp,
--}
--FormationAddSoldierType =
--{
--    TrainSoldier        = 13,--训练士兵
--    ThirdHeroBuild      = 14,--上阵第三个英雄
--    KillMonster         = 15,--击杀低级怪物
--    RadarMonster        = 16,--雷达怪物
--    FormationScience    = 17,--车库科技
--    HeroUpgrade         = 24,---英雄升级
--    HeroExchange        = 25,--英雄替换
--    GoFirstPackage      = 61,--买首充礼包 
--    TrainHighSoldier    = 2011,--训练高等级士兵
--    BuildUpgrade        = 2022,--战力不足，提升建筑
--}

--播放timeline需要点击的气泡

--GuideTimeLineBubbleType =
--{
--    OstrichEgg = 1,--鸵鸟蛋
--    ZeroRocket = 2,--大本0升1火箭
--    Migrate = 3,--移民气泡
--    Cow = 4,--奶牛气泡
--}

--GuideOrderType =
--{
--    CanSubmit = 1,--任意能提交的订单
--    OrderItemType = 2,--确定类型的订单
--    NoSubmit = 3,--任意不能提交的订单
--}

--GuideOrderState =
--{
--    NoSubmit = 1,--不能提交
--    CanSubmit = 2,--能提交
--    Finish = 3,--完成（处于完成冷却中）
--    Delete = 4,--处于删除冷却中
--}

--引导主UI显示类型
--GuideUIMainShowType =
--{
--    Hide = 1,
--    Show = 2
--}

--建筑中心区域类型
--BuildZoneType =
--{
--    No = -1,--不可建造区域
--    All = 0,--任意类型都可建造区域
--    Tower = 1, -- 居民区
--    Hero = 2, -- 工业区
--    Trade = 3, -- 商业区 
--    Military = 4, -- 军事区 
--}

--BuildZoneName =
--{
--    [BuildZoneType.Tower] = 100810,
--    [BuildZoneType.Hero] = 100811,
--    [BuildZoneType.Trade] = 100812,
--    [BuildZoneType.Military] = 100813,
--
--}

--建筑中心区主辅类型
--BuildZoneMainType =
--{
--    Sub = 0,--普通建筑
--    Main = 1,--中心建筑
--}

--StationIdList =
--{
--    BuildZoneType.Tower,
--    BuildZoneType.Trade,
--    BuildZoneType.Military,
--    BuildZoneType.Hero,
--}

--StationBuildId =
--{
--    [BuildZoneType.Tower] = BuildingTypes.FUN_BUILD_MAIN,
--    [BuildZoneType.Trade] = BuildingTypes.APS_BUILD_FARM,
--    [BuildZoneType.Military] = BuildingTypes.FUN_BUILD_TRADING_CENTER,
--    [BuildZoneType.Hero] = BuildingTypes.FUN_BUILD_RADAR_CENTER,
--}

--ResourceItemShowType =
--{
--    No = 0,
--    Show = 1,
--}

--ComplexTipType =
--{
--    Text = 1,
--    Image = 2,
--    Hero = 3,
--}

--建筑气泡状态
--BubbleState =
--{
--    Normal = 1,
--    Road = 2,--修路模式
--}

--NextBusinessComeType = {
--    EARTH_ORDER = 0,
--    GROCERY_STORE = 1,
--    RESIDENT_ORDER = 2,
--}

--ClickUISpecialBtnType =
--{
--    UIFormationSelectHero = 1,
--    UIFormationDeleteHero = 2,
--    UIFormationTableAddHero = 3,
--    UIPVESceneMinHeroRarity = 4,--手指指向上阵中稀有度最低的英雄
--    UIPVESceneHeroId = 5,-- 表示手指指向未上阵中该英雄 para2填写英雄id
--    UIPVESceneHeroRarity = 6,--表示手指指向未上阵中该品质英雄 para2填写英雄品质
--    UIHeroListCanAdvanceHero = 7,--表示手指指向英雄列表可以突破的英雄
--    UIScience = 8,--表示手指指向科技树界面配置科技
--    UIBuildUpgradeLackResource = 9,--表示手指指向升级界面缺少的资源
--    UIHeroAdvanceMainHero = 10,--表示手指指向英雄晋级界面晋级的英雄
--    UIHeroAdvanceSubHero = 11,--表示手指指向英雄晋级界面消耗海报的英雄
--    UIHeroListAdvanceHero = 12,--表示手指指向英雄列表界面可进阶英雄
--    UIHeroListHeroId = 13,--表示手指指向英雄列表配置的英雄
--    UIHeroListStarHero = 14,--表示手指指向英雄列表界面可升星英雄
--    UIMergeMainMonsterSlot = 15,--表示手指指向合成界面怪物格子
--    UIRocketBombPassword = 16,--表示手指指向拆炸弹密码
--}

--协议用了字符串，所以
--NationType = {
--    UnitedNations = "1",
--    China = "2",
--    America = "3",
--}

--PlayerNations = {
--    {
--        Nation = NationType.UnitedNations,
--        Flag = "",
--        Name = "",
--    },
--    {
--        Nation = NationType.China,
--        Flag = "",
--        Name = "",
--    },
--    {
--        Nation = NationType.America,
--        Flag = "",
--        Name = "",
--    },
--}

--ChatReportType = {
--    Politics = 1,
--    Ads = 2,
--    Gambling = 3,
--    Gm = 4,
--    Sexy = 5,
--    Attack = 6,
--    NickName = 7,
--    HeadIcon = 8,
--    Other = 9,
--}

--AllianceMineStatus = {
--    Normal = 0,--正常
--    Constructing = 1,--建造中
--    Ruin = 2,--废墟态
--}

--continuously
--AlMineConditionType = {
--    MemberCount = 1,
--    Power = 2,
--    RuinLv = 3,
--    PreBuild = 4,
--}

--LeagueMatchTab = {
--    Activity = 1,--活动
--    Compete = 2,--对决
--    AllianceRank = 3,--联盟排名
--    DrawLots = 4,--抽签
--    Notice = 5,--开启预告
--    CrossServer = 6,--跨服
--    CrossServerDesert = 7,--??
--    LimitTimeGift = 8, --限时特惠
--}

--LeagueMatchStage = {
--    None = 1,
--    Notice = 2,
--    DrawLots = 3,
--    DrawLotsFinished = 4,
--    Compete = 5,
--    WeeklySummary = 6,
--    FinalSummary = 7,
--}

--SegmentType = {
--    None = 0,
--    Silver = 1,
--    Gold = 2,
--    Diamond = 3,
--}


--ActivityOverviewType = {
--    EarthOrder = 1,--贸易火箭
--    RallyBossAct = 2,--沙虫集结
--    IndividualOrder = 3,--商业大亨
--    ChampionBattle = 4,--冠军对决
--    MineCave = 5,--矿洞探险
--    Puzzle = 6,--寻宝活动
--    AllianceOrder = 7,--万商云集（已废弃）
--    Arena = 8,--竞技场
--    Adventure = 9,--探索活动
--    EverydayTask = 10,--每日任务
--}

--OverviewToActType = {
--    [ActivityOverviewType.RallyBossAct] = EnumActivity.RallyBossAct.Type,--集结奖励
--    [ActivityOverviewType.IndividualOrder] = ActivityEnum.ActivityType.IndividualOrder,--商业大亨
--    [ActivityOverviewType.MineCave] = EnumActivity.MineCave.Type,--矿洞探险
--    [ActivityOverviewType.Puzzle] = ActivityEnum.ActivityType.Puzzle,--星际寻宝
--    [ActivityOverviewType.AllianceOrder] = ActivityEnum.ActivityType.AllianceOrder,--万商云集
--    [ActivityOverviewType.Arena] = EnumActivity.Arena.Type,--竞技场
--}

--TreasureId = {
--    EnergyTreasure = 10000,
--}

--MineCavePlunderType = {
--    DefenseFail = 1,
--    DefenseWin = 2,
--    AttackWin = 3,
--    AttackFail = 4,
--}

--ThemeActivityIcon = {
--    ["1"] = "",
--    
--}

--OverviewTypeToDailyActivity = {
--    [2] = {
--        Type = EnumActivity.RallyBossAct.Type,
--        ActId = EnumActivity.RallyBossAct.ActId,
--    },
--    [3] = {
--        Type = ActivityEnum.ActivityType.IndividualOrder,
--        ActId = nil,
--    },
--    [5] = {
--        Type = EnumActivity.MineCave.Type,
--        ActId = EnumActivity.MineCave.ActId,
--    },
--    [6] = {
--        Type = ActivityEnum.ActivityType.Puzzle,
--        ActId = nil,
--    },
--    [8] = {
--        Type = EnumActivity.Arena.Type,
--        ActId = EnumActivity.Arena.ActId,
--    },
--}

--AlMoveInviteType = {
--    None = 0,
--    SystemInvite = 1,
--    LeaderInvite = 2,
--    InviteTip = 3,
--    AlwaysLeader = 4,
--}

--MoveCityTipType = {
--    AlMoveInvite = 0,--邀请
--    CommonMove = 1,--迁城确认
--    SystemInvite = 2,
--    LeaderInvite = 3,
--    RallyCheck = 4,
--}

--ConsumeItemType = {
--    AlMoveCity_LeaderInvite = 1,--联盟迁城
--    AlMoveCity_SysInvite = 2,--联盟迁城
--}

--CityPrologueBuildType = {
--    Ruins = "Ruins", --废墟状态
--    Normal = "Normal", --正常运转状态
--    Plant = "Plant", --可以种植状态
--    Get = "Get", --可以收获状态
--}

--TranslateType = {
--    MailInfo = 1,
--    ChatMessage = 2,
--}

--WelfareMessageKey =
--{
--    GrowthPlanInfo = 1,
--}

--今日不提示类型
--TodayNoSecondConfirmType =
--{
--    UpgradeUseDiamond = "UpgradeUseDiamond",--升级使用钻石（秒建筑，秒科技，秒兵，秒伤兵）
--    BuyUseDialog = "BuyUseDialog",--买加速，买资源
--    AutoDig = "AutoDig",--挖掘寻宝自动挖掘
--    LuckyShopRefresh = "LuckyShopRefresh",--幸运折扣商店刷新
--    ProductReserve = "ProductReserve",--造预备兵
--    RefreshDispatchTask = "RefreshDispatchTask",-- 使用钻石刷新派遣任务
--    RefreshBestDispatchTask = "RefreshBestDispatchTask", -- 如果玩家有未开始派遣的橙色任务，会弹出确认框让玩家二次确认
--	ResourceReplenish = "ResourceReplenish",--资源一键补齐
--    ForceChangeTarget = "ForceChangeTarget",  -- 在自由行军中强制修改目的地
--    ReinforceSoldiers = "ReinforceSoldiers",  -- 补兵
--    UIAllianceClearMember = "UIAllianceClearMember",
--    LuckyRoll = "LuckyRoll",--购买转盘抽奖道具
--    UIHeroEquipStrength = "UIHeroEquipStrength",--装备强化
--    PVPChallengeWarning = "PVPChallengeWarning", --PVP挑战警告
--    ActCallBigBossWarning = "ActCallBigBossWarning", --挑战试炼大boss警告
--    TrainRefreshWarning = "TrainRefreshWarning",--押镖刷新
--    MoveCityCheckMonsterSiege = "MoveCityCheckMonsterSiege", --迁城时检测是否处于丧尸攻城中
--    UIAircraftClickUp = "UIAircraftClickUp", -- 改装车升级按钮点击时是否需要预警
--    superherostarup = "superherostarup", -- 升星带通用碎片
--    SEASON_GOTO_TIPS = "SEASON_GOTO_TIPS", --赛季管理坐标跳转是否当日不再提醒标记
--    TrainSuperRefresh = "TrainSuperRefresh", --货车超级刷新
--    SmallPeopleRecruitRefresh = "SmallPeopleRecruitRefresh", --小兵招募刷新
--    ActGiftBoxRemindFull = "ActGiftBoxRemindFull", --娃娃机抽奖箱子满了还要抽
--    UseGarageComponSelectBox = "UseGarageComponBox",  --使用改装车组件自选箱子
--    UseGarageComponRandomBox = "UseGarageComponRandomBox",  --使用改装车组件随机箱子
--    UIHeroStarUp = "UIHeroStarUp",--英雄升星
--    ScoutBreakProtect = "ScoutBreakProtect",--侦察破罩
--    ArenaSeasonResetPopup = "ArenaSeasonResetPopup", --竞技场赛季重置弹窗
--    HospitalFull = "HospitalFull", --医院满了
--    TrainRefresh = "TrainRefresh", -- 押镖刷新
--}

--任务显示类型
--QuestShowType =
--{
--    No = 0,
--    Show = 1,
--}

--RedPacketState = {
--    ALREADY_GET  = 0, --已经获取
--    VALID        = 1, --未获取
--    COST_ALL     = 2, --领完了
--    TIMEOUT      = 3, --超时
--    PREPARE_SEND = 4, --待发送
--}

-- 车库BuildId
--GarageBuildIds =
--{
--    BuildingTypes.FUN_BUILD_TRAINFIELD_1,
--    BuildingTypes.FUN_BUILD_TRAINFIELD_2,
--    BuildingTypes.FUN_BUILD_TRAINFIELD_3,
--    BuildingTypes.FUN_BUILD_TRAINFIELD_4,
--
--}

--PackTimeType =
--{
--    Regular = 1, -- 定时出现，定时消失
--    Always = 2, -- 长期出现，永不消失
--    Conditional = 3, -- 条件出现，定时消失
--    -- 4
--    ByTrigger = 5, -- 条件触发，定时消失，消失后可重复触发
--    AlwaysByWeek = 6, -- 跨周的2，start同2，end为结算日
--    Controlled = 7, -- 根据条件出现，条件不符合或者倒计时结束后消失
--    AlwaysHideTime = 8, -- 长期出现，永不消失 不需要填start和time这样不会显示礼包消失时间
--    Periodic = 9, -- 以一个周期循环出现，start填初始出现时间点;循环时间 如2021-09-10-00-00;86400 time填一次持续时间
--}

--ShareCheckType = {
--    StorageShop = 0,--交易行
--    MailScoutResult = 1,--侦查邮件
--    MailBattleReport = 2,--战报邮件
--}

-- 主页礼包中心按钮
--UIMainIconPrefab =
--{
--    ["PiggyBank"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_PiggyBank.prefab",
--    ["EnergyBank"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_EnergyBank.prefab",
--    ["SellCatgirl"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellCop"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellConsigliere"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellDetective"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellSumo"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellClown"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellMishu"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["SellWinterHouse"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_SellHero.prefab",
--    ["Robot0"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["Robot1"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["Robot2"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["Robot3"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["Robot4"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["Robot5"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Robot.prefab",
--    ["SellDiamond"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["SellDiamondNew"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["SellCoin"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["SellHeroCommon"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["SellSpeedCommon"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["SellXmas"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Packstore.prefab",
--    ["UIMain_icon_hero1"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_hero1.prefab",
--    ["UIMain_icon_Onestepahead"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Onestepahead.prefab",
--    ["UIMain_icon_HeroLegend"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_HeroLegend.prefab",
--    ["UIMain_icon_Invincible"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_Invincible.prefab",
--    ["UIMain_icon_firstPay"] = "Assets/Main/Prefabs/UI/UIMain/UIMain_icon_firstPay.prefab",
--}

--SysAlState = {
--    WaitMerge = -2,--待合盟
--    Normal = -1,--普通盟
--    SignUp = 0,--报名参选盟主
--    R4Elect = 1,--投票选择R4
--    R4Reuslt = 2,--R4结果展示
--    LeaderElect = 3,--票选盟主
--    LeaderResult = 4,--盟主展示
--    MergeTime_1 = 5,--合盟考察期1（修改宣言和盟名称）
--    MergeTime_2 = 6,--合盟考察期2
--}

--EffectReasonType =
--{
--    Science = 0,--科技
--    Building = 1,--建筑
--    Hero = 2,    --英雄
--    VIP = 3,--VIP
--    MONTH_CARD = 4,--月卡
--    PLAYER_LEVEL = 5,--玩家等级
--    Hero_Station = 6,--英雄驻扎
--    Science_Activity = 7,--科技活动（最强战区）
--    Alliance_Science = 8,-- 联盟科技
--    World_Alliance_City = 9, --联盟城市
--    Status = 10,--buff
--    Tank = 11,--车库改造
--    Career = 12,--职业
--    Alliance_Career = 13,--联盟职业
--    Land = 14,--地块
--    SERVER_EFFECT = 15,--服务器作用号
--    BASE_TALENT = 16, --大本天赋
--    Mastery = 17, -- 专精
--}
--BuffReasonIcon = {}
--BuffReasonIcon[EffectReasonType.Science] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_technology"
--BuffReasonIcon[EffectReasonType.Hero] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_hero"
--BuffReasonIcon[EffectReasonType.VIP] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_vip"
--BuffReasonIcon[EffectReasonType.BASE_TALENT] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_HQ-Talent"
--BuffReasonIcon[EffectReasonType.Building] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_console"
--BuffReasonIcon[-1] = "Assets/Main/Sprites/UI/UIBuild/UIBuild_icon_robot_other"

--AB测试可以开放的国家
--UseABTestCountry =
--{
--    "IN","CN","PH","ID","GB",
--}

-- 开荒种植状态
--Wasteland_PlantState = {
--    ToPlant = 1,  -- 需要播种
--    ToWater = 2,  -- 需要浇水
--    ToReap = 3,   -- 需要收割
--}

--联盟职业位置
--AllianceCareerPosType =
--{
--    No = 0,--未委任
--    Yes = 1,--委任
--}

--联盟职业作用值显示类型
--AllianceCareerEffectDescriptionType =
--{
--    AddCount = 2,--加整数
--    SubCount = 3,--减整数
--    AddPercent = 4,--加百分比
--    SubPercent = 5,--减百分比
--}

--AllianceCityNewsType = {
--    OCCUPY_NEUTRAL_CITY = 0,--自然联盟城占领
--    OCCUPY_OCCUPIED_CITY = 1,--抢夺联盟城占领
--    FIRST_NEUTRAL_CITY  =2,--首次占领联盟城
--}
--AllianceCityRecordState = {
--
--	CURRENT = 0, --// 0 当前记录
--	HISTORY = 1, --// 1 历史记录
--	HISTORY_FIRST_OCCUPY = 2, --// 2 历史首占
--}

--BattleNewsType={
--    Battle = 0,
--    AllianceCity = 1,
--}

---@class UITipDirection
--UITipDirection = {
--    ABOVE  = 1,
--    BELOW  = 2,
--    LEFT   = 3,
--    RIGHT  = 4,
--}

--AllianceAlertType  = {
--    BUILDING = 0,  -- 建筑
--    COLLECT = 1,  -- 采集
--    ALLIANCE_CITY = 2,   -- 联盟城
--    DESERT = 3, --地块
--    ALLIANCE_BUILD = 4,--联盟建筑
--}

--AllianceTaskFuncType = {
--    AllianceOrder = 1,--万商云集
--    AllianceMoveCity = 2,--联盟迁城
--    AllianceScience = 3,--联盟科技
--    AllianceCareer = 4,--联盟职业
--}

--IrrigationType = {
--    Farmland = 1,--农场
--    Pasture = 2,--牧场
--}

--GuidePrologueFlag =
--{
--    Start = 0,--开始
--    End = 1,--结束
--}

--BuyFlag = {
--    NOT_BUY = 0,--未购买
--    BUY = 1,--已购买
--}

--OriType = {
--    Left = 0,
--    Right = 1,
--    Up = 2,
--    Down = 3,
--    Error = 4
--}

--LandLockState =
--{
--    Any = -1,
--    --Default = 0,
--    --Unlock = 1, 
--    --Start = 2,   --进入关卡
--    
--    Hide = 1,     -- 未解锁隐藏
--    Locked = 2,   -- 已解锁,但是未完成 显示
--    Unlocked = 4, -- 已完成,但是未领奖
--    Finished = 5, -- 已完成,已领奖
--}

--和后端同步的状态
--SurvivalAreaState = 
--{
--    Default = 0,
--    Finish = 1,
--    Start = 2,
--    Complete = 3, -- 出气泡,需要点击才能解锁
--}

--SurvivalRewardType = 
--{
--    Default = 0,
--    Rewarded = 1
--}

--SurvivalGroundType =
--{
--    None  = 0,
--    Puddle = 1,
--    HideFootprint = 2,
--    Floor = 3,
--}

--LandLockBubbleType =
--{
--    Green = 0,
--    Help = 1,
--    Axe = 2,
--    Red = 3,
--    Yellow = 4,
--    Wood = 5,
--}

--LandLockTopIcon =
--{
--    None = "None",
--    Yellow = "Yellow",
--    Red = "Red",
--}

--MonsterLockState =
--{
--    NOT_BUY = 0,
--    BUY = 1,
--    Finished = 2, -- 隐藏气泡，已解锁，已清理，隐藏障碍物
--}

--MonsterLockBubbleState =
--{
--    Unlocked = "Unlocked",
--    Pay = "Pay",
--    Pve = "Pve",
--}


--HeroMonthCardRewardState = {
--    REWARD_STATE_CAN_RECEIVE = 1,--可领取
--    REWARD_STATE_LOCK = 2,--锁定状态
--    REWARD_STATE_RECEIVED = 3,--已经领取
--    REWARD_STATE_UNRECEIVED = 4,--已买但是不可领取
--}

--SeasonForceRewardStatus = {
--    NOT_RECEIVE = 0,-- 0 未领取
--    RECEIVED = 1, --1 已领取
--    BATTLE_PASS_RECEIVED = 2, -- 2 battlepass已领取
--}
--SeasonForceRewardPackageType = {
--    CRYSTAL_BOX = 0,
--    MONEY = 1,
--
--}

--CareerType =
--{
--    None = 0,
--    Admiral = 1, -- 总督
--    Raider = 2, -- 掠夺者
--    Merchant = 3, -- 商人
--    Farmer = 4, -- 农民
--    Guard = 5, -- 军人
--}

--CareerSkillType =
--{
--    Unknown = 0,
--    AdmiralTroopSkill = 1,
--}

--CareerSkillTypeToIdList =
--{
--    -- 总督
--    [CareerSkillType.AdmiralTroopSkill] =
--    {
--        10002, -- 突袭
--        10011, -- 奇袭
--    }
--}

--CareerSkillState =
--{
--    Unknown = 0,
--    Ready = 1, -- 就绪
--    Using = 2, -- 激活
--    Used = 3, -- 冷却
--}
--QuestionAndAnswerType = {
--    Q_A_TYPE_NPC = 2,
--    Q_A_TYPE_NPC_ALL_RIGHT = 3,
--}

--GuideBuildState =
--{
--    Normal = 1, --正常状态-不在升级中、不需要连路、不是盒子状态、不是废墟
--    NeedConnect = 2, --修路状态-需要修路，不管是不是盒子或者废墟
--    Box = 3,--盒子状态-是盒子，不管是不是需要修路
--}
--FactoryIdToProductEffectId ={}
--FactoryIdToProductEffectId[BuildingTypes.FUN_BUILD_FOODSHOP] = EffectDefine.EFFECT_PRODUCT_QUEUE_ADD_711000
--FactoryIdToProductEffectId[BuildingTypes.FUN_BUILD_FOOD] = EffectDefine.EFFECT_PRODUCT_QUEUE_ADD_707000
--FactoryIdToProductEffectId[BuildingTypes.FUN_BUILD_FOOD_1] = EffectDefine.EFFECT_PRODUCT_QUEUE_ADD_717000
--FactoryIdToProductEffectId[BuildingTypes.FUN_BUILD_FOOD_2] = EffectDefine.EFFECT_PRODUCT_QUEUE_ADD_718000
--FactoryIdToProductEffectId[BuildingTypes.FUN_BUILD_OIL_REFINERY] = EffectDefine.EFFECT_PRODUCT_QUEUE_ADD_708000

--GuideNpcDoNextType =
--{
--    Auto = 0,--立刻做下一步
--    WaitWalk = 1,--等待走完/旋转完在做下一步
--    WaitWalkDelete = 2,--立刻做下一步,等待走完/旋转完立刻删除
--}

--SceneManagerSceneID =
--{
--    None = 0,
--    City = 1, -- 主城
--    World = 2, -- 世界
--    PVE = 3, -- PVE场景
--    Bridge = 4, -- 造桥
--    Barrel = 5, --躲避球
--}

--PveStatus =
--{
--    FirstStart = 0, -- 首次开始
--    MultiStart = 1, -- 多次开始
--    Finish = 2, -- 结束
--}

--CurScene =
--{
--    PVEScene = -99,
--}

--PveLevelType =
--{
--    NormalLevel = 1,
--    HeroExpLevel = 2, -- 英雄经验
--    FightLevel = 3,   -- 直接进入PVE战斗
--    NormalExpLevel = 4, -- 有经验水晶的普通关
--    BattleExpLevel = 5, -- 战斗经验关
--    RadarExpLevel = 6, -- 雷达经验关 (直接进入PVE战斗)
--    BattlePlayBackLevel = 7,--战斗回放关
--    AdventureLevel = 8, -- 星珲探险活动关
--    ZombieLevel = 9, -- 丧尸经验关
--    SkillLevel = 10,--砍树放技能关
--    ArmyLevel = 11, -- 带兵关卡
--    --CoinExpLevel = 12, -- 金币经验关
--    -------------------------
--    --LW---------------------
--    BarrageLevel = 12, -- 弹幕关卡
--    ZombieBattle = 20, -- lw丧尸战斗
--    -------------------------    
--    StoryLevel = 13, -- 推图关
--    GuideLevel = 14, -- 引导关卡
--}

--SU_PveLevelType =
--{
--    MainLevel = 1,--主线关卡
--    BranchLevel = 2,--支线关卡
--    HeroLevel = 3,--英雄关
--    RadarHeroLevel = 4, --雷达英雄关
--    StoryHeroLevel = 5, --剧情英雄关
--    AutoHeroLevel = 6,  --自动英雄关
--    ApsAutoLevel = 7,   --突突突关卡
--	ZombieBattle = 9, -- lw丧尸战斗
--    LandingPveLevel = 13, --登录作战
--	CountMaster = 101,
--    Barrel_Pve = 102, -- 房车pve
--    Barrel_Detect = 103, -- 雷达中躲避球关卡
--	
--    --LW---------------------
--    BarrageLevel = 12, -- 弹幕关卡
--    -------------------------
--}

---@class PveEntrance
PveEntrance =
{
	Test = 0, -- 测试
	LandLock = 1, -- 解锁地块
	Monument = 2, -- 英雄丰碑
	DetectEventPve = 3, -- 事件pve
	MonsterLock = 4,--
	MineCave = 5,--矿洞
	ArenaBattle = 6,--竞技场战斗
	ArenaSetting = 7,--竞技场设置阵容
	BattlePlayBack = 8,--战斗邮件回放
	Adventure = 9, -- 星珲探索活动
	AdventureSetting = 10, -- 星珲探索活动设置阵容
	LevelExplore = 11,
	PveAct = 12, -- 活动关卡
    Bridge = 13, -- 造桥
	Story = 14, -- 推图
	Guide = 15, -- 引导进pve
    BattlePve = 16, -- 房车PVE
    TowerClimb = 17, -- 爬塔
    LandingOperation = 18, --英雄战场
    TruckRob = 19, --卡车
    DetectEventTower = 20, --雷达爬塔
    DetectEventBarrelPve = 21, -- 雷达新的进入类型

    ApsTest = 100
}

--PveExitType =
--{
--    ExitBtn = 1,
--    DetectEventExitBtn = 2,
--    TowerupExitBtn = 3,
--}

--PveSweepType =
--{
--    No = 0,
--    Yes = 1,
--}

--ResPointType =
--{
--    Normal = 0,--普通矿
--    Alliance = 1,--联盟矿
--}

--PuzzleTaskState = {
--    PuzzleTaskState_UnComplete = 0,--0未完成
--    PuzzleTaskState_Complete = 1,--已完成可领奖
--    PuzzleTaskState_Reward_Get = 2,--已经领奖
--}

--PuzzleStageRewardState = {
--    PuzzleStageRewardState_UnGet = 0,--0未领奖
--    PuzzleStageRewardState_Get = 1,--已领奖
--}

--LandLockCondition =
--{
--    Unknown = 0, -- 正常情况不会遇到
--    Ok = 1,
--    NeedResource = 2, -- 需要资源
--    NeedItem = 3, -- 需要道具
--    NeedResourceItem = 4, -- 需要资源道具
--    NeedBuilding = 5, -- 需要建筑
--    NeedChapter = 6, -- 需要章节
--    NeedPrior = 7, -- 前驱节点未解锁，正常情况不会遇到
--    ToPay = 8, -- 付费
--    ToPve = 9, -- Pve
--    ToFinish = 10, -- 清理
--}

LookAtFocusState =
{
    None = 0,		--无聚焦
    FarmPlant = 1,	--聚焦农场
    PlaceBuild = 2,	--聚焦放置普通建筑
    EarthOrder = 3,	--聚焦地球订单
    Dome = 4,		--聚焦苍穹
    MoveCity = 5,	--聚焦迁城
    Formation = 6,	--聚焦出征
    BuildRoad = 7,	--聚焦修路
}

--PveBuffType =
--{
--    No = 0,--不显示
--    Speed = 1,--加移速
--    AttackAnim = 2,--旋风斩
--    WeaponBigger = 3,--武器变大
--    Player = 4,--获得一个小人
--    AttackQuick = 5,--频率上升
--    AddAttack = 6,--攻击上升
--    Stun = 7,--晕眩
--}

--PveBuffTimeType =
--{
--    Time = 1,--有持续时间
--    Always = 2,--一直生效
--}
--LandLockBubbleState =
--{
--    None = "None",
--    Hide = "Hide",
--    Locked = "Locked",
--    Unlocked = "Unlocked",
--    Pay = "Pay",
--    Pve = "Pve",
--    Bridge = "Bridge",
--}

--LandLockBubbleVisibleType =
--{
--    Hide = 1,
--    Show = 2,
--}

----pve关卡小人身后背的资源显示类型
--LandLockLevelShowCarryType =
--{
--Show = 0,
--No = 1,
--}

--LandLockRewardType =
--{
--    None = 0,
--    Chest = 1,
--    CallChest = 2,
--    CallSoldier = 3,
--    Call = 4, -- CallChest / CallSoldier
--}

--UIPveSelectBuffOrder = 
--{
--PveBuffType.AddAttack,
--PveBuffType.Speed,
--PveBuffType.Player,
--}

--PveResultShowType =
--{
--Normal = 0,
--Pass = 1,
--}

--LotteryTimeType = {
--    LotteryTimeType_Normal = "0",--普通招募
--    LotteryTimeType_Expert = "3",--高级招募
--}

--LotteryClassType = {
--    LotteryClassType_NORMAL = 100,--普通招募
--    LotteryClassType_Expert = 101,--高级招募
--}

--LotteryDisPlayType = {
--    LotteryDisPlayType_Normal_And_Expert = 1,--普通,高级招募
--}

--SaveBobSceneState =
--{
    --NoSave = 1, --没救
    --PlayTimeLine = 2, --正在救
    --Saved = 3,--已经救完
--}

--PveHasUseBattleHeroType =
--{
--    Any = 1, --没有任何可上阵英雄跳过
--    HeroId = 2, --该英雄不可上阵跳过（判断当前上阵最大数量）
--    HeroQuality = 3,--没有该稀有度英雄可上阵跳过
--    HeroIdWithoutMax = 4, --该英雄不可上阵跳过（不判断当前上阵最大数量）
--    HeroQualityWithoutMax = 5, --没有该稀有度英雄可上阵跳过（不判断当前上阵最大数量）
--}

--ExpSource =
--{
--    GM = 0,
--    Farming = 1, -- 农场
--    Factory = 2, -- 加工厂
--    Building = 3, -- 建筑
--    Science = 4, -- 科技
--    Army = 5, -- 士兵
--    Order = 6, -- 订单
--    Reward = 7, -- 奖励
--    Pasture = 8, -- 牧场
--    KillMonster = 9, -- 打怪
--}

--引导手指移动需不需要等待播1遍动画类型
--UIGuideMoveArrowNeedWaitType =
--{
--    No = 0,--不需要等 直接可以点击
--    Yes = 1,--需要等动画播放一遍后才可以点击
--}

--建筑状态（位表示法）
--BuildQueueState =
--{
--    DEFAULT = 0,--正常状态
--    TRAINING = 1,--训练/晋级士兵状态
--    CURE_ARMY = 2,--治疗伤兵
--    RESEARCH = 3,--研究科技
--    FARMING= 4,--种植
--    FEEDING= 5,--喂养
--    FACTORY= 6,--食品加工厂加工
--    STORAGE_SHOP = 7,--交易行
--    UPGRADE = 16,--建造/升级
--    Ruins = 128,--废墟状态
--}

--ConsumeType = {
--    ConsumeType_Nil = 0,
--    ConsumeType_Resource_Item = 1,
--    ConsumeType_Resource = 2,
--    ConsumeType_Item = 3,
--}

--英雄委托完成状态
--HeroEntrustState =
--{
--    No = 0,--未完成
--    Yes = 1,--全部完成
--}

--ResLackType = {
--    Res  = 1,       --资源  例:金币
--    Item = 2,       --道具
--    ResItem = 3,    --资源道具 ps:目前弃用
--    HeroExp = 4,    --英雄经验
--    Percent = 5,    --抗性
--    DesertNum = 6,  --地块
--    PveMonument = 7,--探险次数
--    MasteryPoint = 8,--专精不足
--    Equip = 9,      --装备
--    TitleSkin = 10, --称号
--    Favor = 11,     --好感度
--    MonthCard = 12, --月卡
--    HeroEquip = 13,--英雄装备
--    SeasonForce = 15, --赛季势力值
--    GarageCompon = 16,  --改装车组件
--}

--各种资源的获取方式
--ResLackGoToType =
--{
--    LoesCamp = 9,
--    ResourceBagUse = 11,
--    ResourceBagBuy = 12,
--    NoConditionShow = 26,--无条件显示
--    BuyGiftShop = 27,
--    LockedLandLockUncheck = 40,
--    BuildBuyItem = 41,
--    UsePaperItem = 42,
--    BuyGiftNew = 44,
--    Explore = 47,
--    BuyPveStamina = 48,
--    UseBuildGoods = 52,
--    ResBuyItem = 73,
--    GoActWin = 78,
--    DailyFreeEnergy = 79,
--    SeasonPass = 81,
--    SeasonWeek = 82,
--    BuyGiftGroup = 87,
--    ResourceBagBuyNew = 96,
--    ResourceHangup = 97,
--    LovelyFavor = 1005,
--    MonthCard = 1008,
--    EnergyBubble = 1011, --1011每日免费体力领取
--    HeroSPEquipItemExchange = 1012, --1012道具兑换（目前只有专武碎片）
--    HeroEquip = 2003,--装备工厂合成
--    HeroEquipItemCompose = 2004,--装备工厂合成
--    HeroEquipItemCollect = 2005,--收取材料
--    HeroEquipItemUse = 2006,--缺装备时使用道具
--    Activity = 2015, --日常活动
--    Dispatch = 2016, -- 英雄派遣
--    HeroBattlegroundsStore = 2017, -- 英雄战场商店
--    HeroEquipGift = 2018, -- 英雄装备礼包
--    StrongCommander = 2019, -- 最强执政官
--    HeroBattleActivity = 2020, --英雄战场活动界面
--    SPEquipCommonBuy = 2021, --买专武通用道具
--    SPEquipCommonShop = 2022, --买专武通用道具 商店途径
--    BuySkinShopTicket = 2023, --买皮肤劵 商店途径
--    BuyFirstPay = 9998,
--    BuyGiftResNew = 9999,
--    ShopBuyMoveCityCmn = 2031,--商店购买高级迁城
--    --赛季地块管理
--    GoSeasonMoreGround = 9001, --占领更多地块
--    GoSeasonHighGround = 9002, --占领更高等级地块
--    GoSeasonRadiate = 9003, --提升辐射抗性
--    GoSeasonGroundLimit = 9004, --提升地块上限
--    GoSeasonAllianceCenter = 9005, --放置联盟中心
--    
--    Exchange = 3001,
--}

--npc气泡对话框类型
--NpcTalkType =
--{
--    Left = 1,--左侧
--    Right = 2,--右侧
--    HeroEntrust = 3,--英雄委托
--}

--英雄委托消耗材料类型
--HeroEntrustNeedType =
--{
--    ResourceItem = 1,--资源道具
--    Resource = 2,--资源
--    Goods = 3,--道具
--}
--编队出征打完是否回家
--MarchAutoBackType =
--{
--    NoBack = 0,--不回家，停在原地
--    Back = 1,--回家
--}

--是否有联盟标志
--HaveAllianceType =
--{
--    Yes = 1,
--    No = 2,
--}

--npc气泡持续类型
--NpcBubbleStayType =
--{
--    Trigger = 1,--触发类型，靠近显示
--    All = 2,--一直显示
--    Time = 3,--过时间自动消失
--}

-- 星珲探险活动状态
--AdventureState =
--{
--    Ready = 1, -- 未进行过
--    Playing = 2, -- 正在进行
--    Won = 3, -- 刚刚胜利过
--    Lost = 4, -- 刚刚失败过
--}

--AdventureType =
--{
--    Default = 0,
--    Monster = 1, -- 怪物
--    Buff = 2, -- 增益
--    Reward = 3, -- 奖励
--    Box = 4, -- 箱子
--}

--AdventureRaidState =
--{
--    Ready = 1, -- 可以扫荡
--    NeedLevel = 2, -- 最高关卡数不够
--    Started = 3, -- 关卡已经开始
--    LevelMaxed = 4, -- 已达最高关卡
--}

--PveLoadingAnimType =
--{
--    Black = 1,
--    Yellow = 2,
--    Circle = 3,
--}

--BattleBuffGroup =
--{
--    Default = 0,
--    Adventure = 1,
--}

--BattleBuffType =
--{
--    Effect = 0, -- 作用号
--    Skill = 1, -- 技能
--    AdventureHp = 2, -- 探索活动加减血
--    DisableHero = 3, -- 禁用英雄
--    HireHero = 4, -- 雇佣英雄
--}

--BattleBuffTimeType =
--{
--    Normal = 0, -- 永久
--    Battle = 1, -- 战斗次数
--    Time = 2, -- 时间限制
--}

--HeroAdvanceConsumeType = {
--    ConsumeType_Same_Hero = 1,
--    ConsumeType_Same_Camp = 2,
--}

--资源采集特效名字
--ResourceTypePickUpEffectName = {}
--ResourceTypePickUpEffectName[ResourceType.Electricity] = "Assets/_Art_LastDay/Effect/Prefab/UI/VFX_ziyuanshouqu_shandian.prefab"
--ResourceTypePickUpEffectName[ResourceType.Metal] = "Assets/_Art_LastDay/Effect/Prefab/UI/VFX_ziyuanshouqu_shuijing.prefab"
--ResourceTypePickUpEffectName[ResourceType.Oil] = "Assets/_Art_LastDay/Effect/Prefab/UI/VFX_ziyuanshouqu_wasi.prefab"
--ResourceTypePickUpEffectName[ResourceType.Water] = "Assets/_Art_LastDay/Effect/Prefab/UI/VFX_ziyuanshouqu_water.prefab"
--ResourceTypePickUpEffectName[ResourceType.Money] = "Assets/_Art_LastDay/Effect/Prefab/UI/VFX_ziyuanshouqu_jinbi.prefab"

--成功出征的标志
--SuccessMarchFlagType =
--{
--    No = 0,--未成功出征
--    Yes = 1,--成功出征
--}

--假玩家显示的类型
--ShowFakePlayerFlagType =
--{
--    Show = 1,--显示
--    Hide = 2,--删除
--}

--pve建筑商店触发点方向
--PveBuildTriggerDirection =
--{
--    Bottom = 1,--下方
--    Left = 2,--左方
--    Top = 3,--上方
--    Right = 4,--右方
--}

--世界垃圾点显示类型
--ShowWorldCollectPointType =
--{
--    Show = 1,--显示
--    Hide = 2,--隐藏
--}

--引导设置出征特殊类型
--SetAttackGuideFlag =
--{
--    NoBackAndWaitResult = 1,--攻击后不回家，直接出征省略最高等级判断并等待出征结果
--    WaitResult = 2,--攻击后回家，直接出征省略最高等级判断并等待出征结果
--}

--引导设置气泡显示/隐藏
--BubbleShowType =
--{
--    Show = 1,--显示
--    Hide = 2,--隐藏
--}

--AccountViewType =
--{
--    Bind = 1,--绑定账号
--    Question = 2,--调查问卷
--}


--引导设置坦克显示/隐藏
--TankShowType =
--{
--    Show = 1,--显示
--    Back = 2,--隐藏
--}

--引导设置加载遮罩界面显示/消失
--ShowLoadMaskType =
--{
--    Show = 1,--显示
--    Hide = 2,--消失
--}

--WeekType =
--{
--    "372307",
--    "372308",
--    "372309",
--    "372310",
--    "372311",
--    "372312",
--    "372313",
--}

--NoticeEquipDelays =
--{
--    --[UIWindowNames.UIRecruitLotteryTip] = 3,
--    --[UIWindowNames.UISoliderGetTip] = 3,
--    --[UIWindowNames.UIGarageRefit] = 3,
--}

--shader类型
--ShaderEffectType =
--{
--    ShakeWhite = 1,--砍树闪白
--}
--引导多语言参数特殊类型
--GuideTalkDialogType =
--{
--    AllianceName = 1, --获取联盟名字
--}

--引导设置地块显示/消失
--ShowLandLockType =
--{
--    Show = 1,--显示
--    Hide = 2,--消失
--}

--引导设置触发点显示/消失
--PveTriggerVisibleType =
--{
--    Show = 1,--显示
--    Hide = 2,--消失
--}
--引导设置物体显示通用枚举
--GuideSetNormalVisible =
--{
--    Show = 1,--显示
--    Hide = 2,--消失
--}

NewMarchType =
{
    DEFAULT =-1,--初始状态
    NORMAL = 0, --0 普通出征
    ASSEMBLY_MARCH = 1, --1 联盟出征
    MONSTER = 2, -- 2 怪物
    BOSS = 3,-- 3 BOSS
    SCOUT = 4,--4 侦查
    EXPLORE = 5,--5 探索
    RESOURCE_HELP = 6,--6资源援助
    GOLLOES_EXPLORE = 7,--7咕噜探索
    GOLLOES_TRADE = 8,--8咕噜商队
    ACT_BOSS = 9, --9 活动BOSS
    PUZZLE_BOSS = 10, --10 拼图BOSS
    DIRECT_MOVE_MARCH = 11, --11 非自由行军，不可操作
    CHALLENGE_BOSS = 12,--12 挑战BOSS    
    MONSTER_SIEGE = 13,--13 黑骑士攻城
    ALLIANCE_BOSS = 14, --14 联盟boss
    TRAIN=15, -- 卡车
    ASSEMBLY_MARCH_NOT_ATTACK = 16, --无法攻击的集结编队
    GodzillaGift = 17, --大boss的奖励
    DRAGON_MARK_SHARE = 18, --巨龙标记分享
    DRAGON_POINT_SHARE = 19, --巨龙点分享
}

--主城内小车和人显示类型
--CityPeopleAndCarVisibleType =
--{
--    AllShow = 1,--全部显示
--    AllHide = 2,--全部隐藏
--}

--pve触发点需要交付的类型
--TriggerNeedType =
--{
--    Resource = 1,--资源
--    ResourceItem = 2,--资源道具
--    Goods = 3,--物品
--}

--小人攻击
--AttackAnimDirection =
--{
--    LeftToRight = 1,--左到右
--    RightToLeft = 2,--右到左
--    Circle = 3,--旋风斩一圈
--}

--pve砍的资源类型
--PveAtomType =
--{
--    Tree = 0,--树
--    Stone = 1,--石头
--}

--LevelExploreState =
--{
--    Hide = 1, -- 隐藏
--    Doing = 2, -- 进行中
--    Locked = 3, -- 锁定
--    Finish = 4, -- 已完成，可重复进入
--    Sweep = 5, -- 已完成，可扫荡
--}

--LevelExploreSpecial =
--{
--    -- must < 0
--    HeroExp = "exp",
--    Activity = "activity",
--}

--引导设置物体显示通用枚举
--PveShowBloodType =
--{
--    No = 0,--不显示
--    Show = 1,--显示
--}

--建筑最大可建造数量类型
--BuildMaxNumType =
--{
--    Cur = 1,--当前可建造最大
--    Guide = 2,--引导可建造最大
--    Quest = 3,--任务可建造最大
--    Chapter = 4,--章节可建造最大
--}

--pve配置初始是否可以显示技能
--PveShowSkill =
--{
--    Show = 0,--可以显示
--    No = 1,--不显示
--}

--FactoryDataType = {
--    FactoryDataType_Normal = 0,--普通加工厂
--    FactoryDataType_PVE = 1,--pve加工厂
--}
--FactoryProductType = {
--    FactoryProductType_Resource_Item = 0,--resourceItem,这个不是填表的，前台自己定义
--    FactoryProductType_Item = 1,--道具
--    FactoryProductType_Resource = 2,--资源
--    FactoryProductType_Score = 3,--关卡排行榜积分
--}

--LevelState =
--{
--    Init = 0,
--    RequestInfo = 1, -- 发送开始关卡消息，等待服务器返回
--    Created = 2,     -- 创建关卡
--    Destroying = 3,  -- 退出关卡，等待主城或世界创建完成
--    Destroyed = 4    -- 销毁关卡
--}

--HeroAdvanceGuideSignalType =
--{
--    Enter = 1,--进入英雄进阶引导（重新布局、排序）
--    ShowMainHeroBlack = 2,--显示进阶英雄黑色遮罩
--    HideMainHeroBlack = 3,--隐藏进阶英雄黑色遮罩
--    ShowSubHeroBlack = 4,--显示消耗海报黑色遮罩
--    HideSubHeroBlack = 5,--隐藏消耗海报黑色遮罩
--    ShowHeroStarUpBlack = 6,--显示升星黑色遮罩
--    HideHeroStarUpBlack = 7,--隐藏升星黑色遮罩
--}

--FogType =
--{
--    Black = 0,--黑色迷雾（关卡规则默认都有迷雾）
--    White = 1,--白色迷雾（关卡规则默认打开迷雾）
--}

--QuestBubbleType =
--{
--    None = 0,
--    World = 1,  --世界
--    Pve = 2,    --pve
--}

--ActMonsterTowerDiff =
--{
--    [1] = "G_js_huizhang01",
--    [2] = "G_js_huizhang02",
--    [3] = "G_js_huizhang03",
--    [4] = "G_js_huizhang04",
--    [5] = "G_js_huizhang05",
--    [6] = "G_js_huizhang06",
--    [7] = "G_js_huizhang07",
--    [8] = "G_js_huizhang08",
--    [9] = "G_js_huizhang09",
--}
--火箭状态
--RocketStatus = {
--    RocketStatus_Normal = 0,--正常可用状态
--    RocketStatus_Preview = 1,--预览状态，只能看不能提交
--}
MainBuildOrder = {
    Other = 21, --其他
    Enemy = 22, --敌人
    Ally = 23, --盟主
    Leader = 24, --盟友
    Self = 25, --自己
}
ForceChangeScene = {
    City = 0,
    World = 1
}
PlayerType = {
    PlayerNone = -1, -- 无
    PlayerSelf = 0, -- 自己
    PlayerAlliance = 1, -- 盟友
    PlayerOther = 2, -- 敌人
    PlayerAllianceLeader = 3, -- 盟主
}
--PveSelectionType =
--{
--    Trigger = 1,
--    DropReward = 2,
--}

--联盟中心状态
--AllianceBuildingStatus =
--{
--    Normal = 0,--正常态
--    Upgrade = 1,--升级中
--    Destroy = 2,--摧毁
--}

--客户端通用需要消耗材料类型
--CommonCostNeedType =
--{
--    Resource = 1,--资源
--    ResourceItem = 2,--资源道具
--    Goods = 3,--道具
--    Build = 4,--建筑
--    Science = 5,--科技
--    RefreshAll = 100,--刷新所有
--}

--产出资源道具类建筑
--ProductResourceItemBuildingTypes =
--{
--    BuildingTypes.FUN_BUILD_OUT_WOOD,
--    BuildingTypes.FUN_BUILD_OUT_STONE,
--    BuildingTypes.FUN_BUILD_HERO_MONUMENT,
--    BuildingTypes.FUN_BUILD_LIBRARY,
--    BuildingTypes.FUN_BUILD_WATER,
--    BuildingTypes.DS_EQUIP_MATERIAL_FACTORY,     -- 
--    BuildingTypes.DS_EQUIP_SMELTING_FACTORY,     --
--    BuildingTypes.DS_EQUIP_SMELTING_FACTORY2,    --
--}

--UIBuildDetailTabType =
--{
--    Build = 1,--显示建筑页
--    Detail = 2,--直接显示属性页
--}

LodType =
{
    None = 0,
    Custom = 1,
    MainSelf = 1001,
    MainAlly = 1002,
    MainOther = 1003,
    WormHoleSelf = 1004,
    WormHoleAlly = 1005,
    WormHoleOther = 1006,
    Monster = 2001,
    Resource = 2002,
    Explore = 2003,
    Sample = 2004,
    Garbage = 2005,
    MonsterReward = 2006,
    RadarPve = 2007,
    WorldBoss = 2008,
    TroopSelf = 3001,
    TroopAlly = 3002,
    TroopOther = 3003,
    Ground = 4001,
    Zone = 4002,
    CityLabel = 5001,
    WorldCity = 5002,
    Desert = 5003,
    WorldAllianceBuild = 5004,
    WorldAllianceFlag = 5005,
    NPCCity = 5006,
    DisPatchTask = 2001,
    MainEnemy = 5007,
    WormHoleEnemy = 5008,
    NpcCity = 5009,
	WorldTree = 5011,		-- 树
	WorldTreeBottom = 5012,  -- 树底片
	WorldShan = 5020, -- 山
	WorldWater = 5021, -- 湖
	WorldTian = 5030, -- 农田
	WorldRoad = 5031, -- 路
    DisPatchTaskIdle = 5042,
    SeasonBuilding = 5043, --赛季建筑
    SeasonBuilding2 = 5044, --赛季建筑
}

--BuildBanMoveType =
--{
--    Yes = 0,--可以移动
--    No = 1,--不可移动
--}
--TODO LastOne人物动画
--PlayerAnimationName = {
--    Idle = "std_kongshou",
--    Walk = "walk_kongshou",
--    Run = "move_kongshou",
--    Attack = "atk1_kongshou",
--    Pick = "Pick",
--    Dig = "Dig",
--    Dead = "die",
--    SneakWalk = "sneak_move_danshou",
--    SneakIdle = "sneak_std_danshou",
--    Cut = "Cut",
--    CutIdle = "CutIdle",
--    weakenIdle = "weakenIdle",
--    weakenWalk = "weakenWalk",
--    Build = "Build",
--    Idle_KongShou = "idle_kongshou",
--    StrideOver = "StrideOver",
--    OpenBox = "OpenBox",
--    Duck = "Duck",
--}
--c_animations表中的类型
AnimationType = {
    Idle = "idle",
    Move = "move",
    Attack = "attack",
    SneakIdle = "sneakIdle",
    SneakMove = "sneakMove",
    InertialIdle = "intertialIdle",
    Sneak = "sneak",
    Run = "walk",
    WeakenWalk = "weakenWalk",
    Dead = "dead",
    DeadEnd = "deadEnd"
}

--路状态
--RoadState =
--{
--    Normal = 0,--正常
--    Updating = 1,--升级
--}

--RoadPathType =
--{
--    NORMAL = 0,-- 普通路
--    VIADUCT = 1,-- 高架桥
--    MAIN_ROAD = 2-- 主路
--}

--RoadDirectType =
--{
--    None = -1,--没有
--    HORIZONTAL = 0,-- 横向 - 高架桥
--    PORTRAIT = 1,-- 纵向 - 高架桥
--    WEST_TO_EAST = 2,-- 自西向东 - 主干道
--    EAST_TO_WEST = 3,-- 自东向西 - 主干道
--    NORTH_TO_SOUTH = 4,-- 自北向南 - 主干道
--    SOUTH_TO_NORTH = 5-- 自南向北 - 主干道
--}

--DomeRange =
--{
--    Zero = 0,
--    Min = 3,
--    Middle = 1,
--    Max = 2,
--}

--LandLockUnlockAnim =
--{
--    None = 0,
--    ChopTree = 1,
--    SoldierWalk = 2,
--}

--苍穹等级
--DomeLevel =
--{
--    [DomeRange.Zero] = 0,
--    [DomeRange.Min] = 1,
--    [DomeRange.Middle] = 2,
--    [DomeRange.Max] = 3,
--}

--DomeRadius =
--{
--    [DomeRange.Zero] = 0,
--    [DomeRange.Min] = 18,
--    [DomeRange.Middle] = 34,
--    [DomeRange.Max] = 44,
--}

--LandLockDomeExRadius =
--{
--    [DomeRange.Zero] = 0,
--    [DomeRange.Min] = -1.2,
--    [DomeRange.Middle] = -1.2,
--    [DomeRange.Max] = -1.0,
--}

ResourceItem =
{
    Wood = 10000,
    Stone = 10001,
    Metal = 300041,
    PoliceInsignia = 200034, -- 警徽
    DroneMaterialDrawing = 230111, -- 无人机升级材料图纸
    DroneMaterialWrench = 230112, -- 无人机升级材料扳手
}

--ResExchangeResItem =
--{
--    [ResourceType.Metal] = ResourceItem.Stone,
--    [ResourceType.Wood] = ResourceItem.Wood,
--    [ResourceType.LM_metal] = ResourceItem.Metal,
--}

--UIHeroStarProgressType = {
--UIHeroStarProgressType_Slider = 1,
--UIHeroStarProgressType_Block = 2,
--}

--GuideSceneType = {
--City = 1,
--World = 2,
--Pve = 3,
--}

--GuideUIBuildListSpecialType = {
--OpenUI = 1,
--Move = 2,
--}

--GuideMaskType = 
--{
--UIPveMainResource = 1,
--UIPveMainStaminaSlider = 2,
--UIPveMainBag = 3,
--}

--GuideMaskTypeSignalType =
--{
--UIPveMainResourceShow = 101,--显示pve主界面资源条黑色遮罩
--UIPveMainResourceHide = 102,--隐藏pve主界面资源条黑色遮罩
--UIPveMainStaminaSliderShow = 104,--显示pve主界面体力条黑色遮罩
--UIPveMainStaminaSliderHide = 105,--隐藏pve主界面体力条黑色遮罩
--UIPveMainBagShow = 106,--显示pve主界面背包黑色遮罩
--UIPveMainBagHide = 107,--隐藏pve主界面背包黑色遮罩
--}

--UIMainTopBtnType =
--{
--    Stamina = "Stamina",--体力条
--    Goods = "Goods",--背包
--    Gold = "Gold",--钻石
--    Army = "Army",--士兵数量
--    ArmyTrap = "ArmyTrap",--陷阱数量
--}



--PvePowerLackType =
--{
--    None = 0,
--    Power = 1,
--    Army = 2,
--    Hero = 3,
--    Fail = 4,
--    ArenaPve = 5,
--}

--PvePowerLackTipType =
--{
--    HeroExpBook = 53,
--    HeroUpgradeRank = 54,
--    HeroUpgradeStar = 55,
--    HeroUpgradeSkill = 56,
--    TrainUnit = 57,
--    HeroHigherLevel = 58,
--    HeroHigherPower = 59,
--    HeroBeyond = 60,
--    FirstPay = 61,
--    MainQuest = 62,
--    HeroExpLevel = 65,
--    HeroRecruit = 71,
--    HeroMonthCard = 74,
--    GiftPackage = 80,
--    UpgradeBuilding = 91,
--    GiftRecommend = 2013,
--    GetHeroExpBook = 2014,
--    
--    -- 前端自用，策划不配，-x 代表套用 x 的配置
--    HeroExpOrBeyond = -53,
--    PutOnHeroEquip = 100001,
--}

--PvePowerLackShowTips =
--{
--    [PvePowerLackType.Power] =
--    {
--        PvePowerLackTipType.HeroExpBook,
--        PvePowerLackTipType.HeroUpgradeRank,
--        PvePowerLackTipType.HeroUpgradeStar,
--        PvePowerLackTipType.HeroUpgradeSkill,
--        PvePowerLackTipType.TrainUnit,
--        PvePowerLackTipType.HeroHigherPower,
--        PvePowerLackTipType.HeroBeyond,
--        PvePowerLackTipType.FirstPay,
--        PvePowerLackTipType.HeroExpLevel,
--        PvePowerLackTipType.HeroRecruit,
--        PvePowerLackTipType.HeroMonthCard,
--    },
--    [PvePowerLackType.Army] =
--    {
--        PvePowerLackTipType.TrainUnit,
--    },
--    [PvePowerLackType.Hero] =
--    {
--        PvePowerLackTipType.HeroExpBook,
--        PvePowerLackTipType.HeroUpgradeRank,
--        PvePowerLackTipType.HeroHigherLevel,
--        PvePowerLackTipType.HeroBeyond,
--        PvePowerLackTipType.HeroExpLevel,
--    },
--    [PvePowerLackType.Fail] =
--    {
--        PvePowerLackTipType.HeroExpBook,
--        PvePowerLackTipType.GetHeroExpBook,
--        PvePowerLackTipType.HeroUpgradeRank,
--        PvePowerLackTipType.HeroUpgradeStar,
--        PvePowerLackTipType.TrainUnit,
--        PvePowerLackTipType.FirstPay,
--        PvePowerLackTipType.HeroExpLevel,
--        PvePowerLackTipType.HeroRecruit,
--        PvePowerLackTipType.HeroMonthCard,
--        PvePowerLackTipType.GiftPackage,
--        PvePowerLackTipType.UpgradeBuilding,
--        PvePowerLackTipType.GiftRecommend,
--    },
--    [PvePowerLackType.ArenaPve] =
--    {
--        PvePowerLackTipType.HeroExpBook,
--        PvePowerLackTipType.HeroUpgradeStar,
--        PvePowerLackTipType.HeroRecruit,
--        PvePowerLackTipType.TrainUnit,
--        PvePowerLackTipType.PutOnHeroEquip,
--    },
--}


--引导结束主UI任务是否弹出
--GuideEndShowQuestType =
--{
--    Show = 0,--弹出显示任务
--    No = 1,--不显示任务
--}

--显示世界上箭头类型
--ShowWorldArrowType =
--{
--    FarmGet = 1,--可以收获的农田显示黄色箭头
--    FarmFree = 2,--空闲的农田显示黄色箭头
--}


--BuildListBuffType = {
--    BuildListBuffType_SpeedUp = 1,--加速
--    BuildListBuffType_Free = 2,--免费时间
--    BuildListBuffType_Max = 3,--终止
--}

--HeroLackTipsType = {
--    HeroLackTipsType_Recruit = 1,--招募
--    HeroLackTipsType_Debris_Exchange = 2,--碎片兑换
--    HeroLackTipsType_First_Charge = 3,--首冲，大小姐
--    HeroLackTipsType_Promotion_Gift_Bag = 4,--type16促销礼包
--    HeroLackTipsType_Recharge_Gift_Bag = 5,--商城充值活动
--    HeroLackTipsType_Activity = 6,--活动中心
--    HeroLackTipsType_Detect_Event = 7,--雷达事件
--    HeroLackTipsType_Vip = 8,--vip尊享
--}

--装扮类型
--DecorationType = {
--    DecorationType_Main_City = 1,--大本
--    DecorationType_Head_Frame = 2,--玩家头像框
--    DecorationType_TittleName = 3,--玩家称号
--    DecorationType_MarchSkin = 4,--玩家运兵车皮肤
--}
--装扮获取类型
--DecorationGainType = {
--    DecorationGainType_Item_Exchange = 0,--物品兑换
--    DecorationGainType_Default = 1,--默认拥有
--    DecorationGainType_Month_Card = 2,--月卡使用获得
--    DecorationGainType_Female = 3,--女性皮肤
--    DecorationGainType_Champions = 4,--冠军对决
--    DecorationGainType_Arena = 5,--竞技场
--    DecorationGainType_OfficialPosition = 6,--官职
--}
--行军预制体类型
MarchPrefabType =
{
    Self = 1,--自己（绿色）
    Alliance = 2,--盟友（蓝色）
    Camp = 3,--同阵营（黄色）
    Other = 4,--敌人（红色）
}
--DecorationQuality = {
--    DecorationQuality_Normal = 1,
--    DecorationGainType_Rare = 2,
--    DecorationGainType_Epic = 3,
--    DecorationGainType_Legend = 4,
--
--}

--AutoFarmStatus = {
--    AutoFarmStatus_FREE = 0,-- 空闲
--    AutoFarmStatus_PRODUCT = 1,-- 生产中
--}

--AutoFarmType = {
--    AutoFarmType_FREE = 0,-- 空闲
--    AutoFarmType_FARM = 1,-- 农场
--    AutoFarmType_PASTURE = 2,-- 牧场
--    AutoFarmType_FACTORY = 3,-- 加工厂
--}

--AutoFarmNpcStatus = {
--    AutoFarmNpcStatus_ALL_FREE = 1,--所有空闲
--    AutoFarmNpcStatus_PRODUCTING = 2,--制作中
--    AutoFarmNpcStatus_WAITING_FOR_GATHER = 3,--等待收获
--}

--GuideMoveSeasonDesertType =
--{
--    OwnLevel = 1,--自己拥有配置等级地块
--    Block = 2, --自身占领最近的空地
--    AllianceBlock = 3, --视口联盟城最近的空地
--    Any = 4,--任意自己拥有的地块
--}

--BuildStatusType =
--{
--    TimeBase = 0, -- 时间生效
--    FrequencyBase = 1, -- 次数生效
--}

--BuildStatusType2 =
--{
--    Default = 0,
--}

--FormStatusType =
--{
--    TimeBase = 0, -- 时间生效
--    FrequencyBase = 1, -- 次数生效
--}

--FormStatusType2 =
--{
--    Default = 0,
--    DirectAttackCity = 1, -- 奇袭
--    MarchBuff =2, --急救
--    
--}

--FormationName =
--{
--    [1] = "302032",
--    [2] = "302033",
--    [3] = "302034",
--}

--RechargeType =
--{
--    Normal = 0,
--    KeepPay = 1,
--    Daily = 2
--}

--ChainPayBoxState =
--{
--    Default = 0,
--    Unlocked = 1,
--    Received = 2,
--}

---遗迹城归属：我方/敌方/无主
--SeasonDesertCity =
--{
--    Alliance = "1",--我方
--    Other = "2", --敌方
--    Block = "3",--无主
--}
--LuckyShopItemType = {
--    LuckyShopItemType_Resource = 1,--资源
--    LuckyShopItemType_Item = 2,--物品
--}

--SpeedUpType =
--{
--    Build = 1,
--    Science = 2,
--}

--性别
--SexType =
--{
--    None = 0,--没选性别
--    Man = 1, -- 男性
--    Woman = 2, -- 女性
--    NotShow = 3, -- 不显示
--}

--收藏名字显示类型
--BookMarkNameArrCountType =
--{
--    Default = 1,--传啥显示啥
--    WithDialog = 2,--使用多语言
--    WithLevelDialog = 3,--使用带等级的多语言
--}

--CampEffectType =
--{
--    None = 0,
--    Fetter_3 = 1,
--    Fetter_3_2 = 2,
--    Fetter_4 = 3,
--    Fetter_5 = 4,
--}

--CampEffectKey =
--{
--    Damage = 1,
--}

--HeroIntensifySlotType =
--{
--    Normal = 0,
--    Random = 1,
--}

--HeroIntensifyCostType =
--{
--    Poster = 1, -- 海报
--    Medal = 2, -- 勋章
--    Open = 3, -- 解锁
--}

--HeroIntensifyTabState =
--{
--    Normal = 1,
--    Hide = 2,
--    NeedBuildingLevel = 3,
--    NeedSeason = 4,
--    NeedHeroMaxed = 5,
--}

--HeroIntensifyState =
--{
--    Normal = 1,
--    Unlocked = 2,
--    ToRandom = 3,
--    NeedBuildingLevel = 4,
--    NeedSeason = 5,
--}

--分享战报战斗结果类型
--ShareFightMailResultState =
--{
--    Fail = "0",--输了
--    Win = "1",--赢了
--    Draw = "2",--平局
--}
--DecorationActivityRewardState = {
--    DecorationActivityRewardState_Normal = 0,--
--    DecorationActivityRewardState_Can_Receive = 1,--可领取
--    DecorationActivityRewardState_Received = 2,--已经领取
--}

--GloryPeriod =
--{
--    None = 0,
--    Unopened = 1, -- 未开始
--    Prepare = 2, -- 准备期
--    Start = 3, -- 入侵期
--    Settle = 4, -- 结算期
--}

--GloryDeclareType =
--{
--    Match = 1, -- 匹配
--    List = 2, -- 列表
--}

--GloryBattleState =
--{
--    None = 0, -- 未宣战
--    Before = 1, -- 未开始
--    Ongoing = 2, -- 正在进行
--    After = 3, -- 已结束
--}

--GloryBattleResult =
--{
--    None = 0,
--    Win = 1,
--    Lose = 2,
--}

--GloryBattleDetailType =
--{
--    Default = 0, -- 默认
--    PlaceFlag = 1, -- 放置前线阵地
--    FoldUpFlag = 2, -- 收起前线阵地
--    Occupy = 3, -- 战力土地
--    CrashBuilding = 4, -- 摧毁建筑
--    CrashCenter = 5, -- 摧毁联盟中心
--    Win = 6, -- 胜利
--    MISSILE_ATTACK_MAIN = 7,--7 导弹炸大本
--}

--CommonDirection =
--{
--    LeftDown = 1,--左下
--    RightDown = 2,--右下
--    RightTop = 3,--右上
--    LeftTop = 4,--左上
--}
--1授权  2拒绝(未设置)   3永久拒绝
--PermissionType =
--{
--    Accept = 1,
--    Request = 2,
--    Refuse = 3
--
--}

--GlorySeverType =
--{
--    Self = 1,--自己的服务器
--    Opponent = 2,--宣战的服务器
--    Other = 3,--其他服务器
--
--}

--GloryScoreRankType =
--{
--    Season = 0,--查看赛季贡献
--    Week = 1,--查看周贡献
--}

--个人贡献详情类型
--GloryContributionType =
--{
--    OCCUPY_DESERT = 1,--占领地块积分
--    SEASON_BUILDING = 2,--升级赛季建筑积分
--    DONATE_ALLIANCE_STORE = 3,--捐献联盟石头
--    DECLARE_SCORE = 4,--宣战积分
--    OCCUPY_ENEMY_DESERT = 5,--占领敌人地块
--}

--宣战记录类型
--DeclareRecordType =
--{
--    Alliance = 1,--本盟宣战记录
--    ServerZone = 2,--战区宣战记录
--}

--GloryDeclareRecordWinType =
--{
--    Win = 1,
--    Lose = 0
--}

--GloryDeclareRecordKoType =
--{
--    No = 0,
--    Ko = 1,
--}

--GloryDeclareRecordAtkType =
--{
--    Attack = 1,--进攻方
--    Defence = 2,--防守方
--}

--GloryInfoTab =
--{
--    None = 0,
--    Summary = 1, -- 数据统计
--    SummaryHistory = 2, -- 历史数据统计
--    Rank = 3, -- 玩家排名
--    RankHistory = 4, -- 历史玩家排名
--    History = 5, -- 战斗详情
--}

--MasteryCondType =
--{
--    And = 0,
--    Or = 1,
--}

--MasteryCdType =
--{
--    Countdown = 1, -- 冷却时间（秒）
--    Everyday = 2, -- 每天重置
--}

--MasteryCdShow =
--{
--    Sec = 1,
--    Min = 2,
--    Hour = 3,
--}

--MasteryHome =
--{
--    Gather = 101,
--    Build = 102,
--    Battle = 103,
--}

--MasteryHomeTitle =
--{
--    [MasteryHome.Gather] = 110716,
--    [MasteryHome.Build] = 110717,
--    [MasteryHome.Battle] = 110718,
--}

--MasteryTipState =
--{
--    None = 0,
--    CanLearn = 1,
--    Maxed = 2,
--    NeedLv = 3,
--    NeedPoint = 4,
--    NeedPrior = 5,
--    Closed = 6,
--}

--MasteryNodeState =
--{
--    Hide = "hide",
--    Off = "off",
--    On = "on",
--}

--MasterySkillState =
--{
--    None = 0,
--    Normal = 1,
--    Locked = 2,
--    CD = 3,
--    Closed = 4,
--    NoUse = 5,
--}

--MasterySkill =
--{
--    Thrive = 1001, -- 兴盛
--    MasteryReward = 1002, -- 专精奖励
--    RapidMine = 1004, -- 急速开采
--    IndustrialDevelop = 1005, -- 工业开发
--    Demolition = 1007, -- 强拆
--    BuildingShield = 1009, -- 坚盾
--    BattleSupply = 1010, -- 站场补给
--    Landmine = 1011, -- 地雷
--    RapidRepair = 1013, -- 快速维修
--    Harvest = 1018, -- 丰收
--    QuickCollect = 1019, -- 强征
--    ProductGarrison = 1020, -- 屯田
--    RandomAddAttack = 1016, -- 振奋
--    RecoverMarch = 1017,--急救
--}

--MasterySkillLocation =
--{
--    None = 0,
--    ActiveSkill = 1, -- 在主动技能中显示
--    WorldBuild = 2, -- 在建筑弹板显示
--    WorldDesert = 3, -- 在地块弹板显示
--    WorldFormation = 4,--在编队上显示
--}

--DesertOperateBtnState =
--{
--    None = 0,
--    Green = 1,
--    Yellow = 2,
--    Gray = 3,
--}

--DesertAnnexItemType =
--{
--    None = 0,
--    Mine = 1,
--    BuildStatus = 2,
--}

--WeekDayName =
--{
--    [1] = "302789",
--    [2] = "302790",
--    [3] = "302791",
--    [4] = "302792",
--    [5] = "302793",
--    [6] = "302794",
--    [7] = "302795",
--}

--黑骑士活动状态
--BlackKnightState =
--{
--    END = 0,-- 整体活动结束或未开始
--    READY = 1, --1 整体活动开始，未开启迎战
--    OPEN = 2, --2 联盟开启迎战
--    CLOSING = 3, --3 联盟出怪结束等待发积分目标奖励邮件和活动结束邮件
--    REWARD = 4, --4 等待发奖
--    CLOSED = 5, --5 联盟的活动结束邮件和积分目标奖励邮件已发完
--
--    --客户端显示用
--    NoAlliance = 100,--没有联盟
--}

--黑骑士活动玩家状态
--BlackKnightUserState =
--{
--    NORMAL = 0,-- 本期未参加过活动
--    ACTIVITY_JOIN = 1, --1 本期在本盟已参加活动（不区分活动是否结束，只要参加了就是1）
--    ORDER_ALLIANCE_ACTIVITY = 2, --2 本期在别的盟已经参加过活动了（不区分之前那个盟的活动是否结束，只要参加了就是2）
--}

--黑骑士活动警告状态
--BlackKnightWarningState =
--{
--    Open = 0,                 --开启预警
--    Close = 1,                  --关闭预警
--}

--任务表list类型
--QuestListType =
--{
--    None = 0,
--    List1 = 1,
--    List2 = 2,
--}

--RedEnvelopeType =
--{
--    Build = 1,
--    Gift = 2,
--    ActReward = 3,
--    JoinPortrait  = 4,--加入竖版用户发送的联盟红包
--}

--可跨服的建筑
--CrossBuildType =
--{
--    BuildingTypes.WORM_HOLE_CROSS,
--}

-- 联盟捐兵黑骑士活动状态
--AllianceDonateState =
--{
--    Waiting = 0, --客户端用
--    Attaking = 1,
--    End = 2,
--    Victory = 3,
--    Lose = 4,
--}

-- 怪物表special含义
--MonsterSpecialType =
--{
--    None = 0, --
--    ActBoss = 2,
--    PuzzleBoss = 3,--拼图活动怪物
--    ChallengeBoss = 4,--挑战活动怪物
--    BlackKnight = 5,--黑骑士活动怪物
--    ExpeditionaryDuel = 6,--远征活动怪物
--    AllianceBoss = 8,--联盟boss
--    RadarBoss = 9,
--}

-- 士兵死亡原因类型
--ArmyDeadType =
--{
--    Hospital = 0, --医院爆仓死亡
--    Fight = 1,--战斗死亡
--}

--MissileIDs = {
--    ALLIANCE_FIGHT_SEND_MISSILE = "53307",
--}

--MigrateApplyType = 
--{
--    APPLY = 0, --申请
--    AGREE = 1, --批准
--    REFUSE = 2, --拒绝
--    MIGRATE = 3, --成功移民
--}

--ApproveMigrateState = {
--    AGREE = 1,
--    REFUSE = 2,
--}

-- 造桥关卡结果
--BridgeLevelResult =
--{
--    Failed = 0,
--    Victory = 1,
--}

--MigrateShowItem = 
--{
--    ServerName = 1,
--    ServerOpenTime = 2,
--    ServerSeason =3,
--    ServerState = 4,
--    ServerPower = 5,
--    ServerPresident = 6,
--}

--MigrateConditionSetting = 
--{
--    Season = 1,
--    Power =2,
--    BuildLevel = 3,
--    Alliance = 4,
--}

--OfficerListConditionType = {
--    Condition_Hero = 1,
--    Condition_Server = 2,
--}

--UIGuideCloseType =
--{
--    Click = 1,--点击关闭界面引导下一步
--    Time = 2,--等待时间到引导下一步（点击不生效）
--}

--ArmyTrainType = {
--    ArmyTrainType_Normal = 0,--正常训练
--    ArmyTrainType_Reserve = 1,--预备兵训练
--}

--Activity_ChampionBattle_Elite_Stage_State =
--{
--    WAIT_START_PHASE = 0,--开始默认等待状态 等待小组赛开始
--    GROUP_QUARTER_PHASE = 1, --小组赛四分之一开打 周四0点变化
--    GROUP_SEMI_PHASE = 2, --小组赛半决赛开打 小组赛四分之一结束后变化
--    GROUP_FINAL_PHASE = 3,--小组赛决赛开打 小组赛半决赛结束后变化
--    QUARTER_PHASE = 4,--四分之决赛 小组赛结束变化
--    SEMI_PHASE = 5,--半决赛 四分之一决赛结束变化
--    FINAL_PHASE = 6,--冠军赛 半决赛结束变化
--}
LineType = { -- 冠军对决中的线段
    LD = 1,
    LT = 2,
    RD = 3,
    RT = 4,
    ML = 5,
    MR = 6,
    M = 7
}

---迁城来源
---@class MoveCityReason
--MoveCityReason = {
--    Default = 0,
--    Fight = 1,
--    Item = 2,
--    Free = 3,
--    Login = 4,
--    Missile = 5,
--    Cross = 6
--}

LevelId = {
    Runner = -1,
    Main = 10001, -- 在InitMessage中重新赋值：LevelId.Main = LuaEntry.DataConfig:TryGetNum("c_initial_Parameter", "k2")
    NewUserLevel = 107,
    TestLevel = 2001,
    Car10003 = 10003,
    XuZhang = 10002,
}

--LoopListMoveType = {
--    Horizontal = 1,
--    Vertical = 2,
--    Not = 3,
--}
--PveSkillId = {
--    NormalAttack = 10000 --普通攻击，用于调节技能节奏的占位符
--}

--MistressChatTriggerType =
--{
--    Next =  0, -- 
--    Drink =  1, -- 喝酒
--    Task =  2, -- 任务
--    Event =  3, -- 事件
--    LoveLv =  4, -- 好感度等级
--    Chat = 5, -- 对话
--    Picture = 6, -- 照片
--    Date = 7, -- 约会
--    Unlock = 8,--解锁
--    Video = 9,--video
--    Bubble = 10,--对话悬浮气泡
--    Gift = 11,--送礼
--    Select = 12,--选中
--}

--FunctionBtnType =
--{
--    Level =  1, -- 关卡
--    World =  2, -- 世界
--    Mistress =  3, -- 美女
--    ViewMode =  4, -- 镜头模式切换
--    Hero = 5, --英雄
--    Alliance = 6, --联盟
--    mailObj = 7, --邮件
--    Prowl = 8, --潜行
--    Chat = 9, --聊天
--    MainTroops = 10, --右下角队列按钮
--    Radar = 11, --雷达
--    timeScale = 12, --游戏倍速
--    build = 13, --建造
--    AutoAI = 14, --自动战斗
--    BluePrint = 15, --蓝图
--    Activity = 16, --日常活动
--    Gold = 17, --金币
--    Gift = 18, --礼包
--    Time = 19, --时间
--    Goods = 20, --背包/仓库
--    Rank = 21, --排行榜
--    story = 22, --推关
--    sidebar = 23,--主城侧边栏
--    Quest = 24, --任务栏
--    TimeCompetition = 25, --限时排行
--    ResourceBar = 26, --资源栏
--    -- 资源栏上的道具和资源(28-32道具)(33-37资源)，id_tips填上itemId或者resType
--    ResourceBarItemOrResBegin = 27, -- 开始(做个标记，占位用的不能配置)
--    ResourceBarItem1 = 28, --资源栏上的道具
--    ResourceBarItem2 = 29,
--    ResourceBarItem3 = 30,
--    ResourceBarItem4 = 31,
--    ResourceBarItem5 = 32,
--    ResourceBarRes1 = 33, --资源栏上的资源
--    ResourceBarRes2 = 34,
--    ResourceBarRes3 = 35,
--    ResourceBarRes4 = 36,
--    ResourceBarRes5 = 37,
--    UIGiftPackageBtn = 38, --礼包商城按钮是否可以展示
--    ResourceBarItemOrResEnd = 39, --结束(做个标记，占位用的不能配置)
--    Soldiers = 40, -- 士兵
--    HeroRecruit = 41, -- 英雄招募
--    InBattle = 42, -- 关卡内
--    HeroSkill = 43, -- 英雄技能
--    ZombieRedEyed = 44, -- 红眼丧尸
--    ZombieDave = 45, -- 丧尸戴夫
--    FreeTime = 46, -- 免费时间
--    Science = 47, -- 科技
--    Dog = 48, -- 猫女
--    Head = 49, -- 左上角头像
--    LoveNewsletter = 50, --爱情通讯
--    CampBonus = 51, --阵营加成
--    CampRestraint = 52, --阵营克制
--    BuildListBtn = 53,--建筑队列入口按钮
--    SevenDay = 54,--七日计划
--    HeroEquipment = 55,--英雄装备
--    Aircraft = 56,--无人机（改装车）
--    ScienceListBtn = 57,--科技队列入口按钮
--    SeasonBtn = 58,--赛季活动入口
--    SeasonGroundBtn = 59,--赛季地块管理入口
--    Vip = 60,--Vip
--    PlayerHead = 61,--玩家头像
--    InitViewMode = 1000, --初始ViewMode
--}

--任务Type2类型
--QuestType2 =
--{
--    NpcTalk = 503,  --与NPC对话
--    NpcItem = 513,  --给NPC东西
--}

--PveObjectSelectEffectColor =
--{
--    Green = 0,
--    Red = 1,
--    Yellow = 2,
--    White = 3,
--    Blue = 4
--}

--PVELevelState = {
--    Finish = 1,
--    Start = 2
--}

APSDamageEffectType =  {

    DEFAULT = 0, -- 默认
    CRIT = 1, --1 暴击
    MISS = 2, --2 闪避
}

--RewardNumControlNumType =
--{
--    Item = 0,
--    ResourceItem = 1,
--    UseGoods = 2,
--}

--BuildingWorkerStatus = {
--    Worker_Status_Locked = 1,
--    Worker_Status_Free = 2,
--    Worker_Status_Working = 3,
--}

--BuildingUpgradeTabType = {
--    TabType_Normal = 1,
--    TabType_Station = 2,
--    TabType_Cooking = 3,
--    TabType_Food = 4,
--    TabType_PoliceInsignia = 5,
--}

--StoryLevelState =
--{
--	None = 0,
--	Normal = 1,
--	Finished = 2,
--	Locked = 3,
--	NeedMainLevel = 4,
--	NeedChapter = 5,
--	NeedQuest = 6,
--}

--StoryStageRewardState =
--{
--	Normal = 0,
--	Received = 1,
--}



--NPC头上的事件气泡
--EventBubbleType =
--{
--    TriggerBubble = 1,
--    CityNpcBubble = 2,
--    TriggerNpcBubble = 3,
--}

--检测事件触发气泡的类型2，用于再细分类型
--EventBubbleType2 =
--{
--    TimeCompetitionBubble = 1,  --限时竞赛气泡
--}

--主城侧边栏类型
--ESidebarType = {
--    Science = 1,--科技研究
--    Work = 2,--工作队列
--    Training = 3,--部队训练
--    AllianceDonate = 4,--联盟捐献
--    HeroRecruit = 5,--英雄招募
--}

--ArrowTypeHero = { 
--    HeroUid = 1,
--    LvUpHero = 2,
--    RankUp = 3
--}

--ClickTypeHero = {
--    MaxPower = 1, -- 最大战力
--    MaxLevel = 2, -- 最大等级
--    MaxStar = 3 -- 最大星级
--}

-------------------------------------------------
--LWSoundAssets =
--{
--    CollectSoldier = "army_soldier_2", --收取士兵
--    StartCollectSoldier = "city_train",      -- 兵营 - 执行训练
--    StartResearch =  "click_research", --科技中心 - 执行研究
--    MainBuildingUpLeve = "commander_lvup", -- 大本升级弹窗
--    CitySoldierClick = "army_soldier", --点击主城行走士兵
--    HospitalCollectSoldier = "army_soldier_2",--医院收兵
--    TrainingSoldiersView = "Training_soldiers_screen_appears",--兵营弹窗音效
--    TrainingClickSoldier = "Click_the_soldier_icon",--点击士兵
--    SoldierClickEffect = "soldier_modal_particle_01", --点击士兵语气音效
--    SoldierUpLevelClick = "Promotion_button",--士兵晋升按钮点击
--    DiamondsEmerges = "Diamonds_emerges", -- 水晶收获-冒出来
--    DiamondsFlies = "Diamonds_flies", -- 水晶收取-飞入槽
--    DialogueClaimedBtn = "Dialogue_Claimed_btn", -- 劇情對白点击领取
--    MoonCardUI = "Moon_Card_UI", -- 月卡界面打开
--    PowerIncrease = "Power_Increase", -- 条幅弹出的提示音效
--    GoodsFlies = "Goods_flies", -- 物品飞向汽车
--    AutoBattle01 = "Auto_Battle_01", -- 城外战斗丧尸被打（受击爆炸）
--    AutoBattle02 = "Auto_Battle_02", -- 城外战斗丧尸被爆（死亡）
--    AddSoldiers = "Add_Soldiers", -- 点击战斗按钮-士兵添加的音效
--    DeployBtn = "Deploy_btn", -- 出征按钮
--    SoldierVoice = "Soldier_Voice", -- 士兵出发的提示音
--    ZombieAttributesUI = "Zombie_Attributes_UI", -- 野怪属性UI弹出的音效
--    SwitchScene01 = "Switch_Scene_01", -- 切换 传送的音效
--    RadarMissionsBtn = "Radar_Missions_btn", -- 雷达任务信息UI弹出的音效
--    RadarUI = "Radar_UI", -- 雷达界面进入
--    RadarScan = "Radar_Scan", -- 雷达扫描的音效
--    RecruitmentUI = "Recruitment_UI", -- 招募界面出现音效
--    RecruitOnceCard = "Recruit_Once_card", -- 招募一次的卡牌出现音效
--    RecruitTenTimes = "Recruit_Ten_Times", -- 招募10卡牌出现音效
--    Recruit_Flip = "Recruit_Flip", -- 普通翻卡的音效
--    Technology_UI = "Technology_UI", -- 科技界面打开
--    Tech_Lvl2_UI = "Tech_Lvl2_UI", -- 科技界面 二级菜单打开
--    Tech_Lvl3_UI = "Tech_Lvl3_UI", -- 科技界面三级菜单打开
--    ResearchBtn = "Research_btn", -- 点击研究按钮
--    PAC_Factory_Interface = "PAC_Factory_Interface", -- 配件工厂打开
--    Select_Accessories = "Select_Accessories", -- 选择配件
--    Craft_btn = "Craft_btn", -- 配件-点击制造的音效
--    Crafting = "Crafting", -- 制造过程音效
--    Tab_Switch_01 = "Tab_Switch_01", -- 配件工厂-切页音效
--    Click_Action = "Click_Action", -- 配件工厂 点击操作音效
--    Click_Disassemble = "Click_Disassemble", -- 配件工厂 点击分解按钮
--}


--region PVE

--BULLET_LOG = false
--DAMAGE_LOG = false
--LOCAL_HERO_SKILL_OVERRIDE = true
--INVINCIBLE = false
--PVE_TEST_MODE = false--关闭？
--DEFAULT_BULLET_MOTION_STRING = "0,0,2,2|1,1,0,0"
--TIME_STOP_DURATION = 3
--SKILL_PUBLIC_CD = 0.01
--TIME_STOP_CD = 0.1
--TIME_STOP_CD_AI = 1
--HALO_SKILL_CD = -1--光环型技能刷新间隔
--HALO_BUFF_DURATION = -1--光环型buff持续时间
--ULTIMATE_SKILL_SLOT_INDEX = 2 --大招是2技能
--DIE_PERCENT = 0.99 --认为追踪弹运动到全程的99%时碰撞到目标，该值必须小于1，因为等于1代表子弹与目标重合，此时击退方向、受击特效方向都是零向量
--ZOMBIE_REMOVE_DISTANCE_Z = 25--丧尸到小队的z轴距离超出25米时，移除以节省性能
--BARRAGE_SCENE_CENTER = 36--推图场景中轴线x坐标
--EXIT_SPEED = 40--24--退场速度
--EXIT_CTRL_POINT_OFFSET = 140--5
--WHITE_MAT = nil
--RED_MAT = nil


--玩法类型，也是LWBattleLogic类型
--PVEType =
--{
--    None = -1,--没有进入任何战斗
--    Parkour = 1000,--倍增门跑酷 -- ParkourBattleLogic
--    Barrage = 1001,--推图  -- ZombieBattleManager
--    Count = 1003, -- CountMasters战斗 -- CountBattleLogic
--    Skirmish = 2,--战斗回放 -- SkirmishLogic
--    Preview = 3,--技能预览 -- PreviewSkillEffectManager
--    World = 4,--大世界战斗 -- WorldBattleManager
--    FakePVP = 6, -- 假PVP战斗：爬塔、大世界雷达、抢卡车，竞技场---@class DataCenter.LWFakePVPBattle.FakePVPLogic
--    Arena3V3 = 7, -- 3v3竞技场战斗、抢火车
--}

--PVE进入方法
--PVEEnterType =
--{
--    GM = 0,--通过gm指令进入
--    Default = 1,
--    Radar = 2,--通过雷达进入
--    TowerupJeepAdventure = 3,--爬塔冒险300关
--    TruckRob = 4,--抢卡车
--    PVPArena = 5,--竞技场
--    Monopoly = 6,--大富翁
--    Arena3V3 = 7,--3v3竞技场
--    ActivityArena = 8,--活动竞技场
--    TrainRob = 9,--抢火车
--}

-- 单位类型
--UnitType =
--{
--    None=0,
--    Zombie=1,--丧尸（可以移动和攻击的）
--    Member=1<<1,--队员
--    Junk=1<<2,--杂物，不能移动攻击的，可以互动的东西。如油桶、路障
--    Plot=1<<3,--剧情单位，纯表现，无互动，如工人
--    TacticalWeapon=1<<4,--战术武器，无互动
--    Neutral = 1<<5,
--    All=15,--全集
--}

--BarrelMemberType = 
--{
--    None = 0,
--    Hero = 1,               --玩家自由英雄
--    BarrelGirl = 1 << 1,    --打桶掉落英雄
--    BarrelTank = 1 << 2,    --道具坦克
--    VehicleTank = 1 << 3,   --前冲载具坦克
--    SummonSoldier = 1 << 4, --技能召唤的士兵
--    BarrelCar = 1 << 5,     --无人机对应的车
--}

--UnitType2String =
--{
--    [1]="丧尸",
--    [2]="英雄",
--    [4]="杂物",
--    [8]="NPC",
--    [16]="战术武器",
--}

--动画名（通用）
--AnimName={
--    Show_Idle = "show_idle",
--    Idle = "idle",
--    Run = "run",
--    Walk = "walk",
--    Attack = "attack",
--    AttackMove = "attack_move",
--    Dead="dead",
--    Dead_Fire="dead_fire",
--    Born="born",
--    Hurt="hurt",
--    Aim="idle",--瞄准
--    Stun="stun",
--    Cheer = "cheer",
--    LeftMoveAttack = "left_move_atk",
--    RightMoveAttack ="right_move_atk",
--    Skill_1 ="skill_1",
--    Drift ="drift",
--    Drift_Jjc = "drift_jjc",
--}


--队员动画
--MemberAnim = {
--    Idle = "idle",
--    Run = "run",
--    Attack = "attack",
--    Dead="dead",
--    Aim="idle"--瞄准
--}

--ZombieAnim =
--{
--    Idle = "idle",
--    Run = "run",
--    ShieldRun = 'shield_run',
--    Walk = "walk",
--    Attack = "attack",
--    ShieldAttack = 'shield_attack',
--    Dead="dead",
--    Dead_Fire="dead_fire",
--    Born="born",
--    Hurt="hurt",
--    DropShield = "drop_shield",
--    Sprint = "run_fast",
--}

--子弹耐久类型
--BulletDurabilityType= {
--    Time=0,--持续型子弹：每隔一定时间做一次碰撞检测，可以对同一个目标造成多次伤害
--    Collide=1,--有限次碰撞型子弹：每帧做碰撞检测，不会对碰过的目标造成伤害，碰过的目标数达到上限后销毁
--    CollideInfinity=-1,--无限次碰撞型子弹：每帧做碰撞检测，不会对碰过的目标造成伤害，目标数无上限
--}

--阵营
--PVECamp={
--    Enemy=0,--敌
--    Ally=1,--友（不包含自己）
--    Neutral=2,--中立
--    Self=3,--自己
--}

--SkillType={
--    Bullet=1,--子弹型技能，必须要有一个目标才能施放
--    Buff=2,--buff型技能，没有目标也能施放
--    Halo=3,--光环型技能，无限时长的作用号修改
--    PassiveDeath=4,--被动技能：死亡时触发
--    CityIdle = 5,--城内放置技能：提供作用号属性加成
--    WorldZone = 6, --场景技能
--}

--BulletMoveType={
--    Static = 0,--不运动
--    Straight = 1,--直线运动
--    Parabola = 2,--抛物线
--    Follow = 4,--挂在枪口
--    Ray = 5,--高速直线子弹，射线检测
--    Laser = 6,--激光
--    AreaBomb = 7,
--}

--站位条件
--LocationCondition={
--    None=0,--无条件
--    Self=1,--自己 
--    Same=2,--对位
--    Default=3,
--    Random=4,--随机n个
--    FrontOnly=5,--仅前排
--    BackOnly=6,--仅后排
--}

--站位
--LocationType={
--    None=0,--无排
--    Front=1,--前排
--    Back=2,--后排
--}


--英雄阵营
--HeroType =
--{
--    None = -1,--不属于任何阵营
--    All = 0,
--    Tank = 1,--坦克
--    Missile = 2,--导弹
--    Aircraft = 3,--飞机
--}

--HeroJob = {
--    Defense = 1,    --防护
--    exportation = 2,--输出
--    subsidiary = 3,--辅助
--}

--碰撞盒类型
--ColliderType= {
--    Sphere=1,
--    Capsule=2,
--}

--索敌AI
--PriorityType={
--    All=0,
--    Nearest=1,
--    LowestHP=2,
--    Farthest=3,
--    Random=4,
--}

--携带buff的子弹
--BulletBuffType={
--    None=0,
--    OnHit=1,--命中后对命中目标施加buff
--    OnHitByChance=2,--命中后有概率对命中目标施加buff
--    OnKill=3,--杀敌后对自己施加buff
--    OnCastToCaster=4,--施放技能后对自己施加buff
--}

--GameObject Layer
--LayerType={
--    Member="Member",
--    Zombie="Zombie",
--    Junk="Junk",
--}


--BuffType={
--    Halo=0,
--    Property=1,
--    Dot=2,
--    Hot=3,
--    Stun=4,
--    Imprison=5, --禁锢
--    BeTaunt=7,
--    FiniteSkill = 8, --有限时间的技能充能
--    Shield=9, --护盾
--    SpecialMove=10, --特殊移动
--    SummonSoldiers = 11, --召唤士兵
--}

--BuffSubType={
--    Default=0,
--    ReduceDamage=1,--减伤
--    ShieldFromCasterHp = 2,    --护盾值根据释放者血量计算
--    --ShieldFromCasterProperty = 3,   --护盾值根据释放者属性计算
--    ShieldFromValue = 3,            --护盾值固定
--}

--BarrageState={--推图玩法状态
--    Prepare = 0, --加个准备阶段
--    Push = 1,--直线推进
--    AutoAttack = 2, --
--    PreExit = 4,--准备退场
--    Exit = 5,--狂飙退场
--    Lose = 6,--失败
--}

--SkirmishStage ={--战斗回放状态
--    Load=1,--加载
--    Opening=2,--开场
--    Fight=3,--互殴
--    End=4,--结算
--}

--FakePVPStage ={--fake PVP
--    Lineup = 0, --阵容
--    Load=1,--加载
--    Opening=2,--开场
--    Fight=3,--互殴
--    End=4,--结算
--}

--ActionPhase ={--skirmish行为类型
--    Prepare=0,--蓄力，目前没有
--    Cast=1,--播放施法动作：如果是子弹型技能，会创建无伤害子弹；如果是buff技能，不会创建buff
--    Damage=2,--造成伤害
--    Buff=3,--添加buff
--    Dot=4,--dot伤害，目前没有
--    FIRE_BULLET=5--创建子弹，用于多段伤害型技能释放
--}


--SkirmishMoveState={--战斗回放运动状态
--    Stay=1,--不动
--    Path=2,--路径点模式
--}

--SkirmishFireState={--战斗回放攻击状态
--    Aim=1,--瞄准
--    Casting=2,--施法中
--    Idle=3,--发呆
--    Die=4,--死亡
--    Auto=5,--自动开火（小兵专用）
--}

--SquadState={
--    Stay=1,--不动
--    Move=2,--移动
--    Exit=3,--狂飙退场
--}

--MemberCommand={
--    Stay=1,--不动
--    Move=2,--移动
--    AutoAttack=3,--自由开火
--    StationAttack=4,--瞄准开火
--    Ultimate=5,--放大招
--}

--MemberState={
--    Stay=1,--不动
--    Move=2,--移动
--    Dead=3,--死亡
--}

--AttackState={
--    StraightAttack = 1, --向前开火
--    AutoAttack = 2, --自由开火
--    StationAttack = 3, --瞄准开火
--    HoldFire = 4, --不开火
--    Ultimate = 5, --释放大招
--}

--ZombieState =
--{
--    Born = 0,
--    Idle = 1,
--    Run = 2,
--    Attack = 3,
--    Die = 4,
--    Hurt = 5,
--    Stun = 6,
--    DefenseRun = 7,
--    DropShield = 8,
--    HardControl = 10,
--    Preview = 11, --英雄技能预览
--    Sprint = 9,
--    Ragdoll = 20,
--}

--DamageTextType =
--{
--    HeroNormalAttack=1,--伤害来源：英雄普攻
--    HeroUltimate=2,--伤害来源：英雄大招
--    ZombieNormalAttack=3,--伤害来源：丧尸普攻
--    ZombieUltimate=4,--伤害来源：丧尸大招
--    ReduceDamageBuff=5,--承伤者拥有减伤buff
--    Miss=6,--未命中
--    GetBuff=7,--吃buff
--}

--ExDamageType={
--    attackPercent=1,
--    hpPercent=2,
--}

--EffectObjType={
--    Normal=0,
--    Sprite=1,
--}

--SkillCastState={
--    Cooldown=0,--冷却中
--    Ready=1,--冷却完成
--    FrontSwing=2,--前摇
--    Chant=3,--吟唱（只有持续施法型技能有）
--    BackSwing=4,--后摇
--}


--SoundLimitType={
--    UnitDeath = 1,
--    BulletHit = 2,
--    BulletCreate = 3,
--    DropGold = 4,
--    MAX = 5,
--}


-- 伤害类型
DamageType =
{
    Physics=0,
    Magic=1,
}

--PveBuffType =
--{
--    No = 0,--不显示
--    Speed = 1,--加移速
--    AttackAnim = 2,--旋风斩
--    WeaponBigger = 3,--武器变大
--    Player = 4,--获得一个小人
--    AttackQuick = 5,--频率上升
--    AddAttack = 6,--攻击上升
--    Stun = 7,--晕眩
--}

--CarriageState = {
--    PullIn = 1,--进站中
--    Hide = 2,--进站完成，隐藏
--    PullOut = 3,--出站中
--    Straight = 4,--走直线
--    Turn = 5,--拐弯
--}

--TrainState = {
--    BeforeDeparture = 1,--没出发
--    Travelling = 2,--行驶中
--    ArrivedFinal = 3,--到达终点站
--}

--TrainKeyFrameType={
--    PullIn = 1,--进站帧
--    PullOut = 2,--出站帧
--    TurnIn = 3,--进弯帧
--    TurnOut = 4,--出弯帧
--}

--UIPveSelectBuffOrder =
--{
--    PveBuffType.AddAttack,
--    PveBuffType.Speed,
--    PveBuffType.Player,
--}

--PveResultShowType =
--{
--    Normal = 0,
--    Pass = 1,
--}

--Type3v3 = {
--    Arena = 1,--竞技场3v3
--    Train = 2,--火车3v3
--}

--TacticalWeaponPageType =
--{
--    Basic = 1,
--    Equip = 2,
--    Skin = 3,
--}

--DecorationShowGroup = {
--    City = 0,
--    TacticalWeapon = 1,
--}

--BattleUnitType =
--{
--    Hero = 1,
--    TacticalWeapon = 2,
--}

--BarrelMapBorder = {
--    Min = 30.5,
--    Max = 41
--}


--BarrelLevelType = 
--{
--    Novice = 1,
--    Hero = 2
--}

--endregion





--HeroEffectDefine =
--{
--    --Strength = 50001,--力量
--    --Vitality = 50002,--体质
--    --Agility = 50003,--敏捷
--    --Produce = 50004,--工作
--    --Trade = 50005,--商业
--    EquipHealthPoint = 50005,--装备生命
--    HealthPoint = 50006,--生命
--    PhysicalAttack = 50007,--物理攻击
--    EquipPhysicalAttack = 50008,--装备攻击
--    --MagicAttack = 50008,--战术攻击
--    PhysicalDefense = 50009,--物理防御
--    EquipPhysicalDefense = 50010,--装备防御
--    --MagicDefense = 50010,--战术防御
--    CriticalRate_Result = 50011,--暴击率结果
--    CriticalDamage_Result = 50012,--暴击伤害结果
--    ChanceToHit_Result = 50013,--命中率结果
--    HealPoint_Result = 50014,--生命值结果
--    PhysicalAttack_Result = 50015,--物理攻击结果
--    Hero_ATK_Result = 50016,--英雄攻击结果
--    PhysicalDefense_Result = 50017,--物理防御结果
--    Hero_DEF_Result = 50018,--英雄防御结果
--    Hero_HP_Result = 50019,--英雄生命值结果
--    Equip_HP_Result = 50020,--装备生命值结果
--    Equip_ATK_Result = 50021,--装备攻击结果
--    Equip_DEF_Result = 50022,--装备防御结果
--    HeroSoldierCapacity = 50079, --英雄带小兵结果
--    HeroSoldierMorale = 50080, --英雄所带小兵士气加成
--	HeroArmyCount = 51001, -- APS公式计算的带兵量
--
--    TacticalWeaponAtk = 50082, --战术武器攻击力
--    TacticalWeaponHp_Result = 50084, --战术武器生命值
--    TacticalWeaponAtk_Result = 50085, --战术武器攻击力结果
--    TacticalWeaponDef_Result = 50086, --战术武器防御力结果
--
--    PhysicalDamageReduce_Result = 50030,--物理减伤结果
--    MagicDamageReduce_Result = 50031,--战术减伤结果
--    PhysicalDamageAdd_Result = 50032,--物理增伤结果
--    MagicDamageAdd_Result = 50033,--战术增伤结果
--    TankBuildingLife = 50039, --建筑对坦克增加的生命
--    TankBuildingAttack = 50041,--建筑对坦克增加的攻击力
--    TankBuildingDefence = 50043,--建筑对坦克增加的防御力
--
--    TankBuildingLastLife = 50040,--最终建筑坦克增加的生命
--    TankBuildingLastAttack = 50042,--最终建筑坦克增加的攻击
--    TankBuildingLastDefence = 50044, --最终建筑坦克增加的防御
--    TankBuildingLastSoldierCapacity = 50072, --最终建筑坦克增加的带兵量
--
--    MissileBuildingLife = 50046,--建筑对导弹增加的生命
--    MissileBuildingAttack = 50048,--建筑对导弹增加的攻击力
--    MissileBuildingDefence = 50050,--建筑对导弹增加的防御力
--
--    MissileBuildingLastLife = 50047,--最终建筑导弹增加的生命
--    MissileBuildingLastAttack = 50049,--最终建筑导弹增加的攻击
--    MissileBuildingLastDefence = 50051, --最终建筑导弹增加的防御
--    MissileBuildingLastSoldierCapacity = 50073, --最终建筑导弹增加的带兵量
--
--    AircraftBuildingLife = 50052,--建筑对飞机增加的生命
--    AircraftBuildingAttack = 50054,--建筑对飞机增加的攻击力
--    AircraftBuildingDefence = 50056,--建筑对飞机增加的防御力
--
--    AircraftBuildingLastLife = 50053,--最终建筑飞增加的生命
--    AircraftBuildingLastAttack = 50055,--最终建筑飞机增加的攻击
--    AircraftBuildingLastDefence = 50057, --最终建筑飞机增加的防御
--    AircraftBuildingLastSoldierCapacity = 50074, --最终建筑飞机增加的带兵量
--
--    Honor_HP_Result = 50064,--荣誉生命值结果
--
--    ProductivityRate = 71000,--工作生产效率
--    CommercialRate = 71001,--商业加工效率
--    AgilityRate = 71002,--灵巧修炼效率
--
--    ConstitutionAddRate = 75000,--体质提升
--    HpAddRate = 75050,--生命值提升
--    BuffHpAddRate = 75051,--buff生命值提升
--    TankHeroHpAddRate = 75053,--坦克英雄生命值提升
--    MissileHeroHpAddRate = 75054,--导弹英雄生命值提升
--    AircraftHeroHpAddRate = 75055,--飞机英雄生命值提升
--    LineupHpAddRate = 75060,--阵容生命值提升
--
--    StrengthAllAttackAddRate = 75100,--力量攻击提升
--    AllAttackAddRate = 75150,--全攻击提升
--    BuffAttackAddRate = 75151,--Buff攻击力提升
--    TankAttackAddRate = 75153,--坦克攻击力提升
--    MissileAttackAddRate = 75154,--导弹攻击力提升
--    AircraftAttackAddRate = 75155,--飞机攻击力提升
--    LineupAttackAddRate = 75160,--阵容攻击力提升
--
--
--    BuffAttackReduceRate = 75200,--Buff攻击力降低
--    AllDefenseAddRate = 75250,--全防御提升
--    BuffDefenseAddRate = 75251,--Buff防御力提升
--    TankDefenseAddRate = 75253,--Buff防御力提升
--    MissileDefenseAddRate = 75254,--Buff防御力提升
--    AircraftDefenseAddRate = 75255,--Buff防御力提升
--
--
--    LineupDefenseAddRate = 75260,--阵容防御力提升
--
--    BuffDefenseReduceRate = 75300,--Buff防御力降低
--    AllCriticalDamageAddRate = 75400,--全暴击伤害提升
--    AllHitChanceAddRate = 75500,--全命中率提升
--    AllAttackSpeedAddRate = 75650,--全攻击速度提升
--
--    AttackAgainstZombieAddRate = 75953,--伤害提升打野
--
--
--    --AttackRate = 25100,--全攻击百分比
--    --DefenseRate = 25200,--全防御百分比
--    --HealthPointRate = 25000,--全生命百分比
--
--    UnlockEquipSlotLimit = 90002,--解锁装备槽位限制
--    UnlockStrengthenWeaponLimit = 90003,--解锁专武强化限制
--
--    AllCriticalChanceAddRate = 75300 ,--全暴击率提升
--    AllCdReduceRate = 75750 ,--全冷却缩减提升
--    AllHealAddRate = 75800 ,--全释放治疗效果提升
--    AllBeHealedAddRate = 75850 ,--全受到治疗效果提升
--    SkillAllDamageAddRate = 75950 ,--技能伤害提升
--    SkillPhysicalDamageAddRate = 75951 ,--技能物理伤害提升
--    SkillMagicDamageAddRate = 75952 ,--技能战术伤害提升
--
--    TankDamageAddRate = 75957 ,--坦克伤害提升
--    MissileDamageAddRate = 75958 ,--导弹伤害提升
--    AircraftDamageAddRate = 75959 ,--飞机伤害提升
--
--
--    SkillDamageReduceRate = 76000 ,--技能伤害降低
--    SkillPhysicalDamageReduceRate = 76001 ,--技能物理伤害降低
--    SkillMagicDamageReduceRate = 76002 ,--技能战术伤害降低
--
--    SkillTakenDamageReduceRate = 76050 ,--技能受到伤害减免提升
--    SkillPhysicalTakenDamageReduceRate = 76051 ,--技能受到物理伤害减免提升
--    SkillMagicTakenDamageReduceRate = 76052 ,--技能受到战术伤害减免提升
--    DefenceAgainstZombieReduceRate = 76053,--受到伤害降低打野
--
--    EquipDamageReduceRateBase = 76057,--装备基础减伤
--    EquipDamageReduceRatePhysics = 76058,--装备物理减伤
--    EquipDamageReduceRateMagic = 76059,--装备魔法减伤
--
--
--    SkillTakenDamageAddRate = 76100 ,--技能受到伤害提升
--    SkillPhysicalTakenDamageAddRate = 76101 ,--技能受到物理伤害提升
--    SkillMagicTakenDamageAddRate = 76102 ,--技能受到战术伤害提升
--    BattleHeroMoveSpeed = 80000 ,--战斗移速增加百分比
--    SuperArmor = 80001 ,--霸体，同时禁用大招
--
--    HeroPower = 100000 ,--英雄战力,=100001+100002+100003
--    HeroPowerLevel = 100001 ,--英雄等级战力
--    HeroPowerSkill = 100002 ,--英雄技能战力
--    HeroPowerEquip = 100003 ,--英雄装备战力
--}

--GuideState =
--{
--    Normal = 0 ,
--    LevelOne = 1, --关卡1
--    OpeningDebut = 2, --新手关卡登场
--
--    -- 后面的都已废弃不再触发
--    CityCopter = 3, --主城直升机动画
--    Soldier = 4, --大头兵汇报
--    UnLanlockTwo = 5, --解锁地块2
--    UnLanlockTwoShowTime = 6, --地块2表演
--    Over = -1 , --结束
--}

--火箭炸弹是否已领奖
--RocketBombRewardState =
--{
--    No = 0,-- 没领奖
--    Yes = 1,--已领取
--}

--CallBossUseType =
--{
--    CallBoss = 0,--召唤Boss
--    GetReward = 1,--获得奖励
--}

---@class BuildPoliceInsigniaType 通过警徽升级建筑
---@field Ruins number 废墟
---@field Ready number 通过警徽子建筑修建完成的状态
---@field Normal number 正常状态
---@field OnProcess number 修复中状态
--BuildPoliceInsigniaType = {
--    Ruins = 3,
--    OnProcess = 2,
--    Ready = 1, 
--    Normal = 0,
--}

---@class TalkTaskState
---@field Finish number 完成
---@field Start number 开始
--TalkTaskState = {
--    Finish = 1, --完成
--    Start = 2, --开始
--}

---@class TalkTaskType
--TalkTaskType = {
--    Detect             = 1, --  内城
--    Detect_World       = 2, --  外城
--    Building_Bubble    = 3, --  内城建筑气泡
--    Trigger_Bubble     = 4, -- trigger气泡
--    CommonQuest_Finish = 5, -- 和通用任务挂钩
--}

---@class TalkTaskUnlockType
--TalkTaskUnlockType = {
--    Building_LevelUp   = 3, --建筑升级
--    Area_Unlock        = 4, -- 地块解锁
--    CommonQuest_Finish = 5, -- 通用任务挂钩，通用任务完成后偶才能完成这个
--}

--建筑升级特效类型
--BuildUpgradeEffectType =
--{
--    Upgradeing = 1,
--    ConfirmBox = 2,
--}

--改名活动通用类型
--ChangeNameAndPicType =
--{
--	No = 0,
--	Yes = 1,
--}

--礼包类型
--FirstPayType =
--{
--    GetOnce = 1,
--    ThreeDayThreeBox = 2,
--    ThreeDayOneBox = 3,
--}

--玩家信息页面箭头类型
--PLayerInfoArrowType =
--{
--    ChangeName = 1,--改名
--    BandAccount = 2,--绑定账号
--    ChangePic = 3,--换头像
--}


--PVPType =
--{
--    [PVEType.Skirmish]=1,
--    [PVEType.FakePVP]=2,
--}

--技能主被动
--SkillAPType={
--    Active=0,--主动技能，cd好了就释放
--    Passive=1,--被动技能，分两种：一种是光环，初始化时生效；另一种由特定时机触发
--}

--每天登陆弹窗的活动类型
--ActPopUIType =
--{
--    TimeCompe = 1, --限时竞赛
--    Arena = 2,--竞技场
--    WorldBoss = 3, --世界BOSS
--    CombatActivity = 4, -- 战力活动
--    StrongCommander = 5, --最强指挥官
--    AllianceCompete = 6, --联盟对决
--    FightPreview = 7, --杀戮活动
--    ChampionBattle = 8, -- 冠军对决
--    Throne = 9,--王座
--    Presidenton = 10,--总统上任
--    GloryDeclareWar = 11,--荣耀宣战
--    ChampionBattleInvitation = 12, --冠军对决邀请
--    UICompensateMonthCardLetter = 13, --补偿月卡信件
--    UICompensateMonthCardPop = 14, --补偿月卡弹窗
--    UIHeroBattlePassPop = 15, --battlePass弹窗
--    UILuckyRollHeroPop = 16, --英雄幸运转盘弹窗
--}

---世界Boss排行标签索引
---@class EWorldBossRankTabIndex
--EWorldBossRankTabIndex = {
--    Rank = 0,  --排行
--    Reward = 1,  --奖励
--    Person = 2,  --个人
--}

---世界建筑类型
---@class BuildSceneType
--BuildSceneType = {
--    City = 1,
--    World = 2,
--    Fake = 3,
--    Alliance = 4,
--}

--周礼包类型
--WeekGiftType = {
--	normal = 1,--正常礼包 (在周卡界面放)
--	select = 2,--选择礼包 (在滑动列表中放)
--	normalInScroll = 3,--正常礼包需要放在列表中的 (在滑动列表中放)
--}

--GarbageResourceAnim = {
--    Idle = "idle",
--    Reward = "reward",
--    Open = "open"
--}

--UI中箭头朝向，比如UIHeroTips、UIArmyTips等
--UIArrowDirection = {
--    ABOVE  = 1,
--    BELOW  = 2,
--    LEFT   = 3,
--    RIGHT  = 4,
--}

--GoToChangeNameType = {
--    player = 1, --点头像
--    chat = 2, -- 点聊天
--}

--英雄技能对应英雄id
--HeroSkillToHeroId =
--{
--    BuildFreeTime = 11001,--建筑免费加速
--    ScienceFreeTime = 22001,--科技免费加速
--    Energy = 1006,--每日领体力
--    Gear = 1012,--每日领齿轮
--    RefitPaper = 1012,--每日改装图纸
--}

-------------------------------
-- 火车相关的类型
--TrainState = {
--	BeforeDeparture = 1,--没出发
--	Travelling = 2,--行驶中
--	ArrivedFinal = 3,--到达终点站
--}


--火车站状态
--火车站解锁有两个条件：a.活动开启,b.推图指定管关卡完成（迷雾解锁）
--RailwayStationState = {
--	Disable = 1,--!a&!b,活动预热，迷雾锁
--	WarmUp = 2,--!a&b,活动预热，迷雾解锁
--	Fog = 3,--a&!b,活动开启，迷雾锁
--	FirstReward = 4,--活动开启，首次奖励可领
--	--Ready = 5,--可以发车
--	--Travelling = 6,--火车旅行中
--	--Reward = 7,--火车已到站，可以领奖
--	--CD = 8,--火车发车cd中
--	--Exhausted = 9,--每日发车次数耗尽
--	CanRob = 10,--可以抢别人
--	CannotRob = 11,--每日抢别人次数耗尽
--}

--卡车站状态
--TruckStationState = {
--	Lock = 0,--该卡车站没解锁
--	Ready = 1,--车在城内，可以发车
--	Exhausted = 2,--车在城内，每日发车次数耗尽，不可以发车
--	Travelling = 3,--卡车旅行中
--	Reward = 4,--卡车已到站，可以领奖
--}

--火车月台
--TrainPlatformState = {
--	NoTrain = 0,--没火车，此时freeTrainTime有值；
--	TrainNoDriver = 1,--有车没司机，trainUuid有效；
--	TrainWithDriver = 2,--有车有司机，乘客在排队，trainUuid，readyEndTime有效
--	TrainWithPassenger = 3,--有车有司机，乘客已上车，trainUuid，readyEndTime有效
--}

--TrainTab={
--	Enemy = 1,
--	Mine = 2,
--	Ally = 3,
--	MAX = 3,
--}
--TrainType={
--	Truck = 1,--个人货车
--	Train = 2,--联盟火车
--}

--打开类型
--TrainUIOpenType={
--	Prepare = 1,--火车的准备界面
--	Departure = 2,--已出发的火车的详情界面
--}
--FormationSaveType =
--{
--    PVESquadAuto = 0,
--    PVESquad = 1,
--    TruckDefenceSquad = 4,
--    TruckAttackSquad = 8,
--
--}
--火车准备
--TrainPreparePage={
--	Driver = 1,--车头
--	Passenger = 2,--车厢
--}

--PathPointType = {
--	Station = 1,
--	Corner = 2,
--}

--TrainStationType = {
--	Main = 1,--玩家主城
--	City = 2,--联盟城市
--}

--TrainKeyFrameType={
--	PullIn = 1,--进站帧
--	PullOut = 2,--出站帧
--	TurnIn = 3,--进弯帧
--	TurnOut = 4,--出弯帧
--}

--WorldMarchEmotionTargetType =
--{
--    None = -1,
--    March = 0,
--    Building = 1,
--}

--WorldMarchEmotionCommandType =
--{
--    None = 0,
--    ShowBtns = 1,
--    HideBtns = 2,
--    ShowEmo = 3,
--    HideEmo = 4,
--}

--FreeTimeBubbleType = {
--    Girl = 1,
--    Hero = 2,
--    Build = 3,
--}

--[[
--Soldier_qualityBg = {
--    [1] = "G_sbxl_dikuang_01",
--    [2] = "G_sbxl_dikuang_02",
--    [3] = "G_sbxl_dikuang_03",
--    [4] = "G_sbxl_dikuang_04",
--}
--]]

-- 科技推荐类型
--ScienceRecommedType =
--{
--    Economy = 1, --经济
--    Battle = 2, --战斗
--}


--字体材质选项
--MediumFontMaterialType =
--{
--    Red = "Oswald-SemiBold Atlas BtnCommon", --"NotoSansSC-Medium SDF BtnRed",
--    Green = "Oswald-SemiBold Atlas BtnCommon",--"NotoSansSC-Medium SDF BtnGreen",
--    Gray = "Oswald-SemiBold Atlas BtnCommon", --"NotoSansSC-Medium SDF",
--    Blue = "Oswald-SemiBold Atlas BtnCommon", --"NotoSansSC-Medium SDF BtnBlue",
--    Bold = "Oswald-SemiBold Atlas BtnCommon", --"NotoSansSC-Medium SDF Bold",
--    Yellow = "Oswald-SemiBold Atlas BtnCommon", --"NotoSansSC-Medium SDF BtnYellow",  --Oswald-SemiBold Atlas BtnCommon
--    YellowOutline = "Oswald-SemiBold Atlas Material Protrait GiftPackage Title",
--    YellowOutlineHero = "Oswald-SemiBold Atlas Material Protrait Title Hero",
--    BoldPack = "NotoSansSC-Bold Atlas Pack",
--    MaskBoldSDF = "Mask_NotoSansSC-Bold SDF",
--    BoldSDF = "NotoSansSC-Bold SDF",
--    MediumSDF = "NotoSansSC-Medium SDF",
--    SelfSelectGiftPackage = "Oswald-SemiBold Atlas GiftPackage",
--    OSNormal = "Oswald-SemiBold Atlas Material",--无阴影描边
--    NSB_YellowOutline = "NotoSansSC-Bold SDF YellowOutline",
--    PortraitBlackOutLineS3 = "NotoSansSC-Bold Atlas Material Portrait Black Outline s3",
--    PortraitNormal = "NotoSansSC-Bold Atlas Material Protrait Normal",
--    NewHeroA = "NotoSansSC-Bold Atlas Material Portrait NewHero A",
--    NewHeroB = "NotoSansSC-Bold Atlas Material Portrait NewHero B",
--    NewHeroS = "NotoSansSC-Bold Atlas Material Portrait NewHero S",
--    OSSP01 = "Oswald-SemiBold Atlas Material Protrait SP 01",
--}

--BtnTMPColor =
--{
--    GrayTMPColor = Color.New(0.698, 0.698, 0.698,1),
--    YellowTMPColor = Color.New(0.352, 0.094, 0,1),
--    BlueTMPColor = Color.New(0.004, 0.176, 0.310,1),
--    RedTMPColor = Color.New(0.353, 0, 0,1),
--    GreenTMPColor = Color.New(0.051, 0.219, 0.004,1),
--    WhiteTMPColor = Color.New(1, 1, 1,1),
--}

--按钮图和字体颜色
--BtnAndTmpColorData =
--{
--    Red = {[1] ="Common_btn_red_M", [2] = BtnTMPColor.WhiteTMPColor},  --RedTMPColor
--    Green = {[1] ="Common_btn_green_M", [2] = BtnTMPColor.WhiteTMPColor}, --GreenTMPColor
--    Gray = {[1] = "Common_btn_gray_M", [2] = BtnTMPColor.GrayTMPColor}, --GrayTMPColor
--    Blue = {[1] = "Common_btn_blue_M",[2] = BtnTMPColor.WhiteTMPColor}, --BlueTMPColor
--    Yellow = {[1] = "Common_btn_yellow_M",[2] = BtnTMPColor.WhiteTMPColor}, --YellowTMPColor
--    Bold = {[1] = "",[2] = BtnTMPColor.WhiteColor},
--}

--SoldierLevelImage = {
--    [1] = "UItroops_img_LV01",
--    [2] = "UItroops_img_LV02",
--    [3] = "UItroops_img_LV03",
--    [4] = "UItroops_img_LV04",
--    [5] = "UItroops_img_LV05",
--    [6] = "UItroops_img_LV06",
--    [7] = "UItroops_img_LV07",
--    [8] = "UItroops_img_LV08",
--    [9] = "UItroops_img_LV09",
--    [10] = "UItroops_img_LV10",
--    [11] = "UItroops_img_LV11",
--}

--这个用来处理同时多个弹窗队列弹出Pop时，处理下优先顺序，数值越小优先级越高
--PopWindowSortOrder =
--{
--    --[UIWindowNames.UIBuildUpUnlock] = 50,
--    --[UIWindowNames.UIPopupPackage] = 51,
--}

--BuildKeyType =
--{
--    No = 0,--非重点建筑
--    Yes = 1,--重点建筑
--}

--HeroInfoViewType =
--{
--    HeroList = 1,
--    HeroPreview = 2,
--}

--NoticeBubbleType =
--{
--    Activity = 1,
--    Notice = 2,
--}

--ThronePopupType =
--{
--    Preview = 0, --预告
--    Battle = 1, --进行中
--    End = 2, --结束
--}

--GarageRefitTalentType = {
--    Normal = 1,
--    Skill = 2,
--}

-- 改装车部件
--CarParts = {
--    Init = 1,               -- 初始化
--    TopGun = 2,             -- 车顶枪火
--    FrontWindshield = 3,    -- 前挡风玻璃
--    BackDoor = 4,           -- 后车门
--    Gear = 5                -- 车轮
--}

--ScienceColorBg = {
--    [1] = "keji_bg_icondi",
--    [2] = "keji_bg_icondi",
--    [3] = "keji_bg_icondi",
--    [4] = "keji_bg_icondi",
--}

--NoticeTipIconPath =
--{
--    [ActivityEnum.ActivityType.BlackKnight] = "Assets/Main/Sprites/UI/UIMain2.0/main_icon_zombiesiege.png",  --僵尸图标
--    [ActivityEnum.ActivityType.AllianceBoss] = "Assets/Main/Sprites/UI/UIMain2.0/main_icon_allianceboss.png", --僵尸boss图标
--    [EnumActivity.Throne.Type] = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/UIMain_icon_capitalwaar.png", --王座争夺战图
--    [EnumActivity.CrossWonder.Type] = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/UIMain_icon_capitalwarserver.png", --跨服王座
--    [EnumActivity.RobotWars.Type] = "Assets/Main/Sprites/UI/UIMain2.0/main_icon_city.png", --首都争夺
--    [EnumActivity.ActDragon.Type] = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/UIMain_icon_planet.png", --巨龙
--    [EnumActivity.GloryDeclare.Type] = "Assets/Main/Sprites/UI/UINewSeason/UIMain_icon_alliancewar.png", --荣耀之战
--    [ActivityEnum.ActivityType.ActWorldResource] = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/main_icon_foodmine.png", --采集
--    [ActivityEnum.ActivityType.ActCrossWorldResource] = "Assets/Main/Sprites/UI/UIMain2.0/UIMainNew/main_icon_foodmine.png", --掠夺
--}

--CarHighlightPath = {
--    [1] = {},
--    [2] = {"A_vehicle_jeep_skin/To_unity/A_vehicle_jeep_qiang", "A_vehicle_jeep_skin/To_unity/A_vehicle_jeep_shuangqiang"},
--    [3] = {"A_vehicle_jeep_skin/To_unity/A_vehicle_jeep/A_vehicle_jeep_qiancheboli"},
--    [4] = {"A_vehicle_jeep_skin/To_unity/A_vehicle_jeep/A_vehicle_jeep_beimianchemen_01", "A_vehicle_jeep_skin/To_unity/A_vehicle_jeep/A_vehicle_jeep_beimianchemen_02"},
--    [5] = {"A_vehicle_jeep_skin/To_unity/A_vehicle_jeep/A_vehicle_jeep_youqianluntai"}
--
--}

--AircraftLevelBg =
--{
--    [1] = "Assets/Main/Sprites/UI/UIAircraft/UIModified_img_linebg3.png",
--    --[2] = "Assets/Main/Sprites/UI/UIAircraft/UIModified_img_linebg2.png",
--    [2] = "Assets/Main/Sprites/UI/UIAircraft/UIModified_img_linebg4.png",
--    [3] = "Assets/Main/Sprites/UI/UIAircraft/UIModified_img_linebg5.png",
--    [4] = "Assets/Main/Sprites/UI/UIAircraft/UIModified_img_linebg6.png",
--}

--CrossWonderActState =
--{
--    None = 0,
--    Preview = 1, -- 预览
--    Prepare = 2, -- 准备
--    Play = 3, -- 进行
--    Settle = 4, -- 结算
--    Close = 5, -- 踢人
--    End = 6, -- 结束
--}
--UIEnterDragonType =
--{
--    Open = 1,
--    Close = 2,
--}

--UIQuitDragonType =
--{
--    Open = 1,
--    Close = 2,
--}

--SCORE_TYPE = {
--    ALLIANCE_DUAL_WIN   = 0,        -- 联盟对决胜利
--    ALLIANCE_DUAL_MVP   = 1,        -- 联盟对决MVP
--    PERSON_ACT_MVP      = 2,        -- 个人军备第一  应该是服务器将个人军备和跨服竞技场搞反了
--    CROSS_ARENA_MVP     = 3,        -- 跨服竞技场第一 应该是服务器将个人军备和跨服竞技场搞反了
--    CROSS_TRAIN_WIN     = 4,        -- 跨服运镖
--    DELITE_MVP          = 5,        -- 冠军对决
--}

--SCORE_TYPE_DIALOG = {
--    [SCORE_TYPE.ALLIANCE_DUAL_WIN]  = 510160,
--    [SCORE_TYPE.ALLIANCE_DUAL_MVP]  = 510161,
--    [SCORE_TYPE.PERSON_ACT_MVP]    = 510163,--个人军备第一   应该是服务器将个人军备和跨服竞技场搞反了
--    [SCORE_TYPE.CROSS_ARENA_MVP]     = 510165,--跨服竞技场第一 应该是服务器将个人军备和跨服竞技场搞反了
--    [SCORE_TYPE.CROSS_TRAIN_WIN]    = 510162,
--    [SCORE_TYPE.DELITE_MVP]         = 511325,
--}

--CROSS_SERVER_TYPE = {
--    Cross_Wonder_MoveTo_VsServer = 4, --跨服王座进入敌对服务器 
--}

--CorssWonderEventTextColor = {
--    Blue = Color.New(0.7372549, 0.8431373, 1,1),
--    Red = Color.New(1, 0.7176471, 0.7372549, 1),
--}

--AllianceWarStage = {
--    -- 没有预约
--    NoReservationStatus = 1,
--    -- 已经预约
--    BookedStatus = 2,
--    -- 不在预约时间内
--    None = 3
--}

--GotoItemTipType = 
--{
--    Common = 1, ---通用道具提示
--    Bauble = 2 --装饰建筑
--}

-- 打点枚举
--ClientEventType = {
--    ShopType = {
--        XianShi = 3, -- 限时商店
--        TeQuan = 2, -- 特权商店
--        DaoJu = 1,  -- 道具商店
--        GongXun = 14,    -- 功勋商店
--        RongYu = 16, -- 荣誉商店
--    },
--    EnterType = {
--        HeiShi = 1, -- 黑市
--        JingJiChang = 2, -- 竞技场
--        YingXiongZhanChang = 3, -- 英雄战场
--        VipRoute = 4, -- Vip
--    }
--}

---奖励标签
---@class RewardFlagType
--RewardFlagType = {
--    Normal = 0, --普通
--    First_Pass = 1, --首通
--}

---搜索Lod类型
---@class SearchLodType
--SearchLodType = {
--    Desert = 1, --赛季地块
--}


---赛季资源标记索引
---@class DesertResFlagIndex
--DesertResFlagIndex = {
--    Crystal = 0, --水晶
--    Cactus = 1, --仙人掌
--}

---赛季等级标记索引
---@class DesertLevelFlagIndex
--DesertLevelFlagIndex = {
--    ALL = 0,
--    Lv1 = 1,
--    Lv2 = 2,
--    Lv3 = 3,
--    Lv4 = 4,
--    Lv5 = 5,
--    Lv6 = 6,
--    Lv7 = 7,
--    Lv8 = 8,
--    Lv9 = 9,
--    Lv10 = 10,
--    Lv11 = 11,
--    Lv12 = 12,
--    Lv13 = 13,
--    Lv14 = 14,
--    Lv15 = 15,
--    Lv16 = 16,
--    Lv17 = 17,
--    Lv18 = 18,
--    Lv19 = 19,
--    Lv20 = 20,
--}

---巨龙能源块状态
---@class DragonSecretState
--DragonSecretState = {
--    Free = 0, --空闲中
--    Our_Escort = 1,  -- 我方护送
--    Enemy_Escort = 2, -- 敌方护送
--    Cool_Down = 3, --倒计时
--}

--DragonApply = {
--    ApplyForBattle = 1,
--    NotParticipating = 2,
--}

--服务器发的赛季类型（供数据使用）
--ServerSeasonPlayTypes = {
--    Default = 0,--联盟城赛季
--    Desert = 1,--地块赛季
--    Eden1 = 2,--伊甸园赛季 二阵营版本
--    Eden2 = 3,--伊甸园赛季 四阵营版本
--}

--前端定义的赛季类型（显示使用）
SeasonPlayType = {
    DEFAULT = 0,--0 联盟城赛季
    DESERT = 1,--1 地块赛季
    EDEN =2,--2 伊甸园赛季
    DESERT_NO_CONNECT = 3,--3 非连地赛季
    EdenPlay_1 = 4,--伊甸园1玩法(2阵营)
    EdenPlay_2 = 5,--伊甸园2玩法(4阵营)
    EdenPlay_3 = 6,--伊甸园2玩法冰雪赛季(4阵营)
    EdenPlay_4 = 7,--伊甸园1玩法冰雪赛季(2阵营)
}

--SeasonMapType = {
--    Desert = 1,    --沙漠
--    Snow = 2,     --雪地
--}

--点击道具弹出tip类型
--GotoItemTipType =
--{
--    Common = 1, ---通用道具提示
--    Bauble = 2 --装饰建筑
--}
--装饰建筑品质类型
--BaubleQuality =
--{
--    White = 0,--白色
--    Green = 1,--绿色
--    Blue = 2,--蓝色
--    Purple = 3,--紫色
--    Orange = 4,--橙色
--}

--UIWorldTileUIViewFromType =
--{
--    Build = 1,--建筑
--    Bauble = 2,--装饰建筑
--}

--联盟领地页签类型
--UIAllianceCityTabType =
--{
--    Mine = 1,--矿
--    City = 2,--领地
--    Resource = 3,--资源
--    Build = 4,--建筑
--    FoodFestival = 5,--美食节
--}
--SeasonBuildTabs =
--{
--    --辐射研究所
--    {
--        index = 1,
--        name = 511194,
--        desc = 511195,
--        buildIds = {741000,746000,747000,748000},
--        icon = "season_bg_fushe",
--        defaultY = 812,
--    },
--    --土地管理局
--    {
--        index = 2,
--        name = 511116,
--        desc = 511193,
--        buildIds = {742000,749000},
--        icon = "season_bg_tudi",
--        defaultY = 474,
--    },
--    --战略兵营
--    {
--        index = 3,
--        name = 488014,
--        desc = 488015,
--        buildIds = {743000,750000},
--        icon = "season_bg_bingying",
--        defaultY = 474,
--    },
--    --军事要塞
--    {
--        index = 4,
--        name = 488016,
--        desc = 488017,
--        buildIds = {744000,751000},
--        icon = "season_bg_yaosai",
--        defaultY = 474,
--    },
--    --防御训练所
--    {
--        index = 5,
--        name = 488018,
--        desc = 488019,
--        buildIds = {745000,752000},
--        icon = "season_bg_fangyu",
--        defaultY = 474,
--    },
--}

--Season_Reward_Grade_Max = 7 --赛季奖励档位数量
--
--解锁按钮类型
--UnlockBtnLockType =
--{
--    Hide = 0,--直接隐藏
--    Lock = 1,--上面有锁，点了告诉解锁条件（不填不显示条件）
--    Normal = 2,--未解锁但正常显示，点击显示条件（不填不显示条件）。【世界】,当满足任意条件显示按钮，全部满足点击正常
--    Show = 10,--正常显示
--}

--AllianceFlagBgColor = {
--    Color.New(78/255,168/255,225/255),
--    Color.New(85/255,226/255,221/255),
--    Color.New(142/255,195/255,112/255),
--    Color.New(244/255,164/255,49/255),
--    Color.New(229/255,106/255,67/255),
--    Color.New(236/255,113/255,185/255),
--    Color.New(132/255,111/255,211/255),
--    Color.New(105/255,104/255,104/255),
--}

--AllianceFlagBg1Color = {
--    Color.New(2/255,55/255,100/255,0.5),
--    Color.New(10/255,78/255,77/255,0.5),
--    Color.New(28/255,71/255,3/255,0.5),
--    Color.New(131/255,65/255,0/255,0.5),
--    Color.New(97/255,4/255,4/255,0.5),
--    Color.New(119/255,0/255,76/255,0.5),
--    Color.New(50/255,35/255,109/255,0.5),
--    Color.New(0/255,0/255,0/255,0.5),
--}

--AllianceFlagGgColor = {
--    Color.New(78/255,203/255,250/255),
--    Color.New(99/255,242/255,228/255),
--    Color.New(138/255,235/255,59/255),
--    Color.New(255/255,201/255,15/255),
--    Color.New(255/255,128/255,59/255),
--    Color.New(255/255,131/255,198/255),
--    Color.New(167/255,139/255,245/255),
--    Color.New(162/255,164/255,174/255),
--}

--AllianceFlagFgColor = {
--    Color.New(244/255,253/255,255/255),
--    Color.New(244/255,255/255,253/255),
--    Color.New(255/255,254/255,244/255),
--    Color.New(255/255,254/255,244/255),
--    Color.New(255/255,247/255,244/255),
--    Color.New(255/255,244/255,249/255),
--    Color.New(247/255,244/255,255/255),
--    Color.New(239/255,239/255,239/255),
--}

--AllianceWarTabType =
--{
--    Attacker = 1, --情报
--    Team = 2,--组队
--    Alliance = 3,--盟友
--}

--联盟科技推荐
--AllianceScienceRecommendState =
--{
--    No = 0,--不推荐
--    Yes = 1,--推荐
--}

--ScienceLineState =
--{
--    No = 1,--没有
--    Dark = 2,--暗
--    Light = 3,--亮
--}

--ScienceLineDirectionState =
--{
--    L = 1,
--    M = 2,
--    R = 3,
--}

--RankingRangeType = 
--{
--    Local = 0,--本服  默认
--    ALLIANCE_DUEL = 1, --对决分组
--    GLOBAL = 2,  --全服
--}

--描点类型
--PivotType = 
--{
--    LeftCenter = Vector2.New(0, 0.5),--左中描点
--    Center = Vector2.New(0.5, 0.5),--中心描点
--    RightCenter = Vector2.New(1, 0.5),--右中描点
--}

--RankItemBg = {
--    [1] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/c_common_RankYellowD.png", -- 第一名
--    [2] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/c_common_RankBlueD.png", -- 第二名
--    [3] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/c_common_RankOrangeD.png", -- 第三名
--    [4] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/c_common_list_normal_bg.png", -- 其他名次
--    [5] = "Assets/Main/Sprites/UI/UIPortrait/UIPortraitCommon/c_common_list_self_bg.png", -- 自己的排名
--}

--GotoArenaAimToType = {
--    None = 1,--不打开任何界面
--    RewardPreview_Daily = 2,--胜利奖励_每日奖励
--    RewardPreview_Final = 3,--胜利奖励_结算奖励
--}

--SmallPeopleType = {
--    List = 1, --在小人列表中
--    Task = 2, --在派遣列表中
--    Build = 3, --在建筑已派遣小人展示中
--    Build_List = 4, --建筑中,选择可用小人列表中
--}

--SmallPeopleCardItemState = {
--    Back = 1,
--    BackWithGlow = 2,
--    Front = 3,
--    FrontGet = 4,
--    FrontAlreadyGet = 5,
--}

--PayActivityRankRemindSettingKeys = {
--    [ActivityEnum.ActivityType.LuckyShop] = "LUCKY_SHOP_RANK_REMIND",
--    [ActivityEnum.ActivityType.LuckyRoll] = "LUCKY_ROLL_RANK_REMIND",
--    [ActivityEnum.ActivityType.GiftBox] = "GIFT_BOX_RANK_REMIND",
--    [EnumActivity.DigActivity.Type] = "DIG_RANK_REMIND",
--}

--WorldPointLodType =
--{
--    Monster = 1,
--    Resource = 2,
--    SeasonRes = 3,
--}

--最强王国当前处于哪个状态
--StrongKingdomStateType =
--{
--    None = 0, --未开始
--    Preview = 1, --预告
--    Match = 2,--匹配
--    Ready = 3,--备战
--    Fight = 4,--战斗
--    Recover = 5,--恢复
--    End = 6,--结束
--}

--最强王国世界玩家城池标记
--StrongKingdomWorldPlayerCityMark =
--{
--    None = 0,
--    Expedition = 1,--远征军
--    Invasion = 2, --入侵者
--    Attack = 3,--进攻方
--    Defend = 4,--防守方
--}

--Season_Reward_Tab = {
--    361021,--盟主奖励
--    361022,--核心奖励
--    361023,--主力奖励
--    361024,--贡献奖励		
--}
--Season_Reward_SubTab = {
--    361021,--盟主奖励
--    361022,--核心奖励
--    361023,--主力奖励
--    361024,--贡献奖励		
--}
--Season_Reward_SubDesc = {
--    511231,--联盟最明智的领导者，联盟的辉煌由你引领
--    582006,--运筹帷幄决胜千里你的一举一动都深刻地影响着联盟前进的方向
--    582007,--身先士卒临危不乱，你是联盟中绝对的中坚力是
--    582008,--你是联盟最坚定的拥护者，积极响应联盟的决策		
--}
--Season_Reward_BoxIcon = {
--    "alliancegift_icon_05",
--    "alliancegift_icon_04",
--    "alliancegift_icon_03",
--    "alliancegift_icon_02",
--    "alliancegift_icon_01",
--    "alliancegift_icon_01",
--}
--Season_Ground_TabType = {
--    Force = 1, --势力值
--    Res = 2, --资源地块
--    Build = 3, --建筑
--}

--赛季规则页签类型
--UISeasonGloryRuleType =
--{
--    Rule = 1,--赛季机制
--    Build = 2,--赛季建筑与资源
--    Declare = 3,--宣战
--    Reward = 4,--赛季奖励
--}

--战令标题颜色设置
--BattlePassTitleConfig =
--{
--    ["PassBlackWoman"] =
--    {
--        TitleTopColor = Color.New(1, 1, 1),
--        TitleBottomColor = Color.New(1, 0.8392157, 0.3529412),
--        DescTextColor = Color.New(170/255, 85/255, 36/255, 1),
--        OutlineNum = 1
--    },
--    ["PassDetective"] =
--    {
--        TitleTopColor = Color.New(1, 1, 1),
--        TitleBottomColor = Color.New(205/255, 227/255, 223/255),
--        DescTextColor = Color.New(170/255, 85/255, 36/255, 1),
--        OutlineNum = 0
--    },
--    ["PassSheriff"] =
--    {
--        TitleTopColor = Color.New(1, 1, 1),
--        TitleBottomColor = Color.New(1, 0.8392157, 0.3529412),
--        DescTextColor = Color.New(170/255, 85/255, 36/255, 1),
--        OutlineNum = 1
--    },
--    ["PassSister"] =
--    {
--        TitleTopColor = Color.New(1, 1, 1),
--        TitleBottomColor = Color.New(1, 0.8392157, 0.3529412),
--        DescTextColor = Color.New(170/255, 85/255, 36/255, 1),
--        OutlineNum = 1
--    },
--}

--客户端完成任务类型
--ClientTriggerTaskType =
--{
--    READ_SEASON_RULE = 1,--阅读规则任务
--}

--CrossWonderScoreKeys = {
--    "type0",
--    "type1",
--    "type2",
--    "type3",
--    "type4",
--    "type5",
--}

---巨龙退出类型
---@class ExitDragonType
--ExitDragonType = {
--    FromPlayer = 1, --主动退出
--    FromScorePanel = 2,  --来自积分面板
--    FromResult = 3, --来自战报
--}

--AllianceCityBattleType = {
--    None = 0,
--    SelfServer = 1,
--    CrossServer = 2
--}

--ToPortraitReason = {
--    Self = 1, --自己转成竖版，比如点击邀请按钮，或者领取联盟奖励前，弹窗提示，点确定转为竖版
--    Accept = 2, --接受别人的邀请
--    SignActivity = 3, --签到活动
--}

--连续手指的类型
--ArrowSecondType =
--{
--    AllianceScience = 1,--联盟科技（先指向主界面联盟按钮，点击后再指向页面中联盟科技）
--    HeroList = 2,--英雄列表界面
--    HeroInfo = 3,--英雄信息
--    HeroStar = 4,--英雄升阶按钮
--    AllianceScienceDonate = 5,--联盟科技捐献（先指向主界面联盟按钮，点击后再指向页面中联盟科技，点击后再执行可捐献的页签）
--    ScienceTab = 6,--科技选择页签
--    MainWorld = 7,--世界主城
--    MainWorldDefence = 8,--世界主城防护罩
--    StoryDogIndex = 9,--推图关狗线索
--    MainTaskEveryDayTab = 10,--主界面每日任务页签
--    AdventureTask = 11,--集会所页面任务
--    SeasonRule = 12,--赛季页面规则按钮
--}
--return ConstClass("EnumType", EnumType)