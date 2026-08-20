--[[
-- 特殊元素类型索引：启动时统一 require 所有 Types，触发各自 register 自注册。
-- 加新特殊元素 = 在此追加一行 require。
-- 单独成文件（而非放注册表里 require）是为了打破 注册表<->Types 的循环加载。
--]]

require "Game.LianLian.Special.Types.Rocket"

return true
