--[[
-- [INPUT]: 依赖 Framework 的 ConstClass 做只读包装
-- [OUTPUT]: 返回只读 UIWindowNames 常量表（同时注入全局），把每个窗口登记为 Name=\"Name\" 同名常量
-- [POS]: UI 模块的窗口名常量表，与 UIConfig 路由表配对使用；新增窗口先在此登记名字，供 UIManager:OpenWindow 与引导等按名引用，避免硬编码字符串
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-11-30
-- UI窗口名字定义，手动添加
--]]

---@class UIWindowNames
UIWindowNames = {
    -- 连连看游戏
    LianLianMain = "LianLianMain",
    LianLianPlay = "LianLianPlay",
    LianLianWin = "LianLianWin",
    LianLianLose = "LianLianLose",
    LianLianRevive = "LianLianRevive",
    LianLianLevelup = "LianLianLevelup",
    LianLianSettings = "LianLianSettings",
    LianLianSkin = "LianLianSkin",
    LianLianToast = "LianLianToast",
    LianLianTest = "LianLianTest",
    LianLianDebug = "LianLianDebug",
    LianLianUnlock = "LianLianUnlock",
}

return ConstClass("UIWindowNames", UIWindowNames)