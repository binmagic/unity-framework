
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
end

-- 退出
local function Exit()
    UIManager:GetInstance():DestroyAllWindow()

    UIManager:GetInstance():Delete()
    TimerManager:GetInstance():Dispose()
    TimeUpManager:GetInstance():Dispose()
    UpdateManager:GetInstance():Dispose()
    EventManager:GetInstance():Delete()

    return
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
