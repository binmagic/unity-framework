# Global/
> L2 | 父级: ../../../CLAUDE.md

全局模块的加载入口与全局命名空间。Global.lua 是唯一的加载脚本，决定"哪些模块是全局的"并按严格依赖顺序注入命名空间；其余成员是被全局持有的基础设施（应用信息、本地化、存储、缓存、事件监听基类、HTTP、字符串驻留）与全局资源/枚举总表。

## 成员清单
Global.lua: 全局模块唯一加载入口，按依赖顺序 require Framework/Common/Util 与本模块成员，把 App/Setting/DataCenter/LuaEntry/UIManager/MsgDefines 等注入全局；无返回值，改动即牵动全局加载链
App.lua: 应用环境信息中枢，缓存 C# 侧平台/版本/包名/设备/调试态查询为只读快照，并含旧 AssetBundle 清理
EnumType.lua: 全局资源与枚举总表，注入 UIConfig/UIAssets/VFXAssets/SoundAssets 及 ProxyList/LoginErrorMessage 等；全项目 prefab/特效/音效/错误码的唯一登记处，地位特殊，加载于依赖链末段
Config.lua: 静态配置常量表，收口 Config.Debug 等编译期开关
Cache.lua: 运行期缓存汇集点，Animator 哈希与 state 字符串复用，可随重启清理
Localization.lua: 本地化门面，Lua 侧缓存 id→字符串省去反复 C# 往返；字符串总表仍在 C#
SettingManager.lua: 客户端本地存储门面，_ToID 驻留 key 减 GC，Private 组按 uid 隔离玩家存档，无前缀旧接口废弃保留
StringLookupTable.lua: 字符串驻留表，str→id 复用压低 Lua↔C# 传值 GC；其 Get 被赋给全局 _ToID
LazyTemplate.lua: 表格惰式解析基类，用元表把大配置表结构化延迟到首访，以启动效率换运行期开销
ListenerHandler.lua: 事件监听基类，把 EventManager 裸订阅封装成随对象生命周期自动清理的持有者
SingletonListenerHandler.lua: 单例版事件监听基类，供全局唯一管理器复用同一套自动清理订阅逻辑
LuaWebRequest.lua: Lua 侧 HTTP 请求封装，包装 UnityWebRequest 为带超时/回调/证书旁路的对象，使用方在 OnUpdate 驱动
UnityUtils.lua: Unity 零散工具集，直接挂全局的轻量 GameObject 辅助函数（如 SetGameObjectDebugName）

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
