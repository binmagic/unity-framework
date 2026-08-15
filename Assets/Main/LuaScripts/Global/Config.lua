--[[
-- [INPUT]: 无外部依赖
-- [OUTPUT]: 对外提供 Config 表，暴露 Config.Debug 等全局编译期开关
-- [POS]: Global 模块的静态配置常量，真机出包时收口调试标记，被全局逻辑读取以切换行为
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-11-30
-- Lua全局配置
--]]

local Config = Config or {}

-- 调试模式：真机出包时关闭
Config.Debug = false

return Config