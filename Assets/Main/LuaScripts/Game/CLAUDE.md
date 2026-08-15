# Game/
> L2 | 父级: ../../../CLAUDE.md

连连看业务代码根，承接母工程被移除的 `Slg/`、`Scene/` 顶层目录位置。当前为预留脚手架——仅有空目录 `Game/LianLian/Manager/`，尚无 .lua 文件。此 L2 为播种地图，声明将来落地的结构与约定，待首个业务类写入后转为正式成员清单。

## 规划
将在 `Game/LianLian/` 下落地连连看业务模块：
- `Game/LianLian/Manager/`：业务管理器（如 LianLianManager），遵循与顶层 DataCenter 一致的 OOP/生命周期/命名规则——`BaseClass(name, super)`，类名=文件名=变量名，`__init` 建字段 / `__delete` 一一置 nil；单例管理器继承 Singleton 用 GetInstance()。AppStartupLoading 末态已预约 `require "Game.LianLian.Manager.LianLianManager"` 并 GetInstance()
- 关卡/棋盘/匹配等子系统按职责在 `Game/LianLian/` 下分目录承载
- 窗口不放这里：连连看 UI 走顶层 `UI/`，前缀 `UI.LianLian.`，先在 `UI/Config/UIWindowNames.lua` 登记名字、`UIConfig.lua` 注册路由
- 数据类若需全局访问，管理器可注册进顶层 `DataCenter/`（Managers 表 + ---@field），或由 LianLianManager 自持

## 成员清单
（暂无 .lua 文件；首个业务类落地后在此逐一登记：一行一文件、职责+技术细节）

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
