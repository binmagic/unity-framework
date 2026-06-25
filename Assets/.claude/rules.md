# Barrel (Survivor) 项目编码规范

## 通用规则

### 1. 文件组织
- **C# 代码**: 位于 `Assets/Main/Scripts/`（Git 子模块）
- **Lua 代码**: 位于 `Assets/Main/LuaScripts/`
- **数据表**: 位于 `Assets/Main/DataTable/`（Git 子模块）
- **编辑器扩展**: 位于 `Assets/Editor/`
- **第三方库**: 位于 `Assets/Main/Scripts/3rdParty/`

### 2. 命名规范

#### C# 命名
- **类名**: PascalCase（如 `GameEntry`, `ApplicationLaunch`）
- **公共方法**: PascalCase（如 `Init()`, `GetResource()`）
- **私有方法**: PascalCase（如 `OnDeepLinkActivated()`）
- **私有字段**: m_ 前缀 + PascalCase（如 `m_ScreenWidth`, `m_LuaEnv`）
- **静态字段**: PascalCase（如 `_instance`）
- **常量**: PascalCase（如 `LuaRootPath_portrait`）
- **接口**: I 前缀 + PascalCase
- **委托**: PascalCase + Delegate 后缀（如 `onApplicationPause`）

#### Lua 命名
- **模块名**: PascalCase（如 `UIManager`, `EventManager`）
- **局部变量**: camelCase
- **全局变量**: PascalCase（如 `GameMain`, `Logger`）
- **常量**: UPPER_SNAKE_CASE
- **私有函数**: 以小写字母开头

### 3. 命名空间
- C# 代码使用 `GameFramework` 和 `UnityGameFramework.Runtime` 命名空间
- Lua 代码通过 `CS.xxx` 访问 C# 命名空间

---

## C# 编码规范

### 1. 类结构
```csharp
using System;
using UnityEngine;

public class ExampleClass : MonoBehaviour
{
    // 常量
    private const int MaxCount = 100;

    // 静态字段
    private static ExampleClass _instance;

    // 公共属性
    public static ExampleClass Instance => _instance;

    // 私有字段（m_ 前缀）
    private int m_Value;
    private bool m_IsActive;

    // Unity 生命周期
    void Awake()
    {
        _instance = this;
    }

    void Update()
    {
        // 更新逻辑
    }

    // 公共方法
    public void DoSomething()
    {
        // 实现
    }

    // 私有方法
    private void InternalMethod()
    {
        // 实现
    }
}
```

### 2. 单例模式
项目中广泛使用单例模式，通过 `GameEntry` 静态类访问：
```csharp
// 访问方式
GameEntry.Resource.LoadAsset(...);
GameEntry.Network.Send(...);
GameEntry.Timer.AddTimer(...);
```

### 3. IL2CPP 优化
对于需要 IL2CPP 优化的类，使用特性：
```csharp
[Unity.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
public static class GameEntry
{
    // ...
}
```

### 4. XLua 桥接
C# 调用 Lua 使用委托：
```csharp
[CSharpCallLua]
public delegate void onApplicationPause(bool pause);
```

---

## Lua 编码规范

### 1. 模块定义
```lua
-- 使用 local 定义模块
local ModuleName = {}

-- 私有函数
local function privateFunc()
    -- 实现
end

-- 公共函数
function ModuleName:PublicFunc()
    -- 实现
end

return ModuleName
```

### 2. 类定义
使用 `BaseClass` 定义类：
```lua
---@class UIManager:Singleton
local UIManager = BaseClass("UIManager", Singleton)

-- 构造函数
local function __init(self)
    -- 初始化
end

-- 析构函数
local function __delete(self)
    -- 清理
end

UIManager.__init = __init
UIManager.__delete = __delete

return UIManager
```

### 3. 单例模式
```lua
local UIManager = BaseClass("UIManager", Singleton)

-- 获取单例
local uiMgr = UIManager:GetInstance()
```

### 4. 访问 C# 代码
```lua
-- 访问 C# 静态类
local ResourceManager = CS.GameEntry.Resource
local GameObject = CS.UnityEngine.GameObject

-- 调用 C# 方法
ResourceManager:LoadAsset(...)
GameObject.Find(...)
```

### 5. 事件系统
```lua
-- 订阅事件
EventManager:GetInstance():AddListener(EventId.XXX, callback)

-- 派发事件
EventManager:GetInstance():Dispatch(EventId.XXX, data)
```

### 6. UI 组件
```lua
-- UI 组件类型
UITextMeshProUGUI    -- 文本
UIImage              -- 图片
UIButton             -- 按钮
UISlider             -- 滑动条
UIInput              -- 输入框
UIToggle             -- 开关
UIUnlimitedScrollView -- 无限滚动视图
```

---

## UI 开发规范

### 1. UI 层级
UI 层级从低到高：
1. `Scene` — 场景层
2. `Background` — 背景层
3. `UIResource` — 资源层
4. `Normal` — 普通层
5. `Info` — 信息层
6. `Dialog` — 对话框层
7. `Guide` — 引导层
8. `TopMost` — 最顶层
9. `TopCanvas` — 顶层画布

### 2. UI 窗口状态
```lua
WindowState = {
    Create = 0,
    Loading = 1,
    Open = 2,
    Close = 3,
    Destroying = 4
}
```

### 3. UI 打开选项
```lua
Default_OpenOptions = {
    anim = true,
    UIMainAnim = UIMainAnimType.AllHide
}
```

---

## 资源管理规范

### 1. 资源加载
```csharp
// C# 方式
GameEntry.Resource.LoadAsset("path/to/asset", callback);

// Lua 方式
CS.GameEntry.Resource:LoadAsset("path/to/asset", callback)
```

### 2. 对象池
使用 `ObjectPoolManager` 管理对象池：
```csharp
GameEntry.Resource.GetObjectFromPool(...);
GameEntry.Resource.ReturnObjectToPool(...);
```

### 3. AssetBundle
- 使用 `XAssetPro` 进行资源管理
- 支持热更新

---

## 网络规范

### 1. 消息定义
- 使用 Protobuf 定义消息格式
- 消息文件位于 `Assets/Main/Proto/`

### 2. 网络通信
```csharp
// C# 方式
GameEntry.Network.Send(message);

// Lua 方式
NetworkManager:GetInstance():Send(message)
```

### 3. SmartFox 协议
主要使用 SmartFox2X 协议进行服务端通信。

---

## 性能优化规范

### 1. 渲染优化
- 使用 LOD 系统
- 视锥剔除（CullingObj）
- GPU Skinning
- Batch 渲染优化

### 2. 内存管理
- 使用对象池
- 及时释放不用的资源
- 使用 `Graphy` 监控性能

### 3. Lua 优化
- 避免频繁的 C#/Lua 交互
- 使用局部变量缓存全局访问
- 避免在 Update 中创建新对象

---

## 调试规范

### 1. 日志系统
```csharp
// C# 日志
Debug.Log("message");
Log.Info("message");

// Lua 日志
Logger.Log("message")
Logger.LogError("message")
```

### 2. 图形调试
项目内置 GFX 控制台（`Assets/Main/Scripts/GFX/Console/`），支持：
- FPS 监控
- Camera 调试
- PostProcess 调试
- Quality 设置
- Shader 查看
- Shadow 调试

### 3. Lua 调试
- 使用 `LuaProfiler` 进行性能分析
- 支持 `mobdebug` 远程调试

---

## 构建规范

### 1. Android 构建
- 使用 Gradle 构建
- 工程位于 `proj_android/`
- 支持多 Gradle 版本（5.6.4/6.5/6.8）

### 2. iOS 构建
- 使用 Xcode 工程
- 工程位于 `proj_xcode/`

### 3. 热更新
- 使用 XAssetPro 进行资源热更
- 动更发布流程参考 `Docs/动更发布流程/`

---

## 注意事项

1. **Git 子模块**: Scripts 和 DataTable 是独立的 Git 子模块，修改时需要提交到对应的子模块仓库
2. **启动场景**: `Assets/Launch.unity` 是唯一的启动场景
3. **本地化**: 支持 16 种语言，阿拉伯语需要 RTL 适配
4. **横屏模式**: 游戏主要以横屏模式运行
5. **Linear 色彩空间**: 项目使用 Linear 色彩空间
6. **URP 管线**: 使用 Universal Render Pipeline，不要使用 Built-in 管线的 API

---

## Lua UI 模块注册规则

### UIWindowNames.lua 格式

文件路径：`Assets/Main/LuaScripts/UI/Config/UIWindowNames.lua`

规则：
- 格式为 `Name = "Name",`（key 与 value 必须是相同的字符串）
- 缩进：4 空格
- 每行一个条目，逗号结尾
- 可加注释分组（`-- 模块名`）
- 最终通过 `ConstClass` 包装为只读表

正确示例：
```lua
    -- 连连看游戏
    LianLianMain = "LianLianMain",
    LianLianPlay = "LianLianPlay",
    LianLianWin = "LianLianWin",
```

错误示例（绝对禁止）：
```lua
-- ❌ 不要用 UIConfig 的映射格式
[UIWindowNames.LianLianMain] = "Game.LianLian.UI.LianLianMain.Config",
-- ❌ 不要 key 和 value 不同名
LianLianMain = "lianLianMain",
```

### UIConfig.lua 格式

文件路径：`Assets/Main/LuaScripts/UI/Config/UIConfig.lua`

规则：
- 格式为 `[UIWindowNames.XXX] = "路径.Config",`
- 缩进：1 个 tab
- 路径前缀**只允许** `UI.` 或 `Slg.UI.`
- 路径对应的物理目录在 `LuaScripts/UI/` 或 `LuaScripts/Slg/UI/` 下
- 不允许自创命名空间（如 `Game.`、`MiniGame.`、`Module.`）

路径格式规则：
- 单层：`"UI.{窗口名}.Config"` — 对应 `LuaScripts/UI/{窗口名}/Config.lua`
- 多层：`"UI.{模块组}.{窗口名}.Config"` — 对应 `LuaScripts/UI/{模块组}/{窗口名}/Config.lua`
- Slg：`"Slg.UI.{模块组}.{窗口名}.Config"` — 对应 `LuaScripts/Slg/UI/{模块组}/{窗口名}/Config.lua`

正确示例：
```lua
	[UIWindowNames.LianLianMain] = "UI.LianLian.LianLianMain.Config",
	[UIWindowNames.UIBagView] = "UI.UIBagView.Config",
	[UIWindowNames.UIAllianceMainTable] = "Slg.UI.UIAlliance.UIAllianceMainTable.Config",
```

错误示例（绝对禁止）：
```lua
-- ❌ 路径前缀不允许 Game.
[UIWindowNames.LianLianMain] = "Game.LianLian.UI.LianLianMain.Config",
-- ❌ 路径前缀不允许自创命名空间
[UIWindowNames.XXX] = "MiniGame.XXX.Config",
```

### Config.lua 文件模板

每个 UI 窗口的 Config.lua 必须包含以下字段：

```lua
local MyWindow = {
    Name = UIWindowNames.MyWindow,
    Layer = UILayer.Normal,
    Ctrl = require "UI.MyModule.MyWindow.Controller.MyWindowCtrl",
    View = require "UI.MyModule.MyWindow.View.MyWindowView",
    PrefabPath = "Assets/Main/Prefabs/UI/MyModule/MyWindow.prefab",
}

return {
    MyWindow = MyWindow,
}
```

### LuaScripts 允许的顶层目录（不可新增）

```
LuaScripts/
  Common/  DataCenter/  Framework/  Global/  Loading/
  Net/  Scene/  Slg/  UI/  Util/
```

新增 UI 模块的 Lua 代码只能放在 `UI/` 或 `Slg/UI/` 下。

### 新增 UI 窗口 checklist

1. `UIWindowNames.lua` 添加：`MyWindow = "MyWindow",`
2. `UIConfig.lua` 注册：`[UIWindowNames.MyWindow] = "UI.MyModule.MyWindow.Config",`
3. 创建目录 `LuaScripts/UI/MyModule/MyWindow/`，包含 Config.lua、Controller/、View/
4. Config.lua 包含 Name、Layer、Ctrl、View、PrefabPath
5. Prefab 放在 `Assets/Main/Prefabs/UI/` 或 `Assets/Main/Prefabs/Slg/UI/` 下

### UI 目录结构规则

详见 `Assets/.claude/ui-directory-structure.md`，核心要点：

- **标准 MVC 模式**（84%，472个）：有 View/ 子目录，可选 Controller/ 和 Component/
- **平铺模式**（10个）：简单弹窗，Config.lua + XxxView.lua 平铺，Ctrl = nil，无子目录
- **分组目录**（44个）：功能模块聚合，本身无 Config.lua，子窗口各自独立
- **公共组件**（34个）：无 Config.lua，不注册到 UIConfig，被其他模块 require

选择规则：
- 有 Controller 逻辑 → 必须用标准 MVC（View/ + Controller/）
- 无 Controller 且文件数 ≤ 2 → 可用平铺模式
- 相关窗口 ≥ 3 个 → 用分组目录聚合
- 不是独立窗口 → 公共组件目录（不注册 UIConfig）
