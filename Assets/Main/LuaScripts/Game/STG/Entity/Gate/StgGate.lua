---
--- STG 数字门基类
--- 对齐编辑器 StgTrapConfig.type == "digital_gate"
--- 门只维护计数器 + 区间表，效果交给 StgBattleLogic:ExecuteEffect
---
---@class StgGate
local StgGate = {}
StgGate.__index = StgGate

local Const = require "Game.STG.Const"

--- @param trapConfig table StgLevelConfig.trapById 里的一条（含预解析的 paraEntries）
--- @param logic table StgBattleLogic
function StgGate.New(trapConfig, logic)
    local self = setmetatable({}, StgGate)
    self.trapConfig = trapConfig
    self.logic = logic
    self.gateType = trapConfig.gateType or Const.GateType.Step
    self.value = trapConfig.initialValue or 0
    self.effectId = nil       -- 当前档位对应的效果
    self.effectIndex = nil    -- 当前档位索引
    self.hasTriggered = false -- 穿门是否已结算
    self.hitCooldown = math.max(0, tonumber(trapConfig.hitCooldown) or 0.05)
    self.hitTimer = 0
    self.unlockMode = trapConfig.unlockMode or "none"
    self.unlockTargetId = trapConfig.unlockTargetId or ""
    self.unlockRequired = math.max(0, tonumber(trapConfig.unlockRequired) or 0)
    self.unlockProgress = self.unlockMode == "none" and self.unlockRequired or 0
    self.isUnlocked = self.unlockMode == "none" or self.unlockRequired <= 0
    self:RecalcEffect()
    return self
end

function StgGate:IsUnlocked()
    return self.isUnlocked
end

function StgGate:GetUnlockProgress()
    return self.unlockProgress or 0, self.unlockRequired or 0
end

function StgGate:TryUnlock(progress)
    if self.isUnlocked then return true end
    self.unlockProgress = math.max(self.unlockProgress or 0, tonumber(progress) or 0)
    if self.unlockProgress >= self.unlockRequired then
        self.isUnlocked = true
        return true
    end
    return false
end

function StgGate:OnTargetBucketAttacked(bucketId, accumulatedDamage)
    if self.unlockMode ~= "bucket_damage" or bucketId ~= self.unlockTargetId then return self.isUnlocked end
    return self:TryUnlock(accumulatedDamage)
end

function StgGate:GetGateType()
    return self.gateType
end

function StgGate:GetValue()
    return self.value
end

function StgGate:GetPosition()
    return self.trapConfig.positionX, self.trapConfig.positionY
end

function StgGate:GetPrefabPath()
    return self.trapConfig.prefabPath
end

--- 子类重写：根据当前 value 重算 effectId / effectIndex
function StgGate:RecalcEffect()
end

--- 子类重写：被打（子弹命中）
--- @param damage number
function StgGate:OnHit(damage)
end

--- 计数门按有效命中增长；整门共享冷却，避免多发弹幕一帧直接升满。
function StgGate:TryAcceptHit(damage)
    if self.hasTriggered or not self:IsUnlocked() or self:IsHeroChargeGate() or self:IsChoiceGate()
        or (tonumber(damage) or 0) <= 0 or self.hitTimer > 0.000001 then
        return false
    end
    self.hitTimer = self.hitCooldown
    return true
end

function StgGate:Update(dt)
    self.hitTimer = math.max(0, self.hitTimer - math.max(0, tonumber(dt) or 0))
end

--- 穿门结算：执行当前档位效果
--- @return boolean 是否成功触发
function StgGate:OnPass()
    if self.hasTriggered then
        return false
    end
    self.hasTriggered = true
    if not self:IsUnlocked() then return false end
    if self:IsChoiceGate() then
        return "choice"
    end
    if self:IsHeroChargeGate() then
        return self.logic:ChargeHeroSkill(self.trapConfig.heroChargeSlot or 0, self.trapConfig.heroChargePercent)
    end

    if self.effectId == nil or self.effectId == "" then
        Logger.Log('#STG# 门穿过了但无对应效果 value=' .. tostring(self.value) .. ' trapId=' .. tostring(self.trapConfig.trapId))
        return false
    end

    return self.logic:ExecuteEffect(self.effectId)
end

function StgGate:IsHeroChargeGate()
    return (tonumber(self.trapConfig.heroChargePercent) or 0) > 0
end

function StgGate:IsChoiceGate()
    return tostring(self.trapConfig.choiceMode or "none") == "three"
end

function StgGate:GetChoicePool()
    local pool = {}
    for rawId in string.gmatch(tostring(self.trapConfig.choicePool or ""), "[^,]+") do
        local id = string.gsub(rawId, "^%s*(.-)%s*$", "%1")
        if id ~= "" then table.insert(pool, id) end
    end
    return pool
end

--- 取当前显示文本（UI 用）
function StgGate:GetDisplayText()
    if self.effectId == nil then
        return tostring(self.value)
    end
    local meta = require("Game.STG.Trigger.StgTriggerEnum").EffectTable[self.effectId]
    if meta ~= nil and meta.text ~= nil then
        return meta.text
    end
    return tostring(self.value)
end

--- 正/负判定（UI 红蓝配色）
function StgGate:IsPositive()
    return self.value >= 0
end

return StgGate
