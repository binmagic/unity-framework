# Data/
> L2 | 父级: ../../../CLAUDE.md

C# 数据模型层：C#-Lua 数据边界。只在 C# 侧驻留高频、稳定的核心数据，其余回 Lua 取。所有容器共享 SmartFox 消息注入契约。

## 成员清单
BaseDataContainer.cs: 数据容器抽象基类，定义 Init/Update/Release 与可重写的 CSInit/CSUpdate 钩子，统一 SFSObject 注入契约
DCPlayer.cs: 玩家数据容器，缓存 uid/serverId/crossServerId 等不变的核心标识
DCBuilding.cs: 建筑数据容器，以 uuid/buildId 从 Lua 侧反查建筑数据（LuaBuildData）供 C# 高频访问

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
