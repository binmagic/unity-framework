local LianLianManager = require "Game.LianLian.Manager.LianLianManager"

local LianLianPlayCtrl = BaseClass("LianLianPlayCtrl", UIBaseCtrl)

function LianLianPlayCtrl:__init()
    self.manager = nil
end

function LianLianPlayCtrl:InitGame(part)
    self.manager = LianLianManager:GetInstance()
    self.manager:startGame(part or 1)
end

function LianLianPlayCtrl:GetPart()
    return self.manager and self.manager:getPart() or 1
end

function LianLianPlayCtrl:GetHp()
    return self.manager and self.manager:getHp() or 0
end

function LianLianPlayCtrl:OnTileClick(pos)
    if not self.manager then return end
    local checked = self.manager.state.item_checked
    if #checked == 0 then
        self.manager:checkTile(1, pos)
    elseif #checked == 1 then
        if checked[1].r == pos.r and checked[1].c == pos.c then
            self.manager:cancelChecked()
        else
            self.manager:checkTile(2, pos)
            local success, pathLine = self.manager:doClear()
            if success then
                EventManager:GetInstance():Broadcast("LianLian_PlayClear", {
                    pathLine = pathLine,
                    posA = checked[1],
                    posB = checked[2],
                })
            end
        end
    end
end

function LianLianPlayCtrl:OnClearEnd()
    if not self.manager then return end
    self.manager:afterClear()
end

function LianLianPlayCtrl:UseTip()
    if not self.manager then return end
    return self.manager:useTip()
end

function LianLianPlayCtrl:UseShuffle()
    if not self.manager then return end
    self.manager:useShuffle()
end

function LianLianPlayCtrl:UseHp()
    if not self.manager then return end
    self.manager:useHp()
end

function LianLianPlayCtrl:Revive()
    if not self.manager then return end
    self.manager:revive()
end

function LianLianPlayCtrl:NextPart()
    if not self.manager then return end
    self.manager:nextPart()
    self:InitGame(self.manager:getPart())
end

function LianLianPlayCtrl:Replay()
    if not self.manager then return end
    self:InitGame(self.manager:getPart())
end

return LianLianPlayCtrl
