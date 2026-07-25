--[[
-- Debug 面板控制器
-- 中介 View 与 LianLianManager，遵守 View → Ctrl → Manager 的 MVC 流程
--]]

local LianLianManager = require "Game.LianLian.DataCenter.LianLianManager"

local LianLianDebugCtrl = BaseClass("LianLianDebugCtrl", UIBaseCtrl)

function LianLianDebugCtrl:__init()
    self.manager = nil
end

--- 直传版：按输入的 行/列/方向/叠加层数 直接生成（图案种类数用默认 KIND_MAX）
--- @param rows number 行数
--- @param cols number 列数
--- @param direction string 移动方向
--- @param layer number 每格叠加层数
function LianLianDebugCtrl:Regen(rows, cols, direction, layer)
    self.manager = LianLianManager:GetInstance()
    -- kindLimit 传 nil → Manager 内 clamp 成 KIND_MAX（种类不限）
    self.manager:startGameCustom(rows, cols, nil, direction, layer)
end

--- 配置池版：只传 level，其余从 LEVEL_BOARD_CONFIG 读
--- @param level number 分层(难度档位)
function LianLianDebugCtrl:RegenByLevel(level)
    self.manager = LianLianManager:GetInstance()
    self.manager:startGameByLevel(level)
end

--- 获取当前盘面参数（供输入框/下拉默认值显示）
--- @return number rows, number cols, number part, string direction
function LianLianDebugCtrl:GetBoardInfo()
    self.manager = LianLianManager:GetInstance()
    local rows, cols = self.manager:getBoardSize()
    return rows, cols, self.manager:getPart(), self.manager:getDirection()
end

--- 提示：高亮「当前可操作层」的一对可消除的牌（顶层消完后自动下移到下一层）
function LianLianDebugCtrl:UseTip()
    self.manager = LianLianManager:GetInstance()
    self.manager:useTip(self.manager:getTopActiveLayer())
end

--- 重排：洗牌「当前可操作层」的棋盘（顶层消完后自动下移到下一层）
function LianLianDebugCtrl:UseShuffle()
    self.manager = LianLianManager:GetInstance()
    self.manager:useShuffle(self.manager:getTopActiveLayer())
end

--- 类型-1：合并「当前可操作层」的一种元素（顶层消完后自动下移到下一层）
function LianLianDebugCtrl:DecreaseKind()
    self.manager = LianLianManager:GetInstance()
    self.manager:decreaseKind(self.manager:getTopActiveLayer())
end

--- 读「全消揭示」遮挡规则开关
function LianLianDebugCtrl:GetFullClearReveal()
    self.manager = LianLianManager:GetInstance()
    return self.manager:getFullClearReveal()
end

--- 设「全消揭示」遮挡规则开关（Manager 内部广播，PlayView 实时刷新遮挡）
function LianLianDebugCtrl:SetFullClearReveal(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setFullClearReveal(v)
end

--- 读「保证可解」开关
function LianLianDebugCtrl:GetEnsureSolvable()
    self.manager = LianLianManager:GetInstance()
    return self.manager:getEnsureSolvable()
end

--- 设「保证可解」开关（改后下次 Gen 生效）
function LianLianDebugCtrl:SetEnsureSolvable(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setEnsureSolvable(v)
end

return LianLianDebugCtrl
