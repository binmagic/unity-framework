local LianLianWinCtrl = BaseClass("LianLianWinCtrl", UIBaseCtrl)

function LianLianWinCtrl:NextLevel()
    -- 通知游戏页进入下一关
    EventManager:GetInstance():Broadcast("LianLian_NextPart")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianWin)
end

function LianLianWinCtrl:Share()
    -- TODO: 调用分享接口
end

return LianLianWinCtrl
