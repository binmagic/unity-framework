---
--- STG 怪物子系统 — 轮胎堆木桶
--- 提炼自 ParkourBattle/Monster/MonsterImpl/BucketTyre.lua 的核心语义：继承 Bucket2D，额外
--- 按血量百分比阈值表分阶段减少"轮胎堆叠层数"的外观表现（原版按 `prefab_change` 阈值表切换
--- 子节点可见性，2D 版本改成通知外部当前应显示几层，具体怎么摆放堆叠层交给调用方）。
--- 阶段判定算法与 PushCarZombie2D:_CalcStage 思路一致（两者原本就是同一套"血量百分比找阶段"
--- 算法在不同类型上的应用），但作为独立文件保留，不强行合并成共享基类。
---
--- 用法：
---   local tyre = BucketTyre2D.New(parentTransform, x, y, {
---       hpMin = 30, hpMax = 30,
---       stageThresholds = { 0.8, 0.6, 0.4, 0.2 },  -- 5 层，每掉一档少一层
---       onStageChanged = function(stage, bucket) --[[ 更新可见层数 ]] end,
---   })
---
---@class BucketTyre2D : Bucket2D
local Bucket2D = require "Game.STG.Monster.Impl.Bucket2D"
local BucketTyre2D = BaseClass("BucketTyre2D", Bucket2D)

--- @param cfg table 继承 Bucket2D 全部字段，额外增加：
---   stageThresholds  number[]  从高到低排列的血量百分比阈值
---   onStageChanged   fun(stage:number, bucket:BucketTyre2D)  阶段变化时触发（含初始化那一次）
function BucketTyre2D:__init(parentTransform, x, y, cfg)
    Bucket2D.__init(self, parentTransform, x, y, cfg)
    self.stageThresholds = (cfg and cfg.stageThresholds) or {}
    self.onStageChanged = cfg and cfg.onStageChanged
    self.curStage = 1

    -- 对齐原版 OnLoadComplete 里 isInit=true 的初次刷新（不算"变化"但要把初始层数告知外部）
    if self.onStageChanged ~= nil then
        self.onStageChanged(self.curStage, self)
    end
end

function BucketTyre2D:GetGoName()
    return "BucketTyre2D"
end

--- 与 PushCarZombie2D:_CalcStage 同一套算法：从高到低比较阈值表，命中第一个满足的档位
function BucketTyre2D:_CalcStage()
    local percent = self.hp / self.maxHp
    for i, threshold in ipairs(self.stageThresholds) do
        if percent >= threshold then
            return i
        end
    end
    return #self.stageThresholds + 1
end

--- 覆写受击：扣血后检查阶段变化，非初始化场景下变化才触发回调（对齐原版 isInit 参数区分）
--- @param damage number
--- @return boolean isDead
function BucketTyre2D:TakeDamage(damage)
    local isDead = Bucket2D.TakeDamage(self, damage)
    if not isDead then
        local newStage = self:_CalcStage()
        if newStage ~= self.curStage then
            self.curStage = newStage
            if self.onStageChanged ~= nil then
                self.onStageChanged(newStage, self)
            end
        end
    end
    return isDead
end

return BucketTyre2D
