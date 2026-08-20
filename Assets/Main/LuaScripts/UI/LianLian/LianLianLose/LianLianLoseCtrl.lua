local LianLianLoseCtrl = BaseClass("LianLianLoseCtrl", UIBaseCtrl)

function LianLianLoseCtrl:Retry()
    EventManager:GetInstance():Broadcast("LianLian_Replay")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianLose)
end

function LianLianLoseCtrl:Close()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianLose)
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianPlay)
end

function LianLianLoseCtrl:Share()
    -- TODO: 调用分享接口
end

return LianLianLoseCtrl
