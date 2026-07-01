# DataCenter 编写规范

基于 `Assets/Main/LuaScripts/DataCenter/` 全目录分析（255 个模块目录，1258 个 lua 文件）总结。

---

## 一、DataCenter 是什么

`DataCenter` 是全局**数据管理中枢**，通过 `DataCenter.lua` 统一注册和懒加载所有数据管理器（Manager）。

- 全局加载：`Global.lua:57` → `DataCenter = require "DataCenter.DataCenter"`
- 访问方式：`DataCenter.XxxManager:Method()`（全局可用，无需 require）
- 数据流定位：`Network (SFS) → Manager 解析 → DataCenter 持有 → Lua 逻辑/UI 读取`

---

## 二、注册机制（DataCenter.lua）

### Managers 注册表

`DataCenter.lua` 顶部有一个 `Managers` 表，把管理器名映射到模块路径（约 509 条）：

```lua
local Managers =
{
    AccountManager = "DataCenter.AccountData.AccountManager",
    ActivityListDataManager = "DataCenter.ActivityListData.ActivityListDataManager",
    SeasonDataManager = "Slg.DataCenter.SeasonManager.SeasonDataManager",
    -- ...
}
```

### 懒加载单例机制

通过 `setmetatable` 的 `__index` 实现按需加载 + 缓存：

```lua
setmetatable(DataCenter,
    {
        __index = function(t, k)
            local manager = Managers[k]
            if manager ~= nil then
                local type = require(manager)
                local inst = type.New()   -- 首次访问时实例化
                t[k] = inst               -- 缓存，后续直接返回
                return inst
            end
            return nil
        end
    })
```

**含义**：`DataCenter.AccountManager` 首次访问时才 `require` 并 `New()`，之后复用。所以：
- 不需要手动初始化管理器
- 没访问过的管理器不会占内存

### EmmyLua 注解

`DataCenter.lua` 末尾有大量 `---@field` 注解，为每个管理器提供类型提示：

```lua
---@field AccountManager AccountManager
---@field MailDataManager MailDataManager
```

### 新增管理器的两步

1. 在 `Managers` 表中加一行：`XxxManager = "DataCenter.XxxModule.XxxManager",`
2. 在末尾 `---@field` 区加一行注解：`---@field XxxManager XxxManager`

路径前缀允许 `DataCenter.` 或 `Slg.DataCenter.`（SLG 业务）或 `Scene.`（场景相关）。

---

## 二·补、LuaEntry — 全局核心数据入口

文件：`DataCenter/Global/LuaEntry.lua`（约 517 行），全局加载 `Global.lua:61` → `LuaEntry = require "DataCenter.Global.LuaEntry"`。

### 与 DataCenter 的区别（重要）

二者是**并列的两个全局数据入口**，职责不同：

| 维度 | `DataCenter` | `LuaEntry` |
|------|-------------|-----------|
| 管理对象 | 各业务模块的 Manager（按需懒加载） | 游戏**最核心、未分组、高频**的数据 |
| 结构 | `Managers` 注册表 + 元表懒加载 | 固定字段，`Init()` 时一次性 New |
| 访问 | `DataCenter.XxxManager:Method()` | `LuaEntry.Player`、`LuaEntry.DataConfig` 等 |
| 生命周期 | 自动懒加载，`DeleteAll` 统一释放 | `LuaEntry:Init/StartGame/EndGame/Uninit` 显式管理 |
| 定位 | 业务数据仓库 | 类似 C# 的 `GameEntry.Data`，框架级入口 |

### 核心字段（高频，全局直接访问）

| 字段 | 类型 | 用途 | 引用量级 |
|------|------|------|----------|
| `LuaEntry.Player` | PlayerInfo | 玩家自身数据（uid/等级/战力等） | ~4800 |
| `LuaEntry.DataConfig` | DataConfig | 游戏配置数据 | ~2800 |
| `LuaEntry.Effect` | EffectData | 特效相关下发数据 | ~770 |
| `LuaEntry.Resource` | ResourceInfo | 玩家资源数据 | ~316 |
| `LuaEntry.GlobalData` | GlobalData | 全局杂项下发数据 | ~70 |
| `LuaEntry.Network` | NetworkManager | 主网络连接 | ~55 |
| `LuaEntry.CrossNetwork` | CrossNetworkManager | 跨服网络连接 | — |

### 生命周期方法（由 GameMain / 框架调用，业务勿乱调）

| 方法 | 职责 |
|------|------|
| `Init()` | 启动时 New 出 Player/Resource/GlobalData/DataConfig/Effect/Network 等核心对象 |
| `onMessage(data)` | 登录消息回来时**重新 New** Player/Effect/Resource 并 `InitFromNet`（防数据串乱，见文件头注释） |
| `LoadDataConfig()` | 加载本地配置表 + 初始化声音 |
| `StartGame()` | 热更后进游戏：批量 `Startup` 各 Manager/单例（建造、世界、引导、活动等） |
| `EndGame()` | 退游戏：`DataCenter:DeleteAll()` + 批量 `Delete` 各单例 |
| `Uninit()` | 释放 Player/Resource/.../Network 核心对象并置 nil |
| `InitDB()` | 初始化本地数据库（邮件、聊天） |
| `OnApplicationPause` / `ApplicationDidEnterBackground` / `ApplicationWillEnterForeground` | App 前后台切换 |
| `IsNeedReconnect()` / `IsNeedReload()` / `SyncGame()` | 重连/重载判定 |

### 关键约定

- `LuaEntry` 用**冒号方法风格**（`function LuaEntry:Xxx()`），它是单例表不是 `BaseClass`
- 登录数据回来时 `onMessage` **重新 New** Player 等对象（注释明确：每次消息回来重新 new 防串乱）—— 因此**不要缓存 `LuaEntry.Player` 引用**，每次用时通过 `LuaEntry.Player` 取
- `StartGame()` 是各 Manager 的统一 `Startup` 入口；新增需要随开局启动的 Manager，在此追加 `DataCenter.XxxManager:Startup()`，并在 `EndGame()` 对应追加 `Delete()`
- 访问 `LuaEntry.Player` 等字段前，框架须已执行 `LuaEntry:Init()`（登录前/简化流程下可能为 nil，需判空）


---

## 三、类的分类与命名

DataCenter 下的类分四种角色，按后缀命名：

| 后缀 | 角色 | 数量 | 说明 |
|------|------|------|------|
| `*Manager` | 管理器 | 418 | 注册到 DataCenter，持有数据、处理网络消息、对外提供接口 |
| `*Template` | 配置行类 | 159 | 对应数据表（DataTable）一行配置，从 row 解析 |
| `*Data` | 数据管理器 | 150 | 同 Manager（数据持有），部分模块用 Data 后缀 |
| `*Info` | 数据实体 | 129 | 纯数据载体，对应一个业务对象（如一个角色、一封邮件） |

命名规则：类名 = 文件名 = `BaseClass` 第一个参数（三者一致）。

---

## 四、类定义模板

### 基类选择

| 类型 | BaseClass 写法 |
|------|----------------|
| 普通 Manager（注册到 DataCenter） | `BaseClass("XxxManager")`（无父类） |
| 单例 Template Manager | `BaseClass("XxxTemplateManager", Singleton)` |
| Template / Info / Data 实体 | `BaseClass("XxxInfo")`（无父类） |

> 注：约 1170 处用无父类 `BaseClass("Name")`，266 处带父类（多为 Singleton）。

### 标准结构（`local function` + 末尾导出风格，主流）

```lua
---@class AccountManager
local AccountManager = BaseClass("AccountManager")
local RolesInfo = require "DataCenter.AccountData.RolesInfo"

local function __init(self)
    self.allAccount = {}
    self.param = {}
    -- 初始化所有字段
end

local function __delete(self)
    self.allAccount = nil
    self.param = nil
    -- 释放所有字段引用
end

local function InitData(self, message)
    -- 业务方法
end

-- 末尾统一导出
AccountManager.__init = __init
AccountManager.__delete = __delete
AccountManager.InitData = InitData

return AccountManager
```

### 冒号方法风格（也广泛使用）

```lua
---@class ActBattlePassTemplateManager : Singleton
local ActBattlePassTemplateManager = BaseClass("ActBattlePassTemplateManager", Singleton)

function ActBattlePassTemplateManager:__init()
    self.tempDict = createtable(0, 10)
end

function ActBattlePassTemplateManager:__delete()
    self.tempDict = nil
end

function ActBattlePassTemplateManager:InitAllTemplate()
    -- ...
end

return ActBattlePassTemplateManager
```

两种风格都可接受。**修改已有文件时跟随该文件已有风格**，不要混用。

---

## 五、生命周期方法

| 方法 | 职责 | 触发时机 |
|------|------|----------|
| `__init(self)` | 初始化所有字段（给默认值） | `New()` 时自动调用 |
| `__delete(self)` | 把所有字段置 nil，释放引用 | `Delete()` 时调用 |

规则：
- `__init` 中初始化的字段，`__delete` 中必须对应置 nil（一一对应，防内存泄漏）
- `__init`/`__delete` 使用率极高（975/908 个文件），是 DataCenter 类的标配
- `DataCenter:DeleteAll()` 会遍历调用每个已加载管理器的 `Delete()`

---

## 六、数据实体类（Info/Template）规范

### Info 类（运行时业务对象）

纯数据载体，核心方法是 `Parse`（从网络 message 解析）：

```lua
local RolesInfo = BaseClass("RolesInfo")

local function __init(self)
    self.pic = ""           -- 头像
    self.gameUserName = ""  -- 名字
    self.power = ""         -- 战力
end

local function __delete(self)
    self.pic = nil
    self.gameUserName = nil
    self.power = nil
end

local function Parse(self, message)
    if message == nil then return end
    if message["pic"] ~= nil then self.pic = message["pic"] end
    if message["gameUserName"] ~= nil then self.gameUserName = message["gameUserName"] end
    -- 字段判 nil 后赋值
end

RolesInfo.__init = __init
RolesInfo.__delete = __delete
RolesInfo.Parse = Parse
return RolesInfo
```

### Template 类（配置表一行）

对应 DataTable 一行配置，核心方法是 `InitData`（从 row 解析）：

```lua
local ActBattlePassTemplate = BaseClass("ActBattlePassTemplate")

local function __init(self)
    self.id = 0
    self.actId = 0       -- 对应活动ID
    self.level = 0       -- 通行证等级
end

local function InitData(self, row)
    if row == nil then return end
    self.id = row:getIntValue("id")
    self.actId = row:getIntValue("activity_panel_Id")
    self.level = row:getIntValue("level")
    self.free_item = row:getValue("free_item")  -- getValue 取字符串
end
```

row 取值 API：`row:getIntValue("列名")`（整数）、`row:getValue("列名")`（字符串）。

---

## 七、网络消息处理规范

Manager 是网络消息的**接收终点**。消息回调方法命名约定：

- 响应/数据处理：`XxxHandle`（如 `AccountBindHandle`、`MonsterSiegeRewardInfoHandle`）
- 服务器推送处理：`PushXxxHandle`（如 `PushMonsterAttackHandle`）

调用链：

```
Net/Msgs/XxxMessage.lua 的 HandleMessage(t)
    → DataCenter.XxxManager:XxxHandle(t)   -- 解析数据存入 Manager
    → EventManager:Broadcast(EventId.Xxx)  -- 广播事件通知 UI 刷新
```

发送消息：`SFSNetwork.SendMessage(MsgDefines.Xxx, ...)`

---

## 八、性能优化约定

- 预分配 table 用 `createtable(narr, nrec)`（XLua 提供，减少 rehash），高频/大表场景使用
- 全局模块和被其持有的引用无法 GC，`__delete` 中务必置 nil

---

## 九、目录组织

```
DataCenter/
    DataCenter.lua              -- 注册中枢（Managers 表 + 懒加载）
    {模块名}/                    -- 每个业务模块一个目录
        XxxManager.lua          -- 管理器（注册到 DataCenter）
        XxxInfo.lua             -- 数据实体
        XxxTemplate.lua         -- 配置行类
        XxxTemplateManager.lua  -- 配置表管理器（单例）
```

部分 SLG 业务管理器在 `Slg/DataCenter/` 下，场景相关在 `Scene/` 下，但都统一注册到同一个 `DataCenter.lua`。

---

## 十、禁止事项

1. **禁止在 Manager 里放 UI 逻辑**（Manager 只管数据，UI 刷新通过 Event 广播）
2. **禁止手动 require + New 管理器**（统一通过 `DataCenter.XxxManager` 懒加载）
3. **禁止 `__init` 初始化的字段在 `__delete` 中漏置 nil**（内存泄漏）
4. **禁止新增管理器时漏加 `Managers` 表注册或 `---@field` 注解**
5. **禁止类名/文件名/BaseClass 名三者不一致**
6. **禁止同一文件内混用 `local function` 导出风格和 `function Class:` 风格**
7. **禁止把配置行类（Template）注册到 DataCenter**（Template 由对应的 TemplateManager 加载）
