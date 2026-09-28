---
--- STG 怪物子系统 — 一次性拾取触发器（对应原版 TriggerGoods）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/TriggerGoods.lua 的核心语义：碰到即拾取一次，
--- 不需要区间表/阶梯表（原版是"道具型 trigger，效果为获得物品或资源"），拾取后播放溶解
--- 表现并从场上移除。去掉了原实现里的 Animator 播放（`Eff_beizengmen_jinbi_xiaoshi`）、
--- 旧战斗框架的目标查找（`CitySpaceManTrigger`/`battleMgr:GetUnit`），拾取表现和目标判定都
--- 交给外部回调决定。
---
--- 用法：
---   local pickup = PickupTrigger2D.New(parentTransform, x, y, {
---       rewardId = "gold_10",
---       onPickup = function(rewardId, pickup) --[[ 发放奖励、播放溶解特效 ]] end,
---   })
---   pickup:CheckPass(layerMask)  -- 每帧检测是否被拾取（复用 TriggerGate2D 的圆形检测）
---
---@class PickupTrigger2D : TriggerGate2D
local TriggerGate2D = require "Game.STG.Monster.Gate.TriggerGate2D"
local PickupTrigger2D = BaseClass("PickupTrigger2D", TriggerGate2D)

--- @param cfg table 继承 TriggerGate2D 全部字段（`effectId` 由 `rewardId` 代替表达更贴切的语义），
---   rewardId  any  拾取后要发放的奖励标识，含义由调用方解释
---   onPickup  fun(rewardId:any, pickup:PickupTrigger2D)  拾取时触发一次
function PickupTrigger2D:__init(parentTransform, x, y, cfg)
    TriggerGate2D.__init(self, parentTransform, x, y, cfg)
    self.rewardId = cfg and cfg.rewardId
end

function PickupTrigger2D:GetGoName()
    return "PickupTrigger2D"
end

--- 覆写触发：直接发放奖励，不查效果表（对齐原版"道具型 trigger 不需要区间/阶梯判定"）
function PickupTrigger2D:Trigger()
    if self.hasTriggered then
        return
    end
    self.hasTriggered = true
    if self.cfg and self.cfg.onPickup ~= nil then
        self.cfg.onPickup(self.rewardId, self)
    end
    self:TakeDamage(self.hp)
end

return PickupTrigger2D
