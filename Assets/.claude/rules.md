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

## UIAssets 资源路径注册规则

文件路径：`Assets/Main/LuaScripts/Global/EnumType.lua`（全局表 `UIAssets`，约 547 行起）

### 用途

`UIAssets` 是**直接实例化型 prefab 的路径常量表**，把逻辑名映射到 prefab 完整路径。
适用于通过 `ResourceManager:InstantiateAsync` / `GameObjectInstantiateAsync` / `AddComponent` 等方式**直接实例化**的 prefab：

- 列表项 / 单元格（Cell、Item）
- 场景中动态生成的 UI（血条、状态图标、气泡）
- 特效 prefab（Effect）
- 子组件 prefab

与 `UIConfig`（通过 `UIManager:OpenWindow` 打开的窗口）是**两套独立机制**，不要混用。

### 格式规则

```lua
UIAssets =
{
    UICommonItem = "Assets/Main/Prefabs/UI/Common/UICommonItem.prefab",
    MailUserItem = "Assets/Main/Prefabs/Slg/Mail/ObjMail/MailUserItem.prefab",
}
```

- 格式为 `逻辑名 = "完整 prefab 路径",`
- 缩进：4 空格
- 逻辑名：PascalCase，通常与 prefab 文件名一致
- 路径：必须是 `Assets/` 开头的完整路径，以 `.prefab` 结尾
- 路径前缀允许 `Assets/Main/Prefabs/...` 或 `Assets/_Art_LastDay/...` 等实际美术目录（不限于 UI 目录）

### 带格式化参数的路径

需要运行时拼接的路径用 `%s` 占位，配合 `string.format` 使用：

```lua
March = "Assets/Main/Prefabs/March/%s.prefab",
BuildUpgradeCompleteEffect = "Assets/Main/Prefabs/BuildEffect/BuildUpgradeCompleteEffect%s.prefab",
```

调用：`string.format(UIAssets.March, prefabName)`

### 使用方式

```lua
-- 实例化
local request = ResourceManager:InstantiateAsync(UIAssets.TroopTransUI)

-- 异步实例化
self:GameObjectInstantiateAsync(UIAssets.UIWorldTileBuildBtn, function(request) ... end)

-- 作为 AddComponent 的 prefab 路径判断
if prefabPathStr == UIAssets.UICommonResItem then ... end
```

### UIConfig vs UIAssets 选择规则

| 场景 | 用哪个 |
|------|--------|
| 通过 `UIManager:OpenWindow` 打开的独立窗口 | `UIConfig` + `UIWindowNames` |
| 直接实例化的 cell / item / 特效 / 子组件 | `UIAssets` |

### 禁止事项

1. **禁止把窗口 prefab 注册到 UIAssets**（窗口走 UIConfig）
2. **禁止把直接实例化的 cell/item 注册到 UIConfig**（它们不是窗口）
3. **禁止路径不以 `.prefab` 结尾**（除非是 `%s` 格式化模板）
4. **禁止逻辑名重复**（UIAssets 是全局唯一 key 表）
5. **新增时追加到 `UIAssets` 表内**，不要新建其他全局资源表

## VFXAssets 特效路径注册规则

文件路径：`Assets/Main/LuaScripts/Global/EnumType.lua`（全局表 `VFXAssets`，紧接 `UIAssets` 之后，约 1126 行起）

### 用途

`VFXAssets` 是**UI 特效（VFX）prefab 的路径常量表**，把逻辑名映射到特效 prefab 完整路径。
专门配合 `self:AddUIEffect` / `self:RemoveUIEffect` 使用，用于挂在 UI 节点上的粒子/动效特效：

- 按钮高亮 / 闪光特效
- 升级 / 解锁 / 战力提升动效
- 列表项 / 头像 / 进度条上的光效

与 `UIAssets`（普通实例化 prefab）、`UIConfig`（窗口）是**三套独立机制**。

### 格式规则

```lua
VFXAssets =
{
    UITopLevelUpEff = 'Assets/_Art_LastDay/Effect/Prefab/UI/UILevel/Eff_UI_level.prefab',
    UnlockNewFunctionInEff = 'Assets/_Art_LastDay/Effect/Prefab/UI/UnlockNewFunction/Eff_UnlockNewFunction_In.prefab',
}
```

- 格式为 `逻辑名 = '完整特效路径',`（注意现有代码用**单引号**，保持一致）
- 缩进：4 空格
- 逻辑名：PascalCase，建议以 `Eff` 结尾（如 `UITopLevelUpEff`、`UISonBuildCellEff`）
- 路径：特效 prefab 一般在美术特效目录下，如 `Assets/_Art_LastDay/Effect/Prefab/...` 或 `Assets/_Art_Barrel/Effect/Prefab/...`，以 `.prefab` 结尾
- 特效 prefab 命名通常以 `Eff_` / `VFX_` 开头（美术规范）
- 带运行时拼接的路径用 `%s` 占位（如 `UIMainNewPath = '.../UIPVEMain/%s.prefab'`）

### 使用方式

```lua
-- 添加特效（挂到指定父节点）
self:AddUIEffect(VFXAssets.UITopLevelUpEff, { parentNode = self.levelUpEffect })

-- 带回调
self:AddUIEffect(VFXAssets.UnlockNewFunctionInEff, { parentNode = btn }, function(obj)
    -- 特效加载完成回调
end)

-- 移除特效（用同一个 key 移除）
self:RemoveUIEffect(VFXAssets.UITopLevelUpEff)
```

`AddUIEffect` 参数表常用字段：`parentNode`（父节点）、`localScale`（缩放）。

### 三套资源表选择规则

| 场景 | 用哪个 | 配套 API |
|------|--------|----------|
| `OpenWindow` 打开的独立窗口 | `UIConfig` + `UIWindowNames` | `UIManager:OpenWindow` |
| 直接实例化的 cell / item / 子组件 | `UIAssets` | `InstantiateAsync` / `AddComponent` |
| 挂在 UI 节点上的粒子/动效特效 | `VFXAssets` | `AddUIEffect` / `RemoveUIEffect` |

### 禁止事项

1. **禁止用双引号**（VFXAssets 现有约定用单引号 `'...'`，新条目保持一致）
2. **禁止把普通 cell/item prefab 注册到 VFXAssets**（非特效走 UIAssets）
3. **禁止把特效 prefab 注册到 UIAssets**（特效走 VFXAssets，配套 AddUIEffect）
4. **禁止 AddUIEffect 后漏写 RemoveUIEffect**（特效需成对管理，避免残留）
5. **禁止逻辑名重复**（VFXAssets 是全局唯一 key 表）
6. **新增时追加到 `VFXAssets` 表内**，不要新建其他全局特效表

## SoundAssets 音效路径注册规则

文件路径：`Assets/Main/LuaScripts/Global/EnumType.lua`（全局表 `SoundAssets`，约 1438 行起）

### 用途

`SoundAssets` 是**音效路径常量表**，把逻辑名映射到音效资源路径，配合 `SUSoundUtil` 播放接口使用。
涵盖：界面音效、收取/建造音效、按钮音效、英雄/科技音效、场景音效、活动音效等。

### 格式规则

```lua
SoundAssets =
{
    Music_Effect_Open = "effect_open",          --打开界面
    Music_Effect_Button = "btn/StereoButtons",  --点击按钮
    Music_Effect_Trained = "city/TrainTroops",  --收取士兵
    SU_BuildUpgrade = "building/sounds_builder_upgrade",
}
```

- 格式为 `逻辑名 = "音效路径", -- 中文注释`（注释说明音效用途，强烈建议写）
- 缩进：4 空格
- 逻辑名：PascalCase。常见前缀：
  - `Music_Effect_`：通用业务音效（最常用）
  - `Effect_`：场景/功能特定音效
  - `Click_`：点击类音效
  - `SU_`：建造系统音效
  - `UI_`：界面专用音效

### 路径两种写法

1. **短路径**（相对 Sound 根目录，推荐）— 底层自动补全：
   ```lua
   Music_Effect_Open = "effect_open",
   Music_Effect_Button = "btn/StereoButtons",
   Music_Effect_Trained = "city/TrainTroops",
   ```
   按子目录组织：`building/`、`city/`、`ui/`、`btn/`、`world/`、`barrel_new/` 等

2. **完整路径**（需精确指定文件、扩展名时用）：
   ```lua
   UI_TerritoryTriumph_Cooper_Loop = "Assets/Main/Sound/Effect/ui/ui_territorytriumph_cooper_loop.ogg",
   ```

### 使用方式

```lua
-- 播放普通音效
SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Button)

-- 播放循环音效（播放后需 stop）
SUSoundUtil.PlayLoopEffect(SoundAssets.XXX)

-- 播放背景音乐
SUSoundUtil.PlaySound(SoundAssets.XXX)

-- 拼接动态后缀（同类多个音效）
SUSoundUtil.PlayEffect(SoundAssets.Click_Monster_Female .. tostring(index))

-- 也可直接调 C# 接口
CS.GameEntry.Sound:PlayEffect(SoundAssets.Music_Effect_Click_Enemy1)
```

### 四套全局资源表总览

| 场景 | 用哪个 | 配套 API |
|------|--------|----------|
| `OpenWindow` 打开的独立窗口 | `UIConfig` + `UIWindowNames` | `UIManager:OpenWindow` |
| 直接实例化的 cell / item / 子组件 | `UIAssets` | `InstantiateAsync` / `AddComponent` |
| 挂在 UI 节点上的粒子/动效特效 | `VFXAssets` | `AddUIEffect` / `RemoveUIEffect` |
| 音效 / 音乐 | `SoundAssets` | `SUSoundUtil.PlayEffect` / `PlaySound` |

### 禁止事项

1. **禁止硬编码音效字符串**（必须通过 `SoundAssets.XXX` 引用，不要直接传 `"effect_open"`）
2. **禁止逻辑名重复**（SoundAssets 是全局唯一 key 表）
3. **禁止循环音效播放后不 stop**（`PlayLoopEffect` 需配对停止）
4. **新增时追加到 `SoundAssets` 表内**，不要新建其他全局音效表
5. **建议每条音效加中文注释**，说明触发场景（与现有约定一致）

## DataCenter 数据层规范

文件路径：`Assets/Main/LuaScripts/DataCenter/`（注册中枢 `DataCenter.lua`）

### 核心机制

- 全局数据管理中枢，`Global.lua` 中 `DataCenter = require "DataCenter.DataCenter"`
- 访问：`DataCenter.XxxManager:Method()`，首次访问时懒加载（`require` + `New()`）并缓存
- 注册：`DataCenter.lua` 顶部 `Managers` 表 `名 = "模块路径"` + 末尾 `---@field` 注解

### 类角色与命名（后缀区分）

| 后缀 | 角色 | 基类 |
|------|------|------|
| `*Manager` / `*Data` | 管理器（注册到 DataCenter） | `BaseClass("XxxManager")` |
| `*TemplateManager` | 配置表管理器（单例） | `BaseClass("Xxx", Singleton)` |
| `*Template` | 配置行类（DataTable 一行） | `BaseClass("XxxTemplate")` |
| `*Info` | 数据实体（业务对象） | `BaseClass("XxxInfo")` |

类名 = 文件名 = BaseClass 名（三者一致）。

### 关键规则

- 生命周期：`__init(self)` 初始化字段 / `__delete(self)` 字段置 nil（一一对应，防泄漏）
- 网络回调命名：`XxxHandle`（响应）、`PushXxxHandle`（推送）；处理后 `EventManager:Broadcast` 通知 UI
- 配置解析：Info 用 `Parse(self, message)`（网络），Template 用 `InitData(self, row)`（`row:getIntValue`/`getValue`）
- 两种方法风格（`local function`+末尾导出 / `function Class:`）均可，单文件内不混用
- 高频/大表用 `createtable(narr, nrec)` 预分配

### 新增管理器两步

1. `Managers` 表加 `XxxManager = "DataCenter.Xxx.XxxManager",`（前缀可为 `DataCenter.`/`Slg.DataCenter.`/`Scene.`）
2. 末尾加 `---@field XxxManager XxxManager`

### 禁止事项

1. **禁止在 Manager 里放 UI 逻辑**（Manager 只管数据，UI 刷新走 Event 广播）
2. **禁止手动 require + New 管理器**（统一走 `DataCenter.XxxManager` 懒加载）
3. **禁止 `__init` 的字段在 `__delete` 中漏置 nil**
4. **禁止新增管理器漏加 `Managers` 注册或 `---@field` 注解**
5. **禁止把 Template 配置行类注册到 DataCenter**（由对应 TemplateManager 加载）

### LuaEntry — 核心数据入口（与 DataCenter 并列）

文件：`DataCenter/Global/LuaEntry.lua`，全局加载 `Global.lua` → `LuaEntry = require "DataCenter.Global.LuaEntry"`

- 类似 C# `GameEntry.Data`，持有最核心高频数据；与 `DataCenter`（业务模块仓库）并列、职责不同
- 核心字段：`LuaEntry.Player`（玩家）、`LuaEntry.DataConfig`（配置）、`LuaEntry.Resource`（资源）、`LuaEntry.Effect`、`LuaEntry.GlobalData`、`LuaEntry.Network`/`CrossNetwork`
- 是**冒号方法风格的单例表**（非 BaseClass）
- 生命周期 `Init/onMessage/LoadDataConfig/StartGame/EndGame/Uninit` 由框架（GameMain）调用，业务不要乱调
- 登录消息回来时 `onMessage` 会**重新 New** Player/Effect/Resource（防数据串乱）

LuaEntry 相关禁止事项：

1. **禁止缓存 `LuaEntry.Player` 等引用**（onMessage 会重建对象，须每次 `LuaEntry.Player` 直接取）
2. **禁止在 `LuaEntry:Init()` 之前访问 `LuaEntry.Player` 等字段**（未登录可能为 nil，需判空）
3. **随开局启动的 Manager 必须在 `StartGame()` 加 `Startup`、`EndGame()` 加 `Delete`**（成对）
4. **禁止把普通业务数据塞进 LuaEntry**（业务数据走 DataCenter 的 Manager，LuaEntry 只放核心未分组数据）

详细规则见 `Assets/.claude/datacenter-conventions.md`
