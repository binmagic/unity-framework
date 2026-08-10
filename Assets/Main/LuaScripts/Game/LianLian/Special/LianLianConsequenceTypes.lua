--[[
-- 消除后果类型索引：启动时统一 require 所有 Consequences，触发各自 register 自注册。
-- 加新后果 = 在此追加一行 require。
-- 单独成文件（而非放注册表里 require）是为了打破 注册表<->Consequences 的循环加载。
--]]

require "Game.LianLian.Special.Consequences.RareDrop"
require "Game.LianLian.Special.Consequences.StepLimit"
require "Game.LianLian.Special.Consequences.Tide"

return true
