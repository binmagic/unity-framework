local LianLianLevelupCtrl = BaseClass("LianLianLevelupCtrl", UIBaseCtrl)

function LianLianLevelupCtrl:Continue()
    EventManager:GetInstance():Broadcast("LianLian_NextPart")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UILianLianLevelup)
end

return LianLianLevelupCtrl
