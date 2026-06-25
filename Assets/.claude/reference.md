# Barrel (Survivor) 项目参考文档

## 核心类参考

### GameEntry — 全局入口静态类

**文件**: `Assets/Main/Scripts/Framework/GameEntry.cs`

所有核心管理器的统一访问入口：

```csharp
public static class GameEntry
{
    // 基础设置
    public static BaseComponent GameBase { get; }
    // 事件订阅
    public static EventComponent Event { get; }
    // UI 容器
    public static Transform UIContainer { get; }
    // 资源管理
    public static ResourceManager Resource { get; }
    // 本地化
    public static LocalizationManager Localization { get; }
    // 网络连接
    public static NetworkManager Network { get; }
    // 声效管理
    public static SoundComponent Sound { get; }
    // 客户端设置存储
    public static SettingManager Setting { get; }
    // Lua脚本管理
    public static XLuaManager Lua { get; }
    // shader管理器
    public static ShaderManager Shader { get; }
    // 玩家数据
    public static CustomDataManager Data { get; }
    // pb预处理
    public static PBController pb { get; }
    // 定时器
    public static TimerComponent Timer { get; }
    // 全局数据
    public static GlobalDataManager GlobalData { get; }
    // 原生系统SDK
    public static SDKManager Sdk { get; }
    // 设备信息
    public static DeviceManager Device { get; }
    // 建筑动画
    public static BuildAnimatorManager BuildAnimatorManager { get; }
    // 配置缓存
    public static ConfigCache ConfigCache { get; }

    // 初始化方法
    public static void Init();
    public static void InitUIContainer();
    public static void RegisterComponent(GameFrameworkComponent com);
}
```

---

### ApplicationLaunch — 游戏启动入口

**文件**: `Assets/Main/Scripts/Application/ApplicationLaunch.cs`

游戏启动 MonoBehaviour，挂载在 `Launch.unity` 场景：

```csharp
public class ApplicationLaunch : MonoBehaviour
{
    public static ApplicationLaunch Instance { get; }
    public static InstanceRequest uiLoadingRequest;
    public bool IsNeedCheckResVer { get; set; }

    // 主要功能：
    // 1. 检测屏幕方向/布局
    // 2. 深度链接处理
    // 3. 热更资源下载
    // 4. 初始化 GameEntry
}
```

---

### XLuaManager — Lua 脚本管理器

**文件**: `Assets/Main/Scripts/XLua/XLuaManager.cs`

管理 Lua 虚拟机和 Lua 脚本的加载执行：

```csharp
public partial class XLuaManager
{
    // Lua 根路径
    private static readonly string[] LuaRootPath_portrait;
    private static readonly string[] LuaRootPath_landscape;
    private static readonly string[] LuaRootPathEditor_portrait;
    private static readonly string[] LuaRootPathEditor_landscape;

    // 常量
    private const string CommonMainScriptName = "Common.Main";
    private const string GameMainScriptName = "GameMain";

    // Lua 环境
    private LuaEnv m_LuaEnv;
    private Action<float, float> luaUpdate;
}
```

---

## Lua 框架参考

### UIManager — UI 管理器

**文件**: `Assets/Main/LuaScripts/Framework/UI/UIManager.lua`

管理所有 UI 窗口的创建、显示、隐藏、销毁：

```lua
---@class UIManager:Singleton
local UIManager = BaseClass("UIManager", Singleton)

-- UI 层级顺序
local LayerOrder = {
    "Scene", "Background", "UIResource", "Normal",
    "Info", "Dialog", "Guide", "TopMost", "TopCanvas"
}

-- 窗口状态
local WindowState = {
    Create = 0,
    Loading = 1,
    Open = 2,
    Close = 3,
    Destroying = 4
}

-- 主要方法
function UIManager:CreateWindow(windowType, ...)
function UIManager:OpenWindow(windowType, ...)
function UIManager:CloseWindow(windowType)
function UIManager:DestroyWindow(windowType)
function UIManager:GetWindow(windowType)
function UIManager:IsWindowOpen(windowType)
```

---

### UIBaseView — UI 视图基类

**文件**: `Assets/Main/LuaScripts/Framework/UI/Base/UIBaseView.lua`

所有 UI 视图的基类，采用 MVC 模式：

```lua
-- MVC 结构
UIBaseView   -- 视图层（负责显示）
UIBaseModel  -- 数据模型层（负责数据）
UIBaseCtrl   -- 控制器层（负责逻辑）

-- 生命周期方法
function UIBaseView:OnCreate()      -- 创建时
function UIBaseView:OnEnable()      -- 启用时
function UIBaseView:OnDisable()     -- 禁用时
function UIBaseView:OnDestroy()     -- 销毁时
function UIBaseView:OnRefresh()     -- 刷新时
```

---

### EventManager — 事件管理器

**文件**: `Assets/Main/LuaScripts/Framework/UI/Message/EventManager.lua`

全局事件系统：

```lua
local EventManager = BaseClass("EventManager", Singleton)

-- 主要方法
function EventManager:AddListener(eventId, callback)
function EventManager:RemoveListener(eventId, callback)
function EventManager:Dispatch(eventId, ...)
function EventManager:DispatchCSEvent(eventId, userData)
```

---

### UI 组件类型

**路径**: `Assets/Main/LuaScripts/Framework/UI/Component/`

| 组件 | 说明 |
|---|---|
| `UITextMeshProUGUI` | TextMeshPro 文本 |
| `UITextMeshProUGUIEx` | 扩展 TMP 文本 |
| `UIText` | 普通文本 |
| `UINewText` | 新版文本 |
| `UINewTMPText` | 新版 TMP 文本 |
| `UIImage` | 图片 |
| `UIRawImage` | 原始图片 |
| `UIButton` | 按钮 |
| `UIButton_LongPress` | 长按按钮 |
| `UISlider` | 滑动条 |
| `UIInput` | 输入框 |
| `UIToggle` | 开关 |
| `UIUnlimitedScrollView` | 无限滚动视图 |
| `UICanvas` | 画布 |
| `UILayerComponent` | 层级组件 |

---

## 场景系统参考

### 城市场景 (City)

**路径**: `Assets/Main/Scripts/Scene/City/`

功能：
- 建筑建造和升级
- LOD 管理
- 材质切换
- 渲染优化

### 世界地图 (World)

**路径**: `Assets/Main/Scripts/Scene/World/`

功能：
- 区块化管理（WorldScene）
- 摄像机控制（WorldCamera）
- 建筑管理（WorldBuilding）
- 地形系统（WorldTerrain）
- 行军系统（March）
- LOD 系统
- 战争迷雾（FogOfWar）

### PVE 战斗系统

**路径**: `Assets/Main/Scripts/Scene/PVE/`

功能：
- 寻路网格（FIGridManager）
- 技能指示器（SkillIndicator）
- 子弹运动（BulletMotion）
- RVO 碰撞避让（RVO/）

---

## 网络协议参考

### Protobuf 消息

**路径**: `Assets/Main/Proto/`

主要消息类型：
- `AllianceCityRecordProto` — 联盟城市记录
- `ArmyUnitInfo` — 军队单位信息
- `BattleReport` — 战斗报告
- `BattleRoundPush` — 战斗回合推送
- `Mail` — 邮件
- `WorldPointInfo` — 世界点信息

### SmartFox 协议

使用 SmartFox2X 作为主要服务端通信协议。

### 跨服网络

`CrossNetworkManager` 支持跨服通信。

---

## 数据表参考

### 数据表位置

**路径**: `Assets/Main/DataTable/`

数据表使用 Excel 格式，通过 `Xlsx2json` 工具转换为 JSON 格式。

### 本地化文件

**路径**: `Assets/Main/DataTable/Localization/`

支持 16 种语言：
- Arabic (阿语)
- ChineseSimplified (简体中文)
- ChineseTraditional (繁体中文)
- English (英语)
- French (法语)
- German (德语)
- Italian (意大利语)
- Japanese (日语)
- Korean (韩语)
- PortuguesePortugal (葡萄牙语)
- Russian (俄语)
- Spanish (西班牙语)
- Thai (泰语)
- Turkish (土耳其语)
- Vietnamese (越南语)

---

## 工具参考

### 构建工具

**路径**: `Tools/`

| 工具 | 说明 |
|---|---|
| `Python27/` | Python 2.7 运行环境 |
| `LuaC/` | Lua 编译器 |
| `Xlsx2json/` | Excel 转 JSON 工具 |
| `gradle/` | Gradle 构建工具（多版本） |
| `jenkins/` | Jenkins CI/CD 配置 |

### 编辑器工具

**路径**: `Assets/Editor/`

| 工具 | 说明 |
|---|---|
| `AmplifyShaderEditor` | 可视化 Shader 编辑器 |
| `MeshBaker` | 网格合并/烘焙 |
| `T4M` | 地形转 Mesh 工具 |
| `Octave3D` | 3D 世界构建 |
| `MantisLODEditor` | LOD 编辑 |
| `PrefabPainter` | 预制体绘制 |
| `ReferenceFinder` | 引用查找 |
| `LuaProfiler` | Lua 性能分析 |
| `Asset Cleaner` | 资源清理 |

---

## URP 渲染配置参考

### 渲染管线资产

**路径**: `Assets/Main/URPSettings/`

| 资产 | 说明 |
|---|---|
| `UniversalRenderPipelineAsset_High.asset` | 高画质配置 |
| `UniversalRenderPipelineAsset_cheku.asset` | 车库专用配置 |
| `Universal Render Pipeline Asset-2D.asset` | 2D 渲染配置 |
| `SceneRenderingSetting.asset` | 场景渲染设置 |

### 后处理效果

项目支持多种后处理效果：
- TAA（时间抗锯齿）
- 体积雾（VolumetricFog）
- 高度雾（HeightFog）
- 上帝之光（Godrays）
- 雨效（Rain）
- 景深模糊（DepthBlur）
- 平面反射（PlanarReflections）
- 移轴镜头（TiltShift）

---

## SDK 集成参考

### 平台 SDK

**路径**: `Assets/Main/Scripts/Framework/SDKManager/`

| SDK | 说明 |
|---|---|
| Android SDK | Android 平台支持 |
| iOS SDK | iOS 平台支持 |
| Editor SDK | 编辑器环境支持 |
| Standalone SDK | 独立平台支持 |

### 第三方 SDK

| SDK | 说明 |
|---|---|
| AppsFlyer | 移动归因/分析 |
| Zendesk | 客服系统 |
| Firebase | 推送和分析 |

---

## 文档参考

### 项目文档

**路径**: `Docs/`

| 文档 | 说明 |
|---|---|
| `客户端启动流程/` | 启动流程详细说明 |
| `数据库/` | 客户端数据库接口文档 |
| `XLua文档/` | XLua 使用文档 |
| `功能文档/` | 各功能模块文档 |
| `动更发布流程/` | 热更新发布流程 |
| `美术规范文档/` | 美术资源规范 |
| `Shader使用说明/` | Shader 使用说明 |
| `Xlsx转Json文档/` | 数据表转换文档 |
| `客户端指南.docx` | 客户端开发指南 |
| `客户端打包文档.docx` | 打包流程文档 |

---

## 常用代码片段

### C# 访问 Lua

```csharp
// 获取 Lua 环境
LuaEnv luaEnv = GameEntry.Lua.GetLuaEnv();

// 调用 Lua 函数
luaEnv.DoString("GameMain.Start()");

// 获取 Lua 全局变量
int value = luaEnv.Global.Get<int>("globalVar");
```

### Lua 访问 C#

```lua
-- 访问 C# 静态类
local GameObject = CS.UnityEngine.GameObject
local ResourceManager = CS.GameEntry.Resource

-- 创建 C# 对象
local go = GameObject("NewObject")

-- 调用 C# 方法
ResourceManager:LoadAsset("path", function(asset)
    -- 回调
end)
```

### 事件订阅

```lua
-- Lua 事件订阅
EventManager:GetInstance():AddListener(EventId.XXX, function(data)
    -- 处理事件
end)

-- C# 事件订阅
GameEntry.Event.Subscribe(EventArgs, (sender, args) =>
{
    // 处理事件
});
```

### UI 窗口创建

```lua
-- 定义 UI 窗口
local MyWindow = BaseClass("MyWindow", UIBaseView)

-- 生命周期
function MyWindow:OnCreate()
    -- 创建时初始化
end

function MyWindow:OnEnable()
    -- 启用时刷新
end

function MyWindow:OnDisable()
    -- 禁用时清理
end

-- 打开窗口
UIManager:GetInstance():OpenWindow(MyWindow)
```

---

## UI 系统架构（注册与路由）

### 文件关系图

```
UIWindowNames.lua     UIConfig.lua           UI/XXX/Config.lua
───────────────────   ──────────────────     ──────────────────
Name = "Name",   →   [UIWindowNames.Name]   →  { Name, Layer, Ctrl,
                      = "UI.XXX.Config"          View, PrefabPath }
```

### UIManager 打开窗口流程

```
UIManager:OpenWindow(UIWindowNames.XXX, ...)
  → UIConfig[UIWindowNames.XXX]           -- 得到 Config 路径字符串
  → require("UI.XXX.Config")              -- 懒加载 Config 模块
  → config = { Name, Layer, Ctrl, View, PrefabPath }
  → window.Ctrl = config.Ctrl.New()       -- 实例化控制器
  → window.View = config.View.New(...)    -- 实例化视图
  → 加载 PrefabPath 的 Prefab
```

### 目录与路径对应关系

| UIConfig 路径前缀 | 物理目录 |
|---|---|
| `"UI.XXX.Config"` | `LuaScripts/UI/XXX/Config.lua` |
| `"Slg.UI.XXX.Config"` | `LuaScripts/Slg/UI/XXX/Config.lua` |

不存在其他前缀。

---

## 性能监控

### Graphy 性能面板

项目集成了 Graphy 性能监控面板，可以监控：
- FPS（帧率）
- 内存使用
- CPU 使用
- GPU 使用
- 网络状态

### GFX 调试控制台

**路径**: `Assets/Main/Scripts/GFX/Console/`

内置图形调试控制台，支持：
- FPS 监控
- Camera 调试
- PostProcess 调试
- Quality 设置
- Shader 查看
- Shadow 调试

### Lua Profiler

**路径**: `Assets/Editor/LuaProfiler/`

Lua 性能分析工具，用于分析 Lua 代码的性能瓶颈。
