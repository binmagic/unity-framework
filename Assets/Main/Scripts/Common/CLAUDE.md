# Common/
> L2 | 父级: ../../../CLAUDE.md

C# 通用层：与具体业务无关的基础设施，被框架层与业务层共同复用。分六个子目录，各司一职。

## 成员清单
Component/: 通用 UI 组件（~35 文件），可复用的挂载式 MonoBehaviour 控件与交互部件
UIExtension/: UI 扩展（~65 文件），对 uGUI/TMP 的增强控件、布局器与视觉扩展
Utils/: 工具集（16 文件，含 AES/ 自研加密子目录），加解密/文件/路径/字符串/贝塞尔/头像 URL 等无状态静态工具，C# 与 Lua 共享
Log/: 日志系统（4 文件），Log 门面 + LogLevel 分级 + LogFile 落盘 + PostEventLog 运营埋点上报
Opti/: 性能优化（5 文件），面向 Unity 老 GC 与 xLua 交互开销的 0-GC 扩展、字符串驻留表、向量运算下沉
Other/: 杂项设施（8 文件），对象池/单例基类/后台线程/协程任务/Lua 剖析/IL2CPP 编译特性/Lua 字符串格式化

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
