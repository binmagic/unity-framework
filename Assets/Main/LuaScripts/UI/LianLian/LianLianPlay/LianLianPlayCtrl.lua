--[[
-- 连连看游戏页控制器
-- 处理游戏逻辑交互
--]]

local LianLianManager = require "Game.LianLian.DataCenter.LianLianManager"

local LianLianPlayCtrl = BaseClass("LianLianPlayCtrl", UIBaseCtrl)

function LianLianPlayCtrl:__init()
    self.manager = nil
    self._inputLocked = false
end

--- 初始化游戏
function LianLianPlayCtrl:InitGame(part)
    -- 从管理器获取单例
    self.manager = LianLianManager:GetInstance()
    self.manager:startGame(part or 1)
end

--- 获取当前关卡
function LianLianPlayCtrl:GetPart()
    return self.manager and self.manager:getPart() or 1
end

--- 获取当前 HP
function LianLianPlayCtrl:GetHp()
    return self.manager and self.manager:getHp() or 0
end

--- 获取当前盘面行列数（供 View 绘制/居中）
--- @return number rows, number cols
function LianLianPlayCtrl:GetBoardSize()
    if not self.manager then return nil, nil end
    return self.manager:getBoardSize()
end

--- 点击牌面（只在同一层内配对；pos 带 layer）
function LianLianPlayCtrl:OnTileClick(pos)
    if not self.manager then return end
    -- 移动/消除动画进行中，拦截点击，避免状态错乱
    if self._inputLocked then return end

    local layer = pos.layer or 1

    -- 跨层规则：已有待配对选中，且这次点击的是「另一层」→ 立刻清除原选中，不发起新选中
    if self._activeLayer and self._activeLayer ~= layer then
        local prev = self.manager:getLayerData(self._activeLayer)
        if prev and #prev.item_checked >= 1 then
            self.manager:cancelChecked(self._activeLayer)
            self._activeLayer = nil
            return
        end
    end

    local ld = self.manager:getLayerData(layer)
    if not ld then return end
    local checked = ld.item_checked

    if #checked == 0 then
        -- 第一次选中，记录当前操作层
        self._activeLayer = layer
        self.manager:checkTile(1, pos)
    elseif #checked == 1 then
        if checked[1].r == pos.r and checked[1].c == pos.c then
            -- 点击同一张牌，取消选中
            self.manager:cancelChecked(layer)
        else
            -- 第二次选中，执行消除（先捕获两张牌位置，doClear 失败时会内部清空 item_checked）
            local posA = { r = checked[1].r, c = checked[1].c, layer = layer }
            local posB = { r = pos.r, c = pos.c, layer = layer }
            self.manager:checkTile(2, pos)
            local success, pathLine = self.manager:doClear(layer)
            if success then
                -- 消除成功：播放连线动画，然后删除牌面
                EventManager:GetInstance():Broadcast("LianLian_PlayClear", {
                    pathLine = pathLine,
                    posA = posA,
                    posB = posB,
                    layer = layer,
                })
            else
                -- 配对失败：闪烁反馈（扣血已在 doClear 内处理）
                EventManager:GetInstance():Broadcast("LianLian_MatchFail", {
                    posA = posA,
                    posB = posB,
                    layer = layer,
                })
            end
        end
    end
end

--- 消除动画结束后调用（作用于刚才消除的那一层）
function LianLianPlayCtrl:OnClearEnd(layer)
    if not self.manager then return end
    self.manager:afterClear(layer or self._activeLayer or 1)
end

--- 使用提示道具（默认当前操作层，缺省第1层）
function LianLianPlayCtrl:UseTip(layer)
    if not self.manager then return end
    return self.manager:useTip(layer or self._activeLayer or 1)
end

--- 使用洗牌道具（默认当前操作层，缺省第1层）
function LianLianPlayCtrl:UseShuffle(layer)
    if not self.manager then return end
    self.manager:useShuffle(layer or self._activeLayer or 1)
end

--- 使用加血道具
function LianLianPlayCtrl:UseHp()
    if not self.manager then return end
    self.manager:useHp()
end

--- 复活
function LianLianPlayCtrl:Revive()
    if not self.manager then return end
    self.manager:revive()
end

--- 进入下一关
function LianLianPlayCtrl:NextPart()
    if not self.manager then return end
    self.manager:nextPart()
    self:InitGame(self.manager:getPart())
end

--- 重玩当前关
function LianLianPlayCtrl:Replay()
    if not self.manager then return end
    self:InitGame(self.manager:getPart())
end

return LianLianPlayCtrl
