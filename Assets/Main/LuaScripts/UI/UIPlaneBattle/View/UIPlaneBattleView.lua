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
local TriggerEventManager  = require "UI.UIPlaneBattle.Logic.TriggerEventManager"
local BulletPool           = require "UI.UIPlaneBattle.Component.BulletPool"
local PlaneUnit            = require "UI.UIPlaneBattle.Component.PlaneUnit"
local GateComponent        = require "UI.UIPlaneBattle.Component.GateComponent"
local BucketComponent      = require "UI.UIPlaneBattle.Component.BucketComponent"
-- STG 运行时：时间轴/波次/门/结算由 StgBattleLogic 驱动，View 只做表现
local StgBattleLogic       = require "Game.STG.Logic.StgBattleLogic"
local StgGateFactory       = require "Game.STG.Entity.Gate.StgGateFactory"

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
local CHINESE_FONT_PATH = "Assets/Main/Fonts/NotoSansSC-Bold SDF.asset"
local ChineseFontAsset   = nil
local ChineseFontPending = {}
local ChineseFontLoading = false

local function _RequestChineseFont(tmpComp)
    if ChineseFontAsset ~= nil then
        tmpComp.font = ChineseFontAsset
        return
    end
    table.insert(ChineseFontPending, tmpComp)
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
            for _, t in ipairs(ChineseFontPending) do
                if t ~= nil and not IsNull(t) then
                    t.font = font
                end
            end
        end
        ChineseFontPending = {}
    end)
end

--- 操作引导只在本局游戏会话里第一次进入战斗时显示一次，模块级变量跨窗口实例保留状态
local guideShownInSession = false

--- 参考画布参考分辨率 750x1625（GameFramework.prefab 里 UIContainer 的 CanvasScaler 设定）
local SAFE_HALF_WIDTH  = 300  -- 主机左右可移动范围：屏幕中心 ±300
local PLANE_SIZE       = Vector2(107, 75)
local PLANE_BOTTOM_Y   = 220  -- 主机距底部的固定高度（anchoredPosition.y，锚点在底部中心）
local WINGMAN_MAX      = 24   -- 僚机数量上限（超过转火力倍率，首期不做倍率，先夹上限）
local SCREEN_HALF_W    = 375  -- 参考分辨率宽 750 的一半，出生点 x 用这个换算成像素
local SPAWN_TOP_Y      = 900  -- 内容按时间轴从这个高度开始下落
local BOTTOM_RECYCLE_Y = -900 -- 低于这个高度回收（飞出屏幕底部）
local WINGMAN_FIRE_INTERVAL = 0.5
local WINGMAN_BULLET_DAMAGE = 10
local BUCKET_COLLIDE_EXTRA  = 25 -- 子弹与油桶/敌机的命中判定半径（子弹半径+目标半径的简化值）

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
    self.wingmanFireTimer = 0
    self.spawnCursor = 1   -- 时间轴下一个待生成的索引（legacy 路径用）
    self.logic = nil       -- StgBattleLogic 实例（STG 路径）
    self.stgGates = {}     -- StgGate 实例列表（STG 路径的门）

    self:_CreateBattleContentRoot()
    self:_CreatePlayerPlane()
    self.bulletPool = BulletPool.New(self.battleContentTf)
    self.lastHudEnemyCount = -1

    self:_CreateHud()
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
    if self.logic ~= nil then
        self.logic:Destroy()
        self.logic = nil
    end
    if self.bulletPool ~= nil then
        self.bulletPool:Clear()
        self.bulletPool = nil
    end

    -- 关键：窗口关闭走的是对象池 SetActive(false)（GameObject 会被复用），不是真正 Destroy。
    -- 本模块的主机/HUD/引导/返回按钮/结算面板全部是 OnCreate 时运行时动态建的节点，
    -- 不在这里显式 Destroy 掉，下次 OnCreate 会在这些残留节点之上再叠一套新的——
    -- 尤其是 ResultPanel 挂着 raycastTarget=true 的全屏遮罩，残留在树里会挡住之后所有点击
    -- （表现就是"点跳过弹出结算面板后不管怎么点都没反应"，其实是上一局的旧遮罩挡在最上层）。
    if self.playerPlaneGo ~= nil and not IsNull(self.playerPlaneGo) then
        self.playerPlaneGo:Destroy()
    end
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

    self.playerPlaneGo = nil
    self.playerPlaneRt = nil
    self.battleContentTf = nil
    self.hudContentTf = nil
    self.hudLevelNameText = nil
    self.hudGoldText = nil
    self.hudEnemyText = nil
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
    base.OnDestroy(self)
end

function UIPlaneBattleView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.PlaneGoldChanged, self._OnGoldChanged)
end

function UIPlaneBattleView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(EventId.PlaneGoldChanged, self._OnGoldChanged)
end

function UIPlaneBattleView:_OnGoldChanged(totalGold)
    if self.hudGoldText ~= nil and not IsNull(self.hudGoldText) then
        self.hudGoldText.text = tostring(totalGold)
    end
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
    self.levelId = levelId
    self:_HideLevelSelect()

    -- 从选关再进关时，这里必须完整复位战斗状态
    self:_ClearBattleObjects()
    self.isBattleOver = false
    self.battleTime = 0
    self.wingmanFireTimer = 0
    self.spawnCursor = 1
    self._lastStgBattleGold = 0

    self:_HideResultPanel()
    self:_SetBattleHudVisible(true)
    self:_RefreshHudLevelName()
    self:_RefreshHudGold()
    self.lastHudEnemyCount = -1
    self:_RefreshHudEnemyCount()

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
            local baseWingman = 0
            -- STG JSON 里没有 base_wingman 字段，从旧 PlaneLevel_Config 兜底读
            local levelMeta = view.ctrl:GetLevelMeta(view.levelId)
            if levelMeta ~= nil then
                baseWingman = tonumber(levelMeta.base_wingman) or 0
            end
            local heroTroopBonus = 0
            local heroMgr = DataCenter.HeroDataManager
            if heroMgr ~= nil then
                local deployedHero = heroMgr:GetDeployedHeroConfig()
                if deployedHero ~= nil then
                    heroTroopBonus = tonumber(deployedHero.base_troop) or 0
                end
            end
            view:_SetWingmanCount(baseWingman + heroTroopBonus)
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
        enemy:SetLocalPos(x, tonumber(r.y) or SPAWN_TOP_Y)
        -- 覆盖模板血量/速度
        if r.hp ~= nil and r.hp > 0 then
            enemy.hp = r.hp
            enemy.maxHp = r.hp
        end
        if r.speed ~= nil and r.speed > 0 then
            enemy.speed = r.speed
        end
        table.insert(self.enemies, enemy)
    end
end

--- STG：生成 Boss
function UIPlaneBattleView:_OnStgSpawnBoss(bossId)
    -- bossId 是字符串，查 bossConfigs 拿 prefabPath/totalHp；首期仍用 PlaneUnit 内置 9001
    local metaId = tonumber(bossId) or 9001
    local boss = PlaneUnit.New(self.battleContentTf, "boss", metaId)
    boss:SetLocalPos(0, SPAWN_TOP_Y)
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

    table.insert(self.gates, visual)
    table.insert(self.stgGates, gate)
end

function UIPlaneBattleView:_OnStgBattleEnd(isWin)
    self.isBattleOver = true
    if isWin then
        -- 通关：推进存档进度
        local mgr = DataCenter.PlaneBattleDataManager
        if mgr ~= nil then
            mgr:OnLevelPass(self.levelId, 50)
        end
        self:_ShowResultPanel(true)
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
        local heroTroopBonus = 0
        local heroMgr = DataCenter.HeroDataManager
        if heroMgr ~= nil then
            local deployedHero = heroMgr:GetDeployedHeroConfig()
            if deployedHero ~= nil then
                heroTroopBonus = tonumber(deployedHero.base_troop) or 0
            end
        end
        self:_SetWingmanCount(baseWingman + heroTroopBonus)
    end
end

--- ---------------------------------------------------------------
--- 节点搭建
--- ---------------------------------------------------------------

function UIPlaneBattleView:_CreateBattleContentRoot()
    self.battleContentTf = self.transform:Find("BattleContent")
    self.hudContentTf = self.transform:Find("HudContent")
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
    img:LoadSprite(RES_DIR .. "PlaneBattle_player.png")

    self.playerPlaneGo = go
    self.playerPlaneRt = rt

    local trigger = go:GetOrAddComponent(UIEventTrigger)
    trigger.onDrag = function(data) self:_OnDragPlayerPlane(data) end
end

--- ---------------------------------------------------------------
--- 主机拖动
--- ---------------------------------------------------------------

function UIPlaneBattleView:_OnDragPlayerPlane(data)
    if self.isBattleOver or self.playerPlaneRt == nil then
        return
    end

    if not guideShownInSession then
        guideShownInSession = true
        self:_HideGuide()
    end

    local pos = self.playerPlaneRt.anchoredPosition
    local newX = pos.x + data.delta.x
    if newX > SAFE_HALF_WIDTH then
        newX = SAFE_HALF_WIDTH
    elseif newX < -SAFE_HALF_WIDTH then
        newX = -SAFE_HALF_WIDTH
    end

    self.playerPlaneRt.anchoredPosition = Vector2(newX, pos.y)
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
    count = math.max(0, math.min(WINGMAN_MAX, math.floor(count)))
    local diff = count - #self.wingmen

    if diff > 0 then
        for _ = 1, diff do
            local wingman = PlaneUnit.New(self.battleContentTf, "wingman")
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
    EventManager:GetInstance():Broadcast(EventId.PlaneWingmanCountChanged, self.wingmanCount)
end

function UIPlaneBattleView:_RefreshWingmanFormation()
    local offsets = FormationLayout.GetOffsets(#self.wingmen)
    local px, py = self:GetPlayerPlanePos()
    for i, wingman in ipairs(self.wingmen) do
        local off = offsets[i]
        if off ~= nil then
            wingman:SetLocalPos(px + off.x, py + off.y)
        end
    end
end

--- ---------------------------------------------------------------
--- 主循环（挂在 UpdateManager 上，UIBaseContainer 检测到 self.Update 存在会自动接管）
--- ---------------------------------------------------------------

function UIPlaneBattleView:Update()
    if self.isBattleOver or self.isInLevelSelect then
        return
    end

    local dt = CS.UnityEngine.Time.deltaTime
    self.battleTime = self.battleTime + dt

    self:_RefreshWingmanFormation()
    self:_UpdateWingmanFire(dt)
    self:_UpdateEnemies(dt)
    self:_UpdateGates(dt)
    self:_UpdateBuckets(dt)
    self.bulletPool:Update(dt)
    self:_CheckBulletCollisions()
    self:_RefreshHudEnemyCount()

    if self.logic ~= nil then
        -- ★ STG 路径：时间轴/波次/结算由 StgBattleLogic 驱动
        self.logic:Update(dt)
    else
        -- Legacy 路径：旧 PlaneSpawn_Config 时间轴 + 超时判负
        self:_ConsumeSpawnTimeline()
        self:_CheckBattleEnd()
    end
end

--- ---------------------------------------------------------------
--- 僚机自动开火
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateWingmanFire(dt)
    if #self.wingmen == 0 then
        return
    end

    self.wingmanFireTimer = self.wingmanFireTimer + dt
    if self.wingmanFireTimer < WINGMAN_FIRE_INTERVAL then
        return
    end
    self.wingmanFireTimer = 0

    for _, wingman in ipairs(self.wingmen) do
        local x, y = wingman:GetLocalPos()
        self.bulletPool:Fire(x, y + 30, 1, WINGMAN_BULLET_DAMAGE)
    end
end

--- ---------------------------------------------------------------
--- 敌机/boss 推进
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateEnemies(dt)
    local i = 1
    while i <= #self.enemies do
        local enemy = self.enemies[i]
        enemy:Update(dt)
        local _, y = enemy:GetLocalPos()
        if y < BOTTOM_RECYCLE_Y then
            enemy:Destroy()
            table.remove(self.enemies, i)
        else
            i = i + 1
        end
    end
end

--- ---------------------------------------------------------------
--- 数字门推进 + 触发
--- ---------------------------------------------------------------

function UIPlaneBattleView:_UpdateGates(dt)
    local px, py = self:GetPlayerPlanePos()
    local i = 1
    while i <= #self.gates do
        local gate = self.gates[i]
        gate:Update(dt)

        if gate:CheckTrigger(px, py) then
            if gate.stgGate ~= nil then
                -- ★ STG 门：逻辑实例结算（内部走 StgBattleLogic:ExecuteEffect）
                local isLeft = px <= 0  -- duet 门按主机落点分左右
                gate.stgGate:OnPass(isLeft)
            elseif gate.kind == "lock" then
                -- Legacy 锁定门
                if self.wingmanCount >= (gate.threshold or 0) then
                    Logger.Log('#PlaneBattle# 通过锁定门 threshold=' .. tostring(gate.threshold) .. ' wingmanCount=' .. tostring(self.wingmanCount))
                else
                    self:_OnBattleLose()
                    return
                end
            else
                -- Legacy buff 门
                self:_ExecuteTrigger(gate.triggerMeta)
            end
        end

        if gate:IsOutOfBounds(BOTTOM_RECYCLE_Y) then
            gate:Destroy()
            table.remove(self.gates, i)
        else
            i = i + 1
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

    -- 敌机/boss
    for _, enemy in ipairs(self.enemies) do
        if not enemy.isDead then
            self:_CheckBulletsAgainstTarget(bullets, enemy, function(dead)
                if dead then
                    self:_OnEnemyDead(enemy)
                end
            end)
        end
    end

    -- 油桶
    for _, bucket in ipairs(self.buckets) do
        if not bucket.isDead then
            self:_CheckBulletsAgainstTarget(bullets, bucket)
        end
    end
end

function UIPlaneBattleView:_CheckBulletsAgainstTarget(bullets, target, onHit)
    local tx, ty = target:GetLocalPos()
    local radius = (target.collideRadius or 35) + BUCKET_COLLIDE_EXTRA

    local i = 1
    while i <= #bullets do
        local b = bullets[i]
        local pos = b.rt.anchoredPosition
        local dx = pos.x - tx
        local dy = pos.y - ty
        if (dx * dx + dy * dy) <= (radius * radius) then
            local dead = target:TakeDamage(b.damage)
            self.bulletPool:Remove(b)
            if onHit ~= nil then
                onHit(dead)
            end
            if dead then
                return -- 目标已死，剩余子弹留给下一帧（避免同帧修改中的 list 越界）
            end
        else
            i = i + 1
        end
    end
end

function UIPlaneBattleView:_OnEnemyDead(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then
            if enemy.kind == "boss" then
                self:_OnBattleWin()
            end
            enemy:Destroy()
            table.remove(self.enemies, i)
            return
        end
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
    Logger.Log('#PlaneBattle# 战斗胜利 levelId=' .. tostring(self.levelId))
    self.ctrl:OnBattleWin(self.levelId, 50)
    self:_ShowResultPanel(true)
end

function UIPlaneBattleView:_OnBattleLose()
    if self.isBattleOver then
        return
    end
    self.isBattleOver = true
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

function UIPlaneBattleView:_CreateHud()
    -- 关卡名：顶部居中
    local nameGo = GameObject("HudLevelName", RectTransform)
    nameGo.transform:SetParent(self.hudContentTf, false)
    local nameRt = nameGo:GetComponent(RectTransform)
    nameRt.anchorMin = Vector2(0.5, 1)
    nameRt.anchorMax = Vector2(0.5, 1)
    nameRt.pivot = Vector2(0.5, 1)
    nameRt.anchoredPosition = Vector2(0, -70)
    nameRt.sizeDelta = Vector2(400, 60)
    local nameText = nameGo:AddComponent(TMPText)
    nameText.text = ""
    nameText.fontSize = 36
    nameText.fontStyle = CS.TMPro.FontStyles.Bold
    nameText.alignment = TMPAlign.Center
    nameText.color = Color(1, 1, 1, 1)
    nameText.raycastTarget = false
    _RequestChineseFont(nameText)
    self.hudLevelNameText = nameText

    -- 金币：左上角图标 + 数字
    local coinIconGo = GameObject("HudCoinIcon", RectTransform)
    coinIconGo.transform:SetParent(self.hudContentTf, false)
    local coinIconRt = coinIconGo:GetComponent(RectTransform)
    coinIconRt.anchorMin = Vector2(0, 1)
    coinIconRt.anchorMax = Vector2(0, 1)
    coinIconRt.pivot = Vector2(0, 1)
    coinIconRt.anchoredPosition = Vector2(30, -60)
    coinIconRt.sizeDelta = Vector2(44, 44)
    local coinIconImg = coinIconGo:AddComponent(Image)
    coinIconImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_coin.png")

    local goldGo = GameObject("HudGoldText", RectTransform)
    goldGo.transform:SetParent(self.hudContentTf, false)
    local goldRt = goldGo:GetComponent(RectTransform)
    goldRt.anchorMin = Vector2(0, 1)
    goldRt.anchorMax = Vector2(0, 1)
    goldRt.pivot = Vector2(0, 1)
    goldRt.anchoredPosition = Vector2(82, -63)
    goldRt.sizeDelta = Vector2(150, 40)
    local goldText = goldGo:AddComponent(TMPText)
    goldText.text = "0"
    goldText.fontSize = 30
    goldText.fontStyle = CS.TMPro.FontStyles.Bold
    goldText.alignment = TMPAlign.Left
    goldText.color = Color(1, 0.85, 0.2, 1)
    goldText.raycastTarget = false
    self.hudGoldText = goldText

    -- 跳过：右上角半透明按钮
    local skipGo = GameObject("HudSkipBtn", RectTransform)
    skipGo.transform:SetParent(self.hudContentTf, false)
    local skipRt = skipGo:GetComponent(RectTransform)
    skipRt.anchorMin = Vector2(1, 1)
    skipRt.anchorMax = Vector2(1, 1)
    skipRt.pivot = Vector2(1, 1)
    skipRt.anchoredPosition = Vector2(-30, -60)
    skipRt.sizeDelta = Vector2(140, 56)
    local skipImg = skipGo:AddComponent(Image)
    skipImg.color = Color(0, 0, 0, 0.4)

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
    _RequestChineseFont(skipText)

    local skipBtn = skipGo:AddComponent(Button)
    skipBtn.onClick:AddListener(function() self:_OnClickSkip() end)

    -- 敌方兵力：顶部居中偏下，深色胶囊 + 骷髅头 + 数字
    local capsuleGo = GameObject("HudEnemyCapsule", RectTransform)
    capsuleGo.transform:SetParent(self.hudContentTf, false)
    local capsuleRt = capsuleGo:GetComponent(RectTransform)
    capsuleRt.anchorMin = Vector2(0.5, 1)
    capsuleRt.anchorMax = Vector2(0.5, 1)
    capsuleRt.pivot = Vector2(0.5, 1)
    capsuleRt.anchoredPosition = Vector2(0, -140)
    capsuleRt.sizeDelta = Vector2(200, 60)
    local capsuleImg = capsuleGo:AddComponent(Image)
    capsuleImg:LoadSprite(RES_DIR .. "PlaneBattle_hud_enemyhp.png")

    local skullGo = GameObject("Skull", RectTransform)
    skullGo.transform:SetParent(capsuleGo.transform, false)
    local skullRt = skullGo:GetComponent(RectTransform)
    skullRt.anchorMin = Vector2(0, 0.5)
    skullRt.anchorMax = Vector2(0, 0.5)
    skullRt.pivot = Vector2(0.5, 0.5)
    skullRt.anchoredPosition = Vector2(38, 0)
    skullRt.sizeDelta = Vector2(36, 36)
    local skullImg = skullGo:AddComponent(Image)
    skullImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_skull.png")

    local enemyTextGo = GameObject("Text", RectTransform)
    enemyTextGo.transform:SetParent(capsuleGo.transform, false)
    local enemyTextRt = enemyTextGo:GetComponent(RectTransform)
    enemyTextRt.anchorMin = Vector2(0, 0)
    enemyTextRt.anchorMax = Vector2(1, 1)
    enemyTextRt.offsetMin = Vector2(56, 0)
    enemyTextRt.offsetMax = Vector2(-16, 0)
    local enemyText = enemyTextGo:AddComponent(TMPText)
    enemyText.text = "0"
    enemyText.fontSize = 30
    enemyText.fontStyle = CS.TMPro.FontStyles.Bold
    enemyText.alignment = TMPAlign.Left
    enemyText.color = Color(1, 1, 1, 1)
    enemyText.raycastTarget = false
    self.hudEnemyText = enemyText
end

function UIPlaneBattleView:_RefreshHudLevelName()
    if self.hudLevelNameText == nil or IsNull(self.hudLevelNameText) then
        return
    end
    self.hudLevelNameText.text = self.levelMeta ~= nil and (self.levelMeta.name or "") or ""
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
    self.hudEnemyText.text = tostring(count)
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
        arrowRt.anchoredPosition = Vector2(offsetX, PLANE_BOTTOM_Y)
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
    handRt.anchoredPosition = Vector2(0, PLANE_BOTTOM_Y - 90)
    handRt.sizeDelta = Vector2(64, 89)
    local handImg = handGo:AddComponent(Image)
    handImg.raycastTarget = false
    handImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_handcursor.png")

    local hintGo = GameObject("HintText", RectTransform)
    hintGo.transform:SetParent(groupGo.transform, false)
    local hintRt = hintGo:GetComponent(RectTransform)
    hintRt.anchorMin = Vector2(0.5, 0)
    hintRt.anchorMax = Vector2(0.5, 0)
    hintRt.pivot = Vector2(0.5, 0.5)
    hintRt.anchoredPosition = Vector2(0, PLANE_BOTTOM_Y - 170)
    hintRt.sizeDelta = Vector2(320, 50)
    local hintText = hintGo:AddComponent(TMPText)
    hintText.text = "按住 & 拖动"
    hintText.fontSize = 30
    hintText.alignment = TMPAlign.Center
    hintText.color = Color(1, 0.85, 0.2, 1)
    hintText.raycastTarget = false
    _RequestChineseFont(hintText)
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
    backRt.anchorMin = Vector2(0, 0)
    backRt.anchorMax = Vector2(0, 0)
    backRt.pivot = Vector2(0, 0)
    backRt.anchoredPosition = Vector2(70, 90)
    backRt.sizeDelta = Vector2(96, 96)
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
    if self.resultPanelGo == nil or IsNull(self.resultPanelGo) then
        self:_BuildResultPanel()
    end

    local minutes = math.floor(self.battleTime / 60)
    local seconds = math.floor(self.battleTime % 60)
    self.resultTimeText.text = string.format("关卡用时  %02d:%02d", minutes, seconds)
    self.resultWingmanText.text = "存活僚机  " .. tostring(#self.wingmen)

    if isWin then
        self.resultTitleText.text = "胜 利"
        self.resultBannerImg.color = Color(1, 1, 1, 1)
        -- 胜利时显示"下一关"；配置表没有下一关时隐藏
        local nextLevelId = (tonumber(self.levelId) or 0) + 1
        local hasNext = self.ctrl:GetLevelMeta(nextLevelId) ~= nil
        if self.resultNextBtnGo ~= nil and not IsNull(self.resultNextBtnGo) then
            self.resultNextBtnGo:SetActive(hasNext)
        end
    else
        self.resultTitleText.text = "失 败"
        self.resultBannerImg.color = Color(1, 0.45, 0.45, 1)
        if self.resultNextBtnGo ~= nil and not IsNull(self.resultNextBtnGo) then
            self.resultNextBtnGo:SetActive(false)
        end
    end

    self.resultPanelGo:SetActive(true)
end

function UIPlaneBattleView:_HideResultPanel()
    if self.resultPanelGo ~= nil and not IsNull(self.resultPanelGo) then
        self.resultPanelGo:SetActive(false)
    end
end

function UIPlaneBattleView:_BuildResultPanel()
    local panelGo = GameObject("ResultPanel", RectTransform)
    panelGo.transform:SetParent(self.transform, false)
    local panelRt = panelGo:GetComponent(RectTransform)
    panelRt.anchorMin = Vector2(0, 0)
    panelRt.anchorMax = Vector2(1, 1)
    panelRt.offsetMin = Vector2(0, 0)
    panelRt.offsetMax = Vector2(0, 0)
    self.resultPanelGo = panelGo

    -- 遮罩：拦掉战斗层剩余输入
    local maskGo = GameObject("DimMask", RectTransform)
    maskGo.transform:SetParent(panelGo.transform, false)
    local maskRt = maskGo:GetComponent(RectTransform)
    maskRt.anchorMin = Vector2(0, 0)
    maskRt.anchorMax = Vector2(1, 1)
    maskRt.offsetMin = Vector2(0, 0)
    maskRt.offsetMax = Vector2(0, 0)
    local maskImg = maskGo:AddComponent(Image)
    maskImg.color = Color(0, 0, 0, 0.4)
    maskImg.raycastTarget = true

    -- banner
    local bannerGo = GameObject("Banner", RectTransform)
    bannerGo.transform:SetParent(panelGo.transform, false)
    local bannerRt = bannerGo:GetComponent(RectTransform)
    bannerRt.anchorMin = Vector2(0.5, 0.5)
    bannerRt.anchorMax = Vector2(0.5, 0.5)
    bannerRt.pivot = Vector2(0.5, 0.5)
    bannerRt.anchoredPosition = Vector2(0, 260)
    bannerRt.sizeDelta = Vector2(640, 180)
    local bannerImg = bannerGo:AddComponent(Image)
    bannerImg:LoadSprite(RES_DIR .. "PlaneBattle_victory_banner.png")
    self.resultBannerImg = bannerImg

    local titleGo = GameObject("Title", RectTransform)
    titleGo.transform:SetParent(bannerGo.transform, false)
    local titleRt = titleGo:GetComponent(RectTransform)
    titleRt.anchorMin = Vector2(0, 0)
    titleRt.anchorMax = Vector2(1, 1)
    titleRt.offsetMin = Vector2(0, 0)
    titleRt.offsetMax = Vector2(0, 0)
    local titleText = titleGo:AddComponent(TMPText)
    titleText.text = "胜 利"
    titleText.fontSize = 60
    titleText.fontStyle = CS.TMPro.FontStyles.Bold
    titleText.alignment = TMPAlign.Center
    titleText.color = Color(1, 1, 1, 1)
    titleText.raycastTarget = false
    _RequestChineseFont(titleText)
    self.resultTitleText = titleText

    -- 统计行：关卡用时
    local timeGo = GameObject("StatTime", RectTransform)
    timeGo.transform:SetParent(panelGo.transform, false)
    local timeRt = timeGo:GetComponent(RectTransform)
    timeRt.anchorMin = Vector2(0.5, 0.5)
    timeRt.anchorMax = Vector2(0.5, 0.5)
    timeRt.pivot = Vector2(0.5, 0.5)
    timeRt.anchoredPosition = Vector2(0, 90)
    timeRt.sizeDelta = Vector2(420, 64)
    local timeImg = timeGo:AddComponent(Image)
    timeImg.color = Color(0.12, 0.16, 0.23, 0.9)
    local timeTextGo = GameObject("Text", RectTransform)
    timeTextGo.transform:SetParent(timeGo.transform, false)
    local timeTextRt = timeTextGo:GetComponent(RectTransform)
    timeTextRt.anchorMin = Vector2(0, 0)
    timeTextRt.anchorMax = Vector2(1, 1)
    timeTextRt.offsetMin = Vector2(0, 0)
    timeTextRt.offsetMax = Vector2(0, 0)
    local timeText = timeTextGo:AddComponent(TMPText)
    timeText.text = ""
    timeText.fontSize = 28
    timeText.alignment = TMPAlign.Center
    timeText.color = Color(1, 1, 1, 1)
    timeText.raycastTarget = false
    _RequestChineseFont(timeText)
    self.resultTimeText = timeText

    -- 统计行：存活僚机
    local wingmanGo = GameObject("StatWingman", RectTransform)
    wingmanGo.transform:SetParent(panelGo.transform, false)
    local wingmanRt = wingmanGo:GetComponent(RectTransform)
    wingmanRt.anchorMin = Vector2(0.5, 0.5)
    wingmanRt.anchorMax = Vector2(0.5, 0.5)
    wingmanRt.pivot = Vector2(0.5, 0.5)
    wingmanRt.anchoredPosition = Vector2(0, 10)
    wingmanRt.sizeDelta = Vector2(420, 64)
    local wingmanImg = wingmanGo:AddComponent(Image)
    wingmanImg.color = Color(0.12, 0.16, 0.23, 0.9)
    local wingmanTextGo = GameObject("Text", RectTransform)
    wingmanTextGo.transform:SetParent(wingmanGo.transform, false)
    local wingmanTextRt = wingmanTextGo:GetComponent(RectTransform)
    wingmanTextRt.anchorMin = Vector2(0, 0)
    wingmanTextRt.anchorMax = Vector2(1, 1)
    wingmanTextRt.offsetMin = Vector2(0, 0)
    wingmanTextRt.offsetMax = Vector2(0, 0)
    local wingmanText = wingmanTextGo:AddComponent(TMPText)
    wingmanText.text = ""
    wingmanText.fontSize = 28
    wingmanText.alignment = TMPAlign.Center
    wingmanText.color = Color(1, 1, 1, 1)
    wingmanText.raycastTarget = false
    _RequestChineseFont(wingmanText)
    self.resultWingmanText = wingmanText

    -- 返回按钮（回选关界面）
    local backGo = GameObject("BtnBack", RectTransform)
    backGo.transform:SetParent(panelGo.transform, false)
    local backRt = backGo:GetComponent(RectTransform)
    backRt.anchorMin = Vector2(0.5, 0.5)
    backRt.anchorMax = Vector2(0.5, 0.5)
    backRt.pivot = Vector2(0.5, 0.5)
    backRt.anchoredPosition = Vector2(0, -90)
    backRt.sizeDelta = Vector2(280, 84)
    local backImg = backGo:AddComponent(Image)
    backImg.color = Color(0.12, 0.16, 0.23, 1)
    local backTextGo = GameObject("Text", RectTransform)
    backTextGo.transform:SetParent(backGo.transform, false)
    local backTextRt = backTextGo:GetComponent(RectTransform)
    backTextRt.anchorMin = Vector2(0, 0)
    backTextRt.anchorMax = Vector2(1, 1)
    backTextRt.offsetMin = Vector2(0, 0)
    backTextRt.offsetMax = Vector2(0, 0)
    local backText = backTextGo:AddComponent(TMPText)
    backText.text = "选 择 关 卡"
    backText.fontSize = 32
    backText.fontStyle = CS.TMPro.FontStyles.Bold
    backText.alignment = TMPAlign.Center
    backText.color = Color(1, 1, 1, 1)
    backText.raycastTarget = false
    _RequestChineseFont(backText)

    local backBtn = backGo:AddComponent(Button)
    backBtn.onClick:AddListener(function() self:_ShowLevelSelect() end)

    -- 下一关按钮（默认隐藏，胜利时才显示）
    local nextGo = GameObject("BtnNext", RectTransform)
    nextGo.transform:SetParent(panelGo.transform, false)
    local nextRt = nextGo:GetComponent(RectTransform)
    nextRt.anchorMin = Vector2(0.5, 0.5)
    nextRt.anchorMax = Vector2(0.5, 0.5)
    nextRt.pivot = Vector2(0.5, 0.5)
    nextRt.anchoredPosition = Vector2(0, -190)
    nextRt.sizeDelta = Vector2(280, 84)
    local nextImg = nextGo:AddComponent(Image)
    nextImg.color = Color(0.18, 0.42, 0.22, 1)
    local nextTextGo = GameObject("Text", RectTransform)
    nextTextGo.transform:SetParent(nextGo.transform, false)
    local nextTextRt = nextTextGo:GetComponent(RectTransform)
    nextTextRt.anchorMin = Vector2(0, 0)
    nextTextRt.anchorMax = Vector2(1, 1)
    nextTextRt.offsetMin = Vector2(0, 0)
    nextTextRt.offsetMax = Vector2(0, 0)
    local nextText = nextTextGo:AddComponent(TMPText)
    nextText.text = "下 一 关"
    nextText.fontSize = 32
    nextText.fontStyle = CS.TMPro.FontStyles.Bold
    nextText.alignment = TMPAlign.Center
    nextText.color = Color(1, 1, 1, 1)
    nextText.raycastTarget = false
    _RequestChineseFont(nextText)
    self.resultNextBtnGo = nextGo

    local nextBtn = nextGo:AddComponent(Button)
    nextBtn.onClick:AddListener(function() self:_OnClickNextLevel() end)
    nextGo:SetActive(false)
end

--- ---------------------------------------------------------------
--- 选关面板
--- ---------------------------------------------------------------

function UIPlaneBattleView:_BuildLevelSelectPanel()
    local panelGo = GameObject("LevelSelectPanel", RectTransform)
    panelGo.transform:SetParent(self.transform, false)
    local panelRt = panelGo:GetComponent(RectTransform)
    panelRt.anchorMin = Vector2(0, 0)
    panelRt.anchorMax = Vector2(1, 1)
    panelRt.offsetMin = Vector2(0, 0)
    panelRt.offsetMax = Vector2(0, 0)
    self.levelSelectGo = panelGo

    -- 全屏底色（拦掉下层点击）
    local bgGo = GameObject("Bg", RectTransform)
    bgGo.transform:SetParent(panelGo.transform, false)
    local bgRt = bgGo:GetComponent(RectTransform)
    bgRt.anchorMin = Vector2(0, 0)
    bgRt.anchorMax = Vector2(1, 1)
    bgRt.offsetMin = Vector2(0, 0)
    bgRt.offsetMax = Vector2(0, 0)
    local bgImg = bgGo:AddComponent(Image)
    bgImg.color = Color(0.06, 0.09, 0.14, 1)
    bgImg.raycastTarget = true

    -- 标题
    local titleGo = GameObject("Title", RectTransform)
    titleGo.transform:SetParent(panelGo.transform, false)
    local titleRt = titleGo:GetComponent(RectTransform)
    titleRt.anchorMin = Vector2(0.5, 1)
    titleRt.anchorMax = Vector2(0.5, 1)
    titleRt.pivot = Vector2(0.5, 1)
    titleRt.anchoredPosition = Vector2(0, -70)
    titleRt.sizeDelta = Vector2(400, 60)
    local titleText = titleGo:AddComponent(TMPText)
    titleText.text = "探险"
    titleText.fontSize = 38
    titleText.fontStyle = CS.TMPro.FontStyles.Normal
    titleText.alignment = TMPAlign.Center
    titleText.color = Color(0.92, 0.94, 0.96, 1)
    titleText.raycastTarget = false
    _RequestChineseFont(titleText)

    -- 金币显示
    local coinIconGo = GameObject("CoinIcon", RectTransform)
    coinIconGo.transform:SetParent(panelGo.transform, false)
    local coinIconRt = coinIconGo:GetComponent(RectTransform)
    coinIconRt.anchorMin = Vector2(0, 1)
    coinIconRt.anchorMax = Vector2(0, 1)
    coinIconRt.pivot = Vector2(0, 1)
    coinIconRt.anchoredPosition = Vector2(30, -60)
    coinIconRt.sizeDelta = Vector2(40, 40)
    local coinIconImg = coinIconGo:AddComponent(Image)
    coinIconImg:LoadSprite(RES_DIR .. "PlaneBattle_icon_coin.png")

    local goldGo = GameObject("GoldText", RectTransform)
    goldGo.transform:SetParent(panelGo.transform, false)
    local goldRt = goldGo:GetComponent(RectTransform)
    goldRt.anchorMin = Vector2(0, 1)
    goldRt.anchorMax = Vector2(0, 1)
    goldRt.pivot = Vector2(0, 1)
    goldRt.anchoredPosition = Vector2(78, -62)
    goldRt.sizeDelta = Vector2(150, 36)
    local goldText = goldGo:AddComponent(TMPText)
    goldText.text = "0"
    goldText.fontSize = 26
    goldText.fontStyle = CS.TMPro.FontStyles.Normal
    goldText.alignment = TMPAlign.Left
    goldText.color = Color(1, 0.9, 0.4, 1)
    goldText.raycastTarget = false
    _RequestChineseFont(goldText)
    self.selectGoldText = goldText

    -- 关卡按钮容器（垂直列表，关卡数少用简单布局即可）
    local listGo = GameObject("LevelList", RectTransform)
    listGo.transform:SetParent(panelGo.transform, false)
    local listRt = listGo:GetComponent(RectTransform)
    listRt.anchorMin = Vector2(0.5, 0.5)
    listRt.anchorMax = Vector2(0.5, 0.5)
    listRt.pivot = Vector2(0.5, 0.5)
    listRt.anchoredPosition = Vector2(0, 20)
    listRt.sizeDelta = Vector2(600, 900)
    self.levelListTf = listGo.transform

    -- 关闭按钮
    local closeGo = GameObject("BtnClose", RectTransform)
    closeGo.transform:SetParent(panelGo.transform, false)
    local closeRt = closeGo:GetComponent(RectTransform)
    closeRt.anchorMin = Vector2(0.5, 0)
    closeRt.anchorMax = Vector2(0.5, 0)
    closeRt.pivot = Vector2(0.5, 0)
    closeRt.anchoredPosition = Vector2(0, 60)
    closeRt.sizeDelta = Vector2(260, 80)
    local closeImg = closeGo:AddComponent(Image)
    closeImg.color = Color(0.12, 0.16, 0.23, 1)
    local closeTextGo = GameObject("Text", RectTransform)
    closeTextGo.transform:SetParent(closeGo.transform, false)
    local closeTextRt = closeTextGo:GetComponent(RectTransform)
    closeTextRt.anchorMin = Vector2(0, 0)
    closeTextRt.anchorMax = Vector2(1, 1)
    closeTextRt.offsetMin = Vector2(0, 0)
    closeTextRt.offsetMax = Vector2(0, 0)
    local closeText = closeTextGo:AddComponent(TMPText)
    closeText.text = "返回船舱"
    closeText.fontSize = 28
    closeText.fontStyle = CS.TMPro.FontStyles.Normal
    closeText.alignment = TMPAlign.Center
    closeText.color = Color(0.85, 0.88, 0.92, 1)
    closeText.raycastTarget = false
    _RequestChineseFont(closeText)
    local closeBtn = closeGo:AddComponent(Button)
    closeBtn.onClick:AddListener(function() self:CloseSelf() end)

    panelGo:SetActive(false)
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

    if self.levelSelectGo ~= nil and not IsNull(self.levelSelectGo) then
        self.levelSelectGo:SetActive(true)
    end
    self:_RefreshLevelList()
    self:_RefreshSelectGold()

    Logger.Log('#PlaneBattle# 打开选关界面')
end

function UIPlaneBattleView:_HideLevelSelect()
    self.isInLevelSelect = false
    if self.levelSelectGo ~= nil and not IsNull(self.levelSelectGo) then
        self.levelSelectGo:SetActive(false)
    end
end

function UIPlaneBattleView:_RefreshSelectGold()
    if self.selectGoldText == nil or IsNull(self.selectGoldText) then
        return
    end
    local mgr = DataCenter.PlaneBattleDataManager
    self.selectGoldText.text = tostring(mgr ~= nil and mgr:GetTotalGold() or 0)
end

function UIPlaneBattleView:_RefreshLevelList()
    if self.levelListTf == nil or IsNull(self.levelListTf) then
        return
    end

    -- 清掉旧按钮
    for i = self.levelListTf.childCount - 1, 0, -1 do
        local child = self.levelListTf:GetChild(i)
        if child ~= nil and not IsNull(child) then
            child.gameObject:Destroy()
        end
    end

    local levels = self.ctrl:GetAllLevels()
    local curLevelId = tonumber(self.ctrl:GetCurLevelId()) or 0
    local btnW, btnH, gapY = 560, 110, 20
    local totalH = #levels * btnH + math.max(0, #levels - 1) * gapY
    local startY = totalH * 0.5 - btnH * 0.5

    for i, lv in ipairs(levels) do
        -- 配置表 getValue 对 number 列仍可能返回字符串，比较前必须 tonumber
        local lvId = tonumber(lv.id) or 0
        local unlocked = lvId <= curLevelId
        local isCurrent = (lvId == curLevelId)

        local btnGo = GameObject("Level_" .. tostring(lvId), RectTransform)
        btnGo.transform:SetParent(self.levelListTf, false)
        local btnRt = btnGo:GetComponent(RectTransform)
        btnRt.anchorMin = Vector2(0.5, 0.5)
        btnRt.anchorMax = Vector2(0.5, 0.5)
        btnRt.pivot = Vector2(0.5, 0.5)
        btnRt.anchoredPosition = Vector2(0, startY - (i - 1) * (btnH + gapY))
        btnRt.sizeDelta = Vector2(btnW, btnH)

        local btnImg = btnGo:AddComponent(Image)
        if isCurrent then
            btnImg.color = Color(0.16, 0.32, 0.18, 1)   -- 当前关：绿色
        elseif unlocked then
            btnImg.color = Color(0.13, 0.18, 0.28, 1)   -- 已通关：深蓝
        else
            btnImg.color = Color(0.09, 0.10, 0.13, 1)   -- 未解锁：暗灰
        end

        -- 关卡名
        local nameGo = GameObject("Name", RectTransform)
        nameGo.transform:SetParent(btnGo.transform, false)
        local nameRt = nameGo:GetComponent(RectTransform)
        nameRt.anchorMin = Vector2(0, 0)
        nameRt.anchorMax = Vector2(0.6, 1)
        nameRt.offsetMin = Vector2(30, 0)
        nameRt.offsetMax = Vector2(0, 0)
        local nameText = nameGo:AddComponent(TMPText)
        nameText.text = lv.name
        nameText.fontSize = 30
        nameText.fontStyle = CS.TMPro.FontStyles.Normal
        nameText.alignment = TMPAlign.Left
        if isCurrent then
            nameText.color = Color(0.6, 1, 0.6, 1)       -- 当前关：亮绿
        elseif unlocked then
            nameText.color = Color(0.9, 0.92, 0.95, 1)   -- 已通关：近白
        else
            nameText.color = Color(0.4, 0.42, 0.48, 1)   -- 未解锁：暗灰
        end
        nameText.raycastTarget = false
        _RequestChineseFont(nameText)

        -- 僚机数提示
        local tipGo = GameObject("Tip", RectTransform)
        tipGo.transform:SetParent(btnGo.transform, false)
        local tipRt = tipGo:GetComponent(RectTransform)
        tipRt.anchorMin = Vector2(0.55, 0)
        tipRt.anchorMax = Vector2(1, 1)
        tipRt.offsetMin = Vector2(0, 0)
        tipRt.offsetMax = Vector2(-20, 0)
        local tipText = tipGo:AddComponent(TMPText)
        tipText.text = unlocked and ("僚机 " .. tostring(tonumber(lv.base_wingman) or 0)) or "未解锁"
        tipText.fontSize = 22
        tipText.alignment = TMPAlign.Right
        if isCurrent then
            tipText.color = Color(0.55, 0.9, 0.55, 1)
        elseif unlocked then
            tipText.color = Color(0.65, 0.75, 0.68, 1)
        else
            tipText.color = Color(0.35, 0.38, 0.42, 1)
        end
        tipText.raycastTarget = false
        _RequestChineseFont(tipText)

        if unlocked then
            local btn = btnGo:AddComponent(Button)
            local targetId = lvId
            btn.onClick:AddListener(function() self:_EnterLevel(targetId) end)
        end
    end
end

--- 战斗内容/HUD 显隐：选关时整体藏起来，进关时整体放出来。
--- BattleContent 挂主机/僚机/敌机/门/子弹；HudContent 挂关卡名/金币/跳过/返回。
--- 选关面板是 self.transform 下的独立全屏层，不在这两者里，所以关掉它们不影响选关。
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
    for _, wingman in ipairs(self.wingmen) do
        wingman:Destroy()
    end
    self.wingmen = {}

    for _, enemy in ipairs(self.enemies) do
        enemy:Destroy()
    end
    self.enemies = {}

    for _, gate in ipairs(self.gates) do
        gate:Destroy()
    end
    self.gates = {}

    for _, bucket in ipairs(self.buckets) do
        bucket:Destroy()
    end
    self.buckets = {}

    -- STG 门是纯逻辑对象，无 GameObject，清列表即可
    self.stgGates = {}

    if self.bulletPool ~= nil then
        self.bulletPool:Clear()
    end
end

return UIPlaneBattleView
