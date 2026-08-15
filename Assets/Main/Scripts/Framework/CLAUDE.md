# Framework/
> L2 | 父级: ../../../CLAUDE.md

C# 框架核心层。承载游戏运行所需的全部底层子系统，业务(C# 与 Lua)统一经全局静态入口 `GameEntry` 访问各子系统，向下屏蔽引擎、平台与热更资源管线的差异。

## 成员清单

### 顶层成员文件

- **GameEntry.cs**: 全局静态入口与总装配点，是本层唯一的静态门面。所有子系统管理器都以静态属性挂载于此(`GameEntry.Event`/`Resource`/`Sound`/`Sdk`/`Timer`/`Localization`/`ConfigCache` 等)，并由其 `Init`/`Update`/`Shutdown` 统一驱动生命周期——业务代码从不直接 new 管理器，一律经 `GameEntry.Xxx` 取用。
- **GameFrameworkComponent.cs**: 场景挂载型框架组件的抽象基类，Awake 时向 GameEntry 自注册，打通 MonoBehaviour 与静态入口。
- **BaseComponent.cs**: 本层唯一挂到场景的基础 MonoBehaviour(继承 GameFrameworkComponent)，作为引擎运行环境总开关，暴露帧率/游戏速度/后台运行/禁休眠及暂停恢复。
- **IGameController.cs**: 各托管子系统的生命周期契约(OnUpdate 轮询 + Shutdown 清理)，由 GameEntry 集中驱动。
- **EventComponent.cs**: 事件中枢(实现 IGameController)，维护 C# 侧 handler 表并将同一事件同步派发到 Lua 双端，内建对象池复用 handler 列表。
- **TimerComponent.cs**: 时间与定时中枢，管理定时器注册/取消及客户端与服务器时差校准、时间戳格式化等时间工具。
- **ResourceManager.cs**: 资源子系统门面，包裹 VEngine(XAssetPro)热更管线——统管清单更新、AB 下载、按帧限流实例化与 SpriteAtlas 延迟绑定，内含 InstanceRequest 与 UI 的 LoadSprite 扩展。
- **ObjectPoolManager.cs**: GameObject 复用层(ObjectPoolMgr/ObjectPool)，被 ResourceManager 持有驱动，承接实例化请求的复用与闲置回收。
- **ShaderManager.cs**: Shader 资源管理器，将散落 shader 归拢入独立 bundle 并预热变体，运行期提供按名取 shader。
- **ConfigCache.cs**: 策划配置读取旁路缓存，架在 C# 与 Lua 配置之间，同帧多次取配置时避免重复跨语言调用。
- **GameFrameworkLogHelper.cs**: 日志适配器，将 GameFramework 内部日志等级桥接到 Unity 控制台，经 SetLogHelper 注入。

### SDKManager/ — 平台抽象层

按编译宏择一注入具体平台实现，屏蔽登录/支付/打点/推送等原生能力的平台差异，由 `GameEntry.Sdk` 持有。
- **SDKManager.cs**: 子系统门面(实现 IGameController)，统一原生能力入口并分发原生回调事件。
- **IPlatformNative.cs**: 平台抽象契约及 GamePlatform/LoginPlatform/PaymentChannel 枚举，各平台实现据此适配。
- **PlatformAndroid.cs / PlatformIOS.cs / PlatformWebGL.cs / PlatformEditor.cs / PlatformStandalone.cs**: Android/iOS/微信小游戏/编辑器/PC 五套平台实现(编辑器与 PC 多为空实现桩)。
- **AnalyticsEvent.cs**: 数据打点语义层，集中定义事件名常量并封装业务打点触发方法(Firebase/AppsFlyer/FB)。
- **HelpManager.cs**: 客服帮助模块(单例)，封装 AIHelp 相关展示入口(本工程裁剪后逻辑基本停用)。

### Localization/ — 本地化子系统

由 `GameEntry.Localization` 持有，将词条字典载入内存供全端取文案。
- **LocalizationManager.cs**: 核心，含字典加载解析、按 string/int 双索引取文案(支持格式化)、语言切换与系统语言映射。
- **Language.cs**: 语言枚举定义，作为语言维度的基准类型。

### LuaMono/ — Lua 与 MonoBehaviour 绑定

将挂载 GameObject 绑定到 Lua table 并转发 Unity 消息，因逻辑多在 Lua 侧，Mono 仅作中转。
- **LuaMonoBase.cs**: 基类，直接用 XLua 底层 API 提供无 GC 的 Lua 函数调用/取值/引用管理原语。
- **LuaMonoConfig.cs**: 通用配置组件(不含 Update)，转发 Awake/OnEnable/碰撞/触发/焦点等 Unity 消息到 Lua。
- **LuaMonoUpdate.cs**: 带 Update 的变体，按需挂载以隔离逐帧转发开销。

### Sound/ — 声音子系统

由 `GameEntry.Sound` 持有，统管音频加载调度与分组播放。
- **SoundComponent.cs**: 门面主体(partial)，含音乐/音效/配音/3D 音效播放与按组停止/暂停/静音/调音量。
- **SoundComponent.SoundGroup.cs**: 声音组实现分部(ISoundGroup/SoundGroup/Sound3DGroup)，单组的实际播放执行单元。
- **PlaySoundInfo.cs**: 播放参数与上下文载体分部(Constant/PlaySoundParams/PlaySoundInfo)，在异步加载回调间传递。
- **PlaySoundErrorCode.cs**: 播放失败错误码枚举。

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
