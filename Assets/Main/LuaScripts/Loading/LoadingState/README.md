

Based on the `AppStartupLoading.lua` and `Loading/Const.lua` analysis, here's the complete startup state machine:

## App 启动到进入游戏的状态列表

启动状态机由 `AppStartupLoading`（继承 Singleton）驱动，通过 `SetState()` 切换状态，每个状态有 `OnEnter/OnUpdate/OnExit` 三个生命周期。

### 正常首次启动流程

| 序号 | 状态 | 枚举值 | 实现文件 | 作用 |
|------|------|--------|----------|------|
| 0 | None | 0 | — | 初始空状态 |
| 1 | **Permission** | 2 | `LoadingState/PermissionState.lua` | 请求系统权限（存储/通知等），等 SDK 回调 |
| 2 | **Logo** | 1 | `LoadingState/LogoState.lua` | 显示开屏 Logo 动画（公司标/品牌） |
| 3 | **EuropeanUnionPrivacy** | 3 | `LoadingState/EuropeanUnionPrivacyState.lua` | 欧盟隐私协议/GDPR 弹窗确认 |
| 4 | **CheckResVersion** | 4 | `LoadingState/CheckResVersionState.lua` | 检查资源版本号，判断是否需要热更 |
| 5 | **AppUpdate** | 13 | `LoadingState/AppUpdateState.lua` | 强制整包更新（跳商店下载新版本） |
| 6 | **DownloadManifest** | 5 | `LoadingState/DownloadManifestState.lua` | 下载资源清单（manifest），对比差异 |
| 7 | **DownloadUpdate** | 6 | `LoadingState/DownloadUpdateState.lua` | 下载热更资源 bundle，显示下载进度 |
| 8 | **LoadDataTable** | 7 | `LoadingState/LoadDataTableState.lua` | 加载本地数据配置表（DataTable） |
| 9 | **CheckMainLevelRes** | 8 | `LoadingState/CheckMainLevelResState.lua` | 检查主关卡/核心资源是否齐全 |
| 10 | **GetServerList** | 9 | `LoadingState/GetServerListState.lua` | 请求服务器列表（GSL），获取服务器 IP/端口 |
| 11 | **GetServerStatus** | 10 | `LoadingState/GetServerStatusState.lua` | 查询目标服务器状态（是否维护/满员等） |
| 12 | **ConnectGame** | 11 | `LoadingState/ConnectGameState.lua` | 建立 SFS2X 长连接到游戏服务器 |
| 13 | **Login** | 12 | `LoadingState/LoginState.lua` | 发送登录消息到服务器，等服务器验证 |
| 14 | **PushInit** | 14 | `LoadingState/PushInitState.lua` | 等待服务器推送 PushInit 消息（表示登录成功、初始数据下发完成），8 秒超时重试 |
| 15 | **AuthPin** | 15 | `LoadingState/AuthPinState.lua` | PIN 码/二次验证（账号安全） |
| 16 | **CNIdentify** | 16 | `LoadingState/CNIdentifyState.lua` | 中国区实名认证（防沉迷） |
| 17 | **LoadScene** | 18 | `LoadingState/LoadSceneState.lua` | 加载游戏主场景（城市/世界 prefab + 地形数据） |
| 18 | **EnterGame** | 19 | `LoadingState/EnterGameState.lua` | 进入游戏（关闭 loading UI、触发 `LuaEntry:StartGame`、批量启动业务 Manager） |
| — | **LoadingError** | 20 | `LoadingState/LoadingErrorState.lua` | 任意环节出错时跳转此状态，弹错误提示/重试 |

### 分支逻辑

`AppStartupLoading:Start(isReload, showLogo)` 决定起始状态：

```
首次启动 (showLogo=true)  → Permission → Logo → EuropeanUnionPrivacy → CheckResVersion → ...
非首次/热更后 (showLogo=false) → CheckResVersion → ...（跳过 Logo/权限/隐私）
重连/重载 (isReload=true)  → LoadDataTable → ...（跳过下载，直接从加载配表开始）
```

### 特殊跳转

- **CheckResVersion** 检测到需要整包更新 → 跳 **AppUpdate**（跳商店）
- **PushInit** 超时 → 根据有无 uid 跳回 **GetServerList** 或 **ConnectGame** 重试
- 任何环节网络错/超时 → 跳 **LoadingError** → 用户点重试后跳回对应状态

### 状态文件汇总

所有状态实现文件位于 `Assets/Main/LuaScripts/Loading/LoadingState/`，基类为 `LoadingStateBase.lua`：

```
Loading/
  AppStartupLoading.lua          -- 状态机驱动器（SetState/Update/进度条）
  Const.lua                      -- 状态枚举 + 错误码定义
  LoadingView2.lua               -- Loading UI 视图
  Versions.lua                   -- 版本号工具
  LoadingState/
    LoadingStateBase.lua         -- 状态基类（OnEnter/OnExit/OnUpdate）
    LogoState.lua
    PermissionState.lua
    EuropeanUnionPrivacyState.lua
    CheckResVersionState.lua
    AppUpdateState.lua
    DownloadManifestState.lua
    DownloadUpdateState.lua
    LoadDataTableState.lua
    CheckMainLevelResState.lua
    GetServerListState.lua
    GetServerStatusState.lua
    ConnectGameState.lua
    LoginState.lua
    PushInitState.lua
    AuthPinState.lua
    CNIdentifyState.lua
    LoadSceneState.lua
    EnterGameState.lua
    LoadingErrorState.lua
```




数据已收集完毕。以下是完整的状态流转图和每个状态的调用位置：

## App 启动状态机 — 完整状态流转与调用关系

### 状态流转图（正常流程）

```
None → Permission → Logo → CheckResVersion → DownloadManifest → DownloadUpdate
  → LoadDataTable → EuropeanUnionPrivacy → CheckMainLevelRes → GetServerList
  → GetServerStatus → ConnectGame → Login → PushInit → AuthPin → LoadScene → EnterGame
```

（注：部分状态可跳过、可重试、可进入 LoadingError）

---

### 每个状态的 `SetState` 调用位置

| 目标状态 | 从哪里调用 | 文件:行号 | 触发条件 |
|----------|-----------|-----------|----------|
| **None** | `AppStartupLoading:Stop()` | `AppStartupLoading.lua:368` | 主动停止状态机 |
| **Permission** | `AppStartupLoading:Start()` | `AppStartupLoading.lua:344` | 首次启动且 showLogo=true |
| | `LogoState:OnEnter()` | `LogoState.lua:32` | Logo 播放完毕 → 进权限 |
| **Logo** | — | — | （由 Permission 内部逻辑触发，或跳过） |
| **EuropeanUnionPrivacy** | `LoadDataTableState:OnUpdate()` | `LoadDataTableState.lua:46` | 配置表加载完且需要隐私确认 |
| **CheckResVersion** | `AppStartupLoading:Start()` | `AppStartupLoading.lua:346` | 非首次/不显示 Logo 直接进 |
| | `PermissionState:OnEnter()` | `PermissionState.lua:146` | 权限获取完毕 |
| **DownloadManifest** | `CheckResVersionState` | `CheckResVersionState.lua:279,281,297` | 版本检查通过，需要对比清单 |
| **DownloadUpdate** | `DownloadManifestState:OnEnter()` | `DownloadManifestState.lua:73` | 清单对比完毕，有资源需下载 |
| **LoadDataTable** | `AppStartupLoading:Start()` | `AppStartupLoading.lua:342` | isReload（重连/重载）直接跳到配置表 |
| | `AppStartupLoading` | `AppStartupLoading.lua:457` | 下载完成后加载配置表 |
| | `CheckResVersionState` | `CheckResVersionState.lua:43` | 无需更新，直接加载配置 |
| | `DownloadUpdateState` | `DownloadUpdateState.lua:126` | 下载完成 |
| **CheckMainLevelRes** | — | — | （由 LoadDataTable 完成后内部跳转） |
| **GetServerList** | `AppStartupLoading:Start()` | `AppStartupLoading.lua:488` | 无缓存连接参数，需获取服务器列表 |
| | `PushInitState:DoRetry()` | `PushInitState.lua:50` | PushInit 超时且无 uid（首次登录），回到获取服务器 |
| **GetServerStatus** | `ConnectGameState:OnEnter()` | `ConnectGameState.lua:93` | 连接前先检查服务器状态 |
| **ConnectGame** | `AppStartupLoading:Start()` | `AppStartupLoading.lua:486` | 有缓存连接参数，直接连 |
| | `AppStartupLoading:OnPushInitOk()` | `AppStartupLoading.lua:709` | 换服/切服后重连 |
| | `GetServerListState` | `GetServerListState.lua:262` | 服务器列表获取成功 → 连接 |
| **Login** | `ConnectGameState:OnEnter()` | `ConnectGameState.lua:99` | 网络连接建立成功 → 发登录 |
| **AppUpdate** | `LoginState`（注释掉了） | `LoginState.lua:65` | （未启用）服务器返回需要强更 |
| **PushInit** | `LoginState:OnUpdate()` | `LoginState.lua:67` | 登录消息发送成功 → 等待推送 |
| | `AppStartupLoading` | `AppStartupLoading.lua:605,741` | 登录流程中进入等待 PushInit |
| | `AppUpdateState:OnEnter()` | `AppUpdateState.lua:39` | 强更检查通过（跳过更新）|
| **AuthPin** | `PushInitState:OnUpdate()` | `PushInitState.lua:88` | PushInit 收到且需要 PIN 验证 |
| **LoadScene** | `PushInitState:OnUpdate()` | `PushInitState.lua:91` | PushInit 收到，无需 PIN，直接加载场景 |
| | `LoadDataTableState:OnUpdate()` | `LoadDataTableState.lua:41` | isReload 模式，配置表加载完直接加载场景 |
| **EnterGame** | `LoadSceneState` | `LoadSceneState.lua:54,174` | 场景加载完毕 → 进入游戏 |
| **LoadingError** | 多处 | 见下表 | 任何异常/超时/网络错误 |

---

### LoadingError 的触发来源

| 来源文件 | 行号 | 错误码 | 含义 |
|----------|------|--------|------|
| `AppStartupLoading.lua` | 601 | `ERROR_INIT` | PushInit 流程异常 |
| `AppStartupLoading.lua` | 755 | `ERROR_SERVER_LIST_EMPTY` | 服务器列表为空 |
| `AppStartupLoading.lua` | 757 | `ERROR_DELETE_ACCOUNT` | 账号已删除 |
| `AppStartupLoading.lua` | 759 | `ERROR_BANID` | 封号 |
| `AppStartupLoading.lua` | 766 | `ERROR_ACCOUNT_ERR` | 服务器无账号 |
| `AppStartupLoading.lua` | 803 | `netError`(动态) | 网络错误 |
| `PermissionState.lua` | 51,54,121 | `ERROR_DOWNLOAD_UPDATE` | 权限阶段下载失败 |
| `CheckMainLevelResState.lua` | 85 | `ERROR_DOWNLOAD_UPDATE` | 核心资源检查失败 |
| `ConnectGameState.lua` | 70 | `ERROR_MAINTENANCE` | 服务器维护 |
| `ConnectGameState.lua` | 105 | 动态 | 连接失败 |
| `DownloadUpdateState.lua` | 111 | `ERROR_DOWNLOAD_UPDATE` | 下载失败 |
| `GetServerListState.lua` | 187 | 动态 | 获取服务器列表失败 |
| `GetServerStatusState.lua` | 98 | `ERROR_MAINTENANCE` | 服务器维护 |
| `GetServerStatusState.lua` | 101 | `STATE_ERROR_CONNECT` | 服务器状态异常 |
| `GetServerStatusState.lua` | 105 | 动态 | 服务器状态查询错误 |
| `LoadDataTableState.lua` | 48 | `ERROR_LOAD_DATATABLE` | 配置表加载失败 |
| `LoadDataTableState.lua` | 53 | `ERROR_LOAD_DATATABLE_TIMEOUT` | 配置表加载超时 |
| `LoadSceneState.lua` | 73 | `ERROR_LOAD_SCENE_ERR` | 场景加载失败 |
| `LoginState.lua` | 50 | `ERROR_LOGIN_TIMEOUT` | 登录超时 |
| `PushInitState.lua` | 81 | `ERROR_INIT_TIMEOUT` | PushInit 8 秒超时 |

---

### 所有状态实现文件

| 状态枚举 | 实现文件 |
|----------|----------|
| `Logo` (1) | `Loading/LoadingState/LogoState.lua` |
| `Permission` (2) | `Loading/LoadingState/PermissionState.lua` |
| `EuropeanUnionPrivacy` (3) | `Loading/LoadingState/EuropeanUnionPrivacyState.lua` |
| `CheckResVersion` (4) | `Loading/LoadingState/CheckResVersionState.lua` |
| `DownloadManifest` (5) | `Loading/LoadingState/DownloadManifestState.lua` |
| `DownloadUpdate` (6) | `Loading/LoadingState/DownloadUpdateState.lua` |
| `LoadDataTable` (7) | `Loading/LoadingState/LoadDataTableState.lua` |
| `CheckMainLevelRes` (8) | `Loading/LoadingState/CheckMainLevelResState.lua` |
| `GetServerList` (9) | `Loading/LoadingState/GetServerListState.lua` |
| `GetServerStatus` (10) | `Loading/LoadingState/GetServerStatusState.lua` |
| `ConnectGame` (11) | `Loading/LoadingState/ConnectGameState.lua` |
| `Login` (12) | `Loading/LoadingState/LoginState.lua` |
| `AppUpdate` (13) | `Loading/LoadingState/AppUpdateState.lua` |
| `PushInit` (14) | `Loading/LoadingState/PushInitState.lua` |
| `AuthPin` (15) | `Loading/LoadingState/AuthPinState.lua` |
| `CNIdentify` (16) | `Loading/LoadingState/CNIdentifyState.lua`（未启用） |
| `LoadScene` (18) | `Loading/LoadingState/LoadSceneState.lua` |
| `EnterGame` (19) | `Loading/LoadingState/EnterGameState.lua` |
| `LoadingError` (20) | `Loading/LoadingState/LoadingErrorState.lua` |

驱动文件：`Loading/AppStartupLoading.lua`（状态机主体，`SetState`/`Update` 驱动），常量定义：`Loading/Const.lua`。