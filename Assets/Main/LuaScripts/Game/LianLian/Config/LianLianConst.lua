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

    -- 移动动画时长（秒）：未消元素从旧位滑到新位的耗时，与牌数无关
    MOVE_DURATION = 0.25,

    -- 按 level 分档的"允许移动方向池"。开新盘时从对应档位随机抽一种，锁定本盘。
    -- 越高 level，池里越难的方向越多；超过最大档位取最后一档（平台期）。
    -- "divide"/"flock" 是大类，抽中后再随机定子方向（左右/上下），见 LianLianPlay.rollDirection。
    LEVEL_MOVE_POOL = {
        [0] = { "" },                                                   -- 新手：不移动，先熟悉规则
        [1] = { "up", "down", "left", "right" },                        -- 入门：仅单向重力
        [2] = { "up", "down", "left", "right" },
        [3] = { "up", "down", "left", "right", "divide", "flock" },     -- 进阶：引入分散/聚拢
        [4] = { "", "up", "down", "left", "right", "divide", "flock" }, -- 熟练：全部（含无移动）
    },

    -- 按分层(level)的完整盘面配置：rows/cols/kindLimit/方向池。
    -- startGameByLevel(level) 只传一个 level，其余 4 项全从这里读；dirPool 随机抽一个方向。
    -- layer：棋盘上叠几层元素（默认 1 = 单层）
    LEVEL_BOARD_CONFIG = {
        [1] = { rows = 4,  cols = 4, kindLimit = 4,  layer = 1, dirPool = { "" } },
        [2] = { rows = 6,  cols = 6, kindLimit = 8,  layer = 1, dirPool = { "up", "down", "left", "right" } },
        [3] = { rows = 8,  cols = 8, kindLimit = 14, layer = 2, dirPool = { "up", "down", "left", "right", "divide_left_right", "divide_up_down" } },
        [4] = { rows = 14, cols = 8, kindLimit = 27, layer = 1, dirPool = { "up", "down", "left", "right", "divide_left_right", "divide_up_down", "flock_left_right", "flock_up_down" } },
    },
}

return LianLianConst
