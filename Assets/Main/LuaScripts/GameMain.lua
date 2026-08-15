--[[
-- [INPUT]: require Global.Global 拉起全局命名空间;依赖 UpdateManager/EventManager/TimerManager/UIManager 等框架单例与 LuaEntry、AppStartupLoading
-- [OUTPUT]: 对外提供全局 GameMain(Start 主入口,ShowTips/ShowMessage/OnApplicationPause/Focus、DispatchCSEvent 等 C# 回调)
-- [POS]: LuaScripts 根级 Lua 程序总入口,被 C# 侧 XLuaManager 启动后调用 Start,依次点火各框架管理器并交棒给加载状态机
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

-- 全局模块
require "Global.Global"

-- 定义为全局模块，整个lua程序的入口类
GameMain = {}

-- Lua脚本主入口
local function Start()
    Logger.Log("GameMain start.......")

    -- 初始化随机种子
    math.randomseed(os.time())

    -- 更新管理器放到第一个处理
    UpdateManager:GetInstance():Startup()
    EventManager:GetInstance()

    TimerManager:GetInstance():Startup()
    TimeUpManager:GetInstance():Startup()
    UIManager:GetInstance():Startup()

    -- 初始化 LuaEntry（全局数据入口）
    LuaEntry:Init()

    -- 启动加载状态机（最终状态会启动游戏）
    AppStartupLoading:GetInstance():Startup()
end

-- 退出
local function Exit()
    -- 销毁连连看游戏管理器
    local LianLianManager = require "Game.LianLian.Manager.LianLianManager"
    LianLianManager:Delete()

    UIManager:GetInstance():DestroyAllWindow()

    UIManager:GetInstance():Delete()
    TimerManager:GetInstance():Dispose()
    TimeUpManager:GetInstance():Dispose()
    UpdateManager:GetInstance():Dispose()
    EventManager:GetInstance():Delete()

    -- 销毁加载状态机和 LuaEntry
    AppStartupLoading:GetInstance():Delete()
    LuaEntry:Uninit()
end

local function ShowTips(msg)
    Logger.Log("ShowTips: " .. tostring(msg))
end

local function ShowMessage(tipText, btnNum, text1, text2, action1, action2, closeAction, titleText, isChangeImg)
    Logger.Log("ShowMessage: " .. tostring(tipText))
end

local function GetTemplateData(_type, itemId, name)
    Logger.Log("GetTemplateData: " .. tostring(_type) .. ", " .. tostring(itemId))
    return nil
end

local function OnApplicationPause(pause)
    Logger.Log("OnApplicationPause: " .. tostring(pause))
end

local function OnApplicationFocus(focus)
    Logger.Log("OnApplicationFocus: " .. tostring(focus))
end

local function DispatchCSEvent(eventId, userData)
    EventManager:GetInstance():DispatchCSEvent(eventId, userData)
end

GameMain.Start = Start
GameMain.Exit = Exit
GameMain.ShowTips = ShowTips
GameMain.ShowMessage = ShowMessage
GameMain.GetTemplateData = GetTemplateData
GameMain.OnApplicationPause = OnApplicationPause
GameMain.OnApplicationFocus = OnApplicationFocus
GameMain.DispatchCSEvent = DispatchCSEvent

return GameMain
