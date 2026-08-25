---
--- 飞船背景UI — Controller
--- 主界面：建筑格子列表，点击选中，底部操作栏显示建筑信息和操作按钮
--- 数据层：DataCenter.ShipPlayerDataManager（本地内存）
--- 网络层：暂不实现，联调时取消函数末尾注释块即可
---@class UIShipBackgroundCtrl : UIBaseCtrl
local UIShipBackgroundCtrl = BaseClass("UIShipBackgroundCtrl", UIBaseCtrl)

--- ---------------------------------------------------------------
--- 内部工具
--- ---------------------------------------------------------------

--- 解析升级费用字符串 "102001,200000;102002,100000" -> {{itemId=102001,count=200000}, ...}
local function ParseCostString(costStr)
    local result = {}
    if not costStr or costStr == "" then
        return result
    end
    for segment in string.gmatch(costStr, "[^;]+") do
        local itemId, count = string.match(segment, "%s*(%d+)%s*,%s*(%d+)%s*")
        if itemId and count then
            table.insert(result, { itemId = tonumber(itemId), count = tonumber(count) })
        end
    end
    return result
end

--- Building_Levelup_Config 缓存索引: [buildLv] = rowId
--- 表结构：每行对应一个建筑等级(build_lv)，rowId 即 build_lv
--- lvup_N / lvup_cost_N / lvup_unlock_N 字段内容格式: "buildId|数据"
local _levelIndex = nil
local function GetBuildingLevelRowId(buildId, buildLv)
    if _levelIndex == nil then
        _levelIndex = {}
        LocalController:instance():visitTable(TableName.Building_Levelup_Config, function(rowId, lineData)
            local blv = tonumber(lineData:getValue("build_lv"))
            if blv then
                _levelIndex[blv] = rowId
            end
        end)
    end
    return _levelIndex[buildLv]
end

--- 从 lvup_N/lvup_cost_N/lvup_unlock_N 字段中找到 buildId 对应的数据段
--- 字段格式: "buildId|数据"，遍历 lvup_1..lvup_37 找前缀匹配的
local MAX_LVUP_COLS = 37
local function GetBuildingLvupFields(rowId, buildId)
    local prefix = tostring(buildId) .. "|"
    for n = 1, MAX_LVUP_COLS do
        local val = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_" .. n)
        if val and val ~= "" then
            if string.sub(val, 1, #prefix) == prefix then
                local costVal   = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_cost_" .. n)   or ""
                local unlockVal = GetTableData(TableName.Building_Levelup_Config, rowId, "lvup_unlock_" .. n) or ""
                return val, costVal, unlockVal
            end
        end
    end
    return nil, nil, nil
end

--- lvup 字段解析: "buildId|条件|时间" -> condStr, lvupTime
local function ParseLvupField(val)
    if not val or val == "" then return "", 0 end
    -- 去掉 buildId 前缀
    local rest = string.match(val, "^%d+|(.+)$") or ""
    -- 格式: "条件|时间"
    local condStr, timeStr = string.match(rest, "^([^|]*)|(.*)$")
    return condStr or "", tonumber(timeStr) or 0
end

--- lvup_cost 字段解析: "buildId|itemId,count;itemId,count" -> costStr
local function ParseLvupCostField(val)
    if not val or val == "" then return "" end
    return string.match(val, "^%d+|(.+)$") or ""
end

--- lvup_unlock 字段解析: "buildId|effType;effArg" -> power
--- 效果类型 1 = AddPower，取 effArg 作为战力值
local function ParseLvupUnlockPower(val)
    if not val or val == "" then return 0 end
    local rest = string.match(val, "^%d+|(.+)$") or ""
    -- 可能有多个效果，分号分隔
    for seg in string.gmatch(rest, "[^;]+") do
        local effType, effArg = string.match(seg, "^(%d+),(.+)$")
        if not effType then
            effType, effArg = string.match(seg, "^(%d+);(.+)$")
        end
        if tonumber(effType) == 1 then
            return tonumber(effArg) or 0
        end
    end
    return 0
end

--- ---------------------------------------------------------------
--- 配置表查询（只读）
--- ---------------------------------------------------------------

--- 获取建筑基础配置（来自 Building_Config 表）
function UIShipBackgroundCtrl:GetBuildingConfig(buildId)
    local cfg = {}
    cfg.id          = buildId
    cfg.name        = GetTableData(TableName.Building_Config, buildId, "name")          or ""
    cfg.desc        = GetTableData(TableName.Building_Config, buildId, "desc")          or ""
    cfg.detail_desc = GetTableData(TableName.Building_Config, buildId, "detail_desc")   or ""
    cfg.level_limit = GetTableNumber(TableName.Building_Config, buildId, "level_limit") or 1
    cfg.condition   = GetTableData(TableName.Building_Config, buildId, "condition")     or ""
    cfg.icon        = GetTableData(TableName.Building_Config, buildId, "icon")          or ""
    cfg.type        = GetTableNumber(TableName.Building_Config, buildId, "type")        or 0
    cfg.group       = GetTableNumber(TableName.Building_Config, buildId, "group")       or 0
    return cfg
end

--- 获取建筑某等级的升级配置（来自 Building_Levelup_Config 表）
function UIShipBackgroundCtrl:GetBuildingLevelConfig(buildId, buildLv)
    local rowId = GetBuildingLevelRowId(buildId, buildLv)
    if not rowId then return nil end

    local lvupVal, costVal, unlockVal = GetBuildingLvupFields(rowId, buildId)
    if not lvupVal then return nil end

    local condStr, lvupTime = ParseLvupField(lvupVal)
    local costStr           = ParseLvupCostField(costVal)
    local power             = ParseLvupUnlockPower(unlockVal)

    -- 解析升级条件字符串，格式: "condType;param1,param2..."
    local condType  = tonumber(string.match(condStr or "", "^(%d+)")) or 0
    local condParam = string.match(condStr or "", "^%d+;(.+)$") or ""

    -- lvup_require1 / lvup_require1_unlock 按条件类型填写，供 View 显示和检查函数使用
    -- condType=1: 无条件；2: 建筑完成(buildId)；3: 玩家等级(lv)；4: 建筑等级(buildId,lv)
    -- condType=5: 物品持有(itemId,count)；6: 英雄(heroId)；7: 科技完成(techId)
    local require1, require1_unlock
    if condType == 0 or condType == 1 then
        require1        = ""
        require1_unlock = -1
    elseif condType == 2 then
        -- 建筑完成: param = buildId
        require1        = condParam
        require1_unlock = -1
    elseif condType == 3 then
        -- 玩家等级: param = 等级
        require1        = condParam
        require1_unlock = tonumber(condParam) or -1
    elseif condType == 4 then
        -- 建筑等级: param = "buildId,等级"
        local bid, lv = string.match(condParam, "^(%d+),(%d+)$")
        require1        = bid or condParam
        require1_unlock = tonumber(lv) or -1
    elseif condType == 5 then
        -- 物品持有: param = "itemId,数量"
        require1        = condParam
        require1_unlock = -1
    elseif condType == 6 then
        -- 英雄条件: param = heroId
        require1        = condParam
        require1_unlock = -1
    elseif condType == 7 then
        -- 科技完成: param = techId
        require1        = condParam
        require1_unlock = -1
    else
        require1        = condParam
        require1_unlock = -1
    end

    local cfg = {}
    cfg.power                = power
    cfg.lvup_cost            = costStr
    cfg.lvup_time            = lvupTime
    cfg.lvup_cond_type       = condType      -- 条件类型，供检查函数分支
    cfg.lvup_require1        = require1      -- 条件参数（建筑ID/等级/物品ID等）
    cfg.lvup_require1_unlock = require1_unlock
    cfg.costList             = ParseCostString(costStr)
    return cfg
end

--- ---------------------------------------------------------------
--- 玩家建筑数据查询
--- ---------------------------------------------------------------

function UIShipBackgroundCtrl:GetPlayerBuildingLevel(buildId)
    return DataCenter.ShipPlayerDataManager:GetMaxBuildingLevel(buildId)
end

function UIShipBackgroundCtrl:GetPlayerBuildingData(buildId)
    return DataCenter.ShipPlayerDataManager:GetMaxLevelBuilding(buildId)
end

function UIShipBackgroundCtrl:IsBuildingUnlocked(buildId)
    return DataCenter.ShipPlayerDataManager:IsBuildingUnlocked(buildId)
end

--- 获取所有建筑 buildId 列表（含未解锁，按 Building_Config 顺序）
function UIShipBackgroundCtrl:GetPlayerBuildIdList()
    return DataCenter.ShipPlayerDataManager:GetAllBuildIdList()
end

--- ---------------------------------------------------------------
--- 前置条件检查
--- ---------------------------------------------------------------

--- 按条件类型检查是否满足，返回 ok, errMsg
--- condType 参考 BuildingUnlockConditionType
local function CheckCondition(self, condType, require1, require1_unlock)
    if condType == 0 or condType == 1 then
        return true
    elseif condType == 2 then
        -- 建筑完成: require1 = buildId
        local bid = tonumber(require1)
        if bid and not self:IsBuildingUnlocked(bid) then
            local preCfg = self:GetBuildingConfig(bid)
            return false, string.format("需要完成建筑【%s】", preCfg.name)
        end
    elseif condType == 3 then
        -- 玩家等级: require1_unlock = 等级
        local needLv = require1_unlock
        local curLv  = DataCenter.ShipPlayerDataManager:GetSelfLevel()
        if needLv and needLv > 0 and curLv < needLv then
            return false, string.format("需要玩家等级达到 %d 级（当前 %d 级）", needLv, curLv)
        end
    elseif condType == 4 then
        -- 建筑等级: require1 = buildId, require1_unlock = 等级
        local bid    = tonumber(require1)
        local needLv = require1_unlock
        if bid and needLv and needLv >= 0 then
            local curLv = self:GetPlayerBuildingLevel(bid)
            if curLv < needLv then
                local preCfg = self:GetBuildingConfig(bid)
                return false, string.format("需要【%s】达到 %d 级（当前 %d 级）",
                    preCfg.name, needLv, curLv)
            end
        end
    elseif condType == 5 then
        -- 物品持有: require1 = "itemId,count"
        local itemId, count = string.match(require1 or "", "^(%d+),(%d+)$")
        itemId = tonumber(itemId); count = tonumber(count)
        if itemId and count then
            local owned = DataCenter.ShipPlayerDataManager:GetResourceCount(itemId)
            if owned < count then
                return false, string.format("需要持有物品 %d x%d（当前 %d）", itemId, count, owned)
            end
        end
    elseif condType == 6 then
        -- 英雄条件: require1 = heroId（暂不实现，默认通过）
    elseif condType == 7 then
        -- 科技完成: require1 = techId（暂不实现，默认通过）
    end
    return true
end

--- 检查解锁前置条件，返回 ok, errMsg
--- 使用 Building_Levelup_Config 第1级的条件（建筑解锁前置条件）
function UIShipBackgroundCtrl:CheckUnlockCondition(buildId)
    local lv1Cfg = self:GetBuildingLevelConfig(buildId, 1)
    if not lv1Cfg then return true end
    return CheckCondition(self, lv1Cfg.lvup_cond_type, lv1Cfg.lvup_require1, lv1Cfg.lvup_require1_unlock)
end

--- 检查升级前置条件，返回 ok, errMsg
function UIShipBackgroundCtrl:CheckUpgradePrerequisite(levelCfg)
    if not levelCfg then return true end
    return CheckCondition(self, levelCfg.lvup_cond_type, levelCfg.lvup_require1, levelCfg.lvup_require1_unlock)
end

--- 检查资源是否满足，返回 ok, lackItemId
function UIShipBackgroundCtrl:CheckResourceEnough(costList)
    return DataCenter.ShipPlayerDataManager:CheckCostEnough(costList)
end

--- ---------------------------------------------------------------
--- 组装升级弹窗所需的完整参数
--- 供 View 调用后传给 UIBuildingPanel
--- ---------------------------------------------------------------

function UIShipBackgroundCtrl:BuildPanelParams(buildId)
    local curLevel  = self:GetPlayerBuildingLevel(buildId)
    local cfg       = self:GetBuildingConfig(buildId)
    local unlocked  = self:IsBuildingUnlocked(buildId)
    local maxLevel  = cfg.level_limit
    local buildData = self:GetPlayerBuildingData(buildId)

    -- 当前等级配置（已解锁时才有）
    local curLevelCfg  = (curLevel > 0) and self:GetBuildingLevelConfig(buildId, curLevel) or nil
    -- 下一级配置
    local nextLevel    = curLevel + 1
    local nextLevelCfg = (nextLevel <= maxLevel) and self:GetBuildingLevelConfig(buildId, nextLevel) or nil

    -- 前置条件检查结果
    local condOk, condDesc = true, ""
    if unlocked and nextLevelCfg then
        condOk, condDesc = self:CheckUpgradePrerequisite(nextLevelCfg)
    elseif not unlocked then
        condOk, condDesc = self:CheckUnlockCondition(buildId)
    end

    -- 资源检查结果（逐项）
    local costCheckList = {}
    local targetCfg = unlocked and nextLevelCfg or self:GetBuildingLevelConfig(buildId, 1)
    if targetCfg and targetCfg.costList then
        for _, cost in ipairs(targetCfg.costList) do
            local owned  = DataCenter.ShipPlayerDataManager:GetResourceCount(cost.itemId)
            table.insert(costCheckList, {
                itemId  = cost.itemId,
                need    = cost.count,
                owned   = owned,
                enough  = owned >= cost.count,
            })
        end
    end

    return {
        buildId       = buildId,
        buildData     = buildData,
        cfg           = cfg,
        curLevel      = curLevel,
        nextLevel     = nextLevel,
        maxLevel      = maxLevel,
        unlocked      = unlocked,
        curLevelCfg   = curLevelCfg,
        nextLevelCfg  = nextLevelCfg,
        condOk        = condOk,
        condDesc      = condDesc,
        costCheckList = costCheckList,
    }
end

--- ---------------------------------------------------------------
--- 主界面操作
--- ---------------------------------------------------------------

--- 底部栏详细数据组装
--- 点击格子后由 View 调用，返回该建筑当前所有展示数据
function UIShipBackgroundCtrl:GetBuildingDetail(buildId)
    local cfg       = self:GetBuildingConfig(buildId)
    local unlocked  = self:IsBuildingUnlocked(buildId)
    local curLevel  = self:GetPlayerBuildingLevel(buildId)
    local maxLevel  = cfg.level_limit
    local buildData = self:GetPlayerBuildingData(buildId)

    -- isUpgrading：仅倒计时进行中，Done（待领取）不算升级中
    local isUpgrading = buildData and (buildData:IsUpgrading() or buildData:IsUnlocking()) or false
    local isDone      = buildData and buildData:IsDone() or false
    local doneType    = buildData and buildData:GetDoneType() or nil
    local isMax       = unlocked and (curLevel >= maxLevel)

    local curLevelCfg = (curLevel > 0) and self:GetBuildingLevelConfig(buildId, curLevel) or nil
    local curPower    = curLevelCfg and curLevelCfg.power or 0
    local curEffect   = cfg.detail_desc ~= "" and cfg.detail_desc or cfg.desc

    -- Done 状态时 nextLevel 指向 upgradeTargetLevel（curLevel 还未写入）
    local nextLevel
    if isDone and buildData and buildData.upgradeTargetLevel > 0 then
        nextLevel = buildData.upgradeTargetLevel
    else
        nextLevel = curLevel + 1
    end
    local nextLevelCfg = (not isMax) and self:GetBuildingLevelConfig(buildId, nextLevel) or nil
    local upgradeTime  = nextLevelCfg and nextLevelCfg.lvup_time or 0

    local resEnough = true
    if nextLevelCfg and nextLevelCfg.costList then
        resEnough = self:CheckResourceEnough(nextLevelCfg.costList)
    end

    -- CheckUpgradePrerequisite / CheckUnlockCondition 返回 (ok, 描述文案)，
    -- 必须一起接住 —— 只接第一个返回值会丢掉"需要主舱达到22级"这类具体原因，
    -- 拒绝升级时就只能给玩家一句笼统的提示
    local condOk, condDesc = true, ""
    if unlocked and nextLevelCfg then
        condOk, condDesc = self:CheckUpgradePrerequisite(nextLevelCfg)
    elseif not unlocked then
        condOk, condDesc = self:CheckUnlockCondition(buildId)
    end

    return {
        buildId       = buildId,
        buildData     = buildData,
        cfg           = cfg,
        unlocked      = unlocked,
        curLevel      = curLevel,
        maxLevel      = maxLevel,
        isMax         = isMax,
        isUpgrading   = isUpgrading,
        isDone        = buildData and buildData:IsDone() or false,
        doneType      = buildData and buildData:GetDoneType() or nil,
        remainSeconds = buildData and buildData:GetRemainSeconds() or 0,
        curPower      = curPower,
        curEffect     = curEffect,
        nextLevel     = nextLevel,
        nextLevelCfg  = nextLevelCfg,
        upgradeTime   = upgradeTime,
        resEnough     = resEnough,
        condOk        = condOk,
        condDesc      = condDesc,   -- 条件不满足时的具体原因，供拒绝提示用
        canOperate    = condOk and resEnough,
        -- 家具列表（有家具的建筑才有数据，无家具的建筑返回空表）
        furnitureList = self:GetFurnitureListDetail(buildId, curLevel),
    }
end

--- 打开升级确认弹窗（传入 detail 数据，弹窗只负责展示和确认）
function UIShipBackgroundCtrl:OpenBuildingPanel(buildId)
    local detail = self:GetBuildingDetail(buildId)
    Logger.Log(string.format("[UIShipBackgroundCtrl] OpenBuildingPanel buildId=%d unlocked=%s isDone=%s isUpgrading=%s canOperate=%s",
        buildId, tostring(detail.unlocked), tostring(detail.isDone), tostring(detail.isUpgrading), tostring(detail.canOperate)))
    -- 第2个参数必须是 options，不能直接传 detail：
    -- UIManager.OpenWindow 用 type(arg1)=="table" 判断有没有 options
    -- （UIManager.lua:411），detail 是 table 会被当成 OpenOptions 吃掉，
    -- userData 只从第3个参数起取，View 的 GetUserData() 就拿到空表，
    -- Refresh 在 `not d.buildId` 处直接 return，弹窗只显示 prefab 占位文本。
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIBuildingPanel, OpenWinAnimTrue, detail)
end

--- ---------------------------------------------------------------
--- 领取建筑结果（玩家点"领取"按钮后调用）
--- 适用于解锁完成待领取 / 升级完成待领取
--- ---------------------------------------------------------------

function UIShipBackgroundCtrl:CollectBuilding(buildId)
    local buildData = self:GetPlayerBuildingData(buildId)
    if not buildData then
        Logger.LogWarning("[UIShipBackgroundCtrl] CollectBuilding: 找不到建筑数据 buildId=" .. tostring(buildId))
        return
    end
    if not buildData:IsDone() then
        Logger.LogWarning("[UIShipBackgroundCtrl] CollectBuilding: 建筑不在待领取状态 buildId=" .. tostring(buildId))
        return
    end

    local ok, errMsg = DataCenter.ShipPlayerDataManager:CollectBuildingResult(buildData.uuid)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] CollectBuilding 失败: " .. tostring(errMsg))
        return
    end

    local cfg = self:GetBuildingConfig(buildId)
    Logger.Log(string.format("[UIShipBackgroundCtrl] 领取完成 id=%d name=%s level=%d power=%d",
        buildId, cfg.name, buildData.level, buildData.power))

    -- TODO: 服务器联调时取消注释
    -- SFSNetwork.SendMessage(MsgDefines.CollectBuildingResult, { uuid = tostring(buildData.uuid) })
end

--- ---------------------------------------------------------------
--- 解锁建筑（本地内存操作）
--- 待服务器联调时：取消下方注释，发送网络请求
---   服务器回包后调用 DataCenter.ShipPlayerDataManager:ApplyServerUnlockResult(message)
--- ---------------------------------------------------------------

function UIShipBackgroundCtrl:UnlockBuilding(buildId)
    local cfg = self:GetBuildingConfig(buildId)
    if not cfg.name or cfg.name == "" then
        Logger.LogWarning("[UIShipBackgroundCtrl] UnlockBuilding: 找不到建筑配置 buildId=" .. tostring(buildId))
        return
    end
    if self:IsBuildingUnlocked(buildId) then return end

    local buildData = self:GetPlayerBuildingData(buildId)
    if buildData and buildData:IsUnlocking() then return end

    local condOk, condDesc = self:CheckUnlockCondition(buildId)
    if not condOk then
        UIUtil.ShowTips(condDesc)
        return
    end

    local levelCfg = self:GetBuildingLevelConfig(buildId, 1)
    if not levelCfg then return end

    local resOk, lackItemId = self:CheckResourceEnough(levelCfg.costList)
    if not resOk then
        UIUtil.ShowTipsId(130500)
        return
    end

    local ok, errMsg = DataCenter.ShipPlayerDataManager:StartUnlockBuilding(
        buildId, levelCfg.costList, levelCfg.lvup_time)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] StartUnlockBuilding 失败: " .. tostring(errMsg))
        return
    end

    Logger.Log(string.format("[UIShipBackgroundCtrl] 解锁建筑 id=%d name=%s 耗时=%d秒",
        buildId, cfg.name, levelCfg.lvup_time))

    -- TODO: 服务器联调时取消注释
    -- if buildData then
    --     SFSNetwork.SendMessage(MsgDefines.FreeBuildingUpNew, {
    --         uuid = tostring(buildData.uuid), gold = BuildUpgradeUseGoldType.No,
    --         upLevel = 1, clientParam = "", truckId = 0, pathTime = 0, robotUuid = 0,
    --     })
    -- end
end

--- ---------------------------------------------------------------
--- 升级建筑（本地内存操作）
--- 待服务器联调时：取消下方注释，发送网络请求
---   服务器回包后调用 DataCenter.ShipPlayerDataManager:ApplyServerUpgradeResult(message)
--- ---------------------------------------------------------------

function UIShipBackgroundCtrl:UpgradeBuilding(buildId, curLevel)
    local cfg = self:GetBuildingConfig(buildId)
    if not cfg.name or cfg.name == "" then
        Logger.LogWarning("[UIShipBackgroundCtrl] UpgradeBuilding: 找不到建筑配置 buildId=" .. tostring(buildId))
        return
    end

    local maxLevel = cfg.level_limit
    if curLevel >= maxLevel then return end

    local buildData = self:GetPlayerBuildingData(buildId)
    if buildData and buildData:IsUpgrading() then
        -- 正在升级中，打开加速界面
        UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed, ItemSpdMenu.ItemSpdMenu_City, buildData.uuid)
        return
    end

    local nextLevel = curLevel + 1
    local levelCfg  = self:GetBuildingLevelConfig(buildId, nextLevel)
    if not levelCfg then return end

    local preOk, preDesc = self:CheckUpgradePrerequisite(levelCfg)
    if not preOk then
        UIUtil.ShowTips(preDesc)
        return
    end

    local resOk, lackItemId = self:CheckResourceEnough(levelCfg.costList)
    if not resOk then
        UIUtil.ShowTipsId(130500)
        return
    end

    local ok, errMsg = DataCenter.ShipPlayerDataManager:StartUpgradeBuilding(
        buildId, levelCfg.costList, levelCfg.lvup_time, nextLevel)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] StartUpgradeBuilding 失败: " .. tostring(errMsg))
        return
    end

    Logger.Log(string.format("[UIShipBackgroundCtrl] 升级建筑 id=%d name=%s %d->%d 战力=%d 耗时=%d秒",
        buildId, cfg.name, curLevel, nextLevel, levelCfg.power, levelCfg.lvup_time))

    -- TODO: 服务器联调时取消注释
    -- if buildData then
    --     SFSNetwork.SendMessage(MsgDefines.FreeBuildingUpNew, {
    --         uuid = tostring(buildData.uuid), gold = BuildUpgradeUseGoldType.No,
    --         upLevel = nextLevel, clientParam = "", truckId = 0, pathTime = 0, robotUuid = 0,
    --     })
    -- end
end

--- ---------------------------------------------------------------
--- 家具相关查询
--- ---------------------------------------------------------------

--- 获取某建筑下所有家具的完整展示数据
--- 返回列表，每项包含：
---   furnitureId, name, level, maxLevel, state,
---   isUnlocked, isUpgrading, isDone, remainSeconds,
---   unlockBuildLevel（解锁所需建筑等级）,
---   canUnlock（当前建筑等级是否满足解锁条件）,
---   canUpgrade（已解锁且空闲且未满级）,
---   curLevelCfg（当前等级配置，含效果）,
---   nextLevelCfg（下一级配置，含升级消耗和效果）,
---   productBonus（家具对建筑产出的加成描述）
function UIShipBackgroundCtrl:GetFurnitureListDetail(buildId, buildingLevel)
    local furnitureMgr = DataCenter.ShipFurnitureManager
    if not furnitureMgr then return {} end

    local list   = furnitureMgr:GetFurnituresByBuildId(buildId)
    local result = {}

    for _, fData in ipairs(list) do
        local fId  = fData.furnitureId
        local fCfg = furnitureMgr:GetFurnitureConfig(fId)

        -- 最大等级：Furniture_Levelup_Config 中 lvup_cost > 0 的最后一行（第30行）
        local MAX_FURNITURE_LEVEL = 30

        local isUnlocked   = fData.unlock == 1 and fData.level > 0
        local isUpgrading  = fData:IsUpgrading()
        local isDone       = fData:IsDone()
        local isMax        = isUnlocked and fData.level >= MAX_FURNITURE_LEVEL
        local canUnlock    = (not isUnlocked) and (buildingLevel >= fCfg.unlockBuildingLevel)
        local canUpgrade   = isUnlocked and (not fData:IsBusy()) and (not isMax)

        -- 当前等级配置（已解锁时才有）
        local curLevelCfg = nil
        if isUnlocked and fData.level > 0 then
            curLevelCfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, fData.level)
        end

        -- 下一级配置（可升级时才有）
        local nextLevelCfg = nil
        local nextLevel    = fData.level + 1
        if isDone and fData.upgradeTargetLevel > 0 then
            nextLevel = fData.upgradeTargetLevel
        end
        if not isMax then
            nextLevelCfg = furnitureMgr:GetFurnitureLevelConfig(fData.furnitureId, nextLevel)
        end

        -- 家具对产出的加成描述（从 eff_type/eff_arg 解析）
        local productBonus = self:_ParseFurnitureEffect(curLevelCfg)
        local nextBonus    = self:_ParseFurnitureEffect(nextLevelCfg)

        table.insert(result, {
            uuid             = fData.uuid,
            furnitureId      = fId,
            name             = fCfg.name,
            level            = fData.level,
            maxLevel         = MAX_FURNITURE_LEVEL,
            state            = fData.state,
            isUnlocked       = isUnlocked,
            isUpgrading      = isUpgrading,
            isDone           = isDone,
            isMax            = isMax,
            remainSeconds    = fData:GetRemainSeconds(),
            upgradeTargetLv  = fData.upgradeTargetLevel,
            unlockBuildLevel = fCfg.unlockBuildingLevel,
            canUnlock        = canUnlock,
            canUpgrade       = canUpgrade,
            curLevelCfg      = curLevelCfg,
            nextLevelCfg     = nextLevelCfg,
            nextLevel        = nextLevel,
            productBonus     = productBonus,   -- 当前等级效果描述
            nextBonus        = nextBonus,      -- 下一级效果描述
        })
    end

    -- 按解锁等级升序排列（未解锁的排后面）
    table.sort(result, function(a, b)
        if a.isUnlocked ~= b.isUnlocked then
            return a.isUnlocked
        end
        return a.unlockBuildLevel < b.unlockBuildLevel
    end)

    return result
end

--- 解析家具效果配置，返回可读描述字符串
--- eff_type 目前用数字字符串表示效果类型，eff_arg 是数值
--- 约定：eff_type "1" = 产出速度加成（%），"2" = 产量上限加成（%）
function UIShipBackgroundCtrl:_ParseFurnitureEffect(levelCfg)
    if not levelCfg then return "" end
    local parts = {}

    local function addEffect(effType, effArg)
        if not effType or effType == "" then return end
        local t   = tonumber(effType)
        local val = tonumber(effArg) or 0
        if t == 1 then
            table.insert(parts, string.format("产出速度+%d%%", val))
        elseif t == 2 then
            table.insert(parts, string.format("产量上限+%d%%", val))
        elseif t == 3 then
            table.insert(parts, string.format("升级时间-%d%%", val))
        elseif t == 4 then
            table.insert(parts, string.format("战力+%d", val))
        elseif effType ~= "" then
            table.insert(parts, string.format("效果%s+%s", effType, tostring(effArg)))
        end
    end

    -- 字段名是驼峰的 effType/effArg（见 GetFurnitureLevelConfig 的组装），
    -- 不是配置表原始的 eff_type/eff_arg —— 写下划线会永远取到 nil，
    -- 导致 productBonus/nextBonus 恒为空字符串。
    addEffect(levelCfg.effType,  levelCfg.effArg)
    addEffect(levelCfg.effType2, levelCfg.effArg2)
    addEffect(levelCfg.effType3, levelCfg.effArg3)
    addEffect(levelCfg.effType4, levelCfg.effArg4)

    return table.concat(parts, "  ")
end

--- 解锁家具（由 View 调用）
function UIShipBackgroundCtrl:UnlockFurniture(furnitureId, buildId)
    local buildingLevel = self:GetPlayerBuildingLevel(buildId)
    local ok, errMsg = DataCenter.ShipFurnitureManager:UnlockFurniture(furnitureId, buildingLevel)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] UnlockFurniture 失败: " .. tostring(errMsg))
        UIUtil.ShowTips(errMsg)
    end
    return ok
end

--- 升级家具（由 View 调用）
function UIShipBackgroundCtrl:UpgradeFurniture(furnitureId, buildId)
    local MAX_FURNITURE_LEVEL = 30
    local ok, errMsg = DataCenter.ShipFurnitureManager:UpgradeFurniture(furnitureId, MAX_FURNITURE_LEVEL)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] UpgradeFurniture 失败: " .. tostring(errMsg))
        UIUtil.ShowTips(errMsg)
    end
    return ok
end

--- 领取家具升级结果（由 View 调用）
function UIShipBackgroundCtrl:CollectFurniture(furnitureUuid)
    local ok, errMsg = DataCenter.ShipFurnitureManager:CollectFurnitureResult(furnitureUuid)
    if not ok then
        Logger.LogWarning("[UIShipBackgroundCtrl] CollectFurniture 失败: " .. tostring(errMsg))
    end
    return ok
end

--- 立即完成升级（消耗钻石）
function UIShipBackgroundCtrl:SpeedUpBuilding(buildId)
    local buildData = self:GetPlayerBuildingData(buildId)
    if not buildData then return end
    if not buildData:IsUpgrading() and not buildData:IsUnlocking() then return end

    local remainSec = buildData:GetRemainSeconds()
    Logger.Log(string.format("[UIShipBackgroundCtrl] 立即完成 buildId=%d 剩余=%d秒", buildId, remainSec))

    -- TODO: 服务器联调时实现钻石加速逻辑
    -- UIManager:GetInstance():OpenWindow(UIWindowNames.UISpeed, ItemSpdMenu.ItemSpdMenu_City, buildData.uuid)
end

return UIShipBackgroundCtrl
