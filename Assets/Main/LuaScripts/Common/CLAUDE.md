# Common/
> L2 | 父级: ../../../CLAUDE.md

Lua 语言级扩展与 C# 交互封装层：补齐 Lua 原生缺失的类型/容器/数学能力，并把 UnityEngine 值类型下沉到 Lua 侧以减少跨 C# 交互开销。**与游戏逻辑无关**——业务工具在同级 `Util/`。所有模块在游戏逻辑跑之前由 `Main.lua` 统一装配（雷同 Unity Plugin）。

## 自研成员

### 目录根（语言级扩展）
Main.lua: 引导入口，require 本目录全部扩展与 Tools/UnityEngine 结构体，装配 Mathf/Vector/Color 等全局符号与 Update 心跳，是整个 Common 的总装配点。
LuaUtil.lua: Lua 全局工具核心，重点解决原生 pack/unpack 的 nil 截断（SafePack/SafeUnpack）与变参安全传递，含 IsNull/SetPointerClick 等，全项目高频依赖。
TableUtil.lua: table 语言级扩展主集，按哈希表/数组/通用三种语义补齐 count/keys/values/clone/merge/只读封装/print_r，直接注入全局 table 命名空间。
TableAdvUtil.lua: table 高级算法扩展，聚焦有序表的二分查找（binsearch）与二分插入（bininsert），与 TableUtil 分工——前者管性能敏感的有序操作。
StringUtil.lua: string 语言级扩展，把高频字符串操作注入原生 string，重点覆盖分割与多字节安全截断，部分依赖 C# 侧 string.split_ss_array 加速。
FuncUtil.lua: 全局函数杂项集，聚焦无状态短函数（类型安全转换 checknumber/BoolToInt、BuildQueryString 等）。
FSMachine.lua: 通用有限状态机基座，以 owner 为宿主管理状态注册与切换，被加载流程/业务复用以组织状态驱动逻辑。
ObjectPool.lua: 按类分桶对象池单例，以类为键复用实例降低 GC，进池前由调用方清数据；对象须实现 _class_type 与 Delete。
StringPool.lua: 字符串池，把分隔符串拆数组后提供随机与顺序轮播两种取用策略，用于台词/提示文案多样化。
ApsRandom.lua: 确定性随机数发生器，复刻 Java LCG 保证与服务器同种子同序列，用于需前后端一致的随机逻辑。
PosConverse.lua: 坐标转换封装，统一世界/屏幕/UI 局部坐标互转，屏蔽 C# RectTransformUtility 多返回值细节。
LuaProfiler.lua: Lua 侧性能剖析器，通过 debug call/return 钩子把 Lua 调用栈打进 Unity Profiler，仅调试期附加。
WatchDog.lua: 调试诊断工具，给目标表套 metatable 拦截并追踪字段写入，Release 下自动空转，排查数据被意外改写。

### Tools/（通用工具与容器，源自 tolua 已本地改造）
Tools/event.lua: 多播事件与帧心跳基座，以 list 存监听器并 xpcall 隔离回调异常，提供全局 Update 帧入口。
Tools/import.lua: 模块加载辅助，支持以 "." 前缀相对定位 require，并提供 reimport 热重载入口。
Tools/list.lua: 双向循环链表容器，O(1) 增删，提供全局迭代器 ilist/rilist，被 event 系统依赖。
Tools/queue.lua: 双端队列（deque），头尾游标实现两端高效进出。
Tools/stack.lua: 后进先出栈容器，基于 table 数组实现。
Tools/memoize.lua: 函数记忆化工具（kikito/memoize），以参数为多级键缓存纯函数结果。

### Tools/UnityEngine/（UnityEngine 值类型的纯 Lua 复刻，源自 tolua 已本地改造）
把 Unity 结构体用 Lua 表复刻并回填 CS.UnityEngine.*，减少高频值类型跨 C# 交互开销。
Tools/UnityEngine/Mathf.lua: 标量数学工具（Clamp/Lerp/Repeat 等），是各向量/四元数的数值基础。
Tools/UnityEngine/Vector2.lua: 二维向量，服务 UI/屏幕坐标与触摸位移。
Tools/UnityEngine/Vector3.lua: 三维向量，位置/方向运算核心，被 Quaternion/Ray/Plane/Bounds 依赖。
Tools/UnityEngine/Vector4.lua: 四维向量，用于 Shader 参数/齐次坐标。
Tools/UnityEngine/Quaternion.lua: 四元数，旋转组合与插值，依赖 CS.xLuaOptiUtils 优化热点。
Tools/UnityEngine/Color.lua: 浮点色彩（rgba/Lerp/运算符重载）。
Tools/UnityEngine/Color32.lua: 字节色彩（0-255 整型 rgba），内存更小的整型颜色场景。
Tools/UnityEngine/Bounds.lua: 包围盒，构造与包含/相交判定。
Tools/UnityEngine/Ray.lua: 射线（origin+direction），配合 Plane/RaycastHit 完成拾取。
Tools/UnityEngine/RaycastHit.lua: 射线命中结果，承接物理检测返回数据。
Tools/UnityEngine/Plane.lua: 平面（法向+距离），射线求交与点侧判定。
Tools/UnityEngine/LayerMask.lua: 层遮罩，层名<->位掩码互转，供射线检测与可见性筛选。
Tools/UnityEngine/Time.lua: 时间缓存，每帧由 event 的 Update 刷新 deltaTime/frameCount 快照，避免高频跨 C# 取值。
Tools/UnityEngine/Touch.lua: 触摸结构体，把移动端多点触控数据以 Lua 表暴露给输入处理。
Tools/UnityEngine/Object.lua: 空引用判定 IsNull/IsNotNull，解决 xLua 下已销毁 UnityObject 不等于 nil 的陷阱。

## 第三方（不维护 L3，勿改）
- Data/: SmartFox2X 数据序列化库（SFSArray/SFSObject/SFSDataType/SFSDataSerializer）。
- mobdebug.lua: MobDebug 远程调试器。
- protoc.lua: protobuf 编译/解析库。
- Tools/cjson/: cjson 及其 util（JSON 编解码）。
- Tools/lpeg/: LPeg 模式匹配库（re.lua）。
- Tools/socket/ 与 Tools/socket.lua: LuaSocket 网络库（ftp/http/smtp/url 等）。
- Tools/ltn12.lua、Tools/mime.lua、Tools/utf8.lua: LuaSocket 配套过滤/编码与 utf8 库。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
