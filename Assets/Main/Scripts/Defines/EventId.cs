public enum EventId
{
	APP_APPLICATION_PAUSE = -1000,

	SCREEN_TOUCH_DOWN = -3000,
	SCREEN_TOUCH_DOWN_IGNORE_UI = -3001,
	SCREEN_TOUCH_UP = -3002,
	SCREEN_TOUCH_UP_IGNORE_UI = -3003,
	SCREEN_TOUCH_CLICK = -3004,
	SCREEN_TOUCH_CLICK_IGNORE_UI = -3005,
	SCREEN_TOUCH_MOVE = -3006,

	UIPrivacy_Cancel = -4000,
	UIPrivacy_Confirm = -4001,

	
    None = 0,
    ResourceUpdated = 1,
    OpenUIFormSuccess = 2,
    OpenUIFormFail = 3,
    CloseUIForm = 4,
    ElectricityLack = 5,
    PlayerInfoUpdated = 6,
    UpdateFiveStarReward = 7,//五星好评
    UpdateBankruptcy = 8,//破产状态刷新
    DoneBankruptcy = 9,//破产状态结束
    PlayerPowerInfoUpdated = 10,
    ServerError = 11,
    BuildPlace = 12,//放置建筑
    BuildUpgradeStart = 13,
    BuildUpgradeFinish = 14,
    TransportFinish = 15,
    CheckActivityRedPoint = 16,
    BuildResources = 17,
    PushCreateBuildingOneHeart = 18,
    TrainArmyData = 19,
    TrainingArmy = 20,
    TrainingArmyFinish = 21,
    ResourceTransport = 22,
    HeroicRecruitmentData = 23,
    WorldMarchFormatiomData = 24,
    WorldMarchCount = 25,
    WorldMarchChristmas = 26,
    HospitaiStart = 27,
    HospitalHelp = 28,
    HospitalFinish = 29,
    HospitalTimeEnd = 30,
    HospitalUpdate = 31,
    DesertHospitalShowSpeedBtn = 32,
    HospitalEffectEnd = 33,//医院特效结束
    ModeReward = 34,
    RepairNeedMessage = 35,
    ArmyFormationSave = 36,
    ChapterTask = 37,//章节任务更新
    QuestNoteBookRedCount = 38,
    LineSpine = 39,//线条动画
    ActiveGuide = 40,
    BuyAndUseItemSuccess = 41,
    forgingSuccess = 42,//锻造成功
    UseItemSuccess = 43,
    AddSpeedSuccess = 44,
    AllianceHelpAddSpeed = 45,
    DailyQuestSuccess = 46,
    MainTaskSuccess = 47,
    AllianceChangeNameSuccess = 48,
    AllianceChangeAbbrSuccess = 49,
    SearchAllianceSuccess = 50,
    AllianceMember = 51,
    KingSearchPlayerList = 52,
    PlayerMessageInfo = 53,
    AllianceHelp = 54,
    AllianceHelpSever = 55,
    AllianceShopShow = 56,
    AllianceMemberRedPoint = 57,//联盟成员小红点
    AllianceInfoRefresh = 58,//联盟图标小红点
    AllianceApplySuccess = 59,//申请加入联盟
    AllianceCreateSuccess = 60,//创建联盟
    AllianceApplyCancel = 61,//取消联盟申请
    AllianceTechnology = 62,//联盟科技信息
    AllianceScienceDonate = 63,//联盟科技捐献
    KickOutAllianceMember = 64,//联盟踢人
    AllianceSettingUpdate = 65,//联盟设置更新
    AllianceAcceptInvite = 66,//接受联盟邀请
    AllianceEvent = 67,
    AllianceWarUpdate = 68,
    ShowTruckIcon = 69,                      // 显示工程车Icon
    ShowMainUIPart = 70,                     // 显示主UI部分内容 [2018/11/6 by rj]
    RefreshPieceInterface = 71,           // 刷新碎片界面 【2019/4/15 by lhy】
    CloseActiveSkillUseUI = 72,              //关闭驻扎英雄主动技能使用面板 lhy
    CloseGarrisonTip = 73,                   //关闭驻守界面的tip
    OpenInvestmentPanel = 74,                //主动驻扎技能，打开投资面板 lhy
    MarchTimeSync = 75,                      //出征时间同步
    ActiveSkillNode = 76,                    //显示技能Node

    RefreshSkillUseUI = 77,
    RefreshActiveSkillUseUI = 78,            //刷新技能使用面板的显示，如按钮置灰，开始计时等等 lhy
    PlayFragBuySuccessAnim = 79,           //播放成功购买碎片的动画
    PlayShopBuySuccessAnim = 80,           //播放商店成功购买的动画
    ShopBuyAnimEnd = 81,                   //购买动画播放结束
    MoveUpFragShopPanel = 82,              //已购买把UI推上去。

    ZombieUnLockAddTransporter = 83,
    NewUserAreaUnLock = 84,                  // 解锁僵尸地块
    UserAreaUnLock = 85,                     // 解锁普通地块
    CenterDailyReward = 86,                  // 福利中心-每日补给奖励
    CenterDailyRewardRedDot = 87,            // 福利中心-每日补给奖励红点数
    CargoReward = 88,                        // Cargo领奖 [2018/11/8 by rj]
    CloseAlliancePanel = 89,
    MoveWorldCity = 90,
    WorldScoutDetail = 91,
    WorldPointDetail = 92,                   // 地块详细信息
    WorldOccupiedTroops = 93,                //地块占领军队详细信息
    WorldCollectPointDetail = 94,            //世界资源点详情
    WorldOccupiedKick = 95,                  //时间援军遣返（王座）
    WorldMarchGetDetail = 96,                // 地块上的队伍的详细信息
    RefreshBookmark = 97,                    // 刷新收藏夹条目显示 [2018/11/13 by rj]
    ChangeBookmarkItemState = 98,            // 改变收藏夹条目状态 [2018/11/14 by rj]
    GuidePreloadFinish = 99,                 // 引导预加载资源加载完毕 [2018/12/7 by rj]
    RequestWorldMarchDetail = 100,
    ArmyUpgrade = 101,//军营是否升级兵种
    ArmyUpgradeStart = 102,//军营兵种开始升级
    ArmyFormatUpdate = 103,//部队编排更新
    // ------ 联盟 ------
    GetAllianceWarArrayEvent = 104,
    GetAllianceWarAtkInfoEvent = 105,
    GetAllianceWarDefInfoEvent = 106,
    AllianceWarCancelEvent = 107,
    AllianceWarIgnore = 108,
    AllianceWarLogEvent = 109,
    RefreshAllianceGift = 110,                // 联盟礼包
    UpdateAllianceGiftNum = 111,              // 刷新礼包数量
    UpdateAllianceHelpNum = 112,              // 刷新帮助数量
    RetGetRewardEvent = 113,                  // 领取奖励
    AllianceGiftShowChangeAni = 114,          // 领取奖励
    RetGiftInfoEvent = 115,                   // 礼包详情
    TerritoryUpdateInfo = 116,                // 联盟中心刷新数据
    TerritoryContri = 117,                    // 联盟捐献
    TerritoryStateChange = 118,               //联盟中心可建造状态改变
    ShowUseResTool = 119,                     // 使用资源
    TerritoryDetail = 120,                    // 联盟建筑详情
    OccupiedMarchKick = 121,                  // 撤回部队
    AlliancebuildEditor = 122,                // 添加联盟建筑(可拖动的)
    ChangeTerritoryInfo = 123,                // 更新联盟信息
    GetAllianceComments = 124,                // 联盟留言
    AllianceSendComment = 125,                // 发送联盟留言
    // ------ 联盟 ------
    // ------末日争霸.荣誉建筑------
    TalentPointChange = 126,                  // 合服天赋
    MsgDesertSkillUseRefresh = 127,           //末日争霸天赋主动技能使用后刷新
    EndStudyTalent = 128,                     //学习天赋结束（刷新）
    HidePutWorldBuildUI = 129,                // 关闭放置荣誉建筑ui
    RefreshUpdateStone = 130,                 // 刷新石头数量
    DomainDefenceValue = 131,                 // 领地详情
    UpdateCrossServerPermission = 132,		// 跨服王战
    DomainFightRewardInfo = 133,              // 打开地块详情面板
    DomainBuildInfo = 134,                    // 荣誉建筑面板所需信息
    WBProductNeedTime = 135,                  // 攻击荣誉建筑时的红点消息
    FactorySelectEvent = 136,                 // 选择要加工的资源
    WorldBuildInfoUpdate = 137,               // 信息更新
    WorldBuildRepair = 138,                   // 开始维修
    WorldBuildFinishRepair = 139,             // 完成维修
    WorldBuildRepairInfo = 140,               // 获取维修信息
    // ------末日争霸.荣誉建筑------
    WorldMarchRepeat = 141,                   // 部队撤退
    EnemyInfoListChange = 142,                // 敌人列表更新
    CityDefend = 143,//防御中心的城防值
    CityDefendIndex = 144,//防御中心的驻守位置
    TroopAssistance = 145,//士兵援助
    UIRefreshAssistanceDetailInfo = 146,
    FightToMonster = 147, // 和Monster战斗
    BuildingAppointhero = 148,//驻扎
    UpdateMarchEntityInfo = 149,    // 更新行军信息
    UpdateWorldMapInfo = 150,    // 更新地图信息

    UpdateMarchSpeedUp = 151,         // 更新行军加速
    BuyItemSuccess = 152,             // 购买道具成功
    UpdateNewChatInfo = 153,      //更新最新聊天消息
    FightReport = 154,                // 战报返回
    RequestAllianceSoldier = 155,     // 请求联盟援助的士兵数据
    GetUserInfo = 156,                // 获取玩家信息 
    PushWorldMarchInfo = 157,         // 推送队列
    PaymentCompleted = 158,           // 支付完成
    PaySuccess = 159,                 // 支付成功

    HeroGrowReward = 160,     // 英雄养成奖励领取
    RequestWeekCardData = 161,        // 返回周卡数据
    WEEK_REFRESH_VIEW = 162,           //周卡刷新

    // ---------------华丽的分割线.battle-----------------
	
    BattleStartOver = 163,            // 战斗开始动画播放完成(开始战斗)
    BattleBeAttackPost = 164,         // 受击
    BattleAddAttackEffect = 165,      // 增加受击特效
    BattleAddBulletAttackEffect = 166, // 子弹攻击效果
    BattleAddMissileAttackEffect = 167,   // 导弹攻击效果
    BattleAddPoisonEffect = 168,          // 中毒效果
    BattleUpdateSodierNum = 169,          // 刷新士兵数量
    BattleAddMaraleEffect = 170,          // 士气崩溃
    BattleWarningTipFinish = 171,         // 中毒动画播放完毕
    BattleShackScreen = 172,              // 抖屏
    BattleAddSkillState = 173,            //MSG_ADD_SKILL_SING 士兵显示状态
    BattleAddSkillEffect = 174,
    BattleAddStateIdEffect = 175,
    BattleShowTroopSkill = 176,
    BattleMoveForward = 177,
    BattleOfficerCellShine = 178,         // ---
    BattleOfficerCellCancelShine = 179,   // ---
    BattleShowGlow = 180,                 // ---
    BattleAddPoisonIcon = 181,            // 中毒Icon --- 
	MSG_ADD_STATE = 182,  
	MSG_SHOW_AOE_EFFECT = 183,            //AOE特效
    MSG_UPDATE_STATE = 184,               //刷新状态
    MSG_SHOW_AOE_MASK = 185,              //压黑特效
	MSG_SHOW_STATUS_EFFECT = 186,         //状态特效
	MSG_ADD_POISON_ICON = 187,			//添加特效
    // ---------------华丽的分割线.battle-----------------

    AccountBindEvent = 188,   //账号绑定
    AccountBindOKEvent = 189, //账号绑定成功
    AccountChangeEvent = 190, //账号切换
    AccountChangePwdEvent = 191, //修改账号密码
    AccountResendMailEvent = 192,   //验证邮件
    AccountChangeMailEvent = 193,   //更改邮件
    AccountNewEvent = 194,          //创建新账号

    NickNameChackEvent = 195,    //检查名称 
    NickNameChangeEvent = 196,    //修改名称 
    MoodInfoChangeEvent = 197,    //玩家心情修改

    PinInputReset = 198,            //PinInput界面 - 刷新
    PinInputClose = 199,            //PinInput界面 - 关闭
    PinInputNext = 200,             //PinInput界面 - 继续
    PinForgetPwd = 201,             //PinForget界面 - 忘记密码
    PinInitFinish = 202,            //Pin init 完成

    // ---------------Activity-----------------
    MSG_INIT_ACTIVITY_EVENT = 203,
    DayChange = 204,                  // 隔天
    GetActivityDetail = 205,          // 活动详情
    ActivityCellRefresh = 206,        // 活动子数据刷新
    MsgFreshSingleScoreView = 207,    // 刷新单人积分 MSG_FRESH_SINGLE_SCORE_VIEW
    MsgFreshSingleScoreRankView = 208,// 刷新单人排行 MSG_FRESH_SINGLE_SCORE_RANK_VIEW
    RefreshDataSingleScore = 209,     // 刷新单人积分数据
    RefreshRwdData = 210,             // 刷新奖励数据
    RefreshSingleScoreUI = 211,       // 刷新单人积分 refresh_singlescore_ui
    MsgScoreRankHistoryView = 212,    // 刷新单人历史排行 MSG_SCORE_RANK_HISTORY_VIEW
    DesertMummyRankData = 213,        // DESERT_MUMMY_RANK_DATA
    GetRewardInfo = 214,              // GETRT_REWARD_INFO
    MsgUpdateActivityEvent = 215,     // 更新活动 MSG_UPDATE_ACTIVITY_EVENT
    MsgAllianceMigrationRefreshData = 216,     // 战区移民列表刷新 MSG_ALLIANCE_MIGRATION_REFRESH_DATA
    MsgAllianceMigrationPopupRefreshData = 217,// 战区移民条件列表 msg.alliance.migration.popup.refresh.data
    MsgGetAllianceArmsDifficulty = 218,// 联盟军备难度信息
    MsgUpdateAllianceArmsUI = 219,    // 刷新联盟军备界面
    MsgUpdateAllianceArmsRankUI = 220, // 刷新联盟军备排行榜界面
    MsgRefreshChampBattleView = 221,   // 刷新冠军对决 "msg.refresh.champBattleView"
    EliteNewAddbet = 222,              // 冠军对决押注 "elite.new.addbet"
    EliteNewBetInfo = 223,             // 冠军对决押注列表
    EliteNewAllocateUpdate = 224,      // elite.new.allocate.update
    MsgChampBattleAllocateCell = 225,      // msg.champ.battle.allocate.cell
    MsgKingGiftUserList = 226, //刷新礼包分配的用户列表
    MsgKingGiftUpdateContact = 227, //刷新最近联系人
    MsgOfficerPosition = 228,          // 王座指派职权
    MsgOfficerCellUpdate = 229,        // 王座指派职权单个cell
    MsgUpdateKingdomFlag = 230,       //王座国旗
    MsgUpdatePresidentHistory = 231,  //历史总统
    MsgUpdateLaunchBoxHistory = 232,
    DRAW_VIEW_UPDATE = 233,            //抽签数据刷新
    DRAW_SELF_VIEW_UPDATE = 234,       //自己点击抽签数据返回
    DRAW_RESULT_VIEW_UPDATE = 235,    //抽签结束
    DRAW_RESULT_VIEW_UPDATE_1 = 236,  //其他组赛况
    ZONE_REWARD_RED_POINT = 237,      //领奖后刷新红点
    DRAW_VS_VIEW_UPDATE = 238,
    ZONE_CONTRIBUTE_RANK_UPDATE = 239, //热身赛本区贡献排名刷新
    CountryTodayViewcheckReward = 240, //
    ZONE_INSIDE_RANK_VIEW = 241,  //自己区排名
    ACTIVITY_THEME_CHANGE = 242, //赛季变化
    REFRESH_SINGLE_HEAD_VIEW = 243, //刷新头像
    ZONE_OUT_LOOK_REFRESH = 244,
    ZONE_WARMUPTODAT_RANK = 245, //服务器返回最强战区热身赛 当日排行榜
    ZONE_WARMUPACCUMULATE_RANK = 246,//服务器返回最强战区热身赛 总排行榜
    ZONE_HISTORY_RANK = 247,//最强战区预选赛 大赛历史排行榜
    ALLIANCE_ACTIVITY_INFO = 248,//联盟活动信息
    ALLIANCE_ACTIVITY_REWARD = 249,//联盟活动奖励
    ALLIANCE_REWARD_RANK = 250,//联盟奖励
    PERSONAL_REWARD_RANK = 251,//个人奖励

    DRAW_PIRZE_VIEW_UPDATE = 252,
    MSG_FRESH_SINGLE_SCORE_RANK_VIEW = 253,
    ZONE_GET_CHOOSE_REFRESH = 254,
    ZONE_GET_CHOOSEINFO_REFRESH = 255,
    ZONE_ACTIVITY_DETAIL_EXTEND = 256,  //活动列表展开
    ZONE_VIEW_CHOOSE_STATE = 257,    //最强战区活动选择状态更改
    ZONE_WARMUP_RANKING_PRIZE_REFRESH = 258,//热身赛排名奖励刷新
    MsgKingdomOfficers = 259,          // 更新王座主界面
    MsgUpdateCommendationView = 260,   // 更新嘉奖界面
    MsgUpdateGiftSelectMemTop = 261,   // 更新总统发奖界面已选择部分
    MsgUpdateGiftSelectMems = 262,     // 更新总统发奖界面成员部分
    MsgHeroLimitedRecruitBoxInit = 263,// 限时招募界面宝箱
    MsgHeroCardInfoEnd = 264,			 // 英雄招募预览
    MsgHeroSelectHero = 265,          // 英雄自选招募选择英雄
    UPDATE_CHRISTMAS_TREE = 266,//圣诞树升级
    INFO_CHANGE_COLORFUL_CHRISTMAS_TREE = 267,////圣诞树界面刷新
    GET_COLORFUL_CHRISTMAS_TREE = 268,//圣诞树奖励刷新
    INFO_CHANGE_CHRISTMAS_GIFT = 269, //圣诞礼包界面刷新
    INFO_CHANGE_CONGRATULATION_CRAD = 270,//圣诞贺卡界面刷新
    CONGRATULATION_CRAD_REWARD = 271,//礼物领取
    // ---------------Activity-----------------

    MsgServerListBack = 272,             // 刷新服务器列表返回 MSG_SERVER_LIST_BACK

    MsgRepayInfoInit = 273,           // 累计充值信息初始化 MSG_REPAY_INFO_INIT
    MsgRepayViewShowDes = 274,        // 累计充值信息
    MonthCardGetReward = 275,         // 月卡领取奖励
    BuyMonthCardSucess = 276,         // 购买月卡成功
    MONTHCARD_REFRESH = 277,          //刷新月卡
    SelectMonthCardReward = 278,      // 选择月卡奖励
    CLICK_WELFARE_CELL = 279,         //更新福利中心
    AccConsumeGetReward = 280,         // 福利中心type35领取奖励
    RefreshActivityCommonView = 281,  //通用活动消息监听
    RefreshActivity7View = 282,  //活动7界面刷新监听
    BattlePassChangeData = 283,       //末日挑战数据变化
    MonthBattlePassChangeData = 284,       //月度挑战数据变化
    SeasonBattlePassChangeData = 285,       //赛季挑战数据变化
    AllianceConsumeChangeData = 286, //联盟累充数据变化
    AllianceConsumeRankList = 287, //联盟累充排行榜
    MSG_HOLIDAY_AWARD_INFO = 288,     //每日礼包刷新
    NightChange = 289,                // 白天黑夜
    LightChange = 290,

    // mark - ---------- hero skill begin -----------
    SkillUpgradeEnd = 291,            // 技能升级
    RefreshUnlockSkillCondition = 292,// 刷新解锁条件界面
    HeroMedalSelectEnd = 293,         // 勋章选择确定
    CloseHeroUnlockPanels = 294,      // 关闭一些特定界面
    UpdateHeroMedalPanel = 295,       // <-- as name
    // mark - ---------- hero skill end -------------

    //英雄相关
    MsgHeroesInit = 296,            //英雄信息初始化
    MsgHeroesUpdate = 297,            //英雄更新信息
    HeroBeDecomposedEnd = 298,        //英雄被分解
    HeroLevelUpgrade = 299,           //英雄等级改变
    HeroRecruitRefreashFree = 300,    //刷新英雄招募免费次数
    HeroRecruitRefreashActivity = 301, //刷新英雄招募活动板块
    OpenHeroPage = 302,            //打开英雄面板时已经打开
    CloseJiBanPanel = 303,            //关闭羁绊界面
    HeroUnLockSkill = 304,            //英雄技能槽解锁成功


    MerchantItemRefresh = 305,        // 旅行商人刷新
    MerchantBuyItemSucess = 306,      // 旅行商人购买道具成功
    ChipCollectSucces = 307,          // 芯片收集完成
    CR_UPDATE_SHOW = 308,             // 连续充值领奖完成刷新
    DesertThroneDataBack = 309,       // 沙漠王座信息返回
    CrossThroneDataBack = 310,        // 王座信息
    ThroneFightInfoDataBack = 311,    // 王座战斗信息
    ThroneUIClose = 312,              // 关闭王座界面
    WorldTrebuchetAtt = 313,          // 防御塔攻击
    UpdateBuildingProtectTime = 314,  // 更新建筑保护罩
    UpdateBuildingResProtectTime = 315,   // 更新建筑资源保护罩时间
    UpdateMarchItem = 316,            // 行军队列
    AllianceExchangeOptRefresh = 317, // 联盟团购，购买联盟礼包后的刷新
    AllianceExchangeRefresh = 318,    // 联盟团购，联盟礼包推送
    AllianceSetRankName = 319,        // 修改联盟 成员称谓返回
    AllianceDonateRankDay = 320,      // 联盟捐献排行榜日榜单
    AllianceDonateRankWeek = 321,      // 联盟捐献排行榜周榜单
    AllianceDonateRankAll = 322,      // 联盟捐献排行榜历史榜单
    GoldBoxRefresh = 323,             // 金币宝箱 刷新
    ChangeWorldScene = 324,      //改变世界地图的场景显示
    WorldMapCameraChangeZoom = 325,  //世界地图相机渐变size大小
    RefreshWorldMapUI = 326,         //刷新世界地图UI
    PlayerRank = 327,                 //角色排行榜信息刷新
    AllianceRank = 328,                //联盟排行
    ResetPositionCity = 329,            //小地图位置点重制位置
    UpdateClonceData = 330,           // 更新克隆中心数据
    UpdateCloneSoldier = 331,         // 更新克隆中心
    UpdateCloneDonate = 332,          // 克隆中心数据返回
    CloneDonateListBack = 333,        // 克隆执行捐赠数据
    CloseDonatePlayerInfoList = 334,  // 关闭捐赠玩家信息列表  lhy
    SearchUserAlliance = 335,         // 邀请入盟 成员搜索
    // landscape - ---------- 建筑学院 begin -------------

    BuildLandscapeList = 336,          //建筑学院界面相关信息
    BuildLandscapeUnLock = 337,       //建筑学院解锁返回
    BuildLandscapeUnDown = 338,       //建筑学院皮肤使用

    // --------------- Missile -----------------
    MissleCostUpdate = 339,           // 导弹升级条件改变，对应ls的消息是"MSG_UPDATE_COST_MISSILE"
    TrainMissile = 340,               // 生产导弹，对应ls的消息是"MSG_TRAIN_MISSILE"
    BeginTrainMissile = 341,
    MSG_FINISH_TRAINING_MISSILE = 342,  // 导弹生成完成，可以收集
    FINISH_TRAINING_MISSILE = 343,
    MSG_MISSILE_DEFENCE_RECORD = 344,  // 反导记录数据更新
    OpenMissleFromSilo = 345,

    // --------------- 配件工厂 -----------------    

    EquipMaterialSceleted = 346,    //制造界面材料被选择。
    PartsEquipMakeStart = 347,      // 装备建造开始
    BuildPartsEquipMakeStart = 348,
    BuildPartsMaterialMakeStart = 349,
    PartsEquipMakeFinished = 350,   //装备制造成功
    PartsMaterialMergeSuccess = 351,            //材料合成
    EquipMergeComplete = 352,        //材料合成成功
    Equip_Harvest = 353,            //装备收取
    Material_Harvest = 354,             //材料收取完成。
    EquipPutOnMsg = 355,            //装备穿戴
    EquipDeleteMsg = 356,            //删除装备
    EquipTakeOffMsg = 357,            //装备脱下
    EquipSplitMsg = 358,                //装备分解
    EquipSuitSkillUpdate = 359,        //套装技能更新。
    DestroyMaterial = 360,            //删除材料
    SpineCarUpdate = 361,               //装备更新后spine动画
    ActiveBg = 362,
    // --------------- Missile -----------------

    // --------------- Truck ------------------
    RefreshTruckInfo = 363,
    // --------------- Truck ------------------

    MailReceiveServerBack = 364,      //领取邮件奖励返回
    MailSaveBack = 365,
    MailPush = 366,                   //有新邮件

    GetStatusItemSuccess = 367, //获取buff数据完成
    GetProtectBuffRecordSuccess = 368, //获取保护罩使用记录数据完成
    ClashBattleStateUpdate = 369,     // CLASH_BATTLE_STATE_UPDATE
    ClashBattleBuildUpdate = 370,     // CLASH_BATTLE_BUILD_UPDATE
    ClashInfoUpdate = 371,            // CLASH_INFO_UPDATE
    ClashBattleBuildUpdateClose = 372,// CLASH_BATTLE_BUILD_UPDATE_CLOSE
    ClashInfoPush = 373,              // CLASH_INFO_PUSH
    MsgRefreshExploitShopView = 374,  // msg.refresh.exploitShop.view
    MsgRefreshFragmentShopView = 375, //刷新碎片商店（金币/纪念章商店）界面(总刷新，有可能需要改) lhy

    MsgRefreshOneFragmentInfo = 376, //单个刷新碎片商店的碎片和金币 --lhy 2019.4.29

    RefreshItems = 377,            // 每次道具更新都发送的信号量
    ChangeServer = 378,           // 切换服务器

    DesertSeasonDataBack = 379,       // 末日争霸 -请求联盟列表数据返回
    FBVipUnlock = 380,            // 是否解锁了vip FBVipUnlock
    FBVipSlotValue = 381,         // vip摇杆值 fbVipSlotValue
    VipStoreRefrsh = 382,         // vip商店刷新 VIP_STORE_REFRSH
    VipPrivilegeRefrsh = 383,     // vip特权刷新 fbVipSlotValue
    MsgVipstoreUpdateExp = 384,     // vip更新经验 MSG_VIPSTORE_UPDATE_EXP
    UpdateVipUpdateLV = 385,       //updateVipUpdateLV
    MsgBuyConfirmOK = 386,     // vip购买确认 msg.buy.confirm.ok
    ItemBuyConfirm = 387,     // item购买确认
    ItemBuyAndUseConfirm = 388,     // item购买并使用 确认 
    ItemUseConfirm = 389,     // item使用 确认 
    RefreshFBPrivelege = 390,   //刷新特权
    RefreshFBStore = 391,       //刷新商店
    ALContributionDataBack = 392,     // 末日争霸 -请求联盟成员贡献数据返回  ls.al.act.contribution.info
    ALSetAvoidTimeBack = 393,
    ALGetAvoidTimeBack = 394,
    // --------------- Queue(FB) -----------------
    MSG_QUEUE_REMOVE = 395,  // 队列完成

    MSG_UPDATE_MSG_BALL = 396,         // 刷新消息球
    GetMemberPointBack = 397,   //成员点的信息

    HerolotterRewarInfo = 398,        // 抽奖中奖者名单
    MsgAllianceBattleActInfo = 399,    // 联盟对决消息
    MsgFreshDoomsView = 400,           // 刷新末日投资 MSG_FRESH_DOOMS_VIEW

    // --------------- 末日争霸盟战 begin------------------
    DeclareWar_RefreshData = 401,                 // 刷新宣战数据
    DeclareWar_DeclareWarRetData = 402,           // 宣战返回信息
    DeclareWar_BeginDeclareWar = 403,             // 开始宣战
    DeclareWar_AlWarResult = 404,                 // 获取同组内战况记录
    DeclareWar_History = 405,                     // 获取宣战记录
    DeclareWar_Search = 406,                     //  查询
    // --------------- 末日争霸盟战 end -------------------

    materialCreateEnd = 407, //材料数据完成，刷新界面
    TalentViewRefreshInfo = 408,      // 专精刷洗界面

    MsgDomainGiveUpPointsBack = 409,// MSG_DOMAIN_GIVE_UP_POINTS_BACK
    MsgMapUpdate = 410,// MSG_MAP_UPDATE
    MsgDomainCollectEnd = 411,// MSG_DOMAIN_COLLECT_END
    MsgMyDomainDataBack = 412, //MSG_MY_DOMAIN_DATA_BACK
    UIDesertTileRedDot = 413, //UI_DESERT_TILE_RED_DOT
    MsgDomainMineArmyBack = 414, //MSG_DOMAIN_MINE_ARMY_BACK
    WBCrashStatus = 415, //w.b.crash.status
    FBTileSeasonDeclareHisListViewNewData = 416, // 请求新的赛季小组列表回调 FBTileSeasonDeclareHisListView_newData
    MsgDeclareWarDetail = 417,        //联盟宣战详情

    GetUserDomainWarHistory = 418,    // 获取末日争霸土地战斗记录
    DesertRewardViewRefresh = 419,    // 末日争霸 土地领奖刷新界面
    ALBattleEvent = 420,                  // al.battle.event
    DomainForceRankDataBack = 421,    // 末日争霸土地排行榜
    RefreashBuildUpGrade = 422,
    PartsMaterialTimeDone = 423,
    MsgMakeProductEnd = 424,          // 世界建筑生产完成事件
    UnBuildUpgradeFinish = 425,       //成功使用加速道具但没有完成
    MsgStopProductEnd = 426,          // 世界建筑停止生产
    MsgColloectProductEnd = 427,      // 世界建筑收集生产
    RelicBuildRebuildSuccess = 428,
    CountryFlagChanged = 429,
    BuyHeroCard = 430, //购买英雄卡 BUY_HERO_CARD
    AllianceCombineList = 431,        //联盟合并列表
    alliance_combine_details_refresh = 432, //alliance_combine_details_refresh 联盟合并信息刷新

    MsgArmyUserRefresh = 433,     // MSG_ARMY_USER_REFRESH
    ResetTreatNum = 434,          // 重置伤兵数 resetTreatNum
    GoToHealthing = 435,          // GO_TO_HEALTHING
    MsgQueueRemove = 436,  // 队列删除 MSG_QUEUE_REMOVE
    MsgQueueAdd = 437,     // 队列添加 MSG_QUEUE_ADD
    ArmyNumChange = 438,   // 兵种数变化 ARMY_NUM_CHANGE
    TreatNumChange = 439,  // 伤兵数变化 TREAT_NUM_CHANGE
    MsgTroopsChange = 440,  // 部队改变 MSG_TROOPS_CHANGE =  TroopsPanel???
    RefreshCarRepairInterface = 441, //刷新修运兵车界面 lhy 2019.5.29
    MsgSpecialSolderUpdate = 442,  //MSG_SPECIAL_SOLDER_UPDATE
    CollectSoldierAddPower = 443, //MSG_COLLECT_SOLDIER_ADD_POWER
    UICommonHelpTipsClose = 444,
    UpdateTradingCenterData = 445,//交易中心数据更新
    UpdateTradingCenterCallPlane = 446,//交易中心呼叫飞机
    GetHeadImgUrl = 447,  //获取自定义头像
    UpdateHeadImg = 448,  //更新自定义头像
    LoadGiftFinish = 449, //加载礼品页面成功
    
    GiftBoxRefresh = 450,
    SELECT_USER_GIVE = 451,
    SearchUserGiftBox = 452, //礼品 搜索玩家
    GiftBoxPeopleSelected = 453, //礼品 选中检索的玩家

    //为了节省性能把队列完成细分为建筑和科技
    OnBuildQueueFinish = 454,    //建筑队列完成，对应建筑小车
    OnScienceQueueFinish = 455,  //科技队列完成，对应科技

    OnScienceQueueResearch = 456, //科技队列研究

    Update_Alliance_Gift_Num = 457, //刷新礼品数量
    Translate_Normal = 458,   //Google翻译 - 界面普通翻译
    Translate_Mail = 459,     //Google翻译 - 邮件内容翻译

    UI_RESOURCE_VISIBLE = 460,  //UIResource会否可见
    CHANGE_UIRESOURCE_TYPE_PUSH = 461,//在UIResource栈中添加一个状态
    CHANGE_UIRESOURCE_TYPE_POP = 462,  //返回在UIResource栈中上一个弹出状态
    CHANGE_UIRESOURCE_TYPE_ALLPOP = 463,  //清空UIResource栈（会变成栈底的样子0）
    BuildPowerAdd = 464,           //建筑战斗力增加
    UpdateGold = 465,              //刷新钻石数量

    CLOSE_UIPOPGETHERO = 466,  //关闭UIPopGetHero界面

    MSG_WORLD_BUILD_FREE_NUMBER_CHANGE = 467, //更改m_worldBuildFreeNumberChangeTime的时候会发

    ClickStateIcon = 468,
    BuildChangeState = 469,//建筑切换状态。
    BUILD_PRODUCE_FAST = 470,//急速生产
    BUILD_PRODUCE_FAST_BACK = 471, //极速生产消息返回
    BUILD_PRODUCE_FAST_END = 472, //极速生产结束，用于让资源的极速动画（不是转表，而是生产动画）停止
    BUILDING_TURBO_MODE_GET = 473, //批量极速信息
    BUILDING_TURBO_MODE_USED = 474,//批量极速使用
    BUILD_REPAIR = 475,//建筑修理
    ITEM_COMPOSE_SUCCESS = 476,//兑换物品成功

    MSG_ITME_STATUS_TIME_CHANGE = 477,//Push作用号之后发的

    //生存者庆典
    MSG_FRESH_SURVIVAL_VIEW_GET = 478,//刷新生存者庆典页面
    MSG_FRESH_SURVIVAL_VIEW = 479,//刷新生存者庆典页面(进页面获取信息后刷新)
    MSG_FRESH_SURVIVAL_VIEW_MARK = 480,//刷新生存者庆典页面

    MSG_RESPONSED3RDPLATFORM = 481,//第三方平台消息
    MSG_USER_BIND_CANCEL = 482,//用户绑定取消
    MSG_USER_BIND_OK = 483,//绑定成功

    RES_TOOL_EXCHANGE_MSG = 484,//交易中心兑换
    RES_SELL_MSG = 485,//交易中心出售
    Immediately_Back_Carport = 486,
    City_Truck_Create = 487,
    City_Truck_Hide = 488,
    ZOMBIE_CLICK_REWARD = 489,//城内点击僵尸
    GOLDEXCHANGE_LIST_CHANGE = 490,//礼包顺序改变
    GOLDEXCHANGE_LIST_CHANGE_RAND = 491,//礼包改变
    PAYMENT_COMMAND_RETURN = 492,//
    CityBattleZombiePreloadFinish = 493,//僵尸预加载完成
	ResetMailState = 494,
	OtherPlayInfo = 495,
    GUIDE_INDEX_CHANGE = 496,//新引导改变引导
    BREAK_SOFT_GUIDE = 497,//新引导打破软引导
    MergeChatMessage = 498, //合并信息类邮件
    ShowMailChatTips = 499, //显示tips
    Translate_Dialog = 500,
    GUIDE_GOTO_ATTACK_WORKER = 501,//新引导丧尸可以攻击工人
    SendMailDone = 502,
    MailRemoveInChannel = 503,//邮件移除频道，刷新当前界面
    REFRESH_MONSTERACTIVITY = 504,//刷新区域扫荡活动数据
    REFRESH_BASEBUILD = 505,//刷新大本状态
    REFRESH_BROKEFENCE = 506,//刷新隔离墙状态
	ShowDialogOriginallan = 507,//显示邮件原文
	WarTroppShowExplain = 508,

    // --------------- BuildIcon ------------------
    LoadCityBuildingFinsh = 509,
    PlayerCareerChanged = 510,
    CareerInfoUpdate = 511,
    UpdateQuickSaveStr = 512,
    RunOutReousrceChipEnergy = 513,
    BackToBaseCar = 514,//吉普车回车库
    GetReward = 515,//主页面领取奖励
    ClearPolt = 516,// 污水处理清楚绿块
    PLAY_MP4 = 517,//新引导播放MP4
    GetRewardAniPlayEnd = 518,
    CloseUIBuilding = 519,//新引导防止卡死


    // --------------- Chat ------------------------
    PUSH_CLASHEVENT_COMMAND = 520,
    CHAT_TRANSLATE_COMMAND = 521,
    CHAT_BLOCK_COMMAND = 522, // 屏蔽
    CHAT_UNBLOCK_COMMAND = 523, // 解除屏蔽
    CHAT_RECIEVE_ROOM_MSG_COMMAND = 524, // 收到新消息
    CHAT_UPDATE_ROOM_MSG_COMMAND = 525,
    CHAT_UPDATE_ALLIANCE_ROOM_COMMAND = 526,
    REDPACK_VIEWLOG_COMMAND = 527, // 查看红包记录
    REDPACK_SELECT_GP_COMMAND = 528,
    REDPACK_BUY_GP_SUCCESS = 529,

    CHAT_SHOW_CONTENT_TIPS_COMMAND = 530,
    CHAT_HIDE_CONTENT_TIPS_COMMAND = 531,
    GOTO_WORLD_POSITION = 532,
    CLOSE_CHAT_UI_COMMAND = 533,
    REDPACK_SHOW_COMMAND = 534,
    CHAT_KEYBOARD_ADJUST_COMMAND = 535,
    CHAT_REQUEST_HISTORY_MSG_RESULT = 536,
    CHAT_SEND_ROOM_MSG_COMMAND = 537,
    CHAT_SEND_ROOM_MSG_SUCCESS = 538,
    CHAT_SEND_ROOM_MSG_FAILURE = 539,
    CHAT_REQUEST_HISTORY_MSG_COMMAND = 540,

    CHAT_ROOM_CREATE_COMMAND = 541,
    CHAT_LEAVE_ROOM_MSG_COMMAND = 542,
    CHAT_ROOM_CHANGE_NAME_COMMAND = 543,
    CHAT_ROOM_OPEN_INVITE = 544,
    CHAT_ROOM_ENABLE_REMOVE = 545,
    CHAT_ROOM_UPDATE_MEMBER = 546,
    CHAT_ROOM_DELETE_MEMBER = 547,

    CHAT_ROOM_INVITE_SHOW_ALLIES_RANK = 548,
    CHAT_ROOM_INVITE_HIDE_ALLIES_RANK = 549,
    CHAT_ROOM_INVITE_USER_TOGGLE_ON = 550,
    CHAT_ROOM_INVITE_USER_TOGGLE_OFF = 551,
    CHAT_ROOM_INVITE_SEARCH_PLAYER_RESULT = 552,
    CHAT_ROOM_INVITE_PLAYER_RESULT = 553,
    CHAT_ROOM_OPEN_BY_GROUP = 554,//打开指定Group的频道
    CHAT_ROOM_OPEN_BY_ID = 555,

    CHAT_SEND_VOICE_MSG = 556,
    CHAT_VOICE_PLAY = 557, // 播放语音
    CHAT_VOICE_QUEUE = 558, // 播放语音队列

    CHAT_RESEND_ROOM_MSG_COMMAND = 559,
    CHAT_REMOVE_ROOM_MSG_COMMAND = 560,

    // --------------- 联盟中心----------------------
    CloseUIBookMarkAlliance = 561,//关闭联盟中心收藏夹界面
    CloseWorldBuildMoving = 562,//关闭让世界建筑进入移动状态的界面

    // --------------- 世界迁城抬起特效----------------------
    WORLD_MOVE_UP_EFFECT = 563,

    // --------------- 新科技界面----------------------
    SCIENCECENTERNEW_CHANGE_INDEX = 564,
    CLOSE_SCIENCE_UPGRADE = 565,//关闭科技升级界面

    //----------------世界标记-----------------//
    UpdateWorldMark = 566,        //刷新世界标记

    MSG_DRAWRESULT_BACK = 567,//幸运大转盘返回数据

    //-----------------军团相关----------------//
    MSG_AZ_TERRITORY_DETAIL = 568,
    ALLIANCE_ARMYGROUP_DOMAIN_CHECK = 569,
    CloseOtherTerritoryArmyInfoDetail = 570,//关闭其他部队详情
    OnEndGarrisonTroopCallBack = 571,       //驻守部队撤回命令消息返回成功
    UpdateTerritoryCenterBuildInfoPage = 572, //刷新联盟中心建筑详情页面
    UpdateLegionSettingPage = 573,            //刷新军团设置界面
    SendChosenLegionTroopForSetting = 574,     //军团设置页面传递选择的部队Id
    ARMYGROUP_LEADER_MEMBER_REFREH = 575,      //设置军团长页面刷新
    ARMYGROUP_DISPATCH_VIEW = 576,             //刷新军团调遣面板
    ALLIANCE_ARMYGROUP_SELECT_ARMYID = 577,
    ALLIANCE_ARMYGROUP_SELECT_ARMYID_EMPTY = 578,

    //-----------------末日争霸领奖排行榜----------------//
    MSG_DOMAINSEASONREWARDCELLITEM = 579,//"msg_DomainSeasonRewardCellItem"
    UI_DOMAIN_PLAYER_RANK_SELECT = 580,//ui_domain_player_rank_select
    UI_DOMAIN_PLAYER_RANK = 581,//ui_domain_player_rank
    DESERTSENDREWARDLISTMESSAGE = 582,//domain.new.al.force.gift.send 消息的回调

    
    //-----------------装扮----------------//
    DECORATE_DRESSBASECITY_REFRESH = 583,
    DECORATE_INFONODE_REFRESH = 584,

    //--------拾荒完成-----//
    ScavengePointFinsh = 585,

    UIMissileLaunchItemSelect = 586,//导弹发射界面选择导弹
    FbMissileAlliance = 587,//刷新毁灭导弹

    Combine_Select_Index = 588,//选择组合index
    Close_Item_Combine_Panel = 589,//关闭使用物品界面
    Close_UIBuildMenu_Panel = 590,//关闭建造类型界面
    
    CLOSE_LOADEDITORBUILD = 591,//关闭load转圈界面
    
    UPDATE_BUILD_DATA = 592,//玩家建筑信息更新

    //--------加载完成-------
    LOAD_COMPLETE = 594,
    
    COLLECT_OBJECT_SHOW = 595,//矿跟提示绿色放置地块
    COLLECT_OBJECT_HIDE = 596,//矿跟隐藏绿色放置地块
    
    UIMAIN_BOTTOM_SELECT_BUILD = 597,
    UIMAIN_BOTTOM_SELECT_BUILDTYPE = 598,
    UIMAIN_BOTTOM_SELECT_RESOURCE = 599,
    GOTO_BUILD = 600,//建造界面
    UIMAIN_BOTTOM_RESET_BUILDTYPE = 601,
    UIMAIN_BOTTOM_RESET_BUILDTYPE_INFO = 602,
    REGET_MAIN_POSITION = 603,
    UPDATE_POINTS_DATA = 604,//更新世界点信息
    UIMAIN_VISIBLE = 605,//刷新主界面是否可见
    UIMAIN_BOTTOM_CHANGE_BUILD_TYPE = 606,
    UIMAIN_BOTTOM_CHANGE_BUILD_SELECTS = 607,
    UIMAIN_BOTTOM_CHANGE_BUILD_TYPE_INFO = 608,
    UIMAIN_BOTTOM_CHANGE_BUILD_TYPE_SELECT = 609,
    UIMAIN_BOTTOM_CHANGE_MIDDLE_RESOURCE_STATE = 610,
    WORLD_CAMERA_CHANGE_POINT = 611,  //相机改变观看坐标点
    UIITEM_SELECT = 612,//点击物品
    CLICK_MAIL_ITEM = 613,//点击邮件页签
    REFRESH_MAIL_TABLE = 614,//刷新邮件整体界面
    REFRESH_RESOURCE_BAG = 615,//刷新资源背包整体
    CLICK_RESOURCE_ITEM = 616,//点击资源背包cell
    UPDATE_SCIENCE_DATA = 617,//更新科技信息
    CLICK_ALLIANCE_ITEM = 618,//点击联盟背包cell
    END_SEARCH = 619,//结束查找
    ALLIANCE_WAR_DELETE = 620,//联盟战争消息删除
    CLICK_FORMATION_ITEM = 621,//点击编队页签
    BUILD_IN_VIEW = 622,//建筑进入视野
    BUILD_OUT_VIEW = 623,//建筑离开视野
    QUEUE_TIME_END = 624,//队列时间到达
    AddBuildSpeedSuccess = 625,//建筑加速
    AllianceQueueHelpNew = 626,//新的联盟帮助申请(队列）
    AllianceBuildHelpNew = 627,//新的联盟帮助申请(建筑）
    MonsterMoveStart = 628,//野怪开始移动
    MonsterMoveEnd = 629,//野怪移动结束
    PUSH_NOTICE = 630,//手机推送通知
    CLICK_ALLIANCE_SHOP_ITEM = 631,//点击联盟商店物品
    AllianceNameChange = 632,//联盟改名
    AllianceAbbrChange = 633,//联盟改简称
    AllianceLanguage = 634,//联盟改语言
    UIMAIN_CHANGE_BUILD_ENTER = 635,
    UIMAIN_CHANGE_BUILD_OUT = 636,
    CHAT_LOGIN_SUCCESS = 637,
    CHAT_REFRESH_CHANNEL = 638,
    ROOM_KICK_PLAYER_RESULT = 639,
    UPDATE_MSG_USERINFO = 640,
    CHAT_UPDATE_ROOM_LIST_LASTMSG = 641,
    CHAT_CHANGE_CURRENT_ROOM = 642,
    BuildResourcesStart = 643,//农田种植
    BuildResourcesSecond = 644,//农田喂副产品 
    ClickFarmBuildShow = 645,
    ClickFarmBuildHide = 646,
    BuildConnect = 647,//建筑联通
    BuildLackConnect = 648,//建筑未联通
    RefreshResidentOrder = 649,//（增加或删除一个居民订单）
    RefreshResourceItem = 650,//刷新资源道具
    DelayRefreshResource = 651,//延时刷新
    BuildUpgradeAnimationFinish = 652, //建造动画播放完成
    EffectNumChange = 653,//作用号发生变化
    OnWorldInputDragBegin = 654,//在世界上拖拽开始
    OnWorldInputDragEnd = 655,//在世界上拖拽结束
    RefreshUIWorldTileUI = 656,//刷新UIWorldTileUI界面
    RefreshFarmUI = 657,//刷新农场界面
    ShowCapacity = 658,//展示仓库
    RewardItemAdd = 659,//仓库增加
    FarmDragEnd = 660,//农田收割松开手
    ChangeCameraLod = 661,//相机高度lod级别改变
    ShowResourceUpdate = 662,//资源变化（仅做展示，不变数据）
    ShowCapacitySecond = 663,//展示仓库-收取副产品
    RefreshEarthOrder = 664,//地球订单刷新
    GetNewEarthOrder = 665,//获得新的地球订单
    EndEarthOrder = 666,//结束地球订单
    ViewEndEarthOrder = 667,//订单页面结束地球订单
    GetFactoryData = 668,
    GatherFactoryItem = 669,
    AddFactoryBox = 670,
    AddFactoryProduct = 671,
    OnMeteoriteHitGlass = 672,//陨石撞罩子
    UIMainWarningShow = 673,//主界面显示红色提示
    UIMainWarningHide = 674,//主界面隐藏红色提示
    FoldUpBuilding = 675,//收起建筑
    LOAD_PLAY_VIDEO = 676,//loading界面播放动画
    FarmSecondProduct = 677,//副产品产生
    Guide_video_Play = 678,//新建账号播放视频
    AllianceAnnounce = 679,//联盟公告
    AllianceRestriction = 680,//入盟限制内容
    GET_INVITE_USERS_SUCCESS = 681,//获取联盟邀请列表
    GOTO_SCIENCE = 682,//跳转科技
    LF_AccountListView_Close = 683,       //历史账号界面关闭
    LF_AccountListView_Refresh = 684,       //历史账号界面刷新
    LF_Account_History = 685,    //历史账号
    MessageBallChange = 686, //消息球修改
    GatherResourceItemFinish = 687,//收获农作物结束
    SoldResourceItem = 689,//卖资源道具
    LUA_BUILD_INIT_END = 690,//LUA初始化建筑信息结束
    CanGetProduct = 691,//食品加工厂可领道具
    GetAllProduct = 692,//食品加工厂所有道具全部领完
    RefreshUIBuildQueue = 693,    //刷新建造队列UI
    RefreshFarmGatherUI = 694,//刷新收获界面
    HeroAdvanceSuccess = 695,
    HeroLvUpSuccess = 696,
    ClickFarmBuildShowEffect = 697,
    ClickFarmBuildHideEffect = 698,
    ShowMainUIExtraResource = 699,//传luatable,里面是资源类型
    HideMainUIExtraResource = 700,
    TouchPastureAnimal = 701,
    RefreshPastureUI = 702,//刷新牧场界面
    SetNewAnimal = 703,//设置新的动物
    HeroResetSuccess = 704,
    OnCancelHeroSelect = 705,
    AllianceInitOK = 706,
    AllianceQuitOK = 707,
    ReturnTimeFromCurPosToTargetPos = 708,
    Mail_DeleteMailDone = 709, // 总数发生变化的时候更新
    Mail_DeleteBatchMailDone = 710, // 批量删除邮件
    Mail_Select_Channel = 711, // 选择频道
    OnSelectHeroSelect = 712,//选择英雄
    UIResourceCostChangeState = 713,//火力发电站进度条改变状态
    RecruitCampChange = 714,
    AllianceIntro = 715,//联盟宣言
    AllianceMemberNeedHelp = 716,//盟友寻求帮助气泡
    COLLECT_OBJECT_SHOWNew = 717,
    COLLECT_OBJECT_HIDENew = 718,
    ChangeNameIcon_Select = 719,
    UpdatePlayerHeadIcon = 720,
    UpdateCollectPos = 721, //更新采集目标点
    GetAssistanceData = 722,//获取援助数据
    FakeBuildingSelectLocation = 723,//新建筑选址中
    UpdateFakeBuildingPos = 724,//选中的位置变化
    ShowIsOnFire = 725,//建筑着火特效
    UpdateRankPreview = 726,//刷新排行榜排名第一的数据
    GetAllDetectInfo = 727,
    UpgradeDetectPower = 728,
    DetectInfoChange = 729,
    HeroMedalExchanged = 730,
    OnClickWorld = 731,
    OnClickMarch = 732,
    CheckDomeOpen = 733,//大本开罩
    CollectAnimEnd = 734,//采矿机器人吧矿扔到建筑里
    MailScoutReposition = 735,
    MailDetailReport_ClickItem = 736,
    RefreshArrow = 737,//刷新箭头位置
    OnGoodsRedState = 738,
    LoginCommandError = 739,  // 登录错误
    LoginInitError = 740, 
    Net_Connect_Error = 741,
    Net_Server_Status = 742,
    CloseDisconnectView = 743,
    WorldTroopGameObjectCreateFinish = 744,//世界行军/野怪创建完成
    CheckShowMainBuildLabel = 745,
    ShowTroopHeadNotBattle = 746,
    ShowTroopHeadInBattle= 747,
    ShowTroopBattleValue= 748,
    HideTroopHead= 749,
    DetectEventRewardGet = 750,
    Event_ShowBattleReportDetail = 751, //显示详细战报
    BundleDownloadProgress = 752,
    RefreshDataPersonalArms = 753,
    CheckPubBubble = 754,
    AlGiftHideNameStateUpdate = 755,
    RefreshTopResByPickUp=756,
    DailyQuestReward = 757,
    OnAdvanceSuccessClosed = 758,
    UpdateRoadData = 759,
    ShowTroopName = 760,
    HideTroopName = 761,
    CheckTroopStateIcon = 762,
    UpdateCityPoint = 763,//更新主城点信息
    Queue_Add = 764,//增加新队列
    CityTroopMove = 765,//移动城市编队
    CityGarbageResult = 766,//捡垃圾结果
    OpenUI = 767,//打开一个UI
    RefreshGuide = 768,//刷新引导
    QuestRewardSuccess = 769,//任务领奖成功
    Build_Time_End = 770,
    Nofity_Alliance_Battle_Week_Rusult_VS = 771,//联盟军备周结算数据
    AllianceCompeteRankListUpdated = 772,//联盟军备排行榜信息更新
    AllianceCompeteRewardsReposition = 773,//联盟军备-奖励重新布局
    AllianceCompeteWeeklySummaryUpdated = 774,//联盟军备-本周日结算数据更新
    AllianceArms_OpenBox = 775,//联盟军备活动开启宝箱
    RefreshAllianceArmsUI = 776,//联盟军备数据更新，刷新界面
    StopSvAutoToCell = 777,//停止自动滚动
    PlayGetReward =778,//播放任务奖励飞行特效
    CreatedResidentOrder = 779, //创建商业中心
    CameraFollowCityTroop = 780, //相机跟随行军
    OnWorldInputPointDown = 781,//在世界上点击
    TroopRotation = 782,//世界行军视角旋转
    SevenDayGetReward = 783,//七日领奖
    SkipFactoryAni = 784, // 加工厂加速动画跳过
    ShowDomeHideEffect = 785,
    ShowDomeShowEffect = 786,
    OpenFogSuccess = 787,// 解锁迷雾
    OnTaskForceRefreshFinish = 788,//任务列表动画结束
    OnSpecialTaskUpdate = 789,//特殊任务刷新
    AttackExploreStart = 790,//攻击探索事件点开始
    AttackExploreEnd = 791,//攻击探索事件点结束
    WorldMarchDelete = 792,//行军删除
	GuideTimelineMarker = 793,
    ContentLayoutReposition = 794,
    ShowExploreHeadInBattle= 795,//战斗中显示探索点头像血量相关
    ShowExploreBattleValue= 796,//更新探索点头像血量战斗相关
    HideExploreHead= 797,//隐藏探索点头像血量战斗相关
    CityFightResult = 798,//城内攻击结果
    CreateFormationUuid= 799,//引导创建兵营存储uuid
    RefreshCityTroopPeopleNum= 800,//城市行军小人数量改变
    BuildMainZeroUpgradeSuccess= 801,//大本0升1
    FirstPayStatusChange = 802,
    FarmGuideFakePlant = 803,//农场引导种植假的土豆
    GetSingleGarbageInfoSuccess = 804,//获取单人捡垃圾奖励
    FarmGuideFakePlantShowState = 805,//农场引导种植土豆隐藏/显示
    ChapterTaskGetReward = 806,
    GarbageCollectStart = 807,//捡垃圾小人跑到位置
    SingleGarbageCollectStart = 808,//主城捡垃圾小人跑到位置
    GuideMoveArrowPlayAnim = 809,//引导移动的手指播放按下/抬起动画
    WorldArmyCollectAnimEnd = 810,//采矿机器人吧矿扔到建筑里
    ShowLoadEditorBuild = 811,//c#打开拖拽建筑的加载效果UI·
    VipDataRefresh = 812,
    VipRefreshFree = 813,
    VipRefreshPayGift = 814,
    ShowPower = 815,
    DailyQuestLs = 816,
    ShowAllGuideObject = 817,
    UnlockFogAnim = 818,//做解锁迷雾动画
    ReadOneMailRespond = 819,
    WelfareStatusChange = 820,
    CloseUI = 821,//关闭UI
    UpdateGiftPackData = 822, //礼包数据更新
    ToggleRecruitScene = 823,
    BeginDownloadUpdate = 824,
    EndDownloadUpdate = 825,
    NetworkRetry = 826,
    UINoInput = 828,//禁止UI点击
    UIMainShowMailTips = 829,
    AllianceWarNewStatusChanged = 830,
    ShowHeroIconByUseSkill=831,
    RefreshGuideAnim = 832,
    ShowHeroHitedUiEffect=834,
    BuildBoxOpenFinish = 835,
    ShowCanBuildEffect = 836,
    HideCanBuildEffect = 837,
    ShowUIMainSearch = 838,
    CityDomeShow = 839,
    CityDomeHide = 840,
    ShowDomeGlass = 841,
    ShowBuildTopUI = 842,
    HideBuildTopUI = 843,
    GuideNoOpenUI = 844,
    LowFps = 845,
    GuideWaitMessage = 846,
    GetNewGroceryStoreOrder = 847,
    RefreshGroceryStoreOrder = 848,
    EndGroceryStoreOrder = 849,
    OnAnyViewClosed = 850,//关闭某个界面
    OnPackageInfoUpdated = 851,//收到新弹出礼包
    WorldAllianceCityDetail = 852,
    UIPlaceBuildChangePos = 853,
    FormationInfoUpdate = 854,
	UICreateFakePlaceBuild = 855,//假建筑创建成功
	GetOneAllianceGift = 856,
	AllianceOrderRank = 857,
    ShowAllianceCitySoldierBlood = 858,
    HideAllianceCitySoliderBlood = 859,
    AllianceOrderGetInfo = 860,
    AllianceOrderGetRank = 861,
    AllianceOrderReceive = 862,
    AllianceOrderGiveUp = 863,
    AllianceOrderFill = 864,
    AllianceOrderGetReward = 865,
    WorldCityOwnerInfoReceived = 866,  //联盟所属信息初始化
    WorldCityOwnerInfoChanged = 867,   //联盟所属信息变更
    RefreshUIWorldPointView = 868,
    OnWorldInputPointClick = 869,//在世界上点击
    OnWorldInputPointDrag = 870,//在世界上拖拽移动一个点
    OnWorldInputPointUp = 871,//在世界上点击抬起
    RefreshTopResSuc = 872,
	AlLeaderElectStatusChange = 873,
	AlLeaderVoteStatusChange = 874,
	AlSysStateChange = 875,
	AlLeaderCandidateUpdate = 876,
	UserResSynNew = 878,
	RefreshUIGuideHeadTalk = 879, //刷新头像对话
	AllianceOrderUpdateStage = 880,
	UnlockBuilding = 881,
	RefreshMonsterRewardBag = 882,
	MarchEndWithReward = 883,//战斗胜利，捡垃圾，采集获得奖励
	MarchFail = 884,//战斗失败
	ShowTroopAction = 885,
	HideTroopAction = 886,
	ShowCityTroopObject = 887,
	RefreshActivityRedDot = 888,
	ShowUnlockBtn = 889, //显示解锁按钮
	UpdateDayActInfo = 890,
	HideMarchTip = 891,
	MonthCardInfoUpdated = 892,
	ShowGolloesMonthCardRewards = 893,
	GolloesNumChange = 894,//Obsolete
	GolloesFreeSpeedTimeChange = 895,//Obsolete
	GolloesExplorerRewardStateChange = 896,//Obsolete
	GolloesTraderRewardStateChange = 897,//Obsolete
	GolloesDataChange = 898,
	ScrollViewContentChange = 899,
	ShowCityTroopHead = 900,
	HideCityTroopHead = 901,
	RefreshTerrainDecoration = 902,
	AllianceCityInView = 903,
	AllianceCityOutView = 904,
	UI_SHOWNOTICE = 905,//跑马灯
	
	UpdatePlayerExp = 910,
	ReceiveLevelReward = 911,
	PasturePanelStateChange = 912,
	CloseGuideMoveArrow = 913,
	RefreshRecommendShow = 914,
	UpdateMyAlCities = 915,
	MyAlCityListChanged = 916,
	AllianceBaseDataUpdated = 918,
	RefreshDataAllianceArms = 923,//联盟军备活动数据
	ShowBattleRedName = 924,
	HideSkillHeadEffect = 925,
	ShowPickGarbageResource = 926,
	//新增行军
	MarchAdd = 927,
	//删除行军
	MarchDelete = 928,
	ReInitLoadingLuaState = 929,
	MarchItemTargetMeUpdate = 932,//更新行军目标为自己
	MarchItemUpdateSelf = 935,//自己的行军发生变化
	ShowTroopAtkBuildIcon = 936,
	HideTroopAtkBuildIcon = 937,

	LoadingState = 948,
	WORLD_BUILD_IN_VIEW = 958,//世界建筑进入视野
	WORLD_BUILD_OUT_VIEW = 959,//世界建筑离开视野
	ShowBuildAttackHeadUI = 1002,
	HideBuildAttackHeadUI = 1003,
	ShowBuildDestroyEffect = 1011,
	ShowBuildFixEffect = 1012,
	
	LandUnlock = 1041, // 地块解锁
    
	ShowBattleBuff = 1051,
	HideBattleBuff = 1052,
	ShowWorldZoneChangeColor = 1053,
	ChangeShowFarmState = 1055,
	ChangeShowAnimalState = 1056,
	
	SetCityLabelShow = 1060,
	ShowDesertAttackHeadUI = 1061,
	DesertInView = 1062,
	DesertOutView = 1063,
	ShowActBossBattleValue= 1064,
	LandLockInView = 1072,
	LandLockOutView = 1073,
	LandLockStateUpdate = 1074,
	WorldZoneChangeColorFinish = 1088,
	ShowMarchTrans= 1098,
	HideMarchTrans= 1099,
	ShowWorldMarchByType= 1124,//显示行军模型
	HideWorldMarchByType= 1125,//隐藏行军模型
	SetCityPeopleAndCarVisible = 1126,//显示主城内人和车
	OnKeyCodeEscape = 1138,
	WorldCollectPointInView = 1162,//采集点进入视野
	WorldCollectPointOutView = 1163,//采集点离开视野
	LandLockCreate = 1168,//世界上地块创建
	LandLockDestroy = 1169,//世界上地块删除
	MiniMapDataRefresh  =1195,
	UICreateFakePlaceAllianceBuild = 1208,
	UIPlaceAllianceBuildChangePos = 1209,
	HideDesertAttackHeadUI = 1216,
	
	ChangeShowTroopAttackEffectState = 1224,
	ChangeShowTroopBloodNumState = 1225,
	ChangeShowTroopDestroyIconState = 1226,
	ChangeShowTroopHeadState = 1227,
	ChangeShowTroopNameState = 1228,
	ShowAllianceBuildAttackHeadUI =1246,
	HideAllianceBuildAttackHeadUI = 1247,
	ChangeShowTroopGunAttackEffectState = 1248,
	ChangeShowTroopDamageAttackEffectState = 1249,
	ShowNPCBuildAttackHeadUI =1251,
	HideNPCBuildAttackHeadUI =1252,
	DesertEffectInView = 1270,
	DesertEffectOutView =1271,
	DesertMineInView = 1309,
	DesertMineOutView = 1310,
	
	ShowSiegeAttack = 1314,
	HideSiegeAttack = 1315,
	ShowActAllianceBuildAttackHeadUI =1358,
	HideActAllianceBuildAttackHeadUI = 1359,
	ShowBattleDamageType = 1363,
	ShowDragonBuildAttackHeadUI =1366,
	HideDragonBuildAttackHeadUI = 1367,
	DragonMapDataRefresh = 1368,
	DragonBuildInView = 1369,
	DragonBuildOutView = 1370,
	DragonSecretShow = 1418,
	WorldPassOwnerInfoReceived = 1422,
	WorldPassOwnerInfoChanged = 1423,
	CrossThroneBuildInView = 1435,
	CrossThroneBuildOutView = 1436,
	ShowCrossThroneAttackHeadUI =1437,
	HideCrossThroneAttackHeadUI = 1438,
	DesertUpdateLevelInView = 1447,
	DesertUpdateLevelOutView = 1448,
	ShowTroopMineDamage = 1449,
	
	GoogleAdsUserEarnedReward = 1453,
	GoogleAdsUserExitReward = 1454,
	GoogleAdsUserCreateRewardedAdFail = 1455,
	GoogleAdsUserCreateRewardedAdSuccess = 1456,
	GoogleAdsUserClickAd = 1457,
	
	UnityAdsUserEarnedReward = 1459,
	UnityAdsUserSkipReward = 1460,
	UnityAdsUserCreateRewardedAdFail = 1461,
	UnityAdsUserCreateRewardedAdSuccess = 1462,
	UnityAdsUserClickAd = 1463,
	OnTroopDragonUpdatePos = 1483,
	ShowCollectBattleValue = 2028,
	CollectPointOut = 2029,
	NpcCityInView = 2042,
	NpcCityOutView = 2043,
	MonsterLockInView = 2111,
	MonsterLockOutView = 2112,
	MonsterLockStateUpdate = 2113,
	ShowCityDome = 2333,//显示苍穹
	HideCityDome = 2334,//隐藏苍穹
	RefreshCityRoadArr = 2336,//刷新城内数据（一组）
	DeleteCityRoadArr = 2337,//删除城内数据（一组）
	SetBuildCanDoAnim = 2342,//控制建筑能否做动画
	SetBuildNoDoAnim = 2343,//控制建筑不能做动画
	OnTouchPinchStart = 2344,//开始双指缩放
	OnTouchPinchEnd = 2345,//结束双指缩放
	OnEditorTouchPinch = 2346,//电脑开始滑动滚轮
	SetBuildCanShowLevel = 2347,//控制建筑能显示等级条
	SetBuildNoShowLevel = 2348,//控制建筑不能显示等级条
	OnInputLongTapStart = 2349,//在长按地面开始
	OnInputLongTapEnd = 2350,//在长按地面结束
	UserCitySkinUpdate = 2361,//玩家主城皮肤信息刷新
	ChangeCameraInitZoom = 1253,//修改相机初始高度
	CheckShowGovPos = 1304,//官职标志刷新
	ShowThroneArmyHeadUI = 1305,//王座血量变化
	HideThroneArmyHeadUI = 1306,
	ShowAllianceBossBattleValue = 1352,//联盟boss
	RefreshBauble = 1400,//刷新一个装饰建筑数据
	RemoveBauble = 1402,//删除一个装饰建筑数据
	BaubleInView = 1403,//装饰建筑进入视野
	BaubleOutView = 1404,//装饰建筑离开视野
	RefreshBuildBreak = 1284,//刷新建筑突破数据
	
	// 造桥
	BridgeLevelCarFallIntoWater = 2496,
	BridgeLevelElementFallIntoWater = 2497,
	BridgeLevelExitFinish = 2498,
	BridgeLevelChangeStageFinish = 2499,
	BridgeLevelVictory = 2500,
	BridgeLevelFailed = 2501,
	BridgeLevelUpdateTools = 2502,
	BridgeLevelChangeStage = 2503,
	BridgeLevelPickToolBack = 2504,
	BridgeLevelEdit = 2505,
	BridgeLevelPlay = 2506,
	BridgeLevelPause = 2507,
	BridgeLevelEnter = 2508,
	BridgeLevelExit = 2509,
	BridgeLevelPlaceElement = 2510,
	BridgeLevelPickElement = 2511,
	BridgeLevelBreak = 2512,
	BridgeLevelEnterZone = 2513,
	BridgeLevelStartDragElement = 2514,
	BridgeLevelDragElement = 2515,
	BridgeLevelEndDragElement = 2516,
	
	RefreshBuildDataArr = 2517,//刷新建筑数据（一组）
	DeleteBuildDataArr = 2518,//删除建筑数据（一组）
	
	// 画线
	PaintEnter = 2627,
	PaintExit = 2628,
	PaintLoading = 2629,
	PaintEdit = 2630,
	PaintPlay = 2631,
	PaintVictory = 2632,
	PaintDefeat = 2633,
	
	// 射击
	ShootEnter = 2700,
	ShootExit = 2701,
	ShootStart = 2702,
	ShootPause = 2703,
	ShootResume = 2704,
	ShootDie = 2705,
	ShootVictory = 2706,
	ShootCollectTreasure = 2707,
	ShootVictoryCollectEnough = 2708,

    QualityChange = 2644,//品质调整
    
    Btn_LongPress = 5001, //Btn长按抬起事件
    
    SDK_PermissionRecv = 6046, // SDK返回Permission
	SU_TimeOfDayChange = 6060, //天气时间改变
	HideZendeskWindow = 9001,
}





