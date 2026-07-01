local LianLianMainCtrl = BaseClass("LianLianMainCtrl", UIBaseCtrl)

function LianLianMainCtrl:StartGame()
    UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianPlay)
end

function LianLianMainCtrl:OpenSettings()
    UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianSettings)
end

function LianLianMainCtrl:OpenSkin()
    UIManager:GetInstance():OpenWindow(UIWindowNames.UILianLianSkin)
end

return LianLianMainCtrl
