---统一使用 CSharpCallLuaInterface 实现c# call lua 功能
---@class CSharpCallLuaInterface
local CSharpCallLuaInterface = {}

--local CityPioneer_Const = require("Scene.CityPioneer.Const")


--local function ToggleCityCheat()
    --CityTriggerPointManager:GetInstance():ToggleCheat()
    --DataCenter.BattleLevel:ToggleCheat()
--end

----[[
---读配置表
---]]
local function GetDataTableCount(xmlName)
   return LocalController:instance():GetTableLength(xmlName)
end

local function GetTemplateData(_type, itemId, name)
    --这里是C#读表接口，先判断AB测
    --if LuaEntry.Player ~= nil then
        --_type = LuaEntry.Player:GetABTestTableName(_type)
    --end
   return LocalController:instance():getStrValue(_type, itemId, name)
end

----[[
----世界点信息
---]]
local function GetWorldPointTileSize(pointId)
   return WorldBuildUtil.GetBuildTile(pointId)
end

local function GetAllianceColorList()
   return DataCenter.WorldAllianceCityDataManager:GetAllianceColorList()
end

local function GetAllianceCityList()
   return DataCenter.WorldAllianceCityDataManager:GetAllianceCityList()
end

local function GetAllianceCitySimpleDataByPointInfo(pointInfo)
   return WorldBuildUtil.GetAllianceCitySimpleDataByPointInfo(pointInfo)
end
local function GetWorldPointModelPath(pointInfo)
   return WorldBuildUtil.GetWorldPointModelPath(pointInfo)
end

----[[
----道路信息
---]]

local function GetAllianceCityIdByPointInfo(pointInfo)
   return WorldBuildUtil.GetAllianceCityIdByPointInfo(pointInfo)
end
local function GetBoardData(uuid)--通过道路uuid获取道路信息
   return DataCenter.BoardManager:GetBoardData(uuid)
end

local function GetBoardDataByPointId(pointId)--通过道路pointId获取道路信息
   return DataCenter.BoardManager:GetBoardDataByPointId(pointId)
end

-- 因为避免给C#返回lua table，这里做了点处理
local function IsTruckRoad(pointId)
	local bd = GetBoardDataByPointId(pointId)
	if bd ~= nil then
		return true
	end
	return false
end

local function IsRoad(pointId)
	local bd = GetBoardDataByPointId(pointId)
	if bd ~= nil then
		return true
	end
	return false
end

local function GetBuildMaxRadius()--获取自己道路可建造最大半径
   return DataCenter.BoardManager:GetBuildMaxRadius()
end

local function GetOtherLimitRadius()--获取他人道路可建造最大半径
   return DataCenter.BoardManager:GetOtherLimitRadius()
end

local function GetRoadBuildTime()--获取道路建造时间
   return DataCenter.BoardManager:GetBuildTime() / 1000
end


local function GetAllRoadData()--获取所有道路信息
   return DataCenter.BoardManager:GetAllRoadData()
end

local function GetAllShowRoadData()--获取所有可显示道路信息
    return DataCenter.BoardManager:GetAllShowRoadData()
end

local function InitRoadData(message)
   DataCenter.BoardManager:InitData(message)
end

local function ResetBoard()--清空所有道路信息
   return DataCenter.BoardManager:ResetBoard()
end


----[[
----dataConfig
---]]
local function CheckSwitch(key)
   return LuaEntry.DataConfig:CheckSwitch(key)
end

local function GetIsAllianceCityOpen()
   -- 临时：打包版不开启
   --if not CS.CommonUtils.IsDebug() then
   --   return false
   --end

    --if CommonUtil.IsInDragonActivity() then
    --    return false
    --end
    
   return true
end
local function GetConfigNum(key1,key2)
   return LuaEntry.DataConfig:TryGetNum(key1,key2)
end
local function GetConfigStr(key1,key2)
   return LuaEntry.DataConfig:TryGetStr(key1,key2)
end

----[[
----建筑
---]]
local function GetTrainingTypeAndBuildingType(buildId)
   return BuildingUtils.GetTrainingTypeAndBuildingType(buildId)
end

local function GetMainPos()
    local pos = BuildingUtils.GetMainPos()
   return CS.UnityEngine.Vector2Int(pos.x, pos.y)
end

local function SetMainPos()
    local buildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
    if buildData~= nil and buildData.state~=BuildingStateType.FoldUp  then
        EventManager:GetInstance():Broadcast(EventId.MainPosChanged)
    end
end

local function GetAllianceBuildTileIndex(buildId,index)
    return WorldAllianceBuildUtil.GetBuildTileIndex(buildId,index)
end

local function GetBuildTileIndex(buildId,index)
   return BuildingUtils.GetBuildTileIndex(buildId,index)
end

local function GetTouchPickablePos()
    return CS.SceneManager.World.touchPickablePos
end
local function SetTouchPickablePos(value)
    CS.SceneManager.World.touchPickablePos = value
end

local function IsCanPutDownByBuild(buildId,index,buildUuid,noPutPoint)
    return BuildingUtils.IsCanPutDownByBuild(buildId,index,buildUuid,noPutPoint)
end

local function IsCanPutDownByAllianceBuild(buildId,index)
    return WorldAllianceBuildUtil.IsCanPutDownByAllianceBuild(buildId,index)
end

local function IsCanShowCollectGreenByPoint(index)
    return BuildingUtils.IsCanShowCollectGreenByPoint(index)
end

local function IsInMyBaseInsideRange(point)
    return BuildingUtils.IsInMyBaseInsideRange(point)
end

local function GetOutermostIndexByIndex(index,radius,maxX,maxY)
    return BuildingUtils.GetOutermostIndexByIndex(index,radius,maxX,maxY)
end

local function GetBuildModelCenter(mainIndex,tile)
    return BuildingUtils.GetBuildModelCenter(mainIndex,tile)
end
local function GetBuildModelCenterVec(mainIndex,tile)
    return BuildingUtils.GetBuildModelCenterVec(mainIndex,tile)
end

local function GetBuildMainVecByModelCenter(centerIndex,tile)
    return BuildingUtils.GetBuildMainVecByModelCenter(centerIndex,tile)
end
local function GetCollectMaxEffectByBuildId(buildId)
    return DataCenter.BuildManager:GetCollectMaxEffectByBuildId(buildId)
end

local function GetDirByPos(lastPos,curPos,nextPos)--获取模型显示方向
   local openDir,flowDir = CommonUtil.GetDirByPos(lastPos,curPos,nextPos)
   return openDir
end

local function SendFindMainBuildInitPositionMessage()
   SFSNetwork.SendMessage(MsgDefines.FindMainBuildInitPosition)
end

local function GetMainLv()
    return DataCenter.BuildManager.MainLv
end

local function CheckReplaceMain()
    DataCenter.BuildManager:CheckReplaceMain()
end

local function UpdateBuildings(message)
    DataCenter.BuildManager:UpdateBuildings(message["building_new"])
end

local function GetAllLuaBuildWithoutFoldUp(list)
    local buildList = DataCenter.BuildManager:GetAllBuildWithoutPickUp()
    if buildList ~= nil then
        for k,v in ipairs(buildList) do
            list:Add(CS.LuaBuildData(v.uuid,v.updateTime,v.pointId,v.state,v.itemId,v.level,v.connect))
        end
    end
    return list
end

local function GetBuildingDataByUuid(uuid)
    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
    if buildData ~= nil then
        return CS.LuaBuildData(buildData.uuid,buildData.updateTime,buildData.pointId,buildData.state,buildData.itemId,buildData.level,buildData.connect)
    end
end

local function GetBuildingDataParamByUuid(uuid)
	local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
	if buildData ~= nil then
		return buildData.uuid,buildData.updateTime,buildData.pointId,buildData.state,buildData.itemId,buildData.level,buildData.connect
	end
end

local function GetBuildingDataByBuildId(buildId)
    local buildData = DataCenter.BuildManager:GetFunbuildByItemID(buildId)
    if buildData ~= nil then
        return CS.LuaBuildData(buildData.uuid,buildData.updateTime,buildData.pointId,buildData.state,buildData.itemId,buildData.level,buildData.connect)
    end
end

local function GetBuildingDataParamByBuildId(buildId)
	local buildData = DataCenter.BuildManager:GetFunbuildByItemID(buildId)
	if buildData ~= nil then
		return buildData.uuid,buildData.updateTime,buildData.pointId,buildData.state,buildData.itemId,buildData.level,buildData.connect
	end
end

local function GetWorldBuildingModelName(pointIndex)
    local buildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
    if buildData~=nil then
        local skinId = 0
        local model = ""
        local skins = DataCenter.DecorationDataManager:GetAllActiveDecoration()
        if skins~=nil then
            for k,v in pairs(skins) do
                local dt = DataCenter.DecorationDataManager:GetSkinDataById(v)
                if dt.type == SkinType.BASE_SKIN and dt.wear and dt.wear == 1 then
                    skinId = v
                    break
                end
            end
        end
        if skinId>0 then
            local template = DataCenter.DecorationTemplateManager:GetTemplate(skinId)
            if template ~= nil and  template:IsDefault()==false then
                model = template.model_world
            end
        end
        if model == nil or model == "" then
            local buildTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildData.itemId, buildData.level)
            if buildTemplate ~= nil then
                model = buildTemplate.model_world
            end
        end

        
        
        return model
        
    end
end

local function GetAllInBaseTruckShowBuild(list)
    local buildList = DataCenter.BuildManager:GetAllInBaseTruckShowBuild()
    if buildList ~= nil then
        for k,v in ipairs(buildList) do
            list:Add(CS.LuaBuildData(v.uuid,v.updateTime,v.pointId,v.state,v.itemId,v.level,v.connect))
        end
    end
    return list
end

local function IsInNewUserWorld()
    return DataCenter.BuildManager:IsInNewUserWorld()
end

local function GetBuildDataResourcePercent(uuid)
    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
    if buildData ~= nil then
        return buildData:GetResourcePercent()
    end
    return 0
end

local function GetBuildStartTimeAndEndTime(uuid)
    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
    if buildData ~= nil then
        local result = {}
        result.startTime = buildData.startTime
        result.endTime = buildData.updateTime
        return result
    end
end

local function IsBuildWork(uuid)
    local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
    if buildData ~= nil then
        local now = UITimeManager:GetInstance():GetServerTime()
        return buildData.unavailableTime == 0 and now < buildData.produceEndTime
    end
    return false
end

local function GetBuildQueueState(uuid)
    return DataCenter.BuildManager:GetBuildQueueState(uuid)
end




----[[
----CityPoint
---]]

local function InitCityPointData(message)
    --DataCenter.CityPointDataManager:InitData(message)
end

local function GetAllCityPointData()
    return DataCenter.CityPointDataManager:GetAllPointData()
end

local function GetCityPointDataByPointId(pointId)
    return DataCenter.CityPointDataManager:GetPointDataByPointId(pointId)
end

local function GetPointDataByUuid(uuid)
    return DataCenter.CityPointDataManager:GetPointDataByUuid(uuid)
end

local function GetSingleMapJunkTemplate( itemId )
    return DataCenter.SingleMapJunkTemplateManager:GetTemplate(itemId)
end

local function RemoveCityPointDataByPointId(pointId)
    DataCenter.CityPointDataManager:RemovePointDataByPointId(pointId)
end

local function RemoveCityPointDataByUuid(uuid)
    DataCenter.CityPointDataManager:RemovePointDataByUuid(uuid)
end

local function GetCityPointType(pointId)
    return DataCenter.CityPointManager:GetPointType(pointId)
end

local function GetCityPointSize(pointId)
    return DataCenter.CityPointManager:GetPointSize(pointId)
end

----[[
----资源
---]]
local function GetResourceNameByType(resourceType)
   return CommonUtil.GetResourceNameByType(resourceType)
end

local function SetIsInCity(value)
    SceneUtils.SetIsInCity(value)
end

local function CheckIsInBuildRange(Ax,Ay,Bx,By,tile)
   return WorldBuildUtil.CheckIsInBuildRange(Ax,Ay,Bx,By,tile)
end

local function IsCollectRangePoint(pointIndex)
    return false
end
local function GetCollectRangePoint(pointIndex,resourceType)
    return nil --WorldBuildUtil.GetCollectRangePoint(pointIndex,resourceType)
end

local function OnPointDownMarch(marchUuid)
    UIUtil.OnPointDownMarch(marchUuid)
end

local function OnPointUpMarch(marchUuid)
    UIUtil.OnPointUpMarch(marchUuid)
end

local function OnBeginDragMarch(marchUuid)
    UIUtil.OnMarchDragStart(marchUuid)
end
local function GetResourcePercent(buildId,buildLv,endTime,startTime)
    return BuildingUtils.GetResourcePercent(buildId,buildLv,endTime,startTime)
end
local function GetBuildCollectSpeed(buildId,level)
    local max = 0
    local buildLevelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildId,level)
    if buildLevelTemplate ~= nil then
        max = buildLevelTemplate:GetCollectSpeed()
    end
    return max
end
local function GetBuildCollectMaxSelf(buildId,level)
    local max = 0
    local buildLevelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildId,level)
    if buildLevelTemplate ~= nil then
        max = buildLevelTemplate:GetCollectMax()
    end
    return max
end
local function GetBuildCollectMaxOther(buildId,level)
    local max = 0
    local buildLevelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildId,level)
    if buildLevelTemplate ~= nil then
        max = buildLevelTemplate:GetCollectMaxOthers()
    end
    return max
end

local function GetShowBubblePercent(buildId,level)
    local percent = 0
    local buildLevelTemplate = DataCenter.BuildTemplateManager:GetBuildingLevelTemplate(buildId,level)
    if buildLevelTemplate ~= nil then
        percent = buildLevelTemplate:GetShowBubblePercent()
    end
    return percent
end

local function GetNextChangeTimeByResourceUuid(uuid, percent)
    local data = DataCenter.BuildManager:GetBuildingDataByUuid(uuid)
    if data ~= nil then
        return data:GetNextChangeTimeByPercent(percent)
    end
    return 0
end

local function GetAllBuildTileByItemId()
    return DataCenter.BuildTemplateManager:GetAllBuildTileByItemId()
end

local function GetAllBuildOffset()
    return DataCenter.BuildTemplateManager:GetAllBuildOffset()
end

local function GetLodArray()
    return LodArray
end

local function GetCityLodArray()
    return CityLodArray
end

--是否可以移动建筑
local function IsCanShowBuildBtn()
    --return BuildingUtils.CanMoveBuild()
	return false
end
--是否可以移动建筑
local function CanMoveBuild(buildId)
    --return BuildingUtils.CanMoveBuild(buildId)
	return false
end

local function CheckIsInBasementRange(pointId)
    return WorldBuildUtil.CheckIsInBasementRange(pointId)
end

local function GetConfigMd5()
    return LuaEntry.DataConfig:GetMd5()
end

local function IsShowBuildFlyPath()
    return DataCenter.BuildManager:IsShowBuildFlyPath()
end

--local function SetGuideGarbageCollectTime(startTime, endTime)
    --DataCenter.PickGarbageDataManager:SetTime(startTime, endTime)
--end

--local function AddGuideGarbageCollectToQueue(pointId)
    --DataCenter.PickGarbageDataManager:AddIndexToGarbageQueue(pointId)
--end

--local function RemoveFromGarbageQueue(pointId)
    --DataCenter.PickGarbageDataManager:RemoveFromGarbageQueue(pointId)
--end

--local function GetCurrentGarbageQueue()
    --return DataCenter.PickGarbageDataManager:GetCurrentPickIndex()
--end

-- 获取盟主uid
local function GetAllianceLeaderUid()
    local allianceBaseData = DataCenter.AllianceBaseDataManager:GetAllianceBaseData()
    return allianceBaseData and allianceBaseData.leaderUid or ""
end

--local function IsShowPrologue()
    --local flag = DataCenter.GuideManager:IsShowPrologue()
	--return flag
--end

--local function IsBeforePrologue()
    --return DataCenter.CityPioneerManager:IsBeforePrologue()
--end


---- 加载场景结束之后，做一个遍历处理
--local function OnLoadSceneOK(sceneNode, sceneName)
    --local list = {}
	--local garbageRoot = sceneNode.gameObject.transform:Find("Scene_City_Dig(Clone)/Interactive")
	--if garbageRoot then
        --if not CSharpCallLuaInterface.CanShowLandLock() then
            --local nodeNames = {'rock', 'crystal', 'cactus', 'water', 'wood'}
            --for _, nodeName in pairs(nodeNames) do
                --local nodeRoot = garbageRoot:Find(nodeName)
                --if nodeRoot ~= nil then
                    --local childCount = nodeRoot.childCount
                    --for i = 0, childCount - 1 do
                        --local child = nodeRoot:GetChild(i).gameObject
                        --local instanceId = child:GetInstanceID()
                        --local build = CS.SceneManager.World:AddObjectByPointId(instanceId, 20)
                        --build._luaTable:BindGameObject(instanceId, child)
                    --end
                --end
            --end
        --end
        --table.insert(list,garbageRoot)
	--end
    --local mountainRoot = sceneNode.gameObject.transform:Find("Scene_City_Dig(Clone)/Mountain")
    --if mountainRoot then
        --table.insert(list,mountainRoot)
    --end
    --local plantRoot = sceneNode.gameObject.transform:Find("Scene_City_Dig(Clone)/Plant")
    --if plantRoot then
        --table.insert(list,plantRoot)
    --end
    --local groundRoot = sceneNode.gameObject.transform:Find("Scene_City_Dig(Clone)/Ground")
    --if groundRoot then
        --table.insert(list,groundRoot)
    --end
    --DataCenter.GuideCityManager:SetCityRoot(list)
--end

local function OnUploadPicStart()
    LuaEntry.Player:UploadPicStart()
end

local function GetPlayerPic()
    return LuaEntry.Player:GetPic()
end
local function GetPlayerPicVer()
    return LuaEntry.Player:GetPicVer()
end

local function GetHeroQuality(rarity,reachMax)
    local isReachMax = reachMax
    if isReachMax~=nil and isReachMax == true then
        if rarity ~= HeroUtils.RarityType.S then
            isReachMax = false
        end
    else
        isReachMax = false
    end
    return HeroUtils.GetCircleQualityIconPath(rarity,isReachMax)
end

local function GetHeroIcon(heroId)
    return HeroUtils.GetHeroIconRoundPath(heroId)
end

local function GetMarchStateIcon(marchInfo)
    return MarchUtil.GetMarchStateIconByType(marchInfo)
end

--[[
    解锁地块
]]

local function GetLandLockDataById(id)
    return DataCenter.LandLockManager:GetLandLockDataById(id)
end

local function GetLandLockDataByPointId(id)
    return DataCenter.LandLockManager:GetLandLockDataByPointId(id)
end

local function GetLandLockDataListByState(state) -- state 是 LandLockState
    return DataCenter.LandLockManager:GetLandLockDataListByState(state)
end

local function CanShowLandLock()
    return DataCenter.BuildManager.MainLv >= 1
end

local function ClickLandLockById(id)
    return DataCenter.LandLockManager:ClickLandLockById(id)
end

local function ClickSelfLandLock(id)
    return DataCenter.LandLockManager:OnClickSelfLandLock(id)
end
local function ClickOtherLandLockById(id,pointId)
    return DataCenter.LandLockManager:OnClickOtherLandLock(id,pointId)
end

local function LandLockTimeLineFinish(id, alter)
    DataCenter.LandLockManager:OnLandLockTimeLineFinish(id, alter)
end

local function GetMonsterLockDataList(state)
    return DataCenter.MonsterLockDataManager:GetAllMonsterExceptRewardData()
end

local function ClickMonsterLockById(id)
    return DataCenter.MonsterLockDataManager:ClickMonsterLockById(id)
end
--

local function GetBuffPerformanceInfo(buffId)
    return DataCenter.StatusManager:GetBuffPerformanceInfo(buffId)
end

local function CanShowCityLabel()
    return DataCenter.BuildManager.showCityLabel == true
end
--是否显示世界垃圾点
local function IsShowWorldCollectPoint()
    return DataCenter.GuideManager:IsShowWorldCollectPoint()
end
local function SendErrorMessageToServer(errorMsg)
    --local now = UITimeManager:GetInstance():GetServerSeconds()
    --CommonUtil.SendErrorMessageToServer(now, now, errorMsg)
    Logger.LogError(errorMsg)
end

function CSharpCallLuaInterface.IndexToTilePos(index)
    return SceneUtils.IndexToTilePos(index)
end

function CSharpCallLuaInterface.TileIndexToWorld(index)
    return SceneUtils.TileIndexToWorld(index)
end

function CSharpCallLuaInterface.TilePosToIndex(tilePos)
    return SceneUtils.TilePosToIndex(tilePos)
end

function CSharpCallLuaInterface.WorldToTile(worldPos)
    return SceneUtils.WorldToTile(worldPos)
end 

function CSharpCallLuaInterface:GetBlockCount()
    return BlockCount
end
function CSharpCallLuaInterface:GetBlockSize()
    return kBlockSize
end

function CSharpCallLuaInterface.AddAfterUpdate(action)
    if SceneManager.IsInWorld() then
        local _world = CS.SceneManager.World
        if _world ~= nil then
            local _camera = _world.Camera
            if _camera ~= nil then
                _camera:AddAfterUpdateAction(action)
            end
        end
        return
    end
    local camera = DataCenter.BattleLevel:GetCamera()
    if camera then
        camera:AddAfterUpdate(action)
    end
end

function CSharpCallLuaInterface.RemoveAfterUpdate(action)
    if SceneManager.IsInWorld() then
        local _world = CS.SceneManager.World
        if _world ~= nil then
            local _camera = _world.Camera
            if _camera ~= nil then
                _camera:DelAfterUpdateAction(action)
            end
        end
        return
    end
    local camera = DataCenter.BattleLevel:GetCamera()
    if camera then
        camera:RemoveAfterUpdate(action)
    end
end

local function GetTargetServerIdAndPort(serverId)
    return CrossServerUtil.GetTargetServerIdAndPort(serverId)
end

local function GetAllProxy()
    return CommonUtil.GetAllProxy()
end

local function GetFightAllianceId()
    return DataCenter.AllianceCompeteDataManager:GetFightAllianceId()
end

local function GetIsUseNetRaw()
    return true
end

--local function GetWorldMainPos()
    --return LuaEntry.Player:GetMainWorldPos()
--end

--local function WorldMarchUpdateHandle(message)
    --DataCenter.WorldMarchDataManager:WorldMarchUpdateHandle(message)
--end

local function WorldMarchBattleUpdateHandle(message)
    DataCenter.WorldMarchDataManager:WorldMarchBattleUpdateHandle(message)
end

local function WorldMarchBattleUpdateBytesHandle(message)
    --DataCenter.WorldMarchDataManager:WorldMarchBattleUpdateBytesHandle(message)
end
local function WorldMarchDelHandle(message)
    DataCenter.WorldMarchDataManager:WorldMarchDelHandle(message)
end

local function WorldMarchTargetMineDataUpdate(needRefreshList,needRemoveList)
	DataCenter.WorldMarchDataManager:WorldMarchTargetMineDataUpdate(needRefreshList,needRemoveList)
end

local function WorldMarchGetReq()
    DataCenter.WorldMarchDataManager:SendRequest()
end

local function GetShowObjectModelParam()
    return DataCenter.CollectResourceManager:GetShowObjectModelParam()
end

local function GetResourceTypeByBuildId(buildId)
    return DataCenter.BuildManager:GetResourceTypeByBuildId(buildId)
end

local function GetCollectRangeInfoByIndex(index)
    return DataCenter.CollectResourceManager:GetCollectRangeInfoByIndex(index)
end

local function GetLodTemplates(lodType)	
    local ret = DataCenter.WorldLodManager:GetTemplatesByType(lodType)
	
	--print ("GetLodTemplates : nil! lodType :", lodType, ", count:", #ret)
	
	return ret
end

local function GetAllLodTemplates()
    return DataCenter.WorldLodManager:GetAllTemplates()
end

local function GetDomeRange()
    return DataCenter.BuildManager:GetDomeRange()
end

local function GetShowRoadDataByPointId(pointId)
    return DataCenter.BoardManager:GetShowRoadDataByPointId(pointId)
end

local function GetAllPathRoadData()--获取所有寻路道路信息
    return DataCenter.BoardManager:GetAllPathRoadData()
end

local function GetPathRoadData(pointId)--获取寻路道路信息
    return DataCenter.BoardManager:GetPathRoadData(pointId)
end

local function GetOnMovingBuildUuid()
    return DataCenter.BuildManager:GetOnMovingBuildUuid()
end

local function HideSunshine()
    DataCenter.BattleLevel:GetEnvironment():HideAllSunShine()
end

local function GetTargetServerIdAndPort(serverId)
    return CrossServerUtil.GetTargetServerIdAndPort(serverId)
end

local function GetAllProxy()
    return CommonUtil.GetAllProxy()
end

local function GetFightAllianceId()
    return DataCenter.AllianceCompeteDataManager:GetFightAllianceId()
end

local function GetWorldMainPos()
    return LuaEntry.Player:GetMainWorldPos()
end

local function WorldMarchUpdateHandle(message)
    DataCenter.WorldMarchDataManager:WorldMarchUpdateHandle(message)
end

local function WorldMarchDelHandle(message)
    DataCenter.WorldMarchDataManager:WorldMarchDelHandle(message)
end

local function WorldMarchGetReq()
    DataCenter.WorldMarchDataManager:SendRequest()
end

local function GetShowObjectModelParam()
    return DataCenter.CollectResourceManager:GetShowObjectModelParam()
end

local function GetResourceTypeByBuildId(buildId)
    return DataCenter.BuildManager:GetResourceTypeByBuildId(buildId)
end

local function GetCollectRangeInfoByIndex(index)
    return DataCenter.CollectResourceManager:GetCollectRangeInfoByIndex(index)
end

CSharpCallLuaInterface.GetLuaStringTable = GetLuaStringTable


CSharpCallLuaInterface.ToggleCityCheat = ToggleCityCheat

local function ShowSunshine()
	DataCenter.BattleLevel:GetEnvironment():ShowAllSunShine()
end

local function UnloadRunnerBundle()
    local runnerRequest = AppStartupLoading:GetInstance().runnerRequest
    if runnerRequest ~= nil then
        Logger.Log('#Runner# UnloadRunnerBundle success!')
        runnerRequest:Destroy(true)
    end
end

local function BackFromRunner()
    SceneManager.Toggle_uSkyPro(true)
    --CS.UnityEngine.Camera.main.gameObject:SetActive(true)
    --DataCenter.BattleLevel:GetCamera():SetEnable(true)
    local param = {}
    param.pveEntrance = PveEntrance.Test
    param.levelId = tonumber(LevelId.Main)
    param.isStart = false
    SceneManager.ChangeToLevel(param)
    --local param = {}
    --param["video"] = "story01_bl.mp4"
    --UIManager:GetInstance():OpenWindow(UIWindowNames.UI_VideoPlayer, OpenWinAnimFalse, param)
end

local function GetBlackDesertDecSpeed()
    return DataCenter.BirthPointTemplateManager:GetBlackLandSpeedByServerId(LuaEntry.Player:GetCurServerId())
end

local function GetCreateBulletMaxCount()
    return 80
end

local function GetCanShowBlackLand()
    --现在都是美术直接挂到scene_world预制体中了 不用再调用cs动态创建
    do
        return false
    end
    
    if CommonUtil.IsInDragonActivity() then
        return false
    end
    
    return true
end

local function IncreaseEventRef(eventId)
    if eventId ~= nil then
        EventManager:GetInstance():IncreaseCSRef(eventId)
    end
end

local function DecreaseEventRef(eventId)
    if eventId ~= nil then
        EventManager:GetInstance():DecreaseCSRef(eventId)
    end
end

local function ClearEventRef(eventId)
    if eventId ~= nil then
        EventManager:GetInstance():ClearCSRef()
    end
end

local function MarchErrorLog()

end

local function GetWorldBuildTileIndex(buildId,index)
    return WorldBuildUtil.GetBuildTileIndex(buildId,index)
end

local function IsCanPutDownByWorldBuild(buildId,index,buildUuid,noPutPoint)
    return WorldBuildUtil.IsCanPutDownByBuildWorld(buildId,index,buildUuid,noPutPoint)
end

local function CheckIsInWorldBuildRange(Ax,Ay,Bx,By,tile)
    return WorldBuildUtil.CheckIsInBuildRange(Ax,Ay,Bx,By,tile)
end

local function GetWorldBuildMainVecByModelCenter(centerIndex,tile)
    return WorldBuildUtil.GetWorldBuildModelCenterVec(centerIndex,tile)
end

local function GetWorldBuildModelCenterVec(mainIndex,tile)
    return WorldBuildUtil.GetWorldBuildModelCenterVec(mainIndex,tile)
end

local function IsNight()
	return false
end

local function IsUseNewAlarmFunction()
	return LuaEntry.DataConfig:CheckSwitch("red_battle_tip_optimized")
end

local function StartUpWorldPoint()
    DataCenter.WorldPointManager:StartUp()
    SceneManager.World:GetStaticMgr():StartUp()
end
local function CloseWorldPoint()
    DataCenter.WorldPointManager:Close()
    SceneManager.World:GetStaticMgr():Close()
    DataCenter.AllianceTeamAssembleManager:ClearAll()
end

local function StartMarchInit()
    DataCenter.AllianceTeamAssembleManager:StartUp()
    DataCenter.WorldMarchDataManager:StartUp()
    WorldTroopLineManager:GetInstance():StartUp()
    WorldTroopManager:GetInstance():StartUp()
    DataCenter.WorldMarchBattleManager:StartUp()
end
local function StartViewRequest()
    DataCenter.WorldPointManager:StartViewRequest()
    DataCenter.WorldPointManager:UpdateViewRequest(true)
end
local function ForceRequestPoint()
    DataCenter.WorldPointManager:UpdateViewRequest(true)
end

function CSharpCallLuaInterface.GetPointInfo(pointIndex)
    if DataCenter.WorldPointManager and DataCenter.WorldPointManager.GetPointInfo then
        return DataCenter.WorldPointManager:GetPointInfo(pointIndex)
    end
    return nil
end

local function IsUseLuaWorldPoint()
    CommonUtil.SetIsUseLuaWorldPoint(true)
    return CommonUtil.IsUseLuaWorldPoint()
end
local function CloseMarch()
    WorldTroopLineManager:GetInstance():Close()
    WorldTroopManager:GetInstance():Close()
    DataCenter.WorldMarchDataManager:Close()
    DataCenter.WorldMarchBattleManager:Close()
    AllianceBuildBloodManager:GetInstance():Close()
end
--通过运兵车皮肤id获取模型（3个特效）名字
local function GetMarchSkinNameBySkinId(skinId)
    --便于以后拓展，把uuid传进来
    local prefabName = MarchPrefabDefaultNameSelf
    local pdName = MarchEffectDefaultPD
    local pkName = MarchEffectDefaultPK
    local hitName = MarchEffectDefaultHit
    local height = MarchEffectDefaultHeight
    local prefabNameAlliance = MarchPrefabDefaultNameAlliance
    local prefabNameCamp = MarchPrefabDefaultNameCamp
    local prefabNameOther = MarchPrefabDefaultNameOther
    local pdNum = 1
    local pdDelay = 0
    local attackSoundEffect = {SoundAssets.Music_Effect_Attack}
    if skinId ~= 0 then
        local template = DataCenter.DecorationTemplateManager:GetTemplate(skinId)
        if template ~= nil then
            prefabName = template:GetMarchPrefabName(MarchPrefabType.Self)
            pdName = template:GetMarchEffectPD()
            pkName = template:GetMarchEffectPK()
            hitName = template:GetMarchEffectHit()
            height = template:GetMarchEffectHeight()
            prefabNameAlliance = template:GetMarchPrefabName(MarchPrefabType.Alliance)
            prefabNameCamp = template:GetMarchPrefabName(MarchPrefabType.Camp)
            prefabNameOther = template:GetMarchPrefabName(MarchPrefabType.Other)
            pdNum = template:GetMarchPdNum()
            pdDelay = template:GetMarchPdDelay()
            attackSoundEffect = template:GetSoundEffect()
        end
    end

    local result = {}
    result.prefabName = string.format(UIAssets.March, prefabName)
    result.pdName = string.format(UIAssets.March, pdName)
    result.pkName = string.format(UIAssets.March, pkName)
    result.hitName = string.format(UIAssets.March, hitName)
    result.height = height
    result.prefabNameAlliance = string.format(UIAssets.March, prefabNameAlliance)
    result.prefabNameCamp = string.format(UIAssets.March, prefabNameCamp)
    result.prefabNameOther = string.format(UIAssets.March, prefabNameOther)
    result.pdNum = pdNum
    result.pdDelay = pdDelay
    result.attackSoundEffect = attackSoundEffect
    return result
end

local function CheckIfIsMainUIOpenOnly()
    return UIManager:GetInstance():CheckIfIsMainUIOpenOnly(true)
end

local function IsTileWalkable(x, y)
	local t = {}
	t.x = x
	t.y = y
	return SceneManager.World:GetStaticMgr():IsTileWalkable(t)
end


local function OnGotoSpecialWorld()
    local worldId = 0
    local serverId = 0
    local crossBuildData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.WORM_HOLE_CROSS)
    if crossBuildData~=nil then
        worldId = crossBuildData.worldId
        serverId = crossBuildData.server
        local pointId = crossBuildData.pointId
        local position = SceneUtils.TileIndexToWorld(pointId, ForceChangeScene.World)
        position.x = position.x - 1
        position.z = position.z - 1
        SceneManager.World:Lookat(position)
        CrossServerUtil.OnCrossServer(serverId,worldId,ServerType.DRAGON_BATTLE_FIGHT_SERVER)
    end
end

CSharpCallLuaInterface.OnGotoSpecialWorld = OnGotoSpecialWorld
CSharpCallLuaInterface.GetMarchSkinNameBySkinId = GetMarchSkinNameBySkinId
CSharpCallLuaInterface.CloseMarch = CloseMarch
CSharpCallLuaInterface.CloseWorldPoint = CloseWorldPoint
CSharpCallLuaInterface.IsUseLuaWorldPoint = IsUseLuaWorldPoint
CSharpCallLuaInterface.StartViewRequest = StartViewRequest
CSharpCallLuaInterface.ForceRequestPoint = ForceRequestPoint

CSharpCallLuaInterface.StartUpWorldPoint = StartUpWorldPoint
CSharpCallLuaInterface.StartMarchInit = StartMarchInit

CSharpCallLuaInterface.IncreaseEventRef = IncreaseEventRef
CSharpCallLuaInterface.DecreaseEventRef = DecreaseEventRef
CSharpCallLuaInterface.ClearEventRef = ClearEventRef

CSharpCallLuaInterface.UnloadRunnerBundle = UnloadRunnerBundle
CSharpCallLuaInterface.BackFromRunner = BackFromRunner

CSharpCallLuaInterface.GetLuaStringTable = GetLuaStringTable

CSharpCallLuaInterface.HideSunshine = HideSunshine

CSharpCallLuaInterface.ShowSunshine = ShowSunshine
--CSharpCallLuaInterface.ToggleCityCheat = ToggleCityCheat
CSharpCallLuaInterface.IsCityCheatOk = IsCityCheatOk

CSharpCallLuaInterface.GetDataTableCount = GetDataTableCount
CSharpCallLuaInterface.GetTemplateData = GetTemplateData
CSharpCallLuaInterface.GetWorldPointTileSize = GetWorldPointTileSize
CSharpCallLuaInterface.GetAllianceColorList = GetAllianceColorList
CSharpCallLuaInterface.GetAllianceCityList = GetAllianceCityList
CSharpCallLuaInterface.GetBoardData = GetBoardData
CSharpCallLuaInterface.GetBoardDataByPointId = GetBoardDataByPointId
CSharpCallLuaInterface.IsTruckRoad = IsTruckRoad
CSharpCallLuaInterface.IsRoad = IsRoad
CSharpCallLuaInterface.GetBuildMaxRadius = GetBuildMaxRadius
CSharpCallLuaInterface.GetOtherLimitRadius = GetOtherLimitRadius
CSharpCallLuaInterface.GetRoadBuildTime = GetRoadBuildTime
CSharpCallLuaInterface.GetAllRoadData = GetAllRoadData
CSharpCallLuaInterface.ResetBoard = ResetBoard 
CSharpCallLuaInterface.GetDirByPos = GetDirByPos
CSharpCallLuaInterface.GetIsAllianceCityOpen= GetIsAllianceCityOpen
CSharpCallLuaInterface.GetWorldPointModelPath =  GetWorldPointModelPath
CSharpCallLuaInterface.SendFindMainBuildInitPositionMessage =  SendFindMainBuildInitPositionMessage
CSharpCallLuaInterface.InitRoadData =  InitRoadData
CSharpCallLuaInterface.GetAllianceCitySimpleDataByPointInfo =GetAllianceCitySimpleDataByPointInfo
CSharpCallLuaInterface.GetAllianceCityIdByPointInfo = GetAllianceCityIdByPointInfo
CSharpCallLuaInterface.CheckSwitch = CheckSwitch
CSharpCallLuaInterface.GetConfigNum = GetConfigNum
CSharpCallLuaInterface.GetConfigStr = GetConfigStr
CSharpCallLuaInterface.GetResourceNameByType = GetResourceNameByType
CSharpCallLuaInterface.GetTrainingTypeAndBuildingType = GetTrainingTypeAndBuildingType
CSharpCallLuaInterface.GetMainPos = GetMainPos
CSharpCallLuaInterface.GetAllianceBuildTileIndex = GetAllianceBuildTileIndex
CSharpCallLuaInterface.GetBuildTileIndex= GetBuildTileIndex
CSharpCallLuaInterface.IsCanPutDownByBuild = IsCanPutDownByBuild
CSharpCallLuaInterface.IsCanPutDownByAllianceBuild = IsCanPutDownByAllianceBuild
CSharpCallLuaInterface.IsCanShowCollectGreenByPoint = IsCanShowCollectGreenByPoint
CSharpCallLuaInterface.IsInMyBaseInsideRange = IsInMyBaseInsideRange
CSharpCallLuaInterface.GetOutermostIndexByIndex= GetOutermostIndexByIndex
CSharpCallLuaInterface.GetBuildModelCenter =GetBuildModelCenter
CSharpCallLuaInterface.GetBuildModelCenterVec= GetBuildModelCenterVec
CSharpCallLuaInterface.GetCollectMaxEffectByBuildId =GetCollectMaxEffectByBuildId
CSharpCallLuaInterface.SetIsInCity = SetIsInCity
CSharpCallLuaInterface.CheckIsInBuildRange =CheckIsInBuildRange
CSharpCallLuaInterface.IsCollectRangePoint =IsCollectRangePoint
CSharpCallLuaInterface.GetCollectRangePoint =GetCollectRangePoint
CSharpCallLuaInterface.OnPointDownMarch = OnPointDownMarch
CSharpCallLuaInterface.OnPointUpMarch = OnPointUpMarch
CSharpCallLuaInterface.OnBeginDragMarch =OnBeginDragMarch
CSharpCallLuaInterface.InitCityPointData = InitCityPointData
CSharpCallLuaInterface.GetAllCityPointData = GetAllCityPointData
CSharpCallLuaInterface.GetCityPointDataByPointId = GetCityPointDataByPointId
CSharpCallLuaInterface.RemoveCityPointDataByPointId = RemoveCityPointDataByPointId
CSharpCallLuaInterface.RemoveCityPointDataByUuid = RemoveCityPointDataByUuid
CSharpCallLuaInterface.GetCityPointType = GetCityPointType
CSharpCallLuaInterface.GetCityPointSize = GetCityPointSize
CSharpCallLuaInterface.GetMainLv =GetMainLv
CSharpCallLuaInterface.CheckReplaceMain =CheckReplaceMain
CSharpCallLuaInterface.SetMainPos =SetMainPos
CSharpCallLuaInterface.UpdateBuildings =UpdateBuildings
CSharpCallLuaInterface.GetAllLuaBuildWithoutFoldUp =GetAllLuaBuildWithoutFoldUp
CSharpCallLuaInterface.GetBuildingDataByUuid =GetBuildingDataByUuid
CSharpCallLuaInterface.GetResourcePercent = GetResourcePercent
CSharpCallLuaInterface.GetBuildCollectSpeed = GetBuildCollectSpeed
CSharpCallLuaInterface.GetBuildCollectMaxSelf = GetBuildCollectMaxSelf
CSharpCallLuaInterface.GetBuildCollectMaxOther = GetBuildCollectMaxOther
CSharpCallLuaInterface.GetShowBubblePercent =GetShowBubblePercent
CSharpCallLuaInterface.GetBuildingDataByBuildId =GetBuildingDataByBuildId
CSharpCallLuaInterface.IsInNewUserWorld =IsInNewUserWorld
CSharpCallLuaInterface.GetBuildDataResourcePercent =GetBuildDataResourcePercent
CSharpCallLuaInterface.GetBuildStartTimeAndEndTime =GetBuildStartTimeAndEndTime
CSharpCallLuaInterface.IsBuildWork =IsBuildWork
CSharpCallLuaInterface.GetAllBuildTileByItemId =GetAllBuildTileByItemId
CSharpCallLuaInterface.GetAllInBaseTruckShowBuild =GetAllInBaseTruckShowBuild
CSharpCallLuaInterface.GetBuildingDataParamByUuid = GetBuildingDataParamByUuid
CSharpCallLuaInterface.GetBuildingDataParamByBuildId = GetBuildingDataParamByBuildId
CSharpCallLuaInterface.GetWorldBuildingModelName = GetWorldBuildingModelName
CSharpCallLuaInterface.GetAllBuildOffset = GetAllBuildOffset
CSharpCallLuaInterface.GetLodArray = GetLodArray
CSharpCallLuaInterface.IsCanShowBuildBtn = IsCanShowBuildBtn
CSharpCallLuaInterface.CheckIsInBasementRange = CheckIsInBasementRange
CSharpCallLuaInterface.GetConfigMd5 = GetConfigMd5
CSharpCallLuaInterface.IsShowBuildFlyPath = IsShowBuildFlyPath
--CSharpCallLuaInterface.SetGuideGarbageCollectTime = SetGuideGarbageCollectTime
--CSharpCallLuaInterface.AddGuideGarbageCollectToQueue = AddGuideGarbageCollectToQueue
--CSharpCallLuaInterface.RemoveFromGarbageQueue = RemoveFromGarbageQueue
--CSharpCallLuaInterface.GetCurrentGarbageQueue = GetCurrentGarbageQueue
CSharpCallLuaInterface.GetAllianceLeaderUid = GetAllianceLeaderUid
--CSharpCallLuaInterface.IsShowPrologue = IsShowPrologue
--CSharpCallLuaInterface.IsBeforePrologue = IsBeforePrologue
CSharpCallLuaInterface.GetPointDataByUuid = GetPointDataByUuid
CSharpCallLuaInterface.GetSingleMapJunkTemplate = GetSingleMapJunkTemplate
CSharpCallLuaInterface.NewLuaObj = NewLuaObj
--CSharpCallLuaInterface.OnLoadSceneOK = OnLoadSceneOK
CSharpCallLuaInterface.OnUploadPicStart = OnUploadPicStart
CSharpCallLuaInterface.GetPlayerPic = GetPlayerPic
CSharpCallLuaInterface.GetPlayerPicVer = GetPlayerPicVer
CSharpCallLuaInterface.GetHeroQuality = GetHeroQuality
CSharpCallLuaInterface.GetHeroIcon =GetHeroIcon
CSharpCallLuaInterface.GetMarchStateIcon = GetMarchStateIcon
CSharpCallLuaInterface.GetLandLockDataById = GetLandLockDataById
CSharpCallLuaInterface.GetLandLockDataByPointId = GetLandLockDataByPointId
CSharpCallLuaInterface.GetLandLockDataListByState = GetLandLockDataListByState
CSharpCallLuaInterface.CanShowLandLock = CanShowLandLock
CSharpCallLuaInterface.ClickLandLockById = ClickLandLockById
CSharpCallLuaInterface.LandLockTimeLineFinish = LandLockTimeLineFinish
CSharpCallLuaInterface.GetBuffPerformanceInfo = GetBuffPerformanceInfo
CSharpCallLuaInterface.CanShowCityLabel = CanShowCityLabel
CSharpCallLuaInterface.GetMonsterLockDataList = GetMonsterLockDataList
CSharpCallLuaInterface.ClickMonsterLockById = ClickMonsterLockById
CSharpCallLuaInterface.GetBuildQueueState = GetBuildQueueState
CSharpCallLuaInterface.IsShowWorldCollectPoint = IsShowWorldCollectPoint
CSharpCallLuaInterface.SendErrorMessageToServer = SendErrorMessageToServer
CSharpCallLuaInterface.MarchErrorLog = MarchErrorLog

-- loading相关
CSharpCallLuaInterface.LoadingInit = LoadingInit
CSharpCallLuaInterface.LoadingStart = LoadingStart
CSharpCallLuaInterface.LoadingDestroy = LoadingDestroy
CSharpCallLuaInterface.IsLoading = IsLoading

----###########---- Survivor begin ----###########----
CSharpCallLuaInterface.CreateSurvivorScene = CreateSurvivorScene
CSharpCallLuaInterface.IsSurvivorMode = IsSurvivorMode
----###########---- Survivor end ----###########----
CSharpCallLuaInterface.GetTargetServerIdAndPort = GetTargetServerIdAndPort
CSharpCallLuaInterface.GetAllProxy =GetAllProxy
CSharpCallLuaInterface.GetFightAllianceId = GetFightAllianceId
CSharpCallLuaInterface.ClickOtherLandLockById = ClickOtherLandLockById
CSharpCallLuaInterface.ClickSelfLandLock = ClickSelfLandLock
CSharpCallLuaInterface.GetIsUseNetRaw = GetIsUseNetRaw
CSharpCallLuaInterface.GetWorldMainPos =GetWorldMainPos
CSharpCallLuaInterface.WorldMarchUpdateHandle =WorldMarchUpdateHandle
CSharpCallLuaInterface.WorldMarchDelHandle = WorldMarchDelHandle
CSharpCallLuaInterface.WorldMarchTargetMineDataUpdate = WorldMarchTargetMineDataUpdate
CSharpCallLuaInterface.WorldMarchGetReq = WorldMarchGetReq
CSharpCallLuaInterface.GetShowObjectModelParam = GetShowObjectModelParam
CSharpCallLuaInterface.GetResourceTypeByBuildId = GetResourceTypeByBuildId
CSharpCallLuaInterface.GetCollectRangeInfoByIndex = GetCollectRangeInfoByIndex
CSharpCallLuaInterface.GetLodTemplates = GetLodTemplates
CSharpCallLuaInterface.GetAllLodTemplates = GetAllLodTemplates
CSharpCallLuaInterface.CanMoveBuild = CanMoveBuild
CSharpCallLuaInterface.GetDomeRange = GetDomeRange
CSharpCallLuaInterface.GetShowRoadDataByPointId = GetShowRoadDataByPointId
CSharpCallLuaInterface.GetAllShowRoadData = GetAllShowRoadData
CSharpCallLuaInterface.GetAllPathRoadData = GetAllPathRoadData
CSharpCallLuaInterface.GetPathRoadData = GetPathRoadData
CSharpCallLuaInterface.GetNextChangeTimeByResourceUuid = GetNextChangeTimeByResourceUuid
CSharpCallLuaInterface.GetOnMovingBuildUuid =GetOnMovingBuildUuid
CSharpCallLuaInterface.GetCityLodArray =GetCityLodArray
CSharpCallLuaInterface.GetBlackDesertDecSpeed  = GetBlackDesertDecSpeed
CSharpCallLuaInterface.GetCreateBulletMaxCount = GetCreateBulletMaxCount
CSharpCallLuaInterface.GetBuildMainVecByModelCenter =GetBuildMainVecByModelCenter
CSharpCallLuaInterface.GetCanShowBlackLand = GetCanShowBlackLand
CSharpCallLuaInterface.WorldMarchBattleUpdateHandle = WorldMarchBattleUpdateHandle
CSharpCallLuaInterface.WorldMarchBattleUpdateBytesHandle = WorldMarchBattleUpdateBytesHandle

CSharpCallLuaInterface.GetWorldBuildTileIndex = GetWorldBuildTileIndex
CSharpCallLuaInterface.IsCanPutDownByWorldBuild = IsCanPutDownByWorldBuild
CSharpCallLuaInterface.CheckIsInWorldBuildRange = CheckIsInWorldBuildRange
CSharpCallLuaInterface.GetWorldBuildMainVecByModelCenter = GetWorldBuildMainVecByModelCenter
CSharpCallLuaInterface.GetWorldBuildModelCenterVec = GetWorldBuildModelCenterVec
CSharpCallLuaInterface.IsNight = IsNight

CSharpCallLuaInterface.IsUseNewAlarmFunction = IsUseNewAlarmFunction
CSharpCallLuaInterface.CheckIfIsMainUIOpenOnly = CheckIfIsMainUIOpenOnly

CSharpCallLuaInterface.GetTouchPickablePos = GetTouchPickablePos
CSharpCallLuaInterface.SetTouchPickablePos = SetTouchPickablePos

CSharpCallLuaInterface.IsTileWalkable = IsTileWalkable

return ConstClass("CSharpCallLuaInterface", CSharpCallLuaInterface)