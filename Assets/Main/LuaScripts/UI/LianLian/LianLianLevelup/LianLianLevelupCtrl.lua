local LianLianLevelupCtrl = BaseClass("LianLianLevelupCtrl", UIBaseCtrl)

function LianLianLevelupCtrl:Continue()
    EventManager:GetInstance():Broadcast("LianLian_NextPart")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianLevelup)
end

return LianLianLevelupCtrl
