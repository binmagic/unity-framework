local LianLianWinCtrl = BaseClass("LianLianWinCtrl", UIBaseCtrl)

function LianLianWinCtrl:NextLevel()
    EventManager:GetInstance():Broadcast("LianLian_NextPart")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianWin)
end

return LianLianWinCtrl
