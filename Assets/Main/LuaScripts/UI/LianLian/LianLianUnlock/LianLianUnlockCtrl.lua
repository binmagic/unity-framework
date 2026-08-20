--[[
-- 解锁界面控制器
-- 中介 View 与 LianLianPlayer / LianLianTheme
--]]

local LianLianPlayer = require "Game.LianLian.DataCenter.LianLianPlayer"
local LianLianTheme = require "Game.LianLian.DataCenter.LianLianTheme"

local LianLianUnlockCtrl = BaseClass("LianLianUnlockCtrl", UIBaseCtrl)

function LianLianUnlockCtrl:__init()
    self.player = nil
end

--- 主题列表
function LianLianUnlockCtrl:GetThemeList()
    return LianLianTheme.GetThemeList()
end

--- 某主题元素数量
function LianLianUnlockCtrl:GetElementCount(themeId)
    return LianLianTheme.GetElementCount(themeId)
end

--- 元素图路径
function LianLianUnlockCtrl:GetElementSpritePath(themeId, elementId)
    return LianLianTheme.GetElementSpritePath(themeId, elementId)
end

--- 是否已解锁
function LianLianUnlockCtrl:IsUnlocked(themeId, elementId)
    self.player = LianLianPlayer:GetInstance()
    return self.player:IsElementUnlocked(themeId, elementId)
end

--- 解锁
function LianLianUnlockCtrl:Unlock(themeId, elementId)
    self.player = LianLianPlayer:GetInstance()
    self.player:UnlockElement(themeId, elementId)
end

return LianLianUnlockCtrl
