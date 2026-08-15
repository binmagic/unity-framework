# DataCenter/
> L2 | 父级: ../../../CLAUDE.md

数据管理中枢与业务 Manager 集散地。DataCenter 用元表按需懒加载各 Manager，是 DataCenter.XxxManager 访问入口；LuaEntry 与之并列，持有最高频的玩家/资源/网络核心数据。Manager 遵循 OOP 生命周期（__init 建字段 / __delete 一一置 nil），网络回调命名 XxxHandle/PushXxxHandle 处理后经 EventManager 广播通知 UI。

## 成员清单
DataCenter.lua: 数据管理中枢，__index 元表把 DataCenter.XxxManager 首访转为 require+New+缓存；Managers 表登记路径、末尾 ---@field 声明类型；暴露 IsValid/DeleteAll
Global/LuaEntry.lua: 核心数据入口（类似 C# GameEntry.Data），持有 Player/Resource/Network 等高频数据，冒号方法风格单例，生命周期 Init/Uninit/OnApplicationPause 由框架驱动；连连看简化流程下当前为存根
GuideManager/GuideManager.lua: 新手引导管理器，母工程完整引导状态机（SetCurGuideId/DoGuide/DoNext/CheckGuideComplete 及信号回调）；连连看简化流程下 __init 仅留字段桩、不注册监听不访问已注释枚举，注册于 DataCenter.Managers

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
