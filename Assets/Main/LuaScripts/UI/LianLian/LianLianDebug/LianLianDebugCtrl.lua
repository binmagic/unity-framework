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

--- 读「无限生成」开关
function LianLianDebugCtrl:GetInfiniteRegen()
    self.manager = LianLianManager:GetInstance()
    return self.manager:getInfiniteRegen()
end

--- 设「无限生成」开关（开启后全清不弹结算，按当前设定重生）
function LianLianDebugCtrl:SetInfiniteRegen(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setInfiniteRegen(v)
end

--- 读「棋盘格线显示」开关
function LianLianDebugCtrl:GetShowGridLine()
    self.manager = LianLianManager:GetInstance()
    return self.manager:getShowGridLine()
end

--- 设「棋盘格线显示」开关（Manager 广播后 PlayView 实时刷新）
function LianLianDebugCtrl:SetShowGridLine(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setShowGridLine(v)
end

--- 取所有已注册的特殊元素类型（供 Debug 下拉展示）
--- @return table 数组 { {type=, name=}, ... }
function LianLianDebugCtrl:GetSpecialTypeList()
    local LianLianSpecial = require "Game.LianLian.Special.LianLianSpecialRegistry"
    local list = {}
    for _, def in ipairs(LianLianSpecial.all()) do
        list[#list + 1] = { type = def.type, name = def.name or def.type }
    end
    return list
end

--- 把「最近点击的盘面格」设为某特殊类型（stype=nil 还原普通）
function LianLianDebugCtrl:ApplySpecialToSelected(stype)
    self.manager = LianLianManager:GetInstance()
    self.manager:setLastClickSpecial(stype)
end

--- 给「最近点击的盘面格」切换某修饰器（有则清、无则加），默认藤蔓
function LianLianDebugCtrl:ToggleModifierOnSelected(mtype)
    self.manager = LianLianManager:GetInstance()
    self.manager:toggleLastClickModifier(mtype or "vine")
end

--- 读「扣血」开关
function LianLianDebugCtrl:GetHpEnabled()
    self.manager = LianLianManager:GetInstance()
    return self.manager:getHpEnabled()
end

--- 设「扣血」开关（关闭后配对失败不扣血、不弹失败/复活页）
function LianLianDebugCtrl:SetHpEnabled(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setHpEnabled(v)
end

--- 读「稀有度掉落」后果是否启用
function LianLianDebugCtrl:GetDropEnabled()
    self.manager = LianLianManager:GetInstance()
    return self.manager:isConsequenceEnabled("rare_drop")
end

--- 开/关「稀有度掉落」C 类后果（Debug 测试用）
function LianLianDebugCtrl:SetDropEnabled(v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setConsequenceEnabled("rare_drop", v)
end

--- 通用：读某 C 类后果是否启用
function LianLianDebugCtrl:GetConsequenceEnabled(ctype)
    self.manager = LianLianManager:GetInstance()
    return self.manager:isConsequenceEnabled(ctype)
end

--- 通用：开/关某 C 类后果，并立即触发一次开局重置（限步初始化步数等）
function LianLianDebugCtrl:SetConsequenceEnabled(ctype, v)
    self.manager = LianLianManager:GetInstance()
    self.manager:setConsequenceEnabled(ctype, v)
    if v then self.manager:fireGameStartConsequences(1) end
end

return LianLianDebugCtrl
