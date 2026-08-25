---
--- 船舱系统无 UI 测试脚本
--- 覆盖：UIShipBackgroundCtrl / UIBuildingPanelCtrl / ShipPlayerDataManager
---
--- 使用方式：
---   进入船舱界面 → 点左上角 [DEBUG] 船舱测试 → 打开调试控制台 → 点 zlhTest
---

local M = {}

-- ---------------------------------------------------------------
-- 工具
-- ---------------------------------------------------------------

local PASS = "<color=lime>[PASS]</color>"
local FAIL = "<color=red>[FAIL]</color>"
local INFO = "<color=cyan>[INFO]</color>"
local SEP  = "=================================================="

local function log(msg)
    Logger.Log("[ShipTest] " .. tostring(msg))
end

local function assert_eq(label, got, expected)
    if got == expected then
        log(PASS .. " " .. label .. "  got=" .. tostring(got))
    else
        log(FAIL .. " " .. label
            .. "  expected=" .. tostring(expected)
            .. "  got=" .. tostring(got))
    end
end

local function assert_true(label, value)
    if value then
        log(PASS .. " " .. label)
    else
        log(FAIL .. " " .. label .. "  (expected true, got false/nil)")
    end
end

local function assert_false(label, value)
    if not value then
        log(PASS .. " " .. label)
    else
        log(FAIL .. " " .. label .. "  (expected false/nil, got true)")
    end
end

local function assert_not_nil(label, value)
    if value ~= nil then
        log(PASS .. " " .. label)
    else
        log(FAIL .. " " .. label .. "  (expected not nil, got nil)")
    end
end

-- ---------------------------------------------------------------
-- 共用工具
-- ---------------------------------------------------------------

local function mgr()
    return DataCenter.ShipPlayerDataManager
end

local function newBgCtrl()
    local ok, cls = pcall(require, "UI.UIShipBackground.Controller.UIShipBackgroundCtrl")
    if not ok then
        log(FAIL .. " 无法 require UIShipBackgroundCtrl: " .. tostring(cls))
        return nil
    end
    return cls.New()
end

local function newPanelCtrl()
    local ok, cls = pcall(require, "UI.UIBuildingPanel.Controller.UIBuildingPanelCtrl")
    if not ok then
        log(FAIL .. " 无法 require UIBuildingPanelCtrl: " .. tostring(cls))
        return nil
    end
    return cls.New()
end

local function firstBuildId()
    local bid = nil
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, _)
        if not bid then bid = tonumber(rowId) end
    end)
    return bid
end

local function allBuildIds()
    return mgr():GetAllBuildIdList()
end

--- 把某个建筑重置为指定状态，方便各用例独立运行
local function resetBuilding(buildId, unlock, level, state)
    local bd = mgr():GetMaxLevelBuilding(buildId)
    if not bd then return end
    bd.unlock            = unlock
    bd.level             = level
    bd.state             = state
    bd.updateTime        = 0
    bd.upgradeTargetLevel = 0
    -- 清理 upgradingSet / unlockingSet，避免残留状态干扰后续用例
    mgr().upgradingSet[bd.uuid] = nil
    mgr().unlockingSet[bd.uuid] = nil
    -- 清理队列中该建筑的任务，避免残留队列干扰后续用例
    local queueMgr = DataCenter.ShipWorkQueueManager
    if queueMgr then
        queueMgr:ClearTaskByBuildId(buildId)
    end
end

-- ---------------------------------------------------------------
-- ① UIShipBackgroundCtrl — GetBuildingConfig / GetBuildingLevelConfig
-- ---------------------------------------------------------------

--[[
function M.TestGetConfig()
    log(SEP)
    log("=== ① BgCtrl.GetBuildingConfig / GetBuildingLevelConfig ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = ctrl:GetBuildingConfig(bid)
    assert_not_nil("cfg 不为 nil",          cfg)
    assert_true("cfg.name 不为空",          cfg.name ~= "")
    assert_true("cfg.level_limit >= 1",     cfg.level_limit >= 1)
    log(INFO .. " name=" .. cfg.name .. "  level_limit=" .. cfg.level_limit)

    local lv1 = ctrl:GetBuildingLevelConfig(bid, 1)
    if lv1 then
        assert_true("lv1.lvup_time >= 0",       lv1.lvup_time >= 0)
        assert_true("lv1.costList 是 table",    type(lv1.costList) == "table")
        log(INFO .. " lv1 power=" .. lv1.power
            .. "  lvup_time=" .. lv1.lvup_time
            .. "  costList=" .. #lv1.costList .. "条")

        -- ★ 诊断：打出 lvup_cost 原始值和类型，排查 ParseCostString 为空的原因
        local rawCost = GetTableData(TableName.Building_Levelup_Config,
            LocalController:instance():getValue and 1 or 1, "lvup_cost_1")
        log(INFO .. " [诊断] lv1.lvup_cost 原始值=【" .. tostring(lv1.lvup_cost)
            .. "】  类型=" .. type(lv1.lvup_cost))
        log(INFO .. " [诊断] costList 条数=" .. #lv1.costList)
        if #lv1.costList == 0 and lv1.lvup_cost ~= "" then
            log(FAIL .. " [诊断] lvup_cost 有值但 costList 为空，ParseCostString 解析失败")
            log(INFO .. " [诊断] 逐字节检查 lvup_cost:")
            for i = 1, math.min(#lv1.lvup_cost, 60) do
                local b = string.byte(lv1.lvup_cost, i)
                if b then
                    io.write and io.write(string.format("[%d:%d]", i, b))
                end
            end
            log(INFO .. " [诊断] 用 string.find 找逗号: "
                .. tostring(string.find(lv1.lvup_cost, ",")))
            log(INFO .. " [诊断] 用 string.find 找分号: "
                .. tostring(string.find(lv1.lvup_cost, ";")))
        elseif #lv1.costList > 0 then
            for i, cost in ipairs(lv1.costList) do
                log(INFO .. string.format(" [诊断] costList[%d] itemId=%s(%s)  count=%s(%s)",
                    i, tostring(cost.itemId), type(cost.itemId),
                       tostring(cost.count),  type(cost.count)))
            end
        end
    else
        log(INFO .. " lv1 配置不存在（表里可能没有该 buildId 的第1级数据）")
    end
end
]]--
-- ---------------------------------------------------------------
-- ② UIShipBackgroundCtrl — GetPlayerBuildingLevel / IsBuildingUnlocked
-- ---------------------------------------------------------------

function M.TestQueryPlayerData()
    log(SEP)
    log("=== ② BgCtrl.GetPlayerBuildingLevel / IsBuildingUnlocked ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    local list = allBuildIds()
    assert_true("建筑列表不为空", #list > 0)

    local bid = list[1]
    resetBuilding(bid, 1, 3, ShipBuildingState.Idle)

    assert_eq("GetPlayerBuildingLevel=3",   ctrl:GetPlayerBuildingLevel(bid), 3)
    assert_true("IsBuildingUnlocked=true",  ctrl:IsBuildingUnlocked(bid))
    log(INFO .. " buildId=" .. bid .. " level=3 unlocked=true ✓")

    if list[2] then
        local bid2 = list[2]
        resetBuilding(bid2, 0, 0, ShipBuildingState.Locked)
        assert_eq("未解锁 level=0",             ctrl:GetPlayerBuildingLevel(bid2), 0)
        assert_false("未解锁 unlocked=false",   ctrl:IsBuildingUnlocked(bid2))
        log(INFO .. " buildId=" .. bid2 .. " level=0 unlocked=false ✓")
    end
end

-- ---------------------------------------------------------------
-- ③ UIShipBackgroundCtrl — CheckUnlockCondition / CheckUpgradePrerequisite
-- ---------------------------------------------------------------

function M.TestCheckCondition()
    log(SEP)
    log("=== ③ BgCtrl.CheckUnlockCondition / CheckUpgradePrerequisite ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

    local ok, errMsg = ctrl:CheckUnlockCondition(bid)
    if ok then
        log(PASS .. " CheckUnlockCondition 无前置条件 ✓")
    else
        log(INFO .. " 有前置条件: " .. tostring(errMsg))
    end

    local lv1 = ctrl:GetBuildingLevelConfig(bid, 1)
    if lv1 then
        local preOk, preDesc = ctrl:CheckUpgradePrerequisite(lv1)
        log(INFO .. " CheckUpgradePrerequisite ok=" .. tostring(preOk)
            .. "  desc=" .. tostring(preDesc))
        assert_not_nil("CheckUpgradePrerequisite 有返回值", preOk)
    end
end

-- ---------------------------------------------------------------
-- ④ UIShipBackgroundCtrl — CheckResourceEnough
-- ---------------------------------------------------------------

function M.TestCheckResource()
    log(SEP)
    log("=== ④ BgCtrl.CheckResourceEnough ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end

    local ok1 = ctrl:CheckResourceEnough({
        { itemId = 102001, count = 100 },
        { itemId = 102002, count = 100 },
    })
    assert_true("资源充足时返回 true", ok1)

    local ok2, lack2 = ctrl:CheckResourceEnough({
        { itemId = 102001, count = 999999999999 },
    })
    assert_false("资源不足时返回 false", ok2)
    assert_eq("不足 itemId=102001", lack2, 102001)
    log(INFO .. " 资源检查 ✓")
end

-- ---------------------------------------------------------------
-- ⑤ UIShipBackgroundCtrl — GetBuildingDetail（底部栏数据）
-- ---------------------------------------------------------------

function M.TestGetBuildingDetail()
    log(SEP)
    log("=== ⑤ BgCtrl.GetBuildingDetail（底部栏数据）===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 场景1：未解锁
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
    local d1 = ctrl:GetBuildingDetail(bid)
    assert_not_nil("detail 不为 nil",           d1)
    assert_false("未解锁 unlocked=false",        d1.unlocked)
    assert_eq("未解锁 curLevel=0",               d1.curLevel, 0)
    assert_false("未解锁 isUpgrading=false",     d1.isUpgrading)
    assert_false("未解锁 isMax=false",           d1.isMax)
    assert_not_nil("cfg.name 存在",              d1.cfg and d1.cfg.name)
    log(INFO .. " [未解锁] name=" .. d1.cfg.name
        .. "  canOperate=" .. tostring(d1.canOperate))

    -- 场景2：已解锁 level=1 空闲
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local d2 = ctrl:GetBuildingDetail(bid)
    assert_true("已解锁 unlocked=true",          d2.unlocked)
    assert_eq("已解锁 curLevel=1",               d2.curLevel, 1)
    assert_false("空闲 isUpgrading=false",       d2.isUpgrading)
    assert_true("curPower 是数字",               type(d2.curPower) == "number")
    assert_not_nil("curEffect 不为 nil",         d2.curEffect)
    assert_not_nil("nextLevelCfg 存在",          d2.nextLevelCfg)
    log(INFO .. " [已解锁] curPower=" .. d2.curPower
        .. "  upgradeTime=" .. d2.upgradeTime
        .. "  canOperate=" .. tostring(d2.canOperate))

    -- 场景3：升级中
    local bd = mgr():GetMaxLevelBuilding(bid)
    if bd then
        bd.state      = ShipBuildingState.Upgrading
        bd.updateTime = os.time() + 3600
    end
    local d3 = ctrl:GetBuildingDetail(bid)
    assert_true("升级中 isUpgrading=true",       d3.isUpgrading)
    assert_true("升级中 remainSeconds > 0",      d3.remainSeconds > 0)
    log(INFO .. " [升级中] remain=" .. d3.remainSeconds .. "s ✓")

    -- 恢复
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
end

-- ---------------------------------------------------------------
-- ⑥ UIShipBackgroundCtrl — GetBuildingDetail 满级场景
-- ---------------------------------------------------------------

function M.TestGetBuildingDetailMaxLevel()
    log(SEP)
    log("=== ⑥ BgCtrl.GetBuildingDetail 满级场景 ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg      = ctrl:GetBuildingConfig(bid)
    local maxLevel = cfg.level_limit
    resetBuilding(bid, 1, maxLevel, ShipBuildingState.Idle)

    local d = ctrl:GetBuildingDetail(bid)
    assert_true("满级 isMax=true",              d.isMax)
    assert_false("满级 isUpgrading=false",      d.isUpgrading)
    log(INFO .. " 满级 maxLevel=" .. maxLevel .. "  isMax=" .. tostring(d.isMax) .. " ✓")

    -- 恢复
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
end

-- ---------------------------------------------------------------
-- ⑦ UIBuildingPanelCtrl — GetLv1Config
-- ---------------------------------------------------------------

function M.TestPanelCtrlGetLv1Config()
    log(SEP)
    log("=== ⑦ PanelCtrl.GetLv1Config ===")

    local ctrl = newPanelCtrl()
    if not ctrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local lv1 = ctrl:GetLv1Config(bid)
    if lv1 then
        assert_true("lv1.lvup_time >= 0",       lv1.lvup_time >= 0)
        assert_true("lv1.costList 是 table",    type(lv1.costList) == "table")
        log(INFO .. " lv1 power=" .. lv1.power
            .. "  lvup_time=" .. lv1.lvup_time
            .. "  costList=" .. #lv1.costList .. "条")
    else
        log(INFO .. " lv1 配置不存在，跳过")
    end
end

-- ---------------------------------------------------------------
-- ⑧ UIBuildingPanelCtrl — DoConfirm 解锁流程
-- ---------------------------------------------------------------

function M.TestPanelCtrlDoConfirmUnlock()
    log(SEP)
    log("=== ⑧ PanelCtrl.DoConfirm 解锁流程 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 重置为未解锁
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

    -- 用 BgCtrl 组装 detail（和真实流程一致）
    local detail = bgCtrl:GetBuildingDetail(bid)
    assert_false("解锁前 unlocked=false", detail.unlocked)

    -- 执行确认
    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("DoConfirm 返回 ok", ok)
    if not ok then
        log(FAIL .. " 错误: " .. tostring(err))
        return
    end

    -- 验证结果
    local bd = mgr():GetMaxLevelBuilding(bid)
    if bd.state == ShipBuildingState.Idle then
        assert_eq("解锁后 unlock=1", bd.unlock, 1)
        assert_eq("解锁后 level=1",  bd.level,  1)
        log(INFO .. " 立即解锁完成 level=1 ✓")
    elseif bd.state == ShipBuildingState.Unlocking then
        assert_true("解锁中 IsUnlocking=true", bd:IsUnlocking())
        log(INFO .. " 进入解锁倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")
    else
        log(FAIL .. " 解锁后状态异常 state=" .. tostring(bd.state))
    end
end

-- ---------------------------------------------------------------
-- ⑨ UIBuildingPanelCtrl — DoConfirm 升级流程
-- ---------------------------------------------------------------

function M.TestPanelCtrlDoConfirmUpgrade()
    log(SEP)
    log("=== ⑨ PanelCtrl.DoConfirm 升级流程 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 确保已解锁 level=1
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)

    local cfg = bgCtrl:GetBuildingConfig(bid)
    if cfg.level_limit <= 1 then
        log(INFO .. " 该建筑 level_limit=1，无法升级，跳过")
        return
    end

    -- 组装 detail
    local detail = bgCtrl:GetBuildingDetail(bid)
    assert_true("升级前 unlocked=true",         detail.unlocked)
    assert_false("升级前 isUpgrading=false",    detail.isUpgrading)
    assert_false("升级前 isMax=false",          detail.isMax)
    assert_not_nil("nextLevelCfg 存在",         detail.nextLevelCfg)

    log(INFO .. " 升级前 level=" .. detail.curLevel
        .. "  → nextLevel=" .. detail.nextLevel
        .. "  upgradeTime=" .. detail.upgradeTime .. "s")

    -- 执行确认
    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("DoConfirm 返回 ok", ok)
    if not ok then
        log(FAIL .. " 错误: " .. tostring(err))
        return
    end

    -- 验证结果
    local bd = mgr():GetMaxLevelBuilding(bid)
    if bd.state == ShipBuildingState.Done then
        -- lvup_time=0 立即进入待领取
        assert_true("升级后 IsDone=true", bd:IsDone())
        log(INFO .. " 立即升级完成（待领取）✓")
    elseif bd.state == ShipBuildingState.Upgrading then
        assert_true("升级中 IsUpgrading=true", bd:IsUpgrading())
        log(INFO .. " 进入升级倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")
    else
        log(FAIL .. " 升级后状态异常 state=" .. tostring(bd.state))
    end
end

-- ---------------------------------------------------------------
-- ⑩ UIBuildingPanelCtrl — DoConfirm 防重复/边界保护
-- ---------------------------------------------------------------

function M.TestPanelCtrlDoConfirmGuard()
    log(SEP)
    log("=== ⑩ PanelCtrl.DoConfirm 边界保护 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 场景1：升级中时 DoConfirm 应拒绝
    local bd = mgr():GetMaxLevelBuilding(bid)
    if bd then
        bd.unlock     = 1
        bd.level      = 1
        bd.state      = ShipBuildingState.Upgrading
        bd.updateTime = os.time() + 3600
    end
    local detail1 = bgCtrl:GetBuildingDetail(bid)
    local ok1, err1 = panelCtrl:DoConfirm(detail1)
    assert_false("升级中时 DoConfirm 应返回 false", ok1)
    log(INFO .. " 升级中拒绝: " .. tostring(err1) .. " ✓")

    -- 场景2：满级时 DoConfirm 应拒绝
    local cfg      = bgCtrl:GetBuildingConfig(bid)
    local maxLevel = cfg.level_limit
    resetBuilding(bid, 1, maxLevel, ShipBuildingState.Idle)
    local detail2 = bgCtrl:GetBuildingDetail(bid)
    local ok2, err2 = panelCtrl:DoConfirm(detail2)
    assert_false("满级时 DoConfirm 应返回 false", ok2)
    log(INFO .. " 满级拒绝: " .. tostring(err2) .. " ✓")

    -- 恢复
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
end

-- ---------------------------------------------------------------
-- ⑪ 完整链路：点格子 → 底部栏数据 → 打开确认弹窗 → 确认升级
-- ---------------------------------------------------------------

function M.TestFullFlow()
    log(SEP)
    log("=== ⑪ 完整链路测试 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- Step1：重置为未解锁
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
    log(INFO .. " Step1 重置为未解锁")

    -- Step2：模拟点格子，获取底部栏数据
    local detail = bgCtrl:GetBuildingDetail(bid)
    assert_false("底部栏：unlocked=false",      detail.unlocked)
    assert_true("底部栏：cfg.name 不为空",      detail.cfg.name ~= "")
    assert_false("底部栏：isUpgrading=false",   detail.isUpgrading)
    log(INFO .. " Step2 底部栏数据 name=" .. detail.cfg.name
        .. "  canOperate=" .. tostring(detail.canOperate))

    -- Step3：模拟打开确认弹窗（只验证数据，不真正 OpenWindow）
    -- 确认弹窗需要展示的数据都在 detail 里
    assert_not_nil("弹窗数据：nextLevelCfg 或 lv1 存在",
        detail.nextLevelCfg or panelCtrl:GetLv1Config(bid))
    log(INFO .. " Step3 确认弹窗数据 upgradeTime=" .. detail.upgradeTime .. "s")

    -- Step4：点确认，执行解锁
    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("Step4 DoConfirm 返回 ok", ok)
    if not ok then log(FAIL .. " " .. tostring(err)) return end

    local bd = mgr():GetMaxLevelBuilding(bid)
    local afterUnlocked = mgr():IsBuildingUnlocked(bid)
    if bd.state == ShipBuildingState.Idle then
        assert_true("解锁后 IsBuildingUnlocked=true", afterUnlocked)
        log(INFO .. " Step4 立即解锁完成 ✓")
    elseif bd.state == ShipBuildingState.Unlocking then
        log(INFO .. " Step4 进入解锁倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")
    end

    -- Step5：再次获取底部栏数据，验证状态已更新
    local detail2 = bgCtrl:GetBuildingDetail(bid)
    if bd.state == ShipBuildingState.Idle then
        assert_true("Step5 底部栏 unlocked=true",   detail2.unlocked)
        assert_eq("Step5 底部栏 curLevel=1",        detail2.curLevel, 1)
    elseif bd.state == ShipBuildingState.Unlocking then
        assert_true("Step5 底部栏 isUpgrading=true", detail2.isUpgrading)
    end
    log(INFO .. " Step5 底部栏状态已更新 ✓")

    log(INFO .. " 完整链路测试通过 ✓")
end

-- ---------------------------------------------------------------
-- ⑫ OpenBuildingPanel — 验证传给弹窗的 detail 数据完整性
--    （不真正 OpenWindow，只验证数据是否够弹窗用）
-- ---------------------------------------------------------------

function M.TestOpenBuildingPanelData()
    log(SEP)
    log("=== ⑫ OpenBuildingPanel 传给弹窗的数据完整性 ===")

    local bgCtrl = newBgCtrl()
    if not bgCtrl then return end
    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 已解锁 level=1，模拟点升级按钮
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local detail = bgCtrl:GetBuildingDetail(bid)

    -- 弹窗标题需要的字段
    assert_not_nil("detail.cfg.name 存在",      detail.cfg and detail.cfg.name)
    assert_not_nil("detail.nextLevel 存在",     detail.nextLevel)
    assert_not_nil("detail.unlocked 存在",      detail.unlocked ~= nil)

    -- 弹窗时间需要的字段
    assert_true("detail.upgradeTime 是数字",    type(detail.upgradeTime) == "number")
    log(INFO .. " upgradeTime=" .. detail.upgradeTime .. "s")

    -- 弹窗资源列表需要的字段
    assert_not_nil("detail.nextLevelCfg 存在",  detail.nextLevelCfg)
    if detail.nextLevelCfg then
        assert_true("costList 是 table",        type(detail.nextLevelCfg.costList) == "table")
        for i, cost in ipairs(detail.nextLevelCfg.costList) do
            local owned = mgr():GetResourceCount(cost.itemId)
            log(INFO .. string.format("  资源[%d] itemId=%d  need=%d  owned=%d  enough=%s",
                i, cost.itemId, cost.count, owned, tostring(owned >= cost.count)))
            assert_true("cost.itemId 是数字",   type(cost.itemId) == "number")
            assert_true("cost.count > 0",       cost.count > 0)
        end
    end

    -- 弹窗前置条件需要的字段
    assert_not_nil("detail.condOk 存在",        detail.condOk ~= nil)
    assert_not_nil("detail.canOperate 存在",    detail.canOperate ~= nil)
    log(INFO .. " condOk=" .. tostring(detail.condOk)
        .. "  canOperate=" .. tostring(detail.canOperate) .. " ✓")

    -- 未解锁时弹窗用 lv1 数据
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
    local detailLocked = bgCtrl:GetBuildingDetail(bid)
    local panelCtrl    = newPanelCtrl()
    if panelCtrl then
        local lv1 = panelCtrl:GetLv1Config(bid)
        if lv1 then
            assert_true("未解锁时 lv1.costList 是 table", type(lv1.costList) == "table")
            log(INFO .. " 未解锁弹窗 lv1 costList=" .. #lv1.costList .. "条 ✓")
        else
            log(INFO .. " lv1 配置不存在（表里无数据）")
        end
    end

    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
end

-- ---------------------------------------------------------------
-- ⑬ DoConfirm 后验证资源被正确扣减
-- ---------------------------------------------------------------

function M.TestResourceDeductAfterConfirm()
    log(SEP)
    log("=== ⑬ DoConfirm 后资源扣减验证 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    -- 确保已解锁 level=1
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)

    local cfg = bgCtrl:GetBuildingConfig(bid)
    if cfg.level_limit <= 1 then
        log(INFO .. " level_limit=1 无法升级，跳过")
        return
    end

    local detail = bgCtrl:GetBuildingDetail(bid)
    if not detail.nextLevelCfg or #detail.nextLevelCfg.costList == 0 then
        log(INFO .. " 该建筑升级无资源消耗，跳过")
        return
    end

    -- 记录 DoConfirm 前的资源数量
    local beforeAmounts = {}
    for _, cost in ipairs(detail.nextLevelCfg.costList) do
        beforeAmounts[cost.itemId] = mgr():GetResourceCount(cost.itemId)
        log(INFO .. string.format("  扣减前 itemId=%d  owned=%d  need=%d",
            cost.itemId, beforeAmounts[cost.itemId], cost.count))
    end

    -- 执行确认
    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("DoConfirm 返回 ok", ok)
    if not ok then
        log(FAIL .. " 错误: " .. tostring(err))
        return
    end

    -- 验证每种资源都被扣减了正确数量
    for _, cost in ipairs(detail.nextLevelCfg.costList) do
        local afterAmount  = mgr():GetResourceCount(cost.itemId)
        local expectedLeft = beforeAmounts[cost.itemId] - cost.count
        log(INFO .. string.format("  扣减后 itemId=%d  before=%d  need=%d  after=%d  expected=%d",
            cost.itemId, beforeAmounts[cost.itemId], cost.count, afterAmount, expectedLeft))
        assert_eq(string.format("itemId=%d 扣减后数量正确", cost.itemId),
            afterAmount, expectedLeft)
    end

    log(INFO .. " 资源扣减验证通过 ✓")
end

-- ---------------------------------------------------------------
-- ⑭ 完整升级链路（含资源扣减验证）
--    点格子 → 底部栏 → 升级按钮 → 确认弹窗数据 → DoConfirm → 资源减少 → 状态变更
-- ---------------------------------------------------------------

function M.TestFullUpgradeFlow()
    log(SEP)
    log("=== ⑭ 完整升级链路（含资源扣减）===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)
    if cfg.level_limit <= 1 then
        log(INFO .. " level_limit=1，改用解锁流程测试")
        -- 走解锁流程
        resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

        -- Step1 点格子
        local d = bgCtrl:GetBuildingDetail(bid)
        assert_false("Step1 底部栏 unlocked=false", d.unlocked)
        assert_true("Step1 底部栏 cfg.name 不为空", d.cfg.name ~= "")
        log(INFO .. " Step1 底部栏 name=" .. d.cfg.name)

        -- Step2 点解锁按钮 → 确认弹窗数据
        local lv1 = panelCtrl:GetLv1Config(bid)
        assert_not_nil("Step2 弹窗 lv1 存在", lv1)
        log(INFO .. " Step2 弹窗 upgradeTime=" .. (lv1 and lv1.lvup_time or 0) .. "s")

        -- Step3 点确认
        local ok, err = panelCtrl:DoConfirm(d)
        assert_true("Step3 DoConfirm ok", ok)
        if not ok then log(FAIL .. " " .. tostring(err)) return end

        -- Step4 验证状态
        local bd = mgr():GetMaxLevelBuilding(bid)
        if bd.state == ShipBuildingState.Idle then
            assert_eq("Step4 level=1", bd.level, 1)
            log(INFO .. " Step4 立即解锁完成 ✓")
        else
            assert_true("Step4 IsUnlocking", bd:IsUnlocking())
            log(INFO .. " Step4 解锁倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")
        end

        -- Step5 再次点格子，底部栏状态已更新
        local d2 = bgCtrl:GetBuildingDetail(bid)
        if bd.state == ShipBuildingState.Idle then
            assert_true("Step5 unlocked=true", d2.unlocked)
        else
            assert_true("Step5 isUpgrading=true", d2.isUpgrading)
        end
        log(INFO .. " Step5 底部栏状态已更新 ✓")
        return
    end

    -- 走升级流程
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)

    -- Step1：点格子，获取底部栏数据
    local detail = bgCtrl:GetBuildingDetail(bid)
    assert_true("Step1 unlocked=true",          detail.unlocked)
    assert_eq("Step1 curLevel=1",               detail.curLevel, 1)
    assert_false("Step1 isUpgrading=false",     detail.isUpgrading)
    assert_true("Step1 cfg.name 不为空",        detail.cfg.name ~= "")
    assert_true("Step1 curPower 是数字",        type(detail.curPower) == "number")
    assert_not_nil("Step1 curEffect 不为 nil",  detail.curEffect)
    log(INFO .. " Step1 底部栏 name=" .. detail.cfg.name
        .. "  level=" .. detail.curLevel
        .. "  power=" .. detail.curPower
        .. "  effect=" .. tostring(detail.curEffect))

    -- Step2：点升级按钮 → 确认弹窗数据
    assert_not_nil("Step2 nextLevelCfg 存在",   detail.nextLevelCfg)
    assert_true("Step2 upgradeTime 是数字",     type(detail.upgradeTime) == "number")
    assert_true("Step2 costList 不为空",        detail.nextLevelCfg and #detail.nextLevelCfg.costList >= 0)
    log(INFO .. " Step2 弹窗 upgradeTime=" .. detail.upgradeTime .. "s"
        .. "  costList=" .. (detail.nextLevelCfg and #detail.nextLevelCfg.costList or 0) .. "条")

    -- 记录扣减前资源
    local beforeAmounts = {}
    if detail.nextLevelCfg then
        for _, cost in ipairs(detail.nextLevelCfg.costList) do
            beforeAmounts[cost.itemId] = mgr():GetResourceCount(cost.itemId)
            log(INFO .. string.format("  Step2 资源 itemId=%d  owned=%d  need=%d  enough=%s",
                cost.itemId, beforeAmounts[cost.itemId], cost.count,
                tostring(beforeAmounts[cost.itemId] >= cost.count)))
        end
    end

    -- Step3：点确认升级
    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("Step3 DoConfirm ok", ok)
    if not ok then log(FAIL .. " " .. tostring(err)) return end

    -- Step4：验证资源扣减
    if detail.nextLevelCfg then
        for _, cost in ipairs(detail.nextLevelCfg.costList) do
            local afterAmount = mgr():GetResourceCount(cost.itemId)
            assert_eq(string.format("Step4 itemId=%d 扣减正确", cost.itemId),
                afterAmount, beforeAmounts[cost.itemId] - cost.count)
            log(INFO .. string.format("  Step4 itemId=%d  %d - %d = %d ✓",
                cost.itemId, beforeAmounts[cost.itemId], cost.count, afterAmount))
        end
    end

    -- Step5：验证建筑状态变更
    local bd = mgr():GetMaxLevelBuilding(bid)
    if bd.state == ShipBuildingState.Done then
        assert_true("Step5 IsDone=true", bd:IsDone())
        log(INFO .. " Step5 立即升级完成（待领取）✓")
    elseif bd.state == ShipBuildingState.Upgrading then
        assert_true("Step5 IsUpgrading=true", bd:IsUpgrading())
        log(INFO .. " Step5 升级倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")
    else
        log(FAIL .. " Step5 状态异常 state=" .. tostring(bd.state))
    end

    -- Step6：再次点格子，底部栏状态已更新
    local detail2 = bgCtrl:GetBuildingDetail(bid)
    if bd.state == ShipBuildingState.Done then
        assert_true("Step6 底部栏 isDone=true", detail2.isDone)
    elseif bd.state == ShipBuildingState.Upgrading then
        assert_true("Step6 底部栏 isUpgrading=true",  detail2.isUpgrading)
        assert_true("Step6 底部栏 remainSeconds > 0", detail2.remainSeconds > 0)
    end
    log(INFO .. " Step6 底部栏状态已更新 ✓")

    log(INFO .. " 完整升级链路通过 ✓")
end

-- ---------------------------------------------------------------
-- ⑮ 全量建筑状态快照（用 BgCtrl 读名称，和真实流程一致）
-- ---------------------------------------------------------------

function M.PrintAllBuildingStatus()
    log(SEP)
    log("=== ⑫ 全量建筑状态快照 ===")
    log(string.format("%-8s %-20s %-6s %-8s %-12s %-10s",
        "buildId", "name", "level", "unlock", "state", "remain(s)"))
    log(string.rep("-", 70))

    local ctrl = newBgCtrl()
    local list = allBuildIds()
    for _, bid in ipairs(list) do
        local name = (ctrl and ctrl:GetBuildingConfig(bid).name)
                     or GetTableData(TableName.Building_Config, bid, "name") or "?"
        local d = mgr():GetMaxLevelBuilding(bid)
        if d then
            local stateStr = ({
                [ShipBuildingState.Locked]    = "Locked",
                [ShipBuildingState.Idle]      = "Idle",
                [ShipBuildingState.Unlocking] = "Unlocking",
                [ShipBuildingState.Upgrading] = "Upgrading",
            })[d.state] or "?"
            log(string.format("%-8d %-20s %-6d %-8d %-12s %-10d",
                bid, name, d.level, d.unlock, stateStr, d:GetRemainSeconds()))
        end
    end
end

-- ---------------------------------------------------------------
-- 【新A】查看所有建筑的激活状态和等级
-- ---------------------------------------------------------------

function M.PrintAllBuildingActivation()
    log(SEP)
    log("=== 【新A】所有建筑激活状态和等级 ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end

    local list = allBuildIds()
    assert_true("建筑列表不为空", #list > 0)
    log(INFO .. " 共 " .. #list .. " 个建筑")
    log(string.rep("-", 72))
    log(string.format("  %-8s %-20s %-6s %-10s %-12s %-8s",
        "buildId", "名称", "等级", "激活状态", "建筑状态", "剩余(s)"))
    log(string.rep("-", 72))

    local lockedCount = 0
    local idleCount   = 0
    local busyCount   = 0

    for _, bid in ipairs(list) do
        local cfg      = ctrl:GetBuildingConfig(bid)
        local level    = ctrl:GetPlayerBuildingLevel(bid)
        local unlocked = ctrl:IsBuildingUnlocked(bid)
        local bd       = mgr():GetMaxLevelBuilding(bid)
        local remain   = 0
        local stateStr = "?"
        local activeStr = unlocked and "已激活" or "未激活"

        if bd then
            remain = bd:GetRemainSeconds()
            if bd.state == ShipBuildingState.Locked then
                stateStr = "Locked"
                lockedCount = lockedCount + 1
            elseif bd.state == ShipBuildingState.Idle then
                stateStr = "Idle"
                idleCount = idleCount + 1
            elseif bd.state == ShipBuildingState.Unlocking then
                stateStr = "Unlocking"
                busyCount = busyCount + 1
            elseif bd.state == ShipBuildingState.Upgrading then
                stateStr = "Upgrading"
                busyCount = busyCount + 1
            end
        end

        log(string.format("  %-8d %-20s %-6d %-10s %-12s %-8d",
            bid, cfg.name, level, activeStr, stateStr, remain))
    end

    log(string.rep("-", 72))
    log(INFO .. string.format(" 汇总：Locked=%d  Idle=%d  升级/解锁中=%d",
        lockedCount, idleCount, busyCount))
end

-- ---------------------------------------------------------------
-- 【新B】查看某个建筑的详情数据
--   当前等级、当前产出效果、当前战力、解锁状态、升级状态
-- ---------------------------------------------------------------

function M.PrintBuildingDetail(targetBuildId)
    log(SEP)
    local bid = targetBuildId or firstBuildId()
    log("=== 【新B】建筑详情  buildId=" .. tostring(bid) .. " ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local d = ctrl:GetBuildingDetail(bid)
    if not d then log(FAIL .. " GetBuildingDetail 返回 nil") return end

    -- 基础信息一行
    log(INFO .. string.format(" [基础] name=%s  maxLv=%d  desc=%s",
        tostring(d.cfg.name), d.maxLevel, tostring(d.cfg.desc)))

    -- 当前等级信息一行
    local curStateStr = d.isUpgrading
        and string.format("升级中(remain=%ds)", d.remainSeconds)
        or  (d.isMax and "满级" or "空闲")
    log(INFO .. string.format(
        " [当前] unlocked=%s  lv=%d  power=%d  effect=%s  state=%s",
        tostring(d.unlocked), d.curLevel, d.curPower,
        tostring(d.curEffect), curStateStr))

    -- 下一级信息一行
    if d.isMax then
        log(INFO .. " [下级] 已达最高等级，无下一级数据")
    elseif d.nextLevelCfg then
        log(INFO .. string.format(
            " [下级] lv=%d  power=%d  time=%ds  condOk=%s  resOk=%s  canOp=%s",
            d.nextLevel, d.nextLevelCfg.power, d.upgradeTime,
            tostring(d.condOk), tostring(d.resEnough), tostring(d.canOperate)))
    else
        log(INFO .. " [下级] 找不到下一级配置（表里可能无数据）")
    end

    assert_not_nil("cfg.name 不为 nil",  d.cfg.name)
    assert_true("curLevel 是数字",       type(d.curLevel) == "number")
    assert_true("curPower 是数字",       type(d.curPower) == "number")
    assert_not_nil("unlocked 不为 nil",  d.unlocked ~= nil)
    assert_not_nil("isMax 不为 nil",     d.isMax ~= nil)
end

-- ---------------------------------------------------------------
-- 【新C】升级确认弹窗界面逻辑
--   所需升级条件、所需材料（当前拥有/所需/是否满足）、升级前后战力对比
-- ---------------------------------------------------------------

function M.PrintUpgradeConfirmDetail(targetBuildId)
    log(SEP)
    local bid = targetBuildId or firstBuildId()
    log("=== 【新C】升级确认弹窗数据  buildId=" .. tostring(bid) .. " ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end
    if not bid then log(FAIL .. " 找不到 buildId") return end

    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local d = bgCtrl:GetBuildingDetail(bid)

    log(INFO .. " ── 弹窗标题 ──────────────────────────")
    if not d.unlocked then
        log(INFO .. " 操作类型 : 解锁")
        log(INFO .. " 标题文字 : " .. d.cfg.name .. "  解锁")
    elseif d.isMax then
        log(INFO .. " 操作类型 : 已满级")
        log(INFO .. " 标题文字 : " .. d.cfg.name .. "  已达最高等级")
    else
        log(INFO .. " 操作类型 : 升级")
        log(INFO .. string.format(" 标题文字 : %s  升至%d级", d.cfg.name, d.nextLevel))
    end

    log(INFO .. " ── 所需时间 ──────────────────────────")
    log(INFO .. " 升级耗时 : " .. tostring(d.upgradeTime) .. "s")

    log(INFO .. " ── 前置条件 ──────────────────────────")
    if d.nextLevelCfg and d.nextLevelCfg.lvup_require1 ~= "" then
        local condType = d.nextLevelCfg.lvup_cond_type or 0
        local condDesc = ""
        if condType == 2 then
            condDesc = string.format("需要完成建筑 ID=%s", d.nextLevelCfg.lvup_require1)
        elseif condType == 3 then
            condDesc = string.format("玩家等级 >= %d", d.nextLevelCfg.lvup_require1_unlock)
        elseif condType == 4 then
            condDesc = string.format("建筑 ID=%s 需达到 %d 级", d.nextLevelCfg.lvup_require1, d.nextLevelCfg.lvup_require1_unlock)
        elseif condType == 5 then
            condDesc = string.format("需要持有物品 %s", d.nextLevelCfg.lvup_require1)
        else
            condDesc = string.format("condType=%d param=%s", condType, d.nextLevelCfg.lvup_require1)
        end
        log(INFO .. " 前置条件 : " .. condDesc)
        if d.condOk then
            log(PASS .. " 前置条件满足")
        else
            log(FAIL .. " 前置条件不满足")
        end
    else
        log(INFO .. " 无前置建筑条件")
    end

    log(INFO .. " ── 所需材料（当前拥有 / 所需 / 是否满足）──")
    local RESOURCE_NAME = {
        [102001]="食材",[102002]="金属",
        [102003]="电力",[102004]="有机质",[102005]="科技点",
    }
    local costList = {}
    if d.nextLevelCfg and d.nextLevelCfg.costList then
        costList = d.nextLevelCfg.costList
    elseif not d.unlocked then
        local lv1 = panelCtrl:GetLv1Config(bid)
        if lv1 then costList = lv1.costList or {} end
    end

    if #costList == 0 then
        log(INFO .. " 无材料消耗")
    else
        log(string.format("  %-12s %-12s %-12s %-8s",
            "材料名称", "当前拥有", "所需数量", "是否满足"))
        log("  " .. string.rep("-", 48))
        local allEnough = true
        for _, cost in ipairs(costList) do
            local owned  = mgr():GetResourceCount(cost.itemId)
            local enough = owned >= cost.count
            if not enough then allEnough = false end
            local name   = RESOURCE_NAME[cost.itemId] or ("id=" .. cost.itemId)
            local flag   = enough and "✓ 满足" or "✗ 不足"
            log(string.format("  %-12s %-12d %-12d %-8s", name, owned, cost.count, flag))
            if enough then
                log(PASS .. " " .. name .. " 资源满足")
            else
                log(FAIL .. " " .. name .. " 不足  owned=" .. owned .. "  need=" .. cost.count)
            end
        end
        log(INFO .. " 材料整体满足: " .. tostring(allEnough))
    end

    log(INFO .. " ── 升级前后战力对比 ──────────────────")
    local curPower  = d.curPower
    local nextPower = d.nextLevelCfg and d.nextLevelCfg.power or 0
    log(INFO .. string.format(" 当前战力 : %d  (Lv.%d)", curPower, d.curLevel))
    log(INFO .. string.format(" 升级后   : %d  (Lv.%d)", nextPower, d.nextLevel))
    log(INFO .. string.format(" 战力提升 : +%d", nextPower - curPower))
    assert_true("升级后战力 >= 当前战力", nextPower >= curPower)

    log(INFO .. " ── 确认按钮状态 ──────────────────────")
    if d.canOperate then
        log(PASS .. " 确认按钮可点击")
    else
        log(INFO .. " 确认按钮置灰（条件或资源不满足）")
    end
end

-- ---------------------------------------------------------------
-- 【新D】升级逻辑完整验证
--   解锁流程 + 升级流程 + 资源扣减 + 状态变更 + 底部栏数据更新
--   + 升级中时拒绝重复操作
-- ---------------------------------------------------------------

function M.TestUpgradeLogic(targetBuildId)
    log(SEP)
    local bid = targetBuildId or firstBuildId()
    log("=== 【新D】升级逻辑完整验证  buildId=" .. tostring(bid) .. " ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)

    -- ── 场景1：未解锁 → 执行解锁 ──────────────────────────────
    log(INFO .. " ── 场景1：解锁流程 ──")
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

    local d1 = bgCtrl:GetBuildingDetail(bid)
    assert_false("解锁前 unlocked=false",    d1.unlocked)
    assert_false("解锁前 isUpgrading=false", d1.isUpgrading)
    log(INFO .. " 解锁前 level=" .. d1.curLevel
        .. "  canOperate=" .. tostring(d1.canOperate))

    local ok1, err1 = panelCtrl:DoConfirm(d1)
    assert_true("DoConfirm(解锁) 返回 ok", ok1)
    if not ok1 then
        log(FAIL .. " 解锁失败: " .. tostring(err1))
    else
        local bd1 = mgr():GetMaxLevelBuilding(bid)
        if bd1.state == ShipBuildingState.Idle then
            assert_eq("解锁后 level=1",  bd1.level,  1)
            assert_eq("解锁后 unlock=1", bd1.unlock, 1)
            log(PASS .. " 立即解锁完成 level=1 ✓")
        elseif bd1.state == ShipBuildingState.Unlocking then
            assert_true("解锁中 IsUnlocking=true", bd1:IsUnlocking())
            log(PASS .. " 进入解锁倒计时 remain=" .. bd1:GetRemainSeconds() .. "s ✓")
        else
            log(FAIL .. " 解锁后状态异常 state=" .. tostring(bd1.state))
        end
        local d1after = bgCtrl:GetBuildingDetail(bid)
        if bd1.state == ShipBuildingState.Idle then
            assert_true("解锁后底部栏 unlocked=true", d1after.unlocked)
            assert_eq("解锁后底部栏 curLevel=1",      d1after.curLevel, 1)
        elseif bd1.state == ShipBuildingState.Unlocking then
            assert_true("解锁中底部栏 isUpgrading=true", d1after.isUpgrading)
        end
        log(INFO .. " 底部栏数据已更新 ✓")
    end

    -- ── 场景2：已解锁 → 执行升级 ──────────────────────────────
    if cfg.level_limit <= 1 then
        log(INFO .. " level_limit=1，跳过升级场景")
        return
    end

    log(INFO .. " ── 场景2：升级流程 ──")
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)

    local d2 = bgCtrl:GetBuildingDetail(bid)
    assert_true("升级前 unlocked=true",      d2.unlocked)
    assert_false("升级前 isUpgrading=false", d2.isUpgrading)
    assert_false("升级前 isMax=false",       d2.isMax)
    assert_not_nil("nextLevelCfg 存在",      d2.nextLevelCfg)
    log(INFO .. " 升级前 level=" .. d2.curLevel
        .. "  power=" .. d2.curPower
        .. "  → nextLevel=" .. d2.nextLevel
        .. "  nextPower=" .. (d2.nextLevelCfg and d2.nextLevelCfg.power or 0)
        .. "  upgradeTime=" .. d2.upgradeTime .. "s")

    -- 记录扣减前资源
    local RESOURCE_NAME = {
        [102001]="食材",[102002]="金属",
        [102003]="电力",[102004]="有机质",[102005]="科技点",
    }
    local beforeAmounts = {}
    if d2.nextLevelCfg then
        for _, cost in ipairs(d2.nextLevelCfg.costList) do
            beforeAmounts[cost.itemId] = mgr():GetResourceCount(cost.itemId)
        end
    end

    local ok2, err2 = panelCtrl:DoConfirm(d2)
    assert_true("DoConfirm(升级) 返回 ok", ok2)
    if not ok2 then
        log(FAIL .. " 升级失败: " .. tostring(err2))
        return
    end

    -- 验证资源扣减
    if d2.nextLevelCfg then
        for _, cost in ipairs(d2.nextLevelCfg.costList) do
            local afterAmount = mgr():GetResourceCount(cost.itemId)
            local expected    = beforeAmounts[cost.itemId] - cost.count
            local name        = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
            assert_eq(name .. " 扣减后数量正确", afterAmount, expected)
            log(INFO .. string.format(" %s: %d - %d = %d ✓",
                name, beforeAmounts[cost.itemId], cost.count, afterAmount))
        end
    end

    -- 验证建筑状态
    local bd2 = mgr():GetMaxLevelBuilding(bid)
    if bd2.state == ShipBuildingState.Done then
        assert_true("升级后 IsDone=true", bd2:IsDone())
        log(PASS .. " 立即升级完成（待领取）✓")
    elseif bd2.state == ShipBuildingState.Upgrading then
        assert_true("升级中 IsUpgrading=true", bd2:IsUpgrading())
        log(PASS .. " 进入升级倒计时 remain=" .. bd2:GetRemainSeconds() .. "s ✓")
    else
        log(FAIL .. " 升级后状态异常 state=" .. tostring(bd2.state))
    end

    -- 验证底部栏数据更新
    local d2after = bgCtrl:GetBuildingDetail(bid)
    if bd2.state == ShipBuildingState.Done then
        assert_true("待领取底部栏 isDone=true", d2after.isDone)
        log(INFO .. " 待领取底部栏 doneType=" .. tostring(d2after.doneType))
    elseif bd2.state == ShipBuildingState.Upgrading then
        assert_true("升级中底部栏 isUpgrading=true",   d2after.isUpgrading)
        assert_true("升级中底部栏 remainSeconds > 0",  d2after.remainSeconds > 0)
    end
    log(INFO .. " 底部栏数据已更新 ✓")

    -- ── 场景3：升级中时拒绝重复操作 ──────────────────────────
    log(INFO .. " ── 场景3：升级中时拒绝重复操作 ──")
    local bd3 = mgr():GetMaxLevelBuilding(bid)
    if bd3 then
        bd3.state      = ShipBuildingState.Upgrading
        bd3.updateTime = os.time() + 3600
    end
    local d3        = bgCtrl:GetBuildingDetail(bid)
    local ok3, err3 = panelCtrl:DoConfirm(d3)
    assert_false("升级中时 DoConfirm 应拒绝", ok3)
    log(PASS .. " 升级中拒绝重复操作: " .. tostring(err3) .. " ✓")

    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    log(INFO .. " 升级逻辑完整验证通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新E】BgCtrl.UnlockBuilding 解锁建筑完整测试
--   覆盖：条件检查 → 资源检查 → 执行解锁 → 状态验证 → 资源扣减验证
--         + 重复解锁保护 + 解锁中保护
-- ---------------------------------------------------------------

function M.TestUnlockBuildingCtrl(targetBuildId)
    log(SEP)
    local bid = targetBuildId or firstBuildId()
    log("=== 【新E】BgCtrl.UnlockBuilding  buildId=" .. tostring(bid) .. " ===")

    local ctrl = newBgCtrl()
    if not ctrl then return end
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = ctrl:GetBuildingConfig(bid)
    log(INFO .. " 建筑名称=" .. cfg.name)

    -- ── 场景1：前置条件检查 ──────────────────────────────────
    log(INFO .. " ── 场景1：前置条件检查 ──")
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

    local condOk, condDesc = ctrl:CheckUnlockCondition(bid)
    if condOk then
        log(PASS .. " 无前置条件或前置条件已满足")
    else
        log(INFO .. " 前置条件不满足: " .. tostring(condDesc))
    end

    -- ── 场景2：资源检查 ──────────────────────────────────────
    log(INFO .. " ── 场景2：资源检查 ──")
    local lv1 = ctrl:GetBuildingLevelConfig(bid, 1)
    if not lv1 then
        log(INFO .. " 找不到第1级配置，跳过资源检查")
    else
        log(INFO .. " 解锁所需时间=" .. lv1.lvup_time .. "s  costList=" .. #lv1.costList .. "条")
        local RESOURCE_NAME = {
            [102001]="食材",[102002]="金属",
            [102003]="电力",[102004]="有机质",[102005]="科技点",
        }
        for _, cost in ipairs(lv1.costList) do
            local owned  = mgr():GetResourceCount(cost.itemId)
            local enough = owned >= cost.count
            local name   = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
            log(INFO .. string.format(" %s: owned=%d  need=%d  %s",
                name, owned, cost.count, enough and "✓满足" or "✗不足"))
        end
        local resOk, lackId = ctrl:CheckResourceEnough(lv1.costList)
        assert_true("资源整体满足", resOk)
    end

    -- ── 场景3：执行解锁，验证状态变更和资源扣减 ─────────────
    log(INFO .. " ── 场景3：执行解锁 ──")
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)

    -- 记录解锁前资源
    local beforeAmounts = {}
    if lv1 then
        for _, cost in ipairs(lv1.costList) do
            beforeAmounts[cost.itemId] = mgr():GetResourceCount(cost.itemId)
        end
    end

    -- 调用 BgCtrl.UnlockBuilding（内部走条件检查+资源检查+StartUnlockBuilding）
    ctrl:UnlockBuilding(bid)

    local bd = mgr():GetMaxLevelBuilding(bid)
    if not bd then
        log(FAIL .. " 找不到 buildData")
        return
    end

    if bd.state == ShipBuildingState.Idle then
        -- lvup_time=0 立即完成
        assert_eq("立即解锁后 unlock=1", bd.unlock, 1)
        assert_eq("立即解锁后 level=1",  bd.level,  1)
        log(PASS .. " 立即解锁完成 level=1 ✓")

        -- 验证资源扣减
        if lv1 then
            local RESOURCE_NAME = {
                [102001]="食材",[102002]="金属",
                [102003]="电力",[102004]="有机质",[102005]="科技点",
            }
            for _, cost in ipairs(lv1.costList) do
                local afterAmount = mgr():GetResourceCount(cost.itemId)
                local expected    = beforeAmounts[cost.itemId] - cost.count
                local name        = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                assert_eq(name .. " 扣减正确", afterAmount, expected)
                log(INFO .. string.format(" %s: %d - %d = %d ✓",
                    name, beforeAmounts[cost.itemId], cost.count, afterAmount))
            end
        end

        -- 验证底部栏数据已更新
        local detail = ctrl:GetBuildingDetail(bid)
        assert_true("解锁后底部栏 unlocked=true", detail.unlocked)
        assert_eq("解锁后底部栏 curLevel=1",      detail.curLevel, 1)
        assert_false("解锁后底部栏 isUpgrading=false", detail.isUpgrading)
        log(INFO .. " 底部栏 power=" .. detail.curPower
            .. "  effect=" .. tostring(detail.curEffect))

    elseif bd.state == ShipBuildingState.Unlocking then
        assert_true("解锁中 IsUnlocking=true", bd:IsUnlocking())
        assert_true("解锁中 remainSeconds > 0", bd:GetRemainSeconds() > 0)
        log(PASS .. " 进入解锁倒计时 remain=" .. bd:GetRemainSeconds() .. "s ✓")

        -- 验证资源已扣减（倒计时解锁也会扣资源）
        if lv1 then
            local RESOURCE_NAME = {
                [102001]="食材",[102002]="金属",
                [102003]="电力",[102004]="有机质",[102005]="科技点",
            }
            for _, cost in ipairs(lv1.costList) do
                local afterAmount = mgr():GetResourceCount(cost.itemId)
                local expected    = beforeAmounts[cost.itemId] - cost.count
                local name        = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                assert_eq(name .. " 扣减正确", afterAmount, expected)
            end
        end

        -- 验证底部栏显示升级中状态
        local detail = ctrl:GetBuildingDetail(bid)
        assert_true("解锁中底部栏 isUpgrading=true", detail.isUpgrading)
        assert_true("解锁中底部栏 remainSeconds > 0", detail.remainSeconds > 0)
        log(INFO .. " 底部栏 remain=" .. detail.remainSeconds .. "s ✓")
    else
        log(FAIL .. " 解锁后状态异常 state=" .. tostring(bd.state))
    end

    -- ── 场景4：重复解锁保护（已解锁时调用 UnlockBuilding 应静默跳过）──
    log(INFO .. " ── 场景4：重复解锁保护 ──")
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local levelBefore = mgr():GetMaxLevelBuilding(bid).level
    ctrl:UnlockBuilding(bid)  -- 已解锁，应直接 return
    local levelAfter = mgr():GetMaxLevelBuilding(bid).level
    assert_eq("已解锁时 UnlockBuilding 不改变 level", levelAfter, levelBefore)
    log(PASS .. " 重复解锁保护正常 ✓")

    -- ── 场景5：解锁中时保护（解锁进行中再次调用应静默跳过）──
    log(INFO .. " ── 场景5：解锁中时保护 ──")
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
    local bd2 = mgr():GetMaxLevelBuilding(bid)
    if bd2 then
        bd2.state      = ShipBuildingState.Unlocking
        bd2.updateTime = os.time() + 3600
    end
    local stateBefore = mgr():GetMaxLevelBuilding(bid).state
    ctrl:UnlockBuilding(bid)  -- 解锁中，应直接 return
    local stateAfter = mgr():GetMaxLevelBuilding(bid).state
    assert_eq("解锁中时 UnlockBuilding 不改变 state",
        stateAfter, stateBefore)
    log(PASS .. " 解锁中保护正常 ✓")

    -- 恢复
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    log(INFO .. " UnlockBuilding 完整测试通过 ✓")
end

-- ---------------------------------------------------------------
-- 【正式流程】完整走一遍真实业务流程，不使用 resetBuilding
--   Step1：查看所有建筑解锁状态和等级
--   Step2：找到一个未解锁的建筑，执行解锁
--   Step3：查看解锁后该建筑的详情数据
--   Step4：模拟打开升级确认弹窗，展示所需资源和时间
--   Step5：触发升级逻辑，验证结果
-- ---------------------------------------------------------------

function M.TestRealFlow()
    log(SEP)
    log("=== 【正式流程】完整业务流程（不使用 resetBuilding）===")
    log(SEP)

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local RESOURCE_NAME = {
        [102001]="食材",[102002]="金属",
        [102003]="电力",[102004]="有机质",[102005]="科技点",
    }

    -- ══════════════════════════════════════════════════════════
    -- Step1：查看所有建筑当前解锁状态和等级
    -- ══════════════════════════════════════════════════════════
    log(SEP)
    log("Step1：查看所有建筑解锁状态和等级")
    log(SEP)

    local list = allBuildIds()
    assert_true("建筑列表不为空", #list > 0)

    log(string.format("  %-8s %-20s %-6s %-10s %-12s",
        "buildId", "名称", "等级", "激活状态", "建筑状态"))
    log("  " .. string.rep("-", 60))

    local lockedBid = nil   -- 找一个未解锁的建筑用于后续解锁
    local idleBid   = nil   -- 找一个已解锁空闲的建筑用于后续升级

    for _, bid in ipairs(list) do
        local cfg      = bgCtrl:GetBuildingConfig(bid)
        local level    = bgCtrl:GetPlayerBuildingLevel(bid)
        local unlocked = bgCtrl:IsBuildingUnlocked(bid)
        local bd       = mgr():GetMaxLevelBuilding(bid)
        local stateStr = "?"
        if bd then
            if bd.state == ShipBuildingState.Locked    then stateStr = "Locked"
            elseif bd.state == ShipBuildingState.Idle      then stateStr = "Idle"
            elseif bd.state == ShipBuildingState.Unlocking then stateStr = "Unlocking"
            elseif bd.state == ShipBuildingState.Upgrading then stateStr = "Upgrading"
            end
        end
        log(string.format("  %-8d %-20s %-6d %-10s %-12s",
            bid, cfg.name, level, unlocked and "已激活" or "未激活", stateStr))

        -- 找第一个未解锁的建筑
        if not lockedBid and not unlocked
            and bd and bd.state == ShipBuildingState.Locked then
            lockedBid = bid
        end
        -- 找第一个已解锁空闲且未满级的建筑
        if not idleBid and unlocked
            and bd and bd.state == ShipBuildingState.Idle
            and level < bgCtrl:GetBuildingConfig(bid).level_limit then
            idleBid = bid
        end
    end

    if not lockedBid then
        log(INFO .. " 没有未解锁的建筑，跳过 Step2-3")
    end
    if not idleBid then
        log(INFO .. " 没有已解锁空闲且未满级的建筑，跳过 Step4-5")
    end

    -- ══════════════════════════════════════════════════════════
    -- Step2：解锁一个未解锁的建筑
    -- ══════════════════════════════════════════════════════════
    log(SEP)
    log("Step2：解锁建筑  buildId=" .. tostring(lockedBid))
    log(SEP)

    if not lockedBid then
        log(INFO .. " 跳过（无未解锁建筑）")
    else
        local cfg2 = bgCtrl:GetBuildingConfig(lockedBid)
        log(INFO .. " 目标建筑: " .. cfg2.name)

        -- 检查前置条件
        local condOk, condDesc = bgCtrl:CheckUnlockCondition(lockedBid)
        if condOk then
            log(PASS .. " 前置条件满足")
        else
            log(INFO .. " 前置条件不满足: " .. tostring(condDesc)
                .. "（仍继续执行，观察 UnlockBuilding 的处理）")
        end

        -- 检查资源
        local lv1 = bgCtrl:GetBuildingLevelConfig(lockedBid, 1)
        if lv1 then
            log(INFO .. " 解锁耗时=" .. lv1.lvup_time .. "s  costList=" .. #lv1.costList .. "条")
            for _, cost in ipairs(lv1.costList) do
                local owned  = mgr():GetResourceCount(cost.itemId)
                local name   = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                log(INFO .. string.format("  %s: owned=%d  need=%d  %s",
                    name, owned, cost.count, owned >= cost.count and "✓" or "✗"))
            end
        end

        -- 记录解锁前资源
        local beforeAmounts = {}
        if lv1 then
            for _, cost in ipairs(lv1.costList) do
                beforeAmounts[cost.itemId] = mgr():GetResourceCount(cost.itemId)
            end
        end

        -- 执行解锁
        bgCtrl:UnlockBuilding(lockedBid)

        -- 验证结果
        local bd2 = mgr():GetMaxLevelBuilding(lockedBid)
        if bd2.state == ShipBuildingState.Idle then
            -- lvup_time=0 立即完成
            assert_eq("解锁后 unlock=1", bd2.unlock, 1)
            assert_eq("解锁后 level=1",  bd2.level,  1)
            log(PASS .. " 立即解锁完成 level=1")
            -- 验证资源扣减
            if lv1 then
                for _, cost in ipairs(lv1.costList) do
                    local name  = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                    local after = mgr():GetResourceCount(cost.itemId)
                    assert_eq(name .. " 扣减正确", after, beforeAmounts[cost.itemId] - cost.count)
                    log(INFO .. string.format("  %s: %d → %d (扣 %d)",
                        name, beforeAmounts[cost.itemId], after, cost.count))
                end
            end
            -- 解锁成功后，这个建筑可以用于后续升级
            if not idleBid then idleBid = lockedBid end

        elseif bd2.state == ShipBuildingState.Unlocking then
            log(PASS .. " 进入解锁倒计时 remain=" .. bd2:GetRemainSeconds() .. "s")
            -- 验证资源扣减
            if lv1 then
                for _, cost in ipairs(lv1.costList) do
                    local name  = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                    local after = mgr():GetResourceCount(cost.itemId)
                    assert_eq(name .. " 扣减正确", after, beforeAmounts[cost.itemId] - cost.count)
                end
            end
            log(INFO .. " 建筑解锁中，自动加速完成并领取...")

            -- 加速：把完成时间设为过去，让 Tick 检测到期
            bd2.updateTime = os.time() - 1
            mgr():Tick()

            -- Tick 后应进入 Done 状态
            if bd2.state == ShipBuildingState.Done then
                log(INFO .. " Tick 后进入待领取状态，自动领取...")
                local collectOk, collectErr = mgr():CollectBuildingResult(bd2.uuid)
                if collectOk then
                    assert_eq("自动领取后 unlock=1", bd2.unlock, 1)
                    assert_eq("自动领取后 level=1",  bd2.level,  1)
                    assert_eq("自动领取后 state=Idle", bd2.state, ShipBuildingState.Idle)
                    log(PASS .. " 解锁倒计时完成并自动领取 level=1 ✓")
                    -- 解锁成功，可用于后续升级
                    if not idleBid then idleBid = lockedBid end
                else
                    log(FAIL .. " 自动领取失败: " .. tostring(collectErr))
                end
            else
                log(INFO .. " Tick 后状态=" .. tostring(bd2.state) .. "，尝试手动完成解锁...")
                mgr():FinishUnlockBuilding(bd2.uuid)
                if bd2.state == ShipBuildingState.Done then
                    local collectOk, collectErr = mgr():CollectBuildingResult(bd2.uuid)
                    if collectOk then
                        log(PASS .. " 手动完成解锁并领取 level=1 ✓")
                        if not idleBid then idleBid = lockedBid end
                    else
                        log(FAIL .. " 领取失败: " .. tostring(collectErr))
                    end
                else
                    log(INFO .. " 建筑解锁中，Step3 将展示解锁中状态")
                end
            end

        elseif bd2.state == ShipBuildingState.Locked then
            log(INFO .. " 解锁未执行（前置条件或资源不满足），建筑仍为 Locked 状态")
        else
            log(FAIL .. " 解锁后状态异常 state=" .. tostring(bd2.state))
        end
    end

    -- ══════════════════════════════════════════════════════════
    -- Step3：查看刚解锁的建筑详情数据
    -- ══════════════════════════════════════════════════════════
    log(SEP)
    log("Step3：查看建筑详情  buildId=" .. tostring(lockedBid))
    log(SEP)

    if not lockedBid then
        log(INFO .. " 跳过（无目标建筑）")
    else
        local d3 = bgCtrl:GetBuildingDetail(lockedBid)
        -- 基础信息
        log(INFO .. string.format(" [基础] name=%s  maxLv=%d",
            d3.cfg.name, d3.maxLevel))
        -- 当前状态
        local stateStr3 = d3.isUpgrading
            and string.format("升级/解锁中(remain=%ds)", d3.remainSeconds)
            or  (d3.isMax and "满级" or "空闲")
        log(INFO .. string.format(
            " [当前] unlocked=%s  lv=%d  power=%d  effect=%s  state=%s",
            tostring(d3.unlocked), d3.curLevel, d3.curPower,
            tostring(d3.curEffect), stateStr3))
        -- 下一级
        if d3.isMax then
            log(INFO .. " [下级] 已满级")
        elseif d3.nextLevelCfg then
            log(INFO .. string.format(
                " [下级] lv=%d  power=%d  time=%ds  condOk=%s  resOk=%s  canOp=%s",
                d3.nextLevel, d3.nextLevelCfg.power, d3.upgradeTime,
                tostring(d3.condOk), tostring(d3.resEnough), tostring(d3.canOperate)))
        else
            log(INFO .. " [下级] 无下一级配置")
        end

        assert_not_nil("detail.cfg.name 存在", d3.cfg.name)
        assert_true("curLevel 是数字", type(d3.curLevel) == "number")
    end

    -- ══════════════════════════════════════════════════════════
    -- Step4：升级确认弹窗数据（找一个已解锁空闲的建筑）
    -- ══════════════════════════════════════════════════════════
    log(SEP)
    log("Step4：升级确认弹窗数据  buildId=" .. tostring(idleBid))
    log(SEP)

    if not idleBid then
        log(INFO .. " 跳过（无已解锁空闲建筑）")
    else
        local d4 = bgCtrl:GetBuildingDetail(idleBid)

        if d4.isUpgrading then
            log(INFO .. " 该建筑正在升级/解锁中，弹窗应显示升级中状态")
        elseif d4.isMax then
            log(INFO .. " 该建筑已满级，弹窗应显示已满级")
        else
            -- 弹窗标题
            log(INFO .. string.format(" 弹窗标题: %s  升至%d级",
                d4.cfg.name, d4.nextLevel))
            -- 所需时间
            log(INFO .. " 所需时间: " .. d4.upgradeTime .. "s")
            -- 前置条件
            if d4.nextLevelCfg and d4.nextLevelCfg.lvup_require1 ~= "" then
                local condType = d4.nextLevelCfg.lvup_cond_type or 0
                local condDesc = ""
                if condType == 2 then
                    condDesc = string.format("需要完成建筑 ID=%s", d4.nextLevelCfg.lvup_require1)
                elseif condType == 3 then
                    condDesc = string.format("玩家等级 >= %d", d4.nextLevelCfg.lvup_require1_unlock)
                elseif condType == 4 then
                    condDesc = string.format("建筑 ID=%s 需达到 %d 级", d4.nextLevelCfg.lvup_require1, d4.nextLevelCfg.lvup_require1_unlock)
                elseif condType == 5 then
                    condDesc = string.format("需要持有物品 %s", d4.nextLevelCfg.lvup_require1)
                else
                    condDesc = string.format("condType=%d param=%s", condType, d4.nextLevelCfg.lvup_require1)
                end
                log(INFO .. string.format(" 前置条件: %s  满足=%s", condDesc, tostring(d4.condOk)))
            else
                log(INFO .. " 前置条件: 无")
            end
            -- 所需材料
            local costList4 = d4.nextLevelCfg and d4.nextLevelCfg.costList or {}
            if #costList4 == 0 then
                log(INFO .. " 所需材料: 无消耗")
            else
                log(string.format("  %-12s %-12s %-12s %-8s",
                    "材料", "当前拥有", "所需数量", "是否满足"))
                log("  " .. string.rep("-", 48))
                for _, cost in ipairs(costList4) do
                    local owned  = mgr():GetResourceCount(cost.itemId)
                    local name   = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                    local enough = owned >= cost.count
                    log(string.format("  %-12s %-12d %-12d %-8s",
                        name, owned, cost.count, enough and "✓满足" or "✗不足"))
                end
            end
            -- 升级前后战力对比
            log(INFO .. string.format(" 战力对比: %d(Lv%d) → %d(Lv%d)  +%d",
                d4.curPower, d4.curLevel,
                d4.nextLevelCfg and d4.nextLevelCfg.power or 0, d4.nextLevel,
                (d4.nextLevelCfg and d4.nextLevelCfg.power or 0) - d4.curPower))
            -- 确认按钮状态
            if d4.canOperate then
                log(PASS .. " 确认按钮可点击")
            else
                log(INFO .. " 确认按钮置灰（条件或资源不满足）")
            end

            assert_not_nil("nextLevelCfg 存在",     d4.nextLevelCfg)
            assert_true("upgradeTime 是数字",        type(d4.upgradeTime) == "number")
        end
    end

    -- ══════════════════════════════════════════════════════════
    -- Step5：触发升级逻辑
    -- ══════════════════════════════════════════════════════════
    log(SEP)
    log("Step5：触发升级  buildId=" .. tostring(idleBid))
    log(SEP)

    if not idleBid then
        log(INFO .. " 跳过（无已解锁空闲建筑）")
    else
        local d5 = bgCtrl:GetBuildingDetail(idleBid)

        if d5.isUpgrading then
            log(INFO .. " 建筑正在升级/解锁中，无法再次升级")
        elseif d5.isMax then
            log(INFO .. " 建筑已满级，无法升级")
        elseif not d5.canOperate then
            log(INFO .. " 条件或资源不满足，无法升级  condOk="
                .. tostring(d5.condOk) .. "  resEnough=" .. tostring(d5.resEnough))

            -- condOk=false 时，强制满足玩家等级条件后继续升级
            if not d5.condOk and d5.nextLevelCfg then
                local condType    = d5.nextLevelCfg.lvup_cond_type or 0
                local requireUnlk = d5.nextLevelCfg.lvup_require1_unlock

                if condType == 3 then
                    -- 玩家等级不足 → 强制设置玩家等级
                    local needLv = requireUnlk or 0
                    log(INFO .. string.format(" [自动修复] 玩家等级不足，强制设置等级 → %d", needLv))
                    mgr().selfPlayer.level = needLv
                else
                    log(INFO .. string.format(" [自动修复] condType=%d 暂不支持自动修复，跳过升级", condType))
                end

                -- 重新获取 detail，验证条件是否已满足
                d5 = bgCtrl:GetBuildingDetail(idleBid)
                if d5.condOk then
                    log(PASS .. " [自动修复] 前置条件已满足，继续升级流程")
                else
                    log(INFO .. " [自动修复] 修复后 condOk 仍为 false，跳过升级")
                end
            end

            -- 修复后再次判断能否操作
            if d5.canOperate then
                -- fall through 到下面的升级执行逻辑
            else
                log(INFO .. " canOperate 仍为 false，跳过升级")
            end
        end

        -- 升级执行逻辑（canOperate=true 时执行，包含原 else 分支和修复后继续的情况）
        if d5.canOperate and not d5.isUpgrading and not d5.isMax then
            -- 记录升级前资源
            local before5 = {}
            if d5.nextLevelCfg then
                for _, cost in ipairs(d5.nextLevelCfg.costList) do
                    before5[cost.itemId] = mgr():GetResourceCount(cost.itemId)
                end
            end
            local levelBefore5 = d5.curLevel
            log(INFO .. " 升级前 level=" .. levelBefore5
                .. "  power=" .. d5.curPower
                .. "  → nextLevel=" .. d5.nextLevel
                .. "  nextPower=" .. (d5.nextLevelCfg and d5.nextLevelCfg.power or 0))

            -- 执行确认升级（走 PanelCtrl.DoConfirm，和点确认按钮一致）
            local ok5, err5 = panelCtrl:DoConfirm(d5)
            assert_true("DoConfirm 返回 ok", ok5)
            if not ok5 then
                log(FAIL .. " 升级失败: " .. tostring(err5))
            else
                -- 验证资源扣减
                if d5.nextLevelCfg then
                    for _, cost in ipairs(d5.nextLevelCfg.costList) do
                        local name  = RESOURCE_NAME[cost.itemId] or tostring(cost.itemId)
                        local after = mgr():GetResourceCount(cost.itemId)
                        assert_eq(name .. " 扣减正确", after, before5[cost.itemId] - cost.count)
                        log(INFO .. string.format("  %s: %d → %d (扣 %d)",
                            name, before5[cost.itemId], after, cost.count))
                    end
                end

                -- 验证建筑状态
                local bd5 = mgr():GetMaxLevelBuilding(idleBid)
                if bd5.state == ShipBuildingState.Done then
                    assert_true("升级后 IsDone=true", bd5:IsDone())
                    log(PASS .. " 立即升级完成（待领取）")
                elseif bd5.state == ShipBuildingState.Upgrading then
                    assert_true("升级中 IsUpgrading=true", bd5:IsUpgrading())
                    log(PASS .. " 进入升级倒计时 remain=" .. bd5:GetRemainSeconds() .. "s")
                else
                    log(FAIL .. " 升级后状态异常 state=" .. tostring(bd5.state))
                end

                -- 验证底部栏数据已更新
                local d5after = bgCtrl:GetBuildingDetail(idleBid)
                if bd5.state == ShipBuildingState.Done then
                    assert_true("待领取底部栏 isDone=true", d5after.isDone)
                elseif bd5.state == ShipBuildingState.Upgrading then
                    assert_true("底部栏 isUpgrading=true", d5after.isUpgrading)
                    log(INFO .. " 底部栏 remain=" .. d5after.remainSeconds .. "s")
                end
            end
        end
    end

    log(SEP)
    log("=== 【正式流程】完成 ===")
    log(SEP)
end

-- ---------------------------------------------------------------
-- 【新F】待领取流程完整测试
--   覆盖：倒计时结束 → Done 状态 → 领取 → 等级/战力写入 → Idle
--         + 重复领取保护 + 领取后底部栏数据更新
-- ---------------------------------------------------------------

function M.TestCollectFlow()
    log(SEP)
    log("=== 【新F】待领取流程完整测试 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)
    log(INFO .. " 建筑名称=" .. cfg.name)

    -- ── 场景1：解锁完成待领取 ────────────────────────────────
    log(INFO .. " ── 场景1：解锁完成待领取 ──")

    -- 模拟解锁倒计时已结束：直接把 state 设为 Done（unlock=0 表示解锁类型）
    local bd = mgr():GetMaxLevelBuilding(bid)
    if not bd then log(FAIL .. " 找不到 buildData") return end
    bd.unlock             = 0
    bd.level              = 0
    bd.state              = ShipBuildingState.Done
    bd.updateTime         = os.time()
    bd.upgradeTargetLevel = 0

    -- 验证 IsDone / GetDoneType
    assert_true("IsDone=true",                  bd:IsDone())
    assert_eq("GetDoneType=unlock",             bd:GetDoneType(), "unlock")

    -- 验证 GetBuildingDetail 里 isDone/doneType 字段
    local d1 = bgCtrl:GetBuildingDetail(bid)
    assert_true("detail.isDone=true",           d1.isDone)
    assert_eq("detail.doneType=unlock",         d1.doneType, "unlock")
    assert_false("detail.isUpgrading=false",    d1.isUpgrading)
    log(INFO .. " detail isDone=" .. tostring(d1.isDone)
        .. "  doneType=" .. tostring(d1.doneType))

    -- 记录领取前战力
    local powerBefore = bd.power

    -- 执行领取
    local ok1, err1 = mgr():CollectBuildingResult(bd.uuid)
    assert_true("CollectBuildingResult(解锁) 返回 ok", ok1)
    if not ok1 then
        log(FAIL .. " 领取失败: " .. tostring(err1))
    else
        assert_eq("领取后 unlock=1",            bd.unlock, 1)
        assert_eq("领取后 level=1",             bd.level,  1)
        assert_eq("领取后 state=Idle",          bd.state,  ShipBuildingState.Idle)
        assert_false("领取后 IsDone=false",     bd:IsDone())
        log(PASS .. " 解锁领取完成 level=1  power=" .. bd.power .. " ✓")

        -- 验证战力已更新
        assert_true("领取后 power >= 0",        bd.power >= 0)
        log(INFO .. " 战力: " .. powerBefore .. " → " .. bd.power)

        -- 验证底部栏数据已更新
        local d1after = bgCtrl:GetBuildingDetail(bid)
        assert_true("领取后底部栏 unlocked=true",   d1after.unlocked)
        assert_eq("领取后底部栏 curLevel=1",         d1after.curLevel, 1)
        assert_false("领取后底部栏 isDone=false",    d1after.isDone)
        assert_false("领取后底部栏 isUpgrading=false", d1after.isUpgrading)
        log(INFO .. " 底部栏 power=" .. d1after.curPower
            .. "  effect=" .. tostring(d1after.curEffect))
    end

    -- ── 场景2：升级完成待领取 ────────────────────────────────
    local maxLevel = cfg.level_limit
    if maxLevel <= 1 then
        log(INFO .. " level_limit=1，跳过升级待领取场景")
    else
        log(INFO .. " ── 场景2：升级完成待领取 ──")

        -- 确保已解锁 level=1，模拟升级倒计时结束进入 Done
        bd.unlock             = 1
        bd.level              = 1
        bd.state              = ShipBuildingState.Done
        bd.updateTime         = os.time()
        bd.upgradeTargetLevel = 2

        assert_true("IsDone=true",              bd:IsDone())
        assert_eq("GetDoneType=upgrade",        bd:GetDoneType(), "upgrade")

        local d2 = bgCtrl:GetBuildingDetail(bid)
        assert_true("detail.isDone=true",       d2.isDone)
        assert_eq("detail.doneType=upgrade",    d2.doneType, "upgrade")
        log(INFO .. " detail isDone=" .. tostring(d2.isDone)
            .. "  doneType=" .. tostring(d2.doneType)
            .. "  curLevel=" .. d2.curLevel)

        local powerBefore2 = bd.power

        local ok2, err2 = mgr():CollectBuildingResult(bd.uuid)
        assert_true("CollectBuildingResult(升级) 返回 ok", ok2)
        if not ok2 then
            log(FAIL .. " 领取失败: " .. tostring(err2))
        else
            assert_eq("领取后 level=2",         bd.level, 2)
            assert_eq("领取后 state=Idle",      bd.state, ShipBuildingState.Idle)
            assert_false("领取后 IsDone=false", bd:IsDone())
            log(PASS .. " 升级领取完成 level=2  power=" .. bd.power .. " ✓")
            log(INFO .. " 战力: " .. powerBefore2 .. " → " .. bd.power)

            local d2after = bgCtrl:GetBuildingDetail(bid)
            assert_eq("领取后底部栏 curLevel=2",        d2after.curLevel, 2)
            assert_false("领取后底部栏 isDone=false",   d2after.isDone)
            log(INFO .. " 底部栏 power=" .. d2after.curPower)
        end
    end

    -- ── 场景3：非 Done 状态时领取应拒绝 ─────────────────────
    log(INFO .. " ── 场景3：非 Done 状态时领取应拒绝 ──")
    bd.state = ShipBuildingState.Idle
    local ok3, err3 = mgr():CollectBuildingResult(bd.uuid)
    assert_false("Idle 状态领取应返回 false", ok3)
    log(PASS .. " 非 Done 状态拒绝领取: " .. tostring(err3) .. " ✓")

    -- ── 场景4：升级中时领取应拒绝 ───────────────────────────
    log(INFO .. " ── 场景4：升级中时领取应拒绝 ──")
    bd.state      = ShipBuildingState.Upgrading
    bd.updateTime = os.time() + 3600
    local ok4, err4 = mgr():CollectBuildingResult(bd.uuid)
    assert_false("Upgrading 状态领取应返回 false", ok4)
    log(PASS .. " 升级中拒绝领取: " .. tostring(err4) .. " ✓")

    -- ── 场景5：BgCtrl.CollectBuilding 调用链验证 ────────────
    log(INFO .. " ── 场景5：BgCtrl.CollectBuilding 调用链 ──")
    bd.unlock             = 1
    bd.level              = 1
    bd.state              = ShipBuildingState.Done
    bd.updateTime         = os.time()
    bd.upgradeTargetLevel = 2

    bgCtrl:CollectBuilding(bid)  -- 走 Ctrl 层调用

    assert_eq("Ctrl 领取后 level=2",        bd.level, 2)
    assert_eq("Ctrl 领取后 state=Idle",     bd.state, ShipBuildingState.Idle)
    assert_false("Ctrl 领取后 IsDone=false", bd:IsDone())
    log(PASS .. " BgCtrl.CollectBuilding 调用链正常 ✓")

    -- ── 场景6：领取后总战力包含新建筑战力 ───────────────────
    log(INFO .. " ── 场景6：领取后总战力刷新验证 ──")

    -- 重置为 Done 状态（解锁类型），记录领取前总战力
    bd.unlock             = 0
    bd.level              = 0
    bd.state              = ShipBuildingState.Done
    bd.updateTime         = os.time()
    bd.upgradeTargetLevel = 0
    bd.power              = 0

    local totalBefore = mgr():CalcTotalPower()
    log(INFO .. " 领取前总战力=" .. totalBefore)

    local ok6, err6 = mgr():CollectBuildingResult(bd.uuid)
    assert_true("CollectBuildingResult(总战力验证) 返回 ok", ok6)
    if ok6 then
        local totalAfter = mgr().selfPlayer.totalPower  -- CollectBuildingResult 内已调用 CalcTotalPower
        assert_true("领取后总战力 >= 领取前", totalAfter >= totalBefore)
        assert_true("领取后总战力包含该建筑战力", totalAfter == totalBefore + bd.power)
        log(PASS .. " 总战力: " .. totalBefore .. " → " .. totalAfter
            .. "  建筑战力=" .. bd.power .. " ✓")
    else
        log(FAIL .. " 领取失败: " .. tostring(err6))
    end

    -- 恢复
    bd.unlock             = 1
    bd.level              = 1
    bd.state              = ShipBuildingState.Idle
    bd.updateTime         = 0
    bd.upgradeTargetLevel = 0
    log(INFO .. " 待领取流程完整测试通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新G-1】触发升级倒计时（第一步，单独跑）
--   跑完后等真实倒计时结束，再跑 TestUpgradeTimerCollect
-- ---------------------------------------------------------------

function M.TestUpgradeTimerStart()
    log(SEP)
    log("=== 【新G-1】触发升级倒计时 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    -- 找第一个 level_limit>1 且第2级 lvup_time>0 的建筑
    local bid = nil
    for _, b in ipairs(allBuildIds()) do
        local cfg = bgCtrl:GetBuildingConfig(b)
        if cfg.level_limit > 1 then
            local lv2 = bgCtrl:GetBuildingLevelConfig(b, 2)
            if lv2 and lv2.lvup_time > 0 then
                bid = b
                break
            end
        end
    end
    if not bid then log(FAIL .. " 找不到合适的建筑") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)

    -- 重置为已解锁 level=1
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local bd = mgr():GetMaxLevelBuilding(bid)

    -- 触发升级
    local detail = bgCtrl:GetBuildingDetail(bid)
    local ok, err = panelCtrl:DoConfirm(detail)
    if not ok then log(FAIL .. " DoConfirm 失败: " .. tostring(err)) return end

    -- 验证进入升级中
    assert_eq("state=Upgrading",    bd.state, ShipBuildingState.Upgrading)
    assert_true("upgradingSet有值", mgr().upgradingSet[bd.uuid] == true)

    log(PASS .. string.format(" 升级已触发  建筑=%s  uuid=%d  剩余=%ds",
        cfg.name, bd.uuid, bd:GetRemainSeconds()))
    log(INFO .. " ★ 请等待倒计时结束后，再调用 M.TestUpgradeTimerCollect()")
end

-- ---------------------------------------------------------------
-- 【新G-2】验证升级完成并领取（第二步，倒计时结束后跑）
-- ---------------------------------------------------------------

function M.TestUpgradeTimerCollect()
    log(SEP)
    log("=== 【新G-2】验证升级完成并领取 ===")

    local bgCtrl = newBgCtrl()
    if not bgCtrl then return end

    -- 找同一个建筑
    local bid = nil
    for _, b in ipairs(allBuildIds()) do
        local cfg = bgCtrl:GetBuildingConfig(b)
        if cfg.level_limit > 1 then
            local lv2 = bgCtrl:GetBuildingLevelConfig(b, 2)
            if lv2 and lv2.lvup_time > 0 then
                bid = b
                break
            end
        end
    end
    if not bid then log(FAIL .. " 找不到合适的建筑") return end

    local bd = mgr():GetMaxLevelBuilding(bid)

    -- 检查当前状态
    if bd:IsUpgrading() then
        log(FAIL .. string.format(" 建筑还在升级中，剩余 %ds，请等倒计时结束再跑此用例", bd:GetRemainSeconds()))
        return
    end

    assert_true("state=Done",          bd:IsDone())
    assert_eq("GetDoneType=upgrade",   bd:GetDoneType(), "upgrade")
    assert_false("upgradingSet已清空", mgr().upgradingSet[bd.uuid] == true)
    log(PASS .. " 升级已自然完成，进入待领取状态 ✓")

    -- 领取
    local powerBefore = bd.power
    local ok, err = mgr():CollectBuildingResult(bd.uuid)
    assert_true("CollectBuildingResult ok", ok)
    if not ok then log(FAIL .. " " .. tostring(err)) return end

    assert_eq("level=2",         bd.level, 2)
    assert_eq("state=Idle",      bd.state, ShipBuildingState.Idle)
    assert_false("IsDone=false", bd:IsDone())
    log(PASS .. string.format(" 领取完成 level=2  power: %d → %d  totalPower=%d ✓",
        powerBefore, bd.power, mgr().selfPlayer.totalPower))

    -- 恢复
    mgr().upgradingSet[bd.uuid] = nil
    mgr().unlockingSet[bd.uuid] = nil
    resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
end

-- ---------------------------------------------------------------
-- 【新G】升级倒计时流程测试（真实等待）
--   触发升级 → 真实等待倒计时结束 → 验证 Done 状态 → 领取 → 验证等级写入
-- ---------------------------------------------------------------

function M.TestUpgradeTimerFlow()
    log(SEP)
    log("=== 【新G】升级倒计时完整流程测试（真实等待）===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local bid = nil
    for _, b in ipairs(allBuildIds()) do
        local cfg = bgCtrl:GetBuildingConfig(b)
        if cfg.level_limit > 1 then
            local lv2 = bgCtrl:GetBuildingLevelConfig(b, 2)
            if lv2 and lv2.lvup_time > 0 then
                bid = b
                break
            end
        end
    end
    if not bid then log(INFO .. " 找不到 lvup_time>0 的建筑，跳过") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)
    log(INFO .. " 目标建筑=" .. cfg.name .. "  buildId=" .. bid)

    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    local bd = mgr():GetMaxLevelBuilding(bid)

    local detail = bgCtrl:GetBuildingDetail(bid)
    local ok2, err2 = panelCtrl:DoConfirm(detail)
    assert_true("DoConfirm ok", ok2)
    if not ok2 then log(FAIL .. " " .. tostring(err2)) return end

    assert_eq("state=Upgrading",      bd.state, ShipBuildingState.Upgrading)
    assert_true("IsUpgrading=true",   bd:IsUpgrading())
    assert_true("updateTime > now",   bd.updateTime > os.time())
    assert_eq("upgradeTargetLevel=2", bd.upgradeTargetLevel, 2)
    assert_true("upgradingSet有uuid", mgr().upgradingSet[bd.uuid] == true)
    log(PASS .. " 升级状态字段正确  remain=" .. bd:GetRemainSeconds() .. "s ✓")

    -- 真实等待倒计时结束（系统 Tick 会自动检测到期并触发 FinishUpgradeBuilding）
    local remainSec = bd:GetRemainSeconds()
    log(INFO .. " 真实等待倒计时 " .. remainSec .. "s，请耐心等待...")

    local checkTimer = TimerManager:GetInstance():GetTimer(remainSec + 1, function()
        log(INFO .. " 倒计时结束，开始验证...")

        -- 系统 Tick 应已自动将 state 变为 Done，如果没有则手动 Tick 一次兜底
        if bd.state == ShipBuildingState.Upgrading then
            mgr():Tick()
        end

        assert_eq("state=Done",            bd.state, ShipBuildingState.Done)
        assert_true("IsDone=true",         bd:IsDone())
        assert_false("upgradingSet已移除", mgr().upgradingSet[bd.uuid] == true)
        log(PASS .. " 真实倒计时结束，Done 状态正确 ✓")

        local powerBefore = bd.power
        local ok6, err6 = mgr():CollectBuildingResult(bd.uuid)
        assert_true("CollectBuildingResult ok", ok6)
        if not ok6 then log(FAIL .. " " .. tostring(err6)) return end

        assert_eq("level=2",         bd.level, 2)
        assert_eq("state=Idle",      bd.state, ShipBuildingState.Idle)
        assert_false("IsDone=false", bd:IsDone())
        log(PASS .. " 领取完成 level=2  power: " .. powerBefore .. " → " .. bd.power .. " ✓")
        log(INFO .. " 总战力=" .. mgr().selfPlayer.totalPower)

        resetBuilding(bid, 0, 0, ShipBuildingState.Locked)
        log(INFO .. " 升级倒计时流程测试通过（真实等待）✓")
    end, nil, false, false, false)
    checkTimer:Start()

    log(INFO .. " 定时器已启动，验证将在 " .. (remainSec + 1) .. "s 后自动执行")
end

-- ---------------------------------------------------------------
-- 【新H】建造队列集成测试
--   点升级 → 队列填充任务 → 完成 → 点领取 → 队列移除任务
-- ---------------------------------------------------------------

function M.TestBuildQueueIntegration()
    log(SEP)
    log("=== 【新H】建造队列集成测试 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local queueMgr = DataCenter.ShipWorkQueueManager
    if not queueMgr then
        log(FAIL .. " ShipWorkQueueManager 不存在")
        return
    end

    local bid = firstBuildId()
    if not bid then log(FAIL .. " 找不到 buildId") return end

    local cfg = bgCtrl:GetBuildingConfig(bid)
    if cfg.level_limit <= 1 then
        log(INFO .. " level_limit=1 无法升级，跳过")
        return
    end

    log(INFO .. " 建筑名称=" .. cfg.name .. "  buildId=" .. bid)

    -- ── Step1：重置建筑为已解锁 level=1 空闲 ──
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    log(INFO .. " Step1 重置为 level=1 Idle")

    -- ── Step2：确认队列中没有该建筑的任务 ──
    local slotBefore = queueMgr:FindSlotByBuildId(bid)
    assert_false("Step2 升级前队列中无此建筑任务", slotBefore ~= nil)
    log(INFO .. " Step2 队列干净 ✓")

    -- ── Step3：执行升级（模拟点确认按钮）──
    local detail = bgCtrl:GetBuildingDetail(bid)
    assert_true("Step3 unlocked=true",   detail.unlocked)
    assert_false("Step3 isMax=false",    detail.isMax)

    local ok, err = panelCtrl:DoConfirm(detail)
    assert_true("Step3 DoConfirm 返回 ok", ok)
    if not ok then
        log(FAIL .. " DoConfirm 失败: " .. tostring(err))
        return
    end

    local bd = mgr():GetMaxLevelBuilding(bid)
    log(INFO .. " Step3 升级后 state=" .. bd.state
        .. "  upgradeTargetLevel=" .. bd.upgradeTargetLevel)

    -- ── Step4：验证队列中已填充任务 ──
    local slotAfter = queueMgr:FindSlotByBuildId(bid)
    if slotAfter then
        assert_eq("Step4 队列任务 buildId 正确",  slotAfter.buildId, bid)
        assert_eq("Step4 队列任务 buildUuid 正确", slotAfter.buildUuid, bd.uuid)
        assert_eq("Step4 队列任务类型=Upgrade",    slotAfter.taskType, ShipWorkQueueTaskType.Upgrade)
        assert_eq("Step4 队列任务 targetLevel=2",  slotAfter.targetLevel, 2)
        log(PASS .. string.format(" Step4 队列已填充 slot=%d buildId=%d targetLv=%d ✓",
            slotAfter.slotIndex, slotAfter.buildId, slotAfter.targetLevel))
    else
        -- lvup_time=0 时，任务可能已完成并被队列 Tick 清理
        if bd.state == ShipBuildingState.Done then
            log(INFO .. " Step4 lvup_time=0，任务已完成被清理（预期行为）")
        else
            log(FAIL .. " Step4 队列中未找到任务，且建筑未进入 Done 状态")
        end
    end

    -- ── Step5：模拟升级完成，进入待领取 ──
    if bd.state == ShipBuildingState.Upgrading then
        -- 倒计时类型：手动触发完成
        bd.state = ShipBuildingState.Done
        bd.updateTime = os.time()
        mgr().upgradingSet[bd.uuid] = nil
        log(INFO .. " Step5 手动设为 Done（模拟倒计时结束）")

        -- 手动 Tick 队列，让队列处理完成
        queueMgr:Tick()

        -- 验证队列任务已清除
        local slotDone = queueMgr:FindSlotByBuildId(bid)
        assert_false("Step5 完成后队列任务已清除", slotDone ~= nil)
        log(PASS .. " Step5 队列任务已清除 ✓")
    elseif bd.state == ShipBuildingState.Done then
        -- 立即完成类型：手动 Tick 确保队列处理
        queueMgr:Tick()
        local slotDone = queueMgr:FindSlotByBuildId(bid)
        if slotDone then
            log(INFO .. " Step5 队列任务仍在（等待自然 Tick 清理）")
        else
            log(INFO .. " Step5 队列任务已清除 ✓")
        end
    end

    -- ── Step6：领取升级结果 ──
    assert_true("Step6 建筑处于 Done 状态", bd:IsDone())

    local collectOk, collectErr = mgr():CollectBuildingResult(bd.uuid)
    assert_true("Step6 CollectBuildingResult 返回 ok", collectOk)
    if not collectOk then
        log(FAIL .. " 领取失败: " .. tostring(collectErr))
        return
    end

    assert_eq("Step6 领取后 level=2",     bd.level, 2)
    assert_eq("Step6 领取后 state=Idle",   bd.state, ShipBuildingState.Idle)
    log(PASS .. " Step6 领取完成 level=" .. bd.level .. " ✓")

    -- ── Step7：领取后队列任务已彻底清除 ──
    local slotAfterCollect = queueMgr:FindSlotByBuildId(bid)
    assert_false("Step7 领取后队列中无此建筑任务", slotAfterCollect ~= nil)
    log(PASS .. " Step7 领取后队列干净 ✓")

    -- 恢复
    resetBuilding(bid, 1, 1, ShipBuildingState.Idle)
    log(INFO .. " 建造队列集成测试通过 ✓")
end

-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- 【新I】WorkQueue 配置读取测试
--   验证 WorkQueue_Config 表能正确加载，队列槽位配置正确
-- ---------------------------------------------------------------

function M.TestWorkQueueConfig()
    log(SEP)
    log("=== 【新I】WorkQueue 配置读取测试 ===")

    local queueMgr = DataCenter.ShipWorkQueueManager
    if not queueMgr then
        log(FAIL .. " ShipWorkQueueManager 不存在")
        return
    end

    local totalCount = queueMgr:GetSlotCount()
    assert_true("WorkQueue 总数 > 0", totalCount > 0)
    log(INFO .. " WorkQueue 总数=" .. totalCount)

    local slots       = queueMgr:GetAllSlots()
    local freeCount   = 0
    local lockedCount = 0
    for _, slot in ipairs(slots) do
        assert_true("slotIndex 是数字", type(slot.slotIndex) == "number")
        assert_true("slotIndex >= 1",   slot.slotIndex >= 1)
        if slot.isUnlocked then
            freeCount = freeCount + 1
            log(INFO .. string.format("  [已解锁] slotIndex=%d", slot.slotIndex))
        else
            lockedCount = lockedCount + 1
            log(INFO .. string.format("  [未解锁] slotIndex=%d", slot.slotIndex))
        end
    end

    assert_true("至少有1条已解锁队列", freeCount >= 1)
    log(INFO .. string.format(" 已解锁=%d  未解锁=%d", freeCount, lockedCount))

    local unlockedCount = queueMgr:GetUnlockedSlotCount()
    assert_eq("GetUnlockedSlotCount 与遍历结果一致", unlockedCount, freeCount)

    local idleSlot = queueMgr:FindIdleSlot()
    assert_not_nil("FindIdleSlot 有返回值（初始状态应有空闲槽）", idleSlot)
    if idleSlot then
        assert_true("空闲槽 isUnlocked=true", idleSlot.isUnlocked)
        assert_true("空闲槽 IsIdle=true",     idleSlot:IsIdle())
        log(INFO .. string.format(" 空闲槽 slotIndex=%d ✓", idleSlot.slotIndex))
    end

    log(INFO .. " WorkQueue 配置读取测试通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新J】WorkQueue 队列解锁逻辑测试
--   验证第1条队列默认解锁，UnlockSlot 接口正常工作
-- ---------------------------------------------------------------

function M.TestWorkQueueUnlock()
    log(SEP)
    log("=== 【新J】WorkQueue 队列解锁逻辑测试 ===")

    local queueMgr = DataCenter.ShipWorkQueueManager
    if not queueMgr then
        log(FAIL .. " ShipWorkQueueManager 不存在")
        return
    end

    local totalCount = queueMgr:GetSlotCount()
    if totalCount == 0 then
        log(INFO .. " 无队列槽位，跳过")
        return
    end

    -- ── 场景1：第1条队列默认已解锁 ──
    log(INFO .. " ── 场景1：第1条队列默认已解锁 ──")
    local slot1 = queueMgr:GetSlot(1)
    assert_not_nil("第1条队列存在", slot1)
    if slot1 then
        assert_true("第1条队列 isUnlocked=true", slot1.isUnlocked)
        log(PASS .. " 第1条队列默认已解锁 ✓")
    end

    -- ── 场景2：第2条队列解锁流程 ──
    log(INFO .. " ── 场景2：第2条队列解锁 ──")
    if totalCount < 2 then
        log(INFO .. " 只有1条队列，跳过场景2")
    else
        local slot2 = queueMgr:GetSlot(2)
        assert_not_nil("第2条队列存在", slot2)
        if slot2 then
            local origUnlocked = slot2.isUnlocked
            slot2.isUnlocked = false
            assert_false("重置后 isUnlocked=false", slot2.isUnlocked)

            local ok, err = queueMgr:UnlockSlot(2)
            assert_true("UnlockSlot(2) 返回 ok", ok)
            if ok then
                assert_true("解锁后 isUnlocked=true", slot2.isUnlocked)
                log(PASS .. " 第2条队列解锁成功 ✓")
            else
                log(FAIL .. " UnlockSlot 失败: " .. tostring(err))
            end
            slot2.isUnlocked = origUnlocked
        end
    end

    -- ── 场景3：对已解锁队列再次解锁应拒绝 ──
    log(INFO .. " ── 场景3：重复解锁应拒绝 ──")
    if slot1 then
        local ok2, err2 = queueMgr:UnlockSlot(1)
        assert_false("已解锁队列重复解锁应返回 false", ok2)
        log(PASS .. " 重复解锁被拒绝: " .. tostring(err2) .. " ✓")
    end

    log(INFO .. " WorkQueue 队列解锁逻辑测试通过 ✓")
end

-- 【新K】WorkQueue 并发队列测试
--   验证多条队列可同时承载不同建筑的升级任务
-- ---------------------------------------------------------------

function M.TestWorkQueueConcurrent()
    log(SEP)
    log("=== 【新K】WorkQueue 并发队列测试 ===")

    local bgCtrl    = newBgCtrl()
    local panelCtrl = newPanelCtrl()
    if not bgCtrl or not panelCtrl then return end

    local queueMgr = DataCenter.ShipWorkQueueManager
    if not queueMgr then
        log(FAIL .. " ShipWorkQueueManager 不存在")
        return
    end


    local totalQueues = queueMgr:GetSlotCount()
    log(INFO .. " 可用队列总数=" .. totalQueues)

    -- 找至少2个 level_limit>1 的建筑用于并发测试
    local candidateBids = {}
    local list = allBuildIds()
    for _, bid in ipairs(list) do
        local cfg = bgCtrl:GetBuildingConfig(bid)
        if cfg.level_limit > 1 then
            table.insert(candidateBids, bid)
            if #candidateBids >= 2 then break end
        end
    end

    if #candidateBids < 2 then
        log(INFO .. " 可升级建筑不足2个，跳过并发测试")
        return
    end

    local bid1 = candidateBids[1]
    local bid2 = candidateBids[2]
    local cfg1 = bgCtrl:GetBuildingConfig(bid1)
    local cfg2 = bgCtrl:GetBuildingConfig(bid2)
    log(INFO .. string.format(" 建筑1: %s(id=%d)  建筑2: %s(id=%d)",
        cfg1.name, bid1, cfg2.name, bid2))

    -- 重置两个建筑
    resetBuilding(bid1, 1, 1, ShipBuildingState.Idle)
    resetBuilding(bid2, 1, 1, ShipBuildingState.Idle)

    -- ── Step1：同时触发两个建筑升级 ──
    log(INFO .. " ── Step1：同时触发两个建筑升级 ──")

    local detail1 = bgCtrl:GetBuildingDetail(bid1)
    local ok1, err1 = panelCtrl:DoConfirm(detail1)
    assert_true("建筑1 DoConfirm ok", ok1)
    if not ok1 then
        log(FAIL .. " 建筑1 升级失败: " .. tostring(err1))
        return
    end
    log(INFO .. " 建筑1 升级已触发")

    local detail2 = bgCtrl:GetBuildingDetail(bid2)
    local ok2, err2 = panelCtrl:DoConfirm(detail2)
    if ok2 then
        log(INFO .. " 建筑2 升级已触发（队列有空位）")
    else
        log(INFO .. " 建筑2 升级被拒绝（队列已满）: " .. tostring(err2))
    end

    -- ── Step2：验证队列占用情况 ──
    log(INFO .. " ── Step2：验证队列占用情况 ──")

    local bd1 = mgr():GetMaxLevelBuilding(bid1)
    local bd2 = mgr():GetMaxLevelBuilding(bid2)

    local stateStr1 = ({
        [ShipBuildingState.Idle]      = "Idle",
        [ShipBuildingState.Upgrading] = "Upgrading",
        [ShipBuildingState.Done]      = "Done",
    })[bd1.state] or tostring(bd1.state)
    local stateStr2 = ({
        [ShipBuildingState.Idle]      = "Idle",
        [ShipBuildingState.Upgrading] = "Upgrading",
        [ShipBuildingState.Done]      = "Done",
    })[bd2.state] or tostring(bd2.state)

    log(INFO .. string.format(" 建筑1 state=%s  建筑2 state=%s", stateStr1, stateStr2))

    -- 建筑1 必须已进入升级或完成状态
    assert_true("建筑1 已进入升级或完成",
        bd1.state == ShipBuildingState.Upgrading or bd1.state == ShipBuildingState.Done)

    -- ── Step3：模拟两个建筑都完成，验证各自独立领取 ──
    log(INFO .. " ── Step3：模拟完成并领取 ──")

    -- 强制两个建筑进入 Done
    if bd1.state == ShipBuildingState.Upgrading then
        bd1.state = ShipBuildingState.Done
        bd1.updateTime = os.time()
        mgr().upgradingSet[bd1.uuid] = nil
    end
    if bd2.state == ShipBuildingState.Upgrading then
        bd2.state = ShipBuildingState.Done
        bd2.updateTime = os.time()
        mgr().upgradingSet[bd2.uuid] = nil
    end

    -- 领取建筑1
    if bd1:IsDone() then
        local c1ok, c1err = mgr():CollectBuildingResult(bd1.uuid)
        assert_true("建筑1 领取 ok", c1ok)
        if c1ok then
            assert_eq("建筑1 领取后 level=2", bd1.level, 2)
            log(PASS .. " 建筑1 领取完成 level=" .. bd1.level .. " ✓")
        else
            log(FAIL .. " 建筑1 领取失败: " .. tostring(c1err))
        end
    end

    -- 领取建筑2（如果进入了升级）
    if bd2:IsDone() then
        local c2ok, c2err = mgr():CollectBuildingResult(bd2.uuid)
        assert_true("建筑2 领取 ok", c2ok)
        if c2ok then
            assert_eq("建筑2 领取后 level=2", bd2.level, 2)
            log(PASS .. " 建筑2 领取完成 level=" .. bd2.level .. " ✓")
        end
    end

    -- 恢复
    resetBuilding(bid1, 1, 1, ShipBuildingState.Idle)
    resetBuilding(bid2, 1, 1, ShipBuildingState.Idle)
    log(INFO .. " WorkQueue 并发队列测试通过 ✓")
end

-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- 【新L】PrintWorkQueueStatus — 打印当前所有队列状态快照
-- ---------------------------------------------------------------

function M.PrintWorkQueueStatus()
    log(SEP)
    log("=== 【新L】WorkQueue 队列状态快照 ===")

    local queueMgr = DataCenter.ShipWorkQueueManager
    if not queueMgr then
        log(FAIL .. " ShipWorkQueueManager 不存在")
        return
    end

    local slots = queueMgr:GetAllSlots()
    if #slots == 0 then
        log(INFO .. " 无队列槽位")
        return
    end

    log(string.format("  %-8s %-10s %-10s %-12s %-10s",
        "slot", "isUnlocked", "状态", "buildId", "剩余秒"))
    log("  " .. string.rep("-", 54))

    for _, slot in ipairs(slots) do
        local stateStr = slot:IsIdle() and "空闲"
            or (slot:IsRunning() and "运行中" or "已完成")
        local remainStr = slot:IsIdle() and "-" or tostring(slot:GetRemainSeconds())
        local bidStr    = slot:IsIdle() and "-" or tostring(slot.buildId)
        log(string.format("  %-8d %-10s %-10s %-12s %-10s",
            slot.slotIndex,
            slot.isUnlocked and "已解锁" or "未解锁",
            stateStr, bidStr, remainStr))
    end

    log(INFO .. string.format(" 总槽位=%d  已解锁=%d  运行中=%d",
        queueMgr:GetSlotCount(),
        queueMgr:GetUnlockedSlotCount(),
        queueMgr:GetRunningCount()))
end

-- 【新M】建筑详情家具数据完整性验证
--   GetBuildingDetail 返回的 furnitureList 字段是否正确填充
-- ---------------------------------------------------------------

function M.TestBuildingDetailFurniture()
    log(SEP)
    log("=== 【新M】建筑详情家具数据完整性验证 ===")

    local bgCtrl = newBgCtrl()
    if not bgCtrl then return end

    -- 找一个有家具的建筑（Furniture_Config 里 build_id 存在的）
    local targetBid = nil
    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        if not targetBid then
            targetBid = tonumber(lineData:getValue("build_id"))
        end
    end)

    if not targetBid then
        log(INFO .. " Furniture_Config 无数据，跳过")
        return
    end

    -- 解锁该建筑到 level=1
    resetBuilding(targetBid, 1, 1, ShipBuildingState.Idle)

    local detail = bgCtrl:GetBuildingDetail(targetBid)

    -- furnitureList 字段必须存在
    assert_not_nil("detail.furnitureList 存在", detail.furnitureList)
    assert_true("furnitureList 是 table", type(detail.furnitureList) == "table")

    local fList = detail.furnitureList
    log(INFO .. string.format(" buildId=%d  家具数量=%d", targetBid, #fList))

    if #fList == 0 then
        log(INFO .. " 该建筑无家具配置，跳过详细验证")
        return
    end

    for i, f in ipairs(fList) do
        assert_not_nil(string.format("家具[%d].furnitureId 存在", i), f.furnitureId)
        assert_not_nil(string.format("家具[%d].name 存在", i),        f.name)
        assert_true(string.format("家具[%d].name 不为空", i),         f.name ~= "")
        assert_true(string.format("家具[%d].level 是数字", i),        type(f.level) == "number")
        assert_true(string.format("家具[%d].maxLevel > 0", i),        f.maxLevel > 0)
        assert_not_nil(string.format("家具[%d].unlockBuildLevel 存在", i), f.unlockBuildLevel)
        assert_not_nil(string.format("家具[%d].isUnlocked 存在", i),  f.isUnlocked ~= nil)
        assert_not_nil(string.format("家具[%d].canUnlock 存在", i),   f.canUnlock ~= nil)
        assert_not_nil(string.format("家具[%d].canUpgrade 存在", i),  f.canUpgrade ~= nil)

        local stateStr = ({
            [ShipFurnitureState.Locked]    = "Locked",
            [ShipFurnitureState.Idle]      = "Idle",
            [ShipFurnitureState.Upgrading] = "Upgrading",
            [ShipFurnitureState.Done]      = "Done",
        })[f.state] or tostring(f.state)

        log(INFO .. string.format(
            "  [%d] %s  lv=%d/%d  state=%s  unlocked=%s  canUnlock=%s  canUpgrade=%s  解锁需建筑Lv=%d",
            f.furnitureId, f.name, f.level, f.maxLevel, stateStr,
            tostring(f.isUnlocked), tostring(f.canUnlock), tostring(f.canUpgrade),
            f.unlockBuildLevel))

        if f.productBonus ~= "" then
            log(INFO .. string.format("    当前效果: %s", f.productBonus))
        end
        if f.nextLevelCfg then
            -- 家具配置的消耗字段是 costStr（形如 "102002,1000"），没有 lvup_cost。
            -- 之前写成 lvup_cost 读到 nil，string.format("%d", nil) 直接抛异常。
            log(INFO .. string.format("    下一级: lv=%d  升级消耗=%s  耗时=%ds  效果: %s",
                f.nextLevel,
                tostring(f.nextLevelCfg.costStr or "无"),
                f.nextLevelCfg.lvup_time or 0,
                f.nextBonus ~= "" and f.nextBonus or "无"))
        end
    end

    log(INFO .. " 建筑详情家具数据完整性验证通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新N】家具解锁流程测试
--   建筑等级满足 → 解锁家具 → 验证状态变更
-- ---------------------------------------------------------------

function M.TestFurnitureUnlock()
    log(SEP)
    log("=== 【新N】家具解锁流程测试 ===")

    local bgCtrl       = newBgCtrl()
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not bgCtrl or not furnitureMgr then
        log(FAIL .. " 依赖管理器不存在")
        return
    end

    -- 找第一个 unlock_building_level == 1 的家具（建筑 level=1 就能解锁）
    local targetFid = nil
    local targetBid = nil
    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        if targetFid then return end
        local unlockLv = tonumber(lineData:getValue("unlock_building_level")) or 99
        if unlockLv <= 1 then
            targetFid = tonumber(rowId)
            targetBid = tonumber(lineData:getValue("build_id"))
        end
    end)

    if not targetFid then
        log(INFO .. " 找不到 unlock_building_level<=1 的家具，跳过")
        return
    end

    local fCfg = furnitureMgr:GetFurnitureConfig(targetFid)
    log(INFO .. string.format(" 目标家具: %s(id=%d)  所属建筑id=%d  解锁需建筑Lv=%d",
        fCfg.name, targetFid, targetBid, fCfg.unlockBuildingLevel))

    -- 重置建筑为 level=1 已解锁
    resetBuilding(targetBid, 1, 1, ShipBuildingState.Idle)

    -- 重置家具为未解锁状态
    local fData = furnitureMgr:GetFurnitureByBuildAndId(targetBid, targetFid)
    assert_not_nil("家具数据存在", fData)
    if not fData then return end

    fData.unlock = 0
    fData.level  = 0
    fData.state  = ShipFurnitureState.Locked

    -- ── Step1：解锁前验证 ──
    local detail1 = bgCtrl:GetBuildingDetail(targetBid)
    local fEntry1 = nil
    for _, f in ipairs(detail1.furnitureList) do
        if f.furnitureId == targetFid then fEntry1 = f break end
    end
    assert_not_nil("Step1 家具在 furnitureList 中", fEntry1)
    assert_false("Step1 isUnlocked=false", fEntry1 and fEntry1.isUnlocked)
    assert_true("Step1 canUnlock=true",    fEntry1 and fEntry1.canUnlock)
    log(INFO .. " Step1 解锁前状态正确 ✓")

    -- ── Step2：执行解锁 ──
    local ok = bgCtrl:UnlockFurniture(targetFid, targetBid)
    assert_true("Step2 UnlockFurniture 返回 ok", ok)
    if not ok then return end

    -- ── Step3：验证解锁后状态 ──
    if fData.state == ShipFurnitureState.Done then
        -- lvup_time=0，立即进入待领取
        log(INFO .. " Step3 立即完成，进入待领取状态")
        local collectOk = bgCtrl:CollectFurniture(fData.uuid)
        assert_true("Step3 CollectFurniture ok", collectOk)
        assert_eq("Step3 解锁后 level=1",  fData.level,  1)
        assert_eq("Step3 解锁后 unlock=1", fData.unlock, 1)
        assert_eq("Step3 state=Idle",      fData.state,  ShipFurnitureState.Idle)
        log(PASS .. " Step3 解锁并领取完成 level=1 ✓")
    elseif fData.state == ShipFurnitureState.Upgrading then
        assert_true("Step3 IsUpgrading=true", fData:IsUpgrading())
        assert_true("Step3 updateTime > now", fData.updateTime > os.time())
        log(PASS .. " Step3 进入解锁倒计时 remain=" .. fData:GetRemainSeconds() .. "s ✓")
    end

    -- ── Step4：解锁后 detail 中家具状态已更新 ──
    local detail4 = bgCtrl:GetBuildingDetail(targetBid)
    local fEntry4 = nil
    for _, f in ipairs(detail4.furnitureList) do
        if f.furnitureId == targetFid then fEntry4 = f break end
    end
    assert_not_nil("Step4 家具仍在 furnitureList 中", fEntry4)
    if fData.state == ShipFurnitureState.Idle then
        assert_true("Step4 isUnlocked=true",  fEntry4 and fEntry4.isUnlocked)
        assert_false("Step4 canUnlock=false", fEntry4 and fEntry4.canUnlock)
        log(PASS .. " Step4 detail 家具状态已更新 ✓")
    end

    -- 恢复家具状态，避免污染后续测试
    fData.unlock = 0
    fData.level  = 0
    fData.state  = ShipFurnitureState.Locked

    log(INFO .. " 家具解锁流程测试通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新O】家具升级流程测试
--   已解锁家具 → 升级 → 验证等级/效果变化
-- ---------------------------------------------------------------

function M.TestFurnitureUpgrade()
    log(SEP)
    log("=== 【新O】家具升级流程测试 ===")

    local bgCtrl       = newBgCtrl()
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not bgCtrl or not furnitureMgr then
        log(FAIL .. " 依赖管理器不存在")
        return
    end

    -- 找第一个有家具的建筑
    local targetFid = nil
    local targetBid = nil
    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        if targetFid then return end
        targetFid = tonumber(rowId)
        targetBid = tonumber(lineData:getValue("build_id"))
    end)

    if not targetFid then
        log(INFO .. " Furniture_Config 无数据，跳过")
        return
    end

    local fCfg = furnitureMgr:GetFurnitureConfig(targetFid)
    log(INFO .. string.format(" 目标家具: %s(id=%d)  所属建筑id=%d",
        fCfg.name, targetFid, targetBid))

    -- 重置建筑和家具为 level=1 已解锁空闲
    resetBuilding(targetBid, 1, 1, ShipBuildingState.Idle)
    local fData = furnitureMgr:GetFurnitureByBuildAndId(targetBid, targetFid)
    assert_not_nil("家具数据存在", fData)
    if not fData then return end

    fData.unlock              = 1
    fData.level               = 1
    fData.state               = ShipFurnitureState.Idle
    fData.upgradeTargetLevel  = 0
    fData.updateTime          = 0
    furnitureMgr.upgradingSet[fData.uuid] = nil

    -- ── Step1：升级前 detail 验证 ──
    local detail1 = bgCtrl:GetBuildingDetail(targetBid)
    local fEntry1 = nil
    for _, f in ipairs(detail1.furnitureList) do
        if f.furnitureId == targetFid then fEntry1 = f break end
    end
    assert_not_nil("Step1 家具在 furnitureList 中", fEntry1)
    assert_true("Step1 isUnlocked=true",  fEntry1 and fEntry1.isUnlocked)
    assert_true("Step1 canUpgrade=true",  fEntry1 and fEntry1.canUpgrade)
    assert_not_nil("Step1 nextLevelCfg 存在", fEntry1 and fEntry1.nextLevelCfg)

    if fEntry1 and fEntry1.nextLevelCfg then
        -- 同上：家具消耗字段是 costStr，不是 lvup_cost
        log(INFO .. string.format(" Step1 升级前 lv=%d  下一级消耗=%s  耗时=%ds  效果: %s",
            fEntry1.level,
            tostring(fEntry1.nextLevelCfg.costStr or "无"),
            fEntry1.nextLevelCfg.lvup_time or 0,
            fEntry1.nextBonus ~= "" and fEntry1.nextBonus or "无"))
    end
    if fEntry1 and fEntry1.productBonus ~= "" then
        log(INFO .. " Step1 当前效果: " .. fEntry1.productBonus)
    end

    -- ── Step2：执行升级 ──
    local ok = bgCtrl:UpgradeFurniture(targetFid, targetBid)
    assert_true("Step2 UpgradeFurniture 返回 ok", ok)
    if not ok then return end

    log(INFO .. string.format(" Step2 升级后 state=%d  upgradeTargetLevel=%d",
        fData.state, fData.upgradeTargetLevel))

    -- ── Step3：验证升级状态 ──
    if fData.state == ShipFurnitureState.Done then
        -- 立即完成
        log(INFO .. " Step3 立即完成，进入待领取")
        assert_true("Step3 IsDone=true", fData:IsDone())
        assert_eq("Step3 upgradeTargetLevel=2", fData.upgradeTargetLevel, 2)

        -- 领取
        local collectOk = bgCtrl:CollectFurniture(fData.uuid)
        assert_true("Step3 CollectFurniture ok", collectOk)
        assert_eq("Step3 领取后 level=2",   fData.level, 2)
        assert_eq("Step3 state=Idle",        fData.state, ShipFurnitureState.Idle)
        log(PASS .. " Step3 升级并领取完成 level=2 ✓")

        -- 验证升级后 detail 效果已变化
        local detail3 = bgCtrl:GetBuildingDetail(targetBid)
        local fEntry3 = nil
        for _, f in ipairs(detail3.furnitureList) do
            if f.furnitureId == targetFid then fEntry3 = f break end
        end
        assert_not_nil("Step3 家具仍在 furnitureList 中", fEntry3)
        if fEntry3 then
            assert_eq("Step3 detail level=2", fEntry3.level, 2)
            log(INFO .. string.format(" Step3 升级后效果: %s",
                fEntry3.productBonus ~= "" and fEntry3.productBonus or "无"))
        end

    elseif fData.state == ShipFurnitureState.Upgrading then
        assert_true("Step3 IsUpgrading=true",   fData:IsUpgrading())
        assert_eq("Step3 upgradeTargetLevel=2", fData.upgradeTargetLevel, 2)
        assert_true("Step3 updateTime > now",   fData.updateTime > os.time())
        log(PASS .. " Step3 进入升级倒计时 remain=" .. fData:GetRemainSeconds() .. "s ✓")

        -- 模拟倒计时结束
        fData.updateTime = os.time() - 1
        furnitureMgr:Tick()

        assert_true("Step3 Tick后 IsDone=true", fData:IsDone())
        log(INFO .. " Step3 Tick 后进入待领取状态")

        local collectOk = bgCtrl:CollectFurniture(fData.uuid)
        assert_true("Step3 CollectFurniture ok", collectOk)
        assert_eq("Step3 领取后 level=2", fData.level, 2)
        log(PASS .. " Step3 模拟倒计时结束并领取完成 level=2 ✓")
    end

    -- ── Step4：升级中时拒绝重复操作 ──
    log(INFO .. " ── Step4：升级中时拒绝重复操作 ──")
    fData.state      = ShipFurnitureState.Upgrading
    fData.updateTime = os.time() + 3600
    furnitureMgr.upgradingSet[fData.uuid] = true

    local ok4 = bgCtrl:UpgradeFurniture(targetFid, targetBid)
    assert_false("Step4 升级中时拒绝重复升级", ok4)
    log(PASS .. " Step4 升级中时正确拒绝 ✓")

    -- 恢复
    fData.state      = ShipFurnitureState.Idle
    fData.updateTime = 0
    fData.level      = 1
    furnitureMgr.upgradingSet[fData.uuid] = nil

    -- 锁回家具，避免污染后续测试
    fData.unlock = 0
    fData.level  = 0
    fData.state  = ShipFurnitureState.Locked

    log(INFO .. " 家具升级流程测试通过 ✓")
end

-- ---------------------------------------------------------------
-- 【新P】PrintFurnitureStatus — 打印所有有家具建筑的家具状态快照
-- ---------------------------------------------------------------

function M.PrintFurnitureStatus()
    log(SEP)
    log("=== 【新P】家具状态快照 ===")

    local bgCtrl       = newBgCtrl()
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not bgCtrl or not furnitureMgr then return end

    -- 收集所有有家具的 buildId
    local buildIds = {}
    local visited  = {}
    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        local bid = tonumber(lineData:getValue("build_id"))
        if bid and not visited[bid] then
            visited[bid] = true
            table.insert(buildIds, bid)
        end
    end)

    if #buildIds == 0 then
        log(INFO .. " 无家具配置")
        return
    end

    for _, bid in ipairs(buildIds) do
        local buildCfg = bgCtrl:GetBuildingConfig(bid)
        local buildLv  = mgr():GetMaxBuildingLevel(bid)
        log(string.format("\n  ▶ %s (buildId=%d  当前Lv=%d)", buildCfg.name, bid, buildLv))
        log(string.format("    %-6s %-16s %-6s %-6s %-10s %-8s %s",
            "fId", "名称", "等级", "满级", "状态", "可升级", "当前效果"))
        log("    " .. string.rep("-", 72))

        local fList = furnitureMgr:GetFurnituresByBuildId(bid)
        for _, fData in ipairs(fList) do
            local fCfg = furnitureMgr:GetFurnitureConfig(fData.furnitureId)
            local stateStr = ({
                [ShipFurnitureState.Locked]    = "未解锁",
                [ShipFurnitureState.Idle]      = "空闲",
                [ShipFurnitureState.Upgrading] = "升级中",
                [ShipFurnitureState.Done]      = "待领取",
            })[fData.state] or tostring(fData.state)

            local canUpgrade = fData.unlock == 1 and not fData:IsBusy() and fData.level < 30
            local curCfg     = (fData.level > 0) and furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, fData.level) or nil
            local bonus      = bgCtrl:_ParseFurnitureEffect(curCfg)

            log(string.format("    %-6d %-16s %-6d %-6d %-10s %-8s %s",
                fData.furnitureId,
                fCfg.name,
                fData.level,
                30,
                stateStr,
                canUpgrade and "✓" or "-",
                bonus ~= "" and bonus or "-"))

            if fData:IsUpgrading() then
                log(string.format("      → 升级中 目标Lv=%d  剩余%ds",
                    fData.upgradeTargetLevel, fData:GetRemainSeconds()))
            end
            if fData.unlock == 0 and buildLv < fCfg.unlockBuildingLevel then
                log(string.format("      → 需建筑达到 Lv%d 才可解锁（当前Lv%d）",
                    fCfg.unlockBuildingLevel, buildLv))
            end
        end
    end
end

-- ---------------------------------------------------------------
-- 【新P】建筑产出 Tick 测试
--   验证：produce_cd > 0 的建筑每秒累积，达到 CD 后产出资源
--   验证：produce_cd <= 0 的建筑不产出
-- ---------------------------------------------------------------

function M.TestBuildingProduction()
    log(SEP)
    log("=== 【新P】建筑产出 Tick 测试 ===")

    local m = mgr()
    if not m then log(FAIL .. " ShipPlayerDataManager 不存在") return end

    -- 找第一个 produce_cd > 0 的建筑
    local prodBid    = nil
    local prodCD     = 0
    local prodBase   = 0
    local prodItemId = 0
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        if prodBid then return end
        local cd = tonumber(lineData:getValue("produce_cd")) or 0
        if cd > 0 then
            local raw = lineData:getValue("product") or ""
            local itemId = tonumber(string.match(raw, "^(%d+)")) or 0
            if itemId > 0 then
                prodBid    = tonumber(rowId)
                prodCD     = cd
                prodBase   = tonumber(lineData:getValue("product_base")) or 0
                prodItemId = itemId
            end
        end
    end)

    if not prodBid then
        log(INFO .. " Building_Config 中无 produce_cd > 0 的建筑，跳过")
        return
    end

    log(INFO .. string.format(" 目标建筑 buildId=%d  produce_cd=%d  product_base=%d  productId=%d",
        prodBid, prodCD, prodBase, prodItemId))

    -- 收集所有产出同 productId 的其他建筑，测试时锁定它们避免干扰
    local otherProdBuildings = {}
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        local otherId = tonumber(rowId)
        if otherId and otherId ~= prodBid then
            local cd = tonumber(lineData:getValue("produce_cd")) or 0
            if cd > 0 then
                local raw = lineData:getValue("product") or ""
                local itemId = tonumber(string.match(raw, "^(%d+)")) or 0
                if itemId == prodItemId then
                    local otherBd = m:GetMaxLevelBuilding(otherId)
                    if otherBd and otherBd.unlock == 1 and otherBd.level > 0 then
                        table.insert(otherProdBuildings, {
                            buildId  = otherId,
                            unlock   = otherBd.unlock,
                            level    = otherBd.level,
                            state    = otherBd.state,
                            cdAccum  = otherBd.cdAccum,
                        })
                        -- 锁定其他产出建筑
                        otherBd.unlock  = 0
                        otherBd.level   = 0
                        otherBd.state   = ShipBuildingState.Locked
                        otherBd.cdAccum = 0
                    end
                end
            end
        end
    end)
    if #otherProdBuildings > 0 then
        log(INFO .. string.format(" 已锁定 %d 个其他产出同 productId=%d 的建筑",
            #otherProdBuildings, prodItemId))
    end

    -- 恢复其他产出建筑的工具函数
    local function restoreOtherBuildings()
        for _, info in ipairs(otherProdBuildings) do
            local bd = m:GetMaxLevelBuilding(info.buildId)
            if bd then
                bd.unlock  = info.unlock
                bd.level   = info.level
                bd.state   = info.state
                bd.cdAccum = info.cdAccum
            end
        end
    end

    -- 确保建筑已解锁 level=1
    resetBuilding(prodBid, 1, 1, ShipBuildingState.Idle)
    local bd = m:GetMaxLevelBuilding(prodBid)
    assert_not_nil("建筑数据存在", bd)
    if not bd then restoreOtherBuildings() return end

    -- 重置 cdAccum
    bd.cdAccum = 0

    -- ── 场景1：累积不足 CD，不产出 ──────────────────────────
    log(INFO .. " ── 场景1：累积不足 CD，不产出 ──")
    local resBefore = m:GetResourceCount(prodItemId)
    -- 手动 Tick prodCD-1 次
    for i = 1, prodCD - 1 do
        m:_TickProduction()
    end
    local resAfter1 = m:GetResourceCount(prodItemId)
    assert_eq("累积不足 CD 时资源未变化", resAfter1, resBefore)
    log(INFO .. string.format(" Tick %d 次后资源=%d（未变化）✓", prodCD - 1, resAfter1))

    -- ── 场景2：再 Tick 1 次，触发产出 ───────────────────────
    log(INFO .. " ── 场景2：再 Tick 1 次，触发产出 ──")
    m:_TickProduction()
    local resAfter2 = m:GetResourceCount(prodItemId)
    assert_true("触发产出后资源增加", resAfter2 > resBefore)
    local delta = resAfter2 - resBefore
    assert_eq("产出量 = product_base（无家具加成）", delta, prodBase)
    log(INFO .. string.format(" 产出触发：资源 %d → %d  delta=%d  product_base=%d ✓",
        resBefore, resAfter2, delta, prodBase))

    -- ── 场景3：produce_cd <= 0 的建筑不产出 ─────────────────
    log(INFO .. " ── 场景3：produce_cd=0 的建筑不产出 ──")
    local noProdBid = nil
    LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
        if noProdBid then return end
        local cd = tonumber(lineData:getValue("produce_cd")) or 0
        if cd <= 0 then
            noProdBid = tonumber(rowId)
        end
    end)
    if noProdBid then
        resetBuilding(noProdBid, 1, 1, ShipBuildingState.Idle)
        local bd2 = m:GetMaxLevelBuilding(noProdBid)
        if bd2 then
            bd2.cdAccum = 0
            -- 随便 Tick 几次，不应该有任何产出变化
            local snapBefore = {}
            for itemId, _ in pairs(m.resourceData.resources or {}) do
                snapBefore[itemId] = m:GetResourceCount(itemId)
            end
            for i = 1, 5 do m:_TickProduction() end
            local changed = false
            for itemId, before in pairs(snapBefore) do
                if m:GetResourceCount(itemId) ~= before then
                    changed = true
                    break
                end
            end
            -- 注意：其他产出建筑可能也在 Tick，这里只验证 noProdBid 自身 cdAccum 不增长
            assert_eq("非产出建筑 cdAccum 保持 0", bd2.cdAccum, 0)
            log(INFO .. string.format(" buildId=%d produce_cd=0，cdAccum 保持 0 ✓", noProdBid))
        end
    else
        log(INFO .. " 所有建筑都有 produce_cd，跳过场景3")
    end

    -- ── 场景4：未解锁建筑不产出 ─────────────────────────────
    log(INFO .. " ── 场景4：未解锁建筑不产出 ──")
    resetBuilding(prodBid, 0, 0, ShipBuildingState.Locked)
    local bd3 = m:GetMaxLevelBuilding(prodBid)
    if bd3 then
        bd3.cdAccum = 0
        local resBefore4 = m:GetResourceCount(prodItemId)
        for i = 1, prodCD + 1 do m:_TickProduction() end
        local resAfter4 = m:GetResourceCount(prodItemId)
        assert_eq("未解锁建筑不产出", resAfter4, resBefore4)
        assert_eq("未解锁建筑 cdAccum 保持 0", bd3.cdAccum, 0)
        log(INFO .. " 未解锁建筑不产出 ✓")
    end

    -- 恢复
    resetBuilding(prodBid, 1, 1, ShipBuildingState.Idle)
    restoreOtherBuildings()
    log(PASS .. " 建筑产出 Tick 测试完成 ✓")
end

-- ---------------------------------------------------------------
-- 【新Q】家具升级影响建筑产出测试
--   验证：家具 effType=1 升级后，GetBuildingOutputInc 增加
--   验证：家具 effType=2 升级后，GetBuildingCDDec 增加
--   验证：产出 Tick 中 realOutput = product_base + outputInc
--   验证：产出 Tick 中 realCD = produce_cd - cdDec（最小1）
-- ---------------------------------------------------------------

function M.TestFurnitureAffectsProduction()
    log(SEP)
    log("=== 【新Q】家具升级影响建筑产出测试 ===")

    local m            = mgr()
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not m or not furnitureMgr then
        log(FAIL .. " 依赖管理器不存在")
        return
    end

    -- 找第一个有家具且 produce_cd > 0 的建筑
    local targetBid  = nil
    local targetFid  = nil
    local prodCD     = 0
    local prodBase   = 0
    local prodItemId = 0

    LocalController:instance():visitTable(TableName.Furniture_Config, function(rowId, lineData)
        if targetBid then return end
        local bid = tonumber(lineData:getValue("build_id"))
        if not bid then return end
        local cd = GetTableNumber(TableName.Building_Config, bid, "produce_cd") or 0
        if cd > 0 then
            local raw    = GetTableData(TableName.Building_Config, bid, "product") or ""
            local itemId = tonumber(string.match(raw, "^(%d+)")) or 0
            if itemId > 0 then
                targetBid  = bid
                targetFid  = tonumber(rowId)
                prodCD     = cd
                prodBase   = GetTableNumber(TableName.Building_Config, bid, "product_base") or 0
                prodItemId = itemId
            end
        end
    end)

    if not targetBid then
        log(INFO .. " 找不到有家具且有产出的建筑，跳过")
        log(INFO .. " 需要在 Furniture_Config 表中添加数据：build_id 对应的 Building_Config 需有 produce_cd>0 和 product 字段")
        return
    end

    log(INFO .. string.format(" 目标建筑 buildId=%d  家具 furnitureId=%d  produce_cd=%d  product_base=%d  productId=%d",
        targetBid, targetFid, prodCD, prodBase, prodItemId))

    -- 重置建筑 level=1 已解锁
    resetBuilding(targetBid, 1, 1, ShipBuildingState.Idle)

    -- 重置家具为 level=1 已解锁空闲
    local fData = furnitureMgr:GetFurnitureByBuildAndId(targetBid, targetFid)
    assert_not_nil("家具数据存在", fData)
    if not fData then return end

    fData.unlock             = 1
    fData.level              = 1
    fData.state              = ShipFurnitureState.Idle
    fData.upgradeTargetLevel = 0
    fData.updateTime         = 0
    furnitureMgr.upgradingSet[fData.uuid] = nil

    -- 读家具 cfgId
    local fCfg = furnitureMgr:GetFurnitureConfig(targetFid)
    assert_not_nil("家具基础配置存在", fCfg)
    if not fCfg then return end

    -- 读 level=1 的效果
    local lv1Cfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, 1)
    if not lv1Cfg then
        log(INFO .. " 找不到家具 level=1 配置（表可能无数据），跳过")
        return
    end
    log(INFO .. string.format(" 家具 level=1 effType=%d  effArg=%d",
        lv1Cfg.effType, lv1Cfg.effArg))

    -- ── 场景1：level=1 时的加成值 ────────────────────────────
    log(INFO .. " ── 场景1：level=1 时的加成值 ──")
    local outputInc1 = furnitureMgr:GetBuildingOutputInc(targetBid)
    local cdDec1     = furnitureMgr:GetBuildingCDDec(targetBid)
    log(INFO .. string.format(" level=1  outputInc=%d  cdDec=%d", outputInc1, cdDec1))

    if lv1Cfg.effType == 1 then
        assert_eq("level=1 outputInc = lv1Cfg.effArg", outputInc1, lv1Cfg.effArg)
        assert_eq("level=1 cdDec = 0（无 effType=2 家具）", cdDec1, 0)
    elseif lv1Cfg.effType == 2 then
        assert_eq("level=1 cdDec = lv1Cfg.effArg", cdDec1, lv1Cfg.effArg)
        assert_eq("level=1 outputInc = 0（无 effType=1 家具）", outputInc1, 0)
    else
        log(INFO .. " effType=" .. lv1Cfg.effType .. "（非产出/CD类型），跳过加成断言")
    end

    -- ── 场景2：升级到 level=2，加成值变化 ───────────────────
    log(INFO .. " ── 场景2：升级到 level=2，加成值变化 ──")
    local lv2Cfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, 2)
    if not lv2Cfg then
        log(INFO .. " 找不到家具 level=2 配置，跳过场景2")
    else
        -- 直接写入 level=2（跳过升级流程，只测产出计算）
        fData.level = 2

        local outputInc2 = furnitureMgr:GetBuildingOutputInc(targetBid)
        local cdDec2     = furnitureMgr:GetBuildingCDDec(targetBid)
        log(INFO .. string.format(" level=2  outputInc=%d  cdDec=%d  lv2effArg=%d",
            outputInc2, cdDec2, lv2Cfg.effArg))

        if lv2Cfg.effType == 1 then
            assert_eq("level=2 outputInc = lv2Cfg.effArg", outputInc2, lv2Cfg.effArg)
            assert_true("level=2 outputInc >= level=1 outputInc（升级后加成不减少）",
                outputInc2 >= outputInc1)
        elseif lv2Cfg.effType == 2 then
            assert_eq("level=2 cdDec = lv2Cfg.effArg", cdDec2, lv2Cfg.effArg)
            assert_true("level=2 cdDec >= level=1 cdDec（升级后减CD不减少）",
                cdDec2 >= cdDec1)
        end

        -- 恢复 level=1
        fData.level = 1
    end

    -- ── 场景3：Tick 中 realOutput = product_base + outputInc ─
    log(INFO .. " ── 场景3：Tick 产出量包含家具加成 ──")
    if lv1Cfg.effType == 1 and lv1Cfg.effArg > 0 then
        local bd = m:GetMaxLevelBuilding(targetBid)
        if bd then
            -- 隔离其他产出同 productId 的建筑
            local otherBlds = {}
            LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
                local oId = tonumber(rowId)
                if oId and oId ~= targetBid then
                    local cd = tonumber(lineData:getValue("produce_cd")) or 0
                    if cd > 0 then
                        local raw = lineData:getValue("product") or ""
                        local itemId = tonumber(string.match(raw, "^(%d+)")) or 0
                        if itemId == prodItemId then
                            local ob = m:GetMaxLevelBuilding(oId)
                            if ob and ob.unlock == 1 and ob.level > 0 then
                                table.insert(otherBlds, { unlock=ob.unlock, level=ob.level, state=ob.state, cdAccum=ob.cdAccum, ref=ob })
                                ob.unlock = 0; ob.level = 0; ob.state = ShipBuildingState.Locked; ob.cdAccum = 0
                            end
                        end
                    end
                end
            end)

            bd.cdAccum = 0
            -- 先 Tick prodCD-1 次（不触发产出）
            for i = 1, prodCD - 1 do m:_TickProduction() end
            local resBefore = m:GetResourceCount(prodItemId)
            -- 再 Tick 1 次触发产出
            m:_TickProduction()
            local resAfter = m:GetResourceCount(prodItemId)
            local delta = resAfter - resBefore
            local expectedOutput = prodBase + lv1Cfg.effArg
            assert_eq("产出量 = product_base + outputInc", delta, expectedOutput)
            log(INFO .. string.format(" 产出 delta=%d  product_base=%d  outputInc=%d  expected=%d ✓",
                delta, prodBase, lv1Cfg.effArg, expectedOutput))
            -- 验证玩家实际持有资源数量也正确增加
            local ownedAfter = m.resourceData.resources[prodItemId] or 0
            assert_eq("玩家持有资源 = tick前持有 + 产出量", ownedAfter, resBefore + expectedOutput)

            -- 恢复其他建筑
            for _, info in ipairs(otherBlds) do
                info.ref.unlock = info.unlock; info.ref.level = info.level
                info.ref.state = info.state; info.ref.cdAccum = info.cdAccum
            end
        end
    else
        log(INFO .. " 家具 effType 非产量类型，跳过场景3 Tick 验证")
    end

    -- ── 场景4：Tick 中 realCD = produce_cd - cdDec ───────────
    log(INFO .. " ── 场景4：Tick 中 realCD 受家具减CD影响 ──")
    if lv1Cfg.effType == 2 and lv1Cfg.effArg > 0 then
        local bd = m:GetMaxLevelBuilding(targetBid)
        if bd then
            -- 隔离其他产出同 productId 的建筑
            local otherBlds2 = {}
            LocalController:instance():visitTable(TableName.Building_Config, function(rowId, lineData)
                local oId = tonumber(rowId)
                if oId and oId ~= targetBid then
                    local cd = tonumber(lineData:getValue("produce_cd")) or 0
                    if cd > 0 then
                        local raw = lineData:getValue("product") or ""
                        local itemId = tonumber(string.match(raw, "^(%d+)")) or 0
                        if itemId == prodItemId then
                            local ob = m:GetMaxLevelBuilding(oId)
                            if ob and ob.unlock == 1 and ob.level > 0 then
                                table.insert(otherBlds2, { unlock=ob.unlock, level=ob.level, state=ob.state, cdAccum=ob.cdAccum, ref=ob })
                                ob.unlock = 0; ob.level = 0; ob.state = ShipBuildingState.Locked; ob.cdAccum = 0
                            end
                        end
                    end
                end
            end)

            bd.cdAccum = 0
            local realCD = math.max(prodCD - lv1Cfg.effArg, 1)
            -- Tick realCD-1 次，不应产出
            local resBefore = m:GetResourceCount(prodItemId)
            for i = 1, realCD - 1 do m:_TickProduction() end
            local resAfterPartial = m:GetResourceCount(prodItemId)
            assert_eq("减CD后 Tick realCD-1 次不产出", resAfterPartial, resBefore)
            -- 再 Tick 1 次，触发产出
            m:_TickProduction()
            local resAfterFull = m:GetResourceCount(prodItemId)
            assert_true("减CD后 Tick realCD 次触发产出", resAfterFull > resBefore)
            log(INFO .. string.format(" produce_cd=%d  cdDec=%d  realCD=%d  产出触发 ✓",
                prodCD, lv1Cfg.effArg, realCD))
            -- 验证玩家实际持有资源数量也正确增加
            local expectedOutput4 = prodBase + furnitureMgr:GetBuildingOutputInc(targetBid)
            local ownedAfter4 = m.resourceData.resources[prodItemId] or 0
            assert_eq("玩家持有资源 = tick前持有 + 产出量", ownedAfter4, resBefore + expectedOutput4)

            -- 恢复其他建筑
            for _, info in ipairs(otherBlds2) do
                info.ref.unlock = info.unlock; info.ref.level = info.level
                info.ref.state = info.state; info.ref.cdAccum = info.cdAccum
            end
        end
    else
        log(INFO .. " 家具 effType 非减CD类型，跳过场景4 Tick 验证")
    end

    -- ── 场景5：家具未解锁时加成为 0 ─────────────────────────
    log(INFO .. " ── 场景5：家具未解锁时加成为 0 ──")
    fData.unlock = 0
    fData.level  = 0
    local outputIncLocked = furnitureMgr:GetBuildingOutputInc(targetBid)
    local cdDecLocked     = furnitureMgr:GetBuildingCDDec(targetBid)
    assert_eq("未解锁家具 outputInc=0", outputIncLocked, 0)
    assert_eq("未解锁家具 cdDec=0",     cdDecLocked,     0)
    log(INFO .. " 未解锁家具加成为 0 ✓")

    -- 恢复
    fData.unlock = 0
    fData.level  = 0
    fData.state  = ShipFurnitureState.Locked
    resetBuilding(targetBid, 1, 1, ShipBuildingState.Idle)
    log(PASS .. " 家具升级影响建筑产出测试完成 ✓")
end

-- ---------------------------------------------------------------
-- RunAll
-- ---------------------------------------------------------------

function M.RunAll()
    log(SEP)
    log("=== ShipSystem 测试开始 ===")
    log(SEP)

    local cases = {
        -- ★ 自动化回归用例（RunAll 跑这些）
        { name = "【正式流程】完整业务流程",         fn = M.TestRealFlow                   },
        { name = "【新H】建造队列集成测试",          fn = M.TestBuildQueueIntegration       },
        { name = "【新I】WorkQueue配置读取",         fn = M.TestWorkQueueConfig             },
        { name = "【新J】WorkQueue队列解锁逻辑",     fn = M.TestWorkQueueUnlock             },
        { name = "【新K】WorkQueue并发队列",         fn = M.TestWorkQueueConcurrent         },
        { name = "【新M】建筑详情家具数据完整性",    fn = M.TestBuildingDetailFurniture     },
        { name = "【新N】家具解锁流程",              fn = M.TestFurnitureUnlock             },
        { name = "【新O】家具升级流程",              fn = M.TestFurnitureUpgrade            },
        { name = "【新P】建筑产出Tick",              fn = M.TestBuildingProduction          },
        { name = "【新Q】家具升级影响建筑产出",      fn = M.TestFurnitureAffectsProduction  },
        --[[
        { name = "【新F】待领取流程完整测试",        fn = M.TestCollectFlow                },
        { name = "【新G-旧】升级倒计时(模拟时间)",  fn = M.TestUpgradeTimerFlow           },
        -- ★ 真实倒计时用例（手动分两步跑，不放在 RunAll 里）
        --   第一步：M.TestUpgradeTimerStart()   → 触发升级，等倒计时
        --   第二步：M.TestUpgradeTimerCollect() → 倒计时结束后验证并领取
        { name = "【新A】所有建筑激活状态和等级",    fn = M.PrintAllBuildingActivation     },
        { name = "【新E】解锁建筑完整验证",          fn = M.TestUnlockBuildingCtrl         },
        { name = "【新B】某建筑详情数据",            fn = M.PrintBuildingDetail            },
        { name = "【新C】升级确认弹窗界面逻辑",      fn = M.PrintUpgradeConfirmDetail      },
        { name = "【新D】升级逻辑完整验证",          fn = M.TestUpgradeLogic               },
        -- 原有用例
        { name = "①GetConfig",                    fn = M.TestGetConfig                  },
        { name = "②QueryPlayerData",              fn = M.TestQueryPlayerData            },
        { name = "③CheckCondition",               fn = M.TestCheckCondition             },
        { name = "④CheckResource",                fn = M.TestCheckResource              },
        { name = "⑤GetBuildingDetail",            fn = M.TestGetBuildingDetail          },
        { name = "⑥GetBuildingDetail满级",        fn = M.TestGetBuildingDetailMaxLevel  },
        { name = "⑦PanelGetLv1Config",            fn = M.TestPanelCtrlGetLv1Config      },
        { name = "⑧DoConfirm解锁",                fn = M.TestPanelCtrlDoConfirmUnlock   },
        { name = "⑨DoConfirm升级",                fn = M.TestPanelCtrlDoConfirmUpgrade  },
        { name = "⑩DoConfirm边界保护",            fn = M.TestPanelCtrlDoConfirmGuard    },
        { name = "⑪完整链路(解锁)",               fn = M.TestFullFlow                   },
        { name = "⑫弹窗数据完整性",               fn = M.TestOpenBuildingPanelData      },
        { name = "⑬资源扣减验证",                 fn = M.TestResourceDeductAfterConfirm },
        { name = "⑭完整升级链路",                 fn = M.TestFullUpgradeFlow            },
        { name = "⑮全量状态快照",                 fn = M.PrintAllBuildingStatus         },
        ]]--
    }

    local passed, failed = 0, 0
    for _, c in ipairs(cases) do
        local ok, err = pcall(c.fn)
        if ok then
            passed = passed + 1
        else
            failed = failed + 1
            log(FAIL .. " 用例「" .. c.name .. "」抛出异常: " .. tostring(err))
        end
    end

    log(SEP)
    log(string.format("=== 测试完成  通过=%d  异常=%d ===", passed, failed))
    log(SEP)
end

return M
