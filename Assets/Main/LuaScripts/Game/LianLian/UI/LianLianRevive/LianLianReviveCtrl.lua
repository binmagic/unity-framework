local LianLianReviveCtrl = BaseClass("LianLianReviveCtrl", UIBaseCtrl)

function LianLianReviveCtrl:ReviveByVideo()
    EventManager:GetInstance():Broadcast("LianLian_Revive")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianRevive)
end

function LianLianReviveCtrl:ReviveByShare()
    EventManager:GetInstance():Broadcast("LianLian_Revive")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianRevive)
end

function LianLianReviveCtrl:GiveUp()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianRevive)
    UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianLose, { canRevive = false })
end

return LianLianReviveCtrl
