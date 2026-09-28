---
--- STG 怪物子系统 — 一次性触发门（三级门状态机 Tier 1）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/TriggerGate.lua：机体/子弹碰到门体即触发一次效果并消失。
--- 是 UpgradeableGate2D / DuetGate2D 的基类，Tier 2/3 在此基础上加"多次命中累计"的状态。
---
--- 用法：
---   local gate = TriggerGate2D.New(parentTransform, x, y, {
---       size = Vector2(60, 60), colliderRadius = 30,
---       effectId = "eff_plus1",
---       onTrigger = function(effectId) --[[ 执行效果 ]] end,
---   })
---   gate:CheckPass(layerMask)   -- 每帧调用，检测是否有目标进入门体范围
---
---@class TriggerGate2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local Collider2DUtil = require "Game.STG.Monster.Collider2DUtil"
local TriggerGate2D = BaseClass("TriggerGate2D", Monster2DBase)

--- @param parentTransform userdata
--- @param x number
--- @param y number
--- @param cfg table
---   size            userdata  Vector2，门体显示尺寸
---   colliderRadius  number    碰撞检测半径（用圆形检测，门体形状简单不需要盒形）
---   effectId        any       命中后要执行的效果标识，含义由调用方解释
---   spritePath      string    门体贴图
---   onTrigger       fun(effectId:any, gate:TriggerGate2D)  触发时回调
function TriggerGate2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    self.effectId = self.cfg.effectId
    self.onTrigger = self.cfg.onTrigger
    self.colliderRadius = self.cfg.colliderRadius or 30
    self.hasTriggered = false

    Monster2DBase.__init(self, parentTransform, x, y, 1, self.cfg.size)
end

function TriggerGate2D:GetGoName()
    return "TriggerGate2D"
end

function TriggerGate2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 每帧检测门体范围内是否有目标（机体/子弹），有则触发一次效果并标记完成。
--- 触发方式对齐原版"机体飞越判定"的语义，但用 Physics2D 圆形检测代替 3D Physics.OverlapBoxNonAlloc。
--- @param layerMask number 目标所在层，默认命中全部层
function TriggerGate2D:CheckPass(layerMask)
    if self.hasTriggered or self.isDead then
        return
    end

    local x, y = self:GetLocalPos()
    local _, cnt = Collider2DUtil.OverlapCircle({ x = x, y = y }, self.colliderRadius, layerMask)
    if cnt > 0 then
        self:Trigger()
    end
end

--- 直接触发（供外部按自己的碰撞判定方式调用，不强制走 CheckPass）
function TriggerGate2D:Trigger()
    if self.hasTriggered then
        return
    end
    self.hasTriggered = true
    if self.onTrigger ~= nil then
        self.onTrigger(self.effectId, self)
    end
    self:TakeDamage(self.hp)
end

--- 子弹命中门体时调用，Tier 1 一次性门不做累计，命中即触发（对齐原版行为）
function TriggerGate2D:OnHit(damage)
    self:Trigger()
end

return TriggerGate2D
