---
--- STG 怪物子系统 — 纯装饰物
--- 提炼自 ParkourBattle/Monster/MonsterImpl/DecorateMonster.lua。
--- 忠实说明：原文件本体是完全空壳——`CalcHpByHurt`/`BeAttack`/`DropGold`/`Death`/`Freeze`/
--- `UnFreeze`/`OnGameStart`/`OnUpdate`/`TriggerEvent`/`DoColliderEffect`/`BeImpactFly` 全部是
--- 空实现，`IsDeath()` 永远返回 false——即"纯视觉展示，不参与任何战斗/交互逻辑"。
--- 这个文件同样很薄不是漏写，是如实还原原文件"什么都不做"这个事实。
--- 2D 版本同理：不覆写 Monster2DBase 的任何战斗方法，也不调用 TakeDamage（没有意义），
--- 只保留位置和贴图展示能力。
---
--- 用法：
---   local deco = DecorateMonster2D.New(parentTransform, x, y, { spritePath = "..." })
---
---@class DecorateMonster2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local DecorateMonster2D = BaseClass("DecorateMonster2D", Monster2DBase)

--- @param cfg table
---   spritePath  string  可选
---   sizeVec2    userdata  Vector2，可选
function DecorateMonster2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    Monster2DBase.__init(self, parentTransform, x, y, 1, self.cfg.sizeVec2)
end

function DecorateMonster2D:GetGoName()
    return "DecorateMonster2D"
end

function DecorateMonster2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 覆写受击：装饰物不参与战斗，永远无效（对齐原版 BeAttack/CalcHpByHurt 空实现）
--- @return boolean 永远返回 false，对齐原版 IsDeath() 恒为 false
function DecorateMonster2D:TakeDamage(damage)
    return false
end

--- 覆写 Update：装饰物不需要每帧逻辑（对齐原版 OnUpdate 空实现）
function DecorateMonster2D:Update(dt)
end

return DecorateMonster2D
