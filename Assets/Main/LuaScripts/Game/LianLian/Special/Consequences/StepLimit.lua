--[[
-- 消除后果：限步结算(step_limit) — C 类
-- 机制：开局给定步数上限，每成功消一对 -1；步数耗尽且盘面未清空 → 失败（gameOver）。
-- 经典关卡目标（也可换成限时，把"步"换成计时）。
--
-- 用到框架能力：onGameStart（开局重置步数）+ onAfterMatch（每对消耗）+
--             Manager 中性服务 initStepGoal/consumeStep（步数状态与广播）。
--]]

local LianLianConsequence = require "Game.LianLian.Special.LianLianConsequenceRegistry"

local STEP_LIMIT = 30   -- 步数上限（可后续由关卡配置覆盖）

LianLianConsequence.register({
    type = "step_limit",
    name = "限步结算",

    -- 开局：重置步数目标
    onGameStart = function(mgr, layer)
        mgr:initStepGoal(STEP_LIMIT)
    end,

    -- 每消一对：消耗 1 步；耗尽且还有牌 → 失败
    onAfterMatch = function(mgr, layer, ctx)
        local left = mgr:consumeStep(1)
        if left ~= nil and left <= 0 then
            -- 盘面已清空的胜利会先于此触发；这里只处理"还有牌但步数耗尽"
            if not mgr:isAllLayersEmpty() then
                mgr:gameOver()
            end
        end
    end,
})

return true
