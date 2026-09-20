---
--- 探险玩法 战斗 — 触发效果注册表
--- 参考 barrel（D:\UnityProject\barrel）TriggerEventManager 的设计模式：用 type 字段
--- 查表调度效果处理函数，门/桶命中时不直接写死逻辑，只管调这里。
--- 第二期加新效果类型（比如换武器、加护盾）只需要在 Handlers 里加一个函数，
--- 不用改 GateComponent/BucketComponent 本身。
---
--- 不依赖 Unity API 本身（效果的实际执行通过传入的 context 回调完成），
--- 可用 D:\lua 桩环境单测调度是否命中正确的 handler。
---
local TriggerEventManager = {}

--- @param triggerMeta table { id, type, para, icon } 来自 PlaneTrigger_Config
--- @param context table 由调用方（View）提供的执行上下文，包含：
---   AddWingman(count) / RemoveWingman(count) / AddGold(count) / AddWingmanSupply(count)
---   worldX, worldY: 触发点位置（用于飞金币动画等表现，首期可不用）
local Handlers = {
    AddWingman = function(triggerMeta, context)
        local count = tonumber(triggerMeta.para) or 0
        if count > 0 and context.AddWingman then
            context.AddWingman(count)
        end
    end,

    RemoveWingman = function(triggerMeta, context)
        local count = tonumber(triggerMeta.para) or 0
        if count > 0 and context.RemoveWingman then
            context.RemoveWingman(count)
        end
    end,

    DropGold = function(triggerMeta, context)
        local count = tonumber(triggerMeta.para) or 0
        if count > 0 and context.AddGold then
            context.AddGold(count)
        end
    end,

    DropWingmanSupply = function(triggerMeta, context)
        local count = tonumber(triggerMeta.para) or 0
        if count > 0 and context.AddWingmanSupply then
            context.AddWingmanSupply(count)
        end
    end,
}

--- 执行一个触发效果，triggerMeta 为 nil 时静默跳过（比如敌机没有掉落配置）
function TriggerEventManager.Execute(triggerMeta, context)
    if triggerMeta == nil then
        return
    end

    local handler = Handlers[triggerMeta.type]
    if handler == nil then
        Logger.LogError('#PlaneBattle# 策划配置错误！未注册的触发效果类型！type:' .. tostring(triggerMeta.type))
        return
    end

    handler(triggerMeta, context)
end

--- 注册新效果类型（第二期扩展用，避免直接改本文件内部表）
function TriggerEventManager.Register(typeName, handlerFn)
    Handlers[typeName] = handlerFn
end

return TriggerEventManager
