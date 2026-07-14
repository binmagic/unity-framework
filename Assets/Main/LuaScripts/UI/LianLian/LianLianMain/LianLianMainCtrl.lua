--[[
-- 连连看主菜单控制器
--]]

local LianLianManager = require "Game.LianLian.DataCenter.LianLianManager"

local LianLianMainCtrl = BaseClass("LianLianMainCtrl", UIBaseCtrl)

function LianLianMainCtrl:StartGame()
    -- 初始化游戏并打开游戏界面
    LianLianManager:GetInstance():startGame(1)
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianPlay)
end

function LianLianMainCtrl:OpenSettings()
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianSettings)
end

function LianLianMainCtrl:OpenSkin()
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianSkin)
end

return LianLianMainCtrl
