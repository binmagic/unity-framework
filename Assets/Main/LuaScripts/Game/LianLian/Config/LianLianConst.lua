--[[
-- 连连看游戏常量配置
-- 从 Cocos 项目 ccon.index.js 迁移
--]]

local LianLianConst = {
    -- 生命值
    HP_NUM = 3,             -- 初始生命值
    HP_MAX = 6,             -- 生命值上限

    -- 复活
    REVIVE_TIMES_MAX = 3,   -- 每局最大复活次数

    -- 棋盘
    GRID_WIDTH = 10,        -- 列数
    GRID_HEIGHT = 16,       -- 行数
    CELL_SIZE = 80,         -- 格子像素大小
    INTERIOR_COLS = 8,      -- 内部有效列数 (WIDTH - 2)
    INTERIOR_ROWS = 14,     -- 内部有效行数 (HEIGHT - 2)
    TOTAL_TILES = 112,      -- 满格牌数 (8 * 14)
    TOTAL_PAIRS = 56,       -- 满格对数

    -- 牌面
    KIND_MAX = 27,          -- 图案种类数

    -- 道具
    CARD_MAX = 3,           -- 每种道具持有上限
    CARD_TIP = 1,           -- 提示道具 ID
    CARD_SHUFFLE = 2,       -- 洗牌道具 ID
    CARD_HP = 3,            -- 加血道具 ID

    -- 教学关牌数
    TUTORIAL_PAIRS = 6,     -- 教学关 6 对 = 12 张牌

    -- 皮肤
    SKIN_COUNT = 9,         -- 皮肤总数
    SKIN_ITEMS = 27,        -- 每套皮肤收集品数

    -- 锁定组概率 (按关卡)
    LEVEL_LOCK_RATE = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0,
    },
}

return LianLianConst
