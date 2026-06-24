
---@class EventId
local EventId = {
	None = 0,
	ResourceUpdated = 1,
	OpenUIFormSuccess = 2,
	OpenUIFormFail = 3,
	CloseUIForm = 4,
	ElectricityLack = 5,
	PlayerInfoUpdated = 6,
	UpdateFiveStarReward = 7,
	UpdateBankruptcy = 8,
	DoneBankruptcy = 9,
	PlayerPowerInfoUpdated = 10,
	ServerError = 11,
	BuildPlace = 12,
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
	HospitalEffectEnd = 33,
	ModeReward = 34,
	RepairNeedMessage = 35,
	ArmyFormationSave = 36,
	ChapterTask = 37,
	QuestNoteBookRedCount = 38,
	LineSpine = 39,
	ActiveGuide = 40,
	BuyAndUseItemSuccess = 41,
	forgingSuccess = 42,
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
	AllianceMemberRedPoint = 57,
	AllianceInfoRefresh = 58,
	AllianceApplySuccess = 59,
	AllianceCreateSuccess = 60,
	AllianceApplyCancel = 61,
	AllianceTechnology = 62,
	AllianceScienceDonate = 63,
	KickOutAllianceMember = 64,
	AllianceSettingUpdate = 65,
	AllianceAcceptInvite = 66,
	AllianceEvent = 67,
	AllianceWarUpdate = 68,
	ShowTruckIcon = 69,
	ShowMainUIPart = 70,
	RefreshPieceInterface = 71,
	CloseActiveSkillUseUI = 72,
	CloseGarrisonTip = 73,
	OpenInvestmentPanel = 74,
	MarchTimeSync = 75,
	ActiveSkillNode = 76,
	RefreshSkillUseUI = 77,
	RefreshActiveSkillUseUI = 78,
	PlayFragBuySuccessAnim = 79,
	PlayShopBuySuccessAnim = 80,
	ShopBuyAnimEnd = 81,
	MoveUpFragShopPanel = 82,
	ZombieUnLockAddTransporter = 83,
	NewUserAreaUnLock = 84,
	UserAreaUnLock = 85,
	CenterDailyReward = 86,
	CenterDailyRewardRedDot = 87,
	CargoReward = 88,
	CloseAlliancePanel = 89,
	MoveWorldCity = 90,
	WorldScoutDetail = 91,
	WorldPointDetail = 92,
	WorldOccupiedTroops = 93,
	WorldCollectPointDetail = 94,
	WorldOccupiedKick = 95,
	WorldMarchGetDetail = 96,
	RefreshBookmark = 97,
	ChangeBookmarkItemState = 98,
	GuidePreloadFinish = 99,
	RequestWorldMarchDetail = 100,
	ArmyUpgrade = 101,
	ArmyUpgradeStart = 102,
	ArmyFormatUpdate = 103,
	GetAllianceWarArrayEvent = 104,
	GetAllianceWarAtkInfoEvent = 105,
	GetAllianceWarDefInfoEvent = 106,
	AllianceWarCancelEvent = 107,
	AllianceWarIgnore = 108,
	AllianceWarLogEvent = 109,
	RefreshAllianceGift = 110,
	UpdateAllianceGiftNum = 111,
	UpdateAllianceHelpNum = 112,
	RetGetRewardEvent = 113,
	AllianceGiftShowChangeAni = 114,
	RetGiftInfoEvent = 115,
	TerritoryUpdateInfo = 116,
	TerritoryContri = 117,
	TerritoryStateChange = 118,
	ShowUseResTool = 119,
	TerritoryDetail = 120,
	OccupiedMarchKick = 121,
	AlliancebuildEditor = 122,
	ChangeTerritoryInfo = 123,
	GetAllianceComments = 124,
	AllianceSendComment = 125,
	TalentPointChange = 126,
	MsgDesertSkillUseRefresh = 127,
	EndStudyTalent = 128,
	HidePutWorldBuildUI = 129,
	RefreshUpdateStone = 130,
	DomainDefenceValue = 131,
	UpdateCrossServerPermission = 132,
	DomainFightRewardInfo = 133,
	DomainBuildInfo = 134,
	WBProductNeedTime = 135,
	FactorySelectEvent = 136,
	WorldBuildInfoUpdate = 137,
	WorldBuildRepair = 138,
	WorldBuildFinishRepair = 139,
	WorldBuildRepairInfo = 140,
	WorldMarchRepeat = 141,
	EnemyInfoListChange = 142,
	CityDefend = 143,
	CityDefendIndex = 144,
	TroopAssistance = 145,
	UIRefreshAssistanceDetailInfo = 146,
	FightToMonster = 147,
	BuildingAppointhero = 148,
	UpdateMarchEntityInfo = 149,
	UpdateWorldMapInfo = 150,
	UpdateMarchSpeedUp = 151,
	BuyItemSuccess = 152,
	UpdateNewChatInfo = 153,
	FightReport = 154,
	RequestAllianceSoldier = 155,
	GetUserInfo = 156,
	PushWorldMarchInfo = 157,
	PaymentCompleted = 158,
	PaySuccess = 159,
	HeroGrowReward = 160,
	RequestWeekCardData = 161,
	WEEK_REFRESH_VIEW = 162,
	BattleStartOver = 163,
	BattleBeAttackPost = 164,
	BattleAddAttackEffect = 165,
	BattleAddBulletAttackEffect = 166,
	BattleAddMissileAttackEffect = 167,
	BattleAddPoisonEffect = 168,
	BattleUpdateSodierNum = 169,
	BattleAddMaraleEffect = 170,
	BattleWarningTipFinish = 171,
	BattleShackScreen = 172,
	BattleAddSkillState = 173,
	BattleAddSkillEffect = 174,
	BattleAddStateIdEffect = 175,
	BattleShowTroopSkill = 176,
	BattleMoveForward = 177,
	BattleOfficerCellShine = 178,
	BattleOfficerCellCancelShine = 179,
	BattleShowGlow = 180,
	BattleAddPoisonIcon = 181,
	MSG_ADD_STATE = 182,
	MSG_SHOW_AOE_EFFECT = 183,
	MSG_UPDATE_STATE = 184,
	MSG_SHOW_AOE_MASK = 185,
	MSG_SHOW_STATUS_EFFECT = 186,
	MSG_ADD_POISON_ICON = 187,
	AccountBindEvent = 188,
	AccountBindOKEvent = 189,
	AccountChangeEvent = 190,
	AccountChangePwdEvent = 191,
	AccountResendMailEvent = 192,
	AccountChangeMailEvent = 193,
	AccountNewEvent = 194,
	NickNameChackEvent = 195,
	NickNameChangeEvent = 196,
	MoodInfoChangeEvent = 197,
	PinInputReset = 198,
	PinInputClose = 199,
	PinInputNext = 200,
	PinForgetPwd = 201,
	PinInitFinish = 202,
	MSG_INIT_ACTIVITY_EVENT = 203,
	DayChange = 204,
	GetActivityDetail = 205,
	ActivityCellRefresh = 206,
	MsgFreshSingleScoreView = 207,
	MsgFreshSingleScoreRankView = 208,
	RefreshDataSingleScore = 209,
	RefreshRwdData = 210,
	RefreshSingleScoreUI = 211,
	MsgScoreRankHistoryView = 212,
	DesertMummyRankData = 213,
	GetRewardInfo = 214,
	MsgUpdateActivityEvent = 215,
	MsgAllianceMigrationRefreshData = 216,
	MsgAllianceMigrationPopupRefreshData = 217,
	MsgGetAllianceArmsDifficulty = 218,
	MsgUpdateAllianceArmsUI = 219,
	MsgUpdateAllianceArmsRankUI = 220,
	MsgRefreshChampBattleView = 221,
	EliteNewAddbet = 222,
	EliteNewBetInfo = 223,
	EliteNewAllocateUpdate = 224,
	MsgChampBattleAllocateCell = 225,
	MsgKingGiftUserList = 226,
	MsgKingGiftUpdateContact = 227,
	MsgOfficerPosition = 228,
	MsgOfficerCellUpdate = 229,
	MsgUpdateKingdomFlag = 230,
	MsgUpdatePresidentHistory = 231,
	MsgUpdateLaunchBoxHistory = 232,
	DRAW_VIEW_UPDATE = 233,
	DRAW_SELF_VIEW_UPDATE = 234,
	DRAW_RESULT_VIEW_UPDATE = 235,
	DRAW_RESULT_VIEW_UPDATE_1 = 236,
	ZONE_REWARD_RED_POINT = 237,
	DRAW_VS_VIEW_UPDATE = 238,
	ZONE_CONTRIBUTE_RANK_UPDATE = 239,
	CountryTodayViewcheckReward = 240,
	ZONE_INSIDE_RANK_VIEW = 241,
	ACTIVITY_THEME_CHANGE = 242,
	REFRESH_SINGLE_HEAD_VIEW = 243,
	ZONE_OUT_LOOK_REFRESH = 244,
	ZONE_WARMUPTODAT_RANK = 245,
	ZONE_WARMUPACCUMULATE_RANK = 246,
	ZONE_HISTORY_RANK = 247,
	ALLIANCE_ACTIVITY_INFO = 248,
	ALLIANCE_ACTIVITY_REWARD = 249,
	ALLIANCE_REWARD_RANK = 250,
	PERSONAL_REWARD_RANK = 251,
	DRAW_PIRZE_VIEW_UPDATE = 252,
	MSG_FRESH_SINGLE_SCORE_RANK_VIEW = 253,
	ZONE_GET_CHOOSE_REFRESH = 254,
	ZONE_GET_CHOOSEINFO_REFRESH = 255,
	ZONE_ACTIVITY_DETAIL_EXTEND = 256,
	ZONE_VIEW_CHOOSE_STATE = 257,
	ZONE_WARMUP_RANKING_PRIZE_REFRESH = 258,
	MsgKingdomOfficers = 259,
	MsgUpdateCommendationView = 260,
	MsgUpdateGiftSelectMemTop = 261,
	MsgUpdateGiftSelectMems = 262,
	MsgHeroLimitedRecruitBoxInit = 263,
	MsgHeroCardInfoEnd = 264,
	MsgHeroSelectHero = 265,
	UPDATE_CHRISTMAS_TREE = 266,
	INFO_CHANGE_COLORFUL_CHRISTMAS_TREE = 267,
	GET_COLORFUL_CHRISTMAS_TREE = 268,
	INFO_CHANGE_CHRISTMAS_GIFT = 269,
	INFO_CHANGE_CONGRATULATION_CRAD = 270,
	CONGRATULATION_CRAD_REWARD = 271,
	MsgServerListBack = 272,
	MsgRepayInfoInit = 273,
	MsgRepayViewShowDes = 274,
	MonthCardGetReward = 275,
	BuyMonthCardSucess = 276,
	MONTHCARD_REFRESH = 277,
	SelectMonthCardReward = 278,
	CLICK_WELFARE_CELL = 279,
	AccConsumeGetReward = 280,
	RefreshActivityCommonView = 281,
	RefreshActivity7View = 282,
	BattlePassChangeData = 283,
	MonthBattlePassChangeData = 284,
	SeasonBattlePassChangeData = 285,
	AllianceConsumeChangeData = 286,
	AllianceConsumeRankList = 287,
	MSG_HOLIDAY_AWARD_INFO = 288,
	NightChange = 289,
	LightChange = 290,
	SkillUpgradeEnd = 291,
	RefreshUnlockSkillCondition = 292,
	HeroMedalSelectEnd = 293,
	CloseHeroUnlockPanels = 294,
	UpdateHeroMedalPanel = 295,
	MsgHeroesInit = 296,
	MsgHeroesUpdate = 297,
	HeroBeDecomposedEnd = 298,
	HeroLevelUpgrade = 299,
	HeroRecruitRefreashFree = 300,
	HeroRecruitRefreashActivity = 301,
	OpenHeroPage = 302,
	CloseJiBanPanel = 303,
	HeroUnLockSkill = 304,
	MerchantItemRefresh = 305,
	MerchantBuyItemSucess = 306,
	ChipCollectSucces = 307,
	CR_UPDATE_SHOW = 308,
	DesertThroneDataBack = 309,
	CrossThroneDataBack = 310,
	ThroneFightInfoDataBack = 311,
	ThroneUIClose = 312,
	WorldTrebuchetAtt = 313,
	UpdateBuildingProtectTime = 314,
	UpdateBuildingResProtectTime = 315,
	UpdateMarchItem = 316,
	AllianceExchangeOptRefresh = 317,
	AllianceExchangeRefresh = 318,
	AllianceSetRankName = 319,
	AllianceDonateRankDay = 320,
	AllianceDonateRankWeek = 321,
	AllianceDonateRankAll = 322,
	GoldBoxRefresh = 323,
	ChangeWorldScene = 324,
	WorldMapCameraChangeZoom = 325,
	RefreshWorldMapUI = 326,
	PlayerRank = 327,
	AllianceRank = 328,
	ResetPositionCity = 329,
	UpdateClonceData = 330,
	UpdateCloneSoldier = 331,
	UpdateCloneDonate = 332,
	CloneDonateListBack = 333,
	CloseDonatePlayerInfoList = 334,
	SearchUserAlliance = 335,
	BuildLandscapeList = 336,
	BuildLandscapeUnLock = 337,
	BuildLandscapeUnDown = 338,
	MissleCostUpdate = 339,
	TrainMissile = 340,
	BeginTrainMissile = 341,
	MSG_FINISH_TRAINING_MISSILE = 342,
	FINISH_TRAINING_MISSILE = 343,
	MSG_MISSILE_DEFENCE_RECORD = 344,
	OpenMissleFromSilo = 345,
	EquipMaterialSceleted = 346,
	PartsEquipMakeStart = 347,
	BuildPartsEquipMakeStart = 348,
	BuildPartsMaterialMakeStart = 349,
	PartsEquipMakeFinished = 350,
	PartsMaterialMergeSuccess = 351,
	EquipMergeComplete = 352,
	Equip_Harvest = 353,
	Material_Harvest = 354,
	EquipPutOnMsg = 355,
	EquipDeleteMsg = 356,
	EquipTakeOffMsg = 357,
	EquipSplitMsg = 358,
	EquipSuitSkillUpdate = 359,
	DestroyMaterial = 360,
	SpineCarUpdate = 361,
	ActiveBg = 362,
	RefreshTruckInfo = 363,
	MailReceiveServerBack = 364,
	MailSaveBack = 365,
	MailPush = 366,
	GetStatusItemSuccess = 367,
	GetProtectBuffRecordSuccess = 368,
	ClashBattleStateUpdate = 369,
	ClashBattleBuildUpdate = 370,
	ClashInfoUpdate = 371,
	ClashBattleBuildUpdateClose = 372,
	ClashInfoPush = 373,
	MsgRefreshExploitShopView = 374,
	MsgRefreshFragmentShopView = 375,
	MsgRefreshOneFragmentInfo = 376,
	RefreshItems = 377,
	ChangeServer = 378,
	DesertSeasonDataBack = 379,
	FBVipUnlock = 380,
	FBVipSlotValue = 381,
	VipStoreRefrsh = 382,
	VipPrivilegeRefrsh = 383,
	MsgVipstoreUpdateExp = 384,
	UpdateVipUpdateLV = 385,
	MsgBuyConfirmOK = 386,
	ItemBuyConfirm = 387,
	ItemBuyAndUseConfirm = 388,
	ItemUseConfirm = 389,
	RefreshFBPrivelege = 390,
	RefreshFBStore = 391,
	ALContributionDataBack = 392,
	ALSetAvoidTimeBack = 393,
	ALGetAvoidTimeBack = 394,
	MSG_QUEUE_REMOVE = 395,
	MSG_UPDATE_MSG_BALL = 396,
	GetMemberPointBack = 397,
	HerolotterRewarInfo = 398,
	MsgAllianceBattleActInfo = 399,
	MsgFreshDoomsView = 400,
	DeclareWar_RefreshData = 401,
	DeclareWar_DeclareWarRetData = 402,
	DeclareWar_BeginDeclareWar = 403,
	DeclareWar_AlWarResult = 404,
	DeclareWar_History = 405,
	DeclareWar_Search = 406,
	materialCreateEnd = 407,
	TalentViewRefreshInfo = 408,
	MsgDomainGiveUpPointsBack = 409,
	MsgMapUpdate = 410,
	MsgDomainCollectEnd = 411,
	MsgMyDomainDataBack = 412,
	UIDesertTileRedDot = 413,
	MsgDomainMineArmyBack = 414,
	WBCrashStatus = 415,
	FBTileSeasonDeclareHisListViewNewData = 416,
	MsgDeclareWarDetail = 417,
	GetUserDomainWarHistory = 418,
	DesertRewardViewRefresh = 419,
	ALBattleEvent = 420,
	DomainForceRankDataBack = 421,
	RefreashBuildUpGrade = 422,
	PartsMaterialTimeDone = 423,
	MsgMakeProductEnd = 424,
	UnBuildUpgradeFinish = 425,
	MsgStopProductEnd = 426,
	MsgColloectProductEnd = 427,
	RelicBuildRebuildSuccess = 428,
	CountryFlagChanged = 429,
	BuyHeroCard = 430,
	AllianceCombineList = 431,
	alliance_combine_details_refresh = 432,
	MsgArmyUserRefresh = 433,
	ResetTreatNum = 434,
	GoToHealthing = 435,
	MsgQueueRemove = 436,
	MsgQueueAdd = 437,
	ArmyNumChange = 438,
	TreatNumChange = 439,
	MsgTroopsChange = 440,
	RefreshCarRepairInterface = 441,
	MsgSpecialSolderUpdate = 442,
	CollectSoldierAddPower = 443,
	UICommonHelpTipsClose = 444,
	UpdateTradingCenterData = 445,
	UpdateTradingCenterCallPlane = 446,
	GetHeadImgUrl = 447,
	--UpdateHeadImg = 448,
	LoadGiftFinish = 449,
	GiftBoxRefresh = 450,
	SELECT_USER_GIVE = 451,
	SearchUserGiftBox = 452,
	GiftBoxPeopleSelected = 453,
	OnBuildQueueFinish = 454,
	OnScienceQueueFinish = 455,
	OnScienceQueueResearch = 456,
	Update_Alliance_Gift_Num = 457,
	Translate_Normal = 458,
	Translate_Mail = 459,
	UI_RESOURCE_VISIBLE = 460,
	CHANGE_UIRESOURCE_TYPE_PUSH = 461,
	CHANGE_UIRESOURCE_TYPE_POP = 462,
	CHANGE_UIRESOURCE_TYPE_ALLPOP = 463,
	BuildPowerAdd = 464,
	UpdateGold = 465,
	CLOSE_UIPOPGETHERO = 466,
	MSG_WORLD_BUILD_FREE_NUMBER_CHANGE = 467,
	ClickStateIcon = 468,
	BuildChangeState = 469,
	BUILD_PRODUCE_FAST = 470,
	BUILD_PRODUCE_FAST_BACK = 471,
	BUILD_PRODUCE_FAST_END = 472,
	BUILDING_TURBO_MODE_GET = 473,
	BUILDING_TURBO_MODE_USED = 474,
	BUILD_REPAIR = 475,
	ITEM_COMPOSE_SUCCESS = 476,
	MSG_ITME_STATUS_TIME_CHANGE = 477,
	MSG_FRESH_SURVIVAL_VIEW_GET = 478,
	MSG_FRESH_SURVIVAL_VIEW = 479,
	MSG_FRESH_SURVIVAL_VIEW_MARK = 480,
	MSG_RESPONSED3RDPLATFORM = 481,
	MSG_USER_BIND_CANCEL = 482,
	MSG_USER_BIND_OK = 483,
	RES_TOOL_EXCHANGE_MSG = 484,
	RES_SELL_MSG = 485,
	Immediately_Back_Carport = 486,
	City_Truck_Create = 487,
	City_Truck_Hide = 488,
	ZOMBIE_CLICK_REWARD = 489,
	GOLDEXCHANGE_LIST_CHANGE = 490,
	GOLDEXCHANGE_LIST_CHANGE_RAND = 491,
	PAYMENT_COMMAND_RETURN = 492,
	CityBattleZombiePreloadFinish = 493,
	ResetMailState = 494,
	OtherPlayInfo = 495,
	GUIDE_INDEX_CHANGE = 496,
	BREAK_SOFT_GUIDE = 497,
	MergeChatMessage = 498,
	ShowMailChatTips = 499,
	Translate_Dialog = 500,
	GUIDE_GOTO_ATTACK_WORKER = 501,
	SendMailDone = 502,
	MailRemoveInChannel = 503,
	REFRESH_MONSTERACTIVITY = 504,
	REFRESH_BASEBUILD = 505,
	REFRESH_BROKEFENCE = 506,
	ShowDialogOriginallan = 507,
	WarTroppShowExplain = 508,
	LoadCityBuildingFinsh = 509,
	PlayerCareerChanged = 510,
	CareerInfoUpdate = 511,
	UpdateQuickSaveStr = 512,
	RunOutReousrceChipEnergy = 513,
	BackToBaseCar = 514,
	GetReward = 515,
	ClearPolt = 516,
	PLAY_MP4 = 517,
	GetRewardAniPlayEnd = 518,
	CloseUIBuilding = 519,
	PUSH_CLASHEVENT_COMMAND = 520,
	CHAT_TRANSLATE_COMMAND = 521,
	CHAT_BLOCK_COMMAND = 522,
	CHAT_UNBLOCK_COMMAND = 523,
	CHAT_RECIEVE_ROOM_MSG_COMMAND = 524,
	CHAT_UPDATE_ROOM_MSG_COMMAND = 525,
	CHAT_UPDATE_ALLIANCE_ROOM_COMMAND = 526,
	REDPACK_VIEWLOG_COMMAND = 527,
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
	CHAT_ROOM_OPEN_BY_GROUP = 554,
	CHAT_ROOM_OPEN_BY_ID = 555,
	CHAT_SEND_VOICE_MSG = 556,
	CHAT_VOICE_PLAY = 557,
	CHAT_VOICE_QUEUE = 558,
	CHAT_RESEND_ROOM_MSG_COMMAND = 559,
	CHAT_REMOVE_ROOM_MSG_COMMAND = 560,
	CloseUIBookMarkAlliance = 561,
	CloseWorldBuildMoving = 562,
	WORLD_MOVE_UP_EFFECT = 563,
	SCIENCECENTERNEW_CHANGE_INDEX = 564,
	CLOSE_SCIENCE_UPGRADE = 565,
	UpdateWorldMark = 566,
	MSG_DRAWRESULT_BACK = 567,
	MSG_AZ_TERRITORY_DETAIL = 568,
	ALLIANCE_ARMYGROUP_DOMAIN_CHECK = 569,
	CloseOtherTerritoryArmyInfoDetail = 570,
	OnEndGarrisonTroopCallBack = 571,
	UpdateTerritoryCenterBuildInfoPage = 572,
	UpdateLegionSettingPage = 573,
	SendChosenLegionTroopForSetting = 574,
	ARMYGROUP_LEADER_MEMBER_REFREH = 575,
	ARMYGROUP_DISPATCH_VIEW = 576,
	ALLIANCE_ARMYGROUP_SELECT_ARMYID = 577,
	ALLIANCE_ARMYGROUP_SELECT_ARMYID_EMPTY = 578,
	MSG_DOMAINSEASONREWARDCELLITEM = 579,
	UI_DOMAIN_PLAYER_RANK_SELECT = 580,
	UI_DOMAIN_PLAYER_RANK = 581,
	DESERTSENDREWARDLISTMESSAGE = 582,
	DECORATE_DRESSBASECITY_REFRESH = 583,
	DECORATE_INFONODE_REFRESH = 584,
	ScavengePointFinsh = 585,
	UIMissileLaunchItemSelect = 586,
	FbMissileAlliance = 587,
	Combine_Select_Index = 588,
	Close_Item_Combine_Panel = 589,
	Close_UIBuildMenu_Panel = 590,
	CLOSE_LOADEDITORBUILD = 591,
	UPDATE_BUILD_DATA = 592,
	REFRESHTRUCKCOUNT = 593,
	LOAD_COMPLETE = 594,
	COLLECT_OBJECT_SHOW = 595,
	COLLECT_OBJECT_HIDE = 596,
	UIMAIN_BOTTOM_SELECT_BUILD = 597,
	UIMAIN_BOTTOM_SELECT_BUILDTYPE = 598,
	UIMAIN_BOTTOM_SELECT_RESOURCE = 599,
	GOTO_BUILD = 600,
	UIMAIN_BOTTOM_RESET_BUILDTYPE = 601,
	UIMAIN_BOTTOM_RESET_BUILDTYPE_INFO = 602,
	REGET_MAIN_POSITION = 603,
	UPDATE_POINTS_DATA = 604,
	UIMAIN_VISIBLE = 605,
	UIMAIN_BOTTOM_CHANGE_BUILD_TYPE = 606,
	UIMAIN_BOTTOM_CHANGE_BUILD_SELECTS = 607,
	UIMAIN_BOTTOM_CHANGE_BUILD_TYPE_INFO = 608,
	UIMAIN_BOTTOM_CHANGE_BUILD_TYPE_SELECT = 609,
	UIMAIN_BOTTOM_CHANGE_MIDDLE_RESOURCE_STATE = 610,
	WORLD_CAMERA_CHANGE_POINT = 611,
	UIITEM_SELECT = 612,
	CLICK_MAIL_ITEM = 613,
	REFRESH_MAIL_TABLE = 614,
	REFRESH_RESOURCE_BAG = 615,
	CLICK_RESOURCE_ITEM = 616,
	UPDATE_SCIENCE_DATA = 617,
	CLICK_ALLIANCE_ITEM = 618,
	END_SEARCH = 619,
	ALLIANCE_WAR_DELETE = 620,
	CLICK_FORMATION_ITEM = 621,
	BUILD_IN_VIEW = 622,
	BUILD_OUT_VIEW = 623,
	QUEUE_TIME_END = 624,
	AddBuildSpeedSuccess = 625,
	AllianceQueueHelpNew = 626,
	AllianceBuildHelpNew = 627,
	MonsterMoveStart = 628,
	MonsterMoveEnd = 629,
	PUSH_NOTICE = 630,
	CLICK_ALLIANCE_SHOP_ITEM = 631,
	AllianceNameChange = 632,
	AllianceAbbrChange = 633,
	AllianceLanguage = 634,
	UIMAIN_CHANGE_BUILD_ENTER = 635,
	UIMAIN_CHANGE_BUILD_OUT = 636,
	CHAT_LOGIN_SUCCESS = 637,
	CHAT_REFRESH_CHANNEL = 638,
	ROOM_KICK_PLAYER_RESULT = 639,
	UPDATE_MSG_USERINFO = 640,
	CHAT_UPDATE_ROOM_LIST_LASTMSG = 641,
	CHAT_CHANGE_CURRENT_ROOM = 642,
	BuildResourcesStart = 643,
	BuildResourcesSecond = 644,
	RefreshResidentOrder = 649,
	RefreshResourceItem = 650,
	DelayRefreshResource = 651,
	BuildUpgradeAnimationFinish = 652,
	EffectNumChange = 653,
	OnWorldInputDragBegin = 654,
	OnWorldInputDragEnd = 655,
	RefreshUIWorldTileUI = 656,
	ShowCapacity = 658,
	RewardItemAdd = 659,
	FarmDragEnd = 660,
	ChangeCameraLod = 661,
	ShowResourceUpdate = 662,
	ShowCapacitySecond = 663,
	RefreshEarthOrder = 664,
	GetNewEarthOrder = 665,
	EndEarthOrder = 666,
	ViewEndEarthOrder = 667,
	GetFactoryData = 668,
	GatherFactoryItem = 669,
	AddFactoryBox = 670,
	AddFactoryProduct = 671,
	OnMeteoriteHitGlass = 672,
	UIMainWarningShow = 673,
	UIMainWarningHide = 674,
	FoldUpBuilding = 675,
	LOAD_PLAY_VIDEO = 676,	-- video加载完毕
	FarmSecondProduct = 677,
	Guide_video_Play = 678,
	AllianceAnnounce = 679,
	AllianceRestriction = 680,
	GET_INVITE_USERS_SUCCESS = 681,
	GOTO_SCIENCE = 682,
	LF_AccountListView_Close = 683,
	LF_AccountListView_Refresh = 684,
	LF_Account_History = 685,
	MessageBallChange = 686,
	GatherResourceItemFinish = 687,
	SoldResourceItem = 689,
	LUA_BUILD_INIT_END = 690,
	CanGetProduct = 691,
	GetAllProduct = 692,
	RefreshUIBuildQueue = 693,
	RefreshFarmGatherUI = 694,
	HeroAdvanceSuccess = 695,
	HeroLvUpSuccess = 696,
	ShowMainUIExtraResource = 699,
	HideMainUIExtraResource = 700,
	HeroResetSuccess = 704,
	OnCancelHeroSelect = 705,
	AllianceInitOK = 706,
	AllianceQuitOK = 707,
	ReturnTimeFromCurPosToTargetPos = 708,
	Mail_DeleteMailDone = 709,
	Mail_DeleteBatchMailDone = 710,
	Mail_Select_Channel = 711,
	OnSelectHeroSelect = 712,
	UIResourceCostChangeState = 713,
	RecruitCampChange = 714,
	AllianceIntro = 715,
	AllianceMemberNeedHelp = 716,
	COLLECT_OBJECT_SHOWNew = 717,
	COLLECT_OBJECT_HIDENew = 718,
	ChangeNameIcon_Select = 719,
	UpdatePlayerHeadIcon = 720,
	UpdateCollectPos = 721,
	GetAssistanceData = 722,
	FakeBuildingSelectLocation = 723,
	UpdateFakeBuildingPos = 724,
	ShowIsOnFire = 725,
	UpdateRankPreview = 726,
	GetAllDetectInfo = 727,
	UpgradeDetectPower = 728,
	DetectInfoChange = 729,
	HeroMedalExchanged = 730,
	OnClickWorld = 731,
	OnClickMarch = 732,
	CheckDomeOpen = 733,
	CollectAnimEnd = 734,
	MailScoutReposition = 735,
	MailDetailReport_ClickItem = 736,
	RefreshArrow = 737,
	OnGoodsRedState = 738,
	LoginCommandError = 739,
	LoginInitError = 740,
	Net_Connect_Error = 741,
	OnNetDisconnect = 742,
	CloseDisconnectView = 743,
	WorldTroopGameObjectCreateFinish = 744,
	CheckShowMainBuildLabel = 745,
	ShowTroopHeadNotBattle = 746,
	ShowTroopHeadInBattle = 747,
	ShowTroopBattleValue = 748,
	HideTroopHead = 749,
	DetectEventRewardGet = 750,
	Event_ShowBattleReportDetail = 751,
	BundleDownloadProgress = 752,
	RefreshDataPersonalArms = 753,
	CheckPubBubble = 754,
	AlGiftHideNameStateUpdate = 755,
	RefreshTopResByPickUp = 756,
	DailyQuestReward = 757,
	OnAdvanceSuccessClosed = 758,
	ShowTroopName = 760,
	HideTroopName = 761,
	CheckTroopStateIcon = 762,
	UpdateCityPoint = 763,
	Queue_Add = 764,
	OpenUI = 767,
	RefreshGuide = 768,
	QuestRewardSuccess = 769,
	Build_Time_End = 770,
	Nofity_Alliance_Battle_Week_Rusult_VS = 771,
	AllianceCompeteRankListUpdated = 772,
	AllianceCompeteRewardsReposition = 773,
	AllianceCompeteWeeklySummaryUpdated = 774,
	AllianceArms_OpenBox = 775,
	RefreshAllianceArmsUI = 776,
	StopSvAutoToCell = 777,
	PlayGetReward = 778,
	CreatedResidentOrder = 779,
	CameraFollowCityTroop = 780,
	OnWorldInputPointDown = 781,
	TroopRotation = 782,
	SevenDayGetReward = 783,
	SkipFactoryAni = 784,
	ShowDomeHideEffect = 785,
	ShowDomeShowEffect = 786,
	OpenFogSuccess = 787,
	OnTaskForceRefreshFinish = 788,
	OnSpecialTaskUpdate = 789,
	AttackExploreStart = 790,--攻击探索事件点开始
	AttackExploreEnd = 791,--攻击探索事件点结束
	WorldMarchDelete = 792,
	GuideTimelineMarker = 793,
	ContentLayoutReposition = 794,
	ShowExploreHeadInBattle = 795,
	ShowExploreBattleValue = 796,
	HideExploreHead = 797,
	CityFightResult = 798,
	CreateFormationUuid = 799,
	RefreshCityTroopPeopleNum = 800,
	BuildMainZeroUpgradeSuccess = 801,
	FirstPayStatusChange = 802,
	FarmGuideFakePlant = 803,
	GetSingleGarbageInfoSuccess = 804,
	FarmGuideFakePlantShowState = 805,
	ChapterTaskGetReward = 806,
	GarbageCollectStart = 807, --捡垃圾小人跑到位置
	SingleGarbageCollectStart = 808, --主城捡垃圾小人跑到位置
	GuideMoveArrowPlayAnim = 809, --引导移动的手指播放按下/抬起动画
	WorldArmyCollectAnimEnd = 810,
	ShowLoadEditorBuild = 811,
	VipDataRefresh = 812,
	VipRefreshFree = 813,
	VipRefreshPayGift = 814,
	ShowPower = 815,
	DailyQuestLs = 816,
	ShowAllGuideObject = 817,
	UnlockFogAnim = 818,--做解锁迷雾动画
	ReadOneMailRespond = 819,
	CloseUI = 821,--关闭UI
	UpdateGiftPackData = 822, --礼包数据更新
	ToggleRecruitScene = 823,
	BeginDownloadUpdate = 824,
	EndDownloadUpdate = 825,
	NetworkRetry = 826,
	ResourceFull = 827,
	UINoInput = 828,--禁止UI点击
	UIMainShowMailTips = 829, --显示主界面邮件提示
	AllianceWarNewStatusChanged = 830,
	ShowHeroIconByUseSkill=831,
	RefreshGuideAnim = 832,
	BuildRedDotRecord = 833,--建筑列表红点消失后的事件
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
	OnAnyViewClosed = 850,
	OnPackageInfoUpdated = 851,
	WorldAllianceCityDetail = 852,
	UIPlaceBuildChangePos = 853,
	FormationInfoUpdate = 854,
	UICreateFakePlaceBuild = 855,--假建筑创建成功
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
	WorldCityOwnerInfoReceived = 866,  --联盟所属信息初始化
	WorldCityOwnerInfoChanged = 867,   --联盟所属信息变更
	RefreshUIWorldPointView = 868,
	OnWorldInputPointClick = 869,--在世界上点击
	OnWorldInputPointDrag = 870,--在世界上拖拽移动一个点
	OnWorldInputPointUp = 871,--在世界上点击抬起
	RefreshTopResSuc = 872,
	AlLeaderElectStatusChange = 873,
	AlLeaderVoteStatusChange = 874,
	AlSysStateChange = 875,
	AlLeaderCandidateUpdate = 876,
	UserResSynNew = 878, --收资源
	RefreshUIGuideHeadTalk = 879, --刷新头像对话
	AllianceOrderUpdateStage = 880,
	UnlockBuilding = 881,
	RefreshMonsterRewardBag = 882,
	MarchEndWithReward = 883,--战斗胜利，捡垃圾，采集获得奖励
	MarchFail = 884,--战斗失败
	ShowTroopAction = 885,--
	HideTroopAction = 886,--
	ShowCityTroopObject = 887,
	RefreshActivityRedDot = 888,
	ShowUnlockBtn = 889,--显示解锁按钮
	UpdateDayActInfo = 890,
	HideMarchTip = 891,
	MonthCardInfoUpdated = 892,
	ShowGolloesMonthCardRewards = 893,
	GolloesNumChange = 894,--Obsolete
	GolloesFreeSpeedTimeChange = 895,--Obsolete
	GolloesExplorerRewardStateChange = 896,--Obsolete
	GolloesTraderRewardStateChange = 897,--Obsolete
	GolloesDataChange = 898,
	ScrollViewContentChange = 899,
	AllianceCityInView = 903,
	AllianceCityOutView = 904,
	UI_SHOWNOTICE = 905,--跑马灯
	RefreshAlertUI = 906,
	BuildLevelUp = 907,--建筑升级（包括建造）
	BuildMove = 908,--建筑移动（包括建造）
	GoTroopListShow = 909,
	UpdatePlayerExp = 910,
	ReceiveLevelReward = 911,
	PasturePanelStateChange = 912,
	CloseGuideMoveArrow = 913,--关闭移动指示手的界面
	RefreshRecommendShow = 914,--刷新
	UpdateMyAlCities = 915,
	MyAlCityListChanged = 916,
	UIPlaceBuildSendMessageBack = 917,--假数据刷新
	AllianceBaseDataUpdated = 918,
	GotoTime = 919,--跳转到timeline时间点
	CheckAccountPwdSuccess = 920,--验证密码正确
	AccountCheckSuccess = 922,--账号验证通过邮件发送
	RefreshDataAllianceArms = 923,--联盟军备活动数据
	ShowBattleRedName = 924,--战斗中以自己为目标的行军名字为红色
	HideSkillHeadEffect = 925,
	ShowPickGarbageResource = 926,
	--新增行军
	MarchAdd = 927,
	--删除行军
	MarchDelete = 928,
	ReInitLoadingLuaState = 929,
	IgnoreAllianceMarch = 930,
	IgnoreTargetForMineMarch = 931,
	MarchItemTargetMeUpdate = 932,--更新行军目标为自己
	ArrowShow = 933,--有箭头出现
	CloseChatView = 934,
	MarchItemUpdateSelf = 935,--自己的行军发生变化
	ShowTroopAtkBuildIcon = 936,
	HideTroopAtkBuildIcon = 937,
	ChapterTaskOrWarningBall = 938,--主界面消息球或任务箭头
	ShowFormationSelect = 939,
	HideFormationSelect = 940,
	--英雄驻扎
	HeroStationSave = 941,
	HeroStationUpdate = 942,
	HeroStationUseSkill = 943,

	FactoryTransportAnimationEnd = 945,
	OnUnlockViewClose = 946, -- 解锁弹窗关闭时
	RefreshGarbageTask = 947,--捡垃圾任务刷新
	-- 登陆状态
	LoadingState = 948,
	ShowArrowPlayerBtn = 949,--绑定账号指向头像
	OnGetNewAlJoinReq = 950,--收到加入联盟请求
	StorageShopGetShopList = 951,--交易站获取简报返回
	StorageShopUnlockSlotSucc = 952,--解锁栏位成功
	StorageShopAddGoods = 953,--上架商品
	StorageShopRemoveGoods = 954,--下架商品
	StorageShopGetOtherShopInfo = 955,--获取他人交易站信息
	StorageShopClaimMoneyBack = 956,--收取金币
	StorageShopBuyGoodsSucc = 957,--购买成功

	WORLD_BUILD_IN_VIEW = 958,--其他人建筑进入视野
	WORLD_BUILD_OUT_VIEW = 959,--其他人建筑离开视野

	StorageShopDataChange = 960,--数据变化刷新气泡
	StorageShopShowBuySuccEff = 961,--购买成功显示飘飞动画
	StorageShopBubbleStatusChange = 962,--农场气泡
	StorageShopSoldSucc = 963,--交易站成功售出

	CreateAccountMailFail = 964,--绑定邮箱发送失败
	Animal_Select = 965,--选中动物
	Animal_Unselect = 966,--取消选中
	AllianceCityNameCheck = 967,
	AllianceCityNameChange = 968,
	CheckFiveStar = 969,
	OnClaimRewardEffFinish = 970,--播完领奖动画后刷新
	MonsterRewardCreate = 971,

	RadarRallyGetBossCount = 972,--雷达集结获取打怪数据

	HeroRankUpSuccess = 973, --英雄军阶升级成功
	ToggleHeroPreviewScene = 974,

	IndividualOrderGetInfo = 975,
	IndividualOrderFill = 976,
	IndividualOrderGetReward = 977,
	StorageShopShopEmpty = 978,
	PlayerChangeHeadRedPot = 979,


	BarterShopExchangeSucc = 980,

	NoticeMainViewUpdateMarch = 981,
	GrowthPlanGetInfo = 982, --成长计划获取信息
	GrowthPlanGetReward = 983, --成长计划领取奖励

	ChangeShowTranslatedStatus = 984,
	BuildFixStart = 985, --废墟修复开始
	BuildFixFinish = 986,--废墟修复结束
	AddBuildFixSpeedSuccess = 987,--废墟加速修改
	Build_Fix_Time_End = 988,--废墟时间结束
	AllianceBuildFixHelpNew = 989,--废墟联盟帮助成功
	RefreshWelfareRedDot = 990,

	FactoryDataAddSpeed = 991,

	ChampionBattleReceiveBoxBack = 992,
	ChampionBattleBetViewBack = 993,
	ChampionBattleFormationSaved = 994,
	ChampionBattleSingUpBack = 995,
	UpdateTask = 996,
	OnUpdateTeamDataEvent = 997,
	ChampionBattleRewardPreviewBack = 998,
	ChampionBattleEntranceNotice = 999,
	ChampionBattleDataRefresh = 1000,
	UpdateKonbini = 1001, -- 小卖部更新
	ShowBuildAttackHeadUI = 1002,
	HideBuildAttackHeadUI = 1003,
	AlWaitMergeStatusChange = 1004,
	AlInviteRecommendUserSucc = 1005,

	GetRedPacketUpdate = 1006,--领取到红包更新
	GetNewUserInfoSucc = 1007,--获取玩家信息

	GarageRefitUpdate = 1008, -- 车库改装
	GetPlayerPoliceStationData = 1009,--刷新玩家警察局数据
	QueueHeroFreeTime = 1010, --英雄加速
	QueueHeroFreeTime_ForGirlCollect = 1011,--宝箱拾取加速
	UploadHead_Start = 1013, --头像开始上传
	UploadHead_End = 1014, --头像上传成功/失败
	AllianceLogUpdate = 1015, --联盟日志更新
	WorldTrendUpdate = 1016,--天下大势更新
	WorldTrendRedUpdate = 1017,--天下大势红点更新
	AllianceOrderAddToken = 1018,
	OnUpdateAlLeaderCandidates = 1019,--盟主选举候选人信息更新
	UpdateAlElectRed = 1020,--更新联盟主界面各功能入口
	OnUpdateActivityEventData = 1021,--更新活动event数据
	UpdateAlertData = 1022,

	PlayerCareerSelect = 1023, -- 玩家职业选择
	PlayerCareerLevelUp = 1024, -- 玩家职业升级
	MainLvUp = 1025, -- 大本升级
	ClickMainAccountBind = 1026,--点击了主界面账号绑定

	UpdateAlCanBeLeader = 1027,--是否可选成为盟主
	OnGetRecommendAlPoint = 1028,--获得推荐联盟迁城点

	OnUpdateAllianceTask = 1029,
	OnAllianceTaskRedChange = 1030,
	PlayerCareerFreeChangeUpdate = 1031,
	OnRewardGetPanelClose = 1032,
	OnKickAllianceMember = 1033,
	UpdateChatQuestRed = 1034,
	OnRecvAllianceStorageInfo = 1035,--获取联盟仓库信息

	AllianceLookForCareers = 1035,

	OnClickPlaceBuild = 1036,
	OnClickMsgNew = 1037,
	RefreshFarmIrrigateUI = 1038,
	ClickFarmBuildHideOnly = 1039,
	UpdateTraderExtraRewardTimes = 1040,

	-- 解锁地块
	LandUnlock = 1041,
	LandLockInit = 1042,

	PointToAllianceMoveBtn = 1043,
	NoRefresh = 1044,--不用刷新，防止气泡刷新两次出现闪一下的问题

	CareerSkillUpdate = 1045, -- 职业技能数据更新
	CareerSkillTimeUpdate = 1046, -- 职业技能使用时间结束

	CreatWormholeBuild = 1047,

	PveLevelEnter = 1048,
	PveLevelExit = 1049,
	ShowAllianceMemberRanks = 1050,
	ShowBattleBuff = 1051,
	HideBattleBuff = 1052,
	ShowWorldZoneChangeColor = 1053,
	SetMovingUI = 1054,

	ChangeShowFarmState = 1055,--1显示，0不显示
	ChangeShowAnimalState = 1056,--1显示，0不显示

	SetGoldStoreBtnVisible = 1057,

	CacheGoldStoreOpenType = 1058,
	RefreshGoldStoreRed = 1059,
	SetCityLabelShow = 1060,
	RefreshStorageShopHistory = 1061, --刷新交易行历史记录
	OnActBossDataRefresh = 1062,--活动boss数据刷新
	OnActBossRankRefresh = 1063,--活动boss排行榜刷新
	ShowActBossBattleValue= 1064,
	ShowActBossOpen = 1065,
	ShowActBossClose = 1066,
	ShowBuildDetail = 1067,
	HideBuildDetail = 1068,
	UpdateMainBubblePosByTempSkin = 1069,
	RefreshExpFromMessage = 1070,
	AddExpFromScene = 1071,

	LandLockInView = 1072,
	LandLockOutView = 1073,
	LandLockStateUpdate = 1074,

	DestroyLandLockBubbleStateHide = 1075,
	AllianceInviteStatusChange = 1076,
	PVEHeroExpFly = 1077,
	AllianceLookForCareers = 1078,
	WorldTrendRefresh = 1079,
	MainPosChanged = 1080,
	
	PveFinishOneTrigger = 1081,--pve完成一个触发点

	AllianceFlagChanged = 1082,
	PVEBattleSetLeftBuffData = 1083,
	PVEBattleSetRightBuffData = 1084,
	PVEBattleShowLeftBuff = 1085,
	PVEBattleShowRightBuff = 1086,
	AllianceCityLogUpdate = 1087, --联盟城日志更新
	WorldZoneChangeColorFinish = 1088,
	UpdateMineCaveInfo = 1089,

	OnRecvMineCavePlunderLog = 1090,
	PveMineCaveInfoUpdate = 1091,

	ResetQuestArrow = 1092,
	FormationStaminaUpdate = 1093,
	UserGoldCoverStamina = 1094,
	UserItemCoverStamina = 1095,

	RefreshResLackList = 1096,
	RefreshHeroEffectSkill = 1097,
	ShowMarchTrans= 1098,
	HideMarchTrans= 1099,
	RefreshNpcTalkBubbleActive = 1100,
	RefreshHeroEntrust = 1101,--刷新英雄委托数据
	AttackSpecialStateFlag = 1102,--出征特殊状态

	BuyKonbiniRefresh = 1103,

	DesertForceRank = 1104,

	SelectBatchMail = 1105,
	SelectBatchAll = 1106,
	SelectCancelOne = 1107,
	RePlyChat = 1108,
	WorldTrendRefreshRank = 1109,
	
	SelectAllianceChannel = 1110, -- 选择联盟频道

	GuideInitFinish = 1113,

	QuestionnaireRefresh = 1114,

	RolesRefresh = 1115,
	ServerListRefresh = 1116,

	OnHeroBountyTaskRefresh = 1117,
	OnHeroBountyOneTaskRefresh = 1118,
	OnSelectHeroSelectForBounty = 1119,
	OnCancelHeroSelectForBounty = 1120,
	OnSelectAccountServer = 1121,

	RefreshHeroBountyBubble = 1122,

	SetHeroOfficial = 1123,
	ShowWorldMarchByType= 1124,--显示行军模型
	HideWorldMarchByType= 1125,--隐藏行军模型
	SetCityPeopleAndCarVisible = 1126,--显示主城内人和车
	ChapterAnimHide = 1127,

	BuyItemAndRes = 1128,

	OnGetServerDataRefresh = 1129,

	-- Level Explore
	LevelExploreGetInfo = 1130,
	LevelExploreGetDetail = 1131,
	LevelExploreSweep = 1132,

	OnEnterCrossServer= 1133,
	OnQuitCrossServer = 1134,

	PveStaminaUpdate = 1135,--刷新pve体力

	PveTaskGetReward = 1136,

	OnKeyCodeEscape = 1138,

	ClickAny = 1139,
	SetPveSkillVisible = 1140,--设置旋风斩按钮显示/隐藏
	RefreshUIPveMainVisible = 1141,--设置pve主界面显示/隐藏
	IDCardCheckSuccess =1142,
	IDCardCheckFail  =1143,
	FoldCrossWormHoleTimeUpdate = 1144,
	ShowCreateCrossWormHole = 1145,
	SetPveBuyBuffSShopEffectVisible = 1146,--设置pve购买Buff商店黑色遮罩显示/隐藏
	FreeWeeklyPackage = 1147,
	PveActScoreUpdate = 1148,
	PveActRankUpdate = 1149,
	PveActGetInfo = 1150,
	PveActTaskReward = 1151,
	PveActStageReward = 1152,
	PveActTaskUpdate = 1153,
	PveActGetRank = 1154,
	SetPveStopRefreshStamina = 1155,--设置pve停止刷新体力
	SetPveNoClickStamina = 1156,--设置pve不能点体力
	RefreshUIHeadTalk = 1157,--刷新头像对话
	CloseUIGuideHeadTalk = 1158,--关闭头像对话
	PingTest = 1159,--ping 测试
	SetPveBagGuide = 1160,--设置pve背包引导
	CrossServerAlliancePoint = 1161,--跨服推荐点
	WorldCollectPointInView = 1162,--采集点进入视野
	WorldCollectPointOutView = 1163,--采集点离开视野
	OnGetBlockList = 1164,
	SetPveResetPositionVisible = 1165,--pve重置位置按钮，显示/消失
	HeroAdvanceGuide = 1166,--英雄进阶引导
	ShowCrossEffect = 1167,
	
	LandLockCreate = 1168,--世界上地块创建
	LandLockDestroy = 1169,--世界上地块删除

	ActMonTowerGetInfo = 1170,
	ActMonTowerChoiceDiff = 1171,
	ActMonTowerCallBoss = 1172,
	ActMonTowerGetRank = 1173,
	ActMonTowerGetReward = 1174,
	ActMonTowerGetTask = 1175,
	ActMonTowerCallHelp = 1176,
	ActMonTowerBossKilled = 1177,
	GuidControlQuest = 1178,
	RefreshBuildUpgradeStock = 1179,--刷新建筑交材料数据
	OnEnterWorld = 1180,
	OnEnterCity = 1181,
	PveDropRewardAdd = 1182,--增加一个pve掉落奖励
	PveDropRewardRemove = 1183,--减少一个pve掉落奖励
	PveBattleBuffRefresh = 1185,

	GetNoticeList = 1188,
	RefreshNotice = 1189,
	NoticeItemClick = 1190,
	NoticeItemReward = 1191,
	ChapterArrow = 1192,

	ShowMiniMap = 1193,
	HideMiniMap = 1194,
	MiniMapDataRefresh =1195,
	ShowArrowSearchBtn = 1196,
	BattleMessageParsed =1197, -- 战斗消息解析完成

	RefreshTaskCell = 1198,
	RefreshMainTask = 1199,

	GetSeasonRewardData = 1200,
	GetSeasonAllianceSendMemberList = 1201,

	RefreshTopResItemByPickUp = 1202,

	UserLostDesert = 1203,
	UserGetDesert = 1204,
	UserDismissDesert = 1205,
	UserCancelDismissDesert =1206,
	UserDesertResCollect = 1207,
	UICreateFakePlaceAllianceBuild = 1208,--假建筑创建成功
	UIPlaceAllianceBuildChangePos = 1209,
	InitSelfDesert = 1210,
	CheckAttackBoss = 1211,

	PveGetFakeItem = 1212,

	OnActBossDataRefresh = 1213,--活动boss数据刷新
	OnActBossRankRefresh = 1214,--活动boss排行榜刷新
	SetUIVisible = 1215,--引导设置UI隐藏
	HideDesertAttackHeadUI = 1216,
	RefreshStorageShopHistory = 1217, --刷新交易行历史记录
	FoldUpSeasonBuild = 1218,--收起赛季建筑
	ActGiftBoxGetInfo = 1219,
	ActGiftBoxOpen = 1220,
	UpdateGold = 1221,
	ActGiftBoxLottery = 1222,
	ActGiftBoxLotteryCount = 1223,

	ChangeShowTroopAttackEffectState = 1224,
	ChangeShowTroopBloodNumState = 1225,
	ChangeShowTroopDestroyIconState = 1226,
	ChangeShowTroopHeadState = 1227,
	ChangeShowTroopNameState = 1228,
	ChangeSex = 1229,--改变性别
	UserGetDesertAdd = 1230,
	DesertForceRefresh = 1231,
	RefreshUINoticeEquipTips = 1232,--刷新个人军备活动展示tips

	OnBeforeEnterWorld = 1233,
	OnBeforeEnterCity = 1234,
	RefreshDeadArmyRecord = 1235,--士兵死亡记录刷新
	RefreshDeadArmyRecordRedDot = 1236,--士兵死亡记录红点刷新
	GatherSeasonResTimeChange = 1237,
	ForceSelfRank = 1238,
	CheckGatherSeasonResRedDot = 1239,
	AllianceForceRankUpdate = 1240,
	RefreshGuideDetectEvent = 1241,
	WorldBuildQueueHeroFreeTime = 1242, --世界建筑英雄加速
	ResetUIBuildClickState = 1243, --建筑升级/交资源出错，重置升级页面连续点击状态

	AllianceFlagUpdate = 1244,--联盟旗帜变化
	ShowCreateAllianceFlag = 1245,
	ShowAllianceBuildAttackHeadUI =1246,
	HideAllianceBuildAttackHeadUI =1247,
	ChangeShowTroopGunAttackEffectState = 1248,
	ChangeShowTroopDamageAttackEffectState = 1249,
	GuideChangeFreeSpeedBtn = 1250,--引导改变加速按钮为免费
	ShowNPCBuildAttackHeadUI =1251,
	HideNPCBuildAttackHeadUI =1252,
	ChangeCameraInitZoom =1253,
	ChatDBInitFinish = 1254,
	FinishGuideDetectEvent = 1255,--完成引导假世界怪事件

	RefreshDailyCumulative = 1256,
	AllianceCenterUpdate = 1257,--联盟中心数据变化
	OnUpdateOneAllianceCenter = 1258,--联盟中心数据变化
	OnDeleteOneAllianceCenter = 1259,

	AllianceFrontUpdate = 1260,--联盟前线数据变化
	OnUpdateOneAllianceFront = 1261,--联盟前线数据变化
	OnDeleteOneAllianceFront = 1262,
	OnPveHeroCancel = 1263,
	--五星吐槽发送完毕
	FiveStarFeedbackComplete = 1264,

	BlackKnightUpdate = 1265,--黑骑士数据变化
	BlackKnightRank = 1266,--黑骑士排行榜变化
	BlackKnightWarning = 1267,--黑骑士警告变化
	AttackInfoForMinimap = 1268,
	AttackerInfoUpdate = 1269,--仇人数据发生变化
	DesertEffectInView = 1270,
	DesertEffectOutView =1271,
	MailGetMore =1272,--邮件显示更多
	MailBatchDelete = 1273,
	
	-- 联盟捐兵相关开始
	GetDonateArmyActivityInfo = 1274, -- 获取捐兵活动信息
	GetDonateArmyScoreInfo = 1275, -- 获取对决双方联盟成员积分信息
	ReceiveDonateArmyTaskReward = 1276, -- 领取捐兵活动任务奖励
	DonateSoldier = 1277, --捐兵
	ReceiveDonateArmyStageReward = 1278, --领取捐兵贡献奖励
	PushDonateArmyTaskUpdate = 1279, --捐兵任务数据推送
	PushArmyInfoEvent = 1280,
	UIDonateSoldierInfoDataUpdate = 1281,
	UIDonateSoldierRankDataUpdate = 1282,
	-- 联盟捐兵相关结束

	ActMainRefreshRed = 1283,
	OnCheckNewDecorate = 1284, 
	
	ActDesertForceGroupRank = 1285,
	ChangeShowTranslatedNotice = 1288,--公告翻译

	RefreshFormationHeroItem = 1289,
	
	GovernmentPresentRefresh = 1300,--王座刷新礼物
	GovernmentPresidentRefresh = 1301,--王座国王刷新
	GovernmentPresentRecordRefresh = 1302,--王座刷新发奖记录
	GovernmentHistoryRecordRefresh = 1303,--王座刷新国王历史记录
	CheckShowGovPos = 1304, --官职标志刷新
	ShowThroneArmyHeadUI = 1305, --王座血量变化
	HideThroneArmyHeadUI = 1306, --
	CancelAllianceTeam = 1307,
	ActGiftBoxRankUpdate = 1308,

	DesertMineInView = 1309,
	DesertMineOutView = 1310,

	-- 刷新英雄勋章商店数据
	UpdateHeroMedalShop = 1311,
	-- 英雄勋章商店每日奖励同步
	UpdateHeroMedalShopDailyReward = 1312,
	-- 英雄勋章商店道具同步
	UpdateHeroMedalShopItem = 1313,

	ShowSiegeAttack = 1314,
	HideSiegeAttack = 1315,
	SetScreenResolution = 1316,
	SetGuideMoveArrowShow= 1318,--引导移动手指显示
	SetGuideMoveArrowHide= 1319,--引导移动手指隐藏

	-- 新联盟捐兵开始
	GetALVSDonateArmyActivityInfo = 1320,
	ReceiveALVSDonateArmyTaskReward = 1321,
	ALVSDonateSoldier = 1322,
	ReceiveALVSDonateArmyStageReward = 1323,
	PushALVSDonateArmyTaskUpdate = 1324,

	ALVSDeclareAllianceListReturn = 1325, --匹配联盟列表返回 刷新匹配联盟界面
	ALVSRandomMatchReturn = 1326, -- 随机匹配对手信息返回 刷新匹配对手界面
	PushALVSMatchSuccessReturn = 1327, --匹配到对手的推送 -- 收到后如果在界面里则发送 get.donate.army.activity.info.v2
	PushALVSDonateArmyBattleStartReturn = 1328, -- 盟主开启迎战后推送 --收到后如果在界面里发送 get.donate.army.battle.info 
	ALVSDonateArmyBattleInfoReturn = 1329, -- 获取对决信息返回
	PushDonateArmyDefenceResult = 1330, -- 新捐兵战斗联盟中心状态变化

	-- 新联盟捐兵结束
	
	GetMigrateList = 1331,
	GetMigrateServerDetail = 1332,
	GetMigrateApplyList = 1333,
	OnMigrateApplyToPresident = 1334,
	OnMigrateApprove = 1335,
	OnRefreshMigrateRedPot = 1336,
	OnGetMigratePoint = 1337,
	
	OnSetMigratingUI = 1338,
	CLICK_MIGRATE_SERVER_ITEM = 1339,

	PushPirateSiegeBattleStartEvent = 1340,

	GetAllianceBossActivityInfo = 1341, -- 获取 联盟boss数据的请求 返回
	AllianceBossDonate = 1342, -- 捐献 联盟boss的请求 返回
	CallAllianceBoss = 1343, -- 召唤联盟boss的请求 返回
	PushAllianceBossCreate = 1344, -- 收到联盟盟主召唤boss的推送
	PushAllianceBossDamageUpdate = 1345, -- 收到对联盟boss造成伤害变化推送
	ReceiveAllianceBossFreeReward = 1346, -- 领取联盟boss免费奖励请求 返回
	GetAllianceBossDonateRank = 1347, -- 获取联盟boss捐献排行榜
	GetAllianceBossDamageRank = 1348, -- 获取联盟boss伤害排行榜

	ShowAllianceBossRewardBoxByPosAndItemid = 1349, -- 获取联盟boss伤害排行榜
	RefreshPrologueBridgeBubble = 1350,--刷新序章造桥气泡

	ShowFormationBlood = 1351,--刷新行军血量
	ShowAllianceBossBattleValue = 1352,
	FoldSubWormHoleTimeUpdate = 1353,
	ControlTimelinePause = 1354,--控制timeline暂停/恢复
	
	OtherServerAlliancePowerRank = 1355,--其他服联盟战力排行榜

	PlayCloseUIAnim = 1357, --播放UI关闭动画
	AllianceActMineUpdate = 1360,
	AllianceActMemberUpdate = 1361,
	AllianceActMineResUpdate = 1362,
	ShowBattleDamageType = 1363,
	OnEnterDragonUI = 1364,
	OnQuitDragonUI = 1365,

	ShowDragonBuildAttackHeadUI =1366,
	HideDragonBuildAttackHeadUI = 1367,

	DragonMapDataRefresh = 1368,
	DragonBuildInView = 1369,
	DragonBuildOutView = 1370,
	ArenaCampEffectUpdate = 1371,
	GetDagonPlayerList = 1372,
	DragonScoreRefresh = 1373,
	RefreshTimelineJump = 1374,--刷新引导timeline跳过参数
	
	RefreshAlarm = 1403,--个人警报
	
	RefreshMigrateInfo = 1404,

	StoreEvaluateInfo = 1405,
	StoreEvaluateReward = 1406,

	DragonRewardInfo = 1410, --巨龙活动奖励信息
	RefreshHeroPlugin = 1420,--刷新英雄插件信息
	EnterDragonWorld = 1411,
	QuitDragonWorld = 1412,
	DragonInfoRefresh = 1413,--巨龙活动信息
	DragonBattleTimes = 1414,--查看报名可选时段
	DragonBattleHistory = 1415,--查看历史记录
	DragonBattleScoreInfo = 1416,--巨龙战斗详情
	DragonBattleResult = 1417,--巨龙战斗结果

	DragonSecretShow = 1418,
	StaminaBallData = 1419,
	DragonSignUp = 1420, -- 巨龙报名
	RefreshMergeOrder = 1421,--刷新合成订单信息

	WorldPassOwnerInfoReceived = 1422,
	WorldPassOwnerInfoChanged = 1423,
	StrongHoldOwnerInfoReceived = 1424,
	StrongHoldOwnerInfoChanged = 1425,
	OnSetEdenUI = 1426,
	EdenUserRank = 1427,
	EdenCampScore = 1428,
	RefreshEquipAct = 1429,
	EdenMarchSignalPoint = 1430,
	UIGuideEdenWarTipsUpdate = 1431,
	UIEdenSubwayBuildUpdate = 1432,
	RefreshFirstChargeUI = 1433,
	UpdateFirstChargeUI = 1434,

	UpdateDragonServerEffect = 1435, --刷新巨龙Buff
	
	RefreshBuildUpgradeEffect = 1440,
	PlayFirstChargeBtnFlyEffect = 1441,
	GetEdenCrossWarGroupData = 1446,
	
	DesertUpdateLevelInView = 1447,
	DesertUpdateLevelOutView = 1448,
	ShowTroopMineDamage = 1449,
	ChangeHeroCamp = 1450,--修改英雄阵营
	RefreshRadarBossDailyRewardCount = 1451,--刷新雷达boss每日领奖次数
	RefreshChangeNameAndPic = 1452,--改头换面活动数据变化
	
	
	GoogleAdsUserEarnedReward = 1453,
	GoogleAdsUserExitReward = 1454,
	GoogleAdsUserCreateRewardedAdFail = 1455,
	GoogleAdsUserCreateRewardedAdSuccess = 1456,
	GoogleAdsUserClickAd = 1457,
	RefreshHeroCampRed = 1458,--刷新英雄阵营红点

	UnityAdsUserEarnedReward = 1459,
	UnityAdsUserSkipReward = 1460,
	UnityAdsUserCreateRewardedAdFail = 1461,
	UnityAdsUserCreateRewardedAdSuccess = 1462,
	UnityAdsUserClickAd = 1463,

	GetEdenMineScoreRank = 1464,
	
	GetEdenMissileData = 1465,

	GetBattlePassMedal = 1466, --获取勇士战令相关勋章

	StrongCommanderUpdate = 1475,
	StrongCommanderRank = 1476,
	StrongCommanderReward = 1477,

	LandingOperationRefresh = 1478,
	LandingOperationTarget = 1479,
	LandingOperationConfirm = 1480,
	LandingOperationReward = 1481,
	LandingOperationRank = 1482,
	LandingOperationQuickFightEnd = 1483,
	OnTroopDragonUpdatePos = 1484,
	LandingOperationQuickFightDone = 1485,
	
	ShowActBossHeadInBattle= 1486,
	HideActBossHead = 1487,
	ShowAllianceBossHeadInBattle= 1488,
	HideAllianceBossHead = 1489,
	ShowMonsterHeadInBattle = 1490,
	HideMonsterHead = 1491,
	ShowMonsterBattleValue = 1492,
	UnlockNewFuncAniEnd = 1493,
	GuideShowDogItemAniEnd = 1494,

	AutoWriteAllianceNameAndAbbr = 1495, --自动填充联盟简称和简称

	ColloesCaravanRecord = 1496, --派遣记录
	UpdateAllianceCumulativeRechargeInfo = 1497,--刷新联盟累充数据

	PlayNormalBubbleAni = 1498, --播放晃动气泡

	ActivityTipStateUpdate = 1500, -- 活动提示弹出限制状态更新

	
	CheckMoveCity = 1502,
	ShowMoveRangeEffect = 1503,
	CrossFightMoveCity = 1504,	---跨服迁城ing
	OpenRallyBossTaskPanel = 1505,
	OnRallyBossTaskRewardGet = 1506,
	
	AssistanceThroneMarchDataUpdate = 1507,
	CheckAllianceCityDomeOpen = 1508,
	
	OnWorldPointObjLoadDone = 1510, --地图加载完成

	UpdateAssistanceLeader = 1511, --刷新增员队长

	AccountDeleteEnterCD = 1512,
	AccountDeleteCancel = 1513,
	
	OnArmyChange = 1519, --当士兵改变时
	UpdateHeroTower = 1520, --刷新英雄塔
	PlayerPowerInfoUpdated2 = 1521, --刷新战力
	UpdateGarageFormationPower = 1522, --刷新车库编队战力

	UpdateDragonScoreInfo = 1523, --刷新巨龙积分信息
	
	CheckDigRewardRedPoint = 1524, --挖宝可领取红点
	
	GetBalloonPuzzleInfo = 1530,
	ReceivePuzzleReward = 1531,
	UpdateAttackZombieRedPoint = 1532,

	ShowDesertMonsterAttack = 1533,
	ShowDesertSoldierAttack = 1534,
	ShowDesertWin = 1535,
	ShowDesertLost = 1536,
	PveLevelBeforeEnter = 1537,
	ShowDesertAttackHeadUI = 1538,

	UpdateDigActivityBag = 1539, --刷新挖宝背包
	
	GetDawnDayActInfoMessage = 1540,
	PushDawnDayActScoreMessage = 1541,
	E_CheckCrossFight = 1542, -- 检测主UI的跨服按钮

	GetSomeAlBattleRushDetail = 1550,
	GetOneAlBattleRushDetail = 1551,
	RefreshAlBattleRushTempTab = 1552,
	GetAlBattleDayVsInfo = 1553,
	ConfirmPrivacy = 1554,

	RefreshMainTroop = 1555,
	RefreshScoutTroop = 1556,
	RefreshHelpTroop = 1557,
	SetMarchIsOutBattle = 1558,
	
	ChangeDesertLevelFlag = 1559, --改变赛季等级标识

	RefreshUINoticeAlCompeteTips = 1560,

		-- 砍伐相关
	RefreshCutReward = 2000,
	MapObjectInitOK = 2001, -- 地图物件初始化完毕

	ChampionBattleRankDataBack = 2002,

	ShowTalkBubble = 2003,
	HideTalkBubble = 2004,
	ChampionBattleReportDataBack = 2005,
	RefreshAllianceCareer = 2006,--刷新联盟职业
	UpdateWorldZoneNews = 2007,
	UpdateWorldNewsData =2008,
	WorldAreaNewsRedDot = 2009,
	WorldAlCityNewsRedDot = 2010,

	RefreshHeroMonthCardAll = 2011,--刷新英雄月卡整个界面
	RefreshHeroMonthCardSingle = 2012,--刷新英雄月卡单个cell

	ShowAlScienceCriticalHitRatio = 2013,--联盟科技捐献暴击

	BuildUpgradeRewardArmy = 2014,--建筑升级获得兵力奖励
	CumulativeReward = 2015,
	DeclareWar = 2016,
	BuildUpgradeBubbleReward = 2017,
	GoGiftPackagePop = 2018,

	ActLuckyRollUpdate = 2019,--幸运转盘信息更新
	ActLuckyRollChoiceItem = 2020,--幸运转盘选择道具
	ActLuckyRollGetReward  = 2021,

	StartAttackMonsterWithoutMsgTip = 2022,--不弹窗开始打野怪，引导用

	ActBattlePass = 2023,--战令信息更新
	ActBattlePassRefresh = 2024,--推送更新
	ActBattlePassTask = 2025,--战令任务更新
	ActBattlePassStage = 2026,--战令阶段更新
	ActBattlePassRed = 2027,
	ShowCollectBattleValue = 2028,
	CollectPointOut = 2029,
	GuideSaveId = 2030,

	ActGolloesCard = 2031,--咕噜翻卡
	ActGolloesCardRefresh    = 2032,
	ActGolloesCardRank = 2033,
	ActGolloesCardRed = 2034,
	ActGolloesCardFlipAll = 2035,
	ActGolloesCardRewardShow = 2036,
	ActGolloesCardFlip = 2037,

	ActSevenDay = 2038,
	ActSevenDayScore = 2039,
	ActRewardState = 2040,

	GetRankRefresh = 2041,

	NpcCityInView = 2042,
	NpcCityOutView = 2043,
	NpcCityGetInfo = 2045,
	NpcCityGetChat = 2046,
	NpcCityDefendChange = 2047,
	NpcCityNewChat = 2048,

	ActLuckyRollRankUpdate = 2049,
	GetAllianceSeasonScoreRank = 2050,

	OnGiftPackageRewardGetUIClose = 2051, --当通用领奖界面关闭时
	
	CustomChatEventCall = 2052, --自定义聊天事件刷新
	
	BuildConfirmFinish = 2053, --建筑升级结束
	
	UpdateDragonBossDamage = 2054, --刷新巨龙boss伤害
	CheckCanAtkSeasonBuild = 2055, -- 检测是否可以攻击赛季建筑
	UpdatePtGold = 2056,

	DidEnterBackground = 2057,
	WillEnterForeground = 2058,
	CrossNetConnectSuccess = 2070,
	
	-- PVE相关
	PVE_Lineup_LoadOK = 2100,  -- 阵型加载完毕
	OnSelectPVEHeroSelect = 2101, --选中英雄
	OnCancelPVEHeroSelect = 2102, --取消选中
	OnEmBattleHeroChanged = 2103, --布阵改变
	PVE_TotalHp_Changed = 2104, --总血量变化
	PVE_Lineup_Init_End = 2105, --阵容初始化完成
	PVE_Exit = 2106, --退出pve
	PuzzleDataUpdate = 2107,--拼图信息刷新
	PuzzleTaskUpdate = 2108,--拼图任务完成

	MonsterLockDataBack = 2109,
	MonsterLockDataUpdate = 2110,
	MonsterLockInView = 2111,
	MonsterLockOutView = 2112,
	MonsterLockStateUpdate = 2113,
	DestroyMonsterLockBubbleStateHide = 2114,

	HeroLotteryInfoUpdate = 2115,
	PveBattleBuffAdd = 2116, -- 已弃用，使用 1179

	OnPuzzleMonsterRankRefresh = 2117,
	OnPuzzleMonsterDataRefresh = 2118,
	HeroBeyondSuccess = 2119,
	
	CrossServerWar = 2120,

	OnRefreshSevenLogin = 2121,
	OnRefreshSeasonCard = 2122,
	SeasonWeekCardBuy = 2123,
	SeasonWeekCardReward = 2124,
	
	SelectResourceLackToggleIndex = 2125, --选中资源不足的Toggle
	
	UpdateGarageRank = 2126, --更新车库排行榜
	BeforeCloseUI = 2127,--关闭页面之前
	ShowAllianceBossNewHeadInBattle = 2128,  -- 显示新联盟boss战斗进度条
	UpdateAllianceBossDmg = 2129,--更新联盟boss伤害
	
	--  [[ MKMKMKMKMKMKMKMKMKMKMKMKMKMKMKMKMK
	OnDailyActivityNewStatusChange = 2193,
	OnClaimCollectRewardSucc = 2194,
	UpdateThemeActNoticeRewardInfo = 2195,
	UpdateOneThemeActivity = 2196,
	MineCaveShowDispatch = 2197,
	OnAlScienceRecommendChange = 2198,
	OnAllianceRecommendChange = 2199,
	UpdateOneCommonShopGoods = 2200,
	UpdateOneCommonShop = 2201,
	OnBuyCommonGoodsSucc = 2202,
	OnQuestRedCountChanged = 2203,
	UpdateAllianceAutoRallyInfo = 2204,
	OnUpdateArenaBaseInfo = 2205,
	OnUpdateArenaHistoryInfo = 2206,
	OnArenaBattleFinish = 2207,
	OnArenaRedChange = 2208,
	OnStorageSellToGolloes = 2209,
	OnChapterTaskBtnVisibleChange = 2210,
	OnMsgBallBtnVisibleChange = 2211,
	UpdateMainAllianceRedCount = 2212,
	OnGetAlMoveInvite = 2213,
	OnOneActivityOverviewRedChange = 2214,
	OnCommonShopRedChange = 2215,
	OnDragUICloseTip = 2216,
	AllianceCountryChanged = 2217,
	OnPassDay = 2218,
	OnGetNewAllianceAutoInvite = 2219,
	OnWeekCardInfoChange = 2220,
	OnAllianceOfficialPosChange = 2221,
	OnUpdateJigsawPuzzleInfo = 2222,
	OnJigsawPuzzleEnd = 2223,
	OnJigsawRankUpdate = 2224,
	SetMainEnergyVisible = 2225,
	OnTreasureInfoUpdate = 2226,
	OnTreasureSkillReady = 2227,
	OnMuseumFocusTreasure = 2228,
	OnDigActivityInfoUpdated = 2229,
	OnCurDigLevelUpdated = 2230,
	OnDigOneBlockSucc = 2231,
	OnGetAutoDigResult = 2232,
	OnDigActFinalResultUpdated = 2233,
	OnbuyPickaxeSucc = 2234,
	OnUnlockActivityViewClose = 2235,
	RefreshAlMoveInviteTip = 2236,
	RefreshPveAdditional = 2237,
	UpateAllAllianceMineList = 2238,
	OnAddOneAllianceMine = 2239,
	OnDelOneAllianceMine = 2240,
	OnRefreshAllianceMineMarch = 2241,
	OnRobotWarActivityUpdate = 2242,
	OnClaimSeasonRewardSucc = 2243,
	OnPaidLotteryInfoUpdate = 2244,
	OnClaimPaidLotteryTicketSucc = 2245,
	OnGetPaidLotteryRollResult = 2246,
	OnPaidLotteryScoreChange = 2247,
	OnSeasonPassInfoUpdate = 2248,
	OnSeasonPassTaskRewardUpdate = 2249,
	OnSeasonPassLevelRewardUpdate = 2250,
	OnHeroGrowthInfoUpdate = 2251,
	OnHeroGrowthScoreChange = 2252,
	OnHeroGrowthScoreBoxStatusUpdate = 2253,
	OnRecvNewActivityInfo = 2254,
	OnWeekCardCustomRewardUpdate = 2255,
	OnAllianceMergeListUpdate = 2256,
	OnMyApplyMergeListUpdate = 2257,
	OnWeekCardOneInfoChange = 2258,
	OnAlContributeBoxStatusChange = 2259,
	OnAlContributeRankInfoUpdate = 2260,
	OnAlContributeEventInfoUpdate = 2261,
	OnExploitMonthCardInfoUpdate = 2262,
	OnDigActivityRankInfoUpdate = 2263,
	OnMyLeagueMatchInfoUpdate = 2264,
	OnLeagueMatchGroupUpdate = 2265,
	OnLeagueMatchBaseInfoUpdate = 2266,
	OnLastLeagueMatchGroupInfoUpdate = 2267,
	OnLeagueMatchRewardInfoUpdate = 2268,
	OnLeagueMatchStageChange = 2269,
	OnGetDigLevelReward = 2270,
	RefreshArenaRed = 2271,

	AllianceTechnology2 = 2272,
	RefreshBauble = 2273,--刷新装饰建筑
	RemoveBauble = 2274,--删除装饰建筑

	OnLeagueMatchSeasonPointUpdate = 2275,

	MK_End = 2300,
	--]] MKMKMKMKMKMKMKMKMKMKMKMKMKMKMKMKMK

	UIShowAllianceCitySolider = 2301,
	UIShowAllianceCityBlood = 2302,
	
	MainToWorldBtn = 2310,
	MainToDailyAct = 2311,
	
	OnOneKeyAdvanceSuccess = 2312,
	OnOneKeyAdvanceSuccessClosed = 2313,
	TalentDataChange = 2314,
	UpdateTrackingStatus = 2315,
	FactoryDataCancel = 2316,
	DeletePastureQueue = 2317,
	HeroExChange = 2318,
	HideAdvanceNew = 2319,
	UnlockArmy = 2320,
	PayTriggerResItemBack = 2321,
	ReceivePveTriggerRewardBack = 2322,
	DelayRefreshPVEStamina = 2323,
	PVEBuildingUpgradeBack = 2324,
	FactoryTransportAnimationStart = 2325,
	GatherEffectEnd = 2326,
	OnRemoveNewHeroFlag = 2327,
	HeroStarUpBack = 2328,

	DoFlyToShopBtn = 2329, --飞向商店按钮

	RefreshTowerFightRecord = 2330,--刷新炮台记录
	
	RecommendGatherChange = 2662,
	Disconnect = 2663,

	UpdateDragonBattleScore = 2664, --巨龙积分刷新

	HeroEquipUpgrade = 2725,--装备升级
	HeroEquipPromotion = 2726,--装备晋升
	HeroEquipInstall = 2727,--穿装备
	HeroEquipUninstall = 2728,--脱装备
	HeroEquipStartProduct = 2729,--装备合成
	HeroEquipDecompose = 2730,--装备分解
	HeroEquipAdd = 2731,--新装备
	HeroEquipMaterialCompose = 2732,--装备材料合成
	HeroEquipMaterialDecompose = 2733,--装备材料合成

	HeroEquipModelUpdate = 2734,
	OnSelectMakePartEquip = 2735,
	OnSelectTakePartEquip = 2736,
	OnSelectEquipMaterialCompose = 2737,
	OnSelectEquipMaterialDecompose = 2738,
	HeroEquipQueueFinish = 2739,

	ChatAllianceAnnouncementTranslated = 2756,
	ChatAllianceAnnouncementRefresh = 2757,
	ChatAllianceAnnouncementAdd = 2758,
	ChatAllianceAnnouncementDel = 2759,
	ChatAllianceAnnouncementRoom = 2760,

	OnSelectHeroEquipStrengthMaterial = 2771,
	OnSelectHeroEquipPromotionMaterial = 2772,
	RefreshHeroEquipRank = 2780,
	
	HeroIntensifyUpgrade = 2775,

	AllianceBossTimeShow = 2800,
	AllianceBossTimeHide = 2801,
	UpdateWorldTerrain = 2802, -- 更新世界地表

	ChristmasCelebrateInfo = 2839,
	
	GetSeasonDeclareRewardInfo = 2863,

	GetRechargeMonthCardInfo = 2864,
	RefreshRechargeMonthCardSingle = 2865,
	GetRechargeMonthCardUnlockIndex = 2866,
	GetRechargeMonthCardAllReward = 2867,

	GetCompensateMonthCardInfo = 2868,
	RefreshCompensateMonthCardSingle = 2869,
	GetCompensateMonthCardUnlockIndex = 2870,
	GetCompensateMonthCardAllReward = 2871,
	GetCompensateMonthCardGoldReward = 2872,
	RefreshCompensateMonthCardOnlineTime = 2873,

	GetICDCandyRoomInfo = 2880,
	CandyRoomRankUpdate = 2881,
	CandyRoomDonateSuccess = 2882,

	-- region 火车号段
	------------------------------------火车号段 Begin----------------------------------------
	ChangeTrainSuccess = 4000, -- 换火车成功
	RefreshTruckHero = 4001, -- 刷新护卫队
	RefreshTrainListData = 4002, -- 刷新火车列表
	RefreshTrainStationView = 4003, -- 刷新内城火车
	RefreshTruckStationView = 4004, -- 刷新内城卡车
	TrainSkirmishDataReceived = 4005, -- 收到火车抢劫战斗录像
	AddOrRefreshMarch = 4006, -- 刷新行军
	RefreshOneMyTruck = 4007, -- 刷新我的一辆货车
	ChangeTruckItemNumChange = 4008, -- 获得换卡车道具
	RefreshMyTruck = 4009, -- 刷新我的一辆或多量货车
	TrainTabChange = 4010, -- 火车页签变更
	TrainSceneCameraInitFinish = 4011, -- 火车场景初始化完成
	TrainPlaceFinish = 4012, -- 火车放置完成
	ClickTrain = 4013, -- 点击火车
	AllianceTrainInviteList = 4014, -- 可选火车司机列表
	AllianceTrainBuySuccess = 4015, -- 火车购买成功
	AllianceTrainBattleRecordList = 4016, -- 火车战斗记录列表
	AllianceTrainBattleRecordDetail = 4017, -- 火车战斗记录详情
	AllianceTrainAssignMessageSuccess = 4018, -- 火车司机任命成功
	AllianceTrainRefreshMessageSuccess = 4019, -- 火车刷新成功
	DelAllyTrain = 4020, -- 删除一辆联盟火车
	PassengerBubble = 4021, -- 乘客气泡
	PassengerAnim = 4022, -- 测试
	TruckBuffChange = 4023, -- 货车部队buff变化
	LeaveRobTruckView = 4024, -- 离开抢夺货车界面
	EnemyTruckWeaponDataArrive = 4025, -- 对方货车无人机数据到达
	PlayBonFireAnim = 4026, -- 播放篝火动画
	PresetDoorPos = 4027, -- 提前预设大门的位置
	ShowKillStreak = 4028, -- 显示连杀
	HideKillStreak = 4029, -- 隐藏连杀

	------------------------------------火车号段 End-----------------------------------------
	
	-------- Survival --- 5000 开始-------
	GameReconnectSuccess = 5000,   --断线重连成功
	GameOnConnectOK = 220020,		-- 网络连接成功 --和长按按钮冲突了 交换一下
	LoadingViewDestroy = 5002,
	SU_UpdateMapItemObject = 5003, -- 更新地表上的节点
	SU_RecvLevelRequestInfo = 5004, -- 请求关卡数据返回
	SU_LevelSceneCreateDone = 5005, -- 地表场景创建完成
	SU_InteractiveConfigDone = 5006, -- 交互物体配置读取完成
	SU_InteractiveChange = 5007, -- 交互物体改变
	Survival_GetBagGridData = 5008,
	Survival_PushUpdateBagGridData = 5009,
	SU_ZombieChange = 5010, -- 角色锁定的Zombie改变
	SU_CharacterBeAttack = 5011, -- 角色/Zombie 被攻击
	SU_PlayerCreateComplete = 5012, -- 角色创建完成
	SU_PlayerHungerChange = 5013, -- 角色饥饿值改变
	Survival_EquipSlotChanged = 5014, -- 装备槽位发生变更
	SU_PlayerExpChanged = 5015, -- 
	Survival_PocketCapacityChanged = 5016, -- 口袋容量发生变化
	Survival_ItemChanges = 5017, -- 道具数量变化
	Survival_EquipDurableChanged = 5018, -- 装备耐久发生变更
	SU_CheckResTarget = 5019, -- 筛选待采集的目标
	SU_CheckMonsterTarget = 5020, -- 筛选怪物
	SU_ToggleBuildBubble = 5021,
	SU_CheckRepairBubble = 5022, -- 检测主UI左侧修复按钮
	SU_DisableBuildObstacle = 5023, -- 
	SU_ZombieSiege = 5024, --丧尸攻城
	SU_BuildBeAttack = 5025, -- 建筑被攻击
	SU_ChangeViewHeight = 5026, -- RPG/SLG镜头切换
	SU_PlayerAttack = 5027, --玩家攻击
	SU_ClickJoystickBtn = 5028, --点击了摇杆上的按钮
	SU_RecoveryBuff = 5029, --恢复buff
	SU_SelectSlot = 5030, --选中了列表上的某个槽位(比如：背包，回收站)
	SU_RefreshMiniMapIcon = 5031, --刷新指定trigger小地图图标
	SU_BagMoveAllResponse = 5032, --背包一键迁移
	SU_ShowMainUI = 5033, --显示主UI
	SU_ShowMainUIBubble = 5034, --显示主UI底部的气泡提示按钮
	SU_RefreshBuildingItem = 5035, -- 刷新建筑功能（主要用来播放音效）
	SU_ChangeScreen = 5036, -- city/world 场景切换
	
	SU_HideOverheadDialog1 = 5037, --
	SU_FlyObjFirst = 5038, -- 飞道具第一个到达
	SU_FlyObjLast = 5039, -- 飞道具最后一个到达
	SU_FadeBlackViewClose = 5040, -- 
	SU_ClickNpcGirlGiveBtn = 5041, --点击了美女送礼物按钮
	RefreshGirlTipItem = 5042, -- 美女悬浮窗的道具刷新了
	RefreshGirlTipUnlockItem = 5043, -- 美女解锁悬浮窗的道具刷新了
	OnCityInputPointDown = 5044,
	PlayEnterAnim = 5045, -- 播放小人进场动画
	
	-- 一个特殊的事件ID，30000这个分段是系统保留
	PUSH_INIT_OK = 30000,
	DomeRangeChanged = 2331,--大本罩子变化之后
	UIBuildListScrollMove = 2332,--建造列表界面滚动
	ShowCityDome = 2333,--显示苍穹
	HideCityDome = 2334,--隐藏苍穹
	SetGuideMask = 2335,--引导通用开启/关闭遮罩事件
	RefreshCityRoadArr = 2336,--刷新城内数据（一组）
	DeleteCityRoadArr = 2337,--删除城内数据（一组）
	NPCQuestBubbleNeedRefresh = 2338,
	SetQuestCanShowInGuide = 2339,--引导期间可以显示任务
	UIScrollToSomeWhere = 2340,--引导打开界面滑动到指定位置
	GuideEndNoShowQuest = 2341,--引导结束不打开主UI左侧任务
	SetBuildCanDoAnim = 2342,--控制建筑能否做动画
	SetBuildNoDoAnim = 2343,--控制建筑不能做动画
	OnTouchPinchStart = 2344,--开始双指缩放
	OnTouchPinchEnd = 2345,--结束双指缩放
	OnEditorTouchPinch = 2346,--电脑开始滑动滚轮
	SetBuildCanShowLevel = 2347,--控制建筑能显示等级条
	SetBuildNoShowLevel = 2348,--控制建筑不能显示等级条
	OnInputLongTapStart = 2349,--在长按地面开始
	OnInputLongTapEnd = 2350,--在长按地面结束
	PosterExchangeSuccess = 2351,--Poster兑换成功
	PveMonumentSweep = 2352,--英雄丰碑扫荡完成
	HeroIntensifyUpdate = 2353,--英雄阵营强化更新
	HeroIntensifyRandomEffect = 2354,--英雄阵营强化随机
	MasteryStatusUpdate = 2355,

	UserSkinUpdate = 2360,--玩家皮肤信息刷新
	UserCitySkinUpdate = 2361,--玩家主城皮肤信息刷新
	
	AutoFarmDataUpdate = 2362,
	FormStatusUpdate = 2363,
	KeepPayUpdate = 2364, -- 每日累充更新
	ChainPayGetInfo = 2365, -- 连续充值GetInfo
	ChainPayReceiveReward = 2366, -- 连续充值ReceiveReward
	ChainPayUpdateState = 2367, -- 连续充值UpdateState

	LuckShopDataUpdate = 2368,--幸运商店信息更新
	LuckShopRefresh = 2369,--幸运商店刷新
	GetLastSeasonHeroRecordInfoSuccess = 2370,--
	TaskInitFinish = 2371,--任务初始化完成
	ChainPayRefresh = 2372, -- 连续充值Refresh

	DecorationActivityDataUpdate = 2373,--皮肤活动信息变化
	SendContactGiftSearchBack = 2374,


	MasteryLearn = 2375,
	MasteryChangePlan = 2376,
	MasteryUseSkill = 2377,
	MasteryUpdate = 2378,
	MasteryReset = 2379,
	MasteryChangeName = 2398,
	PageNameCheckEvent = 2399,

	GloryGetWarData = 2380,
	GloryGetDeclareAlliance = 2381,
	GloryDeclareWar = 2382,
	GloryStart = 2383,
	GloryMatch = 2384,
	GlorySetAvoid = 2385,
	GloryGetMyHistory = 2386,
	GloryGetHistory = 2387,
	GloryGetMemberRecord = 2388,
	GloryGetOldMemberRecord = 2389,
	GloryGetBattleDetail = 2390,
	GloryGetAct = 2391,
	GloryGetContribution = 2392,

	SeasonWeekUpdate = 2393,
	CrossWormPlunderUpdate = 2394,
	CrossWormSaveArmy = 2395,
	CrossWormSaveHero = 2396,
	BuildStatusUpdate = 2397,

	EquipDataUpdate = 2400,
	EquipSuitDataUpdate = 2401,
	EquipSelect = 2402,
	EquipInfoClose = 2403,

	SearchSelectUser = 2404,
	KingdomPositionInfoUpdate = 2405,
	KingdomPresidentInfoUpdate = 2406,

	EquipExpUp = 2407,
	EquipQualityUp = 2408,

	HeroEvolveCellSelect = 2409,
	HeroEvolveChoose = 2410,
	HeroEvolveSkillIconSelect = 2411,
	HeroEvolveSuccess = 2412,

	DecorationIconSelect = 2413,

	-- 聊天室相关
	ChatRoomCreate = 2420,
	ChatRoomDismiss = 2421,
	ChatRoomChangeName = 2422,
	MasteryExpUpdate = 2423,--专精经验增加
	
	RefreshDesertActivityInfoUpdate = 2430,
	
	RefreshBuildDataArr = 2517,--刷新建筑数据（一组）
	DeleteBuildDataArr = 2518,--删除建筑数据（一组）
	
	CheckAllianceAttackerRedPoint = 2520, --联盟情报红点
	CheckAllianceRallyWarRedPoint = 2521, --联盟集结红点
	
	CheckDragonMoveCity = 2540,  --巨龙战场检查迁城
	CheckDragonMark = 2541, --巨龙战场检查标记
	UpdateDragonMarkList = 2542, --刷新巨龙战场标记列表
	InitMainUIDragonPanel = 2543, --刷新主界面巨龙面板 
	OnGetDragonVoteResult = 2544, --巨龙战场投票结果
	
	--功勛
	UpdateSelfExploit = 2440,

	ScratchOffGameRankInfoUpdate = 2441,
	ScratchOffGameRewardRecordInfoUpdate = 2442,
	ScratchOffGameActivityParamUpdate = 2443,
	ScratchOffGameRewardLotteryInfoUpdate = 2444,
	ScratchOffGameGetExtraReward = 2445,
	BackToScratchOff = 2446,
	ScratchOffGameSelectedHeroUpdate = 2447,

	MiningLotteryResInfoUpdate = 2460,
	MiningActParamInfoUpdate = 2461,
	TakeMiningCarReward = 2462,
	MiningQueueSpeedUp = 2463,
	MiningCarCompleted = 2464,
	MiningQueueUnlock = 2465,

	MysteriousActParamUpdate = 2470,
	MysteriousRankInfoUpdate = 2471,
	MysteriousLotteryUpdate = 2472,
	GetMysteriousStageReward = 2473,

	MissileInfoUpgrade = 2450,
	ChampionBattleGroupDataBack = 2451,
	IndividualOrderFillBatch = 2452,
	HeroEvolveHeroInfoBack = 2453,
	EquipmentToggleClick = 2454,

	UpdateRewardControlInfo = 2456,
	MainMapTerrainLoadFinish = 2457,

	CrossWonderGetInfo = 2525,
	CrossWonderGetUserRank = 2526,
	CrossWonderGetUserRankReward = 2527,
	CrossWonderGetAllianceRank = 2528,
	CrossWonderGetAllianceRankReward = 2529,

	EdenKillGetRank = 2530,
	EdenKillGetRankReward = 2531,

	TurfWarGetInfo = 2532,
	
	StoryGetInfo = 2533,
	StoryReceiveStageReward = 2534,
	StoryLevelReward = 2535,
	StoryUpdateHangupTime = 2536,
	StoryGetHangupReward = 2537,
	StoryReceiveHangupReward = 2538,
	StoryGetRank = 2539,

	ReceiveLandReward = 2560,
	RefreshCompeRankData = 2561,  --限时竞赛排行数据刷新
	
	
	QualityChange = 2644,--品质调整
	
	RefreshHeroMonthCard = 2646,
	DailyQuestGetAllTaskReward = 2647,--日常任务奖励一键领取

	GetDailyPackageInfos = 2650,
	DailyPackageSelectHero = 2651,

	OnDailyMustBuyDataChanged = 2701, --每日必买
	OnPassWeek = 2702,
	OpenSyncListener = 2703,		-- 开启，关闭听众位置
	SetFlagRaiseTroopsState = 2704, -- 设置旗手状态

	SelectActById = 2705, --跳转到某个活动

	SelectActById = 2704, --跳转到某个活动
	MainCityHeroObjVisible = 2705, -- 主城内角色是否展示
	NpcTowerObjVisible = 2706, -- 城墙上的npc是否显示
	FORT_SHOT = 2707, -- 开炮
	Recv_Fort_Data = 2708, -- 收到炮塔的数据

	--盟主和r4福利
	AllianceLeaderRewardInfoBack = 2710,
	AllianceLeaderStageRewardReceived = 2711,
	AllianceLeaderDailyRewardReceived = 2712,
	AllianceLeaderRewardRedPoint = 2713,
	--联盟集结
	AllianceRallyRedPoint = 2714, --联盟集结红点
	WorldPointParse = 2715,

	ReceiveLastFreeTimeData = 2841,

	CreditUpdate = 4050,

	BAUBLE_UPGRADE_Refresh = 6034,
	MapBaubleRefresh = 6035,
	InitAllBauble = 6036,
	SU_UpdateBaubleDecorate = 6037,  -- 更新区域的Decorate
	SU_UpdateFeixuDecorate = 6038,  -- 更新区域的Decorate
	SU_RefreshTerrainDocorate = 6039, -- 更新decorate
	SU_UpdateDecorateActive = 6040, -- 更新decorate
	SU_ZoomAreaUnlock = 6041, -- zoom 类型的area解锁
	SU_DestroyLandLockWay = 6043, -- 移除landlock的路点
	SU_ToCreateSunShine = 6044, -- 添加光影的显示
	SDK_PermissionRecv = 6046, -- SDK返回Permission CS那边是6046，这边也用这个
	SU_GuideDone = 6047, -- 引导完成
	SU_ActiveJoyStick = 6048, -- 设置Joystick的active
	SU_PlayerTargetChange = 6049, -- 目标发生变化
	ShowMistressTalk = 6050, -- 
	RefreshMistressView = 6051, -- 
	SU_ForceDestroyLoadingListener = 6052,
	SU_PlayerStateDone = 6053, -- 单个state状态机执行完成
	SU_StopPlayerAutoAI = 6054, -- 停止角色自动AI
	SU_BeginToPlayCollectAnim = 6055, -- 开始播放采集动画
	SU_SetCurPlayerState = 6056, -- 设置当前角色状态
	SU_ResumeCameraFromMoveToNpcMode = 6057, -- 从看向NPC模式恢复摄像机之前状态
	SU_RefreshJoystickBuildBtn = 6058, -- 刷新Joystick的建筑按钮
	SU_TriggerProductBuildBubble = 6059, -- 触发生产建筑气泡
	SU_TimeOfDayChange = 6060, --天气时间改变
	SU_ShowModelByMode = 6061, -- 根据当前不同状态,显示面片还是模型
	SU_PLayerEffectChange = 6062, -- 玩家属性作用号值改变
	SU_CloseMovieCurtain = 6063, -- 关闭电影幕布界面
	SU_ClickToChangeViewMode = 6064, -- 开始转换视角模式
	SU_CloseUIFullScreenBlackBG = 6065, -- 关闭全屏幕布界面
	SU_ShowJoyStick = 6066, -- 显示摇杆
	SU_RefreshFullScreenDialog = 6067, -- 刷新FullScreenDialog
	SU_RefreshBagData = 6068, -- 背包内的数据改变
	ToggleMiniMapTask = 6069,
	SU_OnTriggerFinish = 6070, --trigger完成
	SU_ShowHideBuildHpBar = 6071, --建筑血条显示或隐藏
	SU_UpdateNpcTaskIcon = 6072,
	SU_ToggleGroundHint = 6073, --toggle地面trigger提示
	SU_PlayerSearchEnemy = 6074, --玩家锁敌
	PlayTaskPrompt = 6075, --播放任务弹框
	SU_QuestArrowStateChange = 6076,--任务指引箭头状态改变
	LevelSceneLoadDone = 6077,--加载场景完成
	SU_PlayerLevelUp = 6078,--
	SU_ShowLoadingDownloadComplete = 6079, --登录时资源下载完成
	SelectPicGuideListCell = 6080,
	SU_GuidePicChange = 6081,--
	SU_PlayerHpChanged = 6082, --血量变化
	SU_OpenBuildBtnView = 6083, -- 打开建筑按钮界面
	SU_CloseBuildBtnView = 6084, -- 关闭建筑按钮界面
	SU_PlayerStoolChange = 6085,--主界面大小便按钮切换
	SU_GameEventUpdated = 6086, --su事件id完成
	SU_UpdateBoxSelectColor = 6087, -- 更新箱子的颜色
	SU_RefreshMistressEffect = 6088,--美女脑袋上顶的那几种免费领资源
	SU_UpdateTriggerState = 6089,--更新TriggerState
	HeroExpEffectChange = 6090,--英雄免费经验书领取作用变化
	SU_ResetJoyStick = 6091, -- 恢复摇杆
	StationDataChange = 6092,--人口驻扎数据变化
	SU_ActiveMainUI = 6093, -- 隐藏主UI
	SU_ReAdjustJoyStickBtnStatus = 6094, --强制隐藏Joystick
	SU_RefreshAutoSwitch = 6095, --自动烹饪更新
	SU_MainUIReInit = 6096, -- 重新初始化MainUI
	SU_CloseLensBlackEdge = 6097, -- 关闭电影镜头黑边界面
	SU_BeginDownloadMainLevelRes = 6098, --开始下载主城依赖资源 
	SU_EndDownloadMainLevelRes = 6099, ----结束下载主城依赖资源
	StationUnlockNumChange = 6100,
	RefreshWorkerEffectNumChange = 6101,
	SU_IntoCar10003 = 6102, -- 进入房车内部
	ChangeSkyTime = 6103, -- 场景环境发生变化，需要重新处理
	ZombieDead = 6104,
	SU_CraftDone = 6105, --蓝图制造完成
	SU_GirlUnlock = 6106, --美女解锁
	SU_SetPubLadyBubble = 6107, -- 美女气泡
	RefreshLevel0Bubble = 6108, -- 刷新0级气泡
	RefreshIntelligence = 6109, -- 刷新情报站气泡
	SU_PveReportDoSkill = 6110, --突突突使用技能
	ChangeStoryScene = 6111, -- 推图切换场景
	SU_ResetPubLadyPos = 6112, -- 美女角色复位
	CheckSidebarRed = 6113, --检测侧边栏红点
	QueueFinish = 6114,--队列完成
	UpdateGirlState = 6115, --更新机器人状态
	AddCollectQueue = 6116,--添加机器人队列
	RemoveCollectQueue = 6117,--清理机器人队列

	RefreshBarrelHeroInfo = 6118, -- 刷新英雄的躲避球战力信息
	RefreshDrakeBoss = 6119, --德雷克活动
	
	LW_MainCityAreaFogUpdate = 6120, -- 迷雾消散
	LW_MainCityAreaUpdateState = 6121, -- 更新指定区块的状态
	LWLandLockFinish = 6122, -- landlock解锁
	LWUpdateMainCityRoleTeam = 6123, -- 更新主城内编队
	LWTeamPartnerCreateDone = 6124, -- 主城内成员创建完毕
	LW_CheckBattlePve = 6125, -- 检测是否需要出现房车pve气泡
	DetectNpcGetReward = 6126, -- 雷达npc完成
	RefreshMistressViewByExchange = 6127, -- 
	HeroRankUpFail = 6128, --英雄军阶升级失败
	TeamPlayDialogShow = 6129, -- 播放team多语言
	CheckFlagState = 6130, -- 检测旗杆状态
	RefreshResourceBagViewTab = 6131, -- 刷新资源界面tab选项
	TeamPlayDialogShow = 6132, -- 播放team多语言
	PreloadRes = 8001, -- 预加载资源
	UnloadPreloadRes = 8002, -- 卸载预加载资源
	CarUpgradeFinish = 6133, --改成车升级经验
	CarRefitFinish = 6134, --改装车升级技能

	Zendesk_ReCheck = 9000, -- 检测是否要显示客服红点
	HideZendeskWindow = 9001, --关闭UI


	PVEWin = 82387,
	PVELose = 82388,--推图玩法战败
	NoInputShowArrow = 82389, --无操作提示点击任务
	UpdateBuildEffect = 82390, --建筑作用号更新
	UpdateParkourStage = 82391, --跑酷关卡更新
	SquadSuperArmorStateChange = 82398, --小队霸体状态变更
	LuaEntryEffectRefreshStatus = 82399, --玩家buff更新
	AllianceWarNew = 82400, --新联盟集结
	ShowBuildQueueTip = 82401,
	HeroDropListModified = 82402, --英雄空投列表更新
	CloseMainUIFingerArrow = 82403, -- 关闭主UI任务手指
	ZombieBattleDestroy = 82404, -- 退出推图关卡
	HeroUpgradeRank = 82405, --英雄升阶
	UltimateCastFinish = 82406, -- 大招释放完成
	ShowFirstPayUI = 82407, --显示首充UI
	SearchAllianceError = 82408, --获取联盟详情失败
	PreviewHeroExhibitSceneInit = 82409, -- 英雄展示timeline场景加载完成

	ResourceItemCountChanged = 82410, -- 资源道具数量变化   param {data=data_table, delta=-2}
	OpeningStageZakuZombieInited = 82411, -- 新手关卡挂机僵尸初始化完成
	OpeningStageZakuZombieDestroyed = 82412, -- 新手关卡挂机僵尸销毁
	OpeningStageSetup = 82413, -- 新手关卡初始化 param nextStageId
	OpeningStageClear = 82414, -- 新手关卡清理 param nextStageId
	OpeningStageMarchBegin = 82415, -- 新手关卡行军开始 param nextStageId
	CHAT_GPT_EMOJI_UPDATE = 82416, --智能助手消息同步
	RefreshActivityDetailData = 82417, --刷新活动详细数据 
	RefreshRankingData = 82418, --刷新排行榜数据
	RefreshRankingReward = 82419, --刷新排行榜奖励
	HidePVEFormationPanel = 82420, --隐藏PVE队伍界面
	AllianceAnnouncementTranslate = 82421, --联盟宣言翻译















	PrepareDoDoBattle = 82351, --准备开始进入关卡
	
	LWBattleReward = 82352,--战斗胜利奖励

	ParkourBattleWin = 82370, -- 跑酷模式勝利


	LWBattleBuffStart = 82380, -- 战斗buff开始
	LWBattleBuffEnd = 82381, -- 战斗buff结束
	--region 战术装备
	TacticalWeaponLevelUp = 82850, --战术装备升级
	TacticalWeaponBubbleRefresh = 82851, --战术装备气泡刷新
	TacticalWeaponUpdate = 82852, --战术装备数据更新
	--endregion
	LWBarrageBattleEnd = 830004,--PVE 推图战斗结束 返回战斗结果
	



	--region PVE号段
	------------------------------------PVE号段 Begin----------------------------------------
	OnPVEBattleGetGoods = 83000,
	BarrageWinConditionRefresh = 83001,
	ParkourWinConditionRefresh = 83002,
	SkirmishCastUltimate = 83003,--战斗回放开大
	SkirmishUltimateBubble = 83004,--战斗回放播放大招气泡
	SkirmishEndStage = 83005,
	SkirmishDoAction = 83006,
	SkirmishUnDoAction = 83007,
	SkirmishChangeHp = 83008,
	SkirmishFightStage = 83009,
	UIPVELoadingQuit = 83010,

	CountBattlePlayerGroupSpawn = 83300,  -- Count战斗玩家组生成单位 param amount
	CountBattleReward = 83301, -- Count战斗奖励

	ParkourBattleStart = 83302,	--跑酷选人完成开始战斗
	ParkourBossEnterBattle = 83303,	--跑酷玩法boss出现

	PVEBattleVictoryConfirmed = 83999, -- PVE战斗胜利确认 param battleType
	------------------------------------PVE号段 End-----------------------------------------
	--endregion
	--region 火车号段
	------------------------------------火车号段 Begin----------------------------------------
	ChangeTrainSuccess = 4000,--换火车成功
	RefreshTruckDefenceHero = 4001,--刷新护卫队
	RefreshTrainListData = 4002,--刷新火车列表
	RefreshTrainStationView = 4003, --刷新内城火车
	RefreshTruckStationView = 4004, --刷新内城卡车
	TrainSkirmishDataReceived = 4005, --收到火车抢劫战斗录像
	AddOrRefreshMarch = 4006, --刷新行军
	RefreshOneMyTruck = 4007, --刷新我的一辆货车
	ChangeTruckItemNumChange = 4008, --获得换卡车道具
	RefreshMyTruck = 4009, --刷新我的一辆或多量货车
	TrainTabChange = 4010, --火车页签变更
	TrainSceneCameraInitFinish = 4011, -- 火车场景初始化完成
	TrainPlaceFinish = 4012, -- 火车放置完成
	ClickTrain = 4013, -- 点击火车
	AllianceTrainInviteList = 4014, -- 可选火车司机列表
	AllianceTrainBuySuccess = 4015, -- 火车购买成功
	AllianceTrainBattleRecordList = 4016, -- 火车战斗记录列表
	AllianceTrainBattleRecordDetail = 4017, -- 火车战斗记录详情
	AllianceTrainAssignMessageSuccess = 4018, -- 火车司机任命成功
	AllianceTrainRefreshMessageSuccess = 4019, -- 火车刷新成功
	DelAllyTrain = 4020, --删除一辆联盟火车
	PassengerBubble = 4021, --乘客气泡
	PassengerAnim = 4022, --测试


	------------------------------------火车号段 End-----------------------------------------
	--endregion

	--region Dog
	------------------------------------火车号段 Begin----------------------------------------
	RefreshRescueDog = 4100,
	HideUIRescueDogBottom = 4101,
	UIRescueDogSpineAnim = 4102,
	------------------------------------火车号段 End-----------------------------------------
	--endregion

	------------------------------------新手引导事件号段 Begin------------------------------------
	-- 90000 - 99999 为新手引导专用事件号段
	-- 避免业务层事件变更导致引导触发问题，将引导事件独立区分开，部分事件可能会和业务层事件冗余
	-- 重要！！业务层也尽量不要依赖这些事件，可能会随引导需求进行调整
	GF_guide_start = 90000, --新手引导流程开始 param guideId
	GF_guide_done = 90001, --新手引导流程结束 param guideId
	GF_guide_canceled = 90002, --新手引导流程取消 param guideId
	GF_guide_step_done = 90003, --新手引导流程步骤完成 param behaviourInst
	GF_guide_step_canceled = 90004, --新手引导流程步骤取消 param behaviourInst
	GF_enter_game = 90005, --进入游戏
	GF_enter_city = 90006, --进入主城
	GF_enter_world = 90007, --进入世界
	GF_window_opened = 90008, --窗口打开 param windowName
	GF_window_closed = 90009, --窗口关闭 param windowName
	GF_guide_mask_ready = 90010, --新手引导遮罩准备完毕
	GF_goto_pve_battle = 90011, --进入PVE战斗 param battleContext
	GF_goto_pve_battle_loaded = 90012, --PVE战斗加载完毕 param battleContext
	GF_pve_battle_exit = 90013, --PVE战斗退出 param {id=levelId, type=exitType}  type: "win" "lose" "quit"
	GF_parkour_battle_win = 90014, --跑酷战斗胜利 param levelId
	GF_parkour_battle_lose = 90015, --跑酷战斗失败 param levelId
	GF_count_battle_win = 90016, --Count战斗胜利 param levelId
	GF_count_battle_lose = 90017, --Count战斗失败 param levelId
	GF_zombie_battle_start = 90018, --僵尸战斗开始 param levelId
	GF_parkour_battle_start = 90019,--跑酷战斗开始 param type levelId
	GF_guide_rallybossact = 90020, --危机四伏->前往组队
	GF_guide_fastcombat = 90021, --快速战斗
	--== 特殊事件
	GF_old_guide_done = 99000, --老引导流程完毕
	GF_upgrade_building_failed = 99001, --建筑升级失败
	--== 建筑相关
	GF_building_menu_popout = 95000, --建筑菜单弹出
	GF_building_menu_upgrade_clicked = 95001,  --建筑升级按钮点击 param buildingData
	GF_building_menu_speedup_clicked = 95002,  --建筑加速按钮点击 param buildingData
	GF_building_upgrade_time_over = 95003, --建筑升级时间结束 param buildingData
	GF_building_upgrade_done = 95004, --建筑升级完成 param buildingData
	GF_building_parkour_bubble_refresh = 95005, --战斗入口气泡开关刷新
	GF_building_build_started = 95006, --建筑建造开始 param buildingData
	GF_building_upgrade_started = 95007, --建筑升级开始 param buildingData
	GF_building_speedup_by_item = 95008,  --使用道具加速建筑 param itemInfo
	GF_building_training_begin = 95009, --建筑开始训练 param msg["buildInfo"]
	GF_building_training_collect = 95010, --建筑训练收获 param msg["buildInfo"]
	GF_building_training_speedup = 95011, --建筑训练加速 param msg["buildInfo"]
	GF_building_training_time_over = 95012, --建筑训练完成 param msg["buildInfo"]
	--== 城市内
	GF_city_hero_drop_anim_done = 91000, --主城英雄空降动画完成  param heroId
	GF_city_hero_drop_box_clicked = 91001, --主城英雄空降宝箱点击 param heroId
	GF_hero_squad_saved = 91002, --英雄小队阵容保存后 param squadIndex
	GF_worker_rescued = 91003, --营救工人完毕
	GF_city_zone_loaded = 91004, --城市区域加载完毕
	GF_land_lock_state_changed = 91005,  --地块锁定状态改变 param {landId, state}
	GF_land_unlock_done = 91006,  --地块解锁完成 param landId
	GF_detect_event_refreshed = 91007,  --侦查事件刷新 param eventId
	GF_detect_event_item_clicked = 91008,  --侦查事件条目点击 param eventId
	GF_quest_rewarded = 91009,  --任务奖励领取 param questId
	GF_build_list_tab_selected = 91010,  --建筑列表页签选中 param tabType
	GF_begin_put_building = 91011,  --开始放置建筑 param buildingId
	GF_goods_lack_goto_clicked = 91012,  --资源不足跳转点击 param lackTipType
	GF_detect_event_goto_clicked = 91013,  --侦查事件跳转 param eventId
	GF_detect_event_state_changed = 91014,  --侦查事件状态改变 param msg["eventInfo"]
	GF_item_refreshed = 91015,  --道具刷新 param itemInfo
	GF_get_new_hero = 91016,  --获得新英雄 param heroData
	GF_monopoly_box_opened = 91017, --大富翁宝箱打开时 param monopolyStageId
	GF_monopoly_stage_done = 91018, --大富翁宝箱打开时 param monopolyStageId
	GF_monopoly_new_grid_arrived = 91019, --大富翁新格子到达时 param gridId
	GF_plot_group_done = 91020, --剧情对话结束时 param polyGroupId
	GF_play_timeline_loaded = 91021, --播放timeline加载完毕 param {resPath, timelineGO}
	GF_zombie_battle_ult_ready = 91022, --僵尸战斗大招准备完毕
	GF_click_random_btn = 91023, --点击"换车"--引导用
	GF_click_departure_btn = 91024, --点击"发车"--引导用
	GF_recruit_card_refreshed = 91025,  --招募卷道具刷新 param itemInfo
	GF_save_girl = 91026,				--救妹子拆弹成功 param 剩余解救次数
	--== 世界地图
	------------------------------------新手引导事件号段 End--------------------------------------
	SU_ShowPVEReward = 91027, -- 显示奖励
	
	ConfirmStartPVE = 91100, --在UIBarrelGetStronger界面中点击继续战斗，发送事件到UIPVEScene中，进入战斗
	AfterPVPStartFight = 91101, --PVP开场特效之后
	
	-- 1开头的被聊天占用了，从2开头的开始
	SU_BarrelGoldChanged = 200001, --躲避球金币改变
	SU_PoliceInsigniaChange = 200002, -- 警徽升级建筑改变
	SU_PoliceInsigniaLevelChange = 200003, --警徽升级消息
	SU_PoliceInsigniaFly = 200004, --飞警徽
	SU_RefreshItemById = 200005, --背包内的数据改变带着id
	SU_PoliceInsigniaBubbleShow = 200006, --警徽气泡显示
	SU_PoliceInsigniaMainLvUp = 200007, -- 警徽打本升级
	SU_PoliceInsigniaBuildPack = 200008, -- 警徽建筑进入礼包状态
	SU_BarrelDropGoldDestroy = 200009, -- 躲避球掉落的金币Icon消失
	SU_PoliceInsigniaRefresh = 200010, -- 更新顶部警徽条
	SU_BuildStartLoadEditor = 200011, --建筑开始移动
	SU_BuildGiftPackage = 200012, -- 建筑播放礼包动画
	LandLockFinished = 200013, -- 大富翁地块完成

	Barrel_FreezeAllEnemies = 200014,
	Barrel_GenerateSpiderweb = 200015,
	Barrel_OnEnterSpiderweb = 200016,
	Barrel_OnExitSpiderweb = 200017,
	Barrel_SpawnMine = 200018,
	Barrel_OnEnterMine = 200019,
	Barrel_FireSceneNeutralBullet = 200020,
	Barrel_ObtainTimedMoveSpeedBuff = 20021,
	Barrel_ShowBigBossHitVFX = 20022,
	Barrel_AddHeroTrialHero = 20023,
	Barrel_StartLevelResponse = 20024,
	Barrel_OnTrailLevelMemberDie = 20025,
	Barrel_SetGamePause = 20026,
	Barrel_RemoveSpecifiedHero = 20027,
	PreviewSkillSceneInit = 20028,
	PVEBuffAdded = 20029,
	PVEBuffRemoved = 20030,
	BossEnterBattle = 20031,
	BattleZombiesEnter = 20032,

	Barrel_RemoveSpecifiedHero = 20033,
	OnToggleHeroUpgradeTip = 20034,
	Barrel_UITutorial2Closed = 20035,
	Barrel_DropTriggerGate = 20036,
	
	Barrel_PlayHeroDialogAndCv = 20050,
	Barrel_TryPlayReplaceTrailHero = 20051,
	Barrel_ToggleFormationHeroLevelBar = 20052,
	Barrel_PauseOrResumeUnitAni = 20053,
	Barrel_RescueDogRemoveHero = 20054,
	Barrel_TimedMoveSpeedChanged = 200100,
	
	TalkTaskDataRefresh = 200101, --对话任务数据刷新
	UpdateRadarLevelEventsInfo = 200102, -- 雷达等级气泡点击刷新

	DispatchTaskTodayNumUpdate = 200103,
	DispatchTaskUpdateSingle = 200104,
	DispatchTaskUpdateAlliance = 200105,
	DispatchGetRealPoint = 200106,
	
	TalkTaskAreaUnlockInfo = 200107, --对话任务类型4

	MonthCardFourthGuide = 200108, -- 第四队列月卡指示
	BuildSetToBoxForce = 200109, -- 强制设置为箱子状态

	OnCityMainBuildMoveFinish = 200110, --世界上迁城结束
	
	GuideBreak = 200111,--- 引导被15下中断了

	WorldBuildTopBubblePlot = 200112, -- 世界建筑头顶显示对话
	HelpDetectEndEffectBubbleShow = 200113, -- 世界建筑帮助完成特效

	DetectInfoChangeClaimLevelReward = 200114, -- 领取雷达升级奖励
	NpcCityInView = 200115,
	NpcCityOutView = 200116,
	NpcCityGetInfo = 200117,
	NpcCityGetChat = 200118,
	NpcCityDefendChange = 200119,
	NpcCityNewChat = 200120,
	RefreshRankLikeNum = 200121,

	RefreshUnlockGirlTime = 200122,
	PlayerTeamInitFinish = 200123,
	
	BuildObjectShowOpenBoxTimeline = 200124, -- 建筑升级时是否播放timeLine
	
	GarbageTriggerFinish = 200125,--宝箱采集，领奖完成
	
	SetSimulateState = 200126, -- 设置物理是否开启, 记得最后调用关闭，否则会导致一直开启
	
	DetectEventComplete = 200127, -- 雷达任务完成
	
	GirlCollectSpeedUpRefresh = 200200, --宝箱拾取道具加速信息刷新
	CardGetReward = 200128, -- 刷新周卡月卡气泡
	CloseWorldPointView = 200129, -- 移除大地图上的物体
	
	--生存战备
	PersonalArmsReward = 200130, --刷新战备排行奖励
	PersonalArmsRank = 200131, --刷新战备排行榜

	UIScreenCenterTipsViewClose = 200132, -- 战力条关闭
	NpcCityBloodValueChange =  200133, -- npc City血量变化时消息
	VirtualNpcCityBuildInView = 200134, -- 世界上虚拟玩家进入视野时
	VirtualNpcCityBuildOutView = 200135, -- 世界上虚拟玩家退出视野时
	
	SceneChanged = 201000, --场景发生了变化
	
	WorldBlackTileWindowState = 201001, -- 世界上点击地面的响应事件
	
	OnRefreshTrainRedDot = 201002, --刷新活动中心 押镖红点
	CloseWorldPointView_Truck = 201003, -- 移除大地图上的物体
	
	MarchStatus_DESTROY_WAIT = 201004, -- 世界上status状态变为这个状态
	
	SU_ResourceInfoChange = 201005, -- 资源数据发生变化，数据不一定发生了变化，有可能是服务器更新数据时会带着其他的更新
	ShowFirstPayArrow = 210004, --显示首充指引
	CrossServerReconnectSuccess = 210010, ---跨服重连成功
	TruckInfoUpdate = 210011, -- 卡车相关信息变化更新
	TruckSuperRefresh = 210014, -- 卡车超级刷新
	ShopRefreshCurrency = 210001, --商店刷新货币
	ToDayPlunderRes = 210002, --今日掠夺数量
	ChangeToVertical = 210003, -- 切换为竖版专享用户

	AllianceCityUpdatePointInfo = 210005, ---联盟城PointCityInfo刷新
	AllianceCityInfoUpdateGiveUpEndTime = 210006, ---联盟城PointCityInfo刷新放弃时间
	
	MapObjectDestroyOk                  = 210007,--城内建筑销毁
	StartMoveBuild                      = 210008,--开始移动建筑
	StopMoveBuild                       = 210009,--停止移动建筑

	
	
	
	ShowBuildFakeUpdating = 210012, -- 建筑展示假的升级架子
	ActiveMainCityAreaHud = 210013, -- 激活或者隐藏地块解锁按钮
	--爱情通讯
	SelectHeroInNewsletterHandbook = 210050, --通讯录界面选中某一英雄
	SelectHeroInNewsletter = 210051, --会话界面选中某一英雄
	HeroInNewsletterFilterEnd = 210052,
	SelectStory = 210053,
	UpdateHeroChatMessage = 210054,
	UpdateHeroBatteryPower = 210055,
	UpdateHeroInNewsletterRedMark = 210056,
	HeroChatMessageOutTime = 210057,
	HeroPhotoUnlocked = 210058,
	
	--从竞技场退出
	Exit_From_Arena = 210021,
	
	HeroSkinRefresh = 210024, -- 皮肤刷新
	BuildStationChange = 210025, -- 驻扎小人的建筑发生了变化
	SmallPeopleBtnClick = 210026, -- 主界面小人按钮点击
	UpdateOneHeroSmallPeople = 210027, -- 小人英雄数据刷新
	RefreshBuildMainUpdateStation = 210028, -- 时代变迁UI弹出消息
	DroneTimelineShowHeroBubble = 210029, -- 无人机timeline走过时小人展示气泡
	BonFireBoyResetToStart = 210030, -- 重置小人到初始位置
	BonFireBoyPlayEnterAnim = 210031, -- 小人开始走,带id的
	HeroSkinRed = 210032,--皮肤红点
	WorldPointManagerClose = 210022,
	SkinShopRefresh = 210033, --皮肤商店刷新
	SkinShopTicketRefresh = 210034, --皮肤券商店刷新
	
	SetWorldGoHomeBtnVisible = 210041, -- 设置世界地图返回按钮是否可见
	GuideSaveFinish = 210042, -- 引导保存完成
	
	PveJeepAdventureTaskAllReward = 210103,--pve悬赏任务获取全部奖励
	GetJeepAdventureTask = 210104, --获取悬赏任务
	GetJeepAdventureTaskSingleReward = 210105, --获取悬赏任务单个奖励
	
	MonthDetectCardScoreEvent = 210200,

	DesertInView = 210201,
	DesertOutView = 210202,
	
	PushReportMail  = 2100203, --收到战报邮件
	PushPresidentMail = 2100204, --收到总统邮件
	
	ChatAtTa = 210300,  --聊天@at
	ClearAt = 210301,   --清除聊天@At
	SetChatRoomClickTime = 210302,--设置房间最后点击时间
	ReSetExScrollView = 210303,
	
	--王座活动
	ThroneActUpdateScoreInfo = 220001, --更新王座活动积分信息
	ThroneActUpdateScoreRankView = 220002, --更新王座活动积分排名界面
	ThroneActUpdateScoreRankRewardView = 220003, --更新王座活动积分排名奖励界面
	ThroneActUpdateFightRecordView = 220004, --更新王座战斗记录
	ThroneActAllianceCityInView = 220005,
	ThroneActAllianceCityOutView = 220006,
	ThroneMainBottomBubbleState = 220007,--主界面王座气泡刷新状态
	ThroneAllianceRally = 220008, --王座联盟集结
	ThroneActUpdateMarchWinCount = 220009, --王座更新一个队伍的连胜次数
	ThroneTroopShowHead = 220010, --王座集结队伍显示头像
	ThroneTroopHideHead = 220011, --王座集结队伍隐藏头像
	ThroneLeaveAlliance = 220012, --王座战期间自己被踢出了联盟
	BonFireBoyResetToStart = 210030, -- 重置小人到初始位置
	GarageRefitNewUpdate = 220013, -- 车库改装
	GarageRefitTalentUpdate = 220014, -- 车库天赋数据刷新
	GarageRefitTalentUnlock = 220015, -- 车库天赋数据解锁
	GarageGradingUpdate = 220016, --改装成评级刷新
	BonFireBoyPlayEnterAnim = 210031, -- 小人开始走,带id的
	BatchDetectEventRewardReceive = 220016, --- 雷达批量领取奖励
	AutoFinishDetectEventMessage = 220017, --- 雷达一键执行
	
	FormationSoldierUpdate  = 220018, -- 编队士兵更新

	FlyGoodToGoodsBtnFinish = 220019, -- 飞道具到仓库按钮
	Btn_LongPress = 5001, --Btn长按抬起事件

	
	CrossThroneBuildInView      = 220100,
	CrossThroneBuildOutView     = 220101,
	ShowCrossThroneAttackHeadUI = 220102,
	HideCrossThroneAttackHeadUI = 220103,
	GetCrossThroneBuild         = 220104,
	UpdateCrossThroneBuild      = 220105,
	CrossWonderScoreRefresh     = 220106,
	RefreshRocketBomb           = 220107,--刷新火箭炸弹
	EnterCrossThroneWorld       = 220108,
	QuitCrossThroneWorld        = 220109,

	OnCrossScoreInfoUpdate		= 220200,--跨服王座对决积分更新
	OnServerBattleCrossReward 	= 220201,--跨服王座刷新积分奖励
	OnServerBattleWinReward		= 220202,--胜利奖刷新			
	OnServerBattleRank			= 220203,--跨服王座战斗排名	
	OnGetServerCrossBattleMainInfo = 220204,--跨服王座 跨服战斗信息更新
	OnGetScorePersonRank		= 220205,--玩家个人排行更新
	OnGetScoreAllianceRank		= 220206,--联盟排行更新
	
	UpdateBuildPoliceInsigniaArrow = 220301, -- 更新建筑箱子状态箭头
	
	GuideTimelineJump = 220302, -- 跳过timeline
	ActGiftBoxDrawReward = 220303,
	
	DeclareWarReservationReward = 220310, --预约宣战奖励刷新
	AllianceCityFirstKillReward = 220311, --首占奖励刷新

	ChatPrivateRoomDrag = 220320, --私聊拖动
	ChatPrivateRoomDel = 220321, --删除私聊
	ChatRoomDelMumber = 220322, --删除成员
	
	OnSurvivalHeroCollectionReward= 220400, --照片墙收集任务

	LLFirstPayRewardBubbleShowState = 220401, --首充气泡显示或者隐藏

	ActivityRedPacketRefresh = 220402,--红包活动大刷新
	ActivityRedPacketRefreshReward = 220403,--红包活动大刷新
	ActivityRedPacketRefreshChoose = 220404,--红包活动大刷新

	OnDigTreasureTipEvent = 220500,
	OnTreasureRewardRecordMessage = 220501,

	UIBarrelHeroBottomInfo = 220502, -- 突突突底部箭头刷新
	UIBarrelHeroBottomRefreshPos = 220503, -- 突突突底部箭头是否开启位置跟随
	UIBarrelHeroBottomRefreshLevel = 220504, -- 突突突底部等级层显示
	UIBarrelHeroCameraMove = 220505, -- 突突突开场镜头变化
	
	DragonBuildOutViewNew   = 220510,
	DragonSignupOver        = 220511,--巨龙报名结束
	HeroSPEquipUpdate = 220512,
	HeroSPEquipCheck = 220513,
	DragonMemberApplyChanged = 220514,--申请出战、不参与状态变化
	OnReceiveAllianceBossAllianceReward = 220600,
	DrakeBoss2InfoUpdate = 2206001, -- 洛哈试炼

	CarTalentGradingChange = 220700, -- 改装车天赋改装评分数据改变
	CarTalentGradingTimeChange = 220701, -- 改装车天赋限时刷新
	CarTalentGradingLevelChange = 220702, -- 改装车评分等级改变
	CarTalentPreGradingChange = 220703, -- 评分等级还没刷新时，做飞动画用

	OnReceiveShopFreeReward = 220800,--折扣商店领奖
	LuckyShopDrawReward = 220805,
	OnLuckyShopRankInfoUpdate = 220806,
	TowerClimbingBatchChange = 220801, --挂机关跳过
	CustomChoiceItem = 220802,--自选礼包选择服务器数据返回
	RefreshAddLike = 220803,
	RefreshMailLike = 220804,
	OnEffectUpdate = 220900, -- 作用号发生变化
	
	WorldAllianceCityRecordUpdate = 220901, -- 联盟城战记录更新
	
	GloryDeclareStateRefresh = 220910,  -- 宣战刷新阶段
	
	OnReceiveMinePlunderActivityInfo = 221001,--金矿活动数据返回
	OnMinePlunderObjectInViewChange = 221002,
	OnMinePlunderedForBloodChange = 221003,--金矿受到掠夺攻击血量变化
	OnMinePlunderedBattleStateChange = 221004,--金矿掠夺开战与结束

	GloryDeclareWarRewardRefresh = 221010,  -- 联盟宣战奖励刷新


	--好有
	CheckFriendAlias = 230001,  --检测好有备注
	SetFriendAlias = 230002,    --设置好友备注
	DeleteFriend = 230003,      --删除好友
	RefreshFriendApply = 230004, --刷新申请列表
	RefreshFriend = 230005,      --刷新好友列表
	FriendGroupChat = 230006,    --创建拉入群聊检测
	UpdatePrivateRoomRed = 230007, --更新私聊红点
	UpdatePrivateRoomEdit = 230008, --编辑私聊房间

	MarchEmojiSettingUpdate = 222210,--行军表情设置更新
	SendMarchEmojiTimeUpdate = 222211,--发送行军表情时间更新	
	GetNewMarchEmoji = 222212, --获取新的行军表情

	ChatVoteState = 222213, --聊天投票状态刷新
	
	-- SLG统一业务引擎 25开头
	SecondArrow = 250001, --刷新连续箭头
	WorldFortressActivityUpdate = 250002,
	SetALRankName = 250003,--设置联盟RankName
	
	--联盟Rank改变
	AllianceMemberRank = 2762,

	CreditUpdate = 4050,
	UIChangeShowTranslated = 227001, --UI界面翻译返回   联盟公告、个人信息

	--改装车部件
	CarComponEquipChanged = 222020,	--改装车部件装备改变
	CarComponPartsChanged = 222021,	--改装车部件列表改变
	CarComponDataChanged = 222022,	--改装车数据变化
	CarComponNewCanEquip = 222023,	--改装车部件新增了可以装备的

	BtnStateEventChanged = 222101, --主界面按钮动态创建与删除
	
	-- 跳转赛季地块界面
	GotoSeasonGroundManageTab = 226001,
	RefreshSeasonBtnRedPoint = 226002,
	RefreshSeasonBtnState = 226003,
	RefreshSeasonGroupServerInfo = 226004,
	RefreshSeasonRecord = 226005,
	RefreshSesonCollectRes = 226006,
	RefreshResGuideGo = 226007,

	RefreshShieldGuard = 262002,
	ActBattlePassSeason = 226100,
	-- 英雄小人
	SmallPeopleAddNew = 222000, -- 小人添加新的
	SmallPeopleDelete = 222001, -- 小人删除
	
	--小人养成
	SmallPeopleRankUpFail = 222002, --英雄军阶升级失败
	SmallPeopleRankUpSuccess = 222003, --小人物升星成功
	RefreshSmallPeopleSkill = 222004, --刷新小人物技能
	--小人招募
	SmallPeopleRecruitInfoSuccess = 222005, --小人招募数据发生变化
	SmallPeopleRecruitInfoFail = 222006, --小人招募数据失败
	SmallPeopleRecruitRefreshSuccess = 222007, --小人刷新成功
	SmallPeopleRecruitRefreshFail = 222008, --小人刷新失败
	SmallPeopleRecruitSuccess = 222009, --小人招募成功
	SmallPeopleRecruitFail = 222010, --小人招募失败
	--小人筛选
	SmallPeopleFilterChanged = 222011, --小人筛选状态变更
	SmallPeopleItemRefreshFail = 222013, --道具刷新小人失败
	SmallPeopleItemRefreshSuccess = 222014, --道具刷新小人成功

	--改装车部件
	CarComponEquipChanged = 222020,	--改装车部件装备改变
	CarComponPartsChanged = 222021,	--改装车部件列表改变
	CarComponDataChanged = 222022,	--改装车数据变化
	CarComponNewCanEquip = 222023,	--改装车部件新增了可以装备的
	ChampionBattleScoreRefresh = 22712,
	
	ChampionBattleScoreBoxRefresh = 22713,
	
	ChampionBattleGuessRefresh = 22714,
	ChampionBattleBetMatchRefresh = 22715,

	ChampionBattleBetBack = 22716,
	ChampionBattleBetCancel = 22717,

	ChampionBattleBetRecordRefresh = 22718,
	ChampionBattleMatchRecordRefresh = 22719,

	ChampionBattleBetRewardGet = 22720,
	ChampionBattleSetMsgResponse = 22721,
	ChampionBattleSwitchToFormation = 22722,
	ChampionBattleGuessRedPoint = 22728, --竞猜红点
	
	DecorationUIOpen = 22801,--打开主城皮肤UI,需要隐藏一些气泡
	DecorationUIClose = 22802,--关闭主城皮肤UI,需要重新显示一些气泡
	
	ChampionBattleFinalRank = 22723,
	ChampionBattleSwitchToLastPage = 22724,
	ChampionBattlePushOneMsg = 22725,
	ChampionBattlePushOneFireWork = 22726,
	
	LikeRefresh = 22727, --点赞刷新
	UserSkinConvert = 22730, --兑换皮肤成功

	--大富翁活动
	OnRollMonopolyActivity = 22901,
	OnRevMonopolyStageReward = 22902,--领取阶段奖励
	RefreshDroppedTreasureActivityInfo = 22903,
	OnRollMonopolyNeedRefreshNewGrid = 22904,
	RevMonopolyDailyReward = 22905,
	
	FlipFunInfoRefresh = 23903,--翻转活动信息刷新
	FlipFunStartGame = 23904,--翻转活动开始游戏
	FlipFunOnFlip = 23905,--翻转活动翻转
	FlipFunClaimDailyReward = 23906,--翻转活动领取每日奖励
	FlipFunHelpRecordRefresh = 23907,--翻转活动帮助记录刷新
	FlipFunOnStateChange = 23908,--翻转活动状态改变

	VerticalInviteInfoUpdate = 230010, --个人邀请领奖功能数据刷新
	VerticalInviteMembersUpdate=  230009,
	
	LuckyRollBigRewardRankUpdate = 240004, -- 幸运转盘大奖排行榜刷新
	
	ActExchangeFinish  = 240006, --兑换完成
	ActExchangeListRefresh = 240007, --兑换列表刷新
	ActExchangeSwapRequestSuccess = 240008, --兑换请求成功
	ActExchangeClearSuccessRecord = 240009, --清除兑换成功记录
	ActExchangeRecordRefresh = 240010, --兑换记录刷新
	SendVerticalInviteError = 240011,
	ChangeGameToVerticalSuccess=  240012,
	VerticalInviteStageRewardUpdate= 240013,
	VerticalInviteRulePopFly = 240014,
	OnGetCrossWonderUserScoreRanklist = 240100, -- 跨服王座积分排行刷新
	AllianceVerticalInviteInfoUpdate = 240110, --联盟邀请领奖功能数据刷新
	HospitalSmallPeopleUpdate = 240120, --医院上阵的小人刷新
}

return ConstClass("EventId", EventId)
