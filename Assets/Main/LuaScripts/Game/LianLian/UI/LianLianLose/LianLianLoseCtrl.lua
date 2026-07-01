local LianLianLoseCtrl = BaseClass("LianLianLoseCtrl", UIBaseCtrl)

function LianLianLoseCtrl:Retry()
    EventManager:GetInstance():Broadcast("LianLian_Replay")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianLose)
end

function LianLianLoseCtrl:Close()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianLose)
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianPlay)
end

return LianLianLoseCtrl
