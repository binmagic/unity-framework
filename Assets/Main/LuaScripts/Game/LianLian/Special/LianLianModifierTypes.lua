--[[
-- 格子修饰器类型索引：启动时统一 require 所有 Modifiers，触发各自 register 自注册。
-- 加新修饰器 = 在此追加一行 require。
-- 单独成文件（而非放注册表里 require）是为了打破 注册表<->Modifiers 的循环加载。
--]]

require "Game.LianLian.Special.Modifiers.Vine"

return true
