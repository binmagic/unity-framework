---
--- Created by shimin.
--- DateTime: 2021/8/18 10:52
---
---@class GuideManager
local GuideManager = BaseClass("GuideManager")
local Data = CS.GameEntry.Data
local ResourceManager = CS.GameEntry.Resource

local WaitLoadTime = 0.5
--local CheckJumpState = require "DataCenter.GuideManager.Guide_CheckJumpState"
--local Const = require("Scene.PVEBattleLevel.Const")
--local GuideItem = require "DataCenter.GuideManager.GuideItem"
--local GuideDelayItem = require "DataCenter.GuideManager.GuideDelayItem"
local UseTableItem = true

local function __init(self)
    -- 连连看简化流程：引导逻辑存根，保留字段避免外层访问报错
    self.guideId = nil
    self.template = nil
    self.hasDoneGuide = {}
    self.allTriggerGuide = {}
    self.waitingMessage = {}
    self.isNoOpenUI = false
    self.isDebug = false
    self.effectSound = {}
    self.pveTrigger = {}
    self.specialTriggerGuide = {}
    self.waitTrigger = {}
    self.showUIArr = {}
    self.showPlantarArrow = true
    self.curWaitGuideId = -1
    self.curWaitGuideTime = 0
    self.isInitEnd = false
    -- 不调用 self:AddListener()（EventId 在本项目不存在）
    -- 不访问 GuideCanDoType / PositionType / SuccessMarchFlagType 等已注释枚举
    -- 不访问 LuaEntry.DataConfig / UITimeManager / CS.CommonUtils

    --[[  原引导初始化逻辑，连连看项目暂不需要
    GuideStartId = LuaEntry.DataConfig:TryGetNum("firstNovicebootID", "k1")
    --local nvjingcha_Path = "Assets/Main/Prefabs/Girls/Hero_nvjingcha_talk.prefab"
    --local nanzhu_Path = "Assets/Main/Prefabs/Girls/Hero_nanzhu_show_talk.prefab"
    --local tunvlang_Path = "Assets/Main/Prefabs/Girls/Hero_tunvlang_talk.prefab"
    --local hushi_Path = "Assets/Main/Prefabs/Girls/Hero_hushi_talk.prefab"
    --DataCenter.PreloadModelManager:Preload({nvjingcha_Path, nanzhu_Path, tunvlang_Path, hushi_Path})
    --DataCenter.PreloadModelManager:Preload({nvjingcha_Path, nanzhu_Path})
	--DataCenter.PreloadModelManager:Preload({nanzhu_Path})

    self.guideId = nil--正在进行的引导id  为nil表示没做过新手，设置新手开始id，为 -1表示引导结束
    self.template = nil --当前引导template
    self.hasDoneGuide = {}--已经做过的触发引导
    self.allTriggerGuide = {}--需要触发的引导 <触发类型,<任务id,引导id>>

    self.waitUIView = nil--需要等待的页面加载完成
    self.waitUIBtn = nil--需要等待的页面控件加载完成
    --self.checkJumpState = CheckJumpState.New()

    self.obj = nil
    self.objWorldPos = nil
    self.needParam = nil --判断引导完成需要的参数 建造代表建筑id

    self.waitingMessage = {}

    self.isNoOpenUI = false
    self.guideState = GuideCanDoType.Yes
    self.objPositionType = PositionType.Screen
    self.auto_next_timer_action = function(temp)
        self:AutoNextTimeCallBack()
    end
    self.wait_load_timer_action = function(temp)
        self:WaitLoadCallBack()
    end
    self.wait_time_timer_action = function(temp)
        self:WaitTimeCallBack()
    end
    self.tips_wait_time_timer_action = function(temp)
        self:TipsWaitTimeCallBack()
    end
    --self.wait_long_delay_timer_callback = function(temp)
        --self:WaitLongDelayTimerCallBack()
    --end

    self.guideEndCallBack = nil
    self.midCallBackId = nil
    self.midCallBack = nil
    self.dubName = nil
    self.dubId = nil
    self.noGotoTime = false
    self:AddListener()
    self.isDebug = CS.CommonUtils.IsDebug() and CS.UnityEngine.Application.isEditor
    self.currentGetRewardGarbage = nil
    self.effectSound = {}
    self.fakeQuest = nil-- 假的任务，最多一个
    self.pveTrigger = {}
    self.specialTriggerGuide = {}
    self.successMarchFlag = SuccessMarchFlagType.No
    self.requestGm = nil
    self.waitTrigger = {}--等待回到主城/所有页面关闭后触发
    self.LastZoom = 2
    self.showUIArr = {}
    self.showPlantarArrow = true
    self.lastTriggerTime = UITimeManager:GetInstance():GetServerTime()

	-- 当前等待的任务id及初始等待时间
	self.curWaitGuideId = -1
	self.curWaitGuideTime = 0
    self.isInitEnd = false
    ]]
end

local function __delete(self)
    self.guideId = nil
    self.template = nil
    self.hasDoneGuide = nil
    self.allTriggerGuide = nil
    self.waitingMessage = nil
    self.isNoOpenUI = nil
    self.effectSound = nil
    self.pveTrigger = nil
    self.specialTriggerGuide = nil
    self.waitTrigger = nil
    self.guideBoxBubbles = nil

    --[[  原引导销毁逻辑，连连看项目暂不需要
    self:DestroyGm()
    self:DeleteWaitLoadTimer()
	self.curWaitGuideId = -1
    self:DeleteAutoNextTimer()
    self:DeleteWaitTimeTimer()
    self:DeleteTipsWaitTimeTimer()
    self.guideId = nil
    self.template = nil
    self.hasDoneGuide = nil
    self.allTriggerGuide = nil
    self.auto_next_timer_action = nil
    self.tips_wait_time_timer_action = nil
    self.waitUIView = nil
    self.waitUIBtn = nil
    self.obj = nil
    self.objPositionType = nil
    self.needParam = nil
    self.objWorldPos = nil
    self.isNoOpenUI = nil
    self.guideState = nil
    self.waitingMessage = nil
    self.guideEndCallBack = nil
    self.midCallBackId = nil
    self.midCallBack = nil
    self.dubName = nil
    self.dubId = nil
    self:RemoveListener()
    self.isDebug = nil
    self.noGotoTime = nil
    self.effectSound = nil
    self.fakeQuest = nil
    self.pveTrigger = nil
    self.specialTriggerGuide = nil
    self.successMarchFlag = SuccessMarchFlagType.No
    self.waitTrigger = {}--等待回到主城/所有页面关闭后触发
    self.LastZoom = nil
    if self.guideBoxBubbles then
        for _,v in pairs(self.guideBoxBubbles) do
            if v then
                v:OnDestroy()
            end
        end
    end
    self.guideBoxBubbles = nil
    ]]
end

local function Startup()
end

--服务器数据初始化
local function InitData(self, data)
	self:ClearCurGuideId()
		
    EventManager:GetInstance():Broadcast(EventId.GuideTimelineMarker, GuideTimeLineShowMarkerType.End)
    local guideRecord = data["guideRecord"]
    if guideRecord ~= nil then
        for k, v in pairs(guideRecord) do
            self.hasDoneGuide[k] = v
            self:ShowLog("shimin ------------------------- guideRecord ", k, "   ", v)
        end
    else
        self:ShowLog("shimin ++++++++++++++++++++++++ guideRecord == nil")
    end
    DataCenter.GuideTemplateManager:InitAllTemplate(DataCenter.GuideManager.allTriggerGuide)
    self:InitSpecialTrigger()
    if DataCenter.BuildManager.MainLv == 0 then
        self:SetCanShowBuild(false)
    end
    
    self.initDoGuideId = self:GetSaveGuideId()
    if self.initDoGuideId == -1 then
        local rGuideId = Setting:GetPrivateString("SaveReconnectionGuideId", "")
        if rGuideId ~= "" and rGuideId ~= "-1" then
            self.initDoGuideId = tonumber(rGuideId)
        end
    end
end

local function AddListener(self)
    EventManager:GetInstance():AddListener(EventId.Guide_video_Play, self.UILoadingExitSignal)--进入场景
    EventManager:GetInstance():AddListener(EventId.BuildPlace, self.BuildPlaceSignal)--放置建筑
    EventManager:GetInstance():AddListener(EventId.OpenUI, self.OpenUISignal)--打开UI
    EventManager:GetInstance():AddListener(EventId.QUEUE_TIME_END, self.QueueTimeEndSignal)--队列完成
    EventManager:GetInstance():AddListener(EventId.Queue_Add, self.QueueAddSignal)--新获得队列
    EventManager:GetInstance():AddListener(EventId.OnClickWorld, self.OnClickWorldSignal)--点击世界
    --EventManager:GetInstance():AddListener(EventId.CityGarbageResult, self.CityGarbageResultSignal)--捡垃圾返回结果
    EventManager:GetInstance():AddListener(EventId.OpenFogSuccess, self.OpenFogSuccessSignal)--解锁迷雾
    EventManager:GetInstance():AddListener(EventId.BuildUpgradeFinish, self.BuildUpgradeFinishSignal)--升级完成建筑
    EventManager:GetInstance():AddListener(EventId.ChapterTaskGetReward, self.ChapterTaskGetRewardSignal)--更新章节任务信息
    EventManager:GetInstance():AddListener(EventId.ShowAllGuideObject, self.ShowAllGuideObjectSignal)--显示所有Object
    EventManager:GetInstance():AddListener(EventId.CloseUI, self.CloseUISignal)--关闭UI
    EventManager:GetInstance():AddListener(EventId.ChapterTask, self.ChapterTaskSignal)--章节任务每个小任务成功领取奖励
    EventManager:GetInstance():AddListener(EventId.AllianceApplySuccess, self.AllianceApplySuccessSignal)--成功加入联盟
    EventManager:GetInstance():AddListener(EventId.GuideNoOpenUI, self.GuideNoOpenUISignal)--不能打开其他UI
    EventManager:GetInstance():AddListener(EventId.GuideWaitMessage, self.GuideWaitMessageSignal)--等待种鸵鸟消息
    EventManager:GetInstance():AddListener(EventId.MainTaskSuccess, self.MainTaskSuccessSignal)--刷新主线任务
    EventManager:GetInstance():AddListener(EventId.BuildResourcesStart, self.BuildResourcesStartSignal)--农田种植
    EventManager:GetInstance():AddListener(EventId.OnWorldInputPointDown, self.OnWorldInputPointDownSignal)--点击
    EventManager:GetInstance():AddListener(EventId.TrainingArmy, self.TrainingArmySignal)--
    --EventManager:GetInstance():AddListener(EventId.BuildLackConnect, self.BuildLackConnectSignal)
    EventManager:GetInstance():AddListener(EventId.UPDATE_SCIENCE_DATA, self.UpdateScienceDataSignal)
    EventManager:GetInstance():AddListener(EventId.HospitalUpdate, self.HospitalUpdateSignal)--伤兵
    EventManager:GetInstance():AddListener(EventId.OnScienceQueueResearch, self.OnScienceQueueResearchSignal)--研究科技
    EventManager:GetInstance():AddListener(EventId.StartAttackMonsterWithoutMsgTip, self.StartAttackMonsterWithoutMsgTipSignal)--是否成功出征
    EventManager:GetInstance():AddListener(EventId.UpdateAlCanBeLeader, self.UpdateAlCanBeLeaderSignal)--是否能成为盟主
    EventManager:GetInstance():AddListener(EventId.GarbageCollectStart, self.GarbageCollectStartSignal)--咕噜行军到达
    EventManager:GetInstance():AddListener(EventId.GF_pve_battle_exit, self.OnPVEBattleWinExit)
    EventManager:GetInstance():AddListener(EventId.GF_parkour_battle_win, self.OnPVEBattleWin)
    EventManager:GetInstance():AddListener(EventId.GF_guide_rallybossact, self.OnGoRallyBossAct)
    EventManager:GetInstance():AddListener(EventId.GF_guide_fastcombat, self.OnFastCombatTriggered)
    EventManager:GetInstance():AddListener(EventId.GarbageTriggerFinish, self.OnGarbageTriggerFinished)
    EventManager:GetInstance():AddListener(EventId.Barrel_OnTrailLevelMemberDie, self.OnTrailLevelMemberDie)
    EventManager:GetInstance():AddListener(EventId.GF_parkour_battle_start, self.CheckParkourBattleStart)
    EventManager:GetInstance():AddListener(EventId.Exit_From_Arena, self.OnExitFromArena)
end

local function RemoveListener(self)
    EventManager:GetInstance():RemoveListener(EventId.Guide_video_Play, self.UILoadingExitSignal)--进入场景
    EventManager:GetInstance():RemoveListener(EventId.BuildPlace, self.BuildPlaceSignal)--放置建筑
    EventManager:GetInstance():RemoveListener(EventId.OpenUI, self.OpenUISignal)--打开UI
    EventManager:GetInstance():RemoveListener(EventId.QUEUE_TIME_END, self.QueueTimeEndSignal)--队列完成
    EventManager:GetInstance():RemoveListener(EventId.Queue_Add, self.QueueAddSignal)--新获得队列
    EventManager:GetInstance():RemoveListener(EventId.OnClickWorld, self.OnClickWorldSignal)--点击世界
--    EventManager:GetInstance():RemoveListener(EventId.CityGarbageResult, self.CityGarbageResultSignal)--捡垃圾返回结果
    EventManager:GetInstance():RemoveListener(EventId.OpenFogSuccess, self.OpenFogSuccessSignal)--解锁迷雾
    EventManager:GetInstance():RemoveListener(EventId.BuildUpgradeFinish, self.BuildUpgradeFinishSignal)--升级完成建筑
    EventManager:GetInstance():RemoveListener(EventId.ChapterTaskGetReward, self.ChapterTaskGetRewardSignal)--更新章节任务信息
    EventManager:GetInstance():RemoveListener(EventId.ShowAllGuideObject, self.ShowAllGuideObjectSignal)--显示所有Object
    EventManager:GetInstance():RemoveListener(EventId.CloseUI, self.CloseUISignal)--关闭UI
    EventManager:GetInstance():RemoveListener(EventId.ChapterTask, self.ChapterTaskSignal)--章节任务每个小任务成功领取奖励
    EventManager:GetInstance():RemoveListener(EventId.AllianceApplySuccess, self.AllianceApplySuccessSignal)--成功加入联盟
    EventManager:GetInstance():RemoveListener(EventId.GuideNoOpenUI, self.GuideNoOpenUISignal)--不能打开其他UI
    EventManager:GetInstance():RemoveListener(EventId.GuideWaitMessage, self.GuideWaitMessageSignal)--等待种鸵鸟消息
    EventManager:GetInstance():RemoveListener(EventId.MainTaskSuccess, self.MainTaskSuccessSignal)--刷新主线任务
    EventManager:GetInstance():RemoveListener(EventId.BuildResourcesStart, self.BuildResourcesStartSignal)--农田种植
    EventManager:GetInstance():RemoveListener(EventId.OnWorldInputPointDown, self.OnWorldInputPointDownSignal)--点击
    EventManager:GetInstance():RemoveListener(EventId.TrainingArmy, self.TrainingArmySignal)--
    --EventManager:GetInstance():RemoveListener(EventId.BuildLackConnect, self.BuildLackConnectSignal)
    EventManager:GetInstance():RemoveListener(EventId.UPDATE_SCIENCE_DATA, self.UpdateScienceDataSignal)
    EventManager:GetInstance():RemoveListener(EventId.HospitalUpdate, self.HospitalUpdateSignal)--伤兵
    EventManager:GetInstance():RemoveListener(EventId.OnScienceQueueResearch, self.OnScienceQueueResearchSignal)--研究科技
    EventManager:GetInstance():RemoveListener(EventId.StartAttackMonsterWithoutMsgTip, self.StartAttackMonsterWithoutMsgTipSignal)--是否成功出征
    EventManager:GetInstance():RemoveListener(EventId.UpdateAlCanBeLeader, self.UpdateAlCanBeLeaderSignal)--是否能成为盟主
    EventManager:GetInstance():RemoveListener(EventId.GarbageCollectStart, self.GarbageCollectStartSignal)--咕噜行军到达
    EventManager:GetInstance():RemoveListener(EventId.GF_pve_battle_exit, self.OnPVEBattleWinExit)
    EventManager:GetInstance():RemoveListener(EventId.GF_parkour_battle_win, self.OnPVEBattleWin)
    EventManager:GetInstance():RemoveListener(EventId.GF_guide_rallybossact, self.OnGoRallyBossAct)
    EventManager:GetInstance():RemoveListener(EventId.GF_guide_fastcombat, self.OnFastCombatTriggered)
    EventManager:GetInstance():RemoveListener(EventId.GarbageTriggerFinish, self.OnGarbageTriggerFinished)
    EventManager:GetInstance():RemoveListener(EventId.Barrel_OnTrailLevelMemberDie, self.OnTrailLevelMemberDie)
    EventManager:GetInstance():RemoveListener(EventId.GF_parkour_battle_start, self.CheckParkourBattleStart)
    EventManager:GetInstance():RemoveListener(EventId.Exit_From_Arena, self.OnExitFromArena)
end

--获取引导id
local function GetGuideId(self)
    return self.guideId
end

-- 这个函数用来清除Guide当前的状态；主要是防止游戏内重新登录导致的状态不统一
local function ClearCurGuideId(self)

	self:DeleteWaitLoadTimer()
	self.curWaitGuideId = -1

	self:DeleteAutoNextTimer()
	self:DeleteWaitTimeTimer()
	self:DeleteTipsWaitTimeTimer()
	self.guideId = nil
	self.template = nil
	
	self.externalParam = nil
	self.waitUIView = nil
	self.waitUIBtn = nil
	self.obj = nil
	self.objWorldPos = nil
	
	self.guideState = GuideCanDoType.Yes
	self.objPositionType = PositionType.Screen
	self.lastTriggerTime = UITimeManager:GetInstance():GetServerTime()
	self.needParam = nil
	
	self.noGotoTime = false
	
	self.curWaitGuideId = -1
	self.curWaitGuideTime = 0
	
	-- 这个标志表示聊天数据是否初始化完毕，因为有些逻辑要依赖聊天数据；
	-- 现在重置了就需要标记为false
    self.isInitEnd = false
end

--[[
设置引导id
]]
local function SetCurGuideId(self, id, externalParam, ignoreBrakeOff)
    -- 做一个处理,如果已经在doguide的id了,第二次直接忽略
    if self.guideId == id then
        Logger.LogError('当前引导:' .. tostring(id) .. '已经在执行了(SetCurGuideId)')
        return
    end
    PostEventLog.Record("SetGuideId:" .. tostring(id))
    if self.guideId ~= nil and self.guideId ~= GuideEndId and (id == GuideEndId or id == GuideClickEndId) then
        local str = debug.traceback();
        local newstr = "GuideStop_" .. self.guideId .. ", EndId_" .. id
        PostEventLog.Record(newstr, str)
        --print("****guideStop: " .. " 当前id: " .. self.guideId .. "msg" .. str)
    end
    -- 获取当前guideId,如果不是通过正常donext来触发的,其他情况下都需要检测一下是否可以打断
    if ignoreBrakeOff ~= true and id ~= GuideTestEndId then
        local template = DataCenter.GuideManager:GetCurTemplate()
        if template ~= nil and template:IsBrakeOff() then
            local nextTemplate = DataCenter.GuideTemplateManager:GetGuideTemplate(id)
            if nextTemplate and nextTemplate:CanStrongBrake() then
                Logger.Log('当前引导:' .. tostring(template.id) .. '被:' .. tostring(id) .. '配置强制打断')
            else
                Logger.Log('当前引导:' .. tostring(template.id) .. '不能被:' .. tostring(id) .. '打断')
                return
            end
        end
    else
        local template = DataCenter.GuideManager:GetCurTemplate()
        if template then
            if id == GuideTestEndId then
                Logger.LogError('当前引导:' .. tostring(template.id) .. '被:' .. tostring(id) .. '强制打断(引导目标没找到)')
            else
                if ignoreBrakeOff == true then
                    if externalParam == 1 then
                        Logger.Log('当前引导:' .. tostring(template.id) .. '被:' .. tostring(id) .. '逻辑(doNext)强制打断')
                    end
                    if externalParam == 2 then
                        Logger.Log('当前引导:' .. tostring(template.id) .. '被:' .. tostring(id) .. '逻辑(jump)强制打断')
                    end
                end
            end
        end
    end
    
    self:ShowLog("shimin +++++++++++++++++++++ SetCurGuideId ", id)
    --PostEventLog.Record("SetCurGuideId_" .. tostring(id))
    if id == self.initDoGuideId then
        self.initDoGuideId = GuideEndId
    end

    if self.midCallBackId ~= nil and self.midCallBack ~= nil and self.midCallBackId == id then
        self.midCallBackId = nil
        local callback = self.midCallBack
        self.midCallBack = nil
        callback()
    end

    self:DeleteWaitLoadTimer()
	self.curWaitGuideId = -1
	
    self:DeleteAutoNextTimer()
    local lastGuideId = self.guideId
    local lastTemplate = self.template
    --保存上一条savedoneid
    if self.guideState == GuideCanDoType.Yes and lastTemplate ~= nil and lastTemplate.savedoneid ~= 0 then
        if not self:IsDoneThisGuide(lastTemplate.savedoneid) then
            self:SendSaveGuideMessage(self:GetDoneGuideEndId(lastTemplate.savedoneid), SaveGuideDoneValue)
            EventManager:GetInstance():Broadcast(EventId.GuideSaveId)
        end
    end

    self.guideId = id
    self.externalParam = externalParam
    self.waitUIView = nil
    self.waitUIBtn = nil
    self.obj = nil
    self.objWorldPos = nil
    self.objPositionType = PositionType.Screen
    self.lastTriggerTime = UITimeManager:GetInstance():GetServerTime()
    self.needParam = {}
    if lastGuideId ~= nil then
        self:SendLogMessage(lastGuideId, StatTTType.Guide, id)
    end
    if lastTemplate ~= nil then
        if lastTemplate.gototime ~= "" and not self.noGotoTime then
            EventManager:GetInstance():Broadcast(EventId.GotoTime, lastTemplate.gototime)
        end
    end
    self.noGotoTime = false
    if id == GuideEndId or id == GuideTestEndId or id == GuideClickEndId then
        --DataCenter.CityNpcManager:SetFollowNpc()
        -- GuideClickEndId 不保存
        if self.guideState == GuideCanDoType.Yes and id ~= GuideClickEndId then
            self:SendSaveGuideMessage(SaveGuideId, tostring(id))
        end
        self:ShowLog("shimin +++++++++++++++++++++++ GuideEndId", id)
        self.template = nil
        self.guideState = GuideCanDoType.Yes
        self:DoGuideEndCallBack()
        EventManager:GetInstance():Broadcast(EventId.UINoInput, UINoInputType.Close)
        --self:CheckStopDub()
        EventManager:GetInstance():Broadcast(EventId.RefreshGuide)
        --if DataCenter.BattleLevel:IsInBattleLevel() then
        --    DataCenter.BattleLevel:GuideEnd()
        --end
    else
        self.template = DataCenter.GuideTemplateManager:GetGuideTemplate(id) --10006001
        if self.template ~= nil then
            self.guideState = self:GetCanDoGuideState(id)
            self:ShowLog("shimin +++++++++++++++++++ self.guideState: ", self.guideState)
            if self.guideState == GuideCanDoType.No then
                if self.template.jumpid ~= 0 then
                    self:SetCurGuideId(self.template.jumpid)
                else
                    self:SetCurGuideId(GuideEndId)
                end
            else
                if self.template.forcetype == GuideForceType.Soft and self.template.savedoneid ~= 0 then
                    if not self:IsDoneThisGuide(self.template.savedoneid) then
                        self:SendSaveGuideMessage(self:GetDoneGuideEndId(self.template.savedoneid), SaveGuideDoneValue)
                        EventManager:GetInstance():Broadcast(EventId.GuideSaveId)
                    end
                end
                if self.template.returnstepid ~= 0 and self.template.returnstepid ~= self:GetSaveGuideId() then
                    --发送消息
                    self:SendSaveGuideMessage(SaveGuideId, tostring(self.template.returnstepid))
                end
                if self.template.type == GuideType.ShowTalk then
                    --self.waitUIView = UIWindowNames.UIMain
                elseif self.template.type == GuideType.SkyTime then
                    local state = tonumber(self.template.para1)
                    self:SaveTimeOfDayState(state)
                    if DataCenter.BattleLevel and DataCenter.BattleLevel:GetSkyTime() then
                        DataCenter.BattleLevel:GetSkyTime():DoWhenUseGuideTimeOfDay(false, tonumber(self.template.para2))
                    end
                    --控制晴天/雨天 -- para3=0时，场景显示为晴天；--para3=1时，场景显示为雨天。 =-1时停止引导
                    if self.template.para3 ~= nil and self.template.para3 ~= "" then
                        local state = tonumber(self.template.para3)
                        self:SaveWeatherGuideState(state)
                        DataCenter.BattleLevel:GetSkyTime():ChangeWeatherByType(state, true)
                    end
                    self:DoNext()
                elseif (self.template.type == GuideType.ClickButton or self.template.type == GuideType.ClickButtonNew or self.template.type == GuideType.PoliceInsigniaSubPointer) and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.Screen
                    local para = string.split_ss_array(self.template.para1, "/")
                    local paraCount = table.count(para)
                    if paraCount > 0 then
                        self.waitUIView = para[1]
                        if self.waitUIView == UIWindowNames.MainUI_SU then
                            GoToUtil.CloseAllWindows()
                        end
                        local length = string.len(self.waitUIView)
                        self:ShowLog("shimin +++++++++++++++++++++++ self.waitUIView: ", self.waitUIView)
                        self.waitUIBtn = string.sub(self.template.para1, length + 2, string.len(self.template.para1))
                        if self.waitUIView == UIWindowNames.MainUI_SU and self.waitUIBtn == "safeArea/leftLayer/UIMainQuest/Advanced/RightBtn" then
                            local curIndex = DataCenter.RescueDogManager:GetCurIndex()
                            if curIndex == nil then
                                curIndex = "-"
                            end
                            local tempIndex = DataCenter.RescueDogManager:GetBigIndex()
                            if tempIndex == nil then
                                tempIndex = "-"
                            end
                            local configStr = DataCenter.RescueDogManager.configName
                            if tempIndex > 1 then
                                configStr = configStr .. "_" .. tempIndex
                            end
                            local k5 = LuaEntry.DataConfig:TryGetStr(configStr, "k5")
                            local guideDone = "-"
                            if k5 ~= "" then
                                if DataCenter.GuideManager:IsDoneThisGuide(k5) then
                                    guideDone = "yes"
                                end 
                            else
                                k5 = "-"
                            end
                            local tempPostStr = "RefreshMainQuestDog: curIndex:" .. curIndex .. ", bigIndex:" .. tempIndex .. ", configStr:" .. configStr .. ", k5:" .. k5 .. ", guideDone:" .. guideDone
                            PostEventLog.Record(tempPostStr)
                            EventManager:GetInstance():Broadcast(EventId.GuideShowDogItemAniEnd, 2)
                        end
                        self:ShowLog("shimin +++++++++++++++++++++++ self.waitUIBtn: ", self.waitUIBtn)
                    end
                elseif self.template.type == GuideType.IntroBubble and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.Screen
                    local para = string.split_ss_array(self.template.para1, "/")
                    local paraCount = table.count(para)
                    if paraCount > 0 then
                        self.waitUIView = para[1]
                        local length = string.len(self.waitUIView)
                        self.waitUIBtn = string.sub(self.template.para1, length + 2, string.len(self.template.para1))
                    end
                elseif self.template.type == GuideType.IntroBubble1 and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.Screen
                    local para = string.split_ss_array(self.template.para1, "/")
                    local paraCount = table.count(para)
                    if paraCount > 0 then
                        self.waitUIView = para[1]
                        local length = string.len(self.waitUIView)
                        self.waitUIBtn = string.sub(self.template.para1, length + 2, string.len(self.template.para1))
                    end
                elseif self.template.type == GuideType.BlackHoleMask and self.template.para2 ~= nil and self.template.para2 ~= "" then
                    self.objPositionType = PositionType.Screen
                    local para = string.split_ss_array(self.template.para2, "/")
                    local paraCount = table.count(para)
                    if paraCount > 0 then
                        self.waitUIView = para[1]
                        local length = string.len(self.waitUIView)
                        self.waitUIBtn = string.sub(self.template.para2,length + 2,string.len(self.template.para2))
                    end
                elseif self.template.type == GuideType.MoveBagViewItem and not string.IsNullOrEmpty(self.template.para4) then
                    self.objPositionType = PositionType.Screen
                    local para = string.split_ss_array(self.template.para4, "/")
                    local paraCount = table.count(para)
                    if paraCount > 0 then
                        self.waitUIView = para[1]
                        local length = string.len(self.waitUIView)
                        self.waitUIBtn = string.sub(self.template.para4, length + 2, string.len(self.template.para4))
                    end
                elseif self.template.type == GuideType.ClickBagItem and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.Screen
                    self.waitUIView = UIWindowNames.UIBagView
                elseif self.template.type == GuideType.Bubble or self.template.type == GuideType.PlayLadyBubble 
                        or self.template.type == GuideType.CityGarbage or self.template.type == GuideType.GotoMoveBubble 
                        or self.template.type == GuideType.ClickTimeLineBubble or self.template.type == GuideType.ClickPveTriggerBubble 
                        or self.template.type == GuideType.ClickWoundedCompensateBubble or self.template.type == GuideType.PoliceInsigniaPointer 
                        or self.template.type == GuideType.LLHangUpBubble or self.template.type == GuideType.LLFirstPayRewardBubble
                        or self.template.type == GuideType.TriggerOrNpcEventBubble or self.template.type == GuideType.TalkTaskObjBubble
                        or self.template.type == GuideType.TalkTaskNpcBubbleClick or self.template.type == GuideType.LLVIPPayRewardBubble
                then
                    self.objPositionType = PositionType.World
                elseif (self.template.type == GuideType.OpenFog or self.template.type == GuideType.ClickBuild
                        or self.template.type == GuideType.QueueBuild or self.template.type == GuideType.ClickBuildFinishBox
                        or self.template.type == GuideType.ClickMonster or self.template.type == GuideType.ClickCityPointType
                        or self.template.type == GuideType.ClickLandLockBubble or self.template.type == GuideType.ClickCollectResource
                        or self.template.type == GuideType.ClickLandLockRewardBox)
                        and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.World
                elseif self.template.type == GuideType.PlayMovie then
                    if self.template.para1 ~= nil then
                        local movieType = tonumber(self.template.para1)
                        if movieType == GuidePlayMovieType.GameStartRocketFall or movieType == GuidePlayMovieType.BaseZeroUpgrade then
                            self:SetCanShowBuild(false)
                        end
                    end
                elseif self.template.type == GuideType.CityGarbageResultShow then

                elseif self.template.type == GuideType.ClickQuickBuildBtn or self.template.type == GuideType.ClickGolloesCanSubmitOrder then
                    self.objPositionType = PositionType.Screen
                elseif self.template.type == GuideType.WaitTroopArrive then

                elseif self.template.type == GuideType.ClickTime then
                    self.objPositionType = PositionType.World
                elseif self.template.type == GuideType.ShowGuideTip then
                    if self.template.para2 ~= nil and self.template.para2 ~= "" then
                        local tempSpl = string.split_ss_array(self.template.para2, ";")
                        if #tempSpl > 1 then
                            local btnType = tonumber(tempSpl[1])
                            if btnType == GuideType.ClickButton or btnType == GuideType.ClickButtonNew then
                                self.objPositionType = PositionType.Screen
                                local para = string.split_ss_array(tempSpl[2], "/")
                                local paraCount = table.count(para)
                                if paraCount > 0 then
                                    self.waitUIView = para[1]
                                end
                            end
                        end
                    end
                elseif self.template.type == GuideType.ClickRadarMonster then
                    self.objPositionType = PositionType.World
                elseif self.template.type == GuideType.ClickMonsterReward then
                    self.objPositionType = PositionType.World
                elseif self.template.type == GuideType.ClickRecycleItem and self.template.para1 ~= nil then
                    self.objPositionType = PositionType.Screen
                    self.waitUIView = UIWindowNames.UIRecycle
                elseif self.template.type == GuideType.LoveNewsletter_hero or self.template.type == GuideType.LoveNewsletter_heroStory then
                    self.objPositionType = PositionType.Screen
                    self.waitUIView = UIWindowNames.UILoveNewsletter
                    local waitUIBtnPath = "safearea/Scroll_View/Viewport/Content/Root/MainView/NewsletterView/"
                    if self.template.type == GuideType.LoveNewsletter_hero then
                        waitUIBtnPath = waitUIBtnPath .. string.format("LeftArea/ScrollViewHeros/Viewport/Content/HeroCell%s",self.template.para1)
                    else
                        waitUIBtnPath = waitUIBtnPath .. string.format("RightArea/ScrollViewChatList/Viewport/Content/ChatLoveRoom_Banner%s/Background",self.template.para1)
                    end
                    self.waitUIBtn = waitUIBtnPath
                end
            end
            if id == GuideStartId then
                --清空所有引导信息
                for k, v in pairs(self.hasDoneGuide) do
                    self:SendSaveGuideMessage(k, "")
                end
                --self:SendSaveGuideMessage(SaveNoShowGarbage, SaveGuideDoneValue)
                --self:SendSaveGuideMessage(SaveNoShowBusinessPlaneArrive,SaveGuideDoneValue)
                --self:SendSaveGuideMessage(SaveNoShowBusinessBubble, SaveGuideDoneValue)
                --self:SendSaveGuideMessage(GuideNoShowRadarBubble, SaveGuideDoneValue)
                --self:SendSaveGuideMessage(BeforePrologue, SaveGuideDoneValue)
                --self:SendSaveGuideMessage(PrologueNoAttack, SaveGuideDoneValue)
                self:SendSaveGuideMessage(FactoryFirstFreeSpeed, SaveGuideDoneValue)
                --self:SendSaveGuideMessage(SearchMonsterInGarbage, SaveGuideDoneValue)
            end
            if self:InGuide() and id ~= GuideStartId then
                EventManager:GetInstance():Broadcast(EventId.UINoInput,UINoInputType.ShowNoUI)
            else
                EventManager:GetInstance():Broadcast(EventId.UINoInput,UINoInputType.Close)
            end
            --self:CheckStopDub()
            EventManager:GetInstance():Broadcast(EventId.RefreshGuide)
        end
    end
end

--获取上传的引导id
local function GetSaveGuideId(self)
    if self.hasDoneGuide ~= nil then
        local saveId = self.hasDoneGuide[SaveGuideId]
        if saveId ~= nil then
            return tonumber(saveId)
        end
    end
    if CS.SceneManager.IsInCity() then
        return GuideEndId
    end
    return GuideEndId
end

--保存已经触发过的引导
local function SendSaveGuideMessage(self, saveKey, saveValue)
    if self.hasDoneGuide ~= nil then
        local param = {}
        param.saveKey = tostring(saveKey)
        param.saveValue = tostring(saveValue)
        self.hasDoneGuide[saveKey] = saveValue
        SFSNetwork.SendMessage(MsgDefines.SaveGuide, param)

        if self.template ~= nil then
            EventManager:GetInstance():Broadcast(EventId.GuideSaveFinish, self.template.id)
        end
    end
end

--发送做过的引导（只用于服务器输出日志）
local function SendLogMessage(self, id, statType, curId)
    local param = {}
    param.id = tostring(id)
    param.type = statType
    if curId == nil then
        curId = GuideEndId
    end
    param.curId = tostring(curId)
    SFSNetwork.SendMessage(MsgDefines.StatTT, param)
end

--是否在引导中
local function InGuide(self)
    return self.guideId ~= GuideEndId and self.guideId ~= GuideTestEndId and self.guideId ~= GuideClickEndId and self.template ~= nil
end

local function UILoadingExitSignal()
    DataCenter.GuideManager:CheckLoginGuide()
    if DataCenter.GuideManager.initDoGuideId ~= GuideEndId and DataCenter.GuideManager.initDoGuideId ~= GuideTestEndId and DataCenter.GuideManager.initDoGuideId ~= GuideClickEndId then
        --判断是否始于大本废弃状态
        local mainBuild = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
        if mainBuild ~= nil and mainBuild.state == BuildingStateType.FoldUp then
            DataCenter.GuideManager:SetCurGuideId(GuideEndId)
            DataCenter.GuideManager:DoGuide()
        else
            if not DataCenter.GuideManager:InGuide() then
                DataCenter.GuideManager:SetCurGuideId(DataCenter.GuideManager.initDoGuideId)
                DataCenter.GuideManager:DoGuide()
            end
        end
    else
        if not DataCenter.GuideManager:InGuide() then
            DataCenter.GuideManager:InitTriggerGuide()
        end
    end
    DataCenter.GuideManager:LoadGuideGm()
    DataCenter.GuideManager.isInitEnd = true

    if DataCenter:IsValid('UIPopWindowManager') then
        DataCenter.UIPopWindowManager:CheckOpenWindow()
    end
end

local function DoGuide(self)
    if self.template ~= nil then
        self:ShowLog("shimin ++++++++++++++++++++++++++++++ DoGuide", self.template.id)
        --if self.template.id ~= 10128061 and 
                --self.template.id ~= 10128062 and
                --self.template.id ~= 10120911 then -- 先临时特殊处理下
            --if DataCenter.BattleLevel:GetRoleMgr() then
                --if UIManager:GetInstance():CanResumeRole() then
                    --DataCenter.BattleLevel:GetRoleMgr():ResumeAll()
                --else
                    --DataCenter.BattleLevel:GetRoleMgr():PauseAll()
                --end
            --end
        --end
        
		-- 判断引导是否需要等待；
        if self:NeedWaitLoadComplete() then
			
			-- 第一次初始化引导；curWaitGuideId会在DeleteWaitLoadTimer中重置
			if self.curWaitGuideId == -1 then
				self.curWaitGuideId = self.guideId
				self.curWaitGuideTime = UITimeManager:GetInstance():GetServerSeconds()
            	self:AddWaitLoadTimer()
				--Logger.LogError("--- begin")
			else
				-- 简单判断一下，如果出错的话，就打印一个LOG
				if self.curWaitGuideId ~= self.guideId then
					Logger.LogError("wait id is wrong???", tostring(self.curWaitGuideId), "--", tostring(self.guideId))
				end
				
				--Logger.LogError("--- tick")
				-- 判断是否超时
				local longTime = LuaEntry.DataConfig:TryGetNum("guide_overtime", "k1") / 1000
				local curTime = UITimeManager:GetInstance():GetServerSeconds()
				local diff = curTime - self.curWaitGuideTime
				if diff >= longTime then
					--Logger.LogError("--- end")
					
					self:DeleteWaitLoadTimer()
					self.curWaitGuideId = -1
					
					-- 表示超时，执行超时处理
					self:WaitTimeout()
				end
			end
		
        else
            self:DeleteWaitLoadTimer()
			self.curWaitGuideId = -1
				
            --APS中应该是一个显示在屏幕上面，带头像的对话框，C项目没有这个需求
            --C项目(GuideType.ShowTalk)使用了tipspic这个参数，和APS的意义已经不同，所以这个先不要了 
            --@cola
            --self:CheckTipsWaitTime()
            self:CheckNeedWaitTime()
        end
    else
        if self.guideId ~= GuideEndId and self.guideId ~= GuideTestEndId and self.guideId ~= GuideClickEndId then
            self:SetCurGuideId(GuideEndId)
        end
    end
end

local function BuildPlaceSignal(data)
    if data ~= nil and data:ContainsKey("type") ~= nil then
        local buildId = tonumber(data:GetInt("type"))
        local param = {}
        param.buildId = buildId
        DataCenter.GuideManager:SetCompleteNeedParam(param)
        --if buildId == BuildingTypes.FUN_BUILD_TRAINFIELD_1 then
            --CS.SceneManager.World:DestroyCityTroop()
        --end
        DataCenter.GuideManager:CheckGuideComplete()
    end
end

local function CheckGuideComplete(self)
    if self.template ~= nil then
        if self.template.type == GuideType.ShowTalk
                or self.template.type == GuideType.ShowTalk2 
                or self.template.type == GuideType.ShowTalk3
                or self.template.type == GuideType.ShowTalk4 then
            if self.needParam ~= nil and self.needParam.clickBtnObj ~= nil then
                self:DoNext()
            end
        elseif self.template.type == GuideType.PoliceInsigniaSubPointer then
            self:DoNext()
        elseif self.template.type == GuideType.ClickButton or self.template.type == GuideType.ClickButtonNew 
                or self.template.type == GuideType.ClickQuest or self.template.type == GuideType.ClickQuickBuildBtn 
                or self.template.type == GuideType.ClickGolloesCanSubmitOrder or self.template.type == GuideType.ClickRadarBubble 
                or self.template.type == GuideType.ClickUISpecialBtn or self.template.type == GuideType.ClickBagItem 
                or self.template.type == GuideType.IntroBubble or self.template.type == GuideType.IntroBubble1 
                or self.template.type == GuideType.ClickRecycleItem or self.template.type == GuideType.ClickHero
                or self.template.type == GuideType.LoveNewsletter_hero or self.template.type == GuideType.LoveNewsletter_heroStory then
            if self.obj ~= nil and self.needParam ~= nil and self.obj == self.needParam.clickBtnObj then
                self:DoNext()
            end
        elseif self.template.type == GuideType.BuildPlace then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                if tonumber(self.template.para1) == self.needParam.buildId then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.PlantFarm or self.template.type == GuideType.Factory then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                if tonumber(self.template.para1) == self.needParam.product_id then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.MoveBagViewItem then
            if self.needParam ~= nil then
                local moveItemType = tonumber(self.template.para1)
                if moveItemType == 1 then
                    local itemType = tonumber(self.template.para2)
                    local itemType2 = tonumber(self.template.para3)
                    local itemId = self.needParam.itemId
                    local itemTemplate = DataCenter.ItemTemplateManager:GetItemTemplate(itemId)
                    if itemTemplate.type == tonumber(itemType) and itemTemplate.type2 == tonumber(itemType2) then
                        self:DoNext()
                    end
                end
                if moveItemType == 2 then
                    local itemType = tonumber(self.template.para2)
                    local itemId = self.needParam.itemId
                    if itemId == tonumber(itemType) then
                        self:DoNext()
                    end
                end
            end
        elseif self.template.type == GuideType.GetFarm then
            if self.template.para1 ~= nil and self.needParam ~= nil and self.needParam.queueList ~= nil then
                for k, v in pairs(self.needParam.queueList) do
                    local queueData = DataCenter.QueueDataManager:GetQueueByUuid(v)
                    if queueData ~= nil and queueData.type == tonumber(self.template.para1) then
                        self:DoNext()
                        break
                    end
                end
            end
        elseif self.template.type == GuideType.Bubble then
            if self.template.para2 ~= nil and self.needParam ~= nil then
                if BuildBubbleType[self.template.para2] == self.needParam.buildBubbleType then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.PlayLadyBubble then
            if self.template.para2 ~= nil and self.needParam ~= nil then
                if BuildBubbleType[self.template.para2] == self.needParam.PlayLadyBubble then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.ClickBuildFinishBox then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                if tonumber(self.template.para1) == self.needParam.buildBoxId then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.CityGarbage then
            if self.needParam ~= nil and self.needParam.isClickGarbage then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickMonster then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                local spl = string.split_ss_array(self.template.para1, ",")
                if table.count(spl) > 1 then
                    local vec = {}
                    vec.x = DataCenter.BuildManager.main_city_pos.x + tonumber(spl[1])
                    vec.y = DataCenter.BuildManager.main_city_pos.y + tonumber(spl[2])
                    local pointId = SceneUtils.TilePosToIndex(vec)
                    if pointId == self.needParam.pointId then
                        self:DoNext()
                    end
                end
            end
        elseif self.template.type == GuideType.ClickCityPointType then
            if self.template.para2 ~= nil and self.needParam ~= nil then
                local spl = string.split_ss_array(self.template.para2, ",")
                if table.count(spl) > 1 then
                    local vec = {}
                    vec.x = DataCenter.BuildManager.main_city_pos.x + tonumber(spl[1])
                    vec.y = DataCenter.BuildManager.main_city_pos.y + tonumber(spl[2])
                    local pointId = SceneUtils.TilePosToIndex(vec)
                    if pointId == self.needParam.pointId then
                        self:DoNext()
                    end
                end
            end
        elseif self.template.type == GuideType.ClickTimeLineBubble or self.template.type == GuideType.ClickPveTriggerBubble or self.template.type == GuideType.ClickWoundedCompensateBubble then
            if self.needParam ~= nil then
                if self.needParam.click then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.GotoMoveBubble then
            if self.needParam ~= nil then
                if self.needParam.click then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.OpenFog then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                if Data.Fog:GetPointIdCenterByFogIndex(tonumber(self.template.para1), tonumber(self.template.para2)) == self.needParam.pointId then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.WaitCloseUI then
            if self.needParam ~= nil then
                if self.needParam.uiName == self.template.para1 then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.ClickTime then
            if self.template.para2 ~= nil and self.needParam ~= nil then
                if tonumber(self.template.para2) == self.needParam.buildTimeType then
                    self:DoNext()
                end
            end
            --elseif self.template.type == GuideType.PlantAnimal then
            --if self.template.para2 ~= nil then
            --if tonumber(self.template.para2) == self.needParam.stateType then
            --self:DoNext()
            --end
            --end
        elseif self.template.type == GuideType.ShowCommunicationTalk then
            if self.needParam ~= nil and self.needParam.clickBtnObj ~= nil then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickLandLockBubble then
            if self.template.para1 ~= nil and self.needParam ~= nil then
                if tonumber(self.template.para1) == self.needParam.landLockId then
                    self:DoNext()
                end
            end
        elseif self.template.type == GuideType.ClickCollectResource then
            if self.needParam ~= nil and self.needParam.collectType == tonumber(self.template.para1) then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickLandLockRewardBox then
            if self.needParam ~= nil and self.needParam.id == tonumber(self.template.para1) then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ShowSLGArea then
            if self.needParam ~= nil and self.needParam.id == tonumber(self.template.para1) then
                self:DoNext()
            end
        elseif self.template.type == GuideType.WaitMarchFightEnd then
            if self.needParam ~= nil and self.needParam.waitMarchFightEnd then
                CS.SceneManager.World.marchUuid = 0
                DataCenter.WorldMarchDataManager:TrackMarch(0)
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickRadarMonster then
            if self.needParam ~= nil and self.needParam.monster then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickMonsterReward then
            if self.needParam ~= nil and self.needParam.monsterReward then
                self:DoNext()
            end
        elseif self.template.type == GuideType.ClickGarbageTrigger then
            if self.needParam ~= nil and self.needParam.triggerId == tonumber(self.template.para1) then
                self:DoNext()
            end
        end
    end
end

local function CheckOpenUITriggerGuide(self, uiName)
    if not self:InGuide() then
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.UIPanel, uiName)
    end
end

--打开一个界面
local function OpenUISignal(uiName)
    DataCenter.GuideManager:CheckOpenUITriggerGuide(uiName)
end

local function DeleteAutoNextTimer(self)
    if self.autoNextTimer ~= nil then
        self.autoNextTimer:Stop()
        self.autoNextTimer = nil
    end
end

local function AddAutoNextTimer(self, time)
    self:DeleteAutoNextTimer()
    if self.autoNextTimer == nil then
        self.autoNextTimer = TimerManager:GetInstance():GetTimer(time, self.auto_next_timer_action, self, true, false, false)
        self.autoNextTimer:Start()
    end
end

local function AutoNextTimeCallBack(self)
    self:DeleteAutoNextTimer()
    if self.template ~= nil then
        self:DoNext()
    end
end

local function GetCurTemplate(self)
    return self.template
end

local function HasClick(self, obj)
    if self:InGuide() then
        self.needParam.clickBtnObj = obj
        self:CheckGuideComplete()
    end
end

--主UI加载完成才可以做
local function NeedWaitLoadComplete(self)
    if self.template and self.template.type == GuideType.SaveReconnectionGuideId then
        return false
    end
    
    if self.template and self.template.type == GuideType.GoToMainCityArea then
        local areaId = tonumber(self.template.para1)
        local areaMgr = DataCenter.BattleLevel:GetAreaMgr()
        if areaMgr then
            local areaEntity = areaMgr:GetAreaEntity(areaId)
            if areaEntity and areaEntity.hud and areaEntity.hud.transform and areaEntity.hud.visible then
                return false
            else
                return true
            end
        else
            return true
        end
    end
    
    if self.template and self.template.type == GuideType.BossShowingTimeline then
        return false
    end
    
    if self.template and self.template.type == GuideType.MapObjectPveRoutePlayAnim then
        if  string.IsNullOrEmpty(self.template.para1)
                or string.IsNullOrEmpty(self.template.para3)
        then
            return false
        end

        if SceneManager.IsInHome() and DataCenter.BattleLevel:GetObjMgr() then
            local triggerId = tonumber(self.template.para1)
            local obj = DataCenter.BattleLevel:GetObjMgr():GetObjectByUuid(triggerId)
            if obj then
                return false
            end
            return true
        end
    end
    
    if self.template.type == GuideType.PoliceInsigniaPointer then
        if string.IsNullOrEmpty(self.template.para1) then
            return false
        end

        local initBuildId = nil
        if not string.IsNullOrEmpty(self.template.para2) and tonumber(self.template.para2) ~= nil then
            initBuildId = tonumber(self.template.para2)
        end
        
        local init = DataCenter.BuildPoliceInsigniaManager:CheckPoliceInsigniaInited()
        if not init then
            return true
        end
        
        local uuids = DataCenter.BuildPoliceInsigniaManager:GetCurPoliceInsignia()
        if not uuids or #uuids == 0 then
            return false
        end
        local uuid = nil -- uuids[1]

        for _, v in pairs(uuids) do
            local data = DataCenter.BuildManager:GetBuildingDataByUuid(v)
            if data then
                local para1 = self.template.para1
                if initBuildId ~= nil then
                    if data.itemId == tonumber(para1) and data:GetInitBuildConfig() == initBuildId then
                        uuid = v
                        break
                    end
                else
                    if data.itemId == tonumber(para1) then
                        uuid = v
                        break
                    end
                end
            end
        end

        if not uuid then
            return false
        end
        
        if DataCenter.BuildBubbleManager then
            local bubble = DataCenter.BuildBubbleManager:GetBubbleByBuildUuid(uuid)
            if not bubble then
                return true
            end
            if not bubble.IsInitPos or not bubble:IsInitPos() then
                return true
            end
            local pos = DataCenter.BuildBubbleManager:GetBubblePosition(uuid)
            if not pos then
                return true
            end
            self.objWorldPos = pos
        end
        
        return false
    end

    if self.template.type == GuideType.MoveCameraAndShowTalkBubble or self.template.type == GuideType.ShowBoxBubble then
        if not (DataCenter.BattleLevel and DataCenter.BattleLevel:GetCamera()) then
            return true
        end
    end
    
    if self.template.type == GuideType.LLHangUpBubble then
        local checkHangUp = DataCenter.StoryManager:CheckHangUpIsStart()
        if checkHangUp then
            if DataCenter.BattleLevel
                    and DataCenter.BattleLevel.GetObjMgr
                    and DataCenter.BattleLevel:GetObjMgr() then
                local pos = DataCenter.BattleLevel:GetObjMgr():GetHangUpBubblePos()
                if pos then
                    self.objWorldPos = pos
                    return false
                end
            end
            return true
        else
            return false
        end
    end

    if self.template.type == GuideType.LLFirstPayRewardBubble then
        if DataCenter.BattleLevel
                and DataCenter.BattleLevel.GetObjMgr
                and DataCenter.BattleLevel:GetObjMgr() then
            local pos = DataCenter.BattleLevel:GetObjMgr():GetLLFirstPayRewardBubblePos()
            if pos then
                self.objWorldPos = pos
                return false
            end
        end
        return true
    end

    if self.template.type == GuideType.LLVIPPayRewardBubble then
        if DataCenter.BattleLevel
                and DataCenter.BattleLevel.GetObjMgr
                and DataCenter.BattleLevel:GetObjMgr() then
            local pos = DataCenter.BattleLevel:GetObjMgr():GetLLVipBubblePos()
            if pos then
                self.objWorldPos = pos
                return false
            end
        end
        return true
    end

    if self.template.type == GuideType.TriggerOrNpcEventBubble then
        local bubblePos = DataCenter.EventBubbleManager:GetBubblePosition(EventBubbleType.TriggerNpcBubble, 10001517)
        if bubblePos then
            if DataCenter.BattleLevel and DataCenter.BattleLevel.GetObjMgr then
                self.objWorldPos = bubblePos
                return false
            end
            return true
        else
            return false
        end
    end
    
    if self.template.type == GuideType.PrologueShowNpc or self.template.type == GuideType.PrologueShowSetManPosition then
        local level = SceneManager.GetLevel()
        if level == nil then
            return true
        end
    end
    
    local luaWindow = UIManager:GetInstance():GetWindow(UIWindowNames.UIPVELoading)
    if luaWindow ~= nil and luaWindow.State ~= 4 then
        return true
    end
    
    --大本0级升级不做引导
    --if self.template.type ~= GuideType.PlayMovie then
    --    local mainData = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
    --    if mainData ~= nil and mainData.level == 0 and mainData.updateTime > 0 then
    --        return true
    --    end
    --end

    if self.template.type == GuideType.PlayRoleAnim or self.template.type == GuideType.PrologueShowSetManPosition then
        local player = DataCenter.BattleLevel:GetRoleTeam()
        if player == nil then
            return true
        end
    end

    if self.template.type == GuideType.Factory then
        luaWindow = UIManager:GetInstance():GetWindow(UIWindowNames.UIFactory2)
        if luaWindow == nil or luaWindow.View == nil or luaWindow.View.factoryUid == nil then
            return true
        end
    end

    if self.template.type == GuideType.LoveNewsletter_hero or self.template.type == GuideType.LoveNewsletter_heroStory then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UILoveNewsletter)
        if window and window.View then
            if self.template.type == GuideType.LoveNewsletter_hero then
                window.View:GuideToHeroClick(tonumber(self.template.para1))
            else
                window.View:GuideToHeroStoryClick(tonumber(self.template.para1))
            end
        end
    end

    if self.template.type == GuideType.LoveNewsletter_hero or self.template.type == GuideType.LoveNewsletter_heroStory then
        local window = UIManager:GetInstance():GetWindow(UIWindowNames.UILoveNewsletter)
        if window and window.View then
            if self.template.type == GuideType.LoveNewsletter_hero then
                window.View:GuideToHeroClick(tonumber(self.template.para1))
            else
                window.View:GuideToHeroStoryClick(tonumber(self.template.para1))
            end
        end
    end
    
    if self.waitUIView ~= nil and self.waitUIView ~= "" then
        if self.waitUIView == "Joystick(Clone)" then
            local player = DataCenter.BattleLevel:GetPlayer()
            if player == nil then
                return true
            end
            local joystick = CS.UnityEngine.GameObject.Find(self.waitUIView)
            if not joystick then
                return true
            end
            if self.waitUIBtn ~= nil and self.waitUIBtn ~= "" then
                local waitUiButton = CS.UnityEngine.GameObject.Find(self.waitUIBtn)
                if waitUiButton == nil then
                    return true
                end
                self.obj = waitUiButton.gameObject
                if self.obj == nil then
                    return true
                end
                if self.obj.gameObject and not self.obj.gameObject.activeInHierarchy then
                    return true
                end
            end
        else
            local isLuaWindow = UIManager:GetInstance():IsPanelLoadingComplete(self.waitUIView)
            if not isLuaWindow then
                return true
            end
            if self.waitUIBtn ~= nil and self.waitUIBtn ~= "" then
                local trans = nil
                luaWindow = UIManager:GetInstance():GetWindow(self.waitUIView)
                if luaWindow ~= nil and luaWindow.View ~= nil and luaWindow.View.transform ~= nil then
                    trans = luaWindow.View.transform
                end
                if trans == nil then
                    return true
                end
                self.obj = trans:Find(self.waitUIBtn)
                if self.obj == nil then
                    return true
                end
                --主界面上有 RPG/SLG 2套UI，做引导的时候并不能知道当前处于那套UI模式下
                --所以做一个兼容：obj在当前UI隐藏的时候，找另一套UI上的obj
                if self.waitUIView == UIWindowNames.MainUI_SU and not self.obj.gameObject.activeInHierarchy then
                    local tempWaitUIBtn = nil
                    if string.find(self.waitUIBtn, "/RPGObject/") then
                        tempWaitUIBtn = string.gsub(self.waitUIBtn, '/RPGObject/', '/SLGObject/')
                    elseif string.find(self.waitUIBtn, "/SLGObject/") then
                        tempWaitUIBtn = string.gsub(self.waitUIBtn, '/SLGObject/', '/RPGObject/')
                    end
                    if tempWaitUIBtn ~= nil then
                        self.waitUIBtn = tempWaitUIBtn
                        self.obj = trans:Find(tempWaitUIBtn)
                        self:ShowLog("shimin +++++++++++++++++++++++ self.waitUIBtn_1: ", self.waitUIBtn)
                    end
                end
                if self.obj == nil then
                    return true
                end
                if self.obj.gameObject and not self.obj.gameObject.activeInHierarchy then
                    return true
                end
            end
        end
    end

    local fn = GuideDelayItem and GuideDelayItem[self.template.type]
    if fn then
        if fn(self) == true then
            return true
        end
    end
	
    return false
end

local function DeleteWaitLoadTimer(self)
    if self.waitLoadTimer ~= nil then
        self.waitLoadTimer:Stop()
        self.waitLoadTimer = nil
    end
end

local function AddWaitLoadTimer(self)
	if self.waitLoadTimer ~= nil then
		Logger.LogError("why has timer???")
		self:DeleteWaitLoadTimer()
	end
    --self:DeleteWaitLoadTimer()
    if self.waitLoadTimer == nil then
        self.waitLoadTimer = TimerManager:GetInstance():GetTimer(WaitLoadTime, self.wait_load_timer_action, self, false, false, false)
        self.waitLoadTimer:Start()
    end
end

local function WaitLoadCallBack(self)
    --self:DeleteWaitLoadTimer()
    self:DoGuide()
end

-- 等待超时
local function WaitTimeout(self)
	--self:DeleteWaitLongDelayTimer()
	--直接结束引导
	if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIGuideLoadMask) then
		UIManager:GetInstance():DestroyWindow(UIWindowNames.UIGuideLoadMask,OpenWinAnimTrue)
	end
	if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIGuideLoadBlackMask) then
		UIManager:GetInstance():DestroyWindow(UIWindowNames.UIGuideLoadBlackMask,OpenWinAnimTrue)
	end
    
    -- PlayLadyBubble 特殊处理下
    -- 在关卡返回主城的时候，执行PlayLadyBubble时美女还没有创建
    -- 如果因为没有找到目标，那么执行指定的引导步骤
    if self.template.type == GuideType.PlayLadyBubble and not string.IsNullOrEmpty(self.template.para2) then
        self:SetCurGuideId(self.template.para2)
    else
        self:SetCurGuideId(GuideTestEndId)
    end
	
	-- 下一帧再执行DoGuide更好一些，否则有点蛇咬尾巴哦~！
	TimerManager:GetInstance():DelayNextFrameAction(
		function() 
			self:DoGuide()
		end)
end

--获取引导类型
local function GetGuideType(self)
    if self:InGuide() then
        if self.template ~= nil then
            return self.template.type
        end
    end
    return 0
end

--保存验证完成的参数
local function SetCompleteNeedParam(self, param)
    self.needParam = param
end

--通过触发类型和触发参数获取引导id
local function GetGuideIdByTrigger(self, triggerType, TriggerPara)
    if triggerType ~= nil and TriggerPara ~= nil then
        if self.allTriggerGuide[triggerType] ~= nil then
            local guideId = self.allTriggerGuide[triggerType][TriggerPara]
            self:ShowLog("shimin ++++++++++++++++++++++++ triggerType:" .. triggerType)
            self:ShowLog("shimin ++++++++++++++++++++++++ TriggerPara:" .. TriggerPara)
            if guideId ~= nil and not self:IsDoneThisGuide(guideId) then
                if self:InGuide() then
                    self:ShowLog("shimin ++++++++++++++++++++++++ InGuide:" .. self.guideId)
                else
                    self:ShowLog("shimin ++++++++++++++++++++++++ not InGuide, new guideId:" .. guideId)
                    return guideId
                end
            end
        end
    end
end

--获取当前引导的配置参数
local function GetGuideTemplateParam(self, paramPara)
    if self.template ~= nil and paramPara ~= nil then
        return self.template[paramPara]
    end
end

local function IsCanOpenUI(self, uiName)
    if uiName == UIWindowNames.UIBuildList then
        if true then
            return true
        end
        return DataCenter.UnlockBtnManager:IsShowBtn(UnlockBtnType.Build)
    end
    if self:InGuide() then
        if uiName == UIWindowNames.UINoInput then
            return true
        end
        return not self.isNoOpenUI
    end
    return true
end

--是否可以关闭界面
local function IsCanCloseUI(self, uiName)
    if self:InGuide() then
        if self.template ~= nil then
            if ((self.template.type == GuideType.PlantAnimal or self.template.type == GuideType.ClickTime) and uiName == UIWindowNames.UIPasture)
                    or ((self.template.type == GuideType.PlantFarm) and uiName == UIWindowNames.UIFarm) then
                return false
            end
        end
    end

    return true
end
--是否可以退出聚焦
local function IsCanQuitFocus(self)
    if self:InGuide() then
        if self.template ~= nil then
            if self.template.type == GuideType.PlantAnimal then
                return false
            end
        end
    end
    return true
end

--队列完成信号
local function QueueTimeEndSignal(queueType)
    if queueType ~= nil then
        local id = tostring(queueType)
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.Queue, id)
        if queueType == NewQueueType.OstrichBarn or queueType == NewQueueType.CattleBarn or queueType == NewQueueType.SandWormBarn then
            DataCenter.GuideManager:CheckWaitMessage()
        end
    end
end

--新获得队列信号
local function QueueAddSignal(queueType)
    if queueType ~= nil then
        local id = tostring(queueType)
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.OwnQueue, id)
    end
end

local function InitTriggerGuide(self)
    self:CheckFirstJoinAllianceGuide()
    self:CheckTreatSoldierGuide()
    self:CheckPlayerLevelGuide(DataCenter.GuideManager:GetSaveGuideValue(SaveTriggerGuidePlayerLevel))
end

--获取当前引导的配置参数
local function GetNextGuideTemplateParam(self, paramPara)
    if self.template ~= nil and paramPara ~= nil and self.template.nextid ~= GuideEndId then
        local nextTemplate = DataCenter.GuideTemplateManager:GetGuideTemplate(self.template.nextid)
        if nextTemplate ~= nil then
            return nextTemplate[paramPara]
        end
    end
end

local function OnClickWorldSignal(pointId)
    if DataCenter.GuideManager:IsOnRadarMoveAndClickCamera() then
        return
    end
    local point = tonumber(pointId)
    local param = {}
    param.pointId = point
    DataCenter.GuideManager:SetCompleteNeedParam(param)
    DataCenter.GuideManager:CheckGuideComplete()
end

local function CityGarbageResultSignal(data)
    local pointId = nil
    if data:ContainsKey("pointId") then
        pointId = data:GetInt("pointId")
    end
    if pointId ~= nil then
        local pos = SceneUtils.IndexToTilePos(pointId)
        local triggerPara = pos.x - DataCenter.BuildManager.main_city_pos.x .. "," .. pos.y - DataCenter.BuildManager.main_city_pos.y
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.CityGarbage, triggerPara)
        DataCenter.TroopActionManager:DoTroopAction(TroopActionType.CITY_TROOP_ACTION_COLLECT_GARBAGE)
    end
    DataCenter.GuideManager.currentGetRewardGarbage = nil
end

local function OpenFogSuccessSignal(fogId)
    if fogId ~= nil then
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.OpenFog, tostring(fogId))
    end
end

local function BuildUpgradeFinishSignal(uuid)
    if uuid ~= nil then
        local buildData = DataCenter.BuildManager:GetBuildingDataByUuid(tonumber(uuid))
        if buildData ~= nil then
            local buildId = buildData.itemId
            local level = buildData.level
            local num = DataCenter.BuildManager:GetOwnNumByBuildIdAndLevel(buildId, level)
            local triggerType = buildId..",".. level .. ";" .. num
            DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.BuildUpgrade,triggerType)
        end
    end
end

local function GetDoneGuideEndId(self, guideId)
    return tostring(guideId) .. "end"
end

local function GetDoneGuideStartId(self, guideId)
    return tostring(guideId) .. "start"
end

local function IsDoneThisGuide(self, guideId)
    return self.hasDoneGuide[self:GetDoneGuideEndId(guideId)] == SaveGuideDoneValue
end

local function PlayMovieCompleteSignal(data)
    if DataCenter.GuideManager:InGuide() then
        local template = DataCenter.GuideManager:GetCurTemplate()
        if template ~= nil and template.type == GuideType.PlayMovie then
            GuideManager:DoNext()
        end
    end
end

local function CheckDoTriggerGuide(self, guideTriggerType, triggerPara)
    if true or self:CanUseGuide() then
        local para = "1100001" --self:GetSpecialTriggerPara(guideTriggerType, triggerPara)
        local guideId = 10006001 --self:GetGuideIdByTrigger(guideTriggerType, para)
        if guideId ~= nil then
            -- 加入联盟的引导，不管是怎么样升级的建筑，都直接关闭所以界面
            if guideTriggerType == GuideTriggerType.BuildUpgrade and triggerPara == "402000,1;1" then
                GoToUtil.CloseAllWindows()
            end
            self:SetCurGuideId(guideId)
            self:DoGuide()
            self:RemoveOneWaitTrigger(guideTriggerType, para)
            return true
        end
    end
    return false
end

local function SaveFinalGarbageRewardItemId(self, itemId)
    self:SendSaveGuideMessage(FinalGarbageRewardItemId, tostring(itemId))
end

local function GetFinalGarbageRewardItemId(self)
    return self:GetSaveGuideValue(FinalGarbageRewardItemId)
end

local function GetSaveGuideValue(self, keyName)
    return self.hasDoneGuide and self.hasDoneGuide[keyName]
end

local function SaveCityTroopPeopleNum(self, num)
    self:SendSaveGuideMessage(CityTroopPeopleNum, tostring(num))
end

--获取城市行军有几个小人
local function GetCityTroopPeopleNum(self)
    --local num = self:GetSaveGuideValue(CityTroopPeopleNum)
    --if num ~= nil and num ~= "" then
    --    return tonumber(num)
    --end
    return DefaultCityTroopNum
end

local function ChapterTaskGetRewardSignal(chapterId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ChapterQuestAfterReward, tostring(chapterId))
end

--剧情引导期间显示主UI
local function IsCanDoUIMainAnim(self)
    --播放timeline需要全部隐藏
    return not self.noShowUIMain
end

local function SetNoShowUIMain(self, isNoShow)
    if self.noShowUIMain ~= isNoShow then
        if isNoShow then
            EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, false)
        end
        self.noShowUIMain = isNoShow
        if not isNoShow then
            EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true)
        end
    end
end

local function IsStartCanShowBuild(self)
    return true --not self.isNoShowBuild
end

local function SetCanShowBuild(self, isShow)
    self.isNoShowBuild = not isShow
end

local function ShowAllGuideObjectSignal()
    DataCenter.GuideManager:SetCanShowBuild(true)
end

--关闭一个界面
local function CloseUISignal(uiName)
    if DataCenter.GuideManager:GetGuideType() == GuideType.WaitCloseUI then
        local param = {}
        param.uiName = uiName
        DataCenter.GuideManager:SetCompleteNeedParam(param)
        DataCenter.GuideManager:CheckGuideComplete()
    end
    DataCenter.GuideManager:DoWaitTriggerAfterBack()
end

local function CheckNeedWaitTime(self)
    -- 如果正在切摄像机模式，需要加一个等待，等切换逻辑完善后再干掉这个
    if DataCenter.BattleLevel:IsChangeViewMode() then
        if self.template ~= nil and (self.template.waittime == nil or self.template.waittime < 1000) then
            self.template.waittime = 1000
        end
    end
    if self.template ~= nil and self.template.waittime > 0 then
        self:AddWaitTimeTimer(self.template.waittime / 1000)
    else
        self:CallBackDoGuide()
    end
end

local function DeleteWaitTimeTimer(self)
    if self.waitTimeTimer ~= nil then
        self.waitTimeTimer:Stop()
        self.waitTimeTimer = nil
    end
end

local function AddWaitTimeTimer(self, time)
    self:DeleteWaitTimeTimer()
    if self.waitTimeTimer == nil then
        self.waitTimeTimer = TimerManager:GetInstance():GetTimer(time, self.wait_time_timer_action, self, true, false, false)
        self.waitTimeTimer:Start()
    end
end

local function WaitTimeCallBack(self)
    self:DeleteWaitTimeTimer()
    self:CallBackDoGuide()
end

function GuideManager:InWaiting()
    return self.waitTimeTimer ~= nil
end

local function ChapterTaskSignal()

end

local function MainTaskSuccessSignal()
    local list = DataCenter.TaskManager:GetCanReceivedList()
    if list ~= nil then
        for k, v in ipairs(list) do
            DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.TaskFinish, tostring(v))
        end
    end
end

local function IsCanBuildRoad(self)
    return true
end

local function CheckFirstJoinAllianceGuide(self)
    if not self:InGuide() then
        if LuaEntry.Player.isFirstJoin == FirstJoinAllianceType.Yes and LuaEntry.Player:IsInAlliance() then
            self:CheckDoTriggerGuide(GuideTriggerType.FirstJoinAlliance, FirstJoinAllianceValue)
        end
    end
end

local function AllianceApplySuccessSignal(self)
    DataCenter.GuideManager:CheckFirstJoinAllianceGuide()
end

local function IsStartId(self)
    return self.guideId == GuideStartId
end

local function GuideNoOpenUISignal(isNoOpenUI)
    DataCenter.GuideManager:SetNoOpenUI(isNoOpenUI)
end

local function SetNoOpenUI(self, isNoOpenUI)
    self.isNoOpenUI = isNoOpenUI
end

local function IsCanClick(self, curIndex)
    if self:InGuide() then
        if self.template ~= nil then
            if self.template.type == GuideType.OpenFog then
                if Data.Fog:GetPointIdCenterByFogIndex(tonumber(self.template.para1), tonumber(self.template.para2)) ~= curIndex then
                    return false
                end
            end
        end
    end
    return true
end

local function GuideWaitMessageSignal()
    DataCenter.GuideManager:CheckWaitMessage()
end

local function CheckWaitMessage(self)
    if self:InGuide() then
        if self.template ~= nil and self.template.type == GuideType.WaitMessageFinish then
            if self.template.para1 ~= nil and self.template.para1 ~= "" then
                local guideId = self.template.returnstepid
                local waitType = tonumber(self.template.para1)
                if waitType == WaitMessageFinishType.PlantAnim then
                    if self.template.para3 ~= nil and self.template.para3 ~= "" then
                        local buildId = tonumber(self.template.para3)
                        local buildData = DataCenter.BuildManager:GetFunbuildByItemID(buildId)
                        if buildData == nil or buildData:IsConnect() == false or buildData.state == BuildingStateType.FoldUp then
                            guideId = self.template.returnstepid
                        end
                        local queueList = DataCenter.QueueDataManager:GetQueueListByBuildUuidForPasture(buildData.uuid)
                        if queueList == nil or table.count(queueList) == 0 then
                            guideId = self.template.returnstepid
                        end
                        for k, v in pairs(queueList) do
                            if v.itemId == self.template.para2 then
                                if (v:GetParaState() == QueueProductState.DEFAULT and v:GetQueueState() == NewQueueState.Finish)
                                        or (v:GetParaState() == QueueProductState.PASTURE_MATURE and v:GetQueueState() == NewQueueState.Free) then
                                    guideId = self.template.nextid
                                end
                            end
                        end
                    end
                elseif waitType == WaitMessageFinishType.PlantFarm then
                    if self.template.para2 ~= nil then
                        local spl = string.split_ss_array(self.template.para2, ";")
                        local mainPos = DataCenter.BuildManager.main_city_pos
                        local isCanDone = true
                        for k2, v2 in ipairs(spl) do
                            local spl1 = string.split_ss_array(v2, ",")
                            if table.count(spl) > 1 then
                                local vec = {}
                                vec.x = DataCenter.BuildManager.main_city_pos.x + tonumber(spl1[1])
                                vec.y = DataCenter.BuildManager.main_city_pos.y + tonumber(spl1[2])
                                local pointId = SceneUtils.TilePosToIndex(vec)
                                local buildData = DataCenter.BuildManager:GetBuildingDataByPointId(pointId)
                                if buildData == nil or buildData.itemId ~= BuildingTypes.APS_BUILD_FARM_FIELD then
                                    isCanDone = false
                                end
                            end
                        end
                        if isCanDone then
                            guideId = self.template.nextid
                        end
                    end
                elseif waitType == WaitMessageFinishType.GetAnim then
                    if self.template.para3 ~= nil and self.template.para3 ~= "" then
                        local buildId = tonumber(self.template.para3)
                        local buildData = DataCenter.BuildManager:GetFunbuildByItemID(buildId)
                        if buildData == nil or buildData:IsConnect() == false or buildData.state == BuildingStateType.FoldUp then
                            guideId = self.template.returnstepid
                        end
                        local queueList = DataCenter.QueueDataManager:GetQueueListByBuildUuidForPasture(buildData.uuid)
                        if queueList == nil or table.count(queueList) == 0 then
                            guideId = self.template.returnstepid
                        end
                        for k, v in pairs(queueList) do
                            if v.itemId == self.template.para2 then
                                if (v:GetParaState() == QueueProductState.PASTURE_MATURE and v:GetQueueState() == NewQueueState.Finish) then
                                    guideId = self.template.nextid
                                    self:SetWaitingMessage(WaitMessageFinishType.GetAnim, nil)
                                end
                            end
                        end
                    end
                elseif waitType == WaitMessageFinishType.FeedAnim then
                    if self.template.para3 ~= nil and self.template.para3 ~= "" then
                        local buildId = tonumber(self.template.para3)
                        local buildData = DataCenter.BuildManager:GetFunbuildByItemID(buildId)
                        if buildData == nil or buildData:IsConnect() == false or buildData.state == BuildingStateType.FoldUp then
                            guideId = self.template.returnstepid
                        end
                        local queueList = DataCenter.QueueDataManager:GetQueueListByBuildUuidForPasture(buildData.uuid)
                        if queueList == nil or table.count(queueList) == 0 then
                            guideId = self.template.returnstepid
                        end
                        for k, v in pairs(queueList) do
                            if v.itemId == self.template.para2 then
                                if (v:GetParaState() == QueueProductState.PASTURE_MATURE and v:GetQueueState() == NewQueueState.Work) then
                                    guideId = self.template.nextid
                                    local signal = SFSObject.New()
                                    signal:PutLong("bUuid", buildData.uuid)
                                    signal:PutLong("queueUuid", v.uuid)
                                    EventManager:GetInstance():Broadcast(EventId.ClickFarmBuildShow, signal)
                                end
                            end
                        end
                    end
                elseif waitType == WaitMessageFinishType.AllianceMember then
                    guideId = self.template.nextid
                elseif waitType == WaitMessageFinishType.PurchaseOrderFinish then
                    guideId = self.template.nextid
                else
                    guideId = self.template.nextid
                end
                self:SetCurGuideId(guideId)
                self:DoGuide()
            end
        end
    end
end

local function DoNext(self)
    if self.template ~= nil then
        EventManager:GetInstance():Broadcast(EventId.SU_GuideDone, self.template.id)
		
		-- id和nextid不能是同一个id；否则会陷入死循环！！！
		if self.template.id == self.template.nextid then
			Logger.LogError("+++++++++ id == nextid!!!")
			return
		end
        self:SetCurGuideId(self.template.nextid, nil, true)
        self:DoGuide()
    end
end

local function LoadGuideGm(self)
    if self.requestGm == nil then
        self.requestGm = ResourceManager:InstantiateAsync(UIAssets.GuideGM)
        self.requestGm:completed('+', function()
            if self.requestGm.isError then
                return
            end
            self.requestGm.gameObject:SetActive(true)
            self.requestGm.gameObject.transform:SetAsFirstSibling()
        end)
    end
end

local function DestroyGm(self)
    if self.requestGm ~= nil then
        self.requestGm:Destroy()
        self.requestGm = nil
    end
end

--设置等待的消息
local function SetWaitingMessage(self, waitType, value)
    self.waitingMessage[waitType] = value
end

local function SaveRecommendShow(self, value)
    self:SendSaveGuideMessage(SaveGuideRecommendShow, value)
end

local function GetRecommendShow(self)
    return self:GetSaveGuideValue(SaveGuideRecommendShow)
end

local function BuildResourcesStartSignal()
    if CS.SceneManager:IsInCity() then
        local buildIdList = DataCenter.QueueDataManager:GetBuildUuidInFreeQueueByType(NewQueueType.Field)
        if buildIdList == nil or table.count(buildIdList) == 0 then
            DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.NoFreeQueue, tostring(NewQueueType.Field))
        end
    end
end

local function OnWorldInputPointDownSignal(pointId)
    local guideType = DataCenter.GuideManager:GetGuideType()
    if guideType == GuideType.ShowTroopTalk then
        DataCenter.TroopActionManager:DoTroopAction(TroopActionType.TROOP_ACTION_TYPE_NULL)
        DataCenter.GuideManager:DoNext()
    end
end

local function SetGuideEndCallBack(self, callBack)
    if self:InGuide() then
        self.guideEndCallBack = callBack
    else
        callBack()
    end
end

local function DoGuideEndCallBack(self)
    if self.guideEndCallBack ~= nil then
        local callback = self.guideEndCallBack
        self.guideEndCallBack = nil
        callback()
    end
end

local function SetMidCallBack(self, id, callBack)
    self.midCallBackId = id
    self.midCallBack = callBack
end

--检测主城迁世界加入联盟引导
local function CheckMoveToWorldGuide(self)
    if LuaEntry.Player:IsInAlliance() then
        self:CheckDoTriggerGuide(GuideTriggerType.MoveToWorldJoinAlliance, MoveToWorldJoinAllianceType.Join)
    else
        self:CheckDoTriggerGuide(GuideTriggerType.MoveToWorldJoinAlliance, MoveToWorldJoinAllianceType.No)
    end
end

local function CheckNoInput(self)
    local template = self:GetCurTemplate()
    if template ~= nil and template.forcetype == GuideForceType.Force then
        local guideType = template.type
        if guideType == GuideType.ClickButton or guideType == GuideType.ClickButtonNew
                or guideType == GuideType.LLHangUpBubble or guideType == GuideType.LLFirstPayRewardBubble 
                or guideType == GuideType.TalkTaskObjBubble or guideType == GuideType.LLVIPPayRewardBubble
                or guideType == GuideType.TriggerOrNpcEventBubble or guideType == GuideType.TalkTaskNpcBubbleClick
                or guideType == GuideType.PoliceInsigniaPointer or guideType == GuideType.PoliceInsigniaSubPointer
                or guideType == GuideType.ClickBuild or guideType == GuideType.QueueBuild or guideType == GuideType.Bubble
                or guideType == GuideType.PlayLadyBubble or guideType == GuideType.CityGarbage or guideType == GuideType.GotoMoveBubble
                or guideType == GuideType.OpenFog or guideType == GuideType.ClickBuildFinishBox or guideType == GuideType.ClickTime
                or guideType == GuideType.BuildRoad or guideType == GuideType.DragCityTroop or guideType == GuideType.ClickMonster
                or guideType == GuideType.ClickTimeLineBubble or guideType == GuideType.ClickCityPointType
                or guideType == GuideType.ClickLandLockBubble or guideType == GuideType.ClickCollectResource
                or guideType == GuideType.CollectUISpecialGuide or guideType == GuideType.ClickLandLockRewardBox
                or guideType == GuideType.PveShowBattleSpeedBtn or guideType == GuideType.PveShowBattleFinishBtn
                or guideType == GuideType.PveShowBattlePowerLight or guideType == GuideType.PveShowBattleBloodLight
                or guideType == GuideType.ClickRadarMonster or guideType == GuideType.ClickMonsterReward
                or guideType == GuideType.PveShowStaminaLight or guideType == GuideType.ClickPveTriggerBubble 
                or guideType == GuideType.ClickWoundedCompensateBubble or guideType == GuideType.IntroBubble1 
                or guideType == GuideType.Factory or guideType == GuideType.MoveBagViewItem 
                or guideType == GuideType.IntroBubble or guideType == GuideType.ShowBoxBubble 
                or guideType == GuideType.OpenBuildList or guideType == GuideType.GoToMainCityArea
                or guideType == GuideType.ClickGarbageTrigger or guideType == GuideType.ClickHero
                or guideType == GuideType.LoveNewsletter_hero or guideType == GuideType.LoveNewsletter_heroStory then
            EventManager:GetInstance():Broadcast(EventId.UINoInput, UINoInputType.Close)
        elseif guideType == GuideType.ClickQuest or guideType == GuideType.PlantAnimal
                or guideType == GuideType.WaitCloseUI or guideType == GuideType.UnlockBtn
                or guideType == GuideType.PlantFarm or guideType == GuideType.GetFarm or guideType == GuideType.ClickQuickBuildBtn
                or guideType == GuideType.ShowBuildRoadAnim or guideType == GuideType.ClickGolloesCanSubmitOrder or guideType == GuideType.ClickRadarBubble
                or guideType == GuideType.ClickUISpecialBtn or guideType == GuideType.WaitQuestionEnd or guideType == GuideType.ShowFakeHero
                or guideType == GuideType.AlliancePanelGuide or guideType == GuideType.ClickBagItem or guideType == GuideType.ClickRecycleItem then
            EventManager:GetInstance():Broadcast(EventId.UINoInput, UINoInputType.ShowNoScene)
        else
            EventManager:GetInstance():Broadcast(EventId.UINoInput, UINoInputType.ShowNoUI)
        end
    else
        EventManager:GetInstance():Broadcast(EventId.UINoInput, UINoInputType.Close)
    end
end

local function CheckStopDub(self)
    local template = self:GetCurTemplate()
    if self.dubId ~= nil and (template == nil or template.dub == nil or template.dub == "") then
        CS.GameEntry.Sound:StopSound(self.dubId)
        self.dubId = nil
        self.dubName = nil
    end
end

local function CheckPlayDub(self)
    local template = self:GetCurTemplate()
    if template ~= nil and template.dub ~= nil and template.dub ~= "" and template.dub ~= self.dubName then
        self:PlayDub(template.dub)
    end
end

local function StopDub(self)
    if self.dubId ~= nil then
        CS.GameEntry.Sound:StopSound(self.dubId)
        self.dubId = nil
        self.dubName = nil
    end
end

local function PlayDub(self, name)
	name = tostring(name)
    if self.dubId ~= nil then
        CS.GameEntry.Sound:StopSound(self.dubId)
    end
    self.dubName = name
    self.dubId = CS.GameEntry.Sound:PlayDub(name)
end

local function CheckCanDragGuide(self, inputTilePos, para1)
    local splist = string.split_ss_array(para1, ",")
    if #splist > 1 then
        local tilePos = {}
        local mainPos = BuildingUtils.GetMainPos()
        tilePos.x = mainPos.x + tonumber(splist[1])
        tilePos.y = mainPos.y + tonumber(splist[2])
        local inputTile = {}
        inputTile.x = inputTilePos.x
        inputTile.y = inputTilePos.y
        local list = BuildingUtils.GetAllNeighborsPos(tilePos, 2)
        if list ~= nil and list[tilePos] ~= nil and tilePos.x == inputTile.x and tilePos.y == inputTile.y then
            return true
        end
    end
end

local function CheckTipsWaitTime(self)
    if self.template ~= nil and self.template.tipswaittime > 0 then
        self:AddTipsWaitTimeTimer(self.template.tipswaittime / 1000)
    else
        self:TipsWaitTimeCallBack()
    end
end

local function DeleteTipsWaitTimeTimer(self)
    if self.tipsWaitTimeTimer ~= nil then
        self.tipsWaitTimeTimer:Stop()
        self.tipsWaitTimeTimer = nil
    end
end

local function AddTipsWaitTimeTimer(self, time)
    self:DeleteTipsWaitTimeTimer()
    if self.tipsWaitTimeTimer == nil then
        self.tipsWaitTimeTimer = TimerManager:GetInstance():GetTimer(time, self.tips_wait_time_timer_action, self, true, false, false)
        self.tipsWaitTimeTimer:Start()
    end
end

local function TipsWaitTimeCallBack(self)
    self:DeleteTipsWaitTimeTimer()
    if self.template.tipspic ~= nil and self.template.tipspic ~= "" then
        local param = {}
        param.modelName = self.template.tipspic
        if self.template.tipsdialog ~= nil and self.template.tipsdialog ~= "" then
            param.dialog = Localization:GetString(self.template.tipsdialog)
        end
        if self.template.tipsdirection ~= nil and self.template.tipsdirection ~= "" then
            param.modelPosition = tonumber(self.template.tipsdirection)
        end
        if not UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIGuideHeadTalk) then
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIGuideHeadTalk, { anim = true, playEffect = false }, param)
        else
            EventManager:GetInstance():Broadcast(EventId.RefreshUIGuideHeadTalk, param)
        end
    end
end

--检测低模状态下的电影镜头
function GuideManager:CheckZoom()
    ----不在主城中不走下面
    --if not SceneManager.IsInHome() then
        --return
    --end
    --local _level = SceneManager.GetLevel()
    --if _level == nil then return end
    ---- 这个地方强制做一个篝火的处理,在引导中只做压低,timeline结束后拉起
    --local _zoom = self.template.zoom
    --local _tabZoom = string.string2array_f(_zoom, ';')
    --local _zoomType = _tabZoom[1] or 0
    --local _zoomPara = _tabZoom[2]
    --if Mathf.Approximately(3, _zoomType) then
        --_level:EnterBorfire() 
        --return
    --end

    ----填1表示进行这一步时，先压低镜头至电影视角，再进行功能
    ----填2表示进行这一步时，先进行功能，再抬回镜头至普通视角
    ---- 特殊处理：当next id =-1时，如果没配zoom=2，则默认抬回普通视角 10121034
    ----Logger.LogError("template.id = "..self.template.id.. " template.zoom = "..self.template.zoom.." template.nextid = "..self.template.nextid.." LastZoom = "..self.LastZoom)
    --if self.template.nextid == -1 then
        ----最后一步,上一次镜头没变成普通视角，需要变回来，如果之前已经变回来了，就不用在变一次了
        --if self.LastZoom == 1 then
            --DataCenter.BattleLevel:ResumeFromFirstView()
        --end
        --self.LastZoom = 2
    --else
        --if Mathf.Approximately(1, _zoomType) then
            --if self.LastZoom ~= _zoomType then
                --DataCenter.BattleLevel:MoveToFirstView(_zoomPara)
                --self.LastZoom = _zoomType
            --end
        --elseif Mathf.Approximately(2, _zoomType) then
            --if self.LastZoom ~= _zoomType then
                --DataCenter.BattleLevel:ResumeFromFirstView()
                --self.LastZoom = _zoomType
            --end
        --end
    --end
end

local function CallBackDoGuide(self)
    self:CheckNoInput()
    --self:CheckPlayDub()
    if self.template == nil then
        return
    end

    if self:IsGuideArrowType() then
        if GuideItem then
            GuideItem.DoGuideArrowType(self)
        end
        return
    end

    self:CheckZoom()

    local fn = GuideItem and GuideItem[self.template.type]
    if fn then
        fn(self)
    else
        print("guide type not found :" .. tostring(self.template.type))
    end
	
    return

end

local function ShowGuideHand(self)

end

local function RemoveGuideHand(self)

end

local function LookBackToCharacter(self)

end

local function ShowLog(self, ...)
    if self.isDebug then
        Logger.Log(...)
    end
end

local function DoJump(self)
    if self.template ~= nil and self.template.jumpid ~= 0 then
        self:SetCurGuideId(self.template.jumpid)
        self:DoGuide()
    end
end

local function IsDragGuide(self)
    if self.template ~= nil and self.template.forcetype == GuideForceType.Force then
        if self.template.type == GuideType.Factory or self.template.type == GuideType.MoveBagViewItem then
            return true
        end
    end
    return false
end

local function SetNoGotoTime(self, isGo)
    self.noGotoTime = isGo
end

local function TrainingArmySignal(signal)
    if signal:ContainsKey("queueType") then
        local queueType = signal:GetInt("queueType")
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.NoFreeQueue, tostring(queueType))
    end
end

local function ClickMuchStop(self)
    local guideType = self:GetGuideType()
    if guideType ~= GuideType.PlayMovie and guideType ~= GuideType.WaitMovieComplete
            and guideType ~= GuideType.ShowTalk and guideType ~= GuideType.ShowBlackUI and guideType ~= GuideType.MoveCamera
            and guideType ~= GuideType.ShowChapterAnim and guideType ~= GuideType.ClickTimeLineBubble
            and guideType ~= GuideType.Wastelan_ResetManState and guideType ~= GuideType.ClickPveTriggerBubble
            and guideType ~= GuideType.PrologueShowNpc then
        local id = self.guideId
        if id ~= nil then
            self:DoMuchStopJumpGuide()
            local guideName = StatTTType.JumpGuideId .. id
            if self:GetSaveGuideValue(guideName) ~= SaveGuideDoneValue then
                self:SendSaveGuideMessage(guideName, SaveGuideDoneValue)
                self:SendLogMessage(tostring(id), StatTTType.JumpGuideId)
            end
            DataCenter.GuideManager:SetCurGuideId(GuideClickEndId)
            DataCenter.GuideManager:DoGuide()
        end
    end
end

local function SendLogToNet(self, guideName, recordType)
    if self:GetSaveGuideValue(guideName) ~= SaveGuideDoneValue then
        self:SendSaveGuideMessage(guideName, SaveGuideDoneValue)
        self:SendLogMessage(guideName, recordType)
        self:ShowLog("shimin ------------------------- SendLogToNet  " .. guideName)
    end
end

local function BuildLackConnectSignal(uuid)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.NeedConnect, SaveGuideDoneValue)
end

local function CheckPlayerLevelGuide(self, lastLevel)
    if not self:InGuide() then
        local curLevel = DataCenter.PlayerLevelManager:GetLevel()
        if lastLevel == nil or lastLevel == "" then
            lastLevel = 1
        else
            lastLevel = tonumber(lastLevel)
        end
        if curLevel > lastLevel then
            local needSave = true
            for i = lastLevel, curLevel, 1 do
                local next = i + 1
                local cur = tostring(i)
                if self:CheckDoTriggerGuide(GuideTriggerType.PlayerLevel, cur) then

                    needSave = false
                    self:SetGuideEndCallBack(function()
                        self:SendSaveGuideMessage(SaveTriggerGuidePlayerLevel, cur)
                        self:CheckPlayerLevelGuide(next)
                    end)
                    break
                end
            end
            if needSave then
                self:SendSaveGuideMessage(SaveTriggerGuidePlayerLevel, tostring(curLevel))
            end
        end
    end
end

local function UpdateScienceDataSignal(scienceId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.Science, tostring(scienceId))
end

--是否显示商业中心气派
local function IsShowBusinessBubble(self)
    return DataCenter.GuideManager:GetSaveGuideValue(SaveNoShowBusinessBubble) ~= SaveGuideDoneValue
end

--是否显示商业中心飞机
local function IsShowBusinessPlane(self)
    return DataCenter.GuideManager:GetSaveGuideValue(SaveNoShowBusinessPlaneArrive) ~= SaveGuideDoneValue
end

--当点击15下后，停止引导，期间没有做完的特殊类型要处理
local function DoMuchStopJumpGuide(self)
    EventManager:GetInstance():Broadcast(EventId.GuideBreak, self.guideId)
    local chapterId = DataCenter.ChapterTaskManager:GetCurChapterId()
    if chapterId ~= nil and chapterId <= GuideJumpUnlockBtnChapterId then
        for k, v in ipairs(GuideJumpUnlockBtnType) do
            local template = DataCenter.UnlockBtnTemplateManager:GetUnlockBtnTemplate(v)
            if template ~= nil then
                for k1, v1 in ipairs(template.unlock_noviceboot) do
                    if not self:IsDoneThisGuide(v1) then
                        self:SendSaveGuideMessage(self:GetDoneGuideEndId(v1), SaveGuideDoneValue)
                        EventManager:GetInstance():Broadcast(EventId.GuideSaveId)
                        EventManager:GetInstance():Broadcast(EventId.ShowUnlockBtn, v)
                    end
                end
            end
        end
    else
        local guideId = self.guideId
        local template = nil
        while (guideId ~= GuideEndId) do
            template = DataCenter.GuideTemplateManager:GetGuideTemplate(guideId)
            if template == nil then
                guideId = GuideEndId
            else
                if template.type == GuideType.UnlockBtn then
                    if not self:IsDoneThisGuide(template.savedoneid) then
                        self:SendSaveGuideMessage(self:GetDoneGuideEndId(template.savedoneid), SaveGuideDoneValue)
                        EventManager:GetInstance():Broadcast(EventId.GuideSaveId)
                    end
                    local unlockType = tonumber(template.para1)
                    EventManager:GetInstance():Broadcast(EventId.ShowUnlockBtn, unlockType)
                elseif template.type == GuideType.DoUIMainAnim then
                    if template.para1 ~= nil then
                        local showUIMainType = tonumber(template.para1)
                        if showUIMainType == GuideUIMainShowType.Hide then
                            self:SetNoShowUIMain(true)
                        elseif showUIMainType == GuideUIMainShowType.Show then
                            self:SetNoShowUIMain(false)
                        end
                    end
                elseif template.type == GuideType.WaitMarchFightEnd then
                    self:SetNoShowUIMain(false)
                elseif template.type == GuideType.WaitGolloesArrived then
                    self:SetNoShowUIMain(false)
                elseif template.type == GuideType.SetAllVisible then
                    self:SetNoShowUIMain(false)
                    DataCenter.BuildBubbleManager:ShowBubbleNode()
                    DataCenter.WoundedCompensateManager:AddWoundedBubble()
                    DataCenter.NpcTaskBubbleManager:AddTaskBubble()
                    DataCenter.NpcQAManager:SetNpcQAVisible(true)
                elseif template.type == GuideType.PlayMovie then
                    
                end
                guideId = template.nextid
            end
        end
    end
end

local function StopAllEffectSound(self)
    if self.effectSound ~= nil then
        for k, v in pairs(self.effectSound) do
            CS.GameEntry.Sound:StopSound(v)
        end
        self.effectSound = {}
    end
end

local function RefreshObject(self)
    self.obj = nil
    self.objWorldPos = nil
    self:DoGuide()
end

--是否可以放置建筑
local function IsSendBuildPlace(self)
    return DataCenter.GuideManager:GetSaveGuideValue(SaveNoSendPlaceBuild) ~= SaveGuideDoneValue
end

--是否在序章
local function IsShowPrologue(self)
    --return DataCenter.BuildManager:IsInNewUserWorld()
    return false
end


local function HospitalUpdateSignal()
    DataCenter.GuideManager:CheckTreatSoldierGuide()
end

local function CheckTreatSoldierGuide(self)
    if DataCenter.HospitalManager:IsHaveInjuredSolider() then
        self:CheckDoTriggerGuide(GuideTriggerType.TreatSoldier, SaveGuideDoneValue)
    end
end

local function IsCanShowQuest(self)
    if self.template == nil or self.template.type == GuideType.FakeQuest or
            ((self.template.type == GuideType.ClickButton or self.template.type == GuideType.ClickButtonNew) and string.contains(self.template.para1, "questObj")) then
        if not DataCenter.RecommendShowManager:IsHaveShowRecommend() then
            return true
        end
    end
    return false
end

local function GetFakeQuest(self)
    return self.fakeQuest
end

local function ClearFakeQuest(self)
    self.fakeQuest = nil
end

--是否可以显示地块气泡
local function CanShowLandLockBubble(self)
    return DataCenter.GuideManager:GetSaveGuideValue(NoShowLandLockBubble) ~= SaveGuideDoneValue
end

--初始化需要保存特殊处理的trigger
local function InitSpecialTrigger(self)
    --同一关卡内触发
    local triggerType = GuideTriggerType.PveOwnRes
    local list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            local spl = string.split_ss_array(k, "|")
            if table.count(spl) > 1 then
                local pveId = tonumber(spl[1])
                if self.pveTrigger[pveId] == nil then
                    self.pveTrigger[pveId] = {}
                end
                local param = {}
                param.triggerType = triggerType
                param.triggerPara = k
                param.needRes = {}
                local spl2 = string.split_ss_array(spl[2], ";")
                for k1, v1 in ipairs(spl2) do
                    local spl3 = string.split_ii_array(v1, ",")
                    local spl3Count = table.count(spl3)
                    if spl3Count > 1 then
                        local need = {}
                        need.resType = spl3[1]
                        need.count = spl3[2]
                        table.insert(param.needRes, need)
                    end
                end
                table.insert(self.pveTrigger[pveId], param)
            end
        end
    end

    --所有关卡内触发
    triggerType = GuideTriggerType.PveEnterBattle
    list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            if self.specialTriggerGuide[triggerType] == nil then
                self.specialTriggerGuide[triggerType] = {}
            end
            local param = {}
            param.triggerType = triggerType
            param.triggerPara = k
            param.triggers = string.split_ss_array(k, ";")
            table.insert(self.specialTriggerGuide[triggerType], param)
        end
    end

    triggerType = GuideTriggerType.FinishBattleLevel
    list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            if self.specialTriggerGuide[triggerType] == nil then
                self.specialTriggerGuide[triggerType] = {}
            end
            local param = {}
            param.triggerType = triggerType
            param.triggerPara = k
            param.triggers = {}
            local spl = string.split_ss_array(k, ";")
            for k1, v1 in ipairs(spl) do
                local spl1 = string.split_ii_array(v1, ",")
                local spl1Count = table.count(spl1)
                if spl1Count > 1 and spl1[1] <= spl1[2] then
                    for i = spl1[1], spl1[2], 1 do
                        table.insert(param.triggers, i)
                    end
                elseif spl1Count == 1 then
                    table.insert(param.triggers, spl1[1])
                end
            end
            table.insert(self.specialTriggerGuide[triggerType], param)
        end
    end

    triggerType = GuideTriggerType.Quest
    list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            if self.specialTriggerGuide[triggerType] == nil then
                self.specialTriggerGuide[triggerType] = {}
            end
            local param = {}
            param.triggerType = triggerType
            param.triggerPara = k
            param.triggers = string.split_ss_array(k, ";")
            table.insert(self.specialTriggerGuide[triggerType], param)
        end
    end
    
    triggerType = GuideTriggerType.HeroEquippedGet 
    list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            if self.specialTriggerGuide[triggerType] == nil then
                self.specialTriggerGuide[triggerType] = {}
            end
            local param = {}
            param.triggerType = triggerType
            param.triggerPara = k
            table.insert(self.specialTriggerGuide[triggerType], param)
        end
    end
end

local function GetSpecialTriggerPara(self, triggerType, triggerPara)
    local list = self.specialTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in ipairs(list) do
            if triggerType == GuideTriggerType.PveEnterBattle or triggerType == GuideTriggerType.Quest then
                for k1, v1 in ipairs(v.triggers) do
                    if v1 == triggerPara then
                        return v.triggerPara
                    end
                end
            elseif triggerType == GuideTriggerType.FinishBattleLevel then
                local numTriggerPara = tonumber(triggerPara)
                for k1, v1 in ipairs(v.triggers) do
                    if v1 == numTriggerPara then
                        return v.triggerPara
                    end
                end
            end
        end
    end

    return triggerPara
end


local function OnScienceQueueResearchSignal(data)
    if data:ContainsKey("itemId") then
        local scienceType = data:GetInt("itemId")
        local curLevel = DataCenter.ScienceManager:GetScienceLevel(scienceType)
        DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.StartScience, tostring(scienceType + curLevel))
    end

end

local function IsOnRadarMoveAndClickCamera(self)
    if self:InGuide() and self.template ~= nil and self.template.id == 20008014 then
        return true
    end
    return false
end


--加工厂是否可以免费加速
local function IsFactoryFirstFreeSpeed(self)
    return DataCenter.GuideManager:GetSaveGuideValue(FactoryFirstFreeSpeed) == SaveGuideDoneValue
end

--是否能显示奖励
local function IsCanShowReward(self)
    if self:InGuide() and self.template.type ~= GuideType.ShowFakeHero 
            and self.template.type ~= GuideType.WaitQuestionEnd 
            and self.template.type ~= GuideType.WaitCloseUI
            and self.template.type ~= GuideType.DoEndGuideCallBack then
        print("****dfw: landId recv: curguideid:  " .. tostring(self.template.id))
        return false
    end
    return true
end
--设置是否成功出征标志
local function SetSuccessMarchFlag(self, flag)
    self.successMarchFlag = flag
end

local function StartAttackMonsterWithoutMsgTipSignal(flag)
    DataCenter.GuideManager:SetSuccessMarchFlag(tonumber(flag))
end

--是否显示雷达气泡
local function IsShowRadarBubble(self)
    return DataCenter.GuideManager:GetSaveGuideValue(GuideNoShowRadarBubble) ~= SaveGuideDoneValue
end

--是否显示世界垃圾点
local function IsShowWorldCollectPoint(self)
    return self:GetSaveGuideValue(GuideNoShowCollectPoint) ~= SaveGuideDoneValue
end

--是否是否能砍东西
local function IsPrologueCanAttack(self)
    return self:GetSaveGuideValue(PrologueNoAttack) ~= SaveGuideDoneValue
end

--是否是引导手指点击类型
local function IsGuideArrowType(self)
    return self.template ~= nil and (self.template.type == GuideType.ClickButton
            or self.template.type == GuideType.PoliceInsigniaSubPointer or self.template.type == GuideType.LLHangUpBubble
            or self.template.type == GuideType.LLFirstPayRewardBubble or self.template.type == GuideType.LLVIPPayRewardBubble
            or self.template.type == GuideType.ClickButtonNew or self.template.type == GuideType.ClickBuild
            or self.template.type == GuideType.TalkTaskNpcBubbleClick
            or self.template.type == GuideType.QueueBuild or self.template.type == GuideType.Bubble or self.template.type == GuideType.PlayLadyBubble
            or self.template.type == GuideType.CityGarbage or self.template.type == GuideType.GotoMoveBubble
            or self.template.type == GuideType.OpenFog or self.template.type == GuideType.ClickQuest
            or self.template.type == GuideType.ClickBuildFinishBox or self.template.type == GuideType.ClickTime
            or self.template.type == GuideType.ClickQuickBuildBtn or self.template.type == GuideType.ClickMonster
            or self.template.type == GuideType.ClickTimeLineBubble or self.template.type == GuideType.ClickCityPointType
            or self.template.type == GuideType.ClickGolloesCanSubmitOrder or self.template.type == GuideType.ClickRadarBubble
            or self.template.type == GuideType.ClickUISpecialBtn or self.template.type == GuideType.ClickLandLockBubble
            or self.template.type == GuideType.ClickCollectResource or self.template.type == GuideType.ClickLandLockRewardBox
            or self.template.type == GuideType.ClickRadarMonster or self.template.type == GuideType.ClickMonsterReward
            or self.template.type == GuideType.ClickPveTriggerBubble or self.template.type == GuideType.ClickWoundedCompensateBubble
            or self.template.type == GuideType.ClickBagItem or self.template.type == GuideType.ShowSLGArea
            or self.template.type == GuideType.ClickRecycleItem or self.template.type == GuideType.PoliceInsigniaPointer
            or self.template.type == GuideType.LLHangUpBubble or self.template.type == GuideType.TriggerOrNpcEventBubble
            or self.template.type == GuideType.TriggerOrNpcEventBubble
            or self.template.type == GuideType.TalkTaskObjBubble or self.template.type == GuideType.TalkTaskNpcBubbleClick
            or self.template.type == GuideType.LoveNewsletter_hero or self.template.type == GuideType.LoveNewsletter_heroStory
            or self.template.type == GuideType.ClickHero)
end

function GuideManager:IsOnPoliceInsigniaPointer()
    return self.template ~= nil and self.template.type == GuideType.PoliceInsigniaPointer
end

function GuideManager:IsOnLLHangUpBubble()
    return self.template ~= nil and self.template.type == GuideType.LLHangUpBubble
end

function GuideManager:IsOnLLFirstPayRewardBubble()
    return self.template ~= nil and self.template.type == GuideType.LLFirstPayRewardBubble
end

function GuideManager:IsVipBubble()
    return self.template ~= nil and self.template.type == GuideType.LLVIPPayRewardBubble
end

function GuideManager:IsOnEventBubbleGuide()
    return self.template ~= nil and self.template.type == GuideType.TriggerOrNpcEventBubble
end

local function IsGuideClickBuildType(self)
    return self.template ~= nil and  (self.template.type == GuideType.ClickBuild 
            or self.template.type == GuideType.PoliceInsigniaPointer
            or self.template.type == GuideType.LLHangUpBubble
            or self.template.type == GuideType.LLFirstPayRewardBubble
            or self.template.type == GuideType.TalkTaskObjBubble
            or self.template.type == GuideType.ClickBuildFinishBox
            or self.template.type == GuideType.LLVIPPayRewardBubble
    )
end

local function IsGuideIntroType(self)
    return self.template ~= nil and (self.template.type == GuideType.IntroBubble or self.template.type == GuideType.IntroBubble1)
end

--登录判断
local function CheckLoginGuide(self)
    --登录触发
    local triggerType = GuideTriggerType.Login
    local list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            local saveId = tonumber(v)
            if not self:IsDoneThisGuide(saveId) then
                local template = DataCenter.GuideTemplateManager:GetGuideTemplate(v)
                if template ~= nil then
                    --判断跳过条件 满足就保存
                    local state = self:GetCanDoGuideState(v)
                    if state == GuideCanDoType.Yes then
                        self:SendSaveGuideMessage(self:GetDoneGuideEndId(saveId), SaveGuideDoneValue)
                        EventManager:GetInstance():Broadcast(EventId.GuideSaveId)
                    end
                end
            end
        end
    end
end

local function UpdateAlCanBeLeaderSignal()
    local template = DataCenter.GuideManager:GetCurTemplate()
    if template ~= nil then
        if template.type == GuideType.CheckBecomeAllianceLeader then
            if DataCenter.AllianceLeaderManager:CheckCanBeLeader() then
                DataCenter.GuideManager:SetCurGuideId(tonumber(template.para1))
                DataCenter.GuideManager:DoGuide()
            else
                DataCenter.GuideManager:SetCurGuideId(tonumber(template.para2))
                DataCenter.GuideManager:DoGuide()
            end
        end
    end
end

local function GetGuideBgmName(self)
    return self:GetSaveGuideValue(GuideBgmName)
end

local function GarbageCollectStartSignal(marchUuid)
    if DataCenter.GuideManager:GetGuideType() == GuideType.WaitGolloesArrived then
        local worldMarch, formationInfo = DataCenter.GolloesCampManager:GetGolloesMarchByType(GolloesType.Explorer)
        if worldMarch and worldMarch.targetUuid == marchUuid then
            CS.SceneManager.World.marchUuid = 0
            DataCenter.WorldMarchDataManager:TrackMarch(0)
            EventManager:GetInstance():Broadcast(EventId.UIMAIN_VISIBLE, true)
            DataCenter.GuideManager:DoNext()
        end
    end
end

--如果当前在pve或者打开界面要等到回到主城且界面关闭后才能触发
local function CheckNeedWaitTriggerGuide(self, triggerType, triggerParam)
    if self:InGuide() or DataCenter.BattleLevel:IsInBattleLevel() or UIManager:GetInstance():HasWindow() or not SceneManager.IsInCity() then
        self:AddOneWaitTrigger(triggerType, triggerParam)
    else
        DataCenter.GuideManager:CheckDoTriggerGuide(triggerType, triggerParam)
    end
end

local function AddOneWaitTrigger(self, triggerType, triggerParam)
    for k, v in ipairs(self.waitTrigger) do
        if v.triggerType == triggerType and v.triggerParam == triggerParam then
            return
        end
    end
    local param = {}
    param.triggerType = triggerType
    param.triggerParam = triggerParam
    table.insert(self.waitTrigger, param)
end

local function RemoveOneWaitTrigger(self, triggerType, triggerParam)
    for k, v in ipairs(self.waitTrigger) do
        if v.triggerType == triggerType and v.triggerParam == triggerParam then
            table.remove(self.waitTrigger, k)
            return
        end
    end
end

local function DoWaitTriggerAfterBack(self)
    for k, v in ipairs(self.waitTrigger) do
        self:CheckNeedWaitTriggerGuide(v.triggerType, v.triggerParam)
    end
end

local function IsSoftGuide(self)
    if self.template ~= nil and self.template.forcetype == GuideForceType.Soft then
        return true
    end
    return false
end

local function IsCameraCanFollow(self)
    local isCameraCanFollow = true
    if self.guideId ~= GuideEndId and self.template ~= nil then
        if self.template.type == GuideType.MoveCamera then
            isCameraCanFollow = false
        end
        if self.template.type == GuideType.ShowOverheadDialog then
            if self.template.para1 ~= nil and self.template.para1 ~= "" then
                local dialogType = tonumber(self.template.para1)
                if dialogType == GuideOverheadDialogType.Trigger then
                    isCameraCanFollow = false
                end
            end
        end
    end
    return isCameraCanFollow
end

local function GetCanDoGuideState(self, id)
    --return self.checkJumpState:GetCanDoGuideState(id)
    return nil
end

local function GetTimeOfDayState(self)
    local state = Setting:GetPrivateInt("Guide_TimeOfDayState", -1)
    Logger.Log('#WeatherControl# GetTimeOfDayState state:' .. tostring(state))
    return state
end

local function SaveTimeOfDayState(self, state)
    Logger.Log('#WeatherControl# SaveTimeOfDayState state:' .. tostring(state))

    state = tonumber(state)
    Setting:SetPrivateInt("Guide_TimeOfDayState", state)
end

function GuideManager:SaveWeatherGuideState(state)
    Logger.Log('#WeatherControl# SaveWeatherGuideState state:' .. tostring(state))
    state = tonumber(state)
    Setting:SetPrivateInt("Guide_WeatherRecord", state)
end

function GuideManager:GetWeatherGuideState()
    local state = Setting:GetPrivateInt("Guide_WeatherRecord", -1)
    return state
end

local function IsShouldPauseRole(self)
    local template = self:GetCurTemplate()
    return template and (template.type == GuideType.PlayMovie or template.pause == 1)
end

-- 等待引导查找定时器的最大时间
--function GuideManager:AddWaitLongDelayTimer(time)
    --self:DeleteWaitLongDelayTimer()
    --if self.waitLongDelayTimer == nil then
        --self.waitLongDelayTimer = TimerManager:GetInstance():GetTimer(time, self.wait_long_delay_timer_callback , self, true,false,false)
        --self.waitLongDelayTimer:Start()
    --end
--end

--function GuideManager:DeleteWaitLongDelayTimer()
    --if self.waitLongDelayTimer ~= nil then
        --self.waitLongDelayTimer:Stop()
        --self.waitLongDelayTimer = nil
    --end
--end

---- 当等待最长时间的定时器触发时，引导中断（-2）
--function GuideManager:WaitLongDelayTimerCallBack()
    --self:DeleteWaitLongDelayTimer()
    ----直接结束引导
    --if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIGuideLoadMask) then
        --UIManager:GetInstance():DestroyWindow(UIWindowNames.UIGuideLoadMask,OpenWinAnimTrue)
    --end
    --if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIGuideLoadBlackMask) then
        --UIManager:GetInstance():DestroyWindow(UIWindowNames.UIGuideLoadBlackMask,OpenWinAnimTrue)
    --end
    --self:SetCurGuideId(GuideTestEndId)
    --self:DoGuide()
--end


local function CheckTriggerGuide(self, triggerId)
    self:CheckTriggerTypeGuide(GuideTriggerType.Trigger, triggerId)
end

local function IsShowPlantarArrow(self)
    return self.showPlantarArrow
end

local function CheckNewItemGuide(self, itemId)
    self:CheckTriggerTypeGuide(GuideTriggerType.NewItem, itemId)
end

local function CheckTalentGuide(self, talentId)
    self:CheckTriggerTypeGuide(GuideTriggerType.Talent, talentId)
end

local function CheckDebugGuide(self, debugId)
    self:CheckTriggerTypeGuide(GuideTriggerType.Debug, debugId)
end

local function CheckTriggerTypeGuide(self, triggerType, param)
    local list = self.allTriggerGuide[triggerType]
    if list ~= nil then
        for k, v in pairs(list) do
            local params = string.split_ii_array(k, ";")
            for i = 1, #params do
                local temp_param = params[i]
                local equalParam = false
                local saveId = tonumber(v)
                if triggerType == GuideTriggerType.LMPlayerBlood then
                    equalParam = temp_param >= tonumber(param)
                elseif triggerType == GuideTriggerType.ClickSeasonDesertLevel then
                    equalParam = temp_param <= tonumber(param)
                else
                    equalParam = temp_param == tonumber(param)
                end
                if equalParam and not self:IsDoneThisGuide(saveId) then
                    local template = DataCenter.GuideTemplateManager:GetGuideTemplate(v)
                    if template ~= nil then
                        local state = self:GetCanDoGuideState(v)
                        if state == GuideCanDoType.Yes then
                            self:SendSaveGuideMessage(self:GetDoneGuideEndId(saveId), SaveGuideDoneValue)
                            DataCenter.GuideManager:SetCurGuideId(v)
                            DataCenter.GuideManager:DoGuide()
                            goto continue
                        else
                            local jumpid = template.jumpid
                            if jumpid ~= 0 and not self:IsDoneThisGuide(jumpid) then
                                DataCenter.GuideManager:SetCurGuideId(jumpid)
                                DataCenter.GuideManager:DoGuide()
                                goto continue
                            end
                        end
                    end
                end
            end
        end
    end
    ::continue::
end

local function CheckLMPlayerLevelGuide(self, level)
    self:CheckTriggerTypeGuide(GuideTriggerType.LMPlayerLevel, level)
end

local function CheckLMPlayerBloodGuide(self, blood)
    self:CheckTriggerTypeGuide(GuideTriggerType.LMPlayerBlood, blood)
end

local function CheckLMZombieDeadGuide(self, blood)
    self:CheckTriggerTypeGuide(GuideTriggerType.LMZombieDead, blood)
end

local function IsPlayerShowWeakness(self)
    local state = self:GetPlayerState()
    return state == 1
end

local function SetPlayerState(self, state)
    --state = tonumber(state)
    --Setting:SetPrivateInt("PlayerState", state)
end

local function GetPlayerState(self)
    --local state = Setting:GetPrivateInt("PlayerState", 0)
    --return state
    return 0
end

local function SetForceWalkState(self, state)
    --state = toInt(state)
    --Setting:SetPrivateInt("WalkState", state)
end

local function GetIsWalkState(self)
    --local state = Setting:GetPrivateInt("WalkState", 0)
    --return state == 1
    return false
end

--[[
    强制设置行走状态
]]
--local CharacterStateType = require("Scene.PVEBattleLevel.Character.State.CharacterStateType")
local function SetForceWalkStateNew(self, state)
    --self.WalkStateNew = string.string2table_ss(state, '|', ';')
    --self.WalkStateNew = {}
    --if (not string.IsNullOrEmpty(state)) then
    --    local _tabWalkState = string.split(state, '|')
    --    for _, v in pairs(_tabWalkState) do
    --        local _tabstr = string.split(v, ';')
    --        if table.count(_tabstr) == 2 then
    --            self.WalkStateNew[_tabstr[1]] = _tabstr[2]
    --        end
    --    end
    --end
    --
    --Setting:SetPrivateString("WalkStateNew", state)
    ---- 处理下,如果当前角色是idle状态,强制刷新下动画
    --local level = SceneManager.GetLevel()
    --if level == nil then return end
    --local player = level:GetPlayer()
    --if player == nil then return end
    --if player:GetCurrentStateType() == CharacterStateType.Default then
    --    if not string.IsNullOrEmpty(self:GetForceIdleState()) then
    --        player:PlayAnim(self:GetForceIdleState())
    --    else
    --        player:PlayAnim(player:GetDefaultAnimName())
    --    end
    --end
end

local function GetForceWalkState(self)
    --if self.WalkStateNew == nil then
    --    local str = Setting:GetPrivateString("WalkStateNew", "")
    --    self:SetForceWalkState(str)
    --end
    --return self.WalkStateNew and self.WalkStateNew["walk"] or ""
    return ""
end
local function GetForceIdleState(self)
    --if self.WalkStateNew == nil then
    --    local str = Setting:GetPrivateString("WalkStateNew", "")
    --    self:SetForceWalkState(str)
    --end
    --return self.WalkStateNew and self.WalkStateNew["idle"] or ""
    return ""
end



local function SetPlayerNotCanAttackMonster(self, state)
    --state = toInt(state)
    --Setting:SetPrivateInt("PlayerCanAttackMonster", state)
    --self.isPlayerCanAttackMonster = state == 1
    --EventManager:GetInstance():Broadcast(EventId.SU_ReAdjustJoyStickBtnStatus)
end

local function GetPlayerNotCanAttackMonster(self)
    --if self.isPlayerCanAttackMonster == nil then
    --    local state = Setting:GetPrivateInt("PlayerCanAttackMonster", 0)
    --    self.isPlayerCanAttackMonster = state == 1
    --end
    --return self.isPlayerCanAttackMonster
    return false
end

local function SetMainPlayerWearVCloth(self, cloth)
    --self.isWearVirtualCloth = not string.IsNullOrEmpty(cloth)
    --Setting:SetPrivateString("MainPlayerCloth", cloth)
end

local function GetIsMainPlayerWearVCloth(self)
    --if self.isWearVirtualCloth == nil then
    --    local _cloth = Setting:GetPrivateString("MainPlayerCloth")
    --    self.isWearVirtualCloth = not string.IsNullOrEmpty(_cloth)
    --end
    --return self.isWearVirtualCloth
    return false
end

local function GetMainPlayerVCloth(self)
    --local _cloth = Setting:GetPrivateString("MainPlayerCloth")
    --return _cloth
    return nil
end

function GuideManager:SetMainUIActive( active )
    Setting:SetPrivateBool("MainUIActive", active)
    Setting:Save()
    EventManager:GetInstance():Broadcast(EventId.SU_ActiveMainUI)
end

function GuideManager:GetMainUIActive()
    local active = Setting:GetPrivateBool("MainUIActive", true)
    return active
end

local function GetLastTriggerTime(self)
    return self.lastTriggerTime
end

local function PlayerInGuideAction(self)
    if self.template ~= nil and self.template.type == GuideType.SU_MovePlayerToRelativePos then
        return true
    end
    if self.template ~= nil and self.template.type == GuideType.PlayMovie then
        if self.template.para1 ~= nil then
            local movieType = tonumber(self.template.para1)
            if movieType == GuidePlayMovieType.SU_StartBorfire then
                return true
            end
        end
    end
    return false
end

local function IsGuideWaitCloseUIType(self)
    if self.template ~= nil and self.template.type == GuideType.WaitCloseUI then
        return true
    end
    return false
end

local function CheckUnlockNewFunctionGuide(self, funcType)
    local triggerType = GuideTriggerType.UnlockNewFunction
    local triggerPara = tostring(funcType)
    if self.allTriggerGuide[triggerType] ~= nil then
        local guideId = self.allTriggerGuide[triggerType][triggerPara]
        if guideId ~= nil and not self:IsDoneThisGuide(guideId) then
            return guideId
        end
    end
    return nil
end

function GuideManager:CheckGuideIsTalkTaskDataTriggerBubble()
    if self.template ~= nil and self.template.type == GuideType.TalkTaskNpcBubbleClick then
        return true
    end
    return false
end

local function IsPoliceInsigniaSubPointerGuide(self)
    if self.template ~= nil and self.template.type == GuideType.PoliceInsigniaSubPointer then
        return true
    end
    return false
end

local function IsPoliceInsigniaWaitSubPointerGuide(self)
    if self.template ~= nil and self.template.type == GuideType.WaitPoliceInsigniaPanelReady then
        return true
    end
    return false
end

local function IsTalkTaskObjBubble(self)
    if self.template ~= nil and self.template.type == GuideType.TalkTaskObjBubble then
        return true
    end
    return false
end

local function OnPVEBattleWinExit(param)
    if param ~= nil and param.type ~= nil and param.type == "win" then
        DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.PveBattleWinExit, param.id)
    end
end

function GuideManager:OnGoRallyBossAct()
    DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.GoRallyBossAct, 1)
end

function GuideManager:OnFastCombatTriggered()
    DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.FastCombat, 1)
end

local function OnGarbageTriggerFinished(triggerId)
    DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.GarbageTriggerFinished, triggerId)
end

local function OnTrailLevelMemberDie(levelid)
    --需要重复触发的引导不能通过CheckTriggerTypeGuide来进行触发
    --DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.OnHeroDieInBattle, levelid)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.OnHeroDieInBattle, tostring(levelid))
end

local function OnExitFromArena()
    DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.ExitFromArena, "1")
end

local function OnPVEBattleWin(id)
    DataCenter.GuideManager:CheckTriggerTypeGuide(GuideTriggerType.PveBattleShowWin, id)
end

function GuideManager:AddGuideBoxBubble(pos, bubble)
    if self.guideBoxBubbles == nil then
        self.guideBoxBubbles = {}
    end
    self.guideBoxBubbles[pos] = bubble
end

function GuideManager:GetGuideBoxBubble(pos)
    if self.guideBoxBubbles == nil then
        return nil
    end
    return self.guideBoxBubbles[pos]
end

function GuideManager:RemoveGuideBoxBubble(pos)
    if self.guideBoxBubbles and self.guideBoxBubbles[pos] then
        self.guideBoxBubbles[pos] = nil
    end
end

function GuideManager:CheckReceiveLandReward(landId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ReceiveLandReward, tostring(landId))
end

local function CheckParkourBattleStart(data)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.PveEnterBattle, tostring(data.metaId))
end

function GuideManager:IsOpenBuildList()
    return self.template ~= nil and self.template.type == GuideType.OpenBuildList
end

function GuideManager:IsWaitPoliceInsigniaPanelReady()
    return self.template ~= nil and self.template.type == GuideType.WaitPoliceInsigniaPanelReady
end

function GuideManager:CheckSelectActivityListItem(goID)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.SelectActivityListItem, tostring(goID))
end

function GuideManager:SetOnMainViewOpenDoGuideId(id)
    self.mainViewOpenDoGuideId = id
end

function GuideManager:GetOnMainViewOpenDoGuideId()
    if self.mainViewOpenDoGuideId then
        local guideId = self.mainViewOpenDoGuideId
        self.mainViewOpenDoGuideId = -1
        return guideId
    end
    return -1
end

function GuideManager:CheckOnGuidBuildFenceTimeline()
    return self.template ~= nil and self.template.type == GuideType.MainBuildGuide2
end

function GuideManager:CheckIsOnGetPoliceUI()
    return self.template ~= nil and self.template.type == GuideType.ShowGetPoliceView
end

function GuideManager:CheckIsOnUIBossRunAway()
    return self.template ~= nil and self.template.type == GuideType.ShowBossRunAway
end

function GuideManager:CheckIsOnUIGetPolicewoman()
    return self.template ~= nil and self.template.type == GuideType.ShowUIGetPolicewoman
end

function GuideManager:CheckBuyGiftGuide(itemId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.BuyGift, tostring(itemId))
end

function GuideManager:CheckReplaceTrialHero(heroId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.ReplaceTrialHero, tostring(heroId))
end

--是否免费租赁队列
function GuideManager:IsFreeLeaseBuildQueue()
    local trySec = LuaEntry.DataConfig:TryGetNum("robot_free", "k1")
    if trySec <= 0 then
        return false
    end
    
    if self:GetSaveGuideValue(FreeLeaseSecondBuildQueue) == SaveGuideDoneValue then
        return false
    end
    local count = DataCenter.BuildQueueManager:GetOwnBuildQueueCount()
    if count == 1 then
        return true
    end
    
    return false
end

--是否需要展示雷达若引导
function GuideManager:CheckRadarGuide()
    if LuaEntry.Player.abTest == ABTestType.B then
        return false
    end
    
    if self:GetSaveGuideValue(RadarGuideFlag) == SaveGuideDoneValue then
        return false
    end
    
    return true
end

--是否可以使用引导
function GuideManager:CanUseGuide()
    --判断是否始于大本废弃状态
    local mainBuild = DataCenter.BuildManager:GetFunbuildByItemID(BuildingTypes.FUN_BUILD_MAIN)
    --这里离线期间成被打飞state状态是正常，世界点也有值，但是会弹出一个被打飞提示，此刻要断掉引导
    if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UICommonMessageTip)
            or (mainBuild ~= nil and mainBuild.state == BuildingStateType.FoldUp)
            or (LuaEntry.Player:GetMainWorldPos() == 0)
            or (not DataCenter.CreditManager:GetIsNormal()) then
        return false
    end
    return true
end

function GuideManager:CheckNewHeroGuide(heroId)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.NewHero, tostring(heroId))
end

function GuideManager:CheckDetectEventFinishGuide(type)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.DetectEventFinish, tostring(type))
end

function GuideManager:ChecOnClickWorldAllianceCityGuide(level)
    DataCenter.GuideManager:CheckDoTriggerGuide(GuideTriggerType.OnClickWorldAllianceCity, tostring(level))
end

GuideManager.GetLastTriggerTime = GetLastTriggerTime
GuideManager.SetMainPlayerWearVCloth = SetMainPlayerWearVCloth
GuideManager.GetIsMainPlayerWearVCloth = GetIsMainPlayerWearVCloth
GuideManager.GetMainPlayerVCloth = GetMainPlayerVCloth
GuideManager.SetPlayerNotCanAttackMonster = SetPlayerNotCanAttackMonster
GuideManager.GetPlayerNotCanAttackMonster = GetPlayerNotCanAttackMonster
GuideManager.SetPlayerState = SetPlayerState
GuideManager.GetPlayerState = GetPlayerState
GuideManager.SetForceWalkState = SetForceWalkState
GuideManager.GetIsWalkState = GetIsWalkState
GuideManager.SetForceWalkStateNew = SetForceWalkStateNew
GuideManager.GetForceWalkState = GetForceWalkState
GuideManager.GetForceIdleState = GetForceIdleState
GuideManager.__init = __init
GuideManager.__delete = __delete
GuideManager.Startup = Startup
GuideManager.InitData = InitData
GuideManager.GetSaveGuideId = GetSaveGuideId
GuideManager.SendSaveGuideMessage = SendSaveGuideMessage
GuideManager.ClearCurGuideId = ClearCurGuideId
GuideManager.SetCurGuideId = SetCurGuideId
GuideManager.SendLogMessage = SendLogMessage
GuideManager.InGuide = InGuide
GuideManager.GetGuideId = GetGuideId
GuideManager.AddListener = AddListener
GuideManager.RemoveListener = RemoveListener
GuideManager.DoGuide = DoGuide
GuideManager.UILoadingExitSignal = UILoadingExitSignal
GuideManager.BuildPlaceSignal = BuildPlaceSignal
GuideManager.CheckGuideComplete = CheckGuideComplete
GuideManager.CheckOpenUITriggerGuide = CheckOpenUITriggerGuide
GuideManager.OpenUISignal = OpenUISignal
GuideManager.DeleteAutoNextTimer = DeleteAutoNextTimer
GuideManager.AddAutoNextTimer = AddAutoNextTimer
GuideManager.AutoNextTimeCallBack = AutoNextTimeCallBack
GuideManager.GetCurTemplate = GetCurTemplate
GuideManager.HasClick = HasClick
GuideManager.NeedWaitLoadComplete = NeedWaitLoadComplete
GuideManager.DeleteWaitLoadTimer = DeleteWaitLoadTimer
GuideManager.AddWaitLoadTimer = AddWaitLoadTimer
GuideManager.WaitLoadCallBack = WaitLoadCallBack
GuideManager.WaitTimeout = WaitTimeout
GuideManager.GetGuideType = GetGuideType
GuideManager.SetCompleteNeedParam = SetCompleteNeedParam
GuideManager.GetGuideIdByTrigger = GetGuideIdByTrigger
GuideManager.GetGuideTemplateParam = GetGuideTemplateParam
GuideManager.IsCanOpenUI = IsCanOpenUI
GuideManager.QueueTimeEndSignal = QueueTimeEndSignal
GuideManager.QueueAddSignal = QueueAddSignal
GuideManager.InitTriggerGuide = InitTriggerGuide
GuideManager.GetNextGuideTemplateParam = GetNextGuideTemplateParam
GuideManager.OnClickWorldSignal = OnClickWorldSignal
GuideManager.CityGarbageResultSignal = CityGarbageResultSignal
GuideManager.OpenFogSuccessSignal = OpenFogSuccessSignal
GuideManager.BuildUpgradeFinishSignal = BuildUpgradeFinishSignal
GuideManager.GetDoneGuideEndId = GetDoneGuideEndId
GuideManager.IsDoneThisGuide = IsDoneThisGuide
GuideManager.PlayMovieCompleteSignal = PlayMovieCompleteSignal
GuideManager.CheckDoTriggerGuide = CheckDoTriggerGuide
GuideManager.SaveFinalGarbageRewardItemId = SaveFinalGarbageRewardItemId
GuideManager.GetFinalGarbageRewardItemId = GetFinalGarbageRewardItemId
GuideManager.GetSaveGuideValue = GetSaveGuideValue
GuideManager.GetCityTroopPeopleNum = GetCityTroopPeopleNum
GuideManager.SaveCityTroopPeopleNum = SaveCityTroopPeopleNum
GuideManager.IsCanCloseUI = IsCanCloseUI
GuideManager.IsCanQuitFocus = IsCanQuitFocus
GuideManager.ChapterTaskGetRewardSignal = ChapterTaskGetRewardSignal
GuideManager.IsCanDoUIMainAnim = IsCanDoUIMainAnim
GuideManager.SetNoShowUIMain = SetNoShowUIMain
GuideManager.SetCanShowBuild = SetCanShowBuild
GuideManager.IsStartCanShowBuild = IsStartCanShowBuild
GuideManager.ShowAllGuideObjectSignal = ShowAllGuideObjectSignal
GuideManager.CloseUISignal = CloseUISignal
GuideManager.CheckNeedWaitTime = CheckNeedWaitTime
GuideManager.DeleteWaitTimeTimer = DeleteWaitTimeTimer
GuideManager.AddWaitTimeTimer = AddWaitTimeTimer
GuideManager.WaitTimeCallBack = WaitTimeCallBack
GuideManager.ChapterTaskSignal = ChapterTaskSignal
GuideManager.GetDoneGuideStartId = GetDoneGuideStartId
GuideManager.IsCanBuildRoad = IsCanBuildRoad
GuideManager.CheckFirstJoinAllianceGuide = CheckFirstJoinAllianceGuide
GuideManager.AllianceApplySuccessSignal = AllianceApplySuccessSignal
GuideManager.IsStartId = IsStartId
GuideManager.GuideNoOpenUISignal = GuideNoOpenUISignal
GuideManager.SetNoOpenUI = SetNoOpenUI
GuideManager.IsCanClick = IsCanClick
GuideManager.GuideWaitMessageSignal = GuideWaitMessageSignal
GuideManager.CheckWaitMessage = CheckWaitMessage
GuideManager.MainTaskSuccessSignal = MainTaskSuccessSignal
GuideManager.DoNext = DoNext
GuideManager.LoadGuideGm = LoadGuideGm
GuideManager.DestroyGm = DestroyGm
GuideManager.SetWaitingMessage = SetWaitingMessage
GuideManager.SaveRecommendShow = SaveRecommendShow
GuideManager.GetRecommendShow = GetRecommendShow
GuideManager.BuildResourcesStartSignal = BuildResourcesStartSignal
GuideManager.OnWorldInputPointDownSignal = OnWorldInputPointDownSignal
GuideManager.SetGuideEndCallBack = SetGuideEndCallBack
GuideManager.DoGuideEndCallBack = DoGuideEndCallBack
GuideManager.SetMidCallBack = SetMidCallBack
GuideManager.CheckMoveToWorldGuide = CheckMoveToWorldGuide
GuideManager.CheckNoInput = CheckNoInput
GuideManager.CheckStopDub = CheckStopDub
GuideManager.CheckPlayDub = CheckPlayDub
GuideManager.StopDub = StopDub
GuideManager.PlayDub = PlayDub
GuideManager.CheckCanDragGuide = CheckCanDragGuide
GuideManager.CheckTipsWaitTime = CheckTipsWaitTime
GuideManager.DeleteTipsWaitTimeTimer = DeleteTipsWaitTimeTimer
GuideManager.AddTipsWaitTimeTimer = AddTipsWaitTimeTimer
GuideManager.TipsWaitTimeCallBack = TipsWaitTimeCallBack
GuideManager.CallBackDoGuide = CallBackDoGuide
GuideManager.ShowLog = ShowLog
GuideManager.DoJump = DoJump
GuideManager.IsDragGuide = IsDragGuide
GuideManager.SetNoGotoTime = SetNoGotoTime
GuideManager.TrainingArmySignal = TrainingArmySignal
GuideManager.ClickMuchStop = ClickMuchStop
GuideManager.BuildLackConnectSignal = BuildLackConnectSignal
GuideManager.CheckPlayerLevelGuide = CheckPlayerLevelGuide
GuideManager.UpdateScienceDataSignal = UpdateScienceDataSignal
GuideManager.IsShowBusinessBubble = IsShowBusinessBubble
GuideManager.IsShowBusinessPlane = IsShowBusinessPlane
GuideManager.DoMuchStopJumpGuide = DoMuchStopJumpGuide
GuideManager.StopAllEffectSound = StopAllEffectSound
GuideManager.RefreshObject = RefreshObject
GuideManager.IsSendBuildPlace = IsSendBuildPlace
GuideManager.ShowGuideHand = ShowGuideHand
GuideManager.RemoveGuideHand = RemoveGuideHand
GuideManager.LookBackToCharacter = LookBackToCharacter
GuideManager.IsBeforePrologue = IsBeforePrologue
GuideManager.RefreshPrologueModel = RefreshPrologueModel
GuideManager.HospitalUpdateSignal = HospitalUpdateSignal
GuideManager.CheckTreatSoldierGuide = CheckTreatSoldierGuide
GuideManager.IsCanShowQuest = IsCanShowQuest
GuideManager.GetFakeQuest = GetFakeQuest
GuideManager.ClearFakeQuest = ClearFakeQuest
GuideManager.CanShowLandLockBubble = CanShowLandLockBubble
GuideManager.InitSpecialTrigger = InitSpecialTrigger
GuideManager.GetSpecialTriggerPara = GetSpecialTriggerPara
GuideManager.OnScienceQueueResearchSignal = OnScienceQueueResearchSignal
GuideManager.IsFactoryFirstFreeSpeed = IsFactoryFirstFreeSpeed
GuideManager.IsCanShowReward = IsCanShowReward
GuideManager.StartAttackMonsterWithoutMsgTipSignal = StartAttackMonsterWithoutMsgTipSignal
GuideManager.SetSuccessMarchFlag = SetSuccessMarchFlag
GuideManager.IsShowRadarBubble = IsShowRadarBubble
GuideManager.IsShowWorldCollectPoint = IsShowWorldCollectPoint
GuideManager.IsPrologueCanAttack = IsPrologueCanAttack
GuideManager.IsGuideArrowType = IsGuideArrowType
GuideManager.CheckLoginGuide = CheckLoginGuide
GuideManager.UpdateAlCanBeLeaderSignal = UpdateAlCanBeLeaderSignal
GuideManager.GetGuideBgmName = GetGuideBgmName
GuideManager.GarbageCollectStartSignal = GarbageCollectStartSignal
GuideManager.SendLogToNet = SendLogToNet
GuideManager.CheckNeedWaitTriggerGuide = CheckNeedWaitTriggerGuide
GuideManager.AddOneWaitTrigger = AddOneWaitTrigger
GuideManager.RemoveOneWaitTrigger = RemoveOneWaitTrigger
GuideManager.DoWaitTriggerAfterBack = DoWaitTriggerAfterBack
GuideManager.IsSoftGuide = IsSoftGuide
GuideManager.IsCameraCanFollow = IsCameraCanFollow
GuideManager.GetCanDoGuideState = GetCanDoGuideState
GuideManager.IsGuideIntroType = IsGuideIntroType
GuideManager.GetTimeOfDayState = GetTimeOfDayState
GuideManager.SaveTimeOfDayState = SaveTimeOfDayState
GuideManager.IsShouldPauseRole = IsShouldPauseRole
GuideManager.CheckTriggerGuide = CheckTriggerGuide
GuideManager.IsShowPlantarArrow = IsShowPlantarArrow
GuideManager.CheckNewItemGuide = CheckNewItemGuide
GuideManager.CheckTalentGuide = CheckTalentGuide
GuideManager.CheckDebugGuide = CheckDebugGuide
GuideManager.CheckTriggerTypeGuide = CheckTriggerTypeGuide
GuideManager.CheckLMPlayerLevelGuide = CheckLMPlayerLevelGuide
GuideManager.CheckLMPlayerBloodGuide = CheckLMPlayerBloodGuide
GuideManager.CheckLMZombieDeadGuide = CheckLMZombieDeadGuide
GuideManager.IsPlayerShowWeakness = IsPlayerShowWeakness
GuideManager.PlayerInGuideAction = PlayerInGuideAction
GuideManager.IsGuideClickBuildType = IsGuideClickBuildType
GuideManager.IsGuideWaitCloseUIType = IsGuideWaitCloseUIType
GuideManager.CheckUnlockNewFunctionGuide = CheckUnlockNewFunctionGuide
GuideManager.OnPVEBattleWinExit = OnPVEBattleWinExit
GuideManager.OnPVEBattleWin = OnPVEBattleWin
GuideManager.IsPoliceInsigniaSubPointerGuide = IsPoliceInsigniaSubPointerGuide
GuideManager.IsPoliceInsigniaWaitSubPointerGuide = IsPoliceInsigniaWaitSubPointerGuide
GuideManager.IsOnRadarMoveAndClickCamera = IsOnRadarMoveAndClickCamera
GuideManager.IsTalkTaskObjBubble = IsTalkTaskObjBubble
GuideManager.OnTrailLevelMemberDie = OnTrailLevelMemberDie
GuideManager.OnGarbageTriggerFinished = OnGarbageTriggerFinished
GuideManager.CheckParkourBattleStart = CheckParkourBattleStart
GuideManager.OnExitFromArena = OnExitFromArena

return GuideManager
