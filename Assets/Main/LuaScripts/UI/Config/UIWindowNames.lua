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

    -- 隆隆冒险号船舱
    UIShipCabin = "UIShipCabin",
    -- 船舱背景（解锁/升级的权威校验逻辑在它的 Ctrl 里，UIShipCabinCtrl 会 require 它）
    UIShipBackground = "UIShipBackground",
    -- 船舱详情面板
    UIShipCabinDetail = "UIShipCabinDetail",
    -- 建筑解锁/升级弹窗
    UIBuildingPanel = "UIBuildingPanel",
}

return ConstClass("UIWindowNames", UIWindowNames)