# Defines/
> L2 | 父级: ../../../CLAUDE.md

常量定义层：消除全局魔法数字/魔法字符串。C# 与 Lua 共享的类型与数值契约源。

## 成员清单
GameDefines.cs: 数值常量中心，画质档位/默认字典路径/材质名/聚焦时长等全局常量
GameEnum.cs: 枚举定义集，BuildingState/ResourceType 等游戏分类型词汇
EventId.cs: 全局事件 id 表，App 生命周期/屏幕触摸/UI/业务刷新等，是 GameEntry.Event 广播订阅的唯一 key 源
GameDialogIdDefine.cs: 多语言文本 id 常量表（GameDialogDefine），把代码写死的本地化 id 收敛成带注释具名常量

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
