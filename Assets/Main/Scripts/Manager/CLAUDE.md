# Manager/
> L2 | 父级: ../../../CLAUDE.md

本目录是 C# 层的业务管理器集散地：一批由 `GameEntry` 或各自单例持有的功能型 Manager，向上服务 Lua 业务、向下封装平台与传输细节。可分为三族：网络传输族、本地数据族、平台/资源杂项族。

## 成员清单

### 网络传输族（连接抽象 → 实现 → 中枢）
- INetProxy.cs: 单条连接的传输层抽象接口(连接/发送/心跳/状态)，屏蔽 TCP 与 WebSocket 差异；同文件定义 ProxyStatus 由 NetProxy 承载。
- INetManager.cs: 网络上层回调契约(连接/登录/登出事件)，由 NetworkManager 实现、被各 proxy 回调，按平台分原生(SFS 事件)与 WebGL(拆参)两套签名。
- NetProxy.cs: INetProxy 的原生平台(iOS/Android/PC)实现，封装 SmartFox2X 客户端的 TCP 连接生命周期、心跳与事件转发。
- WebSocketNetProxy.cs: INetProxy 的 WebGL(微信小游戏)实现，经 JsBridge 走浏览器 WebSocket，协议体仍为 SFSObject；与 NetProxy 互斥编译。
- NetworkManager.cs: 网络族中枢与门面(实现 IGameController+INetManager)，由 GameEntry.Network 持有，管理当前 proxy、上行发送(含 Lua 栈直发)与事件到 LuaEntry.Network 的桥接。
- PBController.cs: Protobuf 预处理器，由 GameEntry.pb 持有，开局前把 proto 描述文件加载进 Lua 侧解析器，是网络消息序列化的前置依赖。

### 本地数据族（存储底座 → 玩家/全局数据）
- DatabaseManager.cs: 本地 SQLite 底座(MonoBehaviour 单例)，基于 SQLite4Unity3d + 后台队列线程做异步 SQL 执行与主线程回调。
- LuaDatabaseManager.cs: DatabaseManager 对 Lua 的桥接层，负责结果集与绑定参数的 Lua<->C# 编解码，是 Lua 侧访问本地库的唯一入口。
- CustomDataManager.cs: 玩家自身业务数据的聚合门面，按类型注册并托管各 DataContainer(DCPlayer/DCBuilding)的生命周期。
- GlobalDataManager.cs: 跨会话全局易变状态容器(渠道/版本/gaid/后台与踢下线标识等)，由 GameEntry.GlobalData 持有，是全局标识的单一数据源。
- SettingManager.cs: 本地设置存储门面，收口全工程 PlayerPrefs 访问，提供 public/private(按 uid 隔离)/byId(免拼接) 三套读写接口。

### 平台/资源杂项族
- DeviceManager.cs: 设备信息门面(GameEntry.Device)，汇总型号/网络/图形能力/时区及稳定 deviceUid 的生成与缓存，服务上报、登录与画质决策。
- WebRequestManager.cs: 通用 HTTP 传输底座(单例)，封装 Get/Post/Put 等与纹理加载、断点下载并做并发限流，被数据库/动态资源/上传等复用。
- DynamicResourceManager.cs: 运行时远程资源加载器(MonoBehaviour 单例)，按 URL 异步下载纹理并做内存+本地双层缓存与并发去重，专供头像等下载图片。
- UploadImageManager.cs: 头像图片上传下载流程编排器，串联 Lua 发起、原生选图、AES 鉴权与 HTTP 传输，是头像业务的端到端通道。
- BuildAnimatorManager.cs: 建筑动画状态管理器(GameEntry.BuildAnimatorManager)，基于服务器时间维护正在建造/升级建筑的起止时间，供城建表现层查询。
- PushManager.cs: 消息推送协调器，汇集各平台推送 token 并在登录完成后择机上报，管理推送点击数据的记录与清理。

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
