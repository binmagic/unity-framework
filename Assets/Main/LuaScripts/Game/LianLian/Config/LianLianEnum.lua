--[[
-- 连连看枚举定义
-- 从 Cocos 项目 _enum.js 迁移
--]]

local LianLianEnum = {
    -- 移动方向
    MoveDirection = {
        NONE = "",
        LEFT = "left",
        RIGHT = "right",
        UP = "up",
        DOWN = "down",
        DIVIDE_LEFT_RIGHT = "divide_left_right",
        DIVIDE_UP_DOWN = "divide_up_down",
        FLOCK_LEFT_RIGHT = "flock_left_right",
        FLOCK_UP_DOWN = "flock_up_down",
    },

    -- 游戏状态
    GameState = {
        IDLE = 0,
        PLAYING = 1,
        ANIMATING = 2,
        PAUSED = 3,
        GAME_OVER = 4,
    },

    -- 道具类型
    CardType = {
        TIP = 1,        -- 提示
        SHUFFLE = 2,    -- 洗牌
        HP = 3,         -- 加血
    },
}

return LianLianEnum
