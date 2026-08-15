# Framework/
> L2 | 父级: ../../../CLAUDE.md

Lua 层的框架底座：自研 OOP 系统、UI 基类、事件、定时器、日志、渲染设置。
业务代码(DataCenter/Net/UI/Game)全部构建其上，本层不含任何连连看业务逻辑。

## 子目录
- Common/: 自研 OOP 系统基石(BaseClass/Singleton/DataClass/ConstClass)、有限状态机 FSM、协程封装、消息中心 Messenger、路径工具
- UI/: MVC UI 框架(Base 基类 + Component 组件封装 + Message 事件 + Time + 窗口管理)，详见 UI/CLAUDE.md
- Logger/: 日志系统(本地 Logger / FireBase 崩溃线索 / PostEvent 启动埋点)
- LuaMono/: Lua 侧模拟 MonoBehaviour，主要封装协程
- Render/: URP 渲染设置与画质分档
- snapshot/: 内存快照调试工具(第三方，云风 lua-snapshot)
- Updater/: 定时器与帧更新调度(Timer/TimerManager/UpdateManager/TimeUp*)

## Common/ 成员清单
- BaseClass.lua: 整个 Lua 层 OOP 基石，提供 BaseClass(name, super) 工厂——类共享虚表、构造/析构链、New 实例化
- Singleton.lua: 在 BaseClass 之上的单例范式，实例挂类表 Instance 字段，各 Manager 继承之
- DataClass.lua: 数据结构类范式，强制字段预声明、禁读写未定义域，调试期元表拦截
- ConstClass.lua: 只读常量表范式，调试期拦截写操作，发布期返回裸表
- FSM.lua: 通用有限状态机，按 stateIndex 管理状态并驱动进入/退出/更新/输入
- FSMStateBase.lua: FSM 状态契约基类(当前为空文件，接口约定占位)
- Messenger.lua: 通用消息中心，弱引用监听 + 广播快照防重入 + 空表池减 GC，EventManager/UpdateManager 的底层
- Coroutine.lua: 对 Unity C# 协程的 Lua 全局薄封装(Start/Stop/yield_*)
- PathUtil.lua: 轻量路径工具，取纯文件名，以 ConstClass 包装
- base64.lua: base64 编解码(第三方，Ilya Kolbin/lbase64，MIT)——未加 L3

## Logger/ 成员清单
- Logger.lua: Lua 层唯一日志出口，按级别桥接 C# 日志系统，错误附 traceback，禁裸 print
- FireBaseLog.lua: 向 Firebase Crashlytics 写崩溃线索，仅真机发布环境生效
- PostEventLog.lua: 启动/登录流程打点，Defines 枚举覆盖各阶段，当前委托 C# 实现

## LuaMono/ 成员清单
- LuaMonoBase.lua: Lua 模拟 MonoBehaviour 基类，提供对象级协程 Start/Stop
- MonoClass.lua: MonoClass(name) 工厂(派生 LuaMonoBase 并 New)，附全局 yield_* 辅助

## Render/ 成员清单
- RenderSetting.lua: 唯一渲染设置中枢，依内存/画质档配置 URP 管线特性，反射开关各 RendererFeature，按交互空闲动态降帧

## Updater/ 成员清单
- Timer.lua: 定时器实体，支持秒/帧、一次性/循环、scaled/unscaled，由 TimerManager 调度回收
- TimerManager.lua: 调度中枢单例，挂 UpdateBeat 限频驱动所有 Timer，提供 GetTimer/DelayInvoke/DelayNextFrameAction
- UpdateManager.lua: 每帧更新入口单例，用 Messenger 弱引用广播替代直连 UpdateBeat 避免强引用泄漏
- TimeUper.lua: TimeUp 监听实体，代表某绝对/每日时刻触发一次的回调，由 TimeUpManager 池化
- TimeUpManager.lua: TimeUp 管理器单例，按事件分组、以秒级 Timer 比对服务器时间，解决久留倒计时界面到点不刷新
- TimeUpEventId.lua: TimeUp 事件 ID 只读枚举，作分组监听的键

## snapshot/ 成员清单(第三方，均未加 L3)
- print_r.lua: 表结构递归打印(云风 lua-snapshot 配套)
- snapshot_utils.lua: 快照 diff 森林重建工具(云风 lua-snapshot 配套)
- dump.lua: 仅含快照用法示例的注释文件(无实际代码)

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
