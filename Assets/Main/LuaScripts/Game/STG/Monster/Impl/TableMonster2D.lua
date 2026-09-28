---
--- STG 怪物子系统 — 台子/平台类静态物
--- 提炼自 ParkourBattle/Monster/MonsterImpl/TableMonster.lua 的核心语义：继承静态碰撞物的
--- 距离触发播放能力（对齐 ColliderMonster2D），额外增加血量文本显示和死亡触发效果。原版
--- 死亡时会从预设的英雄列表里随机预选目标（`PreSelectHeroUuid`，对接旧队伍系统触发单人技能/
--- buff/三选一等效果），2D 化后把"预选目标"这件事交给外部回调决定，不内置队伍概念——
--- 这个类只负责"死亡时触发一次 onDeathEvent 回调"，目标怎么选是调用方的事。
---
--- 用法：
---   local table_ = TableMonster2D.New(parentTransform, x, y, {
---       hp = 10, startAnimDistance = 0,
---       onHpTextChanged = function(displayHp, monster) --[[ 更新血量文本 ]] end,
---       onDeathEvent = function(deathEventId, monster) --[[ 触发预设效果 ]] end,
---       deathEventId = "eff_add_buff",
---   })
---
---@class TableMonster2D : ColliderMonster2D
local ColliderMonster2D = require "Game.STG.Monster.Impl.ColliderMonster2D"
local TableMonster2D = BaseClass("TableMonster2D", ColliderMonster2D)

--- @param cfg table 继承 ColliderMonster2D 全部字段，额外增加：
---   deathEventId       any     死亡时要触发的效果标识，含义由调用方解释
---   onHpTextChanged    fun(displayHp:number, monster:TableMonster2D)  受击后触发，displayHp 是 math.ceil 后的整数
---   onDeathEvent       fun(deathEventId:any, monster:TableMonster2D)  死亡时触发一次
function TableMonster2D:__init(parentTransform, x, y, cfg)
    ColliderMonster2D.__init(self, parentTransform, x, y, cfg)
    self.deathEventId = cfg and cfg.deathEventId
    self.onHpTextChanged = cfg and cfg.onHpTextChanged
    self.onDeathEvent = cfg and cfg.onDeathEvent
end

function TableMonster2D:GetGoName()
    return "TableMonster2D"
end

--- 覆写受击：血量文本显示用 math.ceil 取整（对齐原版 self.hpText:SetText(math.ceil(self.curBlood))）
--- @param damage number
--- @return boolean isDead
function TableMonster2D:TakeDamage(damage)
    local isDead = ColliderMonster2D.TakeDamage(self, damage)
    if not isDead and self.onHpTextChanged ~= nil then
        self.onHpTextChanged(math.ceil(self.hp), self)
    end
    return isDead
end

--- 覆写死亡：触发一次预设效果，具体目标预选逻辑（原版的"随机挑一个英雄"）交给外部回调决定
function TableMonster2D:OnDeath()
    if self.onDeathEvent ~= nil then
        self.onDeathEvent(self.deathEventId, self)
    end
end

return TableMonster2D
