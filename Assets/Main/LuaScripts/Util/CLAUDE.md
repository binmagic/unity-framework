# Util/
> L2 | 父级: ../../CLAUDE.md

游戏业务工具类层：与玩家/服务器状态、UI 展示、音效、数据表强相关的跨模块工具，依赖 DataCenter/LuaEntry/GameEntry 等游戏数据层。**区别于 Common**——Common 是与游戏逻辑无关的 Lua 语言级扩展，Util 是承接业务语义的工具。多数以 `ConstClass` 包装为只读表，全局 require 后直接调用。

## 成员清单
CommonUtil.lua: 业务通用工具集，聚合与玩家/服务器状态强相关的跨模块杂项判断（震动、跨服/龙战判定、世界坐标、引导相关），依赖 LuaEntry.Player 与 DataCenter 各 Manager。
UIUtil.lua: UI 业务工具集，承接与界面展示强相关的数值换算与通用弹窗（特效数值、里程指针、来源服限制、确认框），依赖资源/数据层，是 UI 层的业务辅助。
UIStrCache.lua: UI 字符串缓存，把高频 UI 节点路径预生成为常量表，避免运行期反复拼接产生 GC，服务常用界面渲染。
CSharpCallLuaInterface.lua: C#→Lua 单向调用汇聚点，统一收口 C# 主动调用 Lua 的入口（读表、世界点、行走判定），与 C# 侧约定成对，避免绑定散落。
SoundUtil.lua: 音效播放门面，让业务按"声音属性描述"（group/subtype/param）而非具体资源播放，把策划声音表分组规则收口于此，依赖 CS.GameEntry.Sound 与 Setting。
Hex.lua: 六边形网格数学库（移植自 hex.cs），提供 Offset<->Cube 坐标转换、取整、格距计算，为六角地图坐标换算与寻路距离提供纯计算支撑。
Iterator.lua: 数组迭代器，构造时复制值快照保证数据安全，支持顺序与随机两种消费方式，用于轮播/抽取类业务。
WriteLogUtil.lua: 本地文件日志器，把调试信息写入持久化目录 Debug.txt，区别于 Framework/Logger 的运行时日志，用于落盘排查。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
