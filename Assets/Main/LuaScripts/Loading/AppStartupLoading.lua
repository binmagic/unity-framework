---
--- AppStartupLoading - 游戏启动加载状态机
--- 管理从启动到进入游戏的完整加载流程
---

---@class AppStartupLoading
local AppStartupLoading = BaseClass("AppStartupLoading", Singleton)

-- 加载状态常量
local LoadingState =
{
    Permission = 1,
    CheckResVersion = 2,
    DownloadManifest = 3,
    LoadDataTable = 4,
    GetServerList = 5,
    ConnectGame = 6,
    Login = 7,
    PushInit = 8,
    LoadScene = 9,
    EnterGame = 10,
    Error = 11,
}

function AppStartupLoading:GetLoadingProgress()
    return self._currentMaxProgress
end

function AppStartupLoading:GetCurState()
    return self._currState
end

function AppStartupLoading:IsLoading()
    return self.isInLoading
end

function AppStartupLoading:__initState()
    self._stateList = {}
    self._currState = 0
    self._loadingState = nil
end

function AppStartupLoading:__init()
    self.isInLoading = false
    self._loadingProgress = 0
    self._currentMaxProgress = 0
    self._serverStateStop = false
    self._loginData = nil
    self._pauseTime = 0
    self:__initState()
    self.__update_handle = nil
end

function AppStartupLoading:__delete()
    self:Shutdown()
    table.clear(self._stateList)
    self._stateList = nil
end

-- 注册单个状态
function AppStartupLoading:RegisterState(stateId, stateObj)
    self._stateList[stateId] = stateObj
end

--- 启动加载流程
function AppStartupLoading:Startup()
    self.isInLoading = true
    self._loadingProgress = 0
    self._currentMaxProgress = 0

    -- 注册所有加载状态
    self:RegisterState(LoadingState.Permission, PermissionState.New(self))
    self:RegisterState(LoadingState.CheckResVersion, CheckResVersionState.New(self))
    self:RegisterState(LoadingState.DownloadManifest, DownloadManifestState.New(self))
    self:RegisterState(LoadingState.LoadDataTable, LoadDataTableState.New(self))
    self:RegisterState(LoadingState.GetServerList, GetServerListState.New(self))
    self:RegisterState(LoadingState.ConnectGame, ConnectGameState.New(self))
    self:RegisterState(LoadingState.Login, LoginState.New(self))
    self:RegisterState(LoadingState.PushInit, PushInitState.New(self))
    self:RegisterState(LoadingState.LoadScene, LoadSceneState.New(self))
    self:RegisterState(LoadingState.EnterGame, EnterGameState.New(self))

    -- 从第一个状态开始
    self:TransitionState(LoadingState.Permission)

    self:EnableUpdate()
end

--- 状态转换
function AppStartupLoading:TransitionState(newState, ...)
    if self._currState == newState then
        return
    end

    local oldState = self._loadingState
    if oldState ~= nil then
        oldState:OnExit()
    end

    self._currState = newState
    self._loadingState = self._stateList[newState]

    if self._loadingState ~= nil then
        self._loadingState:OnEnter({...})
    end
end

--- 停止加载流程
function AppStartupLoading:Stop()
    self:TransitionState(LoadingState.Error)
end

function AppStartupLoading:EnableUpdate()
    self:DisableUpdate()
    self.__update_handle = function() self:Update() end
    UpdateManager:GetInstance():AddUpdate(self.__update_handle)
end

function AppStartupLoading:DisableUpdate()
    if self.__update_handle then
        UpdateManager:GetInstance():RemoveUpdate(self.__update_handle)
        self.__update_handle = nil
    end
end

function AppStartupLoading:GetState(state)
    return self._stateList[state]
end

function AppStartupLoading:GetStateName(state)
    return tostring(state)
end

function AppStartupLoading:SetState(newState, ...)
    self:TransitionState(newState, ...)
end

function AppStartupLoading:Update()
    self:UpdateLoadingProgress()
    if self._loadingState ~= nil then
        self._loadingState:OnUpdate()
    end
end

function AppStartupLoading:UpdateLoadingProgress()
    self._currentMaxProgress = self._loadingProgress
end

--- 登录成功处理（由 NetworkManager:OnLogin 调用）
function AppStartupLoading:OnLogin(message)
    Logger.Log("AppStartupLoading:OnLogin")
    self._loginData = message

    -- 如果已经在 PushInit 状态，直接处理
    if self._currState == LoadingState.PushInit then
        self:OnPushInitOk()
    end
end

--- 检查服务器是否停服维护
function AppStartupLoading:CheckServerStateStop()
    return self._serverStateStop
end

--- 设置服务器停服状态
function AppStartupLoading:SetServerStateStop(isStop)
    self._serverStateStop = isStop
end

--- 登录错误处理（由 NetworkManager:OnLoginError 调用）
function AppStartupLoading:DoLoginError(errCode, errorMessage)
    Logger.LogError("AppStartupLoading:DoLoginError - " .. tostring(errCode) .. ": " .. tostring(errorMessage))
    self._serverStateStop = true
    UIManager:GetInstance():ShowTips(tostring(errorMessage))
end

--- PushInit 完成处理
function AppStartupLoading:OnPushInitOk()
    Logger.Log("AppStartupLoading:OnPushInitOk")
    -- 继续加载流程：加载场景
    self:TransitionState(LoadingState.LoadScene)
end

--- 前后台切换
function AppStartupLoading:OnApplicationPause(pause)
    if pause then
        self._pauseTime = os.time()
    else
        self._pauseTime = 0
    end
end

--- 关闭加载流程
function AppStartupLoading:Shutdown(needDestroyUI)
    self:DisableUpdate()
    self.isInLoading = false

    -- 清理所有状态
    for _, state in pairs(self._stateList) do
        state:Delete()
    end
    table.clear(self._stateList)

    self._loadingState = nil
    self._currState = 0
end

-----------------------------------------------------------
-- 加载状态实现
-----------------------------------------------------------

-- 状态基类（简化版，兼容 LoadingStateBase 接口）
local BaseState = BaseClass("BaseState")

function BaseState:__init(loading)
    self._loading = loading
end

function BaseState:__delete()
    self._loading = nil
end

function BaseState:OnEnter(args)
end

function BaseState:OnExit()
end

function BaseState:OnUpdate()
end

-----------------------------------------------------------
-- 权限检查状态
-----------------------------------------------------------
PermissionState = BaseClass("PermissionState", BaseState)

function PermissionState:OnEnter(args)
    Logger.Log("[Loading] PermissionState:OnEnter")
    -- 权限检查完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.CheckResVersion)
end

-----------------------------------------------------------
-- 资源版本检查状态
-----------------------------------------------------------
CheckResVersionState = BaseClass("CheckResVersionState", BaseState)

function CheckResVersionState:OnEnter(args)
    Logger.Log("[Loading] CheckResVersionState:OnEnter")
    -- 资源版本检查完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.DownloadManifest)
end

-----------------------------------------------------------
-- 下载 Manifest 状态
-----------------------------------------------------------
DownloadManifestState = BaseClass("DownloadManifestState", BaseState)

function DownloadManifestState:OnEnter(args)
    Logger.Log("[Loading] DownloadManifestState:OnEnter")
    -- 下载完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.LoadDataTable)
end

-----------------------------------------------------------
-- 加载数据表状态
-----------------------------------------------------------
LoadDataTableState = BaseClass("LoadDataTableState", BaseState)

function LoadDataTableState:OnEnter(args)
    Logger.Log("[Loading] LoadDataTableState:OnEnter")
    -- 数据表加载完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.GetServerList)
end

-----------------------------------------------------------
-- 获取服务器列表状态
-----------------------------------------------------------
GetServerListState = BaseClass("GetServerListState", BaseState)

function GetServerListState:OnEnter(args)
    Logger.Log("[Loading] GetServerListState:OnEnter")
    -- 获取服务器列表完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.ConnectGame)
end

-----------------------------------------------------------
-- 连接游戏服务器状态
-----------------------------------------------------------
ConnectGameState = BaseClass("ConnectGameState", BaseState)

function ConnectGameState:OnEnter(args)
    Logger.Log("[Loading] ConnectGameState:OnEnter")
    self._waitTime = 0
    self._connected = false

    -- 监听连接成功事件
    self._onConnectOk = function(eventId, data)
        self._connected = true
    end
    EventManager:GetInstance():AddListener(EventId.GameOnConnectOK, self._onConnectOk)

    -- 尝试连接（简化版：直接标记为已连接）
    -- 实际项目中这里应该调用 NetworkManager:Connect()
    self._connected = true
end

function ConnectGameState:OnUpdate()
    if self._connected then
        EventManager:GetInstance():RemoveListener(EventId.GameOnConnectOK, self._onConnectOk)
        self._loading:TransitionState(LoadingState.Login)
        return
    end

    -- 超时检测
    self._waitTime = self._waitTime + Time.deltaTime
    if self._waitTime > 30 then
        Logger.LogError("[Loading] ConnectGameState: timeout")
        EventManager:GetInstance():RemoveListener(EventId.GameOnConnectOK, self._onConnectOk)
        self._loading:Stop()
    end
end

function ConnectGameState:OnExit()
    self._onConnectOk = nil
end

-----------------------------------------------------------
-- 登录状态
-----------------------------------------------------------
LoginState = BaseClass("LoginState", BaseState)

function LoginState:OnEnter(args)
    Logger.Log("[Loading] LoginState:OnEnter")
    self._waitTime = 0
    self._loginDone = false

    -- 监听登录结果
    self._onLoginOk = function(eventId, data)
        self._loginDone = true
    end
    EventManager:GetInstance():AddListener(EventId.GameOnConnectOK, self._onLoginOk)

    -- 简化版：直接标记登录完成
    -- 实际项目中这里应该发送登录消息给服务器
    self._loginDone = true
end

function LoginState:OnUpdate()
    if self._loginDone then
        EventManager:GetInstance():RemoveListener(EventId.GameOnConnectOK, self._onLoginOk)
        self._loading:TransitionState(LoadingState.PushInit)
        return
    end

    -- 超时检测
    self._waitTime = self._waitTime + Time.deltaTime
    if self._waitTime > 30 then
        Logger.LogError("[Loading] LoginState: timeout")
        EventManager:GetInstance():RemoveListener(EventId.GameOnConnectOK, self._onLoginOk)
        self._loading:Stop()
    end
end

function LoginState:OnExit()
    self._onLoginOk = nil
end

-----------------------------------------------------------
-- 等待 PushInit 状态
-----------------------------------------------------------
PushInitState = BaseClass("PushInitState", BaseState)

function PushInitState:OnEnter(args)
    Logger.Log("[Loading] PushInitState:OnEnter")
    self._waitTime = 0
    self._initOk = false

    -- 先监听 PUSH_INIT_OK 事件（无论哪种模式都需要）
    self._onPushInitOk = function(eventId, data)
        self._initOk = true
    end
    EventManager:GetInstance():AddListener(EventId.PUSH_INIT_OK, self._onPushInitOk)

    if App.IsDebug() or not Network then
        -- 单机模式：模拟服务器 push_init 流程
        local MockServer = require "Loading.MockServer"
        MockServer.SimulatePushInit()
    end
    -- 非单机模式：等待服务器真实 push_init 消息广播 PUSH_INIT_OK
end

function PushInitState:OnUpdate()
    if self._initOk then
        EventManager:GetInstance():RemoveListener(EventId.PUSH_INIT_OK, self._onPushInitOk)
        self._loading:OnPushInitOk()
        return
    end

    -- 超时检测
    self._waitTime = self._waitTime + Time.deltaTime
    if self._waitTime > 60 then
        Logger.LogError("[Loading] PushInitState: timeout")
        EventManager:GetInstance():RemoveListener(EventId.PUSH_INIT_OK, self._onPushInitOk)
        self._loading:Stop()
    end
end

function PushInitState:OnExit()
    if self._onPushInitOk then
        EventManager:GetInstance():RemoveListener(EventId.PUSH_INIT_OK, self._onPushInitOk)
        self._onPushInitOk = nil
    end
end

-----------------------------------------------------------
-- 加载场景状态
-----------------------------------------------------------
LoadSceneState = BaseClass("LoadSceneState", BaseState)

function LoadSceneState:OnEnter(args)
    Logger.Log("[Loading] LoadSceneState:OnEnter")
    -- 场景加载完成，直接进入下一个状态
    self._loading:TransitionState(LoadingState.EnterGame)
end

-----------------------------------------------------------
-- 进入游戏状态
-----------------------------------------------------------
EnterGameState = BaseClass("EnterGameState", BaseState)

function EnterGameState:OnEnter(args)
    Logger.Log("[Loading] EnterGameState:OnEnter")

    -- 初始化连连看游戏管理器并打开主界面
    local LianLianManager = require "Game.LianLian.DataCenter.LianLianManager"
    LianLianManager:GetInstance()
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianMain)
    UIManager:GetInstance():OpenWindow(UIWindowNames.LianLianDebug)

    -- 关闭加载流程
    self._loading:Shutdown()
end

return AppStartupLoading
