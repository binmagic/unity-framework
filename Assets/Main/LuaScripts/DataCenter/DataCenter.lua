

local Managers =
{
    --AttackSnowManManager = "Slg.DataCenter.AttackSnowMan.AttackSnowManManager",

	GuideManager = "DataCenter.GuideManager.GuideManager",


}

-- 已经加载的manager
---@class DataCenter
---@field ThroneActManager ThroneActManager
---@field SearchLodManager SearchLodManager
---@field ActSeasonWeekCardData ActSeasonWeekCardData
---@field WorldMarchBattleManager WorldMarchBattleManager
---@field DragonBuildTemplateManager DragonBuildTemplateManager
---@field TrainSceneManager TrainSceneManager
---@field LWTrainDataManager LWTrainDataManager
---@field BuildTimeManager BuildTimeManager
---@field PayManager PayManager
---@field CreditManager CreditManager
---@field MonsterTemplateManager MonsterTemplateManager
---@field VIPTemplateManager VIPTemplateManager
---@field VIPManager VIPManager
---@field WorldPointManager WorldPointManager
---@field NpcCityManager NpcCityManager
---@field HeroTemplateManager HeroTemplateManager
---@field LandingOperationsDataManager LandingOperationsDataManager
---@field ScienceManager ScienceManager
---@field ScienceTemplateManager ScienceTemplateManager
---@field AllianceMainManager AllianceMainManager
---@field DefenceWallDataManager DefenceWallDataManager
---@field FormationAssistanceDataManager FormationAssistanceDataManager
---@field CityManageDataManager CityManageDataManager
---@field DigActivityManager DigActivityManager
---@field HeroDataManager HeroDataManager
---@field AllianceCityLogManager AllianceCityLogManager
---@field HeroSPEquipManager HeroSPEquipManager
---@field AllianceCareerManager AllianceCareerManager
---@field AllianceMineManager AllianceMineManager
---@field AllianceDeclareWarManager AllianceDeclareWarManager
---@field AlLeaderElectManager AlLeaderElectManager
---@field AllianceHelpDataManager AllianceHelpDataManager
---@field AllianceGiftDataManager AllianceGiftDataManager
---@field AllianceAlertDataManager AllianceAlertDataManager
---@field AllianceWarDataManager AllianceWarDataManager
---@field AllianceRedPointManager AllianceRedPointManager
---@field WorldNewsDataManager WorldNewsDataManager
---@field AllianceTaskManager AllianceTaskManager
---@field GarageRefitManager GarageRefitManager
---@field WorldFortManager WorldFortManager
---@field WorldAllianceTowerDataManager WorldAllianceTowerDataManager
---@field ArrowManager ArrowManager
---@field TowerClimbingManager TowerClimbingManager
---@field StoryManager StoryManager
---@field PveLevelTemplateManager PveLevelTemplateManager
---@field SV_MapItemInfoManager MapItemInfoMgr
---@field PveTaskManager SUPveTaskManager
---@field DetectEventBubbleManager DetectEventBubbleManager
---@field RadarCenterDataManager RadarCenterDataManager
---@field WorldAllianceCityDataManager WorldAllianceCityDataManager
---@field WorldFavoDataManager WorldFavoDataManager
---@field BuildUpgradeEffectManager BuildUpgradeEffectManager
---@field BuildUpgradeStockManager BuildUpgradeStockManager
---@field BuildPoliceInsigniaManager BuildPoliceInsigniaManager
---@field BuildBubbleManager BuildBubbleManager
---@field DetectEventTemplateManager DetectEventTemplateManager
---@field AllianceMemberDataManager AllianceMemberDataManager
---@field MailDataManager MailDataManager
---@field MailShowTemplateManager MailShowTemplateManager
---@field MailGroupTemplateManager MailGroupTemplateManager
---@field RewardManager RewardManager
---@field AllianceBaseDataManager AllianceBaseDataManager
---@field AllianceScienceDataManager AllianceScienceDataManager
---@field AllianceLeaderRewardManager AllianceLeaderRewardManager
---@field ArmyFormationDataManager ArmyFormationDataManager
---@field AppearanceTemplateManager AppearanceTemplateManager
---@field ItemTemplateManager ItemTemplateManager
---@field BuildTemplateManager BuildTemplateManager
---@field AccountManager AccountManager
---@field QueueDataManager QueueDataManager
---@field BattleLevel SU_LevelMgr
---@field PlayerLevelManager PlayerLevelManager
---@field BuildManager BuildManager
---@field SUPveLevelDataManager SUPveLevelDataManager
---@field ArmyTemplateManager ArmyTemplateManager 军队睡觉管理
---@field WorldPointDetailManager WorldPointDetailManager
---@field WorldAllianceCityRecordManager WorldAllianceCityRecordManager
---@field SetTodayNoShowSecondConfirm SecondConfirmManager
---@field ArenaManager ArenaManager 竞技场数据管理
---@field WorldMarchDataManager WorldMarchDataManager 世界行军数据管理
---@field PlayerInfoDataManager PlayerInfoDataManager 玩家数据管理
---@field ActivityListDataManager ActivityListDataManager 活动数据管理
---@field ActDragonManager ActDragonManager
---@field SeasonGroupManager SeasonGroupManager
---@field GloryManager GloryManager
---@field HospitalManager HospitalManager
---@field DesertDataManager DesertDataManager
---@field SeasonDataManager SeasonDataManager
---@field DesertTemplateManager DesertTemplateManager
---@field CrossWonderManager CrossWonderManager
---@field CrossWonderTemplateManager CrossWonderTemplateManager
---@field TaskManager TaskManager
---@field GuideManager GuideManager
---@field WorldGotoManager WorldGotoManager
---@field ResourceManager ResourceManager
---@field BuildQueueManager BuildQueueManager
---@field BuildQueueTemplateManager BuildQueueTemplateManager
---@field WaitTimeManager WaitTimeManager
---@field WaitLoadManager WaitLoadManager
---@field WaitUpdateManager WaitUpdateManager
---@field LuckyShopManager LuckyShopManager
---@field WorldNoticeManager WorldNoticeManager
---@field RadarAlarmDataManager RadarAlarmDataManager
---@field HeroSmallPeopleDataManager HeroSmallPeopleDataManager
---@field SmallPeopleDataManager SmallPeopleDataManager
---@field LotteryDataManager LotteryDataManager
---@field SmallPeopleRecruitDataManager SmallPeopleRecruitDataManager
---@field AllianceCityTemplateManager AllianceCityTemplateManager
---@field AllianceCompeteDataManager AllianceCompeteDataManager
---@field LWMyStationDataManager LWMyStationDataManager
---@field ResLackManager ResLackManager
---@field LoginPopManager LoginPopManager
---@field ArmyManager ArmyManager
---@field UIPopWindowManager UIPopWindowManager
---@field GovernmentTemplateManager GovernmentTemplateManager
---@field WonderGiftTemplateManager WonderGiftTemplateManager
---@field GovernmentManager GovernmentManager
---@field ActChampionBattleManager ActChampionBattleManager
---@field DecorationDataManager DecorationDataManager
---@field GarageComponManager GarageComponManager
---@field ArmyManager ArmyManager
---@field ScienceDataManager ScienceDataManager
---@field ItemData ItemData
---@field HeroEquipManager HeroEquipManager
---@field HeroEquipTemplateManager HeroEquipTemplateManager
---@field FlipFunManager FlipFunManager
---@field ShareMsgManager ShareMsgManager
---@field VerticalInviteData VerticalInviteData
---@field ActExchangeManager ActExchangeManager
---@field ServerBadgeTemplateManager ServerBadgeTemplateManager
---@field AllianceVerticalInviteData AllianceVerticalInviteData
---@field XiaoRenRankTemplateManager XiaoRenRankTemplateManager
local DataCenter = {}

-- 释放的时候，如果没有加载就不再初始化了
function DataCenter:DeleteAll()
	for k,v in pairs(self) do
		if type(v) == 'table' then
			if v.Delete ~= nil then
				v:Delete()
			else
				print("DataManager no Delete function!!!!")
			end
			k = nil
		else
			local t
		end
	end
end

-- 是否有效
function DataCenter:IsValid(k)
	local t = rawget(self, k)
	return t and true or false
end

setmetatable(DataCenter, 
	{ 
		__index = function(t, k)
			local manager = Managers[k]
			if manager ~= nil then
				local type = require(manager)
				local inst = type.New()
				t[k] = inst
				return inst
			end
			return nil
		end
	})

return DataCenter
