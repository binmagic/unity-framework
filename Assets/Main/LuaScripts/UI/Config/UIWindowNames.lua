--[[
-- added by wsh @ 2017-11-30
-- UI窗口名字定义，手动添加
--]]

---@class UIWindowNames
UIWindowNames = {
    -- 连连看游戏
    UILianLianMain = "UILianLianMain",
    UILianLianPlay = "UILianLianPlay",
    UILianLianWin = "UILianLianWin",
    UILianLianLose = "UILianLianLose",
    UILianLianRevive = "UILianLianRevive",
    UILianLianLevelup = "UILianLianLevelup",
    UILianLianSettings = "UILianLianSettings",
    UILianLianSkin = "UILianLianSkin",
    UILianLianToast = "UILianLianToast",
    UILianLianTest = "UILianLianTest",

    -- 通用消息提示条（UIUtil.ShowTips 依赖它，缺失会让所有提示调用报错）
    UICommonMessageBar = "UICommonMessageBar",
}

return ConstClass("UIWindowNames", UIWindowNames)