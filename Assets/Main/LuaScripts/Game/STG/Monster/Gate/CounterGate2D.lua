---
--- STG 怪物子系统 — 单侧区间累计门（对应原版 UpgradeableGate2）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/UpgradeableGate2.lua：命中即计数 +1（可正可负，
--- 取决于调用方传入的 damage 符号），按当前计数值在一张 {min, max, effectId} 区间表里找当前
--- 应生效的效果；如果计数值不落在任何区间内，则没有效果（对齐原版"没落到任何区间碰撞则没有
--- 任何效果"）。这是 UpgradeableGate（血量阶梯门，见 UpgradeableGate2D.lua）的平级兄弟，
--- 两者容易混淆但不是同一种门——阶梯门是"打到 0 就跳到下一档"，这个是"累计值落在哪个区间"。
--- 与 DuetGate2D 共享同一份区间匹配算法（RangeMatchUtil），DuetGate2D 本质上是两个
--- CounterGate2D 拼在一起、外加几何形变表现。
---
--- 用法：
---   local gate = CounterGate2D.New(parentTransform, x, y, {
---       ranges = { {min=-5, max=-1, effectId="eff_minus"}, {min=1, max=5, effectId="eff_plus5"} },
---       onValueChanged = function(value, effectId, gate) --[[ 更新文案/图标 ]] end,
---   })
---   gate:OnHit(1)   -- 每次命中调用，传入本次计数增量
---
---@class CounterGate2D : TriggerGate2D
local TriggerGate2D = require "Game.STG.Monster.Gate.TriggerGate2D"
local RangeMatchUtil = require "Game.STG.Monster.Gate.RangeMatchUtil"
local CounterGate2D = BaseClass("CounterGate2D", TriggerGate2D)

--- @param cfg table 继承 TriggerGate2D 全部字段，额外增加：
---   ranges           table[] { {min, max, effectId}, ... } 按 min 升序排列
---   initialValue     number  初始计数值，默认 0（对齐原版取 para 第一档的默认展示值时也是从 0 开始累计）
---   onValueChanged   fun(value:number, effectId:any, gate:CounterGate2D)  每次命中后触发
function CounterGate2D:__init(parentTransform, x, y, cfg)
    TriggerGate2D.__init(self, parentTransform, x, y, cfg)
    self.ranges = (cfg and cfg.ranges) or {}
    self.value = (cfg and cfg.initialValue) or 0
    self.onValueChanged = cfg and cfg.onValueChanged
    self.effectId = RangeMatchUtil.Match(self.ranges, self.value)
end

function CounterGate2D:GetGoName()
    return "CounterGate2D"
end

--- 命中：累加计数值，重新匹配区间效果，变化后通知外部刷新表现
--- @param delta number 本次命中的计数增量，通常传 1 或 -1
function CounterGate2D:OnHit(delta)
    if self.isDead then
        return
    end
    self.value = self.value + (delta or 1)
    self.effectId = RangeMatchUtil.Match(self.ranges, self.value)
    if self.onValueChanged ~= nil then
        self.onValueChanged(self.value, self.effectId, self)
    end
end

--- 机体飞越门体时结算：直接用当前匹配到的效果，没有落在任何区间则不触发
function CounterGate2D:Trigger()
    if self.effectId ~= nil and self.onTrigger ~= nil then
        self.onTrigger(self.effectId, self)
    end
end

function CounterGate2D:GetValue()
    return self.value
end

function CounterGate2D:GetEffectId()
    return self.effectId
end

return CounterGate2D
