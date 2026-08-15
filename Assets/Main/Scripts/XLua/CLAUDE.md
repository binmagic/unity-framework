# XLua/
> L2 | 父级: ../../../CLAUDE.md

Lua 热更桥接层：C# 与 Lua 双向互操作的核心。虚拟机管理、跨语言调用原语、数据载体、以及为降低交互 GC 而下沉 C# 的高频逻辑，均在此收敛。

## 成员清单
XLuaManager.cs: Lua 虚拟机中枢（partial），管理启停/脚本加载路径（横竖屏两套）/自定义 loader/热重载，即 GameEntry.Lua 实体
CSLuaClass.cs: 跨语言数据载体（LuaBuildData 等 POCO），承载 C# 调 Lua 返回的固定结构
LuaScriptInterface.cs: C#→Lua 接口契约（如 UIManager），以强类型接口代理 Lua 表方法
CSUtils.cs: 交互加速工具，把 Lua 高频固定行为下沉 C# 减 GC
Support/: 互操作支撑子目录
  LuaFunction.cs: 低层函数调用原语，栈操作方式调 Lua 函数并压参
  LuaStackTable.cs: 基于 Lua 栈的轻量 0-GC table（仅存活于栈，不可缓存）
  LuaUpdater.cs: 帧驱动桥，把 Unity Update 转发给 Lua update 函数
  CoroutineRunner.cs: 协程宿主，让 Lua yield 交给 C# 协程驱动并回调
  EventNotify.cs: 事件桥，把 GameEntry.Event.Fire 暴露给 Lua 触发
  UIEventTrigger.cs: UI 输入扩展，补长按判定并以委托暴露给 Lua 订阅
  UnityEngineObjectExtention.cs: Unity 对象判空适配，规避 Lua 感知不到假空对象的坑
  SFSObjectExtention.cs: 网络消息桥，让 Lua 高效消费 SmartFox SFSObject
  BuildInInit.cs: 内建 C 扩展注册（rapidjson/lpeg 等 luaopen 入口）
  UnitySystemProfilerApi.cs: 原生互操作层（CFuncUtils），P/Invoke 访问 C 导出接口与 Profiler
Editor/: 编辑器工具子目录
  GenConfig.cs: 代码生成配置，声明 CSharpCallLua 类型白名单与生成路径
  XLuaMenu.cs: 编辑器菜单，把 Lua 源码导出为运行时可加载的 LuaTxt

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
