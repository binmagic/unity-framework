local LianLianReviveCtrl = BaseClass("LianLianReviveCtrl", UIBaseCtrl)

function LianLianReviveCtrl:ReviveByVideo()
    -- TODO: 播放激励视频广告
    -- 广告完成后调用
    EventManager:GetInstance():Broadcast("LianLian_Revive")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianRevive)
end

function LianLianReviveCtrl:ReviveByShare()
    -- TODO: 调用分享接口
    -- 分享完成后调用
    EventManager:GetInstance():Broadcast("LianLian_Revive")
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianRevive)
end

function LianLianReviveCtrl:GiveUp()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianRevive)
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianLose, { canRevive = false })
end

return LianLianReviveCtrl
