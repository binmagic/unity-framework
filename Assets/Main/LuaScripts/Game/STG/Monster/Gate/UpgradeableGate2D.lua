---
--- STG 怪物子系统 — 阶梯升级门（三级门状态机 Tier 2）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/UpgradeableGate.lua：累计受击伤害，血量耗尽后
--- 切到下一档配置（阈值+效果），如此反复直到最后一档，不再自动消失（对齐原版"升满即长期存在"）。
--- 去掉了原实现里 `string.string2array2d_i` 的旧字符串解析格式，改成直接传 Lua table 配置。
---
--- 用法：
---   local gate = UpgradeableGate2D.New(parentTransform, x, y, {
---       tiers = {
---           { hp = 3,  effectId = "eff_plus1" },
---           { hp = 5,  effectId = "eff_plus2" },
---           { hp = 8,  effectId = "eff_plus5" },
---       },
---       onTierChanged = function(effectId, tierIndex, gate) --[[ 更新文案/图标 ]] end,
---   })
---   gate:OnHit(damage)   -- 子弹/攻击命中时调用
---
---@class UpgradeableGate2D : TriggerGate2D
local TriggerGate2D = require "Game.STG.Monster.Gate.TriggerGate2D"
local UpgradeableGate2D = BaseClass("UpgradeableGate2D", TriggerGate2D)

--- @param cfg table
---   tiers  table[]  { {hp:number, effectId:any}, ... } 按顺序升级，打完最后一档保持不变
---   onTierChanged  fun(effectId:any, tierIndex:number, gate:UpgradeableGate2D)
function UpgradeableGate2D:__init(parentTransform, x, y, cfg)
    TriggerGate2D.__init(self, parentTransform, x, y, cfg)

    self.tiers = (cfg and cfg.tiers) or {}
    self.tierIndex = 1
    self.onTierChanged = cfg and cfg.onTierChanged

    local firstTier = self.tiers[1]
    self.curBlood = firstTier and firstTier.hp or 1
    self.effectId = firstTier and firstTier.effectId or nil
end

function UpgradeableGate2D:GetGoName()
    return "UpgradeableGate2D"
end

--- 累计伤害，血量耗尽即升级到下一档；打完最后一档后维持在最后一档效果，不再消失
--- @param damage number
function UpgradeableGate2D:OnHit(damage)
    if self.isDead then
        return
    end
    self.curBlood = math.max(0, self.curBlood - (damage or 0))
    if self.curBlood <= 0 then
        self:_TryUpgrade()
    end
end

function UpgradeableGate2D:_TryUpgrade()
    if self.tierIndex >= #self.tiers then
        return  -- 已经是最后一档，保持现状（对齐原版"curBlood=IntMaxValue"的效果）
    end

    self.tierIndex = self.tierIndex + 1
    local tier = self.tiers[self.tierIndex]
    self.curBlood = tier.hp
    self.effectId = tier.effectId

    if self.onTierChanged ~= nil then
        self.onTierChanged(self.effectId, self.tierIndex, self)
    end
end

--- Tier 2 不会因为碰撞判定自动触发/消失，Trigger 仅用于外部主动结算当前档效果
function UpgradeableGate2D:Trigger()
    if self.onTrigger ~= nil then
        self.onTrigger(self.effectId, self)
    end
end

function UpgradeableGate2D:GetCurBlood()
    return self.curBlood
end

function UpgradeableGate2D:GetTierIndex()
    return self.tierIndex
end

return UpgradeableGate2D
