--[[
-- 连连看游戏页控制器
-- 处理游戏逻辑交互
--]]

local LianLianManager = require "Game.LianLian.Manager.LianLianManager"

local LianLianPlayCtrl = BaseClass("LianLianPlayCtrl", UIBaseCtrl)

function LianLianPlayCtrl:__init()
    self.manager = nil
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

--- 点击牌面
function LianLianPlayCtrl:OnTileClick(pos)
    if not self.manager then return end

    local checked = self.manager.state.item_checked
    if #checked == 0 then
        -- 第一次选中
        self.manager:checkTile(1, pos)
    elseif #checked == 1 then
        if checked[1].r == pos.r and checked[1].c == pos.c then
            -- 点击同一张牌，取消选中
            self.manager:cancelChecked()
        else
            -- 第二次选中，执行消除
            self.manager:checkTile(2, pos)
            local success, pathLine = self.manager:doClear()
            if success then
                -- 消除成功：播放连线动画，然后删除牌面
                EventManager:GetInstance():Broadcast("LianLian_PlayClear", {
                    pathLine = pathLine,
                    posA = checked[1],
                    posB = checked[2],
                })
            end
        end
    end
end

--- 消除动画结束后调用
function LianLianPlayCtrl:OnClearEnd()
    if not self.manager then return end
    self.manager:afterClear()
end

--- 使用提示道具
function LianLianPlayCtrl:UseTip()
    if not self.manager then return end
    return self.manager:useTip()
end

--- 使用洗牌道具
function LianLianPlayCtrl:UseShuffle()
    if not self.manager then return end
    self.manager:useShuffle()
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
