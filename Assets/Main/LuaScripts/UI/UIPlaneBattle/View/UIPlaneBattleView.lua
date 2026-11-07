---
--- 探险玩法 战斗 — View
--- 首期实现顺序：① 主机左右滑动 → ② 僚机自动开火 → ③ 数字门加减 → ④ 撞击/boss结算
--- 战斗内容（主机/僚机/门/桶/敌机/子弹）全部运行时动态创建，不预置在 prefab 上，
--- 参照 UIShipBackgroundView.lua 里 _CreateDebugBtn 的纯 Lua 建节点手法。
---@class UIPlaneBattleView : UIBaseView
---@field ctrl UIPlaneBattleCtrl
local UIPlaneBattleView = BaseClass("UIPlaneBattleView", UIBaseView)
local base = UIBaseView

local FormationLayout      = require "UI.UIPlaneBattle.Logic.FormationLayout"
local BattleHeroProfile    = require "UI.UIPlaneBattle.Logic.BattleHeroProfile"
local BattleFormationPanel = require "UI.UIPlaneBattle.Component.BattleFormationPanel"
local BattleResultPanel = require "UI.UIPlaneBattle.Component.BattleResultPanel"
local HeroCombatController = require "UI.UIPlaneBattle.Component.HeroCombatController"
local TriggerEventManager  = require "UI.UIPlaneBattle.Logic.TriggerEventManager"
local BulletPool           = require "UI.UIPlaneBattle.Component.BulletPool"
local SecondaryWeapon      = require "UI.UIPlaneBattle.Component.SecondaryWeapon"
local PlaneUnit            = require "UI.UIPlaneBattle.Component.PlaneUnit"
local FlightVisual         = require "UI.UIPlaneBattle.Component.FlightVisual"
local GateFeedback         = require "UI.UIPlaneBattle.Component.GateFeedback"
local GateComponent        = require "UI.UIPlaneBattle.Component.GateComponent"
local BucketComponent      = require "UI.UIPlaneBattle.Component.BucketComponent"
-- STG 运行时：时间轴/波次/门/结算由 StgBattleLogic 驱动，View 只做表现
local StgBattleLogic       = require "Game.STG.Logic.StgBattleLogic"
local StgGateFactory       = require "Game.STG.Entity.Gate.StgGateFactory"
local StgBackgroundRenderer= require "Game.STG.Render.StgBackgroundRenderer"

local GameObject     = CS.UnityEngine.GameObject
local RectTransform  = typeof(CS.UnityEngine.RectTransform)
local Image          = typeof(CS.UnityEngine.UI.Image)
local Button         = typeof(CS.UnityEngine.UI.Button)
local Text           = typeof(CS.UnityEngine.UI.Text)
local TMPText        = typeof(CS.TMPro.TextMeshProUGUI)
local TMPAlign       = CS.TMPro.TextAlignmentOptions
local Vector2        = CS.UnityEngine.Vector2
local Color          = CS.UnityEngine.Color
local UIEventTrigger = typeof(CS.UIEventTrigger)
local Resource       = CS.GameEntry.Resource

--- 美术资源目录（从 D:\UnityProject\UiSource\雷霆战机 / 冒险号 迁入，命名前缀 PlaneBattle_）
local RES_DIR = "Assets/Main/Sprites/PlaneBattle/"

--- 中文字体（HUD/引导/结算面板用），LiberationSans SDF（TMP默认）没有中文字形，
--- 动态创建的TMP文本必须手动挂这个字体。模块级缓存，跨窗口实例复用，避免重复加载。
-- 正文使用 Medium 字重；只有少数标题/数值显式加粗，避免整页中文糊成一团。
local CHINESE_FONT_PATH = "Assets/Main/Fonts/NotoSansSC-Medium SDF.asset"
local ChineseFontAsset   = nil
local ChineseFontPending = {}
local ChineseFontLoading = false

-- 可选 onReady 用于需要在首帧就展示中文的整页界面：等字体可用后再显示，
-- 避免 TMP 先用 LiberationSans 渲染成方块并留下缺字告警。
local function _RequestChineseFont(tmpComp, onReady)
    if ChineseFontAsset ~= nil then
        if tmpComp ~= nil and not IsNull(tmpComp) then
            tmpComp.font = ChineseFontAsset
        end
        if onReady ~= nil then onReady() end
        return
    end
    table.insert(ChineseFontPending, { text = tmpComp, onReady = onReady })
    if ChineseFontLoading then
        return
    end
    ChineseFontLoading = true

    local req = Resource:LoadAssetAsync(CHINESE_FONT_PATH, typeof(CS.TMPro.TMP_FontAsset))
    if req == nil then
        ChineseFontLoading = false
        return
    end
    req:completed('+', function(r)
        ChineseFontLoading = false
        if r ~= nil and r.asset ~= nil then
            local font = r.asset
            cast(font, typeof(CS.TMPro.TMP_FontAsset))
            ChineseFontAsset = font
            for _, pending in ipairs(ChineseFontPending) do
                local t = pending.text
                if t ~= nil and not IsNull(t) then
                    t.font = font
                end
                if pending.onReady ~= nil then pending.onReady() end
            end
        end
        ChineseFontPending = {}
    end)
end

--- 操作引导只在本局游戏会话里第一次进入战斗时显示一次，模块级变量跨窗口实例保留状态
local guideShownInSession = false

--- 参考画布参考分辨率 750x1625（GameFramework.prefab 里 UIContainer 的 CanvasScaler 设定）
local SAFE_HALF_WIDTH  = 300  -- 主机左右可移动范围：屏幕中心 ±300
local PLANE_SIZE       = Vector2(86, 104)
local PLANE_BOTTOM_Y   = 270  -- 底栏上方留出武器摘要与血条的间距
local WINGMAN_MAX      = 12   -- 画面最多呈现 12 架，多余数量仍保存在逻辑层
local SCREEN_HALF_W    = 375  -- 参考分辨率宽 750 的一半，出生点 x 用这个换算成像素
local SPAWN_TOP_Y      = 900  -- 内容按时间轴从这个高度开始下落
local BOTTOM_RECYCLE_Y = -900 -- 低于这个高度回收（飞出屏幕底部）
local WINGMAN_FIRE_INTERVAL = 0.5
local WINGMAN_BULLET_DAMAGE = 10
local PRIMARY_FIRE_INTERVAL = 0.22
local PRIMARY_BULLET_DAMAGE = 3 -- 主炮提供稳定基础输出，增援仍是主要火力来源。
local WEAPON_NAMES = { [0] = "单发", "双发", "扇形散射" }
local BUCKET_COLLIDE_EXTRA  = 25 -- 子弹与油桶/敌机的命中判定半径（子弹半径+目标半径的简化值）
local PLAYER_HULL_MAX       = 3
local FX_DIR                = "Assets/Main/Sprites/STG/CombatFx/"
local FX_LIFETIME           = 0.42
local MAX_COMBAT_FX         = 36
local MAX_FREE_COMBAT_FX    = 24
local BOSS_SHOT_WARNING     = 0.5
local BOSS_DEFEAT_DURATION  = 0.9

function UIPlaneBattleView:OnCreate()
    base.OnCreate(self)

    self.wingmanCount = 0
    self.wingmen = {}      -- PlaneUnit[]（kind=wingman）
    self.enemies = {}      -- PlaneUnit[]（kind=enemy/boss）
    self.gates = {}        -- GateComponent[]
    self.buckets = {}      -- BucketComponent[]
    self.isBattleOver = false
    self.isInLevelSelect = false
    self.battleTime = 0
    self.battleDuration = 0
    self.battleLevelName = nil
    self.lastHudSecond = -1
    self.wingmanFireTimer = 0
    self.primaryFireTimer = 0
    self.playerHull = PLAYER_HULL_MAX
    self.playerHullMax = PLAYER_HULL_MAX
    self.playerHitInvincible = 0
    self.combatFx = {}
    self.combatFxFree = {}
    self.bossDefeat = nil
    self.boss = nil
    self.bossWarningTimer = 0
    self.bossAimGo = nil
    self.bossAimLines = {}
    self.spawnCursor = 1   -- 时间轴下一个待生成的索引（legacy 路径用）
    self.logic = nil       -- StgBattleLogic 实例（STG 路径）
    self.stgGates = {}     -- StgGate 实例列表（STG 路径的门）
    self.heroEscorts = {}

    self:_CreateBattleContentRoot()
    self.bgRenderer = StgBackgroundRenderer.New(self.backgroundRootTf)
    self:_CreatePlayerPlane()
    self.bulletPool = BulletPool.New(self.battleContentTf)
    self.secondaryWeapon = SecondaryWeapon.New(self.battleContentTf)
    self.secondaryHitCallback = BindCallback(self, self._OnSecondaryHit)
    self.lastHudEnemyCount = -1

    self:_CreateHud()
    self.gateFeedback = GateFeedback.New(self.hudContentTf, function(t) self:_RequestHudFont(t) end)
    self:_CreateGuide()
    self:_CreateBackButton()
    self:_BuildLevelSelectPanel()
end

function UIPlaneBattleView:OnEnable()
    base.OnEnable(self)
    self:ApplyUserData()
end

function UIPlaneBattleView:OnDestroy()
    self:_ClearBattleObjects()
    if self.formationPanel ~= nil then self.formationPanel:Delete() end
    if self.resultView ~= nil then self.resultView:Delete() end
    self.levelSelectGo, self.resultPanelGo = nil, nil
    self.resultView, self.battleStats = nil, nil
    self.formationPanel, self.battleTeam, self.heroEscorts = nil, nil, nil
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Delete() end
    self.secondaryWeapon, self.secondaryHitCallback = nil, nil
    if self.gateFeedback ~= nil then
        self.gateFeedback:Destroy()
        self.gateFeedback = nil
    end
    if self.logic ~= nil then
        self.logic:Destroy()
        self.logic = nil
    end
    if self.bulletPool ~= nil then
        self.bulletPool:Clear()
        self.bulletPool = nil
    end
    if self.bgRenderer ~= nil then
        self.bgRenderer:Destroy()
        self.bgRenderer = nil
    end

    -- 关键：窗口关闭走的是对象池 SetActive(false)（GameObject 会被复用），不是真正 Destroy。
    -- 本模块的主机/HUD/引导/返回按钮/结算面板全部是 OnCreate 时运行时动态建的节点，
    -- 不在这里显式 Destroy 掉，下次 OnCreate 会在这些残留节点之上再叠一套新的——
    -- 尤其是 ResultPanel 挂着 raycastTarget=true 的全屏遮罩，残留在树里会挡住之后所有点击
    -- （表现就是"点跳过弹出结算面板后不管怎么点都没反应"，其实是上一局的旧遮罩挡在最上层）。
    if self.playerPlaneGo ~= nil and not IsNull(self.playerPlaneGo) then
        self.playerPlaneGo:Destroy()
    end
    if self.dragSurfaceGo ~= nil and not IsNull(self.dragSurfaceGo) then
        self.dragSurfaceGo:Destroy()
    end
    self.dragSurfaceGo = nil
    self.inputCanvas = nil
    if self.hudContentTf ~= nil and not IsNull(self.hudContentTf) then
        -- HudContent 本身是 prefab 节点要保留，只清空它下面运行时新增的子节点
        -- （关卡名/金币/跳过/敌方兵力/引导/返回按钮，全部是 OnCreate 时新建的）
        for i = self.hudContentTf.childCount - 1, 0, -1 do
            local child = self.hudContentTf:GetChild(i)
            if child ~= nil and not IsNull(child) then
                child.gameObject:Destroy()
            end
        end
    end
    if self.resultPanelGo ~= nil and not IsNull(self.resultPanelGo) then
        self.resultPanelGo:Destroy()
    end
    if self.levelSelectGo ~= nil and not IsNull(self.levelSelectGo) then
        self.levelSelectGo:Destroy()
    end
    -- BackgroundRoot 同样是 OnCreate 时建在 BattleContent（prefab 节点，会被池化复用）下的，
    -- 不显式销毁的话，下次 OnCreate 会再建一个，背景层就会一局叠一层
    if self.backgroundRootGo ~= nil and not IsNull(self.backgroundRootGo) then
        self.backgroundRootGo:Destroy()
    end

    self.playerPlaneGo = nil
    self.playerPlaneRt = nil
    self.playerPlaneImg = nil
    self.playerFlightVisual = nil
    self.primaryFireTimer = nil
    self.backgroundRootGo = nil
    self.backgroundRootTf = nil
    self.battleContentTf = nil
    self.hudContentTf = nil
    if self.hudTextMaterial ~= nil and not IsNull(self.hudTextMaterial) then
        CS.UnityEngine.Object.Destroy(self.hudTextMaterial)
    end
    self.hudTextMaterial = nil
    self.hudLevelNameText = nil
    self.hudGoldText = nil
    self.hudEnemyText = nil
    self.hudHullText = nil
    self.hudProgressRt = nil
    self.hudTimeText = nil
    self.battleDuration = nil
    self.battleLevelName = nil
    self.lastHudSecond = nil
    self.playerHull = nil
    self.playerHitInvincible = nil
    self.combatFx = nil
    self.combatFxFree = nil
    self.bossDefeat = nil
    self.boss = nil
    self.bossWarningTimer = nil
    self.bossAimGo = nil
    self.bossAimLines = nil
    self.hudBossRoot = nil
    self.hudBossFillRt = nil
    self.hudBossText = nil
    self.hudBossShieldGo = nil
    self.hudBossShieldFillRt = nil
    self.hudBossShieldText = nil
    self.bossWarningGo = nil
    self.bossWarningText = nil
    self.guideGroupGo = nil
    self.resultPanelGo = nil
    self.resultTitleText = nil
    self.resultTimeText = nil
    self.resultWingmanText = nil
    self.resultBannerImg = nil
    self.resultNextBtnGo = nil
    self.levelSelectGo = nil
    self.levelListTf = nil
    self.selectGoldText = nil
    self.selectHeroNameText = nil
    self.selectHeroPassiveText = nil
    self.selectHeroAvatarImg = nil
    self.hudHeroNameText = nil
    self.hudHeroPassiveText = nil
    self.hudHeroAvatarImg = nil
    self.battleHero = nil
    self.playerHullMax = nil
    base.OnDestroy(self)
end

function UIPlaneBattleView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.PlaneGoldChanged, self._OnGoldChanged)
    self:AddUIListener(EventId.HeroDeployedChanged, self._OnHeroDeployedChanged)
end

function UIPlaneBattleView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(EventId.PlaneGoldChanged, self._OnGoldChanged)
    self:RemoveUIListener(EventId.HeroDeployedChanged, self._OnHeroDeployedChanged)
end

function UIPlaneBattleView:_OnHeroDeployedChanged()
    if self.isInLevelSelect then self:_RefreshHeroSelect() end
end

function UIPlaneBattleView:_OnGoldChanged(totalGold)
    if self.hudGoldText ~= nil and not IsNull(self.hudGoldText) then
        self.hudGoldText.text = tostring(totalGold)
    end
    if self.isInLevelSelect and self.formationPanel ~= nil then self.formationPanel:Refresh() end
end

function UIPlaneBattleView:_LockBattleHero()
    local mgr = DataCenter.HeroDataManager
    local playerRules = nil
    if self.levelId ~= nil and CS.UnityEngine.Resources.Load("STG/Levels/" .. tostring(self.levelId), typeof(CS.UnityEngine.TextAsset)) ~= nil then
        local StgLevelConfig = require "Game.STG.DataCenter.StgLevelConfig"
        -- 编辑器保存后下一次进关重新读JSON，当前局使用锁定快照。
        StgLevelConfig.ClearCache(self.levelId)
        local cfg = StgLevelConfig.Load(self.levelId)
        playerRules = cfg and cfg.playerRules or nil
    end
    self.playerRules = playerRules or {}
    self.battleTeam = BattleHeroProfile.BuildFormation(DataCenter.PlaneBattleDataManager:GetFormation(), mgr, self.playerRules)
    self.battleHero = self.battleTeam.leader
    if self.playerFlightVisual ~= nil and self.battleHero.aircraft ~= nil then
        self.playerFlightVisual:SetAircraft(self.battleHero.aircraft.sprite)
    end
    self.playerHullMax = self.battleTeam.hullMax
    self.battleStats = { damage = {}, taken = {}, absorbed = {} }
    self:_CreateHeroAircraft()
    self.heroCombat = HeroCombatController.New(self, function(t) self:_RequestHudFont(t) end)
    -- 武器摘要显示在技能栏背板之上；两者都不拦截战场拖动。
    if self.gateFeedback ~= nil then self.gateFeedback.go.transform:SetAsLastSibling() end
    self.playerPlaneGo:SetActive(true)
end

function UIPlaneBattleView:_RefreshBattleHeroHud()
    local hero = self.battleHero
    if hero == nil then return end
    if self.hudHeroNameText ~= nil and not IsNull(self.hudHeroNameText) then
        local alive = 0
        for _, s in ipairs(self.heroCombat and self.heroCombat.state.members or {}) do
            if not s.dead then alive = alive + 1 end
        end
        self.hudHeroNameText.text = hero.name .. " · 存活 " .. tostring(alive) .. "/" .. tostring(#self.battleTeam.members)
    end
    if self.hudHeroPassiveText ~= nil and not IsNull(self.hudHeroPassiveText) then
        self.hudHeroPassiveText.text = string.format("独立装甲 · 额外僚机 +%d", self.battleTeam.wingmanBonus)
    end
    if self.hudHeroAvatarImg ~= nil and not IsNull(self.hudHeroAvatarImg) and hero.avatar ~= "" then
        self.hudHeroAvatarImg:LoadSprite(hero.avatar)
    end
end

function UIPlaneBattleView:_RefreshHeroSelect()
    if self.formationPanel ~= nil then self.formationPanel:Refresh() end
end

--- 每次窗口打开（含首次创建）都会走这里，重新读取关卡数据、复位战斗状态。
--- 抽成独立方法的原因同 UIShipCabinDetailView：窗口已存在时重复 OpenWindow 只会
--- SetActive(true) 不会重新触发 OnCreate/OnEnable 的完整链路时，Ctrl 侧要能显式重调。
---
--- userdata 约定：
---   nil          → 打开选关界面（探险页签默认入口）
---   number       → 直接进入该关卡战斗
---   {levelId=N}  → 同上
function UIPlaneBattleView:ApplyUserData()
    local userData = self:GetUserData()
    local levelId = nil
    if type(userData) == "number" then
        levelId = userData
    elseif type(userData) == "table" then
        levelId = userData.levelId
    end

    self:_ClearBattleObjects()
    self.isBattleOver = false
    self.battleTime = 0
    self.wingmanFireTimer = 0
    self.playerHull = PLAYER_HULL_MAX
    self.playerHitInvincible = 0
    self.boss = nil
    self.bossWarningTimer = 0
    if self.bossWarningGo ~= nil and not IsNull(self.bossWarningGo) then
        self.bossWarningGo:SetActive(false)
    end
    self.spawnCursor = 1

    if levelId == nil then
        self:_ShowLevelSelect()
        return
    end

    self:_EnterLevel(levelId)
end

--- 进入指定关卡战斗（从选关界面点按钮 / ApplyUserData 直传关卡号 都走这里）
--- 优先走 STG 路径（Game/STG JSON + StgBattleLogic）；无 JSON 时回退旧 PlaneSpawn_Config 路径
function UIPlaneBattleView:_EnterLevel(levelId)
    -- 重试/下一关等入口同样不能绕过主位校验。
    if DataCenter.PlaneBattleDataManager:GetFormation()[1] == 0 then
        self:_ShowLevelSelect()
        return
    end
    self.levelId = levelId
    self.levelMeta = self.ctrl:GetLevelMeta(levelId)
    self.battleLevelName = nil
    self.battleDuration = tonumber(self.levelMeta and self.levelMeta.duration) or 0
    self.lastHudSecond = -1
    self:_HideLevelSelect()

    -- 从选关再进关时，这里必须完整复位战斗状态
    self:_ClearBattleObjects()
    self.isBattleOver = false
    self.battleTime = 0
    self.wingmanFireTimer = 0
    self:_LockBattleHero()
    self.playerHull = self.playerHullMax or PLAYER_HULL_MAX
    self.playerHitInvincible = 0
    self.spawnCursor = 1
    self._lastStgBattleGold = 0

    self:_HideResultPanel()
    self:_SetBattleHudVisible(true)
    self:_RefreshHudLevelName()
    self:_RefreshHudGold()
    self.lastHudEnemyCount = -1
    self:_RefreshHudEnemyCount()
    self:_RefreshHudHull()
    self.playerPlaneImg.color = Color(1, 1, 1, 1)
    if self.playerFlightVisual ~= nil then
        self.playerFlightVisual:Reset(self.playerPlaneRt.anchoredPosition.x)
    end

    if self.guideGroupGo ~= nil and not IsNull(self.guideGroupGo) then
        self.guideGroupGo:SetActive(not guideShownInSession)
    end

    -- ★ 优先 STG 路径
    if self:_TryStartStgBattle(levelId) then
        Logger.Log('#PlaneBattle# 进入关卡(STG) levelId=' .. tostring(levelId))
        return
    end

    -- 回退：旧 PlaneSpawn_Config 路径
    self.logic = nil
    self:_StartLegacyBattle(levelId)
    Logger.Log('#PlaneBattle# 进入关卡(Legacy) levelId=' .. tostring(levelId))
end

--- ---------------------------------------------------------------
--- STG 路径：StgBattleLogic 驱动
--- ---------------------------------------------------------------

--- @return boolean 是否成功启动（false = 无 STG JSON，走 legacy）
function UIPlaneBattleView:_TryStartStgBattle(levelId)
    if self.logic ~= nil then
        self.logic:Destroy()
        self.logic = nil
    end

    -- 未导出 JSON 的关卡正常走旧表，缺省资源不是运行错误。
    if CS.UnityEngine.Resources.Load("STG/Levels/" .. tostring(levelId), typeof(CS.UnityEngine.TextAsset)) == nil then
        return false
    end

    local logic = StgBattleLogic.New()
    logic:Init(self:_BuildStgCallbacks())

    -- StartLevel 内部 Load 失败会回调 OnBattleLose；这里先试加载判断是否走 STG
    local StgLevelConfig = require "Game.STG.DataCenter.StgLevelConfig"
    local cfg = StgLevelConfig.Load(levelId)
    if cfg == nil then
        logic:Destroy()
        return false
    end

    self.logic = logic
    logic:StartLevel(levelId)
    return true
end

function UIPlaneBattleView:_BuildStgCallbacks()
    local view = self
    return {
        -- 关卡数据就绪：设置初始僚机（英雄加成仍走 HeroDataManager）
        OnLevelLoaded = function(cfg)
            view.battleLevelName = cfg.levelName
            view.battleDuration = tonumber(cfg.timeline and cfg.timeline.duration) or 0
            view.lastHudSecond = -1
            view:_RefreshHudLevelName()
            view:_RefreshHudProgress()
            local baseWingman = tonumber(cfg.playerRules and cfg.playerRules.initialWingman) or 0
            -- 没有新规则时兼容旧 PlaneLevel_Config.base_wingman
            local levelMeta = view.ctrl:GetLevelMeta(view.levelId)
            if not (cfg.playerRules and cfg.playerRules.initialWingman ~= nil) and levelMeta ~= nil then
                baseWingman = tonumber(levelMeta.base_wingman) or 0
            end
            local heroTroopBonus = view.battleTeam and view.battleTeam.wingmanBonus or 0
            -- 初始编队也写入逻辑层，否则首次过门会用逻辑层的 0 覆盖画面编队。
            if view.logic ~= nil then
                view.logic:AddWingman(math.min(24, baseWingman + heroTroopBonus))
                view.logic:UpgradeWeapon(view.battleTeam and view.battleTeam.weaponLevel or 0)
            end
            view:_RefreshBattleHeroHud()

            -- 背景层：编辑器配的滚屏贴图带/散布装饰在这里接起来。
            -- 滚动速度读 basicScroll.baseSpeed（change_scroll_speed 时间轴事件目前 StgBattleLogic
            -- 未消费，等它支持动态调速后，这里改成读 logic 上的当前速度字段即可）
            if view.bgRenderer ~= nil then
                local scroll = cfg.basicScroll or {}
                local baseSpeed = (tonumber(scroll.baseSpeed) or 0)
                    * (tonumber(scroll.speedMultiplier) or 1)
                view.bgRenderer:Setup(cfg, function() return baseSpeed end)
            end
        end,

        -- 波次生成请求：创建敌机
        OnSpawnRequests = function(requests)
            view:_OnStgSpawnRequests(requests)
        end,

        -- Boss
        OnSpawnBoss = function(bossId)
            view:_OnStgSpawnBoss(bossId)
        end,

        -- 数字门掉落（drop_digital_gate 事件）
        OnDropDigitalGate = function(ev)
            view:_OnStgDropDigitalGate(ev)
        end,

        -- 机关（spawn_trap，含预摆的数字门）
        OnSpawnTrap = function(trapId, x, y)
            view:_OnStgSpawnTrap(trapId, x, y)
        end,

        -- 数值变化：逻辑侧是权威，View 同步表现
        OnWingmanCountChanged = function(count)
            view:_SetWingmanCount(count)
        end,
        OnWeaponChanged = function(level, before)
            view.gateFeedback:SetCount(view.displayLogicalCount or 0, level)
            if view.isResolvingGate then
                local title = level > before and "武器升级" or "武器已满级"
                local unlock = level > before and (level == 1 and " · 追踪导弹解锁" or " · 脉冲激光解锁") or ""
                view.gateFeedback:ShowMessage(title, WEAPON_NAMES[before] .. " → " .. WEAPON_NAMES[level] .. unlock)
                view:_PlayGatePulse(Color(0.5, 0.75, 1, 0.8))
            end
        end,
        OnRepairHull = function(amount)
            local before = view.playerHull
            if view.heroCombat then view.heroCombat:Repair(math.max(0, math.floor(amount))) end
            view:_RefreshHudHull()
            if view.isResolvingGate then
                local title = view.playerHull > before and "全队装甲修复" or "全队装甲补给"
                view.gateFeedback:ShowMessage(title, string.format("主机装甲 %d → %d / %d · 不复活阵亡机", before, view.playerHull, view.playerHullMax or PLAYER_HULL_MAX), Color(0.4, 1, 0.65, 1))
                view:_PlayGatePulse(Color(0.3, 1, 0.65, 0.8))
            end
        end,
        OnGoldChanged = function(battleGold)
            -- logic.gold 是当局累计，存档是历史累计，这里加增量
            local mgr = DataCenter.PlaneBattleDataManager
            if mgr ~= nil then
                local last = view._lastStgBattleGold or 0
                local delta = battleGold - last
                if delta > 0 then
                    mgr:AddGold(delta)
                end
                view._lastStgBattleGold = battleGold
            end
        end,

        -- 结算
        OnBattleWin = function()
            view:_OnStgBattleEnd(true)
        end,
        OnBattleLose = function()
            view:_OnStgBattleEnd(false)
        end,
    }
end

--- STG：批量生成敌机
function UIPlaneBattleView:_OnStgSpawnRequests(requests)
    if requests == nil then
        return
    end
    for _, r in ipairs(requests) do
        local x = (tonumber(r.x) or 0) * SCREEN_HALF_W
        local metaId = tonumber(r.metaId) or 8001
        local enemy = PlaneUnit.New(self.battleContentTf, "enemy", metaId)
        local canvasTop = self.battleContentTf.rect.height
        if canvasTop <= 0 then canvasTop = 1625 end
        -- 保留生成器传来的编队纵深，出生点始终在实际屏幕上沿之外。
        enemy:SetLocalPos(x, canvasTop + 80 + ((tonumber(r.y) or 1700) - 1700))
        -- 覆盖模板血量/速度
        if r.hp ~= nil and r.hp > 0 then
            enemy.hp = r.hp
            enemy.maxHp = r.hp
        end
        if r.speed ~= nil and r.speed > 0 then
            enemy.speed = r.speed
        end
        enemy.spawnX = x
        -- JSON entryPath.amplitude 控制横向掠过幅度；直线波次保持 0。
        enemy.swayAmplitude = r.entryPathType == "from_top_sine" and (tonumber(r.amplitude) or 0) or 0
        enemy.swayFrequency = 2
        enemy.swayPhase = 0
        enemy.fireInterval = tonumber(r.fireInterval) or 0
        table.insert(self.enemies, enemy)
    end
end

--- STG：生成 Boss
function UIPlaneBattleView:_OnStgSpawnBoss(bossId)
    -- bossId 是字符串，查 bossConfigs 拿 prefabPath/totalHp；首期仍用 PlaneUnit 内置 9001
    local metaId = tonumber(bossId) or 9001
    local boss = PlaneUnit.New(self.battleContentTf, "boss", metaId)
    boss:SetLocalPos(0, 1650)
    boss.spawnX = 0
    local cfg = self.logic and self.logic:GetConfig()
    local bossConfig = cfg and cfg.bossById[bossId]
    boss.hp = bossConfig and bossConfig.totalHp or boss.hp
    boss.maxHp = boss.hp
    boss.stationY = 1050
    boss.speed = 140
    boss.bossConfig = bossConfig
    boss.phaseId = nil
    boss.rageShield = 0
    boss.rageShieldMax = 0
    self:_RefreshBossPhase(boss, true)
    self.boss = boss
    self:_ShowBossWarning(bossConfig and bossConfig.bossName or "首领来袭")
    self:_RefreshBossHud()
    table.insert(self.enemies, boss)
end

--- STG：掉落数字门（drop_digital_gate）
function UIPlaneBattleView:_OnStgDropDigitalGate(ev)
    local cfg = self.logic and self.logic:GetConfig()
    if cfg == nil then
        return
    end

    -- drop_digital_gate 引用 isReusableGateTemplate=true 的门模板
    local gateType = ev.gateType
    local templates = cfg.gateTemplates
    local trapConfig = nil
    for _, t in pairs(templates or {}) do
        if t.gateType == gateType then
            trapConfig = t
            break
        end
    end
    if trapConfig == nil then
        -- 没有可复用模板，按 gateType 造一个临时配置
        trapConfig = {
            trapId = "drop_gate_" .. tostring(ev.time),
            type = "digital_gate",
            gateType = gateType,
            paraEntries = {},
            paraEntriesRight = {},
            initialValue = 0,
            positionX = ev.positionX or 0,
            positionY = ev.positionY or SPAWN_TOP_Y,
        }
        Logger.Log('#PlaneBattle# drop_digital_gate 无模板，使用空区间表 gateType=' .. tostring(gateType))
    end

    local count = math.max(1, tonumber(ev.count) or 1)
    local xMin = ev.offsetXMin or 0
    local xMax = ev.offsetXMax or 0

    for i = 1, count do
        local t = trapConfig
        -- 复制一份，避免多个门共享 hasTriggered
        local inst = {
            trapId = t.trapId .. "_" .. i,
            type = t.type,
            gateType = t.gateType,
            paraEntries = t.paraEntries,
            paraEntriesRight = t.paraEntriesRight,
            initialValue = t.initialValue or 0,
            effectTableRef = t.effectTableRef,
            positionX = (count == 1) and (xMin + xMax) * 0.5
                or (xMin + (xMax - xMin) * (i - 1) / math.max(1, count - 1)),
            positionY = ev.positionY or SPAWN_TOP_Y,
        }
        self:_CreateStgGateVisual(inst)
    end
end

--- STG：spawn_trap（含预摆的数字门 / 油桶等）
function UIPlaneBattleView:_OnStgSpawnTrap(trapId, x, y)
    local cfg = self.logic and self.logic:GetConfig()
    if cfg == nil then
        return
    end
    local trapConfig = cfg.trapById[trapId]
    if trapConfig == nil then
        Logger.LogError('#PlaneBattle# trap 不存在 trapId=' .. tostring(trapId))
        return
    end

    -- 事件 position 覆盖配置 position
    if x ~= nil and x ~= 0 then trapConfig = self:_CloneTrapWithPos(trapConfig, x, y) end

    if trapConfig.type == "digital_gate" then
        self:_CreateStgGateVisual(trapConfig)
    elseif trapConfig.type == "destructible" then
        -- 油桶：复用旧 BucketComponent（para 传 hp）
        local px = (tonumber(trapConfig.positionX) or 0) * SCREEN_HALF_W
        local py = tonumber(trapConfig.positionY) or SPAWN_TOP_Y
        local bucket = BucketComponent.New(self.battleContentTf, px, py, trapConfig.hp or 15, nil)
        table.insert(self.buckets, bucket)
    else
        Logger.Log('#PlaneBattle# 未处理的 trap type=' .. tostring(trapConfig.type))
    end
end

function UIPlaneBattleView:_CloneTrapWithPos(trapConfig, x, y)
    local c = {}
    for k, v in pairs(trapConfig) do c[k] = v end
    c.positionX = x
    c.positionY = y
    return c
end

--- 为 STG 数字门创建表现 + 逻辑实例
function UIPlaneBattleView:_CreateStgGateVisual(trapConfig)
    local gate = StgGateFactory.Create(trapConfig, self.logic)
    if gate == nil then
        return
    end

    -- 表现：用旧 GateComponent（贴图/文字/下落/触发检测）
    -- 文本由 gate:GetDisplayText() 提供；kind 按正负区分红蓝
    local px = (tonumber(trapConfig.positionX) or 0) * SCREEN_HALF_W
    local py = tonumber(trapConfig.positionY) or SPAWN_TOP_Y
    local displayText = gate:GetDisplayText()
    local kind = gate.gateType == "gate_duet" and "add"
        or (gate:IsPositive() and "add" or "subtract")

    local visual = GateComponent.New(self.battleContentTf, px, py, displayText, nil, kind)
    visual.stgGate = gate  -- 挂上逻辑实例，Update 里结算用
    visual:ConfigureStg(_RequestChineseFont)

    table.insert(self.gates, visual)
    table.insert(self.stgGates, gate)
end

function UIPlaneBattleView:_OnStgBattleEnd(isWin)
    self.isBattleOver = true
    if self.heroCombat then self.heroCombat:CancelPending() end
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Reset() end
    self:_HideBossAim()
    if isWin then
        -- 通关：推进存档进度
        local mgr = DataCenter.PlaneBattleDataManager
        if mgr ~= nil then
            mgr:OnLevelPass(self.levelId, 50)
        end
        if self.bossDefeat == nil then
            self:_ShowResultPanel(true)
        end
    else
        self:_ShowResultPanel(false)
    end
end

--- ---------------------------------------------------------------
--- Legacy 路径：旧 PlaneSpawn_Config 时间轴
--- ---------------------------------------------------------------

function UIPlaneBattleView:_StartLegacyBattle(levelId)
    local levelMeta = self.ctrl:GetLevelMeta(levelId)
    self.levelMeta = levelMeta
    self.timeline = self.ctrl:GetSpawnTimeline(levelId)

    self.wingmanCount = 0
    if levelMeta ~= nil then
        local baseWingman = tonumber(levelMeta.base_wingman) or 0
        local heroTroopBonus = self.battleTeam and self.battleTeam.wingmanBonus or 0
        self:_SetWingmanCount(baseWingman + heroTroopBonus)
    end
    self:_RefreshBattleHeroHud()
    -- 尚未导出 JSON 的旧关也沿用太空主题，战斗波次仍读它自己的旧表。
    local theme = require("Game.STG.DataCenter.StgLevelConfig").Load(1001)
    if theme ~= nil and self.bgRenderer ~= nil then
        local scroll = theme.basicScroll or {}
        local speed = (tonumber(scroll.baseSpeed) or 0) * (tonumber(scroll.speedMultiplier) or 1)
        self.bgRenderer:Setup(theme, function() return speed end)
    end
    if self.gateFeedback ~= nil then self.gateFeedback:SetCount(#self.wingmen, self.battleTeam.weaponLevel) end
end

--- ---------------------------------------------------------------
--- 节点搭建
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CreateBattleContentRoot()
    self.battleContentTf = self.transform:Find("BattleContent")
    self.hudContentTf = self.transform:Find("HudContent")

    -- 背景根节点：SetSiblingIndex(0) 压到 BattleContent 的最底层，
    -- 保证主机/僚机/敌机/门/子弹（都是后创建的，sibling index 更大）永远画在背景之上
    local bgRootGo = GameObject("BackgroundRoot", RectTransform)
    bgRootGo.transform:SetParent(self.battleContentTf, false)
    local bgRootRt = bgRootGo:GetComponent(RectTransform)
    bgRootRt.anchorMin = Vector2(0, 0)
    bgRootRt.anchorMax = Vector2(1, 1)
    bgRootRt.offsetMin = Vector2(0, 0)
    bgRootRt.offsetMax = Vector2(0, 0)
    bgRootGo.transform:SetSiblingIndex(0)

    self.backgroundRootGo = bgRootGo
    self.backgroundRootTf = bgRootGo.transform

    -- 飞机周围和底部引导区也可起拖；放在表现节点下层，HUD 按钮仍优先接收输入。
    local dragGo = GameObject("BattleDragSurface", RectTransform)
    dragGo.transform:SetParent(self.battleContentTf, false)
    local dragRt = dragGo:GetComponent(RectTransform)
    dragRt.anchorMin, dragRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    dragRt.offsetMin, dragRt.offsetMax = Vector2(0, 0), Vector2(0, 0)
    local dragImg = dragGo:AddComponent(Image)
    dragImg.color = Color(1, 1, 1, 0)
    dragImg.raycastTarget = true
    dragGo:GetOrAddComponent(UIEventTrigger).onDrag = function(data) self:_OnDragPlayerPlane(data) end
    self.dragSurfaceGo = dragGo
    self.inputCanvas = dragGo:GetComponentInParent(typeof(CS.UnityEngine.Canvas)).rootCanvas
end

--- 主机：屏幕下方固定高度，左右拖动
function UIPlaneBattleView:_CreatePlayerPlane()
    local go = GameObject("PlayerPlane", RectTransform)
    go.transform:SetParent(self.battleContentTf, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin        = Vector2(0.5, 0)
    rt.anchorMax        = Vector2(0.5, 0)
    rt.pivot             = Vector2(0.5, 0.5)
    rt.anchoredPosition  = Vector2(0, PLANE_BOTTOM_Y)
    rt.sizeDelta         = PLANE_SIZE

    local img = go:AddComponent(Image)
    img.color = Color(1, 1, 1, 0)
    self.playerFlightVisual = FlightVisual.New(go.transform, PLANE_SIZE, "Assets/Main/Sprites/STG/SpaceRaid/player_blue.png", nil, true)

    self.playerPlaneGo = go
    self.playerPlaneRt = rt
    self.playerPlaneImg = self.playerFlightVisual.bodyImg

    local trigger = go:GetOrAddComponent(UIEventTrigger)
    trigger.onDrag = function(data) self:_OnDragPlayerPlane(data) end
end

--- ---------------------------------------------------------------
--- 主机拖动
--- ---------------------------------------------------------------

function UIPlaneBattleView:_OnDragPlayerPlane(data)
    if self.isBattleOver or self.isInLevelSelect or self.playerPlaneRt == nil then
        return
    end

    if not guideShownInSession then
        guideShownInSession = true
        self:_HideGuide()
    end

    local pos = self.playerPlaneRt.anchoredPosition
    local scale = self.inputCanvas ~= nil and self.inputCanvas.scaleFactor or 1
    local newX = pos.x + data.delta.x / math.max(0.01, scale)
    local leftBound, rightBound = -SAFE_HALF_WIDTH, SAFE_HALF_WIDTH
    for _, unit in ipairs(self.heroEscorts or {}) do
        leftBound = math.max(leftBound, -SCREEN_HALF_W + 30 - unit.formationOffset.x)
        rightBound = math.min(rightBound, SCREEN_HALF_W - 30 - unit.formationOffset.x)
    end
    newX = math.max(leftBound, math.min(rightBound, newX))

    self.playerPlaneRt.anchoredPosition = Vector2(newX, pos.y)
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:MoveEmitter(newX) end
    -- EventSystem 的拖动可能晚于战斗 Update；必须在同次输入中同步僚机，
    -- 否则快速拖动会出现主机先移动、编队下一帧才追上的画面。
    self:_RefreshWingmanFormation()
end

--- 供门/编队读取主机当前坐标
function UIPlaneBattleView:GetPlayerPlanePos()
    if self.playerPlaneRt == nil or IsNull(self.playerPlaneRt) then
        return 0, PLANE_BOTTOM_Y
    end
    local pos = self.playerPlaneRt.anchoredPosition
    return pos.x, pos.y
end

--- ---------------------------------------------------------------
--- 僚机编队
--- ---------------------------------------------------------------

function UIPlaneBattleView:_SetWingmanCount(count)
    local logicalCount = math.max(0, math.floor(count))
    local before = self.displayLogicalCount or 0
    self.displayLogicalCount = logicalCount
    local showUpgrade = self.isResolvingGate and logicalCount > before
    count = math.max(0, math.min(WINGMAN_MAX, math.floor(count)))
    local diff = count - #self.wingmen

    if diff > 0 then
        for _ = 1, diff do
            local wingman = PlaneUnit.New(self.battleContentTf, "wingman")
            if showUpgrade then wingman.flightVisual:PlayJoin() end
            table.insert(self.wingmen, wingman)
        end
    elseif diff < 0 then
        for _ = 1, -diff do
            local wingman = table.remove(self.wingmen)
            if wingman ~= nil then
                wingman:Destroy()
            end
        end
    end

    self.wingmanCount = #self.wingmen
    self:_RefreshWingmanFormation()
    if self.gateFeedback ~= nil then self.gateFeedback:SetCount(logicalCount) end
    EventManager:GetInstance():Broadcast(EventId.PlaneWingmanCountChanged, self.wingmanCount)
end

function UIPlaneBattleView:_RefreshWingmanFormation()
    local offsets = FormationLayout.GetOffsets(#self.wingmen)
    local px, py = self:GetPlayerPlanePos()
    for i, wingman in ipairs(self.wingmen) do
        local off = offsets[i]
        if off ~= nil then
            wingman:SetLocalPos(px + off.x, py + off.y + (#(self.heroEscorts or {}) > 0 and 165 or 0))
        end
    end
    for _, unit in ipairs(self.heroEscorts or {}) do
        unit:SetLocalPos(px + unit.formationOffset.x, py + unit.formationOffset.y)
    end
end

--- 英雄护航机不受数字门增减影响，装甲与技能由 HeroCombatController 管理。
function UIPlaneBattleView:_CreateHeroAircraft()
    local offsets = { [2] = Vector2(-120,70), [3] = Vector2(120,70),
        [4] = Vector2(-210,155), [5] = Vector2(210,155) }
    for _, hero in ipairs(self.battleTeam.members) do
        if hero.slot ~= 1 then
            local unit = PlaneUnit.New(self.battleContentTf, "wingman", nil, hero.aircraft.sprite)
            unit.hero, unit.formationOffset = hero, offsets[hero.slot]
            unit.collideRadius = 24
            table.insert(self.heroEscorts, unit)
        end
    end
    self:_RefreshWingmanFormation()
end

--- ---------------------------------------------------------------
--- 主循环（挂在 UpdateManager 上，UIBaseContainer 检测到 self.Update 存在会自动接管）
--- ---------------------------------------------------------------

function UIPlaneBattleView:Update()
    -- 逻辑已结算也继续播放短暂的击毁演出，随后才打开结果面板。
    if self.bossDefeat ~= nil then
        self:_UpdateBossDefeat(CS.UnityEngine.Time.deltaTime)
        return
    end
    if self.isBattleOver or self.isInLevelSelect then
        return
    end

    local dt = CS.UnityEngine.Time.deltaTime
    self.battleTime = self.battleTime + dt
    self.heroCombat:Tick(dt)
    if self.isBattleOver or self.bossDefeat ~= nil then return end

    -- 背景滚动：放在 STG/Legacy 分支之外统一驱动。
    -- 旧表关卡已在启动时加载默认太空主题，仍走同一滚动更新。
    if self.bgRenderer ~= nil then
        self.bgRenderer:Update(dt)
    end

    self:_RefreshWingmanFormation()
    self:_UpdateFlightVisuals(dt)
    if self.gateFeedback ~= nil then self.gateFeedback:Update(dt) end
    self:_UpdateWingmanFire(dt)
    self:_UpdateBossPhase()
    self:_UpdateEnemies(dt)
    self:_UpdateCombatFx(dt)
    self:_UpdateBossWarning(dt)
    self:_UpdateGates(dt)
    if self.isBattleOver then return end
    self:_UpdateBuckets(dt)
    self.bulletPool:Update(dt)
    self:_CheckBulletCollisions()
    if self.bossDefeat ~= nil then return end
    local px, py = self:GetPlayerPlanePos()
    self.secondaryWeapon:Update(dt, self:_GetBattleWeaponLevel(),
        px, py, self.enemies, self.secondaryHitCallback)
    if self.bossDefeat ~= nil then return end
    self:_CheckEnemyBulletHits(dt)
    self:_RefreshHudEnemyCount()
    self:_RefreshBossHud()

    self:_RefreshHudProgress()

    if self.logic ~= nil then
        -- ★ STG 路径：时间轴/波次/结算由 StgBattleLogic 驱动
        self.logic:Update(dt)
    else
        -- Legacy 路径：旧 PlaneSpawn_Config 时间轴 + 超时判负
        self:_ConsumeSpawnTimeline()
        self:_CheckBattleEnd()
    end
end

function UIPlaneBattleView:_UpdateFlightVisuals(dt)
    local x = self:GetPlayerPlanePos()
    if self.playerFlightVisual ~= nil then
        self.playerFlightVisual:SetWeaponLevel(self:_GetBattleWeaponLevel())
        self.playerFlightVisual:Update(dt, x, self.battleTime)
    end
    for i, wingman in ipairs(self.wingmen) do
        if wingman.flightVisual ~= nil then
            wingman.flightVisual.phase = i * 0.7
            local wx = wingman:GetLocalPos()
            wingman.flightVisual:Update(dt, wx, self.battleTime)
        end
    end
    for _, unit in ipairs(self.heroEscorts or {}) do
        if not unit.isDead then
            local x = unit:GetLocalPos()
            unit.flightVisual:SetWeaponLevel(self:_GetBattleWeaponLevel())
            unit.flightVisual:Update(dt,x,self.battleTime)
        end
    end
end

--- Boss 配置的 phases 以血量阈值划分；进入下一段时即时替换巡航和弹幕参数。
function UIPlaneBattleView:_UpdateBossPhase()
    if self.boss ~= nil and not self.boss.isDead then
        self:_RefreshBossPhase(self.boss, false)
    end
end

function UIPlaneBattleView:_RefreshBossPhase(boss, isInitial)
    local cfg = boss and boss.bossConfig
    local phases = cfg and cfg.phases
    if phases == nil or #phases == 0 then
        return
    end

    local ratio = math.max(0, (boss.hp or 0) / math.max(1, boss.maxHp or 1))
    local selected = phases[1]
    for _, phase in ipairs(phases) do
        -- 与关卡编辑器预览一致：血量降至阈值时，进入该阶段。
        if ratio <= (tonumber(phase.hpThreshold) or 1) then
            selected = phase
        end
    end
    if boss.phaseId == selected.phaseId then
        return
    end

    boss.phaseId = selected.phaseId
    boss.movePattern = selected.movePattern
    local skill = selected.skills and selected.skills[1]
    boss.swayAmplitude = selected.movePattern == "figure_eight" and 220
        or (selected.movePattern == "horizontal_patrol" and 150 or 0)
    boss.swayFrequency = selected.movePattern == "figure_eight" and 1.65 or 0.9
    boss.verticalSwayAmplitude = selected.movePattern == "figure_eight" and 58 or 0
    boss.fireInterval = skill and tonumber(skill.interval) or 0
    boss.shotCount = skill and tonumber(skill.bulletCount) or 1
    boss.spreadAngle = skill and tonumber(skill.spreadAngle) or 0
    boss.fireTimer = 0
    boss.pendingShot = nil
    self:_HideBossAim()

    if not isInitial then
        if selected.phaseId >= 2 and (boss.rageShield or 0) <= 0 then
            boss.rageShieldMax = math.max(180, math.floor((boss.maxHp or 1000) * 0.12))
            boss.rageShield = boss.rageShieldMax
            self:_ShowBossPhaseNotice((cfg.bossName or "首领") .. "·狂暴阶段 · 护盾启动")
            local x, y = boss:GetLocalPos()
            self:_SpawnCombatFx("shield_hit.png", x, y, 300, Color(0.32, 0.72, 1, 0.95), 0.75)
        else
            self:_ShowBossPhaseNotice((cfg.bossName or "首领") .. "·狂暴阶段")
        end
    end
end

--- ---------------------------------------------------------------
--- 主炮与僚机自动开火
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateWingmanFire(dt)
    if dt <= 0 then return end
    local level = self:_GetBattleWeaponLevel()
    local fireRate = self.heroCombat and self.heroCombat.state:GetFireRate() or 1
    self.primaryFireTimer = (self.primaryFireTimer or 0) + dt * fireRate
    self.primaryFireTimer = math.min(self.primaryFireTimer, PRIMARY_FIRE_INTERVAL * 3)
    while self.primaryFireTimer >= PRIMARY_FIRE_INTERVAL do
        self.primaryFireTimer = self.primaryFireTimer - PRIMARY_FIRE_INTERVAL
        local x, y = self:GetPlayerPlanePos()
        self:_FirePlayerVolley(x, y + 46, PRIMARY_BULLET_DAMAGE, level, self.playerFlightVisual, true, self.battleHero.id)
    end

    self.wingmanFireTimer = self.wingmanFireTimer + dt * fireRate
    self.wingmanFireTimer = math.min(self.wingmanFireTimer, WINGMAN_FIRE_INTERVAL * 3)
    while self.wingmanFireTimer >= WINGMAN_FIRE_INTERVAL do
        self.wingmanFireTimer = self.wingmanFireTimer - WINGMAN_FIRE_INTERVAL
        for _, unit in ipairs(self.heroEscorts or {}) do
            if not unit.isDead then
                local x,y = unit:GetLocalPos()
                self:_FirePlayerVolley(x,y+30,WINGMAN_BULLET_DAMAGE,level,unit.flightVisual,false,unit.hero.id)
            end
        end
        if #self.wingmen > 0 then
            local logicalCount = self.logic and self.logic:GetWingmanCount() or #self.wingmen
            local multiplier = math.max(1, math.min(24, logicalCount) / #self.wingmen)
            for _, wingman in ipairs(self.wingmen) do
                local x, y = wingman:GetLocalPos()
                self:_FirePlayerVolley(x,y+30,WINGMAN_BULLET_DAMAGE * multiplier,level,wingman.flightVisual,false)
            end
        end
    end
end

function UIPlaneBattleView:_GetBattleWeaponLevel()
    if self.logic ~= nil then return self.logic:GetWeaponLevel() end
    return self.battleTeam and self.battleTeam.weaponLevel or 0
end

--- 主炮与僚机共享升级弹道；主炮不乘编队数量，伤害仍走现有命中/数字门路径。
function UIPlaneBattleView:_FirePlayerVolley(x, y, damage, level, visual, primary, sourceId)
    local fired = false
    local function fire(offset, velocity, ratio)
        local accepted = self.bulletPool:Fire(x + offset, y, 1, damage * ratio, "player", velocity, level, primary, sourceId)
        fired = accepted or fired
    end
    if level == 1 then
        fire(-7, 0, 0.65)
        fire(7, 0, 0.65)
    elseif level >= 2 then
        for shot = -1, 1 do fire(shot * 7, shot * 180, 0.5) end
    else
        fire(0, 0, 1)
    end
    if fired and visual ~= nil then visual:PlayFire(level) end
end

--- 副武器只打敌机，复用同一死亡结算，首领击毁后立即停下本帧副武器更新。
function UIPlaneBattleView:_OnSecondaryHit(target, damage, x, y)
    if target == nil or target.isDead or self.isBattleOver then return false end
    local dead = self:_TakeBattleTargetDamage(target, damage, x, y)
    local actualDamage = self._lastDamageApplied or 0
    self:_RecordBattleDamage(target, actualDamage, self.battleHero and self.battleHero.id)
    if dead then
        self:_OnEnemyDead(target)
    elseif self.battleTime >= (target.nextImpactAt or 0) then
        self:_SpawnCombatFx("impact.png", x, y, 55, Color(0.45, 0.85, 1, 0.95), 0.16)
        target.nextImpactAt = self.battleTime + 0.1
    end
    return self.bossDefeat ~= nil or self.isBattleOver
end

--- ---------------------------------------------------------------
--- 敌机/boss 推进
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateEnemies(dt)
    local i = 1
    while i <= #self.enemies do
        local enemy = self.enemies[i]
        -- 首领蓄力时锁定位置，预警线和随后发射的弹道保持一致。
        if enemy.pendingShot == nil then
            enemy:Update(dt)
        end
        self:_UpdateEnemyFire(enemy, dt)
        local _, y = enemy:GetLocalPos()
        if y < BOTTOM_RECYCLE_Y then
            enemy:Destroy()
            table.remove(self.enemies, i)
        else
            i = i + 1
        end
    end
end

--- 敌方射击使用波次 JSON 的 behavior.fireInterval。
--- 敌弹使用独立阵营，由护盾命中检测消费。
function UIPlaneBattleView:_UpdateEnemyFire(enemy, dt)
    if dt <= 0 or enemy == nil or enemy.isDead or (enemy.fireInterval or 0) <= 0 then
        return
    end
    local pending = enemy.pendingShot
    if pending ~= nil then
        pending.remaining = math.max(0, pending.remaining - dt)
        for _, line in ipairs(self.bossAimLines) do
            line.img.color = Color(1, 0.23, 0.12, 0.18 + 0.25 * (1 - pending.remaining / pending.duration))
        end
        if pending.remaining <= 0 then
            self:_FireEnemyVolley(pending.x, pending.y, pending.count, pending.spread)
            enemy.pendingShot = nil
            enemy.fireTimer = 0
            self:_HideBossAim()
        end
        return
    end
    local x, y = enemy:GetLocalPos()
    if y < 360 or y > 1400 then
        return
    end
    if enemy.kind == "boss" and not enemy.stationEntered then
        return
    end
    enemy.fireTimer = (enemy.fireTimer or 0) + dt
    local count = math.max(1, math.min(15, enemy.shotCount or 1))
    local spread = math.max(0, math.min(140, enemy.spreadAngle or 0))
    local warning = math.min(BOSS_SHOT_WARNING, enemy.fireInterval * 0.5)
    if enemy.kind == "boss" and enemy.fireTimer >= enemy.fireInterval - warning then
        enemy.pendingShot = { x = x, y = y - 28, count = count, spread = spread,
            remaining = warning, duration = warning }
        self:_ShowBossAim(enemy.pendingShot)
        return
    end
    if enemy.fireTimer < enemy.fireInterval then
        return
    end
    enemy.fireTimer = 0
    self:_FireEnemyVolley(x, y - 28, count, spread)
end

function UIPlaneBattleView:_FireEnemyVolley(x, y, count, spread)
    for shot = 1, count do
        local ratio = count == 1 and 0 or ((shot - 1) / (count - 1) - 0.5)
        local angle = ratio * spread * math.pi / 180
        self.bulletPool:Fire(x, y, -1, 1, "enemy", math.tan(angle) * 310)
    end
end

--- 预警线只用一组可复用 UI 节点；无碰撞、无输入，顶端与实际弹幕出生点重合。
function UIPlaneBattleView:_ShowBossAim(shot)
    if self.bossAimGo == nil or IsNull(self.bossAimGo) then
        self.bossAimGo = GameObject("BossAttackWarning", RectTransform)
        self.bossAimGo.transform:SetParent(self.battleContentTf, false)
        local rt = self.bossAimGo:GetComponent(RectTransform)
        rt.anchorMin = Vector2(0.5, 0)
        rt.anchorMax = Vector2(0.5, 0)
        rt.sizeDelta = Vector2(0, 0)
    end
    self.bossAimGo:GetComponent(RectTransform).anchoredPosition = Vector2(shot.x, shot.y)
    self.bossAimGo:SetActive(true)
    for i = 1, shot.count do
        local line = self.bossAimLines[i]
        if line == nil then
            local go = GameObject("AimLine" .. tostring(i), RectTransform)
            go.transform:SetParent(self.bossAimGo.transform, false)
            local rt = go:GetComponent(RectTransform)
            rt.anchorMin = Vector2(0.5, 0.5)
            rt.anchorMax = Vector2(0.5, 0.5)
            rt.pivot = Vector2(0.5, 1)
            local img = go:AddComponent(Image)
            img.raycastTarget = false
            line = { go = go, rt = rt, img = img }
            self.bossAimLines[i] = line
        end
        local ratio = shot.count == 1 and 0 or ((i - 1) / (shot.count - 1) - 0.5)
        local angle = ratio * shot.spread
        line.rt.sizeDelta = Vector2(3, math.max(1, shot.y) / math.cos(angle * math.pi / 180))
        line.rt.localRotation = CS.UnityEngine.Quaternion.Euler(0, 0, angle)
        line.img.color = Color(1, 0.23, 0.12, 0.18)
        line.go:SetActive(true)
    end
    for i = shot.count + 1, #self.bossAimLines do
        self.bossAimLines[i].go:SetActive(false)
    end
end

function UIPlaneBattleView:_HideBossAim()
    if self.bossAimGo ~= nil and not IsNull(self.bossAimGo) then
        self.bossAimGo:SetActive(false)
    end
end

--- ---------------------------------------------------------------
--- 数字门推进 + 触发
--- ---------------------------------------------------------------

function UIPlaneBattleView:_PlayGatePulse(color)
    local px, py = self:GetPlayerPlanePos()
    self:_SpawnCombatFx("shield_hit.png", px, py + 25, 160, color, 0.35)
end

--- 返回主机即将经过的数字门选择预览；只做表现，不提前执行门效果。
function UIPlaneBattleView:_GetGatePreview(gate)
    if gate == nil or gate.stgGate == nil then return nil end
    local g = gate.stgGate
    local TriggerEnum = require "Game.STG.Trigger.StgTriggerEnum"
    local EffectTable = TriggerEnum.EffectTable
    local function effectText(effectId)
        local meta = effectId ~= nil and EffectTable[effectId] or nil
        if meta == nil then return "待计算" end
        if meta.type == TriggerEnum.Type.UpgradeWeapon then return "武器升级" end
        if meta.type == TriggerEnum.Type.RepairHull then return "装甲 +" .. tostring(meta.para or 1) end
        if meta.type == TriggerEnum.Type.MultiplyWingman then return "编队 ×" .. tostring(meta.para or 2) end
        return meta.text or "效果"
    end
    local _, gateY = gate:GetLocalPos()
    local _, playerY = self:GetPlayerPlanePos()
    local distance = gateY - playerY
    if distance < -80 or distance > 430 then return nil end
    if g.gateType == "gate_duet" then
        local left = effectText(g.leftEffectId)
        local right = effectText(g.rightEffectId)
        local leftColor = (g.leftValue or 0) < 0 and Color(1, 0.42, 0.28, 1) or Color(0.35, 0.92, 1, 1)
        local rightColor = (g.rightValue or 0) < 0 and Color(1, 0.42, 0.28, 1) or Color(0.35, 0.92, 1, 1)
        return "左右选边 · 左 " .. left .. " / 右 " .. right,
            "向左飞：" .. left .. "　向右飞：" .. right,
            leftColor, "duet:" .. tostring(g.leftValue) .. ":" .. tostring(g.rightValue) .. ":" .. left .. ":" .. right
    end
    local text = effectText(g.effectId)
    local negative = (g.value or 0) < 0 or (EffectTable[g.effectId] ~= nil and EffectTable[g.effectId].type == TriggerEnum.Type.RemoveWingman)
    local color = negative and Color(1, 0.42, 0.28, 1) or Color(0.35, 0.92, 1, 1)
    if g.gateType == "gate_step" then
        return "火力充能 · 当前 " .. tostring(math.floor(g.accumulatedDamage or 0)), "通过后领取：" .. text, Color(0.65, 0.72, 1, 1), "step:" .. tostring(g.accumulatedDamage) .. ":" .. text
    end
    return negative and "危险门 · 选择后会减员" or "数字门 · 选择奖励", "通过后领取：" .. text, color, "gate:" .. tostring(g.value) .. ":" .. text
end

function UIPlaneBattleView:_UpdateGates(dt)
    local px, py = self:GetPlayerPlanePos()
    local i = 1
    local previewGate, previewDistance = nil, math.huge
    while i <= #self.gates do
        local gate = self.gates[i]
        gate:Update(dt)

        if not gate.hasTriggered and gate.stgGate ~= nil then
            local _, gateY = gate:GetLocalPos()
            local distance = gateY - py
            if distance >= -80 and distance < previewDistance then
                previewGate, previewDistance = gate, distance
            end
        end

        if gate:CheckTrigger(px, py) then
            local before = self.logic and self.logic:GetWingmanCount() or #self.wingmen
            self.isResolvingGate = true
            if gate.stgGate ~= nil then
                -- ★ STG 门：逻辑实例结算（内部走 StgBattleLogic:ExecuteEffect）
                local gateX = gate:GetLocalPos()
                local isLeft = px <= gateX  -- 双选门以自身中心分栏，支持编辑器横向偏移。
                gate.stgGate:OnPass(isLeft)
            elseif gate.kind == "lock" then
                -- Legacy 锁定门
                if self.wingmanCount >= (gate.threshold or 0) then
                    Logger.Log('#PlaneBattle# 通过锁定门 threshold=' .. tostring(gate.threshold) .. ' wingmanCount=' .. tostring(self.wingmanCount))
                else
                    self.isResolvingGate = false
                    if self.logic ~= nil then self.logic:Lose() else self:_OnBattleLose() end
                    return
                end
            else
                -- Legacy buff 门
                self:_ExecuteTrigger(gate.triggerMeta)
            end
            self.isResolvingGate = false
            local after = self.logic and self.logic:GetWingmanCount() or #self.wingmen
            if after ~= before and self.gateFeedback ~= nil then
                self.gateFeedback:Show(before, after)
                local color = after > before and Color(0.3, 0.95, 1, 0.75) or Color(1, 0.4, 0.2, 0.7)
                self:_SpawnCombatFx("shield_hit.png", px, py + 25, 160, color, 0.35)
            end
            -- 已结算的门立即回收，避免停留在编队上遮挡收益表现。
            gate:Destroy()
            table.remove(self.gates, i)
        elseif gate:IsOutOfBounds(BOTTOM_RECYCLE_Y) then
            gate:Destroy()
            table.remove(self.gates, i)
        else
            i = i + 1
        end
    end
    if self.gateFeedback ~= nil then
        if previewGate ~= nil then
            local title, detail, color, key = self:_GetGatePreview(previewGate)
            if title ~= nil then self.gateFeedback:ShowPreview(title, detail, color, key) end
        else
            self.gateFeedback:HidePreview()
        end
    end
end

--- ---------------------------------------------------------------
--- 油桶推进（血量由子弹碰撞判定处理，见 _CheckBulletCollisions）
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateBuckets(dt)
    local i = 1
    while i <= #self.buckets do
        local bucket = self.buckets[i]
        bucket:Update(dt)

        if bucket.isDead then
            self:_ExecuteTrigger(bucket.triggerMeta)
            bucket:Destroy()
            table.remove(self.buckets, i)
        elseif bucket:IsOutOfBounds(BOTTOM_RECYCLE_Y) then
            bucket:Destroy()
            table.remove(self.buckets, i)
        else
            i = i + 1
        end
    end
end

--- ---------------------------------------------------------------
--- 子弹碰撞判定（圆形距离，僚机子弹只打敌机/boss/油桶）
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CheckBulletCollisions()
    local bullets = self.bulletPool:GetActiveList()
    if #bullets == 0 then
        return
    end

    -- 向上飞的子弹先经过下方门，再到敌机；按门高度排序避免同时命中多个门。
    self:_CheckBulletsAgainstGates(bullets)

    -- 敌机/boss
    -- 死亡回调会从 enemies 中移除目标，倒序遍历避免跳过相邻敌机。
    for enemyIndex = #self.enemies, 1, -1 do
        local enemy = self.enemies[enemyIndex]
        if not enemy.isDead then
            self:_CheckBulletsAgainstTarget(bullets, enemy, function(dead)
                if dead then
                    self:_OnEnemyDead(enemy)
                end
            end)
            if self.bossDefeat ~= nil then return end
        end
    end

    -- 油桶
    for _, bucket in ipairs(self.buckets) do
        if not bucket.isDead then
            self:_CheckBulletsAgainstTarget(bullets, bucket)
        end
    end
end

function UIPlaneBattleView:_CheckBulletsAgainstGates(bullets)
    local sorted = {}
    for _, gate in ipairs(self.gates) do
        if gate.stgGate ~= nil and not gate.hasTriggered then table.insert(sorted, gate) end
    end
    table.sort(sorted, function(a, b)
        local _, ay = a:GetLocalPos()
        local _, by = b:GetLocalPos()
        return ay < by
    end)
    local i = 1
    while i <= #bullets do
        local bullet, hit = bullets[i], false
        if bullet.faction ~= "enemy" then
            for _, gate in ipairs(sorted) do
                if not bullet.heroSkill and gate:TryHitBullet(bullet) then hit = true; break end
            end
        end
        if hit then self.bulletPool:Remove(bullet) else i = i + 1 end
    end
end

--- 每架英雄机独立装甲和短暂无敌，碰撞使用相对扫掠线段。
function UIPlaneBattleView:_CheckEnemyBulletHits(dt)
    if self.heroCombat ~= nil then self.heroCombat:CheckEnemyBullets() end
end

function UIPlaneBattleView:_CheckBulletsAgainstTarget(bullets, target, onHit)
    local tx, ty = target:GetLocalPos()
    local radius = (target.collideRadius or 35) + BUCKET_COLLIDE_EXTRA

    local i = 1
    while i <= #bullets do
        local b = bullets[i]
        if b.faction == "enemy" then
            i = i + 1
        else
            local pos = b.rt.anchoredPosition
            local dx = pos.x - tx
            local dy = pos.y - ty
            if (dx * dx + dy * dy) <= (radius * radius) then
                local dead = self:_TakeBattleTargetDamage(target, b.damage, pos.x, pos.y)
                local actualDamage = self._lastDamageApplied or 0
                self:_RecordBattleDamage(target, actualDamage, b.sourceId)
                -- 同一目标密集命中合并火花，避免多僚机射击时遮住敌机。
                if not dead and target.kind ~= nil and self.battleTime >= (target.nextImpactAt or 0) then
                    self:_SpawnCombatFx("impact.png", pos.x, pos.y, 48, Color(1, 0.88, 0.5, 0.95), 0.16)
                    target.nextImpactAt = self.battleTime + 0.08
                end
                self.bulletPool:Remove(b)
                if onHit ~= nil then
                    onHit(dead)
                end
                if dead then
                    return
                end
            else
                i = i + 1
            end
        end
    end
end

--- 仅计敌机/Boss 实际扣血，溢出伤害、油桶、数字门不计入英雄输出。
function UIPlaneBattleView:_DamageFromHeroSkill(target, damage, sourceId, x, y)
    if target==nil or target.isDead or self.isBattleOver then return end
    local dead = self:_TakeBattleTargetDamage(target, damage, x, y)
    self:_RecordBattleDamage(target, self._lastDamageApplied or 0, sourceId)
    if dead then
        self:_OnEnemyDead(target)
    else
        self:_SpawnCombatFx("impact.png",x,y,95,Color(.6,.85,1,1),.25)
    end
end

--- Boss 狂暴阶段的额外护盾。护盾吸收伤害但不改变 Boss 血条，破盾时给出一次冲击反馈。
function UIPlaneBattleView:_TakeBattleTargetDamage(target, damage, x, y)
    self._lastDamageApplied = 0
    if target == nil or target.isDead then return true end
    damage = math.max(0, tonumber(damage) or 0)
    if target.kind == "boss" and (target.rageShield or 0) > 0 then
        local absorbed = math.min(target.rageShield, damage)
        target.rageShield = target.rageShield - absorbed
        damage = damage - absorbed
        if self.battleTime >= (target.nextShieldFxAt or 0) then
            local bx, by = target:GetLocalPos()
            self:_SpawnCombatFx("shield_hit.png", x or bx, y or by, 115, Color(0.35, 0.8, 1, 0.9), 0.18)
            target.nextShieldFxAt = self.battleTime + 0.1
        end
        if target.rageShield <= 0 then
            local bx, by = target:GetLocalPos()
            self:_ShowBossPhaseNotice("狂暴护盾已击破")
            self:_SpawnCombatFx("shield_hit.png", bx, by, 360, Color(0.45, 0.9, 1, 1), 0.5)
        end
        if damage <= 0 then return false end
    end
    self._lastDamageApplied = damage
    return target:TakeDamage(damage)
end

function UIPlaneBattleView:_RecordBattleDamage(target, damage, sourceId)
    if self.battleStats == nil or (target.kind ~= "enemy" and target.kind ~= "boss") then return end
    local amount = math.min(math.max(0,target.hp or 0),math.max(0,damage or 0))
    local key = sourceId or "reinforcement"
    self.battleStats.damage[key] = (self.battleStats.damage[key] or 0) + amount
end

function UIPlaneBattleView:_OnEnemyDead(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then
            local x, y = enemy:GetLocalPos()
            self:_SpawnCombatFx("explosion.png", x, y, enemy.kind == "boss" and 250 or 115, Color(1, 1, 1, 1))
            self:_SpawnCombatFx("impact.png", x, y, enemy.kind == "boss" and 220 or 95, Color(1, 0.7, 0.3, 0.95))
            self:_SpawnGoldFlyup(x, y)
            if enemy.kind == "boss" then
                self:_HideBossAim()
                self:_BeginBossDefeat(x, y)
                self.boss = nil
                self:_RefreshBossHud()
                if self.logic ~= nil then
                    self.logic:OnBossDefeated()
                else
                    self:_OnBattleWin()
                end
            end
            enemy:Destroy()
            table.remove(self.enemies, i)
            return
        end
    end
end

function UIPlaneBattleView:_BeginBossDefeat(x, y)
    self.bossDefeat = { age = 0, nextBurst = 1, x = x, y = y }
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Reset() end
    self.bulletPool:Clear()
    self.bossWarningTimer = 0
    if self.bossWarningGo ~= nil and not IsNull(self.bossWarningGo) then
        self.bossWarningGo:SetActive(false)
    end
end

function UIPlaneBattleView:_UpdateBossDefeat(dt)
    local defeat = self.bossDefeat
    if defeat == nil or dt <= 0 then return end
    defeat.age = defeat.age + dt
    self:_UpdateCombatFx(dt)
    if self.bgRenderer ~= nil then self.bgRenderer:Update(dt * 0.25) end
    local bursts = { { 0.12, -62, 30 }, { 0.27, 58, -14 }, { 0.43, -20, -42 }, { 0.58, 12, 20 } }
    while defeat.nextBurst <= #bursts and defeat.age >= bursts[defeat.nextBurst][1] do
        local burst = bursts[defeat.nextBurst]
        self:_SpawnCombatFx("explosion.png", defeat.x + burst[2], defeat.y + burst[3], 150, Color(1, 1, 1, 1))
        defeat.nextBurst = defeat.nextBurst + 1
    end
    if defeat.age >= BOSS_DEFEAT_DURATION then
        self.bossDefeat = nil
        if self.isBattleOver then self:_ShowResultPanel(true) end
    end
end

--- 击毁反馈中的金币只做表现，实际金币结算仍由 StgBattleLogic → OnGoldChanged 管理。
function UIPlaneBattleView:_SpawnGoldFlyup(x, y)
    self:_AcquireCombatFx(RES_DIR .. "PlaneBattle_gold.png", x, y, 38, Color(1, 0.85, 0.2, 1), 0.62, true)
end

--- 同贴图节点回池，命中火花、爆炸和金币共享数量上限，不参与碰撞或输入。
function UIPlaneBattleView:_AcquireCombatFx(path, x, y, size, color, lifetime, gold)
    if self.battleContentTf == nil or #self.combatFx >= MAX_COMBAT_FX then return end
    local fx
    for i = #self.combatFxFree, 1, -1 do
        local candidate = self.combatFxFree[i]
        if IsNull(candidate.go) then
            table.remove(self.combatFxFree, i)
        elseif candidate.path == path then
            fx = table.remove(self.combatFxFree, i)
            break
        end
    end
    if fx == nil then
        local go = GameObject("CombatFx", RectTransform)
        go.transform:SetParent(self.battleContentTf, false)
        local rt = go:GetComponent(RectTransform)
        rt.anchorMin = Vector2(0.5, 0)
        rt.anchorMax = Vector2(0.5, 0)
        rt.pivot = Vector2(0.5, 0.5)
        local img = go:AddComponent(Image)
        img.raycastTarget = false
        img:LoadSprite(path)
        fx = { go = go, rt = rt, img = img, path = path }
    end
    fx.age, fx.lifetime, fx.size = 0, lifetime, size
    fx.color, fx.gold, fx.rise = color or Color(1, 1, 1, 1), gold, gold and 95 or 0
    fx.rt.anchoredPosition = Vector2(x, y)
    fx.rt.sizeDelta = Vector2(size, size)
    fx.img.color = fx.color
    fx.rt:SetAsLastSibling()
    fx.go:SetActive(true)
    table.insert(self.combatFx, fx)
end

function UIPlaneBattleView:_SpawnCombatFx(spriteName, x, y, size, color, lifetime)
    self:_AcquireCombatFx(FX_DIR .. spriteName, x, y, size, color, lifetime or FX_LIFETIME, false)
end

function UIPlaneBattleView:_UpdateCombatFx(dt)
    local i = #self.combatFx
    while i >= 1 do
        local fx = self.combatFx[i]
        if fx.go == nil or IsNull(fx.go) then
            table.remove(self.combatFx, i)
        else
            fx.age = fx.age + dt
            local progress = math.min(1, fx.age / fx.lifetime)
            if fx.gold then
                local p = fx.rt.anchoredPosition
                fx.rt.anchoredPosition = Vector2(p.x, p.y + (fx.rise or 0) * dt)
                fx.rt.sizeDelta = Vector2(fx.size * (1 - progress * 0.3), fx.size * (1 - progress * 0.3))
            else
                fx.rt.sizeDelta = Vector2(fx.size * (0.55 + progress * 0.9), fx.size * (0.55 + progress * 0.9))
            end
            local c = fx.color or Color(1, 1, 1, 1)
            fx.img.color = Color(c.r, c.g, c.b, (1 - progress) * c.a)
            if progress >= 1 then
                fx.go:SetActive(false)
                if #self.combatFxFree < MAX_FREE_COMBAT_FX then
                    table.insert(self.combatFxFree, fx)
                else
                    fx.go:Destroy()
                end
                table.remove(self.combatFx, i)
            end
        end
        i = i - 1
    end
end

function UIPlaneBattleView:_ShowBossWarning(name)
    if self.bossWarningGo == nil or IsNull(self.bossWarningGo) then
        local go = GameObject("BossWarning", RectTransform)
        go.transform:SetParent(self.hudContentTf, false)
        local rt = go:GetComponent(RectTransform)
        rt.anchorMin = Vector2(0.5, 0.5)
        rt.anchorMax = Vector2(0.5, 0.5)
        rt.pivot = Vector2(0.5, 0.5)
        rt.anchoredPosition = Vector2(0, 150)
        rt.sizeDelta = Vector2(600, 90)
        local bg = go:AddComponent(Image)
        bg.color = Color(0.52, 0.04, 0.05, 0.88)
        bg.raycastTarget = false
        local textGo = GameObject("Text", RectTransform)
        textGo.transform:SetParent(go.transform, false)
        local textRt = textGo:GetComponent(RectTransform)
        textRt.anchorMin = Vector2(0, 0)
        textRt.anchorMax = Vector2(1, 1)
        textRt.offsetMin = Vector2(0, 0)
        textRt.offsetMax = Vector2(0, 0)
        local text = textGo:AddComponent(TMPText)
        text.fontSize = 36
        text.fontStyle = CS.TMPro.FontStyles.Bold
        text.alignment = TMPAlign.Center
        text.color = Color(1, 0.92, 0.7, 1)
        text.raycastTarget = false
        _RequestChineseFont(text)
        self.bossWarningGo = go
        self.bossWarningText = text
    end
    self.bossWarningText.text = "警报  " .. tostring(name) .. " 接近"
    self.bossWarningGo:SetActive(true)
    self.bossWarningTimer = 1.8
end

--- 阶段转换沿用首领预警条，避免额外常驻 UI 遮挡弹幕；提示结束后自动隐藏。
function UIPlaneBattleView:_ShowBossPhaseNotice(text)
    if self.bossWarningGo == nil or IsNull(self.bossWarningGo) then
        self:_ShowBossWarning("首领")
    end
    if self.bossWarningText ~= nil and not IsNull(self.bossWarningText) then
        self.bossWarningText.text = tostring(text)
    end
    if self.bossWarningGo ~= nil and not IsNull(self.bossWarningGo) then
        self.bossWarningGo:SetActive(true)
    end
    self.bossWarningTimer = 1.35
end

function UIPlaneBattleView:_UpdateBossWarning(dt)
    if self.bossWarningTimer == nil or self.bossWarningTimer <= 0 then
        return
    end
    self.bossWarningTimer = self.bossWarningTimer - dt
    if self.bossWarningTimer <= 0 and self.bossWarningGo ~= nil and not IsNull(self.bossWarningGo) then
        self.bossWarningGo:SetActive(false)
    end
end

--- ---------------------------------------------------------------
--- 时间轴：按 PlaneSpawn_Config 的 time 字段依次生成内容
--- ---------------------------------------------------------------

function UIPlaneBattleView:_ConsumeSpawnTimeline()
    if self.timeline == nil then
        return
    end

    while self.spawnCursor <= #self.timeline do
        local row = self.timeline[self.spawnCursor]
        if row.time > self.battleTime then
            break
        end

        self:_SpawnByRow(row)
        self.spawnCursor = self.spawnCursor + 1
    end
end

function UIPlaneBattleView:_SpawnByRow(row)
    local x = (tonumber(row.x) or 0) * SCREEN_HALF_W
    local triggerMeta = self.ctrl:GetTriggerMeta(row.trigger_id)

    if row.type == 1 then -- 敌机
        local metaId = tonumber(row.para)
        local enemy = PlaneUnit.New(self.battleContentTf, "enemy", metaId)
        enemy:SetLocalPos(x, SPAWN_TOP_Y)
        table.insert(self.enemies, enemy)
    elseif row.type == 2 then -- 数字门（单侧）
        local gate = GateComponent.New(self.battleContentTf, x, SPAWN_TOP_Y, row.para, triggerMeta)
        table.insert(self.gates, gate)
    elseif row.type == 3 then -- 油桶
        local hp = tonumber(row.para) or 1
        local bucket = BucketComponent.New(self.battleContentTf, x, SPAWN_TOP_Y, hp, triggerMeta)
        table.insert(self.buckets, bucket)
    elseif row.type == 4 then -- boss
        local metaId = tonumber(row.para)
        local boss = PlaneUnit.New(self.battleContentTf, "boss", metaId)
        boss:SetLocalPos(x, SPAWN_TOP_Y)
        table.insert(self.enemies, boss)
    elseif row.type == 5 then -- 锁定门（阈值门，横跨全屏不分左右）
        local gate = GateComponent.New(self.battleContentTf, 0, SPAWN_TOP_Y, row.para, nil, "lock")
        table.insert(self.gates, gate)
    end
end

--- ---------------------------------------------------------------
--- 触发效果执行（对接 Logic/TriggerEventManager）
--- ---------------------------------------------------------------

function UIPlaneBattleView:_ExecuteTrigger(triggerMeta)
    if triggerMeta == nil then
        return
    end

    TriggerEventManager.Execute(triggerMeta, {
        AddWingman = function(count) self:_SetWingmanCount(#self.wingmen + count) end,
        RemoveWingman = function(count) self:_SetWingmanCount(#self.wingmen - count) end,
        AddGold = function(count)
            local mgr = DataCenter.PlaneBattleDataManager
            if mgr ~= nil then
                mgr:AddGold(count)
            end
        end,
        AddWingmanSupply = function(count) self:_SetWingmanCount(#self.wingmen + count) end,
    })
end

--- ---------------------------------------------------------------
--- 战斗结算
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CheckBattleEnd()
    -- 时间到但没有boss/时间轴已耗尽且场上没有敌人 → 判负（首期简单规则：超时算失败）
    if self.levelMeta ~= nil and self.levelMeta.duration ~= nil then
        if self.battleTime > tonumber(self.levelMeta.duration) + 30 then
            self:_OnBattleLose()
        end
    end
end

function UIPlaneBattleView:_OnBattleWin()
    if self.isBattleOver then
        return
    end
    self.isBattleOver = true
    if self.heroCombat then self.heroCombat:CancelPending() end
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Reset() end
    self:_HideBossAim()
    Logger.Log('#PlaneBattle# 战斗胜利 levelId=' .. tostring(self.levelId))
    self.ctrl:OnBattleWin(self.levelId, 50)
    if self.bossDefeat == nil then
        self:_ShowResultPanel(true)
    end
end

function UIPlaneBattleView:_OnBattleLose()
    if self.isBattleOver then
        return
    end
    self.isBattleOver = true
    if self.heroCombat then self.heroCombat:CancelPending() end
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Reset() end
    self:_HideBossAim()
    Logger.Log('#PlaneBattle# 战斗失败 levelId=' .. tostring(self.levelId))
    self.ctrl:OnBattleLose(self.levelId)
    self:_ShowResultPanel(false)
end

function UIPlaneBattleView:_CloseSelf()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIPlaneBattle)
end

--- ---------------------------------------------------------------
--- 跳过：直接判胜（策划意图是跳过战斗表现，不是真的放弃）
--- ---------------------------------------------------------------

function UIPlaneBattleView:_OnClickSkip()
    if self.isBattleOver then
        return
    end
    if self.logic ~= nil then
        -- STG 路径：由逻辑切 Result 并回调 OnBattleWin
        self.logic:Win()
    else
        self:_OnBattleWin()
    end
end

--- ---------------------------------------------------------------
--- 顶部 HUD：关卡名 / 金币 / 跳过 / 敌方兵力
--- ---------------------------------------------------------------

-- HUD 使用独立材质，去掉小字上的粗描边，不修改共享字体资产。
function UIPlaneBattleView:_RequestHudFont(text)
    _RequestChineseFont(text, function()
        if self.hudContentTf == nil or IsNull(self.hudContentTf) or IsNull(text) then return end
        if self.hudTextMaterial == nil then
            self.hudTextMaterial = CS.UnityEngine.Material(text.font.material)
            self.hudTextMaterial:SetFloat("_OutlineWidth", 0)
            self.hudTextMaterial:SetFloat("_FaceDilate", 0)
            self.hudTextMaterial:DisableKeyword("OUTLINE_ON")
            self.hudTextMaterial:DisableKeyword("UNDERLAY_ON")
            self.hudTextMaterial:DisableKeyword("UNDERLAY_INNER")
        end
        text.fontSharedMaterial = self.hudTextMaterial
        text.fontStyle = CS.TMPro.FontStyles.Normal
        text.extraPadding = false
    end)
end

function UIPlaneBattleView:_CreateHud()
    -- 信息集中在顶部，战场主体保持开阔。所有装饰均不拦截拖动。
    local plateGo = GameObject("HudTopPlate", RectTransform)
    plateGo.transform:SetParent(self.hudContentTf, false)
    local plateRt = plateGo:GetComponent(RectTransform)
    plateRt.anchorMin = Vector2(0, 1)
    plateRt.anchorMax = Vector2(1, 1)
    plateRt.pivot = Vector2(0.5, 1)
    plateRt.anchoredPosition = Vector2(0, 0)
    plateRt.sizeDelta = Vector2(0, 150)
    local plateImg = plateGo:AddComponent(Image)
    plateImg.color = Color(0.025, 0.055, 0.085, 0.86)
    plateImg.raycastTarget = false

    local trackGo = GameObject("HudProgressTrack", RectTransform)
    trackGo.transform:SetParent(self.hudContentTf, false)
    local trackRt = trackGo:GetComponent(RectTransform)
    trackRt.anchorMin = Vector2(0, 1)
    trackRt.anchorMax = Vector2(1, 1)
    trackRt.pivot = Vector2(0.5, 1)
    trackRt.offsetMin = Vector2(28, -152)
    trackRt.offsetMax = Vector2(-28, -147)
    local trackImg = trackGo:AddComponent(Image)
    trackImg.color = Color(0.2, 0.36, 0.44, 0.65)
    trackImg.raycastTarget = false
    local fillGo = GameObject("Progress", RectTransform)
    fillGo.transform:SetParent(trackGo.transform, false)
    local fillRt = fillGo:GetComponent(RectTransform)
    fillRt.anchorMin = Vector2(0, 0)
    fillRt.anchorMax = Vector2(0, 1)
    fillRt.offsetMin = Vector2(0, 0)
    fillRt.offsetMax = Vector2(0, 0)
    local fillImg = fillGo:AddComponent(Image)
    fillImg.color = Color(0.25, 0.85, 1, 1)
    fillImg.raycastTarget = false
    self.hudProgressRt = fillRt

    -- 英雄头像、装甲和技能集中到底栏，顶部不再重复显示驾驶员小字。

    -- Boss 血条默认隐藏，由 Boss 配置真正生成后显示。
    local bossGo = GameObject("HudBoss", RectTransform)
    bossGo.transform:SetParent(self.hudContentTf, false)
    local bossRt = bossGo:GetComponent(RectTransform)
    bossRt.anchorMin = Vector2(0.5, 1)
    bossRt.anchorMax = Vector2(0.5, 1)
    bossRt.pivot = Vector2(0.5, 1)
    bossRt.anchoredPosition = Vector2(0, -176)
    bossRt.sizeDelta = Vector2(520, 44)
    local bossBg = bossGo:AddComponent(Image)
    bossBg.color = Color(0.06, 0.03, 0.08, 0.9)
    bossBg.raycastTarget = false
    local bossFillGo = GameObject("Fill", RectTransform)
    bossFillGo.transform:SetParent(bossGo.transform, false)
    local bossFillRt = bossFillGo:GetComponent(RectTransform)
    bossFillRt.anchorMin = Vector2(0, 0)
    bossFillRt.anchorMax = Vector2(1, 1)
    bossFillRt.offsetMin = Vector2(4, 4)
    bossFillRt.offsetMax = Vector2(-4, -4)
    local bossFill = bossFillGo:AddComponent(Image)
    bossFill.color = Color(1, 0.26, 0.2, 1)
    bossFill.raycastTarget = false
    local bossTextGo = GameObject("Text", RectTransform)
    bossTextGo.transform:SetParent(bossGo.transform, false)
    local bossTextRt = bossTextGo:GetComponent(RectTransform)
    bossTextRt.anchorMin = Vector2(0, 0)
    bossTextRt.anchorMax = Vector2(1, 1)
    bossTextRt.offsetMin = Vector2(0, 0)
    bossTextRt.offsetMax = Vector2(0, 0)
    local bossText = bossTextGo:AddComponent(TMPText)
    bossText.fontSize = 26
    bossText.fontStyle = CS.TMPro.FontStyles.Bold
    bossText.alignment = TMPAlign.Center
    bossText.color = Color(1, 1, 1, 1)
    bossText.raycastTarget = false
    self:_RequestHudFont(bossText)
    self.hudBossRoot = bossGo
    self.hudBossFillRt = bossFillRt
    self.hudBossText = bossText

    local shieldGo = GameObject("Shield", RectTransform)
    shieldGo.transform:SetParent(self.hudContentTf, false)
    local shieldRt = shieldGo:GetComponent(RectTransform)
    shieldRt.anchorMin = Vector2(0.5, 1)
    shieldRt.anchorMax = Vector2(0.5, 1)
    shieldRt.pivot = Vector2(0.5, 1)
    shieldRt.anchoredPosition = Vector2(0, -228)
    shieldRt.sizeDelta = Vector2(520, 32)
    local shieldBg = shieldGo:AddComponent(Image)
    shieldBg.color = Color(0.02, 0.12, 0.22, 0.92)
    shieldBg.raycastTarget = false
    local shieldFillGo = GameObject("Fill", RectTransform)
    shieldFillGo.transform:SetParent(shieldGo.transform, false)
    local shieldFillRt = shieldFillGo:GetComponent(RectTransform)
    shieldFillRt.anchorMin, shieldFillRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    shieldFillRt.offsetMin, shieldFillRt.offsetMax = Vector2(3, 3), Vector2(-3, -3)
    local shieldFill = shieldFillGo:AddComponent(Image)
    shieldFill.color = Color(0.25, 0.78, 1, 1)
    shieldFill.raycastTarget = false
    local shieldTextGo = GameObject("Text", RectTransform)
    shieldTextGo.transform:SetParent(shieldGo.transform, false)
    local shieldTextRt = shieldTextGo:GetComponent(RectTransform)
    shieldTextRt.anchorMin, shieldTextRt.anchorMax = Vector2(0, 0), Vector2(1, 1)
    shieldTextRt.offsetMin, shieldTextRt.offsetMax = Vector2(0, 0), Vector2(0, 0)
    local shieldText = shieldTextGo:AddComponent(TMPText)
    shieldText.fontSize = 23
    shieldText.fontStyle = CS.TMPro.FontStyles.Bold
    shieldText.alignment = TMPAlign.Center
    shieldText.color = Color(0.78, 0.95, 1, 1)
    shieldText.raycastTarget = false
    self:_RequestHudFont(shieldText)
    self.hudBossShieldGo = shieldGo
    self.hudBossShieldFillRt = shieldFillRt
    self.hudBossShieldText = shieldText
    bossGo:SetActive(false)
    shieldGo:SetActive(false)

    local timeGo = GameObject("HudTime", RectTransform)
    timeGo.transform:SetParent(self.hudContentTf, false)
    local timeRt = timeGo:GetComponent(RectTransform)
    timeRt.anchorMin = Vector2(0.5, 1)
    timeRt.anchorMax = Vector2(0.5, 1)
    timeRt.pivot = Vector2(0.5, 1)
    timeRt.anchoredPosition = Vector2(0, -103)
    timeRt.sizeDelta = Vector2(260, 38)
    local timeText = timeGo:AddComponent(TMPText)
    timeText.fontSize = 26
    timeText.alignment = TMPAlign.Center
    timeText.color = Color(0.65, 0.8, 0.88, 1)
    timeText.raycastTarget = false
    self:_RequestHudFont(timeText)
    self.hudTimeText = timeText

    -- 关卡名：顶部居中
    local nameGo = GameObject("HudLevelName", RectTransform)
    nameGo.transform:SetParent(self.hudContentTf, false)
    local nameRt = nameGo:GetComponent(RectTransform)
    nameRt.anchorMin = Vector2(0.5, 1)
    nameRt.anchorMax = Vector2(0.5, 1)
    nameRt.pivot = Vector2(0.5, 1)
    nameRt.anchoredPosition = Vector2(0, -42)
    nameRt.sizeDelta = Vector2(250, 48)
    local nameText = nameGo:AddComponent(TMPText)
    nameText.text = ""
    nameText.fontSize = 32
    nameText.fontStyle = CS.TMPro.FontStyles.Bold
    nameText.alignment = TMPAlign.Center
    nameText.color = Color(1, 1, 1, 1)
    nameText.raycastTarget = false
    self:_RequestHudFont(nameText)
    self.hudLevelNameText = nameText

    -- 金币：左上角图标 + 数字
    local coinIconGo = GameObject("HudCoinIcon", RectTransform)
    coinIconGo.transform:SetParent(self.hudContentTf, false)
    local coinIconRt = coinIconGo:GetComponent(RectTransform)
    coinIconRt.anchorMin = Vector2(0, 1)
    coinIconRt.anchorMax = Vector2(0, 1)
    coinIconRt.pivot = Vector2(0, 1)
    coinIconRt.anchoredPosition = Vector2(30, -103)
    coinIconRt.sizeDelta = Vector2(28, 28)
    local coinIconImg = coinIconGo:AddComponent(Image)
    coinIconImg.raycastTarget = false
    coinIconImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_coin.png")

    local goldGo = GameObject("HudGoldText", RectTransform)
    goldGo.transform:SetParent(self.hudContentTf, false)
    local goldRt = goldGo:GetComponent(RectTransform)
    goldRt.anchorMin = Vector2(0, 1)
    goldRt.anchorMax = Vector2(0, 1)
    goldRt.pivot = Vector2(0, 1)
    goldRt.anchoredPosition = Vector2(66, -103)
    goldRt.sizeDelta = Vector2(160, 42)
    local goldText = goldGo:AddComponent(TMPText)
    goldText.text = "0"
    goldText.fontSize = 28
    goldText.fontStyle = CS.TMPro.FontStyles.Bold
    goldText.alignment = TMPAlign.Left
    goldText.color = Color(1, 0.85, 0.2, 1)
    goldText.raycastTarget = false
    self:_RequestHudFont(goldText)
    self.hudGoldText = goldText

    -- 跳过：右上角半透明按钮
    local skipGo = GameObject("HudSkipBtn", RectTransform)
    skipGo.transform:SetParent(self.hudContentTf, false)
    local skipRt = skipGo:GetComponent(RectTransform)
    skipRt.anchorMin = Vector2(1, 1)
    skipRt.anchorMax = Vector2(1, 1)
    skipRt.pivot = Vector2(1, 1)
    skipRt.anchoredPosition = Vector2(-28, -38)
    skipRt.sizeDelta = Vector2(120, 52)
    local skipImg = skipGo:AddComponent(Image)
    skipImg.color = Color(0.12, 0.24, 0.32, 0.9)

    local skipTextGo = GameObject("Text", RectTransform)
    skipTextGo.transform:SetParent(skipGo.transform, false)
    local skipTextRt = skipTextGo:GetComponent(RectTransform)
    skipTextRt.anchorMin = Vector2(0, 0)
    skipTextRt.anchorMax = Vector2(1, 1)
    skipTextRt.offsetMin = Vector2(0, 0)
    skipTextRt.offsetMax = Vector2(0, 0)
    local skipText = skipTextGo:AddComponent(TMPText)
    skipText.text = "跳过 >"
    skipText.fontSize = 26
    skipText.alignment = TMPAlign.Center
    skipText.color = Color(1, 1, 1, 1)
    skipText.raycastTarget = false
    self:_RequestHudFont(skipText)

    local skipBtn = skipGo:AddComponent(Button)
    skipBtn.onClick:AddListener(function() self:_OnClickSkip() end)

    -- 敌方兵力：顶部居中偏下，深色胶囊 + 骷髅头 + 数字
    local capsuleGo = GameObject("HudEnemyCapsule", RectTransform)
    capsuleGo.transform:SetParent(self.hudContentTf, false)
    local capsuleRt = capsuleGo:GetComponent(RectTransform)
    capsuleRt.anchorMin = Vector2(1, 1)
    capsuleRt.anchorMax = Vector2(1, 1)
    capsuleRt.pivot = Vector2(1, 1)
    capsuleRt.anchoredPosition = Vector2(-28, -103)
    capsuleRt.sizeDelta = Vector2(140, 38)
    local capsuleImg = capsuleGo:AddComponent(Image)
    capsuleImg.color = Color(0, 0, 0, 0)
    capsuleImg.raycastTarget = false

    local skullGo = GameObject("Skull", RectTransform)
    skullGo.transform:SetParent(capsuleGo.transform, false)
    local skullRt = skullGo:GetComponent(RectTransform)
    skullRt.anchorMin = Vector2(0, 0.5)
    skullRt.anchorMax = Vector2(0, 0.5)
    skullRt.pivot = Vector2(0.5, 0.5)
    skullRt.anchoredPosition = Vector2(15, 0)
    skullRt.sizeDelta = Vector2(24, 24)
    local skullImg = skullGo:AddComponent(Image)
    skullImg.raycastTarget = false
    skullImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_skull.png")

    local enemyTextGo = GameObject("Text", RectTransform)
    enemyTextGo.transform:SetParent(capsuleGo.transform, false)
    local enemyTextRt = enemyTextGo:GetComponent(RectTransform)
    enemyTextRt.anchorMin = Vector2(0, 0)
    enemyTextRt.anchorMax = Vector2(1, 1)
    enemyTextRt.offsetMin = Vector2(36, 0)
    enemyTextRt.offsetMax = Vector2(0, 0)
    local enemyText = enemyTextGo:AddComponent(TMPText)
    enemyText.text = "0"
    enemyText.fontSize = 26
    enemyText.fontStyle = CS.TMPro.FontStyles.Bold
    enemyText.alignment = TMPAlign.Left
    enemyText.color = Color(1, 1, 1, 1)
    enemyText.raycastTarget = false
    self.hudEnemyText = enemyText
    self:_RequestHudFont(enemyText)

    local hullGo = GameObject("HudHull", RectTransform)
    hullGo.transform:SetParent(self.hudContentTf, false)
    local hullRt = hullGo:GetComponent(RectTransform)
    hullRt.anchorMin = Vector2(0, 1)
    hullRt.anchorMax = Vector2(0, 1)
    hullRt.pivot = Vector2(0, 1)
    hullRt.anchoredPosition = Vector2(100, -46)
    hullRt.sizeDelta = Vector2(150, 38)
    local hullText = hullGo:AddComponent(TMPText)
    hullText.fontSize = 26
    hullText.fontStyle = CS.TMPro.FontStyles.Bold
    hullText.alignment = TMPAlign.Left
    hullText.color = Color(0.45, 0.9, 1, 1)
    hullText.raycastTarget = false
    self.hudHullText = hullText
    self:_RequestHudFont(hullText)
    self:_RefreshHudHull()
    self:_RefreshHudProgress()
end

function UIPlaneBattleView:_RefreshBossHud()
    if self.hudBossRoot == nil or IsNull(self.hudBossRoot) then
        return
    end
    local boss = self.boss
    local visible = boss ~= nil and not boss.isDead
    self.hudBossRoot:SetActive(visible)
    if not visible then
        if self.hudBossShieldGo ~= nil and not IsNull(self.hudBossShieldGo) then self.hudBossShieldGo:SetActive(false) end
        return
    end
    local fraction = math.max(0, math.min(1, (boss.hp or 0) / math.max(1, boss.maxHp or 1)))
    self.hudBossFillRt.anchorMax = Vector2(fraction, 1)
    local phaseText = (boss.phaseId or 1) >= 2 and "狂暴阶段" or "阶段 1"
    self.hudBossText.text = "首领·" .. phaseText .. "  "
        .. tostring(math.ceil(boss.hp or 0)) .. " / " .. tostring(math.ceil(boss.maxHp or 0))
    local shield = math.max(0, boss.rageShield or 0)
    local shieldMax = math.max(1, boss.rageShieldMax or 1)
    local shieldVisible = shield > 0 and (boss.phaseId or 1) >= 2
    if self.hudBossShieldGo ~= nil and not IsNull(self.hudBossShieldGo) then
        self.hudBossShieldGo:SetActive(shieldVisible)
        if shieldVisible then
            self.hudBossShieldFillRt.anchorMax = Vector2(math.max(0, math.min(1, shield / shieldMax)), 1)
            self.hudBossShieldText.text = "狂暴护盾  " .. tostring(math.ceil(shield)) .. " / " .. tostring(math.ceil(shieldMax))
        end
    end
end

function UIPlaneBattleView:_RefreshHudLevelName()
    if self.hudLevelNameText == nil or IsNull(self.hudLevelNameText) then
        return
    end
    local name = self.battleLevelName or (self.levelMeta and self.levelMeta.name)
    if name == nil or name == "" then
        name = "关卡 " .. tostring(self.levelId or "")
    end
    self.hudLevelNameText.text = name
end

function UIPlaneBattleView:_RefreshHudProgress()
    local duration = self.battleDuration or 0
    local elapsed = self.battleTime or 0
    if self.hudProgressRt ~= nil and not IsNull(self.hudProgressRt) then
        local progress = duration > 0 and math.min(elapsed / duration, 1) or 0
        self.hudProgressRt.anchorMax = Vector2(progress, 1)
    end
    local second = math.floor(elapsed)
    if second ~= self.lastHudSecond and self.hudTimeText ~= nil and not IsNull(self.hudTimeText) then
        self.lastHudSecond = second
        self.hudTimeText.text = string.format("%02d:%02d / %02d:%02d",
            math.floor(elapsed / 60), second % 60, math.floor(duration / 60), math.floor(duration % 60))
    end
end

function UIPlaneBattleView:_RefreshHudGold()
    local mgr = DataCenter.PlaneBattleDataManager
    if mgr ~= nil then
        self:_OnGoldChanged(mgr:GetTotalGold())
    end
end

function UIPlaneBattleView:_RefreshHudEnemyCount()
    if self.hudEnemyText == nil or IsNull(self.hudEnemyText) then
        return
    end
    local count = #self.enemies
    if count == self.lastHudEnemyCount then
        return
    end
    self.lastHudEnemyCount = count
    self.hudEnemyText.text = "敌机 " .. tostring(count)
end

function UIPlaneBattleView:_RefreshHudHull()
    if self.hudHullText == nil or IsNull(self.hudHullText) then
        return
    end
    local hull = self.playerHull or 0
    self.hudHullText.text = "装甲 " .. tostring(hull) .. "/" .. tostring(self.playerHullMax or PLAYER_HULL_MAX)
    self.hudHullText.color = hull <= 1 and Color(1, 0.45, 0.32, 1) or Color(0.45, 0.9, 1, 1)
end

--- ---------------------------------------------------------------
--- 操作引导：左右箭头 + 手指 + 文字提示，首次拖动后消失（本局会话内只显示一次）
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CreateGuide()
    if guideShownInSession then
        return
    end

    local groupGo = GameObject("GuideGroup", RectTransform)
    groupGo.transform:SetParent(self.hudContentTf, false)
    local groupRt = groupGo:GetComponent(RectTransform)
    groupRt.anchorMin = Vector2(0, 0)
    groupRt.anchorMax = Vector2(1, 1)
    groupRt.offsetMin = Vector2(0, 0)
    groupRt.offsetMax = Vector2(0, 0)
    self.guideGroupGo = groupGo

    local function addArrow(offsetX, text)
        local arrowGo = GameObject("Arrow", RectTransform)
        arrowGo.transform:SetParent(groupGo.transform, false)
        local arrowRt = arrowGo:GetComponent(RectTransform)
        arrowRt.anchorMin = Vector2(0.5, 0)
        arrowRt.anchorMax = Vector2(0.5, 0)
        arrowRt.pivot = Vector2(0.5, 0.5)
        arrowRt.anchoredPosition = Vector2(offsetX, PLANE_BOTTOM_Y + 190)
        arrowRt.sizeDelta = Vector2(60, 60)
        local arrowText = arrowGo:AddComponent(Text)
        arrowText.text = text
        arrowText.fontSize = 48
        arrowText.fontStyle = CS.UnityEngine.FontStyle.Bold
        arrowText.alignment = CS.UnityEngine.TextAnchor.MiddleCenter
        arrowText.color = Color(1, 1, 1, 0.65)
        arrowText.raycastTarget = false
    end

    addArrow(-120, "<")
    addArrow(120, ">")

    local handGo = GameObject("HandCursor", RectTransform)
    handGo.transform:SetParent(groupGo.transform, false)
    local handRt = handGo:GetComponent(RectTransform)
    handRt.anchorMin = Vector2(0.5, 0)
    handRt.anchorMax = Vector2(0.5, 0)
    handRt.pivot = Vector2(0.5, 0.5)
    handRt.anchoredPosition = Vector2(0, PLANE_BOTTOM_Y + 200)
    handRt.sizeDelta = Vector2(42, 58)
    local handImg = handGo:AddComponent(Image)
    handImg.raycastTarget = false
    handImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_handcursor.png")

    local hintGo = GameObject("HintText", RectTransform)
    hintGo.transform:SetParent(groupGo.transform, false)
    local hintRt = hintGo:GetComponent(RectTransform)
    hintRt.anchorMin = Vector2(0.5, 0)
    hintRt.anchorMax = Vector2(0.5, 0)
    hintRt.pivot = Vector2(0.5, 0.5)
    hintRt.anchoredPosition = Vector2(0, PLANE_BOTTOM_Y + 160)
    hintRt.sizeDelta = Vector2(320, 50)
    local hintText = hintGo:AddComponent(TMPText)
    hintText.text = "按住 & 拖动"
    hintText.fontSize = 23
    hintText.alignment = TMPAlign.Center
    hintText.color = Color(0.75, 0.9, 1, 0.85)
    hintText.raycastTarget = false
    self:_RequestHudFont(hintText)
end

function UIPlaneBattleView:_HideGuide()
    if self.guideGroupGo ~= nil and not IsNull(self.guideGroupGo) then
        self.guideGroupGo:SetActive(false)
    end
end

--- ---------------------------------------------------------------
--- 返回按钮：左下角
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CreateBackButton()
    local backGo = GameObject("BtnBack", RectTransform)
    backGo.transform:SetParent(self.hudContentTf, false)
    local backRt = backGo:GetComponent(RectTransform)
    backRt.anchorMin = Vector2(0, 1)
    backRt.anchorMax = Vector2(0, 1)
    backRt.pivot = Vector2(0, 1)
    backRt.anchoredPosition = Vector2(28, -38)
    backRt.sizeDelta = Vector2(58, 52)
    local backImg = backGo:AddComponent(Image)
    backImg:LoadSprite(RES_DIR .. "PlaneBattle_btn_back.png")

    local backBtn = backGo:AddComponent(Button)
    -- 战斗中点返回：回选关界面，不关窗（和 barrel 跑酷关"结算后回选关"同一闭环）
    backBtn.onClick:AddListener(function() self:_ShowLevelSelect() end)
end

--- ---------------------------------------------------------------
--- 结算面板：胜利/失败
--- ---------------------------------------------------------------

function UIPlaneBattleView:_ShowResultPanel(isWin)
    if self.resultView == nil then
        self.resultView = BattleResultPanel.New(self.transform, _RequestChineseFont,
            function() self:_ShowLevelSelect() end, function() self:_OnClickNextLevel() end)
        self.resultPanelGo = self.resultView.go
    end
    local hasNext = self.ctrl:GetLevelMeta((tonumber(self.levelId) or 0) + 1) ~= nil
    self.resultView:Show(isWin, self.battleTeam, self.battleStats, self.battleTime, self.battleLevelName, hasNext)
end

function UIPlaneBattleView:_HideResultPanel()
    if self.resultPanelGo ~= nil and not IsNull(self.resultPanelGo) then
        self.resultPanelGo:SetActive(false)
    end
end

--- 五槽编队与选关共用入口。
function UIPlaneBattleView:_BuildLevelSelectPanel()
    local createPanel = function()
        if self.formationPanel ~= nil or self.transform == nil or IsNull(self.transform) then return end
        self.formationPanel = BattleFormationPanel.New(self.transform, _RequestChineseFont, self.ctrl,
            function(id) self:_EnterLevel(id) end, function() self:CloseSelf() end)
        self.levelSelectGo = self.formationPanel.go
        if self.levelSelectPending then
            self.levelSelectPending = false
            self:_ShowLevelSelect()
        end
    end
    self.levelSelectPanelCreate = createPanel
    -- 首次打开时先异步准备中文 TMP 字体，再创建包含中文的编队节点。
    -- 这样 TMP 不会经历“默认字体创建中文文本”的缺字告警阶段。
    if ChineseFontAsset ~= nil then
        createPanel()
    else
        _RequestChineseFont(nil, createPanel)
    end
end

function UIPlaneBattleView:_ShowLevelSelect()
    self.isInLevelSelect = true
    self.isBattleOver = true  -- 阻止 Update 里的战斗逻辑

    self:_ClearBattleObjects()
    if self.logic ~= nil then
        self.logic:Destroy()
        self.logic = nil
    end
    self:_HideResultPanel()
    self:_SetBattleHudVisible(false)

    if self.guideGroupGo ~= nil and not IsNull(self.guideGroupGo) then
        self.guideGroupGo:SetActive(false)
    end

    if self.formationPanel == nil then
        self.levelSelectPending = true
        return
    end
    if self.levelSelectGo ~= nil and not IsNull(self.levelSelectGo) then
        self.levelSelectGo:SetActive(true)
    end
    self.formationPanel:Show()

    Logger.Log('#PlaneBattle# 打开选关界面')
end

function UIPlaneBattleView:_HideLevelSelect()
    self.isInLevelSelect = false
    if self.levelSelectGo ~= nil and not IsNull(self.levelSelectGo) then
        self.levelSelectGo:SetActive(false)
    end
end

function UIPlaneBattleView:_SetBattleHudVisible(visible)
    if self.battleContentTf ~= nil and not IsNull(self.battleContentTf) then
        self.battleContentTf.gameObject:SetActive(visible)
    end
    if self.hudContentTf ~= nil and not IsNull(self.hudContentTf) then
        self.hudContentTf.gameObject:SetActive(visible)
    end
end

--- 胜利面板点"下一关"
function UIPlaneBattleView:_OnClickNextLevel()
    local nextLevelId = (tonumber(self.levelId) or 0) + 1
    if self.ctrl:GetLevelMeta(nextLevelId) == nil then
        self:_ShowLevelSelect()
        return
    end
    self:_HideResultPanel()
    self:_EnterLevel(nextLevelId)
end

--- ---------------------------------------------------------------
--- 清理
--- ---------------------------------------------------------------

function UIPlaneBattleView:_ClearBattleObjects()
    if self.heroCombat ~= nil then self.heroCombat:Delete(); self.heroCombat = nil end
    for _, unit in ipairs(self.heroEscorts or {}) do unit:Destroy() end
    self.heroEscorts = {}
    if self.playerHeroBadge ~= nil and not IsNull(self.playerHeroBadge) then self.playerHeroBadge:Destroy() end
    self.playerHeroBadge = nil
    if self.secondaryWeapon ~= nil then self.secondaryWeapon:Reset() end
    self.primaryFireTimer = 0
    if self.playerFlightVisual ~= nil then
        self.playerFlightVisual:Reset(self:GetPlayerPlanePos())
    end
    self.isResolvingGate = false
    self.displayLogicalCount = 0
    if self.gateFeedback ~= nil then
        self.gateFeedback:Reset()
        self.gateFeedback:SetCount(0)
    end
    self.bossDefeat = nil
    if self.bossAimGo ~= nil and not IsNull(self.bossAimGo) then
        self.bossAimGo:Destroy()
    end
    self.bossAimGo = nil
    self.bossAimLines = {}
    for _, fx in ipairs(self.combatFx or {}) do
        if fx.go ~= nil and not IsNull(fx.go) then
            fx.go:Destroy()
        end
    end
    self.combatFx = {}
    for _, fx in ipairs(self.combatFxFree or {}) do
        if fx.go ~= nil and not IsNull(fx.go) then fx.go:Destroy() end
    end
    self.combatFxFree = {}
    self.boss = nil
    self.bossWarningTimer = 0
    if self.bossWarningGo ~= nil and not IsNull(self.bossWarningGo) then
        self.bossWarningGo:SetActive(false)
    end
    self:_RefreshBossHud()

    for _, wingman in ipairs(self.wingmen or {}) do
        wingman:Destroy()
    end
    self.wingmen = {}

    for _, enemy in ipairs(self.enemies or {}) do
        enemy:Destroy()
    end
    self.enemies = {}

    for _, gate in ipairs(self.gates or {}) do
        gate:Destroy()
    end
    self.gates = {}

    for _, bucket in ipairs(self.buckets or {}) do
        bucket:Destroy()
    end
    self.buckets = {}

    -- STG 门是纯逻辑对象，无 GameObject，清列表即可
    self.stgGates = {}

    if self.bulletPool ~= nil then
        self.bulletPool:Clear()
    end

    -- 背景层：清掉旧关卡的贴图带/装饰物节点。
    -- 这里只清层、不销毁 renderer 本身（renderer 生命周期跟随窗口，见 OnCreate/OnDestroy）——
    -- _EnterLevel 的调用顺序是先 _ClearBattleObjects 再 OnLevelLoaded→Setup，
    -- 所以进关时这里清空、紧接着 Setup 重建，正好是"清旧建新"，不会把刚建的背景清掉
    if self.bgRenderer ~= nil then
        self.bgRenderer:ClearLayers()
    end
end

return UIPlaneBattleView
