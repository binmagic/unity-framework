--[[
-- 连连看运行时状态
-- 从 Cocos 项目 core.state.js 迁移
--]]

local LianLianConst = require "Game.LianLian.Config.LianLianConst"

local LianLianState = {}

--- 创建新的游戏状态
function LianLianState.New()
    return {
        grid = {},              -- 棋盘数据 {["r_c"] = {r, c, id, ...}}
        items = {},             -- 牌面 UI 节点引用
        item_checked = {},      -- 当前选中的牌位列表
        part = 1,               -- 当前关卡 (Part)
        hp = LianLianConst.HP_NUM,  -- 当前生命值
        revive_times = 0,       -- 本局已复活次数
        card_used = {},         -- 本局道具使用记录
        level = 0,              -- 当前层级 (Layer)
        isPlaying = false,      -- 是否在游戏中
        startTime = 0,          -- 开始时间
        endTime = 0,            -- 结束时间
    }
end

--- 重置状态为新一局
function LianLianState.reset(state)
    state.grid = {}
    state.items = {}
    state.item_checked = {}
    state.hp = LianLianConst.HP_NUM
    state.revive_times = 0
    state.card_used = {}
    state.isPlaying = false
    state.startTime = 0
    state.endTime = 0
end

return LianLianState
