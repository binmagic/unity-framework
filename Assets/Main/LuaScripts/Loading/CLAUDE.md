# Loading/
> L2 | 父级: ../../../CLAUDE.md

启动加载流程与热更版本检测。AppStartupLoading 是核心状态机，串起从权限检查到进入游戏的完整加载链；连连看简化版多数状态直连下一步，末态拉起 LianLianManager 并打开主界面。无服务器环境由 MockServer 伪造 push_init 数据走通流程。

## 成员清单
AppStartupLoading.lua: 启动加载状态机（Singleton），十状态流转 权限→资源版本→下载 Manifest→数据表→服务器列表→连服→登录→PushInit→场景→进游；暴露 Startup/TransitionState/OnLogin/OnPushInitOk/Shutdown，内联 BaseState 及各状态实现
LoadingState/LoadingStateBase.lua: 加载状态基类，定义 OnEnter/OnExit/OnUpdate 统一接口契约供子类覆写；与 AppStartupLoading 内联的 BaseState 同构
MockServer.lua: 单机模拟服务器，无网/Debug 下伪造 push_init 数据并经 LuaEntry→广播 PUSH_INIT_OK 走通流程；由 PushInitState 按需 require

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
