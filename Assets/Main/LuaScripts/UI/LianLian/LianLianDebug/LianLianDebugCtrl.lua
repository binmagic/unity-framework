--[[
-- Debug 面板控制器
-- 中介 View 与 LianLianManager，遵守 View → Ctrl → Manager 的 MVC 流程
--]]

local LianLianManager = require "Game.LianLian.DataCenter.LianLianManager"

local LianLianDebugCtrl = BaseClass("LianLianDebugCtrl", UIBaseCtrl)

function LianLianDebugCtrl:__init()
    self.manager = nil
end

--- 按输入参数重新生成盘面（校验/生成逻辑均在 Manager 内）
--- @param rows number 行数
--- @param cols number 列数
--- @param layer number 关卡/层级
function LianLianDebugCtrl:Regen(rows, cols, layer, moveType)
    self.manager = LianLianManager:GetInstance()
    self.manager:startGameCustom(rows, cols, layer, moveType)
end

--- 获取当前盘面参数（供输入框/下拉默认值显示）
--- @return number rows, number cols, number part, string direction
function LianLianDebugCtrl:GetBoardInfo()
    self.manager = LianLianManager:GetInstance()
    local rows, cols = self.manager:getBoardSize()
    return rows, cols, self.manager:getPart(), self.manager:getDirection()
end

--- 提示：高亮一对可消除的牌（复用现有道具逻辑）
function LianLianDebugCtrl:UseTip()
    self.manager = LianLianManager:GetInstance()
    self.manager:useTip()
end

--- 重排：洗牌当前盘面（复用现有道具逻辑）
function LianLianDebugCtrl:UseShuffle()
    self.manager = LianLianManager:GetInstance()
    self.manager:useShuffle()
end

--- 类型-1：图案种类数减 1，按当前行列/方向重新生成盘面
function LianLianDebugCtrl:DecreaseKind()
    self.manager = LianLianManager:GetInstance()
    self.manager:decreaseKind()
end

return LianLianDebugCtrl
