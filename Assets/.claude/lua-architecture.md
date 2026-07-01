# LuaScripts 整体架构与编写规范

基于 `Assets/Main/LuaScripts/` 全目录分析（10 个顶层目录，约 9200+ 个 lua 文件）总结。
这是 Lua 层的**总纲**，各专项规则见文末「配套文档」。

---

## 一、顶层目录职责

| 目录 | 文件数级 | 职责 | 专项文档 |
|------|---------|------|----------|
| `GameMain.lua` | 1 | Lua 总入口（`Start`/`Exit`/`Protocal`） | 本文 |
| `Global/` | ~16 | 全局模块加载与全局命名空间定义 | 本文 |
| `Framework/` | ~80 | 框架层：OOP 系统、UI 基类、事件、定时器、日志 | 本文 |
| `Common/` | ~55 | Lua 语言级扩展、工具、C# 交互封装（与游戏逻辑无关） | 本文 |
| `Util/` | ~35 | 游戏业务工具类（全局 require） | 本文 |
| `DataCenter/` | ~1258 | 数据管理中枢 + 各业务 Manager | `datacenter-conventions.md` |
| `Net/` | ~1485 | 网络协议：消息定义、路由、消息类 | `rules.md`（MsgDefines/MsgMap） |
| `UI/` | ~3383 | UI 窗口（MVC：View/Controller/Component） | `ui-*.md` |
| `Slg/` | ~1774 | SLG 业务模块（UI/DataCenter/Chat/Generated 的并行体系） | 见下「Slg 说明」 |
| `Scene/` | ~716 | 场景内动态对象管理器（血条、气泡、特效、行军等） | 见下「Scene 说明」 |
| `Loading/` | ~24 | 启动加载流程、热更版本检测 | 本文 |

---

## 二、启动流程

```
C# XLuaManager → DoString → GameMain.Start()
  ↓
require "Global.Global"     -- 加载所有全局模块（在 GameMain 之前由 require 触发）
  ↓
GameMain.Start():
  1. Localization 设置语言
  2. DOTween.Init
  3. UpdateManager / EventManager / TimerManager / TimeUpManager :Startup()
  4. UIManager:GetInstance():Startup()
  5. LuaEntry:Init()                          -- 核心数据入口初始化
  6. AppStartupLoading:Start()                -- 进入 loading 流程
  → (热更检测、登录) → LuaEntry:StartGame()    -- 批量 Startup 各业务 Manager
```

关键：`LuaEntry:Init()` 之前不要访问 `LuaEntry.Player` 等核心数据（详见 datacenter-conventions.md）。

---

## 三、OOP 系统（Framework/Common）

整个 Lua 层基于自研 OOP 系统，**所有类都用 `BaseClass`**。

### BaseClass — 类定义基石

```lua
local MyClass = BaseClass("MyClass")              -- 无父类
local MyChild = BaseClass("MyChild", ParentClass) -- 继承
```

机制（`Framework/Common/BaseClass.lua`）：
- `BaseClass(name, super)` 返回类表，自带 `New(...)` 方法
- `New()` 创建实例，自动沿继承链调用 `__init`
- 实例自带 `Delete()`，沿继承链调用 `__delete`
- 类名必须是非空字符串，**类名 = 文件名 = 变量名**（三者一致）

### 生命周期约定

| 方法 | 触发 | 职责 |
|------|------|------|
| `__init(self, ...)` | `New()` 时 | 初始化所有字段 |
| `__delete(self)` | `Delete()` 时 | 所有字段置 nil（与 __init 一一对应） |

### Singleton — 单例基类

```lua
local MyMgr = BaseClass("MyMgr", Singleton)
-- 使用：MyMgr:GetInstance():Method()
```

- `GetInstance()` 懒创建单例，`Startup()` 用于启动，**均不要重写**
- 大量场景管理器用 `XxxManager:GetInstance()` 形式（区别于 DataCenter 的 `DataCenter.XxxManager`）

### 其他基类

- `DataClass` — 数据类
- `ConstClass(name, tb)` — 只读常量表（UIConfig/UIWindowNames/EnumType 等用它包装）
- `MonoClass` — Lua 模拟 MonoBehaviour
- `UIBaseView` / `UIBaseCtrl` / `UIBaseContainer` — UI 基类（见 ui-coding-conventions.md）
- `SFSBaseMessage` — 网络消息基类（见下）

---

## 四、两种方法定义风格

全项目两种风格并存，**修改文件时跟随该文件已有风格，单文件内不混用**：

### 风格 A：local function + 末尾导出

```lua
local MyClass = BaseClass("MyClass")

local function __init(self)
    self.value = 0
end

local function DoWork(self)
    -- ...
end

MyClass.__init = __init
MyClass.DoWork = DoWork
return MyClass
```

### 风格 B：冒号方法

```lua
local MyClass = BaseClass("MyClass")

function MyClass:__init()
    self.value = 0
end

function MyClass:DoWork()
    -- ...
end

return MyClass
```

所有文件末尾必须 `return 类变量`。

---

## 五、全局命名空间（Global/Global.lua）

`Global.lua` 是全局模块的**唯一加载入口**，在此 require 的模块成为全局变量，全项目无需再 require。

### 加载顺序（有依赖关系，不可随意调整）

```
1. 基础 OOP：BaseClass → DataClass → ConstClass → MonoClass
2. 基础设施：App → Setting → Config → StringLookupTable → Singleton
3. 枚举常量：EnumType → ConstDefine
4. 日志/事件：Logger → EventId → EventManager
5. 数据层：DataCenter → LuaEntry
6. 网络层：MsgDefines → SFSBaseMessage → SFSNetwork
7. 工具类：CommonUtil / UIUtil / HeroUtils / ... （大量 Util）
```

### 常用全局符号

| 全局 | 来源 | 用途 |
|------|------|------|
| `DataCenter` | DataCenter.lua | 业务数据管理中枢 |
| `LuaEntry` | Global/LuaEntry.lua | 核心数据入口（Player/DataConfig/Resource） |
| `UIManager` | Framework | UI 窗口管理 |
| `EventManager` / `EventId` | Framework | 事件广播 |
| `SFSNetwork` / `MsgDefines` | Net | 网络收发 |
| `Setting` | Global | 本地存储 |
| `Logger` | Framework | 日志 |
| `EnumType` / `UIConfig` / `UIWindowNames` | Global/UI | 枚举与配置常量 |
| `_ToID` | StringLookupTable | 字符串→int（降 GC） |
| `BindCallback` | Common/LuaUtil | 绑定 self+方法为回调 |
| `IsNull` | Common/Tools | 判 Unity 对象是否销毁 |
| `createtable(narr,nrec)` | XLua | 预分配 table（降 rehash） |

### 规则

- **新增全局工具类/单例**才在 `Global.lua` 注册；业务逻辑模块不要暴露到全局
- 注意加载顺序：被依赖的模块必须先 require

---

## 六、Common vs Util 区别

| | `Common/` | `Util/` |
|---|-----------|---------|
| 定位 | Lua 语言级扩展、C# 交互封装（与游戏逻辑无关） | 游戏业务工具 |
| 加载 | `Common/Main.lua` 在游戏逻辑前启动（类似 Plugin） | `Global.lua` 中 require |
| 例子 | TableUtil、StringUtil、ObjectPool、Vector3 封装、protoc | HeroUtils、MarchUtil、PveUtil、UIUtil |

---

## 七、Net 网络层结构

```
Net/
  Config/
    MsgDefines.lua    -- 协议命令常量表（全局只读）
    MsgMap.lua        -- 命令ID → 消息类路径 路由表
  Msgs/{分类}/
    XxxMessage.lua    -- 消息类（继承 SFSBaseMessage）
  Proto/              -- Protobuf 定义
  SFSNetwork.lua      -- 收发入口（懒加载消息类）
  SFSBaseMessage.lua  -- 消息基类
```

### 消息类模板（SFSBaseMessage）

```lua
local XxxMessage = BaseClass("XxxMessage", SFSBaseMessage)
local base = SFSBaseMessage

local function OnCreate(self, param)   -- 发送：写入 sfsObj
    base.OnCreate(self)
    self.sfsObj:PutUtfString("key", param.value)
end

local function HandleMessage(self, t)  -- 接收：解析后交给 Manager
    base.HandleMessage(self, t)
    DataCenter.XxxManager:XxxHandle(t)
end

XxxMessage.OnCreate = OnCreate
XxxMessage.HandleMessage = HandleMessage
return XxxMessage
```

新增协议三步：① `MsgDefines` 加命令常量 ② `MsgMap` 加路由 ③ `Net/Msgs/` 建消息类（详见 rules.md）。

---

## 八、Scene 说明

`Scene/` 存放**场景内动态对象的管理器**——血条、气泡、行军图标、地块特效等需要随场景生成/销毁的 UI/对象。

典型结构：

```
Scene/{模块名}/
    XxxManager.lua    -- 管理器（多为 Singleton，用 GetInstance）
    Xxx.lua           -- 单个对象/Tip 类
```

特点：管理器多走 `XxxManager:GetInstance():Startup()`，在 `LuaEntry:StartGame()` 中统一启动、`EndGame()` 中统一 Delete。

---

## 九、Slg 说明

`Slg/` 是 SLG 战略玩法的业务代码，内部是 `UI/`、`DataCenter/`、`Chat/`、`Generated/` 的**并行体系**（与顶层同名目录规则一致）：

- `Slg/UI/` — SLG 相关 UI 窗口（UIConfig 路径前缀 `Slg.UI.`）
- `Slg/DataCenter/` — SLG 相关数据管理器（Managers 注册路径前缀 `Slg.DataCenter.`）
- `Slg/Chat/` — 聊天系统
- `Slg/Generated/` — **工具自动生成的代码（带 `Gen` 后缀），不要手改**

规则与顶层 UI/DataCenter 完全一致，只是命名空间前缀不同。

---

## 十、通用编码规范

### 命名

| 对象 | 规则 | 示例 |
|------|------|------|
| 模块/类名 | PascalCase，= 文件名 = BaseClass 名 | `UIBagView`、`AccountManager` |
| 全局变量 | PascalCase | `DataCenter`、`LuaEntry` |
| 局部变量 | camelCase | `itemList`、`curIndex` |
| 私有函数（local） | PascalCase 或 camelCase | `DoWork`、`__init` |
| 常量表 | PascalCase（ConstClass 包装） | `UIWindowNames`、`EnumType` |

### 性能

- 高频字符串传 C# 用 `_ToID(str)`（驻留为 int，降 GC）
- 高频/大表用 `createtable(narr, nrec)` 预分配
- 用对象池 `ObjectPool`，gameplay 对象不直接 Instantiate/Destroy
- 全局模块持有的引用无法 GC，`__delete` 必须置 nil

### 回调与判空

- 绑定回调用 `BindCallback(self, self.Method)`，避免每次创建闭包
- 操作 Unity 对象前用 `IsNull(obj)` 判断是否已销毁

### 错误处理

- 网络消息处理包在 `xpcall` 中（SFSNetwork 已封装），单条消息崩溃不影响整体

---

## 十一、禁止事项（全局级）

1. **禁止不用 BaseClass 裸写类**（所有类走 OOP 系统）
2. **禁止类名/文件名/BaseClass 名不一致**
3. **禁止单文件内混用两种方法定义风格**
4. **禁止漏写文件末尾 `return 类变量`**
5. **禁止 `__init` 字段在 `__delete` 中漏置 nil**（内存泄漏）
6. **禁止把业务逻辑模块暴露到全局命名空间**（只有工具/单例/常量才进 Global.lua）
7. **禁止手改 `Slg/Generated/` 下的 `*Gen.lua`**（工具生成）
8. **禁止新建顶层目录**（固定 10 个：Common/DataCenter/Framework/Global/Loading/Net/Scene/Slg/UI/Util）
9. **禁止破坏 Global.lua 的 require 加载顺序**（有依赖关系）

---

## 配套文档

| 主题 | 文档 |
|------|------|
| 编码规范总表 + 各资源表（UIConfig/UIAssets/VFXAssets/SoundAssets/MsgDefines）+ DataCenter/LuaEntry | `rules.md` |
| 项目参考（核心类、代码片段、UI 路由） | `reference.md` |
| UI 目录结构（标准 MVC/平铺/分组/公共组件） | `ui-directory-structure.md` |
| UI 代码编写规范（View/Ctrl/Component 模板） | `ui-coding-conventions.md` |
| DataCenter 数据层 + LuaEntry 核心入口 | `datacenter-conventions.md` |
